// src/services/leaderboardService.js
// Camada de acesso a dados do Leaderboard Trimestral (RN §6.6).
// Controla temporadas (ex: "Q3-2026"), snapshots de ranking e histórico.

import { supabase } from '../config/supabase.js';

/**
 * Formata identificador de temporada no padrão Q{quarter}-YYYY
 * @param {number} year - Ano (ex: 2026)
 * @param {number} quarter - Trimestre (1-4)
 * @returns {string} - Ex: "Q3-2026"
 */
export function formatSeasonId(year, quarter) {
  return `Q${quarter}-${year}`;
}

/**
 * Extrai ano e trimestre a partir de uma data
 * @param {Date} date
 * @returns {object} - { year, quarter }
 */
export function getQuarterFromDate(date = new Date()) {
  const year = date.getFullYear();
  const month = date.getMonth() + 1; // 1-12
  const quarter = Math.ceil(month / 3);
  return { year, quarter };
}

/**
 * Retorna a temporada atual
 * @returns {string} - Ex: "Q3-2026"
 */
export function getCurrentSeason() {
  const { year, quarter } = getQuarterFromDate();
  return formatSeasonId(year, quarter);
}

/**
 * Retorna a temporada anterior (último trimestre fechado)
 * @returns {string} - Ex: "Q2-2026"
 */
export function getPreviousSeason() {
  const { year, quarter } = getQuarterFromDate();
  let prevYear = year;
  let prevQuarter = quarter - 1;
  
  if (prevQuarter === 0) {
    prevQuarter = 4;
    prevYear = year - 1;
  }
  
  return formatSeasonId(prevYear, prevQuarter);
}

/**
 * Busca o ranking global da temporada atual
 * @param {string} seasonId - Ex: "Q3-2026"
 * @param {number} limit - Limite de resultados (padrão: 50)
 */
export async function fetchGlobalLeaderboard(seasonId = getCurrentSeason(), limit = 50) {
  const { data, error } = await supabase
    .from('leaderboard')
    .select('*, profiles(full_name, store_id, roles(code))')
    .eq('season_id', seasonId)
    .eq('scope_type', 'global')
    .order('rank_position', { ascending: true })
    .limit(limit);
  
  if (error) throw error;
  return data;
}

/**
 * Busca o ranking por loja da temporada atual
 * @param {string} seasonId - Ex: "Q3-2026"
 * @param {string} storeId - ID da loja
 * @param {number} limit - Limite de resultados (padrão: 20)
 */
export async function fetchStoreLeaderboard(seasonId = getCurrentSeason(), storeId, limit = 20) {
  const { data, error } = await supabase
    .from('leaderboard')
    .select('*, profiles(full_name, roles(code))')
    .eq('season_id', seasonId)
    .eq('scope_type', 'store')
    .eq('scope_id', storeId)
    .order('rank_position', { ascending: true })
    .limit(limit);
  
  if (error) throw error;
  return data;
}

/**
 * Busca o ranking por cargo da temporada atual
 * @param {string} seasonId - Ex: "Q3-2026"
 * @param {string} jobTitle - Cargo (ex: "Vendedor")
 * @param {number} limit - Limite de resultados (padrão: 20)
 */
export async function fetchRoleLeaderboard(seasonId = getCurrentSeason(), jobTitle, limit = 20) {
  const { data, error } = await supabase
    .from('leaderboard')
    .select('*, profiles(full_name, store_id)')
    .eq('season_id', seasonId)
    .eq('scope_type', 'role')
    .eq('scope_id', jobTitle)
    .order('rank_position', { ascending: true })
    .limit(limit);
  
  if (error) throw error;
  return data;
}

/**
 * Busca o histórico de temporadas anteriores (pódios)
 * @param {number} limit - Limite de temporadas (padrão: 4)
 */
export async function fetchSeasonHistory(limit = 4) {
  const { data, error } = await supabase
    .from('leaderboard')
    .select('season_id, scope_type, scope_id, rank_position, total_points, profiles(full_name, store_id)')
    .in('rank_position', [1, 2, 3]) // Top 3 (pódio)
    .order('season_id', { ascending: false })
    .limit(limit * 3); // 3 posições por temporada
  
  if (error) throw error;
  
  // Agrupa por temporada
  const seasons = {};
  data.forEach((entry) => {
    if (!seasons[entry.season_id]) {
      seasons[entry.season_id] = {
        seasonId: entry.season_id,
        podium: [],
      };
    }
    seasons[entry.season_id].podium.push({
      rank: entry.rank_position,
      user: entry.profiles,
      points: entry.total_points,
      scopeType: entry.scope_type,
      scopeId: entry.scope_id,
    });
  });
  
  return Object.values(seasons).slice(0, limit);
}

/**
 * Busca a posição do usuário atual no ranking
 * @param {string} userId - ID do usuário
 * @param {string} seasonId - Ex: "Q3-2026"
 * @param {string} scopeType - 'global', 'store', ou 'role'
 * @param {string} scopeId - ID da loja ou cargo (se aplicável)
 */
export async function fetchUserRank(userId, seasonId = getCurrentSeason(), scopeType = 'global', scopeId = null) {
  let query = supabase
    .from('leaderboard')
    .select('*')
    .eq('season_id', seasonId)
    .eq('scope_type', scopeType)
    .eq('user_id', userId);
  
  if (scopeId) {
    query = query.eq('scope_id', scopeId);
  }
  
  const { data, error } = await query.maybeSingle();
  
  if (error) throw error;
  return data;
}

/**
 * Força atualização das materialized views de leaderboard
 * (chama RPC fn_refresh_leaderboards no servidor)
 * Esta função requer permissão de admin/leader.
 */
export async function refreshLeaderboards() {
  const { data, error } = await supabase.rpc('fn_refresh_leaderboards');
  
  if (error) throw error;
  return data;
}

/**
 * Cria um snapshot do ranking ao fim do trimestre (fechamento de temporada)
 * Esta função deve ser chamada por um admin ao encerrar uma temporada.
 * @param {string} seasonId - ID da temporada a ser fechada (ex: "Q2-2026")
 */
export async function closeSeason(seasonId) {
  // 1. Força atualização das materialized views
  await refreshLeaderboards();
  
  // 2. Cria snapshot do ranking global
  const { data: globalRanking, error: globalError } = await supabase
    .from('mv_leaderboard_global')
    .select('*')
    .order('total_points', { ascending: false });
  
  if (globalError) throw globalError;
  
  // 3. Insere snapshot na tabela leaderboard
  const snapshotEntries = globalRanking.map((entry, index) => ({
    season_id: seasonId,
    user_id: entry.user_id,
    scope_type: 'global',
    scope_id: null,
    rank_position: index + 1,
    total_points: entry.total_points,
    completed_modules: entry.completed_modules || 0,
    completed_quizzes: entry.completed_quizzes || 0,
    streak_days: entry.streak_days || 0,
  }));
  
  const { error: insertError } = await supabase
    .from('leaderboard')
    .insert(snapshotEntries);
  
  if (insertError) throw insertError;
  
  // 4. Cria snapshots por loja (opcional, pode ser feito em batch)
  const { data: stores, error: storesError } = await supabase
    .from('stores')
    .select('id');
  
  if (!storesError && stores) {
    for (const store of stores) {
      const { data: storeRanking } = await supabase
        .from('mv_leaderboard_by_store')
        .select('*')
        .eq('store_id', store.id)
        .order('total_points', { ascending: false });
      
      if (storeRanking && storeRanking.length > 0) {
        const storeEntries = storeRanking.map((entry, index) => ({
          season_id: seasonId,
          user_id: entry.user_id,
          scope_type: 'store',
          scope_id: store.id,
          rank_position: index + 1,
          total_points: entry.total_points,
          completed_modules: entry.completed_modules || 0,
          completed_quizzes: entry.completed_quizzes || 0,
          streak_days: entry.streak_days || 0,
        }));
        
        await supabase.from('leaderboard').insert(storeEntries);
      }
    }
  }
  
  return { success: true, seasonId, entriesCount: snapshotEntries.length };
}

/**
 * Reseta os pontos ativos para a nova temporada
 * NOTA: Esta operação é destrutiva e deve ser feita com cuidado.
 * O histórico em points_ledger é mantido intacto.
 * @param {string} newSeasonId - ID da nova temporada (ex: "Q3-2026")
 */
export async function resetForNewSeason(newSeasonId) {
  // Esta função deve ser implementada com cuidado, pois afeta dados de produção.
  // Por enquanto, retorna um placeholder indicando que precisa de implementação segura.
  throw new Error(
    'resetForNewSeason requer implementação segura com backup. ' +
    'Esta operação deve ser feita via RPC server-side com validação adicional.'
  );
}
