// src/services/quizService.js
// Camada de acesso a dados de quizzes. A correção de resposta NUNCA acontece
// no cliente: fn_submit_quiz_answer e fn_finalize_quiz_attempt (Postgres,
// SECURITY DEFINER) fazem esse cálculo no servidor — ver sql/003_quiz_submission_hardening.sql.

import { supabase } from '../config/supabase.js';

/**
 * Metadados de um conjunto de quizzes por id (nota de corte, tentativas).
 * Usado pela página "Quizzes Extras", que já sabe QUAIS quizzes mostrar
 * (checkpoints de zonas free_order, resolvidos via trilhaService) e só
 * precisa desses detalhes complementares para o card — ver src/pages/quizzes.js.
 */
export async function fetchQuizzesByIds(ids) {
  if (!ids.length) return [];
  const { data, error } = await supabase
    .from('quizzes')
    .select('id, title, passing_score_pct, time_limit_seconds, max_attempts, cover_url')
    .in('id', ids);
  if (error) throw error;
  return data;
}

/** Capa do card 16:9 (redesign 2026-07-10, sql/027) — só admin consegue salvar (quizzes_admin_all). */
export async function updateQuizCover(quizId, coverUrl) {
  const { error } = await supabase.from('quizzes').update({ cover_url: coverUrl || null }).eq('id', quizId);
  if (error) throw error;
}

/**
 * Busca um quiz com perguntas e alternativas SEM o gabarito
 * (usa v_alternatives_public — is_correct nunca trafega para o cliente
 * antes da resposta ser enviada, ver modelagem seção 11 / migrations 13.1).
 */
export async function fetchQuizForAttempt(quizId) {
  const { data: quiz, error: quizErr } = await supabase
    .from('quizzes')
    .select('id, slug, title, passing_score_pct, time_limit_seconds, max_attempts')
    .eq('id', quizId)
    .single();
  if (quizErr) throw quizErr;

  const { data: questions, error: questionsErr } = await supabase
    .from('questions')
    .select('id, body, order_index')
    .eq('quiz_id', quizId)
    .eq('is_active', true)
    .order('order_index', { ascending: true });
  if (questionsErr) throw questionsErr;

  const questionIds = questions.map((q) => q.id);
  const { data: alternatives, error: altsErr } = questionIds.length
    ? await supabase
        .from('v_alternatives_public')
        .select('id, question_id, body, order_index')
        .in('question_id', questionIds)
        .order('order_index', { ascending: true })
    : { data: [], error: null };
  if (altsErr) throw altsErr;

  const questionsComAlternativas = questions.map((q) => ({
    ...q,
    alternatives: alternatives.filter((a) => a.question_id === q.id),
  }));

  return { quiz, questions: questionsComAlternativas };
}

/** Quantidade de tentativas já finalizadas pelo usuário neste quiz (para respeitar max_attempts). */
export async function countFinishedAttempts(userId, quizId) {
  const { count, error } = await supabase
    .from('quiz_attempts')
    .select('id', { count: 'exact', head: true })
    .eq('user_id', userId)
    .eq('quiz_id', quizId)
    .not('finished_at', 'is', null);
  if (error) throw error;
  return count || 0;
}

/**
 * Melhor score_pct (entre tentativas finalizadas) por quiz, pra barra de
 * progresso da Arena de Desafios — 1 query só pra todos os quizzes da lista
 * em vez de N+1 (mesmo padrão de fetchQuizzesByIds/fetchBestScore no gameService).
 */
export async function fetchBestScoresByQuizIds(userId, quizIds) {
  if (!quizIds.length) return new Map();
  const { data, error } = await supabase
    .from('quiz_attempts')
    .select('quiz_id, score_pct')
    .eq('user_id', userId)
    .in('quiz_id', quizIds)
    .not('finished_at', 'is', null);
  if (error) throw error;

  const map = new Map();
  (data || []).forEach((row) => {
    const prev = map.get(row.quiz_id);
    if (prev === undefined || row.score_pct > prev) map.set(row.quiz_id, row.score_pct);
  });
  return map;
}

/** Abre uma nova tentativa. */
export async function startQuizAttempt(userId, quizId) {
  const { data, error } = await supabase
    .from('quiz_attempts')
    .insert({ user_id: userId, quiz_id: quizId })
    .select('id, started_at')
    .single();
  if (error) throw error;
  return data;
}

/**
 * Envia uma resposta. Retorna se estava correta + a explicação da pergunta —
 * ambos calculados/buscados no servidor via fn_submit_quiz_answer (sql/039),
 * nunca no cliente (o cliente não recebe alternatives.is_correct nem
 * questions.explanation antes de responder — mesmo princípio de segurança,
 * só que servido junto no mesmo RPC em vez de round-trip separado).
 */
export async function submitAnswer(attemptId, questionId, alternativeId) {
  const { data, error } = await supabase.rpc('fn_submit_quiz_answer', {
    p_attempt_id: attemptId,
    p_question_id: questionId,
    p_alternative_id: alternativeId,
  });
  if (error) throw error;
  return { isCorrect: data.is_correct, explanation: data.explanation }; // data.explanation pode ser null (pergunta sem explicação cadastrada)
}

/** Fecha a tentativa — score_pct/passed/attempt_number calculados no servidor. */
export async function finalizeQuizAttempt(attemptId) {
  const { data, error } = await supabase.rpc('fn_finalize_quiz_attempt', {
    p_attempt_id: attemptId,
  });
  if (error) throw error;
  return data; // linha de quiz_attempts já atualizada
}

/** Histórico de tentativas do usuário neste quiz, mais recente primeiro. */
export async function fetchAttemptHistory(userId, quizId) {
  const { data, error } = await supabase
    .from('quiz_attempts')
    .select('id, started_at, finished_at, score_pct, passed, attempt_number')
    .eq('user_id', userId)
    .eq('quiz_id', quizId)
    .order('started_at', { ascending: false });
  if (error) throw error;
  return data;
}
