// src/pages/trilhaCompleta.js
// Página dedicada "Trilha Completa" — antes vivia inline dentro do Hero
// Card do Dashboard (toggle "Ver trilha completa" + grade compacta de nós,
// ver histórico de renderMiniTrilha em GpsTrail.js). Virou página própria
// com acordeão por zona + mapa de fases porque a versão inline não tinha
// espaço pra mostrar cada etapa com nome/ícone/estado direito.

import { getCurrentProfile } from '../config/supabase.js';
import { fetchTrilhaPublicada, fetchUserProgress } from '../services/trilhaService.js';
import { renderTrilhaCompletaAccordion, calcularProgresso, proximoCheckpoint } from '../components/GpsTrail.js';
import { navigateToPanel } from '../router.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'trilha-completa') initTrilhaCompletaPage();
});

async function initTrilhaCompletaPage() {
  const root = document.getElementById('trilhaCompletaContainer');
  const progressEl = document.getElementById('trilhaCompletaProgress');
  if (!root) return;

  const brandId = window.selectedBrandId;
  if (!brandId) {
    root.innerHTML = '<p class="learning-error">Escolha uma marca na tela Início primeiro.</p>';
    return;
  }

  root.innerHTML = '<p class="learning-loading">Carregando sua trilha…</p>';
  if (progressEl) progressEl.textContent = '';

  try {
    const profile = await getCurrentProfile();
    if (!profile) {
      root.innerHTML = '<p class="learning-error">Faça login para acompanhar sua trilha.</p>';
      return;
    }

    const { zones } = await fetchTrilhaPublicada(brandId);
    const progressRows = await fetchUserProgress(profile.id);
    const doneCheckpointIds = new Set(
      progressRows.filter((p) => p.status === 'completed').map((p) => p.checkpoint_id)
    );

    const { total, done, pct } = calcularProgresso(zones, doneCheckpointIds);
    if (progressEl) progressEl.textContent = `${done} de ${total} etapas concluídas — ${pct}%`;

    const proximo = proximoCheckpoint(zones, doneCheckpointIds);
    renderTrilhaCompletaAccordion(root, zones, doneCheckpointIds, abrirCheckpoint, proximo?.zone.id ?? null);
  } catch (err) {
    console.error('[TrilhaCompleta] falha ao carregar trilha:', err);
    root.innerHTML = `
      <p class="learning-error">
        Ainda não existe uma trilha publicada para esta marca, ou não foi possível carregá-la agora.
      </p>`;
  }
}

function abrirCheckpoint(checkpoint) {
  const { checkpoint_type, reference_id } = checkpoint;

  if (checkpoint_type === 'module') {
    window.selectedModuleId = reference_id;
    window.moduloConteudoReturnPanel = 'trilha-completa';
    navigateToPanel('modulo-conteudo');
  } else if (checkpoint_type === 'quiz') {
    window.selectedQuizId = reference_id;
    window.quizRunnerReturnPanel = 'trilha-completa';
    navigateToPanel('quiz-runner');
  } else if (checkpoint_type === 'game') {
    window.selectedGameId = reference_id;
    window.gameRunnerReturnPanel = 'trilha-completa';
    navigateToPanel('game-runner');
  }
}
