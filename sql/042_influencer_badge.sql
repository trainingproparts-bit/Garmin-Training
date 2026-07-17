-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 042: Badge Influenciador da Loja
-- ============================================================================
-- Concede badge "Influenciador da Loja" quando uma postagem de conquista
-- no activity_feed atinge 10 reações (curtidas/palmas) dos colegas.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Criar tabela de reações ao activity_feed (se não existir)
-- ----------------------------------------------------------------------------
create table if not exists public.activity_feed_reactions (
  id              uuid primary key default gen_random_uuid(),
  activity_id     uuid not null references public.activity_feed(id) on delete cascade,
  user_id         uuid not null references public.profiles(id) on delete cascade,
  reaction_type   text not null check (reaction_type in ('like', 'clap')),
  created_at      timestamptz not null default now(),
  constraint uq_activity_feed_reaction unique (activity_id, user_id)
);

create index if not exists idx_activity_feed_reactions_activity on public.activity_feed_reactions(activity_id);
create index if not exists idx_activity_feed_reactions_user on public.activity_feed_reactions(user_id);

comment on table public.activity_feed_reactions is
  'Reações (curtidas/palmas) às postagens do Mural de Atividades. Usado para conceder badge Influenciador da Loja (10 reações).';

alter table public.activity_feed_reactions enable row level security;

-- Qualquer autenticado pode reagir
create policy activity_feed_reactions_insert_own on public.activity_feed_reactions
  for insert with check (auth.uid() = user_id);

-- Qualquer autenticado pode ver reações
create policy activity_feed_reactions_select_all on public.activity_feed_reactions
  for select using (true);

grant select, insert on public.activity_feed_reactions to authenticated;

-- ----------------------------------------------------------------------------
-- 2. Função para conceder badge Influenciador da Loja
-- ----------------------------------------------------------------------------
create or replace function public.fn_grant_badge_influencer()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_activity    public.activity_feed;
  v_reaction_count integer;
  v_brand_id    uuid;
  v_badge_id    uuid;
begin
  -- Buscar a postagem e contar reações
  select af.*, af.brand_id into v_activity, v_brand_id
    from public.activity_feed af
   where af.id = new.activity_id;

  if v_activity.id is null then
    return new;
  end if;

  -- Contar reações para esta postagem
  select count(*) into v_reaction_count
    from public.activity_feed_reactions
   where activity_id = new.activity_id;

  -- Se atingiu 10 reações e o post é do usuário (subject_id), conceder badge
  if v_reaction_count >= 10 and v_activity.subject_id is not null then
    select id into v_badge_id
      from public.badges
     where brand_id = v_brand_id
       and slug = 'influenciador-loja-' || (select slug from public.brands where id = v_brand_id);
    
    if v_badge_id is not null then
      insert into public.user_badges (user_id, badge_id, earned_at)
      values (v_activity.subject_id, v_badge_id, now())
      on conflict (user_id, badge_id) do nothing;
    end if;
  end if;

  return new;
end;
$$;

comment on function public.fn_grant_badge_influencer() is
  'Concede badge Influenciador da Loja quando uma postagem atinge 10 reações. SECURITY DEFINER.';

-- ----------------------------------------------------------------------------
-- 3. Trigger em activity_feed_reactions
-- ----------------------------------------------------------------------------
drop trigger if exists trg_grant_badge_influencer on public.activity_feed_reactions;
create trigger trg_grant_badge_influencer
after insert on public.activity_feed_reactions
for each row execute function public.fn_grant_badge_influencer();

-- ============================================================================
-- FIM DA MIGRAÇÃO 042
-- ============================================================================
