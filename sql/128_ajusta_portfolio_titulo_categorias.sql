-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 128: Ajustes na lição do Portfólio de
-- Produtos reportados ao vivo pelo usuário depois de aplicar sql/120-122
-- ============================================================================
-- 4 problemas resolvidos nesta migração, todos na mesma lição (id
-- 7d5e81d0-21a1-426a-9938-7bb667723d3c):
--
-- 1) "aparece o titulo do marq em cima" — título no banco continuava
--    "Linha MARQ (Gen 2): relógios de luxo Garmin", herdado de quando a
--    lição cobria só essa linha. Já tinha sido combinado com o usuário
--    numa rodada anterior desta sessão trocar para "Portfólio de Produtos
--    Garmin" (confirmado por ele via pergunta direta), mas nunca chegou a
--    ser aplicado — ficou pendente. Corrige via UPDATE direto (a função de
--    editar título pelo admin ainda não existe na UI).
--
-- 2) "os cards geraram barra de rolagem sem necessidade nenhuma" —
--    corrigido em CÓDIGO (src/styles/contentBlocks.css), não em dado: o
--    min-height dos flip_card (132px, reduzido na sql/121 pra caber em 4
--    colunas) ficou pequeno demais pro conteúdo real — 20 dos 24 cards da
--    lição estouravam a altura e ativavam o scroll interno. Confirmado ao
--    vivo via DOM (scrollHeight vs clientHeight). Novo valor: 178px.
--
-- 3) "ainda estão os acordeões ciclocomputador, radares, medidores de
--    potencia, etc. eu nao quero pois vou colocar imagem no lugar" —
--    remove o bloco card_grid de 9 categorias (Edge/Varia/Rally/HRM/
--    Descent/Approach/GPSMAP/Blaze/Index S2, sql/120+122) por completo.
--    Usuário vai inserir uma imagem própria no lugar depois, pelo editor.
--    Filtra pelo conteúdo do bloco (não por índice fixo), pra não depender
--    da posição exata dele no array, que já mudou entre migrações.
--
-- 4) "no marq tambem é legal deixar igual o blaze no oq entrega etc" —
--    troca o bloco 'tabs' do MARQ (Commander/Athlete/Golfer Carbon, sql/121)
--    por 3 grupos de 'timeline reveal:true' (um por modelo, 4 perguntas
--    cada: Para quem é?/O que entrega?/O que diferencia?/Como apresentar?),
--    mesmo padrão de revelação por etapas já usado no Blaze (sql/120).
--    Texto idêntico ao já usado no bloco tabs anterior (nenhum dado novo),
--    só reorganizado peça por peça em vez de 2 parágrafos por aba. Como
--    isso troca 1 bloco por 6, usa um array Postgres (jsonb[] via
--    array_agg) pra fatiar blocks[1:idx-1] + novos blocos + blocks[idx+1:]
--    em vez de jsonb_set (que só troca 1-por-1 no mesmo índice).
-- ============================================================================

do $$
declare
  v_lesson_id uuid := '7d5e81d0-21a1-426a-9938-7bb667723d3c';
  v_blocks jsonb[];
  v_idx int;
  v_new_blocks jsonb := '[{"type":"texto_rico","html":"<h4 class=\"cb-model-heading\">MARQ Commander (Gen 2)</h4>"},{"type":"timeline","reveal":true,"items":[{"label":"Para quem é?","text":"Cliente que combina alto desempenho com presença no pulso — quer tecnologia de ponta, mas também estética."},{"label":"O que entrega?","text":"Caixa em titânio e pulseira em couro italiano, estética militar sofisticada, GPS multibanda, mapas completos e modo tático."},{"label":"O que diferencia?","text":"É o único da linha com essa estética tática/militar — combina robustez com acabamento de luxo."},{"label":"Como apresentar?","text":"Pense em quem já usa ou usaria um Fēnix, mas quer um passo além em material e exclusividade."}]},{"type":"texto_rico","html":"<h4 class=\"cb-model-heading\">MARQ Athlete (Gen 2)</h4>"},{"type":"timeline","reveal":true,"items":[{"label":"Para quem é?","text":"Atleta de corrida e triathlon de alto nível que não abre mão de estilo."},{"label":"O que entrega?","text":"Titânio com pulseira sport premium, GPS multibanda, métricas avançadas de treino e Prontidão de Treino."},{"label":"O que diferencia?","text":"É a MARQ voltada especificamente para performance esportiva, não outdoor nem golfe."},{"label":"Como apresentar?","text":"Pense nele como a opção do cliente que já pensaria num Forerunner topo de linha, mas quer também exclusividade de material."}]},{"type":"texto_rico","html":"<h4 class=\"cb-model-heading\">MARQ Golfer Carbon (Gen 2)</h4>"},{"type":"timeline","reveal":true,"items":[{"label":"Para quem é?","text":"Golfista que valoriza tanto o jogo quanto o status do equipamento."},{"label":"O que entrega?","text":"Caixa em fibra de carbono com acabamento premium, mapas de mais de 42.000 campos de golfe, modo caddie digital, estatísticas de jogo e distâncias automáticas."},{"label":"O que diferencia?","text":"É o único relógio de golfe no patamar de luxo real — não existe equivalente Approach com esse posicionamento."},{"label":"Como apresentar?","text":"Não é só \"um Approach mais caro\" — é a opção de quem já joga com equipamento premium e quer o relógio à altura."}]}]'::jsonb;
  v_new_count int;
  v_result jsonb;
begin
  -- 1) título + 3) remove card_grid de categorias
  update lessons
     set title = 'Portfólio de Produtos Garmin',
         body = jsonb_set(
           body,
           '{blocks}',
           (
             select jsonb_agg(elem)
             from jsonb_array_elements(body -> 'blocks') as elem
             where not (
               elem ->> 'type' = 'card_grid'
               and elem -> 'items' @> '[{"title":"Ciclocomputadores — Edge"}]'::jsonb
             )
           )
         )
   where id = v_lesson_id;

  if not found then
    raise exception 'Lição de Portfólio de Produtos (id %) não encontrada.', v_lesson_id;
  end if;

  -- 4) troca o bloco 'tabs' do MARQ por 3x (texto_rico + timeline reveal)
  select array_agg(elem order by ord) into v_blocks
  from jsonb_array_elements((select body -> 'blocks' from lessons where id = v_lesson_id)) with ordinality as t(elem, ord);

  select ord into v_idx
  from jsonb_array_elements((select body -> 'blocks' from lessons where id = v_lesson_id)) with ordinality as t(elem, ord)
  where elem ->> 'type' = 'tabs' and elem -> 'items' @> '[{"label":"Commander"}]'::jsonb;

  if v_idx is null then
    raise exception 'Bloco tabs do MARQ não encontrado na lição %.', v_lesson_id;
  end if;

  select count(*) into v_new_count from jsonb_array_elements(v_new_blocks);

  select jsonb_agg(elem order by seq) into v_result
  from (
    select ord as seq, elem from unnest(v_blocks[1:v_idx-1]) with ordinality as u(elem, ord)
    union all
    select v_idx - 1 + ord as seq, elem from jsonb_array_elements(v_new_blocks) with ordinality as u(elem, ord)
    union all
    select v_idx - 1 + v_new_count + ord as seq, elem from unnest(v_blocks[v_idx+1:array_length(v_blocks, 1)]) with ordinality as u(elem, ord)
  ) t;

  update lessons set body = jsonb_set(body, '{blocks}', v_result) where id = v_lesson_id;
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 128
-- ============================================================================
