-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 177: revisão dos erros ao final do quiz
-- ============================================================================
-- Pedido do usuário (2026-10-09): na tela de resultado do quiz, o
-- colaborador só via a nota. Agora ele vê as perguntas que errou, a
-- alternativa que marcou e a alternativa correta.
--
-- O colaborador não lê alternatives.is_correct direto (RLS
-- alternatives_select_leader_admin, ver sql/003). Por isso o gabarito vem
-- desta função SECURITY DEFINER, com as mesmas travas das outras funções do
-- quiz:
--   - a tentativa precisa ser do usuário autenticado (auth.uid());
--   - a tentativa precisa estar FINALIZADA (finished_at não nulo), então o
--     gabarito nunca aparece no meio de uma tentativa em andamento.
-- Durante o quiz a pessoa já recebe "certa/errada" e a explicação de cada
-- pergunta (sql/039); esta função só junta isso numa revisão no fim.
-- ============================================================================

create or replace function public.fn_quiz_attempt_review(p_attempt_id uuid)
returns table (
  question_id    uuid,
  question_body  text,
  order_index    integer,
  is_correct     boolean,
  chosen_body    text,
  correct_body   text,
  explanation    text
)
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  if not exists (
    select 1 from quiz_attempts
     where id = p_attempt_id
       and user_id = auth.uid()
       and finished_at is not null
  ) then
    raise exception 'tentativa % não pertence ao usuário autenticado ou ainda não foi finalizada', p_attempt_id;
  end if;

  return query
  select q.id,
         q.body,
         q.order_index,
         qa.is_correct,
         chosen.body,
         (select a.body from alternatives a
           where a.question_id = q.id and a.is_correct
           order by a.order_index limit 1),
         q.explanation
    from quiz_answers qa
    join questions q on q.id = qa.question_id
    join alternatives chosen on chosen.id = qa.alternative_id
   where qa.attempt_id = p_attempt_id
   order by q.order_index;
end;
$function$;

comment on function public.fn_quiz_attempt_review(uuid) is
  'Revisão de uma tentativa FINALIZADA do próprio usuário: pergunta, alternativa marcada, alternativa correta e explicação. Usada na tela de resultado do QuizRunner.';

revoke all on function public.fn_quiz_attempt_review(uuid) from public, anon;
grant execute on function public.fn_quiz_attempt_review(uuid) to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 177
-- ============================================================================
