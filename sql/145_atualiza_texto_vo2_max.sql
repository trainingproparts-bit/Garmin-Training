-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 145: Texto mais simples pro card VO2 Máx
-- (módulo Métricas Essenciais e Avançadas de Corrida)
-- ============================================================================
-- Pedido do usuário (2026-09-15): substituir a definição e o "toque
-- prático" do card "Capacidade Cardiorrespiratória (VO2 Máx)" (metric_card_
-- grid, lição "Métricas Fisiológicas e Gestão de Esforço") por um texto mais
-- direto — mantém o nome do card como estava, só troca definição/tip.
-- ============================================================================

update lessons
set body = jsonb_set(
  jsonb_set(
    body,
    '{blocks,0,items,0,definition}',
    '"É uma estimativa da capacidade do corpo de captar e utilizar oxigênio durante o exercício."'::jsonb
  ),
  '{blocks,0,items,0,tip}',
  '"Na prática, é um indicador de condicionamento aeróbico. Quanto maior a capacidade de utilizar oxigênio, maior tende a ser a capacidade de sustentar esforços. Na venda: ajuda o cliente a acompanhar a evolução do condicionamento ao longo do tempo."'::jsonb
)
where id = '342f0472-cd16-409c-aa13-80777d400f2f'
  and body->'blocks'->0->'items'->0->>'name' = 'Capacidade Cardiorrespiratória (VO2 Máx)';

-- ============================================================================
-- FIM DA MIGRAÇÃO 145
-- ============================================================================
