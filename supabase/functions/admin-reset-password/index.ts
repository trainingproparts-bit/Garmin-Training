// supabase/functions/admin-reset-password/index.ts
//
// Redefinição de senha pelo Admin — colaboradores usam e-mail técnico
// ${username}@proparts.internal (sql trigger 009 + admin-create-user), então
// o fluxo padrão de "esqueci minha senha" do Supabase (envio por e-mail) não
// funciona: ninguém lê essa caixa de entrada. Único jeito de trocar a senha
// de outra pessoa é via Supabase Admin API (auth.admin.updateUserById), que
// exige service role key — nunca pode rodar no navegador. Mesmo padrão de
// validação do admin-create-user:
//   1. Valida o JWT de quem chamou e confirma que é admin de verdade
//      (SELECT em profiles/roles com o client do CHAMADOR, respeita RLS).
//   2. Gera uma senha aleatória nova (nunca definida pelo cliente).
//   3. auth.admin.updateUserById() troca a senha do usuário alvo.
// Senha gerada é devolvida na resposta uma única vez, pro admin repassar
// pessoalmente — mesma regra do cadastro (RN 1.1).

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
    return json({ error: 'Apenas administradores podem redefinir senhas.' }, 403);
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: 'Corpo da requisição inválido.' }, 400);
  }

  const targetUserId = typeof body.user_id === 'string' ? body.user_id : '';
  if (!targetUserId) {
    return json({ error: 'user_id é obrigatório.' }, 400);
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey);

  // Confirma que o alvo é mesmo um profile real (evita chamar a Admin API
  // com um id qualquer vindo do cliente) e recupera o username pra devolver
  // na resposta, já que o admin pode não ter decorado.
  const { data: targetProfile, error: targetErr } = await adminClient
    .from('profiles')
    .select('username')
    .eq('id', targetUserId)
    .single();

  if (targetErr || !targetProfile) {
    return json({ error: 'Usuário não encontrado.' }, 404);
  }

  const password = generatePassword();

  const { error: updateErr } = await adminClient.auth.admin.updateUserById(targetUserId, { password });
  if (updateErr) {
    return json({ error: updateErr.message || 'Erro ao redefinir a senha.' }, 400);
  }

  return json({ success: true, username: targetProfile.username, password });
});
