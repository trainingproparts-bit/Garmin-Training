// src/components/ProdutoQuickView.js
// Popup rápido de produto (pedido do usuário, 2026-09-15): clicar no nome de
// um modelo em qualquer tela da Biblioteca Técnica (Perfis de Cliente,
// Produtos) abre um resumo em popup em vez de sair da página — mesmo
// espírito de "ficha de consulta rápida" do resto da tela. Busca os dados
// reais na Academia de Produtos (academiaService.js, domínio separado do
// catálogo simples da Biblioteca) e reaproveita renderBlocks/
// wireBlockInteractions (ContentBlocks.js) pra mostrar a seção "Visão Geral"
// com fidelidade — sem duplicar a renderização rica que já existe em
// produtoDetail.js. Um botão leva pra página completa (comparativos, scripts
// de venda, quiz) pra quem quiser se aprofundar.

import { fetchProductBySlug } from '../services/academiaService.js';
import { renderBlocks, wireBlockInteractions } from './ContentBlocks.js';
import { navigateToPanel, getActivePanelId } from '../router.js';

export async function openProdutoQuickView(brandId, slug) {
  const root = document.createElement('div');
  root.className = 'iuf-modal-backdrop';
  root.innerHTML = `
    <div class="qv-modal">
      <button type="button" class="qv-close" data-role="qv-close" aria-label="Fechar">✕</button>
      <div data-role="qv-body"><p class="learning-loading">Carregando produto…</p></div>
    </div>`;
  document.body.appendChild(root);

  const close = () => root.remove();
  root.addEventListener('click', (e) => { if (e.target === root) close(); });
  root.querySelector('[data-role="qv-close"]').addEventListener('click', close);

  const bodyEl = root.querySelector('[data-role="qv-body"]');

  try {
    const product = await fetchProductBySlug(brandId, slug);
    const overview = product.sections.get('visao_geral');
    const blocks = overview?.blocks || [];
    const categoryName = product.product_categories?.name || (Array.isArray(product.product_categories) ? product.product_categories[0]?.name : '') || '';

    bodyEl.innerHTML = `
      ${product.cover_url ? `<div class="qv-cover" style="background-image:url('${product.cover_url}')"></div>` : ''}
      <div class="qv-content">
        ${categoryName ? `<span class="qv-eyebrow">${categoryName}</span>` : ''}
        <h3 class="qv-name">${product.name}</h3>
        ${product.tagline ? `<p class="qv-tagline">${product.tagline}</p>` : ''}
        ${blocks.length ? `<div class="qv-blocks">${renderBlocks(blocks)}</div>` : '<p class="learning-empty">Sem visão geral cadastrada ainda.</p>'}
        <button type="button" class="qv-cta" data-role="qv-open-full">Ver detalhes do produto completo →</button>
      </div>`;

    wireBlockInteractions(bodyEl);
    bodyEl.querySelector('[data-role="qv-open-full"]').addEventListener('click', () => {
      close();
      window.selectedProductSlug = slug;
      window.academiaReturnPanel = getActivePanelId() || 'biblioteca';
      navigateToPanel('academia-produto-detail');
    });
  } catch (err) {
    console.error('[ProdutoQuickView] erro ao carregar produto:', err);
    bodyEl.innerHTML = '<p class="learning-error">Não foi possível carregar este produto agora.</p>';
  }
}
