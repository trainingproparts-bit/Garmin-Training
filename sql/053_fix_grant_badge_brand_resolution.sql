-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 053: fn_grant_badge nunca concedia nada
-- ============================================================================
-- Achado ao investigar o crash corrigido em sql/052: fn_grant_badge
-- resolvia a marca do badge lendo profiles.brand_id — mas essa coluna é
-- SEMPRE null pra colaboradores normais (marca é escolhida client-side por
-- sessão, nunca persiste no perfil). Diferente do bug de 052 (que
-- derrubava a transação inteira), este aqui é silencioso: a função só dá
-- "return" cedo sem conceder nada, sem erro nenhum. Resultado real: TODOS
-- os badges concedidos via fn_grant_badge nunca foram entregues a nenhum
-- colaborador — Gabarito Garmin (quiz 100%), Ritmo Constante (streak de 5
-- dias), Explorer/Runner/Triathlete (certificação de zona).
--
-- Correção: fn_grant_badge passa a aceitar p_brand_id explícito (cada
-- chamador já tem essa informação de sobra no próprio evento — quiz, game,
-- lição ou certificação sempre sabem sua marca; só o perfil do usuário não
-- sabe). profiles.brand_id vira só um fallback legado, pro caso hipotético
-- de algum dia ser populado. Os 3 chamadores de fn_grant_badge e os 4
-- chamadores de fn_touch_streak (que concede o badge Ritmo Constante) foram
-- atualizados pra passar a marca correta:
--   - fn_grant_badge_on_quiz_100      → quizzes.brand_id (via new.quiz_id)
--   - fn_grant_badge_on_certification → certifications.brand_id (via new.certification_id)
--   - fn_touch_streak_on_quiz         → quizzes.brand_id
--   - fn_touch_streak_on_game         → games.brand_id
--   - fn_touch_streak_on_lesson       → trails.brand_id (via lessons→modules→zones→trails)
--   - fn_touch_streak_on_evaluation   → sem marca própria (avaliação trimestral
--     não é escopada por marca, tabela evaluations não tem brand_id) — continua
--     passando null (fn_touch_streak aceita e já lida com isso, mesmo padrão
--     de fn_post_activity_badge_earned pra streak_milestone). Se o 5º dia do
--     streak cair justo numa avaliação (sem nenhum quiz/game/lição no mesmo
--     dia), o badge Ritmo Constante daquele marco específico não é concedido —
--     limitação aceita, documentada, e rara (qualquer outro evento do mesmo
--     dia teria resolvido a marca normalmente).
-- ============================================================================

-- Precisa dropar as assinaturas antigas antes de recriar com o parâmetro
-- novo — "create or replace" não troca a assinatura de uma função (arity
-- diferente = função distinta no Postgres); sem o drop, a versão velha de
-- 2 args ficaria coexistindo, e fn_touch_streak(uuid) coexistindo com
-- fn_touch_streak(uuid, uuid default null) geraria erro de "function is
-- not unique" pra qualquer chamada de 1 argumento só (ex.: fn_touch_streak_on_evaluation).
drop function if exists public.fn_grant_badge(uuid, text);
drop function if exists public.fn_touch_streak(uuid);

create or replace function public.fn_grant_badge(p_user_id uuid, p_badge_key text, p_brand_id uuid default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_brand_id uuid;
  v_badge_id uuid;
begin
  v_brand_id := p_brand_id;

  -- fallback legado: só entra aqui se ninguém passou p_brand_id explícito.
  if v_brand_id is null then
    select brand_id into v_brand_id from profiles where id = p_user_id;
  end if;

  if v_brand_id is null then
    return;
  end if;

  select b.id into v_badge_id
    from badges b
    join brands br on br.id = b.brand_id
   where b.brand_id = v_brand_id
     and b.slug = p_badge_key || '-' || br.slug;

  if v_badge_id is null then
    return;
  end if;

  insert into user_badges (user_id, badge_id)
  values (p_user_id, v_badge_id)
  on conflict (user_id, badge_id) do nothing;
end;
$$;

comment on function public.fn_grant_badge(uuid, text, uuid) is
  'Concede um badge (slug = p_badge_key || "-" || brand.slug). Recebe p_brand_id explícito do chamador (quiz/game/lição/certificação sempre sabem sua marca) — profiles.brand_id é só fallback legado, pois é null pra colaboradores normais (sql/053, corrige fn_grant_badge que nunca concedia nada de verdade).';

create or replace function public.fn_grant_badge_on_quiz_100()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_brand_id uuid;
begin
  if new.finished_at is not null and new.score_pct = 100 and new.attempt_number = 1 then
    select brand_id into v_brand_id from quizzes where id = new.quiz_id;
    perform fn_grant_badge(new.user_id, 'gabarito-garmin', v_brand_id);
  end if;

  return new;
end;
$$;

create or replace function public.fn_grant_badge_on_certification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cert_slug   text;
  v_badge_key   text;
  v_real_certs  integer;
  v_brand_id    uuid;
begin
  select slug, brand_id into v_cert_slug, v_brand_id from certifications where id = new.certification_id;

  v_badge_key := case v_cert_slug
    when 'explorador' then 'explorer'
    when 'corredor'   then 'runner'
    else null
  end;

  if v_badge_key is not null then
    perform fn_grant_badge(new.user_id, v_badge_key, v_brand_id);
  end if;

  -- Triathlete = trilha real inteira concluída (hoje, Explorador + Corredor —
  -- Maratonista/Triatleta não têm zona/conteúdo próprio ainda, sql/017).
  if v_cert_slug in ('explorador', 'corredor') then
    select count(*) into v_real_certs
      from user_certifications uc
      join certifications c on c.id = uc.certification_id
     where uc.user_id = new.user_id
       and c.slug in ('explorador', 'corredor')
       and uc.revoked_at is null;

    if v_real_certs = 2 then
      perform fn_grant_badge(new.user_id, 'triathlete', v_brand_id);
    end if;
  end if;

  return new;
end;
$$;

create or replace function public.fn_touch_streak(p_user_id uuid, p_brand_id uuid default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row           public.streaks;
  v_today         date := current_date;
  v_dow           integer := extract(dow from current_date)::integer;
  v_expected_prev date;
  v_profile       record;
begin
  if p_user_id is null then
    return;
  end if;

  select * into v_row from public.streaks where user_id = p_user_id for update;

  if not found then
    insert into public.streaks (user_id, current_streak_days, longest_streak_days, last_activity_date, updated_at)
    values (p_user_id, 1, 1, v_today, now());
    return;
  end if;

  if v_row.last_activity_date = v_today then
    return;
  end if;

  v_expected_prev := case
    when v_dow = 1 then v_today - 3
    when v_dow = 0 then v_today - 2
    when v_dow = 6 then v_today - 1
    else v_today - 1
  end;

  if v_row.last_activity_date >= v_expected_prev then
    v_row.current_streak_days := v_row.current_streak_days + 1;
  else
    v_row.current_streak_days := 1;
  end if;

  v_row.longest_streak_days := greatest(v_row.longest_streak_days, v_row.current_streak_days);

  update public.streaks
     set current_streak_days = v_row.current_streak_days,
         longest_streak_days = v_row.longest_streak_days,
         last_activity_date  = v_today,
         updated_at          = now()
   where user_id = p_user_id;

  if v_row.current_streak_days % 5 = 0 then
    select id, full_name, store_id into v_profile from public.profiles where id = p_user_id;

    if v_profile.id is not null and p_brand_id is not null then
      insert into public.activity_feed (brand_id, subject_id, store_id, trigger_type, source_event, message)
      values (
        p_brand_id,
        v_profile.id,
        v_profile.store_id,
        'automatic',
        'streak_milestone',
        format('%s está em chamas! 🔥 %s dias seguidos de estudo!', v_profile.full_name, v_row.current_streak_days)
      );
    end if;

    if v_profile.id is not null then
      insert into public.points_ledger (user_id, source_type, source_id, points, reason)
      values (p_user_id, 'streak', null, 20, format('Streak de %s dias mantido', v_row.current_streak_days));
    end if;

    if v_row.current_streak_days = 5 then
      perform public.fn_grant_badge(p_user_id, 'ritmo-constante', p_brand_id);
    end if;
  end if;
end;
$$;

comment on function public.fn_touch_streak(uuid, uuid) is
  'Atualiza o streak do usuário. p_brand_id (opcional) vem do evento que disparou o toque (quiz/game/lição sabem sua marca; avaliação trimestral não, evaluations não é brand-scoped) — usado pro post de marco no Mural e pra conceder o badge Ritmo Constante no 5º dia (sql/053).';

create or replace function public.fn_touch_streak_on_quiz()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_brand_id uuid;
begin
  if new.finished_at is not null then
    select brand_id into v_brand_id from quizzes where id = new.quiz_id;
    perform public.fn_touch_streak(new.user_id, v_brand_id);
  end if;
  return new;
end;
$$;

create or replace function public.fn_touch_streak_on_game()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_brand_id uuid;
begin
  if new.finished_at is not null then
    select brand_id into v_brand_id from games where id = new.game_id;
    perform public.fn_touch_streak(new.user_id, v_brand_id);
  end if;
  return new;
end;
$$;

create or replace function public.fn_touch_streak_on_lesson()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_brand_id uuid;
begin
  if new.completed_at is not null then
    select t.brand_id into v_brand_id
      from lessons l
      join modules m on m.id = l.module_id
      join zones z on z.id = m.zone_id
      join trails t on t.id = z.trail_id
     where l.id = new.lesson_id;
    perform public.fn_touch_streak(new.user_id, v_brand_id);
  end if;
  return new;
end;
$$;

-- fn_touch_streak_on_evaluation não muda — evaluations não tem brand_id, e
-- a chamada de 1 argumento continua válida (p_brand_id usa o default null).

-- As duas funções recriadas (drop + create) nascem com EXECUTE de PUBLIC por
-- padrão do Postgres — precisa revogar de novo pra manter o mesmo
-- endurecimento de sql/034 (só chamadas internamente pelas triggers
-- SECURITY DEFINER, nunca direto pelo cliente com um p_user_id arbitrário).
revoke execute on function public.fn_grant_badge(uuid, text, uuid) from public, anon, authenticated;
revoke execute on function public.fn_touch_streak(uuid, uuid) from public, anon, authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 053
-- ============================================================================
