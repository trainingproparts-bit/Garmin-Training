-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 041: Badge Gente Boa (onboarding em 7 dias)
-- ============================================================================
-- Concede badge "Gente Boa" quando o usuário conclui a primeira trilha de
-- integração completa nos primeiros 7 dias após o cadastro.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Função para verificar e conceder badge Gente Boa
-- ----------------------------------------------------------------------------
create or replace function public.fn_grant_badge_onboarding_speed()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id      uuid := new.user_id;
  v_brand_id     uuid;
  v_badge_id     uuid;
  v_created_at   timestamptz;
  v_days_since   numeric;
  v_trail_id     uuid;
  v_total_checkpoints integer;
  v_completed_checkpoints integer;
begin
  -- Buscar brand_id e data de criação do usuário
  select p.brand_id, p.created_at into v_brand_id, v_created_at
    from public.profiles p
   where p.id = v_user_id;

  if v_brand_id is null then
    return new;
  end if;

  -- Calcular dias desde o cadastro
  v_days_since := extract(epoch from (now() - v_created_at)) / 86400;

  -- Só verifica se estiver dentro de 7 dias
  if v_days_since > 7 then
    return new;
  end if;

  -- Buscar a trilha publicada da marca
  select id into v_trail_id
    from public.trails
   where brand_id = v_brand_id
     and is_published = true
   order by order_index asc
   limit 1;

  if v_trail_id is null then
    return new;
  end if;

  -- Contar checkpoints totais da trilha
  select count(*) into v_total_checkpoints
    from public.checkpoints c
    join public.zones z on z.id = c.zone_id
   where z.trail_id = v_trail_id;

  -- Contar checkpoints concluídos pelo usuário
  select count(*) into v_completed_checkpoints
    from public.user_progress up
    join public.checkpoints c on c.id = up.checkpoint_id
    join public.zones z on z.id = c.zone_id
   where z.trail_id = v_trail_id
     and up.user_id = v_user_id
     and up.status = 'completed';

  -- Se concluiu todos os checkpoints da trilha em 7 dias, conceder badge
  if v_completed_checkpoints >= v_total_checkpoints and v_total_checkpoints > 0 then
    select id into v_badge_id
      from public.badges
     where brand_id = v_brand_id
       and slug = 'gente-boa-' || (select slug from public.brands where id = v_brand_id);
    
    if v_badge_id is not null then
      insert into public.user_badges (user_id, badge_id, earned_at)
      values (v_user_id, v_badge_id, now())
      on conflict (user_id, badge_id) do nothing;
    end if;
  end if;

  return new;
end;
$$;

comment on function public.fn_grant_badge_onboarding_speed() is
  'Concede badge Gente Boa quando o usuário conclui a primeira trilha completa nos primeiros 7 dias após cadastro. SECURITY DEFINER.';

-- ----------------------------------------------------------------------------
-- 2. Trigger em user_progress (checkpoint completion)
-- ----------------------------------------------------------------------------
drop trigger if exists trg_grant_badge_onboarding_speed on public.user_progress;
create trigger trg_grant_badge_onboarding_speed
after insert or update on public.user_progress
for each row execute function public.fn_grant_badge_onboarding_speed();

-- ============================================================================
-- FIM DA MIGRAÇÃO 041
-- ============================================================================
