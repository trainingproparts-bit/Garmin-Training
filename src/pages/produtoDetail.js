// src/pages/produtoDetail.js
// Página de conhecimento de um produto na Academia — navegação lateral fixa
// entre seções (estilo documentação premium: Apple Developer/Stripe/Linear/
// Notion, pedido explícito do usuário), pensada pra consulta rápida durante
// atendimento, não leitura linear. Reaproveita renderBlocks/wireBlockInteractions
// (ContentBlocks.js) pras 7 seções de conteúdo rico — Comparativos, Downloads
// e Quiz Especialista têm renderização própria (vêm de tabelas próprias, não
// de product_sections).

import { navigateToPanel, getActivePanelId } from '../router.js';
import { fetchProductBySlug } from '../services/academiaService.js';
import { renderBlocks, wireBlockInteractions } from '../components/ContentBlocks.js';

const NAV_SECTIONS = [
  { key: 'visao_geral', label: 'Visão Geral', icon: '📋' },
  { key: 'personas', label: 'Personas', icon: '🧑‍🤝‍🧑' },
  { key: 'diferenciais', label: 'Diferenciais', icon: '⭐' },
  { key: 'comparativos', label: 'Comparativos', icon: '⚖️' },
  { key: 'scripts_venda', label: 'Scripts de Venda', icon: '🗣️' },
  { key: 'objecoes', label: 'Objeções', icon: '🛡️' },
  { key: 'casos_uso', label: 'Casos de Uso', icon: '💼' },
  { key: 'faq', label: 'FAQ', icon: '❓' },
  { key: 'downloads', label: 'Downloads', icon: '📥' },
  { key: 'quiz', label: 'Quiz Especialista', icon: '🏆' },
  { key: 'relacionados', label: 'Relacionados', icon: '🔗' },
];

const MATERIAL_ICON = { pdf: '📄', image: '🖼️', folder: '🗂️', video: '🎬' };

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'academia-produto-detail') initProdutoDetailPage();
});

async function initProdutoDetailPage() {
  const container = document.getElementById('academiaProdutoDetailContainer');
  const titleEl = document.getElementById('academiaProdutoDetailTitle');
  if (!container) return;

  // Não apaga window.selectedProductSlug depois de ler (diferente do padrão
  // usado em deepDiveDetail.js/moduloConteudo.js) — este painel é reativado
  // sem um slug novo quando o usuário volta de um comparativo (ver
  // academiaReturnPanel em router.js), e nesse caso precisa continuar
  // mostrando o MESMO produto, não "esquecer" qual estava aberto.
  const slug = window.selectedProductSlug;

  if (!slug) {
    container.innerHTML = '<p class="content-error">Nenhum produto selecionado.</p>';
    return;
  }

  const brandId = window.selectedBrandId;
  if (!brandId) {
    container.innerHTML = '<p class="content-error">Escolha uma marca na tela Início primeiro.</p>';
    return;
  }

  container.innerHTML = '<p class="home-loading">Carregando produto…</p>';

  try {
    const product = await fetchProductBySlug(brandId, slug);
    if (titleEl) titleEl.textContent = product.name;
    renderProdutoDetail(container, product);
  } catch (err) {
    console.error('[ProdutoDetail] erro ao carregar produto:', err);
    container.innerHTML = '<p class="content-error">Não foi possível carregar este produto agora.</p>';
  }
}

function renderProdutoDetail(container, product) {
  const price = product.price_usd != null ? `US$ ${Number(product.price_usd).toFixed(2).replace('.', ',')}` : '';

  container.innerHTML = `
    <div class="academia-detail-breadcrumb">
      <span data-role="breadcrumb-category">${product.product_categories?.name || 'Academia de Produtos'}</span>
      <span class="academia-detail-breadcrumb-sep">/</span>
      <span>${product.name}</span>
    </div>

    <div class="academia-detail-header">
      <h2 class="academia-detail-name">${product.name}${product.model_code ? ` <span class="academia-detail-model">${product.model_code}</span>` : ''}</h2>
      ${product.tagline ? `<p class="academia-detail-tagline">${product.tagline}</p>` : ''}
      ${price ? `<span class="academia-detail-price">${price}</span>` : ''}
    </div>

    <div class="academia-detail-layout">
      <nav class="academia-detail-nav" data-role="academia-nav">
        ${NAV_SECTIONS.map((s, i) => `
          <button type="button" class="academia-nav-item ${i === 0 ? 'active' : ''}" data-section="${s.key}">
            <span class="academia-nav-item-icon">${s.icon}</span>${s.label}
          </button>
        `).join('')}
      </nav>
      <div class="academia-detail-content" data-role="academia-content">
        ${NAV_SECTIONS.map((s, i) => `
          <div class="academia-section-panel" data-section-panel="${s.key}" ${i === 0 ? '' : 'hidden'}>
            ${renderSectionContent(s.key, product)}
          </div>
        `).join('')}
      </div>
    </div>`;

  wireBlockInteractions(container, { returnPanel: 'academia-produto-detail' });
  wireSectionNav(container);
  wireComparisonLinks(container);
  wireQuizCard(container);
  wireRelatedLinks(container);
}

function renderSectionContent(sectionKey, product) {
  if (sectionKey === 'comparativos') return renderComparativos(product.comparisons, product.slug);
  if (sectionKey === 'downloads') return renderDownloads(product.materials);
  if (sectionKey === 'quiz') return renderQuiz(product.quizzes);
  if (sectionKey === 'relacionados') return renderRelacionados(product.relationships);

  const payload = product.sections.get(sectionKey);
  return renderBlocks(payload?.blocks);
}

function renderComparativos(comparisons, currentSlug) {
  if (!comparisons?.length) return '<p class="learning-empty">Nenhum comparativo publicado envolvendo este produto ainda.</p>';
  return `
    <div class="academia-comparison-list">
      ${comparisons.map((c) => {
        const other = c.product_a?.slug === currentSlug ? c.product_b : c.product_a;
        return `
          <button type="button" class="academia-comparison-card" data-comparison-slug="${c.slug}">
            <span class="academia-comparison-card-icon">⚖️</span>
            <div>
              <div class="academia-comparison-card-title">${c.title}</div>
              ${other ? `<div class="academia-comparison-card-sub">Comparar com ${other.name}</div>` : ''}
            </div>
          </button>`;
      }).join('')}
    </div>`;
}

function renderDownloads(materials) {
  if (!materials?.length) return '<p class="learning-empty">Nenhum material de download cadastrado ainda.</p>';
  return `
    <div class="academia-materials-list">
      ${materials.map((m) => `
        <a class="academia-material-item" href="${m.url}" target="_blank" rel="noopener noreferrer">
          <span class="academia-material-icon">${MATERIAL_ICON[m.type] || '📎'}</span>
          <span class="academia-material-title">${m.title}</span>
          <span class="academia-material-arrow">↗</span>
        </a>
      `).join('')}
    </div>`;
}

function renderQuiz(quizzes) {
  if (!quizzes?.length) return '<p class="learning-empty">Nenhum Quiz Especialista cadastrado ainda.</p>';
  return `
    <div class="academia-quiz-card">
      ${quizzes.map((q) => `
        <button type="button" class="academia-quiz-btn" data-quiz-id="${q.id}">
          <span class="academia-quiz-icon">🏆</span>
          <div>
            <div class="academia-quiz-title">${q.title}</div>
            <div class="academia-quiz-sub">Aprovação: ${q.passing_score_pct}% · Concluir concede XP e badge de especialista</div>
          </div>
        </button>
      `).join('')}
    </div>`;
}

function renderRelacionados(relationships) {
  if (!relationships?.length) return '<p class="learning-empty">Nenhum relacionado cadastrado ainda.</p>';
  return `
    <div class="academia-related-list">
      ${relationships.map((r) => (
        r.slug
          ? `<button type="button" class="academia-related-pill academia-related-pill-link" data-related-slug="${r.slug}">${r.label}</button>`
          : `<span class="academia-related-pill">${r.label}</span>`
      )).join('')}
    </div>`;
}

function wireSectionNav(container) {
  const nav = container.querySelector('[data-role="academia-nav"]');
  nav.querySelectorAll('[data-section]').forEach((btn) => {
    btn.addEventListener('click', () => {
      nav.querySelectorAll('[data-section]').forEach((b) => b.classList.toggle('active', b === btn));
      container.querySelectorAll('[data-section-panel]').forEach((panel) => {
        panel.hidden = panel.dataset.sectionPanel !== btn.dataset.section;
      });
    });
  });
}

function wireComparisonLinks(container) {
  container.querySelectorAll('[data-comparison-slug]').forEach((btn) => {
    btn.addEventListener('click', () => {
      window.selectedComparisonSlug = btn.dataset.comparisonSlug;
      window.academiaReturnPanel = getActivePanelId() || 'academia-produtos';
      navigateToPanel('academia-comparativo');
    });
  });
}

function wireQuizCard(container) {
  container.querySelectorAll('[data-quiz-id]').forEach((btn) => {
    btn.addEventListener('click', () => {
      window.selectedQuizId = btn.dataset.quizId;
      window.quizRunnerReturnPanel = 'academia-produto-detail';
      navigateToPanel('quiz-runner');
    });
  });
}

function wireRelatedLinks(container) {
  container.querySelectorAll('[data-related-slug]').forEach((btn) => {
    btn.addEventListener('click', () => {
      window.selectedProductSlug = btn.dataset.relatedSlug;
      window.academiaReturnPanel = getActivePanelId() || 'academia-produtos';
      navigateToPanel('academia-produto-detail');
    });
  });
}
