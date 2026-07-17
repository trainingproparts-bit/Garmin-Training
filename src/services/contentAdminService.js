// src/services/contentAdminService.js
// CRUD administrativo de módulos/lições/quizzes (Painel da Gestora — 2ª
// rodada). Nenhuma RLS/migração nova: modules_admin_all, lessons_admin_all,
// quizzes_admin_all, questions_admin_all e alternatives_admin_all (todas
// `ALL`, fn_is_admin()) já existem desde o schema base — só faltava a UI.
//
// Fora de escopo aqui, por design do schema (não é uma lacuna desta rodada):
// vincular um módulo/quiz novo à trilha é uma ação separada (criar uma linha
// em `checkpoints` apontando pra ele) — módulos/quizzes são conteúdo,
// checkpoints são posicionamento na trilha, tabelas distintas de propósito.
// Um módulo/quiz criado aqui existe e pode ser editado, mas só aparece na
// trilha de um colaborador depois de alguém adicionar o checkpoint
// correspondente (hoje, via SQL direto — CRUD de trilha/checkpoints fica
// pra uma rodada futura, não foi pedido nesta).

import { supabase } from '../config/supabase.js';

const slugify = (text) =>
  text
    .toLowerCase()
    .normalize('NFD').replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '');

// ── Zonas (só leitura — escopo de módulos) ──────────────────────────────

export async function fetchZonesWithBrand() {
  const { data, error } = await supabase
    .from('zones')
    .select('id, name, order_index, trails(brand_id, brands(name))')
    .order('order_index', { ascending: true });
  if (error) throw error;
  return data;
}

// ── Módulos ──────────────────────────────────────────────────────────────

export async function fetchAllModulesAdmin() {
  const { data, error } = await supabase
    .from('modules')
    .select('id, zone_id, slug, title, summary, estimated_minutes, order_index, is_published, zones(name, trails(brand_id))')
    .order('zone_id', { ascending: true })
    .order('order_index', { ascending: true });
  if (error) throw error;
  return data;
}

export async function createModule({ zoneId, title, summary, estimatedMinutes, orderIndex }) {
  const { data, error } = await supabase
    .from('modules')
    .insert({
      zone_id: zoneId,
      slug: slugify(title),
      title,
      summary: summary || null,
      estimated_minutes: estimatedMinutes || null,
      order_index: orderIndex,
      is_published: false,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function updateModule(moduleId, updates) {
  const { error } = await supabase.from('modules').update(updates).eq('id', moduleId);
  if (error) throw error;
}

export async function deleteModule(moduleId) {
  const { error } = await supabase.from('modules').delete().eq('id', moduleId);
  if (error) throw error;
}

/** Persiste a nova ordem de um grupo de módulos (mesma zona) após drag-and-drop. */
export async function reorderModules(orderedIds) {
  await Promise.all(orderedIds.map((id, i) => supabase.from('modules').update({ order_index: i }).eq('id', id)));
}

// ── Lições ───────────────────────────────────────────────────────────────

/** Todas as lições do módulo, publicadas ou não (diferente de fetchModuleWithLessons, que só traz publicadas). */
export async function fetchAllLessonsAdmin(moduleId) {
  const { data, error } = await supabase
    .from('lessons')
    .select('id, module_id, title, content_type, order_index, is_published')
    .eq('module_id', moduleId)
    .order('order_index', { ascending: true });
  if (error) throw error;
  return data;
}

export async function createLesson({ moduleId, title, orderIndex }) {
  const { data, error } = await supabase
    .from('lessons')
    .insert({
      module_id: moduleId,
      title,
      content_type: 'text',
      body: { blocks: [] },
      order_index: orderIndex,
      is_published: false,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function updateLessonFields(lessonId, updates) {
  const { error } = await supabase.from('lessons').update(updates).eq('id', lessonId);
  if (error) throw error;
}

export async function deleteLesson(lessonId) {
  const { error } = await supabase.from('lessons').delete().eq('id', lessonId);
  if (error) throw error;
}

export async function reorderLessons(orderedIds) {
  await Promise.all(orderedIds.map((id, i) => supabase.from('lessons').update({ order_index: i }).eq('id', id)));
}

// ── Quizzes ──────────────────────────────────────────────────────────────

export async function fetchAllQuizzesAdmin() {
  const { data, error } = await supabase
    .from('quizzes')
    .select('id, brand_id, slug, title, passing_score_pct, max_attempts, is_published, brands(name)')
    .order('title', { ascending: true });
  if (error) throw error;
  return data;
}

export async function createQuiz({ brandId, title, passingScorePct, maxAttempts }) {
  const { data, error } = await supabase
    .from('quizzes')
    .insert({
      brand_id: brandId,
      slug: slugify(title),
      title,
      passing_score_pct: passingScorePct || 70,
      max_attempts: maxAttempts || null,
      is_published: false,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function updateQuiz(quizId, updates) {
  const { error } = await supabase.from('quizzes').update(updates).eq('id', quizId);
  if (error) throw error;
}

export async function deleteQuiz(quizId) {
  const { error } = await supabase.from('quizzes').delete().eq('id', quizId);
  if (error) throw error;
}

// ── Perguntas e alternativas ────────────────────────────────────────────

/** Perguntas + alternativas COM gabarito — só chamado pelo admin (alternatives_select_leader_admin libera is_correct pra líder/admin). */
export async function fetchQuestionsAdmin(quizId) {
  const { data: questions, error: qErr } = await supabase
    .from('questions')
    .select('id, quiz_id, body, explanation, order_index, is_active')
    .eq('quiz_id', quizId)
    .order('order_index', { ascending: true });
  if (qErr) throw qErr;

  const questionIds = questions.map((q) => q.id);
  const { data: alternatives, error: aErr } = questionIds.length
    ? await supabase
        .from('alternatives')
        .select('id, question_id, body, is_correct, order_index')
        .in('question_id', questionIds)
        .order('order_index', { ascending: true })
    : { data: [], error: null };
  if (aErr) throw aErr;

  return questions.map((q) => ({ ...q, alternatives: alternatives.filter((a) => a.question_id === q.id) }));
}

export async function createQuestion({ quizId, body, orderIndex }) {
  const { data, error } = await supabase
    .from('questions')
    .insert({ quiz_id: quizId, body, order_index: orderIndex, is_active: true })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function updateQuestion(questionId, updates) {
  const { error } = await supabase.from('questions').update(updates).eq('id', questionId);
  if (error) throw error;
}

export async function deleteQuestion(questionId) {
  const { error } = await supabase.from('questions').delete().eq('id', questionId);
  if (error) throw error;
}

export async function createAlternative({ questionId, body, orderIndex, isCorrect }) {
  const { data, error } = await supabase
    .from('alternatives')
    .insert({ question_id: questionId, body, order_index: orderIndex, is_correct: !!isCorrect })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function updateAlternative(alternativeId, updates) {
  const { error } = await supabase.from('alternatives').update(updates).eq('id', alternativeId);
  if (error) throw error;
}

/** Marca esta alternativa como a correta — fn_enforce_single_correct_alternative (schema base) desmarca as demais da mesma pergunta automaticamente. */
export async function markAlternativeCorrect(alternativeId) {
  const { error } = await supabase.from('alternatives').update({ is_correct: true }).eq('id', alternativeId);
  if (error) throw error;
}

export async function deleteAlternative(alternativeId) {
  const { error } = await supabase.from('alternatives').delete().eq('id', alternativeId);
  if (error) throw error;
}
