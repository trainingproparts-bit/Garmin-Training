// src/pages/ranking.js
// Ranking de pontos ao vivo (RN §6.4, sem temporada/medalhas ainda — ver
// sql/025_ranking_store_highlights.sql) + Destaque de Vendas por loja
// (pedido direto do usuário em 2026-07-10, atualizado manualmente todo mês
// por Admin ou pelo Líder daquela loja).
//
// Atualizado 2026-07-13: Adicionado painel de histórico de temporadas
// (Leaderboard Trimestral) com pódios das temporadas passadas.

import { getCurrentProfile, isAdminProfile, isLeaderProfile } from '../config/supabase.js';
import {
  fetchPointsRanking,
  fetchStoresForBrand,
  fetchLeaderStoreIds,
  fetchStoreHighlights,
  upsertStoreHighlight,
} from '../services/rankingService.js';
import {
  getCurrentSeason,
  fetchSeasonHistory,
} from '../services/leaderboardService.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'ranking') initRankingPage();
});

async function initRankingPage() {
  const container = document.getElementById('rankingContainer');
  if (!container) return;

  const brandId = window.selectedBrandId;
  if (!brandId) {
    container.innerHTML = '<p class="learning-error">Escolha uma marca na tela Início primeiro.</p>';
    return;
  }

  container.innerHTML = '<p class="learning-loading">Carregando…</p>';

  try {
    const profile = await getCurrentProfile();
    const isAdmin = isAdminProfile(profile);
    const isLeader = isLeaderProfile(profile);

    const [ranking, highlights, stores, leaderStoreIds, seasonHistory] = await Promise.all([
      fetchPointsRanking(brandId),
      fetchStoreHighlights(brandId),
      (isAdmin || isLeader) ? fetchStoresForBrand(brandId) : Promise.resolve([]),
      (isLeader && !isAdmin && profile) ? fetchLeaderStoreIds(profile.id) : Promise.resolve([]),
      fetchSeasonHistory(4),
    ]);

    renderRanking(container, { ranking, highlights, stores, leaderStoreIds, profile, isAdmin, isLeader, seasonHistory });
  } catch (err) {
    console.error('[Ranking] erro ao carregar:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar o ranking agora.</p>';
  }
}

function renderRanking(container, { ranking, highlights, stores, leaderStoreIds, profile, isAdmin, isLeader, seasonHistory }) {
  const highlightMap = new Map(highlights.map((h) => [h.store_id, h]));
  const editableStoreIds = isAdmin ? stores.map((s) => s.id) : leaderStoreIds;
  const currentSeason = getCurrentSeason();

  // Colaborador comum não recebe a lista de lojas (só admin/líder precisam
  // dela pra editar) — nesse caso, mostra só as lojas que já têm destaque.
  const storeEntries = (isAdmin || isLeader)
    ? stores
    : highlights.map((h) => ({ id: h.store_id, name: h.stores?.name || '—' }));

  container.innerHTML = `
    <div class="ranking-layout">
      <div class="ranking-main">
        <h3 class="dash-section-label">🏆 Ranking de Pontos</h3>
        <div class="ranking-list" data-role="ranking-list">
          ${ranking.length ? ranking.map((r, i) => rankingRowHtml(r, i, profile?.id)).join('') : '<p class="learning-empty">Nenhum colaborador ativo ainda.</p>'}
        </div>
      </div>
      <aside class="ranking-side">
        <h3 class="dash-section-label">📣 Destaque de Vendas</h3>
        <div class="ranking-highlight-list" data-role="highlight-list">
          ${storeEntries.length
            ? storeEntries.map((s) => highlightCardHtml(s, highlightMap.get(s.id), editableStoreIds.includes(s.id))).join('')
            : '<p class="dash-empty-text">Nenhum destaque cadastrado ainda.</p>'}
        </div>
        <h3 class="dash-section-label" style="margin-top: 2rem;">🏅 Histórico de Temporadas</h3>
        <div class="ranking-season-history" data-role="season-history">
          ${seasonHistory.length ? seasonHistory.map((season) => seasonHistoryHtml(season, currentSeason)).join('') : '<p class="dash-empty-text">Nenhuma temporada encerrada ainda.</p>'}
        </div>
      </aside>
    </div>
  `;

  wireHighlightEdit(container, { highlightMap, profile });
}

function rankingRowHtml(r, index, currentUserId) {
  const isMe = r.id === currentUserId;
  const position = index === 0 ? '🥇' : index === 1 ? '🥈' : index === 2 ? '🥉' : `${index + 1}º`;
  return `
    <div class="ranking-row${isMe ? ' is-me' : ''}">
      <span class="ranking-position">${position}</span>
      <div class="ranking-person">
        <span class="ranking-name">${r.full_name}${isMe ? ' <em>(você)</em>' : ''}</span>
        <span class="ranking-store">${r.store_name || '—'}</span>
      </div>
      <span class="ranking-score">${r.performance_score ?? 0} pts</span>
    </div>`;
}

function highlightCardHtml(store, highlight, canEdit) {
  const hasMessage = !!highlight?.message;
  return `
    <div class="ranking-highlight-card" data-store-id="${store.id}">
      <div class="ranking-highlight-store">${store.name}</div>
      <p class="ranking-highlight-message">${hasMessage ? highlight.message : 'Nenhum destaque cadastrado ainda.'}</p>
      ${highlight?.updated_at ? `<span class="ranking-highlight-updated">Atualizado em ${new Date(highlight.updated_at).toLocaleDateString('pt-BR')}</span>` : ''}
      ${canEdit ? `<button type="button" class="ranking-highlight-edit-btn" data-store-id="${store.id}">Editar</button>` : ''}
      <div class="ranking-highlight-form" data-role="highlight-form" hidden></div>
    </div>`;
}

function seasonHistoryHtml(season, currentSeason) {
  const isCurrent = season.seasonId === currentSeason;
  const podium = season.podium.sort((a, b) => a.rank - b.rank);
  
  return `
    <div class="ranking-season-card ${isCurrent ? 'is-current' : ''}">
      <div class="ranking-season-header">
        <span class="ranking-season-id">${season.seasonId}</span>
        ${isCurrent ? '<span class="ranking-season-badge">Atual</span>' : ''}
      </div>
      <div class="ranking-season-podium">
        ${podium.map((entry) => {
          const medal = entry.rank === 1 ? '🥇' : entry.rank === 2 ? '🥈' : '🥉';
          return `
            <div class="ranking-season-podium-entry">
              <span class="ranking-season-medal">${medal}</span>
              <span class="ranking-season-name">${entry.user?.full_name || '—'}</span>
              <span class="ranking-season-points">${entry.points} pts</span>
            </div>
          `;
        }).join('')}
      </div>
    </div>
  `;
}

function wireHighlightEdit(container, { highlightMap, profile }) {
  container.querySelectorAll('.ranking-highlight-edit-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
      const storeId = btn.dataset.storeId;
      const card = container.querySelector(`.ranking-highlight-card[data-store-id="${storeId}"]`);
      const formEl = card.querySelector('[data-role="highlight-form"]');
      const currentMessage = highlightMap.get(storeId)?.message || '';

      formEl.innerHTML = `
        <textarea class="ranking-highlight-textarea" rows="3" placeholder="Ex.: Recorde de vendas do trimestre! 🚀">${currentMessage}</textarea>
        <div class="ranking-highlight-form-actions">
          <button type="button" class="cb-editor-btn" data-action="save">Salvar</button>
          <button type="button" class="cb-editor-btn" data-action="cancel">Cancelar</button>
        </div>
        <div class="ranking-highlight-form-msg" data-role="msg"></div>
      `;
      formEl.hidden = false;
      btn.hidden = true;

      formEl.querySelector('[data-action="cancel"]').addEventListener('click', () => {
        formEl.hidden = true;
        btn.hidden = false;
      });

      formEl.querySelector('[data-action="save"]').addEventListener('click', async () => {
        const textarea = formEl.querySelector('textarea');
        const msgEl = formEl.querySelector('[data-role="msg"]');
        msgEl.textContent = 'Salvando...';
        msgEl.style.color = 'var(--text3)';
        try {
          await upsertStoreHighlight(storeId, textarea.value.trim(), profile.id);
          initRankingPage();
        } catch (err) {
          console.error('[Ranking] erro ao salvar destaque:', err);
          msgEl.textContent = 'Erro ao salvar: ' + err.message;
          msgEl.style.color = 'var(--g)';
        }
      });
    });
  });
}
