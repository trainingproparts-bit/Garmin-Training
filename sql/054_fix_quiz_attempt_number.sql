-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 054: quiz_attempts.attempt_number nunca era calculado
-- ============================================================================
-- Achado ao testar a correção de sql/053 (fn_grant_badge): rodei todos os 12
-- quizzes publicados com 100% de acerto e só o badge "Speed Run" foi
-- concedido — "Gabarito Garmin" nunca apareceu, mesmo com a marca resolvida
-- certinho agora. Causa: fn_grant_badge_on_quiz_100 exige
-- "new.attempt_number = 1", mas quiz_attempts.attempt_number nunca é
-- escrito em NENHUMA migração (confirmado via grep no repo inteiro) — a
-- coluna existe, é nullable, sem default, e fica sempre null. O próprio
-- comentário de quizService.js já prometia isso ("score_pct/passed/
-- attempt_number calculados no servidor"), mas fn_finalize_quiz_attempt
-- (sql/003→...→039) nunca de fato escreveu esse campo — provavelmente uma
-- coluna planejada e esquecida antes mesmo da engine de badges existir.
-- Efeito real: o badge Gabarito Garmin (aprovar com 100% na primeira
-- tentativa) nunca foi concedido a ninguém, pra nenhum quiz, desde sempre.
--
-- Correção: fn_finalize_quiz_attempt passa a calcular attempt_number como a
-- posição ordinal desta tentativa entre TODAS as tentativas (inclusive
-- abandonadas, não só finalizadas) do usuário pra este quiz, por started_at
-- — "primeira tentativa de verdade" inclui tentativas anteriores abandonadas,
-- não só as que chegaram ao fim (coerente com o espírito do badge: só conta
-- como "gabarito de primeira" se não houve nenhuma tentativa antes, nem
-- mesmo uma abandonada).
-- ============================================================================

create or replace function public.fn_finalize_quiz_attempt(p_attempt_id uuid)
returns public.quiz_attempts
language plpgsql
security definer
set search_path = public
as $$
declare
  v_attempt         public.quiz_attempts;
  v_total_answers   integer;
  v_correct_answers integer;
  v_passing_pct     numeric(5,2);
  v_score_pct       numeric(5,2);
  v_quiz            public.quizzes;
  v_previous_attempt public.quiz_attempts;
  v_badge_id        uuid;
  v_brand_id        uuid;
  v_time_seconds    numeric;
  v_attempt_number  integer;
begin
  select * into v_attempt
    from public.quiz_attempts
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
    from public.quiz_answers
   where attempt_id = p_attempt_id;

  v_score_pct := case when v_total_answers = 0 then 0
                       else round((v_correct_answers::numeric / v_total_answers::numeric) * 100, 2)
                  end;

  select q.id, q.passing_score_pct, q.brand_id into v_quiz.id, v_passing_pct, v_brand_id
    from public.quizzes q
    join public.checkpoints c on c.reference_id = q.id and c.checkpoint_type = 'quiz'
    join public.quiz_attempts qa on qa.quiz_id = q.id
   where qa.id = p_attempt_id;

  -- posição ordinal desta tentativa entre todas (mesmo abandonadas) do
  -- usuário pra este quiz — "attempt_number = 1" só é verdade se esta for,
  -- de fato, a primeira vez que ele tentou este quiz.
  select count(*) into v_attempt_number
    from public.quiz_attempts
   where user_id = v_attempt.user_id
     and quiz_id = v_attempt.quiz_id
     and started_at <= v_attempt.started_at;

  update public.quiz_attempts
     set finished_at    = now(),
         score_pct      = v_score_pct,
         passed         = (v_score_pct >= coalesce(v_passing_pct, 70)),
         attempt_number = v_attempt_number
   where id = p_attempt_id
   returning * into v_attempt;

  -- ============================================================================
  -- BADGE: Speed Run (quiz completo em <60s com aprovação mínima 80%)
  -- ============================================================================
  v_time_seconds := extract(epoch from (v_attempt.finished_at - v_attempt.started_at));

  if v_attempt.passed and v_score_pct >= 80 and v_time_seconds < 60 then
    select id into v_badge_id
      from public.badges
     where brand_id = v_brand_id
       and slug = 'speed-run-' || (select slug from public.brands where id = v_brand_id);

    if v_badge_id is not null then
      insert into public.user_badges (user_id, badge_id, earned_at)
      values (v_attempt.user_id, v_badge_id, now())
      on conflict (user_id, badge_id) do nothing;
    end if;
  end if;

  -- ============================================================================
  -- BADGE: Inabalável (reprova, refaz em <24h com 100%)
  -- ============================================================================
  select * into v_previous_attempt
    from public.quiz_attempts
   where quiz_id = v_attempt.quiz_id
     and user_id = v_attempt.user_id
     and id != v_attempt.id
     and finished_at is not null
     and passed = false
   order by finished_at desc
   limit 1;

  if v_previous_attempt.id is not null then
    if v_attempt.score_pct = 100 and
       extract(epoch from (v_attempt.started_at - v_previous_attempt.finished_at)) < 86400 then -- 24h em segundos
      select id into v_badge_id
        from public.badges
       where brand_id = v_brand_id
         and slug = 'inabalavel-' || (select slug from public.brands where id = v_brand_id);

      if v_badge_id is not null then
        insert into public.user_badges (user_id, badge_id, earned_at)
        values (v_attempt.user_id, v_badge_id, now())
        on conflict (user_id, badge_id) do nothing;
      end if;
    end if;
  end if;

  return v_attempt;
end;
$$;

comment on function public.fn_finalize_quiz_attempt(uuid) is
  'Fecha a tentativa de quiz, calcula nota/aprovação/attempt_number e concede badges Speed Run (<60s com 80%+) e Inabalável (reprova, refaz em <24h com 100%). attempt_number = posição ordinal entre todas as tentativas (mesmo abandonadas) do usuário pra este quiz — corrigido em sql/054, nunca tinha sido escrito antes (coluna sempre null, bloqueava o badge Gabarito Garmin pra sempre). SECURITY DEFINER.';

-- ============================================================================
-- FIM DA MIGRAÇÃO 054
-- ============================================================================
