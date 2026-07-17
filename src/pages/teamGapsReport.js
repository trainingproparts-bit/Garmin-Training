// src/pages/teamGapsReport.js
// Relatório de Gaps da Equipe — "farol de erros" pro líder ver em quais
// perguntas/temas a equipe da própria loja mais erra (últimos 30 dias).
// Fonte: vw_store_knowledge_gaps (sql/015→043→057), que já agrupa por
// PERGUNTA (uma linha por pergunta, não por par pergunta+colaborador) e já
// escopa por loja/papel no servidor (fn_is_leader()+fn_leader_store_ids() /
// fn_is_admin()) — esta tela só exibe/filtra o que a view devolver, nunca
// filtra loja no cliente. wrong_respondents (sql/057) é o jsonb
// [{id, full_name}] que vira os chips clicáveis de "Quem errou".

import { getCurrentProfile, isLeaderProfile, isAdminProfile } from '../config/supabase.js';
import { fetchStoreKnowledgeGaps, fetchTeamMembers } from '../services/teamService.js';
import { openMemberDrawer } from '../components/MemberDrawer.js';

let allRows = [];
let membersById = new Map();
const state = { colaboradorId: '', moduloTitle: '', showControlled: false };

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'relatorios') initGapsReport();
});

async function initGapsReport() {
  const container = document.getElementById('relatoriosContainer');
  if (!container) return;

  container.innerHTML = '<p class="learning-loading">Carregando relatório de gaps…</p>';
  state.colaboradorId = '';
  state.moduloTitle = '';
  state.showControlled = false;

  try {
    const profile = await getCurrentProfile();
    if (!profile || !(isLeaderProfile(profile) || isAdminProfile(profile))) {
      container.innerHTML = '<p class="learning-error">Esta área é restrita a líderes e administradores.</p>';
      return;
    }

    const [rows, members] = await Promise.all([
      fetchStoreKnowledgeGaps(),
      fetchTeamMembers(),
    ]);
    allRows = rows || [];
    membersById = new Map((members || []).filter((m) => m?.id).map((m) => [m.id, m]));

    if (!allRows.length) {
      container.innerHTML = `
        <p class="learning-empty">
          Nenhuma resposta de quiz registrada pela equipe nos últimos 30 dias — nada pra reportar ainda.
        </p>`;
      return;
    }

    const mostCritical = findMostCriticalQuestion(allRows);

    container.innerHTML = `
      ${renderAlertCard(mostCritical)}
      <h3 class="dash-section-label" style="margin-top:28px;">Perguntas com mais erros (últimos 30 dias)</h3>
      ${renderFilterBar(allRows)}
      <div data-role="gapsTableWrap">${renderGapsTable(applyFilters(allRows))}</div>
    `;

    setupFilters(container);
    wireChipClicks(container);
  } catch (err) {
    console.error('[TeamGapsReport] erro ao carregar relatório de gaps:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar o relatório agora.</p>';
  }
}

/** Pergunta com a MAIOR taxa de erro nos últimos 30 dias — teamService já ordena por error_rate_pct desc, total_answers desc, então rows[0] já seria a resposta; o reduce aqui é só defensivo contra mudança de ordenação upstream. */
function findMostCriticalQuestion(rows) {
  if (!rows?.length) return null;
  return rows.reduce((worst, cur) => ((cur?.error_rate_pct ?? 0) > (worst?.error_rate_pct ?? 0) ? cur : worst));
}

/**
 * Ação sugerida por nível real da certificação (certifications.criteria->>
 * 'level', exposto por vw_store_knowledge_gaps via checkpoints→zones→
 * certifications.zone_id — sql/020). Sem heurística de texto: se o quiz não
 * é checkpoint de nenhuma zona com certificação (Circuito de Desafios,
 * quizzes extras/técnicos fora da trilha sequencial), certification_level
 * vem null e cai no fallback genérico.
 */
const ACTION_BY_LEVEL = {
  'Nível 1': 'Reciclagem rápida no alinhamento de base.',
  'Nível 2': 'Reforço prático nas rotinas de venda.',
  'Nível 3': 'Mentoria individual ou estudo de caso complexo.',
  'Nível 4': 'Mentoria individual ou estudo de caso complexo.',
};

function resolveAction(certificationLevel) {
  if (certificationLevel && ACTION_BY_LEVEL[certificationLevel]) {
    return { label: certificationLevel, action: ACTION_BY_LEVEL[certificationLevel] };
  }
  return { label: 'Fora da trilha principal', action: 'Revisão pontual do conteúdo com a equipe.' };
}

function renderAlertCard(critical) {
  if (!critical) return '';
  const level = resolveAction(critical?.certification_level);

  return `
    <div class="gaps-alert-card">
      <span class="gaps-alert-icon">🚨</span>
      <div>
        <div class="gaps-alert-tag">Farol de alerta, pergunta mais crítica dos últimos 30 dias</div>
        <div class="gaps-alert-title">${critical?.error_rate_pct ?? 0}% da equipe errou a questão "${critical?.question_text || ''}"</div>
        <div class="gaps-alert-meta">
          Parte do treinamento <strong>${critical?.quiz_title || '—'}</strong>,
          ${critical?.wrong_answers ?? 0} de ${critical?.total_answers ?? 0} tentativas erradas nos últimos 30 dias.
        </div>
        <div class="gaps-alert-meta" style="margin-top:8px;">
          <strong>${level.label} · Ação sugerida:</strong> ${level.action}
        </div>
      </div>
    </div>`;
}

/** Filtros são só client-side sobre o que a view já devolveu (RLS já limitou o conjunto por loja/papel) — nenhuma query nova ao trocar filtro. */
function renderFilterBar(rows) {
  const colaboradores = distinctColaboradores(rows);
  const modulos = distinctModulos(rows);

  return `
    <div class="gaps-filter-bar">
      <select id="gapsFilterColaborador" class="login-input">
        <option value="">Todos os colaboradores</option>
        ${colaboradores.map((c) => `<option value="${c.id}">${c.full_name}</option>`).join('')}
      </select>
      <select id="gapsFilterModulo" class="login-input">
        <option value="">Todos os módulos</option>
        ${modulos.map((m) => `<option value="${m}">${m}</option>`).join('')}
      </select>
      <label class="gaps-filter-toggle">
        <input type="checkbox" id="gapsShowControlled">
        Mostrar perguntas sob controle
      </label>
    </div>`;
}

function distinctColaboradores(rows) {
  const map = new Map();
  (rows || []).forEach((r) => {
    (r?.wrong_respondents || []).forEach((w) => {
      if (w?.id && !map.has(w.id)) map.set(w.id, w.full_name || '—');
    });
  });
  return [...map.entries()]
    .map(([id, full_name]) => ({ id, full_name }))
    .sort((a, b) => a.full_name.localeCompare(b.full_name));
}

function distinctModulos(rows) {
  const set = new Set();
  (rows || []).forEach((r) => { if (r?.quiz_title) set.add(r.quiz_title); });
  return [...set].sort((a, b) => a.localeCompare(b));
}

function applyFilters(rows) {
  return (rows || []).filter((r) => {
    if (!state.showControlled && (r?.error_rate_pct ?? 0) === 0) return false;
    if (state.moduloTitle && r?.quiz_title !== state.moduloTitle) return false;
    if (state.colaboradorId && !(r?.wrong_respondents || []).some((w) => w?.id === state.colaboradorId)) return false;
    return true;
  });
}

function setupFilters(container) {
  const colaboradorSelect = container.querySelector('#gapsFilterColaborador');
  const moduloSelect = container.querySelector('#gapsFilterModulo');
  const controlledCheckbox = container.querySelector('#gapsShowControlled');
  const tableWrap = container.querySelector('[data-role="gapsTableWrap"]');

  function refresh() {
    tableWrap.innerHTML = renderGapsTable(applyFilters(allRows));
    wireChipClicks(container);
  }

  colaboradorSelect?.addEventListener('change', () => { state.colaboradorId = colaboradorSelect.value; refresh(); });
  moduloSelect?.addEventListener('change', () => { state.moduloTitle = moduloSelect.value; refresh(); });
  controlledCheckbox?.addEventListener('change', () => { state.showControlled = controlledCheckbox.checked; refresh(); });
}

function renderGapsTable(rows) {
  if (!rows?.length) {
    return '<p class="learning-empty">Nenhuma pergunta encontrada com esses filtros.</p>';
  }

  return `
    <div class="lib-table-wrap">
      <table class="lib-table">
        <thead><tr><th>Pergunta/Tema</th><th>Módulo</th><th>Taxa de erro</th><th>Quem errou</th></tr></thead>
        <tbody>
          ${rows.map((r) => `
            <tr>
              <td class="lib-prod-dest">${r?.question_text || '—'}</td>
              <td class="lib-prod-para">${r?.quiz_title || '—'}</td>
              <td>${renderCriticidadeBadge(r?.error_rate_pct ?? 0)}</td>
              <td>${renderRespondentChips(r?.wrong_respondents)}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>`;
}

function renderRespondentChips(respondents) {
  if (!respondents?.length) return '<span class="lib-prod-series">—</span>';
  return `
    <div class="gaps-chip-list">
      ${respondents.map((w) => `<button type="button" class="gaps-chip" data-respondent-id="${w?.id || ''}">${w?.full_name || '—'}</button>`).join('')}
    </div>`;
}

function wireChipClicks(container) {
  container.querySelectorAll('[data-respondent-id]').forEach((chip) => {
    const id = chip.dataset.respondentId;
    if (!id) return;
    chip.addEventListener('click', () => {
      const member = membersById.get(id) || { id, full_name: chip.textContent };
      openMemberDrawer(member);
    });
  });
}

/** Semáforo: >50% crítico (vermelho), 30–50% atenção (amarelo), <30% sob controle (verde). */
function renderCriticidadeBadge(pct) {
  const level = pct > 50 ? 'critico' : pct >= 30 ? 'atencao' : 'controle';
  const label = level === 'critico' ? 'Crítico' : level === 'atencao' ? 'Atenção' : 'Sob controle';
  return `<span class="gaps-badge gaps-badge-${level}">${pct}% · ${label}</span>`;
}
