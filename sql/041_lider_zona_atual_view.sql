-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 041: v_lider_zona_atual (Dashboard do Líder)
-- ============================================================================
-- Pedido do usuário: dashboard do líder não permitia ver onde cada
-- colaborador está no funil (ex.: "Explorador - Módulo 3" vs "Atleta -
-- Módulo 1"). Construído estritamente sobre a estrutura REAL de hoje —
-- confirmado por query direta antes de escrever isto:
--   - Só "Zona Explorador" e "Zona Atleta" têm conteúdo real (módulos e
--     checkpoints). "Maratonista"/"Triatleta" existem em `certifications`
--     mas com `zone_id = null` — sem módulo nenhum vinculado ainda.
--   - `certifications.title` da 2ª certificação real ainda é 'Corredor'
--     (slug 'corredor') — só o NOME DA ZONA foi trocado pra "Atleta" no
--     sql/038, a certificação em si não (fora do escopo daquele pedido).
--     Esta view já expõe "Atleta" como rótulo (mesmo mapeamento visual
--     usado no app desde sql/038), sem precisar renomear a certificação.
--   - `profiles.hired_at` existe mas está NULL pros 14 usuários reais hoje
--     — a regra de onboarding cai pra `created_at` como data de referência
--     nesse caso (RH ainda não preencheu), e marca isso explicitamente
--     (`onboarding_data_estimada`) pro dashboard não fingir precisão que
--     não existe.
--   - Sem `study_sessions`/`login_events` populados (mesma lacuna já
--     documentada em `liderDashboard.js`) — inatividade usa a última
--     atividade REAL em `lesson_progress`/`quiz_attempts`.
--
-- Segurança: Postgres não tem RLS nativa em views — mesmo padrão já usado
-- em `v_ranking_public`/`vw_store_knowledge_gaps`/`v_team_album`: a
-- condição de escopo (admin vê tudo, líder só a própria loja) fica
-- embutida no WHERE da própria view, usando as funções SECURITY DEFINER
-- que já existem (`fn_is_admin`/`fn_is_leader`/`fn_leader_store_ids`).
--
-- 041b: `stores.name` embutido direto na view (`loja`) em vez de depender
-- do PostgREST auto-detectar o FK de `store_id` pra embedding — views não
-- carregam constraint de FK, então `stores(name)` não funcionaria como
-- embed automático do lado do cliente.
-- ============================================================================

drop view if exists public.v_lider_zona_atual;

create view public.v_lider_zona_atual as
with checkpoints_reais as (
  -- só as zonas com conteúdo de verdade hoje — funil "elegante" de 2 etapas
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
where p.deleted_at is null
  and p.role_id in (1, 2)
  and (
    fn_is_admin()
    or (fn_is_leader() and p.store_id in (select fn_leader_store_ids()))
  );

comment on view public.v_lider_zona_atual is
  'Posição de cada colaborador no funil Explorador→Atleta (só as 2 zonas com conteúdo real hoje), com flag de onboarding (90 dias sem concluir Atleta, com fallback pra created_at quando hired_at está null) e dias de inatividade (última atividade real em lesson_progress/quiz_attempts, já que study_sessions/login_events nunca foram populados). Escopo de segurança embutido no WHERE (mesmo padrão de v_ranking_public/vw_store_knowledge_gaps) — admin vê tudo, líder só a própria loja.';

-- ============================================================================
-- FIM DA MIGRAÇÃO 041
-- ============================================================================
