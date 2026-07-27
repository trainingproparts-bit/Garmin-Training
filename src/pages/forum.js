// src/pages/forum.js
// Fórum/Comunidade de Dúvidas — visão geral: banner explicativo (pedido
// explícito do usuário: explicar pra que serve logo no topo), busca,
// filtro de categoria + status + ordenação, lista de tópicos. Organização
// inteira (sem brand_id, mesmo padrão de blog.js).

import { getCurrentProfile, isLeaderProfile, isAdminProfile } from '../config/supabase.js';
import { navigateToPanel, getActivePanelId } from '../router.js';
import { fetchCategories, fetchThreadList } from '../services/forumService.js';

const STATUS_OPTIONS = [
  { value: 'all', label: 'Todos' },
  { value: 'resolved', label: 'Resolvido' },
  { value: 'unanswered', label: 'Sem Resposta' },
];

const SORT_OPTIONS = [
  { value: 'recent', label: 'Mais Recentes' },
  { value: 'popular', label: 'Mais Populares' },
];

const ROLE_LABEL = { admin: 'Admin', leader: 'Líder' };

let allThreads = [];
let categories = [];
const state = { search: '', categoryId: '', status: 'all', sort: 'recent' };

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'forum') initForumPage();
});

async function initForumPage() {
  const container = document.getElementById('forumContainer');
  if (!container) return;

  container.innerHTML = '<p class="learning-loading">Carregando fórum…</p>';
  state.search = '';
  state.categoryId = '';
  state.status = 'all';
  state.sort = 'recent';

  try {
    const [profile, threads, cats] = await Promise.all([
      getCurrentProfile(),
      fetchThreadList(),
      fetchCategories(),
    ]);
    allThreads = threads || [];
    categories = cats || [];
    renderForum(container, profile);
  } catch (err) {
    console.error('[Forum] erro ao carregar fórum:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar o fórum agora.</p>';
  }
}

function renderForum(container, profile) {
  container.innerHTML = `
    <div class="forum-explainer">
      <h3 class="dash-section-label" style="margin-top:0;">💬 Fórum de Dúvidas e Comunidade</h3>
      <p>Espaço pra tirar dúvidas, resolver problemas do dia a dia e trocar conhecimento com o resto da equipe. Qualquer colaborador pode criar um tópico, responder e votar nas melhores respostas. O autor do tópico (ou um líder/admin) pode marcar uma resposta como <strong>solução oficial</strong>, ela fica destacada no topo pra quem chegar depois com a mesma dúvida.</p>
      <details class="forum-permissions">
        <summary>Quem pode fazer o quê</summary>
        <table class="lib-table" style="margin-top:10px;">
          <thead><tr><th>Ação</th><th>Colaborador</th><th>Líder</th><th>Admin</th></tr></thead>
          <tbody>
            <tr><td>Criar tópico, responder, votar</td><td>✓</td><td>✓</td><td>✓</td></tr>
            <tr><td>Editar/excluir o próprio post</td><td>✓</td><td>✓</td><td>✓</td></tr>
            <tr><td>Marcar solução (no próprio tópico)</td><td>✓</td><td>✓</td><td>✓</td></tr>
            <tr><td>Editar/excluir post de outra pessoa</td><td>—</td><td>✓</td><td>✓</td></tr>
            <tr><td>Fixar ou trancar tópico</td><td>—</td><td>✓</td><td>✓</td></tr>
            <tr><td>Gerenciar categorias</td><td>—</td><td>—</td><td>✓</td></tr>
          </tbody>
        </table>
      </details>
    </div>

    <div class="forum-toolbar">
      <input type="text" id="forumSearchInput" class="login-input" placeholder="Buscar por palavra-chave…" style="flex:1 1 220px;">
      <button type="button" class="login-btn admin-create-submit" id="forumNovoTopicoBtn" style="width:auto; flex-shrink:0;">+ Novo Tópico</button>
    </div>

    <div class="lib-tabs" data-role="forum-category-tabs">
      <button type="button" class="lib-tab active" data-category-filter="">Todas as categorias</button>
      ${categories.map((c) => `<button type="button" class="lib-tab" data-category-filter="${c.id}">${c.name}</button>`).join('')}
    </div>

    <div class="forum-filter-row">
      <select id="forumStatusFilter" class="login-input" style="width:auto;">
        ${STATUS_OPTIONS.map((o) => `<option value="${o.value}">${o.label}</option>`).join('')}
      </select>
      <select id="forumSortFilter" class="login-input" style="width:auto;">
        ${SORT_OPTIONS.map((o) => `<option value="${o.value}">${o.label}</option>`).join('')}
      </select>
    </div>

    <div data-role="forum-thread-list"></div>
  `;

  renderThreadList(container);
  wireForumControls(container, profile);
}

function applyFilters() {
  let rows = [...allThreads];

  if (state.categoryId) rows = rows.filter((t) => t.category_id === state.categoryId);
  if (state.status === 'resolved') rows = rows.filter((t) => t.is_solved);
  if (state.status === 'unanswered') rows = rows.filter((t) => t.reply_count === 0);
  if (state.search.trim()) {
    const term = state.search.trim().toLowerCase();
    rows = rows.filter((t) => t.title.toLowerCase().includes(term) || t.body.toLowerCase().includes(term));
  }

  rows.sort((a, b) => {
    if (a.is_pinned !== b.is_pinned) return a.is_pinned ? -1 : 1;
    if (state.sort === 'popular') return (b.vote_count + b.reply_count) - (a.vote_count + a.reply_count);
    return new Date(b.last_activity_at) - new Date(a.last_activity_at);
  });

  return rows;
}

function renderThreadList(container) {
  const listEl = container.querySelector('[data-role="forum-thread-list"]');
  const rows = applyFilters();

  if (!rows.length) {
    listEl.innerHTML = '<p class="learning-empty">Nenhum tópico encontrado com esses filtros.</p>';
    return;
  }

  listEl.innerHTML = `
    <div class="forum-thread-cards">
      ${rows.map(threadCardHtml).join('')}
    </div>`;

  listEl.querySelectorAll('[data-thread-id]').forEach((card) => {
    card.addEventListener('click', () => {
      window.selectedForumThreadId = card.dataset.threadId;
      window.forumReturnPanel = getActivePanelId() || 'forum';
      navigateToPanel('forum-topico');
    });
  });
}

function threadCardHtml(t) {
  const roleLabel = ROLE_LABEL[t.author_role_code];
  const time = new Date(t.last_activity_at).toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' });
  return `
    <article class="forum-thread-card" data-thread-id="${t.id}">
      <div class="forum-thread-card-top">
        <span class="forum-category-badge">${t.category_name}</span>
        ${t.is_pinned ? '<span class="forum-flag forum-flag-pinned">📌 Fixado</span>' : ''}
        ${t.is_solved ? '<span class="forum-flag forum-flag-solved">✓ Resolvido</span>' : ''}
        ${t.is_locked ? '<span class="forum-flag forum-flag-locked">🔒 Trancado</span>' : ''}
      </div>
      <h4 class="forum-thread-card-title">${t.title}</h4>
      <div class="forum-thread-card-meta">
        <span>${t.author_name}${roleLabel ? ` <span class="role-badge role-badge-${t.author_role_code}">${roleLabel}</span>` : ''}</span>
        <span>${t.reply_count} ${t.reply_count === 1 ? 'resposta' : 'respostas'}</span>
        <span>${t.vote_count} ${t.vote_count === 1 ? 'voto' : 'votos'}</span>
        <span>${time}</span>
      </div>
    </article>`;
}

function wireForumControls(container, profile) {
  container.querySelector('#forumNovoTopicoBtn').addEventListener('click', () => {
    window.forumReturnPanel = getActivePanelId() || 'forum';
    navigateToPanel('forum-novo-topico');
  });

  let debounceTimer;
  container.querySelector('#forumSearchInput').addEventListener('input', (e) => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      state.search = e.target.value;
      renderThreadList(container);
    }, 250);
  });

  container.querySelectorAll('[data-category-filter]').forEach((tab) => {
    tab.addEventListener('click', () => {
      state.categoryId = tab.dataset.categoryFilter;
      container.querySelectorAll('[data-category-filter]').forEach((t) => t.classList.toggle('active', t === tab));
      renderThreadList(container);
    });
  });

  container.querySelector('#forumStatusFilter').addEventListener('change', (e) => {
    state.status = e.target.value;
    renderThreadList(container);
  });

  container.querySelector('#forumSortFilter').addEventListener('change', (e) => {
    state.sort = e.target.value;
    renderThreadList(container);
  });
}
