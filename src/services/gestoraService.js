// src/services/gestoraService.js
// Painel da Gestora — relatório de respostas de quiz de todos os
// colaboradores, separado por loja. Sem view/tabela nova: quiz_attempts já
// tem RLS de leitura total pra admin (quiz_attempts_admin_all, ALL, sem
// escopo de loja — diferente de quiz_attempts_select_leader, que só libera
// a própria loja), então este é o mesmo caminho de fetchTeamQuizAttempts
// (teamService.js), só sem o .limit(20) e com o embed de loja explícito
// pra poder agrupar no cliente.

import { supabase } from '../config/supabase.js';

/**
 * Todas as tentativas de quiz já finalizadas, org inteira (só admin recebe
 * de volta linhas de todas as lojas — RLS quiz_attempts_admin_all). FK de
 * stores explícita (stores!profiles_store_id_fkey) pelo mesmo motivo já
 * documentado em adminService/teamService: profiles tem dois caminhos de
 * relacionamento com stores (FK direta + N:N via store_leaders), o
 * PostgREST não escolhe sozinho sem essa desambiguação (bug real achado e
 * corrigido em 2026-07-09, ver PROJECT_CHECKLIST.md).
 */
export async function fetchAllQuizAttemptsReport() {
  const { data, error } = await supabase
    .from('quiz_attempts')
    .select(`
      id, quiz_id, attempt_number, score_pct, passed, finished_at,
      quizzes(title),
      profiles(id, full_name, store_id, stores!profiles_store_id_fkey(name))
    `)
    .not('finished_at', 'is', null)
    .order('finished_at', { ascending: false });
  if (error) throw error;
  return data;
}
