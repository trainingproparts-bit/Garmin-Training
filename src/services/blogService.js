// src/services/blogService.js
// Blog — tabela `blog_posts` já existia no schema base (sem UI até agora):
// categoria fixa (CHECK: Caso Real/Novidade/Comunicado/Dica), leitura pra
// qualquer autenticado, escrita só admin (blog_posts_insert/update/delete_admin).
// Não é por marca (sem brand_id) — conteúdo é da organização inteira.
// `author_id` referencia auth.users, não profiles diretamente; como o id é
// o mesmo (mesmo padrão usado em todo o app), buscamos o nome via profiles
// numa segunda consulta em vez de embed do PostgREST (não existe FK formal).

import { supabase } from '../config/supabase.js';

export const CATEGORIES = ['Caso Real', 'Novidade', 'Comunicado', 'Dica'];

async function attachAuthorNames(posts) {
  const authorIds = [...new Set(posts.map((p) => p.author_id).filter(Boolean))];
  if (!authorIds.length) return posts;

  const { data: authors, error } = await supabase
    .from('profiles')
    .select('id, full_name')
    .in('id', authorIds);
  if (error) throw error;

  const nameById = new Map(authors.map((a) => [a.id, a.full_name]));
  return posts.map((p) => ({ ...p, author_name: nameById.get(p.author_id) || null }));
}

export async function fetchPublishedPosts() {
  const { data, error } = await supabase
    .from('blog_posts')
    .select('id, title, content, category, banner_url, author_id, created_at')
    .eq('is_published', true)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return attachAuthorNames(data);
}

/** Todos os posts, publicados ou não — só admin consegue de fato ler os não publicados (RLS não filtra por status hoje, então isso é assumido chamado só pelo painel de admin). */
export async function fetchAllPostsForAdmin() {
  const { data, error } = await supabase
    .from('blog_posts')
    .select('id, title, content, category, banner_url, author_id, is_published, created_at')
    .order('created_at', { ascending: false });
  if (error) throw error;
  return attachAuthorNames(data);
}

export async function createPost({ title, content, category, bannerUrl, isPublished, authorId }) {
  const { data, error } = await supabase
    .from('blog_posts')
    .insert({
      title,
      content,
      category,
      banner_url: bannerUrl || null,
      is_published: isPublished,
      author_id: authorId,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function updatePost(postId, { title, content, category, bannerUrl, isPublished }) {
  const { data, error } = await supabase
    .from('blog_posts')
    .update({
      title,
      content,
      category,
      banner_url: bannerUrl || null,
      is_published: isPublished,
      updated_at: new Date().toISOString(),
    })
    .eq('id', postId)
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function deletePost(postId) {
  const { error } = await supabase.from('blog_posts').delete().eq('id', postId);
  if (error) throw error;
}

/**
 * Marca "li este post" (blog_reads, sql/048) — não existia nenhum
 * rastreamento de leitura de blog antes desta tabela; é a base do tipo
 * "blog" na Homologação Semanal. Upsert por (user_id, post_id): clicar de
 * novo não duplica nem dá erro.
 */
export async function markPostAsRead(userId, postId) {
  const { error } = await supabase
    .from('blog_reads')
    .upsert({ user_id: userId, post_id: postId }, { onConflict: 'user_id,post_id' });
  if (error) throw error;
}

/** IDs de posts que o usuário já marcou como lido. */
export async function fetchReadPostIds(userId) {
  const { data, error } = await supabase.from('blog_reads').select('post_id').eq('user_id', userId);
  if (error) throw error;
  return data.map((r) => r.post_id);
}
