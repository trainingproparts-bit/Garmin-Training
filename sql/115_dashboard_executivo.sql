-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 115: Dashboard Executivo
-- ============================================================================
-- Pedido: dashboard executivo de analytics para a Gestora de Treinamentos
-- (visão geral da operação + drill-down por colaborador + funil + evolução
-- temporal + conteúdo com mais dificuldade + risco de baixa performance).
--
-- Construído estritamente sobre fontes VIVAS do schema (confirmado por
-- auditoria de código antes de escrever isto — não é o documento de
-- modelagem aspiracional). Deliberadamente NÃO usa:
--   - login_events / study_sessions / page_views — nenhuma tela grava nelas
--     desde sempre (mesma lacuna já documentada em liderDashboard.js/041).
--   - achievements / user_achievements — código morto, nenhuma tela lê.
--   - leaderboard / mv_leaderboard_* — o frontend de ranking (leaderboardService.js)
--     assume colunas (season_id, completed_modules...) que não existem em
--     nenhuma migração deste repositório; tratar como não confiável.
--   - v_module_difficulty — o join quiz↔módulo dessa view é `on false` de
--     propósito (comentário do autor original admite isso).
--
-- Três views novas, mesmo padrão de segurança já usado em
-- v_lider_zona_atual/vw_store_knowledge_gaps/v_team_album: RLS embutida no
-- próprio WHERE (fn_is_admin() OR fn_is_leader() escopado por
-- fn_leader_store_ids()), porque view não herda RLS de tabela nem tem RLS
-- própria no Postgres. Este painel novo é admin-only no frontend, mas a
-- condição de líder é mantida por consistência com o resto do schema (custo
-- zero, mantém a view reutilizável se um dia o Painel do Líder quiser usar).
--
-- Pré-requisito: schema base + sql/004 (performance_score) + sql/033
-- (streak) + sql/037 (v_team_album/is_top_seller) + sql/046
-- (avaliacoes_google) + sql/005/006 (evaluations) já aplicados.
-- ============================================================================


-- ============================================================================
-- 1) v_exec_colaborador_resumo — uma linha por colaborador ativo
-- ============================================================================
-- Espinha dorsal da tabela "Equipe & Risco" e do drill-down individual do
-- dashboard executivo. Progresso é calculado sobre TODOS os checkpoints
-- obrigatórios de qualquer zona com conteúdo real, não só Explorador/Atleta
-- (diferente de v_lider_zona_atual, sql/041, que foi escrita quando só essas
-- 2 zonas existiam) — assim já estende sozinho conforme Maratonista/
-- Triatleta/Aventureiro ganham conteúdo.
--
-- dias_inatividade usa o maior timestamp real de atividade entre lição,
-- quiz, game e avaliação trimestral concluídos — mais completo que o cálculo
-- do Painel do Líder hoje (só lição+quiz). Continua sem usar login/sessão,
-- porque essas tabelas não são gravadas por nenhuma tela.
--
-- "Reprovação recorrente" = existe algum quiz em que as 2 tentativas
-- finalizadas mais recentes do colaborador foram ambas reprovadas (sinal de
-- dificuldade persistente, não só um erro pontual).
-- ============================================================================

drop view if exists public.v_exec_colaborador_resumo;

create view public.v_exec_colaborador_resumo as
with checkpoints_obrigatorios as (
  -- brand_id explícito (via zona→trilha) — sem isso, um cross join simples
  -- contaria checkpoints da Shokz no total de um colaborador Garmin (e
  -- vice-versa), inflando artificialmente o denominador do progresso.
  select c.id as checkpoint_id, t.brand_id
  from public.checkpoints c
  join public.zones z on z.id = c.zone_id
  join public.trails t on t.id = z.trail_id
  where c.is_required = true
),
progresso as (
  select
    p.id as user_id,
    count(co.checkpoint_id) as checkpoints_obrigatorios_total,
    count(up.id) filter (where up.status = 'completed') as checkpoints_obrigatorios_concluidos
  from public.profiles p
  join checkpoints_obrigatorios co on co.brand_id = p.brand_id
  left join public.user_progress up
    on up.checkpoint_id = co.checkpoint_id and up.user_id = p.id
  group by p.id
),
ultima_atividade as (
  select user_id, max(ts) as data_ultima_atividade
  from (
    select user_id, completed_at as ts from public.lesson_progress where completed_at is not null
    union all
    select user_id, finished_at as ts from public.quiz_attempts where finished_at is not null
    union all
    select user_id, finished_at as ts from public.game_sessions where finished_at is not null
    union all
    select user_id, finished_at as ts from public.evaluation_attempts where finished_at is not null
  ) eventos
  group by user_id
),
quiz_stats as (
  select
    qa.user_id,
    count(*) as quiz_tentativas_total,
    count(*) filter (where qa.passed) as quiz_aprovacoes,
    round(100.0 * count(*) filter (where qa.passed)::numeric / nullif(count(*), 0), 1) as quiz_taxa_aprovacao_pct
  from public.quiz_attempts qa
  where qa.finished_at is not null
  group by qa.user_id
),
quiz_acerto as (
  select
    qt.user_id,
    round(100.0 * count(*) filter (where qan.is_correct)::numeric / nullif(count(*), 0), 1) as quiz_taxa_acerto_pct
  from public.quiz_answers qan
  join public.quiz_attempts qt on qt.id = qan.attempt_id
  group by qt.user_id
),
reprovacao_recorrente as (
  select distinct user_id, true as tem_reprovacao_recorrente
  from (
    select
      qt.user_id,
      qt.quiz_id,
      bool_and(not coalesce(qt.passed, false)) as ultimas_duas_reprovadas,
      count(*) as n
    from (
      select
        user_id, quiz_id, passed,
        row_number() over (partition by user_id, quiz_id order by finished_at desc) as rn
      from public.quiz_attempts
      where finished_at is not null
    ) qt
    where qt.rn <= 2
    group by qt.user_id, qt.quiz_id
    having count(*) = 2
  ) por_quiz
  where ultimas_duas_reprovadas
),
certificacao as (
  select
    uc.user_id,
    count(*) as certificacoes_ativas,
    (array_agg(c.title order by
      case c.slug
        when 'triatleta' then 5
        when 'maratonista' then 4
        when 'aventureiro' then 3
        when 'corredor' then 2
        when 'explorador' then 1
        else 0
      end desc
    ))[1] as certificacao_mais_alta
  from public.user_certifications uc
  join public.certifications c on c.id = uc.certification_id
  where uc.revoked_at is null
  group by uc.user_id
),
streak as (
  select
    s.user_id,
    case
      when s.last_activity_date is null then 0
      when s.last_activity_date = current_date then s.current_streak_days
      when s.last_activity_date >= (
        case extract(dow from current_date)
          when 1 then current_date - 3
          when 0 then current_date - 2
          when 6 then current_date - 1
          else current_date - 1
        end
      ) then s.current_streak_days
      else 0
    end as streak_atual,
    s.longest_streak_days as streak_recorde
  from public.streaks s
),
avaliacao_trimestral as (
  select distinct on (ea.user_id)
    ea.user_id,
    ea.passed as avaliacao_trimestral_aprovado,
    ea.finished_at as avaliacao_trimestral_data
  from public.evaluation_attempts ea
  where ea.finished_at is not null
  order by ea.user_id, ea.finished_at desc
),
google as (
  select
    profile_id as user_id,
    round(avg(nota), 1) as avaliacoes_google_media,
    count(*) as avaliacoes_google_qtd
  from public.avaliacoes_google
  group by profile_id
)
select
  p.id as colaborador_id,
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
  coalesce(cert.certificacoes_ativas, 0) as certificacoes_ativas,
  cert.certificacao_mais_alta,
  coalesce(pr.checkpoints_obrigatorios_total, 0) as checkpoints_obrigatorios_total,
  coalesce(pr.checkpoints_obrigatorios_concluidos, 0) as checkpoints_obrigatorios_concluidos,
  case when coalesce(pr.checkpoints_obrigatorios_total, 0) = 0 then null
       else round(100.0 * pr.checkpoints_obrigatorios_concluidos / pr.checkpoints_obrigatorios_total, 1)
  end as progresso_pct,
  ua.data_ultima_atividade,
  case when ua.data_ultima_atividade is null then null
       else extract(day from (now() - ua.data_ultima_atividade))::int
  end as dias_inatividade,
  coalesce(qs.quiz_tentativas_total, 0) as quiz_tentativas_total,
  coalesce(qs.quiz_aprovacoes, 0) as quiz_aprovacoes,
  qs.quiz_taxa_aprovacao_pct,
  qac.quiz_taxa_acerto_pct,
  coalesce(rr.tem_reprovacao_recorrente, false) as tem_reprovacao_recorrente,
  at.avaliacao_trimestral_aprovado,
  at.avaliacao_trimestral_data,
  g.avaliacoes_google_media,
  coalesce(g.avaliacoes_google_qtd, 0) as avaliacoes_google_qtd
from public.profiles p
left join public.stores s on s.id = p.store_id
left join progresso pr on pr.user_id = p.id
left join ultima_atividade ua on ua.user_id = p.id
left join quiz_stats qs on qs.user_id = p.id
left join quiz_acerto qac on qac.user_id = p.id
left join reprovacao_recorrente rr on rr.user_id = p.id
left join certificacao cert on cert.user_id = p.id
left join streak st on st.user_id = p.id
left join avaliacao_trimestral at on at.user_id = p.id
left join google g on g.user_id = p.id
where p.role_id in (1, 2)
  and p.status = 'active'
  and p.deleted_at is null
  and (
    fn_is_admin()
    or (fn_is_leader() and p.store_id in (select fn_leader_store_ids()))
  );

comment on view public.v_exec_colaborador_resumo is
  'Uma linha por colaborador ativo (role collaborator/leader, status active) com progresso geral (todas as zonas com checkpoints obrigatórios reais, não só Explorador/Atleta), desempenho em quiz, streak efetivo, certificações, avaliação trimestral e avaliações Google. Base da tabela "Equipe & Risco" e do drill-down individual do Dashboard Executivo. Segurança embutida no WHERE (admin vê tudo, líder só a própria loja) — mesmo padrão de v_team_album/vw_store_knowledge_gaps.';

grant select on public.v_exec_colaborador_resumo to authenticated;


-- ============================================================================
-- 2) v_exec_funil_aprendizagem — flags de etapa do funil por colaborador
-- ============================================================================
-- Uma linha por colaborador ativo, com booleanos por etapa (iniciou → módulo
-- em andamento → módulo concluído → quiz iniciado → quiz concluído → quiz
-- aprovado). O frontend agrega/filtra por loja/cargo em memória sem nova
-- query a cada troca de filtro (mesmo padrão client-side de
-- teamGapsReport.js). Generalizado por checkpoints reais — não hardcoded a
-- zonas específicas, então cresce sozinho conforme mais zonas ganham
-- conteúdo (diferente de v_lider_zona_atual, sql/041).
-- ============================================================================

drop view if exists public.v_exec_funil_aprendizagem;

create view public.v_exec_funil_aprendizagem as
select
  p.id as colaborador_id,
  p.store_id,
  s.name as store_name,
  p.job_title,
  exists (
    select 1 from public.user_progress up
    where up.user_id = p.id and up.status <> 'locked'
  ) as iniciou_trilha,
  exists (
    select 1 from public.user_progress up
    join public.checkpoints c on c.id = up.checkpoint_id
    where up.user_id = p.id and c.checkpoint_type = 'module' and up.status = 'in_progress'
  ) as modulo_em_andamento,
  exists (
    select 1 from public.user_progress up
    join public.checkpoints c on c.id = up.checkpoint_id
    where up.user_id = p.id and c.checkpoint_type = 'module' and up.status = 'completed'
  ) as modulo_concluido,
  exists (
    select 1 from public.quiz_attempts qt where qt.user_id = p.id
  ) as quiz_iniciado,
  exists (
    select 1 from public.quiz_attempts qt where qt.user_id = p.id and qt.finished_at is not null
  ) as quiz_concluido,
  exists (
    select 1 from public.quiz_attempts qt where qt.user_id = p.id and qt.passed = true
  ) as quiz_aprovado
from public.profiles p
left join public.stores s on s.id = p.store_id
where p.role_id in (1, 2)
  and p.status = 'active'
  and p.deleted_at is null
  and (
    fn_is_admin()
    or (fn_is_leader() and p.store_id in (select fn_leader_store_ids()))
  );

comment on view public.v_exec_funil_aprendizagem is
  'Flags de etapa do funil de aprendizagem (iniciou → módulo em andamento → módulo concluído → quiz iniciado → quiz concluído → quiz aprovado) por colaborador ativo, para o Dashboard Executivo agregar/filtrar por loja/cargo em memória. Generalizado por checkpoints reais de qualquer zona, não hardcoded a Explorador/Atleta.';

grant select on public.v_exec_funil_aprendizagem to authenticated;


-- ============================================================================
-- 3) v_exec_evolucao_mensal — série temporal por colaborador/mês
-- ============================================================================
-- Uma linha por (colaborador, mês) com XP ganho, checkpoints concluídos e
-- desempenho em quiz naquele mês — só a partir de timestamps confirmados
-- vivos pela auditoria (points_ledger.created_at, checkpoint_progress.changed_at,
-- quiz_attempts.finished_at). O frontend agrupa por mês e filtra por loja em
-- memória (join com v_exec_colaborador_resumo, já carregada), em vez desta
-- view pré-agregar por loja e perder flexibilidade de filtro.
-- ============================================================================

drop view if exists public.v_exec_evolucao_mensal;

create view public.v_exec_evolucao_mensal as
with xp as (
  select user_id, date_trunc('month', created_at)::date as mes, sum(points) as xp_ganho
  from public.points_ledger
  group by 1, 2
),
chk as (
  select user_id, date_trunc('month', changed_at)::date as mes, count(*) as checkpoints_concluidos
  from public.checkpoint_progress
  where to_status = 'completed'
  group by 1, 2
),
qz as (
  select
    user_id,
    date_trunc('month', finished_at)::date as mes,
    count(*) as quiz_tentativas,
    count(*) filter (where passed) as quiz_aprovados
  from public.quiz_attempts
  where finished_at is not null
  group by 1, 2
),
certs as (
  select user_id, date_trunc('month', issued_at)::date as mes, count(*) as certificacoes_emitidas
  from public.user_certifications
  group by 1, 2
),
meses as (
  select user_id, mes from xp
  union select user_id, mes from chk
  union select user_id, mes from qz
  union select user_id, mes from certs
)
select
  m.user_id as colaborador_id,
  m.mes,
  coalesce(xp.xp_ganho, 0) as xp_ganho,
  coalesce(chk.checkpoints_concluidos, 0) as checkpoints_concluidos,
  coalesce(qz.quiz_tentativas, 0) as quiz_tentativas,
  coalesce(qz.quiz_aprovados, 0) as quiz_aprovados,
  coalesce(certs.certificacoes_emitidas, 0) as certificacoes_emitidas
from meses m
left join xp on xp.user_id = m.user_id and xp.mes = m.mes
left join chk on chk.user_id = m.user_id and chk.mes = m.mes
left join qz on qz.user_id = m.user_id and qz.mes = m.mes
left join certs on certs.user_id = m.user_id and certs.mes = m.mes
where (
  fn_is_admin()
  or (
    fn_is_leader()
    and exists (
      select 1 from public.profiles p
      where p.id = m.user_id and p.store_id in (select fn_leader_store_ids())
    )
  )
)
order by m.mes;

comment on view public.v_exec_evolucao_mensal is
  'Série temporal por (colaborador, mês): XP ganho, checkpoints concluídos, tentativas/aprovações de quiz, certificações emitidas — só de tabelas com timestamp confirmado vivo. Sem pré-agregação por loja de propósito: o frontend filtra em memória juntando com v_exec_colaborador_resumo, já carregada. Segurança embutida no WHERE, mesmo padrão das demais views deste arquivo.';

grant select on public.v_exec_evolucao_mensal to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 115
-- ============================================================================
