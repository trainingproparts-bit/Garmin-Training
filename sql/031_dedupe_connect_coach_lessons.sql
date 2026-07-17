-- ============================================================================
-- GARMIN TRAINING HUB — 031: DEDUPLICAÇÃO DAS LIÇÕES DE GARMIN CONNECT E COACH
-- ============================================================================
-- ROADMAP.md já documentava esse bug de dados pré-existente só para Garmin
-- Connect (4 títulos × 3 linhas cada = 12 linhas, mesmo conteúdo). A pesquisa
-- feita para a migração 030 confirmou que o mesmo bug também existe em
-- Garmin Coach (mesmo padrão: 4 títulos × 3 linhas). Isso ficou visível ao
-- testar 030 ao vivo: cada lição aparecia 3 vezes seguidas na tela do
-- módulo, o que esvaziava o valor da reestruturação de conteúdo.
--
-- Confirmado antes de apagar: 0 linhas em lesson_progress referenciam
-- qualquer uma dessas lições (nenhum usuário tem progresso gravado nelas),
-- então a exclusão é segura — não derruba histórico de ninguém.
--
-- Mantém 1 linha por (module_id, title) — a de menor UUID, critério estável
-- e arbitrário já que a tabela não tem created_at. Reduz 24 linhas para 8
-- (4 títulos × 2 módulos).
-- ============================================================================

with ranked as (
  select id, row_number() over (partition by module_id, title order by id) as rn
  from lessons
  where module_id in (
    (select id from modules where title = 'Garmin Connect'),
    (select id from modules where title = 'Garmin Coach')
  )
)
delete from lessons where id in (select id from ranked where rn > 1);

-- ============================================================================
-- FIM DA MIGRAÇÃO 031
-- ============================================================================
