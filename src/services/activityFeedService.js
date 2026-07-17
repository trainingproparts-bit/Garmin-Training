// src/services/activityFeedService.js
// Mural de Atividades — leitura + assinatura Realtime (activity_feed já vem
// escopada por marca via RLS, sql/022_activity_feed.sql; nenhum filtro de
// loja/marca é feito aqui no cliente). Postagem manual do líder passa
// sempre por fn_leader_post_activity (templates fixos, nunca texto livre).

import { supabase } from '../config/supabase.js';

const ACTIVITY_SELECT = 'id, message, source_event, created_at, subject:profiles!subject_id(full_name), store:stores!store_id(name)';

/** Últimas N atividades do mural (mais recente primeiro). */
export async function fetchRecentActivity(limit = 15) {
  const { data, error } = await supabase
    .from('activity_feed')
    .select(ACTIVITY_SELECT)
    .order('created_at', { ascending: false })
    .limit(limit);
  if (error) throw error;
  return data;
}

/**
 * Uma atividade específica com nome de sujeito/loja já embutidos — usado
 * pra enriquecer o payload cru do Realtime (que só traz as colunas da
 * tabela, sem embed) antes de exibir no mural, senão o destaque de
 * nome/loja no texto não funciona pra itens que chegam ao vivo.
 */
export async function fetchActivityById(id) {
  const { data, error } = await supabase
    .from('activity_feed')
    .select(ACTIVITY_SELECT)
    .eq('id', id)
    .single();
  if (error) throw error;
  return data;
}

/**
 * Assina novos INSERTs em activity_feed em tempo real (sem polling).
 * Retorna o channel — chame unsubscribeFromActivityFeed(channel) ao desmontar.
 */
export function subscribeToActivityFeed(onInsert) {
  return supabase
    .channel('activity_feed_changes')
    .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'activity_feed' }, (payload) => {
      onInsert(payload.new);
    })
    .subscribe();
}

export function unsubscribeFromActivityFeed(channel) {
  if (channel) supabase.removeChannel(channel);
}

/** Postagem manual do líder/admin — template fixo, nunca texto livre (RN §6.10). */
export async function postLeaderActivity({ templateKey, subjectId, productModel, storeId }) {
  const { data, error } = await supabase.rpc('fn_leader_post_activity', {
    p_template_key: templateKey,
    p_subject_id: subjectId || null,
    p_product_model: productModel || null,
    p_store_id: storeId || null,
  });
  if (error) throw error;
  return data;
}
