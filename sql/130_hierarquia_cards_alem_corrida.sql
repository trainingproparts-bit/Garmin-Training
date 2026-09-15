-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 130: Hierarquia label/valor nos cards de
-- "Além da corrida" (módulo Perfis de Cliente, lição 3)
-- ============================================================================
-- Pedido do usuário (2026-09-15, brief de UX/layout do módulo inteiro):
-- cards densos (Aventureiro/Trilheiro, Ciclista etc., com "Quem é / Sinais /
-- Pergunta inicial / Linhas relacionadas") precisavam de hierarquia
-- tipográfica — label em caps pequeno e cinza acima do valor, com
-- espaçamento vertical entre os campos, em vez de texto corrido com
-- "&lt;strong&gt;Label:&lt;/strong&gt;" inline (difícil de escanear).
--
-- A sql/129 (já rodada pelo usuário antes deste pedido) usava o formato
-- antigo — o arquivo sql/129 no repositório foi revertido pra bater com o
-- que realmente rodou (nunca reescrevo uma migração já aplicada). Esta
-- migração só atualiza os items do bloco card_grid da lição 3 pro novo
-- formato (.cb-field/.cb-field-label/.cb-field-value, ver
-- contentBlocks.css) — mesmo texto, só reestruturado. Localiza o bloco
-- certo pelo conteúdo (título "Aventureiro / Trilheiro" no 1º item), não
-- por índice fixo.
-- ============================================================================

do $$
declare
  v_lesson_id uuid := '4e259942-be34-46f3-b264-42c681a29e8c';
  v_idx int;
  v_new_items jsonb := '[{"title":"Aventureiro / Trilheiro","text":"<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Ama trilhas, camping e expedições, quer resistência e bateria longa.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Fala de trilha, serra, montanha, expedição.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"As trilhas que você faz têm sinal de celular?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Instinct 3, fēnix 8, Enduro 3.</span></span>","tags":[]},{"title":"Lifestyle e Saúde","text":"<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Quer design elegante com funções inteligentes e acompanhamento de saúde no dia a dia.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Pede um relógio menor ou mais bonito, compara com Apple Watch, quer acompanhar sono ou ciclo menstrual.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"É mais pra acompanhar sono, estresse e rotina do dia a dia?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Lily 2, Lily 2 Active, Venu 4.</span></span>","tags":[]},{"title":"Ciclista","text":"<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Pedala com frequência, seja estrada, mountain bike ou uso casual.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Menciona bike, MTB, estrada, gravel, cadência ou potência.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"Pedala mais na rua, na estrada ou também mountain bike?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Edge 850, Edge 550, Edge 1050, Varia RTL515, Rally RK 200.</span></span>","tags":[]},{"title":"Nadador / Triatleta","text":"<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Nada com frequência ou compete em triathlon.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Fala de piscina, mar, braçadas, SWOLF, triathlon ou duathlon.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"Já compete em provas de triathlon ou é só treino mesmo?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Forerunner 955, Forerunner 965, fēnix 8, HRM 600.</span></span>","tags":[]},{"title":"Mergulhador","text":"<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Precisa de um computador de mergulho.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Menciona profundidade, NDL, nitrox, mergulho técnico.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"Pergunta sobre computador de mergulho?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Descent G2, Descent Mk3i, Descent X30.</span></span>","tags":[]},{"title":"Golfista","text":"<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Quer distâncias e recursos de jogo direto no pulso.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Fala de green, par, bunker, handicap.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"Pergunta por GPS de golfe?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Approach S50, Approach S44.</span></span>","tags":[]},{"title":"Motociclista","text":"<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Viaja de moto e quer navegação específica.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Fala de viagem de moto, rota, estrada.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"Pergunta por GPS para moto?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Zūmo XT2.</span></span>","tags":[]},{"title":"Náutico / Pescador","text":"<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Precisa de sonar ou chartplotter para embarcação.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Menciona pesca em represa, rio ou mar, barco, canoa, lancha.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"Fala de barco, canoa, lancha?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Striker Vivid 5cv, Striker 4, ECHOMAP UHD2 52cv.</span></span>","tags":[]}]'::jsonb;
begin
  select ord - 1 into v_idx
  from jsonb_array_elements((select body -> 'blocks' from lessons where id = v_lesson_id)) with ordinality as t(elem, ord)
  where elem ->> 'type' = 'card_grid' and elem -> 'items' @> '[{"title":"Aventureiro / Trilheiro"}]'::jsonb;

  if v_idx is null then
    raise exception 'Bloco card_grid de "Além da corrida" não encontrado na lição %.', v_lesson_id;
  end if;

  update lessons
     set body = jsonb_set(body, array['blocks', v_idx::text, 'items'], v_new_items)
   where id = v_lesson_id;
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 130
-- ============================================================================
