-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 057: IDs dos colaboradores em vw_store_knowledge_gaps
-- ============================================================================
-- Pedido do usuário: no Relatório de Gaps, o chip de cada colaborador que
-- errou uma pergunta precisa abrir o drawer de diagnóstico DELE — mas a view
-- só expunha wrong_respondent_names como uma string única (string_agg de
-- nomes), sem nenhum id pra linkar o clique a um colaborador específico.
--
-- Adiciona wrong_respondents (jsonb array de {id, full_name}, um por
-- colaborador que errou) — CREATE OR REPLACE VIEW só permite ACRESCENTAR
-- coluna no fim, por isso wrong_respondent_names continua existindo (não é
-- mais lido pelo client novo, mas manter é zero custo e zero risco).
-- Mesmo WHERE/GROUP BY da view original (sql/043) — só a lista de colunas
-- selecionadas muda.
-- ============================================================================

create or replace view public.vw_store_knowledge_gaps as
select
  p.store_id,
  s.name as store_name,
  qz.id as quiz_id,
  qz.title as quiz_title,
  q.id as question_id,
  q.body as question_text,
  z.name as zone_name,
  cert.title as certification_title,
  cert.criteria ->> 'level' as certification_level,
  count(*) as total_answers,
  count(*) filter (where not qa.is_correct) as wrong_answers,
  round(100.0 * count(*) filter (where not qa.is_correct)::numeric / count(*)::numeric, 1) as error_rate_pct,
  string_agg(distinct p.full_name, ', ') filter (where not qa.is_correct) as wrong_respondent_names,
  jsonb_agg(distinct jsonb_build_object('id', p.id, 'full_name', p.full_name)) filter (where not qa.is_correct) as wrong_respondents
from quiz_answers qa
  join quiz_attempts qt on qt.id = qa.attempt_id
  join profiles p on p.id = qt.user_id
  join questions q on q.id = qa.question_id
  join quizzes qz on qz.id = q.quiz_id
  left join stores s on s.id = p.store_id
  left join checkpoints cp on cp.checkpoint_type = 'quiz' and cp.reference_id = qz.id
  left join zones z on z.id = cp.zone_id
  left join certifications cert on cert.zone_id = z.id
where qa.answered_at >= (now() - '30 days'::interval)
  and (fn_is_admin() or fn_is_leader() and (p.store_id in (select fn_leader_store_ids())))
group by p.store_id, s.name, qz.id, qz.title, q.id, q.body, z.name, cert.title, (cert.criteria ->> 'level')
order by (round(100.0 * count(*) filter (where not qa.is_correct)::numeric / count(*)::numeric, 1)) desc, (count(*)) desc;

comment on view public.vw_store_knowledge_gaps is
  'Farol de gaps por pergunta (últimos 30 dias), escopado por loja/papel via RLS embutida no WHERE. wrong_respondents (sql/057) é a versão estruturada (jsonb [{id,full_name}]) de wrong_respondent_names, pra permitir chips clicáveis por colaborador no Relatório de Gaps.';

-- ============================================================================
-- FIM DA MIGRAÇÃO 057
-- ============================================================================
