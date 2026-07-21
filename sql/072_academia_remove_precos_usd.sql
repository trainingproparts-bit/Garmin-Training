-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 072: remove valores em US$ da Academia de
-- Produtos (todos os 6 Forerunners)
-- ============================================================================
-- Pedido do usuário (2026-07-21): "tira os valores em US" — os preços eram
-- os de lançamento no site americano da Garmin (garmin.com), que não
-- refletem preço de venda real no Brasil. Escopo confirmado com o usuário:
-- todos os 6 produtos (570/970 que já existiam + 70/170/55/165 desta seção),
-- não só os 4 novos.
--
-- Abordagem: remove o VALOR (price_usd + toda menção textual "US$ X,XX"),
-- sem inventar um preço em outra moeda — não há fonte oficial de preço em
-- BRL. Onde o preço era o próprio ponto da linha (ex.: rodada "Preço
-- Sugerido" do Duelo, linha "Preço sugerido" da tabela de comparativo),
-- remove o item inteiro em vez de deixar um campo vazio sem sentido.
-- Onde o preço aparecia como argumento comparativo em prosa (ex.: "por
-- US$ 200 a mais"), a frase foi reescrita mantendo o argumento em termos
-- relativos ("por um preço mais alto"), sem inventar número.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. products.price_usd → null (remove o badge de preço do card/header)
-- ----------------------------------------------------------------------------
update products
   set price_usd = null
 where slug in ('forerunner-570','forerunner-970','forerunner-70','forerunner-170','forerunner-55','forerunner-165');

-- ----------------------------------------------------------------------------
-- 2. product_sections — remove/reescreve menções textuais a US$
-- ----------------------------------------------------------------------------

-- visão geral — remove a frase "Preço sugerido: US$ ..." de cada produto
update product_sections set payload = (replace(payload::text,
  '<p><strong>Preço sugerido:</strong> US$ 549,99 (garmin.com, lançamento em maio/2025).</p>', ''))::jsonb
where product_id = (select id from products where slug = 'forerunner-570') and section_type = 'visao_geral';

update product_sections set payload = (replace(payload::text,
  '<p><strong>Preço sugerido:</strong> US$ 749,99 (garmin.com, lançamento em maio/2025).</p>', ''))::jsonb
where product_id = (select id from products where slug = 'forerunner-970') and section_type = 'visao_geral';

update product_sections set payload = (replace(payload::text,
  '<p><strong>Preço sugerido:</strong> US$ 249,99 (garmin.com, lançamento em maio/2026).</p>', ''))::jsonb
where product_id = (select id from products where slug = 'forerunner-70') and section_type = 'visao_geral';

update product_sections set payload = (replace(payload::text,
  '<p><strong>Preço sugerido:</strong> US$ 299,99 (170) ou US$ 349,99 (170 Music), garmin.com, lançamento em maio/2026.</p>', ''))::jsonb
where product_id = (select id from products where slug = 'forerunner-170') and section_type = 'visao_geral';

update product_sections set payload = (replace(payload::text,
  ' Preço sugerido: US$ 199,99.', ''))::jsonb
where product_id = (select id from products where slug = 'forerunner-55') and section_type = 'visao_geral';

update product_sections set payload = (replace(payload::text,
  ' Preço sugerido: US$ 249,99 (165) / US$ 299,99 (165 Music).', ''))::jsonb
where product_id = (select id from products where slug = 'forerunner-165') and section_type = 'visao_geral';

-- FAQ — reescreve frases que citavam diferença de preço em US$
update product_sections set payload = (replace(payload::text,
  'mais armazenamento de música (32 GB) e bateria maior — por um preço US$ 200 mais alto.',
  'mais armazenamento de música (32 GB) e bateria maior — recursos que justificam o preço mais alto do 970.'))::jsonb
where product_id = (select id from products where slug = 'forerunner-570') and section_type = 'faq';

update product_sections set payload = (replace(payload::text,
  'natação em águas abertas e (na versão Music) armazenamento de música — por US$ 50 a mais (170) ou US$ 100 a mais (170 Music).',
  'natação em águas abertas e (na versão Music) armazenamento de música — por um preço mais alto (mais ainda na versão Music).'))::jsonb
where product_id = (select id from products where slug = 'forerunner-70') and section_type = 'faq';

update product_sections set payload = (replace(payload::text,
  'e suporte a fones sem fio, por US$ 50 a mais.',
  'e suporte a fones sem fio, por um preço mais alto.'))::jsonb
where product_id = (select id from products where slug = 'forerunner-170') and section_type = 'faq';

-- Objeções — reescreve pergunta/resposta que citavam valor exato em US$
update product_sections set payload = (replace(replace(payload::text,
  'US$ 200 a mais que o 570 é muita diferença.',
  'O 970 é muito mais caro que o 570?'),
  'É real — mas nesse valor você leva titânio e safira',
  'É real — mas você leva titânio e safira'))::jsonb
where product_id = (select id from products where slug = 'forerunner-970') and section_type = 'objecoes';

update product_sections set payload = (replace(payload::text,
  'o 70 entrega a mesma experiência de treino e recuperação por US$ 50 a menos.',
  'o 70 entrega a mesma experiência de treino e recuperação por um preço mais baixo.'))::jsonb
where product_id = (select id from products where slug = 'forerunner-70') and section_type = 'objecoes';

update product_sections set payload = (replace(payload::text,
  'US$ 50 a mais que o 70 vale a pena?',
  'Vale a pena pagar mais caro que o 70?'))::jsonb
where product_id = (select id from products where slug = 'forerunner-170') and section_type = 'objecoes';

-- Scripts de venda — reescreve fala que citava valor exato em US$
update product_sections set payload = (replace(payload::text,
  'e você leva por US$ 249,99.',
  'e você leva sem pagar o preço dos modelos mais caros.'))::jsonb
where product_id = (select id from products where slug = 'forerunner-70') and section_type = 'scripts_venda';

-- ----------------------------------------------------------------------------
-- 3. product_comparisons — resumo executivo e blocos ricos
-- ----------------------------------------------------------------------------
update product_comparisons set resumo_executivo = replace(resumo_executivo,
  'ECG e compatibilidade com a cinta HRM 600, por US$ 200 a mais.',
  'ECG e compatibilidade com a cinta HRM 600, só que por um preço mais alto.')
where slug = 'forerunner-570-vs-forerunner-970';

update product_comparisons set blocks = (replace(replace(replace(blocks::text,
  'Preço US$ 200 mais baixo · Opção de caixa 42mm',
  'Preço mais baixo · Opção de caixa 42mm'),
  'US$ 200 mais caro · Só existe em 47mm',
  'Preço mais alto · Só existe em 47mm'),
  'só sem mapa colorido, lanterna e ECG — por US$ 200 a menos.',
  'só sem mapa colorido, lanterna e ECG, por um preço mais baixo.'))::jsonb
where slug = 'forerunner-570-vs-forerunner-970';

update product_comparisons set blocks = (replace(blocks::text,
  'Preço mais baixo (US$ 199,99 vs US$ 249,99) — quando ainda disponível',
  'Preço mais baixo — quando ainda disponível'))::jsonb
where slug = 'forerunner-70-vs-forerunner-55';

update product_comparisons set blocks = (replace(blocks::text,
  'Preço mais baixo enquanto disponível (US$ 249,99 vs US$ 299,99) ·',
  'Preço mais baixo enquanto disponível ·'))::jsonb
where slug = 'forerunner-170-vs-forerunner-165';

-- ----------------------------------------------------------------------------
-- 4. comparison_items — remove a linha "Preço sugerido" (sem valor em BRL
--    pra substituir, a linha some em vez de ficar vazia sem sentido; o
--    trigger de sync do review_catalog já cuida de remover o item da
--    revisão espaçada automaticamente no DELETE)
-- ----------------------------------------------------------------------------
delete from comparison_items
 where comparison_id = (select id from product_comparisons where slug = 'forerunner-570-vs-forerunner-970')
   and spec_label = 'Preço sugerido';

delete from comparison_items
 where comparison_id = (select id from product_comparisons where slug = 'forerunner-70-vs-forerunner-55')
   and spec_label = 'Preço sugerido (lançamento)';

delete from comparison_items
 where comparison_id = (select id from product_comparisons where slug = 'forerunner-170-vs-forerunner-165')
   and spec_label = 'Preço sugerido (lançamento)';

-- ----------------------------------------------------------------------------
-- 5. games — remove a rodada "Preço Sugerido" (índice 0 nos 3 jogos) e
--    ajusta a contagem de rodadas/perguntas de 9 pra 8
-- ----------------------------------------------------------------------------
update games
   set config = jsonb_set(
         config #- '{rounds,0}',
         '{meta}',
         (config->'meta') || '{"rodadas_por_partida": 8, "total_perguntas_no_pool": 8}'::jsonb
       )
 where slug in ('duelo-forerunner-570-vs-970', 'duelo-forerunner-70-vs-55', 'duelo-forerunner-170-vs-165')
   and (config->'rounds'->0->'cat'->>'nome') = 'Preço Sugerido';

-- ============================================================================
-- FIM DA MIGRAÇÃO 072
-- ============================================================================
