-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 002: content_library (biblioteca técnica)
-- ============================================================================
-- Extensão da modelagem original (modelagem-banco-dados-training-hub.md).
-- Cobre um domínio que existe hoje só como HTML/JS estático dentro de
-- index_redesign_v5.html e que a documentação de Fases 2-4 ainda não
-- formalizou: perfis de cliente, catálogo de produtos, FAQ, concorrentes
-- e especialidades por esporte ("biblioteca técnica").
--
-- Decisão de arquitetura (Sprint 1): em vez de criar uma tabela por
-- categoria (o que multiplicaria schema para conteúdo majoritariamente de
-- leitura, sem progresso/tentativas associados), usa-se uma única tabela
-- genérica com "category" fechado por CHECK + payload jsonb — mesmo padrão
-- já usado em checkpoints.unlock_rule e badges.rule na modelagem original.
-- Caso o negócio decida, numa fase futura, que uma categoria precisa de
-- colunas próprias (ex.: preço/estoque de produto), ela pode ser promovida
-- para tabela dedicada sem afetar as demais.
--
-- Pré-requisito: garmin_training_hub_migrations.sql já aplicado (usa
-- fn_set_updated_at, fn_is_admin e a tabela brands).
-- ============================================================================

create table if not exists content_library (
  id            uuid primary key default gen_random_uuid(),
  brand_id      uuid not null references brands(id),
  category      text not null,
  slug          text not null,
  title         text not null,
  summary       text,
  payload       jsonb not null default '{}'::jsonb,
  order_index   integer not null default 0,
  is_published  boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint uq_content_library_brand_category_slug unique (brand_id, category, slug),
  constraint chk_content_library_category check (
    category in ('perfil_cliente', 'produto', 'faq', 'concorrente', 'especialidade', 'novidade', 'deep_dive')
  )
);
create index if not exists idx_content_library_brand_category
  on content_library(brand_id, category, order_index);

comment on table content_library is
  'Biblioteca técnica genérica: perfis de cliente, produtos, FAQ, concorrentes, especialidades por esporte. Conteúdo de leitura, sem progresso associado — ver modules/lessons para conteúdo de trilha.';
comment on column content_library.category is
  'perfil_cliente | produto | faq | concorrente | especialidade | novidade | deep_dive';
comment on column content_library.payload is
  'Estrutura livre por categoria — ex.: produto guarda {series, level, target, description}; faq guarda {question, answer}.';

drop trigger if exists trg_content_library_updated_at on content_library;
create trigger trg_content_library_updated_at
before update on content_library
for each row execute function fn_set_updated_at();

alter table content_library enable row level security;

create policy content_library_select_published on content_library
  for select using (is_published = true or fn_is_admin());
create policy content_library_admin_all on content_library
  for all using (fn_is_admin()) with check (fn_is_admin());

-- ============================================================================
-- FIM DA MIGRAÇÃO 002
-- ============================================================================
