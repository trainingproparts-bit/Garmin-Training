// supabase/functions/admin-create-user/index.ts
//
// Cadastro de novo usuário pelo Admin (RN 1.1 — regras-de-negocio-training-hub.md).
// Único jeito de chamar a Supabase Admin API (auth.admin.createUser) com a
// service role key, que nunca pode rodar no navegador. Fluxo:
//   1. Valida o JWT de quem chamou (Authorization header) e confirma que é
//      admin de verdade (SELECT em profiles/roles com o client do CHAMADOR,
//      não com service role — respeita RLS normalmente).
//   2. Gera uma senha aleatória (nunca definida pelo cliente).
//   3. auth.admin.createUser() com email técnico ${username}@proparts.internal
//      (mesmo padrão do backfill/trigger 009 — RN 1.1 não pede e-mail no
//      cadastro, login é por username). Dispara o trigger 009, que cria o
//      profile com role_id=1 (collaborator) e full_name/username vindos do
//      user_metadata passado aqui.
//   4. RPC fn_admin_finalize_new_profile (sql/016) ajusta role_id/store_id/
//      brand_id conforme escolhido no formulário — essa RPC revalida no
//      servidor que quem está pedindo é admin (não confia cegamente no
//      passo 1 sozinho).
//   5. Se o passo 4 falhar, desfaz o auth.users criado no passo 3 (evita
//      usuário órfão sem o papel/loja corretos).
// Senha gerada é devolvida na resposta uma única vez — RN 1.1: "recomenda-se
// exibição única na tela do admin", nunca enviada por e-mail/canal inseguro.

import { createClient } from 'jsr:@supabase/supabase-js@2';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
}

function generatePassword(length = 10) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789';
  const bytes = new Uint8Array(length);
  crypto.getRandomValues(bytes);
  return Array.from(bytes, (b) => chars[b % chars.length]).join('');
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS });
  }

  if (req.method !== 'POST') {
    return json({ error: 'Método não permitido.' }, 405);
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return json({ error: 'Não autenticado.' }, 401);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

  // Cliente com o JWT de quem chamou — só pra confirmar identidade/papel,
  // respeita RLS normalmente (nada de service role aqui ainda).
  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: { user }, error: userErr } = await callerClient.auth.getUser();
  if (userErr || !user) {
    return json({ error: 'Sessão inválida.' }, 401);
  }

  const { data: callerProfile, error: callerProfileErr } = await callerClient
    .from('profiles')
    .select('role_id, roles(code)')
    .eq('id', user.id)
    .single();

  if (callerProfileErr || callerProfile?.roles?.code !== 'admin') {
    return json({ error: 'Apenas administradores podem cadastrar usuários.' }, 403);
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: 'Corpo da requisição inválido.' }, 400);
  }

  const full_name = typeof body.full_name === 'string' ? body.full_name.trim() : '';
  const username = typeof body.username === 'string' ? body.username.trim().toLowerCase() : '';
  const role_id = Number(body.role_id);
  const store_id = body.store_id || null;
  const brand_id = body.brand_id || null;

  if (!full_name || !username || !Number.isInteger(role_id)) {
    return json({ error: 'Nome completo, username e papel são obrigatórios.' }, 400);
  }
  if (!/^[a-z0-9._-]{3,40}$/.test(username)) {
    return json({ error: 'Username deve ter 3-40 caracteres (letras, números, ponto, traço ou underscore).' }, 400);
  }

  const password = generatePassword();
  const email = `${username}@proparts.internal`;

  const adminClient = createClient(supabaseUrl, serviceRoleKey);

  const { data: created, error: createErr } = await adminClient.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { full_name, username },
  });

  if (createErr || !created?.user) {
    const message = (createErr?.message || '').includes('already been registered')
      ? 'Já existe um usuário com esse username.'
      : createErr?.message || 'Erro ao criar usuário.';
    return json({ error: message }, 400);
  }

  const { error: finalizeErr } = await adminClient.rpc('fn_admin_finalize_new_profile', {
    p_actor_id: user.id,
    p_new_user_id: created.user.id,
    p_role_id: role_id,
    p_store_id: store_id,
    p_brand_id: brand_id,
  });

  if (finalizeErr) {
    await adminClient.auth.admin.deleteUser(created.user.id);
    return json({ error: finalizeErr.message }, 400);
  }

  return json({ success: true, username, password, user_id: created.user.id });
});
