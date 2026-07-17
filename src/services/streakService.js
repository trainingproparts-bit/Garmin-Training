// src/services/streakService.js
// Streak de dias consecutivos de estudo (RN §6.5) — sql/033_streak_engine.sql.
// Recalculado reativamente no banco (lição/quiz/game/avaliação concluídos),
// sem job diário. Lê sempre de v_streaks_effective, não da tabela `streaks`
// direto — a view recalcula na hora se o streak gravado ainda está vivo hoje,
// evitando mostrar um streak "fantasma" pra quem parou de estudar há dias.

import { supabase } from '../config/supabase.js';

/** Streak do usuário logado, ou null se ele nunca teve nenhuma atividade registrada. */
export async function fetchMyStreak(userId) {
  const { data, error } = await supabase
    .from('v_streaks_effective')
    .select('current_streak_days_effective, longest_streak_days, last_activity_date')
    .eq('user_id', userId)
    .maybeSingle();
  if (error) throw error;
  return data;
}
