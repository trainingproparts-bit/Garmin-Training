-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 132: Enxuga o verso do card Fēnix 9 (único
-- flip_card que ainda estourava a altura fixa)
-- ============================================================================
-- Pedido do usuário: "e os cards ainda estão com scrow desnecessário".
-- Testado ao vivo em mobile (390px), tablet (820px) e desktop (1280px):
-- dos 24 flip_card da lição, só 1 ainda estourava os 178px (sql/128) — o
-- verso do Fēnix 9 ("Quando oferecer"), com scrollHeight 253-270px conforme
-- a largura. Não dá pra aumentar o min-height só pra esse card: o layout é
-- 4 colunas (sql/121), e todo card na mesma linha compartilha a altura da
-- grade via CSS Grid — subir o valor geral pra caber esse único texto
-- deixaria os outros 3 cards da linha do Fēnix com espaço vazio enorme.
--
-- Em vez disso, enxuga o texto (mesmos fatos, sem cortar nenhum, só menos
-- verboso: "Cliente quer o relógio" → "Quer o", "e quer métricas
-- dedicadas" removido por redundante, "a versão Pro com LTE" → "LTE").
-- Testado ao vivo com o texto novo: cabe em 176px, sem scroll, na largura
-- mais estreita da grade (4 colunas, container 820px).
-- ============================================================================

do $$
declare
  v_lesson_id uuid := '7d5e81d0-21a1-426a-9938-7bb667723d3c';
  v_block_idx int;
  v_card_idx int;
begin
  select ord - 1 into v_block_idx
  from jsonb_array_elements((select body -> 'blocks' from lessons where id = v_lesson_id)) with ordinality as t(elem, ord)
  where elem ->> 'type' = 'flip_card' and elem -> 'cards' @> '[{"title":"Fēnix 9"}]'::jsonb;

  if v_block_idx is null then
    raise exception 'Bloco flip_card com o card "Fēnix 9" não encontrado na lição %.', v_lesson_id;
  end if;

  select ord - 1 into v_card_idx
  from jsonb_array_elements((select body -> 'blocks' -> v_block_idx -> 'cards' from lessons where id = v_lesson_id)) with ordinality as t(elem, ord)
  where elem ->> 'title' = 'Fēnix 9';

  if v_card_idx is null then
    raise exception 'Card "Fēnix 9" não encontrado dentro do bloco flip_card.';
  end if;

  update lessons
     set body = jsonb_set(
       body,
       array['blocks', v_block_idx::text, 'cards', v_card_idx::text, 'backText'],
       to_jsonb('Quer o multiesporte mais completo, com comandos por voz e ferramentas de expedição, ou pratica remo indoor/arco e flecha. Não indique se ele só corre (Forerunner é mais em conta) ou espera ligar sem o celular por perto (LTE ainda não é vendido no Brasil).'::text)
     )
   where id = v_lesson_id;
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 132
-- ============================================================================
