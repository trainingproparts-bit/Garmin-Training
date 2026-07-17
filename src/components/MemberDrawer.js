// src/components/MemberDrawer.js
// "Raio-X" individual do colaborador — painel lateral (drawer) deslizante,
// aberto tanto pela tabela "Equipe" do Dashboard do Líder quanto pelos chips
// "Quem errou" do Relatório de Gaps (dois painéis/arquivos diferentes,
// panel:activated separados — por isso este componente é compartilhado em
// vez de duplicado, único jeito de garantir que os dois pontos de entrada
// abram exatamente o mesmo diagnóstico). Mesma família de padrão dos modais
// já existentes (activity-modal em DashboardHome.js, album-modal em
// album.js): monta HTML num root anexado a document.body, fecha via
// backdrop-click/botão/Esc removendo o root — só que deslizando da direita
// em vez de centralizado.

import { fetchUserQuizAttempts, fetchUserQuizAnswers } from '../services/teamService.js';
import { fetchUserCertifications } from '../services/certificationService.js';

const GAPS_WINDOW_DAYS = 30;

function initials(fullName) {
  return (fullName || '?').trim().charAt(0).toUpperCase();
}

function formatDate(iso) {
  if (!iso) return '—';
  return new Date(iso).toLocaleDateString('pt-BR');
}

/**
 * Abre o drawer pro colaborador `member` — precisa só dos campos básicos já
 * disponíveis na tela chamadora (id, full_name, job_title, stores?.name ou
 * store_name, performance_score); o resto (certificações, respostas,
 * tentativas) o próprio drawer busca, pra não acoplar no que cada tela já
 * carregou.
 */
export async function openMemberDrawer(member) {
  if (!member?.id) return;

  const existing = document.querySelector('[data-role="mdrawer-root"]');
  if (existing) existing.remove();

  const root = document.createElement('div');
  root.dataset.role = 'mdrawer-root';
  root.innerHTML = `
    <div class="mdrawer-backdrop" data-role="mdrawer-backdrop">
      <aside class="mdrawer-panel" data-role="mdrawer-panel">
        <button type="button" class="mdrawer-close" data-role="mdrawer-close" aria-label="Fechar">✕</button>
        ${renderHeader(member)}
        <div class="mdrawer-body" data-role="mdrawer-body">
          <p class="learning-loading">Carregando diagnóstico…</p>
        </div>
      </aside>
    </div>`;
  document.body.appendChild(root);

  const panel = root.querySelector('[data-role="mdrawer-panel"]');
  void panel.offsetHeight; // força reflow antes de animar (rAF não é confiável em abas em segundo plano)
  panel.classList.add('open');

  const close = () => {
    panel.classList.remove('open');
    setTimeout(() => root.remove(), 250);
  };
  root.querySelector('[data-role="mdrawer-backdrop"]').addEventListener('click', (e) => {
    if (e.target === e.currentTarget) close();
  });
  root.querySelector('[data-role="mdrawer-close"]').addEventListener('click', close);
  document.addEventListener('keydown', function onEsc(e) {
    if (e.key === 'Escape') {
      close();
      document.removeEventListener('keydown', onEsc);
    }
  });

  const bodyEl = root.querySelector('[data-role="mdrawer-body"]');
  try {
    const [certifications, attempts, answers] = await Promise.all([
      fetchUserCertifications(member.id),
      fetchUserQuizAttempts(member.id),
      fetchUserQuizAnswers(member.id),
    ]);

    bodyEl.innerHTML = renderBody({ certifications, attempts, answers });
  } catch (err) {
    console.error('[MemberDrawer] erro ao carregar diagnóstico do colaborador:', err);
    bodyEl.innerHTML = '<p class="learning-error">Não foi possível carregar o diagnóstico agora.</p>';
  }
}

function renderHeader(member) {
  const storeName = member.stores?.name || member.store_name || '—';
  const score = member.performance_score ?? 0;

  return `
    <div class="mdrawer-header">
      <div class="mdrawer-avatar">${initials(member.full_name)}</div>
      <div class="mdrawer-header-text">
        <h3 class="mdrawer-name">${member.full_name || 'Colaborador'}</h3>
        <p class="mdrawer-meta">${member.job_title || '—'} · ${storeName}</p>
        <span class="mdrawer-score">${score} pts</span>
      </div>
    </div>`;
}

function renderBody({ certifications, attempts, answers }) {
  const certs = certifications || [];
  const attemptsList = attempts || [];
  const answersList = answers || [];

  const activeCerts = certs.filter((c) => !c?.revoked_at);
  const totalAnswers = answersList.length;
  const correctAnswers = answersList.filter((a) => a?.is_correct).length;
  const accuracyPct = totalAnswers ? Math.round((correctAnswers / totalAnswers) * 100) : null;

  const cutoff = Date.now() - GAPS_WINDOW_DAYS * 24 * 60 * 60 * 1000;
  const recentAnswers = answersList.filter((a) => a?.answered_at && new Date(a.answered_at).getTime() >= cutoff);
  const recentMisses = recentAnswers.filter((a) => !a?.is_correct);

  return `
    <div class="mdrawer-stats">
      <div class="mdrawer-stat-card">
        <span class="mdrawer-stat-label">Certificações emitidas</span>
        <span class="mdrawer-stat-value">${activeCerts.length}</span>
      </div>
      <div class="mdrawer-stat-card">
        <span class="mdrawer-stat-label">Acerto geral em quizzes</span>
        <span class="mdrawer-stat-value">${accuracyPct === null ? '—' : `${accuracyPct}%`}</span>
      </div>
    </div>

    <h4 class="mdrawer-section-title">🎯 Gaps Ativos <span class="mdrawer-section-hint">(últimos ${GAPS_WINDOW_DAYS} dias)</span></h4>
    ${renderGapsSection(recentAnswers, recentMisses)}

    <h4 class="mdrawer-section-title">🕓 Histórico Recente</h4>
    ${renderHistorySection(attemptsList)}
  `;
}

function renderGapsSection(recentAnswers, recentMisses) {
  if (!recentAnswers.length) {
    return '<p class="mdrawer-empty">Sem atividade de quiz nos últimos 30 dias.</p>';
  }
  if (!recentMisses.length) {
    return '<p class="mdrawer-success">✓ 100% de acerto nos últimos 30 dias, nenhum gap ativo agora!</p>';
  }

  return `
    <ul class="mdrawer-gap-list">
      ${recentMisses.map((a) => `
        <li class="mdrawer-gap-item">
          <span class="mdrawer-gap-question">${a?.questions?.body || 'Pergunta'}</span>
          <span class="mdrawer-gap-meta">${a?.questions?.quizzes?.title || 'Quiz'} · ${formatDate(a?.answered_at)}</span>
        </li>`).join('')}
    </ul>`;
}

function renderHistorySection(attempts) {
  if (!attempts.length) {
    return '<p class="mdrawer-empty">Nenhuma tentativa de quiz finalizada ainda.</p>';
  }

  return `
    <ul class="mdrawer-history-list">
      ${attempts.map((a) => `
        <li class="mdrawer-history-item">
          <span class="mdrawer-history-icon">${a?.passed ? '✓' : '✗'}</span>
          <div class="mdrawer-history-text">
            <span class="mdrawer-history-title">${a?.quizzes?.title || 'Quiz'}</span>
            <span class="mdrawer-history-meta">${formatDate(a?.finished_at)}</span>
          </div>
          <span class="mdrawer-history-score">${a?.score_pct ?? 0}%</span>
        </li>`).join('')}
    </ul>`;
}
