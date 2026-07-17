// src/services/contentLibraryService.js
// Camada de acesso à "Biblioteca Técnica" (perfis de cliente, produtos, FAQ,
// concorrentes, especialidades por esporte) — tabela genérica content_library,
// criada nesta sprint (sql/002_content_library_schema.sql) porque a modelagem
// original ainda não formalizava esse domínio (ver relatório de auditoria).

import { supabase } from '../config/supabase.js';

export const CATEGORIES = {
  PERFIL_CLIENTE: 'perfil_cliente',
  PRODUTO: 'produto',
  FAQ: 'faq',
  CONCORRENTE: 'concorrente',
  ESPECIALIDADE: 'especialidade',
  DEEP_DIVE: 'deep_dive',
};

/** Busca todo o conteúdo publicado de uma categoria, para a marca informada. */
export async function fetchContentByCategory(brandId, category) {
  const { data, error } = await supabase
    .from('content_library')
    .select('id, slug, title, summary, payload, order_index')
    .eq('brand_id', brandId)
    .eq('category', category)
    .eq('is_published', true)
    .order('order_index', { ascending: true });
  if (error) throw error;
  return data;
}

/** Busca um único item publicado pelo slug (página dedicada de um guia técnico). */
export async function fetchContentBySlug(brandId, category, slug) {
  const { data, error } = await supabase
    .from('content_library')
    .select('id, slug, title, summary, payload, order_index')
    .eq('brand_id', brandId)
    .eq('category', category)
    .eq('slug', slug)
    .eq('is_published', true)
    .maybeSingle();
  if (error) throw error;
  return data;
}

/** Atualiza um item da biblioteca (usado para edição de personas). */
export async function updateContentItem(id, updates) {
  const { data, error } = await supabase
    .from('content_library')
    .update(updates)
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
}
