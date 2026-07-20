// src/components/GameRunner.js
// Roda o minigame "Duelo de Especificações" — cada rodada compara 2 ou 3
// produtos numa categoria técnica (ex.: "Autonomia — Expedição GPS") e o
// jogador escolhe qual vence. Formato migrado fielmente do protótipo em
// sql/seeds/030_games.sql (games.config.rounds), com estes campos por rodada:
//   cat: {icone, nome, descr} · texto (pergunta) · gabarito (chave vencedora,
//   "ambos"/"todos" quando empatam, ou o "nenhum dos dois") · acerto/erro
//   (textos de feedback) · reveal: { <chave-do-contendor>: "texto comparativo" }
//
// sql/040: as opções de resposta vêm de games.config.meta.opcoes_resposta —
// não só das chaves de `reveal` (que só lista os concorrentes reais, nunca
// "ambos"/"nenhum"/"todos"). Bug real corrigido: a tela só mostrava os
// concorrentes citados em `reveal` (2-3 botões), nunca as opções de
// empate/nenhum — mesmo quando o gabarito de uma rodada era "ambos".
// O nome da chave vencedora em `gabarito` às vezes é abreviado de forma
// diferente das chaves de `reveal` (ex.: "instinct3" vs "i3") — por isso
// existe o mapa GABARITO_TO_REVEAL_KEY abaixo, usado só pra resolver o nome
// de exibição (a comparação de acerto usa o vocabulário de `gabarito`
// diretamente em ambos os lados, cliente e servidor — sql/040).
//
// Gamificação (pedido do usuário, "parece corporativo demais pra um
// joguinho de duelo"): placar ao vivo por concorrente, pulso de suspense
// antes de revelar o resultado, confete no card vencedor, shake no card
// errado, microcopy variado, barra de progresso que fica dourada perto da
// última rodada, troféu só aparece DEPOIS do resultado (ícone neutro antes).

import { startGameSession, submitGameRound, finalizeGameSession } from '../services/gameService.js';

const GABARITO_TO_REVEAL_KEY = { instinct3: 'i3', instincte: 'ie' };
const DISPLAY_NAMES = {
  i3: 'Instinct 3',
  ie: 'Instinct E',
  golfer: 'MARQ Golfer',
  athlete: 'MARQ Athlete',
  commander: 'MARQ Commander',
  fr570: 'Forerunner 570',
  fr970: 'Forerunner 970',
};

const ICON = {
  watch: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="7"/><polyline points="12 9 12 12 13.5 13.5"/><path d="M16.51 17.35 17 21l-5-1.5L7 21l.49-3.65"/><path d="M7.49 6.65 7 3l5 1.5L17 3l-.49 3.65"/></svg>',
  trophy: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 21h8"/><path d="M12 17v4"/><path d="M7 4h10v5a5 5 0 0 1-10 0V4Z"/><path d="M17 5h3a2 2 0 0 1-2 4h-1"/><path d="M7 5H4a2 2 0 0 0 2 4h1"/></svg>',
  scale: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3v18"/><path d="M7 21h10"/><path d="M3 7h2c2 0 5-1 7-2 2 1 5 2 7 2h2"/><path d="m16 16 3-8 3 8c-.87.65-1.92 1-3 1s-2.13-.35-3-1Z"/><path d="m2 16 3-8 3 8c-.87.65-1.92 1-3 1s-2.13-.35-3-1Z"/></svg>',
  xCircle: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>',
  checkCircle: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="8 12 11 15 16 9"/></svg>',
};

// Opções "coringa" que não representam um concorrente específico — nunca
// aparecem em `round.reveal`, só em `config.meta.opcoes_resposta`.
const WILDCARD_OPTIONS = {
  ambos: { label: 'Ambos iguais', icon: ICON.scale },
  todos: { label: 'Todos empatam', icon: ICON.scale },
  nenhum: { label: 'Nenhum dos dois', icon: ICON.xCircle },
};

const CORRECT_HEADLINES = ['Boa! 🎯', 'Na mosca!', 'Você manja de Garmin!', 'Isso aí!', 'Mandou bem!', 'Aí sim!'];
const INCORRECT_HEADLINES = ['Quase! 😅', 'Essa foi pegadinha', 'Não dessa vez', 'Ops, escapou essa', 'Foi por pouco'];

function randomFrom(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function displayName(key) {
  return DISPLAY_NAMES[key] || key.charAt(0).toUpperCase() + key.slice(1);
}

function optionLabel(key) {
  if (WILDCARD_OPTIONS[key]) return WILDCARD_OPTIONS[key].label;
  return displayName(GABARITO_TO_REVEAL_KEY[key] || key);
}

const CONTENDER_COLOR_CLASSES = ['duel-option-c0', 'duel-option-c1', 'duel-option-c2', 'duel-option-c3'];

export async function renderGameRunner(container, game, userId, opts = {}) {
  const rounds = game.config?.rounds || [];

  if (!rounds.length) {
    container.innerHTML = '<p class="learning-empty">Este jogo ainda não tem rodadas configuradas.</p>';
    return;
  }

  const matchupTitle = game.config?.meta?.titulo || game.title;

  // Índice de cor por concorrente FIXO (posição dele em opcoes_resposta,
  // ignorando os coringas ambos/todos/nenhum) — calculado uma vez só, pra
  // um concorrente sempre usar a mesma cor tanto no botão da rodada quanto
  // no pill do placar (antes o placar usava a ordem de inserção no Map,
  // que podia divergir se o 2º concorrente vencesse a 1ª rodada jogada).
  const allOpcoes = game.config?.meta?.opcoes_resposta || [];
  const contenderColorIndex = new Map();
  allOpcoes.filter((k) => !WILDCARD_OPTIONS[k]).forEach((k, i) => contenderColorIndex.set(k, i));

  let session;
  try {
    session = await startGameSession(userId, game.id);
  } catch (err) {
    console.error('[GameRunner] erro ao iniciar sessão:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível iniciar o jogo agora.</p>';
    return;
  }

  let index = 0;
  // Placar ao vivo — não é o placar do JOGADOR (acerto/erro), é um placar
  // meta do próprio "duelo de especificações": cada rodada elege um
  // vencedor real (round.gabarito) e o placar soma isso, reforçando a
  // mecânica de disputa entre os produtos independente de o jogador ter
  // acertado ou não. Coringas (ambos/todos/nenhum) não somam pra ninguém.
  const contenderScore = new Map();

  renderRound();

  function scoreboardHtml() {
    if (!contenderScore.size) return '';
    // ordena pela posição fixa em opcoes_resposta, não pela ordem de
    // inserção no Map (que segue a ordem em que cada um venceu a 1ª vez).
    const entries = [...contenderScore.entries()].sort(
      (a, b) => (contenderColorIndex.get(a[0]) ?? 99) - (contenderColorIndex.get(b[0]) ?? 99)
    );
    return `
      <div class="duel-scoreboard">
        ${entries.map(([key, count]) => `
          <span class="duel-scoreboard-pill ${CONTENDER_COLOR_CLASSES[contenderColorIndex.get(key)] || 'duel-option-c0'}">${displayName(GABARITO_TO_REVEAL_KEY[key] || key)}: <strong>${count}</strong></span>
        `).join('<span class="duel-scoreboard-vs">vs</span>')}
      </div>`;
  }

  function renderRound() {
    const round = rounds[index];
    const contenders = Object.keys(round.reveal || {});
    // opcoes_resposta é o conjunto real de respostas válidas (contendores +
    // coringas como "ambos"/"nenhum") — cai pra só os concorrentes se algum
    // jogo mais antigo não tiver essa lista configurada.
    const opcoes = game.config?.meta?.opcoes_resposta?.length ? game.config.meta.opcoes_resposta : contenders;

    const optionsHtml = opcoes.map((key) => {
      const wildcard = WILDCARD_OPTIONS[key];
      const colorClass = wildcard ? `duel-option-${key}` : CONTENDER_COLOR_CLASSES[contenderColorIndex.get(key)] || 'duel-option-c0';
      return `
        <button type="button" class="duel-option ${colorClass}" data-key="${key}">
          <span class="duel-option-icon" data-option-icon>${wildcard ? wildcard.icon : ICON.watch}</span>
          <span class="duel-option-label">${optionLabel(key)}</span>
        </button>`;
    }).join('');

    const pctDone = (index / rounds.length) * 100;
    const nearEnd = index >= rounds.length - 2;

    container.innerHTML = `
      <div class="game-runner">
        <div class="duel-header">
          <div class="duel-header-top">
            <span class="duel-title">${matchupTitle}</span>
            <span class="duel-round-label">Rodada ${index + 1} de ${rounds.length}</span>
          </div>
          <div class="duel-progress-track"><div class="duel-progress-fill ${nearEnd ? 'near-end' : ''}" style="width:${pctDone}%"></div></div>
        </div>

        ${scoreboardHtml()}

        <div class="duel-criteria-card">
          <span class="duel-criteria-icon">${round.cat?.icone || '⚔️'}</span>
          <div>
            <div class="duel-criteria-name">${round.cat?.nome || ''}</div>
            <div class="duel-criteria-descr">${round.cat?.descr || ''}</div>
          </div>
        </div>

        <p class="duel-question">${round.texto}</p>

        <div class="duel-options" data-role="options">${optionsHtml}</div>

        <div class="quiz-runner-feedback" data-role="feedback" hidden></div>
        <div class="game-runner-reveal" data-role="reveal" hidden></div>
        <button type="button" class="quiz-runner-next" data-role="next" hidden>
          ${index === rounds.length - 1 ? 'Ver resultado' : 'Próxima rodada →'}
        </button>
      </div>
    `;

    container.querySelectorAll('[data-key]').forEach((btn) => {
      btn.addEventListener('click', () => handleChoice(round, btn.dataset.key, btn, contenders));
    });
    container.querySelector('[data-role="next"]').addEventListener('click', handleNext);
  }

  async function handleChoice(round, chosenKey, btn, contenders) {
    if (btn.disabled) return;
    const allButtons = [...container.querySelectorAll('[data-key]')];
    allButtons.forEach((b) => (b.disabled = true));

    // pulso de suspense em todos os cards antes de revelar — dá um
    // respiro dramático em vez de resolver instantaneamente.
    allButtons.forEach((b) => b.classList.add('duel-option-pulse'));
    await new Promise((resolve) => setTimeout(resolve, 450));
    allButtons.forEach((b) => b.classList.remove('duel-option-pulse'));

    let isCorrect;
    try {
      // is_correct sempre vem do servidor (fn_submit_game_round calcula a
      // partir de games.config) — nunca confiamos no cálculo local pra
      // gravar o resultado, só o usamos como fallback visual se a RPC falhar.
      isCorrect = await submitGameRound(session.id, index, chosenKey);
    } catch (err) {
      console.error('[GameRunner] erro ao registrar rodada:', err);
      isCorrect = chosenKey === round.gabarito;
    }

    // placar meta do duelo — só concorrentes reais somam (não ambos/todos/nenhum)
    if (!WILDCARD_OPTIONS[round.gabarito]) {
      contenderScore.set(round.gabarito, (contenderScore.get(round.gabarito) || 0) + 1);
    }
    const scoreboardEl = container.querySelector('.duel-scoreboard');
    const freshScoreboard = scoreboardHtml();
    if (freshScoreboard) {
      if (scoreboardEl) scoreboardEl.outerHTML = freshScoreboard;
      else container.querySelector('.duel-progress-track').insertAdjacentHTML('afterend', freshScoreboard);
    }

    const winnerBtn = container.querySelector(`[data-key="${round.gabarito}"]`);

    btn.classList.add(isCorrect ? 'correct' : 'incorrect');
    if (isCorrect) {
      spawnConfetti(btn);
    } else {
      btn.classList.add('duel-option-shake');
      winnerBtn?.classList.add('correct');
    }
    // troféu só aparece no vencedor de verdade, depois do resultado —
    // antes disso o ícone é neutro (relógio) pros dois lados, sem entregar
    // a resposta antes da hora.
    if (winnerBtn && !WILDCARD_OPTIONS[round.gabarito]) {
      const iconEl = winnerBtn.querySelector('[data-option-icon]');
      if (iconEl) {
        iconEl.innerHTML = ICON.trophy;
        iconEl.classList.add('duel-option-icon-winner');
      }
    }

    const feedbackEl = container.querySelector('[data-role="feedback"]');
    feedbackEl.hidden = false;
    const headline = isCorrect ? randomFrom(CORRECT_HEADLINES) : randomFrom(INCORRECT_HEADLINES);
    const body = isCorrect ? round.acerto : round.erro;
    feedbackEl.innerHTML = `
      <span class="quiz-runner-feedback-icon">${isCorrect ? ICON.checkCircle : ICON.xCircle}</span>
      <span class="quiz-runner-feedback-body">
        <span class="quiz-runner-feedback-headline">${headline}</span>
        ${body ? `<span class="quiz-runner-feedback-explanation">${body}</span>` : ''}
      </span>
    `;
    feedbackEl.className = `quiz-runner-feedback ${isCorrect ? 'ok' : 'no'}`;

    const revealEl = container.querySelector('[data-role="reveal"]');
    revealEl.hidden = false;
    revealEl.innerHTML = contenders
      .map((key) => `<div class="game-runner-reveal-item"><strong>${displayName(key)}:</strong> ${round.reveal[key]}</div>`)
      .join('');

    container.querySelector('[data-role="next"]').hidden = false;
  }

  /** Confete leve (divs coloridos, sem lib nova) só no card vencedor. */
  function spawnConfetti(anchorEl) {
    const colors = ['#E4002B', '#F0A500', '#8C1F2E', '#3b82f6'];
    const burst = document.createElement('div');
    burst.className = 'duel-confetti-burst';
    for (let i = 0; i < 14; i++) {
      const piece = document.createElement('span');
      piece.className = 'duel-confetti-piece';
      piece.style.setProperty('--angle', `${(360 / 14) * i}deg`);
      piece.style.setProperty('--color', colors[i % colors.length]);
      burst.appendChild(piece);
    }
    anchorEl.appendChild(burst);
    setTimeout(() => burst.remove(), 900);
  }

  async function handleNext() {
    if (index < rounds.length - 1) {
      index += 1;
      renderRound();
      return;
    }

    container.innerHTML = '<p class="learning-loading">Calculando resultado…</p>';

    let result;
    try {
      result = await finalizeGameSession(session.id);
    } catch (err) {
      console.error('[GameRunner] erro ao salvar resultado:', err);
      container.innerHTML = '<p class="learning-error">Não foi possível calcular seu resultado agora.</p>';
      return;
    }

    renderResult(result);
  }

  function renderResult({ score, accuracy_pct, rounds_played }) {
    container.innerHTML = `
      <div class="quiz-result ${accuracy_pct >= 70 ? 'passed' : 'failed'}">
        <h3>Fim de jogo!</h3>
        <p class="quiz-result-score">${score}/${rounds_played} <span>· ${accuracy_pct}% de acerto</span></p>
        <button type="button" class="quiz-result-back" data-role="back">Voltar</button>
      </div>
    `;
    container.querySelector('[data-role="back"]').addEventListener('click', () => opts.onFinished?.());
  }
}
