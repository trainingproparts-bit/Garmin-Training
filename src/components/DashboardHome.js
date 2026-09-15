// src/components/DashboardHome.js
// Dashboard real por marca — substitui os dois caminhos concorrentes que
// existiam antes desta sprint (o painel hardcoded dentro de appShell.js e
// a função renderizarDashboardInterno() de home.js, que reescrevia <main>
// inteiro por conta própria). Um único componente, alimentado só por dados
// reais do Supabase; onde ainda não há dado real (ranking, álbum — ver
// relatório de auditoria: gamificação social não implementada), mostra um
// estado vazio honesto em vez de nomes/números inventados.

import { calcularProgresso, proximoCheckpoint, renderHud } from './GpsTrail.js';
import {
  fetchRecentActivity,
  fetchActivityById,
  subscribeToActivityFeed,
  unsubscribeFromActivityFeed,
} from '../services/activityFeedService.js';
import { CATEGORIES, fetchContentByCategory, updateContentItem } from '../services/contentLibraryService.js';
import { updateTrailCover } from '../services/trilhaService.js';
import { fetchMyStreak } from '../services/streakService.js';
import { fetchTeamAlbum } from '../services/teamAlbumService.js';
import { fetchAvaliacoesGoogleDoMes } from '../services/avaliacoesGoogleService.js';
import { fetchReviewStats } from '../services/revisaoService.js';
import { getCurrentProfile, isAdminProfile } from '../config/supabase.js';
import { navigateToPanel } from '../router.js';
import { openImageEditModal } from './ImageEditModal.js';
import { icon } from './icons.js';

// Canal Realtime do Mural — precisa ser cancelado antes de assinar de novo,
// senão cada vez que o Dashboard Principal renderiza (ex.: voltar da trilha)
// empilha um listener novo ouvindo o mesmo INSERT várias vezes.
let activityFeedChannel = null;

/** Saudação pelo horário do acesso — só client-side (hora local do navegador), sem timezone de servidor envolvido. */
function saudacaoPorHorario() {
  const hora = new Date().getHours();
  if (hora < 12) return 'Bom dia';
  if (hora < 18) return 'Boa tarde';
  return 'Boa noite';
}

const BOLT_ICON = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>';

/**
 * Rótulo de zona pro eyebrow/checkpoint-row do Hero (layout de referência
 * anexado pelo usuário, 2026-07-17: gps-carreira-redesign.html). "Zona
 * Corredor" já virou "Atleta" na exibição desde sql/038/041 (rebranding só
 * visual, o slug/nome no banco continua "Corredor") — reaproveita o mesmo
 * mapeamento aqui pra não divergir do que o Líder já vê em v_lider_zona_atual.
 */
const ZONE_DISPLAY_LABEL = { 'Zona Corredor': 'Atleta', 'Zona Atleta': 'Atleta' };
function zoneLabel(zoneName) {
  return ZONE_DISPLAY_LABEL[zoneName] || zoneName.replace(/^Zona\s+/i, '');
}

/**
 * Estado (done/current/locked) de cada zona do caminho principal (não inclui
 * zonas free_order, ex. Circuito de Desafios), pro checkpoint-row do Hero.
 * As zonas futuras (Maratonista/Triatleta/Aventureiro) já existem como linha
 * real em `zones` (só sem checkpoints ainda) — não precisa de placeholder
 * estático, o cálculo abaixo já as mostra "bloqueadas" naturalmente (total=0
 * checkpoints nunca fecha "done", e current já foi atribuído a uma zona
 * anterior com conteúdo).
 */
function heroZoneStatus(zones, doneCheckpointIds) {
  const mainZones = [...zones]
    .filter((z) => !z.free_order)
    .sort((a, b) => a.order_index - b.order_index);

  let currentAssigned = false;
  return mainZones.map((zone) => {
    const total = zone.checkpoints.length;
    const done = zone.checkpoints.filter((cp) => doneCheckpointIds.has(cp.id)).length;
    const isDone = total > 0 && done === total;
    let state = 'locked';
    if (isDone) state = 'done';
    else if (!currentAssigned) { state = 'current'; currentAssigned = true; }
    return { label: zoneLabel(zone.name), state };
  });
}

/**
 * @param {HTMLElement} container
 * @param {{brandName: string, userName: string, trail: object, zones: Array, doneCheckpointIds: Set<string>, moduleProgressMap?: Map<string,number>}} data
 * @param {(checkpoint: object) => void} onCheckpointClick
 */
export async function renderDashboardHome(container, data, onCheckpointClick) {
  const { brandName, userName, userId, trail, zones, doneCheckpointIds, moduleProgressMap, isAdmin } = data;
  const progresso = calcularProgresso(zones, doneCheckpointIds);
  const proximo = proximoCheckpoint(zones, doneCheckpointIds);
  const coverUrl = trail?.cover_url;

  // Zona do próximo passo (eyebrow) — quando a trilha inteira já terminou,
  // usa a última zona do caminho principal como referência.
  const zonaAtualNome = proximo ? proximo.zone.name : [...zones].filter((z) => !z.free_order).sort((a, b) => b.order_index - a.order_index)[0]?.name;
  const zonaAtualLabel = zonaAtualNome ? zoneLabel(zonaAtualNome) : '';

  const zonaRestantes = proximo ? proximo.zone.checkpoints.filter((cp) => !doneCheckpointIds.has(cp.id)).length : 0;
  const heroTitle = proximo ? proximo.checkpoint.title : 'Trilha concluída! 🏁';
  const heroDesc = proximo
    ? `Faltam ${zonaRestantes} checkpoint${zonaRestantes === 1 ? '' : 's'} para concluir esta zona.`
    : 'Confira suas certificações.';

  const checkpointRowHtml = heroZoneStatus(zones, doneCheckpointIds).map(({ label, state }) => `
    <div class="dash-hero-checkpoint">
      <span class="dash-hero-checkpoint-dot ${state}"></span>
      ${label}
    </div>`).join('');

  container.innerHTML = `
    <div class="dash-welcome-row">
      <div class="dash-welcome-text">
        <h2 class="dash-welcome-title">${saudacaoPorHorario()}, ${userName}!</h2>
        <p class="dash-welcome-sub">Bem-vindo(a) ao ${brandName} <span class="dash-highlight">Training<span class="dash-highlight-icon">${BOLT_ICON}</span></span> · aprendizado contínuo, resultado que se destaca.</p>
      </div>
      <div class="dash-welcome-context" data-role="streak-pill"></div>
    </div>

    <div class="dash-main-grid">
      <div class="dash-trail-card ${coverUrl ? 'has-cover' : ''}" ${coverUrl ? `style="background-image:url('${coverUrl}')"` : ''}>
        <div class="dash-trail-top">
          <span class="dash-hero-eyebrow">Trilha atual${zonaAtualLabel ? ` · Zona ${zonaAtualLabel}` : ''}</span>
          ${isAdmin ? '<button type="button" class="dash-trail-edit-cover-btn" data-edit-trail-cover>Editar capa</button>' : ''}
        </div>

        <h1 class="dash-trail-title">${heroTitle}</h1>
        <p class="dash-trail-sub">${heroDesc}</p>

        <div class="dash-hero-row">
          ${proximo ? '<button type="button" class="dash-btn-continue" data-role="continuar">Continuar treinamento ➔</button>' : ''}
          <div class="dash-hero-progress">
            <span class="dash-hero-progress-label">Progresso da trilha</span>
            <span class="dash-hero-progress-value">${progresso.pct}% · <span data-hud="checkpoints">${progresso.done}<span class="unit">/${progresso.total}</span></span> checkpoints</span>
          </div>
        </div>

        <div class="dash-hero-checkpoint-row">${checkpointRowHtml}</div>

        <button type="button" class="dash-trail-toggle-full" data-role="toggle-full-trail">Ver trilha completa →</button>
      </div>

      <div data-role="destaques-preview"></div>
      <div data-role="activity-feed"></div>
    </div>

    <div data-role="revisao-card"></div>

    <div class="dash-special-lines" data-role="special-lines"></div>
  `;

  renderHud(container, progresso);

  // Circuito de Desafios + Duelos saíram do Dashboard (pedido do usuário,
  // 2026-09-15 — "tirar a poluição do site"): já existem como página própria
  // na Arena de Desafios (src/pages/arenaDesafios.js, item da sidebar), sem
  // precisar duplicar a fileira aqui.

  // trilha inteira (todas as zonas, inclusive as escondidas da fileira
  // grande) agora é uma página própria — acordeão por zona + mapa de fases,
  // ver src/pages/trilhaCompleta.js. Não cabia mais inline no Hero Card.
  container.querySelector('[data-role="toggle-full-trail"]')?.addEventListener('click', () => {
    navigateToPanel('trilha-completa');
  });

  container.querySelector('[data-role="continuar"]')?.addEventListener('click', () => {
    if (proximo) onCheckpointClick(proximo.checkpoint);
  });

  container.querySelector('[data-edit-trail-cover]')?.addEventListener('click', () => {
    openImageEditModal({
      title: 'Capa da trilha',
      currentUrl: coverUrl || '',
      folder: 'covers/trilhas',
      onSave: async (url) => {
        await updateTrailCover(trail.id, url || '');
        trail.cover_url = url;
        renderDashboardHome(container, data, onCheckpointClick);
      },
    });
  });

  renderDestaquesPreview(container.querySelector('[data-role="destaques-preview"]'));
  renderActivityFeed(container.querySelector('[data-role="activity-feed"]'));
  renderRevisaoCard(container.querySelector('[data-role="revisao-card"]'));
  renderSpecialLines(container.querySelector('[data-role="special-lines"]'));
  renderStreakPill(container.querySelector('[data-role="streak-pill"]'), userId);
}

/**
 * Card "🎲 Revisão Inteligente" — terceiro domínio da plataforma (sql/066/067),
 * um botão só ("Revisar Agora") que já leva pro seletor de modo
 * (revisao-inteligente), sem escolher assunto nenhum aqui na Home.
 *
 * available_count (fn_review_stats) é o tamanho do BANCO inteiro ainda fora
 * de cooldown, não uma fila do dia — pra uma plataforma com mais de mil
 * itens publicados, isso já passou de 1000 e virava "Você possui 1117
 * conteúdos para revisar, tempo estimado: 745 min" (relato do usuário: "fica
 * assustador"). Nenhuma sessão real passa de 20 itens (fn_start_review_session),
 * então o card agora fala da PRÓXIMA sessão (8 a 20 perguntas, poucos
 * minutos), não do total do banco — o número grande nunca aparece aqui.
 */
const SECONDS_PER_ITEM_ESTIMATE = 40;
const MIN_SESSION_ITEMS = 8;
const MAX_SESSION_ITEMS = 20;

function formatLastReview(iso) {
  if (!iso) return 'Ainda não revisou';
  const days = Math.floor((Date.now() - new Date(iso).getTime()) / 86400000);
  if (days <= 0) return 'Hoje';
  if (days === 1) return 'Ontem';
  return `há ${days} dias`;
}

async function renderRevisaoCard(container) {
  if (!container) return;

  const brandId = window.selectedBrandId;
  if (!brandId) return;

  try {
    const stats = await fetchReviewStats(brandId);
    if (!stats.available_count) {
      container.innerHTML = `
        <div class="dash-revisao-card">
          <div class="dash-revisao-card-text">
            <span class="dash-mini-tag">🎲 Revisão Inteligente</span>
            <p class="dash-revisao-count">Tudo em dia por agora, volte depois pra mais uma rodada.</p>
          </div>
        </div>`;
      return;
    }

    const minMin = Math.round((MIN_SESSION_ITEMS * SECONDS_PER_ITEM_ESTIMATE) / 60);
    const maxMin = Math.round((MAX_SESSION_ITEMS * SECONDS_PER_ITEM_ESTIMATE) / 60);

    container.innerHTML = `
      <div class="dash-revisao-card">
        <div class="dash-revisao-card-text">
          <span class="dash-mini-tag">🎲 Revisão Inteligente</span>
          <p class="dash-revisao-count">Pratique um pouco agora, sessões curtas de ${MIN_SESSION_ITEMS} a ${MAX_SESSION_ITEMS} perguntas</p>
          <div class="dash-revisao-meta">
            <span>Última revisão: <strong>${formatLastReview(stats.last_session_at)}</strong></span>
            <span>Duração: <strong>${minMin} a ${maxMin} min</strong></span>
          </div>
        </div>
        <button type="button" class="dash-revisao-btn" data-role="revisar-agora">Revisar Agora →</button>
      </div>`;

    container.querySelector('[data-role="revisar-agora"]').addEventListener('click', () => navigateToPanel('revisao-inteligente'));
  } catch (err) {
    console.error('[DashboardHome] erro ao carregar Revisão Inteligente:', err);
    container.innerHTML = '';
  }
}

/**
 * Sequência de dias consecutivos de estudo (RN §6.5, sql/033). Lê de
 * v_streaks_effective — já vem "morto" (0) se o usuário passou do dia útil
 * de tolerância sem estudar, mesmo que a engine reativa ainda não tenha
 * corrido de novo pra ele. Sem streak (nunca estudou, ou streak zerado) não
 * mostra nada — não é um estado de erro, é só ausência de dado.
 */
async function renderStreakPill(container, userId) {
  if (!container || !userId) return;

  try {
    const streak = await fetchMyStreak(userId);
    const dias = streak?.current_streak_days_effective || 0;
    if (dias < 2) return; // só vale destacar a partir de 2 dias seguidos

    container.innerHTML = `<span class="dash-pill dash-pill-streak" title="Recorde: ${streak.longest_streak_days} dias">🔥 ${dias} dias seguidos</span>`;
  } catch (err) {
    console.error('[DashboardHome] erro ao carregar streak:', err);
  }
}

/**
 * Destaques do Mês — preview compacto no Dashboard Principal (visível pra
 * todo mundo, não só líder/admin). "Ponta do Mês" por loja reaproveita o
 * que o admin já cura no Álbum da Equipe (sql/037: profiles.is_top_seller).
 * "Melhor reputação" NÃO usa mais profiles.reputation_score — esse campo é
 * um número único sem data nenhuma por trás, então não dava pra saber se
 * refletia o mês corrente ou o histórico inteiro (bug reportado pelo
 * usuário). Passa a contar avaliações Google reais com data dentro do mês
 * corrente (sql/046_avaliacoes_google.sql, registradas manualmente pelo
 * admin) — mesmo critério de recorte mensal já usado em "Ponta do Mês".
 */
const DESTAQUE_STORES = ['Moema', 'Morumbi'];
const SEM_DESTAQUE_MES = 'Ainda sem destaque este mês';

// Ícones outline (mesmo padrão do resto do hub — traço simples, sem
// preenchimento sólido): troféu pro critério "Ponta do Mês", estrela pro
// critério "Melhor reputação" — a cor por trás de cada ícone (CSS) indica a
// loja nas duas linhas de troféu.
const TROPHY_ICON = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 21h8"/><path d="M12 17v4"/><path d="M7 4h10v5a5 5 0 0 1-10 0V4Z"/><path d="M17 5h3a2 2 0 0 1-2 4h-1"/><path d="M7 5H4a2 2 0 0 0 2 4h1"/></svg>';
const STAR_ICON = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>';

/** Iniciais (até 2 letras) pro avatar circular — só quando há gente real no destaque, senão mostra um traço neutro em vez de gerar iniciais erradas a partir do texto "Ainda sem destaque". */
function initialsFor(name) {
  const parts = (name || '').trim().split(/\s+/).filter(Boolean);
  if (!parts.length) return '–';
  const first = parts[0][0];
  const last = parts.length > 1 ? parts[parts.length - 1][0] : '';
  return (first + last).toUpperCase();
}

/**
 * Linha numerada + avatar com iniciais + nome/critério + selo à direita
 * (layout de referência anexado pelo usuário, 2026-07-17:
 * gps-carreira-redesign.html, .rank-item) — substitui os cards tingidos por
 * fundo/borda de antes por uma lista com divisor fino, igual ao arquivo
 * original. Sem "98%" fabricado (não existe essa métrica no nosso modelo de
 * dados) — o selo à direita reaproveita o mesmo ícone outline de antes
 * (troféu/estrela) em vez de inventar um número.
 */
function destaqueRowHtml({ pos, hasData, avatarUrl, avatarClass, iconSvg, iconClass, name, subtitle }) {
  // Sem onerror inline (mesmo motivo do avatarHtml de album.js) — quando a
  // foto existe, o fallback pras iniciais é resolvido depois de inserir no
  // DOM via data-avatar-pos, ver wireDestaqueAvatarFallbacks.
  const avatarInner = avatarUrl
    ? `<img src="${avatarUrl}" alt="" class="destaque-preview-avatar-img" data-avatar-pos="${pos}">`
    : (hasData ? initialsFor(name) : '–');
  return `
    <div class="destaque-preview-row">
      <span class="destaque-preview-pos">${String(pos).padStart(2, '0')}</span>
      <div class="destaque-preview-avatar ${avatarClass}">${avatarInner}</div>
      <div class="destaque-preview-text">
        <span class="destaque-preview-name">${name}</span>
        <span class="destaque-preview-sub">${subtitle}</span>
      </div>
      <span class="destaque-preview-badge ${iconClass}">${iconSvg}</span>
    </div>`;
}

function wireDestaqueAvatarFallbacks(container, fallbackByPos) {
  container.querySelectorAll('[data-avatar-pos]').forEach((img) => {
    const fallback = fallbackByPos.get(Number(img.dataset.avatarPos)) ?? '–';
    img.addEventListener('error', () => {
      img.replaceWith(Object.assign(document.createElement('span'), { textContent: fallback }));
    }, { once: true });
  });
}

async function renderDestaquesPreview(container) {
  if (!container) return;

  const brandId = window.selectedBrandId;
  if (!brandId) return;

  try {
    const album = await fetchTeamAlbum(brandId);

    const topSellerByStore = DESTAQUE_STORES.map((storeName) => ({
      storeName,
      member: album.find((r) => r.is_top_seller && r.store_name === storeName) || null,
    }));

    const avaliacoesMes = await fetchAvaliacoesGoogleDoMes(album.map((r) => r.user_id));
    const contagemPorPerfil = new Map();
    avaliacoesMes.forEach((a) => contagemPorPerfil.set(a.profile_id, (contagemPorPerfil.get(a.profile_id) || 0) + 1));

    let topReputation = null;
    let topReputationCount = 0;
    contagemPorPerfil.forEach((count, profileId) => {
      if (count > topReputationCount) {
        topReputationCount = count;
        topReputation = album.find((r) => r.user_id === profileId) || null;
      }
    });

    const rows = [
      ...topSellerByStore.map(({ storeName, member }, i) => destaqueRowHtml({
        pos: i + 1,
        hasData: !!member,
        avatarUrl: member?.avatar_url || null,
        avatarClass: `destaque-preview-avatar-store-${i}`,
        iconSvg: TROPHY_ICON,
        iconClass: `destaque-preview-icon-store-${i}`,
        name: member?.full_name || SEM_DESTAQUE_MES,
        subtitle: member ? `Ponta do mês · ${storeName}` : storeName,
      })),
      destaqueRowHtml({
        pos: topSellerByStore.length + 1,
        hasData: !!topReputation,
        avatarUrl: topReputation?.avatar_url || null,
        avatarClass: 'destaque-preview-avatar-star',
        iconSvg: STAR_ICON,
        iconClass: 'destaque-preview-icon-star',
        name: topReputation?.full_name || SEM_DESTAQUE_MES,
        subtitle: topReputation
          ? `Melhor reputação · ${topReputationCount} avaliaç${topReputationCount === 1 ? 'ão' : 'ões'} este mês`
          : 'Melhor reputação (Google)',
      }),
    ];

    const fallbackByPos = new Map([
      ...topSellerByStore.map(({ member }, i) => [i + 1, member ? initialsFor(member.full_name) : '–']),
      [topSellerByStore.length + 1, topReputation ? initialsFor(topReputation.full_name) : '–'],
    ]);

    container.innerHTML = `
      <div class="dash-mini-card destaques-preview-card">
        <span class="dash-mini-tag">🏆 Destaques do Mês</span>
        <div class="destaque-preview-list">${rows.join('')}</div>
      </div>`;

    wireDestaqueAvatarFallbacks(container, fallbackByPos);
  } catch (err) {
    console.error('[DashboardHome] erro ao carregar destaques do mês:', err);
    container.innerHTML = '';
  }
}

/**
 * Mural de Atividades — painel compacto no canto do Dashboard Principal
 * (RN §6.10 / modelagem §6.8). Lê o feed já escopado por marca via RLS e
 * assina Realtime pra novos cards subirem sem recarregar a página.
 */
const ACTIVITY_HEADER_ICON = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10v4a1 1 0 0 0 1 1h2l1 5h2l-1-5h1l10 4V6L9 10H4a1 1 0 0 0-1 1Z"/><path d="M15 8.5a3 3 0 0 1 0 7"/></svg>';

async function renderActivityFeed(container) {
  if (!container) return;

  unsubscribeFromActivityFeed(activityFeedChannel);
  activityFeedChannel = null;

  container.innerHTML = `
    <div class="dash-mini-card activity-feed-card">
      <span class="dash-mini-tag"><span class="activity-header-icon">${ACTIVITY_HEADER_ICON}</span>Atividades Recentes</span>
      <div class="activity-feed-list" data-role="activity-list">
        <p class="dash-empty-text">Carregando…</p>
      </div>
      <div class="activity-feed-view-all" data-role="view-all" hidden>
        <a href="#" data-role="view-all-link">Ver todas as atividades</a>
      </div>
    </div>
    <div data-role="activity-modal-root"></div>`;

  const listEl = container.querySelector('[data-role="activity-list"]');
  const viewAllEl = container.querySelector('[data-role="view-all"]');
  const viewAllLink = container.querySelector('[data-role="view-all-link"]');
  const modalRoot = container.querySelector('[data-role="activity-modal-root"]');

  try {
    const rows = await fetchRecentActivity(15);
    renderActivityList(listEl, rows, viewAllEl);
  } catch (err) {
    console.error('[DashboardHome] erro ao carregar mural:', err);
    listEl.innerHTML = '<p class="dash-empty-text">Não foi possível carregar o mural agora.</p>';
  }

  viewAllLink?.addEventListener('click', (e) => {
    e.preventDefault();
    openActivityModal(modalRoot);
  });

  activityFeedChannel = subscribeToActivityFeed(async (row) => {
    // Realtime só entrega as colunas cruas (sem o embed de subject/store),
    // então busca a linha completa de novo pra manter o destaque de nome.
    try {
      const full = await fetchActivityById(row.id);
      prependActivityItem(listEl, full, viewAllEl);
    } catch (err) {
      console.error('[DashboardHome] erro ao enriquecer atividade em tempo real:', err);
      prependActivityItem(listEl, row, viewAllEl);
    }
  });
}

/** Modal com o feed completo (RN pediu link "Ver todas" além dos 5 do card). */
async function openActivityModal(root) {
  if (!root) return;

  root.innerHTML = `
    <div class="activity-modal-backdrop" data-role="activity-modal-backdrop">
      <div class="activity-modal">
        <div class="activity-modal-head">
          <h3>Todas as atividades</h3>
          <button type="button" class="activity-modal-close" data-role="activity-modal-close">✕</button>
        </div>
        <div class="activity-modal-list" data-role="activity-modal-list">
          <p class="dash-empty-text">Carregando…</p>
        </div>
      </div>
    </div>`;

  const closeModal = () => { root.innerHTML = ''; };
  root.querySelector('[data-role="activity-modal-backdrop"]').addEventListener('click', (e) => {
    if (e.target === e.currentTarget) closeModal();
  });
  root.querySelector('[data-role="activity-modal-close"]').addEventListener('click', closeModal);

  const listEl = root.querySelector('[data-role="activity-modal-list"]');
  try {
    const rows = await fetchRecentActivity(50);
    listEl.innerHTML = rows.length
      ? rows.map((r) => activityItemHtml(r, formatRelativeTime(r.created_at))).join('')
      : '<p class="dash-empty-text">Nenhuma atividade ainda.</p>';
  } catch (err) {
    console.error('[DashboardHome] erro ao carregar todas as atividades:', err);
    listEl.innerHTML = '<p class="dash-empty-text">Não foi possível carregar agora.</p>';
  }
}

function renderActivityList(listEl, rows, viewAllEl) {
  if (!rows.length) {
    listEl.innerHTML = '<p class="dash-empty-text">Nenhuma atividade ainda, as próximas conquistas da equipe aparecem aqui.</p>';
    return;
  }

  const displayRows = rows.slice(0, 5);
  listEl.innerHTML = displayRows.map((r) => activityItemHtml(r, formatRelativeTime(r.created_at))).join('');

  if (rows.length > 5 && viewAllEl) {
    viewAllEl.hidden = false;
  }
}

/**
 * source_event sozinho não distingue "meta batida" dos demais posts
 * manuais do líder — todos gravam source_event = 'leader_manual'
 * (sql/022, fn_leader_post_activity), só o texto muda por template. Por
 * isso o tipo "meta" é detectado pelo conteúdo da mensagem, não só pelo
 * evento de origem.
 */
function getActivityType(row) {
  if (/meta batida|meta mensal|gigantes do m[eê]s/i.test(row.message || '')) return 'meta';
  if (row.source_event === 'badge_earned') return 'badge';
  if (row.source_event === 'certification_issued') return 'conquest';
  return 'default';
}

function escapeHtml(str) {
  return str.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}

/** Destaca o nome do colaborador/loja citado na mensagem (facilita leitura rápida). */
function highlightSubject(escapedMessage, row) {
  const name = row.subject?.full_name || row.store?.name;
  if (!name) return escapedMessage;

  const escapedName = escapeHtml(name);
  const idx = escapedMessage.indexOf(escapedName);
  if (idx === -1) return escapedMessage;

  return `${escapedMessage.slice(0, idx)}<strong>${escapedName}</strong>${escapedMessage.slice(idx + escapedName.length)}`;
}

function activityItemHtml(row, timeLabel) {
  const type = getActivityType(row);

  // Remove emojis duplicados do texto (o card já não tem mais ícone por
  // tipo, só o ponto colorido — layout de referência, 2026-07-17)
  const cleanedMessage = row.message
    .replace(/🔥|💪|🏆|🥂|🍾|🏃‍♂️|🚀|⛰️|✨|⌚|➕|🎯|🥇|🏅|⭐|📌/g, '')
    .trim();

  const html = highlightSubject(escapeHtml(cleanedMessage), row);

  return `
    <div class="activity-feed-item type-${type}">
      <span class="activity-feed-item-dot"></span>
      <div class="activity-feed-item-content">
        <p class="activity-feed-message">${html}</p>
        <span class="activity-feed-time">${timeLabel}</span>
      </div>
    </div>`;
}

/** Injeta o card novo no topo com animação de entrada — sem refetch da lista inteira. */
function prependActivityItem(listEl, row, viewAllEl) {
  if (!listEl) return;

  const empty = listEl.querySelector('.dash-empty-text');
  if (empty) empty.remove();

  const wrapper = document.createElement('div');
  wrapper.innerHTML = activityItemHtml(row, 'agora').trim();
  const el = wrapper.firstElementChild;
  el.classList.add('activity-feed-item-enter');
  listEl.prepend(el);

  requestAnimationFrame(() => {
    requestAnimationFrame(() => el.classList.remove('activity-feed-item-enter'));
  });

  // pilha enxuta — mantém o DOM leve, mesma filosofia de "peso zero" da tabela
  const items = listEl.querySelectorAll('.activity-feed-item');
  if (items.length > 5) items[items.length - 1].remove();

  if (items.length > 4 && viewAllEl) {
    viewAllEl.hidden = false;
  }
}

function formatRelativeTime(iso) {
  const diffMs = Date.now() - new Date(iso).getTime();
  const mins = Math.floor(diffMs / 60000);
  if (mins < 1) return 'agora';
  if (mins < 60) return `${mins} min atrás`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h atrás`;
  const days = Math.floor(hours / 24);
  return `${days}d atrás`;
}

/**
 * Linhas Especiais e Novidades — redesenhada em 2026-09-15 (pedido do
 * usuário: "não deve parecer carrossel de produtos", e sim uma biblioteca
 * de treinamentos especiais). Antes era uma fileira única com scroll
 * horizontal (.media-row, componente compartilhado com Trilha/Circuito de
 * Desafios — não mexemos nele, criamos classes próprias .special-lines-*
 * pra não afetar os outros carrosséis que reaproveitam o mesmo CSS).
 *
 * Grid sempre visível (3/2/1 colunas), agrupado em 3 blocos de leitura —
 * Novidades / Linhas Especiais / Ecossistema Garmin — derivados do próprio
 * ASSUNTO de cada artigo (ver SPECIAL_LINE_GROUPS), não um campo novo no
 * banco: os 8 artigos "deep_dive" da Biblioteca Técnica continuam sendo os
 * mesmos de sempre (sql/seeds/060/061), só reorganizados na apresentação.
 */
const SPECIAL_LINE_GROUPS = [
  { key: 'novidades', label: 'Novidades', slugs: ['novidades-2026-forerunner-70-170'] },
  {
    key: 'linhas-especiais',
    label: 'Linhas Especiais',
    slugs: [
      'inreach-comunicadores-satelite',
      'gps-de-mao-gpsmap-etrex',
      'linha-nautica-sonares-chartplotters',
      'edge-ciclocomputadores',
      'blaze-equine-wellness',
      'marq-gen-2-linha-de-luxo',
      'cirqa-monitoramento-sem-tela',
    ],
  },
  { key: 'ecossistema', label: 'Ecossistema Garmin', slugs: ['apps-integracoes-tecnologias-garmin'] },
];

/** Tag curta de assunto por card ("CATEGORIA/TEMA" do brief) — extraída do próprio título do artigo, não um dado novo. */
const SPECIAL_LINE_TAG = {
  'novidades-2026-forerunner-70-170': 'Novidades',
  'inreach-comunicadores-satelite': 'Conectividade',
  'gps-de-mao-gpsmap-etrex': 'GPS de Mão',
  'linha-nautica-sonares-chartplotters': 'Náutica',
  'edge-ciclocomputadores': 'Ciclismo',
  'blaze-equine-wellness': 'Linha Equina',
  'marq-gen-2-linha-de-luxo': 'Linha de Luxo',
  'cirqa-monitoramento-sem-tela': 'Bem-Estar',
  'apps-integracoes-tecnologias-garmin': 'Ecossistema',
};

const SPECIAL_LINE_RECENCY_DAYS = 21;

/**
 * "Novo"/"Atualizado" a partir de created_at/updated_at reais — nenhum dos
 * 8 artigos atuais foi criado/editado nos últimos 21 dias (lote original de
 * 2026-07-10, últimos ajustes em 07-28/07-30), então hoje isso não mostra
 * nada; fica pronto pra acender sozinho quando a Gestora publicar ou editar
 * algo de fato novo, sem precisar marcar manualmente.
 */
function specialLineRecencyBadge(item) {
  const dayMs = 86400000;
  const now = Date.now();
  const created = item.created_at ? new Date(item.created_at).getTime() : null;
  const updated = item.updated_at ? new Date(item.updated_at).getTime() : null;
  if (created && now - created <= SPECIAL_LINE_RECENCY_DAYS * dayMs) return 'Novo';
  if (updated && now - updated <= SPECIAL_LINE_RECENCY_DAYS * dayMs) return 'Atualizado';
  return null;
}

async function renderSpecialLines(container) {
  if (!container) return;

  const brandId = window.selectedBrandId;
  if (!brandId) return;

  try {
    const [items, profile] = await Promise.all([
      fetchContentByCategory(brandId, CATEGORIES.DEEP_DIVE),
      getCurrentProfile(),
    ]);

    if (!items.length) {
      container.innerHTML = '';
      return;
    }

    const isAdmin = isAdminProfile(profile);
    const bySlug = new Map(items.map((i) => [i.slug, i]));

    const groupsHtml = SPECIAL_LINE_GROUPS
      .map((group) => {
        const groupItems = group.slugs.map((s) => bySlug.get(s)).filter(Boolean);
        if (!groupItems.length) return '';
        return `
          <div class="special-lines-section">
            <span class="special-lines-section-label">${group.label}</span>
            <div class="special-lines-grid">
              ${groupItems.map((item) => specialLineCardHtml(item, isAdmin)).join('')}
            </div>
          </div>`;
      })
      .join('');

    container.innerHTML = `
      <div class="special-lines-group">
        <div class="special-lines-header">
          <h3 class="special-lines-title">Linhas Especiais e Novidades</h3>
          <p class="special-lines-subtitle">Conteúdos para ampliar seu conhecimento sobre o ecossistema Garmin.</p>
        </div>
        ${groupsHtml}
      </div>`;

    wireSpecialLineCards(container, items, isAdmin);
  } catch (err) {
    console.error('[DashboardHome] erro ao carregar linhas especiais:', err);
    container.innerHTML = '';
  }
}

function specialLineCardHtml(item, isAdmin) {
  const cover = item.payload?.cover_url;
  const tag = SPECIAL_LINE_TAG[item.slug] || '';
  const badge = specialLineRecencyBadge(item);
  return `
    <article class="special-line-card" data-deepdive-slug="${item.slug}" tabindex="0" role="button" aria-label="Ver treinamento: ${item.title}">
      <div class="special-line-card-media">
        ${cover ? `<img src="${cover}" alt="${item.title}" loading="lazy">` : `<span class="special-line-card-media-fallback">${icon('biblioteca')}</span>`}
        ${badge ? `<span class="special-line-card-badge">${badge}</span>` : ''}
        ${isAdmin ? `<button type="button" class="special-line-card-admin-btn" data-edit-cover-slug="${item.slug}" title="Editar capa" aria-label="Editar capa">${icon('pencil')}</button>` : ''}
      </div>
      <div class="special-line-card-body">
        ${tag ? `<span class="special-line-card-tag">${tag}</span>` : ''}
        <h4 class="special-line-card-title">${item.title}</h4>
        ${item.summary ? `<p class="special-line-card-desc">${item.summary}</p>` : ''}
        <span class="special-line-card-cta">Ver treinamento →</span>
      </div>
    </article>`;
}

function wireSpecialLineCards(container, items, isAdmin) {
  function openDeepDive(slug) {
    window.selectedDeepDiveSlug = slug;
    window.deepDiveReturnPanel = 'trilha';
    navigateToPanel('deep-dive-detail');
  }

  container.querySelectorAll('[data-deepdive-slug]').forEach((card) => {
    card.addEventListener('click', (e) => {
      if (e.target.closest('[data-edit-cover-slug]')) return;
      openDeepDive(card.dataset.deepdiveSlug);
    });
    card.addEventListener('keydown', (e) => {
      if (e.target.closest('[data-edit-cover-slug]')) return;
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        openDeepDive(card.dataset.deepdiveSlug);
      }
    });
  });

  if (!isAdmin) return;

  container.querySelectorAll('[data-edit-cover-slug]').forEach((btn) => {
    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      const slug = btn.dataset.editCoverSlug;
      const item = items.find((i) => i.slug === slug);
      const current = item.payload?.cover_url || '';

      openImageEditModal({
        title: 'Capa do artigo',
        currentUrl: current,
        folder: 'covers/biblioteca',
        onSave: async (url) => {
          await updateContentItem(item.id, { payload: { ...item.payload, cover_url: url || '' } });
          renderSpecialLines(container);
        },
      });
    });
  });
}
