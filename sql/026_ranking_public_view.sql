-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 026: view pública do Ranking de Pontos
-- ============================================================================
-- Achado ao testar o Ranking (sql/025) com login real de colaborador comum
-- (Daniel Lucena): `profiles` só tem RLS de SELECT pra si mesmo
-- (`profiles_select_own`), pro líder ver a própria loja (`profiles_select_leader`)
-- ou pro admin ver tudo (`profiles_admin_all`) — nenhuma política deixa um
-- colaborador comum ver o placar de outros colegas, então o ranking
-- aparecia com 1 linha só (a própria) pra qualquer um que não fosse líder/admin.
--
-- Corrigido com uma view estreita (mesmo padrão de v_alternatives_public,
-- v_evaluation_questions_public, vw_store_knowledge_gaps já existentes):
-- expõe só id/nome/pontuação/loja de perfis ativos, nunca e-mail/role/status/
-- job_title. Escopo de marca embutido na própria view (não é RLS de view,
-- que não existe no Postgres) — mesma técnica de vw_store_knowledge_gaps.
-- ============================================================================

create or replace view public.v_ranking_public as
select
  p.id,
  p.full_name,
  p.performance_score,
  p.store_id,
  s.name as store_name,
  p.brand_id
from public.profiles p
left join public.stores s on s.id = p.store_id
where p.status = 'active'
  and (
    fn_is_admin()
    or p.brand_id = (select brand_id from public.profiles where id = auth.uid())
  );

comment on view public.v_ranking_public is
  'Ranking de Pontos (RN §6.4) — view pública estreita sobre profiles, só id/full_name/performance_score/store_id/store_name/brand_id de perfis ativos. Escopo de marca embutido na própria query (fn_is_admin() vê tudo; qualquer outro autenticado só a própria marca) — sem isso, profiles_select_own bloqueava colaborador comum de ver o placar de qualquer colega.';

grant select on public.v_ranking_public to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 026
-- ============================================================================
