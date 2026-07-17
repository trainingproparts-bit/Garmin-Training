// src/pages/gameRunner.js
import { getCurrentProfile } from '../config/supabase.js';
import { fetchGameById } from '../services/gameService.js';
import { renderGameRunner } from '../components/GameRunner.js';
import { navigateToPanel } from '../router.js';

window.addEventListener('panel:activated', async (e) => {
  if (e.detail.panelId !== 'game-runner') return;

  const container = document.getElementById('gameRunnerContainer');
  if (!container) return;

  const gameId = window.selectedGameId;
  if (!gameId) {
    container.innerHTML = '<p class="learning-error">Nenhum game selecionado.</p>';
    return;
  }

  const profile = await getCurrentProfile();
  if (!profile) {
    container.innerHTML = '<p class="learning-error">Faça login para jogar.</p>';
    return;
  }

  container.innerHTML = '<p class="learning-loading">Carregando jogo…</p>';
  try {
    const game = await fetchGameById(gameId);
    renderGameRunner(container, game, profile.id, {
      onFinished: () => navigateToPanel(window.gameRunnerReturnPanel || 'arena'),
    });
  } catch (err) {
    console.error('[GameRunner] erro ao carregar game:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar este jogo agora.</p>';
  }
});
