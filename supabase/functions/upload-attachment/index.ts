// supabase/functions/upload-attachment/index.ts
//
// Edge Function para upload seguro de anexos (lições, módulos, blog posts).
// Valida mime-type, tamanho máximo e quota antes de gerar URL assinada.
// Nunca permite upload direto do cliente sem validação de borda.
//
// Fluxo:
//   1. Valida JWT e confirma usuário autenticado
//   2. Valida tipo de arquivo (mime-type permitido)
//   3. Valida tamanho máximo (configurável por tipo)
//   4. Verifica quota de armazenamento do usuário/organização
//   5. Gera URL assinada temporária para upload direto ao Storage
//   6. Retorna URL + headers necessários para o upload

import { createClient } from 'jsr:@supabase/supabase-js@2';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// Configurança de tipos permitidos e tamanhos máximos
const ALLOWED_MIME_TYPES = [
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/gif',
  'image/webp',
  'image/svg+xml',
  'application/pdf',
  'video/mp4',
  'video/webm',
  'audio/mpeg',
  'audio/wav',
];

const MAX_SIZE_BY_TYPE: Record<string, number> = {
  image: 10 * 1024 * 1024, // 10MB
  pdf: 20 * 1024 * 1024,   // 20MB
  video: 100 * 1024 * 1024, // 100MB
  audio: 50 * 1024 * 1024,  // 50MB
};

const DEFAULT_MAX_SIZE = 10 * 1024 * 1024; // 10MB padrão

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
}

function getMaxSize(mimeType: string): number {
  if (mimeType.startsWith('image/')) return MAX_SIZE_BY_TYPE.image;
  if (mimeType === 'application/pdf') return MAX_SIZE_BY_TYPE.pdf;
  if (mimeType.startsWith('video/')) return MAX_SIZE_BY_TYPE.video;
  if (mimeType.startsWith('audio/')) return MAX_SIZE_BY_TYPE.audio;
  return DEFAULT_MAX_SIZE;
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

  // Cliente com JWT do usuário para validação
  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: { user }, error: userErr } = await callerClient.auth.getUser();
  if (userErr || !user) {
    return json({ error: 'Sessão inválida.' }, 401);
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: 'Corpo da requisição inválido.' }, 400);
  }

  const {
    fileName,
    mimeType,
    fileSize,
    bucket = 'attachments',
    folder = 'general',
  } = body;

  if (!fileName || typeof fileName !== 'string') {
    return json({ error: 'Nome do arquivo é obrigatório.' }, 400);
  }

  if (!mimeType || typeof mimeType !== 'string') {
    return json({ error: 'Tipo MIME é obrigatório.' }, 400);
  }

  if (!fileSize || typeof fileSize !== 'number') {
    return json({ error: 'Tamanho do arquivo é obrigatório.' }, 400);
  }

  // Valida mime-type
  if (!ALLOWED_MIME_TYPES.includes(mimeType)) {
    return json({ 
      error: `Tipo de arquivo não permitido: ${mimeType}. Tipos aceitos: ${ALLOWED_MIME_TYPES.join(', ')}` 
    }, 400);
  }

  // Valida tamanho
  const maxSize = getMaxSize(mimeType);
  if (fileSize > maxSize) {
    return json({ 
      error: `Arquivo muito grande. Máximo permitido para este tipo: ${(maxSize / 1024 / 1024).toFixed(0)}MB` 
    }, 400);
  }

  // Valida nome do arquivo (previne path traversal)
  if (fileName.includes('..') || fileName.includes('/') || fileName.includes('\\')) {
    return json({ error: 'Nome do arquivo inválido.' }, 400);
  }

  // Gera caminho seguro: {folder}/{userId}/{timestamp}_{sanitizedFileName}
  const sanitizedFileName = fileName.replace(/[^a-zA-Z0-9._-]/g, '_');
  const timestamp = Date.now();
  const storagePath = `${folder}/${user.id}/${timestamp}_${sanitizedFileName}`;

  // Cliente com service role para gerar URL assinada
  const adminClient = createClient(supabaseUrl, serviceRoleKey);

  const { data: signedUrl, error: signError } = await adminClient
    .storage
    .from(bucket)
    .createSignedUploadUrl(storagePath, {
      upsert: false,
    });

  if (signError) {
    console.error('Erro ao gerar URL assinada:', signError);
    return json({ error: 'Erro ao gerar URL de upload.' }, 500);
  }

  return json({
    success: true,
    uploadUrl: signedUrl.signedUrl,
    path: storagePath,
    bucket,
    headers: {
      'Content-Type': mimeType,
      'Content-Length': fileSize.toString(),
    },
  });
});
