// src/pages/quizRunner.js
import { getCurrentProfile } from '../config/supabase.js';
import { renderQuizRunner } from '../components/QuizRunner.js';
import { navigateToPanel } from '../router.js';

window.addEventListener('panel:activated', async (e) => {
  if (e.detail.panelId !== 'quiz-runner') return;

  const container = document.getElementById('quizRunnerContainer');
  if (!container) return;

  const quizId = window.selectedQuizId;
  if (!quizId) {
    container.innerHTML = '<p class="learning-error">Nenhum quiz selecionado.</p>';
    return;
  }

  const profile = await getCurrentProfile();
  if (!profile) {
    container.innerHTML = '<p class="learning-error">Faça login para responder a este quiz.</p>';
    return;
  }

  renderQuizRunner(container, quizId, profile.id, {
    // Quiz pode ser lançado como checkpoint da trilha (abrirCheckpoint em
    // trilha.js) ou pela lista solta "Quizzes Extras" (quizzes.js) — cada
    // um marca de onde veio antes de navegar pra cá, pra "Voltar" no
    // resultado devolver pro lugar certo em vez de sempre cair em
    // "Quizzes Extras" (isso deixava a trilha com o checkpoint recém-
    // desbloqueado sem refletir na tela até um reload manual).
    onFinished: () => navigateToPanel(window.quizRunnerReturnPanel || 'arena'),
  });
});
