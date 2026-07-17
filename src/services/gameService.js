// src/services/gameService.js
// Camada de acesso a dados dos minigames ("Duelo de Especificações").
// Iniciar sessão continua direto pelo cliente (RLS own-row, mesmo padrão de
// quiz_attempts). Submeter rodada e fechar sessão passam por RPC
// SECURITY DEFINER (sql/021_game_submission_hardening.sql) — achado ao
// testar ao vivo que o caminho antigo (UPDATE game_sessions + upsert direto
// em game_scores) estava genuinamente quebrado: faltava policy de UPDATE em
// game_sessions (o PATCH "sucedia" mas não alterava nada) e de INSERT em
// game_scores (403 direto). O placar agora é sempre calculado no servidor a
// partir de game_round_answers, nunca do valor que o cliente mandar.

import { supabase } from '../config/supabase.js';

/** Lista games publicados de uma marca. */
export async function fetchPublishedGames(brandId) {
  const { data, error } = await supabase
    .from('games')
    .select('id, slug, title, config, cover_url')
    .eq('brand_id', brandId)
    .eq('is_published', true)
    .order('title', { ascending: true });
  if (error) throw error;
  return data;
}

export async function fetchGameById(gameId) {
  const { data, error } = await supabase
    .from('games')
    .select('id, slug, title, config, cover_url')
    .eq('id', gameId)
    .single();
  if (error) throw error;
  return data;
}

/** Capa do card 16:9 na Arena de Desafios (sql/051) — só admin consegue salvar (games_admin_all). */
export async function updateGameCover(gameId, coverUrl) {
  const { error } = await supabase.from('games').update({ cover_url: coverUrl || null }).eq('id', gameId);
  if (error) throw error;
}

/** Melhor pontuação pessoal do usuário neste game (exibida no card, RN dashboard). */
export async function fetchBestScore(userId, gameId) {
  const { data, error } = await supabase
    .from('game_sessions')
    .select('id, game_scores(score, accuracy_pct)')
    .eq('user_id', userId)
    .eq('game_id', gameId)
    .not('finished_at', 'is', null);
  if (error) throw error;

  const scores = (data || []).flatMap((s) => s.game_scores || []).map((s) => s.score);
  return scores.length ? Math.max(...scores) : null;
}

export async function startGameSession(userId, gameId) {
  const { data, error } = await supabase
    .from('game_sessions')
    .insert({ user_id: userId, game_id: gameId })
    .select('id, started_at')
    .single();
  if (error) throw error;
  return data;
}

/** Registra a escolha de uma rodada — is_correct é calculado no servidor a partir de games.config, o cliente nunca envia esse valor. */
export async function submitGameRound(sessionId, roundIndex, chosenKey) {
  const { data, error } = await supabase.rpc('fn_submit_game_round', {
    p_session_id: sessionId,
    p_round_index: roundIndex,
    p_chosen_key: chosenKey,
  });
  if (error) throw error;
  return data; // boolean is_correct
}

/** Fecha a sessão e devolve o placar calculado no servidor (nunca o que o cliente contou). */
export async function finalizeGameSession(sessionId) {
  const { data, error } = await supabase.rpc('fn_finalize_game_session', { p_session_id: sessionId });
  if (error) throw error;
  return data?.[0];
}
