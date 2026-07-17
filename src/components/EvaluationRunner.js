// src/components/EvaluationRunner.js
// Componente de execução da Avaliação Trimestral — mesma estrutura do
// QuizRunner.js, com duas diferenças: as opções vêm de options_json (array
// de strings, não linhas de alternatives com id próprio) e existe uma
// checagem de trava de 24h antes de abrir a tentativa (sem limite de
// tentativas, só o cooldown pós-reprovação).

import {
  fetchEvaluationQuestions,
  checkEvaluationLock,
  startEvaluationAttempt,
  submitEvaluationAnswer,
  finishEvaluationAttempt,
} from '../services/evaluationService.js';

function formatLockedUntil(iso) {
  return new Date(iso).toLocaleString('pt-BR', { dateStyle: 'short', timeStyle: 'short' });
}

/**
 * @param {HTMLElement} container
 * @param {string} evaluationType - 'explorer' | 'runner' | 'triathlete'
 * @param {{onFinished?: (attempt: object) => void}} opts
 */
export async function renderEvaluationRunner(container, evaluationType, opts = {}) {
  container.innerHTML = '<p class="learning-loading">Carregando avaliação…</p>';

  try {
    const { evaluation, questions } = await fetchEvaluationQuestions(evaluationType);

    if (!questions.length) {
      container.innerHTML = '<p class="learning-empty">Esta avaliação ainda não tem perguntas cadastradas.</p>';
      return;
    }

    const lock = await checkEvaluationLock(evaluation.id);
    if (lock.locked) {
      container.innerHTML = `
        <div class="learning-blocked">
          <h3>Avaliação em cooldown</h3>
          <p>Você reprovou a última tentativa de <strong>${evaluation.title}</strong> e precisa esperar até
          <strong>${formatLockedUntil(lock.locked_until)}</strong> para tentar de novo.
          Peça liberação antecipada ao seu líder, se necessário.</p>
        </div>`;
      return;
    }

    const attempt = await startEvaluationAttempt(evaluation.id);
    runEvaluation(container, evaluation, questions, attempt.id, opts);
  } catch (err) {
    console.error('[EvaluationRunner] erro ao carregar avaliação:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar esta avaliação agora.</p>';
  }
}

function runEvaluation(container, evaluation, questions, attemptId, opts) {
  let index = 0;
  let answered = false;

  renderQuestion();

  function renderQuestion() {
    answered = false;
    const q = questions[index];
    const options = q.options_json || [];
    container.innerHTML = `
      <div class="quiz-runner">
        <div class="quiz-runner-header">
          <span class="quiz-runner-title">${evaluation.title}</span>
          <span class="quiz-runner-progress">Pergunta ${index + 1} de ${questions.length}</span>
        </div>
        <div class="quiz-runner-track"><div class="quiz-runner-track-fill" style="width:${(index / questions.length) * 100}%"></div></div>

        <p class="quiz-runner-question">${q.question_text}</p>
        <div class="quiz-runner-options" data-role="options">
          ${options.map((opt, i) => `
            <button type="button" class="quiz-runner-option" data-option-index="${i}">${opt}</button>
          `).join('')}
        </div>
        <div class="quiz-runner-feedback" data-role="feedback" hidden></div>
        <button type="button" class="quiz-runner-next" data-role="next" hidden>
          ${index === questions.length - 1 ? 'Finalizar avaliação' : 'Próxima pergunta →'}
        </button>
      </div>
    `;

    container.querySelectorAll('[data-option-index]').forEach((btn) => {
      btn.addEventListener('click', () => handleAnswer(q, btn));
    });
    container.querySelector('[data-role="next"]').addEventListener('click', handleNext);
  }

  async function handleAnswer(question, btn) {
    if (answered) return;
    answered = true;

    container.querySelectorAll('[data-option-index]').forEach((b) => (b.disabled = true));

    try {
      const isCorrect = await submitEvaluationAnswer(attemptId, question.id, Number(btn.dataset.optionIndex));
      btn.classList.add(isCorrect ? 'correct' : 'incorrect');

      const feedbackEl = container.querySelector('[data-role="feedback"]');
      feedbackEl.hidden = false;
      feedbackEl.textContent = isCorrect ? '✓ Resposta correta!' : '✗ Resposta incorreta.';
      feedbackEl.className = `quiz-runner-feedback ${isCorrect ? 'ok' : 'no'}`;

      container.querySelector('[data-role="next"]').hidden = false;
    } catch (err) {
      console.error('[EvaluationRunner] erro ao enviar resposta:', err);
      answered = false;
      container.querySelectorAll('[data-option-index]').forEach((b) => (b.disabled = false));
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
      const result = await finishEvaluationAttempt(attemptId);
      renderResult(result);
    } catch (err) {
      console.error('[EvaluationRunner] erro ao finalizar tentativa:', err);
      container.innerHTML = '<p class="learning-error">Não foi possível calcular seu resultado agora.</p>';
    }
  }

  function renderResult(attempt) {
    container.innerHTML = `
      <div class="quiz-result ${attempt.passed ? 'passed' : 'failed'}">
        <h3>${attempt.passed ? '✓ Aprovado!' : '✗ Não foi desta vez'}</h3>
        <p class="quiz-result-score">${attempt.score_pct}% <span>· corte mínimo ${evaluation.passing_score_pct}%</span></p>
        ${!attempt.passed ? '<p class="cert-obj">Você poderá tentar de novo em 24h, ou pedir liberação ao seu líder.</p>' : ''}
        <button type="button" class="quiz-result-back" data-role="back">Voltar</button>
      </div>
    `;
    container.querySelector('[data-role="back"]').addEventListener('click', () => {
      opts.onFinished?.(attempt);
    });
  }
}
