-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 061: baseline "já concluído até o módulo 3"
-- (Corredor — Garmin Coach) pra toda a equipe, porque fizeram o treinamento
-- em outra plataforma antes de migrar pra cá.
-- ============================================================================
-- Confirmado com o usuário: (1) aplica pros 14 perfis (incluindo as contas
-- sem loja Samara/Mariana/Salomão); (2) inclui também os quizzes extras do
-- Circuito de Desafios e os Duelos, não só os checkpoints obrigatórios.
--
-- Estratégia: a conta da Samara já está EXATAMENTE no estado desejado (12
-- checkpoints completos = Zona Explorador inteira + Garmin Connect/Garmin
-- Coach da Zona Atleta, certificações Explorador+Corredor emitidas, 6
-- badges, 11 quizzes com respostas reais, 2 duelos concluídos) — resultado
-- da verificação ao vivo feita nesta sessão. Em vez de recalcular manualmente
-- toda a cadeia de badge/certificação, replico literalmente as linhas dela
-- (user_progress + quiz_attempts + quiz_answers + game_sessions) pros outros
-- 13 perfis e deixo os triggers já existentes (fn_issue_certification,
-- fn_grant_badge_on_certification, fn_grant_badge_on_quiz_100,
-- fn_check_badge_rules) recalcularem certificações/badges igual fizeram pra
-- ela — garante consistência com a lógica real do app em vez de eu tentar
-- adivinhar regra por regra.
--
-- BUG ENCONTRADO E CORRIGIDO: os 8 checkpoints "aspiracionais" adicionados
-- à Zona Atleta em sql/055 (Métricas Essenciais, Edge, Potência, Preço)
-- nasceram com is_required=true por padrão. Isso quebra silenciosamente
-- fn_issue_certification pra QUALQUER usuário novo dali em diante — a
-- certificação Corredor exige TODOS os checkpoints obrigatórios da zona, e
-- com 12 obrigatórios em vez de 4, ela nunca mais seria emitida automaticamente
-- só com Garmin Connect + Garmin Coach (que é exatamente o que a própria
-- criteria.note da certificação Corredor já documentava como sendo o
-- requisito real, o resto é aspiracional). Corrigido aqui: só os 4
-- checkpoints originais continuam is_required=true.
--
-- Dados de teste limpos: Daniel Lucena tinha 3 tentativas duplicadas do
-- quiz do Módulo 1 (todas em ~2min, claramente teste) + 1 badge decorrente;
-- a própria Samara tinha 2 sessões de duelo abandonadas (finished_at null).
-- ============================================================================

do $$
declare
  v_source_user uuid := 'cda848a9-cbe0-44d7-9d24-4c41ee68854a'; -- Samara Pereira (referência já verificada)
  v_target_users uuid[] := array[
    '9244ad95-870f-4502-a216-17ff1dd7514b', -- Beatriz (Moema)
    '236d1e5a-abf5-47d1-9163-18b171ab191b', -- Dayane Sousa (Moema)
    'f5649522-ee8b-4b9b-8347-568cf9d521d3', -- Ribli Silva (Moema)
    '3bcff82d-ad19-4152-9c03-fb21a28a2afd', -- William (Moema)
    'b66e7a9c-b551-4263-a601-2195b1a9ed7c', -- Ailma Almeida (Morumbi)
    '4c2a3fd8-cff0-441c-af4f-19ae5c003a8b', -- Daniel Lucena (Morumbi)
    'cd736e18-06ab-4ac2-8cb6-f4704d09c1da', -- Fabio Borges (Morumbi)
    'e60cc6bc-5bb3-4561-8fb5-0be2f3dd3202', -- Gustavo Morais (Morumbi)
    '390a153c-1253-441a-841c-3aaff7bdb3d5', -- Joyce Souza (Morumbi)
    '9d77da37-2b6c-4b0f-a2b5-2c11129d68dd', -- Mayara Freire (Morumbi)
    '8262d1ec-7383-4380-8dbf-ed3dc44becbb', -- Renato Dias (Morumbi)
    '6ae99023-4f5e-4d30-9076-f801e2194a3a', -- Mariana Muzzio (admin)
    '94d2dbc5-d942-4e39-9a13-8b958ff5dbdd'  -- Salomão Setton (admin)
  ];
  v_target uuid;
  v_source_attempt record;
  v_new_attempt_id uuid;
begin
  -- 1) Bug fix: só os 4 checkpoints originais da Zona Atleta são obrigatórios
  --    pra certificação Corredor — o resto (adicionado em sql/055) é aspiracional.
  update public.checkpoints
     set is_required = false
   where zone_id = '7ded46e1-864c-4122-be37-bf99f0385683'
     and reference_id not in (
       '478e1177-c66a-4f19-adfc-e5e7ed9a605c', -- módulo Garmin Connect
       '6fceb4b1-c342-4a07-9dff-51a77abf6d27', -- quiz Corredor — Garmin Connect
       '8efdbd42-8c93-4fc4-869c-f1a326fce1b8', -- módulo Garmin Coach
       '0048a818-d7f3-4766-8196-8e9e948f734a'  -- quiz Corredor — Garmin Coach
     );

  -- 2) Limpeza de dados de teste/aleatórios
  delete from public.quiz_answers
   where attempt_id in (select id from public.quiz_attempts where user_id = '4c2a3fd8-cff0-441c-af4f-19ae5c003a8b');
  delete from public.quiz_attempts where user_id = '4c2a3fd8-cff0-441c-af4f-19ae5c003a8b';
  delete from public.user_badges where user_id = '4c2a3fd8-cff0-441c-af4f-19ae5c003a8b';
  delete from public.game_sessions where user_id = v_source_user and finished_at is null;

  -- 3) Suprime o post automático no Mural de Atividades pra esse backfill em
  --    lote (são ~100+ eventos que já "aconteceram" em outra plataforma, não
  --    aconteceram agora — não deve aparecer como novidade "1 min atrás").
  alter table public.user_badges disable trigger trg_post_activity_badge_earned;
  alter table public.user_certifications disable trigger trg_post_activity_certification_issued;

  foreach v_target in array v_target_users loop

    -- 12 checkpoints completos (Zona Explorador inteira + Garmin Connect/Coach)
    insert into public.user_progress (user_id, checkpoint_id, status, completed_at, updated_at)
    select v_target, t.checkpoint_id, 'completed', t.completed_at, t.completed_at
      from (values
        ('cc611f99-652a-4ba1-92c8-7b83d2331f61'::uuid, '2026-07-15 20:22:24.592328+00'::timestamptz),
        ('677d7744-8492-4bb7-83e7-9d3c6fda0ace'::uuid, '2026-07-16 05:14:39.580068+00'::timestamptz),
        ('a539e7a8-02ae-4994-ba05-1474b465f08f'::uuid, '2026-07-16 14:25:31.254546+00'::timestamptz),
        ('5d724828-2333-4b28-b823-5fde3f6527bb'::uuid, '2026-07-16 14:28:54.664381+00'::timestamptz),
        ('bf2785d1-b427-4793-a74a-4d0be6bccaa2'::uuid, '2026-07-16 14:30:24.694827+00'::timestamptz),
        ('58b66cc3-7b52-4903-a8d3-3328ab37b945'::uuid, '2026-07-16 14:31:06.6597+00'::timestamptz),
        ('9f202d66-b180-4d9b-874a-db5f085122d3'::uuid, '2026-07-16 14:32:17.633966+00'::timestamptz),
        ('981823a8-6f32-4cd4-be0a-098fc031f1f1'::uuid, '2026-07-16 14:33:03.689123+00'::timestamptz),
        ('8c308893-aa44-43a0-b681-495bb244a05e'::uuid, '2026-07-16 14:33:59.662634+00'::timestamptz),
        ('292a7ac2-1d2f-480d-9fdc-bb5361469313'::uuid, '2026-07-16 14:35:43.654657+00'::timestamptz),
        ('25cc1a65-55cb-493c-931d-b051a0942e68'::uuid, '2026-07-16 14:36:22.673534+00'::timestamptz),
        ('369de921-0583-4e1c-bceb-81d2af6aa30b'::uuid, '2026-07-16 14:37:22.672094+00'::timestamptz)
      ) as t(checkpoint_id, completed_at)
    on conflict (user_id, checkpoint_id) do nothing;

    -- 11 quiz_attempts (6 dos módulos reais + 5 do Circuito de Desafios) com
    -- as respostas reais copiadas pergunta a pergunta (remapeando o attempt_id)
    for v_source_attempt in
      select id, quiz_id, started_at, finished_at, score_pct, passed
        from public.quiz_attempts
       where user_id = v_source_user
         and id in (
           '7037aa22-f3fa-4b87-843c-b748d5acc2e7','0d00e555-a769-41f1-b84c-bbf48b26ed3c',
           'de836187-fc55-4ab4-89c6-96c9426df38d','9dac8e52-1cd4-4172-9319-c7dac5f42c98',
           'fd13e43e-ecf6-42d7-85a3-335cf9c7e88e','7b827987-60dd-4c6a-95d3-ee3bad3e70e3',
           'b0818e25-0225-4b68-83ea-26995c8a5b8b','f1079fb7-0b20-4799-9259-66d0a3d488c0',
           '7e2f45dc-45fe-443f-b542-527baa9bab7e','7f58a9e8-0bff-411f-bbf6-63e516c431f9',
           '878d8c1e-2935-4367-8592-a2072fa8ada9'
         )
    loop
      v_new_attempt_id := gen_random_uuid();

      insert into public.quiz_attempts (id, user_id, quiz_id, started_at, finished_at, score_pct, passed, attempt_number)
      values (v_new_attempt_id, v_target, v_source_attempt.quiz_id, v_source_attempt.started_at,
              v_source_attempt.finished_at, v_source_attempt.score_pct, v_source_attempt.passed, 1);

      insert into public.quiz_answers (attempt_id, question_id, alternative_id, is_correct, answered_at)
      select v_new_attempt_id, qa.question_id, qa.alternative_id, qa.is_correct, qa.answered_at
        from public.quiz_answers qa
       where qa.attempt_id = v_source_attempt.id;
    end loop;

    -- 2 duelos concluídos (Circuito de Desafios)
    insert into public.game_sessions (user_id, game_id, started_at, finished_at, rounds_played, result_summary)
    select v_target, gs.game_id, gs.started_at, gs.finished_at, gs.rounds_played, gs.result_summary
      from public.game_sessions gs
     where gs.user_id = v_source_user and gs.finished_at is not null;

  end loop;

  alter table public.user_badges enable trigger trg_post_activity_badge_earned;
  alter table public.user_certifications enable trigger trg_post_activity_certification_issued;
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 061
-- ============================================================================
