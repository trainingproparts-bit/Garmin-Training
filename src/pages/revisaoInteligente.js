// src/pages/revisaoInteligente.js
// Tela inicial da Revisão Inteligente — escolha de modo (Rápida/Completa/
// Surpresa/Erros/Por Produto). O algoritmo de seleção roda 100% no backend
// (fn_start_review_session, sql/067); esta tela só coleta a escolha do
// usuário e navega pro painel de sessão (revisao-session).

import { navigateToPanel } from '../router.js';
import { fetchReviewStats, fetchProductsForPicker, startReviewSession } from '../services/revisaoService.js';

const MODES = [
  { key: 'rapida', icon: '⚡', label: 'Revisão Rápida', sub: '≈5 minutos · 8 conteúdos' },
  { key: 'completa', icon: '📚', label: 'Revisão Completa', sub: '≈15 minutos · 20 conteúdos' },
  { key: 'surpresa', icon: '🎲', label: 'Revisão Surpresa', sub: 'Conteúdo totalmente aleatório' },
  { key: 'erros', icon: '🔁', label: 'Revisão dos Erros', sub: 'Só o que você errou ou ainda não domina' },
  { key: 'produto', icon: '🔎', label: 'Revisão por Produto', sub: 'Escolha um produto, o resto é automático' },
];

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'revisao-inteligente') initRevisaoInteligentePage();
});

async function initRevisaoInteligentePage() {
  const container = document.getElementById('revisaoInteligenteContainer');
  if (!container) return;

  const brandId = window.selectedBrandId;
  if (!brandId) {
    container.innerHTML = '<p class="learning-error">Escolha uma marca na tela Início primeiro.</p>';
    return;
  }

  container.innerHTML = '<p class="learning-loading">Carregando…</p>';

  try {
    const [stats, products] = await Promise.all([fetchReviewStats(), fetchProductsForPicker(brandId)]);
    renderModePicker(container, stats, products);
  } catch (err) {
    console.error('[RevisaoInteligente] erro ao carregar:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar agora.</p>';
  }
}

function renderModePicker(container, stats, products) {
  container.innerHTML = `
    <p class="revisao-picker-intro">
      ${stats.available_count} conteúdo${stats.available_count === 1 ? '' : 's'} disponíve${stats.available_count === 1 ? 'l' : 'is'} pra revisar. Escolha como quer revisar hoje:
    </p>
    <div class="revisao-mode-grid">
      ${MODES.map((m) => `
        <button type="button" class="revisao-mode-card" data-mode="${m.key}">
          <span class="revisao-mode-icon">${m.icon}</span>
          <span class="revisao-mode-label">${m.label}</span>
          <span class="revisao-mode-sub">${m.sub}</span>
        </button>
      `).join('')}
    </div>
    <div class="revisao-product-picker" data-role="product-picker" hidden>
      <p class="revisao-product-picker-label">Qual produto?</p>
      <div class="revisao-product-picker-list">
        ${products.map((p) => `<button type="button" class="revisao-product-pill" data-product-id="${p.id}">${p.name}</button>`).join('')}
      </div>
    </div>
  `;

  const productPicker = container.querySelector('[data-role="product-picker"]');

  container.querySelectorAll('[data-mode]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const mode = btn.dataset.mode;

      if (mode === 'produto') {
        productPicker.hidden = !productPicker.hidden;
        return;
      }

      await launchSession(container, mode, null);
    });
  });

  productPicker.querySelectorAll('[data-product-id]').forEach((pill) => {
    pill.addEventListener('click', () => launchSession(container, 'produto', pill.dataset.productId));
  });
}

async function launchSession(container, mode, productId) {
  container.innerHTML = '<p class="learning-loading">Montando sua revisão…</p>';
  try {
    const sessionId = await startReviewSession(mode, productId);
    window.selectedReviewSessionId = sessionId;
    navigateToPanel('revisao-session');
  } catch (err) {
    console.error('[RevisaoInteligente] erro ao iniciar sessão:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível montar a revisão agora.</p>';
  }
}
