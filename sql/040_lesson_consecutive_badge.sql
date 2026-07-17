-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 040: Badge Foco de Ferro (5 lições seguidas)
-- ============================================================================
-- Concede badge "Foco de Ferro" quando o usuário completa 5 lições teóricas
-- seguidas sem pular para os quizzes, demonstrando assimilação do material.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Função para verificar e conceder badge Foco de Ferro
-- ----------------------------------------------------------------------------
create or replace function public.fn_grant_badge_consecutive_lessons()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id      uuid := new.user_id;
  v_brand_id     uuid;
  v_badge_id     uuid;
  v_consecutive  integer;
  v_last_lessons record;
begin
  -- Buscar brand_id do usuário
  select brand_id into v_brand_id
    from public.profiles
   where id = v_user_id;

  if v_brand_id is null then
    return new;
  end if;

  -- Verificar se as últimas 5 conclusões de lição foram consecutivas
  -- (sem quizzes intermediários)
  select count(*) into v_consecutive
    from (
      select lp.id, lp.lesson_id, lp.completed_at,
             lag(lp.completed_at) over (order by lp.completed_at) as prev_completed
        from public.lesson_progress lp
       where lp.user_id = v_user_id
         and lp.completed_at is not null
       order by lp.completed_at desc
       limit 5
    ) as recent
    where prev_completed is null 
       or (completed_at - prev_completed) < interval '1 hour'; -- Lições consecutivas (mesma sessão)

  -- Verificar se não houve quiz finalizado entre essas lições
  select count(*) into v_last_lessons.count
    from public.quiz_attempts qa
   where qa.user_id = v_user_id
     and qa.finished_at is not null
     and qa.finished_at > (select min(completed_at) from (
       select lp.completed_at
         from public.lesson_progress lp
        where lp.user_id = v_user_id
          and lp.completed_at is not null
        order by lp.completed_at desc
        limit 5
     ) as last_5);

  if v_consecutive >= 5 and v_last_lessons.count = 0 then
    -- Conceder badge Foco de Ferro
    select id into v_badge_id
      from public.badges
     where brand_id = v_brand_id
       and slug = 'foco-de-ferro-' || (select slug from public.brands where id = v_brand_id);
    
    if v_badge_id is not null then
      insert into public.user_badges (user_id, badge_id, earned_at)
      values (v_user_id, v_badge_id, now())
      on conflict (user_id, badge_id) do nothing;
    end if;
  end if;

  return new;
end;
$$;

comment on function public.fn_grant_badge_consecutive_lessons() is
  'Concede badge Foco de Ferro quando o usuário completa 5 lições teóricas consecutivas sem quizzes intermediários. SECURITY DEFINER.';

-- ----------------------------------------------------------------------------
-- 2. Trigger em lesson_progress
-- ----------------------------------------------------------------------------
drop trigger if exists trg_grant_badge_consecutive_lessons on public.lesson_progress;
create trigger trg_grant_badge_consecutive_lessons
after insert or update on public.lesson_progress
for each row execute function public.fn_grant_badge_consecutive_lessons();

-- ============================================================================
-- FIM DA MIGRAÇÃO 040
-- ============================================================================
