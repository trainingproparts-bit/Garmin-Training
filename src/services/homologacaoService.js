// src/services/homologacaoService.js
// Homologação Semanal de Treinamento (sql/048) — ciclo semanal por loja com
// conteúdo avulso (módulo/quiz/blog/game) marcado pelo admin, que o líder da
// loja confirma. Listagem de módulos/quizzes/posts/games pro seletor do
// admin reaproveita os fetchers já existentes (contentAdminService.js,
// blogService.js, gameService.js) — nenhum fetch novo pra isso.

import { supabase } from '../config/supabase.js';

/** Ciclos de uma loja, mais recente primeiro. */
export async function fetchCiclosPorLoja(storeId) {
  const { data, error } = await supabase
    .from('ciclos_semanais')
    .select('id, store_id, data_inicio, data_fim, status, created_at')
    .eq('store_id', storeId)
    .order('data_inicio', { ascending: false });
  if (error) throw error;
  return data;
}

/** Ciclo ativo mais recente de uma loja (o que o líder assina) — null se não houver nenhum. */
export async function fetchCicloAtivo(storeId) {
  const { data, error } = await supabase
    .from('ciclos_semanais')
    .select('id, store_id, data_inicio, data_fim, status, created_at')
    .eq('store_id', storeId)
    .eq('status', 'ativo')
    .order('data_inicio', { ascending: false })
    .limit(1)
    .maybeSingle();
  if (error) throw error;
  return data;
}

/** Cria o ciclo + já grava os itens selecionados (módulo/quiz/blog/game) numa só chamada. */
export async function criarCicloComConteudos({ storeId, dataInicio, dataFim, itens }) {
  const { data: ciclo, error: cicloErr } = await supabase
    .from('ciclos_semanais')
    .insert({ store_id: storeId, data_inicio: dataInicio, data_fim: dataFim, status: 'ativo' })
    .select()
    .single();
  if (cicloErr) throw cicloErr;

  if (itens.length) {
    const rows = itens.map((it) => ({ ciclo_id: ciclo.id, tipo_conteudo: it.tipo, conteudo_id: it.id }));
    const { error: itensErr } = await supabase.from('ciclo_conteudos').insert(rows);
    if (itensErr) throw itensErr;
  }

  return ciclo;
}

export async function encerrarCiclo(cicloId) {
  const { error } = await supabase.from('ciclos_semanais').update({ status: 'encerrado' }).eq('id', cicloId);
  if (error) throw error;
}

/** Itens do ciclo com título já resolvido (pra listagem no painel do admin). */
export async function fetchConteudosDoCiclo(cicloId) {
  const { data, error } = await supabase
    .from('ciclo_conteudos')
    .select('id, tipo_conteudo, conteudo_id')
    .eq('ciclo_id', cicloId);
  if (error) throw error;
  return data;
}

/** Progresso por item (RPC fn_ciclo_itens_progresso, sql/048) — resolve a tabela certa por tipo. */
export async function fetchProgressoDoCiclo(cicloId) {
  const { data, error } = await supabase.rpc('fn_ciclo_itens_progresso', { p_ciclo_id: cicloId });
  if (error) throw error;
  return data;
}

/** Assinatura do líder (RPC fn_assinar_ciclo, sql/048) — valida janela sexta 00:00–segunda 23:59 no servidor. */
export async function assinarCiclo(cicloId, { ipAssinatura, termoTexto } = {}) {
  const { data, error } = await supabase.rpc('fn_assinar_ciclo', {
    p_ciclo_id: cicloId,
    p_ip_assinatura: ipAssinatura || null,
    p_termo_texto: termoTexto || null,
  });
  if (error) throw error;
  return data;
}

/** Assinatura já registrada pro líder atual neste ciclo (null se ainda não assinou). */
export async function fetchMinhaAssinatura(cicloId, liderId) {
  const { data, error } = await supabase
    .from('assinaturas_lideres')
    .select('id, ciclo_id, lider_id, store_id, percentual_conclusao_time, assinado_em, status_assinatura')
    .eq('ciclo_id', cicloId)
    .eq('lider_id', liderId)
    .maybeSingle();
  if (error) throw error;
  return data;
}
