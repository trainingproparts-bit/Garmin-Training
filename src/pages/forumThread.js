// src/pages/forumThread.js
// Fórum — tópico individual: corpo, controles de moderação (líder/admin),
// resposta-solução destacada, lista de respostas com voto, composer de
// resposta (escondido se o tópico estiver trancado). Padrão de retorno
// dinâmico (window.selectedForumThreadId / window.forumReturnPanel), igual
// produtoDetail.js — o tópico é alcançável da lista, da busca e de um
// clique em notificação do sino.

import { getCurrentProfile, isLeaderProfile, isAdminProfile } from '../config/supabase.js';
import { navigateToPanel } from '../router.js';
import {
  fetchThreadById,
  fetchReplies,
  fetchVoteCounts,
  createReply,
  updateThreadContent,
  setThreadPinned,
  setThreadLocked,
  setThreadSolution,
  deleteThread,
  updateReplyContent,
  deleteReply,
  toggleVote,
} from '../services/forumService.js';

const ROLE_LABEL = { admin: 'Admin', leader: 'Líder' };

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'forum-topico') initForumThreadPage();
});

async function initForumThreadPage() {
  const container = document.getElementById('forumThreadContainer');
  const titleEl = document.getElementById('forumThreadTitle');
  if (!container) return;

  const threadId = window.selectedForumThreadId;
  if (!threadId) {
    container.innerHTML = '<p class="learning-error">Nenhum tópico selecionado.</p>';
    return;
  }

  container.innerHTML = '<p class="learning-loading">Carregando tópico…</p>';

  try {
    const [profile, thread, replies, votes] = await Promise.all([
      getCurrentProfile(),
      fetchThreadById(threadId),
      fetchReplies(threadId),
      fetchVoteCounts(threadId),
    ]);
    if (titleEl) titleEl.textContent = thread.title;
    renderThread(container, thread, replies, votes, profile);
  } catch (err) {
    console.error('[ForumThread] erro ao carregar tópico:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar este tópico agora.</p>';
  }
}

function reload() {
  initForumThreadPage();
}

function renderThread(container, thread, replies, votes, profile) {
  const isMod = profile && (isLeaderProfile(profile) || isAdminProfile(profile));
  const isAuthor = profile && profile.id === thread.author_id;
  const canModerateThread = isMod;
  const canMarkSolution = isAuthor || isMod;

  const voteCountByReply = new Map();
  const myVoteReplyIds = new Set();
  (votes || []).forEach((v) => {
    voteCountByReply.set(v.reply_id, (voteCountByReply.get(v.reply_id) || 0) + 1);
    if (profile && v.user_id === profile.id) myVoteReplyIds.add(v.reply_id);
  });

  const solutionReply = replies.find((r) => r.id === thread.solution_reply_id);
  const otherReplies = replies.filter((r) => r.id !== thread.solution_reply_id);

  container.innerHTML = `
    <div class="forum-thread-header">
      <div class="forum-thread-header-top">
        <span class="forum-category-badge">${thread.category_name}</span>
        ${thread.is_pinned ? '<span class="forum-flag forum-flag-pinned">📌 Fixado</span>' : ''}
        ${thread.is_solved ? '<span class="forum-flag forum-flag-solved">✓ Resolvido</span>' : ''}
        ${thread.is_locked ? '<span class="forum-flag forum-flag-locked">🔒 Trancado</span>' : ''}
      </div>
      <h2 class="forum-thread-title">${thread.title}</h2>
      <div class="forum-thread-card-meta">
        <span>${thread.author_name}${ROLE_LABEL[thread.author_role_code] ? ` <span class="role-badge role-badge-${thread.author_role_code}">${ROLE_LABEL[thread.author_role_code]}</span>` : ''}</span>
        <span>${new Date(thread.created_at).toLocaleDateString('pt-BR')}</span>
      </div>
      <div class="forum-post-body" data-role="thread-body">${escapeAndBreak(thread.body)}</div>

      <div class="forum-post-actions">
        ${isAuthor ? '<button type="button" class="cb-editor-btn" data-role="edit-thread">Editar</button>' : ''}
        ${isAuthor || isMod ? '<button type="button" class="cb-editor-btn cb-editor-btn-danger" data-role="delete-thread">Excluir tópico</button>' : ''}
        ${canModerateThread ? `
          <button type="button" class="cb-editor-btn" data-role="toggle-pin">${thread.is_pinned ? 'Desfixar' : 'Fixar'}</button>
          <button type="button" class="cb-editor-btn" data-role="toggle-lock">${thread.is_locked ? 'Reabrir' : 'Trancar'}</button>
        ` : ''}
      </div>
      <div data-role="edit-thread-form" hidden></div>
    </div>

    ${solutionReply ? `
      <h3 class="dash-section-label" style="margin-top:24px;">✓ Solução</h3>
      <div data-role="reply-list-solution">${replyCardHtml(solutionReply, { isSolution: true, voteCount: voteCountByReply.get(solutionReply.id) || 0, iVoted: myVoteReplyIds.has(solutionReply.id), profile, isMod, canMarkSolution })}</div>
    ` : ''}

    <h3 class="dash-section-label" style="margin-top:24px;">${otherReplies.length} ${otherReplies.length === 1 ? 'Resposta' : 'Respostas'}</h3>
    <div data-role="reply-list">
      ${otherReplies.length
        ? otherReplies.map((r) => replyCardHtml(r, { isSolution: false, voteCount: voteCountByReply.get(r.id) || 0, iVoted: myVoteReplyIds.has(r.id), profile, isMod, canMarkSolution })).join('')
        : '<p class="learning-empty">Nenhuma resposta ainda, seja o primeiro.</p>'}
    </div>

    ${thread.is_locked
      ? '<p class="dash-empty-text" style="margin-top:16px;">Este tópico está trancado, não aceita novas respostas.</p>'
      : profile ? `
        <div class="admin-create-card" style="margin-top:16px;">
          <form id="forumReplyForm">
            <textarea name="body" class="login-input" rows="4" placeholder="Escreva sua resposta…" required></textarea>
            <button type="submit" class="login-btn admin-create-submit" style="margin-top:8px; width:auto;">Responder</button>
          </form>
        </div>` : ''}
  `;

  wireThreadActions(container, thread, profile, canModerateThread, isAuthor);
  wireReplyActions(container, thread, profile, isMod, canMarkSolution);
}

function replyCardHtml(reply, { isSolution, voteCount, iVoted, profile, isMod, canMarkSolution }) {
  const author = reply.author || {};
  const roleCode = author.roles?.code;
  const isReplyAuthor = profile && profile.id === author.id;
  return `
    <article class="forum-reply-card${isSolution ? ' is-solution' : ''}" data-reply-id="${reply.id}">
      <div class="forum-reply-vote">
        <button type="button" class="forum-vote-btn${iVoted ? ' is-voted' : ''}" data-role="vote-btn" ${profile ? '' : 'disabled'}>▲</button>
        <span class="forum-vote-count">${voteCount}</span>
      </div>
      <div class="forum-reply-content">
        <div class="forum-thread-card-meta">
          <span>${author.full_name || '—'}${ROLE_LABEL[roleCode] ? ` <span class="role-badge role-badge-${roleCode}">${ROLE_LABEL[roleCode]}</span>` : ''}</span>
          <span>${new Date(reply.created_at).toLocaleDateString('pt-BR')}</span>
        </div>
        <div class="forum-post-body" data-role="reply-body">${escapeAndBreak(reply.body)}</div>
        <div class="forum-post-actions">
          ${canMarkSolution ? `<button type="button" class="cb-editor-btn" data-role="toggle-solution">${isSolution ? 'Desmarcar solução' : 'Marcar como solução'}</button>` : ''}
          ${isReplyAuthor ? '<button type="button" class="cb-editor-btn" data-role="edit-reply">Editar</button>' : ''}
          ${isReplyAuthor || isMod ? '<button type="button" class="cb-editor-btn cb-editor-btn-danger" data-role="delete-reply">Excluir</button>' : ''}
        </div>
        <div data-role="edit-reply-form" hidden></div>
      </div>
    </article>`;
}

function escapeAndBreak(text) {
  const div = document.createElement('div');
  div.textContent = text || '';
  return div.innerHTML.replace(/\n/g, '<br>');
}

function wireThreadActions(container, thread, profile, canModerateThread, isAuthor) {
  container.querySelector('[data-role="delete-thread"]')?.addEventListener('click', async () => {
    if (!window.confirm(`Excluir o tópico "${thread.title}"? As respostas também serão apagadas. Essa ação não pode ser desfeita.`)) return;
    try {
      await deleteThread(thread.id);
      navigateToPanel(window.forumReturnPanel || 'forum');
    } catch (err) {
      console.error('[ForumThread] erro ao excluir tópico:', err);
      window.alert('Não foi possível excluir agora.');
    }
  });

  container.querySelector('[data-role="toggle-pin"]')?.addEventListener('click', async (e) => {
    e.target.disabled = true;
    try {
      await setThreadPinned(thread.id, !thread.is_pinned);
      reload();
    } catch (err) {
      console.error('[ForumThread] erro ao fixar/desfixar:', err);
      window.alert('Não foi possível atualizar agora.');
      e.target.disabled = false;
    }
  });

  container.querySelector('[data-role="toggle-lock"]')?.addEventListener('click', async (e) => {
    e.target.disabled = true;
    try {
      await setThreadLocked(thread.id, !thread.is_locked);
      reload();
    } catch (err) {
      console.error('[ForumThread] erro ao trancar/reabrir:', err);
      window.alert('Não foi possível atualizar agora.');
      e.target.disabled = false;
    }
  });

  container.querySelector('[data-role="edit-thread"]')?.addEventListener('click', () => {
    const formEl = container.querySelector('[data-role="edit-thread-form"]');
    formEl.innerHTML = `
      <form data-role="edit-thread-inline-form" style="margin-top:10px;">
        <input type="text" name="title" class="login-input" value="${thread.title}" required>
        <textarea name="body" class="login-input" rows="6" required style="margin-top:8px;">${thread.body}</textarea>
        <div class="cb-editor-save-row" style="margin-top:8px;">
          <button type="submit" class="cb-editor-btn">Salvar</button>
          <button type="button" class="cb-editor-btn" data-role="cancel-edit-thread">Cancelar</button>
        </div>
      </form>`;
    formEl.hidden = false;

    formEl.querySelector('[data-role="cancel-edit-thread"]').addEventListener('click', () => { formEl.hidden = true; formEl.innerHTML = ''; });
    formEl.querySelector('form').addEventListener('submit', async (e) => {
      e.preventDefault();
      const fd = new FormData(e.target);
      try {
        await updateThreadContent(thread.id, { title: fd.get('title').trim(), body: fd.get('body').trim() });
        reload();
      } catch (err) {
        console.error('[ForumThread] erro ao editar tópico:', err);
        window.alert('Não foi possível salvar agora.');
      }
    });
  });

  const replyForm = container.querySelector('#forumReplyForm');
  replyForm?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const submitBtn = e.target.querySelector('button[type="submit"]');
    submitBtn.disabled = true;
    const fd = new FormData(e.target);
    try {
      await createReply({ threadId: thread.id, authorId: profile.id, body: fd.get('body').trim() });
      reload();
    } catch (err) {
      console.error('[ForumThread] erro ao responder:', err);
      window.alert('Não foi possível enviar a resposta agora.');
      submitBtn.disabled = false;
    }
  });
}

function wireReplyActions(container, thread, profile, isMod, canMarkSolution) {
  container.querySelectorAll('[data-role="vote-btn"]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      if (!profile) return;
      const replyId = btn.closest('[data-reply-id]').dataset.replyId;
      btn.disabled = true;
      try {
        await toggleVote(replyId, profile.id);
        reload();
      } catch (err) {
        console.error('[ForumThread] erro ao votar:', err);
        btn.disabled = false;
      }
    });
  });

  container.querySelectorAll('[data-role="toggle-solution"]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const replyId = btn.closest('[data-reply-id]').dataset.replyId;
      const alreadySolution = thread.solution_reply_id === replyId;
      btn.disabled = true;
      try {
        await setThreadSolution(thread.id, alreadySolution ? null : replyId);
        reload();
      } catch (err) {
        console.error('[ForumThread] erro ao marcar solução:', err);
        window.alert('Não foi possível atualizar agora.');
        btn.disabled = false;
      }
    });
  });

  container.querySelectorAll('[data-role="delete-reply"]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      if (!window.confirm('Excluir esta resposta? Essa ação não pode ser desfeita.')) return;
      const replyId = btn.closest('[data-reply-id]').dataset.replyId;
      try {
        await deleteReply(replyId);
        reload();
      } catch (err) {
        console.error('[ForumThread] erro ao excluir resposta:', err);
        window.alert('Não foi possível excluir agora.');
      }
    });
  });

  container.querySelectorAll('[data-role="edit-reply"]').forEach((btn) => {
    btn.addEventListener('click', () => {
      const card = btn.closest('[data-reply-id]');
      const replyId = card.dataset.replyId;
      const bodyEl = card.querySelector('[data-role="reply-body"]');
      const formEl = card.querySelector('[data-role="edit-reply-form"]');
      formEl.innerHTML = `
        <form data-role="edit-reply-inline-form" style="margin-top:8px;">
          <textarea name="body" class="login-input" rows="4" required>${bodyEl.textContent}</textarea>
          <div class="cb-editor-save-row" style="margin-top:8px;">
            <button type="submit" class="cb-editor-btn">Salvar</button>
            <button type="button" class="cb-editor-btn" data-role="cancel-edit-reply">Cancelar</button>
          </div>
        </form>`;
      formEl.hidden = false;

      formEl.querySelector('[data-role="cancel-edit-reply"]').addEventListener('click', () => { formEl.hidden = true; formEl.innerHTML = ''; });
      formEl.querySelector('form').addEventListener('submit', async (e) => {
        e.preventDefault();
        const fd = new FormData(e.target);
        try {
          await updateReplyContent(replyId, fd.get('body').trim());
          reload();
        } catch (err) {
          console.error('[ForumThread] erro ao editar resposta:', err);
          window.alert('Não foi possível salvar agora.');
        }
      });
    });
  });
}
