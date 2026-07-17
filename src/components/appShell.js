/**
 * App Shell — estrutura base unificada do Garmin Training Hub.
 *
 * Sprint 1 (consolidação): este arquivo agora cuida SÓ de montar o HTML do
 * shell (sidebar, painéis) e de reagir a eventos de perfil/auth. Sem faixa
 * de header fixa no topo — só o sidebar (dentro do dashboard) carrega
 * identidade visual, evitando repetir chrome de marca em duas camadas. A
 * navegação entre painéis vive em src/router.js — antes, appShell.js definia
 * navigateToPanel() internamente e outras páginas importavam essa função
 * "emprestada" dele, misturando layout e navegação no mesmo arquivo.
 *
 * A navegação da sidebar agora é gerada a partir de NAV_ITEMS em vez de
 * links <a href="#"> soltos sem data-panel — antes existiam 5 links mortos
 * (Games, Quizzes, Formação, Certificações, Ferramentas) que não levavam a
 * lugar nenhum.
 */

import { initLoginPage } from '../pages/login.js';
import { getCurrentProfile, isLeaderProfile, isAdminProfile } from '../config/supabase.js';
import { signOut } from '../services/authService.js';
import { initPanelNavigation, navigateToPanel, getActivePanelId, revealBrandScopedNav, hideBrandScopedNav } from '../router.js';
import { icon } from './icons.js';
import { fetchUserNotifications, countUnreadNotifications, markAsRead } from '../services/notificationService.js';
import { searchAll } from '../services/searchService.js';

const SIDEBAR_COLLAPSE_KEY = 'gth-sidebar-collapsed';

const NAV_ITEMS = [
  // "Início" saiu do menu — era redundante com "Trocar de marca" (mesmo
  // destino, panel 'home'). O painel e os "← Início" continuam existindo,
  // só não tem mais link fixo na sidebar pra ele.
  { id: 'trilha', iconKey: 'trilha', label: 'Dashboard', brandScoped: true },
  { id: 'arena', iconKey: 'arena', label: 'Arena de Desafios', brandScoped: true },
  { id: 'certificacao', iconKey: 'certificacao', label: 'Certificações', brandScoped: true },
  { id: 'biblioteca', iconKey: 'biblioteca', label: 'Biblioteca Técnica', brandScoped: true },
  { id: 'ranking', iconKey: 'ranking', label: 'Ranking', brandScoped: true },
  { id: 'album', iconKey: 'album', label: 'Álbum da Equipe', brandScoped: true },
  { id: 'blog', iconKey: 'blog', label: 'Blog', brandScoped: false },
  // Não são brandScoped: visão de líder/admin é por loja/organização, não
  // por marca/trilha em andamento. Ficam escondidas até o papel ser
  // resolvido (updateSidebarProfile) — nunca é o client que autoriza o
  // acesso aos dados, só decide o que aparece no menu; quem barra de
  // verdade é a RLS (profiles_select_leader, fn_is_admin()...).
  // location: 'avatar' — a sidebar tava ficando comprida demais (precisava
  // de scroll); esses 3 saíram do sb-nav e foram pro menu do avatar no
  // topbar (mesmo padrão do notif-dropdown). Continuam classe .sb-link +
  // data-panel, só mudou ONDE são renderizados — clique/estado ativo/
  // visibilidade por papel (revealRoleScopedNav) seguem funcionando sem
  // nenhuma mudança em router.js, porque os seletores são por classe/
  // atributo, não por posição no DOM.
  { id: 'lider', iconKey: 'lider', label: 'Dashboard do Líder', brandScoped: false, rolesAllowed: ['leader', 'admin'], location: 'avatar' },
  { id: 'relatorios', iconKey: 'relatorios', label: 'Relatórios', brandScoped: false, rolesAllowed: ['leader', 'admin'], location: 'avatar' },
  { id: 'admin', iconKey: 'admin', label: 'Painel Admin', brandScoped: false, rolesAllowed: ['admin'], location: 'avatar' },
  { id: 'gestora', iconKey: 'gestora', label: 'Painel da Gestora', brandScoped: false, rolesAllowed: ['admin'], location: 'avatar' },
  { id: 'homologacao', iconKey: 'certificacao', label: 'Homologação Semanal', brandScoped: false, rolesAllowed: ['admin'], location: 'avatar' },
];

const SIDEBAR_NAV_ITEMS = NAV_ITEMS.filter((item) => item.location !== 'avatar');
const AVATAR_NAV_ITEMS = NAV_ITEMS.filter((item) => item.location === 'avatar');

/** Lido de forma síncrona antes do primeiro render — evita flash de sidebar expandida antes de colapsar. */
function readSidebarCollapsed() {
  try {
    return localStorage.getItem(SIDEBAR_COLLAPSE_KEY) === '1';
  } catch {
    return false;
  }
}

export function renderAppShell(container) {
  const collapsed = readSidebarCollapsed();

  container.innerHTML = `
    <div id="appShell">
      <aside class="app-sidebar${collapsed ? ' collapsed' : ''}" id="appSidebar" aria-label="Navegação principal" hidden>
        <div class="sb-brand">
          <img src="/logo-preto.png" alt="Proparts" class="sb-brand-logo">
          <span class="sb-brand-monogram">P</span>
          <div class="sb-brand-divider"></div>
          <div class="sb-brand-label">Training <span>Hub</span></div>
        </div>

        <button type="button" class="sb-collapse-btn" id="sbCollapseBtn" aria-label="Recolher/expandir menu">
          ${icon(collapsed ? 'panelExpand' : 'panelCollapse')}
        </button>

        <nav class="sb-nav" id="sbNav">
          ${SIDEBAR_NAV_ITEMS.map((item) => `
            <a class="sb-link" href="#" data-panel="${item.id}" title="${item.label}" ${(item.brandScoped || item.rolesAllowed) ? 'hidden' : ''}>
              <span class="sb-icon">${icon(item.iconKey)}</span><span class="sb-label">${item.label}</span>
            </a>
          `).join('')}
          <a class="sb-link sb-link-muted" href="#" data-panel="home" title="Trocar de marca">
            <span class="sb-icon">${icon('switchBrand')}</span><span class="sb-label">Trocar de marca</span>
          </a>
        </nav>

        <div class="sb-quick-access" id="sbQuickAccess">
          <div class="sb-quick-access-label">Acesso Rápido</div>
          <button type="button" class="sb-link sb-quick-link" id="qaUltimaAtividade" title="Última Atividade">
            <span class="sb-icon">${icon('trilha')}</span><span class="sb-label">Última Atividade</span>
          </button>
          <button type="button" class="sb-link sb-quick-link" id="qaNovidades" title="Novidades">
            <span class="sb-icon">${icon('blog')}</span><span class="sb-label">Novidades</span>
          </button>
          <button type="button" class="sb-link sb-quick-link" id="qaFaq" title="FAQ">
            <span class="sb-icon">${icon('quizzes')}</span><span class="sb-label">FAQ</span>
          </button>
        </div>

        <div class="sb-footer">
          <div class="sb-profile">
            <div class="sb-profile-info">
              <div class="sb-profile-name" id="sbProfileName">Visitante</div>
              <div class="sb-profile-level" id="sbProfileLevel">–</div>
            </div>
          </div>
        </div>
      </aside>

      <main class="app-main">
        <div class="app-topbar" id="appTopbar" hidden>
          <div class="topbar-search-wrap" id="topbarSearchWrap">
            <input type="search" class="topbar-search-input" id="topbarSearchInput"
              placeholder="Buscar produtos, guias, módulos…" autocomplete="off" aria-label="Busca global">
            <div class="topbar-search-dropdown" id="topbarSearchDropdown" hidden></div>
          </div>
          <div class="app-topbar-spacer"></div>
          <div class="app-topbar-right">
            <div class="notif-bell-wrap">
              <button type="button" class="notif-bell-btn" id="notifBellBtn" aria-label="Notificações">
                ${icon('bell')}
                <span class="notif-badge" id="notifBadge" hidden>0</span>
              </button>
              <div class="notif-dropdown" id="notifDropdown" hidden>
                <div class="notif-dropdown-header">Notificações</div>
                <div class="notif-dropdown-list" id="notifList">
                  <p class="dash-empty-text">Carregando…</p>
                </div>
              </div>
            </div>
            <div class="avatar-menu-wrap" id="avatarMenuWrap">
              <button type="button" class="app-topbar-avatar" id="topbarAvatar" aria-label="Menu do usuário">?</button>
              <div class="avatar-dropdown" id="avatarDropdown" hidden>
                <div class="avatar-dropdown-header">
                  <div class="avatar-dropdown-name" id="avatarDropdownName">Visitante</div>
                  <div class="avatar-dropdown-role" id="avatarDropdownRole">Sem sessão</div>
                </div>
                <div class="avatar-dropdown-links">
                  ${AVATAR_NAV_ITEMS.map((item) => `
                    <a class="sb-link avatar-dropdown-link" href="#" data-panel="${item.id}" hidden>
                      <span class="sb-icon">${icon(item.iconKey)}</span><span class="sb-label">${item.label}</span>
                    </a>
                  `).join('')}
                  ${AVATAR_NAV_ITEMS.length ? '<div class="avatar-dropdown-divider"></div>' : ''}
                  <button type="button" id="darkModeBtn" class="avatar-dropdown-action">
                    <span class="sb-icon">${icon('moon')}</span><span class="sb-label">Modo escuro</span>
                  </button>
                  <button type="button" id="logoutBtn" class="avatar-dropdown-action avatar-dropdown-logout" hidden>
                    <span class="sb-icon">${icon('logout')}</span><span class="sb-label">Sair</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="panel-stack" id="panelStack">

          <div class="panel" id="panel-login" data-panel="login">
            <div class="panel-body login-panel-body">
              <div id="loginContainer"></div>
            </div>
          </div>

          <div class="panel" id="panel-home" data-panel="home" hidden>
            <div class="panel-header">
              <div class="panel-title"><span>Início</span></div>
            </div>
            <div class="panel-body">
              <div class="home-welcome">
                <h2 id="welcomeTitle">Olá, Visitante! ✨</h2>
                <p id="welcomeText">Você está conhecendo o Garmin Training Hub. Para salvar seu progresso, faça login.</p>
              </div>
              <div class="home-brands-section">
                <h3 class="home-section-title">Marcas Disponíveis</h3>
                <div id="brandsContainer" class="home-brands-grid">
                  <p class="home-loading">Carregando marcas...</p>
                </div>
              </div>
            </div>
          </div>

          <div class="panel" id="panel-trilha" data-panel="trilha" hidden>
            <div class="panel-body" id="trilhaContainer">
              <p class="learning-loading">Carregando sua trilha…</p>
            </div>
          </div>

          <div class="panel" id="panel-trilha-completa" data-panel="trilha-completa" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" data-back-to="trilha">← Voltar</button>
              <div class="panel-title has-progress">
                <span>Sua Trilha Completa</span>
                <div class="panel-title-progress" id="trilhaCompletaProgress"></div>
              </div>
            </div>
            <div class="panel-body" id="trilhaCompletaContainer">
              <p class="learning-loading">Carregando sua trilha…</p>
            </div>
          </div>

          <div class="panel" id="panel-arena" data-panel="arena" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" data-back-to="trilha">← Dashboard</button>
              <div class="panel-title"><span>Arena de Desafios</span></div>
            </div>
            <div class="panel-body" id="arenaContainer"></div>
          </div>

          <div class="panel" id="panel-quiz-runner" data-panel="quiz-runner" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" id="quizRunnerBackBtn">← Voltar</button>
              <div class="panel-title">Quiz</div>
            </div>
            <div class="panel-body" id="quizRunnerContainer"></div>
          </div>

          <div class="panel" id="panel-game-runner" data-panel="game-runner" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" id="gameRunnerBackBtn">← Voltar</button>
              <div class="panel-title">Duelo</div>
            </div>
            <div class="panel-body" id="gameRunnerContainer"></div>
          </div>

          <div class="panel" id="panel-certificacao" data-panel="certificacao" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" data-back-to="trilha">← Dashboard</button>
              <div class="panel-title"><span>Certificações</span></div>
            </div>
            <div class="panel-body" id="certificacaoContainer"></div>
          </div>

          <div class="panel" id="panel-evaluation-runner" data-panel="evaluation-runner" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" data-back-to="certificacao">← Voltar</button>
              <div class="panel-title">Avaliação Trimestral</div>
            </div>
            <div class="panel-body" id="evaluationRunnerContainer"></div>
          </div>

          <div class="panel" id="panel-biblioteca" data-panel="biblioteca" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" data-back-to="trilha">← Dashboard</button>
              <div class="panel-title"><span>Biblioteca Técnica</span></div>
            </div>
            <div class="panel-body">
              <div class="lib-tabs" id="bibliotecaTabs"></div>
              <div id="bibliotecaContainer"></div>
            </div>
          </div>

          <div class="panel" id="panel-ranking" data-panel="ranking" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" data-back-to="trilha">← Dashboard</button>
              <div class="panel-title"><span>Ranking</span></div>
            </div>
            <div class="panel-body" id="rankingContainer"></div>
          </div>

          <div class="panel" id="panel-album" data-panel="album" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" data-back-to="trilha">← Dashboard</button>
              <div class="panel-title"><span>Álbum da Equipe</span></div>
            </div>
            <div class="panel-body" id="albumContainer"></div>
          </div>

          <div class="panel" id="panel-blog" data-panel="blog" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" data-back-to="home">← Início</button>
              <div class="panel-title"><span>Blog</span></div>
            </div>
            <div class="panel-body" id="blogContainer"></div>
          </div>

          <div class="panel" id="panel-lider" data-panel="lider" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" data-back-to="home">← Início</button>
              <div class="panel-title"><span>Dashboard do Líder</span></div>
            </div>
            <div class="panel-body" id="liderContainer"></div>
          </div>

          <div class="panel" id="panel-relatorios" data-panel="relatorios" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" data-back-to="home">← Início</button>
              <div class="panel-title"><span>Relatório de Gaps da Equipe</span></div>
            </div>
            <div class="panel-body" id="relatoriosContainer"></div>
          </div>

          <div class="panel" id="panel-admin" data-panel="admin" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" data-back-to="home">← Início</button>
              <div class="panel-title"><span>Painel Admin</span></div>
            </div>
            <div class="panel-body" id="adminContainer"></div>
          </div>

          <div class="panel" id="panel-gestora" data-panel="gestora" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" data-back-to="home">← Início</button>
              <div class="panel-title"><span>Painel da Gestora</span></div>
            </div>
            <div class="panel-body" id="gestoraContainer"></div>
          </div>

          <div class="panel" id="panel-homologacao" data-panel="homologacao" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" data-back-to="home">← Início</button>
              <div class="panel-title"><span>Homologação Semanal</span></div>
            </div>
            <div class="panel-body" id="homologacaoContainer"></div>
          </div>

          <div class="panel" id="panel-modulo-conteudo" data-panel="modulo-conteudo" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" id="moduloConteudoBackBtn">← Voltar</button>
              <div class="panel-title"><span id="moduloTitle">Módulo</span></div>
            </div>
            <div class="panel-body">
              <div id="moduloContentContainer" class="modulo-content-container">
                <p class="home-loading">Carregando conteúdo...</p>
              </div>
            </div>
          </div>

          <div class="panel" id="panel-deep-dive-detail" data-panel="deep-dive-detail" hidden>
            <div class="panel-header">
              <button type="button" class="back-btn" id="deepDiveBackBtn">← Voltar</button>
              <div class="panel-title"><span id="deepDiveDetailTitle">Guia Técnico</span></div>
            </div>
            <div class="panel-body">
              <div id="deepDiveDetailContainer" class="deep-dive-detail-container">
                <p class="home-loading">Carregando conteúdo...</p>
              </div>
            </div>
          </div>

        </div>
      </main>
    </div>
  `;

  initPanelNavigation();
  initLoginPage();
  setupAuthListeners();
  updateSidebarProfile();
  setupLogoutButton();
  setupDarkModeButton();
  setupSidebarCollapse();
  setupQuickAccess();
  setupNotificationBell();
  setupAvatarMenu();
  setupGlobalSearch();
}

function setupAuthListeners() {
  window.addEventListener('auth:login-success', () => {
    navigateToPanel('home');
    updateSidebarProfile();
  });

  window.addEventListener('auth:guest-access', () => {
    navigateToPanel('home');
  });

  window.addEventListener('brand:selected', (e) => {
    const { id, name } = e.detail;
    window.selectedBrandId = id;
    window.selectedBrandName = name;
    revealBrandScopedNav();
    navigateToPanel('trilha');
  });
}

/** Preenche o avatar do topbar com a foto (profiles.avatar_url) quando existir, senão a inicial colorida — com fallback pra inicial se a URL falhar ao carregar. */
function setAvatarContent(el, avatarUrl, fallbackText) {
  if (!el) return;
  if (avatarUrl) {
    el.innerHTML = `<img src="${avatarUrl}" alt="" class="app-topbar-avatar-img">`;
    el.querySelector('img').addEventListener('error', () => { el.textContent = fallbackText; }, { once: true });
  } else {
    el.textContent = fallbackText;
  }
}

async function updateSidebarProfile() {
  const nameEl = document.getElementById('sbProfileName');
  const levelEl = document.getElementById('sbProfileLevel');
  const logoutBtn = document.getElementById('logoutBtn');
  const topbarAvatarEl = document.getElementById('topbarAvatar');
  const avatarDropdownNameEl = document.getElementById('avatarDropdownName');
  const avatarDropdownRoleEl = document.getElementById('avatarDropdownRole');

  if (!nameEl || !levelEl || !logoutBtn) return;

  const profile = await getCurrentProfile();

  if (profile) {
    const firstName = profile.full_name?.split(' ')[0] || profile.email?.split('@')[0] || 'Usuário';
    const initial = firstName.charAt(0).toUpperCase();
    // O avatar da sidebar foi removido (duplicava o do topbar sem propósito
    // próprio — pedido do usuário) — só o avatar do topbar mostra a inicial
    // (ou a foto de profiles.avatar_url, quando a pessoa define uma em
    // Álbum da Equipe → "Editar minha figurinha").
    setAvatarContent(topbarAvatarEl, profile.avatar_url, initial);
    if (avatarDropdownNameEl) avatarDropdownNameEl.textContent = firstName;
    if (avatarDropdownRoleEl) {
      avatarDropdownRoleEl.textContent = isAdminProfile(profile) ? 'Admin' : isLeaderProfile(profile) ? 'Líder' : 'Colaborador';
    }
    nameEl.textContent = firstName;
    // Sprint 3: passou a ler profiles.performance_score (Score de Performance)
    // — o antigo profile.level nunca existiu no schema real, sempre caía no
    // fallback "Nível 1", o que dava a falsa impressão de nível fixo.
    levelEl.textContent = formatScore(profile.performance_score);
    logoutBtn.hidden = false;
    refreshNotificationBadge(profile.id);
  } else {
    setAvatarContent(topbarAvatarEl, null, '?');
    if (avatarDropdownNameEl) avatarDropdownNameEl.textContent = 'Visitante';
    if (avatarDropdownRoleEl) avatarDropdownRoleEl.textContent = 'Sem sessão';
    nameEl.textContent = 'Visitante';
    levelEl.textContent = 'Sem sessão';
    // Visitante não tem sessão real, mas precisa de uma saída visível — sem
    // isso ficava preso no modo visitante sem jeito de voltar ao login.
    logoutBtn.hidden = false;
  }

  revealRoleScopedNav(profile);
}

/**
 * Mostra na sidebar os itens de nav restritos por papel (Dashboard do
 * Líder, Painel Admin). Só controla visibilidade do link — quem barra o
 * acesso de verdade é a RLS de cada tabela consultada pelas páginas.
 */
function revealRoleScopedNav(profile) {
  const role = isAdminProfile(profile) ? 'admin' : isLeaderProfile(profile) ? 'leader' : null;

  NAV_ITEMS.filter((item) => item.rolesAllowed).forEach((item) => {
    document.querySelectorAll(`.sb-link[data-panel="${item.id}"]`).forEach((link) => {
      link.hidden = !(role && item.rolesAllowed.includes(role));
    });
  });
}

function formatScore(score) {
  const n = Number.isFinite(score) ? score : 0;
  return `Score ${n} pts`;
}

// Sprint 3: outras páginas (moduloConteudo, futura quiz-runner com pontos)
// disparam este evento após qualquer ação que altere o Score de Performance.
// Atualiza SÓ o texto do score, sem refetch de profile inteiro nem repintar
// avatar/name (que não mudaram).
window.addEventListener('profile:score-updated', (e) => {
  const levelEl = document.getElementById('sbProfileLevel');
  if (!levelEl) return;
  const next = e.detail?.performance_score;
  if (Number.isFinite(next)) levelEl.textContent = formatScore(next);
});

function setupDarkModeButton() {
  const btn = document.getElementById('darkModeBtn');
  const label = btn?.querySelector('.sb-label');
  if (!btn || !label) return;

  btn.addEventListener('click', () => {
    document.body.classList.toggle('dark-mode');
    const isDark = document.body.classList.contains('dark-mode');
    label.textContent = isDark ? 'Modo claro' : 'Modo escuro';
  });
}

/** Colapsa/expande a sidebar pra icon-only, persistindo em localStorage (lido de forma síncrona em readSidebarCollapsed() no próximo carregamento). */
function setupSidebarCollapse() {
  const btn = document.getElementById('sbCollapseBtn');
  const sidebar = document.getElementById('appSidebar');
  if (!btn || !sidebar) return;

  btn.addEventListener('click', () => {
    const collapsed = sidebar.classList.toggle('collapsed');
    btn.innerHTML = icon(collapsed ? 'panelExpand' : 'panelCollapse');
    try {
      localStorage.setItem(SIDEBAR_COLLAPSE_KEY, collapsed ? '1' : '0');
    } catch {
      // localStorage indisponível (modo privado etc.) — colapso ainda funciona, só não persiste.
    }
  });
}

/**
 * Atalhos fixos da sidebar — "Favoritos" (citado como exemplo pelo usuário)
 * foi substituído por "Novidades" porque não existe sistema de favoritos no
 * schema; os 3 atalhos aqui apontam pra funcionalidade real já existente.
 */
function setupQuickAccess() {
  document.getElementById('qaUltimaAtividade')?.addEventListener('click', () => {
    navigateToPanel('trilha');
  });

  document.getElementById('qaNovidades')?.addEventListener('click', () => {
    navigateToPanel('blog');
  });

  document.getElementById('qaFaq')?.addEventListener('click', () => {
    window.selectedLibraryCategory = 'faq';
    navigateToPanel('biblioteca');
  });
}

/**
 * Menu do avatar no topbar — abriga Dashboard do Líder / Relatórios / Painel
 * Admin, Modo escuro e Sair (todos saíram da sidebar pra ela não precisar de
 * scroll). Mesmo padrão do notif-dropdown: toggle no clique, fecha ao clicar
 * fora. Os links de painel já são .sb-link[data-panel] normais
 * (initPanelNavigation cuida do clique de navegação); darkModeBtn/logoutBtn
 * têm seus próprios listeners (setupDarkModeButton/setupLogoutButton) — aqui
 * só fecha o dropdown depois que qualquer item de dentro é clicado.
 */
function setupAvatarMenu() {
  const btn = document.getElementById('topbarAvatar');
  const dropdown = document.getElementById('avatarDropdown');
  if (!btn || !dropdown) return;

  btn.addEventListener('click', (e) => {
    e.stopPropagation();
    dropdown.hidden = !dropdown.hidden;
  });

  dropdown.querySelectorAll('.avatar-dropdown-link, .avatar-dropdown-action').forEach((el) => {
    el.addEventListener('click', () => { dropdown.hidden = true; });
  });

  document.addEventListener('click', (e) => {
    if (!dropdown.hidden && !dropdown.contains(e.target) && e.target !== btn) {
      dropdown.hidden = true;
    }
  });
}

const SEARCH_TYPE_ICON = { library: '📘', module: '🎓', quiz: '📝', blog: '📰' };

/**
 * Busca global do topbar — o input e o dropdown já existiam no HTML desde a
 * sprint 1, mas nunca foram ligados a nada (bug real: digitar não fazia
 * nada). searchAll (src/services/searchService.js) já existia pronta e
 * também nunca era chamada. Debounce de 300ms pra não disparar 1 query por
 * tecla; mesmo padrão de dropdown do notif-bell/avatar (toggle + fecha ao
 * clicar fora).
 */
function setupGlobalSearch() {
  const wrap = document.getElementById('topbarSearchWrap');
  const input = document.getElementById('topbarSearchInput');
  const dropdown = document.getElementById('topbarSearchDropdown');
  if (!wrap || !input || !dropdown) return;

  let debounceTimer = null;
  let requestId = 0;

  input.addEventListener('input', () => {
    const term = input.value.trim();
    clearTimeout(debounceTimer);

    if (term.length < 2) {
      dropdown.hidden = true;
      dropdown.innerHTML = '';
      return;
    }

    debounceTimer = setTimeout(() => runSearch(term), 300);
  });

  input.addEventListener('focus', () => {
    if (input.value.trim().length >= 2 && dropdown.innerHTML) dropdown.hidden = false;
  });

  input.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      dropdown.hidden = true;
      input.blur();
    }
  });

  document.addEventListener('click', (e) => {
    if (!dropdown.hidden && !wrap.contains(e.target)) {
      dropdown.hidden = true;
    }
  });

  async function runSearch(term) {
    const myRequestId = ++requestId;
    const brandId = window.selectedBrandId;
    if (!brandId) {
      dropdown.hidden = false;
      dropdown.innerHTML = '<p class="search-dropdown-empty">Escolha uma marca na tela Início pra buscar.</p>';
      return;
    }

    dropdown.hidden = false;
    dropdown.innerHTML = '<p class="search-dropdown-empty">Buscando…</p>';

    try {
      const results = await searchAll(brandId, term);
      if (myRequestId !== requestId) return; // resposta de uma busca antiga, já superada por uma mais nova

      if (!results.length) {
        dropdown.innerHTML = '<p class="search-dropdown-empty">Nenhum resultado pra essa busca.</p>';
        return;
      }

      dropdown.innerHTML = results.map((r, i) => `
        <button type="button" class="search-result-item" data-result-index="${i}">
          <span class="search-result-icon">${SEARCH_TYPE_ICON[r.type] || '🔎'}</span>
          <span class="search-result-body">
            <span class="search-result-title">${r.title}</span>
            <span class="search-result-meta">${r.label}${r.subtitle ? ` · ${r.subtitle}` : ''}</span>
          </span>
        </button>`).join('');

      dropdown.querySelectorAll('[data-result-index]').forEach((btn) => {
        btn.addEventListener('click', () => {
          const r = results[Number(btn.dataset.resultIndex)];
          if (!r) return;
          // A busca global é acessível de qualquer painel — o "voltar" de
          // módulo/guia técnico precisa lembrar de onde a busca foi aberta,
          // não um destino fixo (mesmo padrão de quizRunnerReturnPanel).
          if (r.nav.moduleId) {
            window.selectedModuleId = r.nav.moduleId;
            window.moduloConteudoReturnPanel = getActivePanelId() || 'trilha';
          }
          if (r.nav.deepDiveSlug) {
            window.selectedDeepDiveSlug = r.nav.deepDiveSlug;
            window.deepDiveReturnPanel = getActivePanelId() || 'biblioteca';
          }
          if (r.nav.libraryCategory) window.selectedLibraryCategory = r.nav.libraryCategory;
          navigateToPanel(r.nav.panel);
          dropdown.hidden = true;
          input.value = '';
        });
      });
    } catch (err) {
      if (myRequestId !== requestId) return;
      console.error('[AppShell] erro na busca global:', err);
      dropdown.innerHTML = '<p class="search-dropdown-empty">Não foi possível buscar agora.</p>';
    }
  }
}

/** Badge de não-lidas do sino — chamado sempre que o perfil resolve/atualiza. */
async function refreshNotificationBadge(userId) {
  const badge = document.getElementById('notifBadge');
  if (!badge || !userId) return;
  try {
    const count = await countUnreadNotifications(userId);
    badge.textContent = count > 9 ? '9+' : String(count);
    badge.hidden = count === 0;
  } catch (err) {
    console.error('[AppShell] erro ao contar notificações:', err);
  }
}

function setupNotificationBell() {
  const btn = document.getElementById('notifBellBtn');
  const dropdown = document.getElementById('notifDropdown');
  const list = document.getElementById('notifList');
  if (!btn || !dropdown || !list) return;

  btn.addEventListener('click', async (e) => {
    e.stopPropagation();
    const opening = dropdown.hidden;
    dropdown.hidden = !opening;
    if (!opening) return;

    const profile = await getCurrentProfile();
    if (!profile) {
      list.innerHTML = '<p class="dash-empty-text">Faça login para ver notificações.</p>';
      return;
    }

    try {
      const notifications = await fetchUserNotifications(profile.id);
      renderNotificationList(list, notifications);
      wireNotificationItems(list, profile.id);
    } catch (err) {
      console.error('[AppShell] erro ao carregar notificações:', err);
      list.innerHTML = '<p class="learning-error">Não foi possível carregar agora.</p>';
    }
  });

  document.addEventListener('click', (e) => {
    if (!dropdown.hidden && !dropdown.contains(e.target) && e.target !== btn) {
      dropdown.hidden = true;
    }
  });
}

function renderNotificationList(list, notifications) {
  if (!notifications.length) {
    list.innerHTML = '<p class="dash-empty-text">Nenhuma notificação ainda.</p>';
    return;
  }
  list.innerHTML = notifications.map((n) => `
    <div class="notif-item${n.is_read ? '' : ' is-unread'}" data-notif-id="${n.id}">
      <div class="notif-item-title">${n.title}</div>
      <p class="notif-item-message">${n.message}</p>
      <span class="notif-item-time">${new Date(n.created_at).toLocaleDateString('pt-BR')}</span>
    </div>`).join('');
}

function wireNotificationItems(list, userId) {
  list.querySelectorAll('.notif-item.is-unread').forEach((el) => {
    el.addEventListener('click', async () => {
      const id = el.dataset.notifId;
      el.classList.remove('is-unread');
      try {
        await markAsRead(id);
        refreshNotificationBadge(userId);
      } catch (err) {
        console.error('[AppShell] erro ao marcar notificação como lida:', err);
      }
    });
  });
}

function setupLogoutButton() {
  const logoutBtn = document.getElementById('logoutBtn');
  if (!logoutBtn) return;

  logoutBtn.addEventListener('click', async () => {
    const result = await signOut();
    if (result.success) {
      hideBrandScopedNav();
      updateSidebarProfile();
      navigateToPanel('login');
    }
  });
}
