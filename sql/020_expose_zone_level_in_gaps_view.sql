-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 020: expõe zona/nível em vw_store_knowledge_gaps
-- ============================================================================
-- O Card de Alerta Máximo do Relatório de Gaps (teamGapsReport.js) precisa
-- classificar a pergunta mais crítica por nível de módulo (inicial/
-- intermediário/avançado) para sugerir a ação certa. A primeira versão
-- fazia isso com uma heurística de texto sobre quiz_title ("Módulo N" vs
-- "Corredor") — funciona hoje, mas quebra silenciosamente se um quiz novo
-- não seguir esse padrão de nome.
--
-- Fix: a view passa a expor o nível de verdade, resolvido via
-- checkpoints (quiz → zone) → certifications.zone_id (sql/017) →
-- certifications.criteria->>'level' (o mesmo texto "Nível 1"/"Nível 2" já
-- exibido na tela de Certificações). Sem heurística nenhuma no cliente.
--
-- Confirmado antes de aplicar: nenhum quiz é referenciado por mais de um
-- checkpoint (checkpoints.reference_id é único por quiz), então o LEFT JOIN
-- não duplica linha.
-- ============================================================================

-- CREATE OR REPLACE VIEW não deixa inserir coluna no meio de uma view
-- existente (só no fim) — precisa dropar e recriar.
drop view if exists public.vw_store_knowledge_gaps;

create view public.vw_store_knowledge_gaps as
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
  round(100.0 * count(*) filter (where not qa.is_correct) / count(*), 1) as error_rate_pct
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
  'Farol de erros do Líder: taxa de erro por pergunta, últimos 30 dias, escopado à(s) loja(s) do líder ou a toda a organização se admin. Filtro de segurança embutido na query (fn_is_admin/fn_is_leader/fn_leader_store_ids), não em RLS de view. zone_name/certification_title/certification_level (020) resolvidos via checkpoints→zones→certifications.zone_id (017) — null quando o quiz não é checkpoint de nenhuma zona com certificação (ex.: Circuito de Desafios, quizzes extras).';

grant select on public.vw_store_knowledge_gaps to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 020
-- ============================================================================
