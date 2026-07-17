// src/pages/biblioteca.js
// "Biblioteca Técnica" — perfis de cliente, produtos, FAQ, concorrentes e
// especialidades por esporte. Antes desta sprint esse conteúdo só existia
// como HTML/JS estático dentro de index_redesign_v5.html; agora vem da
// tabela content_library (ver sql/002_content_library_schema.sql e
// sql/seeds/040_biblioteca_tecnica.sql).

import { CATEGORIES, fetchContentByCategory } from '../services/contentLibraryService.js';
import { renderLibrarySection } from '../components/LibraryContent.js';

const TABS = [
  { id: CATEGORIES.PERFIL_CLIENTE, label: 'Perfis de Cliente' },
  { id: CATEGORIES.PRODUTO, label: 'Produtos' },
  { id: CATEGORIES.FAQ, label: 'FAQ' },
  { id: CATEGORIES.CONCORRENTE, label: 'Concorrentes' },
  { id: CATEGORIES.ESPECIALIDADE, label: 'Especialidades' },
  { id: CATEGORIES.DEEP_DIVE, label: 'Guias Técnicos' },
];

let activeCategory = TABS[0].id;

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'biblioteca') initBibliotecaPage();
});

function initBibliotecaPage() {
  const tabsEl = document.getElementById('bibliotecaTabs');
  if (!tabsEl) return;

  // Deep-link vindo do Acesso Rápido (sidebar) — window.selectedLibraryCategory
  // abre direto na aba certa. (Guias Técnicos específicos deep-linkam direto
  // pro painel deep-dive-detail — ver DashboardHome.js/LibraryContent.js.)
  if (window.selectedLibraryCategory) {
    activeCategory = window.selectedLibraryCategory;
    delete window.selectedLibraryCategory;
  }

  tabsEl.innerHTML = TABS.map((t) => `
    <button type="button" class="lib-tab ${t.id === activeCategory ? 'active' : ''}" data-category="${t.id}">${t.label}</button>
  `).join('');

  tabsEl.querySelectorAll('[data-category]').forEach((btn) => {
    btn.addEventListener('click', () => {
      activeCategory = btn.dataset.category;
      tabsEl.querySelectorAll('[data-category]').forEach((b) => b.classList.toggle('active', b === btn));
      loadCategory(activeCategory);
    });
  });

  loadCategory(activeCategory);
}

async function loadCategory(category) {
  const container = document.getElementById('bibliotecaContainer');
  if (!container) return;

  const brandId = window.selectedBrandId;
  if (!brandId) {
    container.innerHTML = '<p class="learning-error">Escolha uma marca na tela Início primeiro.</p>';
    return;
  }

  container.innerHTML = '<p class="learning-loading">Carregando…</p>';

  try {
    const items = await fetchContentByCategory(brandId, category);
    renderLibrarySection(container, category, items);
  } catch (err) {
    console.error('[Biblioteca] erro ao carregar categoria:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar este conteúdo agora.</p>';
  }
}
