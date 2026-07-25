-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 098: Revisão Inteligente passa a priorizar
-- conteúdo ativo (quiz_question/comparison_spec) sobre conteúdo passivo
-- ============================================================================
-- Pedido do usuário (2026-07-24): "as pessoas estão passando pelas revisões
-- e textos apenas para 'ganhar XP', sem realmente absorver o conteúdo...
-- reformule a mecânica de revisão para que seja baseada primariamente em
-- questionários diretos de verificação".
--
-- Causa raiz: fn_start_review_session pontuava a fila só por estado de
-- repetição espaçada (nunca visto / precisa revisar / erro / ok), sem
-- nenhuma distinção entre block_type — um item de texto_rico/banner/card
-- (sem certo/errado, sempre vira "visualizado" ao clicar Próximo) competia
-- de igual pra igual com quiz_question/comparison_spec (testam de verdade).
-- Com 691 blocos passivos contra 413 ativos publicados no catálogo, uma
-- sessão inteira podia sair sem nenhuma pergunta de verdade.
--
-- fn_submit_review_item/SM-2 já impedia "dominado" via visualização passiva
-- (só 3 acertos consecutivos levam a esse estado) — não mexido aqui, o
-- problema era só a seleção.
--
-- Modo "surpresa" continua sorteio puro, sem peso nenhum — pedido explícito
-- e anterior do usuário (ver comentário original em sql/067), não faz parte
-- deste ajuste.
-- ============================================================================

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
    -- em rodada anterior). Não entra na priorização de conteúdo ativo.
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
    -- rapida / completa / produto: pontuação por peso (spaced repetition),
    -- agora com prioridade forte pra conteúdo ativo. +300 pra quiz_question/
    -- comparison_spec garante que eles vêm primeiro na fila sempre que
    -- existirem candidatos suficientes (413 publicados hoje, bem acima do
    -- maior target de sessão) — conteúdo passivo só preenche o que sobrar.
    insert into public.review_session_items (session_id, catalog_item_id, order_index, weight_at_selection)
    select v_session_id, id, (row_number() over (order by score desc)) - 1, round(score::numeric, 2)
    from (
      select
        c.id,
        (case when c.block_type in ('quiz_question', 'comparison_spec') then 300 else 0 end)
        + (case
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
  'Monta a fila de revisão no servidor — score ponderado inspirado em spaced repetition, com prioridade forte (+300) pra conteúdo ativo (quiz_question/comparison_spec) sobre conteúdo passivo, garantindo que a revisão teste de verdade em vez de só passar texto pra ganhar XP. Modo surpresa continua sorteio puro (sem peso), modo erros também prioriza ativo dentro do filtro de itens com dificuldade registrada. Congela a fila em review_session_items; o cliente só lê de volta via SELECT normal (RLS restringe à própria sessão).';

grant execute on function public.fn_start_review_session(text, uuid) to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 098
-- ============================================================================
