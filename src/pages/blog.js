// src/pages/blog.js
// Blog da organização (não por marca) — categorias fixas (Caso Real,
// Novidade, Comunicado, Dica), leitura pra qualquer autenticado, autoria
// só pelo Admin (RLS já existia no schema base, sem UI até 2026-07-10).

import { getCurrentProfile, isAdminProfile } from '../config/supabase.js';
import {
  CATEGORIES,
  fetchPublishedPosts,
  fetchAllPostsForAdmin,
  createPost,
  updatePost,
  deletePost,
  markPostAsRead,
  fetchReadPostIds,
} from '../services/blogService.js';

const CATEGORY_CLASS = {
  'Caso Real': 'blog-badge-caso',
  'Novidade': 'blog-badge-novidade',
  'Comunicado': 'blog-badge-comunicado',
  'Dica': 'blog-badge-dica',
};

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'blog') initBlogPage();
});

async function initBlogPage() {
  const container = document.getElementById('blogContainer');
  if (!container) return;

  container.innerHTML = '<p class="learning-loading">Carregando…</p>';

  try {
    const profile = await getCurrentProfile();
    const isAdmin = isAdminProfile(profile);
    const posts = isAdmin ? await fetchAllPostsForAdmin() : await fetchPublishedPosts();
    const readPostIds = profile ? await fetchReadPostIds(profile.id) : [];
    renderBlog(container, posts, profile, isAdmin, new Set(readPostIds));
  } catch (err) {
    console.error('[Blog] erro ao carregar posts:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar o blog agora.</p>';
  }
}

function renderBlog(container, posts, profile, isAdmin, readPostIds) {
  container.innerHTML = `
    ${isAdmin ? `
      <div class="admin-create-card" style="margin-bottom:24px;">
        <div style="display:flex; align-items:center; justify-content:space-between;">
          <h3 class="dash-section-label" style="margin:0;">Novo Post</h3>
          <button type="button" class="cb-editor-btn" data-role="blog-new-toggle">+ Novo Post</button>
        </div>
        <div data-role="blog-new-form" hidden></div>
      </div>
    ` : ''}
    <div class="blog-list" data-role="blog-list">
      ${posts.length ? posts.map((p) => postCardHtml(p, isAdmin, profile, readPostIds)).join('') : '<p class="learning-empty">Nenhum post publicado ainda.</p>'}
    </div>
  `;

  if (isAdmin) {
    container.querySelector('[data-role="blog-new-toggle"]').addEventListener('click', (e) => {
      const formEl = container.querySelector('[data-role="blog-new-form"]');
      const showing = !formEl.hidden;
      if (showing) {
        formEl.hidden = true;
        e.target.textContent = '+ Novo Post';
        return;
      }
      formEl.innerHTML = postFormHtml(null);
      formEl.hidden = false;
      e.target.textContent = 'Cancelar';
      wirePostForm(formEl, null, profile, () => initBlogPage());
    });
  }

  wirePostCards(container, posts, profile, isAdmin);
  wireMarkAsRead(container, profile);
}

function postCardHtml(post, isAdmin, profile, readPostIds) {
  const date = new Date(post.created_at).toLocaleDateString('pt-BR', { day: '2-digit', month: 'short', year: 'numeric' });
  const badgeClass = CATEGORY_CLASS[post.category] || 'blog-badge-novidade';
  const isRead = readPostIds?.has(post.id);
  return `
    <article class="blog-card" data-post-id="${post.id}">
      ${post.banner_url ? `<img src="${post.banner_url}" alt="" class="blog-card-banner">` : ''}
      <div class="blog-card-body">
        <div class="blog-card-meta">
          <span class="blog-badge ${badgeClass}">${post.category}</span>
          ${isAdmin && !post.is_published ? '<span class="blog-badge blog-badge-draft">Rascunho</span>' : ''}
          <span class="blog-card-date">${date}${post.author_name ? ` · ${post.author_name}` : ''}</span>
        </div>
        <h3 class="blog-card-title" data-role="blog-title-toggle">${post.title}</h3>
        <div class="blog-card-content" data-role="blog-content" hidden>${post.content}</div>
        <div class="blog-card-actions">
          <button type="button" class="blog-read-more" data-role="blog-title-toggle">Ler mais</button>
          ${profile ? `
            <button type="button" class="cb-editor-btn" data-role="blog-mark-read" ${isRead ? 'disabled' : ''}>
              ${isRead ? '✓ Lido' : 'Marcar como lido'}
            </button>
          ` : ''}
          ${isAdmin ? `
            <button type="button" class="cb-editor-btn" data-role="blog-edit">Editar</button>
            <button type="button" class="cb-editor-btn cb-editor-btn-danger" data-role="blog-delete">Excluir</button>
          ` : ''}
        </div>
        <div class="blog-edit-form" data-role="blog-edit-form" hidden></div>
      </div>
    </article>`;
}

/** "Marcar como lido" (blog_reads, sql/048) — base do tipo "blog" na Homologação Semanal. */
function wireMarkAsRead(container, profile) {
  if (!profile) return;
  container.querySelectorAll('[data-role="blog-mark-read"]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const postId = btn.closest('.blog-card').dataset.postId;
      btn.disabled = true;
      try {
        await markPostAsRead(profile.id, postId);
        btn.textContent = '✓ Lido';
      } catch (err) {
        console.error('[Blog] erro ao marcar como lido:', err);
        btn.disabled = false;
        btn.textContent = 'Marcar como lido';
      }
    });
  });
}

function postFormHtml(post) {
  const p = post || { title: '', content: '', category: CATEGORIES[1], banner_url: '', is_published: true };
  return `
    <form class="blog-form">
      <input type="text" name="title" class="ranking-highlight-textarea" placeholder="Título" value="${p.title}" required>
      <select name="category" class="ranking-highlight-textarea">
        ${CATEGORIES.map((c) => `<option value="${c}" ${c === p.category ? 'selected' : ''}>${c}</option>`).join('')}
      </select>
      <input type="text" name="banner_url" class="ranking-highlight-textarea" placeholder="URL do banner (opcional)" value="${p.banner_url || ''}">
      <textarea name="content" class="ranking-highlight-textarea" rows="6" placeholder="Conteúdo (HTML permitido)" required>${p.content}</textarea>
      <label style="display:flex; align-items:center; gap:6px; font-size:13px; color:var(--text2);">
        <input type="checkbox" name="is_published" ${p.is_published ? 'checked' : ''}> Publicado
      </label>
      <div class="cb-editor-save-row">
        <button type="submit" class="cb-editor-btn">Salvar</button>
        <div class="ranking-highlight-form-msg" data-role="msg"></div>
      </div>
    </form>`;
}

function wirePostForm(formContainer, post, profile, onSaved) {
  const form = formContainer.querySelector('form');
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const msgEl = form.querySelector('[data-role="msg"]');
    msgEl.textContent = 'Salvando…';
    msgEl.style.color = 'var(--text3)';

    const fd = new FormData(form);
    const payload = {
      title: fd.get('title').trim(),
      content: fd.get('content').trim(),
      category: fd.get('category'),
      bannerUrl: fd.get('banner_url').trim(),
      isPublished: fd.get('is_published') === 'on',
    };

    try {
      if (post) {
        await updatePost(post.id, payload);
      } else {
        await createPost({ ...payload, authorId: profile.id });
      }
      onSaved();
    } catch (err) {
      console.error('[Blog] erro ao salvar post:', err);
      msgEl.textContent = 'Erro ao salvar: ' + err.message;
      msgEl.style.color = 'var(--g)';
    }
  });
}

function wirePostCards(container, posts, profile, isAdmin) {
  container.querySelectorAll('[data-role="blog-title-toggle"]').forEach((el) => {
    el.addEventListener('click', () => {
      const card = el.closest('.blog-card');
      const contentEl = card.querySelector('[data-role="blog-content"]');
      contentEl.hidden = !contentEl.hidden;
      const readMoreBtn = card.querySelector('.blog-read-more');
      if (readMoreBtn) readMoreBtn.textContent = contentEl.hidden ? 'Ler mais' : 'Ler menos';
    });
  });

  if (!isAdmin) return;

  container.querySelectorAll('[data-role="blog-delete"]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const card = btn.closest('.blog-card');
      const postId = card.dataset.postId;
      if (!window.confirm('Excluir este post do blog? Essa ação não pode ser desfeita.')) return;
      try {
        await deletePost(postId);
        initBlogPage();
      } catch (err) {
        console.error('[Blog] erro ao excluir post:', err);
        window.alert('Erro ao excluir: ' + err.message);
      }
    });
  });

  container.querySelectorAll('[data-role="blog-edit"]').forEach((btn) => {
    btn.addEventListener('click', () => {
      const card = btn.closest('.blog-card');
      const postId = card.dataset.postId;
      const post = posts.find((p) => p.id === postId);
      const editFormEl = card.querySelector('[data-role="blog-edit-form"]');
      editFormEl.innerHTML = postFormHtml(post);
      editFormEl.hidden = false;
      wirePostForm(editFormEl, post, profile, () => initBlogPage());
    });
  });
}
