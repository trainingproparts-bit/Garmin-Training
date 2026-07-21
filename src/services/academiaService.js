// src/services/academiaService.js
// Camada de acesso a dados da Academia de Produtos — domínio independente
// das Trilhas (não reaproveita modules/lessons; ver sql/064). Reaproveita só
// o FORMATO de conteúdo rico já existente (product_sections.payload usa o
// mesmo { blocks: [...] } de content_library, renderizado por
// ContentBlocks.js) e o motor de quiz/game já existentes (product_quizzes só
// liga produto→quiz, product_comparisons.comparison_game_id só aponta pra um
// game — nenhum motor novo).

import { supabase } from '../config/supabase.js';

export const SECTION_TYPES = [
  { key: 'visao_geral', label: 'Visão Geral', icon: '📋' },
  { key: 'personas', label: 'Personas', icon: '🧑‍🤝‍🧑' },
  { key: 'diferenciais', label: 'Diferenciais', icon: '⭐' },
  { key: 'comparativos', label: 'Comparativos', icon: '⚖️' },
  { key: 'scripts_venda', label: 'Scripts de Venda', icon: '🗣️' },
  { key: 'objecoes', label: 'Objeções', icon: '🛡️' },
  { key: 'casos_uso', label: 'Casos de Uso', icon: '💼' },
  { key: 'faq', label: 'FAQ', icon: '❓' },
  { key: 'downloads', label: 'Downloads', icon: '📥' },
  { key: 'quiz', label: 'Quiz Especialista', icon: '🏆' },
];

/** Categorias + contagem de produtos publicados, pra tela inicial da Academia. */
export async function fetchCategories(brandId) {
  const { data, error } = await supabase
    .from('product_categories')
    .select('id, slug, name, icon, order_index, products(count)')
    .eq('brand_id', brandId)
    .order('order_index', { ascending: true });
  if (error) throw error;
  return data.map((c) => ({ ...c, productCount: c.products?.[0]?.count || 0 }));
}

/** Produtos publicados de uma categoria (cards da grade). */
export async function fetchProductsByCategory(categoryId) {
  const { data, error } = await supabase
    .from('products')
    .select('id, slug, name, model_code, tagline, price_usd, cover_url')
    .eq('category_id', categoryId)
    .eq('is_published', true)
    .order('order_index', { ascending: true });
  if (error) throw error;
  return data;
}

/**
 * Página completa de um produto: dados básicos + as 7 seções de bloco rico +
 * materiais de download + quiz especialista ligado + relacionados (grafo).
 * Comparativos NÃO vêm daqui — são buscados à parte (fetchComparisonsForProduct)
 * porque um comparativo pode aparecer nas páginas dos DOIS produtos que ele liga.
 */
export async function fetchProductBySlug(brandId, slug) {
  const { data: product, error: prodErr } = await supabase
    .from('products')
    .select('id, slug, name, model_code, tagline, price_usd, cover_url, category_id, product_categories(name, slug)')
    .eq('brand_id', brandId)
    .eq('slug', slug)
    .eq('is_published', true)
    .single();
  if (prodErr) throw prodErr;

  const [sections, materials, quizzes, relationships, comparisons] = await Promise.all([
    fetchSections(product.id),
    fetchMaterials(product.id),
    fetchProductQuizzes(product.id),
    fetchRelationships(product.id),
    fetchComparisonsForProduct(product.id),
  ]);

  return { ...product, sections, materials, quizzes, relationships, comparisons };
}

async function fetchSections(productId) {
  const { data, error } = await supabase
    .from('product_sections')
    .select('section_type, payload')
    .eq('product_id', productId);
  if (error) throw error;

  const map = new Map(data.map((s) => [s.section_type, s.payload]));
  return map;
}

async function fetchMaterials(productId) {
  const { data, error } = await supabase
    .from('product_materials')
    .select('id, type, title, url')
    .eq('product_id', productId)
    .order('order_index', { ascending: true });
  if (error) throw error;
  return data;
}

async function fetchProductQuizzes(productId) {
  const { data, error } = await supabase
    .from('product_quizzes')
    .select('quiz_id, quizzes(id, slug, title, passing_score_pct)')
    .eq('product_id', productId)
    .order('order_index', { ascending: true });
  if (error) throw error;
  return data.map((r) => r.quizzes).filter(Boolean);
}

/** Relacionados — related_product_id vira link navegável, related_label vira tag informativa. */
async function fetchRelationships(productId) {
  const { data, error } = await supabase
    .from('product_relationships')
    .select('id, relationship_type, related_label, related_product_id, related:related_product_id(slug, name)')
    .eq('product_id', productId)
    .order('order_index', { ascending: true });
  if (error) throw error;
  return data.map((r) => ({
    id: r.id,
    type: r.relationship_type,
    label: r.related_label || r.related?.name,
    slug: r.related?.slug || null,
    relatedProductId: r.related_product_id,
  }));
}

/** Comparativos onde o produto aparece (como A ou como B). */
export async function fetchComparisonsForProduct(productId) {
  const { data, error } = await supabase
    .from('product_comparisons')
    .select('id, slug, title, product_a:product_a_id(slug, name), product_b:product_b_id(slug, name)')
    .or(`product_a_id.eq.${productId},product_b_id.eq.${productId}`)
    .eq('is_published', true);
  if (error) throw error;
  return data;
}

/** Página de comparativo completa: resumo, blocos ricos, tabela spec-a-spec e o game ligado (se houver). */
export async function fetchComparisonBySlug(brandId, slug) {
  const { data: comparison, error } = await supabase
    .from('product_comparisons')
    .select(`
      id, slug, title, resumo_executivo, blocks, comparison_game_id,
      product_a:product_a_id(id, slug, name, cover_url),
      product_b:product_b_id(id, slug, name, cover_url),
      games(id, slug, title)
    `)
    .eq('brand_id', brandId)
    .eq('slug', slug)
    .eq('is_published', true)
    .single();
  if (error) throw error;

  const { data: items, error: itemsErr } = await supabase
    .from('comparison_items')
    .select('id, spec_label, value_a, value_b, winner')
    .eq('comparison_id', comparison.id)
    .order('order_index', { ascending: true });
  if (itemsErr) throw itemsErr;

  return { ...comparison, items };
}

// ---------------------------------------------------------------------------
// Edição (admin) — "preciso que seja possível editar todo o conteúdo
// facilmente" (pedido do usuário, 2026-07-20). RLS já libera ALL pra admin
// em toda tabela da Academia (sql/064); aqui só as funções de escrita.
// Materiais/relacionados/itens de comparativo usam delete-then-reinsert (listas
// pequenas, mesmo princípio já usado em fn_review_catalog_sync_blocks pra
// blocos) — mais simples que tentar casar id-a-id numa lista que pode ganhar/
// perder linhas a qualquer edição.
// ---------------------------------------------------------------------------

export async function updateProduct(productId, fields) {
  const { error } = await supabase.from('products').update(fields).eq('id', productId);
  if (error) throw error;
}

export async function updateProductSection(productId, sectionType, blocks) {
  const { error } = await supabase
    .from('product_sections')
    .upsert({ product_id: productId, section_type: sectionType, payload: { blocks } }, { onConflict: 'product_id,section_type' });
  if (error) throw error;
}

export async function replaceMaterials(productId, materials) {
  const { error: delErr } = await supabase.from('product_materials').delete().eq('product_id', productId);
  if (delErr) throw delErr;
  if (!materials.length) return;
  const rows = materials.map((m, i) => ({ product_id: productId, type: m.type, title: m.title, url: m.url, order_index: i }));
  const { error } = await supabase.from('product_materials').insert(rows);
  if (error) throw error;
}

export async function replaceRelationships(productId, relationships) {
  const { error: delErr } = await supabase.from('product_relationships').delete().eq('product_id', productId);
  if (delErr) throw delErr;
  if (!relationships.length) return;
  const rows = relationships.map((r, i) => ({
    product_id: productId,
    related_product_id: r.relatedProductId || null,
    related_label: r.relatedProductId ? null : (r.label || null),
    relationship_type: r.type || null,
    order_index: i,
  }));
  const { error } = await supabase.from('product_relationships').insert(rows);
  if (error) throw error;
}

/** Produtos publicados de TODAS as categorias da marca — pro seletor de "relacionado" no editor. */
export async function fetchAllProductsForBrand(brandId) {
  const { data, error } = await supabase
    .from('products')
    .select('id, name')
    .eq('brand_id', brandId)
    .eq('is_published', true)
    .order('name', { ascending: true });
  if (error) throw error;
  return data;
}

export async function updateComparison(comparisonId, fields) {
  const { error } = await supabase.from('product_comparisons').update(fields).eq('id', comparisonId);
  if (error) throw error;
}

export async function replaceComparisonItems(comparisonId, items) {
  const { error: delErr } = await supabase.from('comparison_items').delete().eq('comparison_id', comparisonId);
  if (delErr) throw delErr;
  if (!items.length) return;
  const rows = items.map((it, i) => ({
    comparison_id: comparisonId,
    spec_label: it.spec_label,
    value_a: it.value_a || null,
    value_b: it.value_b || null,
    winner: it.winner || null,
    order_index: i,
  }));
  const { error } = await supabase.from('comparison_items').insert(rows);
  if (error) throw error;
}
