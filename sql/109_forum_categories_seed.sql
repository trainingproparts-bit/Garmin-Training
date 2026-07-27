-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 109: categorias iniciais do fórum
-- ============================================================================

begin;

insert into forum_categories (name, slug, description, order_index) values
('Resolução de Problemas', 'resolucao-de-problemas', 'Dúvidas técnicas, bugs e problemas no dia a dia com produtos ou processos.', 0),
('Dúvidas Gerais', 'duvidas-gerais', 'Perguntas que não se encaixam nas outras categorias.', 1),
('Sugestões', 'sugestoes', 'Ideias e sugestões de melhoria pra equipe, produtos ou processos.', 2),
('Linha de Produtos', 'linha-de-produtos', 'Discussões sobre modelos, specs e comparativos de produtos Garmin.', 3);

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 109
-- ============================================================================
