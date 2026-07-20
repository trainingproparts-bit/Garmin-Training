-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 067: Revisão Inteligente (algoritmo + RPCs)
-- ============================================================================
-- 3 funções SECURITY DEFINER, mesmo princípio de sempre no resto do schema
-- (quiz_answers/fn_submit_quiz_answer, game_round_answers/fn_submit_game_round):
-- o cliente NUNCA calcula a fila nem o estado de conhecimento, só chama RPC.
--
--   fn_start_review_session(modo, produto?)  → monta a fila (server-side) e
--     devolve o session_id; o cliente lê a fila de volta via SELECT normal
--     em review_session_items (RLS já restringe à própria sessão).
--   fn_submit_review_item(item, resposta?)   → calcula acerto/erro no servidor
--     (nunca confia no cliente) e atualiza o SM-2 simplificado em review_progress.
--   fn_finalize_review_session(session)      → fecha a sessão, concede XP
--     (points_ledger) e toca o streak já existente (fn_touch_streak, sql/033).
--
-- Pesos do algoritmo documentados inline (decisão: constantes na função, não
-- tabela review_weights — ver nota de escopo em sql/066).
-- ============================================================================

-- 1) Estende o CHECK de points_ledger.source_type (mesmo padrão de sql/035),
--    partindo da lista completa mais recente (sql/062 já tinha acrescentado
--    'avaliacao_google' — não copiar só a lista de sql/035, senão o ALTER
--    quebra em cima de linhas reais com esse source_type).
alter table public.points_ledger
  drop constraint if exists chk_points_ledger_source;
alter table public.points_ledger
  add constraint chk_points_ledger_source
  check (source_type in ('quiz','module','lesson','game','badge','certification','streak','avaliacao_google','manual_adjustment','review_session'));

-- ----------------------------------------------------------------------------
-- 2) fn_start_review_session — monta a fila.
-- ----------------------------------------------------------------------------
create or replace function public.fn_start_review_session(p_mode text, p_product_id uuid default null)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id      uuid := auth.uid();
  v_brand_id     uuid;
  v_target       integer;
  v_session_id   uuid;
  v_related_ids  uuid[];
begin
  if v_user_id is null then
    raise exception 'usuário não autenticado';
  end if;

  select brand_id into v_brand_id from public.profiles where id = v_user_id;
  if v_brand_id is null then
    raise exception 'perfil sem marca selecionada';
  end if;

  -- Tamanho alvo por modo (RN do pedido: Rápida ≈5min, Completa ≈15min,
  -- ~40s/item na estimativa usada também no card da Home).
  v_target := case p_mode
    when 'rapida'   then 8
    when 'completa' then 20
    when 'surpresa' then 10
    when 'erros'    then 15
    when 'produto'  then 12
    else 8
  end;

  insert into public.review_sessions (user_id, brand_id, mode, product_id, target_item_count)
  values (v_user_id, v_brand_id, p_mode, p_product_id, v_target)
  returning id into v_session_id;

  if p_mode = 'produto' then
    select array_agg(related_product_id) into v_related_ids
      from public.product_relationships
     where product_id = p_product_id and related_product_id is not null;
  end if;

  if p_mode = 'surpresa' then
    -- Sorteio puro, de propósito — sem peso nenhum (pedido explícito do usuário).
    insert into public.review_session_items (session_id, catalog_item_id, order_index, weight_at_selection)
    select v_session_id, c.id, (row_number() over (order by random())) - 1, 0
      from public.review_catalog c
     where c.brand_id = v_brand_id and c.is_published
     order by random()
     limit v_target;

  elsif p_mode = 'erros' then
    -- Só itens com estado precisa_revisar OU último resultado erro, mais
    -- antigos primeiro (quem está errado há mais tempo entra primeiro).
    insert into public.review_session_items (session_id, catalog_item_id, order_index, weight_at_selection)
    select v_session_id, c.id, (row_number() over (order by rp.updated_at asc)) - 1, 80
      from public.review_catalog c
      join public.review_progress rp on rp.catalog_item_id = c.id and rp.user_id = v_user_id
     where c.brand_id = v_brand_id and c.is_published
       and (rp.state = 'precisa_revisar' or rp.last_result = 'erro')
     order by rp.updated_at asc
     limit v_target;

  else
    -- rapida / completa / produto: pontuação por peso (spaced repetition).
    -- nunca visto (100) > precisa_revisar (80) > erro recente (60) > 0 (ok);
    -- +20 se ainda não dominado; até +50 por "idade" desde a última vez visto
    -- (cresce com o tempo, sem inflar demais); -1000 se dominado E revisado
    -- nos últimos 7 dias (praticamente removido da fila, é o espaçamento);
    -- +jitter pequeno (0-10) só pra não sair visivelmente "ordenado".
    insert into public.review_session_items (session_id, catalog_item_id, order_index, weight_at_selection)
    select v_session_id, id, (row_number() over (order by score desc)) - 1, round(score::numeric, 2)
    from (
      select
        c.id,
        (case
          when rp.id is null then 100
          when rp.state = 'precisa_revisar' then 80
          when rp.last_result = 'erro' then 60
          else 0
        end)
        + (case when rp.id is null or rp.state <> 'dominado' then 20 else 0 end)
        + least(50, extract(epoch from (now() - coalesce(rp.last_seen_at, now() - interval '365 days'))) / 86400.0 / 2.0)
        - (case when rp.state = 'dominado' and rp.last_seen_at > now() - interval '7 days' then 1000 else 0 end)
        + (random() * 10) as score
      from public.review_catalog c
      left join public.review_progress rp on rp.catalog_item_id = c.id and rp.user_id = v_user_id
      where c.brand_id = v_brand_id and c.is_published
        and (p_mode <> 'produto' or c.product_id = p_product_id or c.product_id = any(coalesce(v_related_ids, array[]::uuid[])))
    ) scored
    order by score desc
    limit v_target;
  end if;

  return v_session_id;
end;
$$;

comment on function public.fn_start_review_session(text, uuid) is
  'Monta a fila de revisão no servidor (nunca no cliente) — score ponderado inspirado em spaced repetition, exceto no modo surpresa (sorteio puro, de propósito) e erros (só itens com dificuldade registrada). Congela a fila em review_session_items; o cliente só lê de volta via SELECT normal (RLS restringe à própria sessão).';

grant execute on function public.fn_start_review_session(text, uuid) to authenticated;

-- ----------------------------------------------------------------------------
-- 3) fn_submit_review_item — calcula acerto/erro no servidor e atualiza o
--    SM-2 simplificado. Tipos sem certo/errado (texto_rico, banner, card,
--    roteiro, objecao, etc.) sempre resultam em 'visualizado'.
-- ----------------------------------------------------------------------------
create or replace function public.fn_submit_review_item(p_session_item_id uuid, p_answer text default null)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id       uuid := auth.uid();
  v_session_user  uuid;
  v_catalog       record;
  v_result        text;
  v_progress      record;
  v_new_state     text;
  v_new_interval  integer;
  v_new_ease      numeric(3,2);
  v_new_consec    integer;
begin
  select rs.user_id into v_session_user
    from public.review_session_items rsi
    join public.review_sessions rs on rs.id = rsi.session_id
   where rsi.id = p_session_item_id;

  if v_session_user is null or v_session_user <> v_user_id then
    raise exception 'item de sessão % não pertence ao usuário autenticado', p_session_item_id;
  end if;

  select c.* into v_catalog
    from public.review_catalog c
    join public.review_session_items rsi on rsi.catalog_item_id = c.id
   where rsi.id = p_session_item_id;

  if v_catalog.block_type = 'quiz_question' then
    select case when exists (
      select 1 from public.alternatives a
       where a.question_id = v_catalog.source_id and a.id = p_answer::uuid and a.is_correct
    ) then 'acerto' else 'erro' end into v_result;
  elsif v_catalog.block_type = 'comparison_spec' then
    select case
      when ci.winner = 'tie' then 'acerto'
      when ci.winner = p_answer then 'acerto'
      else 'erro'
    end into v_result
    from public.comparison_items ci where ci.id = v_catalog.source_id;
  else
    v_result := 'visualizado';
  end if;

  update public.review_session_items
     set result = v_result, responded_at = now(), shown_at = coalesce(shown_at, now())
   where id = p_session_item_id;

  select * into v_progress from public.review_progress
   where user_id = v_user_id and catalog_item_id = v_catalog.id
   for update;

  v_new_ease     := coalesce(v_progress.ease_factor, 2.50);
  v_new_interval := coalesce(v_progress.interval_days, 0);
  v_new_consec   := coalesce(v_progress.consecutive_correct, 0);

  if v_result = 'erro' then
    v_new_ease     := greatest(1.3, v_new_ease - 0.2);
    v_new_interval := 1;
    v_new_consec   := 0;
    v_new_state    := 'precisa_revisar';
  elsif v_result = 'acerto' then
    v_new_consec   := v_new_consec + 1;
    v_new_interval := case when v_new_interval > 0 then round(v_new_interval * v_new_ease) else 1 end;
    v_new_ease     := least(3.0, v_new_ease + 0.1);
    v_new_state    := case when v_new_consec >= 3 then 'dominado' else 'revisado' end;
  else -- visualizado (conteúdo passivo, sem certo/errado)
    v_new_interval := case when v_new_interval > 0 then round(v_new_interval * 1.5) else 1 end;
    v_new_state    := case when v_progress.state is null or v_progress.state = 'aprendizado' then 'revisado' else v_progress.state end;
  end if;

  insert into public.review_progress (
    user_id, catalog_item_id, state, times_seen, times_correct,
    last_seen_at, last_result, ease_factor, interval_days, consecutive_correct, next_review_due_at
  ) values (
    v_user_id, v_catalog.id, v_new_state,
    coalesce(v_progress.times_seen, 0) + 1,
    coalesce(v_progress.times_correct, 0) + (case when v_result = 'acerto' then 1 else 0 end),
    now(), v_result, v_new_ease, v_new_interval, v_new_consec,
    now() + make_interval(days => v_new_interval)
  )
  on conflict (user_id, catalog_item_id) do update set
    state = excluded.state,
    times_seen = excluded.times_seen,
    times_correct = excluded.times_correct,
    last_seen_at = excluded.last_seen_at,
    last_result = excluded.last_result,
    ease_factor = excluded.ease_factor,
    interval_days = excluded.interval_days,
    consecutive_correct = excluded.consecutive_correct,
    next_review_due_at = excluded.next_review_due_at,
    updated_at = now();

  return v_result;
end;
$$;

comment on function public.fn_submit_review_item(uuid, text) is
  'Único caminho pra registrar uma resposta de revisão — calcula acerto/erro no servidor (quiz_question via alternatives.is_correct, comparison_spec via comparison_items.winner) e aplica um SM-2 simplificado em review_progress (erro reseta intervalo pra 1 dia e ease cai; acerto cresce o intervalo pelo ease_factor e dominado após 3 acertos seguidos; visualizado é um sinal fraco positivo pra conteúdo sem certo/errado).';

grant execute on function public.fn_submit_review_item(uuid, text) to authenticated;

-- ----------------------------------------------------------------------------
-- 4) fn_finalize_review_session — fecha a sessão, XP e streak.
-- ----------------------------------------------------------------------------
create or replace function public.fn_finalize_review_session(p_session_id uuid)
returns table (items_reviewed integer, mastered_count integer, precisa_revisar_count integer, xp_earned integer, duration_seconds integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id        uuid := auth.uid();
  v_owner_ok       boolean;
  v_started        timestamptz;
  v_items_reviewed integer;
  v_mastered       integer;
  v_precisa        integer;
  v_xp             integer;
  v_duration       integer;
begin
  select (user_id = v_user_id and finished_at is null), started_at
    into v_owner_ok, v_started
    from public.review_sessions where id = p_session_id;

  if v_owner_ok is not true then
    raise exception 'sessão % não pertence ao usuário autenticado ou já foi finalizada', p_session_id;
  end if;

  select count(*) filter (where result is not null) into v_items_reviewed
    from public.review_session_items where session_id = p_session_id;

  select count(*) into v_mastered
    from public.review_session_items rsi
    join public.review_progress rp on rp.catalog_item_id = rsi.catalog_item_id and rp.user_id = v_user_id
   where rsi.session_id = p_session_id and rp.state = 'dominado';

  select count(*) into v_precisa
    from public.review_session_items rsi
    join public.review_progress rp on rp.catalog_item_id = rsi.catalog_item_id and rp.user_id = v_user_id
   where rsi.session_id = p_session_id and rp.state = 'precisa_revisar';

  -- 3 pts/item — prática informal e frequente, escala menor que quiz/game
  -- (50 pts, conquista pontual) de propósito, senão infla o XP total rápido
  -- demais numa atividade pensada pra ser feita todo dia.
  v_xp := v_items_reviewed * 3;
  v_duration := greatest(0, extract(epoch from (now() - v_started))::integer);

  update public.review_sessions
     set finished_at = now(), xp_earned = v_xp
   where id = p_session_id;

  if v_xp > 0 then
    insert into public.points_ledger (user_id, source_type, source_id, points, reason)
    values (v_user_id, 'review_session', p_session_id, v_xp, format('Revisão Inteligente: %s conteúdos revisados', v_items_reviewed));

    perform public.fn_touch_streak(v_user_id);
  end if;

  return query select v_items_reviewed, v_mastered, v_precisa, v_xp, v_duration;
end;
$$;

comment on function public.fn_finalize_review_session(uuid) is
  'Fecha a sessão de revisão, concede XP (3 pts/item, points_ledger) e reaproveita o streak já existente (fn_touch_streak, sql/033) — Revisão Inteligente conta como atividade relevante de estudo pro streak, mesmo critério de lição/quiz/game/avaliação.';

grant execute on function public.fn_finalize_review_session(uuid) to authenticated;

-- ----------------------------------------------------------------------------
-- 5) v_review_stats — pro card "Revisão Inteligente" da Home (disponíveis +
--    última revisão). Segurança embutida na própria view (mesmo padrão de
--    v_streaks_effective, sql/033) — streak em si continua vindo de
--    v_streaks_effective, não duplicado aqui.
-- ----------------------------------------------------------------------------
create or replace view public.v_review_stats as
select
  p.id as user_id,
  (
    select count(*) from public.review_catalog c
     where c.brand_id = p.brand_id and c.is_published
       and not exists (
         select 1 from public.review_progress rp
          where rp.catalog_item_id = c.id and rp.user_id = p.id and rp.next_review_due_at > now()
       )
  ) as available_count,
  (
    select max(finished_at) from public.review_sessions rs where rs.user_id = p.id and rs.finished_at is not null
  ) as last_session_at
from public.profiles p
where p.id = auth.uid();

comment on view public.v_review_stats is
  'Estatísticas da Revisão Inteligente pro card da Home: quantos itens do catálogo estão disponíveis pra revisar agora (nunca vistos ou com next_review_due_at já vencido) e quando foi a última sessão concluída. Streak vem de v_streaks_effective (sql/033), não duplicado aqui — Revisão Inteligente já alimenta o mesmo streak via fn_touch_streak.';

grant select on public.v_review_stats to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 067
-- ============================================================================
