-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 024: lessons.body → schema de blocos
-- ============================================================================
-- Fase 4 (UX, ux-training-hub-fase4.md §6.6) documenta lições como sequência
-- de blocos tipados (banner, texto rico, accordion, card, timeline, vídeo,
-- galeria, quiz embutido — subconjunto essencial dos 20 componentes do
-- editor completo, decidido com o usuário em 2026-07-10; drag-and-drop e os
-- demais 12 tipos ficam para uma rodada futura) em vez de um HTML fixo
-- único. Esta migração converte as 38 lições reais (content_type='text',
-- body só com a chave 'html') para
-- {"blocks": [{"type": "texto_rico", "html": "..."}]} — sem perda de
-- conteúdo, só empacotando o HTML existente como o primeiro (e único)
-- bloco. Ver src/components/ContentBlocks.js para o renderer/editor dos
-- 8 tipos e src/pages/moduloConteudo.js para o editor administrativo.
--
-- content_library (categoria deep_dive) NÃO tem nenhuma linha em produção
-- hoje — sql/seeds/060/061_biblioteca_deep_dives_*.sql nunca rodaram.
-- Corrigidos na origem para já nascerem no formato de blocos; não precisam
-- de UPDATE aqui.
-- ============================================================================

update public.lessons
set body = jsonb_build_object(
  'blocks',
  jsonb_build_array(
    jsonb_build_object('type', 'texto_rico', 'html', body->>'html')
  )
)
where not (body ? 'blocks')
  and body ? 'html';

comment on table public.lessons is
  'body: {"blocks": [...]} — array de blocos tipados (banner, texto_rico, accordion, card, timeline, video, galeria, quiz_embutido; ver src/components/ContentBlocks.js). Migrado de {"html": "..."} único em sql/024_lesson_content_blocks_migration.sql.';

-- ============================================================================
-- FIM DA MIGRAÇÃO 024
-- ============================================================================
