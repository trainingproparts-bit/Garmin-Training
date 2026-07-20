// src/services/revisaoService.js
// Camada de acesso a dados da Revisão Inteligente — terceiro domínio da
// plataforma (sql/066/067), independente de Trilhas e Academia de Produtos.
// Nunca calcula fila nem estado de conhecimento aqui: fn_start_review_session/
// fn_submit_review_item/fn_finalize_review_session (RPCs SECURITY DEFINER)
// fazem isso no servidor — este arquivo só chama RPC e busca o CONTEÚDO ao
// vivo na tabela-fonte de cada item (nunca duplicado no catálogo).

import { supabase } from '../config/supabase.js';

/**
 * Card "Revisão Inteligente" na Home — disponíveis + última sessão (streak
 * vem de streakService, não duplicado aqui). brandId é sempre a marca
 * ESCOLHIDA (window.selectedBrandId) — nunca profiles.brand_id, que é NULL
 * pra contas admin (bug real corrigido em sql/068: dava sempre "0
 * disponíveis" pra qualquer admin, já que c.brand_id = null nunca bate).
 */
export async function fetchReviewStats(brandId) {
  const { data, error } = await supabase.rpc('fn_review_stats', { p_brand_id: brandId }).single();
  if (error) throw error;
  return data;
}

/** Produtos publicados da marca — pro seletor do modo "Revisão por Produto". */
export async function fetchProductsForPicker(brandId) {
  const { data, error } = await supabase
    .from('products')
    .select('id, slug, name')
    .eq('brand_id', brandId)
    .eq('is_published', true)
    .order('order_index', { ascending: true });
  if (error) throw error;
  return data;
}

/** Monta a fila no servidor e devolve o session_id — nunca a fila calculada no cliente. brandId é sempre a marca escolhida (window.selectedBrandId), mesmo motivo de fetchReviewStats. */
export async function startReviewSession(mode, brandId, productId = null) {
  const { data, error } = await supabase.rpc('fn_start_review_session', { p_mode: mode, p_brand_id: brandId, p_product_id: productId });
  if (error) throw error;
  return data; // uuid da sessão
}

/** Fila já congelada da sessão (RLS restringe à própria sessão) — só ponteiros, sem conteúdo. */
export async function fetchSessionItems(sessionId) {
  const { data, error } = await supabase
    .from('review_session_items')
    .select('id, order_index, catalog_item_id, review_catalog(source_table, source_id, block_index, block_type, title, product_id)')
    .eq('session_id', sessionId)
    .order('order_index', { ascending: true });
  if (error) throw error;
  return data;
}

/**
 * Busca o CONTEÚDO ao vivo de um item pra renderizar — nunca lido do
 * catálogo (que só tem ponteiro). Retorna { kind: 'block', block } pros tipos
 * já cobertos por ContentBlocks.js, ou { kind: 'quiz_question', ... } /
 * { kind: 'comparison_spec', ... } pros 2 tipos novos específicos da revisão.
 */
export async function fetchItemContent(catalogEntry) {
  const { source_table, source_id, block_index, block_type } = catalogEntry;

  if (block_type === 'quiz_question') {
    const { data: question, error: qErr } = await supabase
      .from('questions')
      .select('id, body, explanation')
      .eq('id', source_id)
      .single();
    if (qErr) throw qErr;

    const { data: alternatives, error: aErr } = await supabase
      .from('alternatives')
      .select('id, body, order_index')
      .eq('question_id', source_id)
      .order('order_index', { ascending: true });
    if (aErr) throw aErr;

    return { kind: 'quiz_question', question, alternatives };
  }

  if (block_type === 'comparison_spec') {
    const { data: item, error } = await supabase
      .from('comparison_items')
      .select('spec_label, value_a, value_b, winner, product_comparisons(product_a:product_a_id(name), product_b:product_b_id(name))')
      .eq('id', source_id)
      .single();
    if (error) throw error;
    return { kind: 'comparison_spec', item };
  }

  // Demais tipos: busca o array de blocks da tabela-fonte e pega só o bloco pedido.
  let blocks;
  if (source_table === 'lessons') {
    const { data, error } = await supabase.from('lessons').select('body').eq('id', source_id).single();
    if (error) throw error;
    blocks = data.body?.blocks;
  } else if (source_table === 'content_library') {
    const { data, error } = await supabase.from('content_library').select('payload').eq('id', source_id).single();
    if (error) throw error;
    blocks = data.payload?.blocks;
  } else if (source_table === 'product_sections') {
    const { data, error } = await supabase.from('product_sections').select('payload').eq('id', source_id).single();
    if (error) throw error;
    blocks = data.payload?.blocks;
  } else if (source_table === 'product_comparisons') {
    const { data, error } = await supabase.from('product_comparisons').select('blocks').eq('id', source_id).single();
    if (error) throw error;
    blocks = data.blocks;
  }

  return { kind: 'block', block: blocks?.[block_index] || null };
}

/** Calcula acerto/erro no servidor (quiz_question/comparison_spec) e atualiza o estado de conhecimento — nunca confia no cliente. */
export async function submitReviewItem(sessionItemId, answer = null) {
  const { data, error } = await supabase.rpc('fn_submit_review_item', { p_session_item_id: sessionItemId, p_answer: answer });
  if (error) throw error;
  return data; // 'acerto' | 'erro' | 'visualizado'
}

/** Fecha a sessão — XP e streak calculados no servidor. */
export async function finalizeReviewSession(sessionId) {
  const { data, error } = await supabase.rpc('fn_finalize_review_session', { p_session_id: sessionId });
  if (error) throw error;
  return data?.[0];
}
