// src/pages/gestoraContentEditor.js
// Painel da Gestora — 2ª rodada: CRUD de módulos/lições/quizzes sem SQL
// direto, com reordenação por arrastar-e-soltar. Montado dentro de
// gestoraPanel.js (initContentEditor), 3 abas (mesmo padrão .itabs/.itab já
// usado nos guias técnicos densos da Biblioteca).
//
// Edição do CONTEÚDO da lição (os blocos em si) continua em ContentBlocks.js
// via o painel de Conteúdo do Módulo (botão "Editar conteúdo") — não
// duplicado aqui, essa página só cria/reordena/publica/apaga a lição.
//
// Vincular um módulo/quiz novo à trilha (criar o checkpoint correspondente)
// é uma ação separada, fora de escopo desta rodada — ver comentário em
// contentAdminService.js.

import {
  fetchZonesWithBrand, fetchAllModulesAdmin, createModule, updateModule, deleteModule, reorderModules,
  fetchAllLessonsAdmin, createLesson, updateLessonFields, deleteLesson, reorderLessons,
  fetchAllQuizzesAdmin, createQuiz, updateQuiz, deleteQuiz,
  fetchQuestionsAdmin, createQuestion, updateQuestion, deleteQuestion,
  createAlternative, markAlternativeCorrect, updateAlternative, deleteAlternative,
} from '../services/contentAdminService.js';
import { fetchActiveBrands } from '../services/brandService.js';
import { navigateToPanel } from '../router.js';

const TABS = [
  { id: 'modulos', label: 'Módulos' },
  { id: 'licoes', label: 'Lições' },
  { id: 'quizzes', label: 'Quizzes' },
];

export async function initContentEditor(container) {
  container.innerHTML = `
    <div class="itabs" data-role="ce-tabs">
      ${TABS.map((t, i) => `<button type="button" class="itab${i === 0 ? ' active' : ''}" data-tab="${t.id}">${t.label}</button>`).join('')}
    </div>
    <div data-role="ce-body"><p class="learning-loading">Carregando…</p></div>
  `;

  const body = container.querySelector('[data-role="ce-body"]');
  let activeTab = 'modulos';

  const renderers = { modulos: renderModulosTab, licoes: renderLicoesTab, quizzes: renderQuizzesTab };

  async function showTab(tabId) {
    activeTab = tabId;
    container.querySelectorAll('[data-tab]').forEach((btn) => btn.classList.toggle('active', btn.dataset.tab === tabId));
    body.innerHTML = '<p class="learning-loading">Carregando…</p>';
    try {
      await renderers[tabId](body);
    } catch (err) {
      console.error('[GestoraContentEditor] erro ao carregar aba', tabId, err);
      body.innerHTML = '<p class="learning-error">Não foi possível carregar esta seção agora.</p>';
    }
  }

  container.querySelectorAll('[data-tab]').forEach((btn) => {
    btn.addEventListener('click', () => showTab(btn.dataset.tab));
  });

  await showTab(activeTab);
}

// ── Helper genérico: reordenar por arrastar-e-soltar ────────────────────
// list: array de {id, ...}; rowSelector: seletor das linhas arrastáveis
// dentro de listEl; onReorder(orderedIds) persiste a nova ordem.
function wireDragReorder(listEl, list, onReorder, rerender) {
  let draggedId = null;

  listEl.querySelectorAll('[data-drag-id]').forEach((row) => {
    row.addEventListener('dragstart', () => {
      draggedId = row.dataset.dragId;
      row.classList.add('ce-dragging');
    });
    row.addEventListener('dragend', () => row.classList.remove('ce-dragging'));
    row.addEventListener('dragover', (e) => {
      e.preventDefault();
      row.classList.add('ce-drag-over');
    });
    row.addEventListener('dragleave', () => row.classList.remove('ce-drag-over'));
    row.addEventListener('drop', async (e) => {
      e.preventDefault();
      row.classList.remove('ce-drag-over');
      const targetId = row.dataset.dragId;
      if (!draggedId || draggedId === targetId) return;

      const fromIdx = list.findIndex((x) => x.id === draggedId);
      const toIdx = list.findIndex((x) => x.id === targetId);
      if (fromIdx === -1 || toIdx === -1) return;

      const [moved] = list.splice(fromIdx, 1);
      list.splice(toIdx, 0, moved);
      // Mantém order_index em memória sincronizado com a nova ordem — sem
      // isso, o próximo render ordenaria de novo pelos valores antigos
      // (list contém as MESMAS referências de objeto do array mestre, então
      // mutar aqui já reflete lá).
      list.forEach((item, i) => { item.order_index = i; });

      await onReorder(list.map((x) => x.id));
      rerender();
    });
  });
}

// ══════════════════════════════════════════════════════════════════════
// MÓDULOS
// ══════════════════════════════════════════════════════════════════════

async function renderModulosTab(body) {
  const [zones, modules] = await Promise.all([fetchZonesWithBrand(), fetchAllModulesAdmin()]);

  if (!zones.length) {
    body.innerHTML = '<p class="learning-empty">Nenhuma zona de trilha cadastrada ainda, módulos precisam de uma zona (fora de escopo criar zona nova aqui).</p>';
    return;
  }

  body.innerHTML = `
    <div class="admin-create-card">
      <h3 class="dash-section-label">Novo módulo</h3>
      <form id="ceModuleForm" class="admin-create-form">
        <select name="zone_id" class="login-input" required>
          <option value="">Zona...</option>
          ${zones.map((z) => `<option value="${z.id}">${z.name} (${z.trails?.brands?.name || '—'})</option>`).join('')}
        </select>
        <input type="text" name="title" class="login-input" placeholder="Título" required>
        <input type="text" name="summary" class="login-input" placeholder="Resumo (opcional)">
        <input type="number" name="estimated_minutes" class="login-input" placeholder="Minutos estimados" min="1">
        <button type="submit" class="login-btn admin-create-submit">Criar módulo</button>
      </form>
      <div class="ranking-highlight-form-msg" data-role="ce-module-msg"></div>
    </div>
    <div data-role="ce-module-groups" style="margin-top:20px;"></div>
  `;

  renderModuleGroups(body, zones, modules);
  wireModuleForm(body, zones, modules);
}

function renderModuleGroups(body, zones, modules) {
  const groupsEl = body.querySelector('[data-role="ce-module-groups"]');
  groupsEl.innerHTML = zones.map((z) => {
    const zoneModules = modules.filter((m) => m.zone_id === z.id).sort((a, b) => a.order_index - b.order_index);
    return `
      <div style="margin-bottom:22px;">
        <div class="dash-mini-tag" style="margin-bottom:8px;">${z.name}</div>
        ${zoneModules.length ? `
          <div class="lib-table-wrap">
            <table class="lib-table" data-role="ce-module-list" data-zone-id="${z.id}">
              <thead><tr><th style="width:24px;"></th><th>Título</th><th>Min.</th><th>Publicado</th><th></th></tr></thead>
              <tbody>
                ${zoneModules.map((m) => moduleRowHtml(m)).join('')}
              </tbody>
            </table>
          </div>
        ` : '<p class="learning-empty">Nenhum módulo nesta zona.</p>'}
      </div>`;
  }).join('');

  zones.forEach((z) => {
    const zoneModules = modules.filter((m) => m.zone_id === z.id).sort((a, b) => a.order_index - b.order_index);
    const tbody = groupsEl.querySelector(`[data-zone-id="${z.id}"] tbody`);
    if (!tbody || !zoneModules.length) return;
    wireDragReorder(tbody, zoneModules, reorderModules, () => renderModuleGroups(body, zones, modules));
  });

  wireModuleRowActions(body, zones, modules);
}

function moduleRowHtml(m) {
  return `
    <tr data-drag-id="${m.id}" draggable="true" class="ce-drag-row">
      <td class="ce-drag-handle" title="Arraste para reordenar">⠿</td>
      <td class="lib-prod-name" data-role="ce-module-title">${m.title}</td>
      <td>${m.estimated_minutes || '—'}</td>
      <td>
        <button type="button" class="learning-card-btn" data-toggle-pub data-module-id="${m.id}" data-current="${m.is_published}" style="padding:4px 10px; font-size:11px;">
          ${m.is_published ? '✓ Sim' : '✕ Não'}
        </button>
      </td>
      <td style="white-space:nowrap;">
        <button type="button" class="cb-editor-btn" data-edit-module="${m.id}">Editar</button>
        <button type="button" class="cb-editor-btn cb-editor-btn-danger" data-delete-module="${m.id}">Excluir</button>
      </td>
    </tr>`;
}

/** Linha de edição completa (título, resumo, minutos, zona) — cobre os
 * mesmos campos que "Novo módulo" pede, não só o título (achado ao testar:
 * criar um módulo e só poder editar o nome depois não serve pra nada). */
function moduleEditRowHtml(m, zones) {
  return `
    <td colspan="5" style="padding:10px 4px;">
      <div style="display:flex; gap:8px; flex-wrap:wrap; align-items:center;">
        <select data-field="zone_id" class="login-input" style="flex:1 1 160px;">
          ${zones.map((z) => `<option value="${z.id}" ${z.id === m.zone_id ? 'selected' : ''}>${z.name}</option>`).join('')}
        </select>
        <input type="text" data-field="title" class="login-input" value="${m.title}" placeholder="Título" style="flex:2 1 180px;">
        <input type="text" data-field="summary" class="login-input" value="${m.summary || ''}" placeholder="Resumo" style="flex:2 1 180px;">
        <input type="number" data-field="estimated_minutes" class="login-input" value="${m.estimated_minutes || ''}" placeholder="Minutos" min="1" style="width:100px;">
        <button type="button" class="cb-editor-btn" data-save-module-edit>Salvar</button>
        <button type="button" class="cb-editor-btn" data-cancel-module-edit>Cancelar</button>
      </div>
    </td>`;
}

function wireModuleEditRow(row, body, zones, modules, m) {
  row.querySelector('[data-cancel-module-edit]').addEventListener('click', () => {
    renderModuleGroups(body, zones, modules);
  });

  row.querySelector('[data-save-module-edit]').addEventListener('click', async () => {
    const title = row.querySelector('[data-field="title"]').value.trim();
    if (!title) return;
    const newZoneId = row.querySelector('[data-field="zone_id"]').value;
    const summary = row.querySelector('[data-field="summary"]').value.trim();
    const minutesVal = row.querySelector('[data-field="estimated_minutes"]').value;
    const zoneChanged = newZoneId !== m.zone_id;

    const updates = {
      title,
      summary: summary || null,
      estimated_minutes: minutesVal ? Number(minutesVal) : null,
      zone_id: newZoneId,
    };
    // Mudou de zona: reaparece no fim da lista da zona nova (order_index
    // relativo é só entre módulos da mesma zona, mesma lógica da criação).
    if (zoneChanged) {
      const destModules = modules.filter((x) => x.zone_id === newZoneId);
      updates.order_index = destModules.length ? Math.max(...destModules.map((x) => x.order_index)) + 1 : 0;
    }

    try {
      await updateModule(m.id, updates);
      Object.assign(m, updates);
      if (zoneChanged) m.zones = zones.find((z) => z.id === newZoneId);
      renderModuleGroups(body, zones, modules);
    } catch (err) {
      console.error('[GestoraContentEditor] erro ao salvar módulo:', err);
      alert('Não foi possível salvar agora.');
    }
  });
}

function wireModuleForm(body, zones, modules) {
  const form = body.querySelector('#ceModuleForm');
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const msgEl = body.querySelector('[data-role="ce-module-msg"]');
    const fd = new FormData(form);
    const zoneId = fd.get('zone_id');
    const zoneModules = modules.filter((m) => m.zone_id === zoneId);
    const nextOrder = zoneModules.length ? Math.max(...zoneModules.map((m) => m.order_index)) + 1 : 0;

    msgEl.textContent = 'Criando…';
    msgEl.style.color = 'var(--text3)';
    try {
      const created = await createModule({
        zoneId,
        title: fd.get('title').trim(),
        summary: fd.get('summary').trim(),
        estimatedMinutes: fd.get('estimated_minutes') ? Number(fd.get('estimated_minutes')) : null,
        orderIndex: nextOrder,
      });
      modules.push({ ...created, zones: zones.find((z) => z.id === zoneId) });
      msgEl.textContent = 'Módulo criado.';
      msgEl.style.color = 'var(--acc)';
      form.reset();
      renderModuleGroups(body, zones, modules);
    } catch (err) {
      console.error('[GestoraContentEditor] erro ao criar módulo:', err);
      msgEl.textContent = 'Erro: ' + err.message;
      msgEl.style.color = 'var(--g)';
    }
  });
}

function wireModuleRowActions(body, zones, modules) {
  body.querySelectorAll('[data-toggle-pub][data-module-id]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const moduleId = btn.dataset.moduleId;
      const nextVal = btn.dataset.current !== 'true';
      btn.disabled = true;
      try {
        await updateModule(moduleId, { is_published: nextVal });
        const m = modules.find((x) => x.id === moduleId);
        if (m) m.is_published = nextVal;
        btn.dataset.current = String(nextVal);
        btn.textContent = nextVal ? '✓ Sim' : '✕ Não';
      } catch (err) {
        console.error('[GestoraContentEditor] erro ao publicar módulo:', err);
        alert('Não foi possível atualizar agora.');
      } finally {
        btn.disabled = false;
      }
    });
  });

  // Edição completa (título, resumo, minutos, zona) — não só o título.
  // Cada clique em "Editar" substitui a linha inteira por um formulário;
  // Salvar/Cancelar sempre terminam chamando renderModuleGroups (re-render
  // total), então não há risco do bug de listener empilhado que existia na
  // versão anterior (edição só do título, alternando estado no mesmo botão).
  body.querySelectorAll('[data-edit-module]').forEach((btn) => {
    btn.addEventListener('click', () => {
      const moduleId = btn.dataset.editModule;
      const m = modules.find((x) => x.id === moduleId);
      if (!m) return;
      const row = btn.closest('tr');
      row.draggable = false; // evita conflito com o drag-reorder enquanto os campos estão abertos
      row.innerHTML = moduleEditRowHtml(m, zones);
      wireModuleEditRow(row, body, zones, modules, m);
    });
  });

  body.querySelectorAll('[data-delete-module]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const moduleId = btn.dataset.deleteModule;
      const m = modules.find((x) => x.id === moduleId);
      if (!window.confirm(`Excluir o módulo "${m?.title}"? As lições dentro dele também serão apagadas. Essa ação não pode ser desfeita.`)) return;
      try {
        await deleteModule(moduleId);
        const idx = modules.findIndex((x) => x.id === moduleId);
        if (idx !== -1) modules.splice(idx, 1);
        renderModuleGroups(body, zones, modules);
      } catch (err) {
        console.error('[GestoraContentEditor] erro ao excluir módulo:', err);
        alert('Não foi possível excluir agora — ' + (err.message || 'verifique se ele ainda é referenciado pela trilha (checkpoint).'));
      }
    });
  });
}

// ══════════════════════════════════════════════════════════════════════
// LIÇÕES
// ══════════════════════════════════════════════════════════════════════

async function renderLicoesTab(body) {
  const modules = await fetchAllModulesAdmin();

  body.innerHTML = `
    <div class="admin-create-card">
      <h3 class="dash-section-label">Selecionar módulo</h3>
      <select id="ceLessonModuleSelect" class="login-input">
        <option value="">Selecione um módulo...</option>
        ${modules.map((m) => `<option value="${m.id}">${m.zones?.name ? `${m.zones.name} · ` : ''}${m.title}</option>`).join('')}
      </select>
    </div>
    <div data-role="ce-lessons-body" style="margin-top:16px;"></div>
  `;

  body.querySelector('#ceLessonModuleSelect').addEventListener('change', async (e) => {
    const moduleId = e.target.value;
    const lessonsBody = body.querySelector('[data-role="ce-lessons-body"]');
    if (!moduleId) { lessonsBody.innerHTML = ''; return; }
    lessonsBody.innerHTML = '<p class="learning-loading">Carregando lições…</p>';
    try {
      const lessons = await fetchAllLessonsAdmin(moduleId);
      renderLessonsList(lessonsBody, moduleId, lessons);
    } catch (err) {
      console.error('[GestoraContentEditor] erro ao carregar lições:', err);
      lessonsBody.innerHTML = '<p class="learning-error">Não foi possível carregar as lições agora.</p>';
    }
  });
}

function renderLessonsList(container, moduleId, lessons) {
  container.innerHTML = `
    <div class="admin-create-card">
      <form id="ceLessonForm" class="admin-create-form">
        <input type="text" name="title" class="login-input" placeholder="Título da nova lição" required>
        <button type="submit" class="login-btn admin-create-submit">Criar lição</button>
      </form>
      <div class="ranking-highlight-form-msg" data-role="ce-lesson-msg"></div>
    </div>
    ${lessons.length ? `
      <div class="lib-table-wrap" style="margin-top:14px;">
        <table class="lib-table" data-role="ce-lesson-list">
          <thead><tr><th style="width:24px;"></th><th>Título</th><th>Publicada</th><th></th></tr></thead>
          <tbody>
            ${lessons.map((l) => lessonRowHtml(l)).join('')}
          </tbody>
        </table>
      </div>
    ` : '<p class="learning-empty" style="margin-top:14px;">Nenhuma lição neste módulo ainda.</p>'}
  `;

  const tbody = container.querySelector('[data-role="ce-lesson-list"] tbody');
  if (tbody) wireDragReorder(tbody, lessons, reorderLessons, () => renderLessonsList(container, moduleId, lessons));

  wireLessonForm(container, moduleId, lessons);
  wireLessonRowActions(container, moduleId, lessons);
}

function lessonRowHtml(l) {
  return `
    <tr data-drag-id="${l.id}" draggable="true" class="ce-drag-row">
      <td class="ce-drag-handle" title="Arraste para reordenar">⠿</td>
      <td class="lib-prod-name" data-role="ce-lesson-title">${l.title}</td>
      <td>
        <button type="button" class="learning-card-btn" data-toggle-lesson-pub data-lesson-id="${l.id}" data-current="${l.is_published}" style="padding:4px 10px; font-size:11px;">
          ${l.is_published ? '✓ Sim' : '✕ Não'}
        </button>
      </td>
      <td style="white-space:nowrap;">
        <button type="button" class="cb-editor-btn" data-edit-lesson="${l.id}">Editar título</button>
        <button type="button" class="cb-editor-btn" data-open-content="${l.id}" data-module-id="${l.module_id}">Editar conteúdo →</button>
        <button type="button" class="cb-editor-btn cb-editor-btn-danger" data-delete-lesson="${l.id}">Excluir</button>
      </td>
    </tr>`;
}

function wireLessonForm(container, moduleId, lessons) {
  const form = container.querySelector('#ceLessonForm');
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const msgEl = container.querySelector('[data-role="ce-lesson-msg"]');
    const fd = new FormData(form);
    const nextOrder = lessons.length ? Math.max(...lessons.map((l) => l.order_index)) + 1 : 0;
    msgEl.textContent = 'Criando…';
    msgEl.style.color = 'var(--text3)';
    try {
      const created = await createLesson({ moduleId, title: fd.get('title').trim(), orderIndex: nextOrder });
      lessons.push(created);
      msgEl.textContent = 'Lição criada.';
      msgEl.style.color = 'var(--acc)';
      renderLessonsList(container, moduleId, lessons);
    } catch (err) {
      console.error('[GestoraContentEditor] erro ao criar lição:', err);
      msgEl.textContent = 'Erro: ' + err.message;
      msgEl.style.color = 'var(--g)';
    }
  });
}

function wireLessonRowActions(container, moduleId, lessons) {
  container.querySelectorAll('[data-toggle-lesson-pub]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const lessonId = btn.dataset.lessonId;
      const nextVal = btn.dataset.current !== 'true';
      btn.disabled = true;
      try {
        await updateLessonFields(lessonId, { is_published: nextVal });
        const l = lessons.find((x) => x.id === lessonId);
        if (l) l.is_published = nextVal;
        btn.dataset.current = String(nextVal);
        btn.textContent = nextVal ? '✓ Sim' : '✕ Não';
      } catch (err) {
        console.error('[GestoraContentEditor] erro ao publicar lição:', err);
        alert('Não foi possível atualizar agora.');
      } finally {
        btn.disabled = false;
      }
    });
  });

  container.querySelectorAll('[data-edit-lesson]').forEach((btn) => {
    const lessonId = btn.dataset.editLesson;
    const l = lessons.find((x) => x.id === lessonId);
    if (!l) return;
    const row = btn.closest('tr');
    const titleCell = row.querySelector('[data-role="ce-lesson-title"]');
    // Mesmo padrão de toggle único (dataset.mode) usado em wireModuleRowActions —
    // um só listener, sem empilhar a cada clique.
    btn.addEventListener('click', async () => {
      if (btn.dataset.mode !== 'saving') {
        titleCell.innerHTML = `<input type="text" class="login-input" value="${l.title}" style="padding:5px;font-size:12.5px;" data-role="ce-inline-lesson-title">`;
        btn.textContent = 'Salvar';
        btn.dataset.mode = 'saving';
        return;
      }
      const input = titleCell.querySelector('[data-role="ce-inline-lesson-title"]');
      const newTitle = input.value.trim();
      if (!newTitle) return;
      try {
        await updateLessonFields(lessonId, { title: newTitle });
        l.title = newTitle;
        renderLessonsList(container, moduleId, lessons);
      } catch (err) {
        console.error('[GestoraContentEditor] erro ao salvar lição:', err);
        alert('Não foi possível salvar agora.');
      }
    });
  });

  container.querySelectorAll('[data-open-content]').forEach((btn) => {
    btn.addEventListener('click', () => {
      window.selectedModuleId = btn.dataset.moduleId;
      window.moduloConteudoReturnPanel = 'gestora';
      navigateToPanel('modulo-conteudo');
    });
  });

  container.querySelectorAll('[data-delete-lesson]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const lessonId = btn.dataset.deleteLesson;
      const l = lessons.find((x) => x.id === lessonId);
      if (!window.confirm(`Excluir a lição "${l?.title}"? Essa ação não pode ser desfeita.`)) return;
      try {
        await deleteLesson(lessonId);
        const idx = lessons.findIndex((x) => x.id === lessonId);
        if (idx !== -1) lessons.splice(idx, 1);
        renderLessonsList(container, moduleId, lessons);
      } catch (err) {
        console.error('[GestoraContentEditor] erro ao excluir lição:', err);
        alert('Não foi possível excluir agora.');
      }
    });
  });
}

// ══════════════════════════════════════════════════════════════════════
// QUIZZES
// ══════════════════════════════════════════════════════════════════════

async function renderQuizzesTab(body) {
  const [brandsResult, quizzes] = await Promise.all([fetchActiveBrands(), fetchAllQuizzesAdmin()]);
  const brands = brandsResult.data || [];

  body.innerHTML = `
    <div class="admin-create-card">
      <h3 class="dash-section-label">Novo quiz</h3>
      <form id="ceQuizForm" class="admin-create-form">
        <select name="brand_id" class="login-input" required>
          <option value="">Marca...</option>
          ${brands.map((b) => `<option value="${b.id}">${b.name}</option>`).join('')}
        </select>
        <input type="text" name="title" class="login-input" placeholder="Título" required>
        <input type="number" name="passing_score_pct" class="login-input" placeholder="Nota mínima (%)" value="70" min="0" max="100">
        <input type="number" name="max_attempts" class="login-input" placeholder="Máx. tentativas (opcional)" min="1">
        <button type="submit" class="login-btn admin-create-submit">Criar quiz</button>
      </form>
      <div class="ranking-highlight-form-msg" data-role="ce-quiz-msg"></div>
    </div>
    <div data-role="ce-quiz-list" style="margin-top:16px;"></div>
  `;

  renderQuizList(body, quizzes);
  wireQuizForm(body, quizzes, brands);
}

function renderQuizList(body, quizzes) {
  const listEl = body.querySelector('[data-role="ce-quiz-list"]');
  if (!quizzes.length) {
    listEl.innerHTML = '<p class="learning-empty">Nenhum quiz cadastrado ainda.</p>';
    return;
  }
  listEl.innerHTML = quizzes.map((q) => `
    <div class="lib-acc-item" data-quiz-id="${q.id}" style="margin-bottom:8px;">
      <button type="button" class="lib-acc-btn" data-toggle-quiz="${q.id}">
        <span>${q.title} <span class="lib-deepdive-summary">· ${q.brands?.name || '—'} · nota mín. ${q.passing_score_pct}%${q.is_published ? '' : ' · rascunho'}</span></span>
        <span class="lib-acc-chevron">▾</span>
      </button>
      <div class="lib-acc-body" data-role="ce-quiz-detail" hidden></div>
    </div>
  `).join('');

  listEl.querySelectorAll('[data-toggle-quiz]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const quizId = btn.dataset.toggleQuiz;
      const item = listEl.querySelector(`[data-quiz-id="${quizId}"]`);
      const detail = item.querySelector('[data-role="ce-quiz-detail"]');
      const opening = detail.hidden;
      btn.classList.toggle('open', opening);
      detail.hidden = !opening;
      if (opening && !detail.dataset.loaded) {
        detail.dataset.loaded = '1';
        detail.innerHTML = '<p class="learning-loading">Carregando…</p>';
        const quiz = quizzes.find((q) => q.id === quizId);
        await renderQuizDetail(detail, quiz, quizzes, body);
      }
    });
  });
}

async function renderQuizDetail(detail, quiz, quizzes, body) {
  const questions = await fetchQuestionsAdmin(quiz.id);

  detail.innerHTML = `
    <div style="display:flex; gap:8px; margin-bottom:14px;">
      <button type="button" class="learning-card-btn" data-toggle-quiz-pub data-current="${quiz.is_published}" style="padding:5px 12px; font-size:11.5px;">
        ${quiz.is_published ? '✓ Publicado' : '✕ Rascunho'}
      </button>
      <button type="button" class="cb-editor-btn cb-editor-btn-danger" data-delete-quiz>Excluir quiz</button>
    </div>

    <form id="ceQuestionForm" style="display:flex; gap:6px; margin-bottom:14px;">
      <input type="text" name="body" class="login-input" placeholder="Nova pergunta" required style="flex:1;">
      <button type="submit" class="cb-editor-btn">+ Pergunta</button>
    </form>

    <div data-role="ce-question-list">
      ${questions.map((q) => questionBlockHtml(q)).join('') || '<p class="learning-empty">Nenhuma pergunta ainda.</p>'}
    </div>
  `;

  detail.querySelector('[data-toggle-quiz-pub]').addEventListener('click', async (e) => {
    const btn = e.currentTarget;
    const nextVal = btn.dataset.current !== 'true';
    try {
      await updateQuiz(quiz.id, { is_published: nextVal });
      quiz.is_published = nextVal;
      btn.dataset.current = String(nextVal);
      btn.textContent = nextVal ? '✓ Publicado' : '✕ Rascunho';
    } catch (err) {
      console.error('[GestoraContentEditor] erro ao publicar quiz:', err);
      alert('Não foi possível atualizar agora.');
    }
  });

  detail.querySelector('[data-delete-quiz]').addEventListener('click', async () => {
    if (!window.confirm(`Excluir o quiz "${quiz.title}" e todas as suas perguntas? Essa ação não pode ser desfeita.`)) return;
    try {
      await deleteQuiz(quiz.id);
      const idx = quizzes.findIndex((q) => q.id === quiz.id);
      if (idx !== -1) quizzes.splice(idx, 1);
      renderQuizList(body, quizzes);
    } catch (err) {
      console.error('[GestoraContentEditor] erro ao excluir quiz:', err);
      alert('Não foi possível excluir agora.');
    }
  });

  detail.querySelector('#ceQuestionForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const input = e.target.querySelector('[name="body"]');
    const bodyText = input.value.trim();
    if (!bodyText) return;
    const nextOrder = questions.length ? Math.max(...questions.map((q) => q.order_index)) + 1 : 0;
    try {
      const created = await createQuestion({ quizId: quiz.id, body: bodyText, orderIndex: nextOrder });
      questions.push({ ...created, alternatives: [] });
      input.value = '';
      renderQuestionList(detail, questions);
    } catch (err) {
      console.error('[GestoraContentEditor] erro ao criar pergunta:', err);
      alert('Não foi possível criar a pergunta agora.');
    }
  });

  wireQuestionActions(detail, questions);
}

function questionBlockHtml(q) {
  return `
    <div class="cb-card" data-question-id="${q.id}" style="margin-bottom:10px;">
      <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:10px;">
        <p class="cb-card-text" style="font-weight:600; color:var(--text);" data-role="ce-question-body">${q.body}</p>
        <button type="button" class="cb-editor-btn cb-editor-btn-danger" data-delete-question="${q.id}" style="flex-shrink:0;">✕</button>
      </div>
      <div data-role="ce-alt-list" style="margin-top:8px; display:flex; flex-direction:column; gap:6px;">
        ${q.alternatives.map((a) => alternativeRowHtml(a, q.id)).join('')}
      </div>
      <form data-role="ce-alt-form" data-question-id="${q.id}" style="display:flex; gap:6px; margin-top:8px;">
        <input type="text" name="body" class="login-input" placeholder="Nova alternativa" required style="flex:1; padding:6px; font-size:12.5px;">
        <button type="submit" class="cb-editor-btn">+ Alternativa</button>
      </form>
    </div>`;
}

function alternativeRowHtml(a, questionId) {
  return `
    <label style="display:flex; align-items:center; gap:8px; font-size:12.5px; padding:4px 0;" data-alt-id="${a.id}">
      <input type="radio" name="ce-correct-${questionId}" data-mark-correct="${a.id}" ${a.is_correct ? 'checked' : ''}>
      <span style="flex:1; ${a.is_correct ? 'color:var(--acc); font-weight:600;' : ''}" data-role="ce-alt-body">${a.body}</span>
      <button type="button" class="cb-editor-btn cb-editor-btn-danger" data-delete-alt="${a.id}" style="padding:3px 8px; font-size:10.5px;">✕</button>
    </label>`;
}

function renderQuestionList(detail, questions) {
  const listEl = detail.querySelector('[data-role="ce-question-list"]');
  listEl.innerHTML = questions.map((q) => questionBlockHtml(q)).join('') || '<p class="learning-empty">Nenhuma pergunta ainda.</p>';
  wireQuestionActions(detail, questions);
}

function wireQuestionActions(detail, questions) {
  detail.querySelectorAll('[data-delete-question]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const questionId = btn.dataset.deleteQuestion;
      if (!window.confirm('Excluir esta pergunta e suas alternativas?')) return;
      try {
        await deleteQuestion(questionId);
        const idx = questions.findIndex((q) => q.id === questionId);
        if (idx !== -1) questions.splice(idx, 1);
        renderQuestionList(detail, questions);
      } catch (err) {
        console.error('[GestoraContentEditor] erro ao excluir pergunta:', err);
        alert('Não foi possível excluir agora.');
      }
    });
  });

  detail.querySelectorAll('[data-mark-correct]').forEach((radio) => {
    radio.addEventListener('change', async () => {
      const altId = radio.dataset.markCorrect;
      try {
        await markAlternativeCorrect(altId);
        const q = questions.find((qq) => qq.alternatives.some((a) => a.id === altId));
        if (q) q.alternatives.forEach((a) => { a.is_correct = a.id === altId; });
        renderQuestionList(detail, questions);
      } catch (err) {
        console.error('[GestoraContentEditor] erro ao marcar alternativa correta:', err);
        alert('Não foi possível atualizar agora.');
      }
    });
  });

  detail.querySelectorAll('[data-delete-alt]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const altId = btn.dataset.deleteAlt;
      try {
        await deleteAlternative(altId);
        questions.forEach((q) => {
          const idx = q.alternatives.findIndex((a) => a.id === altId);
          if (idx !== -1) q.alternatives.splice(idx, 1);
        });
        renderQuestionList(detail, questions);
      } catch (err) {
        console.error('[GestoraContentEditor] erro ao excluir alternativa:', err);
        alert('Não foi possível excluir agora.');
      }
    });
  });

  detail.querySelectorAll('[data-role="ce-alt-form"]').forEach((form) => {
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      const questionId = form.dataset.questionId;
      const input = form.querySelector('[name="body"]');
      const bodyText = input.value.trim();
      if (!bodyText) return;
      const q = questions.find((qq) => qq.id === questionId);
      const nextOrder = q.alternatives.length ? Math.max(...q.alternatives.map((a) => a.order_index)) + 1 : 0;
      try {
        const created = await createAlternative({ questionId, body: bodyText, orderIndex: nextOrder, isCorrect: q.alternatives.length === 0 });
        q.alternatives.push(created);
        input.value = '';
        renderQuestionList(detail, questions);
      } catch (err) {
        console.error('[GestoraContentEditor] erro ao criar alternativa:', err);
        alert('Não foi possível criar a alternativa agora.');
      }
    });
  });
}

function wireQuizForm(body, quizzes, brands) {
  const form = body.querySelector('#ceQuizForm');
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const msgEl = body.querySelector('[data-role="ce-quiz-msg"]');
    const fd = new FormData(form);
    const brandId = fd.get('brand_id');
    msgEl.textContent = 'Criando…';
    msgEl.style.color = 'var(--text3)';
    try {
      const created = await createQuiz({
        brandId,
        title: fd.get('title').trim(),
        passingScorePct: fd.get('passing_score_pct') ? Number(fd.get('passing_score_pct')) : 70,
        maxAttempts: fd.get('max_attempts') ? Number(fd.get('max_attempts')) : null,
      });
      // createQuiz() só devolve as colunas cruas (sem o embed brands(name))
      // — completa aqui pra não mostrar "—" até o próximo fetch.
      quizzes.push({ ...created, brands: brands.find((b) => b.id === brandId) });
      msgEl.textContent = 'Quiz criado.';
      msgEl.style.color = 'var(--acc)';
      form.reset();
      renderQuizList(body, quizzes);
    } catch (err) {
      console.error('[GestoraContentEditor] erro ao criar quiz:', err);
      msgEl.textContent = 'Erro: ' + err.message;
      msgEl.style.color = 'var(--g)';
    }
  });
}
