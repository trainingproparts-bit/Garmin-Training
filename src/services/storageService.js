// src/services/storageService.js
// Upload de imagens de conteúdo pro Supabase Storage — mesmo padrão já
// comprovado em produção por certificateService.js (upload direto do client,
// sem Edge Function): supabase.storage.from(bucket).upload(...) usando a
// sessão do usuário logado, autorização via policy de storage (sql/116), não
// via validação de servidor separada. Bucket 'content-images' (sql/116) já
// aplica limite real de tamanho/tipo no próprio Storage — a validação aqui é
// só pra dar erro amigável antes de sequer tentar o upload.

import { supabase } from '../config/supabase.js';

const BUCKET = 'content-images';

export const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
export const MAX_IMAGE_SIZE_BYTES = 5 * 1024 * 1024; // 5MB — mesmo limite do bucket (sql/116)

/** @returns {string|null} mensagem de erro, ou null se o arquivo é válido */
export function validateImageFile(file) {
  if (!file) return 'Nenhum arquivo selecionado.';
  if (!ALLOWED_IMAGE_TYPES.includes(file.type)) {
    return 'Formato não suportado. Envie uma imagem JPG, PNG, WEBP ou GIF.';
  }
  if (file.size > MAX_IMAGE_SIZE_BYTES) {
    return `Imagem muito grande (máx. ${Math.round(MAX_IMAGE_SIZE_BYTES / 1024 / 1024)}MB).`;
  }
  return null;
}

function extensionFor(file) {
  const fromName = (file.name || '').split('.').pop()?.toLowerCase().replace(/[^a-z0-9]/g, '');
  if (fromName) return fromName;
  const fromType = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp', 'image/gif': 'gif' };
  return fromType[file.type] || 'jpg';
}

/**
 * Envia uma imagem pro bucket 'content-images' e devolve a URL pública.
 * @param {File} file
 * @param {string} folder - ex.: 'covers/trilhas', 'avatars/<userId>', 'blocks/licoes'
 * @returns {Promise<string>} URL pública da imagem
 */
export async function uploadContentImage(file, folder) {
  const validationError = validateImageFile(file);
  if (validationError) throw new Error(validationError);

  const path = `${folder}/${crypto.randomUUID()}.${extensionFor(file)}`;

  const { error } = await supabase.storage.from(BUCKET).upload(path, file, {
    contentType: file.type,
    upsert: false,
  });
  if (error) throw error;

  const { data } = supabase.storage.from(BUCKET).getPublicUrl(path);
  return data.publicUrl;
}
