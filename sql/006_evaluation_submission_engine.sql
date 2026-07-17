-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 006: motor de submissão/correção da
-- Avaliação Trimestral
-- ============================================================================
-- Fecha a lacuna deixada de propósito em sql/005_evaluations_and_notifications.sql:
-- a trava de 24h estava implementada (fn_check_evaluation_lock) mas nada
-- criava uma tentativa reprovada de verdade, porque não existia motor de
-- resposta/correção. Este arquivo espelha exatamente o padrão já usado e
-- testado em quiz_answers/fn_submit_quiz_answer/fn_finalize_quiz_attempt
-- (sql/003_quiz_submission_hardening.sql) — mesmo princípio: a correção
-- nunca acontece no cliente.
--
-- Pré-requisito: sql/005_evaluations_and_notifications.sql já rodado.
-- ============================================================================

create table if not exists evaluation_answers (
  id              uuid primary key default gen_random_uuid(),
  attempt_id      uuid not null references evaluation_attempts(id) on delete cascade,
  question_id     uuid not null references evaluation_questions(id),
  selected_option integer not null,
  is_correct      boolean not null,
  answered_at     timestamptz not null default now(),
  constraint uq_evaluation_answers_attempt_question unique (attempt_id, question_id)
);
create index if not exists idx_evaluation_answers_question on evaluation_answers(question_id);
create index if not exists idx_evaluation_answers_attempt  on evaluation_answers(attempt_id);
comment on table evaluation_answers is 'Resposta congelada por tentativa — is_correct sempre calculado no servidor via fn_submit_evaluation_answer.';


-- ============================================================================
-- 1) fn_start_evaluation_attempt — cria (ou retoma) uma tentativa,
--    respeitando a trava de 24h/liberação do líder.
-- ============================================================================
create or replace function fn_start_evaluation_attempt(p_evaluation_id uuid)
returns evaluation_attempts
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id  uuid := auth.uid();
  v_lock     jsonb;
  v_existing evaluation_attempts;
  v_new      evaluation_attempts;
begin
  if v_user_id is null then
    raise exception 'fn_start_evaluation_attempt exige usuário autenticado';
  end if;

  -- tentativa em andamento (não finalizada) — retoma em vez de duplicar
  select * into v_existing
    from evaluation_attempts
   where user_id = v_user_id
     and evaluation_id = p_evaluation_id
     and finished_at is null
   order by started_at desc
   limit 1;

  if found then
    return v_existing;
  end if;

  v_lock := fn_check_evaluation_lock(p_evaluation_id);
  if (v_lock->>'locked')::boolean then
    raise exception 'avaliação bloqueada até % — reprovação recente ainda em cooldown de 24h', v_lock->>'locked_until';
  end if;

  insert into evaluation_attempts (user_id, evaluation_id)
  values (v_user_id, p_evaluation_id)
  returning * into v_new;

  return v_new;
end;
$$;

comment on function fn_start_evaluation_attempt(uuid) is
  'Único caminho para criar uma evaluation_attempts — aplica a trava de 24h antes de permitir nova tentativa.';

grant execute on function fn_start_evaluation_attempt(uuid) to authenticated;


-- ============================================================================
-- 2) fn_submit_evaluation_answer — grava resposta com correção no servidor
-- ============================================================================
create or replace function fn_submit_evaluation_answer(
  p_attempt_id  uuid,
  p_question_id uuid,
  p_selected_option integer
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_owner_ok   boolean;
  v_correct    integer;
  v_is_correct boolean;
begin
  select exists (
    select 1 from evaluation_attempts
     where id = p_attempt_id
       and user_id = auth.uid()
       and finished_at is null
  ) into v_owner_ok;

  if not v_owner_ok then
    raise exception 'tentativa % não pertence ao usuário autenticado ou já foi finalizada', p_attempt_id;
  end if;

  select eq.correct_option into v_correct
    from evaluation_questions eq
    join evaluation_attempts ea on ea.evaluation_id = eq.evaluation_id
   where eq.id = p_question_id
     and ea.id = p_attempt_id;

  if not found then
    raise exception 'pergunta % não pertence à avaliação da tentativa %', p_question_id, p_attempt_id;
  end if;

  v_is_correct := (v_correct = p_selected_option);

  insert into evaluation_answers (attempt_id, question_id, selected_option, is_correct)
  values (p_attempt_id, p_question_id, p_selected_option, v_is_correct)
  on conflict (attempt_id, question_id)
  do update set selected_option = excluded.selected_option,
                is_correct      = excluded.is_correct,
                answered_at     = now();

  return v_is_correct;
end;
$$;

comment on function fn_submit_evaluation_answer(uuid, uuid, integer) is
  'Único caminho permitido para gravar evaluation_answers — calcula is_correct no servidor, nunca confia no cliente.';

grant execute on function fn_submit_evaluation_answer(uuid, uuid, integer) to authenticated;


-- ============================================================================
-- 3) fn_finish_evaluation_attempt — fecha a tentativa, calcula score/passed
-- ============================================================================
create or replace function fn_finish_evaluation_attempt(p_attempt_id uuid)
returns evaluation_attempts
language plpgsql
security definer
set search_path = public
as $$
declare
  v_attempt         evaluation_attempts;
  v_total_answers   integer;
  v_correct_answers integer;
  v_passing_pct     numeric(5,2);
  v_score_pct       numeric(5,2);
begin
  select * into v_attempt
    from evaluation_attempts
   where id = p_attempt_id
     and user_id = auth.uid();

  if not found then
    raise exception 'tentativa % não encontrada para o usuário autenticado', p_attempt_id;
  end if;

  if v_attempt.finished_at is not null then
    return v_attempt; -- já finalizada, idempotente
  end if;

  select count(*), count(*) filter (where is_correct)
    into v_total_answers, v_correct_answers
    from evaluation_answers
   where attempt_id = p_attempt_id;

  v_score_pct := case when v_total_answers = 0 then 0
                       else round((v_correct_answers::numeric / v_total_answers::numeric) * 100, 2)
                  end;

  select passing_score_pct into v_passing_pct
    from evaluations
   where id = v_attempt.evaluation_id;

  update evaluation_attempts
     set finished_at = now(),
         score_pct   = v_score_pct,
         passed      = (v_score_pct >= coalesce(v_passing_pct, 70))
   where id = p_attempt_id
  returning * into v_attempt;

  return v_attempt;
end;
$$;

comment on function fn_finish_evaluation_attempt(uuid) is
  'Fecha a tentativa e calcula nota/aprovação no servidor — mesma lógica de fn_finalize_quiz_attempt.';

grant execute on function fn_finish_evaluation_attempt(uuid) to authenticated;


-- ============================================================================
-- 4) RLS de evaluation_answers
-- ============================================================================
alter table evaluation_answers enable row level security;

create policy evaluation_answers_select_own on evaluation_answers
  for select using (
    exists (select 1 from evaluation_attempts ea where ea.id = evaluation_answers.attempt_id and ea.user_id = auth.uid())
  );
create policy evaluation_answers_select_leader on evaluation_answers
  for select using (
    fn_is_leader() and exists (
      select 1 from evaluation_attempts ea
      join profiles p on p.id = ea.user_id
      where ea.id = evaluation_answers.attempt_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy evaluation_answers_admin_all on evaluation_answers
  for all using (fn_is_admin()) with check (fn_is_admin());

-- Mesma regra de evaluation_attempts: só as três funções acima gravam.
revoke insert, update on evaluation_answers from authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 006
-- ============================================================================
