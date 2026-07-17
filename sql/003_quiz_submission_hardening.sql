-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 003: submissão de resposta de quiz (hardening)
-- ============================================================================
-- Problema estrutural encontrado na Sprint 1 (não previsto na modelagem original):
--
-- A policy `quiz_answers_insert_own` (garmin_training_hub_migrations.sql, seção 12.7)
-- só valida que o INSERT pertence à tentativa do próprio usuário — ela NÃO valida
-- o valor de `is_correct`. Como `alternatives.is_correct` é propositalmente
-- invisível ao Colaborador (policy alternatives_select_leader_admin, seção 12.6),
-- o cliente nunca teria como calcular esse valor sozinho de forma legítima — mas
-- também nada impede, hoje, um INSERT direto manual com `is_correct = true`
-- forjado, já que a RLS de INSERT não verifica a alternativa.
--
-- A documentação original já previa a correção via Edge Function
-- ("submit-quiz-answer" — modelagem-banco-dados-training-hub.md, seção 12), mas
-- nenhuma Edge Function foi criada até esta sprint. Em vez de deixar o envio de
-- quiz sem proteção nenhuma (ou reimplementar em Deno, fora do escopo desta
-- sprint de frontend), a correção equivalente e correta em SQL é:
--
--   1. Revogar INSERT direto em quiz_answers do papel "authenticated";
--   2. Expor apenas uma function SECURITY DEFINER que audita a alternativa
--      internamente (sem nunca devolver is_correct de outras alternativas) e
--      grava a resposta já com o valor correto.
--
-- Isso mantém o princípio "nunca confia em valor calculado no cliente" (mesmo
-- princípio 1 da modelagem) sem depender de infraestrutura de Edge Functions.
-- ============================================================================

revoke insert on quiz_answers from authenticated;

create or replace function fn_submit_quiz_answer(
  p_attempt_id     uuid,
  p_question_id    uuid,
  p_alternative_id uuid
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_owner_ok  boolean;
  v_is_correct boolean;
begin
  select exists (
    select 1 from quiz_attempts
     where id = p_attempt_id
       and user_id = auth.uid()
       and finished_at is null
  ) into v_owner_ok;

  if not v_owner_ok then
    raise exception 'tentativa % não pertence ao usuário autenticado ou já foi finalizada', p_attempt_id;
  end if;

  select is_correct into v_is_correct
    from alternatives
   where id = p_alternative_id
     and question_id = p_question_id;

  if not found then
    raise exception 'alternativa % não pertence à pergunta %', p_alternative_id, p_question_id;
  end if;

  insert into quiz_answers (attempt_id, question_id, alternative_id, is_correct)
  values (p_attempt_id, p_question_id, p_alternative_id, v_is_correct)
  on conflict (attempt_id, question_id)
  do update set alternative_id = excluded.alternative_id,
                is_correct     = excluded.is_correct,
                answered_at    = now();

  return v_is_correct;
end;
$$;

comment on function fn_submit_quiz_answer(uuid, uuid, uuid) is
  'Único caminho permitido para gravar quiz_answers — calcula is_correct no servidor e nunca expõe o gabarito de outras alternativas ao cliente.';

grant execute on function fn_submit_quiz_answer(uuid, uuid, uuid) to authenticated;
grant execute on function fn_finalize_quiz_attempt(uuid) to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 003
-- ============================================================================
