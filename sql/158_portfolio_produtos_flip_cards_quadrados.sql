-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 158: Flip cards quadrados na lição
-- "Portfólio de Produtos Garmin" (3 blocos: tiers, Fēnix, Lily/Venu/Vivoactive)
-- ============================================================================
-- Pedido do usuário (2026-09-15, ao ver o bloco Lily 2/Lily 2 Active/Venu 4/
-- Vivoactive 6 com foto): mesmo problema já corrigido em "Além da corrida"
-- (sql/147) — 4 colunas com min-height fixo de 178px davam uma proporção
-- larga/baixa, apertando título+subtítulo+texto sobre a foto. Usa a flag
-- `square` (aspect-ratio 1:1, ver ContentBlocks.js/.cb-flip-square) nos 3
-- blocos flip_card desta lição (mesmo padrão visual, mesma correção).
--
-- Acompanha também um ajuste de CSS (contentBlocks.css) no degradê escuro
-- de fundo dos cards com foto — antes só escurecia forte embaixo (pensado
-- pro "toque para ver mais"), deixando o título no topo pouco legível em
-- fotos claras.
-- ============================================================================

update lessons
set body = jsonb_set(
  jsonb_set(
    jsonb_set(body, '{blocks,3,square}', 'true'::jsonb),
    '{blocks,5,square}', 'true'::jsonb
  ),
  '{blocks,9,square}', 'true'::jsonb
)
where id = '7d5e81d0-21a1-426a-9938-7bb667723d3c';

-- ============================================================================
-- FIM DA MIGRAÇÃO 158
-- ============================================================================
