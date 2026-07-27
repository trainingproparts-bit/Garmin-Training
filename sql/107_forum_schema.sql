-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 107: schema do Fórum/Comunidade de Dúvidas
-- ============================================================================
-- 4 tabelas novas: forum_categories, forum_threads, forum_replies,
-- forum_votes. Sem brand_id (conteúdo de organização inteira, mesmo padrão
-- de blog_posts — ver comentário em searchService.js "Blog é da organização
-- inteira"). Papel "Líder/Moderador" reaproveita o role 'leader' já
-- existente (fn_is_leader()), nenhum cargo novo precisa ser criado.
--
-- Decisões de segurança importantes (evitando bugs reais já vistos neste
-- schema):
--   1. Política de moderação é SEMPRE `for update`/`for delete` separadas,
--      NUNCA `for all`. `for all using (fn_is_leader() or fn_is_admin())`
--      também libera INSERT sem checar author_id — um líder poderia criar
--      tópico se passando por outro usuário. Esse exato bug já existe hoje
--      em `points_ledger_admin_all` (para all, sem with check restritivo),
--      não repetir aqui.
--   2. INSERT no fórum checa profiles.status = 'active' explicitamente —
--      hoje "banir" (status='suspended') só esconde de rankings, nenhuma
--      política de escrita em lugar nenhum do schema checa status. O fórum
--      é o primeiro lugar onde suspenso realmente impede ação.
--   3. ON DELETE CASCADE nas FKs desde o início (forum_replies→threads,
--      forum_votes→replies) — evita reproduzir o bug de hoje mais cedo em
--      contentAdminService.js, onde FKs sem cascade faziam TODO delete de
--      módulo/quiz falhar com violação de FK.
--   4. Trigger de guarda: RLS é por LINHA, não por coluna — um usuário
--      comum editando o próprio tópico (permitido) também conseguiria
--      alterar is_pinned/is_locked na mesma chamada se não houver um guard
--      explícito. fn_forum_thread_guard_columns() bloqueia isso.
-- ============================================================================

begin;

-- ============================================================================
-- TABELAS
-- ============================================================================

create table forum_categories (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  slug         text not null unique,
  description  text,
  order_index  integer not null default 0,
  is_active    boolean not null default true,
  created_at   timestamptz not null default now()
);
comment on table forum_categories is 'Categorias do fórum (Resolução de Problemas, Dúvidas Gerais, Sugestões, Linha de Produtos). Gerenciadas só por admin. Nunca hard-delete (RESTRICT), só is_active.';

create table forum_threads (
  id                 uuid primary key default gen_random_uuid(),
  category_id        uuid not null references forum_categories(id) on delete restrict,
  author_id          uuid not null references profiles(id) on delete cascade,
  title              text not null,
  body               text not null,
  is_pinned          boolean not null default false,
  is_locked          boolean not null default false,
  solution_reply_id  uuid, -- FK adicionada depois que forum_replies existir
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
comment on table forum_threads is 'Tópicos do fórum, organização inteira (sem brand_id, mesmo padrão de blog_posts).';

create table forum_replies (
  id          uuid primary key default gen_random_uuid(),
  thread_id   uuid not null references forum_threads(id) on delete cascade,
  author_id   uuid not null references profiles(id) on delete cascade,
  body        text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
comment on table forum_replies is 'Respostas de um tópico, uma camada só (sem reply-to-reply, não foi pedido).';

alter table forum_threads add constraint fk_forum_threads_solution_reply
  foreign key (solution_reply_id) references forum_replies(id) on delete set null;

create table forum_votes (
  id          uuid primary key default gen_random_uuid(),
  reply_id    uuid not null references forum_replies(id) on delete cascade,
  user_id     uuid not null references profiles(id) on delete cascade,
  created_at  timestamptz not null default now(),
  constraint uq_forum_votes_reply_user unique (reply_id, user_id)
);
comment on table forum_votes is 'Upvote simples (sem downvote) numa resposta, um voto por usuário por resposta.';

create index idx_forum_threads_category on forum_threads(category_id);
create index idx_forum_threads_created_at on forum_threads(created_at desc);
create index idx_forum_replies_thread on forum_replies(thread_id);
create index idx_forum_votes_reply on forum_votes(reply_id);

create trigger trg_forum_threads_updated_at
before update on forum_threads
for each row execute function fn_set_updated_at();

create trigger trg_forum_replies_updated_at
before update on forum_replies
for each row execute function fn_set_updated_at();

-- ============================================================================
-- GUARDA: RLS é por linha, não por coluna. Um autor editando o próprio
-- tópico não pode, na mesma chamada, alterar is_pinned/is_locked, e
-- solution_reply_id só pode apontar pra uma resposta da PRÓPRIA thread.
-- ============================================================================

create or replace function fn_forum_thread_guard_columns()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if (new.is_pinned is distinct from old.is_pinned or new.is_locked is distinct from old.is_locked)
     and not (fn_is_leader() or fn_is_admin()) then
    raise exception 'Só líder ou admin pode fixar/trancar um tópico.';
  end if;

  if new.solution_reply_id is not null then
    if not exists (
      select 1 from forum_replies r
      where r.id = new.solution_reply_id and r.thread_id = new.id
    ) then
      raise exception 'A resposta marcada como solução precisa pertencer a este tópico.';
    end if;
  end if;

  return new;
end;
$$;

comment on function fn_forum_thread_guard_columns() is 'Bloqueia fixar/trancar por não-moderador na mesma chamada de edição normal, e valida que solution_reply_id pertence à própria thread.';

create trigger trg_forum_thread_guard_columns
before update on forum_threads
for each row execute function fn_forum_thread_guard_columns();

-- ============================================================================
-- VIEW: lista de tópicos sem N+1 (categoria, autor+cargo, contagens)
-- ============================================================================

create or replace view v_forum_thread_list as
select
  t.id,
  t.category_id,
  c.name as category_name,
  c.slug as category_slug,
  t.author_id,
  p.full_name as author_name,
  r.code as author_role_code,
  t.title,
  t.body,
  t.is_pinned,
  t.is_locked,
  t.solution_reply_id,
  (t.solution_reply_id is not null) as is_solved,
  t.created_at,
  t.updated_at,
  coalesce(rc.reply_count, 0) as reply_count,
  coalesce(vc.vote_count, 0) as vote_count,
  greatest(t.updated_at, coalesce(rc.last_reply_at, t.created_at)) as last_activity_at
from forum_threads t
join forum_categories c on c.id = t.category_id
join profiles p on p.id = t.author_id
join roles r on r.id = p.role_id
left join (
  select thread_id, count(*) as reply_count, max(created_at) as last_reply_at
  from forum_replies
  group by thread_id
) rc on rc.thread_id = t.id
left join (
  select fr.thread_id, count(fv.id) as vote_count
  from forum_replies fr
  join forum_votes fv on fv.reply_id = fr.id
  group by fr.thread_id
) vc on vc.thread_id = t.id;

comment on view v_forum_thread_list is 'Lista de tópicos pra tela de overview do fórum, já com categoria/autor/cargo/contagens resolvidos — evita N+1 no client.';

-- ============================================================================
-- RLS
-- ============================================================================

alter table forum_categories enable row level security;
alter table forum_threads enable row level security;
alter table forum_replies enable row level security;
alter table forum_votes enable row level security;

-- categorias: leitura livre pra autenticado, escrita só admin
create policy forum_categories_select_all on forum_categories
for select to authenticated using (true);

create policy forum_categories_insert_admin on forum_categories
for insert to authenticated with check (fn_is_admin());

create policy forum_categories_update_admin on forum_categories
for update to authenticated using (fn_is_admin()) with check (fn_is_admin());

-- tópicos
create policy forum_threads_select_all on forum_threads
for select to authenticated using (true);

create policy forum_threads_insert_own on forum_threads
for insert to authenticated with check (
  author_id = auth.uid()
  and exists (select 1 from profiles where id = auth.uid() and status = 'active' and deleted_at is null)
);

create policy forum_threads_update_own on forum_threads
for update to authenticated using (author_id = auth.uid()) with check (author_id = auth.uid());

create policy forum_threads_update_moderator on forum_threads
for update to authenticated using (fn_is_leader() or fn_is_admin()) with check (fn_is_leader() or fn_is_admin());

create policy forum_threads_delete_own on forum_threads
for delete to authenticated using (author_id = auth.uid());

create policy forum_threads_delete_moderator on forum_threads
for delete to authenticated using (fn_is_leader() or fn_is_admin());

-- respostas
create policy forum_replies_select_all on forum_replies
for select to authenticated using (true);

create policy forum_replies_insert_own on forum_replies
for insert to authenticated with check (
  author_id = auth.uid()
  and exists (select 1 from profiles where id = auth.uid() and status = 'active' and deleted_at is null)
  and exists (select 1 from forum_threads t where t.id = thread_id and not t.is_locked)
);

create policy forum_replies_update_own on forum_replies
for update to authenticated using (author_id = auth.uid()) with check (author_id = auth.uid());

create policy forum_replies_update_moderator on forum_replies
for update to authenticated using (fn_is_leader() or fn_is_admin()) with check (fn_is_leader() or fn_is_admin());

create policy forum_replies_delete_own on forum_replies
for delete to authenticated using (author_id = auth.uid());

create policy forum_replies_delete_moderator on forum_replies
for delete to authenticated using (fn_is_leader() or fn_is_admin());

-- votos: só própria (sem override de moderador, escopo além do pedido)
create policy forum_votes_select_all on forum_votes
for select to authenticated using (true);

create policy forum_votes_insert_own on forum_votes
for insert to authenticated with check (
  user_id = auth.uid()
  and exists (select 1 from profiles where id = auth.uid() and status = 'active' and deleted_at is null)
);

create policy forum_votes_delete_own on forum_votes
for delete to authenticated using (user_id = auth.uid());

grant select on v_forum_thread_list to authenticated;

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 107
-- ============================================================================
