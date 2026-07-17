// src/services/evaluationService.js
// Camada de acesso ao Motor de Avaliações Trimestrais (evaluations/
// evaluation_questions). Correção (correct_option) nunca trafega para o
// cliente antes de responder — a leitura de perguntas usa
// v_evaluation_questions_public, a mesma técnica de v_alternatives_public.
// Submissão e correção (fn_submit_evaluation_answer/fn_finish_evaluation_attempt,
// sql/006_evaluation_submission_engine.sql) seguem o mesmo princípio do
// quizService.js: o servidor calcula, o cliente nunca envia nota pronta.

import { supabase } from '../config/supabase.js';

/** Busca a avaliação publicada de um tier (explorer/runner/triathlete) com suas perguntas, sem gabarito. */
export async function fetchEvaluationQuestions(evaluationType) {
  const { data: evaluation, error: evalErr } = await supabase
    .from('evaluations')
    .select('id, title, type, passing_score_pct')
    .eq('type', evaluationType)
    .eq('is_published', true)
    .single();
  if (evalErr) throw evalErr;

  const { data: questions, error: questionsErr } = await supabase
    .from('v_evaluation_questions_public')
    .select('id, question_text, options_json, order_index')
    .eq('evaluation_id', evaluation.id)
    .order('order_index', { ascending: true });
  if (questionsErr) throw questionsErr;

  return { evaluation, questions };
}

/**
 * Verifica se o usuário está bloqueado para iniciar uma nova tentativa desta
 * avaliação (regra: 24h após reprovar, sem limite de tentativas, liberável
 * manualmente por um líder — ver fn_check_evaluation_lock).
 * Retorna { locked, locked_until, reason }.
 */
export async function checkEvaluationLock(evaluationId) {
  const { data, error } = await supabase.rpc('fn_check_evaluation_lock', {
    p_evaluation_id: evaluationId,
  });
  if (error) throw error;
  return data;
}

/** Ação de líder/admin: libera uma tentativa reprovada antes do prazo de 24h vencer. */
export async function unlockEvaluationAttempt(attemptId) {
  const { error } = await supabase.rpc('fn_unlock_evaluation_attempt', {
    p_attempt_id: attemptId,
  });
  if (error) throw error;
}

/**
 * Abre (ou retoma, se já houver uma em andamento) uma tentativa — aplica a
 * trava de 24h no servidor antes de criar a linha. Lança erro se bloqueado.
 */
export async function startEvaluationAttempt(evaluationId) {
  const { data, error } = await supabase.rpc('fn_start_evaluation_attempt', {
    p_evaluation_id: evaluationId,
  });
  if (error) throw error;
  return data;
}

/**
 * Envia uma resposta. Retorna se estava correta — calculado no servidor,
 * o cliente nunca recebe evaluation_questions.correct_option.
 */
export async function submitEvaluationAnswer(attemptId, questionId, selectedOption) {
  const { data, error } = await supabase.rpc('fn_submit_evaluation_answer', {
    p_attempt_id: attemptId,
    p_question_id: questionId,
    p_selected_option: selectedOption,
  });
  if (error) throw error;
  return data; // boolean
}

/** Fecha a tentativa — score_pct/passed calculados no servidor a partir das respostas. */
export async function finishEvaluationAttempt(attemptId) {
  const { data, error } = await supabase.rpc('fn_finish_evaluation_attempt', {
    p_attempt_id: attemptId,
  });
  if (error) throw error;
  return data;
}
