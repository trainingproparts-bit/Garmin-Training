// src/pages/login.js
// Renderiza o formulário de login usando o Design System Proparts

import { signIn } from '../services/authService.js';

export function initLoginPage() {
  const loginContainer = document.getElementById('loginContainer');
  if (!loginContainer) return;

  renderLoginForm(loginContainer);
}

function renderLoginForm(container) {
  container.innerHTML = `
    <div class="login-card">
      <div class="login-header">
        <div class="login-logo">
          <img src="/logo-preto.png" alt="Proparts Logo" class="login-logo-img" />
          <div class="login-brand-label">Training <span>Hub</span></div>
        </div>
        <p class="login-subtitle">Insira seus dados para entrar na plataforma</p>
      </div>

      <form id="loginForm" class="login-form">
        <div class="login-field">
          <label for="username" class="login-label">Usuário</label>
          <input 
            type="text" 
            id="username" 
            name="username"
            placeholder="ex: samara.pereira" 
            required 
            class="login-input"
            autocomplete="username"
          />
        </div>

        <div class="login-field">
          <label for="password" class="login-label">Senha</label>
          <input 
            type="password" 
            id="password" 
            name="password"
            placeholder="••••••••" 
            required 
            class="login-input"
            autocomplete="current-password"
          />
        </div>

        <button type="submit" class="login-btn">
          Entrar no Hub
        </button>

        <div class="login-divider">
          <span>ou</span>
        </div>

        <a href="#" id="continueAsGuest" class="login-guest-link">
          Continuar como Visitante ➔
        </a>
      </form>

      <div id="loginError" class="login-error" hidden></div>
    </div>
  `;

  // Adiciona event listeners
  const form = document.getElementById('loginForm');
  const guestLink = document.getElementById('continueAsGuest');
  const errorEl = document.getElementById('loginError');

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value;

    // Desabilita botão durante o login
    const submitBtn = form.querySelector('.login-btn');
    submitBtn.disabled = true;
    submitBtn.textContent = 'Entrando...';
    errorEl.hidden = true;

    const result = await signIn(username, password);

    if (result.success) {
      // Login bem-sucedido - dispara evento para o app shell navegar
      window.dispatchEvent(new CustomEvent('auth:login-success'));
    } else {
      // Mostra erro
      errorEl.textContent = result.error;
      errorEl.hidden = false;
      submitBtn.disabled = false;
      submitBtn.textContent = 'Entrar no Hub';
    }
  });

  guestLink.addEventListener('click', (e) => {
    e.preventDefault();
    // Navega para o painel home como visitante
    window.dispatchEvent(new CustomEvent('auth:guest-access'));
  });
}
