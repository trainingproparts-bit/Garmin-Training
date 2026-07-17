// src/pages/adminPanel.js
// Painel Admin — gestão de usuários (cargo, loja, bloqueio) + cadastro de
// usuário novo (RN 1.1), via Edge Function admin-create-user (a única forma
// possível: precisa da Supabase Admin API, que exige service role key e
// nunca pode rodar no navegador — ver src/services/adminService.js).

import { getCurrentProfile, isAdminProfile } from '../config/supabase.js';
import {
  fetchAllProfiles,
  fetchRoles,
  fetchStores,
  updateProfileRole,
  updateProfileStore,
  updateProfileStatus,
  createUser,
} from '../services/adminService.js';
import { fetchActiveBrands } from '../services/brandService.js';
import { insertAvaliacaoGoogle } from '../services/avaliacoesGoogleService.js';

window.addEventListener('panel:activated', (e) => {
  if (e.detail.panelId === 'admin') initAdminPanel();
});

async function initAdminPanel() {
  const container = document.getElementById('adminContainer');
  if (!container) return;

  container.innerHTML = '<p class="learning-loading">Carregando usuários…</p>';

  try {
    const profile = await getCurrentProfile();
    if (!profile || !isAdminProfile(profile)) {
      container.innerHTML = '<p class="learning-error">Esta área é restrita a administradores.</p>';
      return;
    }

    const [profiles, roles, stores, brandsResult] = await Promise.all([
      fetchAllProfiles(),
      fetchRoles(),
      fetchStores(),
      fetchActiveBrands(),
    ]);
    renderPanel(container, profiles, roles, stores, brandsResult.data || []);
  } catch (err) {
    console.error('[AdminPanel] erro ao carregar usuários:', err);
    container.innerHTML = '<p class="learning-error">Não foi possível carregar os usuários agora.</p>';
  }
}

function renderPanel(container, profiles, roles, stores, brands) {
  container.innerHTML = `
    ${renderCreateUserForm(roles, stores, brands)}
    ${renderGoogleReviewForm(profiles)}
    <h3 class="dash-section-label" style="margin-top:28px;">Usuários cadastrados</h3>
    <div id="usersTableSection">${renderTable(profiles, roles, stores)}</div>
  `;

  // No sucesso do cadastro, só a tabela recarrega — o card com a senha
  // (exibição única, RN 1.1) não pode ser apagado por um refresh do painel
  // inteiro, senão o admin nunca teria tempo de ler/copiar a senha.
  setupCreateUserForm(container, () => refreshUsersTable(container, roles, stores));
  setupGoogleReviewForm(container, profiles);
  setupTableHandlers(container);
}

/**
 * Registro manual de avaliação Google (sql/046_avaliacoes_google.sql) —
 * governança explícita do usuário: "quem gerencia essas avaliações é o
 * ADMIN" (não o líder, por isso vive aqui e não em liderDashboard.js). Uma
 * linha por avaliação individual, com data real — alimenta a contagem de
 * "Melhor reputação do mês" no Dashboard Principal, sem depender mais de
 * profiles.reputation_score (número único sem histórico).
 */
function renderGoogleReviewForm(profiles) {
  return `
    <div class="admin-create-card" style="margin-top:20px;">
      <h3 class="dash-section-label">Registrar Avaliação Google</h3>
      <p class="dash-empty-text" style="margin-top:0;">Vendedor + data + nota, alimenta "Melhor reputação do mês" no Dashboard Principal.</p>
      <form id="googleReviewForm" class="admin-create-form">
        <select id="grVendedor" class="login-input" required>
          <option value="">Vendedor...</option>
          ${profiles.map((p) => `<option value="${p.id}">${p.full_name}</option>`).join('')}
        </select>
        <input type="date" id="grData" class="login-input" required value="${new Date().toISOString().slice(0, 10)}">
        <select id="grNota" class="login-input">
          <option value="">Nota (opcional)...</option>
          ${[5, 4, 3, 2, 1].map((n) => `<option value="${n}">${'★'.repeat(n)}</option>`).join('')}
        </select>
        <input type="text" id="grObservacao" class="login-input" placeholder="Link/print/texto (opcional)">
        <button type="submit" class="login-btn admin-create-submit" id="grSubmitBtn">Registrar Avaliação</button>
      </form>
      <div id="googleReviewResult"></div>
    </div>`;
}

function setupGoogleReviewForm(container, profiles) {
  const form = container.querySelector('#googleReviewForm');
  if (!form) return;

  const resultEl = container.querySelector('#googleReviewResult');

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const submitBtn = form.querySelector('#grSubmitBtn');
    submitBtn.disabled = true;
    submitBtn.textContent = 'Registrando…';
    resultEl.innerHTML = '';

    try {
      const profileId = form.querySelector('#grVendedor').value;
      const dataAvaliacao = form.querySelector('#grData').value;
      const notaRaw = form.querySelector('#grNota').value;
      const observacao = form.querySelector('#grObservacao').value.trim();

      await insertAvaliacaoGoogle({
        profileId,
        dataAvaliacao,
        nota: notaRaw ? Number(notaRaw) : null,
        observacao: observacao || null,
      });

      const nome = profiles.find((p) => p.id === profileId)?.full_name || 'Colaborador';
      resultEl.innerHTML = `<p class="admin-create-success">✓ Avaliação registrada para ${nome}.</p>`;
      form.reset();
      form.querySelector('#grData').value = new Date().toISOString().slice(0, 10);
    } catch (err) {
      console.error('[AdminPanel] erro ao registrar avaliação Google:', err);
      resultEl.innerHTML = `<p class="learning-error">${err.message || 'Não foi possível registrar agora.'}</p>`;
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = 'Registrar Avaliação';
    }
  });
}

async function refreshUsersTable(container, roles, stores) {
  const section = container.querySelector('#usersTableSection');
  if (!section) return;
  try {
    const profiles = await fetchAllProfiles();
    section.innerHTML = renderTable(profiles, roles, stores);
    setupTableHandlers(container);
  } catch (err) {
    console.error('[AdminPanel] erro ao atualizar lista de usuários:', err);
  }
}

function renderCreateUserForm(roles, stores, brands) {
  const roleOptions = roles.map((r) => `<option value="${r.id}">${r.label}</option>`).join('');
  const storeOptions = stores.map((s) => `<option value="${s.id}">${s.name}</option>`).join('');
  const brandOptions = brands.map((b) => `<option value="${b.id}">${b.name}</option>`).join('');
  const adminRoleId = roles.find((r) => r.code === 'admin')?.id;

  return `
    <div class="admin-create-card">
      <h3 class="dash-section-label">Cadastrar novo usuário</h3>
      <form id="createUserForm" class="admin-create-form" data-admin-role-id="${adminRoleId ?? ''}">
        <input type="text" id="cuFullName" class="login-input" placeholder="Nome completo" required autocomplete="off" />
        <input type="text" id="cuUsername" class="login-input" placeholder="Username (ex: joao.silva)" required autocomplete="off" />
        <select id="cuRole" class="login-input" required>
          <option value="">Papel...</option>
          ${roleOptions}
        </select>
        <select id="cuStore" class="login-input">
          <option value="">Sem loja</option>
          ${storeOptions}
        </select>
        <select id="cuBrand" class="login-input">
          <option value="">Sem marca</option>
          ${brandOptions}
        </select>
        <button type="submit" class="login-btn admin-create-submit" id="cuSubmitBtn">Cadastrar</button>
      </form>
      <div id="createUserResult"></div>
    </div>
  `;
}

function setupCreateUserForm(container, onCreated) {
  const form = container.querySelector('#createUserForm');
  if (!form) return;

  const roleSelect = form.querySelector('#cuRole');
  const storeSelect = form.querySelector('#cuStore');
  const brandSelect = form.querySelector('#cuBrand');
  const resultEl = container.querySelector('#createUserResult');
  const adminRoleId = form.dataset.adminRoleId;

  // Admin nasce sem loja/marca (vê a organização inteira) — mesmo padrão do backfill.
  roleSelect.addEventListener('change', () => {
    const isAdminRole = adminRoleId && roleSelect.value === adminRoleId;
    storeSelect.disabled = isAdminRole;
    brandSelect.disabled = isAdminRole;
    if (isAdminRole) {
      storeSelect.value = '';
      brandSelect.value = '';
    }
  });

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const submitBtn = form.querySelector('#cuSubmitBtn');
    submitBtn.disabled = true;
    submitBtn.textContent = 'Cadastrando…';
    resultEl.innerHTML = '';

    try {
      const result = await createUser({
        full_name: form.querySelector('#cuFullName').value.trim(),
        username: form.querySelector('#cuUsername').value.trim(),
        role_id: Number(roleSelect.value),
        store_id: storeSelect.value || null,
        brand_id: brandSelect.value || null,
      });

      resultEl.innerHTML = `
        <div class="admin-create-success">
          <strong>Usuário criado com sucesso.</strong> Repasse a senha pessoalmente ou por canal interno —
          ela só aparece aqui, uma única vez.
          <div class="admin-create-credentials">
            <span>Username: <strong>${result.username}</strong></span>
            <span>Senha temporária: <strong>${result.password}</strong></span>
          </div>
        </div>`;
      form.reset();
      onCreated();
    } catch (err) {
      console.error('[AdminPanel] erro ao cadastrar usuário:', err);
      resultEl.innerHTML = `<p class="learning-error">${err.message || 'Não foi possível cadastrar o usuário agora.'}</p>`;
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = 'Cadastrar';
    }
  });
}

function renderTable(profiles, roles, stores) {
  if (!profiles.length) {
    return '<p class="learning-empty">Nenhum usuário cadastrado ainda.</p>';
  }

  return `
    <div class="lib-table-wrap">
      <table class="lib-table">
        <thead><tr><th>Nome</th><th>Cargo</th><th>Loja</th><th>Status</th><th>Score</th></tr></thead>
        <tbody>
          ${profiles.map((p) => `
            <tr data-profile-id="${p.id}">
              <td><div class="lib-prod-name">${p.full_name}</div><span class="lib-prod-series">@${p.username}</span></td>
              <td>
                <select class="login-input" data-role-select style="padding:6px;font-size:12.5px;">
                  ${roles.map((r) => `<option value="${r.id}" ${r.id === p.role_id ? 'selected' : ''}>${r.label}</option>`).join('')}
                </select>
              </td>
              <td>
                <select class="login-input" data-store-select style="padding:6px;font-size:12.5px;">
                  <option value="">Sem loja</option>
                  ${stores.map((s) => `<option value="${s.id}" ${s.id === p.store_id ? 'selected' : ''}>${s.name}</option>`).join('')}
                </select>
              </td>
              <td>
                <button type="button" class="learning-card-btn" data-status-toggle data-current-status="${p.status}" style="padding:5px 10px;font-size:11.5px;">
                  ${p.status === 'suspended' ? '🔒 Desbloquear' : '🔓 Bloquear'}
                </button>
              </td>
              <td class="lib-prod-dest">${p.performance_score ?? 0} pts</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>
  `;
}

function setupTableHandlers(container) {
  container.querySelectorAll('[data-role-select]').forEach((select) => {
    select.addEventListener('change', async () => {
      const profileId = select.closest('[data-profile-id]').dataset.profileId;
      try {
        await updateProfileRole(profileId, Number(select.value));
      } catch (err) {
        console.error('[AdminPanel] erro ao atualizar cargo:', err);
        alert('Não foi possível atualizar o cargo agora.');
      }
    });
  });

  container.querySelectorAll('[data-store-select]').forEach((select) => {
    select.addEventListener('change', async () => {
      const profileId = select.closest('[data-profile-id]').dataset.profileId;
      try {
        await updateProfileStore(profileId, select.value || null);
      } catch (err) {
        console.error('[AdminPanel] erro ao atualizar loja:', err);
        alert('Não foi possível atualizar a loja agora.');
      }
    });
  });

  container.querySelectorAll('[data-status-toggle]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const profileId = btn.closest('[data-profile-id]').dataset.profileId;
      const isBlocked = btn.dataset.currentStatus === 'suspended';
      const nextStatus = isBlocked ? 'active' : 'suspended';
      btn.disabled = true;
      try {
        await updateProfileStatus(profileId, nextStatus);
        btn.dataset.currentStatus = nextStatus;
        btn.textContent = nextStatus === 'suspended' ? '🔒 Desbloquear' : '🔓 Bloquear';
      } catch (err) {
        console.error('[AdminPanel] erro ao atualizar status:', err);
        alert('Não foi possível atualizar o status agora.');
      } finally {
        btn.disabled = false;
      }
    });
  });
}
