// src/pages/comparativoDetail.js
// Página de comparativo lado a lado entre 2 produtos da Academia — resumo
// executivo, tabela spec-a-spec (comparison_items) e blocos ricos
// (vantagens/limitações/quando vender/argumentos/faq/objeções, reaproveitando
// ContentBlocks.js) + link pro game de comparativo, quando existir.
//
// Edição (admin, 2026-07-20): resumo e blocos reaproveitam o mesmo padrão de
// produtoDetail.js (textarea simples / setupBlockArrayEditor); a tabela
// spec-a-spec ganha um editor de linhas próprio (não é um bloco rico, é a
// estrutura própria de comparison_items com vencedor por linha).

import { navigateToPanel } from '../router.js';
import { fetchComparisonBySlug, updateComparison, replaceComparisonItems } from '../services/academiaService.js';
import { renderBlocks, wireBlockInteractions, setupBlockArrayEditor } from '../components/ContentBlocks.js';
import { getCurrentProfile, isAdminProfile } from '../config/supabase.js';

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
    const [comparison, profile] = await Promise.all([fetchComparisonBySlug(brandId, slug), getCurrentProfile()]);
    const isAdmin = isAdminProfile(profile);
    if (titleEl) titleEl.textContent = comparison.title;
    renderComparativoDetail(container, comparison, isAdmin);
  } catch (err) {
    console.error('[ComparativoDetail] erro ao carregar comparativo:', err);
    container.innerHTML = '<p class="content-error">Não foi possível carregar este comparativo agora.</p>';
  }
}

function winnerClass(winner, side) {
  if (winner === 'tie') return 'tie';
  return winner === side ? 'winner' : '';
}

function renderComparativoDetail(container, comparison, isAdmin) {
  const { product_a: a, product_b: b, games: game } = comparison;

  container.innerHTML = `
    <div class="academia-vs-header">
      <div class="academia-vs-side">${a?.name || '—'}</div>
      <div class="academia-vs-badge">VS</div>
      <div class="academia-vs-side">${b?.name || '—'}</div>
    </div>

    <div data-role="resumo-read">${renderResumoRead(comparison.resumo_executivo)}</div>
    ${isAdmin ? '<button type="button" class="academia-edit-btn" data-edit-resumo>✎ Editar resumo</button>' : ''}

    ${game ? `
      <button type="button" class="academia-vs-game-btn" data-game-id="${game.id}">
        <span>🎮</span> Jogar Duelo de Comparativo: ${game.title}
      </button>
    ` : ''}

    <div data-role="table-read">${renderTableRead(comparison.items, a, b)}</div>
    ${isAdmin ? '<button type="button" class="academia-edit-btn" data-edit-table>✎ Editar tabela</button>' : ''}

    <div data-role="blocks-read" class="academia-vs-blocks">${renderBlocks(comparison.blocks)}</div>
    ${isAdmin ? '<button type="button" class="academia-edit-btn" data-edit-blocks>✎ Editar blocos</button>' : ''}
  `;

  wireBlockInteractions(container, { returnPanel: 'academia-comparativo' });

  container.querySelector('[data-game-id]')?.addEventListener('click', (e) => {
    window.selectedGameId = e.currentTarget.dataset.gameId;
    window.gameRunnerReturnPanel = 'academia-comparativo';
    navigateToPanel('game-runner');
  });

  if (isAdmin) {
    wireResumoEditor(container, comparison);
    wireTableEditor(container, comparison);
    wireBlocksEditor(container, comparison);
  }
}

// ── Resumo executivo ─────────────────────────────────────────────────────

function renderResumoRead(resumo) {
  return resumo ? `<div class="academia-vs-summary">${resumo}</div>` : '<p class="learning-empty">Sem resumo executivo ainda.</p>';
}

function wireResumoEditor(container, comparison) {
  const btn = container.querySelector('[data-edit-resumo]');
  if (!btn) return;

  btn.addEventListener('click', () => {
    const readEl = container.querySelector('[data-role="resumo-read"]');
    btn.hidden = true;
    readEl.innerHTML = `
      <div class="academia-edit-form">
        <textarea data-field="resumo" rows="5">${comparison.resumo_executivo || ''}</textarea>
        <div class="academia-edit-form-actions">
          <button type="button" class="cb-editor-btn" data-save-resumo>Salvar</button>
          <button type="button" class="cb-editor-btn" data-cancel-resumo>Cancelar</button>
        </div>
      </div>`;

    readEl.querySelector('[data-cancel-resumo]').addEventListener('click', () => {
      readEl.innerHTML = renderResumoRead(comparison.resumo_executivo);
      btn.hidden = false;
    });
    readEl.querySelector('[data-save-resumo]').addEventListener('click', async () => {
      const value = readEl.querySelector('[data-field="resumo"]').value.trim();
      try {
        await updateComparison(comparison.id, { resumo_executivo: value || null });
        comparison.resumo_executivo = value || null;
        readEl.innerHTML = renderResumoRead(comparison.resumo_executivo);
        btn.hidden = false;
      } catch (err) {
        console.error('[ComparativoDetail] erro ao salvar resumo:', err);
        alert('Não foi possível salvar agora.');
      }
    });
  });
}

// ── Tabela spec-a-spec ────────────────────────────────────────────────────

function renderTableRead(items, a, b) {
  if (!items?.length) return '<p class="learning-empty">Nenhuma linha na tabela comparativa ainda.</p>';
  return `
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
    </div>`;
}

function tableRowHtml(it, i) {
  return `
    <div class="academia-edit-row academia-edit-row-table" data-row-index="${i}">
      <input type="text" data-field="spec_label" value="${it.spec_label || ''}" placeholder="Especificação">
      <input type="text" data-field="value_a" value="${it.value_a || ''}" placeholder="Valor A">
      <input type="text" data-field="value_b" value="${it.value_b || ''}" placeholder="Valor B">
      <select data-field="winner">
        <option value="" ${!it.winner ? 'selected' : ''}>—</option>
        <option value="a" ${it.winner === 'a' ? 'selected' : ''}>A vence</option>
        <option value="b" ${it.winner === 'b' ? 'selected' : ''}>B vence</option>
        <option value="tie" ${it.winner === 'tie' ? 'selected' : ''}>Empate</option>
      </select>
      <button type="button" class="cb-editor-btn cb-editor-btn-danger" data-remove-row>✕</button>
    </div>`;
}

function wireTableEditor(container, comparison) {
  const btn = container.querySelector('[data-edit-table]');
  if (!btn) return;

  btn.addEventListener('click', () => {
    let rows = comparison.items.map((it) => ({ ...it }));
    const readEl = container.querySelector('[data-role="table-read"]');
    btn.hidden = true;

    const editorHost = document.createElement('div');
    editorHost.className = 'academia-edit-list';
    readEl.replaceWith(editorHost);

    function render() {
      editorHost.innerHTML = `
        <div data-role="rows">${rows.map(tableRowHtml).join('')}</div>
        <button type="button" class="cb-editor-btn" data-add-row>+ Linha</button>
        <div class="academia-edit-form-actions">
          <button type="button" class="cb-editor-btn" data-save-table>Salvar</button>
          <button type="button" class="cb-editor-btn" data-cancel-table>Cancelar</button>
        </div>`;

      editorHost.querySelectorAll('[data-remove-row]').forEach((removeBtn) => {
        removeBtn.addEventListener('click', () => {
          syncFromDom();
          rows.splice(Number(removeBtn.closest('[data-row-index]').dataset.rowIndex), 1);
          render();
        });
      });
      editorHost.querySelector('[data-add-row]').addEventListener('click', () => {
        syncFromDom();
        rows.push({ spec_label: '', value_a: '', value_b: '', winner: '' });
        render();
      });
      editorHost.querySelector('[data-cancel-table]').addEventListener('click', () => restoreRead(comparison.items));
      editorHost.querySelector('[data-save-table]').addEventListener('click', async () => {
        syncFromDom();
        try {
          await replaceComparisonItems(comparison.id, rows);
          comparison.items = rows;
          restoreRead(rows);
        } catch (err) {
          console.error('[ComparativoDetail] erro ao salvar tabela:', err);
          alert('Não foi possível salvar agora.');
        }
      });
    }

    function syncFromDom() {
      editorHost.querySelectorAll('[data-row-index]').forEach((rowEl) => {
        const i = Number(rowEl.dataset.rowIndex);
        rows[i] = {
          spec_label: rowEl.querySelector('[data-field="spec_label"]').value.trim(),
          value_a: rowEl.querySelector('[data-field="value_a"]').value.trim(),
          value_b: rowEl.querySelector('[data-field="value_b"]').value.trim(),
          winner: rowEl.querySelector('[data-field="winner"]').value || null,
        };
      });
    }

    function restoreRead(items) {
      const el = document.createElement('div');
      el.dataset.role = 'table-read';
      el.innerHTML = renderTableRead(items, comparison.product_a, comparison.product_b);
      editorHost.replaceWith(el);
      btn.hidden = false;
    }

    render();
  });
}

// ── Blocos ricos (vantagens/limitações/roteiro/objeções/faq) ─────────────

function wireBlocksEditor(container, comparison) {
  const btn = container.querySelector('[data-edit-blocks]');
  if (!btn) return;

  btn.addEventListener('click', () => {
    const readEl = container.querySelector('[data-role="blocks-read"]');
    const currentBlocks = comparison.blocks || [];
    btn.hidden = true;

    const editorHost = document.createElement('div');
    readEl.replaceWith(editorHost);

    const restoreRead = (blocks) => {
      const el = document.createElement('div');
      el.dataset.role = 'blocks-read';
      el.className = 'academia-vs-blocks';
      el.innerHTML = renderBlocks(blocks);
      editorHost.replaceWith(el);
      wireBlockInteractions(el, { returnPanel: 'academia-comparativo' });
      btn.hidden = false;
    };

    setupBlockArrayEditor(editorHost, currentBlocks, {
      onSave: async (blocks) => {
        await updateComparison(comparison.id, { blocks });
        comparison.blocks = blocks;
        restoreRead(blocks);
      },
      onCancel: () => restoreRead(currentBlocks),
    });
  });
}
