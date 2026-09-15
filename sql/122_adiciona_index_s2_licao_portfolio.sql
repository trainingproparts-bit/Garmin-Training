-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 122: Adiciona o Index S2 (balança de
-- bioimpedância) na grade de "outras categorias" da lição de Portfólio
-- ============================================================================
-- Pedido do usuário (2026-09-15): incluir o Index S2 na lição de Portfólio
-- de Produtos, junto das outras categorias que não são relógios (bloco
-- card_grid "Garmin é muito mais do que relógios" — Edge/Varia/Rally/HRM/
-- Descent/Approach/GPSMAP/Blaze, ver sql/120). Nenhum dado deste produto
-- estava cadastrado em lugar nenhum do projeto (nem Academia de Produtos,
-- nem content_library) — pedido explícito do usuário pra pesquisar as specs
-- reais no site oficial da Garmin em vez de inventar. Fatos usados, todos
-- confirmados no manual oficial (garmin.com/support, manual do Index S2):
-- mede peso, IMC, % de gordura corporal, % de água corporal, massa muscular
-- esquelética e massa óssea por bioimpedância; carga máxima 181,4 kg;
-- sincroniza direto com o Garmin Connect por Wi-Fi, sem precisar do celular
-- por perto; reconhece automaticamente até 16 perfis de usuário na mesma
-- balança.
--
-- Só acrescenta um 9º item ao array `items` do bloco card_grid (índice 11
-- — estrutura fixa da sql/120/121, lição só editada por migração) via
-- concatenação jsonb (`||`), sem tocar nos 8 itens existentes.
-- ============================================================================

do $$
declare
  v_lesson_id uuid := '7d5e81d0-21a1-426a-9938-7bb667723d3c';
  v_new_item jsonb := '{
    "title": "Composição corporal — Index S2",
    "text": "Balança que mede peso, IMC, % de gordura corporal, % de água corporal, massa muscular e óssea por bioimpedância — sincroniza direto com o Garmin Connect por Wi-Fi e reconhece automaticamente até 16 perfis de usuário.",
    "tags": []
  }'::jsonb;
begin
  update lessons
     set body = jsonb_set(
       body,
       '{blocks,11,items}',
       (body -> 'blocks' -> 11 -> 'items') || jsonb_build_array(v_new_item)
     )
   where id = v_lesson_id;

  if not found then
    raise exception 'Lição de Portfólio de Produtos (id %) não encontrada.', v_lesson_id;
  end if;
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 122
-- ============================================================================
