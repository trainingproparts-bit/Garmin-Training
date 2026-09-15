-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 138: Flip cards compactos em "As perguntas
-- que ajudam a encontrar o caminho" (módulo Perfis de Cliente, Zona Explorador)
-- ============================================================================
-- Pedido do usuário (2026-09-15, ao ver a lição ao vivo): o flip_card dessa
-- seção (frente = 1 pergunta curta, verso = 1 frase curta) ficava com muito
-- espaço vazio no min-height padrão de 178px (ver comentário de `tall` em
-- ContentBlocks.js). Usa a flag `compact` nova (oposto do `tall`, mesmo
-- mecanismo aditivo — ver renderFlipCardBlock/.cb-flip-compact) só neste
-- bloco; nenhum outro flip_card do app muda.
-- ============================================================================

update lessons
set body = jsonb_set(
  body,
  '{blocks,3,compact}',
  'true'::jsonb
)
where id = '4e259942-be34-46f3-b264-42c681a29e8c'
  and body->'blocks'->3->>'type' = 'flip_card';

-- ============================================================================
-- FIM DA MIGRAÇÃO 138
-- ============================================================================
