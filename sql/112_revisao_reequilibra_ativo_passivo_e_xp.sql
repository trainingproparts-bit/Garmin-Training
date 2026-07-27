-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 112: Revisão Inteligente — reequilibra
-- conteúdo ativo/passivo e reduz XP por sessão pra um valor fixo
-- ============================================================================
-- Pedido do usuário:
--   1. "eu acho que é bom ter explicações sim nas revisões, não precisa ser
--      só quiz" — a migração 098 deu +300 de peso pra quiz_question/
--      comparison_spec sobre conteúdo passivo (texto_rico/banner/roteiro/
--      card/etc), o que, com 413 itens ativos publicados sempre acima do
--      maior target de sessão (20), fazia a fila virar 100% quiz na prática
--      (conteúdo passivo "só preenche o que sobra" nunca sobrava nada).
--      Correção: em vez de um bônus aditivo que sempre vence, reserva uma
--      cota fixa por sessão (~70% ativo / ~30% passivo) nos modos
--      rapida/completa/produto, garantindo que explicações sempre apareçam
--      sem devolver ao problema original (sessão inteira só de texto passivo
--      pra "ganhar XP"). Modos surpresa e erros não mudam (surpresa é
--      sorteio puro por pedido anterior; erros já filtra por dificuldade
--      registrada, não por volume total do catálogo).
--   2. "eu só diminuiria pq 24xp é muito, diminuiria pra 5 por revisão
--      completa" — fn_finalize_review_session pagava 3 pts/item (até 24 XP
--      no modo rápido de 8 itens, até 60 no modo completo de 20). Substituído
--      por um valor fixo de 5 XP por sessão concluída (só se pelo menos 1
--      item foi de fato respondido/visualizado, senão 0 — mesma guarda
--      anti-grind de antes, só que o valor não escala mais com o tamanho da
--      sessão).
-- ============================================================================

create or replace function public.fn_start_review_session(p_mode text, p_product_id uuid default null)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id        uuid := auth.uid();
  v_brand_id       uuid;
  v_target         integer;
  v_active_target  integer;
  v_passive_target integer;
  v_session_id     uuid;
  v_related_ids    uuid[];
begin
  if v_user_id is null then
    raise exception 'usuário não autenticado';
  end if;

  select brand_id into v_brand_id from public.profiles where id = v_user_id;
  if v_brand_id is null then
    raise exception 'perfil sem marca selecionada';
  end if;

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
    -- Sorteio puro, de propósito — sem peso nenhum (pedido explícito do usuário
    -- em rodada anterior). Não entra na cota ativo/passivo.
    insert into public.review_session_items (session_id, catalog_item_id, order_index, weight_at_selection)
    select v_session_id, c.id, (row_number() over (order by random())) - 1, 0
      from public.review_catalog c
     where c.brand_id = v_brand_id and c.is_published
     order by random()
     limit v_target;

  elsif p_mode = 'erros' then
    -- Só itens com estado precisa_revisar OU último resultado erro. Dentro
    -- desse filtro, prioriza item ativo (testa de verdade) sobre passivo,
    -- e só depois por mais antigo primeiro.
    insert into public.review_session_items (session_id, catalog_item_id, order_index, weight_at_selection)
    select v_session_id, c.id,
           (row_number() over (
             order by (case when c.block_type in ('quiz_question', 'comparison_spec') then 1 else 0 end) desc,
                      rp.updated_at asc
           )) - 1,
           80
      from public.review_catalog c
      join public.review_progress rp on rp.catalog_item_id = c.id and rp.user_id = v_user_id
     where c.brand_id = v_brand_id and c.is_published
       and (rp.state = 'precisa_revisar' or rp.last_result = 'erro')
     order by (case when c.block_type in ('quiz_question', 'comparison_spec') then 1 else 0 end) desc,
              rp.updated_at asc
     limit v_target;

  else
    -- rapida / completa / produto: cota fixa ~70% ativo (quiz_question/
    -- comparison_spec) e ~30% passivo (texto_rico/banner/roteiro/card/etc),
    -- cada grupo ordenado pelo mesmo score de repetição espaçada. Cota em
    -- vez de bônus aditivo garante que explicações sempre apareçam, sem
    -- deixar a sessão virar só texto passivo de novo.
    v_active_target := ceil(v_target * 0.7)::int;
    v_passive_target := v_target - v_active_target;

    insert into public.review_session_items (session_id, catalog_item_id, order_index, weight_at_selection)
    select v_session_id, id, (row_number() over (order by score desc)) - 1, round(score::numeric, 2)
    from (
      (
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
          and c.block_type in ('quiz_question', 'comparison_spec')
          and (p_mode <> 'produto' or c.product_id = p_product_id or c.product_id = any(coalesce(v_related_ids, array[]::uuid[])))
        order by score desc
        limit v_active_target
      )
      union all
      (
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
          and c.block_type not in ('quiz_question', 'comparison_spec')
          and (p_mode <> 'produto' or c.product_id = p_product_id or c.product_id = any(coalesce(v_related_ids, array[]::uuid[])))
        order by score desc
        limit v_passive_target
      )
    ) scored
    order by score desc
    limit v_target;
  end if;

  return v_session_id;
end;
$$;

comment on function public.fn_start_review_session(text, uuid) is
  'Monta a fila de revisão no servidor. Modos rapida/completa/produto reservam uma cota fixa (~70% ativo / ~30% passivo) em vez de um bônus aditivo que sempre vencia — garante que quiz_question/comparison_spec dominem a sessão (testam de verdade) sem eliminar por completo o conteúdo passivo explicativo (texto_rico/banner/roteiro/card/etc). Modo surpresa continua sorteio puro (sem peso), modo erros continua priorizando ativo dentro do filtro de itens com dificuldade registrada. Congela a fila em review_session_items; o cliente só lê de volta via SELECT normal (RLS restringe à própria sessão).';

grant execute on function public.fn_start_review_session(text, uuid) to authenticated;

-- ----------------------------------------------------------------------------
-- fn_finalize_review_session — XP fixo de 5 por sessão concluída (era
-- 3 pts/item, chegando a 24-60 XP dependendo do modo).
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

  -- 5 pts fixos por sessão concluída, não escala mais por item (era 3
  -- pts/item, chegando a 24-60 XP) — só paga se pelo menos 1 item foi
  -- respondido/visualizado, mesma guarda anti-grind de antes.
  v_xp := case when v_items_reviewed > 0 then 5 else 0 end;
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
  'Fecha a sessão de revisão, concede XP fixo (5 pts por sessão concluída com pelo menos 1 item respondido/visualizado, points_ledger) e reaproveita o streak já existente (fn_touch_streak, sql/033).';

grant execute on function public.fn_finalize_review_session(uuid) to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 112
-- ============================================================================
