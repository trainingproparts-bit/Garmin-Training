// src/services/avaliacoesGoogleService.js
// Avaliações Google (sql/046) — uma linha por avaliação individual, com
// data real, registrada manualmente pelo admin (sem integração com a API do
// Google). Fonte de "Melhor reputação do mês" no Dashboard Principal —
// substitui o antigo profiles.reputation_score (número único sem histórico)
// por uma contagem de verdade dentro do mês corrente.

import { supabase } from '../config/supabase.js';

/**
 * Avaliações com data dentro do mês corrente, para os perfis informados.
 * Escopo de marca já vem da lista de profileIds passada (tipicamente o
 * array já buscado de v_team_album, que é brand-scoped) — não duplica
 * filtro de marca aqui.
 */
export async function fetchAvaliacoesGoogleDoMes(profileIds) {
  if (!profileIds?.length) return [];

  const now = new Date();
  const inicioMes = new Date(now.getFullYear(), now.getMonth(), 1).toISOString().slice(0, 10);
  const inicioProximoMes = new Date(now.getFullYear(), now.getMonth() + 1, 1).toISOString().slice(0, 10);

  const { data, error } = await supabase
    .from('avaliacoes_google')
    .select('id, profile_id, nota, data_avaliacao')
    .in('profile_id', profileIds)
    .gte('data_avaliacao', inicioMes)
    .lt('data_avaliacao', inicioProximoMes);
  if (error) throw error;
  return data;
}

/** Registro manual (admin) de uma avaliação Google — Vendedor + Data + Nota + observação/link. */
export async function insertAvaliacaoGoogle({ profileId, nota, dataAvaliacao, observacao }) {
  const { data: userData } = await supabase.auth.getUser();

  const { data, error } = await supabase
    .from('avaliacoes_google')
    .insert({
      profile_id: profileId,
      nota: nota || null,
      data_avaliacao: dataAvaliacao || new Date().toISOString().slice(0, 10),
      observacao: observacao || null,
      created_by: userData?.user?.id || null,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}
