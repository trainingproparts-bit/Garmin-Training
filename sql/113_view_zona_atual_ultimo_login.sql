-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 113: v_lider_zona_atual + último login real
-- ============================================================================
-- Pedido do usuário: "quem concluiu eu não consigo ver a última vez que
-- logou, preciso ver mesmo que a pessoa tenha concluído". Duas causas:
--   1) inatividadeBadge() no liderDashboard.js troca a coluna inteira por um
--      badge fixo "✓ Concluiu" quando zona_atual = 'Trilha concluída' —
--      qualquer data que existisse ali desaparecia da UI.
--   2) a única aproximação de atividade que a view tinha vinha de
--      lesson_progress/quiz_attempts (documentado no sql/041 original), que
--      literalmente para de gerar linhas quando a pessoa termina a trilha —
--      não é "último login", é "última lição/quiz".
--
-- Fix: auth.users.last_sign_in_at já é mantido nativamente pelo Supabase Auth
-- a cada login, independente de progresso em lição/quiz. Exposto aqui como
-- ultimo_login/dias_desde_login, colunas novas e independentes de
-- data_ultimo_progresso/dias_inatividade (que continuam existindo, com o
-- mesmo significado de antes). O front (liderDashboard.js/teamService.js)
-- ganhou uma coluna "Último Login" própria, que nunca é substituída pelo
-- badge de conclusão.
-- ============================================================================

drop view if exists public.v_lider_zona_atual;

create view public.v_lider_zona_atual as
with checkpoints_reais as (
  select
    z.id as zone_id,
    case z.name when 'Zona Corredor' then 'Atleta' when 'Zona Atleta' then 'Atleta' else replace(z.name, 'Zona ', '') end as zona_label,
    z.order_index as zona_ordem,
    c.id as checkpoint_id,
    c.order_index as checkpoint_ordem,
    coalesce(m.title, q.title) as etapa_titulo
  from zones z
  join checkpoints c on c.zone_id = z.id
  left join modules m on m.id = c.reference_id and c.checkpoint_type = 'module'
  left join quizzes q on q.id = c.reference_id and c.checkpoint_type = 'quiz'
  where z.name in ('Zona Explorador', 'Zona Atleta', 'Zona Corredor')
),
progresso_expandido as (
  select
    p.id as user_id,
    cr.zone_id,
    cr.zona_label,
    cr.zona_ordem,
    cr.checkpoint_id,
    cr.checkpoint_ordem,
    cr.etapa_titulo,
    up.status
  from profiles p
  cross join checkpoints_reais cr
  left join user_progress up on up.checkpoint_id = cr.checkpoint_id and up.user_id = p.id
  where p.deleted_at is null and p.role_id in (1, 2) -- collaborator + leader (admin não tem trilha — sem loja/marca)
),
pendente_atual as (
  -- primeiro checkpoint NÃO concluído na ordem certa (zona, depois checkpoint) = onde a pessoa está agora
  select distinct on (user_id)
    user_id, zona_label, etapa_titulo
  from progresso_expandido
  where status is distinct from 'completed'
  order by user_id, zona_ordem, checkpoint_ordem
),
ultima_atividade as (
  select user_id, max(ts) as last_activity_at from (
    select user_id, completed_at as ts from lesson_progress where completed_at is not null
    union all
    select user_id, finished_at as ts from quiz_attempts where finished_at is not null
  ) atividades
  group by user_id
),
onboarding_concluido as (
  -- "concluiu Atleta" = tem a certificação 'corredor' (rótulo "Atleta") emitida e não revogada
  select uc.user_id
  from user_certifications uc
  join certifications cert on cert.id = uc.certification_id
  where cert.slug = 'corredor' and uc.revoked_at is null
)
select
  p.id as colaborador_id,
  p.full_name as nome,
  p.store_id,
  s.name as loja,
  p.job_title as cargo,
  coalesce(pa.zona_label, 'Trilha concluída') as zona_atual,
  pa.etapa_titulo as modulo_atual,
  ua.last_activity_at as data_ultimo_progresso,
  case when ua.last_activity_at is null then null
       else extract(day from (now() - ua.last_activity_at))::int
  end as dias_inatividade,
  au.last_sign_in_at as ultimo_login,
  case when au.last_sign_in_at is null then null
       else extract(day from (now() - au.last_sign_in_at))::int
  end as dias_desde_login,
  coalesce(p.hired_at, p.created_at::date) as data_referencia_onboarding,
  (p.hired_at is null) as onboarding_data_estimada,
  (
    (current_date - coalesce(p.hired_at, p.created_at::date)) > 90
    and oc.user_id is null
  ) as alerta_onboarding
from profiles p
left join stores s on s.id = p.store_id
left join pendente_atual pa on pa.user_id = p.id
left join ultima_atividade ua on ua.user_id = p.id
left join onboarding_concluido oc on oc.user_id = p.id
left join auth.users au on au.id = p.id
where p.deleted_at is null
  and p.role_id in (1, 2)
  and (
    fn_is_admin()
    or (fn_is_leader() and p.store_id in (select fn_leader_store_ids()))
  );

comment on view public.v_lider_zona_atual is
  'Posição de cada colaborador no funil Explorador→Atleta (só as 2 zonas com conteúdo real hoje), com flag de onboarding (90 dias sem concluir Atleta, com fallback pra created_at quando hired_at está null), dias de inatividade (última atividade real em lesson_progress/quiz_attempts) e último login real (auth.users.last_sign_in_at, mantido nativamente pelo Supabase Auth — continua populado mesmo após a pessoa concluir a trilha toda, diferente das outras duas colunas). Escopo de segurança embutido no WHERE (mesmo padrão de v_ranking_public/vw_store_knowledge_gaps) — admin vê tudo, líder só a própria loja.';

-- ============================================================================
-- FIM DA MIGRAÇÃO 113
-- ============================================================================
