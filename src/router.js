// src/router.js
// Navegação central do app — único lugar que sabe como trocar de painel.
// Antes desta sprint, appShell.js definia essa lógica internamente e
// src/pages/cursos.js importava navigateToPanel de dentro de appShell.js
// (layout e navegação misturados no mesmo arquivo). Agora qualquer página
// importa só daqui, e appShell.js cuida apenas de montar o HTML do shell.

const PANEL_SELECTOR = '.panel';
const NAV_LINK_SELECTOR = '.sb-link[data-panel]';

/** Painéis que só aparecem na navegação depois que uma marca foi escolhida. */
const BRAND_SCOPED_PANELS = new Set(['trilha', 'arena', 'certificacao', 'biblioteca', 'ranking', 'album', 'academia-produtos']);

/** Painéis "de entrada" (login/escolha de marca) — o sidebar só aparece depois deles, dentro do dashboard. */
const NO_SIDEBAR_PANELS = new Set(['login', 'home']);

let activePanelId = null;

export function navigateToPanel(panelId) {
  const panels = document.querySelectorAll(PANEL_SELECTOR);
  const navLinks = document.querySelectorAll(NAV_LINK_SELECTOR);
  const sidebar = document.getElementById('appSidebar');
  const topbar = document.getElementById('appTopbar');

  panels.forEach((panel) => {
    const isTarget = panel.dataset.panel === panelId;
    panel.classList.toggle('active', isTarget);
    panel.hidden = !isTarget;
  });

  navLinks.forEach((link) => {
    link.classList.toggle('active', link.dataset.panel === panelId);
  });

  // sidebar/topbar seguem só o painel ativo (login/home escondem os dois) —
  // não dependem de perfil, senão vira corrida com updateSidebarProfile()
  // (achado ao testar: o topbar aparecia na tela de escolha de marca porque
  // updateSidebarProfile() resolvia depois e revelava incondicionalmente).
  const hideChrome = NO_SIDEBAR_PANELS.has(panelId);
  if (sidebar) sidebar.hidden = hideChrome;
  if (topbar) topbar.hidden = hideChrome;

  activePanelId = panelId;
  window.dispatchEvent(new CustomEvent('panel:activated', { detail: { panelId } }));
}

export function getActivePanelId() {
  return activePanelId;
}

/** Mostra na sidebar os links que só fazem sentido depois de escolher uma marca. */
export function revealBrandScopedNav() {
  BRAND_SCOPED_PANELS.forEach((id) => {
    const link = document.querySelector(`.sb-link[data-panel="${id}"]`);
    if (link) link.hidden = false;
  });
}

export function hideBrandScopedNav() {
  BRAND_SCOPED_PANELS.forEach((id) => {
    const link = document.querySelector(`.sb-link[data-panel="${id}"]`);
    if (link) link.hidden = true;
  });
}

export function initPanelNavigation() {
  document.querySelectorAll(NAV_LINK_SELECTOR).forEach((link) => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      navigateToPanel(link.dataset.panel);
    });
  });

  document.addEventListener('click', (e) => {
    const backBtn = e.target.closest('[data-back-to]');
    if (!backBtn) return;
    navigateToPanel(backBtn.dataset.backTo);
  });

  // Painéis alcançáveis por mais de uma origem (Dashboard, Arena, Trilha
  // Completa, Biblioteca, editor de conteúdo do admin) não podem usar
  // data-back-to estático — cada chamador grava a própria origem numa
  // variável global antes de navegar pra cá (mesmo padrão já usado por
  // quizRunnerReturnPanel desde antes desta correção), e o botão de voltar
  // lê essa variável na hora do clique em vez de um destino fixo.
  document.getElementById('quizRunnerBackBtn')?.addEventListener('click', () => {
    navigateToPanel(window.quizRunnerReturnPanel || 'trilha');
  });
  document.getElementById('gameRunnerBackBtn')?.addEventListener('click', () => {
    navigateToPanel(window.gameRunnerReturnPanel || 'arena');
  });
  document.getElementById('moduloConteudoBackBtn')?.addEventListener('click', () => {
    navigateToPanel(window.moduloConteudoReturnPanel || 'trilha');
  });
  document.getElementById('deepDiveBackBtn')?.addEventListener('click', () => {
    navigateToPanel(window.deepDiveReturnPanel || 'biblioteca');
  });

  // Academia de Produtos: produto e comparativo são alcançáveis de várias
  // origens (lista principal, busca global, links de "Relacionados", e um
  // comparativo pode levar a outro produto e vice-versa) — mesmo padrão de
  // return-panel dinâmico acima, em vez de data-back-to estático.
  document.getElementById('academiaProdutoDetailBackBtn')?.addEventListener('click', () => {
    navigateToPanel(window.academiaReturnPanel || 'academia-produtos');
  });
  document.getElementById('academiaComparativoBackBtn')?.addEventListener('click', () => {
    navigateToPanel(window.academiaReturnPanel || 'academia-produtos');
  });
}
