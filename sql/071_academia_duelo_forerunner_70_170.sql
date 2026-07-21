-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 071: Duelo de Especificações — 70 vs 55 e
-- 170 vs 165
-- ============================================================================
-- Pedido do usuário (2026-07-21): "pode adicionar" — os games de comparativo
-- (motor de Duelo já existente, mesmo padrão do 570-vs-970 em sql/065) pros
-- dois pares novos, que tinham ficado de fora da rodada anterior (sql/070).
--
-- Reaproveita o motor de Duelo já existente (games/game_sessions/
-- fn_submit_game_round/fn_finalize_game_session, sql/021/040) sem nenhuma
-- mudança de schema. Fatos de cada rodada vêm diretamente dos
-- comparison_items já aplicados em sql/070 — nenhum dado novo.
--
-- src/components/GameRunner.js precisa de um nome de exibição por chave
-- (DISPLAY_NAMES) — adicionadas fr70/fr170/fr55/fr165 nesse mapa junto com
-- esta migração (commit da mesma leva).
-- ============================================================================

do $$
declare
  v_brand_id     uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_game70x55    uuid;
  v_game170x165  uuid;
begin
  -- ==========================================================================
  -- 1. Duelo Forerunner 70 vs Forerunner 55
  -- ==========================================================================
  insert into games (brand_id, slug, title, config, is_published) values (
    v_brand_id,
    'duelo-forerunner-70-vs-55',
    'Duelo de Especificações: Forerunner 70 vs Forerunner 55',
    $j$
    {
      "meta": {
        "modo": "duelo_1v1",
        "titulo": "Forerunner 70 vs Forerunner 55",
        "opcoes_resposta": ["fr70", "fr55", "ambos", "nenhum"],
        "rodadas_por_partida": 9,
        "total_perguntas_no_pool": 9
      },
      "rounds": [
        {"cat": {"nome": "Preço Sugerido", "descr": "Valor de lançamento em garmin.com", "icone": "💵"}, "texto": "Qual modelo tem o preço sugerido mais baixo?", "gabarito": "fr55", "acerto": "✅ Correto! O Forerunner 55 custa US$ 199,99, contra US$ 249,99 do Forerunner 70 — US$ 50 mais barato.", "erro": "❌ É o Forerunner 55, a US$ 199,99. O 70 custa US$ 249,99.", "reveal": {"fr70": "US$ 249,99", "fr55": "<strong>US$ 199,99</strong>"}},
        {"cat": {"nome": "Tela", "descr": "Tecnologia e interação", "icone": "⌚"}, "texto": "Qual modelo tem tela AMOLED touchscreen?", "gabarito": "fr70", "acerto": "✅ Isso mesmo! O Forerunner 70 tem tela AMOLED de 1,2\" com touchscreen. O 55 usa tela MIP sem touch.", "erro": "❌ É o Forerunner 70. O 55 tem tela MIP (Memory-in-Pixel), sem touchscreen.", "reveal": {"fr70": "<strong>AMOLED touchscreen</strong> 1,2\"", "fr55": "MIP transflativa 1,04\" (sem touch)"}},
        {"cat": {"nome": "Bateria — Modo Smartwatch", "descr": "Autonomia no uso diário", "icone": "🔋"}, "texto": "Qual modelo dura mais em modo smartwatch (uso diário)?", "gabarito": "fr55", "acerto": "✅ Correto! O 55 aguenta até 14 dias, contra até 13 dias do 70 — a tela mais simples consome menos energia.", "erro": "❌ É o Forerunner 55, com até 14 dias. O 70 aguenta até 13 dias.", "reveal": {"fr70": "Até 13 dias", "fr55": "Até <strong>14 dias</strong>"}},
        {"cat": {"nome": "Training Readiness + Training Status", "descr": "Métricas avançadas de treino", "icone": "📊"}, "texto": "Qual modelo tem Training Readiness e Training Status?", "gabarito": "fr70", "acerto": "✅ Exato! Esses recursos são exclusivos do Forerunner 70 nesta dupla — não existiam quando o 55 foi lançado.", "erro": "❌ É o Forerunner 70. O 55 não tem Training Readiness nem Training Status.", "reveal": {"fr70": "<strong>Training Readiness + Training Status</strong> ✓", "fr55": "Sem esses recursos ✗"}},
        {"cat": {"nome": "Potência de Corrida no Pulso", "descr": "Métrica sem cinta cardíaca", "icone": "⚡"}, "texto": "Qual modelo estima potência de corrida direto no sensor de pulso?", "gabarito": "fr70", "acerto": "✅ Correto! O Forerunner 70 traz potência e dinâmica de corrida no pulso, sem precisar de cinta cardíaca.", "erro": "❌ É o Forerunner 70. O 55 não tem essa métrica.", "reveal": {"fr70": "<strong>Potência de corrida no pulso</strong> ✓", "fr55": "Sem essa métrica ✗"}},
        {"cat": {"nome": "Sensor Cardíaco", "descr": "Painéis de luz do sensor óptico", "icone": "❤️"}, "texto": "Qual modelo tem sensor cardíaco com mais painéis de luz?", "gabarito": "fr70", "acerto": "✅ Isso aí! O 70 tem 4 painéis de luz, contra 2 painéis do 55.", "erro": "❌ É o Forerunner 70, com 4 painéis. O 55 tem 2 painéis.", "reveal": {"fr70": "<strong>4 painéis</strong> de luz", "fr55": "2 painéis de luz"}},
        {"cat": {"nome": "Garmin Coach", "descr": "Planos de treino guiados", "icone": "🏃"}, "texto": "Qual modelo tem Garmin Coach completo (incluindo run/walk)?", "gabarito": "fr70", "acerto": "✅ Correto! O 70 tem Garmin Coach completo. O 55 só tem treinos sugeridos básicos.", "erro": "❌ É o Forerunner 70. O 55 fica só no treino sugerido diário, sem o Garmin Coach completo.", "reveal": {"fr70": "<strong>Garmin Coach</strong> completo ✓", "fr55": "Treino sugerido básico"}},
        {"cat": {"nome": "Resistência à Água", "descr": "Classificação para natação", "icone": "💧"}, "texto": "Os dois modelos têm a mesma classificação de resistência à água (5 ATM)?", "gabarito": "ambos", "acerto": "✅ Exato! Os dois têm 5 ATM — essa especificação não mudou entre as gerações.", "erro": "❌ Os dois têm 5 ATM — é uma especificação COMPARTILHADA, não exclusiva de um dos dois.", "reveal": {"fr70": "5 ATM ✓", "fr55": "5 ATM ✓"}},
        {"cat": {"nome": "Bateria — Só GPS", "descr": "Autonomia treinando com GPS ligado", "icone": "🛰️"}, "texto": "Qual modelo dura mais treinando só com GPS ligado?", "gabarito": "fr70", "acerto": "✅ Correto! O 70 aguenta até 23h só de GPS, contra até 20h do 55.", "erro": "❌ É o Forerunner 70, com até 23h. O 55 aguenta até 20h.", "reveal": {"fr70": "Até <strong>23h</strong>", "fr55": "Até 20h"}}
      ]
    }
    $j$,
    true
  ) returning id into v_game70x55;

  update product_comparisons
     set comparison_game_id = v_game70x55
   where brand_id = v_brand_id and slug = 'forerunner-70-vs-forerunner-55';

  -- ==========================================================================
  -- 2. Duelo Forerunner 170 vs Forerunner 165
  -- ==========================================================================
  insert into games (brand_id, slug, title, config, is_published) values (
    v_brand_id,
    'duelo-forerunner-170-vs-165',
    'Duelo de Especificações: Forerunner 170 vs Forerunner 165',
    $j$
    {
      "meta": {
        "modo": "duelo_1v1",
        "titulo": "Forerunner 170 vs Forerunner 165",
        "opcoes_resposta": ["fr170", "fr165", "ambos", "nenhum"],
        "rodadas_por_partida": 9,
        "total_perguntas_no_pool": 9
      },
      "rounds": [
        {"cat": {"nome": "Preço Sugerido", "descr": "Valor de lançamento em garmin.com", "icone": "💵"}, "texto": "Qual modelo tem o preço sugerido mais baixo?", "gabarito": "fr165", "acerto": "✅ Correto! O Forerunner 165 custa US$ 249,99, contra US$ 299,99 do Forerunner 170 — US$ 50 mais barato.", "erro": "❌ É o Forerunner 165, a US$ 249,99. O 170 custa US$ 299,99.", "reveal": {"fr170": "US$ 299,99", "fr165": "<strong>US$ 249,99</strong>"}},
        {"cat": {"nome": "Tela", "descr": "Tecnologia e tamanho", "icone": "⌚"}, "texto": "Os dois modelos têm a mesma tela AMOLED touchscreen de 1,2\"?", "gabarito": "ambos", "acerto": "✅ Exato! O 170 herda exatamente a mesma tela do 165 — a diferença entre eles está no software, não na tela.", "erro": "❌ Os dois têm a MESMA tela AMOLED touchscreen de 1,2\" — o 170 herda essa peça do 165.", "reveal": {"fr170": "AMOLED touchscreen 1,2\" ✓", "fr165": "AMOLED touchscreen 1,2\" ✓"}},
        {"cat": {"nome": "Bateria — Modo Smartwatch", "descr": "Autonomia no uso diário", "icone": "🔋"}, "texto": "Qual modelo dura mais em modo smartwatch (uso diário)?", "gabarito": "fr165", "acerto": "✅ Correto! O 165 aguenta até 11 dias, contra até 10 dias do 170 — o software mais avançado do 170 consome um pouco mais.", "erro": "❌ É o Forerunner 165, com até 11 dias. O 170 aguenta até 10 dias.", "reveal": {"fr170": "Até 10 dias", "fr165": "Até <strong>11 dias</strong>"}},
        {"cat": {"nome": "Training Readiness + Training Status", "descr": "Métricas avançadas de treino", "icone": "📊"}, "texto": "Qual modelo tem Training Readiness e Training Status?", "gabarito": "fr170", "acerto": "✅ Isso aí! Esses recursos chegam com o software mais moderno do 170 — o 165 não tem.", "erro": "❌ É o Forerunner 170. O 165 não tem Training Readiness nem Training Status.", "reveal": {"fr170": "<strong>Training Readiness + Training Status</strong> ✓", "fr165": "Sem esses recursos ✗"}},
        {"cat": {"nome": "Potência de Corrida no Pulso", "descr": "Métrica completa de potência", "icone": "⚡"}, "texto": "Qual modelo tem Potência de Corrida completa no pulso (não só dinâmica básica)?", "gabarito": "fr170", "acerto": "✅ Correto! O 170 tem Potência de Corrida completa. O 165 só tem dinâmica básica (cadência, passada, tempo de contato com o solo).", "erro": "❌ É o Forerunner 170. O 165 fica só na dinâmica básica de corrida, sem a potência completa.", "reveal": {"fr170": "<strong>Potência completa</strong> ✓", "fr165": "Só dinâmica básica"}},
        {"cat": {"nome": "Garmin Pay", "descr": "Pagamento por aproximação", "icone": "💳"}, "texto": "Os dois modelos têm Garmin Pay?", "gabarito": "ambos", "acerto": "✅ Exato! Garmin Pay já vinha no 165 e continua no 170 — não é uma novidade desta geração.", "erro": "❌ Os dois têm Garmin Pay — não é um recurso novo do 170, já existia no 165.", "reveal": {"fr170": "Garmin Pay ✓", "fr165": "Garmin Pay ✓"}},
        {"cat": {"nome": "Sensores Extras", "descr": "Altímetro, bússola, giroscópio, termômetro", "icone": "🧭"}, "texto": "Qual modelo tem altímetro barométrico, bússola, giroscópio e termômetro?", "gabarito": "fr170", "acerto": "✅ Correto! Esse conjunto de sensores é exclusivo do Forerunner 170 nesta dupla.", "erro": "❌ É o Forerunner 170. O 165 não tem nenhum desses sensores.", "reveal": {"fr170": "<strong>Barômetro + bússola + giroscópio + termômetro</strong> ✓", "fr165": "Nenhum desses sensores ✗"}},
        {"cat": {"nome": "Ciclismo", "descr": "Suporte a medidor de potência", "icone": "🚴"}, "texto": "Qual modelo suporta medidor de potência de ciclismo (com Garmin Cycling Coach)?", "gabarito": "fr170", "acerto": "✅ Isso aí! Só o 170 conecta com medidor de potência ou rolo inteligente de ciclismo.", "erro": "❌ É o Forerunner 170. O 165 não tem suporte a medidor de potência de ciclismo.", "reveal": {"fr170": "<strong>Suporte a medidor de potência</strong> ✓", "fr165": "Sem suporte ✗"}},
        {"cat": {"nome": "Natação em Águas Abertas", "descr": "Modo de atividade dedicado", "icone": "🏊"}, "texto": "Qual modelo tem modo dedicado de natação em águas abertas?", "gabarito": "fr170", "acerto": "✅ Correto! O 170 tem modo dedicado pra águas abertas. O 165 fica só na piscina.", "erro": "❌ É o Forerunner 170. O 165 só tem natação em piscina, sem o modo de águas abertas.", "reveal": {"fr170": "<strong>Águas abertas</strong> + piscina ✓", "fr165": "Só piscina"}}
      ]
    }
    $j$,
    true
  ) returning id into v_game170x165;

  update product_comparisons
     set comparison_game_id = v_game170x165
   where brand_id = v_brand_id and slug = 'forerunner-170-vs-forerunner-165';
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 071
-- ============================================================================
