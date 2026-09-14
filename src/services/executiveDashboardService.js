// src/services/executiveDashboardService.js
// Camada de dados do Dashboard Executivo — admin-only (mesmo guard de
// gestoraPanel.js/liderDashboard.js). Lê as 3 views novas de sql/115
// (v_exec_colaborador_resumo, v_exec_funil_aprendizagem, v_exec_evolucao_mensal)
// + reaproveita views/serviços já existentes e testados em produção
// (vw_store_knowledge_gaps via teamService.js, v_team_album, avaliacoes_google).
// Sem filtro de marca nas queries — mesmo padrão de teamService.js: a RLS
// (fn_is_admin()) já libera a organização inteira pra quem está logado como
// admin, e hoje só a marca Garmin tem colaboradores reais atribuídos.

import { supabase } from '../config/supabase.js';
import { fetchStoreKnowledgeGaps } from './teamService.js';

const COLABORADOR_RESUMO_COLUMNS = `
  colaborador_id, full_name, username, job_title, status, store_id, store_name, brand_id,
  performance_score, streak_atual, streak_recorde, certificacoes_ativas, certificacao_mais_alta,
  checkpoints_obrigatorios_total, checkpoints_obrigatorios_concluidos, progresso_pct,
  data_ultima_atividade, dias_inatividade,
  quiz_tentativas_total, quiz_aprovacoes, quiz_taxa_aprovacao_pct, quiz_taxa_acerto_pct,
  tem_reprovacao_recorrente, avaliacao_trimestral_aprovado, avaliacao_trimestral_data,
  avaliacoes_google_media, avaliacoes_google_qtd
`;

export async function fetchColaboradorResumo() {
  const { data, error } = await supabase
    .from('v_exec_colaborador_resumo')
    .select(COLABORADOR_RESUMO_COLUMNS)
    .order('full_name', { ascending: true });
  if (error) throw error;
  return data || [];
}

export async function fetchFunilAprendizagem() {
  const { data, error } = await supabase
    .from('v_exec_funil_aprendizagem')
    .select('colaborador_id, store_id, store_name, job_title, iniciou_trilha, modulo_em_andamento, modulo_concluido, quiz_iniciado, quiz_concluido, quiz_aprovado');
  if (error) throw error;
  return data || [];
}

export async function fetchEvolucaoMensal() {
  const { data, error } = await supabase
    .from('v_exec_evolucao_mensal')
    .select('colaborador_id, mes, xp_ganho, checkpoints_concluidos, quiz_tentativas, quiz_aprovados, certificacoes_emitidas')
    .order('mes', { ascending: true });
  if (error) throw error;
  return data || [];
}

/** Reaproveita vw_store_knowledge_gaps (sql/015→057) via teamService.js — admin já recebe a organização inteira, sem escopo de loja. */
export { fetchStoreKnowledgeGaps };

/**
 * Funil de certificação por trilha/zona (aba Competências) — a partir de
 * `certifications` (definição) + `user_certifications` (emissão). Conta
 * quantos colaboradores ativos têm cada certificação emitida e não revogada,
 * dividido pelo total de colaboradores ativos — não inventa dado para zonas
 * ainda sem conteúdo (criteria->>'required_modules' vazio não é filtrado
 * aqui, a ausência de conteúdo já se reflete em 0 emissões).
 */
export async function fetchFunilCertificacao() {
  const [{ data: certs, error: certsError }, { data: emitidas, error: emitidasError }, { data: ativos, error: ativosError }] = await Promise.all([
    supabase.from('certifications').select('id, slug, title, trail_id, zone_id'),
    supabase.from('user_certifications').select('user_id, certification_id, revoked_at').is('revoked_at', null),
    supabase.from('profiles').select('id').in('role_id', [1, 2]).eq('status', 'active').is('deleted_at', null),
  ]);
  if (certsError) throw certsError;
  if (emitidasError) throw emitidasError;
  if (ativosError) throw ativosError;

  const totalAtivos = ativos?.length || 0;
  const contagemPorCert = new Map();
  (emitidas || []).forEach((row) => {
    contagemPorCert.set(row.certification_id, (contagemPorCert.get(row.certification_id) || 0) + 1);
  });

  const ORDEM_NIVEL = { explorador: 1, corredor: 2, maratonista: 3, triatleta: 4, aventureiro: 5 };

  return (certs || [])
    .map((c) => ({
      id: c.id,
      slug: c.slug,
      title: c.title,
      temConteudo: !!c.zone_id,
      emitidas: contagemPorCert.get(c.id) || 0,
      totalAtivos,
      pct: totalAtivos ? Math.round((100 * (contagemPorCert.get(c.id) || 0)) / totalAtivos) : 0,
    }))
    .sort((a, b) => (ORDEM_NIVEL[a.slug] || 99) - (ORDEM_NIVEL[b.slug] || 99));
}

const AMOSTRA_MINIMA_CONTEUDO = 3; // menos que isso, taxa de aprovação/conclusão é ruído, não sinal

/**
 * Desempenho por quiz (aba Conteúdo) — taxa de aprovação agregada em JS a
 * partir de quiz_attempts finalizadas, sem view nova (mesmo princípio
 * pragmático já usado no projeto: não criar infra nova quando o volume de
 * dado é pequeno o bastante pra agregar no cliente, ver sql/015 README).
 * Quizzes com poucas tentativas ficam de fora — amostra insuficiente.
 */
export async function fetchQuizPerformance() {
  const { data, error } = await supabase
    .from('quiz_attempts')
    .select('quiz_id, passed, quizzes(title)')
    .not('finished_at', 'is', null);
  if (error) throw error;

  const porQuiz = new Map();
  (data || []).forEach((row) => {
    if (!row.quiz_id) return;
    const atual = porQuiz.get(row.quiz_id) || { quizId: row.quiz_id, title: row.quizzes?.title || 'Quiz', tentativas: 0, aprovadas: 0 };
    atual.tentativas += 1;
    if (row.passed) atual.aprovadas += 1;
    porQuiz.set(row.quiz_id, atual);
  });

  return [...porQuiz.values()]
    .filter((q) => q.tentativas >= AMOSTRA_MINIMA_CONTEUDO)
    .map((q) => ({ ...q, taxaAprovacaoPct: Math.round((100 * q.aprovadas) / q.tentativas) }))
    .sort((a, b) => a.taxaAprovacaoPct - b.taxaAprovacaoPct);
}

/**
 * Módulos com maior abandono (aba Conteúdo) — a partir de user_progress
 * cruzado com checkpoints tipo 'module' + modules/zones. checkpoints.reference_id
 * é uma FK "polimórfica" sem constraint real (ver modelagem, seção 2.6), então
 * o PostgREST não consegue fazer embed automático — o cruzamento é feito em
 * JS a partir de 3 queries simples, mesmo padrão já usado pro resto do
 * dashboard. "Abandono" = iniciou (status in_progress/unlocked/completed) mas
 * não chegou a 'completed'. Módulos com poucos colaboradores que sequer
 * começaram ficam de fora — amostra insuficiente pra afirmar dificuldade.
 */
export async function fetchModuleAbandonment() {
  const [{ data: modules, error: modulesError }, { data: checkpoints, error: checkpointsError }, { data: progress, error: progressError }] = await Promise.all([
    supabase.from('modules').select('id, title, zone_id, zones(name)'),
    supabase.from('checkpoints').select('id, reference_id, checkpoint_type').eq('checkpoint_type', 'module'),
    supabase.from('user_progress').select('checkpoint_id, status'),
  ]);
  if (modulesError) throw modulesError;
  if (checkpointsError) throw checkpointsError;
  if (progressError) throw progressError;

  const moduleByCheckpointId = new Map();
  (checkpoints || []).forEach((cp) => {
    const mod = (modules || []).find((m) => m.id === cp.reference_id);
    if (mod) moduleByCheckpointId.set(cp.id, mod);
  });

  const statsByModule = new Map();
  (progress || []).forEach((row) => {
    if (row.status === 'locked') return; // nunca chegou a ver o módulo — não conta como "começou"
    const mod = moduleByCheckpointId.get(row.checkpoint_id);
    if (!mod) return;
    const atual = statsByModule.get(mod.id) || { moduleId: mod.id, title: mod.title, zoneName: mod.zones?.name || '—', iniciados: 0, concluidos: 0 };
    atual.iniciados += 1;
    if (row.status === 'completed') atual.concluidos += 1;
    statsByModule.set(mod.id, atual);
  });

  return [...statsByModule.values()]
    .filter((m) => m.iniciados >= AMOSTRA_MINIMA_CONTEUDO)
    .map((m) => ({ ...m, taxaConclusaoPct: Math.round((100 * m.concluidos) / m.iniciados) }))
    .sort((a, b) => a.taxaConclusaoPct - b.taxaConclusaoPct);
}
