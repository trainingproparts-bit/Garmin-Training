-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 147: Flip cards quadrados (Além da corrida)
-- ============================================================================
-- Pedido do usuário (2026-09-15, ao ver os flip cards já com foto de capa
-- enviada): numa grade de 2 colunas, o min-height fixo de 178px dava uma
-- proporção "banner fino" em vez de foto quadrada — "ficou muito estreito,
-- era melhor quadrado". Usa a flag nova `square` (ver ContentBlocks.js/
-- .cb-flip-square, aspect-ratio 1:1) nos dois blocos flip_card da lição
-- "Além da corrida e as perguntas certas": os 8 perfis com foto e o de
-- perguntas rápidas (que tinha `compact: true`, agora substituído por
-- `square: true`).
-- ============================================================================

update lessons
set body = jsonb_set(
  jsonb_set(body, '{blocks,1,square}', 'true'::jsonb),
  '{blocks,3}',
  (body->'blocks'->3) || '{"square": true, "compact": false}'::jsonb
)
where id = '4e259942-be34-46f3-b264-42c681a29e8c';

-- ============================================================================
-- FIM DA MIGRAÇÃO 147
-- ============================================================================
