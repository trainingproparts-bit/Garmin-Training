-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 045: remove destaques_mensais (sql/044)
-- ============================================================================
-- A sql/044 criou destaques_mensais pra um "Destaques do Mês" com escolha
-- manual separada (dropdown + texto livre) pro líder preencher todo mês.
-- Ao pedir a mesma seção na tela inicial (visível pra todos), o usuário
-- mostrou um print cujo conteúdo já é 100% coberto por dado que JÁ existe e
-- JÁ é curado pelo admin no Álbum da Equipe (sql/037):
--   - "Melhor Vendedor <Loja>"  → profiles.is_top_seller ("Ponta do Mês")
--   - "Melhor reputação"        → maior profiles.reputation_score da marca
--
-- Manter as duas fontes em paralelo (destaques_mensais + Álbum) arriscava
-- mostrar nomes diferentes pro mesmo mês em painéis diferentes. Decisão
-- combinada com o usuário: unificar tudo no Álbum (fonte única, sem
-- reentrada manual duplicada) e remover a tabela que ficou sem uso — nenhum
-- dado real dependia dela (testada e limpa na rodada anterior).
-- ============================================================================

drop table if exists public.destaques_mensais;

-- ============================================================================
-- FIM DA MIGRAÇÃO 045
-- ============================================================================
