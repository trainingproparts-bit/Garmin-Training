-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 124: corrige trigger de delete de lessons
-- que quebrava a Revisão Inteligente, e refaz a sql/123
-- ============================================================================
-- Erro real ao rodar a sql/123:
--   ERROR: 23503: update or delete on table "review_catalog" violates
--   foreign key constraint "review_session_items_catalog_item_id_fkey"
--   DETAIL: Key (id)=(...) is still referenced from table "review_session_items".
--   CONTEXT: ...fn_review_catalog_sync_lesson()... delete from review_catalog...
--
-- Causa: fn_review_catalog_sync_lesson() (sql/066) faz, no branch DELETE,
-- um hard delete em review_catalog pros blocos daquela lição. Se algum
-- colaborador já revisou um desses blocos na Revisão Inteligente, existe
-- uma linha em review_session_items apontando pro review_catalog.id, e o
-- delete quebra a FK. Esse EXATO bug (hard delete de review_catalog vs.
-- FK de review_session_items) já tinha sido corrigido uma vez pra UPDATE
-- em fn_review_catalog_sync_blocks (sql/092, "vira is_published=false em
-- vez de deletar") — só que aquela correção não cobria o branch DELETE de
-- fn_review_catalog_sync_lesson, que continuava fazendo delete puro.
--
-- Como a sql/123 rodou dentro de um único `do $$ ... $$`, o erro no meio
-- fez rollback do bloco inteiro — nada foi de fato apagado (nem
-- lesson_progress, nem lessons). Bloco seguro pra rodar de novo.
-- ============================================================================

create or replace function public.fn_review_catalog_sync_lesson()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_brand_id uuid;
begin
  if tg_op = 'DELETE' then
    -- Mesmo princípio da sql/092: nunca hard-delete linhas de review_catalog
    -- que podem estar referenciadas por review_session_items (histórico de
    -- quem já revisou). is_published=false já é o campo que a RLS e o
    -- algoritmo de seleção de revisão usam pra excluir do sorteio.
    update public.review_catalog
       set is_published = false, updated_at = now()
     where source_table = 'lessons' and source_id = old.id;
    return old;
  end if;

  select tr.brand_id into v_brand_id
    from public.modules m
    join public.zones z on z.id = m.zone_id
    join public.trails tr on tr.id = z.trail_id
   where m.id = new.module_id;

  if v_brand_id is not null then
    perform public.fn_review_catalog_sync_blocks('lessons', new.id, new.body->'blocks', new.title, v_brand_id, null, new.is_published);
  end if;

  return new;
end;
$$;

comment on function public.fn_review_catalog_sync_lesson() is
  'DELETE desativa (is_published=false) as linhas de review_catalog em vez de apagar — evita violar review_session_items_catalog_item_id_fkey quando alguém já revisou algum bloco daquela lição (mesmo princípio da sql/092, que corrigiu o mesmo bug no caminho de UPDATE).';

-- Refaz a exclusão das lições órfãs (sql/123) agora que o trigger não quebra mais.
do $$
declare
  v_forerunner_id uuid := '3405fe07-5dd7-4599-9392-17c9155a1400';
  v_fenix_id      uuid := '2aa7a7af-19e2-4d02-94b6-81de1bc9460f';
begin
  delete from lesson_progress where lesson_id in (v_forerunner_id, v_fenix_id);
  delete from lessons where id in (v_forerunner_id, v_fenix_id);
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 124
-- ============================================================================
