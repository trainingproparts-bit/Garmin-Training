-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 131: Volta o MARQ pro layout de abas
-- (igual o Edge), desfaz a revelação por etapas da sql/128
-- ============================================================================
-- Pedido do usuário (2026-09-15): "o marq com o texto que vai abrindo aos
-- poucos ficou ruim, melhor voltar pro layout original, que é igual ao do
-- edge e no centro". A sql/128 tinha trocado as abas do MARQ (Commander/
-- Athlete/Golfer Carbon) por 3 grupos de timeline reveal:true, a pedido do
-- próprio usuário numa mensagem anterior ("deixa igual o blaze") — testado
-- ao vivo, não agradou, e ele pediu pra reverter pro padrão de abas
-- (mesmo componente 'tabs' já usado no Edge/HRM, com os botões e o título
-- centralizados — CSS de centralização já existe, .cb-tabs.itabs e
-- .cb-model-heading, sql/128).
--
-- Restaura o texto exato do bloco 'tabs' original (sql/121, antes da
-- sql/128 trocar por timeline) — nenhum dado novo, é literalmente o mesmo
-- conteúdo de antes. Troca os 6 blocos (3x texto_rico h4 + 3x
-- timeline) por 1 bloco 'tabs', usando o mesmo array Postgres (jsonb[] via
-- array_agg + unnest) já usado na sql/128 pra trocar N blocos por M.
-- ============================================================================

do $$
declare
  v_lesson_id uuid := '7d5e81d0-21a1-426a-9938-7bb667723d3c';
  v_blocks jsonb[];
  v_start_idx int;
  v_new_block jsonb := '{"type":"tabs","items":[{"label":"Commander","title":"MARQ Commander (Gen 2)","text":"<strong>Para quem é:</strong> cliente que combina alto desempenho com presença no pulso — quer tecnologia de ponta, mas também estética. <strong>O que entrega:</strong> caixa em titânio e pulseira em couro italiano, estética militar sofisticada, GPS multibanda, mapas completos e modo tático.","note":"<strong>Diferencial:</strong> é o único da linha com essa estética tática/militar — combina robustez com acabamento de luxo. <strong>Como apresentar:</strong> pense em quem já usa ou usaria um Fēnix, mas quer um passo além em material e exclusividade."},{"label":"Athlete","title":"MARQ Athlete (Gen 2)","text":"<strong>Para quem é:</strong> atleta de corrida e triathlon de alto nível que não abre mão de estilo. <strong>O que entrega:</strong> titânio com pulseira sport premium, GPS multibanda, métricas avançadas de treino e Training Readiness.","note":"<strong>Diferencial:</strong> é a MARQ voltada especificamente para performance esportiva, não outdoor nem golfe. <strong>Como apresentar:</strong> pense nele como a opção do cliente que já pensaria num Forerunner topo de linha, mas quer também exclusividade de material."},{"label":"Golfer Carbon","title":"MARQ Golfer Carbon (Gen 2)","text":"<strong>Para quem é:</strong> golfista que valoriza tanto o jogo quanto o status do equipamento. <strong>O que entrega:</strong> caixa em fibra de carbono com acabamento premium, mapas de mais de 42.000 campos de golfe, modo caddie digital, estatísticas de jogo e distâncias automáticas.","note":"<strong>Diferencial:</strong> é o único relógio de golfe no patamar de luxo real — não existe equivalente Approach com esse posicionamento. <strong>Como apresentar:</strong> não é só \"um Approach mais caro\" — é a opção de quem já joga com equipamento premium e quer o relógio à altura."}]}'::jsonb;
  v_result jsonb;
begin
  select array_agg(elem order by ord) into v_blocks
  from jsonb_array_elements((select body -> 'blocks' from lessons where id = v_lesson_id)) with ordinality as t(elem, ord);

  select ord into v_start_idx
  from jsonb_array_elements((select body -> 'blocks' from lessons where id = v_lesson_id)) with ordinality as t(elem, ord)
  where elem ->> 'type' = 'texto_rico' and elem ->> 'html' = '<h4 class="cb-model-heading">MARQ Commander (Gen 2)</h4>';

  if v_start_idx is null then
    raise exception 'Bloco "MARQ Commander (Gen 2)" (sql/128) não encontrado na lição %.', v_lesson_id;
  end if;

  -- sql/128 inseriu exatamente 6 blocos nesta posição (3x texto_rico + 3x timeline).
  select jsonb_agg(elem order by seq) into v_result
  from (
    select ord as seq, elem from unnest(v_blocks[1:v_start_idx-1]) with ordinality as u(elem, ord)
    union all
    select v_start_idx as seq, v_new_block as elem
    union all
    select v_start_idx + ord as seq, elem from unnest(v_blocks[v_start_idx+6:array_length(v_blocks, 1)]) with ordinality as u(elem, ord)
  ) t;

  update lessons set body = jsonb_set(body, '{blocks}', v_result) where id = v_lesson_id;
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 131
-- ============================================================================
