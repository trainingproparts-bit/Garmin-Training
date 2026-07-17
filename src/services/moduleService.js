// src/services/moduleService.js
// Camada de acesso a dados de módulos/aulas (substitui cursoService.js, que
// consultava uma tabela "courses" inexistente no schema definitivo).

import { supabase } from '../config/supabase.js';

/** Busca um módulo publicado com suas aulas ordenadas. */
export async function fetchModuleWithLessons(moduleId) {
  const { data: module, error: moduleErr } = await supabase
    .from('modules')
    .select('id, zone_id, slug, title, summary, estimated_minutes, zones(name)')
    .eq('id', moduleId)
    .single();
  if (moduleErr) throw moduleErr;

  const { data: lessons, error: lessonsErr } = await supabase
    .from('lessons')
    .select('id, title, content_type, body, order_index')
    .eq('module_id', moduleId)
    .eq('is_published', true)
    .order('order_index', { ascending: true });
  if (lessonsErr) throw lessonsErr;

  return { module, lessons: lessons || [] };
}

/** Progresso do usuário logado numa aula específica (para "continuar de onde parou"). */
export async function fetchLessonProgress(userId, lessonIds) {
  if (!lessonIds.length) return [];
  const { data, error } = await supabase
    .from('lesson_progress')
    .select('lesson_id, progress_pct, completed_at')
    .eq('user_id', userId)
    .in('lesson_id', lessonIds);
  if (error) throw error;
  return data;
}

/**
 * @deprecated desde Sprint 3 (2026-07-08). Use completeLesson(), que também
 * concede Score de Performance atomicamente via fn_complete_lesson. Mantido
 * como fallback para chamadas antigas.
 */
export async function markLessonComplete(userId, lessonId) {
  const { error } = await supabase
    .from('lesson_progress')
    .upsert(
      {
        user_id: userId,
        lesson_id: lessonId,
        progress_pct: 100,
        completed_at: new Date().toISOString(),
      },
      { onConflict: 'user_id,lesson_id' }
    );
  if (error) throw error;
}

/**
 * Fecha o ciclo de conclusão da lição em uma única chamada atômica:
 * grava lesson_progress, lança pontos no points_ledger (só na primeira vez,
 * RN 6.1 — sem pontuação repetida) e devolve o novo total de Score de
 * Performance do usuário. Não recebe userId — a função server-side lê de
 * auth.uid(), não confia em valor vindo do cliente.
 *
 * Retorna { performance_score, points_awarded, already_completed }.
 */
export async function completeLesson(lessonId, amount = 25) {
  const { data, error } = await supabase.rpc('fn_complete_lesson', {
    p_lesson_id: lessonId,
    p_amount: amount,
  });
  if (error) throw error;
  return data;
}

/**
 * Percentual concluído das lições publicadas do módulo — usado pela barra
 * de progresso no topo da tela do módulo. Fica em service (não em página)
 * para poder ser reaproveitado pelo dashboard/trilha no futuro.
 */
export async function fetchModuleProgress(userId, moduleId) {
  const { data: lessons, error: lessonsErr } = await supabase
    .from('lessons')
    .select('id')
    .eq('module_id', moduleId)
    .eq('is_published', true);
  if (lessonsErr) throw lessonsErr;

  const total = lessons?.length || 0;
  if (!total) return { total: 0, completed: 0, pct: 0, completedIds: new Set() };

  const lessonIds = lessons.map((l) => l.id);
  const progress = await fetchLessonProgress(userId, lessonIds);
  const completedIds = new Set(progress.filter((p) => p.completed_at).map((p) => p.lesson_id));

  return {
    total,
    completed: completedIds.size,
    pct: Math.round((completedIds.size / total) * 100),
    completedIds,
  };
}

/**
 * Checkpoint de quiz que vem logo depois deste módulo na mesma zona da
 * trilha (se existir) — usado pelo CTA "Responder quiz" que aparece quando
 * o módulo é 100% concluído, levando direto pro quiz sem o usuário precisar
 * voltar pra "Minha Trilha" e procurar manualmente o card recém-desbloqueado.
 */
export async function fetchNextQuizCheckpoint(zoneId, moduleId) {
  const { data: checkpoints, error } = await supabase
    .from('checkpoints')
    .select('id, checkpoint_type, reference_id, order_index')
    .eq('zone_id', zoneId)
    .order('order_index', { ascending: true });
  if (error) throw error;

  const moduleCp = checkpoints.find((c) => c.checkpoint_type === 'module' && c.reference_id === moduleId);
  if (!moduleCp) return null;

  const nextCp = checkpoints.find((c) => c.order_index > moduleCp.order_index);
  return nextCp?.checkpoint_type === 'quiz' ? nextCp : null;
}

/** Atualiza o conteúdo de uma lição (usado para edição administrativa). */
export async function updateLesson(lessonId, updates) {
  const { data, error } = await supabase
    .from('lessons')
    .update(updates)
    .eq('id', lessonId)
    .select()
    .single();
  if (error) throw error;
  return data;
}
