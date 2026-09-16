// src/pages/home.js
// Seleção de marca — só isso. A renderização de dashboard duplicada que
// existia aqui antes (renderizarDashboardInterno(), que reescrevia <main>
// inteiro com HTML/CSS inline próprio, competindo com o painel de
// appShell.js) foi removida: agora clicar numa marca dispara o evento
// "brand:selected", que o appShell escuta para navegar até o painel
// "trilha" — ver src/pages/trilha.js.
//
// V2 (2026-09-16): portal de entrada centralizado. Cada card passou a
// mostrar o progresso REAL da trilha daquela marca, em vez do texto fixo
// "Clique para entrar na sua trilha de treinamento" que não dizia nada.

import { fetchActiveBrands, updateBrandLogo } from '../services/brandService.js';
import { getCurrentProfile, isAdminProfile } from '../config/supabase.js';
import { openImageEditModal } from '../components/ImageEditModal.js';
import { navigateToPanel } from '../router.js';
import { fetchTrilhaPublicada, fetchUserProgress } from '../services/trilhaService.js';
import { calcularProgresso } from '../components/GpsTrail.js';
import { icon } from '../components/icons.js';
import { setupReveal, animateProgressFills, fadeOutPanel } from '../components/motion.js';

/**
 * Progresso real por marca. Só é calculado para quem está logado (visitante
 * não tem progresso) e só aparece quando a marca realmente tem trilha
 * publicada — sem trilha, o card não mostra barra nenhuma em vez de fingir
 * 0%. Uma marca que falhe ao carregar não derruba as outras.
 *
 * @returns {Promise<Map<string, {pct: number, done: number, total: number}>>}
 */
async function fetchProgressoPorMarca(brands, profileId) {
  if (!profileId) return new Map();

  const progressRows = await fetchUserProgress(profileId);
  const doneCheckpointIds = new Set(
    progressRows.filter((p) => p.status === 'completed').map((p) => p.checkpoint_id)
  );

  const entries = await Promise.all(brands.map(async (marca) => {
    try {
      const { zones: todasZonas } = await fetchTrilhaPublicada(marca.id);
      // Mesmo recorte da Trilha Completa: zonas de ordem livre (Arena) ficam
      // de fora da contagem da trilha sequencial.
      const zones = (todasZonas || []).filter((zone) => !zone.free_order);
      if (!zones.length) return null;
      return [marca.id, calcularProgresso(zones, doneCheckpointIds)];
    } catch (err) {
      console.error(`[Home] progresso indisponível para a marca ${marca.name}:`, err);
      return null;
    }
  }));

  return new Map(entries.filter(Boolean));
}

function brandEmblemHtml(marca) {
  // `has-logo` deixa a caixa mais larga: logo de marca costuma ser wordmark
  // (deitado), e num quadrado de 64px ele encolheria a ponto de não se ler.
  if (marca.logo_url) {
    return `<div class="brand-card-emblem has-logo"><img src="${marca.logo_url}" alt="${marca.name}"></div>`;
  }
  const inicial = (marca.name || '?').trim().charAt(0).toUpperCase();
  return `<div class="brand-card-emblem" aria-hidden="true">${inicial}</div>`;
}

function brandProgressHtml(marca, progresso) {
  if (!progresso) return '';
  // Sem repetir o nome da marca aqui (2026-09-16, pedido do usuário): o card
  // já tem o nome como título logo acima, então "Trilha Garmin" dentro do
  // card da Garmin era a mesma palavra duas vezes.
  return `
    <div class="brand-card-progress">
      <span class="brand-card-progress-label">Trilha: <strong>${progresso.pct}% concluída</strong></span>
      <span class="brand-card-progress-track">
        <span class="brand-card-progress-fill" data-animate-progress style="width:${progresso.pct}%"></span>
      </span>
    </div>`;
}

export async function initHomePage() {
  const welcomeTitle = document.getElementById('welcomeTitle');
  const welcomeText = document.getElementById('welcomeText');
  const brandsContainer = document.getElementById('brandsContainer');
  const portal = document.getElementById('homePortal');

  if (!brandsContainer) return;

  const profile = await getCurrentProfile();

  if (profile) {
    const userName = profile.full_name?.split(' ')[0] || profile.email?.split('@')[0] || 'Parceiro';
    if (welcomeTitle) welcomeTitle.innerHTML = `Bem-vindo de volta, <span>${userName}</span>!`;
  } else {
    if (welcomeTitle) welcomeTitle.innerHTML = 'Olá, <span>Visitante</span>!';
  }
  if (welcomeText) welcomeText.textContent = 'Selecione a marca para acessar seu painel de treinamento:';

  // Visitante precisa de um caminho de volta pro login: a frase antiga
  // ("Para salvar seu progresso, faça login") era a única pista, e ela saiu
  // quando o subtítulo virou instrução de seleção. Quem já está logado não vê
  // nada aqui — sair é pelo menu do avatar.
  const loginCta = document.getElementById('homeLoginCta');
  if (loginCta) {
    if (profile) {
      loginCta.hidden = true;
      loginCta.innerHTML = '';
    } else {
      loginCta.hidden = false;
      loginCta.innerHTML = `
        <p class="home-login-cta-text">Você está no modo visitante, seu progresso não fica salvo.</p>
        <button type="button" class="home-login-cta-btn" data-role="ir-para-login">
          Entrar na minha conta
          <span class="home-login-cta-icon">${icon('chevronDown')}</span>
        </button>`;
      loginCta.querySelector('[data-role="ir-para-login"]')
        ?.addEventListener('click', () => navigateToPanel('login'));
    }
  }

  try {
    const { data: brands, error } = await fetchActiveBrands();
    if (error) throw new Error(error);

    if (!brands || !brands.length) {
      brandsContainer.innerHTML = '<p class="home-empty">Nenhuma marca ativa encontrada.</p>';
      return;
    }

    const progressoPorMarca = await fetchProgressoPorMarca(brands, profile?.id);

    const isAdmin = isAdminProfile(profile);

    brandsContainer.innerHTML = brands.map((marca) => `
      <div class="brand-card${marca.logo_url ? ' has-logo' : ''}" data-reveal data-brand-id="${marca.id}" role="button" tabindex="0" aria-label="Acessar painel ${marca.name}">
        ${isAdmin ? `<button type="button" class="brand-card-logo-btn" data-edit-logo="${marca.id}" title="Editar logo" aria-label="Editar logo da ${marca.name}">${icon('pencil')}</button>` : ''}
        ${brandEmblemHtml(marca)}
        <h4 class="brand-card-name">${marca.name}</h4>
        <p class="brand-card-desc">Trilha de treinamento e conteúdos da marca.</p>
        ${brandProgressHtml(marca, progressoPorMarca.get(marca.id))}
        <span class="brand-card-action">
          Acessar Painel
          <span class="brand-card-action-icon">${icon('chevronDown')}</span>
        </span>
      </div>`).join('');

    // Cascata em ordem de DOM dentro do portal: boas-vindas (0s), primeiro
    // card (0.1s), segundo card (0.2s).
    setupReveal(portal || brandsContainer, { stagger: 0.1 });
    animateProgressFills(brandsContainer);

    brandsContainer.querySelectorAll('[data-edit-logo]').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation(); // não deixa o clique abrir o painel da marca
        const marca = brands.find((b) => b.id === btn.dataset.editLogo);
        openImageEditModal({
          title: `Logo da ${marca.name}`,
          currentUrl: marca.logo_url || '',
          folder: 'marcas',
          onSave: async (url) => {
            await updateBrandLogo(marca.id, url);
            await initHomePage();
          },
        });
      });
    });

    brandsContainer.querySelectorAll('[data-brand-id]').forEach((card) => {
      const abrir = async () => {
        const marca = brands.find((b) => b.id === card.dataset.brandId);
        if (!marca) return;
        await fadeOutPanel(portal);
        window.dispatchEvent(new CustomEvent('brand:selected', { detail: { id: marca.id, name: marca.name } }));
      };

      card.addEventListener('click', abrir);
      card.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          abrir();
        }
      });
    });
  } catch (err) {
    console.error('[Home] Erro ao carregar marcas:', err);
    brandsContainer.innerHTML = '<p class="home-error">Erro ao carregar marcas. Verifique a conexão com o banco.</p>';
  }
}
