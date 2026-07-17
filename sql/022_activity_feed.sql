-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 022: Mural de Atividades (activity_feed)
-- ============================================================================
-- Especificado em regras-de-negocio-training-hub.md §6.10 e
-- modelagem-banco-dados-training-hub.md §6.8. Escopo desta migração segue
-- o pedido atual do usuário (mais estreito que o documento original):
--   - Gatilhos automáticos: só badge (user_badges) e certificação
--     (user_certifications). Streak/nota-100% ficam para quando streak/
--     avaliação-perfeita tiverem hook equivalente — não fazem parte deste
--     recorte.
--   - Gatilho manual: só Líder/Admin, via templates fixos (sem texto livre).
--
-- Global DENTRO da marca (brand_id), não entre marcas — mesma decisão já
-- registrada na modelagem (Garmin e Shokz não se misturam), mas qualquer
-- loja da mesma marca vê tudo (reforça senso de comunidade da rede).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Tabela
-- ----------------------------------------------------------------------------
create table if not exists public.activity_feed (
  id               uuid primary key default gen_random_uuid(),
  brand_id         uuid not null references public.brands(id),
  subject_id       uuid references public.profiles(id) on delete set null,
  store_id         uuid references public.stores(id) on delete set null,
  author_id        uuid references public.profiles(id) on delete set null,
  trigger_type     text not null check (trigger_type in ('automatic', 'manual')),
  source_event     text not null,
  related_badge_id uuid references public.badges(id) on delete set null,
  message          text not null,
  created_at       timestamptz not null default now(),
  constraint chk_activity_feed_manual_author check (trigger_type = 'manual' or author_id is null)
);

create index if not exists idx_activity_feed_brand_created on public.activity_feed(brand_id, created_at desc);
create index if not exists idx_activity_feed_subject on public.activity_feed(subject_id);

comment on table public.activity_feed is
  'Mural de Atividades — feed global dentro da marca (todas as lojas), texto puro pré-renderizado, sem upload de mídia. Automático via trigger (badge/certificação); manual só líder/admin via fn_leader_post_activity (templates fixos, sem texto livre).';

alter table public.activity_feed enable row level security;

-- Leitura global dentro da marca do próprio perfil; admin (brand_id null) vê tudo.
drop policy if exists activity_feed_select_all on public.activity_feed;
create policy activity_feed_select_all on public.activity_feed
  for select using (
    fn_is_admin()
    or brand_id = (select brand_id from public.profiles where id = auth.uid())
  );

drop policy if exists activity_feed_admin_all on public.activity_feed;
create policy activity_feed_admin_all on public.activity_feed
  for all using (fn_is_admin()) with check (fn_is_admin());

-- Sem policy de INSERT pro authenticated de propósito: automático vem de
-- trigger SECURITY DEFINER; manual só pela RPC fn_leader_post_activity, que
-- valida líder+escopo de loja antes de gravar.

grant select on public.activity_feed to authenticated;

-- ----------------------------------------------------------------------------
-- 2. Seed dos 5 badges nomeados (catálogo — tabela existia vazia; a
--    concessão automática por regra continua fora de escopo, é backlog de
--    Gamificação social já registrado no ROADMAP). icon_url reaproveitado
--    pra guardar o emoji nativo direto (texto puro, sem upload de mídia).
-- ----------------------------------------------------------------------------
-- badges.slug é único GLOBALMENTE (não por marca, ao contrário de quizzes) —
-- por isso o slug leva o sufixo da marca.
insert into public.badges (brand_id, slug, title, description, icon_url, rule)
select b.id, v.slug || '-' || b.slug, v.title, v.description, v.icon_url, '{}'::jsonb
from public.brands b
cross join (values
  ('explorer',        'Explorer',        'Desbravou o território inicial da trilha.',            '🧭'),
  ('runner',          'Runner',          'Avançou com consistência pelas zonas intermediárias.', '🏃'),
  ('triathlete',      'Triathlete',      'Dominou todas as frentes técnicas da trilha.',          '🏅'),
  ('gabarito-garmin', 'Gabarito Garmin', 'Acertou 100% em um quiz técnico.',                      '🎯'),
  ('ritmo-constante', 'Ritmo Constante', 'Manteve a sequência de estudo em dia.',                 '🔥')
) as v(slug, title, description, icon_url)
where not exists (
  select 1 from public.badges existing where existing.brand_id = b.id and existing.slug = v.slug || '-' || b.slug
);

-- ----------------------------------------------------------------------------
-- 3. Gatilho automático: badge conquistado
-- ----------------------------------------------------------------------------
create or replace function public.fn_post_activity_badge_earned()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile record;
  v_badge   record;
begin
  select id, full_name, brand_id, store_id into v_profile from profiles where id = new.user_id;
  select id, title, icon_url into v_badge from badges where id = new.badge_id;

  if v_profile.id is null or v_badge.id is null then
    return new;
  end if;

  insert into activity_feed (brand_id, subject_id, store_id, trigger_type, source_event, related_badge_id, message)
  values (
    v_profile.brand_id,
    v_profile.id,
    v_profile.store_id,
    'automatic',
    'badge_earned',
    v_badge.id,
    format('%s conquistou o badge %s! %s', v_profile.full_name, v_badge.title, coalesce(v_badge.icon_url, '🏅'))
  );

  return new;
end;
$$;

comment on function public.fn_post_activity_badge_earned() is
  'Posta automaticamente no Mural quando user_badges ganha uma linha nova. SECURITY DEFINER pra sempre conseguir gravar em activity_feed, independente do contexto de quem concedeu o badge.';

drop trigger if exists trg_post_activity_badge_earned on public.user_badges;
create trigger trg_post_activity_badge_earned
after insert on public.user_badges
for each row execute function public.fn_post_activity_badge_earned();

-- ----------------------------------------------------------------------------
-- 4. Gatilho automático: certificação emitida
-- ----------------------------------------------------------------------------
create or replace function public.fn_post_activity_certification_issued()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile record;
  v_cert    record;
begin
  select id, full_name, brand_id, store_id into v_profile from profiles where id = new.user_id;
  select id, title into v_cert from certifications where id = new.certification_id;

  if v_profile.id is null or v_cert.id is null then
    return new;
  end if;

  insert into activity_feed (brand_id, subject_id, store_id, trigger_type, source_event, message)
  values (
    v_profile.brand_id,
    v_profile.id,
    v_profile.store_id,
    'automatic',
    'certification_issued',
    format('%s conquistou a certificação %s! 🎓🏆', v_profile.full_name, v_cert.title)
  );

  return new;
end;
$$;

comment on function public.fn_post_activity_certification_issued() is
  'Posta automaticamente no Mural quando user_certifications ganha uma linha nova (fn_issue_certification, sql/017-019). SECURITY DEFINER pelo mesmo motivo do badge.';

drop trigger if exists trg_post_activity_certification_issued on public.user_certifications;
create trigger trg_post_activity_certification_issued
after insert on public.user_certifications
for each row execute function public.fn_post_activity_certification_issued();

-- ----------------------------------------------------------------------------
-- 5. RPC de postagem manual (Líder/Admin) — templates fixos, zero texto livre
-- ----------------------------------------------------------------------------
create or replace function public.fn_leader_post_activity(
  p_template_key  text,
  p_subject_id    uuid default null,
  p_product_model text default null,
  p_store_id      uuid default null
)
returns public.activity_feed
language plpgsql
security definer
set search_path = public
as $$
declare
  v_subject    record;
  v_store      record;
  v_message    text;
  v_row        public.activity_feed;
  v_is_team_template boolean := p_template_key in ('meta_dia', 'meta_mes');
  v_brand_id   uuid;
  v_author     record;
begin
  if not (fn_is_leader() or fn_is_admin()) then
    raise exception 'apenas líderes ou administradores podem postar no mural';
  end if;

  -- Derivar brand_id do autor (líder/admin) como fallback
  select id, brand_id into v_author from profiles where id = auth.uid();
  v_brand_id := v_author.brand_id;

  if v_is_team_template then
    if p_store_id is null then
      raise exception 'loja é obrigatória para este tipo de destaque';
    end if;

    select id, name, brand_id into v_store from stores where id = p_store_id;
    if v_store.id is null then
      raise exception 'loja % não encontrada', p_store_id;
    end if;

    -- Usar brand_id da loja se disponível, senão do autor
    if v_store.brand_id is not null then
      v_brand_id := v_store.brand_id;
    end if;

    if fn_is_leader() and not fn_is_admin() and p_store_id not in (select fn_leader_store_ids()) then
      raise exception 'loja % não está sob sua gestão', p_store_id;
    end if;

    v_message := case p_template_key
      when 'meta_dia' then format('🔥 Meta Batida! A equipe da loja %s cravou o objetivo do dia! O painel tá verde! 🍾', v_store.name)
      when 'meta_mes' then format('🏆 GIGANTES DO MÊS! A equipe da loja %s jogou em nível de elite e acaba de BATER A META MENSAL! Parabéns pelo foco inabalável! 🥂🔥🥇', v_store.name)
    end;

    insert into activity_feed (brand_id, subject_id, store_id, author_id, trigger_type, source_event, message)
    values (v_brand_id, null, v_store.id, auth.uid(), 'manual', 'leader_manual', v_message)
    returning * into v_row;

    return v_row;
  end if;

  -- templates individuais: exigem vendedor
  if p_subject_id is null then
    raise exception 'vendedor é obrigatório para este tipo de destaque';
  end if;

  select id, full_name, brand_id, store_id into v_subject from profiles where id = p_subject_id;
  if v_subject.id is null then
    raise exception 'colaborador % não encontrado', p_subject_id;
  end if;

  -- Usar brand_id do subject se disponível, senão do autor
  if v_subject.brand_id is not null then
    v_brand_id := v_subject.brand_id;
  end if;

  if fn_is_leader() and not fn_is_admin() then
    if v_subject.store_id is null or v_subject.store_id not in (select fn_leader_store_ids()) then
      raise exception 'colaborador % não está em loja sob sua gestão', p_subject_id;
    end if;
  end if;

  v_message := case p_template_key
    when 'relogio_corrida'   then format('%s mandou bem demais e garantiu um Forerunner %s no pulso de mais um corredor! 🏃‍♂️🚀', v_subject.full_name, coalesce(p_product_model, '165'))
    when 'relogio_outdoor'   then format('%s acaba de fechar a venda de um Fēnix %s! O cliente levou o ápice da resistência e navegação técnica. ⛰️🏆', v_subject.full_name, coalesce(p_product_model, '8'))
    when 'relogio_lifestyle' then format('Tem novo cliente monitorando tudo com o Venu vendido por %s. Venda certeira e elegante! ✨⌚', v_subject.full_name)
    when 'combo_acessorios'  then format('%s garantiu a experiência completa com relógio + acessórios extras para o cliente! ➕🎯', v_subject.full_name)
    else null
  end;

  if v_message is null then
    raise exception 'template % desconhecido', p_template_key;
  end if;

  insert into activity_feed (brand_id, subject_id, store_id, author_id, trigger_type, source_event, message)
  values (v_brand_id, v_subject.id, v_subject.store_id, auth.uid(), 'manual', 'leader_manual', v_message)
  returning * into v_row;

  return v_row;
end;
$$;

comment on function public.fn_leader_post_activity(text, uuid, text, uuid) is
  'Único caminho pro líder/admin postar no Mural — sempre por template fixo (nunca texto livre), validando escopo de loja do líder. Templates: relogio_corrida, relogio_outdoor, relogio_lifestyle, combo_acessorios (exigem p_subject_id), meta_dia, meta_mes (exigem p_store_id).';

grant execute on function public.fn_leader_post_activity(text, uuid, text, uuid) to authenticated;

-- ----------------------------------------------------------------------------
-- 6. Realtime — front assina INSERT e injeta no topo do mural sem polling
-- ----------------------------------------------------------------------------
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
     where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'activity_feed'
  ) then
    alter publication supabase_realtime add table public.activity_feed;
  end if;
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 022
-- ============================================================================
