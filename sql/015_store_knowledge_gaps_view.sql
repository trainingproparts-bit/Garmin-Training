-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 015: vw_store_knowledge_gaps
-- ============================================================================
-- "Relatório de Gaps da Equipe" (farol de erros) do Dashboard do Líder.
-- Nenhuma tabela nova: extrai o histórico direto de quiz_answers/
-- quiz_attempts (schema base, garmin_training_hub_migrations.sql seção 4),
-- que já guarda cada resposta congelada por pergunta/tentativa.
--
-- Modelagem: quizzes não têm FK direta pra modules (são checkpoints
-- irmãos de módulo dentro de uma zone, não filhos de um módulo) — por isso
-- "Módulo/Tema" aqui é quizzes.title, o agrupamento mais próximo que o
-- schema real oferece. Se um dia quizzes ganhar module_id, ajustar aqui.
--
-- Segurança: a view NÃO tem RLS própria (views não suportam policy; só
-- tabelas). O filtro de escopo é embutido na própria query, usando
-- fn_is_admin()/fn_is_leader()/fn_leader_store_ids() — as 3 já são
-- SECURITY DEFINER (sql/013), então funcionam corretamente aqui mesmo a
-- view rodando com os privilégios do dono (bypassa RLS de
-- profiles/quiz_answers/quiz_attempts de propósito, para poder agregar
-- entre usuários — o auth.uid() dentro dessas funções sempre reflete quem
-- está consultando de verdade, não o dono da view). Resultado: colaborador
-- comum consultando a view recebe 0 linhas; líder só vê a própria loja;
-- admin vê todas (com quebra por loja, já que store_id/store_name entram
-- no agrupamento).
--
-- "Vivo e dinâmico": filtro de 30 dias em qa.answered_at — gargalo antigo já
-- resolvido pela equipe some sozinho do relatório sem precisar de rotina de
-- limpeza.
-- ============================================================================

create index if not exists idx_quiz_answers_answered_at on quiz_answers(answered_at);

create or replace view public.vw_store_knowledge_gaps as
select
  p.store_id,
  s.name        as store_name,
  qz.id         as quiz_id,
  qz.title      as quiz_title,
  q.id          as question_id,
  q.body        as question_text,
  count(*)      as total_answers,
  count(*) filter (where not qa.is_correct) as wrong_answers,
  round(100.0 * count(*) filter (where not qa.is_correct) / count(*), 1) as error_rate_pct
from quiz_answers qa
join quiz_attempts qt on qt.id = qa.attempt_id
join profiles p       on p.id = qt.user_id
join questions q      on q.id = qa.question_id
join quizzes qz       on qz.id = q.quiz_id
left join stores s    on s.id = p.store_id
where qa.answered_at >= now() - interval '30 days'
  and (
    fn_is_admin()
    or (fn_is_leader() and p.store_id in (select fn_leader_store_ids()))
  )
group by p.store_id, s.name, qz.id, qz.title, q.id, q.body
order by error_rate_pct desc, total_answers desc;

comment on view public.vw_store_knowledge_gaps is
  'Farol de erros do Líder: taxa de erro por pergunta, últimos 30 dias, escopado à(s) loja(s) do líder ou a toda a organização se admin. Filtro de segurança embutido na query (fn_is_admin/fn_is_leader/fn_leader_store_ids), não em RLS de view (views não suportam policy).';

grant select on public.vw_store_knowledge_gaps to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 015
-- ============================================================================
