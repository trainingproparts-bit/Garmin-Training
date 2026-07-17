// src/services/certificationService.js
// Camada de acesso a dados de certificações. A emissão em si é automática
// (trigger fn_issue_certification, disparada quando user_progress indica
// trilha 100% concluída) — este service só LÊ o estado, nunca escreve
// certificação diretamente do cliente (RN 5.1/5.2 — emissão/revogação
// são sempre server-side ou ação auditada de admin).

import { supabase } from '../config/supabase.js';

/** Lista as certificações definidas para uma trilha (ex.: os 4 níveis do GPS da Carreira). */
export async function fetchCertificationsForTrail(trailId) {
  const { data, error } = await supabase
    .from('certifications')
    .select('id, slug, title, criteria, certificate_template_url')
    .eq('trail_id', trailId)
    .order('title', { ascending: true });
  if (error) throw error;
  return data || [];
}

/** Certificações já emitidas para o usuário logado (ou, se um líder/admin chamar com outro userId, de um colaborador — RLS escopa por loja). */
export async function fetchUserCertifications(userId) {
  const { data, error } = await supabase
    .from('user_certifications')
    .select('id, certification_id, issued_at, certificate_url, revoked_at, certifications(title)')
    .eq('user_id', userId);
  if (error) throw error;
  return data || [];
}
