-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 068: Revisão Inteligente — correção de escopo de marca
-- ============================================================================
-- Bug real reportado pelo usuário (2026-07-20, "fala que não tem revisão
-- disponível"): v_review_stats/fn_start_review_session (sql/067) resolviam a
-- marca via `profiles.brand_id` — mas esse campo é NULL pra contas admin
-- (ex.: Samara Pereira), que navegam entre Garmin/Shokz pela tela de troca de
-- marca, não têm uma marca fixa no perfil. `c.brand_id = null` nunca é
-- verdadeiro, então available_count sempre dava 0 e fn_start_review_session
-- lançava "perfil sem marca selecionada" pra qualquer admin.
--
-- Todo o RESTO do app já resolve isso corretamente passando a marca
-- ESCOLHIDA (window.selectedBrandId, guardado no momento em que a pessoa
-- clica numa marca na tela Início) como parâmetro explícito — fetchCategories
-- (Academia), searchAll (busca global), fetchContentByCategory (Biblioteca)
-- etc. nenhum deles lê profiles.brand_id. Este arquivo alinha a Revisão
-- Inteligente com essa mesma convenção: brand_id passa a ser parâmetro
-- explícito, não inferido do perfil. Isso não abre brecha de segurança nova
-- — review_catalog já é lido só por is_published (RLS), brand_id sempre foi
-- um recorte de UX/multi-tenant, nunca o controle de acesso de verdade.
-- ============================================================================

-- v_review_stats era uma VIEW (não aceita parâmetro) — vira função, mesmo
-- padrão de RPC usado no resto do domínio.
drop view if exists public.v_review_stats;

create or replace function public.fn_review_stats(p_brand_id uuid)
returns table (available_count integer, last_session_at timestamptz)
language sql
security definer
set search_path = public
stable
as $$
  select
    (
      select count(*)::integer from public.review_catalog c
       where c.brand_id = p_brand_id and c.is_published
         and not exists (
           select 1 from public.review_progress rp
            where rp.catalog_item_id = c.id and rp.user_id = auth.uid() and rp.next_review_due_at > now()
         )
    ) as available_count,
    (
      select max(finished_at) from public.review_sessions rs
       where rs.user_id = auth.uid() and rs.brand_id = p_brand_id and rs.finished_at is not null
    ) as last_session_at;
$$;

comment on function public.fn_review_stats(uuid) is
  'Estatísticas da Revisão Inteligente pro card da Home — brand_id é parâmetro explícito (marca escolhida na tela Início), não profiles.brand_id (NULL pra contas admin que navegam entre marcas — bug real corrigido aqui). Substitui v_review_stats (view não aceita parâmetro).';

grant execute on function public.fn_review_stats(uuid) to authenticated;

-- fn_start_review_session ganha p_brand_id como parâmetro (mesmo motivo) —
-- assinatura muda (2 params → 3), então PRECISA dropar a versão antiga
-- primeiro (create or replace não troca lista de parâmetros).
drop function if exists public.fn_start_review_session(text, uuid);

create or replace function public.fn_start_review_session(p_mode text, p_brand_id uuid, p_product_id uuid default null)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id      uuid := auth.uid();
  v_target       integer;
  v_session_id   uuid;
  v_related_ids  uuid[];
begin
  if v_user_id is null then
    raise exception 'usuário não autenticado';
  end if;
  if p_brand_id is null then
    raise exception 'marca não informada';
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
  values (v_user_id, p_brand_id, p_mode, p_product_id, v_target)
  returning id into v_session_id;

  if p_mode = 'produto' then
    select array_agg(related_product_id) into v_related_ids
      from public.product_relationships
     where product_id = p_product_id and related_product_id is not null;
  end if;

  if p_mode = 'surpresa' then
    insert into public.review_session_items (session_id, catalog_item_id, order_index, weight_at_selection)
    select v_session_id, c.id, (row_number() over (order by random())) - 1, 0
      from public.review_catalog c
     where c.brand_id = p_brand_id and c.is_published
     order by random()
     limit v_target;

  elsif p_mode = 'erros' then
    insert into public.review_session_items (session_id, catalog_item_id, order_index, weight_at_selection)
    select v_session_id, c.id, (row_number() over (order by rp.updated_at asc)) - 1, 80
      from public.review_catalog c
      join public.review_progress rp on rp.catalog_item_id = c.id and rp.user_id = v_user_id
     where c.brand_id = p_brand_id and c.is_published
       and (rp.state = 'precisa_revisar' or rp.last_result = 'erro')
     order by rp.updated_at asc
     limit v_target;

  else
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
      where c.brand_id = p_brand_id and c.is_published
        and (p_mode <> 'produto' or c.product_id = p_product_id or c.product_id = any(coalesce(v_related_ids, array[]::uuid[])))
    ) scored
    order by score desc
    limit v_target;
  end if;

  return v_session_id;
end;
$$;

comment on function public.fn_start_review_session(text, uuid, uuid) is
  'Monta a fila de revisão no servidor — brand_id é parâmetro explícito (marca escolhida na tela Início), não profiles.brand_id. Ver fn_review_stats para o mesmo motivo.';

grant execute on function public.fn_start_review_session(text, uuid, uuid) to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 068
-- ============================================================================
