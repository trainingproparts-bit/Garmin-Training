// src/config/supabase.js
// Ponto único de acesso ao Supabase. Nenhum outro arquivo deve chamar
// createClient() de novo — sempre importar { supabase } daqui.

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL;
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  throw new Error(
    '[Supabase] Faltam VITE_SUPABASE_URL / VITE_SUPABASE_ANON_KEY no .env — veja .env.example.'
  );
}

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    persistSession: true,     // mantém sessão entre recarregamentos (RN 1.2 — sessão persistente)
    autoRefreshToken: true,   // renova o JWT sozinho enquanto o usuário está ativo
    detectSessionInUrl: true, // necessário para o fluxo de recuperação de senha por e-mail (RN 1.4)
  },
});

/** Usuário autenticado no Supabase Auth (não é o profile da aplicação). */
export async function getCurrentUser() {
  const { data: { user }, error } = await supabase.auth.getUser();
  if (error) {
    // "Auth session missing" é o estado normal do modo convidado (RN 1.2) —
    // não é uma falha a reportar como erro, só ausência de sessão.
    if (error.name !== 'AuthSessionMissingError') {
      console.error('[Supabase] getCurrentUser:', error.message);
    }
    return null;
  }
  return user;
}

/**
 * Profile da aplicação (tabela `profiles`), 1:1 com auth.users.
 * É o objeto que praticamente toda a UI usa (nome, loja, cargo, must_change_password...).
 * Inclui o papel resolvido (roles.code/label) via join — é o que a nav e as
 * páginas de Líder/Admin usam pra decidir o que mostrar. Papel nunca é
 * decidido só pelo client: toda tela de líder/admin também depende da RLS
 * correspondente (profiles_select_leader, fn_is_admin()...) para os dados
 * reais — isto aqui só controla o que aparece na tela, não é a autorização.
 */
export async function getCurrentProfile() {
  const user = await getCurrentUser();
  if (!user) return null;

  const { data, error } = await supabase
    .from('profiles')
    .select('*, roles(code, label)')
    .eq('id', user.id)
    .single();

  if (error) {
    console.error('[Supabase] getCurrentProfile:', error.message);
    return null;
  }
  return data;
}

/** Atalhos de papel a partir do profile já carregado (ver getCurrentProfile). */
export function isLeaderProfile(profile) {
  return profile?.roles?.code === 'leader';
}

export function isAdminProfile(profile) {
  return profile?.roles?.code === 'admin';
}

export async function signOut() {
  const { error } = await supabase.auth.signOut();
  if (error) console.error('[Supabase] signOut:', error.message);
  return { error };
}
