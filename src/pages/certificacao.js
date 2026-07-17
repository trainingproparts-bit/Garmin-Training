import { getCurrentProfile } from '../config/supabase.js';
import { fetchTrilhaPublicada } from '../services/trilhaService.js';
import { fetchCertificationsForTrail, fetchUserCertifications } from '../services/certificationService.js';
import { checkEvaluationLock } from '../services/evaluationService.js';
import { supabase } from '../config/supabase.js';
import { navigateToPanel } from '../router.js';

const EVALUATION_TIERS = [
  { type: 'explorer', label: 'Explorer' },
  { type: 'runner', label: 'Runner' },
  { type: 'triathlete', label: 'Triathlete' },
];

// Mesmo emoji/cor por classe usados no Álbum da Equipe (CLASSE_CONFIG,
// album.js) — unifica a linguagem visual entre as duas telas.
const CERT_VISUAL = {
  explorador:  { emoji: '🧭', stripe: 'linear-gradient(90deg,#8a93a0,#aeb4bd)' },
  corredor:    { emoji: '🏃', stripe: 'linear-gradient(90deg,#8C1F2E,#c26b7a)' },
  maratonista: { emoji: '🏅', stripe: 'linear-gradient(90deg,#9b59b6,#c090d6)' },
  triatleta:   { emoji: '🏆', stripe: 'linear-gradient(90deg,#F0A500,#ffcf5c)' },
  aventureiro: { emoji: '🏔️', stripe: 'linear-gradient(90deg,#2E86AB,#6fb8d9)' },
};

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'certificacao') initCertificacaoPage();
});

async function initCertificacaoPage() {
  const container = document.getElementById('certificacaoContainer');
  if (!container) return;

  const brandId = window.selectedBrandId;
  if (!brandId) {
    container.innerHTML = '<p class="learning-error">Escolha uma marca na tela Início primeiro.</p>';
    return;
  }

  container.innerHTML = '<p class="learning-loading">Carregando certificações…</p>';

  try {
    const profile = await getCurrentProfile();
    const { trail } = await fetchTrilhaPublicada(brandId);
    const certs = await fetchCertificationsForTrail(trail.id);
    const userCerts = profile ? await fetchUserCertifications(profile.id) : [];
    const issuedById = new Map(userCerts.filter((c) => !c.revoked_at).map((c) => [c.certification_id, c]));

    const certsHtml = !certs.length
      ? '<p class="learning-empty">Nenhuma certificação configurada ainda para esta trilha.</p>'
      : `<div class="lib-grid">${certs.map((c) => {
          const issued = issuedById.get(c.id);
          const criteria = c.criteria || {};
          const visual = CERT_VISUAL[c.slug] || CERT_VISUAL.explorador;
          const requiredModules = criteria.required_modules || [];
          return `
            <div class="cert-card ${issued ? 'unlocked' : 'locked'}">
              <div class="cert-stripe" style="background:${visual.stripe};"></div>
              <div class="cert-header">
                <div class="cert-emoji">${visual.emoji}</div>
                <div class="cert-header-text">
                  <div class="cert-level-text">${criteria.level || ''}</div>
                  <div class="cert-name-text">${c.title}</div>
                </div>
                <div class="cert-status">${issued ? '✓ Emitida' : '🔒 Pendente'}</div>
              </div>
              ${criteria.objective ? `<p class="cert-obj">${criteria.objective}</p>` : ''}
              ${requiredModules.length ? `
                <div class="cert-modules">
                  ${requiredModules.map((m) => `<span class="cert-mod-pill">${m.title}</span>`).join('')}
                </div>` : ''}
              ${issued ? `<p class="cert-issued-date">Emitida em ${new Date(issued.issued_at).toLocaleDateString('pt-BR')}</p>` : ''}
            </div>`;
        }).join('')}</div>`;

    container.innerHTML = `
      ${certsHtml}
      <h3 class="dash-section-label" style="margin-top:32px;">Avaliações Trimestrais</h3>
      <div class="lib-grid" data-role="evaluations">
        <p class="learning-loading">Carregando avaliações…</p>
      </div>
    `;

    renderEvaluationTiers(container.querySelector('[data-role="evaluations"]'), profile);
  } catch (err) {
    console.error('[Certificacao] erro ao carregar certificações:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar as certificações agora.</p>';
  }
}

async function renderEvaluationTiers(el, profile) {
  if (!el) return;

  try {
    const { data: evaluations, error } = await supabase
      .from('evaluations')
      .select('id, title, type, passing_score_pct')
      .eq('is_published', true);
    if (error) throw error;

    const byType = new Map(evaluations.map((e) => [e.type, e]));

    const locks = profile
      ? await Promise.all(
          EVALUATION_TIERS.map((tier) => {
            const evaluation = byType.get(tier.type);
            return evaluation ? checkEvaluationLock(evaluation.id) : Promise.resolve(null);
          })
        )
      : EVALUATION_TIERS.map(() => null);

    el.innerHTML = EVALUATION_TIERS.map((tier, i) => {
      const evaluation = byType.get(tier.type);
      const lock = locks[i];

      if (!evaluation) {
        return `
          <div class="learning-card">
            <h4>${tier.label}</h4>
            <p>Ainda não cadastrada.</p>
          </div>`;
      }

      const blocked = lock?.locked;
      return `
        <div class="learning-card">
          <h4>${evaluation.title}</h4>
          <p>Nota mínima ${evaluation.passing_score_pct}% · sem limite de tentativas</p>
          ${blocked
            ? `<p class="cert-status">🔒 Bloqueada até ${new Date(lock.locked_until).toLocaleString('pt-BR', { dateStyle: 'short', timeStyle: 'short' })}</p>`
            : `<button type="button" class="learning-card-btn" data-evaluation-type="${tier.type}">Iniciar avaliação ➔</button>`}
        </div>`;
    }).join('');

    el.querySelectorAll('[data-evaluation-type]').forEach((btn) => {
      btn.addEventListener('click', () => {
        if (!profile) {
          alert('Faça login para fazer a avaliação.');
          return;
        }
        window.selectedEvaluationType = btn.dataset.evaluationType;
        navigateToPanel('evaluation-runner');
      });
    });
  } catch (err) {
    console.error('[Certificacao] erro ao carregar avaliações trimestrais:', err);
    el.innerHTML = '<p class="learning-error">Não foi possível carregar as avaliações agora.</p>';
  }
}
