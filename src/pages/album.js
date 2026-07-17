// src/pages/album.js
// Álbum da Equipe — figurinhas por colaborador, portadas de
// index_redesign_v5.html (sql/037_team_album.sql tem o mapeamento completo
// de cada atributo pra dado real, e o que ficou de fora — "Selo" — por
// pedido do usuário).

import { getCurrentProfile, isAdminProfile } from '../config/supabase.js';
import { fetchTeamAlbum, updateMyAlbumProfile, updateCuratedAlbumFields } from '../services/teamAlbumService.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'album') initAlbumPage();
});

const CLASSE_CONFIG = {
  'Explorador':   { cor: '#8a93a0', gradiente: 'linear-gradient(135deg,#1a1d21,#2a2d35)' },
  'Corredor':     { cor: '#8C1F2E', gradiente: 'linear-gradient(135deg,#1a0a0d,#2a0d14)' },
  'Maratonista':  { cor: '#9b59b6', gradiente: 'linear-gradient(135deg,#140d1e,#1e1030)' },
  'Triatleta':    { cor: '#F0A500', gradiente: 'linear-gradient(135deg,#1a1400,#2a2000)' },
};

// #d4580a (laranja) e #00C2A8 (teal) trocados por #8C1F2E (vinho, mesmo tom
// de --acc) e #6b7280 (cinza) — paleta cinza/vermelho, sem verde/teal/laranja.
// Azul e roxo não estavam na lista de cores proibidas, mantidos.
const STORE_COLORS = [
  '#F0A500', '#8C1F2E', '#1a6adb', '#6b7280', '#9b59b6', '#4a90e2',
];

let albumState = { rows: [], profile: null, filter: 'todos' };
const storeColorCache = new Map();

function classeCfg(classe) {
  return CLASSE_CONFIG[classe] || CLASSE_CONFIG['Explorador'];
}

function storeColor(storeId) {
  if (!storeId) return '#8a93a0';
  if (!storeColorCache.has(storeId)) {
    storeColorCache.set(storeId, STORE_COLORS[storeColorCache.size % STORE_COLORS.length]);
  }
  return storeColorCache.get(storeId);
}

function attrColor(val) {
  if (val >= 85) return '#8C1F2E';
  if (val >= 65) return '#F0A500';
  if (val >= 40) return '#4a90e2';
  return '#8a93a0';
}

async function initAlbumPage() {
  const container = document.getElementById('albumContainer');
  if (!container) return;

  const brandId = window.selectedBrandId;
  if (!brandId) {
    container.innerHTML = '<p class="learning-error">Escolha uma marca na tela Início primeiro.</p>';
    return;
  }

  container.innerHTML = '<p class="learning-loading">Carregando álbum…</p>';

  try {
    const [rows, profile] = await Promise.all([fetchTeamAlbum(brandId), getCurrentProfile()]);
    albumState = { rows, profile, filter: 'todos' };
    renderAlbum(container);
  } catch (err) {
    console.error('[Album] erro ao carregar:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar o álbum agora.</p>';
  }
}

function renderAlbum(container) {
  const { rows, profile, filter } = albumState;
  const storeNames = [...new Map(rows.filter((r) => r.store_id).map((r) => [r.store_id, r.store_name])).entries()];
  const especialistas = rows.filter((r) => r.produto_pct >= 100).length;

  container.innerHTML = `
    <div class="album-intro">
      <div class="album-intro-eyebrow">Training Hub · Temporada 2026</div>
      <div class="album-intro-title">Álbum da Equipe</div>
      <p class="album-intro-sub">Cada colaborador tem sua figurinha. A classe evolui conforme as certificações da trilha.</p>
      <details class="album-score-explainer">
        <summary>Como funciona a pontuação?</summary>
        <p><strong>Score de Performance</strong> (o número que aparece no seu perfil) soma pontos de: lição concluída (+25), quiz aprovado (+100), certificação emitida (+300), jogo jogado pela primeira vez (+50), sequência de estudo mantida a cada 5 dias (+20) e avaliação Google recebida (+10 cada).</p>
        <p>Os atributos da figurinha vêm de dados reais: <strong>Produto</strong> = % de lições concluídas · <strong>Precisão</strong> = média de acerto nos quizzes · <strong>Jogo</strong> = média de acerto nos jogos · <strong>Ritmo</strong> = posição aproximada no ranking de Score de Performance · <strong>Reputação</strong> = curada pelo admin a partir das avaliações Google.</p>
      </details>
      <div class="album-stats-row">
        <div class="album-stat-pill"><div class="album-stat-num">${rows.length}</div><div class="album-stat-label">Colaboradores</div></div>
        <div class="album-stat-pill"><div class="album-stat-num">🥇 ${especialistas}</div><div class="album-stat-label">Conteúdo 100%</div></div>
      </div>
      <div class="album-filters-row">
        <button type="button" class="album-filter-chip${filter === 'todos' ? ' active' : ''}" data-filter="todos">Todos</button>
        ${storeNames.map(([id, name]) => `<button type="button" class="album-filter-chip${filter === id ? ' active' : ''}" data-filter="${id}">${name}</button>`).join('')}
        ${profile ? `<button type="button" class="album-edit-me-btn" data-role="edit-me">✏️ Editar minha figurinha</button>` : ''}
      </div>
    </div>

    <div class="album-grid" data-role="album-grid"></div>
    <div data-role="album-modal-root"></div>
  `;

  renderGrid(container);
  wireFilters(container);

  const editBtn = container.querySelector('[data-role="edit-me"]');
  if (editBtn) editBtn.addEventListener('click', () => openEditMeModal(container));
}

function renderGrid(container) {
  const { rows, filter } = albumState;
  const gridEl = container.querySelector('[data-role="album-grid"]');
  const items = filter === 'todos' ? rows : rows.filter((r) => r.store_id === filter);

  if (!items.length) {
    gridEl.innerHTML = '<p class="learning-empty">Nenhum colaborador nessa loja ainda.</p>';
    return;
  }

  gridEl.innerHTML = items.map((r) => cardHtml(r)).join('');

  gridEl.querySelectorAll('[data-album-user]').forEach((el) => {
    el.addEventListener('click', () => openDetailModal(container, el.dataset.albumUser));
  });
  wireAvatarFallbacks(gridEl);
}

// Sem onerror inline (evita interpolar texto livre do usuário — emoji é um
// campo de texto sem validação — dentro de um handler JS via string, que
// seria um vetor de XSS mais sério que interpolação simples em innerHTML).
// O fallback é resolvido depois de inserir no DOM, por wireAvatarFallbacks().
function avatarHtml(r, size) {
  const fallback = r.emoji || '👤';
  if (r.avatar_url) {
    return `<span data-avatar-fallback="${fallback}"><img src="${r.avatar_url}" alt="" data-role="avatar-img" style="width:${size}px;height:${size}px;font-size:${Math.round(size * 0.55)}px;"></span>`;
  }
  return `<span style="font-size:${Math.round(size * 0.55)}px;">${fallback}</span>`;
}

function wireAvatarFallbacks(root) {
  root.querySelectorAll('[data-role="avatar-img"]').forEach((img) => {
    img.addEventListener('error', () => {
      const wrap = img.closest('[data-avatar-fallback]');
      const size = parseInt(img.style.width, 10) || 44;
      img.replaceWith(Object.assign(document.createElement('span'), {
        textContent: wrap?.dataset.avatarFallback || '👤',
        style: `font-size:${Math.round(size * 0.55)}px`,
      }));
    }, { once: true });
  });
}

function cardHtml(r) {
  const cfg = classeCfg(r.classe);
  const sColor = storeColor(r.store_id);
  const nameParts = r.full_name.split(' ');
  return `
    <div class="album-card${r.is_top_seller ? ' has-top-seller' : ''}" style="background:${cfg.gradiente};" data-album-user="${r.user_id}">
      ${r.is_top_seller ? '<div class="album-card-top-seller">🔥 Ponta do Mês</div>' : ''}
      <div class="album-card-store-bar" style="background:${sColor};"></div>
      <div class="album-card-head">
        <div class="album-card-store-label">${r.store_name || 'Sem loja'}</div>
      </div>
      <div class="album-card-avatar">${avatarHtml(r, 44)}</div>
      <div class="album-card-name">${nameParts[0]}<br><span style="font-size:11px;opacity:0.7;">${nameParts.slice(1).join(' ')}</span></div>
      <div class="album-card-classe"><span style="color:${cfg.cor};border-color:${cfg.cor}55;">${r.classe}</span></div>
      <div class="album-card-attrs">
        ${attrRowHtml('Produto', r.produto_pct)}
        ${attrRowHtml('Ritmo', r.ritmo_pct)}
        ${attrRowHtml('Precisão', r.precisao_pct)}
        ${attrRowHtml('Jogo', r.jogo_pct)}
      </div>
    </div>`;
}

function attrRowHtml(label, val) {
  return `
    <div class="album-attr-row">
      <div class="album-attr-label">${label}</div>
      <div class="album-attr-track"><div class="album-attr-fill" style="width:${val}%;background:${attrColor(val)};"></div></div>
      <div class="album-attr-val">${val || '—'}</div>
    </div>`;
}

function wireFilters(container) {
  container.querySelectorAll('[data-filter]').forEach((btn) => {
    btn.addEventListener('click', () => {
      albumState.filter = btn.dataset.filter;
      container.querySelectorAll('[data-filter]').forEach((b) => b.classList.toggle('active', b.dataset.filter === albumState.filter));
      renderGrid(container);
    });
  });
}

function openDetailModal(container, userId) {
  const r = albumState.rows.find((x) => x.user_id === userId);
  if (!r) return;
  const cfg = classeCfg(r.classe);
  const isAdmin = isAdminProfile(albumState.profile);
  const isMe = albumState.profile?.id === userId;
  const root = container.querySelector('[data-role="album-modal-root"]');

  root.innerHTML = `
    <div class="album-modal-backdrop" data-role="modal-backdrop">
      <div class="album-modal" style="background:${cfg.gradiente};">
        <div class="album-modal-head">
          <div style="font-size:10px;letter-spacing:2px;text-transform:uppercase;color:${cfg.cor};">${r.classe.toUpperCase()}</div>
        </div>
        <div class="album-modal-avatar">${avatarHtml(r, 84)}</div>
        <div class="album-modal-name">${r.full_name}</div>
        <div class="album-modal-attrs">
          ${modalAttrHtml('Produto', r.produto_pct)}
          ${modalAttrHtml('Ritmo', r.ritmo_pct)}
          ${modalAttrHtml('Precisão', r.precisao_pct)}
          ${modalAttrHtml('Jogo', r.jogo_pct)}
          ${modalAttrHtml('⭐ Reputação', r.reputation_score ?? 0)}
        </div>
        <div class="album-modal-facts">
          ${r.specialty ? factHtml('Especialidade', r.specialty) : ''}
          ${r.favorite_watch ? factHtml('Equipamento', `⌚ ${r.favorite_watch}`) : ''}
          ${r.sport ? factHtml('Esporte', `🏃 ${r.sport}`) : ''}
          ${r.phrase ? `<div class="album-modal-phrase">"${r.phrase}"</div>` : ''}
          ${!r.specialty && !r.favorite_watch && !r.sport && !r.phrase ? '<p style="font-size:12px;opacity:0.5;">Essa pessoa ainda não preencheu os dados pessoais da figurinha.</p>' : ''}
        </div>
        ${isAdmin && !isMe ? renderCuratedForm(r) : ''}
        <button type="button" class="album-modal-close" data-role="modal-close">Fechar</button>
      </div>
    </div>`;

  root.querySelector('[data-role="modal-backdrop"]').addEventListener('click', (e) => {
    if (e.target === e.currentTarget) root.innerHTML = '';
  });
  root.querySelector('[data-role="modal-close"]').addEventListener('click', () => { root.innerHTML = ''; });
  wireAvatarFallbacks(root);

  if (isAdmin && !isMe) wireCuratedForm(root, container, r);
}

function modalAttrHtml(label, val) {
  return `
    <div class="album-modal-attr-row">
      <div class="album-modal-attr-top">
        <span class="album-modal-attr-name">${label}</span>
        <span style="font-size:10px;font-weight:700;color:${attrColor(val)};">${val || '—'}</span>
      </div>
      <div class="album-modal-attr-track"><div class="album-modal-attr-fill" style="width:${val}%;background:${attrColor(val)};"></div></div>
    </div>`;
}

function factHtml(label, val) {
  return `
    <div class="album-modal-fact">
      <div class="album-modal-fact-label">${label}</div>
      <div class="album-modal-fact-val">${val}</div>
    </div>`;
}

function renderCuratedForm(r) {
  return `
    <div class="album-curated-row" style="flex-direction:column; align-items:stretch;">
      <div style="font-size:9px;font-weight:700;letter-spacing:1px;text-transform:uppercase;color:rgba(255,255,255,0.35);margin-bottom:6px;">Curadoria (admin)</div>
      <div style="display:flex; gap:10px; align-items:center;">
        <input type="number" min="0" max="100" data-field="reputation" value="${r.reputation_score ?? ''}" placeholder="Reputação 0-100" style="width:120px; padding:6px; border-radius:6px; border:1px solid rgba(255,255,255,0.2); background:rgba(255,255,255,0.05); color:#fff; font-size:12px;">
        <label><input type="checkbox" data-field="top-seller" ${r.is_top_seller ? 'checked' : ''}> Ponta do Mês</label>
      </div>
      <button type="button" class="cb-editor-btn" data-role="save-curated" style="margin-top:8px; align-self:flex-start;">Salvar curadoria</button>
      <div data-role="curated-msg" style="font-size:11px; margin-top:4px;"></div>
    </div>`;
}

function wireCuratedForm(root, container, r) {
  root.querySelector('[data-role="save-curated"]').addEventListener('click', async () => {
    const msgEl = root.querySelector('[data-role="curated-msg"]');
    const reputationInput = root.querySelector('[data-field="reputation"]');
    const topSellerInput = root.querySelector('[data-field="top-seller"]');
    msgEl.textContent = 'Salvando…';
    msgEl.style.color = 'rgba(255,255,255,0.6)';
    try {
      await updateCuratedAlbumFields(r.user_id, {
        reputationScore: reputationInput.value,
        isTopSeller: topSellerInput.checked,
      });
      r.reputation_score = reputationInput.value === '' ? null : Number(reputationInput.value);
      r.is_top_seller = topSellerInput.checked;
      msgEl.textContent = 'Salvo.';
      msgEl.style.color = 'var(--acc)';
      renderGrid(container);
    } catch (err) {
      console.error('[Album] erro ao salvar curadoria:', err);
      msgEl.textContent = 'Erro: ' + err.message;
      msgEl.style.color = 'var(--g)';
    }
  });
}

function openEditMeModal(container) {
  const { profile, rows } = albumState;
  const mine = rows.find((r) => r.user_id === profile.id);
  if (!mine) return;
  const cfg = classeCfg(mine.classe);
  const root = container.querySelector('[data-role="album-modal-root"]');

  root.innerHTML = `
    <div class="album-modal-backdrop" data-role="modal-backdrop">
      <div class="album-modal" style="background:${cfg.gradiente};">
        <div class="album-modal-name" style="margin-bottom:4px;">Editar minha figurinha</div>
        <p style="text-align:center; font-size:11px; opacity:0.6; margin-bottom:14px;">Emoji, foto, frase e dados pessoais, só você edita os seus.</p>
        <form class="album-edit-form" data-role="edit-me-form">
          <input type="text" name="emoji" maxlength="4" value="${mine.emoji || ''}" placeholder="Emoji (ex: 🔥)">
          <input type="text" name="avatar_url" value="${mine.avatar_url || ''}" placeholder="URL de uma foto (opcional)">
          <input type="text" name="specialty" value="${mine.specialty || ''}" placeholder="Especialidade / ponto forte">
          <input type="text" name="favorite_watch" value="${mine.favorite_watch || ''}" placeholder="Relógio favorito">
          <input type="text" name="sport" value="${mine.sport || ''}" placeholder="Esporte que pratica">
          <textarea name="phrase" rows="2" placeholder="Frase / mantra pessoal">${mine.phrase || ''}</textarea>
          <div style="display:flex; gap:8px;">
            <button type="submit" class="cb-editor-btn">Salvar</button>
            <div data-role="edit-me-msg" style="font-size:11px; align-self:center;"></div>
          </div>
        </form>
        <button type="button" class="album-modal-close" data-role="modal-close">Fechar</button>
      </div>
    </div>`;

  root.querySelector('[data-role="modal-backdrop"]').addEventListener('click', (e) => {
    if (e.target === e.currentTarget) root.innerHTML = '';
  });
  root.querySelector('[data-role="modal-close"]').addEventListener('click', () => { root.innerHTML = ''; });

  root.querySelector('[data-role="edit-me-form"]').addEventListener('submit', async (e) => {
    e.preventDefault();
    const msgEl = root.querySelector('[data-role="edit-me-msg"]');
    const fd = new FormData(e.target);
    msgEl.textContent = 'Salvando…';
    msgEl.style.color = 'rgba(255,255,255,0.6)';
    try {
      const updates = {
        emoji: fd.get('emoji').trim(),
        avatarUrl: fd.get('avatar_url').trim(),
        specialty: fd.get('specialty').trim(),
        favoriteWatch: fd.get('favorite_watch').trim(),
        sport: fd.get('sport').trim(),
        phrase: fd.get('phrase').trim(),
      };
      await updateMyAlbumProfile(profile.id, updates);
      Object.assign(mine, {
        emoji: updates.emoji || null,
        avatar_url: updates.avatarUrl || null,
        specialty: updates.specialty || null,
        favorite_watch: updates.favoriteWatch || null,
        sport: updates.sport || null,
        phrase: updates.phrase || null,
      });
      msgEl.textContent = 'Salvo!';
      msgEl.style.color = 'var(--acc)';
      renderGrid(container);
    } catch (err) {
      console.error('[Album] erro ao salvar meu perfil:', err);
      msgEl.textContent = 'Erro: ' + err.message;
      msgEl.style.color = 'var(--g)';
    }
  });
}
