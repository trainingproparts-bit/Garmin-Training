-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 080: Academia de Produtos — Edge 540, 840,
-- 1040, 550, 850 e 1050 (linha Ciclismo)
-- ============================================================================
-- Pedido do usuário (2026-07-21): "faz tambem do edge 540/550 840/850
-- 1040/1050 e comparativo com o 1030 530 e 830" — 6 produtos completos.
-- Reaproveita a categoria "Ciclismo" criada em sql/079.
--
-- Estrutura da linha Edge (confirmada via pesquisa oficial, importante pra
-- não confundir gerações — são DUAS trocas de geração empilhadas):
--   - Edge 530/830/1030 (2019/2018): geração anterior, GPS multi-constelação
--     (GPS+GLONASS+Galileo) mas SEM multibanda. 530 = só botão. 830 = com
--     touchscreen. 1030 (depois 1030 Plus) = tela maior, também touchscreen.
--   - Edge 540/840 (11/abr/2023) e Edge 1040 (jun/2022): geração seguinte.
--     Introduziram GNSS multibanda pela primeira vez na linha Edge — o
--     1040 foi o pioneiro (jun/2022), o 540/840 vieram um ano depois
--     (abr/2023) já com a tecnologia. 540 = só botão, 840 = touchscreen
--     (mesma divisão do 530/830 anterior).
--   - Edge 550/850 (9/set/2025) e Edge 1050 (25/jun/2024): geração mais
--     nova (refresh), sucessora direta do 540/840/1040 respectivamente.
--
-- ATENÇÃO — nuance importante pra não confundir "multi-constelação" com
-- "multibanda" (evitando o erro do Venu 4 que o usuário já corrigiu antes):
--   - Multi-constelação = usar mais de um sistema de satélite (GPS +
--     GLONASS + Galileo) — isso o Edge 530/830/1030 (2019) JÁ TINHA.
--   - Multibanda = captar mais de uma FREQUÊNCIA de sinal (L1 + L5) do
--     mesmo satélite, o que aumenta muito a precisão em ambiente urbano
--     ou mata fechada — isso é NOVO a partir do Edge 1040 (2022) e
--     540/840 (2023). O Edge 530/830/1030 NÃO tem multibanda.
--
-- Achado que vale registrar com transparência (mesmo padrão do Descent
-- Mk3i/G2/Instinct): a bateria do Edge 550/850 e do Edge 1050 é MENOR em
-- horas de uso intenso que a geração anterior (550/850: até 12h intenso
-- contra até 26h do 540/840 não-solar; 1050: até 20h contra até 35h do
-- 1040) — trade-off real por telas mais brilhantes/maiores e, no 1050,
-- alto-falante embutido. Reportado sem esconder.
--
-- FONTES — só oficiais:
--   - Edge 540/840: garmin.com/en-US/newsroom/press-release/sports-fitness/
--     improve-every-day-with-the-new-edge-540-and-edge-840-series-gps-
--     cycling-computers-from-garmin/
--   - Edge 1040: garmin.com/en-US/newsroom/press-release/sports-fitness/
--     garmin-introduces-the-edge-1040-solar-the-ultimate-gps-bike-computer-
--     featuring-breakthrough-solar-charging-and-multi-band-gnss-technology/
--   - Edge 550/850: garmin.com/en-US/newsroom/press-release/sports-fitness/
--     garmin-introduces-edge-550-and-850-its-brightest-and-smartest-compact-
--     cycling-computers/
--   - Edge 1050: garmin.com/en-US/newsroom/press-release/sports-fitness/
--     garmin-unveils-its-brightest-and-smartest-cycling-computer-ever-the-
--     edge-1050/
-- ============================================================================

do $$
declare
  v_brand_id   uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_id     uuid;
  v_p_540 uuid; v_p_840 uuid; v_p_1040 uuid;
  v_p_550 uuid; v_p_850 uuid; v_p_1050 uuid;
  v_quiz uuid; v_q uuid;
begin
  select id into v_cat_id from product_categories where slug = 'ciclismo' and brand_id = v_brand_id;

  -- ==========================================================================
  -- 1. Produtos
  -- ==========================================================================
  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index) values
  (v_brand_id, v_cat_id, 'edge-540', 'Edge 540', '010-02694', 'Ciclocomputador GPS com GNSS multibanda e coaching adaptativo, controle por botão', true, 10),
  (v_brand_id, v_cat_id, 'edge-840', 'Edge 840', '010-02695', 'Ciclocomputador GPS com GNSS multibanda, touchscreen e coaching adaptativo', true, 11),
  (v_brand_id, v_cat_id, 'edge-1040', 'Edge 1040', '010-02503', 'Ciclocomputador GPS premium com tela de 3.5", GNSS multibanda pioneiro e carregamento solar opcional', true, 12),
  (v_brand_id, v_cat_id, 'edge-550', 'Edge 550', '010-02997', 'Ciclocomputador GPS compacto com tela mais brilhante e Garmin Cycling Coach adaptativo, controle por botão', true, 13),
  (v_brand_id, v_cat_id, 'edge-850', 'Edge 850', '010-02998', 'Ciclocomputador GPS compacto com tela mais brilhante, touchscreen e campainha digital', true, 14),
  (v_brand_id, v_cat_id, 'edge-1050', 'Edge 1050', '010-02845', 'Ciclocomputador GPS topo de linha com tela de 3.5" touch, Garmin Pay e alto-falante embutido', true, 15)
  returning id into v_p_540;
  -- (returning só captura o último; buscamos os ids individualmente a seguir)
  select id into v_p_540 from products where slug = 'edge-540';
  select id into v_p_840 from products where slug = 'edge-840';
  select id into v_p_1040 from products where slug = 'edge-1040';
  select id into v_p_550 from products where slug = 'edge-550';
  select id into v_p_850 from products where slug = 'edge-850';
  select id into v_p_1050 from products where slug = 'edge-1050';

  -- ==========================================================================
  -- 2. EDGE 540
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_540, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Edge 540</strong> é o ciclocomputador GPS de entrada da linha performance da Garmin, controlado só por botão — lançado em 11 de abril de 2023 como sucessor do Edge 530.</p><p><strong>Público-alvo:</strong> ciclista que quer dados de treino completos (potência, coaching adaptativo, ClimbPro) sem depender de touchscreen.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "GNSS multibanda", "text": "Maior precisão de posicionamento em mata fechada ou áreas urbanas densas.", "tags": []},
      {"title": "Avaliação de capacidade ciclística", "text": "Analisa a exigência do percurso e sugere ritmo de esforço.", "tags": []},
      {"title": "Coaching adaptativo direcionado", "text": "Planos de treino que se ajustam ao seu progresso.", "tags": []},
      {"title": "Monitor de resistência em tempo real", "text": "Mostra quanta \"gasolina\" ainda resta durante o pedal.", "tags": []},
      {"title": "ClimbPro", "text": "Planejador de subida com perfil de elevação do trecho.", "tags": []},
      {"title": "Bateria de até 26h (42h solar*)", "text": "*Versão solar disponível separadamente, com Power Glass.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_540, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista que prefere botão", "text": "Não quer depender de touchscreen, especialmente com luva ou chuva.", "tags": [{"label": "Praticidade", "color": "green"}]},
      {"title": "Ciclista estruturando treino", "text": "Quer coaching adaptativo e métricas de potência sem pagar pelo topo de linha.", "tags": [{"label": "Performance", "color": "blue"}]},
      {"title": "Mountain biker recreativo", "text": "Usa as métricas de MTB (jump count, grit, flow) em trilha.", "tags": [{"label": "MTB", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer ciclocomputador completo sem touchscreen</li><li>Cliente treina por potência e quer coaching adaptativo</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer touchscreen → indicar o Edge 840</li><li>Cliente quer a tela mais brilhante e recursos mais recentes → indicar o Edge 550</li></ul>"}
  ]}
  $j$),
  (v_p_540, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "GNSS multibanda", "html": "<p>Capta mais de uma frequência de sinal de satélite, melhorando muito a precisão em ambiente urbano denso ou sob mata fechada — recurso que a linha Edge não tinha antes da geração 540/840/1040.</p>"},
      {"title": "Avaliação de capacidade ciclística e exigência do percurso", "html": "<p>O relógio/computador analisa o perfil da rota e sugere como distribuir esforço ao longo do percurso.</p>"},
      {"title": "Coaching adaptativo direcionado", "html": "<p>Planos de treino que se ajustam automaticamente ao progresso do ciclista.</p>"},
      {"title": "Monitor de resistência em tempo real", "html": "<p>Mostra a reserva de energia estimada durante o pedal, ajudando a dosar esforço.</p>"},
      {"title": "Power Guide", "html": "<p>Orientação de potência-alvo pra gerenciar esforço ao longo do percurso.</p>"},
      {"title": "ClimbPro", "html": "<p>Planejador de subida com perfil de elevação em tempo real do trecho à frente.</p>"},
      {"title": "Métricas de mountain bike", "html": "<p>Contagem e distância de saltos, além de métricas de Grit (dificuldade técnica) e Flow (fluidez) da trilha.</p>"}
    ]}
  ]}
  $j$),
  (v_p_540, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Edge 530</strong> (2019), o modelo direto que o 540 substitui."},
    {"type": "accordion", "items": [
      {"title": "GNSS multibanda (recurso totalmente novo)", "html": "<p>O 530 tinha GPS multi-constelação (GPS+GLONASS+Galileo), mas não captava múltiplas frequências. O 540 traz multibanda, melhorando muito a precisão em ambiente urbano denso ou mata fechada.</p>"},
      {"title": "Coaching adaptativo direcionado (recurso totalmente novo)", "html": "<p>O 530 não analisava a exigência do percurso nem ajustava plano de treino automaticamente — isso é novo do 540.</p>"},
      {"title": "Monitor de resistência em tempo real (recurso totalmente novo)", "html": "<p>Mostra a reserva de energia estimada durante o pedal — não existia no 530.</p>"},
      {"title": "Métricas de mountain bike (recurso totalmente novo)", "html": "<p>Contagem/distância de saltos, Grit e Flow — o 530 não tinha esses dados de MTB.</p>"},
      {"title": "Opção de carregamento solar (recurso totalmente novo)", "html": "<p>O 530 não tinha nenhuma variante solar — o 540 Solar (vendido separadamente) introduz essa opção na linha.</p>"},
      {"title": "O que NÃO mudou (continua igual ao 530)", "html": "<p>Controle só por botão (sem touchscreen) e tela de tamanho similar já vinham do 530.</p>"}
    ]}
  ]}
  $j$),
  (v_p_540, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo coaching adaptativo", "dialog": "O Edge 540 não só registra seus dados — ele analisa a exigência do percurso e ajusta o plano de treino conforme seu progresso, com coaching direcionado de verdade.", "tip": "Bom argumento pra ciclista que já usa plano de treino ou quer estruturar um."},
      {"title": "Puxando o GNSS multibanda", "dialog": "Se você já pedalou em mata fechada ou centro urbano e viu o GPS \"pular\" de posição, o multibanda do Edge 540 resolve isso — ele capta mais de uma frequência de sinal, ficando muito mais preciso nesses ambientes.", "tip": "Ótimo argumento pra quem pedala em trilha com muita árvore ou em cidade grande."},
      {"title": "Fechamento", "dialog": "Com o Edge 540 você sai com GNSS multibanda, coaching adaptativo e ClimbPro, tudo controlado por botão — sem depender de touchscreen.", "tip": "Se o cliente hesitar por causa da tela sem toque, pergunte se ele prefere o Edge 840."}
    ]}
  ]}
  $j$),
  (v_p_540, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não tem touchscreen?", "answer": "É uma escolha de design — botão funciona em qualquer condição (chuva, luva, dedo molhado), sem depender de toque. Se o cliente prefere touchscreen, o Edge 840 tem exatamente as mesmas funções com tela sensível ao toque."},
      {"question": "Vale mais que o Edge 530 antigo?", "answer": "Sim — o 540 adiciona GNSS multibanda (o 530 não tem), coaching adaptativo, monitor de resistência em tempo real e métricas de MTB, tudo isso é novo em relação ao 530."},
      {"question": "Por que não o Edge 550, que é mais novo?", "answer": "O 550 tem tela mais brilhante e recursos mais recentes (fueling inteligente, clima em tempo real), mas custa mais. Se o orçamento for a prioridade, o 540 continua sendo um ciclocomputador completo."}
    ]}
  ]}
  $j$),
  (v_p_540, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Ciclista treinando por potência", "text": "Usa o coaching adaptativo e o Power Guide pra estruturar o treino.", "tags": []},
      {"title": "Pedalador em área urbana densa", "text": "O GNSS multibanda evita saltos de posição entre prédios altos.", "tags": []},
      {"title": "Mountain biker recreativo", "text": "Acompanha saltos, Grit e Flow em trilha.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_540, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tem versão solar?", "html": "<p>Sim, vendida separadamente (Edge 540 Solar) — bateria de até 32h em uso intenso ou 60h em modo economia (assumindo exposição solar contínua de 75.000 lux).</p>"},
      {"title": "Qual a diferença pro Edge 840?", "html": "<p>O 840 tem touchscreen responsivo além do controle por botão — o resto das funções (GNSS multibanda, coaching, ClimbPro) é igual.</p>"},
      {"title": "Qual a diferença pro Edge 550?", "html": "<p>O 550 é a geração seguinte, com tela mais brilhante (2.7\") e recursos mais recentes como fueling inteligente e clima em tempo real — mas a bateria em uso intenso é menor (até 12h contra até 26h do 540).</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 3. EDGE 840 (mesma base do 540 + touchscreen)
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_840, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Edge 840</strong> é o ciclocomputador GPS com touchscreen responsivo da Garmin, lançado em 11 de abril de 2023 como sucessor do Edge 830 — mesma base tecnológica do Edge 540, com tela sensível ao toque.</p><p><strong>Público-alvo:</strong> ciclista que quer as mesmas funções do 540, mas prefere navegar por toque na tela (mapas, zoom, planejamento de rota).</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Touchscreen responsivo", "text": "Navegação por toque em mapas, além do controle por botão.", "tags": []},
      {"title": "GNSS multibanda", "text": "Maior precisão de posicionamento em mata fechada ou áreas urbanas densas.", "tags": []},
      {"title": "Coaching adaptativo direcionado", "text": "Planos de treino que se ajustam ao seu progresso.", "tags": []},
      {"title": "Monitor de resistência em tempo real", "text": "Mostra quanta \"gasolina\" ainda resta durante o pedal.", "tags": []},
      {"title": "ClimbPro", "text": "Planejador de subida com perfil de elevação do trecho.", "tags": []},
      {"title": "Bateria de até 26h (32h solar*)", "text": "*Versão solar disponível separadamente, com Power Glass.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_840, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista que gosta de touchscreen", "text": "Prefere navegar em mapas e planejar rota tocando a tela.", "tags": [{"label": "Navegação", "color": "blue"}]},
      {"title": "Ciclista estruturando treino", "text": "Quer coaching adaptativo e métricas de potência.", "tags": [{"label": "Performance", "color": "gold"}]},
      {"title": "Quem vem do Edge 830", "text": "Já está acostumado com touchscreen e quer manter esse padrão de uso.", "tags": [{"label": "Upgrade", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer touchscreen pra navegar em mapas com facilidade</li><li>Cliente vem de um Edge 830 e quer manter a mesma forma de uso</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente prefere controle só por botão (chuva/luva) → indicar o Edge 540</li><li>Cliente quer a campainha digital e recursos mais recentes → indicar o Edge 850</li></ul>"}
  ]}
  $j$),
  (v_p_840, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Touchscreen responsivo", "html": "<p>Permite navegar em mapas, dar zoom e planejar rota tocando a tela, além do controle por botão que já funciona em todas as condições.</p>"},
      {"title": "GNSS multibanda", "html": "<p>Capta mais de uma frequência de sinal de satélite, melhorando muito a precisão em ambiente urbano denso ou sob mata fechada.</p>"},
      {"title": "Avaliação de capacidade ciclística e exigência do percurso", "html": "<p>Analisa o perfil da rota e sugere como distribuir esforço.</p>"},
      {"title": "Coaching adaptativo direcionado", "html": "<p>Planos de treino que se ajustam automaticamente ao progresso do ciclista.</p>"},
      {"title": "ClimbPro", "html": "<p>Planejador de subida com perfil de elevação em tempo real.</p>"},
      {"title": "Métricas de mountain bike", "html": "<p>Contagem e distância de saltos, Grit e Flow da trilha.</p>"}
    ]}
  ]}
  $j$),
  (v_p_840, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Edge 830</strong> (2019), o modelo direto que o 840 substitui."},
    {"type": "accordion", "items": [
      {"title": "GNSS multibanda (recurso totalmente novo)", "html": "<p>O 830 tinha GPS multi-constelação (GPS+GLONASS+Galileo), mas não captava múltiplas frequências. O 840 traz multibanda, melhorando muito a precisão em ambiente urbano denso ou mata fechada.</p>"},
      {"title": "Coaching adaptativo direcionado (recurso totalmente novo)", "html": "<p>O 830 não analisava a exigência do percurso nem ajustava plano de treino automaticamente — isso é novo do 840.</p>"},
      {"title": "Monitor de resistência em tempo real (recurso totalmente novo)", "html": "<p>Mostra a reserva de energia estimada durante o pedal — não existia no 830.</p>"},
      {"title": "Métricas de mountain bike (recurso totalmente novo)", "html": "<p>Contagem/distância de saltos, Grit e Flow — o 830 não tinha esses dados de MTB.</p>"},
      {"title": "Opção de carregamento solar (recurso totalmente novo)", "html": "<p>O 830 não tinha nenhuma variante solar — o 840 Solar (vendido separadamente) introduz essa opção na linha.</p>"},
      {"title": "O que NÃO mudou (continua igual ao 830)", "html": "<p>Touchscreen responsivo já vinha do 830 — essa continua sendo a diferença pro 540 (só botão), não uma novidade desta geração.</p>"}
    ]}
  ]}
  $j$),
  (v_p_840, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo touchscreen", "dialog": "Se você gosta de navegar em mapa tocando a tela pra dar zoom ou traçar rota, o Edge 840 tem touchscreen responsivo, além do controle por botão pros momentos que precisar.", "tip": "Bom argumento pra quem usa muito navegação/mapas durante o pedal."},
      {"title": "Puxando o GNSS multibanda", "dialog": "Assim como no 540, o 840 capta mais de uma frequência de satélite — muito mais preciso em mata fechada ou centro urbano denso.", "tip": "Reaproveita o mesmo argumento do Edge 540."},
      {"title": "Fechamento", "dialog": "Com o Edge 840 você sai com touchscreen, GNSS multibanda e coaching adaptativo completo.", "tip": "Confirme se o cliente realmente valoriza touchscreen — se não, o 540 é mais em conta com as mesmas funções."}
    ]}
  ]}
  $j$),
  (v_p_840, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Vale a diferença de preço pro Edge 540?", "answer": "A diferença é só o touchscreen — se o cliente não valoriza navegar por toque, o 540 entrega exatamente as mesmas outras funções por menos."},
      {"question": "Vale mais que o Edge 830 antigo?", "answer": "Sim — o 840 adiciona GNSS multibanda (o 830 não tem), coaching adaptativo, monitor de resistência em tempo real e métricas de MTB."},
      {"question": "Por que não o Edge 850, que é mais novo?", "answer": "O 850 tem tela mais brilhante, campainha digital e recursos mais recentes de fueling/clima, mas custa mais e tem menos horas de bateria em uso intenso."}
    ]}
  ]}
  $j$),
  (v_p_840, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Ciclista que navega por rotas planejadas", "text": "Usa o touchscreen pra ajustar rota e dar zoom no mapa durante o pedal.", "tags": []},
      {"title": "Cliente migrando do Edge 830", "text": "Quer manter a mesma experiência de touchscreen, com recursos novos.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_840, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tem versão solar?", "html": "<p>Sim, vendida separadamente (Edge 840 Solar) — bateria de até 32h em uso intenso ou 60h em modo economia.</p>"},
      {"title": "Qual a diferença pro Edge 540?", "html": "<p>Só o touchscreen — o 540 é controlado apenas por botão, o resto das funções é idêntico.</p>"},
      {"title": "Qual a diferença pro Edge 850?", "html": "<p>O 850 é a geração seguinte, com tela mais brilhante (2.7\"), campainha digital e recursos mais recentes — mas menos horas de bateria em uso intenso (até 12h contra até 26h do 840).</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 4. EDGE 1040
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_1040, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Edge 1040</strong> é o ciclocomputador GPS premium da Garmin com tela de 3.5\", lançado em junho de 2022 como sucessor do Edge 1030 Plus — foi o primeiro Edge da história a trazer GNSS multibanda, um ano antes da tecnologia chegar ao 540/840.</p><p><strong>Público-alvo:</strong> ciclista que quer a tela maior da linha Edge, com opção de carregamento solar e a melhor precisão de GPS disponível na época do lançamento.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela touchscreen de 3.5\"", "text": "A maior tela da linha Edge até então.", "tags": []},
      {"title": "GNSS multibanda pioneiro", "text": "Primeiro Edge da Garmin com essa tecnologia.", "tags": []},
      {"title": "Carregamento solar (versão Solar)", "text": "Power Glass integrado, estende a autonomia em uso à luz do dia.", "tags": []},
      {"title": "32 GB de memória interna", "text": "Espaço de sobra pra mapas e músicas.", "tags": []},
      {"title": "Bateria de até 35h (70h economia)", "text": "Autonomia робusta pra provas longas.", "tags": []},
      {"title": "USB-C", "text": "Conector moderno de carregamento e transferência de dados.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_1040, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista de longa distância / brevet", "text": "Precisa de bateria robusta e tela grande e legível.", "tags": [{"label": "Endurance", "color": "blue"}]},
      {"title": "Quem quer a maior tela da linha Edge", "text": "Valoriza visibilidade de mapa e dados em tela grande.", "tags": [{"label": "Navegação", "color": "gold"}]},
      {"title": "Ciclista que pedala fora de área de cobertura", "text": "Aproveita a versão Solar pra estender autonomia.", "tags": [{"label": "Bateria", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer a tela mais grande da linha Edge com preço mais em conta que o 1050</li><li>Cliente prioriza bateria de longa duração acima de recursos mais recentes</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer Garmin Pay, alto-falante embutido e tela ainda mais brilhante → indicar o Edge 1050</li></ul>"}
  ]}
  $j$),
  (v_p_1040, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "GNSS multibanda pioneiro", "html": "<p>O Edge 1040 foi o primeiro ciclocomputador Garmin a trazer captação de múltiplas frequências de satélite — um ano antes de chegar ao 540/840.</p>"},
      {"title": "Tela touchscreen de 3.5\"", "html": "<p>A maior tela da linha Edge na época do lançamento, facilitando leitura de mapas e dados.</p>"},
      {"title": "Carregamento solar (versão Solar)", "html": "<p>Power Glass integrado ao vidro da tela, estendendo a autonomia em pedais sob luz do dia.</p>"},
      {"title": "32 GB de memória interna", "html": "<p>Espaço de sobra pra mapas offline e músicas, com suporte a cartão de memória externo.</p>"},
      {"title": "Roteamento e busca de destino mais rápidos", "html": "<p>Cálculo de rota e busca de destino significativamente mais ágeis que a geração 1030.</p>"},
      {"title": "USB-C e traseira/tabs metálicos", "html": "<p>Conector moderno e acabamento reforçado no encaixe do suporte.</p>"}
    ]}
  ]}
  $j$),
  (v_p_1040, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Edge 1030 Plus</strong>, o modelo direto que o 1040 substitui."},
    {"type": "accordion", "items": [
      {"title": "GNSS multibanda (recurso totalmente novo)", "html": "<p>O 1030 Plus tinha GPS multi-constelação (GPS+GLONASS+Galileo), mas não captava múltiplas frequências. O 1040 foi o primeiro Edge a trazer essa tecnologia, melhorando muito a precisão em ambiente urbano denso ou mata fechada.</p>"},
      {"title": "Carregamento solar (versão Solar)", "html": "<p>Recurso novo — o 1030 Plus não tinha opção de carregamento solar.</p>"},
      {"title": "Roteamento mais rápido", "html": "<p>Cálculo de rota e busca de destino dramaticamente mais ágeis que no 1030 Plus.</p>"},
      {"title": "USB-C", "html": "<p>O 1030 Plus usava micro-USB — o 1040 traz o conector mais moderno.</p>"},
      {"title": "O que NÃO mudou (continua igual ao 1030 Plus)", "html": "<p>Tela touchscreen de tamanho similar e a proposta de topo de linha da Edge já vinham do 1030 Plus.</p>"}
    ]}
  ]}
  $j$),
  (v_p_1040, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela tela grande e bateria", "dialog": "O Edge 1040 tem a maior tela da linha Edge e bateria de até 35 horas em uso intenso — ideal pra quem pedala prova longa ou brevet.", "tip": "Bom argumento pra ciclista de endurance/ultra distância."},
      {"title": "Puxando o pioneirismo do multibanda", "dialog": "O 1040 foi o primeiro ciclocomputador Garmin com GNSS multibanda — ele capta mais de uma frequência de sinal, ficando muito mais preciso em cidade grande ou mata fechada.", "tip": "Bom argumento técnico pra cliente exigente."},
      {"title": "Fechamento", "dialog": "Com o Edge 1040 você sai com a maior tela, bateria robusta e a precisão de GPS mais avançada da linha na época — e ainda pode escolher a versão Solar.", "tip": "Se o orçamento permitir, mencione o Edge 1050 como a geração mais nova."}
    ]}
  ]}
  $j$),
  (v_p_1040, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não o Edge 1050, que é mais novo?", "answer": "O 1050 tem Garmin Pay, alto-falante embutido e tela ainda mais brilhante, mas custa mais e tem menos horas de bateria em uso intenso (até 20h contra até 35h do 1040). Se o cliente prioriza autonomia, o 1040 é uma opção sólida."},
      {"question": "Vale mais que o Edge 1030 Plus antigo?", "answer": "Sim — o 1040 traz GNSS multibanda (o 1030 Plus não tem), roteamento muito mais rápido e a opção de carregamento solar."},
      {"question": "Preciso da versão Solar?", "answer": "Só se o cliente pedala muitas horas seguidas sob luz do dia — a versão Solar estende bastante a autonomia nessas condições, mas custa mais."}
    ]}
  ]}
  $j$),
  (v_p_1040, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Ciclista de brevet/ultra distância", "text": "Bateria robusta e opção solar pra provas de muitas horas.", "tags": []},
      {"title": "Cliente que quer topo de linha por menos que o 1050", "text": "Mesma proposta premium, geração anterior, custo menor.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_1040, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tem Garmin Pay?", "html": "<p>Não — Garmin Pay é exclusivo da geração Edge 1050.</p>"},
      {"title": "Qual a diferença real pro Edge 1050?", "html": "<p>O 1050 adiciona Garmin Pay, alto-falante embutido, WiFi pra atualização de mapas e tela ainda mais brilhante, mas dura menos horas por carga em uso intenso. Veja a aba \"O que há de novo?\" pra comparação completa com o 1030 Plus.</p>"},
      {"title": "Quanto de memória interna tem?", "html": "<p>32 GB, com suporte a cartão de memória externo.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 5. EDGE 550 (refresh do 540) + novidades
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_550, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Edge 550</strong> é a geração mais nova do ciclocomputador GPS compacto por botão da Garmin, lançado em 9 de setembro de 2025 como sucessor direto do Edge 540 — tela mais brilhante e recursos de treino mais recentes.</p><p><strong>Público-alvo:</strong> ciclista que quer o ciclocomputador por botão mais atual da Garmin, com fueling inteligente e clima em tempo real.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela de 2.7\" mais brilhante", "text": "Redesenho de tela mais legível sob sol direto.", "tags": []},
      {"title": "Garmin Cycling Coach adaptativo", "text": "Plano de treino que se ajusta automaticamente ao progresso.", "tags": []},
      {"title": "Alertas inteligentes de fueling", "text": "Recomendações personalizadas de nutrição e hidratação durante o pedal.", "tags": []},
      {"title": "Clima em tempo real", "text": "Sobreposição de vento e radar de chuva no mapa.", "tags": []},
      {"title": "Perfis enduro/downhill", "text": "Gravação de GPS a 5Hz e cronometragem por trecho pra MTB.", "tags": []},
      {"title": "Bateria de até 36h (economia)", "text": "Até 12h em uso intenso com todos os recursos ativos.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_550, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista que quer o mais recente por botão", "text": "Valoriza fueling inteligente e clima em tempo real.", "tags": [{"label": "Tecnologia", "color": "blue"}]},
      {"title": "Usuário do Edge 540 avaliando upgrade", "text": "Quer saber se vale trocar de geração.", "tags": [{"label": "Upgrade", "color": "gold"}]},
      {"title": "Mountain biker de enduro/downhill", "text": "Usa gravação a 5Hz e cronometragem por trecho.", "tags": [{"label": "MTB", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer o ciclocomputador por botão mais atual, com fueling e clima em tempo real</li><li>Cliente pratica enduro/downhill e valoriza gravação de GPS a 5Hz</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente prioriza mais horas de bateria em uso intenso → o Edge 540 dura mais por carga</li><li>Cliente quer touchscreen → indicar o Edge 850</li></ul>"}
  ]}
  $j$),
  (v_p_550, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tela de 2.7\" mais brilhante", "html": "<p>Redesenho de tela com melhor legibilidade sob sol direto, maior que a tela de 2.6\" do 540.</p>"},
      {"title": "Garmin Cycling Coach adaptativo", "html": "<p>Plano de treino que se ajusta automaticamente ao progresso do ciclista.</p>"},
      {"title": "Alertas inteligentes de fueling", "html": "<p>Recomendações personalizadas de nutrição e hidratação durante o pedal.</p>"},
      {"title": "Sobreposições de clima em tempo real", "html": "<p>Vento e radar de chuva sobrepostos ao mapa.</p>"},
      {"title": "Comparações de GroupRide", "html": "<p>Compara métricas do grupo de pedal em tempo real.</p>"},
      {"title": "Análise de relação de marcha", "html": "<p>Avalia a relação de marcha usada durante o pedal.</p>"},
      {"title": "Perfis enduro/downhill", "html": "<p>Gravação de GPS a 5Hz e cronometragem (timing gates) por trecho, pra MTB de descida.</p>"}
    ]}
  ]}
  $j$),
  (v_p_550, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Edge 540</strong>, o modelo direto que o 550 substitui."},
    {"type": "accordion", "items": [
      {"title": "Tela maior e mais brilhante", "html": "<p>2.7\" no 550 contra 2.6\" no 540, com brilho aprimorado pra melhor leitura sob sol.</p>"},
      {"title": "Garmin Cycling Coach adaptativo", "html": "<p>Sistema de coaching evoluído em relação ao coaching adaptativo já existente no 540 — mais integrado ao ecossistema Garmin Connect.</p>"},
      {"title": "Alertas inteligentes de fueling (recurso totalmente novo)", "html": "<p>O 540 não tinha recomendações de nutrição/hidratação personalizadas — recurso novo do 550.</p>"},
      {"title": "Clima em tempo real (recurso totalmente novo)", "html": "<p>Sobreposição de vento e radar de chuva no mapa — não existia no 540.</p>"},
      {"title": "Perfis enduro/downhill com 5Hz e timing gates (recurso totalmente novo)", "html": "<p>Gravação de GPS a 5Hz e cronometragem por trecho pra MTB de descida — não existia no 540.</p>"},
      {"title": "Bateria dura menos horas em uso intenso (atenção ao vender)", "html": "<p>Até 12h em uso intenso no 550 contra até 26h no 540 (não-solar) — provavelmente reflexo da tela mais brilhante e dos recursos adicionais ativos. Em modo economia a diferença é menor (36h contra 42h). Vale mencionar essa troca com transparência.</p>"}
    ]}
  ]}
  $j$),
  (v_p_550, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo fueling inteligente", "dialog": "O Edge 550 te avisa quando comer e beber durante o pedal, com recomendações personalizadas de nutrição — isso é novo nessa geração.", "tip": "Bom argumento pra ciclista de prova longa ou fundista."},
      {"title": "Puxando o clima em tempo real", "dialog": "Ele também mostra vento e chuva em tempo real sobrepostos no mapa — dá pra planejar o pedal sabendo exatamente o que vem pela frente.", "tip": "Bom argumento pra quem pedala em região de clima instável."},
      {"title": "Sendo transparente sobre a bateria", "dialog": "Uma coisa importante: em uso intenso com tudo ativado, a bateria dura menos que a geração anterior — mas em modo economia a diferença é pequena.", "tip": "Melhor mencionar isso proativamente."},
      {"title": "Fechamento", "dialog": "Com o Edge 550 você sai com a tela mais brilhante da linha por botão, fueling inteligente e clima em tempo real.", "tip": "Confirme se o cliente faz enduro/downhill — o timing gate pode ser decisivo."}
    ]}
  ]}
  $j$),
  (v_p_550, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Vale a pena trocar o 540 pelo 550?", "answer": "Vale se o cliente quer fueling inteligente, clima em tempo real ou os perfis de enduro/downhill. Se prioriza bateria de longa duração em uso intenso, o 540 ainda é uma opção válida."},
      {"question": "Por que a bateria dura menos em uso intenso?", "answer": "Provavelmente reflexo da tela mais brilhante e dos novos recursos ativos simultaneamente — em modo economia a diferença é pequena (36h contra 42h)."},
      {"question": "Tem versão touchscreen?", "answer": "Não — pra touchscreen, o modelo correto é o Edge 850."}
    ]}
  ]}
  $j$),
  (v_p_550, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Ciclista de prova longa preocupado com nutrição", "text": "Usa os alertas inteligentes de fueling durante o percurso.", "tags": []},
      {"title": "Mountain biker de enduro/downhill", "text": "Usa gravação a 5Hz e timing gates por trecho.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_550, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Qual a diferença real pro 540?", "html": "<p>Tela maior e mais brilhante, fueling inteligente, clima em tempo real e perfis enduro/downhill — mas bateria em uso intenso menor. Veja a aba \"O que há de novo?\" pra comparação completa.</p>"},
      {"title": "Tem opção solar?", "html": "<p>O material oficial do lançamento do 550/850 não menciona variante solar — diferente do 540/840, que têm opção Solar vendida separadamente.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 6. EDGE 850 (refresh do 840, mesma base do 550 + touchscreen + campainha)
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_850, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Edge 850</strong> é a geração mais nova do ciclocomputador GPS compacto com touchscreen da Garmin, lançado em 9 de setembro de 2025 como sucessor direto do Edge 840 — mesma base do Edge 550, com touchscreen e campainha digital exclusiva.</p><p><strong>Público-alvo:</strong> ciclista que quer touchscreen, os recursos de treino mais recentes e um alerta sonoro pra pedestres.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Touchscreen responsivo", "text": "Navegação por toque em mapas, zoom, denúncia de riscos.", "tags": []},
      {"title": "Campainha digital", "text": "Alerta sonoro pra pedestres e outros ciclistas — exclusivo do 850.", "tags": []},
      {"title": "Garmin Cycling Coach adaptativo", "text": "Plano de treino que se ajusta ao seu progresso.", "tags": []},
      {"title": "Alertas inteligentes de fueling", "text": "Recomendações personalizadas de nutrição e hidratação.", "tags": []},
      {"title": "Clima em tempo real", "text": "Sobreposição de vento e radar de chuva no mapa.", "tags": []},
      {"title": "Bateria de até 36h (economia)", "text": "Até 12h em uso intenso com todos os recursos ativos.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_850, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista urbano", "text": "Usa a campainha digital pra alertar pedestres com segurança.", "tags": [{"label": "Segurança", "color": "blue"}]},
      {"title": "Usuário do Edge 840 avaliando upgrade", "text": "Quer saber se vale trocar de geração.", "tags": [{"label": "Upgrade", "color": "gold"}]},
      {"title": "Ciclista que quer touchscreen + recursos recentes", "text": "Fueling inteligente e clima em tempo real com navegação por toque.", "tags": [{"label": "Tecnologia", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente pedala em ambiente urbano e valoriza a campainha digital</li><li>Cliente quer touchscreen com os recursos mais recentes de treino</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente prioriza mais horas de bateria em uso intenso → o Edge 840 dura mais por carga</li><li>Cliente prefere controle só por botão → indicar o Edge 550</li></ul>"}
  ]}
  $j$),
  (v_p_850, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Touchscreen responsivo", "html": "<p>Pra pan/zoom em mapas, denúncia de riscos na via e navegação entre telas.</p>"},
      {"title": "Campainha digital", "html": "<p>Alerta sonoro pra avisar pedestres e outros ciclistas — recurso exclusivo do 850 (o 550, por botão, não tem).</p>"},
      {"title": "Garmin Cycling Coach adaptativo", "html": "<p>Plano de treino que se ajusta automaticamente ao progresso.</p>"},
      {"title": "Alertas inteligentes de fueling", "html": "<p>Recomendações personalizadas de nutrição e hidratação durante o pedal.</p>"},
      {"title": "Sobreposições de clima em tempo real", "html": "<p>Vento e radar de chuva sobrepostos ao mapa.</p>"},
      {"title": "Análise de relação de marcha", "html": "<p>Avalia a relação de marcha usada durante o pedal.</p>"}
    ]}
  ]}
  $j$),
  (v_p_850, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Edge 840</strong>, o modelo direto que o 850 substitui."},
    {"type": "accordion", "items": [
      {"title": "Campainha digital (recurso totalmente novo)", "html": "<p>O 840 não tinha esse alerta sonoro pra pedestres/ciclistas — exclusivo da geração 850.</p>"},
      {"title": "Tela maior e mais brilhante", "html": "<p>2.7\" no 850 contra 2.6\" no 840, com brilho aprimorado.</p>"},
      {"title": "Alertas inteligentes de fueling (recurso totalmente novo)", "html": "<p>Recomendações de nutrição/hidratação personalizadas — não existia no 840.</p>"},
      {"title": "Clima em tempo real (recurso totalmente novo)", "html": "<p>Sobreposição de vento e radar de chuva — não existia no 840.</p>"},
      {"title": "Bateria dura menos horas em uso intenso (atenção ao vender)", "html": "<p>Até 12h em uso intenso no 850 contra até 26h no 840 (não-solar). Em modo economia a diferença é menor (36h contra 42h). Vale mencionar com transparência.</p>"},
      {"title": "O que NÃO mudou (continua igual ao 840)", "html": "<p>Touchscreen responsivo e GNSS multibanda já vinham do 840.</p>"}
    ]}
  ]}
  $j$),
  (v_p_850, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela campainha digital", "dialog": "O Edge 850 tem uma campainha digital embutida — dá pra avisar pedestre ou outro ciclista sem precisar gritar ou tirar a mão do guidão.", "tip": "Ótimo argumento pra ciclista urbano ou que pedala em ciclovia compartilhada."},
      {"title": "Puxando o fueling inteligente", "dialog": "Ele também te avisa quando comer e beber durante o pedal, com recomendações personalizadas — isso é novo nessa geração.", "tip": "Bom argumento pra ciclista de prova longa."},
      {"title": "Fechamento", "dialog": "Com o Edge 850 você sai com touchscreen, campainha digital, fueling inteligente e clima em tempo real.", "tip": "Se o cliente não valoriza a campainha, pergunte se prefere o Edge 550 (mesma base, por botão, mais em conta)."}
    ]}
  ]}
  $j$),
  (v_p_850, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Vale a pena trocar o 840 pelo 850?", "answer": "Vale se o cliente quer campainha digital, fueling inteligente ou clima em tempo real. Se prioriza bateria de longa duração em uso intenso, o 840 ainda é válido."},
      {"question": "A campainha substitui uma campainha física?", "answer": "Ela complementa — é um recurso adicional de segurança, não elimina a necessidade de sinalização visual/manual em algumas situações de trânsito."},
      {"question": "Qual a diferença pro Edge 550?", "answer": "O 550 não tem touchscreen nem campainha digital — é controlado só por botão. O resto dos recursos de treino é o mesmo."}
    ]}
  ]}
  $j$),
  (v_p_850, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Ciclista urbano em ciclovia compartilhada", "text": "Usa a campainha digital pra alertar pedestres com segurança.", "tags": []},
      {"title": "Cliente migrando do Edge 840", "text": "Quer manter touchscreen e ganhar os recursos mais recentes.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_850, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Qual a diferença real pro 840?", "html": "<p>Campainha digital, tela maior/mais brilhante, fueling inteligente e clima em tempo real — mas bateria em uso intenso menor. Veja a aba \"O que há de novo?\" pra comparação completa.</p>"},
      {"title": "A campainha funciona em qualquer volume?", "html": "<p>O material oficial não detalha níveis de volume — apenas confirma a função de alerta sonoro pra pedestres.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 7. EDGE 1050 (refresh do 1040)
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_1050, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Edge 1050</strong> é o ciclocomputador GPS topo de linha da Garmin, lançado em 25 de junho de 2024 como sucessor do Edge 1040 — descrito pela própria Garmin como \"o ciclocomputador mais brilhante e inteligente já feito\" até então.</p><p><strong>Público-alvo:</strong> ciclista que quer o que há de mais avançado na linha Edge, incluindo pagamento por aproximação e alerta sonoro embutido.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela touchscreen de 3.5\" vívida", "text": "Alto contraste, visor angulado e botões metálicos discretos.", "tags": []},
      {"title": "Garmin Pay", "text": "Pagamento por aproximação direto do ciclocomputador.", "tags": []},
      {"title": "Alto-falante embutido", "text": "Funciona como campainha e emite avisos de treino/navegação.", "tags": []},
      {"title": "WiFi pra atualização de mapas", "text": "Mapas do ciclismo e dados do Trailforks sempre atualizados.", "tags": []},
      {"title": "Trendline Popularity Routing", "text": "Roteamento baseado nas rotas mais populares entre ciclistas.", "tags": []},
      {"title": "Bateria de até 20h (60h economia)", "text": "Menos horas em uso intenso que o 1040, por conta da tela maior/mais brilhante e alto-falante.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_1050, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista que quer o topo de linha absoluto", "text": "Não abre mão de nenhum recurso disponível na linha Edge.", "tags": [{"label": "Topo de linha", "color": "gold"}]},
      {"title": "Quem valoriza Garmin Pay no pedal", "text": "Faz paradas em loja de conveniência/posto sem levar carteira.", "tags": [{"label": "Praticidade", "color": "blue"}]},
      {"title": "Usuário do Edge 1040 avaliando upgrade", "text": "Quer saber se vale trocar de geração.", "tags": [{"label": "Upgrade", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer o ciclocomputador mais completo da Garmin, sem restrição de orçamento</li><li>Cliente valoriza Garmin Pay e alto-falante embutido</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente prioriza bateria de longa duração em uso intenso acima de tudo → o Edge 1040 dura mais por carga</li></ul>"}
  ]}
  $j$),
  (v_p_1050, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tela touchscreen de 3.5\" vívida e de alto contraste", "html": "<p>Visor angulado, botões metálicos discretos e suporte de montagem substituível de giro rápido.</p>"},
      {"title": "Garmin Pay", "html": "<p>Pagamento por aproximação direto do ciclocomputador, sem precisar levar carteira ou celular.</p>"},
      {"title": "Alto-falante embutido", "html": "<p>Funciona como campainha e emite avisos sonoros de treino e navegação.</p>"},
      {"title": "WiFi integrado", "html": "<p>Atualização de mapas do ciclismo (com dados Trailforks de mountain bike) sem precisar de computador.</p>"},
      {"title": "Trendline Popularity Routing", "html": "<p>Sugere rotas com base na popularidade entre outros ciclistas.</p>"},
      {"title": "GroupRide aprimorado e alertas de risco na via", "html": "<p>Mensagens com localização ao vivo do grupo e alertas de riscos reportados por outros ciclistas.</p>"},
      {"title": "Ranking em subidas e prêmios pós-pedal", "html": "<p>Classificação em tempo real durante subidas e reconhecimentos ao final do percurso.</p>"}
    ]}
  ]}
  $j$),
  (v_p_1050, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Edge 1040</strong>, o modelo direto que o 1050 substitui."},
    {"type": "accordion", "items": [
      {"title": "Garmin Pay (recurso totalmente novo)", "html": "<p>O 1040 não tinha pagamento por aproximação — recurso exclusivo do 1050.</p>"},
      {"title": "Alto-falante embutido (recurso totalmente novo)", "html": "<p>Funciona como campainha e emite avisos sonoros — o 1040 não tinha alto-falante.</p>"},
      {"title": "WiFi integrado (recurso totalmente novo)", "html": "<p>Atualização de mapas sem cabo — o 1040 dependia de conexão via app/computador para isso.</p>"},
      {"title": "Design com visor angulado e botões metálicos", "html": "<p>Novo acabamento físico, com suporte de montagem substituível de giro rápido.</p>"},
      {"title": "Trendline Popularity Routing e GroupRide aprimorado", "html": "<p>Recursos de roteamento social e mensagens com localização ao vivo, novos em relação ao 1040.</p>"},
      {"title": "Bateria dura bem menos horas em uso intenso (atenção ao vender)", "html": "<p>Até 20h no 1050 contra até 35h no 1040 — reflexo direto da tela maior/mais brilhante e do alto-falante embutido. Em modo economia a diferença também existe (60h contra 70h). É a troca mais significativa dessa geração e vale ser transparente sobre ela.</p>"},
      {"title": "O que NÃO mudou (continua igual ao 1040)", "html": "<p>Tela touchscreen de 3.5\", GNSS multibanda e 32 GB de memória interna já vinham do 1040.</p>"}
    ]}
  ]}
  $j$),
  (v_p_1050, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo Garmin Pay", "dialog": "O Edge 1050 tem Garmin Pay embutido — dá pra parar num posto ou loja de conveniência no meio do pedal e pagar direto pelo ciclocomputador, sem levar carteira.", "tip": "Bom argumento pra ciclista de longa distância que faz paradas durante o percurso."},
      {"title": "Puxando o alto-falante embutido", "dialog": "Ele também tem alto-falante integrado, que funciona como campainha e avisa você por som durante o treino ou navegação.", "tip": "Bom argumento de segurança/praticidade."},
      {"title": "Sendo transparente sobre a bateria", "dialog": "Uma coisa importante: com a tela maior e mais brilhante e o alto-falante, a bateria em uso intenso dura bem menos que a geração anterior — vale considerar isso se o cliente faz provas muito longas.", "tip": "Melhor mencionar isso proativamente, principalmente pra quem vem do 1040."},
      {"title": "Fechamento", "dialog": "Com o Edge 1050 você sai com o ciclocomputador mais completo da Garmin — Garmin Pay, alto-falante, WiFi e a tela mais vívida da linha.", "tip": "Se bateria for prioridade máxima, mencione o Edge 1040 como alternativa."}
    ]}
  ]}
  $j$),
  (v_p_1050, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Vale a pena trocar o 1040 pelo 1050?", "answer": "Vale se o cliente quer Garmin Pay, alto-falante embutido e WiFi. Se prioriza bateria de longa duração em uso intenso (prova muito longa, brevet), o 1040 ainda entrega mais horas por carga."},
      {"question": "Por que a bateria caiu tanto?", "answer": "É o trade-off direto de ter uma tela maior/mais brilhante e um alto-falante embutido consumindo energia extra — vale ser transparente sobre isso, especialmente com quem pedala provas de resistência muito longas."},
      {"question": "O Garmin Pay funciona em qualquer estabelecimento?", "answer": "Depende da adesão do estabelecimento e do banco emissor do cartão — mesma lógica de pagamento por aproximação já usada em relógios Garmin com Garmin Pay."}
    ]}
  ]}
  $j$),
  (v_p_1050, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Ciclista que faz paradas durante o pedal", "text": "Usa o Garmin Pay pra abastecer sem levar carteira.", "tags": []},
      {"title": "Cliente que quer o topo de linha absoluto", "text": "Não abre mão de nenhum recurso disponível na linha Edge.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_1050, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Qual a diferença real pro 1040?", "html": "<p>Garmin Pay, alto-falante embutido, WiFi integrado e novo design — mas bateria em uso intenso bem menor (até 20h contra até 35h). Veja a aba \"O que há de novo?\" pra comparação completa.</p>"},
      {"title": "Tem versão Solar?", "html": "<p>O material oficial do lançamento do 1050 não menciona variante solar.</p>"},
      {"title": "Quanto de memória interna tem?", "html": "<p>Mesma capacidade do 1040: 32 GB internos, com suporte a cartão de memória externo.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 8. Quiz Especialista — 6 produtos (3 perguntas cada, resumido dado o volume)
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-edge-540', 'Quiz Especialista: Edge 540', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Edge 540 tem touchscreen?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — controle só por botão', true, 1), (v_q, 'Sim, touchscreen completo', false, 2), (v_q, 'Só em algumas telas', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que é GNSS multibanda?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Captação de mais de uma frequência de sinal de satélite', true, 1), (v_q, 'Usar dois GPS ao mesmo tempo', false, 2), (v_q, 'Sinal de rádio FM', false, 3), (v_q, 'Conexão WiFi dupla', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Edge 530 (2019) tinha GNSS multibanda?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — só multi-constelação (GPS+GLONASS+Galileo)', true, 1), (v_q, 'Sim, já tinha', false, 2), (v_q, 'Não tinha GPS', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-edge-840', 'Quiz Especialista: Edge 840', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual a principal diferença do Edge 840 pro Edge 540?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Touchscreen responsivo', true, 1), (v_q, 'Bateria maior', false, 2), (v_q, 'Tela menor', false, 3), (v_q, 'Não tem GNSS multibanda', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Edge 840 tem carregamento solar de fábrica?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — versão Solar é vendida separadamente', true, 1), (v_q, 'Sim, sempre vem com solar', false, 2), (v_q, 'Não existe versão solar', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Edge 830 (predecessor) tinha touchscreen?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Sim, já tinha touchscreen', true, 1), (v_q, 'Não, só botão', false, 2), (v_q, 'Só em modo mapa', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-edge-1040', 'Quiz Especialista: Edge 1040', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Edge 1040 foi pioneiro em qual tecnologia na linha Edge?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'GNSS multibanda', true, 1), (v_q, 'Touchscreen', false, 2), (v_q, 'Garmin Pay', false, 3), (v_q, 'WiFi', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Quanta memória interna tem o Edge 1040?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '32 GB', true, 1), (v_q, '8 GB', false, 2), (v_q, '128 GB', false, 3), (v_q, '16 GB', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Edge 1040 tem Garmin Pay?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é exclusivo do Edge 1050', true, 1), (v_q, 'Sim, tem Garmin Pay', false, 2), (v_q, 'Só na versão Solar', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-edge-550', 'Quiz Especialista: Edge 550', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que os alertas de fueling do Edge 550 recomendam?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Nutrição e hidratação personalizadas', true, 1), (v_q, 'Rota alternativa', false, 2), (v_q, 'Troca de marcha', false, 3), (v_q, 'Calibração de sensor', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Comparado ao Edge 540, a bateria do 550 em uso intenso é...', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Menor (até 12h contra até 26h)', true, 1), (v_q, 'Maior', false, 2), (v_q, 'Idêntica', false, 3), (v_q, 'Não tem bateria', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Edge 550 tem touchscreen?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — controle só por botão', true, 1), (v_q, 'Sim', false, 2), (v_q, 'Só em modo mapa', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-edge-850', 'Quiz Especialista: Edge 850', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual recurso é exclusivo do Edge 850 (não está no Edge 550)?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Campainha digital + touchscreen', true, 1), (v_q, 'Garmin Cycling Coach', false, 2), (v_q, 'Alertas de fueling', false, 3), (v_q, 'Clima em tempo real', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que a campainha digital do Edge 850 faz?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Emite alerta sonoro pra pedestres/ciclistas', true, 1), (v_q, 'Toca música', false, 2), (v_q, 'Avisa chamada telefônica', false, 3), (v_q, 'Nenhuma das anteriores', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Edge 840 (predecessor) tinha campainha digital?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é novo do 850', true, 1), (v_q, 'Sim, já tinha', false, 2), (v_q, 'Só na versão Solar', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-edge-1050', 'Quiz Especialista: Edge 1050', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que o Edge 1050 tem que o 1040 não tinha?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Garmin Pay e alto-falante embutido', true, 1), (v_q, 'GNSS multibanda', false, 2), (v_q, 'Touchscreen', false, 3), (v_q, '32GB de memória', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Comparado ao Edge 1040, a bateria do 1050 em uso intenso é...', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Bem menor (até 20h contra até 35h)', true, 1), (v_q, 'Maior', false, 2), (v_q, 'Idêntica', false, 3), (v_q, 'Não tem bateria', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O alto-falante do Edge 1050 serve pra quê?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Campainha e avisos sonoros de treino/navegação', true, 1), (v_q, 'Tocar música', false, 2), (v_q, 'Chamada telefônica viva-voz', false, 3), (v_q, 'Nenhuma das anteriores', false, 4);

  insert into product_quizzes (product_id, quiz_id)
  select id, (select id from quizzes where slug = 'quiz-especialista-edge-540') from products where slug = 'edge-540'
  union all select id, (select id from quizzes where slug = 'quiz-especialista-edge-840') from products where slug = 'edge-840'
  union all select id, (select id from quizzes where slug = 'quiz-especialista-edge-1040') from products where slug = 'edge-1040'
  union all select id, (select id from quizzes where slug = 'quiz-especialista-edge-550') from products where slug = 'edge-550'
  union all select id, (select id from quizzes where slug = 'quiz-especialista-edge-850') from products where slug = 'edge-850'
  union all select id, (select id from quizzes where slug = 'quiz-especialista-edge-1050') from products where slug = 'edge-1050';

  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-edge-540-garmin', 'Especialista Edge 540', 'Concedido ao passar no Quiz Especialista do Edge 540.', '{"tipo": "quiz_especialista_produto", "produto": "edge-540"}'),
  (v_brand_id, 'especialista-edge-840-garmin', 'Especialista Edge 840', 'Concedido ao passar no Quiz Especialista do Edge 840.', '{"tipo": "quiz_especialista_produto", "produto": "edge-840"}'),
  (v_brand_id, 'especialista-edge-1040-garmin', 'Especialista Edge 1040', 'Concedido ao passar no Quiz Especialista do Edge 1040.', '{"tipo": "quiz_especialista_produto", "produto": "edge-1040"}'),
  (v_brand_id, 'especialista-edge-550-garmin', 'Especialista Edge 550', 'Concedido ao passar no Quiz Especialista do Edge 550.', '{"tipo": "quiz_especialista_produto", "produto": "edge-550"}'),
  (v_brand_id, 'especialista-edge-850-garmin', 'Especialista Edge 850', 'Concedido ao passar no Quiz Especialista do Edge 850.', '{"tipo": "quiz_especialista_produto", "produto": "edge-850"}'),
  (v_brand_id, 'especialista-edge-1050-garmin', 'Especialista Edge 1050', 'Concedido ao passar no Quiz Especialista do Edge 1050.', '{"tipo": "quiz_especialista_produto", "produto": "edge-1050"}');

  -- ==========================================================================
  -- 9. Grafo de conhecimento — relacionados
  -- ==========================================================================
  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index) values
  (v_p_540, v_p_550, null, 'upgrade', 1),
  (v_p_540, v_p_840, null, 'variante_touchscreen', 2),
  (v_p_840, v_p_850, null, 'upgrade', 1),
  (v_p_840, v_p_540, null, 'variante_botao', 2),
  (v_p_1040, v_p_1050, null, 'upgrade', 1),
  (v_p_550, v_p_540, null, 'entrada', 1),
  (v_p_550, v_p_850, null, 'variante_touchscreen', 2),
  (v_p_850, v_p_840, null, 'entrada', 1),
  (v_p_850, v_p_550, null, 'variante_botao', 2),
  (v_p_1050, v_p_1040, null, 'entrada', 1);
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 080
-- ============================================================================
