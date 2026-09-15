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
import { icon } from '../components/icons.js';

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
    </div>
  `;

  if (!profile) {
    wireBlockInteractions(container, { returnPanel: 'modulo-conteudo' });
    return; // visitante: mostra conteúdo, mas não grava progresso
  }

  wireBlockInteractions(container, { returnPanel: 'modulo-conteudo' });
  wireCompleteButtons(container, progress, nextQuiz);
  wireQuizCta(container, nextQuiz);
  wireLessonEdit(container, lessons, module.id, nextQuiz);
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
  // sempre falharia (406 silencioso) pra líder/colaborador. Ícone discreto
  // no canto (2026-09-15, pedido do usuário) em vez de botão de texto
  // repetido ao final de cada lição — mesmo padrão já usado na Academia de
  // Produtos (academia-edit-btn-header).
  const editBtnHtml = canEdit
    ? `<button type="button" class="lesson-edit-btn" data-lesson-index="${index}" title="Editar conteúdo" aria-label="Editar conteúdo">${icon('pencil')}</button>`
    : '';

  return `
    <div class="content-article${cardCompleted}" data-lesson-index="${index}" data-lesson-id="${lesson.id}">
      ${editBtnHtml}
      <h2 class="content-lesson-title">${lesson.title}</h2>
      ${bodyHtml}
      <button type="button" class="content-complete-btn" data-role="complete-lesson" data-lesson-id="${lesson.id}" ${btnDisabled}>
        ${btnLabel}
      </button>
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
