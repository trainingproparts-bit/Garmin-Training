// src/components/QuizRunner.js
// Componente de execução de quiz — pergunta a pergunta, com correção sempre
// calculada no servidor (quizService.submitAnswer chama fn_submit_quiz_answer).
// Reutilizável por qualquer painel que precise rodar um quiz (checkpoint da
// trilha, ou a listagem avulsa de Quizzes).

import {
  fetchQuizForAttempt,
  countFinishedAttempts,
  startQuizAttempt,
  submitAnswer,
  finalizeQuizAttempt,
} from '../services/quizService.js';
import { wireTermTips } from './ContentBlocks.js';

const OPTION_LETTERS = ['A', 'B', 'C', 'D', 'E', 'F'];

// Ícones outline (mesmo espírito dos cards da trilha, GpsTrail.js) — usados
// no header da pergunta pra dar contexto temático em vez de só texto solto.
const HEADER_ICON = {
  droplet: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2.69s-5.5 6.16-5.5 10a5.5 5.5 0 0 0 11 0c0-3.84-5.5-10-5.5-10Z"/></svg>',
  chat: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 11.5a8.5 8.5 0 0 1-8.5 8.5 8.4 8.4 0 0 1-4-1L3 20l1-5.5a8.5 8.5 0 1 1 17-3Z"/></svg>',
  heart: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.6l-1-1a5.5 5.5 0 0 0-7.8 7.8l1 1L12 21l7.8-7.8 1-1a5.5 5.5 0 0 0 0-7.8Z"/></svg>',
  watch: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="7"/><polyline points="12 9 12 12 13.5 13.5"/><path d="M16.51 17.35 17 21l-5-1.5L7 21l.49-3.65"/><path d="M7.49 6.65 7 3l5 1.5L17 3l-.49 3.65"/></svg>',
  help: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 2-3 4"/><line x1="12" y1="17.02" x2="12.01" y2="17.02"/></svg>',
};

const TOPIC_ICON_RULES = [
  { test: /ipx|resist[êe]ncia.*[áa]gua|imperme[áa]v/i, icon: 'droplet' },
  { test: /atendimento|script/i, icon: 'chat' },
  { test: /card[íi]ac|hrm|cinta/i, icon: 'heart' },
  { test: /instinct|rel[óo]gio/i, icon: 'watch' },
];

function headerIconFor(title) {
  const rule = TOPIC_ICON_RULES.find((r) => r.test.test(title || ''));
  return HEADER_ICON[rule?.icon || 'help'];
}

const RESULT_ICON = {
  correct: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="8 12 11 15 16 9"/></svg>',
  incorrect: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>',
};

/**
 * @param {HTMLElement} container
 * @param {string} quizId
 * @param {string} userId
 * @param {{onFinished?: (attempt: object) => void}} opts
 */
export async function renderQuizRunner(container, quizId, userId, opts = {}) {
  container.innerHTML = '<p class="learning-loading">Carregando quiz…</p>';

  try {
    const { quiz, questions } = await fetchQuizForAttempt(quizId);

    if (!questions.length) {
      container.innerHTML = '<p class="learning-empty">Este quiz ainda não tem perguntas cadastradas.</p>';
      return;
    }

    if (quiz.max_attempts) {
      const finished = await countFinishedAttempts(userId, quizId);
      if (finished >= quiz.max_attempts) {
        container.innerHTML = `
          <div class="learning-blocked">
            <h3>Limite de tentativas atingido</h3>
            <p>Você já usou as ${quiz.max_attempts} tentativas disponíveis para <strong>${quiz.title}</strong>.
            Peça liberação de uma nova tentativa ao seu líder.</p>
          </div>`;
        return;
      }
    }

    const attempt = await startQuizAttempt(userId, quizId);
    runQuiz(container, quiz, questions, attempt.id, opts);
  } catch (err) {
    console.error('[QuizRunner] erro ao carregar quiz:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar este quiz agora.</p>';
  }
}

function runQuiz(container, quiz, questions, attemptId, opts) {
  let index = 0;
  let answered = false;
  const headerIcon = headerIconFor(quiz.title);

  renderQuestion();

  function renderQuestion() {
    answered = false;
    const q = questions[index];
    container.innerHTML = `
      <div class="quiz-runner">
        <div class="quiz-runner-header">
          <div class="quiz-runner-header-icon">${headerIcon}</div>
          <div class="quiz-runner-header-text">
            <span class="quiz-runner-title">${quiz.title}</span>
            <span class="quiz-runner-progress">Pergunta ${index + 1} de ${questions.length}</span>
          </div>
        </div>
        <div class="quiz-runner-track"><div class="quiz-runner-track-fill" style="width:${(index / questions.length) * 100}%"></div></div>

        <p class="quiz-runner-question">${q.body}</p>
        <div class="quiz-runner-options" data-role="options">
          ${q.alternatives.map((alt, i) => `
            <button type="button" class="quiz-runner-option" data-alt-id="${alt.id}">
              <span class="quiz-runner-option-letter">${OPTION_LETTERS[i] || '•'}</span>
              <span class="quiz-runner-option-text">${alt.body}</span>
              <span class="quiz-runner-option-result-icon" data-result-icon></span>
            </button>
          `).join('')}
        </div>
        <div class="quiz-runner-feedback" data-role="feedback" hidden></div>
        <button type="button" class="quiz-runner-next" data-role="next" hidden>
          ${index === questions.length - 1 ? 'Finalizar quiz' : 'Próxima pergunta →'}
        </button>
      </div>
    `;

    container.querySelectorAll('[data-alt-id]').forEach((btn) => {
      btn.addEventListener('click', () => handleAnswer(q, btn));
    });
    container.querySelector('[data-role="next"]').addEventListener('click', handleNext);
    wireTermTips(container);
  }

  async function handleAnswer(question, btn) {
    if (answered) return;
    answered = true;

    container.querySelectorAll('[data-alt-id]').forEach((b) => (b.disabled = true));

    try {
      const { isCorrect, explanation } = await submitAnswer(attemptId, question.id, btn.dataset.altId);
      btn.classList.add(isCorrect ? 'correct' : 'incorrect');
      btn.querySelector('[data-result-icon]').innerHTML = RESULT_ICON[isCorrect ? 'correct' : 'incorrect'];

      const feedbackEl = container.querySelector('[data-role="feedback"]');
      feedbackEl.hidden = false;
      feedbackEl.innerHTML = `
        <span class="quiz-runner-feedback-icon">${RESULT_ICON[isCorrect ? 'correct' : 'incorrect']}</span>
        <span class="quiz-runner-feedback-body">
          <span class="quiz-runner-feedback-headline">${isCorrect ? 'Resposta correta!' : 'Resposta incorreta.'}</span>
          ${explanation ? `<span class="quiz-runner-feedback-explanation">${explanation}</span>` : ''}
        </span>
      `;
      feedbackEl.className = `quiz-runner-feedback ${isCorrect ? 'ok' : 'no'}`;

      container.querySelector('[data-role="next"]').hidden = false;
    } catch (err) {
      console.error('[QuizRunner] erro ao enviar resposta:', err);
      answered = false;
      container.querySelectorAll('[data-alt-id]').forEach((b) => (b.disabled = false));
    }
  }

  async function handleNext() {
    if (index < questions.length - 1) {
      index += 1;
      renderQuestion();
      return;
    }

    container.innerHTML = '<p class="learning-loading">Calculando resultado…</p>';
    try {
      const result = await finalizeQuizAttempt(attemptId);
      renderResult(result);
    } catch (err) {
      console.error('[QuizRunner] erro ao finalizar tentativa:', err);
      container.innerHTML = '<p class="learning-error">Não foi possível calcular seu resultado agora.</p>';
    }
  }

  function renderResult(attempt) {
    container.innerHTML = `
      <div class="quiz-result ${attempt.passed ? 'passed' : 'failed'}">
        <h3>${attempt.passed ? '✓ Aprovado!' : '✗ Não foi desta vez'}</h3>
        <p class="quiz-result-score">${attempt.score_pct}% <span>· corte mínimo ${quiz.passing_score_pct}%</span></p>
        <button type="button" class="quiz-result-back" data-role="back">Voltar</button>
      </div>
    `;
    container.querySelector('[data-role="back"]').addEventListener('click', () => {
      opts.onFinished?.(attempt);
    });
  }
}
