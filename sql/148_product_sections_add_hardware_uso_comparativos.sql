-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 148: Novos section_type "hardware"/"uso" e
-- libera "comparativos" pra blocos ricos em product_sections
-- ============================================================================
-- Pedido do usuário (2026-09-15): redesign da página do CIRQA como
-- "experiência de descoberta do produto" (mostrar primeiro, explicar depois)
-- precisou de 2 seções novas na página de produto — "Hardware" (specs
-- técnicas) e "Uso" (pulso/bíceps, LEDs, botão físico, limitações) — ver
-- NAV_SECTIONS/NAV_GROUPS/BLOCK_SECTION_KEYS em produtoDetail.js e
-- SECTION_TYPES em academiaService.js. Genéricas, não exclusivas do CIRQA.
--
-- "comparativos" passa a aceitar blocos ricos (product_sections) ALÉM da
-- lista nativa de product_comparisons — necessário pro comparativo
-- editorial "CIRQA × Whoop": Whoop não é um produto deste catálogo, não dá
-- pra criar uma linha real em product_comparisons (que exige os dois
-- produtos cadastrados). Ver renderSectionPanelInner em produtoDetail.js —
-- aditivo, mostra os blocos SE existirem e sempre mostra a lista nativa
-- depois; produtos que só usam um dos dois caminhos não mudam.
--
-- O CHECK constraint de product_sections.section_type não previa nenhum dos
-- três valores — precisou ser recriado com a lista ampliada.
-- ============================================================================

alter table product_sections drop constraint product_sections_section_type_check;
alter table product_sections add constraint product_sections_section_type_check
  check (section_type = any (array['visao_geral','personas','diferenciais','hardware','uso','novidades','comparativos','scripts_venda','objecoes','casos_uso','faq']));

-- ============================================================================
-- FIM DA MIGRAÇÃO 148
-- ============================================================================
