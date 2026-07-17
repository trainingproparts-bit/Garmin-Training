// src/pages/trilha.js
// Substitui src/pages/formacao.js. Duas correções em relação à versão
// anterior:
//  1. formacao.js chamava fetchBrandIdBySlug('garmin') fixo — ou seja,
//     mesmo escolhendo "Shokz" na tela Início, sempre carregava a trilha da
//     Garmin. Agora usa window.selectedBrandId, que é a marca realmente
//     escolhida.
//  2. formacao.js escrevia em #gpsRoute/#gpsHudPercent/etc., elementos que
//     não existiam em appShell.js — a página nunca renderizava (código
//     morto). O painel "trilha" do novo appShell tem um único container
//     (#trilhaContainer) preenchido por este arquivo via DashboardHome.

import { getCurrentProfile, isAdminProfile } from '../config/supabase.js';
import { fetchTrilhaPublicada, fetchUserProgress, fetchModuleProgressMap } from '../services/trilhaService.js';
import { renderDashboardHome } from '../components/DashboardHome.js';
import { navigateToPanel } from '../router.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'trilha') initTrilhaPage();
});

async function initTrilhaPage() {
  const root = document.getElementById('trilhaContainer');
  if (!root) return;

  const brandId = window.selectedBrandId;
  if (!brandId) {
    root.innerHTML = '<p class="learning-error">Escolha uma marca na tela Início primeiro.</p>';
    return;
  }

  root.innerHTML = '<p class="learning-loading">Carregando sua trilha…</p>';

  try {
    const profile = await getCurrentProfile();
    const { trail, zones } = await fetchTrilhaPublicada(brandId);

    if (!profile) {
      renderGuestModuleBrowser(root, zones);
      return;
    }

    const progressRows = await fetchUserProgress(profile.id);
    const doneCheckpointIds = new Set(
      progressRows.filter((p) => p.status === 'completed').map((p) => p.checkpoint_id)
    );

    const moduleIds = zones
      .flatMap((z) => z.checkpoints)
      .filter((c) => c.checkpoint_type === 'module')
      .map((c) => c.reference_id);
    const moduleProgressMap = await fetchModuleProgressMap(moduleIds, profile.id);

    const userName = profile.full_name?.split(' ')[0] || 'Colaborador';

    await renderDashboardHome(
      root,
      { brandName: window.selectedBrandName || 'Garmin', userName, userId: profile.id, avatarUrl: profile.avatar_url, trail, zones, doneCheckpointIds, moduleProgressMap, isAdmin: isAdminProfile(profile) },
      abrirCheckpoint
    );
  } catch (err) {
    console.error('[Trilha] falha ao carregar trilha:', err);
    root.innerHTML = `
      <p class="learning-error">
        Ainda não existe uma trilha publicada para esta marca, ou não foi possível carregá-la agora.
      </p>`;
  }
}

/**
 * Modo visitante: sem perfil não dá pra rastrear checkpoint/quiz/certificação,
 * então em vez do dashboard completo (que depende de userId em toda parte),
 * mostra só uma lista dos módulos por zona, só leitura — clicar abre a lição
 * em modulo-conteudo.js (que já tolera profile nulo, mostra o conteúdo sem
 * progresso). Quiz/games ficam de fora de propósito (dependem de userId pra
 * gravar tentativa) — o pedido era só "visitar os módulos e ler o conteúdo".
 */
function renderGuestModuleBrowser(root, zones) {
  const zonesComModulos = zones
    .map((zone) => ({ zone, modulos: zone.checkpoints.filter((c) => c.checkpoint_type === 'module') }))
    .filter((z) => z.modulos.length);

  root.innerHTML = `
    <div class="guest-trilha-banner">
      <h2>Conheça os módulos do treinamento</h2>
      <p>Você está no modo visitante, pode abrir e ler o conteúdo das lições livremente. Para fazer os quizzes, acumular pontos e conquistar certificações, <button type="button" class="guest-trilha-login-link" data-back-to="login">faça login</button>.</p>
    </div>
    ${zonesComModulos.map(({ zone, modulos }) => `
      <div class="media-row-group">
        <div class="media-row-header"><h3 class="media-row-title">${zone.name}</h3></div>
        <div class="media-row">
          ${modulos.map((m) => `
            <div class="media-card" data-guest-module-id="${m.reference_id}">
              <div class="media-card-thumb media-card-thumb-module">
                ${m.cover_url ? `<img src="${m.cover_url}" alt="">` : '<span class="media-card-thumb-icon">📘</span>'}
              </div>
              <div class="media-card-body">
                <div class="media-card-title">${m.title}</div>
              </div>
            </div>`).join('')}
        </div>
      </div>`).join('')}
  `;

  root.querySelectorAll('[data-guest-module-id]').forEach((card) => {
    card.addEventListener('click', () => {
      window.selectedModuleId = card.dataset.guestModuleId;
      window.moduloConteudoReturnPanel = 'trilha';
      navigateToPanel('modulo-conteudo');
    });
  });
}

function abrirCheckpoint(checkpoint) {
  const { checkpoint_type, reference_id } = checkpoint;

  if (checkpoint_type === 'module') {
    window.selectedModuleId = reference_id;
    window.moduloConteudoReturnPanel = 'trilha';
    navigateToPanel('modulo-conteudo');
  } else if (checkpoint_type === 'quiz') {
    window.selectedQuizId = reference_id;
    window.quizRunnerReturnPanel = 'trilha';
    navigateToPanel('quiz-runner');
  } else if (checkpoint_type === 'game') {
    window.selectedGameId = reference_id;
    window.gameRunnerReturnPanel = 'trilha';
    navigateToPanel('game-runner');
  }
}
