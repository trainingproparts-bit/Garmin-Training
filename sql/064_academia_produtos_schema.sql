-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 064: Academia de Produtos (schema)
-- ============================================================================
-- Segundo domínio da plataforma, independente das Trilhas de aprendizagem
-- (pedido do usuário, 2026-07-20): cada produto Garmin vira uma página de
-- conhecimento profundo pra consulta rápida durante atendimento, não mais um
-- "checkpoint" de trilha sequencial. Não reaproveita modules/lessons (regras
-- de navegação/comparação/relacionamento são próprias), mas REAPROVEITA o
-- Design System de conteúdo já existente:
--   - product_sections.payload usa o mesmíssimo formato { blocks: [...] } de
--     content_library.payload — os blocos tipados de ContentBlocks.js
--     (roteiro, objecao, tabela, card_grid, accordion etc.) cobrem quase
--     todas as 10 seções pedidas sem precisar de renderer novo.
--   - Quiz Especialista reaproveita quizzes/questions/alternatives e o
--     QuizRunner já existentes (product_quizzes é só a ligação produto→quiz,
--     não duplica o motor de quiz).
--   - Badge "Especialista em X" reaproveita o engine de badges já existente
--     (fn_grant_badge, badges/user_badges) — não criamos product_badges como
--     tabela própria, só um novo gatilho específico (ver fim do arquivo).
--   - Game de comparativo reaproveita games/game_sessions (motor de Duelo já
--     existente) — comparisons.comparison_game_id só aponta pra um game.
--
-- Simplificações deliberadas em relação ao esboço original do usuário:
--   - "product_sections" + "product_section_blocks" viraram UMA tabela só
--     (product_sections.payload jsonb), espelhando o padrão já usado em
--     content_library — não havia ganho real em separar em duas tabelas.
--   - "product_badges" não existe como tabela — ver acima.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Categorias e produtos
-- ----------------------------------------------------------------------------
create table public.product_categories (
  id          uuid primary key default gen_random_uuid(),
  brand_id    uuid not null references public.brands(id),
  slug        text not null,
  name        text not null,
  icon        text,
  order_index integer not null default 0,
  created_at  timestamptz not null default now(),
  unique (brand_id, slug)
);

create table public.products (
  id            uuid primary key default gen_random_uuid(),
  brand_id      uuid not null references public.brands(id),
  category_id   uuid not null references public.product_categories(id) on delete cascade,
  slug          text not null,
  name          text not null,
  model_code    text,
  tagline       text,
  price_usd     numeric(10,2),
  cover_url     text,
  is_published  boolean not null default false,
  order_index   integer not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (brand_id, slug)
);
create index idx_products_category on public.products(category_id);

-- ----------------------------------------------------------------------------
-- 2. Seções de conteúdo rico por produto (Visão Geral, Personas, Diferenciais,
--    Scripts de Venda, Objeções, Casos de Uso, FAQ). Comparativos, Downloads
--    e Quiz Especialista têm tabelas próprias abaixo, não vivem aqui.
-- ----------------------------------------------------------------------------
create table public.product_sections (
  id           uuid primary key default gen_random_uuid(),
  product_id   uuid not null references public.products(id) on delete cascade,
  section_type text not null check (section_type in (
    'visao_geral', 'personas', 'diferenciais', 'scripts_venda', 'objecoes', 'casos_uso', 'faq'
  )),
  payload      jsonb not null default '{"blocks": []}'::jsonb,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (product_id, section_type)
);

-- ----------------------------------------------------------------------------
-- 3. Comparativos lado a lado (2 produtos por comparativo)
-- ----------------------------------------------------------------------------
create table public.product_comparisons (
  id                  uuid primary key default gen_random_uuid(),
  brand_id            uuid not null references public.brands(id),
  product_a_id        uuid not null references public.products(id) on delete cascade,
  product_b_id        uuid not null references public.products(id) on delete cascade,
  slug                text not null,
  title               text not null,
  resumo_executivo    text,
  blocks              jsonb not null default '[]'::jsonb,
  comparison_game_id  uuid references public.games(id),
  is_published        boolean not null default false,
  order_index         integer not null default 0,
  created_at          timestamptz not null default now(),
  unique (brand_id, slug),
  check (product_a_id <> product_b_id)
);
create index idx_product_comparisons_a on public.product_comparisons(product_a_id);
create index idx_product_comparisons_b on public.product_comparisons(product_b_id);

-- Tabela comparativa spec-a-spec (o "lado a lado" literal da tela de comparativo)
create table public.comparison_items (
  id             uuid primary key default gen_random_uuid(),
  comparison_id  uuid not null references public.product_comparisons(id) on delete cascade,
  spec_label     text not null,
  value_a        text,
  value_b        text,
  winner         text check (winner in ('a', 'b', 'tie')),
  order_index    integer not null default 0
);
create index idx_comparison_items_comparison on public.comparison_items(comparison_id);

-- ----------------------------------------------------------------------------
-- 4. Downloads (PDFs, imagens, folders, vídeos)
-- ----------------------------------------------------------------------------
create table public.product_materials (
  id           uuid primary key default gen_random_uuid(),
  product_id   uuid not null references public.products(id) on delete cascade,
  type         text not null check (type in ('pdf', 'image', 'folder', 'video')),
  title        text not null,
  url          text not null,
  order_index  integer not null default 0,
  created_at   timestamptz not null default now()
);
create index idx_product_materials_product on public.product_materials(product_id);

-- ----------------------------------------------------------------------------
-- 5. Quiz Especialista — liga o produto a um quiz do sistema já existente
--    (quizzes/questions/alternatives, mesmo motor do QuizRunner da trilha)
-- ----------------------------------------------------------------------------
create table public.product_quizzes (
  id           uuid primary key default gen_random_uuid(),
  product_id   uuid not null references public.products(id) on delete cascade,
  quiz_id      uuid not null references public.quizzes(id) on delete cascade,
  order_index  integer not null default 0,
  unique (product_id, quiz_id)
);
create index idx_product_quizzes_product on public.product_quizzes(product_id);

-- ----------------------------------------------------------------------------
-- 6. Grafo de conhecimento — "Relacionados". related_product_id aponta pra um
--    produto navegável de verdade; related_label cobre conceitos que ainda
--    não são um produto próprio na Academia (ex.: "Running Dynamics", "VO2
--    Max", "Garmin Coach") — aparecem como tag informativa, não clicável.
-- ----------------------------------------------------------------------------
create table public.product_relationships (
  id                  uuid primary key default gen_random_uuid(),
  product_id          uuid not null references public.products(id) on delete cascade,
  related_product_id  uuid references public.products(id) on delete cascade,
  related_label       text,
  relationship_type   text,
  order_index         integer not null default 0,
  check (related_product_id is not null or related_label is not null)
);
create index idx_product_relationships_product on public.product_relationships(product_id);

-- ============================================================================
-- 7. RLS — mesmo padrão de content_library/quizzes/games (fn_is_admin() já
--    existe no schema base): publicado é público pra autenticado, admin lê/
--    escreve tudo. Tabelas-filha sem is_published próprio herdam do produto/
--    comparativo pai via EXISTS.
-- ============================================================================
alter table public.product_categories  enable row level security;
alter table public.products            enable row level security;
alter table public.product_sections    enable row level security;
alter table public.product_comparisons enable row level security;
alter table public.comparison_items    enable row level security;
alter table public.product_materials   enable row level security;
alter table public.product_quizzes     enable row level security;
alter table public.product_relationships enable row level security;

create policy product_categories_admin_all on public.product_categories
  for all using (fn_is_admin()) with check (fn_is_admin());
create policy product_categories_select_all on public.product_categories
  for select using (true);

create policy products_admin_all on public.products
  for all using (fn_is_admin()) with check (fn_is_admin());
create policy products_select_published on public.products
  for select using (is_published = true or fn_is_admin());

create policy product_sections_admin_all on public.product_sections
  for all using (fn_is_admin()) with check (fn_is_admin());
create policy product_sections_select on public.product_sections
  for select using (
    fn_is_admin() or exists (
      select 1 from public.products p where p.id = product_sections.product_id and p.is_published
    )
  );

create policy product_comparisons_admin_all on public.product_comparisons
  for all using (fn_is_admin()) with check (fn_is_admin());
create policy product_comparisons_select_published on public.product_comparisons
  for select using (is_published = true or fn_is_admin());

create policy comparison_items_admin_all on public.comparison_items
  for all using (fn_is_admin()) with check (fn_is_admin());
create policy comparison_items_select on public.comparison_items
  for select using (
    fn_is_admin() or exists (
      select 1 from public.product_comparisons c where c.id = comparison_items.comparison_id and c.is_published
    )
  );

create policy product_materials_admin_all on public.product_materials
  for all using (fn_is_admin()) with check (fn_is_admin());
create policy product_materials_select on public.product_materials
  for select using (
    fn_is_admin() or exists (
      select 1 from public.products p where p.id = product_materials.product_id and p.is_published
    )
  );

create policy product_quizzes_admin_all on public.product_quizzes
  for all using (fn_is_admin()) with check (fn_is_admin());
create policy product_quizzes_select on public.product_quizzes
  for select using (
    fn_is_admin() or exists (
      select 1 from public.products p where p.id = product_quizzes.product_id and p.is_published
    )
  );

create policy product_relationships_admin_all on public.product_relationships
  for all using (fn_is_admin()) with check (fn_is_admin());
create policy product_relationships_select on public.product_relationships
  for select using (
    fn_is_admin() or exists (
      select 1 from public.products p where p.id = product_relationships.product_id and p.is_published
    )
  );

-- ============================================================================
-- 8. Badge "Especialista em <produto>" ao passar no Quiz Especialista —
--    reaproveita fn_grant_badge (sql/023): só precisa de um novo gatilho
--    específico + inserir os badges/slugs correspondentes (feito no seed).
-- ============================================================================
create or replace function public.fn_grant_badge_on_product_quiz_pass()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_product_slug text;
begin
  if new.finished_at is not null and new.passed = true then
    select p.slug into v_product_slug
      from public.product_quizzes pq
      join public.products p on p.id = pq.product_id
     where pq.quiz_id = new.quiz_id
     limit 1;

    if v_product_slug is not null then
      perform public.fn_grant_badge(new.user_id, 'especialista-' || v_product_slug);
    end if;
  end if;

  return new;
end;
$$;

comment on function public.fn_grant_badge_on_product_quiz_pass() is
  'Concede o badge "Especialista em <produto>" (badges.slug = ''especialista-<slug produto>-<slug marca>'') quando o Quiz Especialista daquele produto é aprovado. AFTER INSERT OR UPDATE em quiz_attempts, mesmo evento de fn_grant_badge_on_quiz_100 (sql/023) — os dois gatilhos coexistem sem conflito, cada um concede um badge diferente.';

drop trigger if exists trg_grant_badge_on_product_quiz_pass on public.quiz_attempts;
create trigger trg_grant_badge_on_product_quiz_pass
after insert or update on public.quiz_attempts
for each row execute function public.fn_grant_badge_on_product_quiz_pass();

-- ============================================================================
-- FIM DA MIGRAÇÃO 064
-- ============================================================================
