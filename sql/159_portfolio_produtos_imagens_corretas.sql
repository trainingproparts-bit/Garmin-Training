-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 159: Portfólio de Produtos — corrige imagens
-- ============================================================================
-- Pedido do usuário (2026-09-15): "a imagem ainda tá ruim" + "o lily 2 ta
-- claramente menor" na lição "Portfólio de Produtos Garmin".
--
-- Achado ao investigar: a imagem de capa (topo da lição) e as fotos dos
-- cards Venu 4 e Vivoactive 6 apontavam pra fotos de blog completamente
-- erradas (header de artigo sobre ciclo menstrual "Natural Cycles" e header
-- de um relatório sobre diabetes) — não eram fotos de produto Garmin. O
-- card do Lily 2 usava uma foto de lifestyle real, mas em close no
-- colo/pescoço da modelo, deixando o relógio quase invisível no card
-- (por isso parecia "menor" que os outros).
--
-- Correção: todas as 4 fotos dos flip cards (Lily 2, Lily 2 Active, Venu 4,
-- Vivoactive 6) passam a usar o mesmo estilo de foto oficial de produto
-- (studio, fundo branco, relógio de frente, mesmo enquadramento) direto do
-- CDN da Garmin — mesmo padrão, então nenhum "parece menor" que o outro. A
-- imagem de capa da lição vira uma foto real de lineup de smartwatches
-- Garmin (também do CDN oficial), no lugar do header de blog errado.
-- ============================================================================

update lessons
set body = jsonb_set(
  jsonb_set(
    jsonb_set(
      jsonb_set(
        jsonb_set(body, '{blocks,0,url}',
          '"https://res.garmin.com/en/products/010-03014-00/g/77928-Family-D.jpg"'::jsonb),
        '{blocks,9,cards,0,coverUrl}',
        '"https://res.garmin.com/transform/image/upload/b_rgb:FFFFFF,c_pad,dpr_1.0,f_auto,h_600,q_auto,w_600/c_pad,h_600,w_600/v1/Product_Images/en/products/010-02839-00/v/cf-xl?pgw=1"'::jsonb
      ),
      '{blocks,9,cards,1,coverUrl}',
      '"https://res.garmin.com/transform/image/upload/b_rgb:FFFFFF,c_pad,dpr_1.0,f_auto,h_600,q_auto,w_600/c_pad,h_600,w_600/v1/Product_Images/en/products/010-02891-00/v/cf-xl?pgw=1"'::jsonb
    ),
    '{blocks,9,cards,2,coverUrl}',
    '"https://res.garmin.com/transform/image/upload/b_rgb:FFFFFF,c_pad,dpr_1.0,f_auto,h_600,q_auto,w_600/c_pad,h_600,w_600/v1/Product_Images/en/products/010-03014-01/v/cf-xl?pgw=1"'::jsonb
  ),
  '{blocks,9,cards,3,coverUrl}',
  '"https://res.garmin.com/transform/image/upload/b_rgb:FFFFFF,c_pad,dpr_1.0,f_auto,h_600,q_auto,w_600/c_pad,h_600,w_600/v1/Product_Images/en/products/010-02985-01/v/cf-xl?pgw=1"'::jsonb
)
where id = '7d5e81d0-21a1-426a-9938-7bb667723d3c';

-- ============================================================================
-- FIM DA MIGRAÇÃO 159
-- ============================================================================
