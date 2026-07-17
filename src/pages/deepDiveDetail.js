// src/pages/deepDiveDetail.js
// Página dedicada de um guia técnico (content_library, categoria deep_dive).
// Antes, os 8 guias viviam como itens de accordion dentro da própria
// Biblioteca Técnica — uma lista comprida de textão. Isso obrigava um scroll
// infinito e não tinha nenhuma navegação interna, diferente do protótipo
// original (index_redesign_v5.html), que dava a cada guia seu próprio painel
// e, pros 3 guias mais densos (inReach, Edge, Apps/Integrações), um seletor
// de abas (.itabs) pra não empilhar tudo numa rolagem só. Este painel
// reproduz os dois: navegação dedicada (mesmo padrão de modulo-conteudo.js,
// com back button) e abas quando `payload.tabs` existe.

import { CATEGORIES, fetchContentBySlug } from '../services/contentLibraryService.js';
import { renderBlocks, wireBlockInteractions } from '../components/ContentBlocks.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'deep-dive-detail') initDeepDiveDetailPage();
});

async function initDeepDiveDetailPage() {
  const container = document.getElementById('deepDiveDetailContainer');
  const titleEl = document.getElementById('deepDiveDetailTitle');
  if (!container) return;

  const slug = window.selectedDeepDiveSlug;
  delete window.selectedDeepDiveSlug;

  if (!slug) {
    container.innerHTML = '<p class="content-error">Nenhum guia técnico selecionado.</p>';
    return;
  }

  const brandId = window.selectedBrandId;
  if (!brandId) {
    container.innerHTML = '<p class="content-error">Escolha uma marca na tela Início primeiro.</p>';
    return;
  }

  container.innerHTML = '<p class="home-loading">Carregando conteúdo...</p>';

  try {
    const item = await fetchContentBySlug(brandId, CATEGORIES.DEEP_DIVE, slug);
    if (!item) {
      container.innerHTML = '<p class="content-error">Este guia técnico não foi encontrado.</p>';
      return;
    }

    if (titleEl) titleEl.textContent = item.title || 'Guia Técnico';
    renderDeepDiveDetail(container, item);
  } catch (err) {
    console.error('[DeepDiveDetail] erro ao buscar guia técnico:', err);
    container.innerHTML = '<p class="content-error">Erro ao carregar este guia técnico.</p>';
  }
}

function renderDeepDiveDetail(container, item) {
  const payload = item.payload || {};

  if (Array.isArray(payload.tabs) && payload.tabs.length) {
    renderTabbedDetail(container, item, payload);
    return;
  }

  container.innerHTML = `
    <div class="deep-dive-article">
      ${item.summary ? `<p class="deep-dive-summary">${item.summary}</p>` : ''}
      <div class="deep-dive-body">${renderBlocks(payload.blocks)}</div>
    </div>`;

  wireBlockInteractions(container, { returnPanel: 'deep-dive-detail' });
}

function renderTabbedDetail(container, item, payload) {
  container.innerHTML = `
    <div class="deep-dive-article">
      ${item.summary ? `<p class="deep-dive-summary">${item.summary}</p>` : ''}
      ${payload.intro ? `<div class="deep-dive-intro">${payload.intro}</div>` : ''}
      <div class="itabs" data-role="deepdive-itabs">
        ${payload.tabs.map((tab, i) => `
          <button type="button" class="itab ${i === 0 ? 'active' : ''}" data-tab-index="${i}">${tab.label}</button>
        `).join('')}
      </div>
      ${payload.tabs.map((tab, i) => `
        <div class="deep-dive-body" data-tab-panel="${i}" ${i === 0 ? '' : 'hidden'}>${renderBlocks(tab.blocks)}</div>
      `).join('')}
    </div>`;

  wireBlockInteractions(container, { returnPanel: 'deep-dive-detail' });

  const tabsEl = container.querySelector('[data-role="deepdive-itabs"]');
  tabsEl.querySelectorAll('[data-tab-index]').forEach((btn) => {
    btn.addEventListener('click', () => {
      const index = btn.dataset.tabIndex;
      tabsEl.querySelectorAll('[data-tab-index]').forEach((b) => b.classList.toggle('active', b === btn));
      container.querySelectorAll('[data-tab-panel]').forEach((panel) => {
        panel.hidden = panel.dataset.tabPanel !== index;
      });
    });
  });
}
