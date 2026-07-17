// src/pages/arenaDesafios.js
// "Arena de Desafios" — substitui as antigas páginas separadas "Quizzes
// Extras" (quizzes.js) e "Games" (games.js), que empilhavam duas listas
// genéricas sem nenhuma relação visual entre si. Pedido do usuário: uma
// vitrine única, gamificada, com o Duelo em destaque estilo confronto "VS" e
// os quizzes com mais personalidade (badge de recompensa + barra de
// progresso real, em vez de texto simples). Fonte de dados não mudou —
// mesmos quizzes extras (checkpoints de zona free_order, via trilhaService) e
// mesmos games publicados (gameService) — só a forma de exibir.

import { getCurrentProfile, isAdminProfile } from '../config/supabase.js';
import { fetchTrilhaPublicada } from '../services/trilhaService.js';
import { fetchQuizzesByIds, updateQuizCover, fetchBestScoresByQuizIds } from '../services/quizService.js';
import { fetchPublishedGames, fetchBestScore, updateGameCover } from '../services/gameService.js';
import { navigateToPanel } from '../router.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'arena') initArenaPage();
});

// Ícones outline locais (mesmo traço simples de src/components/icons.js) —
// duplicados aqui em vez de importados porque o SVG_ICON de GpsTrail.js não
// é exportado (arquivo interno da trilha) e não vale acoplar os dois só por
// causa de 5 ícones pequenos.
const ICON = {
  droplet: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2.69s-5.5 6.16-5.5 10a5.5 5.5 0 0 0 11 0c0-3.84-5.5-10-5.5-10Z"/></svg>',
  heart: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.6l-1-1a5.5 5.5 0 0 0-7.8 7.8l1 1L12 21l7.8-7.8 1-1a5.5 5.5 0 0 0 0-7.8Z"/></svg>',
  watch: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="7"/><polyline points="12 9 12 12 13.5 13.5"/><path d="M16.51 17.35 17 21l-5-1.5L7 21l.49-3.65"/><path d="M7.49 6.65 7 3l5 1.5L17 3l-.49 3.65"/></svg>',
  chat: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 11.5a8.5 8.5 0 0 1-8.5 8.5 8.4 8.4 0 0 1-4-1L3 20l1-5.5a8.5 8.5 0 1 1 17-3Z"/></svg>',
  help: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 2-3 4"/><line x1="12" y1="17.02" x2="12.01" y2="17.02"/></svg>',
  bolt: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>',
};

// Personalidade visual por tópico do quiz — mesma heurística de palavra-chave
// já usada em GpsTrail.js (não há campo de categoria estruturado no schema).
const QUIZ_THEME_RULES = [
  { test: /ipx|resist[êe]ncia.*[áa]gua|imperme[áa]v/i, key: 'water', icon: 'droplet' },
  { test: /card[íi]ac|hrm|cinta/i, key: 'heart', icon: 'heart' },
  { test: /instinct|rel[óo]gio|watch/i, key: 'watch', icon: 'watch' },
  { test: /atendimento|script/i, key: 'chat', icon: 'chat' },
];

function quizTheme(title) {
  return QUIZ_THEME_RULES.find((r) => r.test.test(title || '')) || { key: 'default', icon: 'help' };
}

/**
 * Badge de recompensa com valor REAL (não decorativo) — reflete
 * fn_award_points_on_pass (schema base): 200 XP se o quiz tem max_attempts
 * limitado, 100 XP se ilimitado, concedido só na 1ª aprovação. Quiz com
 * tempo limite ganha o rótulo "Desafio Relâmpago" em vez do valor de XP.
 */
function quizRewardBadge(meta) {
  if (meta?.time_limit_seconds) return { icon: 'bolt', text: 'Desafio Relâmpago' };
  const xp = meta?.max_attempts ? 200 : 100;
  return { icon: null, text: `+${xp} XP` };
}

async function initArenaPage() {
  const container = document.getElementById('arenaContainer');
  if (!container) return;

  const brandId = window.selectedBrandId;
  if (!brandId) {
    container.innerHTML = '<p class="learning-error">Escolha uma marca na tela Início primeiro.</p>';
    return;
  }

  container.innerHTML = '<p class="learning-loading">Carregando a Arena de Desafios…</p>';

  try {
    const profile = await getCurrentProfile();
    const isAdmin = isAdminProfile(profile);

    const [{ zones }, games] = await Promise.all([
      fetchTrilhaPublicada(brandId),
      fetchPublishedGames(brandId),
    ]);

    // Mesmo critério de sempre: só quizzes que já são checkpoints de zona
    // free_order ("Circuito de Desafios") — quiz de zona sequencial só se
    // acessa pelo próprio checkpoint na trilha.
    const freeQuizCheckpoints = zones
      .filter((zone) => zone.free_order)
      .flatMap((zone) => zone.checkpoints.filter((cp) => cp.checkpoint_type === 'quiz'));

    if (!freeQuizCheckpoints.length && !games.length) {
      container.innerHTML = '<p class="learning-empty">Nenhum desafio disponível fora da trilha principal ainda.</p>';
      return;
    }

    const quizzesMeta = freeQuizCheckpoints.length
      ? await fetchQuizzesByIds(freeQuizCheckpoints.map((cp) => cp.reference_id))
      : [];
    const quizMetaById = new Map(quizzesMeta.map((q) => [q.id, q]));

    const [bestScoresByQuiz, bestScoresByGame] = await Promise.all([
      profile ? fetchBestScoresByQuizIds(profile.id, quizzesMeta.map((q) => q.id)) : Promise.resolve(new Map()),
      profile ? Promise.all(games.map((g) => fetchBestScore(profile.id, g.id))) : Promise.resolve(games.map(() => null)),
    ]);

    const duelRowsHtml = games.map((g, i) => renderDuelCard(g, bestScoresByGame[i], isAdmin)).join('');
    const quizRowsHtml = freeQuizCheckpoints.map((cp) => {
      const meta = quizMetaById.get(cp.reference_id);
      return renderQuizCard(cp, meta, bestScoresByQuiz.get(cp.reference_id) ?? null, isAdmin);
    }).join('');

    // Lista compacta em vez da vitrine de cards grandes de antes — pedido do
    // usuário: com muitos games/quizzes, cards grandes obrigavam scroll
    // demais pra achar um item específico. Agrupado em 2 seções (Duelos /
    // Quizzes Extras) em vez de um grid misto, pra escanear mais rápido.
    container.innerHTML = `
      <div class="arena-intro">
        <h2 class="arena-intro-title">⚡ Arena Proparts</h2>
        <p class="arena-intro-sub">Desafios rápidos da semana, teste seu conhecimento nos quizzes extras e dispute o Duelo de Especificações.</p>
      </div>
      ${games.length ? `
        <div class="arena-section">
          <h3 class="arena-section-title">⚔️ Duelos</h3>
          <div class="arena-list">${duelRowsHtml}</div>
        </div>
      ` : ''}
      ${freeQuizCheckpoints.length ? `
        <div class="arena-section">
          <h3 class="arena-section-title">📝 Quizzes Extras</h3>
          <div class="arena-list">${quizRowsHtml}</div>
        </div>
      ` : ''}
    `;

    wireQuizCards(container, profile);
    wireGameCards(container, profile);
    wireCoverEditors(container, quizMetaById, games);
  } catch (err) {
    console.error('[ArenaDesafios] erro ao carregar arena:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar a Arena de Desafios agora.</p>';
  }
}

function renderDuelCard(g, bestScore, isAdmin) {
  const meta = g.config?.meta || {};
  const is1v1 = meta.modo === 'duelo_1v1' && typeof meta.titulo === 'string' && meta.titulo.includes(' vs ');
  const totalRounds = meta.rodadas_por_partida || null;
  const pct = bestScore != null && totalRounds ? Math.round((bestScore / totalRounds) * 100) : 0;

  return `
    <div class="arena-row arena-row-duel" data-game-id="${g.id}">
      <div class="arena-row-thumb arena-row-thumb-duel">
        ${g.cover_url ? `<img src="${g.cover_url}" alt="">` : `<span class="arena-row-vs">${is1v1 ? 'VS' : '⚔️'}</span>`}
      </div>
      <div class="arena-row-body">
        <div class="arena-row-top">
          <span class="arena-row-title">${g.title}</span>
          <span class="arena-reward-pill arena-reward-pill-game">+50 XP</span>
        </div>
        <p class="arena-row-meta">${bestScore != null ? `Sua melhor pontuação: ${bestScore}${totalRounds ? `/${totalRounds}` : ''}` : 'Você ainda não jogou'}</p>
        <div class="arena-progress-track"><div class="arena-progress-fill arena-progress-fill-game" style="width:${pct}%"></div></div>
      </div>
      ${isAdmin ? `<button type="button" class="arena-edit-cover-btn" data-edit-cover-game-id="${g.id}" aria-label="Editar capa">✎</button>` : ''}
    </div>
  `;
}

function renderQuizCard(cp, meta, bestScore, isAdmin) {
  const theme = quizTheme(cp.title);
  const reward = quizRewardBadge(meta);
  const passingPct = meta?.passing_score_pct ?? 70;
  const pct = bestScore ?? 0;
  const passed = bestScore != null && bestScore >= passingPct;

  return `
    <div class="arena-row arena-row-quiz" data-quiz-id="${cp.reference_id}">
      <div class="arena-row-thumb arena-row-thumb-${theme.key}">
        ${meta?.cover_url ? `<img src="${meta.cover_url}" alt="">` : `<span class="arena-row-thumb-icon">${ICON[theme.icon]}</span>`}
        ${theme.key === 'water' ? '<span class="arena-water-waves" aria-hidden="true"></span>' : ''}
      </div>
      <div class="arena-row-body">
        <div class="arena-row-top">
          <span class="arena-row-title">${cp.title}</span>
          <span class="arena-reward-pill">${reward.icon ? `${ICON[reward.icon]} ` : ''}${reward.text}</span>
        </div>
        <p class="arena-row-meta">${meta ? `Nota mínima ${meta.passing_score_pct}%${meta.max_attempts ? ` · ${meta.max_attempts} tentativas` : ' · tentativas ilimitadas'}` : 'Quiz extra da trilha'}</p>
        <div class="arena-progress-track"><div class="arena-progress-fill ${passed ? 'is-passed' : ''}" style="width:${pct}%"></div></div>
      </div>
      <span class="arena-row-status">${bestScore != null ? `${bestScore}%` : '—'}</span>
      ${isAdmin ? `<button type="button" class="arena-edit-cover-btn" data-edit-cover-quiz-id="${cp.reference_id}" aria-label="Editar capa">✎</button>` : ''}
    </div>
  `;
}

function wireQuizCards(container, profile) {
  container.querySelectorAll('[data-quiz-id]').forEach((card) => {
    card.addEventListener('click', () => {
      if (!profile) {
        alert('Faça login para responder a este quiz.');
        return;
      }
      window.selectedQuizId = card.dataset.quizId;
      window.quizRunnerReturnPanel = 'arena';
      navigateToPanel('quiz-runner');
    });
  });
}

function wireGameCards(container, profile) {
  container.querySelectorAll('[data-game-id]').forEach((card) => {
    card.addEventListener('click', () => {
      if (!profile) {
        alert('Faça login para jogar.');
        return;
      }
      window.selectedGameId = card.dataset.gameId;
      window.gameRunnerReturnPanel = 'arena';
      navigateToPanel('game-runner');
    });
  });
}

function wireCoverEditors(container, quizMetaById, games) {
  container.querySelectorAll('[data-edit-cover-quiz-id]').forEach((btn) => {
    btn.addEventListener('click', async (e) => {
      e.stopPropagation();
      const quizId = btn.dataset.editCoverQuizId;
      const current = quizMetaById.get(quizId)?.cover_url || '';
      const url = window.prompt('URL da imagem de capa (16:9) — deixe em branco pra remover:', current);
      if (url === null) return;
      try {
        await updateQuizCover(quizId, url.trim());
        initArenaPage();
      } catch (err) {
        console.error('[ArenaDesafios] erro ao salvar capa do quiz:', err);
        alert('Não foi possível salvar a capa agora.');
      }
    });
  });

  container.querySelectorAll('[data-edit-cover-game-id]').forEach((btn) => {
    btn.addEventListener('click', async (e) => {
      e.stopPropagation();
      const gameId = btn.dataset.editCoverGameId;
      const current = games.find((g) => g.id === gameId)?.cover_url || '';
      const url = window.prompt('URL da imagem de capa (16:9) — deixe em branco pra remover:', current);
      if (url === null) return;
      try {
        await updateGameCover(gameId, url.trim());
        initArenaPage();
      } catch (err) {
        console.error('[ArenaDesafios] erro ao salvar capa do duelo:', err);
        alert('Não foi possível salvar a capa agora.');
      }
    });
  });
}
