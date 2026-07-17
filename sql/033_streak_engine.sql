-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 033: Engine de Streak (sequência de estudo)
-- ============================================================================
-- Especificado em regras-de-negocio-training-hub.md §6.5 e
-- modelagem-banco-dados-training-hub.md §6.6 — deixado fora de escopo em
-- sql/022 e sql/023 ("Ritmo Constante FORA de escopo: depende de sistema de
-- streak que não existe ainda").
--
-- Diferença deliberada em relação ao desenho original da modelagem: o
-- documento previa um job diário (Edge Function `compute-streaks`, cron)
-- lendo `study_sessions`/`login_events`. Essas duas tabelas até EXISTEM no
-- schema base — mas nenhum código do app grava nelas (confirmado por
-- comentário pré-existente em `src/pages/liderDashboard.js`: "nenhuma tela
-- loga sessão de estudo ou evento de login hoje"). O schema base também já
-- tinha `streaks` (tabela + RLS own/líder/admin) e um `fn_update_streak()`
-- que lê de `study_sessions` — mas como nada popula essa tabela e nenhum
-- trigger/job chama essa função (confirmado via `pg_trigger`), ela nunca
-- rodou de verdade: código morto desde sempre, não uma regressão.
--
-- Em vez de depender de `study_sessions`/cron (exigiria instrumentar login E
-- criar Edge Function agendada — duas peças de infra que não existem),
-- streak aqui é recalculado de forma REATIVA, no momento de cada atividade
-- relevante de estudo que já existe e já teria motivo pra existir de
-- qualquer forma (lição concluída, quiz/avaliação finalizada, game jogado)
-- — mesma filosofia pragmática do Relatório de Gaps (sql/015: "não criar
-- tabela pra economizar espaço"/infra nova quando dá pra reaproveitar o que
-- já existe). Como não há job noturno "quebrando" streaks inativos, a view
-- `v_streaks_effective` no final deste arquivo recalcula, na hora da
-- leitura, se o streak gravado ainda está vivo (sem escrever nada) — evita
-- mostrar um streak "fantasma" pra quem parou de estudar há dias.
--
-- RN §6.5 — recomendação adotada: pausa automática em fins de semana
-- (streak só quebra em dia útil sem atividade, não penaliza sábado/domingo).
-- RN §6.10 — marco de streak no Mural "ex.: 5 dias seguidos"; badge "Ritmo
-- Constante" (já cadastrado em sql/022, sem regra de concessão até agora)
-- concedido no primeiro marco de 5 dias.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Tabela — já existia no schema base (com RLS own/líder/admin idêntica
--    à que este arquivo precisaria criar). `create table if not exists` e os
--    `grant`/RLS abaixo são no-ops em produção; mantidos pra quem aplicar
--    este arquivo do zero num ambiente novo.
-- ----------------------------------------------------------------------------
create table if not exists public.streaks (
  id                   uuid primary key default gen_random_uuid(),
  user_id              uuid not null unique references public.profiles(id) on delete cascade,
  current_streak_days  integer not null default 0,
  longest_streak_days  integer not null default 0,
  last_activity_date   date,
  updated_at           timestamptz not null default now()
);

comment on table public.streaks is
  'Sequência de dias consecutivos com atividade relevante de estudo (RN §6.5). Recalculado reativamente por fn_touch_streak a cada lição/quiz/game/avaliação concluídos — sem job diário (fn_update_streak do schema base nunca foi chamada por nada, retirada abaixo). Ler via v_streaks_effective, não direto, pra não mostrar streak desatualizado de quem parou de estudar.';

alter table public.streaks enable row level security;

drop policy if exists streaks_select_own on public.streaks;
create policy streaks_select_own on public.streaks
  for select using (user_id = auth.uid());

drop policy if exists streaks_select_leader on public.streaks;
create policy streaks_select_leader on public.streaks
  for select using (
    fn_is_leader()
    and exists (
      select 1 from public.profiles p
       where p.id = streaks.user_id
         and p.store_id in (select fn_leader_store_ids())
    )
  );

-- streaks_admin_all (schema base) já cobre admin com ALL, não só SELECT —
-- não recriar uma policy redundante aqui.

-- Sem policy de INSERT/UPDATE pro authenticated de propósito — só
-- fn_touch_streak (SECURITY DEFINER) escreve aqui, mesmo padrão de
-- activity_feed (sql/022).

grant select on public.streaks to authenticated;

-- Retira o job-stub do schema base: nunca foi chamado por nenhum trigger
-- (confirmado em pg_trigger) e lê de study_sessions, tabela que nenhum
-- código grava — substituído pela engine reativa abaixo.
drop function if exists public.fn_update_streak(uuid);

-- ----------------------------------------------------------------------------
-- 2. fn_touch_streak — coração da engine, chamado por cada trigger de
--    atividade abaixo. Idempotente por dia (2ª atividade no mesmo dia não
--    soma streak de novo).
-- ----------------------------------------------------------------------------
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
    return; -- primeira atividade registrada — sem marco a comemorar ainda
  end if;

  if v_row.last_activity_date = v_today then
    return; -- já contabilizado hoje, chamada idempotente
  end if;

  -- Dia útil anterior esperado (RN §6.5 — pausa automática em fim de
  -- semana): segunda (dow=1) e também sábado/domingo (dow=6/0, se a função
  -- for tocada num dia de estudo "bônus" de fim de semana) usam sexta como
  -- piso; terça a sexta exigem o dia anterior (ontem).
  v_expected_prev := case
    when v_dow = 1 then v_today - 3 -- segunda → sexta
    when v_dow = 0 then v_today - 2 -- domingo → sexta
    when v_dow = 6 then v_today - 1 -- sábado → sexta
    else v_today - 1                -- terça a sexta → ontem
  end;

  if v_row.last_activity_date >= v_expected_prev then
    v_row.current_streak_days := v_row.current_streak_days + 1;
  else
    v_row.current_streak_days := 1; -- quebrou em dia útil sem atividade
  end if;

  v_row.longest_streak_days := greatest(v_row.longest_streak_days, v_row.current_streak_days);

  update public.streaks
     set current_streak_days = v_row.current_streak_days,
         longest_streak_days = v_row.longest_streak_days,
         last_activity_date  = v_today,
         updated_at          = now()
   where user_id = p_user_id;

  -- Marco a cada 5 dias seguidos (RN §6.10, exemplo "5 dias seguidos"):
  -- posta no Mural; no primeiro marco, concede o badge Ritmo Constante.
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

    if v_row.current_streak_days = 5 then
      perform public.fn_grant_badge(p_user_id, 'ritmo-constante');
    end if;
  end if;
end;
$$;

comment on function public.fn_touch_streak(uuid) is
  'Recalcula streaks de forma reativa (sem job diário): incrementa se a última atividade foi ontem (ou sexta, se hoje é segunda — pausa de fim de semana, RN §6.5), senão reseta pra 1. A cada múltiplo de 5 dias posta marco no Mural e, no 5º dia, concede o badge Ritmo Constante (fn_grant_badge, sql/023).';

-- ----------------------------------------------------------------------------
-- 3. Gatilhos de atividade relevante — lição concluída, quiz/avaliação
--    finalizados, game jogado até o fim. Todos AFTER INSERT OR UPDATE (não
--    só UPDATE) pelo mesmo motivo já documentado em sql/019/023: o evento de
--    "primeira conclusão" às vezes é um INSERT direto com o campo de
--    conclusão já preenchido, não sempre um UPDATE partindo de linha aberta.
-- ----------------------------------------------------------------------------
create or replace function public.fn_touch_streak_on_lesson()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.completed_at is not null then
    perform public.fn_touch_streak(new.user_id);
  end if;
  return new;
end;
$$;

drop trigger if exists trg_touch_streak_on_lesson on public.lesson_progress;
create trigger trg_touch_streak_on_lesson
after insert or update on public.lesson_progress
for each row execute function public.fn_touch_streak_on_lesson();

create or replace function public.fn_touch_streak_on_quiz()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.finished_at is not null then
    perform public.fn_touch_streak(new.user_id);
  end if;
  return new;
end;
$$;

drop trigger if exists trg_touch_streak_on_quiz on public.quiz_attempts;
create trigger trg_touch_streak_on_quiz
after insert or update on public.quiz_attempts
for each row execute function public.fn_touch_streak_on_quiz();

create or replace function public.fn_touch_streak_on_game()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.finished_at is not null then
    perform public.fn_touch_streak(new.user_id);
  end if;
  return new;
end;
$$;

drop trigger if exists trg_touch_streak_on_game on public.game_sessions;
create trigger trg_touch_streak_on_game
after insert or update on public.game_sessions
for each row execute function public.fn_touch_streak_on_game();

create or replace function public.fn_touch_streak_on_evaluation()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.finished_at is not null then
    perform public.fn_touch_streak(new.user_id);
  end if;
  return new;
end;
$$;

drop trigger if exists trg_touch_streak_on_evaluation on public.evaluation_attempts;
create trigger trg_touch_streak_on_evaluation
after insert or update on public.evaluation_attempts
for each row execute function public.fn_touch_streak_on_evaluation();

-- ----------------------------------------------------------------------------
-- 4. v_streaks_effective — recalcula na leitura se o streak gravado ainda
--    está vivo hoje, sem escrever nada (substitui o papel do job diário que
--    o desenho original previa). Mesma predicate de segurança embutida na
--    própria query usada em vw_store_knowledge_gaps (sql/015) — funções já
--    são SECURITY DEFINER desde sql/013, então funcionam aqui mesmo a view
--    rodando com privilégio do dono.
-- ----------------------------------------------------------------------------
create or replace view public.v_streaks_effective as
select
  s.id,
  s.user_id,
  s.longest_streak_days,
  s.last_activity_date,
  case
    when s.last_activity_date is null then 0
    when s.last_activity_date = current_date then s.current_streak_days
    when s.last_activity_date >= (
      case extract(dow from current_date)
        when 1 then current_date - 3 -- segunda → sexta
        when 0 then current_date - 2 -- domingo → sexta
        when 6 then current_date - 1 -- sábado → sexta
        else current_date - 1        -- terça a sexta → ontem
      end
    ) then s.current_streak_days
    else 0
  end as current_streak_days_effective,
  s.updated_at
from public.streaks s
where
  fn_is_admin()
  or s.user_id = auth.uid()
  or (
    fn_is_leader()
    and exists (
      select 1 from public.profiles p
       where p.id = s.user_id
         and p.store_id in (select fn_leader_store_ids())
    )
  );

comment on view public.v_streaks_effective is
  'Leitura recomendada de streaks: recalcula na hora se o streak gravado ainda está vivo hoje (sem job diário), zerando current_streak_days_effective quando o usuário passou do dia útil de tolerância sem estudar. Segurança embutida na própria query (mesmo padrão de vw_store_knowledge_gaps, sql/015): self, líder da própria loja, ou admin.';

grant select on public.v_streaks_effective to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 033
-- ============================================================================
