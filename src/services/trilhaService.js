// src/services/trilhaService.js
// Camada de acesso a dados da Trilha de Formação. Nenhuma função aqui toca
// no DOM — quem renderiza é src/pages/trilha.js (via src/components/GpsTrail.js).

import { supabase } from '../config/supabase.js';

/** Resolve o brand_id a partir do slug (ex: 'garmin', 'shokz'). */
export async function fetchBrandIdBySlug(slug) {
  const { data, error } = await supabase
    .from('brands')
    .select('id')
    .eq('slug', slug)
    .single();

  if (error) throw new Error(`[trilhaService] marca "${slug}" não encontrada: ${error.message}`);
  return data.id;
}

/**
 * Busca a trilha publicada da marca, já com zonas e checkpoints aninhados.
 * Retorna: { trail, zones: [{ ...zone, checkpoints: [...] }] }
 */
export async function fetchTrilhaPublicada(brandId) {
  const { data: trail, error: trailErr } = await supabase
    .from('trails')
    .select('id, slug, name, description, cover_url')
    .eq('brand_id', brandId)
    .eq('is_published', true)
    .order('order_index', { ascending: true })
    .limit(1)
    .single();
  if (trailErr) throw trailErr;

  const { data: zones, error: zonesErr } = await supabase
    .from('zones')
    .select('id, name, banner_message, free_order, order_index')
    .eq('trail_id', trail.id)
    .order('order_index', { ascending: true });
  if (zonesErr) throw zonesErr;

  const zoneIds = zones.map((z) => z.id);
  const { data: checkpoints, error: cpErr } = await supabase
    .from('checkpoints')
    .select('id, zone_id, checkpoint_type, reference_id, order_index, is_required')
    .in('zone_id', zoneIds)
    .order('order_index', { ascending: true });
  if (cpErr) throw cpErr;

  const checkpointsComTitulo = await resolveCheckpointTitles(checkpoints);

  const zonesComCheckpoints = zones.map((zone) => ({
    ...zone,
    checkpoints: checkpointsComTitulo.filter((c) => c.zone_id === zone.id),
  }));

  return { trail, zones: zonesComCheckpoints };
}

/** Admin-only: define/remove a capa em tela cheia do Hero Card (sql/038). */
export async function updateTrailCover(trailId, coverUrl) {
  const { error } = await supabase
    .from('trails')
    .update({ cover_url: coverUrl || null })
    .eq('id', trailId);
  if (error) throw error;
}

/**
 * checkpoints.reference_id é polimórfico (module | quiz | game) — não existe
 * FK nativa pra isso no Postgres, então resolvemos o título com 3 buscas em lote
 * (mais barato que 1 query por checkpoint).
 */
async function resolveCheckpointTitles(checkpoints) {
  const idsByType = (type) => checkpoints.filter((c) => c.checkpoint_type === type).map((c) => c.reference_id);
  const quizIds = idsByType('quiz');

  // module/quiz têm cover_url (sql/027, redesign 2026-07-10) pro card 16:9
  // da trilha; games não tem coluna de capa ainda. Contagem de perguntas
  // (pedido do usuário — indicador "N perguntas" no card do Circuito de
  // Desafios) só existe pra quiz; time_limit_seconds é sempre null hoje
  // (nenhum quiz real usa limite de tempo), por isso não vale a pena
  // mostrar "N min" — a contagem de perguntas é o dado real disponível.
  const [modules, quizzes, games, questionCounts] = await Promise.all([
    fetchMeta('modules', idsByType('module'), true),
    fetchMeta('quizzes', idsByType('quiz'), true),
    fetchMeta('games', idsByType('game'), false),
    fetchQuizQuestionCounts(quizIds),
  ]);

  const metaMap = new Map([...modules, ...quizzes, ...games]);

  return checkpoints.map((c) => {
    const meta = metaMap.get(`${c.checkpoint_type}:${c.reference_id}`);
    return {
      ...c,
      title: meta?.title || 'Conteúdo indisponível',
      cover_url: meta?.cover_url || null,
      question_count: c.checkpoint_type === 'quiz' ? (questionCounts.get(c.reference_id) || 0) : undefined,
    };
  });
}

/** Quantidade de perguntas ativas por quiz — indicador de "peso" no card da trilha. */
async function fetchQuizQuestionCounts(quizIds) {
  if (!quizIds.length) return new Map();
  const { data, error } = await supabase
    .from('questions')
    .select('quiz_id')
    .eq('is_active', true)
    .in('quiz_id', quizIds);
  if (error) throw error;

  const counts = new Map();
  data.forEach((row) => counts.set(row.quiz_id, (counts.get(row.quiz_id) || 0) + 1));
  return counts;
}

async function fetchMeta(table, ids, hasCover) {
  if (!ids.length) return [];
  const type = table === 'modules' ? 'module' : table === 'quizzes' ? 'quiz' : 'game';
  const { data, error } = await supabase.from(table).select(hasCover ? 'id, title, cover_url' : 'id, title').in('id', ids);
  if (error) throw error;
  return data.map((row) => [`${type}:${row.id}`, { title: row.title, cover_url: row.cover_url }]);
}

/** Progresso do usuário logado — status por checkpoint (locked/unlocked/in_progress/completed). */
export async function fetchUserProgress(userId) {
  const { data, error } = await supabase
    .from('user_progress')
    .select('checkpoint_id, status, completed_at')
    .eq('user_id', userId);
  if (error) throw error;
  return data;
}

/**
 * Fração de lições concluídas por módulo (0-100), pra mini barra de
 * progresso nos cards da trilha (redesign 2026-07-10). Uma query em lote
 * pra todos os módulos da trilha de uma vez, em vez de N chamadas
 * (moduleService.fetchModuleProgress já existe mas é 1 módulo por vez —
 * feito pra dentro da tela do próprio módulo, não pra trilha inteira).
 */
export async function fetchModuleProgressMap(moduleIds, userId) {
  if (!moduleIds.length) return new Map();

  const { data: lessons, error: lessonsErr } = await supabase
    .from('lessons')
    .select('id, module_id')
    .in('module_id', moduleIds)
    .eq('is_published', true);
  if (lessonsErr) throw lessonsErr;

  let completedLessonIds = new Set();
  if (userId && lessons.length) {
    const { data: progress, error: progErr } = await supabase
      .from('lesson_progress')
      .select('lesson_id, completed_at')
      .eq('user_id', userId)
      .in('lesson_id', lessons.map((l) => l.id));
    if (progErr) throw progErr;
    completedLessonIds = new Set(progress.filter((p) => p.completed_at).map((p) => p.lesson_id));
  }

  const totalByModule = new Map();
  const doneByModule = new Map();
  lessons.forEach((l) => {
    totalByModule.set(l.module_id, (totalByModule.get(l.module_id) || 0) + 1);
    if (completedLessonIds.has(l.id)) doneByModule.set(l.module_id, (doneByModule.get(l.module_id) || 0) + 1);
  });

  const result = new Map();
  moduleIds.forEach((id) => {
    const total = totalByModule.get(id) || 0;
    const done = doneByModule.get(id) || 0;
    result.set(id, total ? Math.round((done / total) * 100) : 0);
  });
  return result;
}
