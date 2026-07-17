// src/services/teamAlbumService.js
// Álbum da Equipe (sql/037_team_album.sql) — figurinhas por colaborador.
// Leitura via v_team_album (view pública estreita, mesmo padrão de
// v_ranking_public): qualquer autenticado vê a equipe inteira da própria
// marca. Produto/Precisão/Jogo vêm calculados da view a partir de dado real
// (lição/quiz/game); Ritmo não tem fonte real (RN não define — o protótipo
// original também não tinha, dependia de planilha externa de vendas), então
// é aproximado aqui como o percentil de profiles.performance_score dentro
// do grupo já carregado — documentado como aproximação, não venda real.

import { supabase } from '../config/supabase.js';

export async function fetchTeamAlbum(brandId) {
  const { data, error } = await supabase
    .from('v_team_album')
    .select('user_id, full_name, store_id, store_name, emoji, phrase, avatar_url, specialty, favorite_watch, sport, reputation_score, is_top_seller, performance_score, produto_pct, precisao_pct, jogo_pct, classe')
    .eq('brand_id', brandId)
    .order('full_name', { ascending: true });
  if (error) throw error;
  return withRitmo(data);
}

/** Ritmo = percentil de performance_score dentro do grupo (aproximação — sem fonte real de ranking de vendas, ver comentário no topo do arquivo). */
function withRitmo(rows) {
  const sorted = [...rows].sort((a, b) => a.performance_score - b.performance_score);
  const n = sorted.length;
  return rows.map((r) => {
    const rank = sorted.findIndex((x) => x.user_id === r.user_id);
    const ritmo = n > 1 ? Math.round((rank / (n - 1)) * 100) : 0;
    return { ...r, ritmo_pct: ritmo };
  });
}

/** Campos de identidade pessoal — autoeditáveis (fn_guard_profile_self_update não bloqueia). */
export async function updateMyAlbumProfile(userId, { emoji, phrase, avatarUrl, specialty, favoriteWatch, sport }) {
  const { error } = await supabase
    .from('profiles')
    .update({
      emoji: emoji || null,
      phrase: phrase || null,
      avatar_url: avatarUrl || null,
      specialty: specialty || null,
      favorite_watch: favoriteWatch || null,
      sport: sport || null,
    })
    .eq('id', userId);
  if (error) throw error;
}

/** Reputação/Ponta do Mês — dado curado, só admin (fn_guard_profile_self_update bloqueia autoedição). */
export async function updateCuratedAlbumFields(userId, { reputationScore, isTopSeller }) {
  const { error } = await supabase
    .from('profiles')
    .update({
      reputation_score: reputationScore === '' || reputationScore == null ? null : Number(reputationScore),
      is_top_seller: !!isTopSeller,
    })
    .eq('id', userId);
  if (error) throw error;
}
