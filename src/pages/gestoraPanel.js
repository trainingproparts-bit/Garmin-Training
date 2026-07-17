// src/pages/gestoraPanel.js
// Painel da Gestora — admin-only. 3 blocos:
//   1. Postar no Blog sem sair do painel (reaproveita blogService, mesma
//      tabela/RLS já usada em blog.js — não é uma 2ª forma de postar).
//   2. Relatório com as respostas de quiz de TODOS os colaboradores,
//      agrupado por loja (gestoraService.js — quiz_attempts_admin_all já
//      libera a organização inteira pra admin, sem precisar de view nova).
//   3. CRUD de módulos/lições/quizzes com reordenação por arrastar-e-soltar
//      (gestoraContentEditor.js) — 2ª rodada, pedida em seguida pelo usuário.
//      Edição do CONTEÚDO da lição (blocos) continua em ContentBlocks.js,
//      não duplicada aqui; os 20 tipos de bloco documentados na Fase 4
//      seguem fora de escopo (hoje só os 13 já existentes).

import { getCurrentProfile, isAdminProfile } from '../config/supabase.js';
import { CATEGORIES, fetchAllPostsForAdmin, createPost } from '../services/blogService.js';
import { fetchAllQuizAttemptsReport } from '../services/gestoraService.js';
import { initContentEditor } from './gestoraContentEditor.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'gestora') initGestoraPanel();
});

async function initGestoraPanel() {
  const container = document.getElementById('gestoraContainer');
  if (!container) return;

  container.innerHTML = '<p class="learning-loading">Carregando painel da gestora…</p>';

  try {
    const profile = await getCurrentProfile();
    if (!profile || !isAdminProfile(profile)) {
      container.innerHTML = '<p class="learning-error">Esta área é restrita a administradores.</p>';
      return;
    }

    const [recentPosts, quizRows] = await Promise.all([
      fetchAllPostsForAdmin(),
      fetchAllQuizAttemptsReport(),
    ]);

    container.innerHTML = `
      <h3 class="dash-section-label">📰 Postar no Blog</h3>
      ${renderBlogSection(recentPosts)}

      <h3 class="dash-section-label" style="margin-top:32px;">📊 Relatório de Quizzes por Loja</h3>
      ${renderQuizReportSection(quizRows)}

      <h3 class="dash-section-label" style="margin-top:32px;">🗂️ Conteúdo, Módulos, Lições e Quizzes</h3>
      <div data-role="ce-root"></div>
    `;

    wireBlogForm(container, profile);
    wireQuizReportSection(container, quizRows);
    initContentEditor(container.querySelector('[data-role="ce-root"]'));
  } catch (err) {
    console.error('[GestoraPanel] erro ao carregar painel:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar o painel agora.</p>';
  }
}

// ── Bloco 1: postar no blog ─────────────────────────────────────────────

function renderBlogSection(recentPosts) {
  return `
    <div class="admin-create-card">
      <form id="gestoraBlogForm" class="blog-form">
        <input type="text" name="title" class="ranking-highlight-textarea" placeholder="Título" required>
        <select name="category" class="ranking-highlight-textarea">
          ${CATEGORIES.map((c) => `<option value="${c}">${c}</option>`).join('')}
        </select>
        <input type="text" name="banner_url" class="ranking-highlight-textarea" placeholder="URL do banner (opcional)">
        <textarea name="content" class="ranking-highlight-textarea" rows="5" placeholder="Conteúdo (HTML permitido)" required></textarea>
        <label style="display:flex; align-items:center; gap:6px; font-size:13px; color:var(--text2);">
          <input type="checkbox" name="is_published" checked> Publicado
        </label>
        <div class="cb-editor-save-row">
          <button type="submit" class="cb-editor-btn" id="gestoraBlogSubmit">Publicar</button>
          <div class="ranking-highlight-form-msg" data-role="msg"></div>
        </div>
      </form>
      ${recentPosts.length ? `
        <h4 style="margin:20px 0 10px; font-size:12.5px; color:var(--text3); text-transform:uppercase; letter-spacing:0.5px;">Últimos posts</h4>
        <div style="display:flex; flex-direction:column; gap:6px;">
          ${recentPosts.slice(0, 5).map((p) => `
            <div style="display:flex; justify-content:space-between; gap:10px; font-size:13px; padding:8px 0; border-bottom:1px solid var(--border);">
              <span>${p.title}${!p.is_published ? ' <span class="blog-badge blog-badge-draft">Rascunho</span>' : ''}</span>
              <span style="color:var(--text3); white-space:nowrap;">${new Date(p.created_at).toLocaleDateString('pt-BR')}</span>
            </div>
          `).join('')}
        </div>
        <p style="margin-top:10px; font-size:12px; color:var(--text3);">Editar ou excluir um post existente: painel <strong>Blog</strong>.</p>
      ` : ''}
    </div>`;
}

function wireBlogForm(container, profile) {
  const form = container.querySelector('#gestoraBlogForm');
  if (!form) return;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const submitBtn = form.querySelector('#gestoraBlogSubmit');
    const msgEl = form.querySelector('[data-role="msg"]');
    submitBtn.disabled = true;
    msgEl.textContent = 'Publicando…';
    msgEl.style.color = 'var(--text3)';

    const fd = new FormData(form);
    try {
      await createPost({
        title: fd.get('title').trim(),
        content: fd.get('content').trim(),
        category: fd.get('category'),
        bannerUrl: fd.get('banner_url').trim(),
        isPublished: fd.get('is_published') === 'on',
        authorId: profile.id,
      });
      msgEl.textContent = 'Post publicado.';
      msgEl.style.color = 'var(--acc)';
      form.reset();
      initGestoraPanel();
    } catch (err) {
      console.error('[GestoraPanel] erro ao publicar post:', err);
      msgEl.textContent = 'Erro ao publicar: ' + err.message;
      msgEl.style.color = 'var(--g)';
    } finally {
      submitBtn.disabled = false;
    }
  });
}

// ── Bloco 2: relatório de quizzes por loja ──────────────────────────────
// Sem filtro/colapso, essa lista virava um scroll infinito (toda tentativa
// de quiz de toda loja, sempre expandida — pedido do usuário, 2026-07-17,
// pra resolver isso). Agora cada loja é um item de acordeão fechado por
// padrão (mesmo padrão já usado no FAQ da Biblioteca Técnica, ver
// LibraryContent.js/wireAccordion), com chips de filtro por loja e por
// período em cima (mesmo padrão de .lib-tabs/.lib-tab) — os dois filtros
// combinam entre si (ex.: "Moema" + "Últimos 7 dias" ao mesmo tempo).
// A lista é reconstruída em JS a cada troca de filtro (a partir do array
// `rows` original guardado em closure) pra manter a contagem "X respostas"
// de cada loja sempre correta pro recorte ativo.

const PERIOD_OPTIONS = [
  { value: 'todos', label: 'Todo o período', days: null },
  { value: '7', label: 'Últimos 7 dias', days: 7 },
  { value: '15', label: 'Últimos 15 dias', days: 15 },
  { value: '30', label: 'Últimos 30 dias', days: 30 },
];

function renderQuizReportSection(rows) {
  if (!rows.length) {
    return '<p class="learning-empty">Nenhuma tentativa de quiz registrada ainda.</p>';
  }

  const storeNames = Object.keys(groupByStore(rows)).sort((a, b) => a.localeCompare(b, 'pt-BR'));

  return `
    <div class="lib-tabs" data-role="quiz-report-period-tabs">
      ${PERIOD_OPTIONS.map((p) => `<button type="button" class="lib-tab ${p.value === 'todos' ? 'active' : ''}" data-period-filter="${p.value}">${p.label}</button>`).join('')}
    </div>
    <div class="lib-tabs" data-role="quiz-report-tabs" style="margin-top:8px;">
      <button type="button" class="lib-tab active" data-store-filter="todos">Todas as lojas</button>
      ${storeNames.map((name) => `<button type="button" class="lib-tab" data-store-filter="${name}">${name}</button>`).join('')}
    </div>
    <div class="lib-accordion" data-role="quiz-report-list"></div>`;
}

function wireQuizReportSection(container, rows) {
  const periodTabsEl = container.querySelector('[data-role="quiz-report-period-tabs"]');
  const storeTabsEl = container.querySelector('[data-role="quiz-report-tabs"]');
  const listEl = container.querySelector('[data-role="quiz-report-list"]');
  if (!periodTabsEl || !storeTabsEl || !listEl) return;

  let activePeriod = 'todos';
  let activeStore = 'todos';

  function renderList() {
    const periodDef = PERIOD_OPTIONS.find((p) => p.value === activePeriod);
    const cutoff = periodDef?.days ? Date.now() - periodDef.days * 24 * 60 * 60 * 1000 : null;
    const filteredRows = cutoff ? rows.filter((r) => new Date(r.finished_at).getTime() >= cutoff) : rows;

    if (!filteredRows.length) {
      listEl.innerHTML = '<p class="learning-empty">Nenhuma tentativa nesse período.</p>';
      return;
    }

    const byStore = groupByStore(filteredRows);
    const storeNames = Object.keys(byStore).sort((a, b) => a.localeCompare(b, 'pt-BR'));

    listEl.innerHTML = storeNames.map((storeName, i) => `
      <div class="lib-acc-item" data-store-block="${storeName}" ${activeStore !== 'todos' && activeStore !== storeName ? 'hidden' : ''}>
        <button type="button" class="lib-acc-btn" data-acc-target="quiz-report-${i}">
          <span>🏬 ${storeName} · ${byStore[storeName].length} respostas</span><span class="lib-acc-chevron">▼</span>
        </button>
        <div class="lib-acc-body" id="quiz-report-${i}" hidden>${renderStoreTable(byStore[storeName])}</div>
      </div>
    `).join('');

    listEl.querySelectorAll('[data-acc-target]').forEach((btn) => {
      btn.addEventListener('click', () => {
        const body = listEl.querySelector(`#${CSS.escape(btn.dataset.accTarget)}`);
        if (!body) return;
        body.hidden = !body.hidden;
        btn.classList.toggle('open', !body.hidden);
      });
    });

    // Filtrar por uma loja específica já abre o acordeão dela — não faz
    // sentido escolher "Moema" e ainda precisar clicar de novo pra ver.
    if (activeStore !== 'todos') {
      const block = listEl.querySelector(`[data-store-block="${CSS.escape(activeStore)}"]`);
      const body = block?.querySelector('.lib-acc-body');
      const accBtn = block?.querySelector('[data-acc-target]');
      if (body && body.hidden) {
        body.hidden = false;
        accBtn.classList.add('open');
      }
    }
  }

  periodTabsEl.querySelectorAll('[data-period-filter]').forEach((tab) => {
    tab.addEventListener('click', () => {
      activePeriod = tab.dataset.periodFilter;
      periodTabsEl.querySelectorAll('[data-period-filter]').forEach((t) => t.classList.toggle('active', t === tab));
      renderList();
    });
  });

  storeTabsEl.querySelectorAll('[data-store-filter]').forEach((tab) => {
    tab.addEventListener('click', () => {
      activeStore = tab.dataset.storeFilter;
      storeTabsEl.querySelectorAll('[data-store-filter]').forEach((t) => t.classList.toggle('active', t === tab));
      renderList();
    });
  });

  renderList();
}

function groupByStore(rows) {
  return rows.reduce((acc, r) => {
    const storeName = r.profiles?.stores?.name || 'Sem loja';
    if (!acc[storeName]) acc[storeName] = [];
    acc[storeName].push(r);
    return acc;
  }, {});
}

function renderStoreTable(rows) {
  return `
    <div class="lib-table-wrap">
      <table class="lib-table">
        <thead><tr><th>Colaborador</th><th>Quiz</th><th>Tentativa</th><th>Nota</th><th>Resultado</th><th>Data</th></tr></thead>
        <tbody>
          ${rows.map((r) => `
            <tr>
              <td class="lib-prod-name">${r.profiles?.full_name || '—'}</td>
              <td class="lib-prod-para">${r.quizzes?.title || '—'}</td>
              <td>${r.attempt_number ?? '—'}</td>
              <td>${r.score_pct != null ? `${r.score_pct}%` : '—'}</td>
              <td>${renderResultBadge(r.passed)}</td>
              <td class="lib-prod-para">${new Date(r.finished_at).toLocaleDateString('pt-BR')}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>`;
}

function renderResultBadge(passed) {
  if (passed === true) return '<span class="gaps-badge gaps-badge-controle">Aprovado</span>';
  if (passed === false) return '<span class="gaps-badge gaps-badge-critico">Reprovado</span>';
  return '—';
}
