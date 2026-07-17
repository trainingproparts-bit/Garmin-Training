// src/components/ContentBlocks.js
// Schema de blocos tipados (Fase 4 UX §6.6) — subconjunto essencial de 8
// tipos decidido com o usuário em 2026-07-10 (dos 20 documentados): banner,
// texto_rico, accordion, card, timeline, video, galeria, quiz_embutido.
// Substitui o {"html": "..."} único de lessons.body/content_library.payload
// por { blocks: [{ type, ...campos }] } — ver sql/024_lesson_content_blocks_migration.sql.
// Editor aqui é formulário estruturado por tipo (campos simples, listas
// "um item por linha"), sem drag-and-drop — isso fica para uma rodada
// futura (Painel da Gestora completo, Fase 4 §6.6).

import { navigateToPanel } from '../router.js';

export const BLOCK_TYPES = [
  { key: 'texto_rico', label: 'Texto Rico' },
  { key: 'banner', label: 'Banner' },
  { key: 'card', label: 'Card' },
  { key: 'accordion', label: 'Accordion' },
  { key: 'timeline', label: 'Timeline' },
  { key: 'video', label: 'Vídeo' },
  { key: 'galeria', label: 'Galeria' },
  { key: 'quiz_embutido', label: 'Quiz Embutido' },
  { key: 'roteiro', label: 'Roteiro de Venda' },
  { key: 'objecao', label: 'Objeção (P&R)' },
  { key: 'tabela', label: 'Tabela Comparativa' },
  { key: 'card_grid', label: 'Grade de Cards' },
  { key: 'flip_card', label: 'Card Giratório (flip)' },
  { key: 'metric_card_grid', label: 'Cards de Métrica (expansível)' },
  { key: 'match_quiz', label: 'Quiz de Associação (aquecimento)' },
];

export function defaultBlockFor(type) {
  switch (type) {
    case 'texto_rico': return { type, html: '' };
    case 'banner': return { type, tone: 'info', text: '' };
    case 'card': return { type, icon: '💡', title: '', text: '' };
    case 'accordion': return { type, items: [] };
    case 'timeline': return { type, items: [] };
    case 'video': return { type, videoUrl: '', caption: '' };
    case 'galeria': return { type, images: [] };
    case 'quiz_embutido': return { type, quizId: '', label: '' };
    case 'roteiro': return { type, steps: [] };
    case 'objecao': return { type, items: [] };
    case 'tabela': return { type, headers: [], rows: [] };
    case 'card_grid': return { type, columns: 2, items: [] };
    case 'flip_card': return { type, columns: 2, cards: [] };
    case 'metric_card_grid': return { type, columns: 2, items: [] };
    case 'match_quiz': return { type, pairs: [] };
    default: return { type };
  }
}

// ---------------------------------------------------------------------------
// Renderização (modo exibição)
// ---------------------------------------------------------------------------

export function renderBlocks(blocks) {
  if (!Array.isArray(blocks) || !blocks.length) {
    return '<p class="content-placeholder-text">Conteúdo desta aula ainda não cadastrado.</p>';
  }
  return blocks.map((block, index) => renderBlock(block, index)).join('');
}

function renderBlock(block, index) {
  switch (block.type) {
    case 'banner': return renderBannerBlock(block);
    case 'texto_rico': return renderTextoRicoBlock(block);
    case 'accordion': return renderAccordionBlock(block, index);
    case 'card': return renderCardBlock(block);
    case 'timeline': return renderTimelineBlock(block);
    case 'video': return renderVideoBlock(block);
    case 'galeria': return renderGaleriaBlock(block);
    case 'quiz_embutido': return renderQuizEmbutidoBlock(block);
    case 'roteiro': return renderRoteiroBlock(block, index);
    case 'objecao': return renderObjecaoBlock(block);
    case 'tabela': return renderTabelaBlock(block);
    case 'card_grid': return renderCardGridBlock(block);
    case 'flip_card': return renderFlipCardBlock(block);
    case 'metric_card_grid': return renderMetricCardGridBlock(block, index);
    case 'match_quiz': return renderMatchQuizBlock(block, index);
    default: return '';
  }
}

const BANNER_ICON = { info: 'ℹ️', success: '✅', warning: '⚠️' };

function renderBannerBlock(b) {
  const tone = BANNER_ICON[b.tone] ? b.tone : 'info';
  return `
    <div class="cb-banner cb-banner-${tone}">
      <span class="cb-banner-icon">${BANNER_ICON[tone]}</span>
      <p class="cb-banner-text">${b.text || ''}</p>
    </div>`;
}

function renderTextoRicoBlock(b) {
  return `<div class="content-article-body">${b.html || ''}</div>`;
}

function renderAccordionBlock(b, index) {
  const items = Array.isArray(b.items) ? b.items : [];
  return `
    <div class="cb-accordion">
      ${items.map((it, i) => `
        <div class="cb-accordion-item">
          <button type="button" class="cb-accordion-btn" data-cb-acc="cb-acc-${index}-${i}">
            <span>${it.title || ''}</span><span class="cb-accordion-chevron">▼</span>
          </button>
          <div class="cb-accordion-body" id="cb-acc-${index}-${i}" hidden>${it.html || ''}</div>
        </div>`).join('')}
    </div>`;
}

// Borda lateral colorida por card — sem campo de "tema" estruturado no
// schema, a cor é escolhida de forma determinística (hash do título/texto),
// mesmo padrão já usado pra variar o gradiente dos cards de checkpoint
// (gradientFor em GpsTrail.js): dá identidade visual sem inventar dado novo
// nem depender de conteúdo já cadastrado ter que ser reescrito.
const CARD_ACCENT_COLORS = ['var(--g)', 'var(--acc)', 'var(--gold)', '#4dabf7'];

function hashText(str) {
  let h = 0;
  for (let i = 0; i < str.length; i++) h = (h * 31 + str.charCodeAt(i)) >>> 0;
  return h;
}

function cardAccentColor(seed) {
  return CARD_ACCENT_COLORS[hashText(seed || 'card') % CARD_ACCENT_COLORS.length];
}

function renderCardBlock(b) {
  return `
    <div class="cb-card" style="border-left: 3px solid ${cardAccentColor(b.title || b.text)};">
      <span class="cb-card-icon">${b.icon || '💡'}</span>
      <h4 class="cb-card-title">${b.title || ''}</h4>
      <p class="cb-card-text">${b.text || ''}</p>
    </div>`;
}

function renderTimelineBlock(b) {
  const items = Array.isArray(b.items) ? b.items : [];
  return `
    <div class="cb-timeline">
      ${items.map((it) => `
        <div class="cb-timeline-item">
          <div class="cb-timeline-dot"></div>
          <div class="cb-timeline-content">
            <strong class="cb-timeline-label">${it.label || ''}</strong>
            <p class="cb-timeline-text">${it.text || ''}</p>
          </div>
        </div>`).join('')}
    </div>`;
}

function renderVideoBlock(b) {
  if (!b.videoUrl) return '';
  return `
    <div class="content-video-wrapper">
      <div class="content-video-container">
        <iframe src="${b.videoUrl}" class="content-video-iframe" frameborder="0" allowfullscreen></iframe>
      </div>
      ${b.caption ? `<p class="cb-video-caption">${b.caption}</p>` : ''}
    </div>`;
}

function renderGaleriaBlock(b) {
  const images = Array.isArray(b.images) ? b.images : [];
  if (!images.length) return '';
  return `
    <div class="cb-gallery">
      ${images.map((img) => `
        <figure class="cb-gallery-item">
          <img src="${img.url}" alt="${img.caption || ''}" loading="lazy">
          ${img.caption ? `<figcaption>${img.caption}</figcaption>` : ''}
        </figure>`).join('')}
    </div>`;
}

function renderQuizEmbutidoBlock(b) {
  if (!b.quizId) return '';
  return `
    <div class="cb-quiz-embed">
      <span class="cb-quiz-embed-icon">📋</span>
      <div class="cb-quiz-embed-text">${b.label || 'Praticar com um quiz rápido'}</div>
      <button type="button" class="cb-quiz-embed-btn" data-quiz-embed-id="${b.quizId}">Iniciar quiz</button>
    </div>`;
}

function renderRoteiroBlock(b) {
  const steps = Array.isArray(b.steps) ? b.steps : [];
  return `
    <div class="cb-roteiro">
      ${steps.map((s, i) => `
        <div class="cb-roteiro-step">
          <div class="cb-roteiro-num">${i + 1}</div>
          <div class="cb-roteiro-body">
            ${s.title ? `<h4 class="cb-roteiro-title">${s.title}</h4>` : ''}
            ${s.dialog ? `
              <div class="cb-roteiro-dialog">
                “${s.dialog}”
                <button type="button" class="cb-roteiro-copy-btn" data-copy-text="${encodeURIComponent(s.dialog)}">📋 Copiar Argumento</button>
              </div>` : ''}
            ${s.tip ? `<div class="cb-roteiro-tip"><span>💡</span><span>${s.tip}</span></div>` : ''}
          </div>
        </div>`).join('')}
    </div>`;
}

function renderObjecaoBlock(b) {
  const items = Array.isArray(b.items) ? b.items : [];
  return `
    <div class="cb-objecao">
      ${items.map((it) => `
        <div class="cb-objecao-item">
          <p class="cb-objecao-q"><span>🗣️</span><span>${it.question || ''}</span></p>
          <p class="cb-objecao-a"><span>✅</span><span>${it.answer || ''}</span></p>
        </div>`).join('')}
    </div>`;
}

// Marca ✓/✗ literais (comparativos de produto/comparativos com concorrente)
// com spans coloridos — verde pro check, vermelho pro x — pra facilitar a
// leitura visual em qualquer bloco comparativo (card_grid, tabela), sem
// precisar reescrever o conteúdo de cada artigo já cadastrado.
function colorizeCheckmarks(text) {
  if (!text) return text;
  return String(text)
    .replace(/✓/g, '<span class="cb-check">✓</span>')
    .replace(/✗/g, '<span class="cb-x">✗</span>');
}

// "colorful" é opt-in (só o Dicionário Rápido do Módulo 4 usa) pra não mudar
// o visual das tabelas comparativas já cadastradas nos artigos de Linhas
// Especiais — 1ª célula de cada linha ganha cor+borda por hash do próprio
// termo, mesma paleta/lógica de cardAccentColor já usada em card/card_grid.
function renderTabelaBlock(b) {
  const headers = Array.isArray(b.headers) ? b.headers : [];
  const rows = Array.isArray(b.rows) ? b.rows : [];
  if (!headers.length && !rows.length) return '';
  const colorful = !!b.colorful;
  return `
    <div class="cb-table-wrap">
      <table class="cb-table${colorful ? ' cb-table-colorful' : ''}">
        ${headers.length ? `<thead><tr>${headers.map((h) => `<th>${h}</th>`).join('')}</tr></thead>` : ''}
        <tbody>
          ${rows.map((row) => {
            const accent = colorful ? cardAccentColor(row[0] || '') : null;
            return `<tr>${row.map((cell, i) => `<td${colorful && i === 0 ? ` style="border-left:3px solid ${accent};color:${accent};font-weight:700;"` : ''}>${colorizeCheckmarks(cell)}</td>`).join('')}</tr>`;
          }).join('')}
        </tbody>
      </table>
    </div>`;
}

const CARD_GRID_TAG_CLASSES = ['blue', 'green', 'orange', 'gold'];

function renderCardGridBlock(b) {
  const items = Array.isArray(b.items) ? b.items : [];
  const cols = b.columns === 3 ? 3 : 2;
  return `
    <div class="cb-card-grid cols-${cols}">
      ${items.map((it) => `
        <div class="cb-card" style="border-left: 3px solid ${cardAccentColor(it.title || it.text)};">
          ${it.title ? `<h4 class="cb-card-title">${it.title}</h4>` : ''}
          ${it.text ? `<p class="cb-card-text">${colorizeCheckmarks(it.text)}</p>` : ''}
          ${Array.isArray(it.tags) && it.tags.length ? `
            <div class="cb-card-grid-tags">
              ${it.tags.map((t) => `<span class="tag ${CARD_GRID_TAG_CLASSES.includes(t.color) ? t.color : ''}">${t.label}</span>`).join('')}
            </div>` : ''}
        </div>`).join('')}
    </div>`;
}

function renderFlipCardBlock(b) {
  const cards = Array.isArray(b.cards) ? b.cards : [];
  const cols = b.columns === 3 ? 3 : 2;
  return `
    <div class="cb-flip-grid cols-${cols}">
      ${cards.map((c) => `
        <div class="cb-flip-card" data-flip-card>
          <div class="cb-flip-card-inner">
            <div class="cb-flip-face">
              ${c.emoji ? `<div class="cb-flip-emoji">${c.emoji}</div>` : ''}
              ${c.title ? `<div class="cb-flip-title">${c.title}</div>` : ''}
              ${c.subtitle ? `<div class="cb-flip-subtitle">${c.subtitle}</div>` : ''}
              <div class="cb-flip-text">${c.frontText || ''}</div>
              <div class="cb-flip-hint">👆 toque para ver mais</div>
            </div>
            <div class="cb-flip-face cb-flip-face-back">
              ${c.backLabel ? `<div class="cb-flip-back-title">${c.backLabel}</div>` : ''}
              <div class="cb-flip-text">${c.backText || ''}</div>
              <div class="cb-flip-hint">👆 toque para voltar</div>
            </div>
          </div>
        </div>`).join('')}
    </div>`;
}

// Card de métrica expansível — ícone + nome + selo opcional sempre visíveis
// (versão fechada, curta e escaneável), definição de 1-2 frases logo abaixo
// (também sempre visível), e o "toque prático" só aparece ao clicar — reusa
// o mesmo mecanismo genérico de toggle do accordion (data-cb-acc / #id +
// classe "open"), já ligado em wireBlockInteractions, sem precisar de JS novo.
function renderMetricCardGridBlock(b, index) {
  const items = Array.isArray(b.items) ? b.items : [];
  const cols = b.columns === 3 ? 3 : 2;
  return `
    <div class="cb-metric-grid cols-${cols}">
      ${items.map((it, i) => `
        <div class="cb-metric-card">
          <div class="cb-metric-card-top">
            <span class="cb-metric-icon">${it.icon || '📊'}</span>
            <span class="cb-metric-name">${it.name || ''}</span>
            ${it.badge ? `<span class="cb-metric-badge">${it.badge}</span>` : ''}
          </div>
          <p class="cb-metric-def">${it.definition || ''}</p>
          <button type="button" class="cb-metric-toggle" data-cb-acc="cb-acc-${index}-${i}">
            <span>Toque prático</span><span class="cb-accordion-chevron">▼</span>
          </button>
          <div class="cb-metric-tip" id="cb-acc-${index}-${i}" hidden>
            <span class="cb-metric-tip-icon">🎯</span>
            <p>${it.tip || ''}</p>
          </div>
        </div>`).join('')}
    </div>`;
}

// Quiz de associação por clique (aquecimento antes do quiz de múltipla
// escolha) — decisão deste arquivo desde o início é NÃO ter
// drag-and-drop (ver comentário no topo do arquivo); associação por clique
// (clica no termo, depois na definição) cumpre o mesmo objetivo pedagógico
// sem precisar da API de drag-and-drop do navegador. Estado e correção são
// só client-side, não grava tentativa nenhuma — é aquecimento, não avaliação.
function renderMatchQuizBlock(b, index) {
  const pairs = Array.isArray(b.pairs) ? b.pairs : [];
  if (!pairs.length) return '';
  const terms = pairs.map((p, i) => ({ ...p, i })).sort(() => 0.5 - Math.random());
  const defs = pairs.map((p, i) => ({ ...p, i })).sort(() => 0.5 - Math.random());
  return `
    <div class="cb-match-quiz" data-cb-match="${index}">
      <p class="cb-match-instructions">🔗 Clique em um termo e depois na definição correspondente.</p>
      <div class="cb-match-columns">
        <div class="cb-match-col" data-role="cb-match-terms">
          ${terms.map((t) => `<button type="button" class="cb-match-pill" data-match-i="${t.i}">${t.term}</button>`).join('')}
        </div>
        <div class="cb-match-col" data-role="cb-match-defs">
          ${defs.map((d) => `<button type="button" class="cb-match-pill" data-match-i="${d.i}">${d.definition}</button>`).join('')}
        </div>
      </div>
      <p class="cb-match-progress" data-role="cb-match-progress">0 de ${pairs.length} associados</p>
    </div>`;
}

/** Liga accordion e botão de quiz embutido depois do innerHTML ser inserido. */
export function wireBlockInteractions(container, { returnPanel } = {}) {
  container.querySelectorAll('[data-cb-acc]').forEach((btn) => {
    btn.addEventListener('click', () => {
      // Pega o próximo irmão em vez de buscar por #id — moduloConteudo.js
      // renderiza TODAS as lições da página juntas, e o índice do bloco
      // (usado pra montar o id) reinicia em cada lição; isso gerava ids
      // duplicados (ex.: "cb-acc-1-0" em várias lições), e querySelector('#id')
      // sempre pega a PRIMEIRA ocorrência da página — clicar num card de
      // métrica de uma lição mais abaixo abria o "toque prático" de outra
      // lição, fora da tela, parecendo que o clique não fazia nada.
      const body = btn.nextElementSibling;
      if (!body) return;
      body.hidden = !body.hidden;
      btn.classList.toggle('open', !body.hidden);
    });
  });

  container.querySelectorAll('[data-quiz-embed-id]').forEach((btn) => {
    btn.addEventListener('click', () => {
      window.selectedQuizId = btn.dataset.quizEmbedId;
      window.quizRunnerReturnPanel = returnPanel || 'modulo-conteudo';
      navigateToPanel('quiz-runner');
    });
  });

  container.querySelectorAll('[data-copy-text]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const text = decodeURIComponent(btn.dataset.copyText);
      try {
        await navigator.clipboard.writeText(text);
        const original = btn.textContent;
        btn.textContent = '✅ Copiado!';
        btn.classList.add('is-copied');
        setTimeout(() => {
          btn.textContent = original;
          btn.classList.remove('is-copied');
        }, 1500);
      } catch (err) {
        console.error('[ContentBlocks] falha ao copiar argumento:', err);
      }
    });
  });

  container.querySelectorAll('[data-flip-card]').forEach((card) => {
    card.addEventListener('click', () => card.classList.toggle('flipped'));
  });

  container.querySelectorAll('[data-cb-match]').forEach(wireMatchQuiz);

  wireTermTips(container);
}

/**
 * Termos técnicos com tooltip (fora dos cards de métrica) — a bolha some no
 * hover/focus via CSS puro, mas em touch não existe :hover persistente, então
 * o clique alterna uma classe pra abrir/fechar, e clicar fora fecha tudo.
 * Reaproveitado pelo QuizRunner.js (enunciado das perguntas), que não passa
 * pelo resto de wireBlockInteractions.
 */
export function wireTermTips(container) {
  const tips = container.querySelectorAll('.term-tip');
  if (!tips.length) return;
  tips.forEach((el) => {
    el.addEventListener('click', (e) => {
      e.stopPropagation();
      const wasOpen = el.classList.contains('is-tip-open');
      tips.forEach((t) => t.classList.remove('is-tip-open'));
      if (!wasOpen) el.classList.add('is-tip-open');
    });
  });
  document.addEventListener('click', () => {
    tips.forEach((t) => t.classList.remove('is-tip-open'));
  });
}

function wireMatchQuiz(root) {
  let selectedTerm = null;
  const progressEl = root.querySelector('[data-role="cb-match-progress"]');
  const total = root.querySelectorAll('[data-role="cb-match-terms"] [data-match-i]').length;
  let solved = 0;

  function updateProgress() {
    if (progressEl) progressEl.textContent = `${solved} de ${total} associados`;
  }

  root.querySelectorAll('[data-role="cb-match-terms"] [data-match-i]').forEach((btn) => {
    btn.addEventListener('click', () => {
      if (btn.classList.contains('is-solved')) return;
      root.querySelectorAll('[data-role="cb-match-terms"] [data-match-i]').forEach((b) => b.classList.remove('is-selected'));
      btn.classList.add('is-selected');
      selectedTerm = btn;
    });
  });

  root.querySelectorAll('[data-role="cb-match-defs"] [data-match-i]').forEach((btn) => {
    btn.addEventListener('click', () => {
      if (!selectedTerm || btn.classList.contains('is-solved')) return;
      const isCorrect = selectedTerm.dataset.matchI === btn.dataset.matchI;
      if (isCorrect) {
        selectedTerm.classList.remove('is-selected');
        selectedTerm.classList.add('is-solved');
        btn.classList.add('is-solved');
        solved += 1;
        updateProgress();
      } else {
        btn.classList.add('is-wrong');
        selectedTerm.classList.add('is-wrong');
        setTimeout(() => {
          btn.classList.remove('is-wrong');
          selectedTerm?.classList.remove('is-wrong', 'is-selected');
        }, 500);
      }
      selectedTerm = null;
    });
  });
}

// ---------------------------------------------------------------------------
// Editor (formulário estruturado por tipo — sem drag-and-drop)
// ---------------------------------------------------------------------------

/** Uma linha "campo | campo" por item de lista (accordion/timeline/galeria). */
function encodeItems(items, fields) {
  return (items || []).map((it) => fields.map((f) => it[f] || '').join(' | ')).join('\n');
}

function decodeItems(raw, fields) {
  return raw
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const parts = line.split('|').map((p) => p.trim());
      const obj = {};
      fields.forEach((f, i) => { obj[f] = parts[i] || ''; });
      return obj;
    });
}

function encodeMetricItems(items) {
  return (items || []).map((it) => [it.icon || '', it.name || '', it.definition || '', it.tip || '', it.badge || ''].join(' | ')).join('\n');
}

function decodeMetricItems(raw) {
  return raw
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [icon, name, definition, tip, badge] = line.split('|').map((p) => (p || '').trim());
      return { icon, name, definition, tip, badge };
    });
}

function encodeMatchPairs(pairs) {
  return (pairs || []).map((p) => `${p.term || ''} | ${p.definition || ''}`).join('\n');
}

function decodeMatchPairs(raw) {
  return raw
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [term, definition] = line.split('|').map((p) => (p || '').trim());
      return { term, definition };
    });
}

function encodeCardGridItems(items) {
  return (items || []).map((it) => {
    const tagsRaw = (it.tags || []).map((t) => `${t.label}:${t.color}`).join(', ');
    return [it.title || '', it.text || '', tagsRaw].join(' | ');
  }).join('\n');
}

function decodeCardGridItems(raw) {
  return raw
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const parts = line.split('|').map((p) => p.trim());
      const tags = (parts[2] || '')
        .split(',')
        .map((t) => t.trim())
        .filter(Boolean)
        .map((t) => {
          const [label, color] = t.split(':').map((x) => x.trim());
          return { label: label || t, color: color || '' };
        });
      return { title: parts[0] || '', text: parts[1] || '', tags };
    });
}

function renderBlockFields(block) {
  switch (block.type) {
    case 'texto_rico':
      return `<textarea data-field="html" rows="6" placeholder="HTML do bloco">${block.html || ''}</textarea>`;
    case 'banner':
      return `
        <select data-field="tone">
          <option value="info" ${block.tone === 'info' ? 'selected' : ''}>Info</option>
          <option value="success" ${block.tone === 'success' ? 'selected' : ''}>Sucesso</option>
          <option value="warning" ${block.tone === 'warning' ? 'selected' : ''}>Atenção</option>
        </select>
        <textarea data-field="text" rows="2" placeholder="Texto do banner">${block.text || ''}</textarea>`;
    case 'card':
      return `
        <input type="text" data-field="icon" value="${block.icon || ''}" placeholder="Emoji (ex.: 💡)">
        <input type="text" data-field="title" value="${block.title || ''}" placeholder="Título do card">
        <textarea data-field="text" rows="3" placeholder="Texto do card">${block.text || ''}</textarea>`;
    case 'accordion':
      return `
        <textarea data-field="items_raw" rows="5" placeholder="Um item por linha: Título | HTML do conteúdo">${encodeItems(block.items, ['title', 'html'])}</textarea>
        <p class="cb-editor-hint">Formato: Título | HTML do conteúdo (um item por linha)</p>`;
    case 'timeline':
      return `
        <textarea data-field="items_raw" rows="5" placeholder="Um item por linha: Rótulo | Texto">${encodeItems(block.items, ['label', 'text'])}</textarea>
        <p class="cb-editor-hint">Formato: Rótulo | Texto (um item por linha)</p>`;
    case 'video':
      return `
        <input type="text" data-field="videoUrl" value="${block.videoUrl || ''}" placeholder="URL do vídeo (embed)">
        <input type="text" data-field="caption" value="${block.caption || ''}" placeholder="Legenda (opcional)">`;
    case 'galeria':
      return `
        <textarea data-field="images_raw" rows="4" placeholder="Uma imagem por linha: URL | Legenda">${encodeItems(block.images, ['url', 'caption'])}</textarea>
        <p class="cb-editor-hint">Formato: URL da imagem | Legenda (uma por linha)</p>`;
    case 'quiz_embutido':
      return `
        <input type="text" data-field="quizId" value="${block.quizId || ''}" placeholder="ID do quiz (ver em Quizzes Extras)">
        <input type="text" data-field="label" value="${block.label || ''}" placeholder="Texto do botão (opcional)">`;
    case 'roteiro':
      return `
        <textarea data-field="steps_raw" rows="5" placeholder="Um passo por linha: Título | Fala do vendedor | Dica (opcional)">${encodeItems(block.steps, ['title', 'dialog', 'tip'])}</textarea>
        <p class="cb-editor-hint">Formato: Título | Fala do vendedor | Dica opcional (um passo por linha)</p>`;
    case 'objecao':
      return `
        <textarea data-field="items_raw" rows="5" placeholder="Uma objeção por linha: Pergunta do cliente | Resposta">${encodeItems(block.items, ['question', 'answer'])}</textarea>
        <p class="cb-editor-hint">Formato: Pergunta do cliente | Resposta (uma por linha)</p>`;
    case 'tabela':
      return `
        <input type="text" data-field="headers_raw" value="${(block.headers || []).join(' | ')}" placeholder="Cabeçalhos separados por | (ex.: Modelo | Tela | Preço)">
        <textarea data-field="rows_raw" rows="5" placeholder="Uma linha de tabela por linha de texto, células separadas por |">${(block.rows || []).map((r) => r.join(' | ')).join('\n')}</textarea>
        <p class="cb-editor-hint">Cabeçalhos e células separados por | , uma linha de tabela por linha de texto</p>`;
    case 'card_grid':
      return `
        <select data-field="columns">
          <option value="2" ${block.columns !== 3 ? 'selected' : ''}>2 colunas</option>
          <option value="3" ${block.columns === 3 ? 'selected' : ''}>3 colunas</option>
        </select>
        <textarea data-field="items_raw" rows="5" placeholder="Um card por linha: Título | Texto | tag1:blue, tag2:green (opcional)">${encodeCardGridItems(block.items)}</textarea>
        <p class="cb-editor-hint">Formato: Título | Texto | tags rótulo:cor separadas por vírgula (cores: blue, green, orange, gold), tags opcionais</p>`;
    case 'flip_card':
      return `
        <select data-field="columns">
          <option value="2" ${block.columns !== 3 ? 'selected' : ''}>2 colunas</option>
          <option value="3" ${block.columns === 3 ? 'selected' : ''}>3 colunas</option>
        </select>
        <textarea data-field="cards_raw" rows="6" placeholder="Um card por linha: Emoji | Título | Subtítulo | Texto da frente | Rótulo do verso | Texto do verso">${encodeItems(block.cards, ['emoji', 'title', 'subtitle', 'frontText', 'backLabel', 'backText'])}</textarea>
        <p class="cb-editor-hint">Formato: Emoji | Título | Subtítulo | Texto da frente | Rótulo do verso | Texto do verso (um card por linha, clique para virar)</p>`;
    case 'metric_card_grid':
      return `
        <select data-field="columns">
          <option value="2" ${block.columns !== 3 ? 'selected' : ''}>2 colunas</option>
          <option value="3" ${block.columns === 3 ? 'selected' : ''}>3 colunas</option>
        </select>
        <textarea data-field="items_raw" rows="6" placeholder="Um card por linha: Emoji | Nome da métrica | Definição curta | Toque prático | Selo (opcional, ex.: Requer HRM 600)">${encodeMetricItems(block.items)}</textarea>
        <p class="cb-editor-hint">Formato: Emoji | Nome | Definição (1-2 frases, sempre visível) | Toque prático (só aparece ao expandir) | Selo opcional (ex.: "Requer HRM 600")</p>`;
    case 'match_quiz':
      return `
        <textarea data-field="pairs_raw" rows="5" placeholder="Um par por linha: Termo | Definição curta">${encodeMatchPairs(block.pairs)}</textarea>
        <p class="cb-editor-hint">Formato: Termo | Definição (um par por linha). Vira um mini quiz de associação por clique, aquecimento antes do quiz final</p>`;
    default:
      return '';
  }
}

function renderBlockEditorRow(block, index, total) {
  const typeLabel = BLOCK_TYPES.find((t) => t.key === block.type)?.label || block.type;
  return `
    <div class="cb-editor-row" data-block-index="${index}">
      <div class="cb-editor-row-head">
        <span class="cb-editor-row-type">${typeLabel}</span>
        <div class="cb-editor-row-actions">
          <button type="button" class="cb-editor-btn" data-action="up" data-index="${index}" ${index === 0 ? 'disabled' : ''}>↑</button>
          <button type="button" class="cb-editor-btn" data-action="down" data-index="${index}" ${index === total - 1 ? 'disabled' : ''}>↓</button>
          <button type="button" class="cb-editor-btn cb-editor-btn-danger" data-action="remove" data-index="${index}">Remover</button>
        </div>
      </div>
      <div class="cb-editor-row-fields">${renderBlockFields(block)}</div>
    </div>`;
}

function readBlockFromRow(row, type) {
  const get = (field) => row.querySelector(`[data-field="${field}"]`)?.value ?? '';
  switch (type) {
    case 'texto_rico': return { type, html: get('html') };
    case 'banner': return { type, tone: get('tone') || 'info', text: get('text') };
    case 'card': return { type, icon: get('icon'), title: get('title'), text: get('text') };
    case 'accordion': return { type, items: decodeItems(get('items_raw'), ['title', 'html']) };
    case 'timeline': return { type, items: decodeItems(get('items_raw'), ['label', 'text']) };
    case 'video': return { type, videoUrl: get('videoUrl'), caption: get('caption') };
    case 'galeria': return { type, images: decodeItems(get('images_raw'), ['url', 'caption']) };
    case 'quiz_embutido': return { type, quizId: get('quizId'), label: get('label') };
    case 'roteiro': return { type, steps: decodeItems(get('steps_raw'), ['title', 'dialog', 'tip']) };
    case 'objecao': return { type, items: decodeItems(get('items_raw'), ['question', 'answer']) };
    case 'tabela': return {
      type,
      headers: get('headers_raw').split('|').map((h) => h.trim()).filter(Boolean),
      rows: get('rows_raw').split('\n').map((l) => l.trim()).filter(Boolean).map((l) => l.split('|').map((c) => c.trim())),
    };
    case 'card_grid': return { type, columns: Number(get('columns')) === 3 ? 3 : 2, items: decodeCardGridItems(get('items_raw')) };
    case 'flip_card': return { type, columns: Number(get('columns')) === 3 ? 3 : 2, cards: decodeItems(get('cards_raw'), ['emoji', 'title', 'subtitle', 'frontText', 'backLabel', 'backText']) };
    case 'metric_card_grid': return { type, columns: Number(get('columns')) === 3 ? 3 : 2, items: decodeMetricItems(get('items_raw')) };
    case 'match_quiz': return { type, pairs: decodeMatchPairs(get('pairs_raw')) };
    default: return { type };
  }
}

/**
 * Editor de array de blocos — adicionar/remover/mover/editar por tipo, sem
 * drag-and-drop. `onSave(blocks)` recebe o array já sincronizado.
 */
export function setupBlockArrayEditor(container, initialBlocks, { onSave, onCancel } = {}) {
  let blocks = JSON.parse(JSON.stringify(initialBlocks || []));

  function syncFromDom() {
    container.querySelectorAll('.cb-editor-row').forEach((row) => {
      const index = Number(row.dataset.blockIndex);
      if (Number.isInteger(index) && blocks[index]) {
        blocks[index] = readBlockFromRow(row, blocks[index].type);
      }
    });
  }

  function render() {
    const listEl = container.querySelector('[data-role="cb-block-list"]');
    listEl.innerHTML = blocks.length
      ? blocks.map((b, i) => renderBlockEditorRow(b, i, blocks.length)).join('')
      : '<p class="cb-editor-hint">Nenhum bloco ainda, adicione um abaixo.</p>';

    listEl.querySelectorAll('[data-action]').forEach((btn) => {
      btn.addEventListener('click', () => {
        syncFromDom();
        const index = Number(btn.dataset.index);
        const action = btn.dataset.action;
        if (action === 'remove') {
          blocks.splice(index, 1);
        } else if (action === 'up' && index > 0) {
          [blocks[index - 1], blocks[index]] = [blocks[index], blocks[index - 1]];
        } else if (action === 'down' && index < blocks.length - 1) {
          [blocks[index + 1], blocks[index]] = [blocks[index], blocks[index + 1]];
        }
        render();
      });
    });
  }

  container.innerHTML = `
    <div class="cb-editor" data-role="cb-editor">
      <div data-role="cb-block-list"></div>
      <div class="cb-editor-add-row">
        <select data-role="cb-add-type">
          ${BLOCK_TYPES.map((t) => `<option value="${t.key}">${t.label}</option>`).join('')}
        </select>
        <button type="button" class="cb-editor-btn" data-role="cb-add-btn">+ Adicionar bloco</button>
      </div>
      <div class="cb-editor-save-row">
        <button type="button" class="login-btn" data-role="cb-save-btn" style="width:auto; padding:10px 20px;">Salvar</button>
        <button type="button" class="cb-editor-btn" data-role="cb-cancel-btn">Cancelar</button>
      </div>
      <div data-role="cb-editor-message"></div>
    </div>`;

  render();

  container.querySelector('[data-role="cb-add-btn"]').addEventListener('click', () => {
    syncFromDom();
    const type = container.querySelector('[data-role="cb-add-type"]').value;
    blocks.push(defaultBlockFor(type));
    render();
  });

  container.querySelector('[data-role="cb-cancel-btn"]').addEventListener('click', () => {
    if (onCancel) onCancel();
  });

  container.querySelector('[data-role="cb-save-btn"]').addEventListener('click', async () => {
    syncFromDom();
    const messageEl = container.querySelector('[data-role="cb-editor-message"]');
    const saveBtn = container.querySelector('[data-role="cb-save-btn"]');
    saveBtn.disabled = true;
    messageEl.textContent = 'Salvando...';
    try {
      if (onSave) await onSave(blocks);
    } catch (err) {
      messageEl.textContent = 'Erro ao salvar: ' + err.message;
      messageEl.style.color = 'var(--g)';
      saveBtn.disabled = false;
    }
  });
}
