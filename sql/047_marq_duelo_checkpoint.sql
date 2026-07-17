-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 047: checkpoint do Duelo MARQ
-- ============================================================================
-- Bug reportado pelo usuário: "o duelo MARQ subiu das abas" — o Duelo MARQ
-- Carbon (games.id d4bfa12e-8c5c-4553-8114-c623d6d47137) nunca teve
-- checkpoint associado a nenhuma zona, então não aparecia dentro do
-- Circuito de Desafios (com os níveis/abas) como o Duelo Instinct 3
-- (checkpoint 53b77835-..., zona "Circuito de Desafios", order_index 5) —
-- em vez disso, "flutuava" solto na listagem genérica de Games (games.js
-- lista TODOS os games publicados da marca, sem depender de checkpoint).
--
-- Fix: mesmo tratamento do Duelo Instinct 3 — checkpoint tipo 'game',
-- opcional (is_required=false, mesmo padrão dos extras do Circuito de
-- Desafios). Vai pra "Circuito de Desafios · Nível 2" (não pro Nível 1,
-- que já tem o duelo Instinct) — mesma zona do "Quiz Especial — Cintas
-- Cardíacas (HRM)" hoje único item de lá, order_index 2 (logo depois).
-- ============================================================================

insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
values (
  '5436de90-b090-43dc-95b0-15237036d129', -- Circuito de Desafios · Nível 2
  'game',
  'd4bfa12e-8c5c-4553-8114-c623d6d47137', -- Duelo MARQ Carbon
  2,
  false
);

-- ============================================================================
-- FIM DA MIGRAÇÃO 047
-- ============================================================================
