// src/pages/liderDashboard.js
// Dashboard do Líder — indicadores agregados da equipe (RN seção 8). Fica
// de fora nesta primeira versão: tempo médio de estudo e inatividade 7+
// dias (dependem de study_sessions/login_events, que existem no schema
// mas nenhum código ainda grava — nenhuma tela loga sessão de estudo ou
// evento de login hoje). Marcado como pendência explícita na UI, não
// escondido silenciosamente.

import { getCurrentProfile, isLeaderProfile, isAdminProfile } from '../config/supabase.js';
import {
  fetchTeamMembers,
  fetchTeamCertifications,
  fetchTeamQuizAttempts,
  fetchLeaderZonaAtual,
} from '../services/teamService.js';
import { postLeaderActivity } from '../services/activityFeedService.js';
import { openMemberDrawer } from '../components/MemberDrawer.js';
import {
  fetchCicloAtivo,
  fetchProgressoDoCiclo,
  fetchMinhaAssinatura,
  assinarCiclo,
} from '../services/homologacaoService.js';

const TIPO_LABEL = { modulo: 'Módulo', quiz: 'Quiz', blog: 'Post', game: 'Game' };

/** Best-effort — esta arquitetura não tem camada de servidor que inspecione o IP real da requisição, então isso nunca é uma prova forte, só um registro complementar. */
async function tentarObterIp() {
  try {
    const res = await fetch('https://api.ipify.org?format=json');
    const data = await res.json();
    return data.ip || null;
  } catch {
    return null;
  }
}

function dentroDaJanelaDeAssinatura() {
  const dia = new Date().getDay(); // 0=domingo ... 6=sábado
  return [5, 6, 0, 1].includes(dia); // sexta, sábado, domingo, segunda
}

/** Tipos de destaque → template fixo (fn_leader_post_activity, sql/022). Sem texto livre — RN §6.10. */
const HIGHLIGHT_TYPES = [
  { key: 'relogio_corrida', label: 'Relógio de Corrida (Forerunner)', needsSubject: true, models: ['165', '265', '965', '970'] },
  { key: 'relogio_outdoor', label: 'Relógio Outdoor (Fenix)', needsSubject: true, models: ['Fenix 8', 'Enduro 3', 'Instinct 3', 'Instinct 3 Solar'] },
  { key: 'relogio_lifestyle', label: 'Relógio Lifestyle (Venu)', needsSubject: true, models: null },
  { key: 'combo_acessorios', label: 'Combo/Acessórios', needsSubject: true, models: null },
  { key: 'meta_dia', label: 'Meta do Dia (equipe)', needsSubject: false, models: null },
  { key: 'meta_mes', label: 'Meta do Mês (equipe)', needsSubject: false, models: null },
];

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'lider') initLiderDashboard();
});

async function initLiderDashboard() {
  const container = document.getElementById('liderContainer');
  if (!container) return;

  container.innerHTML = '<p class="learning-loading">Carregando dashboard da equipe…</p>';

  try {
    const profile = await getCurrentProfile();
    if (!profile || !(isLeaderProfile(profile) || isAdminProfile(profile))) {
      container.innerHTML = '<p class="learning-error">Esta área é restrita a líderes e administradores.</p>';
      return;
    }

    const [membersRaw, certificationsRaw, attemptsRaw, zonaAtualRaw] = await Promise.all([
      fetchTeamMembers(),
      fetchTeamCertifications(),
      fetchTeamQuizAttempts(),
      fetchLeaderZonaAtual(),
    ]);
    const members = membersRaw || [];
    const certifications = certificationsRaw || [];
    const attempts = attemptsRaw || [];
    const zonaAtual = zonaAtualRaw || [];

    const activeCertsCount = certifications.filter((c) => !c?.revoked_at).length;
    const avgScore = members.length
      ? Math.round(members.reduce((sum, m) => sum + (m?.performance_score || 0), 0) / members.length)
      : 0;
    const passedCount = attempts.filter((a) => a?.passed).length;
    const approvalRate = attempts.length ? Math.round((passedCount / attempts.length) * 100) : null;

    const stores = distinctStores(members);
    const ciclosAtivos = (await Promise.all(stores.map(async (s) => {
      const ciclo = await fetchCicloAtivo(s.id);
      return ciclo ? { store: s, ciclo } : null;
    }))).filter(Boolean);

    container.innerHTML = `
      ${renderHomologacaoWidget(ciclosAtivos)}

      <div class="dash-quick-grid" style="margin-bottom:28px;">
        <div class="dash-mini-card">
          <span class="dash-mini-tag">Colaboradores</span>
          <div class="cert-name-text" style="margin-top:8px;">${members.length}</div>
        </div>
        <div class="dash-mini-card">
          <span class="dash-mini-tag">Score médio da equipe</span>
          <div class="cert-name-text" style="margin-top:8px;">${avgScore} pts</div>
        </div>
        <div class="dash-mini-card">
          <span class="dash-mini-tag">Certificações emitidas</span>
          <div class="cert-name-text" style="margin-top:8px;">${activeCertsCount}</div>
        </div>
        <div class="dash-mini-card">
          <span class="dash-mini-tag">Aprovação em quizzes</span>
          <div class="cert-name-text" style="margin-top:8px;">${approvalRate === null ? '—' : `${approvalRate}%`}</div>
        </div>
      </div>

      ${renderActivityForm(members)}

      <h3 class="dash-section-label">Funil de Capacitação</h3>
      ${renderFunilMacro(zonaAtual)}
      ${renderZonaAtualSection(zonaAtual)}

      <h3 class="dash-section-label">Equipe</h3>
      ${renderTeamTable(members)}

      <h3 class="dash-section-label" style="margin-top:28px;">Tentativas de quiz recentes</h3>
      ${renderAttemptsList(attempts)}
    `;

    setupActivityForm(container, members);
    setupZonaAtualFilter(container, zonaAtual);
    setupHomologacaoWidget(container, ciclosAtivos, profile.id);
    setupTeamTableClicks(container, members);
  } catch (err) {
    console.error('[LiderDashboard] erro ao carregar dashboard da equipe:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar o dashboard da equipe agora.</p>';
  }
}

/**
 * Homologação Semanal (sql/048) — o admin marca conteúdo avulso (módulo,
 * quiz, post, game) que "vale" na semana pra loja do líder; aqui ele vê o
 * progresso consolidado e assina confirmando. Um card por loja com ciclo
 * ativo (líder pode responder por mais de uma loja).
 */
function renderHomologacaoWidget(ciclosAtivos) {
  if (!ciclosAtivos?.length) return '';

  return (ciclosAtivos || []).map(({ store, ciclo } = {}) => `
    <div class="hom-sign-card" data-role="hom-card" data-ciclo-id="${ciclo?.id || ''}" data-store-id="${store?.id || ''}">
      <div style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:8px;">
        <h3 class="dash-section-label" style="margin:0;">📝 Homologação Semanal, ${store?.name || '—'}</h3>
        <span class="dash-empty-text" style="margin:0;">${ciclo?.data_inicio ? new Date(ciclo.data_inicio).toLocaleDateString('pt-BR') : '—'} a ${ciclo?.data_fim ? new Date(ciclo.data_fim).toLocaleDateString('pt-BR') : '—'}</span>
      </div>
      <div class="hom-sign-progress-track"><div class="hom-sign-progress-fill" data-role="hom-progress-fill" style="width:0%"></div></div>
      <p class="dash-empty-text" data-role="hom-progress-label" style="margin:0 0 12px;">Carregando progresso…</p>
      <div data-role="hom-sign-area"></div>
    </div>`).join('');
}

function setupHomologacaoWidget(container, ciclosAtivos, liderId) {
  ciclosAtivos.forEach(async ({ ciclo }) => {
    const card = container.querySelector(`[data-role="hom-card"][data-ciclo-id="${ciclo.id}"]`);
    if (!card) return;

    try {
      const [itens, minhaAssinatura] = await Promise.all([
        fetchProgressoDoCiclo(ciclo.id),
        fetchMinhaAssinatura(ciclo.id, liderId),
      ]);

      const media = itens.length
        ? Math.round((itens.reduce((sum, it) => sum + Number(it.pct_conclusao), 0) / itens.length) * 10) / 10
        : 0;

      card.querySelector('[data-role="hom-progress-fill"]').style.width = `${media}%`;
      card.querySelector('[data-role="hom-progress-label"]').textContent =
        `${media}% de conclusão média da equipe em ${itens.length} ${itens.length === 1 ? 'item' : 'itens'} cobrados`;

      const signArea = card.querySelector('[data-role="hom-sign-area"]');

      if (minhaAssinatura?.status_assinatura === 'assinado') {
        signArea.innerHTML = `<p class="admin-create-success" style="margin:0;">✓ Assinado por você em ${new Date(minhaAssinatura.assinado_em).toLocaleString('pt-BR')}, ${minhaAssinatura.percentual_conclusao_time}% registrado.</p>`;
        return;
      }

      const podeAssinar = dentroDaJanelaDeAssinatura();
      signArea.innerHTML = `
        <button type="button" class="login-btn admin-create-submit" data-role="hom-abrir-modal" ${podeAssinar ? '' : 'disabled'} style="width:auto;">
          Ver itens avaliados e assinar
        </button>
        ${!podeAssinar ? '<p class="dash-empty-text" style="margin-top:6px;">Assinatura liberada de sexta-feira 00:00 a segunda-feira 23:59.</p>' : ''}
      `;

      signArea.querySelector('[data-role="hom-abrir-modal"]')?.addEventListener('click', () => {
        abrirModalAssinatura(ciclo, itens, liderId, () => setupHomologacaoWidget(container, ciclosAtivos, liderId));
      });
    } catch (err) {
      console.error('[LiderDashboard] erro ao carregar homologação semanal:', err);
      card.querySelector('[data-role="hom-progress-label"]').textContent = 'Não foi possível carregar o progresso agora.';
    }
  });
}

function abrirModalAssinatura(ciclo, itens, liderId, onSigned) {
  const root = document.createElement('div');
  root.innerHTML = `
    <div class="hom-modal-backdrop" data-role="hom-modal-backdrop">
      <div class="hom-modal">
        <h3 class="dash-section-label" style="margin-top:0;">Itens avaliados nesta semana</h3>
        <ul class="hom-modal-item-list">
          ${(itens || []).map((it) => `<li><strong>${TIPO_LABEL[it?.tipo_conteudo] || it?.tipo_conteudo || '—'}:</strong> ${it?.titulo || '—'}, ${it?.pct_conclusao ?? 0}% concluído</li>`).join('')}
        </ul>
        <p class="dash-empty-text">Ao assinar, você confirma que revisou o progresso da equipe nos itens acima referentes ao ciclo de ${new Date(ciclo.data_inicio).toLocaleDateString('pt-BR')} a ${new Date(ciclo.data_fim).toLocaleDateString('pt-BR')}.</p>
        <div id="homModalResult"></div>
        <div style="display:flex; gap:10px; margin-top:12px;">
          <button type="button" class="login-btn admin-create-submit" id="homConfirmarBtn" style="width:auto;">Assinar Homologação</button>
          <button type="button" class="cb-editor-btn" data-role="hom-modal-close">Cancelar</button>
        </div>
      </div>
    </div>`;
  document.body.appendChild(root);

  const close = () => root.remove();
  root.querySelector('[data-role="hom-modal-backdrop"]').addEventListener('click', (e) => {
    if (e.target === e.currentTarget) close();
  });
  root.querySelector('[data-role="hom-modal-close"]').addEventListener('click', close);

  root.querySelector('#homConfirmarBtn').addEventListener('click', async () => {
    const btn = root.querySelector('#homConfirmarBtn');
    const resultEl = root.querySelector('#homModalResult');
    btn.disabled = true;
    btn.textContent = 'Assinando…';

    try {
      const ip = await tentarObterIp();
      const termo = `Confirmo que revisei o progresso da equipe no ciclo de ${ciclo.data_inicio} a ${ciclo.data_fim} e assino esta homologação semanal.`;
      await assinarCiclo(ciclo.id, { ipAssinatura: ip, termoTexto: termo });
      close();
      onSigned();
    } catch (err) {
      console.error('[LiderDashboard] erro ao assinar ciclo:', err);
      resultEl.innerHTML = `<p class="learning-error">${err.message || 'Não foi possível assinar agora.'}</p>`;
      btn.disabled = false;
      btn.textContent = 'Assinar Homologação';
    }
  });
}

/**
 * Visão macro do funil: % do time em cada zona real de hoje (Explorador,
 * Atleta, Trilha concluída). Só 2 zonas têm conteúdo — Maratonista/
 * Triatleta não têm módulo cadastrado ainda (certifications.zone_id nulo),
 * por isso não aparecem aqui: mostrar 0% pras duas seria fingir uma
 * granularidade que a trilha ainda não tem.
 */
function renderFunilMacro(zonaAtual) {
  if (!zonaAtual?.length) return '<p class="learning-empty">Nenhum colaborador na sua loja ainda.</p>';

  const total = zonaAtual.length;
  const counts = new Map();
  (zonaAtual || []).forEach((r) => counts.set(r?.zona_atual, (counts.get(r?.zona_atual) || 0) + 1));

  // ordem fixa (funil, não alfabética) — "Trilha concluída" sempre por último
  const ordem = ['Explorador', 'Atleta', 'Trilha concluída'];
  const etapas = ordem.filter((k) => counts.has(k));

  return `
    <div class="dash-quick-grid" style="margin-bottom:16px;">
      ${etapas.map((etapa) => {
        const n = counts.get(etapa);
        const pct = Math.round((n / total) * 100);
        return `
          <div class="dash-mini-card">
            <span class="dash-mini-tag">${etapa}</span>
            <div class="cert-name-text" style="margin-top:8px;">${pct}%</div>
            <span class="lib-prod-series">${n} de ${total} colaboradores</span>
          </div>`;
      }).join('')}
    </div>`;
}

const INATIVIDADE_LIMIAR_DIAS = 15; // RN combinada com o usuário: "estagnado" = 15+ dias sem progresso real

function inatividadeBadge(dias, zonaAtual) {
  if (zonaAtual === 'Trilha concluída') return '<span class="lib-pill">✓ Concluiu</span>';
  if (dias === null || dias === undefined) return '<span class="lib-prod-series">Sem atividade ainda</span>';
  if (dias >= INATIVIDADE_LIMIAR_DIAS) return `<span class="lib-pill" style="background:var(--g3); color:var(--g2); border-color:var(--g4);">🔴 Estagnado · ${dias}d</span>`;
  if (dias >= 7) return `<span class="lib-pill" style="background:var(--warn-tint); color:var(--warn); border-color:#e6c3c3;">⚠️ Atenção · ${dias}d</span>`;
  return `<span class="lib-pill" style="background:var(--acc-tint); color:var(--acc); border-color:var(--g4);">🟤 Em dia · ${dias}d</span>`;
}

function onboardingBadge(row) {
  if (!row.alerta_onboarding) return '<span class="lib-prod-series">—</span>';
  const estimado = row.onboarding_data_estimada ? ' (data estimada)' : '';
  return `<span class="lib-pill" style="background:var(--g3); color:var(--g2); border-color:var(--g4);">⚠️ 90+ dias sem Atleta${estimado}</span>`;
}

/** Tabela detalhada do funil — filtro de loja é client-side (dropdown), a view já limita o conjunto por RLS embutida. */
function renderZonaAtualSection(zonaAtual) {
  const stores = [...new Map(zonaAtual.filter((r) => r.store_id).map((r) => [r.store_id, r.loja])).entries()]
    .map(([id, name]) => ({ id, name }));

  return `
    <div style="margin-bottom:12px; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px;">
      <p class="dash-empty-text" style="margin:0;">
        Posição de cada colaborador no funil (só Explorador e Atleta têm conteúdo real hoje — Maratonista/Triatleta
        ainda não têm módulo cadastrado). Inatividade calculada pela última lição/quiz real, já que sessão de
        estudo/login ainda não é registrada em nenhuma tela.
      </p>
      ${stores.length > 1 ? `
        <select id="zonaAtualStoreFilter" class="login-input" style="max-width:200px;">
          <option value="">Todas as lojas</option>
          ${stores.map((s) => `<option value="${s.id}">${s.name}</option>`).join('')}
        </select>
      ` : ''}
    </div>
    <div id="zonaAtualTableWrap">${zonaAtualTableHtml(zonaAtual)}</div>
  `;
}

function zonaAtualTableHtml(rows) {
  if (!rows?.length) return '<p class="learning-empty">Nenhum colaborador nessa loja.</p>';

  return `
    <div class="lib-table-wrap" style="margin-bottom:28px;">
      <table class="lib-table">
        <thead><tr><th>Nome</th><th>Loja</th><th>Zona Atual</th><th>Módulo Atual</th><th>Inatividade</th><th>Onboarding</th></tr></thead>
        <tbody>
          ${(rows || []).map((r) => `
            <tr>
              <td><div class="lib-prod-name">${r?.nome || '—'}</div></td>
              <td class="lib-prod-para">${r?.loja || '—'}</td>
              <td class="lib-prod-para">${r?.zona_atual || '—'}</td>
              <td class="lib-prod-dest">${r?.modulo_atual || '—'}</td>
              <td>${inatividadeBadge(r?.dias_inatividade, r?.zona_atual)}</td>
              <td>${onboardingBadge(r || {})}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>`;
}

function setupZonaAtualFilter(container, zonaAtual) {
  const select = container.querySelector('#zonaAtualStoreFilter');
  if (!select) return;

  select.addEventListener('change', () => {
    const filtered = select.value ? zonaAtual.filter((r) => r.store_id === select.value) : zonaAtual;
    container.querySelector('#zonaAtualTableWrap').innerHTML = zonaAtualTableHtml(filtered);
  });
}

/** Lojas distintas a partir da própria equipe carregada — evita nova query só pra popular o dropdown de Meta do Dia/Mês. */
function distinctStores(members) {
  const map = new Map();
  (members || []).forEach((m) => {
    if (m?.store_id && m?.stores?.name && !map.has(m.store_id)) {
      map.set(m.store_id, m.stores.name);
    }
  });
  return [...map.entries()].map(([id, name]) => ({ id, name }));
}

function renderActivityForm(members) {
  const stores = distinctStores(members);

  return `
    <div class="admin-create-card" style="margin-bottom:28px;">
      <h3 class="dash-section-label">Destaques do Balcão</h3>
      <p class="dash-empty-text" style="margin-top:0;">Selecione o tipo, o vendedor e o modelo, sem campo de texto livre, a mensagem sai pronta de um template fixo.</p>
      <form id="activityForm" class="admin-create-form">
        <select id="actType" class="login-input" required>
          <option value="">Tipo de destaque...</option>
          ${HIGHLIGHT_TYPES.map((t) => `<option value="${t.key}">${t.label}</option>`).join('')}
        </select>
        <select id="actSubject" class="login-input" hidden>
          <option value="">Vendedor...</option>
          ${(members || []).map((m) => `<option value="${m?.id || ''}">${m?.full_name || '—'}</option>`).join('')}
        </select>
        <select id="actModel" class="login-input" hidden>
          <option value="">Modelo...</option>
        </select>
        <select id="actStore" class="login-input" hidden>
          <option value="">Loja...</option>
          ${(stores || []).map((s) => `<option value="${s?.id || ''}">${s?.name || '—'}</option>`).join('')}
        </select>
        <button type="submit" class="login-btn admin-create-submit" id="actSubmitBtn">Postar no Mural</button>
      </form>
      <div id="activityResult"></div>
    </div>`;
}

function setupActivityForm(container, members) {
  const form = container.querySelector('#activityForm');
  if (!form) return;

  const typeSelect = form.querySelector('#actType');
  const subjectSelect = form.querySelector('#actSubject');
  const modelSelect = form.querySelector('#actModel');
  const storeSelect = form.querySelector('#actStore');
  const resultEl = container.querySelector('#activityResult');
  const stores = distinctStores(members);

  typeSelect.addEventListener('change', () => {
    const type = HIGHLIGHT_TYPES.find((t) => t.key === typeSelect.value);
    resultEl.innerHTML = '';

    subjectSelect.hidden = !type?.needsSubject;
    subjectSelect.required = !!type?.needsSubject;
    subjectSelect.value = '';

    // só um dropdown de loja se o líder responder por mais de uma — com uma só, usa ela direto sem escolha.
    // required precisa desligar junto com hidden: campo required escondido bloqueia o submit
    // silenciosamente (checkValidity falha sem nenhuma mensagem visível pro usuário).
    const isTeamTemplate = !type?.needsSubject && !!type;
    const singleStore = stores.length <= 1;
    storeSelect.hidden = !isTeamTemplate || singleStore;
    storeSelect.required = isTeamTemplate && !singleStore;
    storeSelect.value = '';

    if (type?.models) {
      modelSelect.hidden = false;
      modelSelect.required = true;
      modelSelect.innerHTML = `<option value="">Modelo...</option>${type.models.map((m) => `<option value="${m}">${m}</option>`).join('')}`;
    } else {
      modelSelect.hidden = true;
      modelSelect.required = false;
      modelSelect.value = '';
    }
  });

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const type = HIGHLIGHT_TYPES.find((t) => t.key === typeSelect.value);
    if (!type) return;

    const submitBtn = form.querySelector('#actSubmitBtn');
    submitBtn.disabled = true;
    submitBtn.textContent = 'Postando…';
    resultEl.innerHTML = '';

    try {
      const storeId = !type.needsSubject && stores.length === 1 ? stores[0].id : (storeSelect.value || null);

      await postLeaderActivity({
        templateKey: type.key,
        subjectId: type.needsSubject ? subjectSelect.value : null,
        productModel: type.models ? modelSelect.value : null,
        storeId,
      });

      resultEl.innerHTML = '<p class="admin-create-success">✓ Destaque postado no Mural de Atividades.</p>';
      form.reset();
      typeSelect.dispatchEvent(new Event('change'));
    } catch (err) {
      console.error('[LiderDashboard] erro ao postar destaque:', err);
      resultEl.innerHTML = `<p class="learning-error">${err.message || 'Não foi possível postar agora.'}</p>`;
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = 'Postar no Mural';
    }
  });
}

function renderTeamTable(members) {
  if (!members?.length) return '<p class="learning-empty">Nenhum colaborador na sua loja ainda.</p>';

  return `
    <div class="lib-table-wrap">
      <table class="lib-table">
        <thead><tr><th>Nome</th><th>Cargo</th><th>Loja</th><th>Status</th><th>Score</th></tr></thead>
        <tbody>
          ${(members || []).map((m) => `
            <tr class="team-row-clickable" data-member-id="${m?.id || ''}" title="Ver diagnóstico de ${m?.full_name || 'colaborador'}">
              <td><div class="lib-prod-name">${m?.full_name || '—'}</div><span class="lib-prod-series">@${m?.username || '—'}</span></td>
              <td class="lib-prod-para">${m?.job_title || '—'}</td>
              <td class="lib-prod-para">${m?.stores?.name || '—'}</td>
              <td class="lib-prod-para">${statusLabel(m?.status)}</td>
              <td class="lib-prod-dest">${m?.performance_score ?? 0} pts</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>`;
}

/** Clique em qualquer linha da Equipe abre o Raio-X individual (MemberDrawer) — busca o membro já carregado em memória, sem query nova. */
function setupTeamTableClicks(container, members) {
  container.querySelectorAll('[data-member-id]').forEach((row) => {
    const memberId = row.dataset.memberId;
    if (!memberId) return;
    row.addEventListener('click', () => {
      const member = (members || []).find((m) => m?.id === memberId);
      if (member) openMemberDrawer(member);
    });
  });
}

function statusLabel(status) {
  if (status === 'active') return 'Ativo';
  if (status === 'inactive') return 'Inativo';
  if (status === 'suspended') return 'Bloqueado';
  return status || '—';
}

function renderAttemptsList(attempts) {
  if (!attempts?.length) return '<p class="learning-empty">Nenhuma tentativa de quiz registrada ainda.</p>';

  return `
    <div class="lib-accordion">
      ${(attempts || []).map((a) => `
        <div class="lib-acc-item">
          <div class="lib-acc-btn" style="cursor:default;">
            <span>${a?.passed ? '✓' : '✗'} ${a?.profiles?.full_name || 'Colaborador'} · ${a?.quizzes?.title || 'Quiz'}</span>
            <span class="lib-deepdive-summary">${a?.score_pct ?? 0}% · ${a?.finished_at ? new Date(a.finished_at).toLocaleDateString('pt-BR') : '—'}</span>
          </div>
        </div>
      `).join('')}
    </div>`;
}
