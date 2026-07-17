-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 043: nomes de quem errou em vw_store_knowledge_gaps
-- ============================================================================
-- Pedido do usuário: o Relatório de Gaps da Equipe (teamGapsReport.js) só
-- mostrava a taxa de erro agregada por pergunta — útil pra ver ONDE a
-- equipe erra, mas não QUEM precisa de reforço naquele tema específico.
--
-- Adiciona wrong_respondent_names: nomes (distintos) de quem errou aquela
-- pergunta nos últimos 30 dias, agregados com string_agg + FILTER (mesmo
-- filtro de 30 dias e do mesmo escopo de segurança já embutido na view —
-- nada muda em RLS/segurança, só um agregado a mais no SELECT). Só
-- adiciona coluna no fim (CREATE OR REPLACE VIEW), sem precisar dropar —
-- ao contrário da 020, aqui não há reordenação de coluna.
-- ============================================================================

create or replace view public.vw_store_knowledge_gaps as
select
  p.store_id,
  s.name        as store_name,
  qz.id         as quiz_id,
  qz.title      as quiz_title,
  q.id          as question_id,
  q.body        as question_text,
  z.name        as zone_name,
  cert.title    as certification_title,
  cert.criteria->>'level' as certification_level,
  count(*)      as total_answers,
  count(*) filter (where not qa.is_correct) as wrong_answers,
  round(100.0 * count(*) filter (where not qa.is_correct) / count(*), 1) as error_rate_pct,
  string_agg(distinct p.full_name, ', ') filter (where not qa.is_correct) as wrong_respondent_names
from quiz_answers qa
join quiz_attempts qt   on qt.id = qa.attempt_id
join profiles p         on p.id = qt.user_id
join questions q        on q.id = qa.question_id
join quizzes qz         on qz.id = q.quiz_id
left join stores s       on s.id = p.store_id
left join checkpoints cp on cp.checkpoint_type = 'quiz' and cp.reference_id = qz.id
left join zones z        on z.id = cp.zone_id
left join certifications cert on cert.zone_id = z.id
where qa.answered_at >= now() - interval '30 days'
  and (
    fn_is_admin()
    or (fn_is_leader() and p.store_id in (select fn_leader_store_ids()))
  )
group by p.store_id, s.name, qz.id, qz.title, q.id, q.body, z.name, cert.title, cert.criteria->>'level'
order by error_rate_pct desc, total_answers desc;

comment on view public.vw_store_knowledge_gaps is
  'Farol de erros do Líder: taxa de erro por pergunta, últimos 30 dias, escopado à(s) loja(s) do líder ou a toda a organização se admin. Filtro de segurança embutido na query (fn_is_admin/fn_is_leader/fn_leader_store_ids), não em RLS de view. zone_name/certification_title/certification_level (020) resolvidos via checkpoints→zones→certifications.zone_id (017). wrong_respondent_names (043): nomes distintos de quem errou aquela pergunta no período, pra apoio individual, não só o percentual agregado.';

grant select on public.vw_store_knowledge_gaps to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 043
-- ============================================================================
