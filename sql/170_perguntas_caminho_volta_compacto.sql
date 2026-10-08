-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 170: "As perguntas que ajudam a encontrar o
-- caminho" volta a ser flip card compacto (Perfis de Cliente, Zona Explorador)
-- ============================================================================
-- Pedido do usuário (2026-10-07, print da lição ao vivo): os 5 cards de
-- pergunta viraram quadrados enormes (~520px em 2 colunas) com a pergunta
-- pequena no canto e o resto vazio. A sql/138 tinha deixado o bloco
-- `compact` justamente por ser 1 pergunta curta por card; depois, pelo
-- editor, os cards ganharam foto de fundo (coverUrl, os pontos de
-- interrogação) e a flag `square`, que tem prioridade sobre `compact` em
-- renderFlipCardBlock.
--
-- Aqui: square = false, compact = true. A foto de fundo é mantida (fica
-- atrás do texto, com o overlay escuro) e a pergunta volta a ficar
-- centralizada num card baixo. Só este bloco muda.
--
-- O bloco é localizado pelo conteúdo ("Qual atividade você pratica"), não
-- pela posição, porque a posição pode ter mudado com edições pelo editor.
-- ============================================================================

do $$
declare
  v_lesson_id uuid := '4e259942-be34-46f3-b264-42c681a29e8c';
  v_idx int;
begin
  select (e.ord - 1)::int
    into v_idx
    from lessons l,
         jsonb_array_elements(l.body->'blocks') with ordinality as e(elem, ord)
   where l.id = v_lesson_id
     and e.elem->>'type' = 'flip_card'
     and e.elem::text ilike '%Qual atividade voc%pratica%'
   limit 1;

  if v_idx is null then
    raise exception 'Bloco de flip cards das perguntas não encontrado na lição %.', v_lesson_id;
  end if;

  update lessons
     set body = jsonb_set(
                  body,
                  array['blocks', v_idx::text],
                  (body->'blocks'->v_idx) || '{"square": false, "compact": true}'::jsonb
                )
   where id = v_lesson_id;
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 170
-- ============================================================================
