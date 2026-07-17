-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 052: corrige crash "brand_id null" no Mural
-- ============================================================================
-- Bug real reportado pelo usuário: "o quiz ainda está dando erro... Não foi
-- possível calcular seu resultado agora" mesmo depois da dedupe de perguntas
-- (sql/050). Testado ao vivo via SQL direto (impersonando auth.uid() da
-- Samara, respondendo todas as perguntas certas) em TODOS os 12 quizzes
-- publicados do sistema — TODOS falharam de verdade com o mesmo erro:
--   "null value in column brand_id of relation activity_feed violates
--    not-null constraint"
-- Stack trace completo (capturado via GET STACKED DIAGNOSTICS) apontou a
-- causa exata: fn_finalize_quiz_attempt (sql/039) concede o badge "Speed
-- Run" quando a tentativa passa em <60s com nota >=80% — isso insere direto
-- em user_badges (sem passar pela função segura fn_grant_badge), o que
-- dispara o trigger fn_post_activity_badge_earned. Essa função lia
-- profiles.brand_id pra popular activity_feed.brand_id (NOT NULL) — mas
-- profiles.brand_id é NULL pra colaboradores normais (a marca é escolhida
-- client-side por sessão via window.selectedBrandId, nunca persistida no
-- perfil; só fn_touch_streak, sql/033, já tinha o guard certo pra isso).
-- Qualquer tentativa rápida (<60s) com nota >=80% batia nesse crash — não é
-- caso raro: qualquer colaborador respondendo com confiança cai nele.
--
-- fn_post_activity_certification_issued (mesmo arquivo/padrão) tinha
-- exatamente o mesmo bug, só que nunca foi exercitado ao vivo ainda porque
-- nenhuma certificação real foi emitida nesta sessão de teste.
--
-- Correção: as duas funções passam a tirar o brand_id de uma coluna que É
-- garantidamente NOT NULL e semanticamente mais correta pro evento em si —
-- badges.brand_id (o badge já é escopado por marca) e
-- certifications.brand_id — em vez de profiles.brand_id.
-- ============================================================================

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
  select id, full_name, store_id into v_profile from profiles where id = new.user_id;
  select id, title, icon_url, brand_id into v_badge from badges where id = new.badge_id;

  if v_profile.id is null or v_badge.id is null then
    return new;
  end if;

  insert into activity_feed (brand_id, subject_id, store_id, trigger_type, source_event, related_badge_id, message)
  values (
    v_badge.brand_id,
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
  'Posta no Mural quando um badge é concedido. brand_id vem de badges.brand_id (NOT NULL, badge já é escopado por marca) — antes vinha de profiles.brand_id, que é NULL pra colaboradores normais (marca é sessão client-side, não persiste no perfil) e derrubava fn_finalize_quiz_attempt inteiro sempre que o badge Speed Run era concedido (sql/052).';

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
  select id, full_name, store_id into v_profile from profiles where id = new.user_id;
  select id, title, brand_id into v_cert from certifications where id = new.certification_id;

  if v_profile.id is null or v_cert.id is null then
    return new;
  end if;

  insert into activity_feed (brand_id, subject_id, store_id, trigger_type, source_event, message)
  values (
    v_cert.brand_id,
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
  'Posta no Mural quando uma certificação é emitida. brand_id vem de certifications.brand_id (NOT NULL) — mesmo bug/mesma correção de fn_post_activity_badge_earned (sql/052): profiles.brand_id é NULL pra colaboradores normais.';

-- ============================================================================
-- FIM DA MIGRAÇÃO 052
-- ============================================================================
