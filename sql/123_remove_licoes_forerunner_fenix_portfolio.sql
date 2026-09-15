-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 123: Remove as lições "Linha Forerunner" e
-- "Linha Fenix" do módulo Portfólio de Produtos (Zona Explorador)
-- ============================================================================
-- Pedido do usuário (2026-09-15, urgente — "tira esse título... linha
-- forerunner... e linha fenix"): o módulo tinha 3 lições (Forerunner, Fenix,
-- MARQ — sql/030). Desde a sql/120, a 3ª lição (MARQ) virou a mega-aula
-- "Portfólio de Produtos Garmin", que já recapitula Forerunner e Fenix
-- dentro dela mesma (blocos flip_card, ver sql/120/121). As duas lições
-- antigas nunca tiveram o corpo da sql/030 aplicado nesta base (rodavam
-- vazias — "Conteúdo desta aula ainda não cadastrado." na tela), então
-- sobravam só como títulos órfãos duplicando o que a mega-aula já cobre.
--
-- Some usuários já tinham marcado essas duas lições como concluídas
-- (lesson_progress) mesmo sem conteúdo — fn_complete_lesson permite marcar
-- uma lição vazia como feita. lesson_progress.lesson_id NÃO tem "on delete
-- cascade" (garmin_training_hub_migrations.sql:467), então apagar a lição
-- direto quebraria com erro de FK — por isso apaga o progresso associado
-- primeiro. O XP já concedido (points_ledger) fica intacto: source_id lá é
-- só um uuid solto, sem FK pra lessons (migrations.sql:494-505), e
-- fetchModuleProgress recalcula "X de Y lições" contando as lições
-- restantes ao vivo (moduleService.js) — módulo com 1 lição já concluída
-- continua mostrando 100%, sem "perder" progresso pro usuário.
-- ============================================================================

do $$
declare
  v_forerunner_id uuid := '3405fe07-5dd7-4599-9392-17c9155a1400';
  v_fenix_id      uuid := '2aa7a7af-19e2-4d02-94b6-81de1bc9460f';
begin
  delete from lesson_progress where lesson_id in (v_forerunner_id, v_fenix_id);
  delete from lessons where id in (v_forerunner_id, v_fenix_id);
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 123
-- ============================================================================
