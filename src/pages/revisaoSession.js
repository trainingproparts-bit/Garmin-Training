// src/pages/revisaoSession.js
// Sessão de revisão — 1 conteúdo por vez, estilo feed (sem menus, sem
// voltar, botão "Próximo" sempre em destaque). Reaproveita renderBlocks/
// wireBlockInteractions (ContentBlocks.js) pros tipos de bloco já existentes;
// só quiz_question e comparison_spec (exclusivos da revisão, sem
// certo/errado visível antes de responder) ganham renderização própria aqui.

import { navigateToPanel } from '../router.js';
import {
  fetchSessionItems,
  fetchItemContent,
  submitReviewItem,
  finalizeReviewSession,
} from '../services/revisaoService.js';
import { renderBlocks, wireBlockInteractions } from '../components/ContentBlocks.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'revisao-session') initRevisaoSessionPage();
});

async function initRevisaoSessionPage() {
  const container = document.getElementById('revisaoSessionContainer');
  if (!container) return;

  const sessionId = window.selectedReviewSessionId;
  delete window.selectedReviewSessionId;

  if (!sessionId) {
    container.innerHTML = '<p class="content-error">Nenhuma sessão de revisão em andamento.</p>';
    return;
  }

  container.innerHTML = '<p class="learning-loading">Preparando sua revisão…</p>';

  try {
    const items = await fetchSessionItems(sessionId);
    if (!items.length) {
      renderEmptySession(container, sessionId);
      return;
    }
    runSession(container, sessionId, items);
  } catch (err) {
    console.error('[RevisaoSession] erro ao carregar sessão:', err);
    container.innerHTML = '<p class="content-error">Não foi possível carregar a revisão agora.</p>';
  }
}

function renderEmptySession(container) {
  container.innerHTML = `
    <div class="revisao-empty">
      <span class="revisao-empty-icon">✨</span>
      <p>Nenhum conteúdo disponível pra esse modo agora — nada errado pra revisar, ou o catálogo ainda tá vazio.</p>
      <button type="button" class="revisao-empty-back" data-role="back">Voltar</button>
    </div>`;
  container.querySelector('[data-role="back"]').addEventListener('click', () => navigateToPanel('revisao-inteligente'));
}

function runSession(container, sessionId, items) {
  let index = 0;
  const startedAt = Date.now();

  renderItem();

  async function renderItem() {
    const item = items[index];
    const pct = (index / items.length) * 100;

    container.innerHTML = `
      <div class="revisao-runner">
        <div class="revisao-runner-top">
          <button type="button" class="revisao-exit-btn" data-role="exit">✕</button>
          <div class="revisao-progress-track"><div class="revisao-progress-fill" style="width:${pct}%"></div></div>
          <span class="revisao-progress-label">${index + 1}/${items.length}</span>
        </div>
        <div class="revisao-card" data-role="card">
          <p class="learning-loading">Carregando…</p>
        </div>
        <button type="button" class="revisao-next-btn" data-role="next" hidden>Próximo →</button>
      </div>
    `;

    container.querySelector('[data-role="exit"]').addEventListener('click', () => finishSession(container, sessionId, startedAt));

    const cardEl = container.querySelector('[data-role="card"]');
    const nextBtn = container.querySelector('[data-role="next"]');

    try {
      const content = await fetchItemContent(item.review_catalog);
      renderCard(cardEl, nextBtn, item, content);
    } catch (err) {
      console.error('[RevisaoSession] erro ao buscar conteúdo do item:', err);
      cardEl.innerHTML = '<p class="content-error">Não foi possível carregar este conteúdo.</p>';
      nextBtn.hidden = false;
      nextBtn.textContent = index === items.length - 1 ? 'Ver resumo' : 'Próximo →';
      nextBtn.addEventListener('click', handleNext, { once: true });
    }
  }

  // Identifica de onde vem o conteúdo (produto/comparativo/lição/artigo) —
  // pro conteúdo passivo (accordion, banner, card_grid, roteiro etc.), o
  // review_catalog.title já guarda exatamente esse contexto (nome do
  // produto ou título do comparativo/lição/artigo), só nunca tinha sido
  // exibido na tela — daí a confusão reportada pelo usuário.
  const SOURCE_ICON = {
    product_sections: '📦',
    product_comparisons: '⚖️',
    lessons: '📘',
    content_library: '📄',
  };

  function sourceTagHtml(catalogEntry) {
    if (!catalogEntry?.title) return '';
    const icon = SOURCE_ICON[catalogEntry.source_table] || '📌';
    return `<div class="revisao-source-tag">${icon} ${catalogEntry.title}</div>`;
  }

  function renderCard(cardEl, nextBtn, item, content) {
    nextBtn.textContent = index === items.length - 1 ? 'Ver resumo' : 'Próximo →';

    if (content.kind === 'quiz_question') {
      renderQuizQuestionCard(cardEl, nextBtn, item, content);
    } else if (content.kind === 'comparison_spec') {
      renderComparisonSpecCard(cardEl, nextBtn, item, content);
    } else {
      renderPassiveBlockCard(cardEl, nextBtn, item, content);
    }
  }

  function renderPassiveBlockCard(cardEl, nextBtn, item, content) {
    if (!content.block) {
      cardEl.innerHTML = '<p class="content-error">Este conteúdo não está disponível mais.</p>';
      nextBtn.hidden = false;
      nextBtn.addEventListener('click', handleNext, { once: true });
      return;
    }

    cardEl.innerHTML = sourceTagHtml(item.review_catalog) + renderBlocks([content.block]);
    wireBlockInteractions(cardEl, { returnPanel: 'revisao-session' });

    // Conteúdo passivo (texto/roteiro/objeção/tabela/vídeo/card etc.) não tem
    // certo/errado — clicar em "Próximo" já registra como "visualizado".
    nextBtn.hidden = false;
    nextBtn.addEventListener('click', async () => {
      nextBtn.disabled = true;
      try {
        await submitReviewItem(item.id, null);
      } catch (err) {
        console.error('[RevisaoSession] erro ao registrar item:', err);
      }
      handleNext();
    }, { once: true });
  }

  function renderQuizQuestionCard(cardEl, nextBtn, item, content) {
    const { question, alternatives } = content;
    cardEl.innerHTML = `
      <div class="revisao-quiz-card">
        <span class="revisao-quiz-card-tag">Pergunta rápida</span>
        <p class="revisao-quiz-card-question">${question.body}</p>
        <div class="revisao-quiz-card-options" data-role="options">
          ${alternatives.map((a) => `<button type="button" class="revisao-quiz-option" data-alt-id="${a.id}">${a.body}</button>`).join('')}
        </div>
        <div class="revisao-quiz-card-feedback" data-role="feedback" hidden></div>
      </div>`;

    cardEl.querySelectorAll('[data-alt-id]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const options = [...cardEl.querySelectorAll('[data-alt-id]')];
        options.forEach((o) => { o.disabled = true; });

        let result;
        try {
          result = await submitReviewItem(item.id, btn.dataset.altId);
        } catch (err) {
          console.error('[RevisaoSession] erro ao registrar resposta:', err);
          result = 'erro';
        }

        btn.classList.add(result === 'acerto' ? 'correct' : 'incorrect');

        const feedbackEl = cardEl.querySelector('[data-role="feedback"]');
        feedbackEl.hidden = false;
        feedbackEl.className = `revisao-quiz-card-feedback ${result === 'acerto' ? 'ok' : 'no'}`;
        feedbackEl.textContent = result === 'acerto'
          ? '✅ Boa! Você já domina isso.'
          : `❌ ${question.explanation || 'Não dessa vez — vai voltar a aparecer em breve.'}`;

        nextBtn.hidden = false;
        nextBtn.addEventListener('click', handleNext, { once: true });
      }, { once: true });
    });
  }

  function renderComparisonSpecCard(cardEl, nextBtn, item, content) {
    const { spec_label, value_a, value_b, product_comparisons: cmp } = content.item;
    const nameA = cmp?.product_a?.name || 'Produto A';
    const nameB = cmp?.product_b?.name || 'Produto B';

    cardEl.innerHTML = `
      <div class="revisao-spec-card">
        <span class="revisao-quiz-card-tag">Qual vence?</span>
        <p class="revisao-quiz-card-question">${spec_label}</p>
        <div class="revisao-spec-options">
          <button type="button" class="revisao-spec-option" data-answer="a"><strong>${nameA}</strong><span>${value_a || '—'}</span></button>
          <button type="button" class="revisao-spec-option" data-answer="b"><strong>${nameB}</strong><span>${value_b || '—'}</span></button>
        </div>
        <div class="revisao-quiz-card-feedback" data-role="feedback" hidden></div>
      </div>`;

    cardEl.querySelectorAll('[data-answer]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const options = [...cardEl.querySelectorAll('[data-answer]')];
        options.forEach((o) => { o.disabled = true; });

        let result;
        try {
          result = await submitReviewItem(item.id, btn.dataset.answer);
        } catch (err) {
          console.error('[RevisaoSession] erro ao registrar resposta:', err);
          result = 'erro';
        }

        btn.classList.add(result === 'acerto' ? 'correct' : 'incorrect');

        const feedbackEl = cardEl.querySelector('[data-role="feedback"]');
        feedbackEl.hidden = false;
        feedbackEl.className = `revisao-quiz-card-feedback ${result === 'acerto' ? 'ok' : 'no'}`;
        feedbackEl.textContent = result === 'acerto' ? '✅ Isso mesmo!' : '❌ Não dessa vez.';

        nextBtn.hidden = false;
        nextBtn.addEventListener('click', handleNext, { once: true });
      }, { once: true });
    });
  }

  function handleNext() {
    if (index < items.length - 1) {
      index += 1;
      renderItem();
    } else {
      finishSession(container, sessionId, startedAt);
    }
  }
}

async function finishSession(container, sessionId, startedAt) {
  container.innerHTML = '<p class="learning-loading">Calculando seu resumo…</p>';

  try {
    const summary = await finalizeReviewSession(sessionId);
    renderSummary(container, summary, startedAt);
  } catch (err) {
    console.error('[RevisaoSession] erro ao finalizar sessão:', err);
    container.innerHTML = '<p class="content-error">Não foi possível calcular o resumo agora.</p>';
  }
}

function renderSummary(container, summary, startedAt) {
  const { items_reviewed, mastered_count, precisa_revisar_count, xp_earned } = summary || {};
  const minutes = Math.max(1, Math.round((Date.now() - startedAt) / 60000));

  container.innerHTML = `
    <div class="revisao-summary">
      <span class="revisao-summary-icon">🎉</span>
      <h2>Revisão concluída!</h2>
      <div class="revisao-summary-stats">
        <div class="revisao-summary-stat"><strong>${items_reviewed ?? 0}</strong><span>conteúdos revisados</span></div>
        <div class="revisao-summary-stat"><strong>${minutes} min</strong><span>tempo estudado</span></div>
        <div class="revisao-summary-stat"><strong>+${xp_earned ?? 0} XP</strong><span>ganho</span></div>
        <div class="revisao-summary-stat"><strong>${mastered_count ?? 0}</strong><span>já dominados</span></div>
        ${precisa_revisar_count ? `<div class="revisao-summary-stat revisao-summary-stat-warn"><strong>${precisa_revisar_count}</strong><span>precisam voltar a aparecer</span></div>` : ''}
      </div>
      <button type="button" class="revisao-summary-btn" data-role="finish">Concluir</button>
    </div>`;

  container.querySelector('[data-role="finish"]').addEventListener('click', () => navigateToPanel('revisao-inteligente'));
}
