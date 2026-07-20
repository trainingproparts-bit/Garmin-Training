// src/services/searchService.js
// Busca global (topbar) — item do ROADMAP que estava "sem especificação de
// escopo"; escopo pragmático definido em 2026-07-14: busca por título/resumo
// nas 4 fontes de conteúdo que já existem (Biblioteca Técnica, módulos,
// quizzes, blog), via ILIKE do PostgREST — sem índice full-text, sem tabela
// nova, sem IA (o "Assistente IA especialista" segue como item separado do
// roadmap, com discovery próprio). Volume atual (~150 itens de biblioteca +
// 7 módulos + 12 quizzes + blog) não justifica nada mais pesado.
//
// RLS já escopa tudo: content_library/quizzes só publicados pra não-admin,
// blog_posts publicados pra qualquer autenticado, modules via
// modules_select_published. Nenhuma query aqui vaza rascunho.

import { supabase } from '../config/supabase.js';

const LIMIT_PER_SOURCE = 6;

/** Escapa os curingas do ILIKE — busca literal, termo do usuário nunca vira padrão. */
function likePattern(term) {
  return `%${term.replace(/[%_\\]/g, '\\$&')}%`;
}

const CATEGORY_LABELS = {
  perfil_cliente: 'Perfil de Cliente',
  produto: 'Produto',
  faq: 'FAQ',
  concorrente: 'Concorrente',
  especialidade: 'Especialidade',
  deep_dive: 'Guia Técnico',
};

/**
 * Busca em todas as fontes em paralelo. Retorna uma lista plana de
 * resultados { type, label, title, subtitle, nav } — `nav` carrega o que a
 * UI precisa pra deep-linkar (mesmo mecanismo window.selected* já usado por
 * Dashboard/Acesso Rápido).
 */
export async function searchAll(brandId, term) {
  const pattern = likePattern(term);

  const [library, modules, quizzes, blog, products, comparisons] = await Promise.all([
    searchLibrary(brandId, pattern),
    searchModules(brandId, pattern),
    searchQuizzes(brandId, pattern),
    searchBlog(pattern),
    searchProducts(brandId, pattern),
    searchComparisons(brandId, pattern),
  ]);

  return [...library, ...modules, ...quizzes, ...blog, ...products, ...comparisons];
}

/** Academia de Produtos — busca por produto (nome/tagline) e por comparativo (título). */
async function searchProducts(brandId, pattern) {
  const { data, error } = await supabase
    .from('products')
    .select('slug, name, tagline')
    .eq('brand_id', brandId)
    .eq('is_published', true)
    .or(`name.ilike.${pattern},tagline.ilike.${pattern}`)
    .limit(LIMIT_PER_SOURCE);
  if (error) throw error;

  return data.map((p) => ({
    type: 'product',
    label: 'Academia de Produtos',
    title: p.name,
    subtitle: p.tagline || '',
    nav: { panel: 'academia-produto-detail', productSlug: p.slug },
  }));
}

async function searchComparisons(brandId, pattern) {
  const { data, error } = await supabase
    .from('product_comparisons')
    .select('slug, title')
    .eq('brand_id', brandId)
    .eq('is_published', true)
    .ilike('title', pattern)
    .limit(LIMIT_PER_SOURCE);
  if (error) throw error;

  return data.map((c) => ({
    type: 'comparison',
    label: 'Comparativo',
    title: c.title,
    subtitle: '',
    nav: { panel: 'academia-comparativo', comparisonSlug: c.slug },
  }));
}

async function searchLibrary(brandId, pattern) {
  const { data, error } = await supabase
    .from('content_library')
    .select('id, slug, title, summary, category')
    .eq('brand_id', brandId)
    .eq('is_published', true)
    .or(`title.ilike.${pattern},summary.ilike.${pattern}`)
    .limit(LIMIT_PER_SOURCE);
  if (error) throw error;

  return data.map((item) => ({
    type: 'library',
    label: CATEGORY_LABELS[item.category] || 'Biblioteca',
    title: item.title,
    subtitle: item.summary || '',
    nav: item.category === 'deep_dive'
      ? { panel: 'deep-dive-detail', deepDiveSlug: item.slug }
      : { panel: 'biblioteca', libraryCategory: item.category },
  }));
}

async function searchModules(brandId, pattern) {
  // Escopo de marca via módulo→zona→trilha (modules não tem brand_id direto).
  const { data, error } = await supabase
    .from('modules')
    .select('id, title, summary, zones!inner(trails!inner(brand_id))')
    .eq('zones.trails.brand_id', brandId)
    .eq('is_published', true)
    .or(`title.ilike.${pattern},summary.ilike.${pattern}`)
    .limit(LIMIT_PER_SOURCE);
  if (error) throw error;

  return data.map((m) => ({
    type: 'module',
    label: 'Módulo',
    title: m.title,
    subtitle: m.summary || '',
    nav: { panel: 'modulo-conteudo', moduleId: m.id },
  }));
}

async function searchQuizzes(brandId, pattern) {
  const { data, error } = await supabase
    .from('quizzes')
    .select('id, title')
    .eq('brand_id', brandId)
    .eq('is_published', true)
    .ilike('title', pattern)
    .limit(LIMIT_PER_SOURCE);
  if (error) throw error;

  // Navega pra Arena de Desafios (lista), não direto pro runner — entrar no
  // runner cria uma tentativa real em quiz_attempts, efeito pesado demais pra
  // um clique em resultado de busca.
  return data.map((q) => ({
    type: 'quiz',
    label: 'Quiz',
    title: q.title,
    subtitle: '',
    nav: { panel: 'arena' },
  }));
}

async function searchBlog(pattern) {
  // Blog é da organização inteira (sem brand_id) — mesma regra de blog.js.
  const { data, error } = await supabase
    .from('blog_posts')
    .select('id, title, category')
    .eq('is_published', true)
    .or(`title.ilike.${pattern},content.ilike.${pattern}`)
    .limit(LIMIT_PER_SOURCE);
  if (error) throw error;

  return data.map((p) => ({
    type: 'blog',
    label: `Blog · ${p.category}`,
    title: p.title,
    subtitle: '',
    nav: { panel: 'blog' },
  }));
}
