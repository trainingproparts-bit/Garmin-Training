-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 121: Reduz cards giratórios (flip_card) da
-- lição de Portfólio e troca o acordeão MARQ por abas
-- ============================================================================
-- Pedido do usuário (2026-09-15): depois de aplicar a sql/120, o usuário viu
-- a lição renderizada e apontou dois problemas de design:
-- 1) Os flip_card de Forerunner, Fēnix e Lifestyle (4 cards cada) usavam só
--    2 ou 3 colunas, empilhando os cards em várias linhas e deixando a
--    seção "quadrada"/pesada — mesma reclamação de design já feita antes
--    ("muito quadrado", ver sql/120). Corrigido no código (ContentBlocks.js
--    + contentBlocks.css: suporte a columns:4, cards mais compactos) — esta
--    migração só ajusta o dado (columns) dos 3 blocos flip_card existentes.
-- 2) O acordeão com os 3 modelos MARQ (Commander/Athlete/Golfer Carbon)
--    continuava no ar mesmo depois do usuário já ter pedido, em rodadas
--    anteriores, menos repetição do padrão accordion/quadrado. Substituído
--    por um bloco 'tabs' (mesmo padrão já usado pra Edge 550/850/1050 e HRM
--    200/600 nesta mesma lição) — texto igual ao do acordeão original
--    (nenhum dado novo/inventado), só reorganizado em 2 parágrafos por aba
--    (quem é + o que entrega / diferencial + como apresentar).
--
-- Os índices dos blocos (3, 5, 7, 9) vêm da estrutura fixa da sql/120 — essa
-- lição só é editada por migração, nunca pelo editor admin, então a ordem
-- dos blocos é estável e conhecida.
-- ============================================================================

do $$
declare
  v_lesson_id uuid := '7d5e81d0-21a1-426a-9938-7bb667723d3c';
begin
  update lessons
     set body = jsonb_set(
       jsonb_set(
         jsonb_set(
           jsonb_set(
             body,
             '{blocks,3,columns}', '4'::jsonb
           ),
           '{blocks,5,columns}', '4'::jsonb
         ),
         '{blocks,9,columns}', '4'::jsonb
       ),
       '{blocks,7}', '{"type":"tabs","items":[{"label":"Commander","title":"MARQ Commander (Gen 2)","text":"<strong>Para quem é:</strong> cliente que combina alto desempenho com presença no pulso — quer tecnologia de ponta, mas também estética. <strong>O que entrega:</strong> caixa em titânio e pulseira em couro italiano, estética militar sofisticada, GPS multibanda, mapas completos e modo tático.","note":"<strong>Diferencial:</strong> é o único da linha com essa estética tática/militar — combina robustez com acabamento de luxo. <strong>Como apresentar:</strong> pense em quem já usa ou usaria um Fēnix, mas quer um passo além em material e exclusividade."},{"label":"Athlete","title":"MARQ Athlete (Gen 2)","text":"<strong>Para quem é:</strong> atleta de corrida e triathlon de alto nível que não abre mão de estilo. <strong>O que entrega:</strong> titânio com pulseira sport premium, GPS multibanda, métricas avançadas de treino e Training Readiness.","note":"<strong>Diferencial:</strong> é a MARQ voltada especificamente para performance esportiva, não outdoor nem golfe. <strong>Como apresentar:</strong> pense nele como a opção do cliente que já pensaria num Forerunner topo de linha, mas quer também exclusividade de material."},{"label":"Golfer Carbon","title":"MARQ Golfer Carbon (Gen 2)","text":"<strong>Para quem é:</strong> golfista que valoriza tanto o jogo quanto o status do equipamento. <strong>O que entrega:</strong> caixa em fibra de carbono com acabamento premium, mapas de mais de 42.000 campos de golfe, modo caddie digital, estatísticas de jogo e distâncias automáticas.","note":"<strong>Diferencial:</strong> é o único relógio de golfe no patamar de luxo real — não existe equivalente Approach com esse posicionamento. <strong>Como apresentar:</strong> não é só “um Approach mais caro” — é a opção de quem já joga com equipamento premium e quer o relógio à altura."}]}'::jsonb
     )
   where id = v_lesson_id;

  if not found then
    raise exception 'Lição de Portfólio de Produtos (id %) não encontrada.', v_lesson_id;
  end if;
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 121
-- ============================================================================
