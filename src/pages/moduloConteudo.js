// src/pages/moduloConteudo.js
// Sprint 3 (2026-07-08): fecha o ciclo de progresso da lição.
//   - Ao carregar, busca lesson_progress do módulo e marca visualmente as
//     lições já concluídas (a versão anterior sempre renderizava todas como
//     pendentes, ignorando o histórico).
//   - Barra de progresso do módulo no topo, alimentada por moduleService.
//   - Botão "concluir" agora chama completeLesson (RPC atômica) em vez de
//     markLessonComplete direto — grava lesson_progress + points_ledger +
//     atualiza profiles.performance_score em uma transação.
//   - Ao sucesso, atualiza a barra local e dispara "profile:score-updated"
//     para o AppShell redesenhar o Score do sidebar.
// Edição administrativa de conteúdo (updateLesson, adicionada pelo Cursor)
// foi preservada intacta — não é o foco desta sprint.

import { getCurrentProfile, isAdminProfile } from '../config/supabase.js';
import {
  fetchModuleWithLessons,
  fetchModuleProgress,
  completeLesson,
  updateLesson,
  fetchNextQuizCheckpoint,
} from '../services/moduleService.js';
import { navigateToPanel } from '../router.js';
import { renderBlocks, wireBlockInteractions, setupBlockArrayEditor } from '../components/ContentBlocks.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'modulo-conteudo') initModuloConteudoPage();
});

async function initModuloConteudoPage() {
  const container = document.getElementById('moduloContentContainer');
  const titleEl = document.getElementById('moduloTitle');
  if (!container) return;

  const moduleId = window.selectedModuleId;
  if (!moduleId) {
    container.innerHTML = '<p class="content-error">Nenhum módulo selecionado.</p>';
    return;
  }

  container.innerHTML = '<p class="home-loading">Carregando conteúdo...</p>';

  try {
    const profile = await getCurrentProfile();
    const { module, lessons } = await fetchModuleWithLessons(moduleId);
    const progress = profile
      ? await fetchModuleProgress(profile.id, moduleId)
      : { total: lessons.length, completed: 0, pct: 0, completedIds: new Set() };
    // Bug real reportado pelo usuário: terminar o módulo não levava pro quiz
    // — a pessoa tinha que voltar pra "Minha Trilha" e achar o card
    // recém-desbloqueado manualmente. Busca o quiz que vem logo depois
    // deste módulo na trilha (se existir) pra mostrar um CTA "Responder
    // quiz" assim que as lições chegarem a 100%.
    const nextQuiz = profile && module.zone_id ? await fetchNextQuizCheckpoint(module.zone_id, module.id) : null;

    if (titleEl) titleEl.textContent = module.title || 'Módulo';
    renderModule(container, module, lessons, profile, progress, nextQuiz);
  } catch (err) {
    console.error('[ModuloConteudo] erro ao buscar módulo:', err);
    container.innerHTML = '<p class="content-error">Erro ao carregar o conteúdo do módulo.</p>';
  }
}

function renderModule(container, module, lessons, profile, progress, nextQuiz) {
  const showQuizCta = progress.pct === 100 && Boolean(nextQuiz);
  const zoneName = module.zones?.name;
  // "atual" = primeira lição ainda não concluída, mesmo critério já usado
  // pra checkpoint em GpsTrail.js (statusPorCheckpoint) — sem estado de
  // "bloqueada" aqui porque, ao contrário dos checkpoints da trilha, as
  // lições dentro de um módulo não têm gate sequencial real no schema hoje
  // (qualquer uma pode ser concluída em qualquer ordem); fingir um cadeado
  // que não existe de verdade seria mentir pro usuário sobre o que o clique
  // faz.
  const firstIncompleteIndex = lessons.findIndex((l) => !progress.completedIds.has(l.id));

  container.innerHTML = `
    <div class="content-layout">
      <div class="content-main">
        <div class="content-header">
          <nav class="content-breadcrumb" aria-label="Localização na trilha">
            ${zoneName ? `<button type="button" class="content-breadcrumb-link" data-back-to="trilha">${zoneName}</button><span class="content-breadcrumb-sep">›</span>` : ''}
            <span class="content-breadcrumb-current">${module.title}</span>
          </nav>
          ${module.estimated_minutes ? `<span class="content-duration">${module.estimated_minutes} min</span>` : ''}
        </div>

        ${lessons.length ? `
          <div class="module-progress" data-role="module-progress">
            <div class="module-progress-head">
              <span class="module-progress-label">Progresso do módulo</span>
              <span class="module-progress-count" data-role="progress-count">${progress.completed} de ${progress.total} lições</span>
            </div>
            <div class="module-progress-track"><div class="module-progress-fill" data-role="progress-fill" style="width:${progress.pct}%"></div></div>
          </div>

          ${nextQuiz ? `
            <div class="module-quiz-cta" data-role="quiz-cta" ${showQuizCta ? '' : 'hidden'}>
              <div class="module-quiz-cta-text">
                <strong>Módulo concluído!</strong>
                <span>Responda o quiz agora para desbloquear o próximo módulo.</span>
              </div>
              <button type="button" class="module-quiz-cta-btn" data-role="answer-quiz">Responder quiz →</button>
            </div>
          ` : ''}

          <div class="content-lesson-list" data-role="lessons">
            ${lessons.map((lesson, index) => renderLesson(lesson, index, progress.completedIds.has(lesson.id), isAdminProfile(profile))).join('')}
          </div>
        ` : `
          <div class="content-placeholder">
            <div class="content-placeholder-icon">📄</div>
            <h3 class="content-placeholder-title">Conteúdo em preparação</h3>
            <p class="content-placeholder-text">
              A estrutura do módulo já existe, mas o texto das aulas ainda não foi migrado
              do material original — isso está no backlog da próxima sprint de conteúdo.
            </p>
          </div>
        `}
      </div>

      <aside class="content-sidebar">
        <div class="content-sidebar-card content-sidebar-sticky">
          <h4 class="sidebar-card-title">Sobre este módulo</h4>
          <p class="sidebar-card-text">${module.summary || 'Sem descrição disponível.'}</p>

          ${lessons.length ? `
            <div class="sidebar-progress">
              <div class="sidebar-progress-track"><div class="sidebar-progress-fill" data-role="sidebar-progress-fill" style="width:${progress.pct}%"></div></div>
              <span class="sidebar-progress-label" data-role="sidebar-progress-label">${progress.completed} de ${progress.total} lições · ${progress.pct}%</span>
            </div>

            ${module.estimated_minutes ? `<div class="sidebar-meta-time">⏱ ~${module.estimated_minutes} min de leitura</div>` : ''}

            <ul class="sidebar-lesson-nav" data-role="sidebar-lesson-nav">
              ${lessons.map((lesson, index) => {
                const isDone = progress.completedIds.has(lesson.id);
                const state = isDone ? 'done' : (index === firstIncompleteIndex ? 'current' : 'pending');
                return `
                  <li class="sidebar-lesson-item ${state}" data-role="sidebar-lesson-link" data-lesson-index="${index}">
                    <span class="sidebar-lesson-status">${isDone ? '✓' : index + 1}</span>
                    <span class="sidebar-lesson-title">${lesson.title}</span>
                  </li>`;
              }).join('')}
            </ul>
          ` : ''}
        </div>
      </aside>
    </div>
  `;

  wireSidebarLessonNav(container);

  if (!profile) {
    wireBlockInteractions(container, { returnPanel: 'modulo-conteudo' });
    return; // visitante: mostra conteúdo, mas não grava progresso
  }

  wireBlockInteractions(container, { returnPanel: 'modulo-conteudo' });
  wireCompleteButtons(container, progress, nextQuiz);
  wireQuizCta(container, nextQuiz);
  wireLessonEdit(container, lessons, module.id, nextQuiz);
}

/** Navegação rápida da sidebar — todas as lições já estão na mesma página (scroll), então "navegar" é rolar até o card certo. */
function wireSidebarLessonNav(container) {
  container.querySelectorAll('[data-role="sidebar-lesson-link"]').forEach((item) => {
    item.addEventListener('click', () => {
      const target = container.querySelector(`.content-article[data-lesson-index="${item.dataset.lessonIndex}"]`);
      target?.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });
}

function wireQuizCta(container, nextQuiz) {
  container.querySelector('[data-role="answer-quiz"]')?.addEventListener('click', () => {
    if (!nextQuiz) return;
    window.selectedQuizId = nextQuiz.reference_id;
    window.quizRunnerReturnPanel = 'trilha';
    navigateToPanel('quiz-runner');
  });
}

function renderLesson(lesson, index, isCompleted, canEdit) {
  const body = lesson.body || {};
  const bodyHtml = renderBlocks(body.blocks);

  const btnLabel = isCompleted ? '✓ Concluída' : '✓ Marcar aula como concluída';
  const btnDisabled = isCompleted ? 'disabled' : '';
  const cardCompleted = isCompleted ? ' is-completed' : '';

  // Edição de conteúdo é admin-only na RLS (lessons_admin_all) — o botão só
  // aparece pra quem de fato consegue salvar, pra não expor uma ação que
  // sempre falharia (406 silencioso) pra líder/colaborador.
  const editBtnHtml = canEdit
    ? `<button type="button" class="lesson-edit-btn" data-lesson-index="${index}" style="margin-top: 8px; padding: 6px 12px; background: var(--off); border: 1px solid var(--border); border-radius: var(--r2); cursor: pointer; font-size: 12px;">Editar conteúdo</button>`
    : '';

  return `
    <div class="content-article${cardCompleted}" data-lesson-index="${index}" data-lesson-id="${lesson.id}">
      <h3 class="content-lesson-title">${lesson.title}</h3>
      ${bodyHtml}
      <button type="button" class="content-complete-btn" data-role="complete-lesson" data-lesson-id="${lesson.id}" ${btnDisabled}>
        ${btnLabel}
      </button>
      ${editBtnHtml}
    </div>
    <div id="lesson-edit-${index}" class="lesson-edit-panel" hidden></div>`;
}

function wireCompleteButtons(container, progress, nextQuiz) {
  container.querySelectorAll('[data-role="complete-lesson"]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      if (btn.disabled) return;
      const lessonId = btn.dataset.lessonId;
      const originalLabel = btn.textContent.trim();
      btn.disabled = true;
      btn.textContent = 'Salvando…';

      try {
        const result = await completeLesson(lessonId);
        // result: { performance_score, points_awarded, already_completed }
        markLessonAsCompleted(container, lessonId, result.points_awarded);
        updateProgressBar(container, progress, lessonId);
        window.dispatchEvent(new CustomEvent('profile:score-updated', {
          detail: { performance_score: result.performance_score },
        }));

        // Última lição do módulo — revela o CTA "Responder quiz" na hora,
        // sem precisar recarregar a página (bug real reportado: terminar o
        // módulo não levava pro quiz, a pessoa tinha que voltar pra "Minha
        // Trilha" e achar o card recém-desbloqueado manualmente).
        if (progress.pct === 100 && nextQuiz) {
          const ctaEl = container.querySelector('[data-role="quiz-cta"]');
          if (ctaEl) {
            ctaEl.hidden = false;
            ctaEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
          }
        }
      } catch (err) {
        console.error('[ModuloConteudo] erro ao concluir lição:', err);
        btn.disabled = false;
        btn.textContent = originalLabel === 'Salvando…' ? 'Tentar novamente' : originalLabel;
      }
    });
  });
}

function markLessonAsCompleted(container, lessonId, pointsAwarded) {
  const card = container.querySelector(`.content-article[data-lesson-id="${lessonId}"]`);
  if (card) card.classList.add('is-completed');
  const btn = container.querySelector(`[data-role="complete-lesson"][data-lesson-id="${lessonId}"]`);
  if (btn) {
    btn.disabled = true;
    btn.textContent = pointsAwarded > 0 ? `✓ Concluída · +${pointsAwarded} pts` : '✓ Concluída';
  }

  // sidebar: marca essa lição como feita e promove a próxima pendente a "atual"
  const navItem = container.querySelector(`.sidebar-lesson-item[data-lesson-index="${card?.dataset.lessonIndex}"]`);
  if (navItem) {
    navItem.classList.remove('current');
    navItem.classList.add('done');
    navItem.querySelector('.sidebar-lesson-status').textContent = '✓';
    const nextPending = navItem.parentElement.querySelector('.sidebar-lesson-item.pending');
    if (nextPending) nextPending.classList.replace('pending', 'current');
  }
}

function updateProgressBar(container, progress, justCompletedLessonId) {
  // Evita contar duas vezes se o usuário clicar de novo.
  if (progress.completedIds.has(justCompletedLessonId)) return;
  progress.completedIds.add(justCompletedLessonId);
  progress.completed = progress.completedIds.size;
  progress.pct = progress.total ? Math.round((progress.completed / progress.total) * 100) : 0;

  const countEl = container.querySelector('[data-role="progress-count"]');
  const fillEl = container.querySelector('[data-role="progress-fill"]');
  if (countEl) countEl.textContent = `${progress.completed} de ${progress.total} lições`;
  if (fillEl) fillEl.style.width = `${progress.pct}%`;

  const sidebarFillEl = container.querySelector('[data-role="sidebar-progress-fill"]');
  const sidebarLabelEl = container.querySelector('[data-role="sidebar-progress-label"]');
  if (sidebarFillEl) sidebarFillEl.style.width = `${progress.pct}%`;
  if (sidebarLabelEl) sidebarLabelEl.textContent = `${progress.completed} de ${progress.total} lições · ${progress.pct}%`;
}

function wireLessonEdit(container, lessons, moduleId, nextQuiz) {
  container.querySelectorAll('.lesson-edit-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
      const index = parseInt(btn.dataset.lessonIndex, 10);
      const lesson = lessons[index];
      if (!lesson) return;

      const editPanel = container.querySelector(`#lesson-edit-${index}`);
      if (!editPanel) return;

      const body = lesson.body || {};
      editPanel.innerHTML = `<div class="cb-editor-wrap"><h3 class="content-lesson-title">Editar: ${lesson.title}</h3></div>`;
      editPanel.hidden = false;
      const editorContainer = editPanel.querySelector('.cb-editor-wrap');

      setupBlockArrayEditor(editorContainer, body.blocks || [], {
        onCancel: () => { editPanel.hidden = true; },
        onSave: async (blocks) => {
          const updatedBody = { blocks };
          await updateLesson(lesson.id, { body: updatedBody });
          lessons[index].body = updatedBody;

          // Recarrega o módulo inteiro para reaproveitar o pipeline de
          // render (mantém o progresso atual do usuário, se estiver logado).
          editPanel.hidden = true;
          const profile = await getCurrentProfile();
          const { module } = await fetchModuleWithLessons(moduleId);
          const progress = profile
            ? await fetchModuleProgress(profile.id, moduleId)
            : { total: lessons.length, completed: 0, pct: 0, completedIds: new Set() };
          renderModule(container, module, lessons, profile, progress, nextQuiz);
        },
      });
    });
  });
}
