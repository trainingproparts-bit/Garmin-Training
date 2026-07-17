// src/services/brandService.js
// Serviço para buscar marcas do Supabase

import { supabase } from '../config/supabase.js';

/**
 * Busca todas as marcas ativas do Supabase.
 * @returns {Promise<{data: Array, error?: string}>}
 */
export async function fetchActiveBrands() {
  try {
    const { data, error } = await supabase
      .from('brands')
      .select('*')
      .eq('is_active', true)
      .order('name', { ascending: true });

    if (error) {
      return { data: [], error: error.message };
    }

    return { data };
  } catch (err) {
    console.error('[brandService] Erro ao buscar marcas:', err);
    return { data: [], error: 'Erro ao conectar com o banco de dados.' };
  }
}

/**
 * Busca uma marca específica por ID.
 * @param {string} brandId - ID da marca
 * @returns {Promise<{data: object|null, error?: string}>}
 */
export async function fetchBrandById(brandId) {
  try {
    const { data, error } = await supabase
      .from('brands')
      .select('*')
      .eq('id', brandId)
      .single();

    if (error) {
      return { data: null, error: error.message };
    }

    return { data };
  } catch (err) {
    console.error('[brandService] Erro ao buscar marca:', err);
    return { data: null, error: 'Erro ao conectar com o banco de dados.' };
  }
}
