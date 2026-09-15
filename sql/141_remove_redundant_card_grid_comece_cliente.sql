-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 141: Remove card_grid redundante em "Comece
-- pelo cliente" (módulo Perfis de Cliente, Zona Explorador)
-- ============================================================================
-- Pedido do usuário (2026-09-15, ao revisar o redesign da sql/137): o
-- card_grid de 11 perfis no final da lição "Comece pelo cliente" duplicava,
-- em resumo, o mesmo conteúdo detalhado nas lições seguintes ("Perfis de
-- corrida" — Corredor Iniciante/Dedicado/Atleta de Performance — e "Além da
-- corrida" — Aventureiro, Lifestyle, Ciclista, Nadador, Mergulhador,
-- Golfista, Motociclista, Náutico). Virou mais visível depois do redesign
-- visual (sql/137) deixar os cards mais chamativos.
--
-- Troca o card_grid por um parágrafo de transição simples — usuário pediu
-- texto, não uma lista de tags.
-- ============================================================================

update lessons
set body = jsonb_set(
  body,
  '{blocks,7}',
  '{"type": "texto_rico", "html": "<p>Nas próximas etapas você vai conhecer, com mais detalhe, cada um desses perfis — do corredor iniciante ao praticante de esportes náuticos — e como reconhecer e atender cada um deles.</p>"}'::jsonb
)
where id = '94bb47ef-1fd6-4d07-97ff-e5c6b226e47f'
  and body->'blocks'->7->>'type' = 'card_grid';

-- ============================================================================
-- FIM DA MIGRAÇÃO 141
-- ============================================================================
