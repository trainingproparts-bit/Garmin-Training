-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 063: corrige order_index duplicado na
-- Zona Atleta (bug reportado: "próximo passo" volta a mostrar o quiz do
-- Garmin Coach de novo depois de já ter sido concluído)
-- ============================================================================
-- sql/055 inseriu o checkpoint do módulo "Métricas Essenciais de Corrida"
-- com order_index=4, colidindo com o checkpoint do quiz "Corredor — Garmin
-- Coach" (que já usava order_index=4). proximoCheckpoint() (GpsTrail.js)
-- percorre zone.checkpoints na ordem que a query devolve — com dois
-- checkpoints empatados em order_index e SEM critério de desempate no
-- ORDER BY (nem no SQL, nem no .order() do Supabase client), o Postgres não
-- garante qual das duas linhas empatadas vem primeiro. Dependendo do plano
-- de execução, isso pode fazer o quiz recém-concluído reaparecer como
-- "próximo passo" em vez do módulo seguinte de verdade.
--
-- Correção: renumera os 12 checkpoints da Zona Atleta com order_index único
-- e estritamente sequencial (preserva a ordem relativa já existente —
-- módulo sempre antes do próprio quiz, cada par antes do próximo).
-- ============================================================================

update public.checkpoints set order_index = 1  where id = '8c308893-aa44-43a0-b681-495bb244a05e'; -- Garmin Connect (módulo)
update public.checkpoints set order_index = 2  where id = '292a7ac2-1d2f-480d-9fdc-bb5361469313'; -- Corredor — Garmin Connect (quiz)
update public.checkpoints set order_index = 3  where id = '25cc1a65-55cb-493c-931d-b051a0942e68'; -- Garmin Coach (módulo)
update public.checkpoints set order_index = 4  where id = '369de921-0583-4e1c-bceb-81d2af6aa30b'; -- Corredor — Garmin Coach (quiz)
update public.checkpoints set order_index = 5  where id = '1d9afa46-3c91-4b2a-ba5d-d6bbc84814d2'; -- Métricas Essenciais de Corrida (módulo)
update public.checkpoints set order_index = 6  where id = '02371d34-aa4d-496c-ab7c-6fa285eb15f7'; -- Quiz — Métricas Essenciais de Corrida
update public.checkpoints set order_index = 7  where id = '855dc058-b799-4644-ab36-2357c306e08e'; -- Linha Edge de Entrada e Sensores (módulo)
update public.checkpoints set order_index = 8  where id = 'a19c5cc7-aaa1-487f-aa22-40389efa5d0c'; -- Quiz — Linha Edge de Entrada e Sensores
update public.checkpoints set order_index = 9  where id = 'e624be62-397c-4cec-8396-d9074b20ebd8'; -- Introdução à Potência e Dinâmica de Pedal (módulo)
update public.checkpoints set order_index = 10 where id = '0e530eb1-3367-4f34-a21a-bd724d8baa5d'; -- Quiz — Potência e Dinâmica de Pedal
update public.checkpoints set order_index = 11 where id = 'd07d9652-f365-42cf-b17e-9ed7476c0cef'; -- Contornando Objeções de Preço (módulo)
update public.checkpoints set order_index = 12 where id = 'e6d65e12-01e4-44d0-9cce-4d1912e9fd8a'; -- Quiz — Contornando Objeções de Preço

-- ============================================================================
-- FIM DA MIGRAÇÃO 063
-- ============================================================================
