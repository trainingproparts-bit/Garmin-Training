// src/pages/academiaProdutos.js
// Tela inicial da Academia de Produtos — redesenhada em 2026-09-15 (pedido do
// usuário: "não deve parecer loja virtual", e sim uma ferramenta de estudo de
// portfólio) a partir da mesma base de dados de sempre (fetchCategories/
// fetchProductsByCategory, sql/064) — nenhuma tabela nova, nenhum produto
// inventado. Três coisas novas, só de apresentação:
//   1. Cabeçalho + nav de categorias (scroll até a seção) + busca + filtro
//      rápido por nível, tudo client-side (poucas dezenas de produtos, não
//      justifica ida ao servidor a cada tecla).
//   2. Dentro de cada categoria, produtos agrupados por nível (Entrada/
//      Avançado/Premium) quando esse nível está claramente indicado na
//      própria tagline já cadastrada (ver inferTier) — sem nível óbvio no
//      texto existente, o produto aparece direto na grade, sem etiqueta
//      inventada.
//   3. Card padronizado (imagem/etiqueta/nome/descrição curta) com o mesmo
//      clique de sempre pro detalhe do produto (window.selectedProductSlug +
//      navigateToPanel) — nada na navegação/estado global muda.

import { navigateToPanel, getActivePanelId } from '../router.js';
import { fetchCategories, fetchProductsByCategory } from '../services/academiaService.js';
import { icon } from '../components/icons.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'academia-produtos') initAcademiaProdutosPage();
});

const TIER_LABELS = { entrada: 'Entrada', avancado: 'Avançado', premium: 'Premium' };
const TIER_ORDER = ['entrada', 'avancado', 'premium'];

/**
 * Nível de portfólio (Entrada/Avançado/Premium) inferido da PRÓPRIA tagline
 * já cadastrada — a maioria dos produtos já descreve isso em palavras
 * ("...de entrada", "básico", "avançado", "premium", "topo de linha").
 * Sem nenhuma dessas palavras no texto existente, o produto fica sem nível
 * (renderiza normal, só não agrupado) — não inventamos posicionamento que
 * não esteja no dado real.
 *
 * Único caso com override: Forerunner 165 ("modelo anterior ao 170", sem
 * palavra de nível) — o usuário pediu explicitamente que ficasse junto do
 * 55/70 como "Entrada" da linha, mesma posição real de mercado.
 */
const TIER_OVERRIDE = { 'forerunner-165': 'entrada' };

function inferTier(product) {
  if (TIER_OVERRIDE[product.slug]) return TIER_OVERRIDE[product.slug];
  const t = product.tagline || '';
  if (/\b(entrada|básico|acessível)\b/i.test(t)) return 'entrada';
  if (/\bpremium\b|topo de linha/i.test(t)) return 'premium';
  if (/avançad[oa]s?/i.test(t)) return 'avancado';
  return null;
}

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
    const categoriesWithProducts = categories
      .map((cat, i) => ({ ...cat, products: productsByCategory[i] }))
      .filter((cat) => cat.products.length);

    if (!categoriesWithProducts.length) {
      container.innerHTML = '<p class="learning-empty">Nenhum produto publicado na Academia ainda.</p>';
      return;
    }

    container.innerHTML = renderHub(categoriesWithProducts);
    wireHub(container);
  } catch (err) {
    console.error('[AcademiaProdutos] erro ao carregar:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar a Academia de Produtos agora.</p>';
  }
}

function renderHub(categories) {
  return `
    <div class="academia-hub">
      <header class="academia-hub-header">
        <h1 class="academia-hub-title">Portfólio Garmin</h1>
        <p class="academia-hub-subtitle">Conheça as principais linhas e entenda onde cada produto se encaixa.</p>
      </header>

      <nav class="academia-hub-catnav" aria-label="Ir para categoria">
        ${categories.map((c) => `<button type="button" class="academia-hub-catnav-item" data-cat-anchor="academia-cat-${c.slug}">${c.name}</button>`).join('')}
      </nav>

      <div class="academia-hub-toolbar">
        <label class="academia-hub-search">
          <span class="academia-hub-search-icon">${icon('search')}</span>
          <input type="text" data-role="hub-search" placeholder="Buscar produto..." aria-label="Buscar produto">
        </label>
        <div class="academia-hub-tier-filter" role="group" aria-label="Filtrar por nível">
          <button type="button" class="academia-hub-tier-btn is-active" data-tier-filter="todos" aria-pressed="true">Todos</button>
          ${TIER_ORDER.map((k) => `<button type="button" class="academia-hub-tier-btn" data-tier-filter="${k}" aria-pressed="false">${TIER_LABELS[k]}</button>`).join('')}
        </div>
      </div>

      <div class="academia-hub-sections">
        ${categories.map(renderCategorySection).join('')}
      </div>

      <p class="academia-hub-empty" data-role="hub-empty" hidden>Nenhum produto encontrado com esses filtros.</p>
    </div>`;
}

function renderCategorySection(category) {
  const withTier = category.products.map((p) => ({ ...p, tier: inferTier(p) }));
  const hasAnyTier = withTier.some((p) => p.tier);

  const tieredGroupsHtml = hasAnyTier
    ? TIER_ORDER
        .map((key) => ({ key, items: withTier.filter((p) => p.tier === key) }))
        .filter((g) => g.items.length)
        .map((g) => `
          <div class="academia-hub-tier-group" data-tier-group="${g.key}">
            <span class="academia-hub-tier-heading">${TIER_LABELS[g.key]}</span>
            <div class="academia-hub-grid">${g.items.map(renderProductCard).join('')}</div>
          </div>`)
        .join('')
    : '';

  const untiered = withTier.filter((p) => !p.tier);
  const untieredHtml = untiered.length
    ? `<div class="academia-hub-tier-group" data-tier-group="">
        <div class="academia-hub-grid">${untiered.map(renderProductCard).join('')}</div>
      </div>`
    : '';

  return `
    <section class="academia-hub-category" id="academia-cat-${category.slug}" data-category-section>
      <h2 class="academia-hub-category-title">${category.name}</h2>
      ${tieredGroupsHtml}
      ${untieredHtml}
    </section>`;
}

function renderProductCard(product) {
  const tierLabel = product.tier ? TIER_LABELS[product.tier] : '';
  const searchIndex = `${product.name} ${product.tagline || ''}`.toLowerCase();
  return `
    <article
      class="academia-hub-card"
      data-product-slug="${product.slug}"
      data-tier="${product.tier || ''}"
      data-search="${searchIndex}"
      tabindex="0"
      role="button"
      aria-label="Ver detalhes de ${product.name}"
    >
      <div class="academia-hub-card-media">
        ${product.cover_url
          ? `<img src="${product.cover_url}" alt="${product.name}" loading="lazy">`
          : `<span class="academia-hub-card-media-fallback">${icon('watch')}</span>`}
      </div>
      <div class="academia-hub-card-body">
        ${tierLabel ? `<span class="academia-hub-card-tier">${tierLabel}</span>` : ''}
        <h3 class="academia-hub-card-name">${product.name}</h3>
        ${product.tagline ? `<p class="academia-hub-card-desc">${product.tagline}</p>` : ''}
      </div>
    </article>`;
}

function wireHub(container) {
  const cards = [...container.querySelectorAll('[data-product-slug]')];
  const groups = [...container.querySelectorAll('[data-tier-group]')];
  const sections = [...container.querySelectorAll('[data-category-section]')];
  const emptyState = container.querySelector('[data-role="hub-empty"]');
  const searchInput = container.querySelector('[data-role="hub-search"]');
  const tierBtns = [...container.querySelectorAll('[data-tier-filter]')];

  let activeTier = 'todos';

  function applyFilters() {
    const term = searchInput.value.trim().toLowerCase();

    cards.forEach((card) => {
      const matchesTerm = !term || card.dataset.search.includes(term);
      const matchesTier = activeTier === 'todos' || card.dataset.tier === activeTier;
      card.hidden = !(matchesTerm && matchesTier);
    });

    groups.forEach((group) => {
      group.hidden = ![...group.querySelectorAll('[data-product-slug]')].some((c) => !c.hidden);
    });

    let anyVisible = false;
    sections.forEach((section) => {
      const visible = [...section.querySelectorAll('[data-product-slug]')].some((c) => !c.hidden);
      section.hidden = !visible;
      if (visible) anyVisible = true;
    });

    emptyState.hidden = anyVisible;
  }

  searchInput.addEventListener('input', applyFilters);

  tierBtns.forEach((btn) => {
    btn.addEventListener('click', () => {
      activeTier = btn.dataset.tierFilter;
      tierBtns.forEach((b) => {
        b.classList.toggle('is-active', b === btn);
        b.setAttribute('aria-pressed', b === btn ? 'true' : 'false');
      });
      applyFilters();
    });
  });

  container.querySelectorAll('[data-cat-anchor]').forEach((btn) => {
    btn.addEventListener('click', () => {
      document.getElementById(btn.dataset.catAnchor)?.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });

  function openProduct(slug) {
    window.selectedProductSlug = slug;
    window.academiaReturnPanel = getActivePanelId() || 'academia-produtos';
    navigateToPanel('academia-produto-detail');
  }

  cards.forEach((card) => {
    card.addEventListener('click', () => openProduct(card.dataset.productSlug));
    card.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        openProduct(card.dataset.productSlug);
      }
    });
  });
}
