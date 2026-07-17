import { renderAppShell } from './components/appShell.js';
import { initHomePage } from './pages/home.js';
import './pages/trilha.js';
import './pages/trilhaCompleta.js';
import './pages/arenaDesafios.js';
import './pages/quizRunner.js';
import './pages/gameRunner.js';
import './pages/certificacao.js';
import './pages/evaluationRunner.js';
import './pages/biblioteca.js';
import './pages/ranking.js';
import './pages/album.js';
import './pages/blog.js';
import './pages/moduloConteudo.js';
import './pages/deepDiveDetail.js';
import './pages/liderDashboard.js';
import './pages/teamGapsReport.js';
import './pages/adminPanel.js';
import './pages/gestoraPanel.js';
import './pages/homologacaoAdmin.js';
import { isAuthenticated } from './services/authService.js';
import { navigateToPanel } from './router.js';
import './style.css';

document.addEventListener('DOMContentLoaded', async () => {
  const appContainer = document.querySelector('#app');
  if (!appContainer) return;

  renderAppShell(appContainer);
  initHomePage();

  // Sempre navega explicitamente para um painel inicial — nenhum painel tem
  // a classe "active" por padrão (só o link da sidebar tinha, um resquício
  // que não bastava para mostrar o painel correspondente).
  const authenticated = await isAuthenticated();
  navigateToPanel(authenticated ? 'home' : 'login');
});
