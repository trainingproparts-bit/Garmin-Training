// src/services/adminService.js
// Gestão de usuários existentes (cargo, loja, status). NÃO cria usuário
// novo — isso exige a Supabase Admin API com a service role key, que não
// pode rodar no navegador (precisa de uma Edge Function, ainda não
// construída). Tudo aqui depende de profiles_admin_all (RLS) e do trigger
// fn_guard_profile_self_update (sql/008) barrando qualquer edição de
// cargo/loja/status por quem não é admin.

import { supabase } from '../config/supabase.js';

/** Todos os perfis da organização — RLS (profiles_admin_all) só deixa admin ver todo mundo. */
export async function fetchAllProfiles() {
  const { data, error } = await supabase
    .from('profiles')
    .select('id, full_name, username, job_title, status, performance_score, role_id, store_id, roles(code, label), stores!profiles_store_id_fkey(name)')
    .is('deleted_at', null)
    .order('full_name', { ascending: true });
  if (error) throw error;
  return data;
}

export async function fetchRoles() {
  const { data, error } = await supabase.from('roles').select('id, code, label').order('id');
  if (error) throw error;
  return data;
}

export async function fetchStores() {
  const { data, error } = await supabase
    .from('stores')
    .select('id, name, code, brand_id, brands(name)')
    .eq('is_active', true)
    .order('name');
  if (error) throw error;
  return data;
}

/** Troca o cargo de um perfil. */
export async function updateProfileRole(profileId, roleId) {
  const { error } = await supabase.from('profiles').update({ role_id: roleId }).eq('id', profileId);
  if (error) throw error;
}

/** Troca a loja de um perfil (RN 1.7 — ação exclusiva de admin, histórico do colaborador não é afetado). */
export async function updateProfileStore(profileId, storeId) {
  const { error } = await supabase.from('profiles').update({ store_id: storeId }).eq('id', profileId);
  if (error) throw error;
}

/** Bloqueia/desbloqueia manualmente (RN 1.5) — 'suspended' = bloqueado, 'active' = normal. */
export async function updateProfileStatus(profileId, status) {
  const { error } = await supabase.from('profiles').update({ status }).eq('id', profileId);
  if (error) throw error;
}

/**
 * Cadastro de novo usuário (RN 1.1) — só possível via Edge Function porque
 * precisa da Supabase Admin API (service role key, nunca no navegador).
 * A função valida de novo, no servidor, que quem chama é admin — o client
 * aqui só encaminha o pedido. Senha é gerada pelo servidor e devolvida uma
 * única vez na resposta, para o admin repassar pessoalmente.
 */
export async function createUser({ full_name, username, role_id, store_id, brand_id }) {
  const { data, error } = await supabase.functions.invoke('admin-create-user', {
    body: { full_name, username, role_id, store_id, brand_id },
  });
  if (error) {
    const message = data?.error || error.message || 'Erro ao criar usuário.';
    throw new Error(message);
  }
  if (data?.error) throw new Error(data.error);
  return data;
}

/**
 * Remove um usuário da plataforma (RN — desligamento de colaborador). Nunca
 * é um DELETE físico: chama fn_soft_delete_profile (sql/117), que marca
 * status='inactive' e deleted_at=now(), preservando histórico/certificações
 * e barrando login. A checagem de admin e o registro de quem fez a ação
 * acontecem dentro da própria função (auth.uid() no servidor), não aqui.
 */
export async function deleteUser(profileId) {
  const { error } = await supabase.rpc('fn_soft_delete_profile', { p_profile_id: profileId });
  if (error) throw error;
}

/**
 * Redefine a senha de qualquer usuário (RN — colaboradores usam e-mail
 * técnico @proparts.internal, então o "esqueci minha senha" por e-mail do
 * Supabase não serve; só a Admin API resolve, daí a Edge Function). Mesma
 * regra de exibição única da senha do cadastro — nunca fica salva em lugar
 * nenhum além dessa resposta.
 */
export async function resetUserPassword(userId) {
  const { data, error } = await supabase.functions.invoke('admin-reset-password', {
    body: { user_id: userId },
  });
  if (error) {
    const message = data?.error || error.message || 'Erro ao redefinir a senha.';
    throw new Error(message);
  }
  if (data?.error) throw new Error(data.error);
  return data;
}
