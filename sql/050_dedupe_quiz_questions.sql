-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 050: dedupe de perguntas de quiz
-- ============================================================================
-- Bug real reportado pelo usuário: "as perguntas do quiz estavam duplicadas
-- e não salvaram no final" (testado no quiz do Módulo 1 — Universo Garmin).
-- Investigação confirmou algo bem maior: TODAS as perguntas de TODOS os
-- quizzes do sistema estão duplicadas 2x (mesmo quiz_id + mesmo texto, ids
-- diferentes) — sql/questions nunca teve constraint de unicidade, e algum
-- seed/migração rodou o INSERT duas vezes em algum momento. fetchQuizForAttempt
-- (quizService.js) busca todas as perguntas is_active da quiz sem dedupe
-- nenhum, então o QuizRunner sempre mostrou o dobro de perguntas reais.
--
-- Isso quebrou de verdade 3 tentativas (todas da Samara, todas nunca
-- finalizadas — ninguém mais chegou a responder as 2 cópias de tudo):
--   30bf12d0-ea3e-42f7-b244-133605877e5d (Módulo 1 — Universo Garmin, 20/20 respondidas)
--   af30f458-747f-4161-b91b-fd897ed20d41 (outro quiz, 20/20 respondidas)
--   6309d9b2-4b0f-4ad0-a926-3ae3ec736aa5 (outro quiz, 2 respostas, abandonada)
-- Nenhuma tem finished_at — são tentativas de teste quebradas pelo bug, não
-- dado real de avaliação de ninguém. Removidas antes do dedupe pra não
-- violar a FK de quiz_answers.question_id (NO ACTION, não cascade).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Remove as tentativas quebradas pelo bug (cascade já limpa quiz_answers)
-- ----------------------------------------------------------------------------
delete from public.quiz_attempts
where id in (
  '30bf12d0-ea3e-42f7-b244-133605877e5d',
  'af30f458-747f-4161-b91b-fd897ed20d41',
  '6309d9b2-4b0f-4ad0-a926-3ae3ec736aa5'
);

-- ----------------------------------------------------------------------------
-- 2. Remove a cópia duplicada de cada pergunta (mantém a de menor id;
--    alternatives cai junto via CASCADE). Confirmado antes de aplicar: com
--    o passo 1 feito, nenhum quiz_answers real referencia as cópias que
--    serão removidas aqui.
-- ----------------------------------------------------------------------------
with duplicatas as (
  select id,
    row_number() over (partition by quiz_id, body order by id) as posicao
  from public.questions
)
delete from public.questions
where id in (select id from duplicatas where posicao > 1);

-- ----------------------------------------------------------------------------
-- 3. Trava pra não repetir — order_index já era pra ser único dentro do
--    quiz (é a posição da pergunta), nunca teve constraint garantindo isso.
-- ----------------------------------------------------------------------------
alter table public.questions
  drop constraint if exists uq_questions_quiz_order;
alter table public.questions
  add constraint uq_questions_quiz_order unique (quiz_id, order_index);

-- ============================================================================
-- FIM DA MIGRAÇÃO 050
-- ============================================================================
