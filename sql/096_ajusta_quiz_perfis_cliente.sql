-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 096: ajusta 3 perguntas do quiz de
-- "Perfis de Cliente" que não batiam exatamente com o texto do módulo
-- ============================================================================
-- Diferente de "O Universo Garmin" (sql/095), este quiz já estava bem
-- alinhado ao texto (12 das 15 perguntas conferem exatamente). Só 3 tinham
-- problema:
--   Q0: resposta certa citava "Forerunner 55 ou 165", mas a lição só lista
--       165/70/170 pra esse perfil (Corredor Iniciante) — Forerunner 55
--       nem aparece nesse trecho.
--   Q10: resposta certa atribuía "+42.000 campos mapeados" ao Approach S50,
--        mas a lição atribui esse dado ao Approach S44 (S50 é "tela AMOLED
--        e experiência completa", sem menção ao número de campos).
--   Q11: testava uma objeção ("celular no suporte não é suficiente") que
--        não existe em nenhum lugar do texto do módulo pro perfil Ciclista
--        — pergunta inventada, sem lastro na lição. Substituída por uma
--        pergunta sobre o produto principal do perfil, que estava no texto
--        mas não era testado.
-- ============================================================================

begin;

update questions set explanation = 'A lição indica o Forerunner 165 como porta de entrada ideal pra esse perfil (também considerando o Forerunner 70 ou 170).'
where id = '4d0def67-1ff7-4576-86ee-fbe8fd2f8a8f';
update alternatives set body = 'Forerunner 165, a porta de entrada ideal para iniciantes' where id = 'b105c887-3e02-4aca-aee1-e433940bede3';

update questions set explanation = 'O Approach S50 é a versão AMOLED com experiência mais completa; o mapeamento de mais de 42 mil campos é a característica citada do Approach S44 na lição.'
where id = 'd3266833-4b3b-4295-a43b-363172b926ec';
update alternatives set body = 'Approach S50, tela AMOLED e experiência mais completa' where id = '30ba5923-5e14-4bf5-b909-6a7e02f20d34';

update questions set
  body = 'Qual é o produto principal recomendado para o perfil "Ciclista"?',
  explanation = 'A lição indica o Edge 850 como produto principal, considerando também Edge 550, Edge 1050, Varia RTL515 e Rally RK 200.'
where id = 'aeef808c-7e55-4ae3-8fe0-61aeb0254e9d';
update alternatives set body = 'Edge 850', is_correct = true where id = 'e2fb8202-2488-4a1f-a847-5a2cab641796';
update alternatives set body = 'Fenix 8', is_correct = false where id = '1c334384-6830-433d-83df-21c8649376e1';
update alternatives set body = 'Forerunner 970', is_correct = false where id = '5653f851-21df-44cc-ac6f-735da8516f1e';
update alternatives set body = 'Instinct 3', is_correct = false where id = '97660130-06bf-4a00-9305-363d8751a3cb';

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 096
-- ============================================================================
