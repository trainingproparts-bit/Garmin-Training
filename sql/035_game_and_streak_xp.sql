-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 035: XP de game e de streak
-- ============================================================================
-- RN §6.1 lista as fontes de XP: "aprovação em quiz, conclusão de módulo,
-- participação em game, badge/achievement, streak mantido, certificação
-- emitida" — com recomendação de valor padrão "50 game". De todas essas,
-- só "participação em game" e "streak mantido" nunca chegaram a lançar em
-- points_ledger (quiz: fn_award_points_on_pass, schema base; lição:
-- fn_complete_lesson, sql/004; badge/certificação: fora do XP direto, viram
-- Mural — RN §6.10 é explícita que o Mural "não gera XP", o XP já veio do
-- evento original). Este arquivo fecha as 2 lacunas restantes.
--
-- ----------------------------------------------------------------------------
-- XP de game (RN §6.1 — "50 game")
-- ----------------------------------------------------------------------------
-- Só na PRIMEIRA sessão finalizada de cada game por usuário — mesmo
-- princípio já usado em quiz (fn_award_points_on_pass) e lição
-- (fn_complete_lesson): sem isso, como games são intencionalmente abertos
-- pra replay livre (decisão de design já documentada — "práticas informais
-- sem peso de certificação, não requerem bloqueio sequencial"), XP por
-- sessão permitiria farm infinito só jogando de novo.
--
-- ----------------------------------------------------------------------------
-- XP de streak (RN §6.1 — "streak mantido", sem valor de referência dado)
-- ----------------------------------------------------------------------------
-- Reaproveita o mesmo marco de 5 dias que já dispara o post no Mural e o
-- badge Ritmo Constante (fn_touch_streak, sql/033) — mesmo evento, 3 efeitos
-- (Mural + badge no 5º dia + XP em todo marco). Valor pequeno (20 pts) por
-- ser um bônus de consistência, não uma conquista de conteúdo.
-- ============================================================================

-- 1) Estende o CHECK de source_type para incluir 'streak' (mesmo padrão de
--    sql/004, que adicionou 'lesson' — 'game' já existia desde o schema base).
alter table public.points_ledger
  drop constraint if exists chk_points_ledger_source;
alter table public.points_ledger
  add constraint chk_points_ledger_source
  check (source_type in ('quiz','module','lesson','game','badge','certification','streak','manual_adjustment'));

-- 2) XP de game — primeira sessão finalizada de cada game, 50 pts (RN §6.1).
create or replace function public.fn_award_points_on_game_finish()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_already_finished boolean;
begin
  if new.finished_at is null then
    return new;
  end if;
  if tg_op = 'UPDATE' and old.finished_at is not null then
    return new; -- já estava finalizada, não repete
  end if;

  select exists (
    select 1 from public.game_sessions
     where user_id = new.user_id
       and game_id = new.game_id
       and finished_at is not null
       and id <> new.id
  ) into v_already_finished;

  if v_already_finished then
    return new; -- já tinha terminado esse game antes — sem XP repetido (evita farm por replay)
  end if;

  insert into public.points_ledger (user_id, source_type, source_id, points, reason)
  values (new.user_id, 'game', new.id, 50, 'Participação em game (primeira vez)');

  return new;
end;
$$;

comment on function public.fn_award_points_on_game_finish() is
  'Concede 50 pts (RN §6.1) na primeira sessão finalizada de cada game por usuário — mesmo princípio de fn_award_points_on_pass (quiz)/fn_complete_lesson (lição): sem XP repetido, aqui evitando farm via replay livre (games não têm bloqueio sequencial, decisão de design já documentada).';

drop trigger if exists trg_award_points_on_game_finish on public.game_sessions;
create trigger trg_award_points_on_game_finish
after insert or update on public.game_sessions
for each row execute function public.fn_award_points_on_game_finish();

revoke execute on function public.fn_award_points_on_game_finish() from anon, authenticated;

-- 3) XP de streak — reaproveita o marco de 5 dias de fn_touch_streak (sql/033).
create or replace function public.fn_touch_streak(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row           public.streaks;
  v_today         date := current_date;
  v_dow           integer := extract(dow from current_date)::integer; -- 0=domingo … 6=sábado
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
    when v_dow = 1 then v_today - 3 -- segunda → sexta
    when v_dow = 0 then v_today - 2 -- domingo → sexta
    when v_dow = 6 then v_today - 1 -- sábado → sexta
    else v_today - 1                -- terça a sexta → ontem
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
    select id, full_name, brand_id, store_id into v_profile from public.profiles where id = p_user_id;

    if v_profile.id is not null and v_profile.brand_id is not null then
      insert into public.activity_feed (brand_id, subject_id, store_id, trigger_type, source_event, message)
      values (
        v_profile.brand_id,
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
      perform public.fn_grant_badge(p_user_id, 'ritmo-constante');
    end if;
  end if;
end;
$$;

comment on function public.fn_touch_streak(uuid) is
  'Recalcula streaks de forma reativa (sem job diário): incrementa se a última atividade foi ontem (ou sexta, se hoje é segunda/sábado/domingo — pausa de fim de semana, RN §6.5), senão reseta pra 1. A cada múltiplo de 5 dias posta marco no Mural e concede 20 pts de XP (RN §6.1 — "streak mantido"); no 5º dia também concede o badge Ritmo Constante (fn_grant_badge, sql/023). EXECUTE revogado de anon/authenticated (sql/034) — só chamada pelas 4 triggers de atividade (lição/quiz/game/avaliação), nunca direto pelo cliente com um p_user_id arbitrário.';

-- ============================================================================
-- FIM DA MIGRAÇÃO 035
-- ============================================================================
