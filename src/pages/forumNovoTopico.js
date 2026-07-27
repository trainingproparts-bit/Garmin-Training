// src/pages/forumNovoTopico.js
// Fórum — criação de tópico. Painel próprio (não inline), como pedido
// explicitamente pelo usuário na lista de telas.

import { getCurrentProfile } from '../config/supabase.js';
import { navigateToPanel } from '../router.js';
import { fetchCategories, createThread } from '../services/forumService.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'forum-novo-topico') initForumNovoTopicoPage();
});

async function initForumNovoTopicoPage() {
  const container = document.getElementById('forumNovoTopicoContainer');
  if (!container) return;

  container.innerHTML = '<p class="learning-loading">Carregando…</p>';

  try {
    const [profile, categories] = await Promise.all([getCurrentProfile(), fetchCategories()]);
    if (!profile) {
      container.innerHTML = '<p class="learning-error">Faça login pra criar um tópico.</p>';
      return;
    }
    renderForm(container, profile, categories);
  } catch (err) {
    console.error('[ForumNovoTopico] erro ao carregar:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar agora.</p>';
  }
}

function renderForm(container, profile, categories) {
  container.innerHTML = `
    <div class="admin-create-card">
      <form id="forumNovoTopicoForm" class="admin-create-form">
        <select name="category_id" class="login-input" required>
          <option value="">Categoria...</option>
          ${categories.map((c) => `<option value="${c.id}">${c.name}</option>`).join('')}
        </select>
        <input type="text" name="title" class="login-input" placeholder="Título do tópico" required autocomplete="off">
        <textarea name="body" class="login-input" rows="8" placeholder="Descreva sua dúvida ou o que quer discutir…" required></textarea>
        <button type="submit" class="login-btn admin-create-submit" id="forumNovoTopicoSubmit">Criar Tópico</button>
      </form>
      <div id="forumNovoTopicoResult"></div>
    </div>`;

  const form = container.querySelector('#forumNovoTopicoForm');
  const resultEl = container.querySelector('#forumNovoTopicoResult');

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const submitBtn = form.querySelector('#forumNovoTopicoSubmit');
    submitBtn.disabled = true;
    submitBtn.textContent = 'Criando…';
    resultEl.innerHTML = '';

    const fd = new FormData(form);
    try {
      const thread = await createThread({
        categoryId: fd.get('category_id'),
        authorId: profile.id,
        title: fd.get('title').trim(),
        body: fd.get('body').trim(),
      });
      window.selectedForumThreadId = thread.id;
      window.forumReturnPanel = 'forum';
      navigateToPanel('forum-topico');
    } catch (err) {
      console.error('[ForumNovoTopico] erro ao criar tópico:', err);
      resultEl.innerHTML = `<p class="learning-error">${err.message || 'Não foi possível criar o tópico agora.'}</p>`;
      submitBtn.disabled = false;
      submitBtn.textContent = 'Criar Tópico';
    }
  });
}
