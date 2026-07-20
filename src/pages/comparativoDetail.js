// src/pages/comparativoDetail.js
// Página de comparativo lado a lado entre 2 produtos da Academia — resumo
// executivo, tabela spec-a-spec (comparison_items) e blocos ricos
// (vantagens/limitações/quando vender/argumentos/faq/objeções, reaproveitando
// ContentBlocks.js) + link pro game de comparativo, quando existir.

import { navigateToPanel } from '../router.js';
import { fetchComparisonBySlug } from '../services/academiaService.js';
import { renderBlocks, wireBlockInteractions } from '../components/ContentBlocks.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'academia-comparativo') initComparativoDetailPage();
});

async function initComparativoDetailPage() {
  const container = document.getElementById('academiaComparativoContainer');
  const titleEl = document.getElementById('academiaComparativoTitle');
  if (!container) return;

  // Não apaga window.selectedComparisonSlug depois de ler — o painel é
  // reativado sem slug novo quando o usuário volta do game de comparativo
  // (gameRunnerReturnPanel aponta pra cá), e precisa continuar mostrando o
  // MESMO comparativo, não "esquecer" qual estava aberto.
  const slug = window.selectedComparisonSlug;

  if (!slug) {
    container.innerHTML = '<p class="content-error">Nenhum comparativo selecionado.</p>';
    return;
  }

  const brandId = window.selectedBrandId;
  if (!brandId) {
    container.innerHTML = '<p class="content-error">Escolha uma marca na tela Início primeiro.</p>';
    return;
  }

  container.innerHTML = '<p class="home-loading">Carregando comparativo…</p>';

  try {
    const comparison = await fetchComparisonBySlug(brandId, slug);
    if (titleEl) titleEl.textContent = comparison.title;
    renderComparativoDetail(container, comparison);
  } catch (err) {
    console.error('[ComparativoDetail] erro ao carregar comparativo:', err);
    container.innerHTML = '<p class="content-error">Não foi possível carregar este comparativo agora.</p>';
  }
}

function winnerClass(winner, side) {
  if (winner === 'tie') return 'tie';
  return winner === side ? 'winner' : '';
}

function renderComparativoDetail(container, comparison) {
  const { product_a: a, product_b: b, items, blocks, games: game } = comparison;

  container.innerHTML = `
    <div class="academia-vs-header">
      <div class="academia-vs-side">${a?.name || '—'}</div>
      <div class="academia-vs-badge">VS</div>
      <div class="academia-vs-side">${b?.name || '—'}</div>
    </div>

    ${comparison.resumo_executivo ? `<div class="academia-vs-summary">${comparison.resumo_executivo}</div>` : ''}

    ${game ? `
      <button type="button" class="academia-vs-game-btn" data-game-id="${game.id}">
        <span>🎮</span> Jogar Duelo de Comparativo: ${game.title}
      </button>
    ` : ''}

    ${items?.length ? `
      <div class="cb-table-wrap academia-vs-table-wrap">
        <table class="cb-table academia-vs-table">
          <thead><tr><th>Especificação</th><th>${a?.name || 'A'}</th><th>${b?.name || 'B'}</th></tr></thead>
          <tbody>
            ${items.map((it) => `
              <tr>
                <td class="academia-vs-spec-label">${it.spec_label}</td>
                <td class="${winnerClass(it.winner, 'a')}">${it.value_a || '—'}</td>
                <td class="${winnerClass(it.winner, 'b')}">${it.value_b || '—'}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    ` : ''}

    <div class="academia-vs-blocks">${renderBlocks(blocks)}</div>
  `;

  wireBlockInteractions(container, { returnPanel: 'academia-comparativo' });

  container.querySelector('[data-game-id]')?.addEventListener('click', (e) => {
    window.selectedGameId = e.currentTarget.dataset.gameId;
    window.gameRunnerReturnPanel = 'academia-comparativo';
    navigateToPanel('game-runner');
  });
}
