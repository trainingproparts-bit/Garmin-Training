// src/services/teamService.js
// Dados agregados da equipe para o Dashboard do Líder. Nenhuma query aqui
// filtra por loja manualmente — a RLS já faz isso (profiles_select_leader,
// quiz_attempts_select_leader, user_certifications_select_leader,
// garmin_training_hub_migrations.sql seção 12), então um líder chamando
// estas funções só recebe de volta gente da(s) própria(s) loja(s). Um
// admin (fn_is_admin()) vê a organização inteira pelas mesmas queries.

import { supabase } from '../config/supabase.js';

/** Colaboradores visíveis para o líder/admin autenticado. */
export async function fetchTeamMembers() {
  const { data, error } = await supabase
    .from('profiles')
    .select('id, full_name, username, job_title, status, performance_score, store_id, stores!profiles_store_id_fkey(name)')
    .order('full_name', { ascending: true });
  if (error) throw error;
  return data || [];
}

/** Certificações emitidas para a equipe, mais recente primeiro. */
export async function fetchTeamCertifications() {
  const { data, error } = await supabase
    .from('user_certifications')
    .select('user_id, certification_id, issued_at, revoked_at, certifications(title)')
    .order('issued_at', { ascending: false });
  if (error) throw error;
  return data || [];
}

/** Tentativas de quiz já finalizadas da equipe, mais recente primeiro. */
export async function fetchTeamQuizAttempts(limit = 20) {
  const { data, error } = await supabase
    .from('quiz_attempts')
    .select('id, user_id, quiz_id, finished_at, score_pct, passed, quizzes(title), profiles(full_name)')
    .not('finished_at', 'is', null)
    .order('finished_at', { ascending: false })
    .limit(limit);
  if (error) throw error;
  return data || [];
}

/**
 * Farol de gaps de conhecimento (Relatório de Gaps da Equipe) — taxa de erro
 * por pergunta nos últimos 30 dias. Escopo por loja já vem embutido em
 * vw_store_knowledge_gaps (sql/015): líder só recebe a própria loja, admin
 * recebe a organização inteira. Nada aqui filtra loja no cliente.
 */
export async function fetchStoreKnowledgeGaps() {
  const { data, error } = await supabase
    .from('vw_store_knowledge_gaps')
    .select('store_id, store_name, quiz_id, quiz_title, question_id, question_text, zone_name, certification_title, certification_level, total_answers, wrong_answers, error_rate_pct, wrong_respondent_names, wrong_respondents')
    .order('error_rate_pct', { ascending: false })
    .order('total_answers', { ascending: false });
  if (error) throw error;
  return data || [];
}

/** Histórico de tentativas de quiz FINALIZADAS de UM colaborador (drawer de diagnóstico) — RLS mesmo escopo de fetchTeamQuizAttempts, só filtrado por usuário. */
export async function fetchUserQuizAttempts(userId, limit = 10) {
  const { data, error } = await supabase
    .from('quiz_attempts')
    .select('id, quiz_id, finished_at, score_pct, passed, quizzes(title)')
    .eq('user_id', userId)
    .not('finished_at', 'is', null)
    .order('finished_at', { ascending: false })
    .limit(limit);
  if (error) throw error;
  return data || [];
}

/**
 * Todas as respostas de quiz de UM colaborador, com a pergunta e o quiz
 * juntados — base pro drawer de diagnóstico calcular tanto o % geral de
 * acerto (sem recorte de data) quanto os gaps ativos (recorte de 30 dias,
 * calculado no cliente a partir do mesmo resultado, sem 2ª query). RLS via
 * quiz_answers_select_leader (join quiz_attempts→profiles, escopo de loja).
 */
export async function fetchUserQuizAnswers(userId) {
  const { data, error } = await supabase
    .from('quiz_answers')
    .select('id, is_correct, answered_at, questions(body, quizzes(title)), quiz_attempts!inner(user_id)')
    .eq('quiz_attempts.user_id', userId)
    .order('answered_at', { ascending: false });
  if (error) throw error;
  return data || [];
}

/**
 * Posição de cada colaborador no funil Explorador→Atleta, com alerta de
 * onboarding (90 dias sem concluir Atleta) e dias de inatividade — escopo
 * por loja já embutido em v_lider_zona_atual (sql/041), mesmo padrão de
 * vw_store_knowledge_gaps (líder só a própria loja, admin a organização
 * inteira). Filtro de loja é client-side aqui (não uma 2ª query) porque a
 * view já devolve o conjunto inteiro que o papel pode ver — o filtro é só
 * pra UI (dropdown "Todas as lojas"/"Morumbi"/"Moema"), não um limite de
 * segurança adicional.
 */
export async function fetchLeaderZonaAtual() {
  const { data, error } = await supabase
    .from('v_lider_zona_atual')
    .select('colaborador_id, nome, store_id, loja, cargo, zona_atual, modulo_atual, data_ultimo_progresso, dias_inatividade, data_referencia_onboarding, onboarding_data_estimada, alerta_onboarding')
    .order('loja', { ascending: true })
    .order('nome', { ascending: true });
  if (error) throw error;
  return data || [];
}
