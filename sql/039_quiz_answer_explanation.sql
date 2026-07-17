-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 039: explicação da resposta no feedback do quiz
-- ============================================================================
-- Bug real reportado pelo usuário: "antes aparecia um feedback com frase de
-- explicação" nos quizzes (inclusive os "Quiz Especial" do Circuito de
-- Desafios) — e de fato `questions.explanation` já existe no schema base,
-- com conteúdo real cadastrado (confirmado por query direta), mas nunca foi
-- selecionado por `quizService.fetchQuizForAttempt` nem renderizado por
-- `QuizRunner.js`. Não é uma regressão desta sessão — o campo nunca foi
-- ligado no app Vite (única entrada no git log de QuizRunner.js é o commit
-- inicial do Sprint 1).
--
-- Risco de segurança considerado: buscar `explanation` de TODAS as perguntas
-- já no carregamento inicial do quiz (como já é feito com `body`) revelaria
-- a resposta certa de perguntas futuras antes de o usuário responder —
-- quebra o mesmo princípio que já protege `alternatives.is_correct` (nunca
-- trafega antes da resposta, v_alternatives_public / fn_submit_quiz_answer).
-- Corrigido servindo a explicação a partir do SERVIDOR, no mesmo RPC que já
-- calcula se a resposta está certa — nunca antes de responder aquela
-- pergunta especificamente, e sem round-trip extra.
-- ============================================================================

-- Precisa dropar antes: mudar de `RETURNS boolean` para parâmetros OUT
-- (composite record) é uma mudança de tipo de retorno, que `CREATE OR
-- REPLACE FUNCTION` não permite fazer in-place.
drop function if exists public.fn_submit_quiz_answer(uuid, uuid, uuid);

create or replace function public.fn_submit_quiz_answer(
  p_attempt_id uuid,
  p_question_id uuid,
  p_alternative_id uuid,
  out is_correct boolean,
  out explanation text
)
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_owner_ok boolean;
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

  select a.is_correct into is_correct
    from alternatives a
   where a.id = p_alternative_id
     and a.question_id = p_question_id;

  if not found then
    raise exception 'alternativa % não pertence à pergunta %', p_alternative_id, p_question_id;
  end if;

  insert into quiz_answers (attempt_id, question_id, alternative_id, is_correct)
  values (p_attempt_id, p_question_id, p_alternative_id, is_correct)
  on conflict (attempt_id, question_id)
  do update set alternative_id = excluded.alternative_id,
                is_correct     = excluded.is_correct,
                answered_at    = now();

  select q.explanation into explanation
    from questions q
   where q.id = p_question_id;

  return;
end;
$function$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 039
-- ============================================================================
