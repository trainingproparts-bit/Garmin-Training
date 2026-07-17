// src/pages/home.js
// Seleção de marca — só isso. A renderização de dashboard duplicada que
// existia aqui antes (renderizarDashboardInterno(), que reescrevia <main>
// inteiro com HTML/CSS inline próprio, competindo com o painel de
// appShell.js) foi removida: agora clicar numa marca dispara o evento
// "brand:selected", que o appShell escuta para navegar até o painel
// "trilha" — ver src/pages/trilha.js.

import { fetchActiveBrands } from '../services/brandService.js';
import { getCurrentProfile } from '../config/supabase.js';

export async function initHomePage() {
  const welcomeTitle = document.getElementById('welcomeTitle');
  const welcomeText = document.getElementById('welcomeText');
  const brandsContainer = document.getElementById('brandsContainer');

  if (!brandsContainer) return;

  const profile = await getCurrentProfile();

  if (profile) {
    const userName = profile.full_name?.split(' ')[0] || profile.email?.split('@')[0] || 'Parceiro';
    if (welcomeTitle) welcomeTitle.innerHTML = `Bem-vindo de volta, <span>${userName}</span>!`;
    if (welcomeText) welcomeText.innerHTML = 'Você está logado. Seu progresso está sendo salvo.';
  } else {
    if (welcomeTitle) welcomeTitle.innerHTML = 'Olá, <span>Visitante</span>!';
    if (welcomeText) welcomeText.innerHTML = 'Você está conhecendo o Garmin Training Hub. Para salvar seu progresso, faça login.';
  }

  try {
    const { data: brands, error } = await fetchActiveBrands();
    if (error) throw new Error(error);

    brandsContainer.innerHTML = '';

    if (brands && brands.length > 0) {
      brands.forEach((marca) => {
        const card = document.createElement('div');
        card.className = 'brand-card';
        card.innerHTML = `
          <h4 class="brand-card-name">${marca.name}</h4>
          <p class="brand-card-desc">Clique para entrar na sua trilha de treinamento.</p>
          <span class="brand-card-action">Acessar Painel ➔</span>
        `;
        card.addEventListener('click', () => {
          window.dispatchEvent(new CustomEvent('brand:selected', { detail: { id: marca.id, name: marca.name } }));
        });
        brandsContainer.appendChild(card);
      });
    } else {
      brandsContainer.innerHTML = '<p class="home-empty">Nenhuma marca ativa encontrada.</p>';
    }
  } catch (err) {
    console.error('[Home] Erro ao carregar marcas:', err);
    brandsContainer.innerHTML = '<p class="home-error">Erro ao carregar marcas. Verifique a conexão com o banco.</p>';
  }
}
