-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 092: corrige bug real no sync do review_catalog
-- ============================================================================
-- Achado durante a varredura de travessões (sql/091 em diante): qualquer
-- UPDATE em product_sections/lessons/content_library/product_comparisons
-- disparava fn_review_catalog_sync_blocks, que sempre fazia
-- `delete from review_catalog where source_table=... and source_id=...`
-- ANTES de reinserir os blocos — apagando todas as linhas antigas (com IDs
-- próprios) e criando linhas novas com IDs diferentes.
--
-- Isso quebra a FK de review_session_items.catalog_item_id sempre que algum
-- colaborador já tinha aquele bloco específico numa sessão de Revisão
-- Inteligente (ativa ou já finalizada) — não é um problema só do texto que
-- estou editando agora, é QUALQUER edição de conteúdo depois que alguém já
-- revisou aquele trecho. Bug pré-existente, não introduzido nesta sessão.
--
-- Correção: em vez de apagar tudo e reinserir, faz upsert por chave natural
-- (source_table, source_id, block_index) — já existia um ON CONFLICT DO
-- UPDATE no loop, só a delete anterior ao loop que destruía a garantia de
-- manter o mesmo id. Blocos que deixaram de existir (índice além do novo
-- tamanho do array) não são mais deletados — viram is_published=false
-- (a mesma coluna que a RLS e o algoritmo de seleção de revisão já usam pra
-- filtrar o que pode ser sorteado), preservando o histórico de quem já
-- revisou aquele item sem quebrar a FK.
-- ============================================================================

create or replace function public.fn_review_catalog_sync_blocks(
  p_source_table text,
  p_source_id    uuid,
  p_blocks       jsonb,
  p_title        text,
  p_brand_id     uuid,
  p_product_id   uuid,
  p_is_published boolean
)
returns void
language plpgsql
security definer
set search_path = 'public'
as $function$
declare
  v_block   jsonb;
  v_idx     integer := 0;
  v_count   integer := 0;
begin
  if p_blocks is not null and jsonb_typeof(p_blocks) = 'array' then
    for v_block in select * from jsonb_array_elements(p_blocks)
    loop
      insert into public.review_catalog (brand_id, source_table, source_id, block_index, block_type, title, product_id, is_published)
      values (p_brand_id, p_source_table, p_source_id, v_idx, coalesce(v_block->>'type', 'texto_rico'), p_title, p_product_id, p_is_published)
      on conflict (source_table, source_id, block_index) do update
        set block_type = excluded.block_type, title = excluded.title, product_id = excluded.product_id,
            is_published = excluded.is_published, brand_id = excluded.brand_id, updated_at = now();
      v_idx := v_idx + 1;
    end loop;
    v_count := v_idx;
  end if;

  -- Blocos que existiam antes (índice >= v_count) e não existem mais no
  -- conteúdo atual: desativa em vez de apagar, preservando a FK de
  -- review_session_items pra quem já revisou esse item.
  update public.review_catalog
  set is_published = false, updated_at = now()
  where source_table = p_source_table
    and source_id = p_source_id
    and block_index >= v_count;
end;
$function$;

comment on function public.fn_review_catalog_sync_blocks(text, uuid, jsonb, text, uuid, uuid, boolean) is
  'Upsert por (source_table, source_id, block_index) preservando o id de review_catalog entre edições — nunca apaga linha existente (evita violar review_session_items_catalog_item_id_fkey quando alguém já revisou aquele bloco). Blocos removidos do conteúdo viram is_published=false em vez de deletados.';

-- ============================================================================
-- FIM DA MIGRAÇÃO 092
-- ============================================================================
