// src/pages/evaluationRunner.js
import { getCurrentProfile } from '../config/supabase.js';
import { renderEvaluationRunner } from '../components/EvaluationRunner.js';
import { navigateToPanel } from '../router.js';

window.addEventListener('panel:activated', async (e) => {
  if (e.detail.panelId !== 'evaluation-runner') return;

  const container = document.getElementById('evaluationRunnerContainer');
  if (!container) return;

  const evaluationType = window.selectedEvaluationType;
  if (!evaluationType) {
    container.innerHTML = '<p class="learning-error">Nenhuma avaliação selecionada.</p>';
    return;
  }

  const profile = await getCurrentProfile();
  if (!profile) {
    container.innerHTML = '<p class="learning-error">Faça login para fazer a avaliação.</p>';
    return;
  }

  renderEvaluationRunner(container, evaluationType, {
    onFinished: () => navigateToPanel('certificacao'),
  });
});
