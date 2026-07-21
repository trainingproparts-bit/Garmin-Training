// src/pages/produtoDetail.js
// Página de conhecimento de um produto na Academia — navegação lateral fixa
// entre seções (estilo documentação premium: Apple Developer/Stripe/Linear/
// Notion, pedido explícito do usuário), pensada pra consulta rápida durante
// atendimento, não leitura linear. Reaproveita renderBlocks/wireBlockInteractions
// (ContentBlocks.js) pras 7 seções de conteúdo rico — Comparativos, Downloads
// e Quiz Especialista têm renderização própria (vêm de tabelas próprias, não
// de product_sections).
//
// Edição (admin, 2026-07-20 — "preciso editar todo o conteúdo facilmente"):
// cada seção de bloco reaproveita setupBlockArrayEditor (mesmo editor já
// usado em lições/guias técnicos, ContentBlocks.js) sem nenhuma mudança nele.
// Cabeçalho/downloads/relacionados usam formulários simples próprios (não são
// blocos ricos, são campos estruturados).

import { navigateToPanel, getActivePanelId } from '../router.js';
import {
  fetchProductBySlug, updateProduct, updateProductSection,
  replaceMaterials, replaceRelationships, fetchAllProductsForBrand,
} from '../services/academiaService.js';
import { renderBlocks, wireBlockInteractions, setupBlockArrayEditor } from '../components/ContentBlocks.js';
import { getCurrentProfile, isAdminProfile } from '../config/supabase.js';

const NAV_SECTIONS = [
  { key: 'visao_geral', label: 'Visão Geral', icon: '📋' },
  { key: 'personas', label: 'Personas', icon: '🧑‍🤝‍🧑' },
  { key: 'diferenciais', label: 'Diferenciais', icon: '⭐' },
  { key: 'novidades', label: 'O que há de novo?', icon: '🆕' },
  { key: 'comparativos', label: 'Comparativos', icon: '⚖️' },
  { key: 'scripts_venda', label: 'Scripts de Venda', icon: '🗣️' },
  { key: 'objecoes', label: 'Objeções', icon: '🛡️' },
  { key: 'casos_uso', label: 'Casos de Uso', icon: '💼' },
  { key: 'faq', label: 'FAQ', icon: '❓' },
  { key: 'downloads', label: 'Downloads', icon: '📥' },
  { key: 'quiz', label: 'Quiz Especialista', icon: '🏆' },
  { key: 'relacionados', label: 'Relacionados', icon: '🔗' },
];

const BLOCK_SECTION_KEYS = new Set(['visao_geral', 'personas', 'diferenciais', 'novidades', 'scripts_venda', 'objecoes', 'casos_uso', 'faq']);
const MATERIAL_ICON = { pdf: '📄', image: '🖼️', folder: '🗂️', video: '🎬' };
const MATERIAL_TYPES = ['pdf', 'image', 'folder', 'video'];

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
    const [product, profile] = await Promise.all([fetchProductBySlug(brandId, slug), getCurrentProfile()]);
    const isAdmin = isAdminProfile(profile);
    if (titleEl) titleEl.textContent = product.name;
    renderProdutoDetail(container, product, isAdmin, brandId);
  } catch (err) {
    console.error('[ProdutoDetail] erro ao carregar produto:', err);
    container.innerHTML = '<p class="content-error">Não foi possível carregar este produto agora.</p>';
  }
}

function renderProdutoDetail(container, product, isAdmin, brandId) {
  container.innerHTML = `
    <div class="academia-detail-breadcrumb">
      <span data-role="breadcrumb-category">${product.product_categories?.name || 'Academia de Produtos'}</span>
      <span class="academia-detail-breadcrumb-sep">/</span>
      <span>${product.name}</span>
    </div>

    <div class="academia-detail-header" data-role="header-wrap">${renderHeaderRead(product, isAdmin)}</div>

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
            ${renderSectionPanelInner(s.key, product, isAdmin)}
          </div>
        `).join('')}
      </div>
    </div>`;

  wireBlockInteractions(container, { returnPanel: 'academia-produto-detail' });
  wireSectionNav(container);
  wireComparisonLinks(container);
  wireQuizCard(container);
  wireRelatedLinks(container);

  if (isAdmin) {
    wireHeaderEditor(container, product);
    BLOCK_SECTION_KEYS.forEach((key) => wireBlockSectionEditor(container, product, key));
    wireMaterialsEditor(container, product);
    wireRelationshipsEditor(container, product, brandId);
  }
}

function renderSectionPanelInner(sectionKey, product, isAdmin) {
  if (sectionKey === 'comparativos') return renderComparativos(product.comparisons, product.slug);
  if (sectionKey === 'downloads') return renderDownloadsPanel(product, isAdmin);
  if (sectionKey === 'quiz') return renderQuiz(product.quizzes);
  if (sectionKey === 'relacionados') return renderRelacionadosPanel(product, isAdmin);
  return renderBlockSectionPanel(sectionKey, product, isAdmin);
}

// ── Seções de bloco rico (reaproveita ContentBlocks.js) ──────────────────

function renderBlockSectionPanel(sectionKey, product, isAdmin) {
  const blocks = product.sections.get(sectionKey)?.blocks;
  return `
    ${isAdmin ? `<button type="button" class="academia-edit-btn" data-edit-section="${sectionKey}">✎ Editar seção</button>` : ''}
    <div data-role="section-read-${sectionKey}">${renderBlocks(blocks)}</div>
  `;
}

function wireBlockSectionEditor(container, product, sectionKey) {
  const btn = container.querySelector(`[data-edit-section="${sectionKey}"]`);
  if (!btn) return;

  btn.addEventListener('click', () => {
    const readEl = container.querySelector(`[data-role="section-read-${sectionKey}"]`);
    const currentBlocks = product.sections.get(sectionKey)?.blocks || [];
    btn.hidden = true;

    const editorHost = document.createElement('div');
    readEl.replaceWith(editorHost);

    const restoreRead = (blocks) => {
      const el = document.createElement('div');
      el.dataset.role = `section-read-${sectionKey}`;
      el.innerHTML = renderBlocks(blocks);
      editorHost.replaceWith(el);
      wireBlockInteractions(el, { returnPanel: 'academia-produto-detail' });
      btn.hidden = false;
    };

    setupBlockArrayEditor(editorHost, currentBlocks, {
      onSave: async (blocks) => {
        await updateProductSection(product.id, sectionKey, blocks);
        product.sections.set(sectionKey, { blocks });
        restoreRead(blocks);
      },
      onCancel: () => restoreRead(currentBlocks),
    });
  });
}

// ── Cabeçalho (nome/tagline/preço/modelo) ─────────────────────────────────

function renderHeaderRead(product, isAdmin) {
  const price = product.price_usd != null ? `US$ ${Number(product.price_usd).toFixed(2).replace('.', ',')}` : '';
  return `
    <h2 class="academia-detail-name">${product.name}${product.model_code ? ` <span class="academia-detail-model">${product.model_code}</span>` : ''}</h2>
    ${product.tagline ? `<p class="academia-detail-tagline">${product.tagline}</p>` : ''}
    ${price ? `<span class="academia-detail-price">${price}</span>` : ''}
    ${isAdmin ? '<button type="button" class="academia-edit-btn" data-edit-header>✎ Editar produto</button>' : ''}
  `;
}

function renderHeaderForm(product) {
  return `
    <div class="academia-edit-form">
      <label>Nome<input type="text" data-field="name" value="${product.name || ''}"></label>
      <label>Código do modelo<input type="text" data-field="model_code" value="${product.model_code || ''}"></label>
      <label>Tagline<input type="text" data-field="tagline" value="${product.tagline || ''}"></label>
      <label>Preço (US$)<input type="number" step="0.01" data-field="price_usd" value="${product.price_usd ?? ''}"></label>
      <label>URL da capa<input type="text" data-field="cover_url" value="${product.cover_url || ''}"></label>
      <div class="academia-edit-form-actions">
        <button type="button" class="cb-editor-btn" data-save-header>Salvar</button>
        <button type="button" class="cb-editor-btn" data-cancel-header>Cancelar</button>
      </div>
    </div>`;
}

function wireHeaderEditor(container, product) {
  const wrap = container.querySelector('[data-role="header-wrap"]');

  wrap.querySelector('[data-edit-header]')?.addEventListener('click', () => {
    wrap.innerHTML = renderHeaderForm(product);
    wrap.querySelector('[data-cancel-header]').addEventListener('click', () => {
      wrap.innerHTML = renderHeaderRead(product, true);
      wireHeaderEditor(container, product);
    });
    wrap.querySelector('[data-save-header]').addEventListener('click', async () => {
      const get = (f) => wrap.querySelector(`[data-field="${f}"]`).value;
      const fields = {
        name: get('name').trim(),
        model_code: get('model_code').trim() || null,
        tagline: get('tagline').trim() || null,
        price_usd: get('price_usd') ? Number(get('price_usd')) : null,
        cover_url: get('cover_url').trim() || null,
      };
      try {
        await updateProduct(product.id, fields);
        Object.assign(product, fields);
        const titleEl = document.getElementById('academiaProdutoDetailTitle');
        if (titleEl) titleEl.textContent = product.name;
        wrap.innerHTML = renderHeaderRead(product, true);
        wireHeaderEditor(container, product);
      } catch (err) {
        console.error('[ProdutoDetail] erro ao salvar produto:', err);
        alert('Não foi possível salvar agora.');
      }
    });
  });
}

// ── Comparativos (só leitura aqui — edição na própria página do comparativo) ──

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

// ── Downloads ──────────────────────────────────────────────────────────

function renderDownloadsPanel(product, isAdmin) {
  return `
    <div data-role="downloads-read">${renderDownloadsRead(product.materials)}</div>
    ${isAdmin ? '<button type="button" class="academia-edit-btn" data-edit-downloads>✎ Editar downloads</button>' : ''}
  `;
}

function renderDownloadsRead(materials) {
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

function materialRowHtml(m, i) {
  return `
    <div class="academia-edit-row" data-row-index="${i}">
      <select data-field="type">${MATERIAL_TYPES.map((t) => `<option value="${t}" ${m.type === t ? 'selected' : ''}>${t}</option>`).join('')}</select>
      <input type="text" data-field="title" value="${m.title || ''}" placeholder="Título">
      <input type="text" data-field="url" value="${m.url || ''}" placeholder="URL">
      <button type="button" class="cb-editor-btn cb-editor-btn-danger" data-remove-row>✕</button>
    </div>`;
}

function wireMaterialsEditor(container, product) {
  const panel = container.querySelector('[data-section-panel="downloads"]');
  const editBtn = panel.querySelector('[data-edit-downloads]');
  if (!editBtn) return;

  editBtn.addEventListener('click', () => {
    let rows = product.materials.map((m) => ({ ...m }));
    const readEl = panel.querySelector('[data-role="downloads-read"]');
    editBtn.hidden = true;

    const editorHost = document.createElement('div');
    editorHost.className = 'academia-edit-list';
    readEl.replaceWith(editorHost);

    function render() {
      editorHost.innerHTML = `
        <div data-role="rows">${rows.map(materialRowHtml).join('')}</div>
        <button type="button" class="cb-editor-btn" data-add-row>+ Material</button>
        <div class="academia-edit-form-actions">
          <button type="button" class="cb-editor-btn" data-save-materials>Salvar</button>
          <button type="button" class="cb-editor-btn" data-cancel-materials>Cancelar</button>
        </div>`;

      editorHost.querySelectorAll('[data-remove-row]').forEach((btn) => {
        btn.addEventListener('click', () => {
          rows.splice(Number(btn.closest('[data-row-index]').dataset.rowIndex), 1);
          render();
        });
      });
      editorHost.querySelector('[data-add-row]').addEventListener('click', () => {
        syncFromDom();
        rows.push({ type: 'folder', title: '', url: '' });
        render();
      });
      editorHost.querySelector('[data-cancel-materials]').addEventListener('click', () => restoreRead(product.materials));
      editorHost.querySelector('[data-save-materials]').addEventListener('click', async () => {
        syncFromDom();
        try {
          await replaceMaterials(product.id, rows);
          product.materials = rows;
          restoreRead(rows);
        } catch (err) {
          console.error('[ProdutoDetail] erro ao salvar downloads:', err);
          alert('Não foi possível salvar agora.');
        }
      });
    }

    function syncFromDom() {
      editorHost.querySelectorAll('[data-row-index]').forEach((rowEl) => {
        const i = Number(rowEl.dataset.rowIndex);
        rows[i] = {
          type: rowEl.querySelector('[data-field="type"]').value,
          title: rowEl.querySelector('[data-field="title"]').value.trim(),
          url: rowEl.querySelector('[data-field="url"]').value.trim(),
        };
      });
    }

    function restoreRead(materials) {
      const el = document.createElement('div');
      el.dataset.role = 'downloads-read';
      el.innerHTML = renderDownloadsRead(materials);
      editorHost.replaceWith(el);
      editBtn.hidden = false;
    }

    render();
  });
}

// ── Quiz Especialista (só leitura) ─────────────────────────────────────

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

// ── Relacionados ───────────────────────────────────────────────────────

function renderRelacionadosPanel(product, isAdmin) {
  return `
    <div data-role="relacionados-read">${renderRelacionadosRead(product.relationships)}</div>
    ${isAdmin ? '<button type="button" class="academia-edit-btn" data-edit-relacionados>✎ Editar relacionados</button>' : ''}
  `;
}

function renderRelacionadosRead(relationships) {
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

function relationshipRowHtml(r, i, allProducts) {
  return `
    <div class="academia-edit-row" data-row-index="${i}">
      <select data-field="relatedProductId">
        <option value="">— texto livre —</option>
        ${allProducts.map((p) => `<option value="${p.id}" ${r.relatedProductId === p.id ? 'selected' : ''}>${p.name}</option>`).join('')}
      </select>
      <input type="text" data-field="label" value="${r.relatedProductId ? '' : (r.label || '')}" placeholder="Rótulo (se não for produto)" ${r.relatedProductId ? 'disabled' : ''}>
      <input type="text" data-field="type" value="${r.type || ''}" placeholder="Tipo (ex.: upgrade, acessorio)">
      <button type="button" class="cb-editor-btn cb-editor-btn-danger" data-remove-row>✕</button>
    </div>`;
}

function wireRelationshipsEditor(container, product, brandId) {
  const panel = container.querySelector('[data-section-panel="relacionados"]');
  const editBtn = panel.querySelector('[data-edit-relacionados]');
  if (!editBtn) return;

  editBtn.addEventListener('click', async () => {
    editBtn.hidden = true;
    const readEl = panel.querySelector('[data-role="relacionados-read"]');
    readEl.innerHTML = '<p class="learning-loading">Carregando…</p>';

    let allProducts;
    try {
      allProducts = (await fetchAllProductsForBrand(brandId)).filter((p) => p.id !== product.id);
    } catch (err) {
      console.error('[ProdutoDetail] erro ao carregar produtos:', err);
      allProducts = [];
    }

    let rows = product.relationships.map((r) => ({ ...r }));
    const editorHost = document.createElement('div');
    editorHost.className = 'academia-edit-list';
    readEl.replaceWith(editorHost);

    function render() {
      editorHost.innerHTML = `
        <div data-role="rows">${rows.map((r, i) => relationshipRowHtml(r, i, allProducts)).join('')}</div>
        <button type="button" class="cb-editor-btn" data-add-row>+ Relacionado</button>
        <div class="academia-edit-form-actions">
          <button type="button" class="cb-editor-btn" data-save-rel>Salvar</button>
          <button type="button" class="cb-editor-btn" data-cancel-rel>Cancelar</button>
        </div>`;

      editorHost.querySelectorAll('[data-field="relatedProductId"]').forEach((sel) => {
        sel.addEventListener('change', () => {
          const labelInput = sel.closest('[data-row-index]').querySelector('[data-field="label"]');
          labelInput.disabled = !!sel.value;
          if (sel.value) labelInput.value = '';
        });
      });
      editorHost.querySelectorAll('[data-remove-row]').forEach((btn) => {
        btn.addEventListener('click', () => {
          rows.splice(Number(btn.closest('[data-row-index]').dataset.rowIndex), 1);
          render();
        });
      });
      editorHost.querySelector('[data-add-row]').addEventListener('click', () => {
        syncFromDom();
        rows.push({ relatedProductId: null, label: '', type: '' });
        render();
      });
      editorHost.querySelector('[data-cancel-rel]').addEventListener('click', () => restoreRead(product.relationships));
      editorHost.querySelector('[data-save-rel]').addEventListener('click', async () => {
        syncFromDom();
        try {
          await replaceRelationships(product.id, rows);
          const other = await fetchAllProductsForBrand(brandId);
          product.relationships = rows.map((r) => ({
            ...r,
            slug: r.relatedProductId ? other.find((p) => p.id === r.relatedProductId)?.slug : null,
            label: r.relatedProductId ? (other.find((p) => p.id === r.relatedProductId)?.name || r.label) : r.label,
          }));
          restoreRead(product.relationships);
        } catch (err) {
          console.error('[ProdutoDetail] erro ao salvar relacionados:', err);
          alert('Não foi possível salvar agora.');
        }
      });
    }

    function syncFromDom() {
      editorHost.querySelectorAll('[data-row-index]').forEach((rowEl) => {
        const i = Number(rowEl.dataset.rowIndex);
        const relatedProductId = rowEl.querySelector('[data-field="relatedProductId"]').value || null;
        rows[i] = {
          relatedProductId,
          label: rowEl.querySelector('[data-field="label"]').value.trim(),
          type: rowEl.querySelector('[data-field="type"]').value.trim(),
        };
      });
    }

    function restoreRead(relationships) {
      const el = document.createElement('div');
      el.dataset.role = 'relacionados-read';
      el.innerHTML = renderRelacionadosRead(relationships);
      editorHost.replaceWith(el);
      wireRelatedLinks(container);
      editBtn.hidden = false;
    }

    render();
  });
}

// ── Navegação/wiring geral ───────────────────────────────────────────────

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
