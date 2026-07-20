// src/components/GpsTrail.js
// Renderiza a trilha (zonas + checkpoints) a partir de dados reais do
// trilhaService. Extraído de src/pages/formacao.js (Sprint 1) para ser
// reutilizável tanto na página "Minha Trilha" quanto no resumo do Dashboard.
// Não toca em fetch — recebe os dados já carregados e emite um evento de
// clique por delegação (sem handlers inline em window, ao contrário da versão anterior).
//
// Redesign 2026-07-10: cada zona virou uma fileira horizontal de cards
// 16:9 (.media-card, ver cards.css) em vez de lista vertical de linhas.
// A lógica de desbloqueio sequencial (done/current/locked, zone.free_order)
// e o contrato de clique (data-checkpoint-id/data-clickable) não mudaram —
// só o container visual.

import { updateQuizCover } from '../services/quizService.js';

// Ícones outline (traço simples, sem preenchimento sólido — pedido
// explícito do usuário: nada de emoji colorido nos cards do Circuito de
// Desafios). Desenhados à mão em SVG básico (círculo/path), não copiados de
// nenhuma biblioteca de ícones específica.
const SVG_ICON = {
  book: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2Z"/></svg>',
  bolt: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>',
  gamepad: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="6" width="20" height="13" rx="6.5"/><path d="M7 10v4M5 12h4"/><circle cx="15" cy="10.5" r="0.9" fill="currentColor" stroke="none"/><circle cx="17.5" cy="13" r="0.9" fill="currentColor" stroke="none"/></svg>',
  droplet: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2.69s-5.5 6.16-5.5 10a5.5 5.5 0 0 0 11 0c0-3.84-5.5-10-5.5-10Z"/></svg>',
  chat: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 11.5a8.5 8.5 0 0 1-8.5 8.5 8.4 8.4 0 0 1-4-1L3 20l1-5.5a8.5 8.5 0 1 1 17-3Z"/></svg>',
  heart: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.6l-1-1a5.5 5.5 0 0 0-7.8 7.8l1 1L12 21l7.8-7.8 1-1a5.5 5.5 0 0 0 0-7.8Z"/></svg>',
  watch: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="7"/><polyline points="12 9 12 12 13.5 13.5"/><path d="M16.51 17.35 17 21l-5-1.5L7 21l.49-3.65"/><path d="M7.49 6.65 7 3l5 1.5L17 3l-.49 3.65"/></svg>',
  shield: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z"/></svg>',
  help: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 2-3 4"/><line x1="12" y1="17.02" x2="12.01" y2="17.02"/></svg>',
  clock: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>',
  check: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>',
  lock: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>',
  flag: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 15s1-1 4-1 5 2 8 2 4 0 4-4 4-4-1-4-4V4l-2 1"/><path d="M4 4v16"/></svg>',
  compass: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"/></svg>',
  trophy: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 21h8"/><path d="M12 17v4"/><path d="M7 4h10v5a5 5 0 0 1-10 0V4Z"/><path d="M17 5h3a2 2 0 0 1-2 4h-1"/><path d="M7 5H4a2 2 0 0 0 2 4h1"/></svg>',
  chevron: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>',
};

// Ícone por tópico (heurística de palavra-chave no título do quiz — não há
// campo de categoria/tópico estruturado no schema hoje). Sem match, cai no
// ícone genérico de quiz ("help").
const TOPIC_ICON_RULES = [
  { test: /ipx|resist[êe]ncia.*[áa]gua|imperme[áa]v/i, icon: 'droplet' },
  { test: /atendimento|script/i, icon: 'chat' },
  { test: /card[íi]ac|hrm|cinta/i, icon: 'heart' },
  { test: /instinct|rel[óo]gio/i, icon: 'watch' },
];

function iconKeyFor(cp) {
  if (cp.checkpoint_type === 'module') return 'book';
  if (cp.checkpoint_type === 'game') return 'gamepad';
  const rule = TOPIC_ICON_RULES.find((r) => r.test.test(cp.title || ''));
  return rule?.icon || 'help';
}

// Variantes de gradiente escuro dentro da mesma família de cor por tipo —
// só pra reduzir a sensação de "template repetido" quando vários quizzes
// aparecem lado a lado, sem perder a identidade visual do tipo (todo quiz
// continua na família vinho, por exemplo). Escolhida de forma determinística
// (hash simples do id do checkpoint), não aleatória a cada render.
const GRADIENT_VARIANTS = {
  module: ['linear-gradient(135deg, #1e293b, #0f172a)', 'linear-gradient(135deg, #23304a, #111a2e)'],
  quiz: ['linear-gradient(135deg, #4a1420, #1c0509)', 'linear-gradient(135deg, #5c0d2c, #2c0416)', 'linear-gradient(135deg, #4f1224, #2e0512)'],
  game: ['linear-gradient(135deg, #3b1e5e, #1a0d2e)', 'linear-gradient(135deg, #4a1e42, #200d1c)'],
};

function hashString(str) {
  let h = 0;
  for (let i = 0; i < str.length; i++) h = (h * 31 + str.charCodeAt(i)) >>> 0;
  return h;
}

function gradientFor(cp) {
  const variants = GRADIENT_VARIANTS[cp.checkpoint_type] || GRADIENT_VARIANTS.quiz;
  return variants[hashString(cp.id) % variants.length];
}

const STATUS_LABEL = { done: '✓ Concluído', current: 'Em andamento', available: 'Disponível', locked: 'Bloqueado' };
const STATUS_BADGE_ICON = { done: 'check', current: 'clock', available: 'clock', locked: 'lock' };
const STATUS_BADGE_TEXT = { done: 'Feito', current: 'Atual', available: 'Disponível', locked: 'Bloqueado' };

// Seletor de nível (pedido do usuário) — reaproveita zonas REAIS que já
// existem no banco, sem inventar conteúdo novo: zonas cujo nome é
// "<Nome base>" e "<Nome base> · Nível N" viram um único card com pills de
// nível em vez de duas fileiras empilhadas. Hoje só existe esse par
// ("Circuito de Desafios" / "Circuito de Desafios · Nível 2"), mas a regra
// é genérica — funciona pra quantos níveis existirem no futuro.
const LEVEL_STORAGE_PREFIX = 'gth-desafio-nivel-';

function baseNameAndLevel(zoneName) {
  const match = zoneName.match(/^(.*?)\s*[·:]\s*n[íi]vel\s*(\d+)\s*$/i);
  return match ? { baseName: match[1].trim(), level: parseInt(match[2], 10) } : { baseName: zoneName, level: 1 };
}

function groupZonesByChallenge(zones) {
  const groups = new Map();
  zones.forEach((zone) => {
    const { baseName, level } = baseNameAndLevel(zone.name);
    if (!groups.has(baseName)) groups.set(baseName, []);
    groups.get(baseName).push({ level, zone });
  });
  groups.forEach((entries) => entries.sort((a, b) => a.level - b.level));
  return groups;
}

function slugify(text) {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9]+/g, '-');
}

function readSelectedLevel(baseName, maxLevel) {
  try {
    const n = parseInt(localStorage.getItem(LEVEL_STORAGE_PREFIX + slugify(baseName)), 10);
    return n >= 1 && n <= maxLevel ? n : 1;
  } catch {
    return 1;
  }
}

function writeSelectedLevel(baseName, level) {
  try {
    localStorage.setItem(LEVEL_STORAGE_PREFIX + slugify(baseName), String(level));
  } catch {
    // localStorage indisponível (modo privado etc.) — seleção não persiste, mas continua funcionando na sessão
  }
}

/**
 * @param {HTMLElement} container
 * @param {Array} zones - [{ id, name, free_order, checkpoints: [{id, checkpoint_type, reference_id, title, is_required}] }]
 * @param {Set<string>} doneCheckpointIds
 * @param {(checkpoint: object) => void} onCheckpointClick
 * @param {Map<string, number>} [moduleProgressMap] - % de lições concluídas por module_id (mini barra nos cards de módulo)
 * @param {boolean} [isAdmin] - habilita "Editar capa" nos quizzes do Circuito de Desafios (layout de referência, 2026-07-17)
 */
export function renderGpsTrail(container, zones, doneCheckpointIds, onCheckpointClick, moduleProgressMap = new Map(), isAdmin = false) {
  const groups = groupZonesByChallenge(zones);

  container.innerHTML = [...groups.entries()].map(([baseName, entries]) => (
    entries.length > 1
      ? renderChallengeGroup(baseName, entries, doneCheckpointIds, moduleProgressMap, isAdmin)
      : renderZona(entries[0].zone, doneCheckpointIds, moduleProgressMap)
  )).join('');

  wireCardClicks(container, zones, onCheckpointClick);
  wireMediaRowCarousels(container);
  wireLevelSelectors(container, groups, doneCheckpointIds, moduleProgressMap, zones, onCheckpointClick, isAdmin);
  wireQuizCoverButtons(container, zones);
}

function wireCardClicks(scopeEl, zones, onCheckpointClick) {
  scopeEl.querySelectorAll('.media-card[data-clickable="true"], .quiz-compact-card[data-clickable="true"], .avulso-panel[data-clickable="true"]').forEach((el) => {
    el.addEventListener('click', (e) => {
      if (e.target.closest('[data-edit-quiz-cover]')) return;
      const cp = zones.flatMap((z) => z.checkpoints).find((c) => c.id === el.dataset.checkpointId);
      if (cp) onCheckpointClick(cp);
    });
  });
}

/** Admin: "Editar capa" nos cards compactos de quiz do Circuito de Desafios — mesmo padrão de arenaDesafios.js/updateQuizCover, só que reaplicado aqui (o card de imagem grande virou card numerado sem foto, mas o quiz em si continua com cover_url no banco). */
function wireQuizCoverButtons(scopeEl, zones) {
  scopeEl.querySelectorAll('[data-edit-quiz-cover]').forEach((btn) => {
    btn.addEventListener('click', async (e) => {
      e.stopPropagation();
      const quizId = btn.dataset.editQuizCover;
      const cp = zones.flatMap((z) => z.checkpoints).find((c) => c.reference_id === quizId && c.checkpoint_type === 'quiz');
      const url = window.prompt('URL da imagem de capa (16:9) — deixe em branco pra remover:', cp?.cover_url || '');
      if (url === null) return;

      try {
        await updateQuizCover(quizId, url.trim());
        if (cp) cp.cover_url = url.trim() || null;
      } catch (err) {
        console.error('[GpsTrail] erro ao salvar capa do quiz:', err);
        alert('Não foi possível salvar a capa agora.');
      }
    });
  });
}

/** Troca o nível ativo sem recarregar a página — só re-renderiza o conteúdo daquele grupo. */
function wireLevelSelectors(container, groups, doneCheckpointIds, moduleProgressMap, zones, onCheckpointClick, isAdmin) {
  container.querySelectorAll('[data-challenge-group]').forEach((groupEl) => {
    const baseName = groupEl.dataset.challengeGroup;
    const entries = groups.get(baseName);

    groupEl.querySelectorAll('[data-level]').forEach((pill) => {
      pill.addEventListener('click', () => {
        const level = Number(pill.dataset.level);
        writeSelectedLevel(baseName, level);

        groupEl.querySelectorAll('[data-level]').forEach((p) => p.classList.toggle('active', Number(p.dataset.level) === level));

        const entry = entries.find((e) => e.level === level);
        const contentEl = groupEl.querySelector('[data-role="level-content"]');
        contentEl.innerHTML = renderZonaBody(entry.zone, doneCheckpointIds, moduleProgressMap, true, isAdmin);

        wireCardClicks(contentEl, zones, onCheckpointClick);
        wireMediaRowCarousels(contentEl);
        wireQuizCoverButtons(contentEl, zones);
      });
    });
  });
}

function renderChallengeGroup(baseName, entries, doneCheckpointIds, moduleProgressMap, isAdmin) {
  const selectedLevel = readSelectedLevel(baseName, entries.length);
  const activeEntry = entries.find((e) => e.level === selectedLevel) || entries[0];
  const allFreeOrder = entries.every((e) => e.zone.free_order);

  const pillsHtml = entries.map(({ level, zone }) => {
    const isDone = zone.checkpoints.length > 0 && zone.checkpoints.every((cp) => doneCheckpointIds.has(cp.id));
    const isActive = level === activeEntry.level;
    return `
      <button type="button" class="level-pill ${isActive ? 'active' : ''}" data-level="${level}">
        Nível ${level}${isDone ? `<span class="level-pill-check">${SVG_ICON.check}</span>` : ''}
      </button>`;
  }).join('');

  return `
    <div class="media-row-group" data-challenge-group="${baseName}">
      <div class="media-row-header">
        <h3 class="media-row-title">
          <span class="media-row-title-icon">${SVG_ICON.flag}</span>
          ${baseName}${allFreeOrder ? ' <span class="tag blue">Ordem livre</span>' : ''}
        </h3>
        <div class="level-selector">${pillsHtml}</div>
      </div>
      <div data-role="level-content">${renderZonaBody(activeEntry.zone, doneCheckpointIds, moduleProgressMap, true, isAdmin)}</div>
    </div>
  `;
}

/**
 * Setas + dots de paginação por fileira (pedido do usuário: "as setas de
 * navegação estão muito discretas... considerar dots de paginação"). Só
 * rola a fileira, não interfere na lógica de bloqueio/clique dos cards.
 */
function wireMediaRowCarousels(container) {
  container.querySelectorAll('.media-row-carousel').forEach((carousel) => {
    const row = carousel.querySelector('.media-row');
    const prevBtn = carousel.querySelector('[data-row-prev]');
    const nextBtn = carousel.querySelector('[data-row-next]');
    // .media-row-dots sempre é o irmão imediato de .media-row-carousel no
    // template (rowWithCarousel) — usar nextElementSibling em vez de um
    // querySelector no pai evita pegar os dots errados quando uma zona tem
    // 2 fileiras (quiz + duelo), cada uma com seu próprio par carousel/dots.
    const dotsEl = carousel.nextElementSibling;
    const cards = row ? [...row.children] : [];
    if (!row || cards.length < 2) {
      // 0 ou 1 card: nada pra navegar, esconde os controles em vez de
      // mostrar setas/dots inúteis.
      prevBtn && (prevBtn.hidden = true);
      nextBtn && (nextBtn.hidden = true);
      if (dotsEl) dotsEl.hidden = true;
      return;
    }

    if (dotsEl) {
      dotsEl.innerHTML = cards.map((_, i) => `<button type="button" class="media-row-dot" data-dot-index="${i}" aria-label="Item ${i + 1}"></button>`).join('');
    }
    const dots = dotsEl ? [...dotsEl.children] : [];

    function updateControls() {
      const scrollLeft = row.scrollLeft;
      let closestIdx = 0;
      let closestDist = Infinity;
      cards.forEach((card, i) => {
        const dist = Math.abs(card.offsetLeft - scrollLeft);
        if (dist < closestDist) { closestDist = dist; closestIdx = i; }
      });
      dots.forEach((d, i) => d.classList.toggle('active', i === closestIdx));
      prevBtn.disabled = scrollLeft <= 4;
      nextBtn.disabled = scrollLeft >= row.scrollWidth - row.clientWidth - 4;
    }

    prevBtn?.addEventListener('click', () => row.scrollBy({ left: -(cards[0].offsetWidth + 14) * 2, behavior: 'smooth' }));
    nextBtn?.addEventListener('click', () => row.scrollBy({ left: (cards[0].offsetWidth + 14) * 2, behavior: 'smooth' }));
    dots.forEach((dot, i) => dot.addEventListener('click', () => row.scrollTo({ left: cards[i].offsetLeft, behavior: 'smooth' })));
    row.addEventListener('scroll', () => requestAnimationFrame(updateControls));

    updateControls();
  });
}

// Ícone temático por zona (mesma heurística de palavra-chave do resto do
// arquivo — não há campo de categoria estruturado pra zona no schema).
function zoneIconKey(zone) {
  if (/desafio/i.test(zone.name)) return 'flag';
  if (/explorador/i.test(zone.name)) return 'compass';
  if (/atleta|corredor|maratonista|triatleta/i.test(zone.name)) return 'watch';
  return 'flag';
}

/**
 * Página dedicada "Trilha Completa" (src/pages/trilhaCompleta.js) — cada
 * zona vira uma seção sempre aberta (sem accordion — pedido do usuário,
 * 2026-07-20: o formato anterior de caminho serpenteado com zigue-zague
 * dificultava a visão macro dos temas) com os checkpoints numa grade de
 * cards de tamanho consistente, em vez do carrossel de cards 16:9 usado no
 * resto do app. Navegação totalmente aberta: qualquer card é clicável,
 * independente do estado done/current/available/locked — o estado só
 * aparece como indicador visual (badge/ícone), não bloqueia mais o clique.
 * @param {HTMLElement} container
 * @param {Array} zones
 * @param {Set<string>} doneCheckpointIds
 * @param {(checkpoint: object) => void} onCheckpointClick
 * @param {string|null} currentZoneId - zona do próximo passo, ganha destaque visual
 */
export function renderTrilhaCompletaAccordion(container, zones, doneCheckpointIds, onCheckpointClick, currentZoneId) {
  container.innerHTML = zones.map((zone) => renderZoneSection(zone, doneCheckpointIds, zone.id === currentZoneId)).join('');
  wirePhaseCardClicks(container, zones, onCheckpointClick);
}

function renderZoneSection(zone, doneCheckpointIds, isCurrent) {
  const total = zone.checkpoints.length;
  const done = zone.checkpoints.filter((cp) => doneCheckpointIds.has(cp.id)).length;

  return `
    <div class="zone-section ${isCurrent ? 'current' : ''}" data-zone-id="${zone.id}">
      <div class="zone-section-header">
        <span class="zone-section-icon">${SVG_ICON[zoneIconKey(zone)]}</span>
        <span class="zone-section-name">${zone.name}${zone.free_order ? ' <span class="tag blue">Ordem livre</span>' : ''}</span>
        <span class="zone-section-progress">${done}/${total}</span>
      </div>
      <div class="phase-card-grid">
        ${renderPhaseCards(zone, doneCheckpointIds)}
      </div>
    </div>`;
}

function renderPhaseCards(zone, doneCheckpointIds) {
  const comEstado = statusPorCheckpoint(zone, doneCheckpointIds);
  const isMilestone = (i) => !zone.free_order && zone.checkpoints.length > 1 && i === zone.checkpoints.length - 1;

  return comEstado.map(({ cp, state }, i) => {
    const milestone = isMilestone(i);
    const iconSvg = state === 'done' ? SVG_ICON.check : (milestone ? SVG_ICON.trophy : SVG_ICON[iconKeyFor(cp)]);

    return `
      <button type="button" class="phase-card ${state}${milestone ? ' milestone' : ''}" data-checkpoint-id="${cp.id}">
        <span class="phase-card-icon">${iconSvg}</span>
        <span class="phase-card-title">${cp.title}</span>
        <span class="phase-card-status">${STATUS_LABEL[state]}</span>
      </button>`;
  }).join('');
}

function wirePhaseCardClicks(container, zones, onCheckpointClick) {
  container.querySelectorAll('.phase-card').forEach((btn) => {
    btn.addEventListener('click', () => {
      const cpId = btn.dataset.checkpointId;
      const cp = zones.flatMap((z) => z.checkpoints).find((c) => c.id === cpId);
      if (cp) onCheckpointClick(cp);
    });
  });
}

/**
 * Estado (done/current/available/locked) de cada checkpoint da zona, na
 * ordem original — compartilhado entre a fileira grande (renderZona) e a
 * trilha mini compacta (renderMiniTrilha), pra não duplicar a regra de
 * liberação sequencial em dois lugares.
 *
 * Bug real corrigido: em zonas free_order (Circuito de Desafios), TODO
 * checkpoint pendente virava "current" — badge "Atual" aparecia em vários
 * cards ao mesmo tempo, sem sentido (só devia destacar qual fazer a
 * seguir). Agora só o primeiro pendente da zona (por order_index) vira
 * "current"; os outros pendentes de uma zona free_order viram "available"
 * (desbloqueados, mas sem o destaque de "próximo passo").
 */
function statusPorCheckpoint(zone, doneCheckpointIds) {
  let jaTemPendenteAtual = false;
  return zone.checkpoints.map((cp) => {
    const isDone = doneCheckpointIds.has(cp.id);
    if (isDone) return { cp, state: 'done' };

    if (zone.free_order) {
      if (!jaTemPendenteAtual) {
        jaTemPendenteAtual = true;
        return { cp, state: 'current' };
      }
      return { cp, state: 'available' };
    }

    // zonas sequenciais liberam só o primeiro pendente
    const isCurrent = !jaTemPendenteAtual;
    if (isCurrent) jaTemPendenteAtual = true;
    return { cp, state: isCurrent ? 'current' : 'locked' };
  });
}

function renderZona(zone, doneCheckpointIds, moduleProgressMap) {
  return `
    <div class="media-row-group">
      <div class="media-row-header">
        <h3 class="media-row-title">
          ${zone.name}${zone.free_order ? ' <span class="tag blue">Ordem livre</span>' : ''}
        </h3>
      </div>
      ${renderZonaBody(zone, doneCheckpointIds, moduleProgressMap)}
    </div>
  `;
}

/** Fileiras de cards de uma zona (sem o título/wrapper) — reaproveitado tanto por uma zona solteira (renderZona) quanto pelo conteúdo trocável de um grupo de níveis (renderChallengeGroup). */
function renderZonaBody(zone, doneCheckpointIds, moduleProgressMap, compact = false, isAdmin = false) {
  // separados por tipo pra exibição (quiz numa fileira, duelo/game na de
  // baixo) depois de calculado o estado na ordem original da zona.
  const comEstado = statusPorCheckpoint(zone, doneCheckpointIds);

  const quizzesEModulos = comEstado.filter(({ cp }) => cp.checkpoint_type !== 'game');
  const duelos = comEstado.filter(({ cp }) => cp.checkpoint_type === 'game');

  // Circuito de Desafios (layout de referência, 2026-07-17): grade compacta
  // de cards numerados com trilha pontilhada + duelos em painel avulso
  // horizontal, em vez do carrossel de cards 16:9 usado no caminho
  // principal (Explorador/Atleta) — ver renderZona/renderCheckpointCard.
  if (compact) {
    return `
      ${quizzesEModulos.length ? renderCompactQuizGrid(quizzesEModulos, isAdmin) : ''}
      ${duelos.length ? `
        <div class="media-row-header">
          <h4 class="media-row-title">
            <span class="media-row-title-icon">${SVG_ICON.gamepad}</span>
            Duelos
          </h4>
        </div>
        <div class="avulso-panel-list">${duelos.map(({ cp, state }) => renderAvulsoPanel(cp, state)).join('')}</div>
      ` : ''}
    `;
  }

  const renderRow = (items) => items.map(({ cp, state }) => renderCheckpointCard(cp, state, moduleProgressMap)).join('');
  const rowWithCarousel = (items) => `
    <div class="media-row-carousel">
      <button type="button" class="media-row-arrow media-row-arrow-prev" data-row-prev aria-label="Rolar pra trás">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
      </button>
      <div class="media-row">${renderRow(items)}</div>
      <button type="button" class="media-row-arrow media-row-arrow-next" data-row-next aria-label="Rolar pra frente">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
      </button>
    </div>
    <div class="media-row-dots" data-row-dots></div>
  `;

  return `
    ${quizzesEModulos.length ? rowWithCarousel(quizzesEModulos) : ''}
    ${duelos.length ? `
      <div class="media-row-header">
        <h4 class="media-row-title">
          <span class="media-row-title-icon">${SVG_ICON.gamepad}</span>
          Duelos
        </h4>
      </div>
      ${rowWithCarousel(duelos)}
    ` : ''}
  `;
}

const COMPACT_STATUS_LABEL = { done: 'Concluído ✓', current: 'Comece agora', available: 'Disponível', locked: 'Bloqueado' };

/** Grade de cards numerados com trilha pontilhada conectando-os (layout de referência). */
function renderCompactQuizGrid(items, isAdmin) {
  const cardsHtml = items.map(({ cp, state }, i) => {
    const clickable = state !== 'locked';
    const meta = cp.question_count ? `${cp.question_count} pergunta${cp.question_count === 1 ? '' : 's'}` : '';
    return `
      <div class="quiz-compact-card ${state}" data-checkpoint-id="${cp.id}" data-clickable="${clickable}">
        ${cp.checkpoint_type === 'quiz' && isAdmin ? `<button type="button" class="quiz-compact-edit-btn" data-edit-quiz-cover="${cp.reference_id}" aria-label="Editar capa">✎</button>` : ''}
        <span class="quiz-compact-num">${state === 'done' ? SVG_ICON.check : String(i + 1).padStart(2, '0')}</span>
        <div class="quiz-compact-name">${cp.title}</div>
        ${meta ? `<span class="quiz-compact-tag">${meta}</span>` : ''}
        <span class="quiz-compact-status">${COMPACT_STATUS_LABEL[state]}</span>
      </div>`;
  }).join('');

  return `
    <div class="quiz-trail-track">
      <div class="quiz-trail-line"></div>
      <div class="quiz-trail-grid">${cardsHtml}</div>
    </div>
  `;
}

/** Painel horizontal único (ícone + texto + ação) pra desafios avulsos (duelos) — não entram na trilha principal, então não competem visualmente com o Circuito de Desafios. */
function renderAvulsoPanel(cp, state) {
  const clickable = state !== 'locked';
  const btnLabel = state === 'done' ? 'Concluído — revisar' : state === 'locked' ? 'Bloqueado' : 'Jogar duelo →';

  return `
    <div class="avulso-panel ${state}" data-checkpoint-id="${cp.id}" data-clickable="${clickable}">
      <span class="avulso-icon">${SVG_ICON.gamepad}</span>
      <div class="avulso-body">
        <h3>${cp.title}</h3>
        <p>Desafio avulso, não entra na trilha principal</p>
      </div>
      <button type="button" class="avulso-cta" ${clickable ? '' : 'disabled'}>${btnLabel}</button>
    </div>`;
}

function renderCheckpointCard(cp, state, moduleProgressMap) {
  const clickable = state !== 'locked';
  const type = cp.checkpoint_type;
  const pct = type === 'module' ? moduleProgressMap.get(cp.reference_id) : undefined;
  const meta = type === 'quiz' && cp.question_count ? `${cp.question_count} perguntas · ` : '';

  return `
    <div class="media-card ${state}" data-checkpoint-id="${cp.id}" data-clickable="${clickable}">
      <div class="media-card-thumb media-card-thumb-${type}" ${cp.cover_url ? '' : `style="background:${gradientFor(cp)}"`}>
        ${cp.cover_url ? `<img src="${cp.cover_url}" alt="">` : `<span class="media-card-thumb-icon">${SVG_ICON[iconKeyFor(cp)]}</span>`}
        <span class="media-card-status-badge ${state}"><span class="media-card-status-badge-icon">${SVG_ICON[STATUS_BADGE_ICON[state]]}</span>${STATUS_BADGE_TEXT[state]}</span>
      </div>
      ${Number.isFinite(pct) ? `
        <div class="media-card-progress-track"><div class="media-card-progress-fill" style="width:${pct}%"></div></div>
      ` : ''}
      <div class="media-card-body">
        <div class="media-card-title">${cp.title}</div>
        <div class="media-card-meta">${meta}${STATUS_LABEL[state]}</div>
      </div>
    </div>`;
}

/** Calcula percentual concluído para o HUD (usado pelo Dashboard e por Minha Trilha). */
export function calcularProgresso(zones, doneCheckpointIds) {
  const total = zones.reduce((acc, z) => acc + z.checkpoints.length, 0);
  const done = zones.reduce(
    (acc, z) => acc + z.checkpoints.filter((c) => doneCheckpointIds.has(c.id)).length,
    0
  );
  return { total, done, pct: total ? Math.round((done / total) * 100) : 0 };
}

/** Primeiro checkpoint pendente da trilha inteira — "continuar de onde parei". */
export function proximoCheckpoint(zones, doneCheckpointIds) {
  for (const zone of zones) {
    for (const cp of zone.checkpoints) {
      if (!doneCheckpointIds.has(cp.id)) return { zone, checkpoint: cp };
    }
  }
  return null;
}

export function renderHud(container, { total, done, pct }) {
  const pctEl = container.querySelector('[data-hud="percent"]');
  const cpEl = container.querySelector('[data-hud="checkpoints"]');
  const barEl = container.querySelector('[data-hud="bar"]');

  if (pctEl) pctEl.innerHTML = `${pct}<span class="unit">%</span>`;
  if (cpEl) cpEl.innerHTML = `${done}<span class="unit">/${total}</span>`;
  if (barEl) setTimeout(() => { barEl.style.width = `${pct}%`; }, 100);
}
