// src/services/rankingService.js
// Ranking de pontos ao vivo (profiles.performance_score, já o total
// acumulado real — sql/004) + Destaque de Vendas por loja (texto manual,
// atualizado por admin/líder — sql/025_ranking_store_highlights.sql).
// Sem temporada trimestral/medalhas (RN §6.4/6.6) nesta rodada.

import { supabase } from '../config/supabase.js';

/**
 * Ranking ao vivo dos colaboradores ativos da marca, maior pontuação primeiro.
 * Lê de v_ranking_public (sql/026), não direto de profiles — profiles só
 * tem RLS de SELECT pra si mesmo/líder da própria loja/admin, então um
 * colaborador comum não conseguiria ver o placar de ninguém além dele
 * mesmo sem essa view (achado testando ao vivo com Daniel Lucena).
 */
export async function fetchPointsRanking(brandId, limit = 50) {
  const { data, error } = await supabase
    .from('v_ranking_public')
    .select('id, full_name, performance_score, store_id, store_name')
    .eq('brand_id', brandId)
    .order('performance_score', { ascending: false })
    .limit(limit);
  if (error) throw error;
  return data;
}

export async function fetchStoresForBrand(brandId) {
  const { data, error } = await supabase
    .from('stores')
    .select('id, name')
    .eq('brand_id', brandId)
    .eq('is_active', true)
    .order('name');
  if (error) throw error;
  return data;
}

/** IDs das lojas que o usuário logado lidera — filtra quais destaques ele pode editar. */
export async function fetchLeaderStoreIds(userId) {
  const { data, error } = await supabase
    .from('store_leaders')
    .select('store_id')
    .eq('leader_id', userId);
  if (error) throw error;
  return data.map((r) => r.store_id);
}

export async function fetchStoreHighlights(brandId) {
  const { data, error } = await supabase
    .from('store_sales_highlights')
    .select('id, store_id, message, updated_at, stores!inner(name, brand_id)')
    .eq('stores.brand_id', brandId);
  if (error) throw error;
  return data;
}

/** Cria ou substitui o destaque atual da loja (1 linha por loja — uq_store_sales_highlights_store). */
export async function upsertStoreHighlight(storeId, message, updatedByUserId) {
  const { data, error } = await supabase
    .from('store_sales_highlights')
    .upsert(
      { store_id: storeId, message, updated_by: updatedByUserId, updated_at: new Date().toISOString() },
      { onConflict: 'store_id' },
    )
    .select()
    .single();
  if (error) throw error;
  return data;
}
