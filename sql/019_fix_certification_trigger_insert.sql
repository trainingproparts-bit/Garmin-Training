-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 019: trg_issue_certification também no INSERT
-- ============================================================================
-- Segundo bug real achado no mesmo teste de 017/018 (fluxo completo de
-- colaborador): trg_issue_certification disparava só AFTER UPDATE ON
-- user_progress. Mas fn_update_user_progress_from_lesson()/
-- fn_update_user_progress_from_quiz() sempre fazem
-- `INSERT ... ON CONFLICT DO UPDATE` — na PRIMEIRA vez que um checkpoint é
-- concluído (o caso normal, quase sempre), é um INSERT, não um UPDATE. Ou
-- seja, o trigger nunca rodava na prática: confirmado ao vivo com Daniel
-- Lucena, que completou os 8 checkpoints obrigatórios da Zona Explorador
-- (4 módulos + 4 quizzes, 100% em todos) e nenhuma certificação foi emitida
-- — user_certifications ficou vazia mesmo com user_progress 8/8 completed.
--
-- Combinado com o bug de 017 (contagem por trilha inteira em vez de por
-- zona), isso tornava a emissão de certificado praticamente impossível na
-- prática, não só incorreta.
--
-- Fix: trigger passa a rodar também em INSERT.
-- ============================================================================

drop trigger if exists trg_issue_certification on public.user_progress;
create trigger trg_issue_certification
after insert or update on public.user_progress
for each row execute function fn_issue_certification();

-- ============================================================================
-- FIM DA MIGRAÇÃO 019
-- ============================================================================
