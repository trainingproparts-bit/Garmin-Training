-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 062: +10 pontos por avaliação Google
-- ============================================================================
-- Pedido do usuário: colaborador que receber uma avaliação Google (registrada
-- manualmente pelo admin em avaliacoes_google, sql/046) ganha +10 pts de
-- Score de Performance. Mesmo padrão já usado pras outras fontes de XP (quiz:
-- fn_award_points_on_pass; lição: fn_complete_lesson, sql/004; game/streak:
-- sql/035) — insere em points_ledger, que profiles.performance_score
-- (trg_sync_performance_score, sql/004) já soma automaticamente.
--
-- +10 por avaliação (não só na primeira) — diferente de quiz/lição/game, uma
-- avaliação Google não é algo que o próprio colaborador possa "farmar"
-- clicando de novo (é o admin quem registra, a partir de uma avaliação real
-- de cliente), então não precisa da trava de "só a primeira vez".
-- ============================================================================

alter table public.points_ledger
  drop constraint if exists chk_points_ledger_source;
alter table public.points_ledger
  add constraint chk_points_ledger_source
  check (source_type in ('quiz','module','lesson','game','badge','certification','streak','avaliacao_google','manual_adjustment'));

create or replace function public.fn_award_points_on_avaliacao_google()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.points_ledger (user_id, source_type, source_id, points, reason)
  values (new.profile_id, 'avaliacao_google', new.id, 10, 'Avaliação Google recebida');

  return new;
end;
$$;

comment on function public.fn_award_points_on_avaliacao_google() is
  'Concede 10 pts de Score de Performance a cada avaliação Google registrada (avaliacoes_google, sql/046) — sem trava de "primeira vez" porque quem registra é o admin a partir de uma avaliação real de cliente, não algo que o colaborador possa repetir sozinho.';

drop trigger if exists trg_award_points_on_avaliacao_google on public.avaliacoes_google;
create trigger trg_award_points_on_avaliacao_google
after insert on public.avaliacoes_google
for each row execute function public.fn_award_points_on_avaliacao_google();

revoke execute on function public.fn_award_points_on_avaliacao_google() from anon, authenticated;

-- Backfill: as ~65 avaliações já registradas nas migrações 059/060 (Morumbi
-- e Moema) foram inseridas antes deste trigger existir — sem isso ficariam
-- inconsistentes (avaliação real registrada, mas sem os pontos da regra
-- nova). source_id = avaliacoes_google.id garante que rodar de novo não
-- duplica (não existe linha nova pra essas avaliações antigas).
insert into public.points_ledger (user_id, source_type, source_id, points, reason)
select ag.profile_id, 'avaliacao_google', ag.id, 10, 'Avaliação Google recebida'
  from public.avaliacoes_google ag
 where not exists (
   select 1 from public.points_ledger pl
    where pl.source_type = 'avaliacao_google' and pl.source_id = ag.id
 );

-- ============================================================================
-- FIM DA MIGRAÇÃO 062
-- ============================================================================
