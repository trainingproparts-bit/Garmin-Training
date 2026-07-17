-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 007: dedupe + constraints únicas em
-- evaluations/evaluation_questions
-- ============================================================================
-- Bug real encontrado ao testar fetchEvaluationQuestions('explorer') contra
-- o Supabase de produção: quebrou com PGRST116 ("Cannot coerce the result
-- to a single JSON object"), sinal de mais de uma linha por type. Causa
-- raiz: sql/005_evaluations_and_notifications.sql nunca deu a evaluations
-- uma constraint UNIQUE, e sql/seeds/070_evaluations_mock.sql usava
-- "on conflict do nothing" sem apontar pra nenhuma — sem constraint pra
-- checar, o Postgres simplesmente insere de novo a cada re-execução do
-- seed. O mesmo valia (silenciosamente, sem erro visível ainda) pra
-- evaluation_questions.
--
-- Este arquivo: 1) remove as duplicatas mantendo a linha mais antiga de
-- cada type/pergunta, 2) adiciona as constraints que deveriam ter existido
-- desde o início. sql/seeds/070_evaluations_mock.sql foi atualizado para
-- apontar pra elas no "on conflict" — rodar de novo depois desta migração
-- é seguro.
--
-- Pré-requisito: sql/005_evaluations_and_notifications.sql já rodado.
-- ============================================================================

-- 1) Remove tentativas órfãs que ficariam presas em uma evaluations
--    duplicada prestes a ser apagada (FK de evaluation_attempts pra
--    evaluations não tem ON DELETE CASCADE de propósito — mas nesta
--    feature ainda não deveria existir tentativa real nenhuma).
delete from evaluation_attempts
where evaluation_id in (
  select id from evaluations
  where id not in (
    select distinct on (type) id
    from evaluations
    order by type, created_at asc, id asc
  )
);

-- 2) Remove as evaluations duplicadas, mantendo a mais antiga por type.
--    Cascata: evaluation_questions.evaluation_id tem ON DELETE CASCADE,
--    então as perguntas das duplicatas somem junto (o conteúdo é idêntico
--    ao da linha que fica, então nada de real se perde).
delete from evaluations
where id not in (
  select distinct on (type) id
  from evaluations
  order by type, created_at asc, id asc
);

-- 3) Remove evaluation_questions duplicadas dentro da mesma evaluation
--    (mesmo evaluation_id + order_index, caso o seed tenha rodado mais de
--    uma vez apontando pra mesma evaluations sobrevivente).
delete from evaluation_questions
where id not in (
  select distinct on (evaluation_id, order_index) id
  from evaluation_questions
  order by evaluation_id, order_index, id
);

-- 4) Constraints que faltavam — agora "on conflict" no seed tem o que checar.
alter table evaluations
  add constraint uq_evaluations_type unique (type);

alter table evaluation_questions
  add constraint uq_evaluation_questions_eval_order unique (evaluation_id, order_index);

-- ============================================================================
-- FIM DA MIGRAÇÃO 007
-- ============================================================================
