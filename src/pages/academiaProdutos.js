// src/pages/academiaProdutos.js
// Tela inicial da Academia de Produtos — segundo domínio da plataforma
// (independente das Trilhas, sql/064): categorias sempre abertas (mesmo
// princípio já adotado em Trilha Completa, 2026-07-20 — visão macro em vez de
// esconder atrás de accordion), cada uma com a grade de produtos publicados.

import { navigateToPanel, getActivePanelId } from '../router.js';
import { fetchCategories, fetchProductsByCategory } from '../services/academiaService.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'academia-produtos') initAcademiaProdutosPage();
});

async function initAcademiaProdutosPage() {
  const container = document.getElementById('academiaProdutosContainer');
  if (!container) return;

  const brandId = window.selectedBrandId;
  if (!brandId) {
    container.innerHTML = '<p class="learning-error">Escolha uma marca na tela Início primeiro.</p>';
    return;
  }

  container.innerHTML = '<p class="learning-loading">Carregando Academia de Produtos…</p>';

  try {
    const categories = await fetchCategories(brandId);
    if (!categories.length) {
      container.innerHTML = '<p class="learning-empty">Nenhum produto cadastrado na Academia ainda.</p>';
      return;
    }

    const productsByCategory = await Promise.all(categories.map((c) => fetchProductsByCategory(c.id)));

    container.innerHTML = categories.map((cat, i) => renderCategorySection(cat, productsByCategory[i])).join('');
    wireProductCards(container);
  } catch (err) {
    console.error('[AcademiaProdutos] erro ao carregar:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar a Academia de Produtos agora.</p>';
  }
}

function renderCategorySection(category, products) {
  return `
    <div class="academia-category-section">
      <h3 class="academia-category-title">
        <span class="academia-category-icon">${category.icon || '📦'}</span>
        ${category.name}
      </h3>
      ${products.length ? `
        <div class="academia-product-grid">
          ${products.map(renderProductCard).join('')}
        </div>
      ` : '<p class="learning-empty">Nenhum produto publicado nesta categoria ainda.</p>'}
    </div>`;
}

function renderProductCard(product) {
  const price = product.price_usd != null ? `US$ ${Number(product.price_usd).toFixed(2).replace('.', ',')}` : '';
  return `
    <div class="academia-product-card" data-product-slug="${product.slug}">
      <div class="academia-product-card-thumb" ${product.cover_url ? '' : 'style="background:linear-gradient(135deg, #1e293b, #0f172a);"'}>
        ${product.cover_url ? `<img src="${product.cover_url}" alt="">` : `<span class="academia-product-card-thumb-icon">⌚</span>`}
      </div>
      <div class="academia-product-card-body">
        <div class="academia-product-card-name">${product.name}</div>
        ${product.tagline ? `<div class="academia-product-card-tagline">${product.tagline}</div>` : ''}
        ${price ? `<div class="academia-product-card-price">${price}</div>` : ''}
      </div>
    </div>`;
}

function wireProductCards(container) {
  container.querySelectorAll('[data-product-slug]').forEach((card) => {
    card.addEventListener('click', () => {
      window.selectedProductSlug = card.dataset.productSlug;
      window.academiaReturnPanel = getActivePanelId() || 'academia-produtos';
      navigateToPanel('academia-produto-detail');
    });
  });
}
