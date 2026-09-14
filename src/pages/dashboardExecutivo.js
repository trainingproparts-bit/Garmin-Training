// src/pages/dashboardExecutivo.js
// Dashboard Executivo — admin-only. Consolida em 5 abas o que hoje está
// espalhado entre Painel do Líder, Relatório de Gaps e Painel da Gestora,
// com identidade visual própria (preto/branco/vermelho, ver
// styles/dashboardExecutivo.css) e construído só sobre fontes de dado vivas
// (ver header de sql/115_dashboard_executivo.sql para o que foi
// deliberadamente deixado de fora e por quê).
//
// Padrão de re-render: filtros globais (loja/cargo/período) e troca de aba
// disparam render() do painel inteiro — dataset é pequeno (dezenas de
// colaboradores), custo desprezível. A aba Equipe & Risco é exceção: busca/
// ordenação/paginação re-renderizam só o corpo da tabela (não o campo de
// busca), pra não perder foco/cursor a cada tecla digitada.

import { getCurrentProfile, isAdminProfile } from '../config/supabase.js';
import {
  fetchColaboradorResumo,
  fetchFunilAprendizagem,
  fetchEvolucaoMensal,
  fetchStoreKnowledgeGaps,
  fetchFunilCertificacao,
  fetchQuizPerformance,
  fetchModuleAbandonment,
} from '../services/executiveDashboardService.js';
import { computeRiskScore, computeMediaProgresso, RISK_BAND_LABEL } from '../services/riskScoring.js';
import { computeInsights } from '../services/insightsEngine.js';
import { lineChartSvg, barChartSvg, funnelChartSvg, escapeAttr } from '../components/chartsSvg.js';
import { openMemberDrawer } from '../components/MemberDrawer.js';
import { navigateToPanel } from '../router.js';

const TABS = [
  { id: 'visao', label: 'Visão Executiva' },
  { id: 'evolucao', label: 'Evolução' },
  { id: 'equipe', label: 'Equipe & Risco' },
  { id: 'conteudo', label: 'Conteúdo' },
  { id: 'competencias', label: 'Competências' },
];

const TABLE_COLUMNS = [
  { key: 'full_name', label: 'Colaborador' },
  { key: 'store_name', label: 'Loja' },
  { key: 'progresso_pct', label: 'Progresso' },
  { key: 'quiz_taxa_aprovacao_pct', label: 'Aprovação' },
  { key: 'dias_inatividade', label: 'Atividade' },
  { key: 'risco', label: 'Risco' },
];

const AMOSTRA_MINIMA_GAP_PREVIEW = 3;

const MESES_LABEL = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];

const state = {
  raw: { colaboradores: [], funil: [], evolucaoMensal: [], gaps: [], certFunil: [], quizPerf: [], moduleAbandon: [] },
  filters: { storeId: '', jobTitle: '', busca: '', periodoMeses: 6 },
  activeTab: 'visao',
  table: { sortKey: 'progresso_pct', sortDir: 'desc', page: 1, pageSize: 10 },
};

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'executivo') initDashboardExecutivo();
});

async function initDashboardExecutivo() {
  const container = document.getElementById('executivoContainer');
  if (!container) return;

  container.className = 'exec-dash';
  container.innerHTML = '<div class="ed-loading">Carregando dashboard executivo…</div>';

  try {
    const profile = await getCurrentProfile();
    if (!profile || !isAdminProfile(profile)) {
      container.innerHTML = '<div class="ed-error">Esta área é restrita a administradores.</div>';
      return;
    }

    const [colaboradores, funil, evolucaoMensal, gaps, certFunil, quizPerf, moduleAbandon] = await Promise.all([
      fetchColaboradorResumo(),
      fetchFunilAprendizagem(),
      fetchEvolucaoMensal(),
      fetchStoreKnowledgeGaps(),
      fetchFunilCertificacao(),
      fetchQuizPerformance(),
      fetchModuleAbandonment(),
    ]);

    state.raw = { colaboradores, funil, evolucaoMensal, gaps, certFunil, quizPerf, moduleAbandon };
    state.filters = { storeId: '', jobTitle: '', busca: '', periodoMeses: 6 };
    state.activeTab = 'visao';
    state.table = { sortKey: 'progresso_pct', sortDir: 'desc', page: 1, pageSize: 10 };

    render(container);
  } catch (err) {
    console.error('[DashboardExecutivo] erro ao carregar dados:', err);
    container.innerHTML = '<div class="ed-error">Não foi possível carregar o dashboard agora. Tente novamente em instantes.</div>';
  }
}

// ── Orquestração de render ────────────────────────────────────────────

function render(container) {
  const { colaboradores, funil, evolucaoMensal, gaps, certFunil, quizPerf, moduleAbandon } = state.raw;

  const colabFiltrados = applyGlobalFilters(colaboradores);
  const mediaProgresso = computeMediaProgresso(colabFiltrados);
  const colabComRisco = colabFiltrados.map((c) => ({ ...c, _risco: computeRiskScore(c, { mediaProgressoPct: mediaProgresso }) }));

  const idsFiltrados = new Set(colabComRisco.map((c) => c.colaborador_id));
  const funilFiltrado = funil.filter((f) => idsFiltrados.has(f.colaborador_id));
  const evolucaoFiltrada = applyPeriodo(evolucaoMensal.filter((r) => idsFiltrados.has(r.colaborador_id)));
  const gapsFiltrados = state.filters.storeId ? gaps.filter((g) => g.store_id === state.filters.storeId) : gaps;

  const insights = computeInsights({ colaboradores: colabComRisco, evolucaoMensal: evolucaoFiltrada, gaps: gapsFiltrados });

  container.innerHTML = `
    ${renderHeader()}
    ${renderFilterBar(colaboradores)}
    ${renderTabs()}
    <div class="ed-tabpanel ${state.activeTab === 'visao' ? 'is-active' : ''}" data-tabpanel="visao">
      ${renderVisaoExecutiva(colabComRisco, funilFiltrado, evolucaoFiltrada, insights)}
    </div>
    <div class="ed-tabpanel ${state.activeTab === 'evolucao' ? 'is-active' : ''}" data-tabpanel="evolucao">
      ${renderEvolucao(evolucaoFiltrada)}
    </div>
    <div class="ed-tabpanel ${state.activeTab === 'equipe' ? 'is-active' : ''}" data-tabpanel="equipe">
      ${renderEquipeRisco(colabComRisco)}
    </div>
    <div class="ed-tabpanel ${state.activeTab === 'conteudo' ? 'is-active' : ''}" data-tabpanel="conteudo">
      ${renderConteudo(gapsFiltrados, quizPerf, moduleAbandon)}
    </div>
    <div class="ed-tabpanel ${state.activeTab === 'competencias' ? 'is-active' : ''}" data-tabpanel="competencias">
      ${renderCompetencias(certFunil)}
    </div>
  `;

  wireFilterBar(container);
  wireTabs(container);
  wireEquipeSection(container, colabComRisco);
  wireRiskPreview(container, colabComRisco);
  container.querySelector('[data-goto-gaps-report]')?.addEventListener('click', () => navigateToPanel('relatorios'));
}

function applyGlobalFilters(colaboradores) {
  const { storeId, jobTitle } = state.filters;
  return colaboradores.filter((c) => {
    if (storeId && c.store_id !== storeId) return false;
    if (jobTitle && c.job_title !== jobTitle) return false;
    return true;
  });
}

function applyPeriodo(evolucaoRows) {
  const meses = state.filters.periodoMeses;
  if (!meses) return evolucaoRows;
  const limite = new Date();
  limite.setDate(1);
  limite.setMonth(limite.getMonth() - (meses - 1));
  const limiteStr = limite.toISOString().slice(0, 7);
  return evolucaoRows.filter((r) => String(r.mes).slice(0, 7) >= limiteStr);
}

// ── Cabeçalho + filtros + abas ─────────────────────────────────────────

function renderHeader() {
  return `
    <div class="ed-header">
      <div>
        <span class="ed-eyebrow">Dashboard Executivo</span>
        <h2 class="ed-title">Como está a operação de treinamento</h2>
        <p class="ed-subtitle">Visão consolidada da equipe, do estado geral ao diagnóstico individual — construída só sobre dado real registrado pela plataforma.</p>
      </div>
      <span class="ed-updated-at">Carregado às ${new Date().toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}</span>
    </div>`;
}

function renderFilterBar(colaboradoresTodos) {
  const stores = [...new Map(colaboradoresTodos.filter((c) => c.store_id).map((c) => [c.store_id, c.store_name])).entries()]
    .sort((a, b) => a[1].localeCompare(b[1]));
  const cargos = [...new Set(colaboradoresTodos.map((c) => c.job_title).filter(Boolean))].sort();

  return `
    <div class="ed-filter-bar">
      <select id="edFilterStore" aria-label="Filtrar por loja">
        <option value="">Todas as lojas</option>
        ${stores.map(([id, name]) => `<option value="${id}" ${state.filters.storeId === id ? 'selected' : ''}>${name}</option>`).join('')}
      </select>
      <select id="edFilterJobTitle" aria-label="Filtrar por cargo">
        <option value="">Todos os cargos</option>
        ${cargos.map((c) => `<option value="${escapeAttr(c)}" ${state.filters.jobTitle === c ? 'selected' : ''}>${c}</option>`).join('')}
      </select>
      <select id="edFilterPeriodo" aria-label="Período da série temporal">
        <option value="3" ${state.filters.periodoMeses === 3 ? 'selected' : ''}>Últimos 3 meses</option>
        <option value="6" ${state.filters.periodoMeses === 6 ? 'selected' : ''}>Últimos 6 meses</option>
        <option value="12" ${state.filters.periodoMeses === 12 ? 'selected' : ''}>Últimos 12 meses</option>
        <option value="0" ${state.filters.periodoMeses === 0 ? 'selected' : ''}>Todo o histórico</option>
      </select>
    </div>
    <p class="ed-section-hint" style="margin-top:-16px;">Loja e cargo afetam o dashboard inteiro. Período afeta só a aba Evolução e os insights de tendência.</p>`;
}

function wireFilterBar(container) {
  container.querySelector('#edFilterStore')?.addEventListener('change', (e) => {
    state.filters.storeId = e.target.value;
    state.table.page = 1;
    render(container);
  });
  container.querySelector('#edFilterJobTitle')?.addEventListener('change', (e) => {
    state.filters.jobTitle = e.target.value;
    state.table.page = 1;
    render(container);
  });
  container.querySelector('#edFilterPeriodo')?.addEventListener('change', (e) => {
    state.filters.periodoMeses = Number(e.target.value);
    render(container);
  });
}

function renderTabs() {
  return `
    <div class="ed-tabs" role="tablist">
      ${TABS.map((t) => `<button type="button" class="ed-tab ${state.activeTab === t.id ? 'is-active' : ''}" data-tab="${t.id}" role="tab">${t.label}</button>`).join('')}
    </div>`;
}

function wireTabs(container) {
  container.querySelectorAll('[data-tab]').forEach((btn) => {
    btn.addEventListener('click', () => {
      if (state.activeTab === btn.dataset.tab) return;
      state.activeTab = btn.dataset.tab;
      render(container);
    });
  });
}

// ── Helpers compartilhados ──────────────────────────────────────────────

function progressCellHtml(pct) {
  if (pct === null || pct === undefined) return '<span class="ed-cell-sub">—</span>';
  return `<span class="ed-progress-track"><span class="ed-progress-fill" style="width:${pct}%"></span></span>${pct}%`;
}

function riskBadgeHtml(risco) {
  return `<span class="ed-risk-badge ed-risk-${risco.band}">${RISK_BAND_LABEL[risco.band]}</span>`;
}

function toDrawerMember(c) {
  return {
    id: c.colaborador_id,
    full_name: c.full_name,
    job_title: c.job_title,
    stores: { name: c.store_name },
    performance_score: c.performance_score,
    // Campos extras (Dashboard Executivo) — MemberDrawer.js só renderiza as
    // seções correspondentes quando eles estão presentes, então chamadores
    // antigos (Painel do Líder, Relatório de Gaps) continuam funcionando
    // sem alteração.
    progresso_pct: c.progresso_pct,
    dias_inatividade: c.dias_inatividade,
    streak_atual: c.streak_atual,
    certificacoes_ativas: c.certificacoes_ativas,
    certificacao_mais_alta: c.certificacao_mais_alta,
    quiz_taxa_aprovacao_pct: c.quiz_taxa_aprovacao_pct,
    tem_reprovacao_recorrente: c.tem_reprovacao_recorrente,
    avaliacao_trimestral_aprovado: c.avaliacao_trimestral_aprovado,
    avaliacao_trimestral_data: c.avaliacao_trimestral_data,
    avaliacoes_google_media: c.avaliacoes_google_media,
    avaliacoes_google_qtd: c.avaliacoes_google_qtd,
    risco: c._risco,
  };
}

function formatMesLabel(mesIso) {
  const [y, m] = String(mesIso).slice(0, 7).split('-');
  return `${MESES_LABEL[Number(m) - 1] || m}/${y.slice(2)}`;
}

function aggregateMonthly(rows) {
  const map = new Map();
  (rows || []).forEach((r) => {
    const cur = map.get(r.mes) || { mes: r.mes, xp: 0, checkpoints: 0, tentativas: 0, aprovados: 0 };
    cur.xp += Number(r.xp_ganho) || 0;
    cur.checkpoints += Number(r.checkpoints_concluidos) || 0;
    cur.tentativas += Number(r.quiz_tentativas) || 0;
    cur.aprovados += Number(r.quiz_aprovados) || 0;
    map.set(r.mes, cur);
  });
  return [...map.values()].sort((a, b) => String(a.mes).localeCompare(String(b.mes)));
}

function kpiDeltaHtml(deltaValue, { suffix = '' } = {}) {
  if (deltaValue === null || deltaValue === undefined) return '';
  const dir = deltaValue > 0 ? 'is-up' : deltaValue < 0 ? 'is-down' : 'is-flat';
  const arrow = deltaValue > 0 ? '↑' : deltaValue < 0 ? '↓' : '→';
  return `<span class="ed-kpi-delta ${dir}">${arrow} ${Math.abs(deltaValue)}${suffix} vs. mês anterior</span>`;
}

function kpiCardHtml(label, value, { delta = null, deltaSuffix = '', sub = null } = {}) {
  return `
    <div class="ed-kpi-card">
      <span class="ed-kpi-label">${label}</span>
      <span class="ed-kpi-value">${value}</span>
      ${sub ? `<span class="ed-kpi-delta is-flat">${sub}</span>` : kpiDeltaHtml(delta, { suffix: deltaSuffix })}
    </div>`;
}

// ── Aba 1: Visão Executiva ──────────────────────────────────────────────

function renderVisaoExecutiva(colaboradores, funil, evolucaoFiltrada, insights) {
  if (!colaboradores.length) {
    return '<div class="ed-empty">Nenhum colaborador encontrado com os filtros atuais.</div>';
  }

  const total = colaboradores.length;
  const comAtividadeRecente = colaboradores.filter((c) => c.dias_inatividade !== null && c.dias_inatividade < 7).length;
  const emAtencao = colaboradores.filter((c) => c._risco.band === 'atencao' || c._risco.band === 'alta_atencao').length;
  const progressoMedio = computeMediaProgresso(colaboradores);

  const meses = aggregateMonthly(evolucaoFiltrada);
  const atual = meses[meses.length - 1];
  const anterior = meses.length >= 2 ? meses[meses.length - 2] : null;

  const taxaAprovAtual = atual?.tentativas ? Math.round((100 * atual.aprovados) / atual.tentativas) : null;
  const taxaAprovAnterior = anterior?.tentativas ? Math.round((100 * anterior.aprovados) / anterior.tentativas) : null;
  const deltaAprov = taxaAprovAtual !== null && taxaAprovAnterior !== null ? taxaAprovAtual - taxaAprovAnterior : null;
  const deltaXp = atual && anterior ? atual.xp - anterior.xp : null;

  return `
    <div class="ed-kpi-grid">
      ${kpiCardHtml('Colaboradores Ativos', total)}
      ${kpiCardHtml('Atividade Recente (7d)', `${Math.round((100 * comAtividadeRecente) / total)}%`, { sub: `${comAtividadeRecente} de ${total}` })}
      ${kpiCardHtml('Progresso Médio da Trilha', progressoMedio === null ? '—' : `${Math.round(progressoMedio)}%`)}
      ${kpiCardHtml('Aprovação em Quiz (mês)', taxaAprovAtual === null ? '—' : `${taxaAprovAtual}%`, { delta: deltaAprov, deltaSuffix: 'pp' })}
      ${kpiCardHtml('Score Ganho no Mês', atual ? atual.xp : '—', { delta: deltaXp })}
      ${kpiCardHtml('Em Atenção', emAtencao, { sub: `${emAtencao} de ${total}` })}
    </div>

    <div class="ed-grid-2">
      <div class="ed-section">
        <h3 class="ed-section-title">Funil de Aprendizagem</h3>
        <p class="ed-section-hint">Quantos colaboradores chegam a cada etapa — onde está a maior perda.</p>
        ${renderFunilChart(funil)}
      </div>
      <div class="ed-section">
        <h3 class="ed-section-title">Insights</h3>
        <p class="ed-section-hint">Gerados automaticamente a partir do que está carregado, só quando há amostra suficiente.</p>
        ${renderInsightsList(insights)}
      </div>
    </div>

    <div class="ed-section">
      <h3 class="ed-section-title">Quem precisa de atenção agora</h3>
      <p class="ed-section-hint">Colaboradores em Atenção ou Alta Atenção, ordenados por score de risco. Clique para o diagnóstico completo.</p>
      ${renderRiskPreview(colaboradores)}
    </div>
  `;
}

function renderFunilChart(funil) {
  if (!funil.length) return '<div class="ed-empty">Sem dados de progresso para os filtros atuais.</div>';
  const total = funil.length;
  const stages = [
    { label: 'Colaboradores ativos', value: total },
    { label: 'Iniciou a trilha', value: funil.filter((f) => f.iniciou_trilha).length },
    { label: 'Concluiu ao menos 1 módulo', value: funil.filter((f) => f.modulo_concluido).length },
    { label: 'Iniciou algum quiz', value: funil.filter((f) => f.quiz_iniciado).length },
    { label: 'Concluiu algum quiz', value: funil.filter((f) => f.quiz_concluido).length },
    { label: 'Foi aprovado em algum quiz', value: funil.filter((f) => f.quiz_aprovado).length },
  ];
  return `<div class="ed-card">${funnelChartSvg(stages)}</div>`;
}

function renderInsightsList(insights) {
  if (!insights.length) return '<div class="ed-empty">Sem sinais relevantes com os dados e filtros atuais.</div>';
  return `
    <ul class="ed-insight-list">
      ${insights.map((i) => `
        <li class="ed-insight-item tone-${i.tone}">
          <span class="ed-insight-marker"></span>
          <span>${i.text}</span>
        </li>`).join('')}
    </ul>`;
}

function renderRiskPreview(colaboradores) {
  const emRisco = colaboradores
    .filter((c) => c._risco.band === 'atencao' || c._risco.band === 'alta_atencao')
    .sort((a, b) => b._risco.score - a._risco.score)
    .slice(0, 8);

  if (!emRisco.length) {
    return '<div class="ed-empty">Nenhum colaborador em Atenção ou Alta Atenção com os filtros atuais.</div>';
  }

  return `
    <div class="ed-table-wrap">
      <table class="ed-table">
        <thead><tr><th>Colaborador</th><th>Loja</th><th>Progresso</th><th>Inatividade</th><th>Risco</th></tr></thead>
        <tbody>
          ${emRisco.map((c) => `
            <tr data-risk-row="${c.colaborador_id}">
              <td><span class="ed-cell-name">${c.full_name}</span><span class="ed-cell-sub">${c.job_title || '—'}</span></td>
              <td>${c.store_name || '—'}</td>
              <td>${progressCellHtml(c.progresso_pct)}</td>
              <td>${c.dias_inatividade === null ? 'Sem atividade' : `${c.dias_inatividade}d`}</td>
              <td>${riskBadgeHtml(c._risco)}</td>
            </tr>`).join('')}
        </tbody>
      </table>
    </div>`;
}

function wireRiskPreview(container, colaboradores) {
  container.querySelectorAll('[data-risk-row]').forEach((row) => {
    row.addEventListener('click', () => {
      const c = colaboradores.find((x) => x.colaborador_id === row.dataset.riskRow);
      if (c) openMemberDrawer(toDrawerMember(c));
    });
  });
}

// ── Aba 2: Evolução ──────────────────────────────────────────────────────

function renderEvolucao(evolucaoFiltrada) {
  const meses = aggregateMonthly(evolucaoFiltrada);
  if (meses.length < 2) {
    return '<div class="ed-empty">Ainda não há pelo menos 2 meses de dado real acumulado para uma série temporal confiável com os filtros atuais. Volte aqui quando houver mais histórico.</div>';
  }

  const labels = meses.map((m) => formatMesLabel(m.mes));
  const xpSeries = meses.map((m) => m.xp);
  const aprovSeries = meses.map((m) => (m.tentativas ? Math.round((100 * m.aprovados) / m.tentativas) : 0));

  return `
    <div class="ed-section">
      <h3 class="ed-section-title">Score de Performance ganho por mês</h3>
      <div class="ed-card">${lineChartSvg([{ label: 'Score', data: xpSeries }], { labels })}</div>
    </div>
    <div class="ed-section">
      <h3 class="ed-section-title">Checkpoints concluídos por mês</h3>
      <div class="ed-card">${barChartSvg(meses.map((m, i) => ({ label: labels[i], value: m.checkpoints })))}</div>
    </div>
    <div class="ed-section">
      <h3 class="ed-section-title">Taxa de aprovação em quiz por mês</h3>
      <p class="ed-section-hint">Considera só meses com tentativas de quiz registradas.</p>
      <div class="ed-card">${lineChartSvg([{ label: 'Aprovação %', data: aprovSeries }], { labels })}</div>
    </div>
  `;
}

// ── Aba 3: Equipe & Risco ────────────────────────────────────────────────

function thHtml(col) {
  const isSorted = state.table.sortKey === col.key;
  const cls = `${isSorted ? 'is-sorted' : ''} ${isSorted && state.table.sortDir === 'asc' ? 'is-asc' : ''}`.trim();
  return `<th data-sort-key="${col.key}" class="${cls}">${col.label}</th>`;
}

function rowHtml(c) {
  return `
    <tr data-team-row="${c.colaborador_id}">
      <td><span class="ed-cell-name">${c.full_name}</span><span class="ed-cell-sub">@${c.username}</span></td>
      <td>${c.store_name || '—'}</td>
      <td>${progressCellHtml(c.progresso_pct)}</td>
      <td>${c.quiz_taxa_aprovacao_pct === null || c.quiz_taxa_aprovacao_pct === undefined ? '—' : `${c.quiz_taxa_aprovacao_pct}%`}</td>
      <td>${c.dias_inatividade === null ? 'Sem atividade' : `${c.dias_inatividade}d`}</td>
      <td>${riskBadgeHtml(c._risco)}</td>
    </tr>`;
}

function equipeSearchFilter(list) {
  const q = (state.filters.busca || '').trim().toLowerCase();
  if (!q) return list;
  return list.filter((c) => `${c.full_name} ${c.username}`.toLowerCase().includes(q));
}

function sortColaboradores(list) {
  const { sortKey, sortDir } = state.table;
  return [...list].sort((a, b) => {
    let av = sortKey === 'risco' ? a._risco.score : a[sortKey];
    let bv = sortKey === 'risco' ? b._risco.score : b[sortKey];
    if (av === null || av === undefined) av = typeof bv === 'string' ? '' : -Infinity;
    if (bv === null || bv === undefined) bv = typeof av === 'string' ? '' : -Infinity;
    if (typeof av === 'string') return sortDir === 'asc' ? av.localeCompare(bv) : bv.localeCompare(av);
    return sortDir === 'asc' ? av - bv : bv - av;
  });
}

function renderEquipeRisco(colaboradoresBase) {
  return `
    <div class="ed-section" data-role="ed-team-section">
      <div class="ed-table-toolbar">
        <input type="search" id="edTeamSearch" placeholder="Buscar por nome ou usuário…" value="${escapeAttr(state.filters.busca)}">
      </div>
      <div data-role="ed-team-body">${renderEquipeBody(colaboradoresBase)}</div>
    </div>`;
}

function renderEquipeBody(colaboradoresBase) {
  const searched = equipeSearchFilter(colaboradoresBase);
  if (!searched.length) {
    return '<div class="ed-empty">Nenhum colaborador encontrado com os filtros e busca atuais.</div>';
  }

  const sorted = sortColaboradores(searched);
  const { pageSize } = state.table;
  const totalPages = Math.max(1, Math.ceil(sorted.length / pageSize));
  state.table.page = Math.min(Math.max(state.table.page, 1), totalPages);
  const page = state.table.page;
  const pageRows = sorted.slice((page - 1) * pageSize, page * pageSize);

  return `
    <p class="ed-section-hint" style="margin:0 0 10px;">${searched.length} colaborador${searched.length === 1 ? '' : 'es'}</p>
    <div class="ed-table-wrap">
      <table class="ed-table">
        <thead><tr>${TABLE_COLUMNS.map(thHtml).join('')}</tr></thead>
        <tbody>${pageRows.map(rowHtml).join('')}</tbody>
      </table>
    </div>
    <div class="ed-pagination">
      <button type="button" data-page-prev ${page <= 1 ? 'disabled' : ''}>← Anterior</button>
      <span>Página ${page} de ${totalPages}</span>
      <button type="button" data-page-next ${page >= totalPages ? 'disabled' : ''}>Próxima →</button>
    </div>`;
}

function wireEquipeSection(container, colaboradoresBase) {
  const section = container.querySelector('[data-role="ed-team-section"]');
  if (!section) return;

  const searchInput = section.querySelector('#edTeamSearch');
  const bodyEl = section.querySelector('[data-role="ed-team-body"]');

  const refreshBody = () => {
    bodyEl.innerHTML = renderEquipeBody(colaboradoresBase);
    wireEquipeBody(bodyEl, colaboradoresBase);
  };

  searchInput?.addEventListener('input', () => {
    state.filters.busca = searchInput.value;
    state.table.page = 1;
    refreshBody();
  });

  wireEquipeBody(bodyEl, colaboradoresBase);
}

function wireEquipeBody(bodyEl, colaboradoresBase) {
  bodyEl.querySelectorAll('[data-sort-key]').forEach((th) => {
    th.addEventListener('click', () => {
      const key = th.dataset.sortKey;
      if (state.table.sortKey === key) {
        state.table.sortDir = state.table.sortDir === 'asc' ? 'desc' : 'asc';
      } else {
        state.table.sortKey = key;
        state.table.sortDir = 'desc';
      }
      bodyEl.innerHTML = renderEquipeBody(colaboradoresBase);
      wireEquipeBody(bodyEl, colaboradoresBase);
    });
  });

  bodyEl.querySelector('[data-page-prev]')?.addEventListener('click', () => {
    state.table.page = Math.max(1, state.table.page - 1);
    bodyEl.innerHTML = renderEquipeBody(colaboradoresBase);
    wireEquipeBody(bodyEl, colaboradoresBase);
  });
  bodyEl.querySelector('[data-page-next]')?.addEventListener('click', () => {
    state.table.page += 1;
    bodyEl.innerHTML = renderEquipeBody(colaboradoresBase);
    wireEquipeBody(bodyEl, colaboradoresBase);
  });

  bodyEl.querySelectorAll('[data-team-row]').forEach((row) => {
    row.addEventListener('click', () => {
      const c = colaboradoresBase.find((x) => x.colaborador_id === row.dataset.teamRow);
      if (c) openMemberDrawer(toDrawerMember(c));
    });
  });
}

// ── Aba 4: Conteúdo ──────────────────────────────────────────────────────

function renderConteudo(gapsFiltrados, quizPerf, moduleAbandon) {
  return `
    <div class="ed-grid-2">
      <div class="ed-section">
        <h3 class="ed-section-title">Perguntas com mais erro (30 dias)</h3>
        <p class="ed-section-hint">Só perguntas com pelo menos ${AMOSTRA_MINIMA_GAP_PREVIEW} respostas registradas.</p>
        ${renderGapsPreviewTable(gapsFiltrados)}
      </div>
      <div class="ed-section">
        <h3 class="ed-section-title">Quizzes com menor aprovação</h3>
        <p class="ed-section-hint">Considera toda a organização, independente do filtro de loja — conteúdo é compartilhado entre lojas.</p>
        ${renderQuizPerfChart(quizPerf)}
      </div>
    </div>
    <div class="ed-section">
      <h3 class="ed-section-title">Módulos com maior abandono</h3>
      <p class="ed-section-hint">Colaboradores que começaram mas não concluíram. Também considera a organização inteira.</p>
      ${renderModuleAbandonChart(moduleAbandon)}
    </div>
  `;
}

function renderGapsPreviewTable(gaps) {
  const relevantes = (gaps || []).filter((g) => (g.total_answers ?? 0) >= AMOSTRA_MINIMA_GAP_PREVIEW).slice(0, 8);
  if (!relevantes.length) {
    return '<div class="ed-empty">Nenhuma pergunta com amostra suficiente nos últimos 30 dias.</div>';
  }
  return `
    <div class="ed-table-wrap">
      <table class="ed-table">
        <thead><tr><th>Pergunta</th><th>Quiz</th><th>Erro</th></tr></thead>
        <tbody>
          ${relevantes.map((g) => `
            <tr>
              <td>${g.question_text}</td>
              <td>${g.quiz_title || '—'}</td>
              <td><strong>${g.error_rate_pct}%</strong></td>
            </tr>`).join('')}
        </tbody>
      </table>
    </div>
    <button type="button" class="ed-link-btn" data-goto-gaps-report style="margin-top:14px;">Ver relatório completo, quem errou →</button>`;
}

function renderQuizPerfChart(quizPerf) {
  if (!quizPerf?.length) return '<div class="ed-empty">Nenhum quiz com tentativas suficientes ainda.</div>';
  const pior = quizPerf.slice(0, 8);
  return `<div class="ed-card">${barChartSvg(
    pior.map((q) => ({ label: q.title, value: q.taxaAprovacaoPct })),
    { horizontal: true, valueFormatter: (v) => `${v}%` },
  )}</div>`;
}

const ABANDONO_LIMIAR_PCT = 90; // abaixo disso é que vira sinal de dificuldade real, não ruído de amostra pequena

function renderModuleAbandonChart(moduleAbandon) {
  if (!moduleAbandon?.length) return '<div class="ed-empty">Nenhum módulo com amostra suficiente ainda.</div>';

  const comAbandonoReal = moduleAbandon.filter((m) => m.taxaConclusaoPct < ABANDONO_LIMIAR_PCT);
  if (!comAbandonoReal.length) {
    return `<div class="ed-empty">Nenhum módulo com abandono relevante — todos os módulos com amostra suficiente têm ${ABANDONO_LIMIAR_PCT}%+ de conclusão entre quem começou.</div>`;
  }

  const pior = comAbandonoReal.slice(0, 8);
  return `<div class="ed-card">${barChartSvg(
    pior.map((m) => ({ label: m.title, value: m.taxaConclusaoPct })),
    { horizontal: true, valueFormatter: (v) => `${v}%` },
  )}</div>`;
}

// ── Aba 5: Competências ──────────────────────────────────────────────────

function renderCompetencias(certFunil) {
  if (!certFunil?.length) return '<div class="ed-empty">Nenhuma certificação cadastrada.</div>';
  return `
    <div class="ed-section">
      <p class="ed-section-hint">Percentual de colaboradores ativos (organização inteira) com cada certificação emitida e válida hoje.</p>
      <div class="ed-comp-grid">
        ${certFunil.map((c) => `
          <div class="ed-comp-card">
            <span class="ed-comp-title">${c.title}</span>
            <span class="ed-comp-pct">${c.pct}%</span>
            <span class="ed-comp-meta">${c.emitidas} de ${c.totalAtivos} colaboradores${c.temConteudo ? '' : ' · conteúdo em preparação'}</span>
            <div class="ed-comp-track"><div class="ed-comp-fill" style="width:${c.pct}%"></div></div>
          </div>`).join('')}
      </div>
    </div>`;
}
