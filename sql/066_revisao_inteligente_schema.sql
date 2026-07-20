-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 066: Revisão Inteligente (schema)
-- ============================================================================
-- Terceiro domínio da plataforma (2026-07-20) — retenção de conhecimento via
-- repetição espaçada. NÃO guarda conteúdo próprio: indexa (source_table,
-- source_id, block_index) apontando pros blocos ricos que já existem em
-- lessons/content_library/product_sections/product_comparisons, mais
-- questions (quiz) e comparison_items (specs de comparativo). Na hora de
-- exibir, o front busca o bloco AO VIVO na tabela-fonte e renderiza com
-- ContentBlocks.js sem nenhuma mudança nele — se um admin editar a lição
-- depois, a revisão já reflete, nunca fica desatualizada.
--
-- Certificações (evaluations/evaluation_questions) ficam DE FORA de propósito
-- — instrumento de recertificação de alto peso, não prática informal.
--
-- Simplificações em relação ao esboço original do usuário (mesmo espírito das
-- já feitas em Academia de Produtos — sql/064):
--   - Sem review_queue: a fila é calculada do zero a cada "Revisar Agora" e
--     congelada em review_session_items — não há ganho em persistir fila
--     que ninguém consumiu.
--   - Sem review_scores: coberto por review_progress (por item) e
--     review_sessions.xp_earned (por sessão).
--   - Sem review_history: review_session_items + review_sessions JÁ é o
--     histórico completo (join direto responde "o que revisei e quando").
--   - Sem review_weights/review_settings: pesos do algoritmo são constantes
--     documentadas na função de seleção, não uma tabela editável — não há
--     UI de admin pedida pra isso ainda; promover pra tabela é trivial depois.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. review_catalog — índice polimórfico de tudo que é revisável.
-- ----------------------------------------------------------------------------
create table public.review_catalog (
  id            uuid primary key default gen_random_uuid(),
  brand_id      uuid not null references public.brands(id),
  source_table  text not null check (source_table in (
    'lessons', 'content_library', 'product_sections', 'product_comparisons', 'questions', 'comparison_items'
  )),
  source_id     uuid not null,
  -- -1 (sentinela, NÃO null) pra questions/comparison_items, já atômicas —
  -- precisa ser um valor de verdade porque NULL <> NULL em UNIQUE/ON CONFLICT
  -- no Postgres; com null aqui, cada re-sync inseriria uma linha duplicada em
  -- vez de atualizar a existente. Índice >= 0 = posição real num array de blocks.
  block_index   integer not null default -1,
  block_type    text not null, -- 'roteiro'/'objecao'/'card_grid'/... (mesmos tipos de ContentBlocks.js) + 'quiz_question'/'comparison_spec'
  title         text not null, -- denormalizado (título do pai) só pra listar/depurar, nunca usado pra renderizar
  product_id    uuid references public.products(id), -- só quando o conteúdo pertence a um produto (Academia) — alimenta "Revisão por Produto"
  is_published  boolean not null default true, -- denormalizado do pai, evita join nas 4 tabelas-fonte em toda query
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (source_table, source_id, block_index)
);
create index idx_review_catalog_brand on public.review_catalog(brand_id) where is_published;
create index idx_review_catalog_product on public.review_catalog(product_id) where product_id is not null;

alter table public.review_catalog enable row level security;

create policy review_catalog_admin_all on public.review_catalog
  for all using (fn_is_admin()) with check (fn_is_admin());
create policy review_catalog_select_published on public.review_catalog
  for select using (is_published = true or fn_is_admin());

-- Sem INSERT/UPDATE/DELETE pro authenticated de propósito — só as funções de
-- sincronização abaixo (SECURITY DEFINER) escrevem aqui.

-- ----------------------------------------------------------------------------
-- 2. review_progress — 1 linha por (usuário, item do catálogo). Ausência de
--    linha = "nunca visto" (não pré-cria pra todo mundo).
-- ----------------------------------------------------------------------------
create table public.review_progress (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null references public.profiles(id) on delete cascade,
  catalog_item_id     uuid not null references public.review_catalog(id) on delete cascade,
  state               text not null default 'aprendizado' check (state in ('aprendizado', 'revisado', 'dominado', 'precisa_revisar')),
  times_seen          integer not null default 0,
  times_correct       integer not null default 0,
  last_seen_at        timestamptz,
  last_result         text check (last_result in ('acerto', 'erro', 'visualizado')),
  ease_factor         numeric(3,2) not null default 2.50,
  interval_days       integer not null default 0,
  consecutive_correct integer not null default 0,
  next_review_due_at  timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (user_id, catalog_item_id)
);
create index idx_review_progress_user_due on public.review_progress(user_id, next_review_due_at);

alter table public.review_progress enable row level security;

create policy review_progress_select_own on public.review_progress
  for select using (user_id = auth.uid());
create policy review_progress_admin_all on public.review_progress
  for all using (fn_is_admin()) with check (fn_is_admin());

-- Sem INSERT/UPDATE pro authenticated — só fn_submit_review_item grava aqui
-- (mesmo princípio de quiz_answers/game_round_answers: nunca confia em
-- estado de conhecimento calculado no cliente).

-- ----------------------------------------------------------------------------
-- 3. review_sessions — 1 linha por "Revisar Agora".
-- ----------------------------------------------------------------------------
create table public.review_sessions (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null references public.profiles(id) on delete cascade,
  brand_id            uuid not null references public.brands(id),
  mode                text not null check (mode in ('rapida', 'completa', 'surpresa', 'erros', 'produto')),
  product_id          uuid references public.products(id), -- só no modo 'produto'
  target_item_count   integer not null,
  started_at          timestamptz not null default now(),
  finished_at         timestamptz,
  xp_earned           integer not null default 0
);
create index idx_review_sessions_user on public.review_sessions(user_id, started_at desc);

alter table public.review_sessions enable row level security;

create policy review_sessions_select_own on public.review_sessions
  for select using (user_id = auth.uid());
create policy review_sessions_admin_all on public.review_sessions
  for all using (fn_is_admin()) with check (fn_is_admin());

-- INSERT/UPDATE só via fn_start_review_session/fn_finalize_review_session.

-- ----------------------------------------------------------------------------
-- 4. review_session_items — fila JÁ CONGELADA daquela sessão (dobra como
--    histórico completo via join com review_sessions).
-- ----------------------------------------------------------------------------
create table public.review_session_items (
  id                   uuid primary key default gen_random_uuid(),
  session_id           uuid not null references public.review_sessions(id) on delete cascade,
  catalog_item_id      uuid not null references public.review_catalog(id),
  order_index          integer not null,
  weight_at_selection  numeric(6,2) not null default 0, -- score que fez o algoritmo escolher esse item (transparência/depuração)
  shown_at             timestamptz,
  result               text check (result in ('acerto', 'erro', 'visualizado', 'pulado')),
  responded_at         timestamptz,
  unique (session_id, order_index)
);
create index idx_review_session_items_session on public.review_session_items(session_id);

alter table public.review_session_items enable row level security;

create policy review_session_items_select_own on public.review_session_items
  for select using (
    exists (select 1 from public.review_sessions s where s.id = review_session_items.session_id and s.user_id = auth.uid())
  );
create policy review_session_items_admin_all on public.review_session_items
  for all using (fn_is_admin()) with check (fn_is_admin());

-- Sem INSERT/UPDATE pro authenticated — só fn_start_review_session/
-- fn_submit_review_item (SECURITY DEFINER) escrevem aqui.

-- ============================================================================
-- 5. Sincronização do catálogo — 1 função genérica por array de blocos +
--    wrappers específicos por tabela-fonte, chamados por triggers AFTER
--    INSERT OR UPDATE OR DELETE. "Delete-then-reinsert" por source_id (não
--    upsert 1:1) porque block_index desloca quando blocos são reordenados/
--    adicionados/removidos — mais simples e correto que tentar casar índices
--    antigos com novos.
-- ============================================================================
create or replace function public.fn_review_catalog_sync_blocks(
  p_source_table  text,
  p_source_id     uuid,
  p_blocks        jsonb,
  p_title         text,
  p_brand_id      uuid,
  p_product_id    uuid,
  p_is_published  boolean
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_block   jsonb;
  v_idx     integer := 0;
begin
  delete from public.review_catalog where source_table = p_source_table and source_id = p_source_id;

  if p_blocks is null or jsonb_typeof(p_blocks) <> 'array' then
    return;
  end if;

  for v_block in select * from jsonb_array_elements(p_blocks)
  loop
    insert into public.review_catalog (brand_id, source_table, source_id, block_index, block_type, title, product_id, is_published)
    values (p_brand_id, p_source_table, p_source_id, v_idx, coalesce(v_block->>'type', 'texto_rico'), p_title, p_product_id, p_is_published)
    on conflict (source_table, source_id, block_index) do update
      set block_type = excluded.block_type, title = excluded.title, product_id = excluded.product_id,
          is_published = excluded.is_published, brand_id = excluded.brand_id, updated_at = now();
    v_idx := v_idx + 1;
  end loop;
end;
$$;

-- 5a. lessons.body->'blocks' — brand_id via module→zone→trail (lessons não tem brand_id direto).
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
    delete from public.review_catalog where source_table = 'lessons' and source_id = old.id;
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

drop trigger if exists trg_review_catalog_sync_lesson on public.lessons;
create trigger trg_review_catalog_sync_lesson
after insert or update or delete on public.lessons
for each row execute function public.fn_review_catalog_sync_lesson();

-- 5b. content_library.payload->'blocks'
create or replace function public.fn_review_catalog_sync_content_library()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    delete from public.review_catalog where source_table = 'content_library' and source_id = old.id;
    return old;
  end if;

  perform public.fn_review_catalog_sync_blocks('content_library', new.id, new.payload->'blocks', new.title, new.brand_id, null, new.is_published);
  return new;
end;
$$;

drop trigger if exists trg_review_catalog_sync_content_library on public.content_library;
create trigger trg_review_catalog_sync_content_library
after insert or update or delete on public.content_library
for each row execute function public.fn_review_catalog_sync_content_library();

-- 5c. product_sections.payload->'blocks' — brand_id/product_id via products.
create or replace function public.fn_review_catalog_sync_product_section()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_brand_id uuid;
  v_title    text;
begin
  if tg_op = 'DELETE' then
    delete from public.review_catalog where source_table = 'product_sections' and source_id = old.id;
    return old;
  end if;

  select p.brand_id, p.name into v_brand_id, v_title from public.products p where p.id = new.product_id;

  if v_brand_id is not null then
    perform public.fn_review_catalog_sync_blocks('product_sections', new.id, new.payload->'blocks', v_title, v_brand_id, new.product_id, true);
  end if;

  return new;
end;
$$;

drop trigger if exists trg_review_catalog_sync_product_section on public.product_sections;
create trigger trg_review_catalog_sync_product_section
after insert or update or delete on public.product_sections
for each row execute function public.fn_review_catalog_sync_product_section();

-- 5d. product_comparisons.blocks (array "solto", não {blocks:[...]}) — tagueado
--     com product_a_id (simplificação: um comparativo entra na "Revisão por
--     Produto" do primeiro produto do par; nos modos Rápida/Completa/
--     Surpresa/Erros ele aparece pra todo mundo do mesmo jeito, sem filtro
--     de produto).
create or replace function public.fn_review_catalog_sync_product_comparison()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    delete from public.review_catalog where source_table = 'product_comparisons' and source_id = old.id;
    return old;
  end if;

  perform public.fn_review_catalog_sync_blocks('product_comparisons', new.id, new.blocks, new.title, new.brand_id, new.product_a_id, new.is_published);
  return new;
end;
$$;

drop trigger if exists trg_review_catalog_sync_product_comparison on public.product_comparisons;
create trigger trg_review_catalog_sync_product_comparison
after insert or update or delete on public.product_comparisons
for each row execute function public.fn_review_catalog_sync_product_comparison();

-- 5e. questions — já atômicas (1 questão = 1 card "pergunta rápida"), block_index null.
create or replace function public.fn_review_catalog_sync_question()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_brand_id     uuid;
  v_is_published boolean;
begin
  if tg_op = 'DELETE' then
    delete from public.review_catalog where source_table = 'questions' and source_id = old.id;
    return old;
  end if;

  select q.brand_id, q.is_published into v_brand_id, v_is_published from public.quizzes q where q.id = new.quiz_id;

  if v_brand_id is not null then
    insert into public.review_catalog (brand_id, source_table, source_id, block_index, block_type, title, is_published)
    values (v_brand_id, 'questions', new.id, -1, 'quiz_question', left(new.body, 80), v_is_published and new.is_active)
    on conflict (source_table, source_id, block_index) do update
      set is_published = excluded.is_published, title = excluded.title, brand_id = excluded.brand_id, updated_at = now();
  end if;

  return new;
end;
$$;

drop trigger if exists trg_review_catalog_sync_question on public.questions;
create trigger trg_review_catalog_sync_question
after insert or update or delete on public.questions
for each row execute function public.fn_review_catalog_sync_question();

-- 5f. comparison_items — já atômicas (1 linha de spec = 1 card "qual vence?").
create or replace function public.fn_review_catalog_sync_comparison_item()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_brand_id     uuid;
  v_product_id   uuid;
  v_is_published boolean;
begin
  if tg_op = 'DELETE' then
    delete from public.review_catalog where source_table = 'comparison_items' and source_id = old.id;
    return old;
  end if;

  select c.brand_id, c.product_a_id, c.is_published into v_brand_id, v_product_id, v_is_published
    from public.product_comparisons c where c.id = new.comparison_id;

  if v_brand_id is not null then
    insert into public.review_catalog (brand_id, source_table, source_id, block_index, block_type, title, product_id, is_published)
    values (v_brand_id, 'comparison_items', new.id, -1, 'comparison_spec', new.spec_label, v_product_id, v_is_published)
    on conflict (source_table, source_id, block_index) do update
      set is_published = excluded.is_published, title = excluded.title, product_id = excluded.product_id,
          brand_id = excluded.brand_id, updated_at = now();
  end if;

  return new;
end;
$$;

drop trigger if exists trg_review_catalog_sync_comparison_item on public.comparison_items;
create trigger trg_review_catalog_sync_comparison_item
after insert or update or delete on public.comparison_items
for each row execute function public.fn_review_catalog_sync_comparison_item();

-- ============================================================================
-- 6. Backfill — popula o catálogo com tudo que já existe hoje. lessons não
--    tem updated_at (não dá pra "cutucar" um UPDATE no-op pra disparar o
--    trigger), então chama fn_review_catalog_sync_blocks diretamente pra
--    cada fonte, com a mesma lógica de resolução de brand_id/product_id dos
--    triggers acima.
-- ============================================================================
do $$
declare
  r record;
begin
  for r in
    select l.id, l.title, l.body, l.is_published, tr.brand_id
      from public.lessons l
      join public.modules m on m.id = l.module_id
      join public.zones z on z.id = m.zone_id
      join public.trails tr on tr.id = z.trail_id
  loop
    perform public.fn_review_catalog_sync_blocks('lessons', r.id, r.body->'blocks', r.title, r.brand_id, null, r.is_published);
  end loop;

  for r in select id, title, payload, brand_id, is_published from public.content_library loop
    perform public.fn_review_catalog_sync_blocks('content_library', r.id, r.payload->'blocks', r.title, r.brand_id, null, r.is_published);
  end loop;

  for r in
    select ps.id, ps.payload, p.brand_id, p.name as title, p.id as product_id
      from public.product_sections ps
      join public.products p on p.id = ps.product_id
  loop
    perform public.fn_review_catalog_sync_blocks('product_sections', r.id, r.payload->'blocks', r.title, r.brand_id, r.product_id, true);
  end loop;

  for r in select id, title, blocks, brand_id, product_a_id, is_published from public.product_comparisons loop
    perform public.fn_review_catalog_sync_blocks('product_comparisons', r.id, r.blocks, r.title, r.brand_id, r.product_a_id, r.is_published);
  end loop;

  for r in
    select q.id, q.body, qz.brand_id, qz.is_published
      from public.questions q
      join public.quizzes qz on qz.id = q.quiz_id
     where q.is_active
  loop
    insert into public.review_catalog (brand_id, source_table, source_id, block_index, block_type, title, is_published)
    values (r.brand_id, 'questions', r.id, -1, 'quiz_question', left(r.body, 80), r.is_published)
    on conflict (source_table, source_id, block_index) do nothing;
  end loop;

  for r in
    select ci.id, ci.spec_label, c.brand_id, c.product_a_id, c.is_published
      from public.comparison_items ci
      join public.product_comparisons c on c.id = ci.comparison_id
  loop
    insert into public.review_catalog (brand_id, source_table, source_id, block_index, block_type, title, product_id, is_published)
    values (r.brand_id, 'comparison_items', r.id, -1, 'comparison_spec', r.spec_label, r.product_a_id, r.is_published)
    on conflict (source_table, source_id, block_index) do nothing;
  end loop;
end $$;
