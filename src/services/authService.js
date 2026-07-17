// src/services/authService.js
// Serviço de autenticação - login, logout e verificação de sessão
// Migrado de js/auth.js para o ecossistema Vite

import { supabase, getCurrentUser, signOut as supabaseSignOut } from '../config/supabase.js';

/**
 * Realiza login com username (ex: samara.pereira) e senha.
 * O e-mail real (que o usuário nunca precisa saber/digitar) é resolvido no
 * servidor via fn_resolve_login_email — não depende de nenhum domínio fixo,
 * então funciona igual pra quem tem e-mail real em qualquer domínio e pra
 * quem ainda está no e-mail placeholder interno.
 * @param {string} username - Username sem o domínio
 * @param {string} password - Senha do usuário
 * @returns {Promise<{success: boolean, error?: string}>}
 */
export async function signIn(username, password) {
  try {
    let email = username;

    if (!username.includes('@')) {
      const { data: resolvedEmail, error: resolveError } = await supabase.rpc(
        'fn_resolve_login_email',
        { p_username: username }
      );

      if (resolveError || !resolvedEmail) {
        return { success: false, error: 'Usuário ou senha inválidos.' };
      }

      email = resolvedEmail;
    }

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      return { success: false, error: error.message };
    }

    return { success: true, data };
  } catch (err) {
    console.error('[authService] Erro ao fazer login:', err);
    return { success: false, error: 'Erro ao conectar com o servidor de autenticação.' };
  }
}

/**
 * Realiza logout do usuário e limpa a sessão.
 * @returns {Promise<{success: boolean, error?: string}>}
 */
export async function signOut() {
  try {
    const { error } = await supabaseSignOut();
    if (error) {
      return { success: false, error: error.message };
    }
    return { success: true };
  } catch (err) {
    console.error('[authService] Erro ao fazer logout:', err);
    return { success: false, error: 'Erro ao encerrar sessão.' };
  }
}

/**
 * Verifica se existe uma sessão ativa.
 * @returns {Promise<boolean>}
 */
export async function isAuthenticated() {
  try {
    const user = await getCurrentUser();
    return user !== null;
  } catch (err) {
    console.error('[authService] Erro ao verificar autenticação:', err);
    return false;
  }
}

/**
 * Obtém a sessão atual do Supabase.
 * @returns {Promise<{session: object|null, error?: string}>}
 */
export async function getSession() {
  try {
    const { data: { session }, error } = await supabase.auth.getSession();
    if (error) {
      return { session: null, error: error.message };
    }
    return { session };
  } catch (err) {
    console.error('[authService] Erro ao obter sessão:', err);
    return { session: null, error: 'Erro ao obter sessão.' };
  }
}
