// src/services/forumService.js
// Fórum/Comunidade de Dúvidas — organização inteira (sem brand_id, mesmo
// padrão de blog_posts). Escrita de conteúdo próprio (thread/reply/voto)
// e edição/moderação são todas decididas pela RLS (sql/107); este service
// não duplica nenhuma checagem de permissão no cliente além do que a UI
// precisa pra decidir o que mostrar.

import { supabase } from '../config/supabase.js';

// ── Categorias ───────────────────────────────────────────────────────────

export async function fetchCategories() {
  const { data, error } = await supabase
    .from('forum_categories')
    .select('id, name, slug, description, order_index, is_active')
    .eq('is_active', true)
    .order('order_index', { ascending: true });
  if (error) throw error;
  return data;
}

/** Todas, incluindo inativas — só pro painel admin de gerenciamento. */
export async function fetchAllCategoriesAdmin() {
  const { data, error } = await supabase
    .from('forum_categories')
    .select('id, name, slug, description, order_index, is_active')
    .order('order_index', { ascending: true });
  if (error) throw error;
  return data;
}

export async function createCategory({ name, slug, description, orderIndex }) {
  const { data, error } = await supabase
    .from('forum_categories')
    .insert({ name, slug, description: description || null, order_index: orderIndex ?? 0 })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function updateCategory(categoryId, updates) {
  const { error } = await supabase.from('forum_categories').update(updates).eq('id', categoryId);
  if (error) throw error;
}

// ── Tópicos ──────────────────────────────────────────────────────────────

/** Lista via v_forum_thread_list (sql/107) — já vem com categoria/autor/cargo/contagens, sem N+1. */
export async function fetchThreadList() {
  const { data, error } = await supabase
    .from('v_forum_thread_list')
    .select('*')
    .order('is_pinned', { ascending: false })
    .order('last_activity_at', { ascending: false });
  if (error) throw error;
  return data;
}

export async function fetchThreadById(threadId) {
  const { data, error } = await supabase
    .from('v_forum_thread_list')
    .select('*')
    .eq('id', threadId)
    .single();
  if (error) throw error;
  return data;
}

export async function createThread({ categoryId, authorId, title, body }) {
  const { data, error } = await supabase
    .from('forum_threads')
    .insert({ category_id: categoryId, author_id: authorId, title, body })
    .select()
    .single();
  if (error) throw error;
  return data;
}

/** Editar título/corpo do próprio tópico — RLS bloqueia editar de outro. */
export async function updateThreadContent(threadId, { title, body }) {
  const { error } = await supabase.from('forum_threads').update({ title, body }).eq('id', threadId);
  if (error) throw error;
}

/** Fixar/desfixar — só líder/admin (RLS + trigger de guarda em sql/107 bloqueiam qualquer outro). */
export async function setThreadPinned(threadId, isPinned) {
  const { error } = await supabase.from('forum_threads').update({ is_pinned: isPinned }).eq('id', threadId);
  if (error) throw error;
}

/** Trancar/reabrir — só líder/admin. */
export async function setThreadLocked(threadId, isLocked) {
  const { error } = await supabase.from('forum_threads').update({ is_locked: isLocked }).eq('id', threadId);
  if (error) throw error;
}

/** Marcar/desmarcar solução — autor do tópico OU líder/admin (RLS: update_own cobre o autor, update_moderator cobre o resto). Passar null desmarca. */
export async function setThreadSolution(threadId, replyId) {
  const { error } = await supabase.from('forum_threads').update({ solution_reply_id: replyId }).eq('id', threadId);
  if (error) throw error;
}

export async function deleteThread(threadId) {
  const { error } = await supabase.from('forum_threads').delete().eq('id', threadId);
  if (error) throw error;
}

// ── Respostas ────────────────────────────────────────────────────────────

const REPLY_SELECT = 'id, thread_id, body, created_at, updated_at, author:profiles!author_id(id, full_name, roles(code))';

export async function fetchReplies(threadId) {
  const { data, error } = await supabase
    .from('forum_replies')
    .select(REPLY_SELECT)
    .eq('thread_id', threadId)
    .order('created_at', { ascending: true });
  if (error) throw error;
  return data;
}

export async function createReply({ threadId, authorId, body }) {
  const { data, error } = await supabase
    .from('forum_replies')
    .insert({ thread_id: threadId, author_id: authorId, body })
    .select(REPLY_SELECT)
    .single();
  if (error) throw error;
  return data;
}

export async function updateReplyContent(replyId, body) {
  const { error } = await supabase.from('forum_replies').update({ body }).eq('id', replyId);
  if (error) throw error;
}

export async function deleteReply(replyId) {
  const { error } = await supabase.from('forum_replies').delete().eq('id', replyId);
  if (error) throw error;
}

// ── Votos ────────────────────────────────────────────────────────────────

export async function fetchVoteCounts(threadId) {
  const { data, error } = await supabase
    .from('forum_votes')
    .select('reply_id, user_id, forum_replies!inner(thread_id)')
    .eq('forum_replies.thread_id', threadId);
  if (error) throw error;
  return data;
}

/** Toggle: se o usuário já votou, remove; senão, insere. Retorna o novo estado (true = votado). */
export async function toggleVote(replyId, userId) {
  const { data: existing, error: selErr } = await supabase
    .from('forum_votes')
    .select('id')
    .eq('reply_id', replyId)
    .eq('user_id', userId)
    .maybeSingle();
  if (selErr) throw selErr;

  if (existing) {
    const { error } = await supabase.from('forum_votes').delete().eq('id', existing.id);
    if (error) throw error;
    return false;
  }

  const { error } = await supabase.from('forum_votes').insert({ reply_id: replyId, user_id: userId });
  if (error) throw error;
  return true;
}
