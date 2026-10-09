-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 166: último login na Visão da Operação
-- ============================================================================
-- Pedido do usuário (2026-09-16): a Visão da Operação media "inatividade"
-- pela última ATIVIDADE CONCLUÍDA (lição, quiz, duelo ou avaliação). O
-- problema levantado por ela: "se eu ficar 20 dias sem postar nada novo a
-- galera vai ficar inativa à toa" — sem conteúdo novo pra concluir, uma
-- equipe que entra todo dia aparece como parada.
--
-- E o efeito ia além da coluna: inatividade é o fator de MAIOR peso do score
-- de risco (45 de 100 pts, ver src/services/riskScoring.js), então uma
-- semana sem publicar empurrava a base inteira pra "Atenção"/"Alta atenção".
--
-- Esta migração só ACRESCENTA as duas colunas de login; data_ultima_atividade
-- e dias_inatividade continuam existindo, porque o Desempenho da Equipe
-- (v_lider_zona_atual) legitimamente mostra as duas coisas lado a lado.
--
-- Fonte do login: auth.users.last_sign_in_at, exatamente a mesma já usada por
-- v_lider_zona_atual — não é uma tabela nova nem um dado estimado.
-- ============================================================================

create or replace view v_exec_colaborador_resumo as
with checkpoints_obrigatorios as (
  select c.id as checkpoint_id, t.brand_id
  from checkpoints c
    join zones z on z.id = c.zone_id
    join trails t on t.id = z.trail_id
  where c.is_required = true
), progresso as (
  select p_1.id as user_id,
    count(co.checkpoint_id) as checkpoints_obrigatorios_total,
    count(up.id) filter (where up.status = 'completed') as checkpoints_obrigatorios_concluidos
  from profiles p_1
    join checkpoints_obrigatorios co on co.brand_id = p_1.brand_id
    left join user_progress up on up.checkpoint_id = co.checkpoint_id and up.user_id = p_1.id
  group by p_1.id
), ultima_atividade as (
  select eventos.user_id, max(eventos.ts) as data_ultima_atividade
  from (
    select lesson_progress.user_id, lesson_progress.completed_at as ts
      from lesson_progress where lesson_progress.completed_at is not null
    union all
    select quiz_attempts.user_id, quiz_attempts.finished_at as ts
      from quiz_attempts where quiz_attempts.finished_at is not null
    union all
    select game_sessions.user_id, game_sessions.finished_at as ts
      from game_sessions where game_sessions.finished_at is not null
    union all
    select evaluation_attempts.user_id, evaluation_attempts.finished_at as ts
      from evaluation_attempts where evaluation_attempts.finished_at is not null
  ) eventos
  group by eventos.user_id
), quiz_stats as (
  select qa.user_id,
    count(*) as quiz_tentativas_total,
    count(*) filter (where qa.passed) as quiz_aprovacoes,
    round(100.0 * count(*) filter (where qa.passed)::numeric / nullif(count(*), 0)::numeric, 1) as quiz_taxa_aprovacao_pct
  from quiz_attempts qa
  where qa.finished_at is not null
  group by qa.user_id
), quiz_acerto as (
  select qt.user_id,
    round(100.0 * count(*) filter (where qan.is_correct)::numeric / nullif(count(*), 0)::numeric, 1) as quiz_taxa_acerto_pct
  from quiz_answers qan
    join quiz_attempts qt on qt.id = qan.attempt_id
  group by qt.user_id
), reprovacao_recorrente as (
  select distinct por_quiz.user_id, true as tem_reprovacao_recorrente
  from (
    select qt.user_id, qt.quiz_id,
      bool_and(not coalesce(qt.passed, false)) as ultimas_duas_reprovadas,
      count(*) as n
    from (
      select quiz_attempts.user_id, quiz_attempts.quiz_id, quiz_attempts.passed,
        row_number() over (partition by quiz_attempts.user_id, quiz_attempts.quiz_id order by quiz_attempts.finished_at desc) as rn
      from quiz_attempts
      where quiz_attempts.finished_at is not null
    ) qt
    where qt.rn <= 2
    group by qt.user_id, qt.quiz_id
    having count(*) = 2
  ) por_quiz
  where por_quiz.ultimas_duas_reprovadas
), certificacao as (
  select uc.user_id,
    count(*) as certificacoes_ativas,
    (array_agg(c.title order by (
      case c.slug
        when 'triatleta' then 5
        when 'maratonista' then 4
        when 'aventureiro' then 3
        when 'corredor' then 2
        when 'explorador' then 1
        else 0
      end) desc))[1] as certificacao_mais_alta
  from user_certifications uc
    join certifications c on c.id = uc.certification_id
  where uc.revoked_at is null
  group by uc.user_id
), streak as (
  select s_1.user_id,
    case
      when s_1.last_activity_date is null then 0
      when s_1.last_activity_date = current_date then s_1.current_streak_days
      when s_1.last_activity_date >= case extract(dow from current_date)
        when 1 then current_date - 3
        when 0 then current_date - 2
        when 6 then current_date - 1
        else current_date - 1
      end then s_1.current_streak_days
      else 0
    end as streak_atual,
    s_1.longest_streak_days as streak_recorde
  from streaks s_1
), avaliacao_trimestral as (
  select distinct on (ea.user_id) ea.user_id,
    ea.passed as avaliacao_trimestral_aprovado,
    ea.finished_at as avaliacao_trimestral_data
  from evaluation_attempts ea
  where ea.finished_at is not null
  order by ea.user_id, ea.finished_at desc
), google as (
  select avaliacoes_google.profile_id as user_id,
    round(avg(avaliacoes_google.nota), 1) as avaliacoes_google_media,
    count(*) as avaliacoes_google_qtd
  from avaliacoes_google
  group by avaliacoes_google.profile_id
)
select p.id as colaborador_id,
  p.full_name,
  p.username,
  p.job_title,
  p.status,
  p.store_id,
  s.name as store_name,
  p.brand_id,
  p.performance_score,
  coalesce(st.streak_atual, 0) as streak_atual,
  coalesce(st.streak_recorde, 0) as streak_recorde,
  coalesce(cert.certificacoes_ativas, 0::bigint) as certificacoes_ativas,
  cert.certificacao_mais_alta,
  coalesce(pr.checkpoints_obrigatorios_total, 0::bigint) as checkpoints_obrigatorios_total,
  coalesce(pr.checkpoints_obrigatorios_concluidos, 0::bigint) as checkpoints_obrigatorios_concluidos,
  case
    when coalesce(pr.checkpoints_obrigatorios_total, 0::bigint) = 0 then null::numeric
    else round(100.0 * pr.checkpoints_obrigatorios_concluidos::numeric / pr.checkpoints_obrigatorios_total::numeric, 1)
  end as progresso_pct,
  ua.data_ultima_atividade,
  case
    when ua.data_ultima_atividade is null then null::integer
    else extract(day from now() - ua.data_ultima_atividade)::integer
  end as dias_inatividade,
  coalesce(qs.quiz_tentativas_total, 0::bigint) as quiz_tentativas_total,
  coalesce(qs.quiz_aprovacoes, 0::bigint) as quiz_aprovacoes,
  qs.quiz_taxa_aprovacao_pct,
  qac.quiz_taxa_acerto_pct,
  coalesce(rr.tem_reprovacao_recorrente, false) as tem_reprovacao_recorrente,
  at.avaliacao_trimestral_aprovado,
  at.avaliacao_trimestral_data,
  g.avaliacoes_google_media,
  coalesce(g.avaliacoes_google_qtd, 0::bigint) as avaliacoes_google_qtd,
  -- NOVO (sql/166): mesmo par já exposto por v_lider_zona_atual. Fica no
  -- FIM da lista de propósito: `create or replace view` só aceita coluna
  -- nova acrescentada depois das existentes (no meio dá erro 42P16,
  -- "cannot change name of view column"), e assim não precisa de drop,
  -- que perderia o grant pro authenticated.
  au.last_sign_in_at as ultimo_login,
  case
    when au.last_sign_in_at is null then null::integer
    else extract(day from now() - au.last_sign_in_at)::integer
  end as dias_desde_login
from profiles p
  left join stores s on s.id = p.store_id
  left join progresso pr on pr.user_id = p.id
  left join ultima_atividade ua on ua.user_id = p.id
  left join quiz_stats qs on qs.user_id = p.id
  left join quiz_acerto qac on qac.user_id = p.id
  left join reprovacao_recorrente rr on rr.user_id = p.id
  left join certificacao cert on cert.user_id = p.id
  left join streak st on st.user_id = p.id
  left join avaliacao_trimestral at on at.user_id = p.id
  left join google g on g.user_id = p.id
  left join auth.users au on au.id = p.id
where (p.role_id = any (array[1, 2]))
  and p.status = 'active'
  and p.deleted_at is null
  and (fn_is_admin() or fn_is_leader() and (p.store_id in (select fn_leader_store_ids() as fn_leader_store_ids)));

-- ============================================================================
-- FIM DA MIGRAÇÃO 166
-- ============================================================================
