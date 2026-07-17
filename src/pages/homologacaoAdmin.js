// src/pages/homologacaoAdmin.js
// Homologação Semanal de Treinamento (sql/048) — painel do Admin: escolhe a
// loja, marca conteúdo avulso (módulo/quiz/post/game, de qualquer formato)
// que "vale" naquela semana, e dispara o ciclo. O líder da loja confirma
// depois (ver renderHomologacaoWidget em liderDashboard.js).

import { getCurrentProfile, isAdminProfile } from '../config/supabase.js';
import { fetchStores } from '../services/adminService.js';
import { fetchAllModulesAdmin, fetchAllQuizzesAdmin } from '../services/contentAdminService.js';
import { fetchAllPostsForAdmin } from '../services/blogService.js';
import { fetchPublishedGames } from '../services/gameService.js';
import {
  fetchCiclosPorLoja,
  criarCicloComConteudos,
  encerrarCiclo,
} from '../services/homologacaoService.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'homologacao') initHomologacaoAdminPage();
});

async function initHomologacaoAdminPage() {
  const container = document.getElementById('homologacaoContainer');
  if (!container) return;

  container.innerHTML = '<p class="learning-loading">Carregando…</p>';

  try {
    const profile = await getCurrentProfile();
    if (!profile || !isAdminProfile(profile)) {
      container.innerHTML = '<p class="learning-error">Esta área é restrita a administradores.</p>';
      return;
    }

    const stores = await fetchStores();
    renderPicker(container, stores);
  } catch (err) {
    console.error('[HomologacaoAdmin] erro ao carregar:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar agora.</p>';
  }
}

function renderPicker(container, stores) {
  container.innerHTML = `
    <div class="admin-create-card">
      <h3 class="dash-section-label">Homologação Semanal, Selecionar Loja</h3>
      <p class="dash-empty-text" style="margin-top:0;">Escolha a loja pra montar o ciclo desta semana com conteúdo avulso (módulo, quiz, post do blog e/ou game).</p>
      <select id="homStoreSelect" class="login-input" style="max-width:320px;">
        <option value="">Selecione a loja...</option>
        ${stores.map((s) => `<option value="${s.id}" data-brand-id="${s.brand_id}">${s.name} (${s.brands?.name || '—'})</option>`).join('')}
      </select>
    </div>
    <div id="homContent" style="margin-top:20px;"></div>
  `;

  container.querySelector('#homStoreSelect').addEventListener('change', async (e) => {
    const opt = e.target.selectedOptions[0];
    const contentEl = container.querySelector('#homContent');
    if (!opt.value) {
      contentEl.innerHTML = '';
      return;
    }
    await loadStoreContent(contentEl, opt.value, opt.dataset.brandId);
  });
}

async function loadStoreContent(contentEl, storeId, brandId) {
  contentEl.innerHTML = '<p class="learning-loading">Carregando conteúdo da marca…</p>';

  try {
    const [modules, quizzes, posts, games, ciclos] = await Promise.all([
      fetchAllModulesAdmin(),
      fetchAllQuizzesAdmin(),
      fetchAllPostsForAdmin(),
      fetchPublishedGames(brandId),
      fetchCiclosPorLoja(storeId),
    ]);

    const modulosDaMarca = modules.filter((m) => m.is_published && m.zones?.trails?.brand_id === brandId);
    const quizzesDaMarca = quizzes.filter((q) => q.is_published && q.brand_id === brandId);
    const postsPublicados = posts.filter((p) => p.is_published);

    renderContentPicker(contentEl, storeId, { modulosDaMarca, quizzesDaMarca, postsPublicados, games, ciclos });
  } catch (err) {
    console.error('[HomologacaoAdmin] erro ao carregar conteúdo da loja:', err);
    contentEl.innerHTML = '<p class="learning-error">Não foi possível carregar o conteúdo agora.</p>';
  }
}

function checklistSectionHtml(title, items, tipo) {
  if (!items.length) return `<div class="hom-picker-section"><h4>${title}</h4><p class="dash-empty-text" style="margin:0;">Nenhum item publicado.</p></div>`;
  return `
    <div class="hom-picker-section">
      <h4>${title}</h4>
      <div class="hom-picker-list">
        ${items.map((it) => `
          <label class="hom-picker-item">
            <input type="checkbox" data-tipo="${tipo}" data-id="${it.id}">
            <span>${it.title}</span>
          </label>`).join('')}
      </div>
    </div>`;
}

function renderContentPicker(contentEl, storeId, { modulosDaMarca, quizzesDaMarca, postsPublicados, games, ciclos }) {
  const hoje = new Date().toISOString().slice(0, 10);
  const daquiUmaSemana = new Date(Date.now() + 7 * 86400000).toISOString().slice(0, 10);

  contentEl.innerHTML = `
    <div class="admin-create-card">
      <h3 class="dash-section-label">Selecionar Conteúdo da Semana</h3>
      <div style="display:flex; gap:12px; margin-bottom:16px; flex-wrap:wrap;">
        <label class="dash-mini-tag">Início <input type="date" id="homDataInicio" class="login-input" value="${hoje}"></label>
        <label class="dash-mini-tag">Fim <input type="date" id="homDataFim" class="login-input" value="${daquiUmaSemana}"></label>
      </div>
      <div class="hom-picker-grid">
        ${checklistSectionHtml('📘 Módulos', modulosDaMarca, 'modulo')}
        ${checklistSectionHtml('📋 Quizzes', quizzesDaMarca, 'quiz')}
        ${checklistSectionHtml('📰 Posts do Blog', postsPublicados, 'blog')}
        ${checklistSectionHtml('🎮 Games', games, 'game')}
      </div>
      <button type="button" class="login-btn admin-create-submit" id="homDispararBtn" style="margin-top:16px;">Disparar Ciclo Semanal</button>
      <div id="homDispararResult"></div>
    </div>
    <div id="homCiclosExistentes" style="margin-top:20px;">${renderCiclosList(ciclos)}</div>
  `;

  contentEl.querySelector('#homDispararBtn').addEventListener('click', async () => {
    const btn = contentEl.querySelector('#homDispararBtn');
    const resultEl = contentEl.querySelector('#homDispararResult');
    const itens = [...contentEl.querySelectorAll('input[type="checkbox"]:checked')].map((cb) => ({
      tipo: cb.dataset.tipo,
      id: cb.dataset.id,
    }));

    if (!itens.length) {
      resultEl.innerHTML = '<p class="learning-error">Selecione ao menos um item.</p>';
      return;
    }

    btn.disabled = true;
    btn.textContent = 'Disparando…';
    resultEl.innerHTML = '';

    try {
      await criarCicloComConteudos({
        storeId,
        dataInicio: contentEl.querySelector('#homDataInicio').value,
        dataFim: contentEl.querySelector('#homDataFim').value,
        itens,
      });
      resultEl.innerHTML = '<p class="admin-create-success">✓ Ciclo semanal disparado, o líder já pode ver e assinar.</p>';
      const ciclosAtualizados = await fetchCiclosPorLoja(storeId);
      contentEl.querySelector('#homCiclosExistentes').innerHTML = renderCiclosList(ciclosAtualizados);
      wireCiclosList(contentEl);
    } catch (err) {
      console.error('[HomologacaoAdmin] erro ao disparar ciclo:', err);
      resultEl.innerHTML = `<p class="learning-error">${err.message || 'Não foi possível disparar o ciclo agora.'}</p>`;
    } finally {
      btn.disabled = false;
      btn.textContent = 'Disparar Ciclo Semanal';
    }
  });

  wireCiclosList(contentEl);
}

function renderCiclosList(ciclos) {
  if (!ciclos.length) return '';
  return `
    <h3 class="dash-section-label">Ciclos desta loja</h3>
    <div class="lib-table-wrap">
      <table class="lib-table">
        <thead><tr><th>Período</th><th>Status</th><th></th></tr></thead>
        <tbody>
          ${ciclos.map((c) => `
            <tr data-ciclo-id="${c.id}">
              <td class="lib-prod-para">${new Date(c.data_inicio).toLocaleDateString('pt-BR')} a ${new Date(c.data_fim).toLocaleDateString('pt-BR')}</td>
              <td>${c.status === 'ativo' ? '<span class="tag green">Ativo</span>' : '<span class="tag">Encerrado</span>'}</td>
              <td>${c.status === 'ativo' ? '<button type="button" class="cb-editor-btn" data-role="hom-encerrar">Encerrar</button>' : ''}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>`;
}

function wireCiclosList(contentEl) {
  contentEl.querySelectorAll('[data-role="hom-encerrar"]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const cicloId = btn.closest('[data-ciclo-id]').dataset.cicloId;
      btn.disabled = true;
      try {
        await encerrarCiclo(cicloId);
        btn.closest('tr').querySelector('td:nth-child(2)').innerHTML = '<span class="tag">Encerrado</span>';
        btn.remove();
      } catch (err) {
        console.error('[HomologacaoAdmin] erro ao encerrar ciclo:', err);
        alert('Não foi possível encerrar agora.');
        btn.disabled = false;
      }
    });
  });
}
