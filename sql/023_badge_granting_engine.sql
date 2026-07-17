-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 023: Engine de concessão automática de badges
-- ============================================================================
-- sql/022 já cria os 5 badges nomeados e o trigger que posta no Mural quando
-- user_badges ganha uma linha — mas nada até agora inseria nessa tabela.
-- Regra decidida com o usuário (2026-07-10), a partir das descrições dos
-- badges já escritas em 022:
--   - Explorer  → certificação "Explorador" emitida (mesma zona, mesmo evento)
--   - Runner    → certificação "Corredor" emitida
--   - Triathlete → as duas acima emitidas (hoje é a trilha real inteira —
--     Maratonista/Triatleta não têm zona/conteúdo implementado ainda, sql/017)
--   - Gabarito Garmin → 100% na 1ª tentativa de qualquer quiz
--   - Ritmo Constante → FORA de escopo aqui: depende de sistema de streak
--     (job diário, pausa em fim de semana, RN §6.5) que não existe ainda.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Helper: concede um badge pelo "tipo" (sem sufixo de marca), resolvendo
--    a marca a partir do próprio perfil. Idempotente via uq_user_badges.
-- ----------------------------------------------------------------------------
create or replace function public.fn_grant_badge(p_user_id uuid, p_badge_key text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_brand_id uuid;
  v_badge_id uuid;
begin
  select brand_id into v_brand_id from profiles where id = p_user_id;
  if v_brand_id is null then
    return;
  end if;

  select b.id into v_badge_id
    from badges b
    join brands br on br.id = b.brand_id
   where b.brand_id = v_brand_id
     and b.slug = p_badge_key || '-' || br.slug;

  if v_badge_id is null then
    return;
  end if;

  insert into user_badges (user_id, badge_id)
  values (p_user_id, v_badge_id)
  on conflict (user_id, badge_id) do nothing;
end;
$$;

comment on function public.fn_grant_badge(uuid, text) is
  'Concede um badge pelo tipo (ex.: ''explorer'') resolvendo a marca do próprio perfil — badges.slug leva sufixo de marca (sql/022). Idempotente (uq_user_badges); grava em user_badges, que já dispara o post automático no Mural (trg_post_activity_badge_earned, sql/022).';

-- ----------------------------------------------------------------------------
-- 2. Explorer / Runner / Triathlete — a partir de certificação emitida
-- ----------------------------------------------------------------------------
create or replace function public.fn_grant_badge_on_certification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cert_slug   text;
  v_badge_key   text;
  v_real_certs  integer;
begin
  select slug into v_cert_slug from certifications where id = new.certification_id;

  v_badge_key := case v_cert_slug
    when 'explorador' then 'explorer'
    when 'corredor'   then 'runner'
    else null
  end;

  if v_badge_key is not null then
    perform fn_grant_badge(new.user_id, v_badge_key);
  end if;

  -- Triathlete = trilha real inteira concluída (hoje, Explorador + Corredor —
  -- Maratonista/Triatleta não têm zona/conteúdo próprio ainda, sql/017).
  if v_cert_slug in ('explorador', 'corredor') then
    select count(*) into v_real_certs
      from user_certifications uc
      join certifications c on c.id = uc.certification_id
     where uc.user_id = new.user_id
       and c.slug in ('explorador', 'corredor')
       and uc.revoked_at is null;

    if v_real_certs = 2 then
      perform fn_grant_badge(new.user_id, 'triathlete');
    end if;
  end if;

  return new;
end;
$$;

comment on function public.fn_grant_badge_on_certification() is
  'Concede Explorer/Runner na emissão da certificação de zona correspondente, e Triathlete quando as duas estiverem emitidas e não revogadas (trilha real completa). AFTER INSERT em user_certifications — mesmo evento de trg_issue_certification (schema base), sem alterar essa trigger já sensível.';

drop trigger if exists trg_grant_badge_on_certification on public.user_certifications;
create trigger trg_grant_badge_on_certification
after insert on public.user_certifications
for each row execute function public.fn_grant_badge_on_certification();

-- ----------------------------------------------------------------------------
-- 3. Gabarito Garmin — 100% na 1ª tentativa de qualquer quiz
-- ----------------------------------------------------------------------------
create or replace function public.fn_grant_badge_on_quiz_100()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.finished_at is not null and new.score_pct = 100 and new.attempt_number = 1 then
    perform fn_grant_badge(new.user_id, 'gabarito-garmin');
  end if;

  return new;
end;
$$;

comment on function public.fn_grant_badge_on_quiz_100() is
  'Concede Gabarito Garmin quando a 1ª tentativa de um quiz fecha com 100% (fn_finalize_quiz_attempt, schema base, faz UPDATE — nunca INSERT já com finished_at preenchido). Mesmo padrão de AFTER INSERT OR UPDATE de trg_award_points_on_pass.';

drop trigger if exists trg_grant_badge_on_quiz_100 on public.quiz_attempts;
create trigger trg_grant_badge_on_quiz_100
after insert or update on public.quiz_attempts
for each row execute function public.fn_grant_badge_on_quiz_100();

-- ============================================================================
-- FIM DA MIGRAÇÃO 023
-- ============================================================================
