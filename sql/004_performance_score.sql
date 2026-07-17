-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 004: Score de Performance + ciclo fechado da lição
-- ============================================================================
-- Regra de negócio (decidida na Sprint 3): o sistema não usa a nomenclatura
-- "XP" (o público é vendedor de esporte/performance, faz mais sentido falar
-- em "Score de Performance"). A conta continua sendo a mesma: soma dos
-- lançamentos em points_ledger. O que muda é o rótulo exposto e a
-- adição de um campo materializado em profiles para leitura barata do
-- total, evitando um SUM() a cada renderização de sidebar.
--
-- Este arquivo cobre 3 coisas que a Sprint 3 pediu:
--   1. Coluna profiles.performance_score (cache do total, alimentado por
--      trigger — nunca escrito diretamente do cliente).
--   2. Extensão do CHECK de points_ledger.source_type para incluir 'lesson'
--      (antes só existia 'quiz', 'module', 'game', 'badge', 'certification',
--      'manual_adjustment'). Lição é granularidade mais fina que módulo.
--   3. Função RPC fn_complete_lesson(p_lesson_id) que fecha o loop:
--      grava lesson_progress + lança points_ledger + retorna o novo total.
--      SECURITY DEFINER porque a policy points_ledger_admin_insert impede
--      qualquer INSERT vindo do cliente (só admin pode, e o cliente não é).
--
-- Pré-requisito: garmin_training_hub_migrations.sql (schema base) já rodado.
-- ============================================================================

-- 1) Coluna cacheada de score no profile ------------------------------------
alter table profiles
  add column if not exists performance_score integer not null default 0;

comment on column profiles.performance_score is
  'Cache do Score de Performance total (SUM(points_ledger.points) para este user_id). Alimentado pela trigger trg_sync_performance_score — nunca escrito diretamente pelo cliente.';

-- Backfill: qualquer usuário que já tenha lançamentos em points_ledger
-- (do trigger fn_award_points_on_pass, por exemplo) recebe o total agora.
update profiles p
   set performance_score = coalesce(l.total, 0)
  from (
    select user_id, sum(points)::integer as total
      from points_ledger
     group by user_id
  ) l
 where l.user_id = p.id;

-- 2) Estender o CHECK de source_type para incluir 'lesson' ------------------
alter table points_ledger
  drop constraint if exists chk_points_ledger_source;
alter table points_ledger
  add constraint chk_points_ledger_source
  check (source_type in ('quiz','module','lesson','game','badge','certification','manual_adjustment'));

-- 3) Trigger que mantém profiles.performance_score em sincronia --------------
create or replace function fn_sync_performance_score()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
begin
  v_user_id := coalesce(new.user_id, old.user_id);
  update profiles
     set performance_score = coalesce(
       (select sum(points)::integer from points_ledger where user_id = v_user_id),
       0
     )
   where id = v_user_id;
  return coalesce(new, old);
end;
$$;

comment on function fn_sync_performance_score() is
  'Recalcula profiles.performance_score sempre que points_ledger muda para aquele usuário. Vale para lançamentos vindos de quiz aprovado (fn_award_points_on_pass), certificação, lição e ajustes manuais.';

drop trigger if exists trg_sync_performance_score on points_ledger;
create trigger trg_sync_performance_score
after insert or update or delete on points_ledger
for each row execute function fn_sync_performance_score();

-- 4) RPC de fechamento do ciclo da lição ------------------------------------
-- Grava a conclusão em lesson_progress, lança pontos em points_ledger (que
-- dispara a trigger acima e sincroniza profiles.performance_score) e devolve
-- ao cliente o novo total + quantos pontos foram concedidos nesta chamada.
-- Concessão de score é IDEMPOTENTE: se o usuário já concluiu a lição antes,
-- reset do timestamp acontece mas NÃO gera pontos duplicados (mesmo princípio
-- de fn_award_points_on_pass, RN 6.1 — sem XP repetido).

create or replace function fn_complete_lesson(p_lesson_id uuid, p_amount integer default 25)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id           uuid := auth.uid();
  v_already_completed boolean;
  v_points_awarded    integer := 0;
  v_new_total         integer;
begin
  if v_user_id is null then
    raise exception 'fn_complete_lesson exige usuário autenticado';
  end if;

  if not exists (select 1 from lessons where id = p_lesson_id) then
    raise exception 'lesson % não encontrada', p_lesson_id;
  end if;

  select (completed_at is not null)
    into v_already_completed
    from lesson_progress
   where user_id = v_user_id and lesson_id = p_lesson_id;

  v_already_completed := coalesce(v_already_completed, false);

  insert into lesson_progress (user_id, lesson_id, progress_pct, completed_at, updated_at)
  values (v_user_id, p_lesson_id, 100, now(), now())
  on conflict (user_id, lesson_id)
  do update set progress_pct = 100,
                completed_at = coalesce(lesson_progress.completed_at, now()),
                updated_at   = now();

  if not v_already_completed and p_amount > 0 then
    insert into points_ledger (user_id, source_type, source_id, points, reason)
    values (v_user_id, 'lesson', p_lesson_id, p_amount, 'Conclusão de lição');
    v_points_awarded := p_amount;
  end if;

  select performance_score into v_new_total from profiles where id = v_user_id;

  return jsonb_build_object(
    'performance_score', coalesce(v_new_total, 0),
    'points_awarded',    v_points_awarded,
    'already_completed', v_already_completed
  );
end;
$$;

comment on function fn_complete_lesson(uuid, integer) is
  'Ciclo fechado da conclusão de lição: grava lesson_progress, lança pontos em points_ledger (só na primeira vez) e devolve o novo total de performance_score para o cliente atualizar a UI.';

grant execute on function fn_complete_lesson(uuid, integer) to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 004
-- ============================================================================
