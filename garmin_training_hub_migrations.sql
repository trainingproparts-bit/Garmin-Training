-- ============================================================================
-- GARMIN TRAINING HUB — MIGRATIONS CONSOLIDADAS (Supabase / PostgreSQL)
-- ============================================================================
-- Gerado a partir do documento "Modelagem de Dados — Garmin Training Hub"
-- + nova funcionalidade de Blog / Novidades / Casos Reais.
--
-- ORDEM DE EXECUÇÃO (este arquivo já respeita a ordem correta de dependência):
--   0. Extensões e funções utilitárias genéricas
--   1. Tabelas independentes (brands, roles, stores)
--   2. Profiles + store_leaders
--   3. Domínio de Conteúdo (trails, zones, modules, lessons, attachments, checkpoints)
--   4. Domínio de Quizzes
--   5. Domínio de Games
--   6. Domínio de Progresso
--   7. Domínio de Gamificação
--   8. Domínio de Certificações
--   9. Domínio de Analytics e Auditoria
--  10. Nova funcionalidade: Blog / Novidades / Casos Reais
--  11. Functions e Triggers de regra de negócio
--  12. Row Level Security (RLS) — habilitação e políticas
--  13. Views e Materialized Views
--  14. Seeds mínimos e refresh inicial das materialized views
--
-- Pode ser colado e executado de uma vez no SQL Editor do Supabase.
-- ============================================================================


-- ============================================================================
-- 0. EXTENSÕES E FUNÇÕES UTILITÁRIAS GENÉRICAS
-- ============================================================================

-- Necessária para gen_random_uuid()
create extension if not exists "pgcrypto";

-- Função genérica reaproveitada por todas as tabelas que têm updated_at
create or replace function fn_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

comment on function fn_set_updated_at() is 'Atualiza automaticamente a coluna updated_at em qualquer UPDATE.';


-- ============================================================================
-- 1. TABELAS INDEPENDENTES — brands, roles, stores
-- ============================================================================

-- 1.1 brands: suporte multi-tenant (Garmin, Shokz, futuras marcas)
create table if not exists brands (
  id            uuid primary key default gen_random_uuid(),
  slug          text not null,
  name          text not null,
  logo_url      text,
  theme_config  jsonb not null default '{}'::jsonb,
  is_active     boolean not null default true,
  created_at    timestamptz not null default now(),
  constraint uq_brands_slug unique (slug)
);
comment on table brands is 'Marcas atendidas pela plataforma (multi-tenant).';

-- 1.2 roles: catálogo fechado de papéis
create table if not exists roles (
  id     smallint primary key,
  code   text not null,
  label  text not null,
  constraint uq_roles_code unique (code)
);
comment on table roles is 'Catálogo fechado de papéis: collaborator, leader, admin.';

insert into roles (id, code, label) values
  (1, 'collaborator', 'Colaborador'),
  (2, 'leader',       'Líder'),
  (3, 'admin',        'Administrador')
on conflict (id) do nothing;

-- 1.3 stores: unidade/loja
create table if not exists stores (
  id          uuid primary key default gen_random_uuid(),
  brand_id    uuid not null references brands(id) on delete restrict,
  name        text not null,
  code        text not null,
  region      text,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  constraint uq_stores_brand_code unique (brand_id, code)
);
create index if not exists idx_stores_brand on stores(brand_id);
comment on table stores is 'Lojas/unidades usadas para ranking e escopo de visibilidade do líder.';


-- ============================================================================
-- 2. PROFILES + STORE_LEADERS
-- ============================================================================

-- 2.1 profiles: perfil de aplicação, 1:1 com auth.users
create table if not exists profiles (
  id                     uuid primary key references auth.users(id) on delete cascade,
  brand_id               uuid references brands(id),
  store_id               uuid references stores(id),
  role_id                smallint not null references roles(id),
  full_name              text not null,
  username               text not null,
  avatar_url             text,
  emoji                  text,
  phrase                 text,
  job_title              text,
  hired_at               date,
  must_change_password   boolean not null default true,
  is_guest               boolean not null default false,
  status                 text not null default 'active',
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),
  deleted_at             timestamptz,
  constraint uq_profiles_username unique (username),
  constraint chk_profiles_status check (status in ('active','inactive','suspended'))
);
create index if not exists idx_profiles_store        on profiles(store_id);
create index if not exists idx_profiles_role         on profiles(role_id);
create index if not exists idx_profiles_brand        on profiles(brand_id);
create index if not exists idx_profiles_store_role   on profiles(store_id, role_id);
comment on table profiles is 'Nó central do grafo — quase toda tabela de progresso/gamificação referencia profiles.id.';

drop trigger if exists trg_profiles_updated_at on profiles;
create trigger trg_profiles_updated_at
before update on profiles
for each row execute function fn_set_updated_at();

-- 2.2 store_leaders: um líder pode responder por mais de uma loja
create table if not exists store_leaders (
  leader_id    uuid not null references profiles(id) on delete cascade,
  store_id     uuid not null references stores(id) on delete cascade,
  assigned_at  timestamptz not null default now(),
  constraint pk_store_leaders primary key (leader_id, store_id)
);
comment on table store_leaders is 'Junção N:N entre líderes e lojas sob sua gestão.';

-- Garante, via trigger, que leader_id de fato tenha o papel 'leader'
create or replace function fn_check_store_leader_role()
returns trigger
language plpgsql
as $$
begin
  if not exists (
    select 1
    from profiles p
    join roles r on r.id = p.role_id
    where p.id = new.leader_id
      and r.code = 'leader'
  ) then
    raise exception 'O usuário % não possui papel de Líder e não pode ser vinculado a uma loja como líder.', new.leader_id;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_store_leaders_check on store_leaders;
create trigger trg_store_leaders_check
before insert or update on store_leaders
for each row execute function fn_check_store_leader_role();


-- ============================================================================
-- 3. DOMÍNIO: CONTEÚDO (trilhas, zonas, módulos, aulas)
-- ============================================================================

-- 3.1 trails
create table if not exists trails (
  id            uuid primary key default gen_random_uuid(),
  brand_id      uuid not null references brands(id),
  slug          text not null,
  name          text not null,
  description   text,
  cover_url     text,
  order_index   integer not null default 0,
  is_published  boolean not null default false,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint uq_trails_brand_slug unique (brand_id, slug)
);
create index if not exists idx_trails_brand_order on trails(brand_id, order_index);
comment on table trails is 'Trilha de carreira (Explorador → Corredor → Maratonista → Triatleta), agora como dado.';

drop trigger if exists trg_trails_updated_at on trails;
create trigger trg_trails_updated_at
before update on trails
for each row execute function fn_set_updated_at();

-- 3.2 zones
create table if not exists zones (
  id              uuid primary key default gen_random_uuid(),
  trail_id        uuid not null references trails(id) on delete cascade,
  name            text not null,
  banner_message  text,
  free_order      boolean not null default false,
  order_index     integer not null default 0,
  unlock_rule     jsonb not null default '{}'::jsonb,
  constraint uq_zones_trail_order unique (trail_id, order_index)
);
create index if not exists idx_zones_trail on zones(trail_id);
comment on table zones is 'Zona dentro de uma trilha, com suporte a free_order (Circuito de Desafios).';

-- 3.3 modules
create table if not exists modules (
  id                 uuid primary key default gen_random_uuid(),
  zone_id            uuid not null references zones(id) on delete cascade,
  slug               text not null,
  title              text not null,
  summary            text,
  estimated_minutes  integer,
  order_index        integer not null default 0,
  is_published       boolean not null default false,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  constraint uq_modules_slug unique (slug)
);
create index if not exists idx_modules_zone_order on modules(zone_id, order_index);
comment on table modules is 'Conteúdo educacional — um módulo é um tipo de checkpoint.';

drop trigger if exists trg_modules_updated_at on modules;
create trigger trg_modules_updated_at
before update on modules
for each row execute function fn_set_updated_at();

-- 3.4 lessons
create table if not exists lessons (
  id            uuid primary key default gen_random_uuid(),
  module_id     uuid not null references modules(id) on delete cascade,
  title         text not null,
  content_type  text not null,
  body          jsonb,
  order_index   integer not null default 0,
  is_published  boolean not null default false,
  constraint chk_lessons_content_type check (content_type in ('text','video','interactive','case_study'))
);
create index if not exists idx_lessons_module_order on lessons(module_id, order_index);
comment on table lessons is 'Granularidade abaixo do módulo — permite "continuar de onde parou" fino.';

-- 3.5 attachments
create table if not exists attachments (
  id            uuid primary key default gen_random_uuid(),
  lesson_id     uuid references lessons(id) on delete cascade,
  module_id     uuid references modules(id) on delete cascade,
  bucket        text not null,
  storage_path  text not null,
  file_type     text not null,
  uploaded_by   uuid references profiles(id),
  created_at    timestamptz not null default now(),
  constraint chk_attachments_owner check (lesson_id is not null or module_id is not null),
  constraint chk_attachments_type  check (file_type in ('image','video','pdf','doc'))
);
create index if not exists idx_attachments_lesson on attachments(lesson_id);
create index if not exists idx_attachments_module on attachments(module_id);

-- 3.6 checkpoints (indireção que unifica módulo/quiz/game)
-- Observação: a FK "polimórfica" (reference_id) não existe nativamente no Postgres,
-- por isso a integridade é garantida via trigger (fn_validate_checkpoint_reference),
-- criada mais abaixo, depois que as tabelas quizzes/games já existirem.
create table if not exists checkpoints (
  id               uuid primary key default gen_random_uuid(),
  zone_id          uuid not null references zones(id) on delete cascade,
  checkpoint_type  text not null,
  reference_id     uuid not null,
  order_index      integer not null default 0,
  is_required      boolean not null default true,
  constraint chk_checkpoints_type check (checkpoint_type in ('module','quiz','game'))
);
create index if not exists idx_checkpoints_zone_order on checkpoints(zone_id, order_index);
create index if not exists idx_checkpoints_type_ref    on checkpoints(checkpoint_type, reference_id);
comment on table checkpoints is 'Unifica módulo, quiz e game como "etapas" de uma zona.';


-- ============================================================================
-- 4. DOMÍNIO: QUIZZES
-- ============================================================================

-- 4.1 quizzes
create table if not exists quizzes (
  id                  uuid primary key default gen_random_uuid(),
  brand_id            uuid not null references brands(id),
  slug                text not null,
  title               text not null,
  passing_score_pct   numeric(5,2) not null default 70.00,
  time_limit_seconds  integer,
  max_attempts        integer, -- null = ilimitado
  is_published        boolean not null default false,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  constraint uq_quizzes_brand_slug unique (brand_id, slug),
  constraint chk_quizzes_score check (passing_score_pct between 0 and 100)
);
comment on table quizzes is 'Definição do quiz (substitui os objetos quizData* hardcoded).';

drop trigger if exists trg_quizzes_updated_at on quizzes;
create trigger trg_quizzes_updated_at
before update on quizzes
for each row execute function fn_set_updated_at();

-- 4.2 questions
create table if not exists questions (
  id            uuid primary key default gen_random_uuid(),
  quiz_id       uuid not null references quizzes(id) on delete cascade,
  body          text not null,
  explanation   text,
  order_index   integer not null default 0,
  is_active     boolean not null default true
);
create index if not exists idx_questions_quiz_order on questions(quiz_id, order_index);

-- 4.3 alternatives
create table if not exists alternatives (
  id            uuid primary key default gen_random_uuid(),
  question_id   uuid not null references questions(id) on delete cascade,
  body          text not null,
  is_correct    boolean not null default false,
  feedback      text,
  order_index   integer not null default 0
);
create index if not exists idx_alternatives_question on alternatives(question_id);
comment on table alternatives is 'is_correct nunca deve ser exposto ao Colaborador antes de responder — ver v_alternatives_public.';

-- 4.4 quiz_attempts — fonte de verdade para nota/aprovação; score/passed sempre calculados no servidor
create table if not exists quiz_attempts (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references profiles(id),
  quiz_id          uuid not null references quizzes(id),
  started_at       timestamptz not null default now(),
  finished_at      timestamptz,
  score_pct        numeric(5,2),
  passed           boolean,
  attempt_number   integer,
  duration_seconds integer
);
create index if not exists idx_quiz_attempts_user_quiz    on quiz_attempts(user_id, quiz_id);
create index if not exists idx_quiz_attempts_quiz_passed  on quiz_attempts(quiz_id, passed);
create index if not exists idx_quiz_attempts_finished     on quiz_attempts(finished_at);
comment on table quiz_attempts is 'score_pct, passed, attempt_number e duration_seconds nunca são inseridos pelo cliente — preenchidos por fn_finalize_quiz_attempt.';

-- 4.5 quiz_answers — resposta congelada no momento em que foi dada
create table if not exists quiz_answers (
  id              uuid primary key default gen_random_uuid(),
  attempt_id      uuid not null references quiz_attempts(id) on delete cascade,
  question_id     uuid not null references questions(id),
  alternative_id  uuid not null references alternatives(id),
  is_correct      boolean not null,
  answered_at     timestamptz not null default now(),
  constraint uq_quiz_answers_attempt_question unique (attempt_id, question_id)
);
create index if not exists idx_quiz_answers_question on quiz_answers(question_id);
create index if not exists idx_quiz_answers_attempt  on quiz_answers(attempt_id);


-- ============================================================================
-- 5. DOMÍNIO: GAMES
-- ============================================================================

create table if not exists games (
  id          uuid primary key default gen_random_uuid(),
  brand_id    uuid not null references brands(id),
  slug        text not null,
  title       text not null,
  config      jsonb not null default '{}'::jsonb,
  is_published boolean not null default false,
  constraint uq_games_slug unique (slug)
);

create table if not exists game_sessions (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references profiles(id),
  game_id        uuid not null references games(id),
  started_at     timestamptz not null default now(),
  finished_at    timestamptz,
  rounds_played  integer,
  result_summary jsonb
);
create index if not exists idx_game_sessions_user_game on game_sessions(user_id, game_id);
create index if not exists idx_game_sessions_finished  on game_sessions(finished_at);

create table if not exists game_scores (
  id            uuid primary key default gen_random_uuid(),
  session_id    uuid not null references game_sessions(id),
  score         integer not null,
  accuracy_pct  numeric(5,2),
  rank_at_time  integer,
  constraint uq_game_scores_session unique (session_id)
);
create index if not exists idx_game_scores_score on game_scores(score);

-- Agora que quizzes e games existem, criamos a trigger de validação de checkpoints
create or replace function fn_validate_checkpoint_reference()
returns trigger
language plpgsql
as $$
begin
  if new.checkpoint_type = 'module' then
    if not exists (select 1 from modules where id = new.reference_id) then
      raise exception 'reference_id % não existe na tabela modules', new.reference_id;
    end if;
  elsif new.checkpoint_type = 'quiz' then
    if not exists (select 1 from quizzes where id = new.reference_id) then
      raise exception 'reference_id % não existe na tabela quizzes', new.reference_id;
    end if;
  elsif new.checkpoint_type = 'game' then
    if not exists (select 1 from games where id = new.reference_id) then
      raise exception 'reference_id % não existe na tabela games', new.reference_id;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_validate_checkpoint_reference on checkpoints;
create trigger trg_validate_checkpoint_reference
before insert or update on checkpoints
for each row execute function fn_validate_checkpoint_reference();

-- Garante exatamente uma alternativa correta por pergunta
create or replace function fn_enforce_single_correct_alternative()
returns trigger
language plpgsql
as $$
begin
  if new.is_correct then
    update alternatives
       set is_correct = false
     where question_id = new.question_id
       and id <> new.id
       and is_correct = true;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_enforce_single_correct_alternative on alternatives;
create trigger trg_enforce_single_correct_alternative
before insert or update on alternatives
for each row execute function fn_enforce_single_correct_alternative();


-- ============================================================================
-- 6. DOMÍNIO: PROGRESSO
-- ============================================================================

-- 6.1 user_progress — estado ATUAL do usuário em cada checkpoint
create table if not exists user_progress (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references profiles(id),
  checkpoint_id  uuid not null references checkpoints(id),
  status         text not null default 'locked',
  completed_at   timestamptz,
  updated_at     timestamptz not null default now(),
  constraint uq_user_progress unique (user_id, checkpoint_id),
  constraint chk_user_progress_status check (status in ('locked','unlocked','in_progress','completed'))
);
create index if not exists idx_user_progress_user_status on user_progress(user_id, status);
create index if not exists idx_user_progress_checkpoint  on user_progress(checkpoint_id);
comment on table user_progress is 'Escrito por trigger a partir de quiz_attempts/lesson_progress/game_sessions — nunca direto pelo frontend.';

-- 6.2 lesson_progress — granularidade fina de "continuar de onde parou"
create table if not exists lesson_progress (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references profiles(id),
  lesson_id      uuid not null references lessons(id),
  progress_pct   numeric(5,2) not null default 0,
  last_position  jsonb,
  completed_at   timestamptz,
  updated_at     timestamptz not null default now(),
  constraint uq_lesson_progress unique (user_id, lesson_id)
);
create index if not exists idx_lesson_progress_user_updated on lesson_progress(user_id, updated_at desc);

-- 6.3 checkpoint_progress — log de eventos (histórico), distinto do estado atual
create table if not exists checkpoint_progress (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references profiles(id),
  checkpoint_id  uuid not null references checkpoints(id),
  from_status    text,
  to_status      text,
  changed_at     timestamptz not null default now()
);
create index if not exists idx_checkpoint_progress_user       on checkpoint_progress(user_id, changed_at);
create index if not exists idx_checkpoint_progress_checkpoint on checkpoint_progress(checkpoint_id, changed_at);


-- ============================================================================
-- 7. DOMÍNIO: GAMIFICAÇÃO
-- ============================================================================

-- 7.1 points_ledger — livro-razão de pontos/XP, nunca um total editado manualmente
create table if not exists points_ledger (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references profiles(id),
  source_type  text not null,
  source_id    uuid,
  points       integer not null,
  reason       text,
  created_by   uuid references profiles(id),
  created_at   timestamptz not null default now(),
  constraint chk_points_ledger_source check (source_type in ('quiz','module','game','badge','certification','manual_adjustment')),
  constraint chk_points_ledger_manual_reason check (source_type <> 'manual_adjustment' or reason is not null)
);
create index if not exists idx_points_ledger_user_created on points_ledger(user_id, created_at);
comment on table points_ledger is 'XP total do usuário = SUM(points) — nunca um campo próprio. Ver v_user_total_points.';

-- 7.2 badges + user_badges
create table if not exists badges (
  id           uuid primary key default gen_random_uuid(),
  brand_id     uuid not null references brands(id),
  slug         text not null,
  title        text not null,
  description  text,
  icon_url     text,
  rule         jsonb not null default '{}'::jsonb,
  constraint uq_badges_slug unique (slug)
);

create table if not exists user_badges (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references profiles(id),
  badge_id   uuid not null references badges(id),
  earned_at  timestamptz not null default now(),
  constraint uq_user_badges unique (user_id, badge_id)
);
create index if not exists idx_user_badges_user on user_badges(user_id);

-- 7.3 achievements + user_achievements
create table if not exists achievements (
  id           uuid primary key default gen_random_uuid(),
  brand_id     uuid not null references brands(id),
  slug         text not null,
  title        text not null,
  description  text,
  rule         jsonb not null default '{}'::jsonb,
  tier         text,
  constraint uq_achievements_slug unique (slug),
  constraint chk_achievements_tier check (tier is null or tier in ('bronze','silver','gold'))
);

create table if not exists user_achievements (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references profiles(id),
  achievement_id  uuid not null references achievements(id),
  earned_at       timestamptz not null default now(),
  constraint uq_user_achievements unique (user_id, achievement_id)
);
create index if not exists idx_user_achievements_user on user_achievements(user_id);

-- 7.4 streaks (1:1 com o usuário)
create table if not exists streaks (
  id                    uuid primary key default gen_random_uuid(),
  user_id               uuid not null references profiles(id),
  current_streak_days   integer not null default 0,
  longest_streak_days   integer not null default 0,
  last_activity_date    date,
  updated_at            timestamptz not null default now(),
  constraint uq_streaks_user unique (user_id)
);

-- 7.5 leaderboard — snapshot periódico (não é fonte de verdade)
create table if not exists leaderboard (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references profiles(id),
  scope_type     text not null,
  scope_id       uuid,
  period         text not null, -- ex: '2026-07' ou 'all_time'
  total_points   integer not null default 0,
  rank_position  integer,
  computed_at    timestamptz not null default now(),
  constraint chk_leaderboard_scope check (scope_type in ('global','store','role','brand'))
);
create index if not exists idx_leaderboard_scope_period_rank
  on leaderboard(scope_type, scope_id, period, rank_position);
comment on table leaderboard is 'Snapshot histórico, gerado por job — nunca escrito manualmente.';


-- ============================================================================
-- 8. DOMÍNIO: CERTIFICAÇÕES
-- ============================================================================

create table if not exists certifications (
  id                       uuid primary key default gen_random_uuid(),
  brand_id                 uuid not null references brands(id),
  trail_id                 uuid references trails(id),
  slug                     text not null,
  title                    text not null,
  criteria                 jsonb not null default '{}'::jsonb,
  certificate_template_url text,
  constraint uq_certifications_slug unique (slug)
);

create table if not exists user_certifications (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null references profiles(id),
  certification_id   uuid not null references certifications(id),
  issued_at          timestamptz not null default now(),
  certificate_url    text,
  revoked_at         timestamptz, -- permite revogação sem apagar histórico
  constraint uq_user_certifications unique (user_id, certification_id)
);
create index if not exists idx_user_certifications_user on user_certifications(user_id);
create index if not exists idx_user_certifications_cert on user_certifications(certification_id);


-- ============================================================================
-- 9. DOMÍNIO: ANALYTICS E AUDITORIA
-- ============================================================================

create table if not exists login_events (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references profiles(id),
  logged_in_at   timestamptz not null default now(),
  device_info    jsonb,
  ip_hash        text
);
create index if not exists idx_login_events_user_time on login_events(user_id, logged_in_at desc);

create table if not exists study_sessions (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references profiles(id),
  started_at        timestamptz not null default now(),
  ended_at          timestamptz,
  duration_seconds  integer
);
create index if not exists idx_study_sessions_user_started on study_sessions(user_id, started_at);

create table if not exists page_views (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null references profiles(id),
  study_session_id   uuid references study_sessions(id),
  panel_id           text,
  entity_type        text,
  entity_id          uuid,
  viewed_at          timestamptz not null default now()
);
create index if not exists idx_page_views_user_viewed on page_views(user_id, viewed_at);
create index if not exists idx_page_views_entity       on page_views(entity_type, entity_id);

create table if not exists activity_log (
  id           uuid primary key default gen_random_uuid(),
  actor_id     uuid references profiles(id),
  subject_id   uuid references profiles(id),
  event_type   text not null,
  payload      jsonb not null default '{}'::jsonb,
  created_at   timestamptz not null default now()
);
create index if not exists idx_activity_log_subject_created on activity_log(subject_id, created_at);
create index if not exists idx_activity_log_type_created    on activity_log(event_type, created_at);


-- ============================================================================
-- 10. NOVA FUNCIONALIDADE: BLOG / NOVIDADES / CASOS REAIS
-- ============================================================================
-- Funcionalidade adicional (fora do escopo original da modelagem), pensada
-- para a Gestora publicar novidades de produto, casos reais de venda e
-- comunicados — visível para toda a equipe autenticada.

create table if not exists blog_posts (
  id             uuid primary key default gen_random_uuid(),
  title          text not null,
  content        text not null,           -- conteúdo longo (markdown ou HTML simples)
  category       text not null default 'Novidade',
  banner_url     text,
  author_id      uuid references auth.users(id),
  is_published   boolean not null default true,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  constraint chk_blog_posts_category check (category in ('Caso Real','Novidade','Comunicado','Dica'))
);
create index if not exists idx_blog_posts_created  on blog_posts(created_at desc);
create index if not exists idx_blog_posts_category on blog_posts(category);
comment on table blog_posts is 'Blog interno de novidades, casos reais e comunicados — leitura livre, escrita só de admin.';

drop trigger if exists trg_blog_posts_updated_at on blog_posts;
create trigger trg_blog_posts_updated_at
before update on blog_posts
for each row execute function fn_set_updated_at();


-- ============================================================================
-- 11. FUNCTIONS E TRIGGERS DE REGRA DE NEGÓCIO
-- ============================================================================
-- (fn_set_updated_at, fn_check_store_leader_role, fn_validate_checkpoint_reference
--  e fn_enforce_single_correct_alternative já foram criadas acima, próximas às
--  tabelas a que se referem, para manter o arquivo lógico de cima para baixo.)

-- 11.1 fn_finalize_quiz_attempt
-- Calcula score_pct, passed, attempt_number e duration_seconds a partir de
-- quiz_answers — nunca confia em valor vindo do cliente. Deve ser chamada
-- pela Edge Function "finalize-quiz-attempt" quando o colaborador termina o quiz.
create or replace function fn_finalize_quiz_attempt(p_attempt_id uuid)
returns quiz_attempts
language plpgsql
security definer
set search_path = public
as $$
declare
  v_attempt        quiz_attempts;
  v_total_answers   integer;
  v_correct_answers integer;
  v_passing_pct     numeric(5,2);
  v_score_pct       numeric(5,2);
  v_attempt_number  integer;
begin
  select * into v_attempt from quiz_attempts where id = p_attempt_id;
  if not found then
    raise exception 'quiz_attempt % não encontrado', p_attempt_id;
  end if;

  select count(*), count(*) filter (where is_correct)
    into v_total_answers, v_correct_answers
    from quiz_answers
   where attempt_id = p_attempt_id;

  if v_total_answers = 0 then
    v_score_pct := 0;
  else
    v_score_pct := round((v_correct_answers::numeric / v_total_answers::numeric) * 100, 2);
  end if;

  select passing_score_pct into v_passing_pct from quizzes where id = v_attempt.quiz_id;

  select count(*) + 1 into v_attempt_number
    from quiz_attempts
   where user_id = v_attempt.user_id
     and quiz_id = v_attempt.quiz_id
     and finished_at is not null
     and id <> p_attempt_id;

  update quiz_attempts
     set finished_at      = now(),
         score_pct        = v_score_pct,
         passed           = (v_score_pct >= coalesce(v_passing_pct, 70)),
         attempt_number    = v_attempt_number,
         duration_seconds = extract(epoch from (now() - v_attempt.started_at))::integer
   where id = p_attempt_id
  returning * into v_attempt;

  return v_attempt;
end;
$$;

comment on function fn_finalize_quiz_attempt(uuid) is
  'Fecha a tentativa e calcula nota/aprovação no servidor — chamada pela Edge Function finalize-quiz-attempt.';

-- 11.2 fn_award_points_on_pass
-- Dispara quando quiz_attempts.passed vira true: concede XP, mas apenas na
-- primeira aprovação daquele quiz pelo usuário (RN 6.1 — sem XP repetido).
create or replace function fn_award_points_on_pass()
returns trigger
language plpgsql
as $$
declare
  v_already_passed boolean;
  v_points integer;
begin
  if new.passed is distinct from true then
    return new;
  end if;
  if tg_op = 'UPDATE' and old.passed is true then
    return new; -- já estava aprovado, não repete
  end if;

  select exists (
    select 1 from quiz_attempts
     where user_id = new.user_id
       and quiz_id = new.quiz_id
       and passed = true
       and id <> new.id
  ) into v_already_passed;

  if v_already_passed then
    return new; -- já tinha sido aprovado antes nesta questão — não gera XP de novo
  end if;

  -- valor padrão simples; a Gestora pode sofisticar isso depois via tabela de configuração
  select case when max_attempts is not null then 200 else 100 end
    into v_points
    from quizzes
   where id = new.quiz_id;

  insert into points_ledger (user_id, source_type, source_id, points, reason)
  values (new.user_id, 'quiz', new.id, coalesce(v_points, 100), 'Aprovação em quiz (primeira vez)');

  return new;
end;
$$;

drop trigger if exists trg_award_points_on_pass on quiz_attempts;
create trigger trg_award_points_on_pass
after insert or update on quiz_attempts
for each row execute function fn_award_points_on_pass();

-- 11.3 fn_update_user_progress
-- Atualiza user_progress.status a partir de quiz_attempts aprovados,
-- lesson_progress 100% ou game_sessions concluídas.
create or replace function fn_update_user_progress_from_quiz()
returns trigger
language plpgsql
as $$
declare
  v_checkpoint_id uuid;
begin
  if new.passed is distinct from true then
    return new;
  end if;

  select id into v_checkpoint_id
    from checkpoints
   where checkpoint_type = 'quiz'
     and reference_id = new.quiz_id
   limit 1;

  if v_checkpoint_id is not null then
    insert into user_progress (user_id, checkpoint_id, status, completed_at)
    values (new.user_id, v_checkpoint_id, 'completed', now())
    on conflict (user_id, checkpoint_id)
    do update set status = 'completed', completed_at = now(), updated_at = now()
    where user_progress.status is distinct from 'completed';
  end if;

  return new;
end;
$$;

drop trigger if exists trg_update_user_progress_from_quiz on quiz_attempts;
create trigger trg_update_user_progress_from_quiz
after insert or update on quiz_attempts
for each row execute function fn_update_user_progress_from_quiz();

create or replace function fn_update_user_progress_from_lesson()
returns trigger
language plpgsql
as $$
declare
  v_module_id     uuid;
  v_checkpoint_id uuid;
begin
  if new.progress_pct < 100 then
    return new;
  end if;

  select module_id into v_module_id from lessons where id = new.lesson_id;

  select id into v_checkpoint_id
    from checkpoints
   where checkpoint_type = 'module'
     and reference_id = v_module_id
   limit 1;

  if v_checkpoint_id is not null then
    insert into user_progress (user_id, checkpoint_id, status, completed_at)
    values (new.user_id, v_checkpoint_id, 'completed', now())
    on conflict (user_id, checkpoint_id)
    do update set status = 'completed', completed_at = now(), updated_at = now()
    where user_progress.status is distinct from 'completed';
  end if;

  return new;
end;
$$;

drop trigger if exists trg_update_user_progress_from_lesson on lesson_progress;
create trigger trg_update_user_progress_from_lesson
after insert or update on lesson_progress
for each row execute function fn_update_user_progress_from_lesson();

create or replace function fn_update_user_progress_from_game()
returns trigger
language plpgsql
as $$
declare
  v_checkpoint_id uuid;
begin
  if new.finished_at is null then
    return new;
  end if;

  select id into v_checkpoint_id
    from checkpoints
   where checkpoint_type = 'game'
     and reference_id = new.game_id
   limit 1;

  if v_checkpoint_id is not null then
    insert into user_progress (user_id, checkpoint_id, status, completed_at)
    values (new.user_id, v_checkpoint_id, 'completed', now())
    on conflict (user_id, checkpoint_id)
    do update set status = 'completed', completed_at = now(), updated_at = now()
    where user_progress.status is distinct from 'completed';
  end if;

  return new;
end;
$$;

drop trigger if exists trg_update_user_progress_from_game on game_sessions;
create trigger trg_update_user_progress_from_game
after insert or update on game_sessions
for each row execute function fn_update_user_progress_from_game();

-- 11.4 fn_log_checkpoint_change — alimenta o histórico checkpoint_progress
create or replace function fn_log_checkpoint_change()
returns trigger
language plpgsql
as $$
begin
  if old.status is distinct from new.status then
    insert into checkpoint_progress (user_id, checkpoint_id, from_status, to_status)
    values (new.user_id, new.checkpoint_id, old.status, new.status);
  end if;
  return new;
end;
$$;

drop trigger if exists trg_log_checkpoint_change on user_progress;
create trigger trg_log_checkpoint_change
after update on user_progress
for each row execute function fn_log_checkpoint_change();

-- 11.5 fn_check_badge_rules
-- Avalia regras simples de badges/achievements baseadas em contagem de eventos.
-- Suporta regras no formato: {"action":"quiz_pass","count":3,"scope":"any"}
-- Para regras mais elaboradas, a Gestora deve ajustar esta function conforme
-- os badges cadastrados (é o ponto de extensão do "zero código" na interface).
create or replace function fn_check_badge_rules()
returns trigger
language plpgsql
as $$
declare
  v_user_id uuid;
  v_badge record;
  v_achievement record;
  v_count integer;
begin
  v_user_id := coalesce(new.user_id, null);
  if v_user_id is null then
    return new;
  end if;

  -- badges cuja regra seja "aprovar N quizzes"
  for v_badge in
    select * from badges
     where rule ->> 'action' = 'quiz_pass'
  loop
    select count(*) into v_count
      from quiz_attempts
     where user_id = v_user_id
       and passed = true;

    if v_count >= coalesce((v_badge.rule ->> 'count')::integer, 999999) then
      insert into user_badges (user_id, badge_id)
      values (v_user_id, v_badge.id)
      on conflict (user_id, badge_id) do nothing;
    end if;
  end loop;

  -- achievements cuja regra seja "concluir N checkpoints"
  for v_achievement in
    select * from achievements
     where rule ->> 'action' = 'checkpoints_completed'
  loop
    select count(*) into v_count
      from user_progress
     where user_id = v_user_id
       and status = 'completed';

    if v_count >= coalesce((v_achievement.rule ->> 'count')::integer, 999999) then
      insert into user_achievements (user_id, achievement_id)
      values (v_user_id, v_achievement.id)
      on conflict (user_id, achievement_id) do nothing;
    end if;
  end loop;

  return new;
end;
$$;

drop trigger if exists trg_check_badge_rules_points on points_ledger;
create trigger trg_check_badge_rules_points
after insert on points_ledger
for each row execute function fn_check_badge_rules();

drop trigger if exists trg_check_badge_rules_progress on user_progress;
create trigger trg_check_badge_rules_progress
after insert or update on user_progress
for each row execute function fn_check_badge_rules();

-- 11.6 fn_issue_certification
-- Quando a trilha inteira é concluída (todos os checkpoints obrigatórios das
-- zonas dessa trilha), emite a certificação automaticamente.
create or replace function fn_issue_certification()
returns trigger
language plpgsql
as $$
declare
  v_trail_id uuid;
  v_cert record;
  v_total_required   integer;
  v_completed_required integer;
begin
  if new.status <> 'completed' then
    return new;
  end if;

  select z.trail_id into v_trail_id
    from checkpoints c
    join zones z on z.id = c.zone_id
   where c.id = new.checkpoint_id;

  if v_trail_id is null then
    return new;
  end if;

  for v_cert in
    select * from certifications where trail_id = v_trail_id
  loop
    select count(*) into v_total_required
      from checkpoints c
      join zones z on z.id = c.zone_id
     where z.trail_id = v_trail_id
       and c.is_required = true;

    select count(*) into v_completed_required
      from checkpoints c
      join zones z on z.id = c.zone_id
      join user_progress up on up.checkpoint_id = c.id and up.user_id = new.user_id
     where z.trail_id = v_trail_id
       and c.is_required = true
       and up.status = 'completed';

    if v_total_required > 0 and v_completed_required = v_total_required then
      insert into user_certifications (user_id, certification_id)
      values (new.user_id, v_cert.id)
      on conflict (user_id, certification_id) do nothing;

      insert into points_ledger (user_id, source_type, source_id, points, reason)
      values (new.user_id, 'certification', v_cert.id, 300, 'Emissão automática de certificação');
    end if;
  end loop;

  return new;
end;
$$;

drop trigger if exists trg_issue_certification on user_progress;
create trigger trg_issue_certification
after update on user_progress
for each row execute function fn_issue_certification();

-- 11.7 fn_update_streak — chamada por job diário (Edge Function compute-streaks)
create or replace function fn_update_streak(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_had_activity_today boolean;
  v_streak streaks;
  v_yesterday date := (current_date - interval '1 day')::date;
  v_is_weekend_today boolean := extract(isodow from current_date) in (6,7);
begin
  select exists (
    select 1 from study_sessions
     where user_id = p_user_id
       and started_at::date = current_date
  ) into v_had_activity_today;

  select * into v_streak from streaks where user_id = p_user_id;
  if not found then
    insert into streaks (user_id, current_streak_days, longest_streak_days, last_activity_date)
    values (p_user_id, 0, 0, null)
    returning * into v_streak;
  end if;

  if v_had_activity_today then
    if v_streak.last_activity_date = v_yesterday or v_streak.last_activity_date = current_date then
      update streaks
         set current_streak_days = current_streak_days + case when last_activity_date = current_date then 0 else 1 end,
             last_activity_date  = current_date,
             longest_streak_days = greatest(longest_streak_days, current_streak_days + 1),
             updated_at = now()
       where user_id = p_user_id;
    else
      update streaks
         set current_streak_days = 1,
             last_activity_date  = current_date,
             longest_streak_days = greatest(longest_streak_days, 1),
             updated_at = now()
       where user_id = p_user_id;
    end if;
  else
    -- sem atividade hoje: só quebra o streak se NÃO for fim de semana (RN 6.5 — pausa em fim de semana)
    if not v_is_weekend_today and v_streak.last_activity_date < v_yesterday then
      update streaks
         set current_streak_days = 0,
             updated_at = now()
       where user_id = p_user_id;
    end if;
  end if;
end;
$$;

comment on function fn_update_streak(uuid) is
  'Recalcula o streak de um usuário — chamada pelo cron diário compute-streaks (RN 6.5: pausa em fins de semana).';

-- 11.8 fn_soft_delete_profile — desligamento nunca é DELETE físico
create or replace function fn_soft_delete_profile(p_profile_id uuid, p_actor_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update profiles
     set status = 'inactive',
         deleted_at = now(),
         updated_at = now()
   where id = p_profile_id;

  insert into activity_log (actor_id, subject_id, event_type, payload)
  values (p_actor_id, p_profile_id, 'profile_soft_deleted', jsonb_build_object('at', now()));
end;
$$;

comment on function fn_soft_delete_profile(uuid, uuid) is
  'Desligamento de colaborador: soft delete, nunca DELETE físico. Preserva histórico e certificações.';


-- ============================================================================
-- 12. ROW LEVEL SECURITY (RLS)
-- ============================================================================
-- Regra geral: RLS habilitado em 100% das tabelas, nada fica aberto por omissão.

-- 12.1 Funções auxiliares de autorização
create or replace function fn_is_admin()
returns boolean
language sql
stable
as $$
  select exists (
    select 1 from profiles p
    join roles r on r.id = p.role_id
    where p.id = auth.uid() and r.code = 'admin'
  );
$$;

create or replace function fn_is_leader()
returns boolean
language sql
stable
as $$
  select exists (
    select 1 from profiles p
    join roles r on r.id = p.role_id
    where p.id = auth.uid() and r.code = 'leader'
  );
$$;

create or replace function fn_leader_store_ids()
returns setof uuid
language sql
stable
as $$
  select store_id from store_leaders where leader_id = auth.uid();
$$;

-- 12.2 Habilitação de RLS em todas as tabelas
alter table brands               enable row level security;
alter table roles                enable row level security;
alter table stores               enable row level security;
alter table profiles             enable row level security;
alter table store_leaders        enable row level security;
alter table trails               enable row level security;
alter table zones                enable row level security;
alter table modules              enable row level security;
alter table lessons              enable row level security;
alter table attachments          enable row level security;
alter table checkpoints          enable row level security;
alter table quizzes              enable row level security;
alter table questions            enable row level security;
alter table alternatives         enable row level security;
alter table quiz_attempts        enable row level security;
alter table quiz_answers         enable row level security;
alter table games                enable row level security;
alter table game_sessions        enable row level security;
alter table game_scores          enable row level security;
alter table user_progress        enable row level security;
alter table lesson_progress      enable row level security;
alter table checkpoint_progress  enable row level security;
alter table points_ledger        enable row level security;
alter table badges               enable row level security;
alter table user_badges          enable row level security;
alter table achievements         enable row level security;
alter table user_achievements    enable row level security;
alter table streaks              enable row level security;
alter table leaderboard          enable row level security;
alter table certifications       enable row level security;
alter table user_certifications  enable row level security;
alter table login_events         enable row level security;
alter table study_sessions       enable row level security;
alter table page_views           enable row level security;
alter table activity_log         enable row level security;
alter table blog_posts           enable row level security;

-- 12.3 brands / stores / roles — leitura da própria marca/loja; admin total
create policy roles_select_all on roles
  for select using (true);

create policy brands_select_all on brands
  for select using (true);
create policy brands_admin_all on brands
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy stores_select_all on stores
  for select using (true);
create policy stores_admin_all on stores
  for all using (fn_is_admin()) with check (fn_is_admin());

-- 12.4 profiles
create policy profiles_select_own on profiles
  for select using (id = auth.uid());
create policy profiles_update_own on profiles
  for update using (id = auth.uid());
create policy profiles_select_leader on profiles
  for select using (fn_is_leader() and store_id in (select fn_leader_store_ids()));
create policy profiles_admin_all on profiles
  for all using (fn_is_admin()) with check (fn_is_admin());

-- 12.5 store_leaders
create policy store_leaders_select_own on store_leaders
  for select using (leader_id = auth.uid());
create policy store_leaders_admin_all on store_leaders
  for all using (fn_is_admin()) with check (fn_is_admin());

-- 12.6 Conteúdo (trails, zones, modules, lessons, quizzes, questions, games,
--      badges, achievements, certifications): select onde is_published=true
--      para colaborador/líder; admin CRUD total. zones/questions/checkpoints
--      não têm coluna própria is_published — herdam via join com a tabela pai.
create policy trails_select_published on trails
  for select using (is_published = true or fn_is_admin());
create policy trails_admin_all on trails
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy zones_select_via_trail on zones
  for select using (
    exists (select 1 from trails t where t.id = zones.trail_id and (t.is_published or fn_is_admin()))
  );
create policy zones_admin_all on zones
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy modules_select_published on modules
  for select using (is_published = true or fn_is_admin());
create policy modules_admin_all on modules
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy lessons_select_published on lessons
  for select using (is_published = true or fn_is_admin());
create policy lessons_admin_all on lessons
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy attachments_select_all on attachments
  for select using (true);
create policy attachments_admin_all on attachments
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy checkpoints_select_all on checkpoints
  for select using (true);
create policy checkpoints_admin_all on checkpoints
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy quizzes_select_published on quizzes
  for select using (is_published = true or fn_is_admin());
create policy quizzes_admin_all on quizzes
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy questions_select_all on questions
  for select using (true);
create policy questions_admin_all on questions
  for all using (fn_is_admin()) with check (fn_is_admin());

-- alternatives.is_correct nunca deve ser visível ao Colaborador antes de responder.
-- RLS é por linha, não por coluna — por isso restringimos a tabela base a
-- líder/admin e expomos o conteúdo "seguro" via view v_alternatives_public (seção 13).
create policy alternatives_select_leader_admin on alternatives
  for select using (fn_is_leader() or fn_is_admin());
create policy alternatives_admin_all on alternatives
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy games_select_published on games
  for select using (is_published = true or fn_is_admin());
create policy games_admin_all on games
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy badges_select_all on badges
  for select using (true);
create policy badges_admin_all on badges
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy achievements_select_all on achievements
  for select using (true);
create policy achievements_admin_all on achievements
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy certifications_select_all on certifications
  for select using (true);
create policy certifications_admin_all on certifications
  for all using (fn_is_admin()) with check (fn_is_admin());

-- 12.7 Execução do usuário: quiz_attempts / quiz_answers
create policy quiz_attempts_select_own on quiz_attempts
  for select using (user_id = auth.uid());
create policy quiz_attempts_insert_own on quiz_attempts
  for insert with check (user_id = auth.uid());
create policy quiz_attempts_select_leader on quiz_attempts
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = quiz_attempts.user_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy quiz_attempts_admin_all on quiz_attempts
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy quiz_answers_select_own on quiz_answers
  for select using (
    exists (select 1 from quiz_attempts qa where qa.id = quiz_answers.attempt_id and qa.user_id = auth.uid())
  );
create policy quiz_answers_insert_own on quiz_answers
  for insert with check (
    exists (select 1 from quiz_attempts qa where qa.id = quiz_answers.attempt_id and qa.user_id = auth.uid())
  );
create policy quiz_answers_select_leader on quiz_answers
  for select using (
    fn_is_leader() and exists (
      select 1 from quiz_attempts qa
      join profiles p on p.id = qa.user_id
      where qa.id = quiz_answers.attempt_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy quiz_answers_admin_all on quiz_answers
  for all using (fn_is_admin()) with check (fn_is_admin());

-- 12.8 game_sessions / game_scores — mesmo padrão de quiz_attempts
create policy game_sessions_select_own on game_sessions
  for select using (user_id = auth.uid());
create policy game_sessions_insert_own on game_sessions
  for insert with check (user_id = auth.uid());
create policy game_sessions_select_leader on game_sessions
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = game_sessions.user_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy game_sessions_admin_all on game_sessions
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy game_scores_select_own on game_scores
  for select using (
    exists (select 1 from game_sessions gs where gs.id = game_scores.session_id and gs.user_id = auth.uid())
  );
create policy game_scores_admin_all on game_scores
  for all using (fn_is_admin()) with check (fn_is_admin());

-- 12.9 user_progress / lesson_progress / checkpoint_progress
-- Select próprio; INSERT/UPDATE direto NÃO é permitido para colaborador —
-- as escritas acontecem só via as functions/triggers SECURITY DEFINER acima.
create policy user_progress_select_own on user_progress
  for select using (user_id = auth.uid());
create policy user_progress_select_leader on user_progress
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = user_progress.user_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy user_progress_admin_all on user_progress
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy lesson_progress_select_own on lesson_progress
  for select using (user_id = auth.uid());
create policy lesson_progress_insert_own on lesson_progress
  for insert with check (user_id = auth.uid());
create policy lesson_progress_update_own on lesson_progress
  for update using (user_id = auth.uid());
create policy lesson_progress_select_leader on lesson_progress
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = lesson_progress.user_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy lesson_progress_admin_all on lesson_progress
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy checkpoint_progress_select_own on checkpoint_progress
  for select using (user_id = auth.uid());
create policy checkpoint_progress_select_leader on checkpoint_progress
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = checkpoint_progress.user_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy checkpoint_progress_admin_all on checkpoint_progress
  for all using (fn_is_admin()) with check (fn_is_admin());

-- 12.10 points_ledger — select próprio, sem INSERT/UPDATE direto (só via trigger/function);
--       admin pode fazer ajuste manual, mas created_by é obrigatório (garantido pela CHECK constraint)
create policy points_ledger_select_own on points_ledger
  for select using (user_id = auth.uid());
create policy points_ledger_select_leader on points_ledger
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = points_ledger.user_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy points_ledger_admin_insert on points_ledger
  for insert with check (fn_is_admin() and created_by = auth.uid());
create policy points_ledger_admin_all on points_ledger
  for all using (fn_is_admin()) with check (fn_is_admin());

-- 12.11 user_badges / user_achievements / user_certifications
create policy user_badges_select_own on user_badges
  for select using (user_id = auth.uid());
create policy user_badges_select_leader on user_badges
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = user_badges.user_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy user_badges_admin_all on user_badges
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy user_achievements_select_own on user_achievements
  for select using (user_id = auth.uid());
create policy user_achievements_select_leader on user_achievements
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = user_achievements.user_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy user_achievements_admin_all on user_achievements
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy user_certifications_select_own on user_certifications
  for select using (user_id = auth.uid());
create policy user_certifications_select_leader on user_certifications
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = user_certifications.user_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy user_certifications_admin_all on user_certifications
  for all using (fn_is_admin()) with check (fn_is_admin());

-- 12.12 streaks — select próprio; sistema escreve via SECURITY DEFINER
create policy streaks_select_own on streaks
  for select using (user_id = auth.uid());
create policy streaks_select_leader on streaks
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = streaks.user_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy streaks_admin_all on streaks
  for all using (fn_is_admin()) with check (fn_is_admin());

-- 12.13 leaderboard — ranking é público internamente para todo autenticado
create policy leaderboard_select_authenticated on leaderboard
  for select using (auth.uid() is not null);
create policy leaderboard_admin_all on leaderboard
  for all using (fn_is_admin()) with check (fn_is_admin());

-- 12.14 login_events / study_sessions / page_views — telemetria: insert/select próprio
create policy login_events_insert_own on login_events
  for insert with check (user_id = auth.uid());
create policy login_events_select_own on login_events
  for select using (user_id = auth.uid());
create policy login_events_select_leader on login_events
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = login_events.user_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy login_events_admin_all on login_events
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy study_sessions_insert_own on study_sessions
  for insert with check (user_id = auth.uid());
create policy study_sessions_update_own on study_sessions
  for update using (user_id = auth.uid());
create policy study_sessions_select_own on study_sessions
  for select using (user_id = auth.uid());
create policy study_sessions_select_leader on study_sessions
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = study_sessions.user_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy study_sessions_admin_all on study_sessions
  for all using (fn_is_admin()) with check (fn_is_admin());

create policy page_views_insert_own on page_views
  for insert with check (user_id = auth.uid());
create policy page_views_select_own on page_views
  for select using (user_id = auth.uid());
create policy page_views_select_leader on page_views
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = page_views.user_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy page_views_admin_all on page_views
  for all using (fn_is_admin()) with check (fn_is_admin());

-- 12.15 activity_log — sem acesso direto para colaborador
create policy activity_log_select_leader on activity_log
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = activity_log.subject_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy activity_log_admin_all on activity_log
  for all using (fn_is_admin()) with check (fn_is_admin());

-- 12.16 BLOG_POSTS — regra pedida explicitamente:
--       qualquer usuário autenticado pode SELECT;
--       apenas administradores podem INSERT / UPDATE / DELETE.
create policy blog_posts_select_authenticated on blog_posts
  for select
  using (auth.uid() is not null);

create policy blog_posts_insert_admin on blog_posts
  for insert
  with check (fn_is_admin());

create policy blog_posts_update_admin on blog_posts
  for update
  using (fn_is_admin())
  with check (fn_is_admin());

create policy blog_posts_delete_admin on blog_posts
  for delete
  using (fn_is_admin());


-- ============================================================================
-- 13. VIEWS E MATERIALIZED VIEWS
-- ============================================================================

-- 13.1 v_alternatives_public — versão segura das alternativas, sem is_correct,
--      para servir o quiz em andamento sem revelar o gabarito.
create or replace view v_alternatives_public as
select id, question_id, body, order_index
from alternatives;

-- 13.2 v_user_total_points — XP total por usuário
create or replace view v_user_total_points as
select user_id, coalesce(sum(points), 0) as total_points
from points_ledger
group by user_id;

-- 13.3 v_user_last_activity — base do "quem não acessa há 7+ dias"
create or replace view v_user_last_activity as
select user_id, max(logged_in_at) as last_login_at
from login_events
group by user_id;

-- 13.4 v_quiz_accuracy_by_question — taxa de erro por pergunta
create or replace view v_quiz_accuracy_by_question as
select
  question_id,
  count(*) as total_answers,
  count(*) filter (where is_correct) as correct_answers,
  round(
    (count(*) filter (where is_correct))::numeric / nullif(count(*), 0)::numeric * 100,
    2
  ) as accuracy_pct
from quiz_answers
group by question_id;

-- 13.5 v_module_difficulty — combina taxa de erro dos quizzes do módulo + tempo médio em lesson_progress
create or replace view v_module_difficulty as
select
  m.id as module_id,
  m.title as module_title,
  avg(vqa.accuracy_pct) as avg_question_accuracy_pct,
  avg(lp.progress_pct) as avg_lesson_progress_pct
from modules m
left join lessons l on l.module_id = m.id
left join lesson_progress lp on lp.lesson_id = l.id
left join checkpoints c on c.checkpoint_type = 'module' and c.reference_id = m.id
left join zones z on z.id = c.zone_id
left join quizzes q on false -- módulo não tem FK direta para quiz; ligação feita via checkpoints da mesma zona
left join v_quiz_accuracy_by_question vqa on false
group by m.id, m.title;

comment on view v_module_difficulty is
  'Aproximação de dificuldade por módulo. Para precisão total, vincule explicitamente o quiz de cada módulo via checkpoints da mesma zona.';

-- 13.6 v_user_study_time_avg — tempo médio de estudo por colaborador/período (mensal)
create or replace view v_user_study_time_avg as
select
  user_id,
  date_trunc('month', started_at) as month,
  avg(duration_seconds) as avg_duration_seconds,
  sum(duration_seconds) as total_duration_seconds
from study_sessions
where duration_seconds is not null
group by user_id, date_trunc('month', started_at);

-- 13.7 v_user_monthly_evolution — pontos e módulos concluídos por mês
create or replace view v_user_monthly_evolution as
select
  pl.user_id,
  date_trunc('month', pl.created_at) as month,
  sum(pl.points) as points_earned
from points_ledger pl
group by pl.user_id, date_trunc('month', pl.created_at);

create or replace view v_user_monthly_checkpoints as
select
  cp.user_id,
  date_trunc('month', cp.changed_at) as month,
  count(*) filter (where cp.to_status = 'completed') as checkpoints_completed
from checkpoint_progress cp
group by cp.user_id, date_trunc('month', cp.changed_at);

-- 13.8 v_team_comparison — comparação do colaborador com a média da equipe/loja
create or replace view v_team_comparison as
select
  p.id as user_id,
  p.store_id,
  vtp.total_points as user_total_points,
  avg(vtp2.total_points) over (partition by p.store_id) as store_avg_points
from profiles p
left join v_user_total_points vtp on vtp.user_id = p.id
left join profiles p2 on p2.store_id = p.store_id and p2.deleted_at is null
left join v_user_total_points vtp2 on vtp2.user_id = p2.id
where p.deleted_at is null;

-- 13.9 Materialized Views de Leaderboard — atualizadas por job (fn_refresh_leaderboards)

create materialized view if not exists mv_leaderboard_global as
select
  row_number() over (order by coalesce(vtp.total_points, 0) desc) as rank_position,
  p.id as user_id,
  p.full_name,
  p.store_id,
  coalesce(vtp.total_points, 0) as total_points
from profiles p
left join v_user_total_points vtp on vtp.user_id = p.id
where p.deleted_at is null and p.status = 'active';
create unique index if not exists uq_mv_leaderboard_global_user on mv_leaderboard_global(user_id);

create materialized view if not exists mv_leaderboard_by_store as
select
  row_number() over (partition by p.store_id order by coalesce(vtp.total_points, 0) desc) as rank_position,
  p.store_id,
  p.id as user_id,
  p.full_name,
  coalesce(vtp.total_points, 0) as total_points
from profiles p
left join v_user_total_points vtp on vtp.user_id = p.id
where p.deleted_at is null and p.status = 'active';
create unique index if not exists uq_mv_leaderboard_by_store_user on mv_leaderboard_by_store(user_id);

create materialized view if not exists mv_leaderboard_by_role as
select
  row_number() over (partition by p.job_title order by coalesce(vtp.total_points, 0) desc) as rank_position,
  p.job_title,
  p.id as user_id,
  p.full_name,
  coalesce(vtp.total_points, 0) as total_points
from profiles p
left join v_user_total_points vtp on vtp.user_id = p.id
where p.deleted_at is null and p.status = 'active';
create unique index if not exists uq_mv_leaderboard_by_role_user on mv_leaderboard_by_role(user_id);

create materialized view if not exists mv_leaderboard_by_certifications as
select
  row_number() over (order by count(uc.id) desc) as rank_position,
  p.id as user_id,
  p.full_name,
  count(uc.id) as certifications_count
from profiles p
left join user_certifications uc on uc.user_id = p.id and uc.revoked_at is null
where p.deleted_at is null and p.status = 'active'
group by p.id, p.full_name;
create unique index if not exists uq_mv_leaderboard_by_cert_user on mv_leaderboard_by_certifications(user_id);

create materialized view if not exists mv_leaderboard_engagement as
select
  row_number() over (order by engagement_score desc) as rank_position,
  p.id as user_id,
  p.full_name,
  (
    coalesce(le.login_count, 0) * 1.0
    + coalesce(ss.total_seconds, 0) / 60.0 * 0.5
    + coalesce(st.current_streak_days, 0) * 2.0
  ) as engagement_score
from profiles p
left join (
  select user_id, count(*) as login_count
  from login_events
  where logged_in_at > now() - interval '30 days'
  group by user_id
) le on le.user_id = p.id
left join (
  select user_id, sum(duration_seconds) as total_seconds
  from study_sessions
  where started_at > now() - interval '30 days'
  group by user_id
) ss on ss.user_id = p.id
left join streaks st on st.user_id = p.id
where p.deleted_at is null and p.status = 'active';
create unique index if not exists uq_mv_leaderboard_engagement_user on mv_leaderboard_engagement(user_id);

create materialized view if not exists mv_leaderboard_completion_speed as
select
  row_number() over (order by avg(extract(epoch from (completed_at_evt.changed_at - unlocked_at_evt.changed_at))) asc nulls last) as rank_position,
  unlocked_at_evt.user_id,
  avg(extract(epoch from (completed_at_evt.changed_at - unlocked_at_evt.changed_at))) as avg_seconds_to_complete
from checkpoint_progress unlocked_at_evt
join checkpoint_progress completed_at_evt
  on completed_at_evt.user_id = unlocked_at_evt.user_id
 and completed_at_evt.checkpoint_id = unlocked_at_evt.checkpoint_id
 and completed_at_evt.to_status = 'completed'
where unlocked_at_evt.to_status = 'unlocked'
group by unlocked_at_evt.user_id;
create unique index if not exists uq_mv_leaderboard_speed_user on mv_leaderboard_completion_speed(user_id);

-- 13.10 fn_refresh_leaderboards — chamada pelo cron (Edge Function refresh-leaderboards)
create or replace function fn_refresh_leaderboards()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  refresh materialized view concurrently mv_leaderboard_global;
  refresh materialized view concurrently mv_leaderboard_by_store;
  refresh materialized view concurrently mv_leaderboard_by_role;
  refresh materialized view concurrently mv_leaderboard_by_certifications;
  refresh materialized view concurrently mv_leaderboard_engagement;
  refresh materialized view concurrently mv_leaderboard_completion_speed;
end;
$$;

comment on function fn_refresh_leaderboards() is
  'Atualiza todas as materialized views de ranking — chamada pelo cron refresh-leaderboards (ex.: a cada hora).';


-- ============================================================================
-- 14. SEEDS MÍNIMOS E REFRESH INICIAL
-- ============================================================================

insert into brands (slug, name, is_active) values
  ('garmin', 'Garmin', true),
  ('shokz',  'Shokz',  true)
on conflict (slug) do nothing;

-- Primeira carga das materialized views (podem estar vazias até haver dados,
-- mas precisam existir "populadas" antes do uso de REFRESH CONCURRENTLY)
select fn_refresh_leaderboards();

-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================
