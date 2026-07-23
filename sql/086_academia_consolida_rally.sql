-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 086: Consolida a linha Rally em 3 produtos
-- (100, 200 e 210), com RK/RS explicados DENTRO de cada um
-- ============================================================================
-- Pedido do usuário (2026-07-22): "o rally vc deixou um pra cada, mas rally
-- rs e rk é o mesmo, então é pra deixar só 3 (200, 210 e 100) e dentro
-- especificar as diferenças entre RS e RK" — correção da migração 079, que
-- tinha criado 4 produtos separados (RK200/RS200/RK210/RS210). RK e RS são
-- o MESMO pedal, só variando o sistema de taquinho (LOOK KEO vs SHIMANO
-- SPD-SL) — não justificam produtos à parte, então cada produto agora cobre
-- as duas variantes de taquinho na mesma página. O Rally 100 (single-sensing)
-- também vira produto próprio pela primeira vez, atendendo o pedido original
-- de "comparativo com o rally 100".
--
-- Os 4 produtos antigos (rally-rk200/rs200/rk210/rs210) e todo o conteúdo
-- ligado a eles (review_catalog, quizzes, badges) já foram removidos do banco
-- antes desta migração.
-- ============================================================================

do $$
declare
  v_brand_id uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_id   uuid;
  v_p_100    uuid;
  v_p_200    uuid;
  v_p_210    uuid;
  v_quiz     uuid;
  v_q        uuid;
begin
  select id into v_cat_id from product_categories where slug = 'ciclismo' and brand_id = v_brand_id;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index) values
  (v_brand_id, v_cat_id, 'rally-100', 'Rally 100', '010-02388-100', 'Pedal medidor de potência single-sensing, disponível pra taquinho LOOK KEO (RK100) ou SHIMANO SPD-SL (RS100)', true, 1),
  (v_brand_id, v_cat_id, 'rally-200', 'Rally 200', '010-02388-200', 'Pedal medidor de potência dual-sensing, disponível pra taquinho LOOK KEO (RK200) ou SHIMANO SPD-SL (RS200)', true, 2),
  (v_brand_id, v_cat_id, 'rally-210', 'Rally 210', '010-02875-210', 'Pedal medidor de potência dual-sensing com bateria recarregável e giroscópio, disponível pra LOOK KEO (RK210) ou SHIMANO SPD-SL (RS210)', true, 3);
  select id into v_p_100 from products where slug = 'rally-100';
  select id into v_p_200 from products where slug = 'rally-200';
  select id into v_p_210 from products where slug = 'rally-210';

  -- ==========================================================================
  -- RALLY 100 (single-sensing) — RK100 e RS100
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_100, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Rally 100</strong> é o pedal medidor de potência de entrada da Garmin, single-sensing (mede potência total, sem separar esquerda/direita), sucessor do Vector 3S — lançado em 2021 junto com toda a linha Rally.</p><p><strong>Disponível em dois taquinhos</strong>: <strong>RK100</strong> (compatível com LOOK KEO) e <strong>RS100</strong> (compatível com SHIMANO SPD-SL). A diferença entre os dois é só o sistema de encaixe do pedal; o resto (sensor, bateria, precisão) é idêntico.</p><p><strong>Público-alvo:</strong> ciclista que quer potência total confiável pra treinar por zonas, sem precisar do balanço perna a perna do Rally 200.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Medição single-sensing", "text": "Potência total da pedalada, sem separar as duas pernas.", "tags": []},
      {"title": "Precisão de ±1%", "text": "Mesma precisão de medidores profissionais.", "tags": []},
      {"title": "Bateria de até 120h", "text": "Bateria substituível — treina semanas ou meses sem trocar.", "tags": []},
      {"title": "Transferível entre bicicletas", "text": "O eixo sensor troca de corpo de pedal sem perder calibração.", "tags": []},
      {"title": "Dois taquinhos disponíveis", "text": "RK100 (LOOK KEO) ou RS100 (SHIMANO SPD-SL) — mesmo sensor, encaixe diferente.", "tags": []},
      {"title": "Resistência IPX7", "text": "Protegido contra chuva e respingos.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_100, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista que quer potência total, sem custo extra", "text": "Não precisa do balanço esquerda/direita, só quer treinar por zonas de potência.", "tags": [{"label": "Custo-benefício", "color": "gold"}]},
      {"title": "Quem troca de bicicleta com frequência", "text": "Valoriza a transferência fácil do sensor entre corpos de pedal.", "tags": [{"label": "Praticidade", "color": "green"}]},
      {"title": "Cliente iniciando com medição de potência", "text": "Primeiro medidor, sem precisar do pacote completo de dinâmica de pedalada.", "tags": [{"label": "Entrada", "color": "blue"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer potência total confiável por um preço mais em conta que o Rally 200</li><li>Cliente não precisa de balanço esquerda/direita nem dinâmica de pedalada avançada</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer balanço esquerda/direita, fase de potência ou tempo sentado vs em pé → indicar o Rally 200 (ou 210)</li></ul>"}
  ]}
  $j$),
  (v_p_100, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Medição single-sensing", "html": "<p>Mede a potência total aplicada na pedalada, sem separar entre perna esquerda e direita — diferente do Rally 200/210, que fazem essa separação (dual-sensing).</p>"},
      {"title": "Precisão de ±1%", "html": "<p>Mesmo padrão de precisão de medidores de potência profissionais.</p>"},
      {"title": "Bateria substituível de até 120h", "html": "<p>Permite treinar semanas ou meses sem precisar trocar a bateria.</p>"},
      {"title": "Eixo transferível", "html": "<p>O sensor de potência troca de corpo de pedal sem perder a calibração — dá pra usar o mesmo sensor em bicicletas diferentes.</p>"},
      {"title": "RK100 vs RS100: só o taquinho muda", "html": "<p>O RK100 é compatível com LOOK KEO. O RS100 é compatível com SHIMANO SPD-SL. Fora o sistema de encaixe do pedal, sensor, bateria e precisão são idênticos nos dois.</p>"},
      {"title": "Compatível com Edge, Connect e apps de treino indoor", "html": "<p>Funciona com ciclocomputadores Edge, o app Garmin Connect e plataformas como Zwift, TrainerRoad e Tacx Training App.</p>"},
      {"title": "Resistência IPX7", "html": "<p>Protegido contra chuva e respingos.</p>"}
    ]}
  ]}
  $j$),
  (v_p_100, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo custo-benefício", "dialog": "Se você quer treinar por potência sem pagar pelo balanço perna a perna, o Rally 100 mede a potência total com a mesma precisão de ±1% do topo de linha.", "tip": "Bom argumento pra ciclista que está começando a treinar com dados de potência."},
      {"title": "Confirmando o taquinho", "dialog": "Ele vem em duas versões: RK100 pra quem usa LOOK KEO, e RS100 pra quem usa SHIMANO SPD-SL. O sensor é o mesmo, só muda o encaixe do pedal.", "tip": "Confirme o sistema de taquinho do cliente antes de fechar — é a decisão mais importante."},
      {"title": "Fechamento", "dialog": "Com o Rally 100 você sai com potência total precisa, eixo transferível entre bicicletas, e o taquinho certo pra sua sapatilha.", "tip": "Se o cliente perguntar sobre balanço esquerda/direita, apresente o Rally 200."}
    ]}
  ]}
  $j$),
  (v_p_100, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Qual a diferença pro Rally 200?", "answer": "O Rally 200 mede potência de cada perna separadamente (dual-sensing) e traz dinâmica de pedalada avançada. O 100 mede só a potência total — mais simples e mais em conta."},
      {"question": "RK ou RS, como escolher?", "answer": "Depende só do taquinho da sapatilha do cliente: LOOK KEO usa o RK100, SHIMANO SPD-SL usa o RS100. O resto do produto é idêntico."},
      {"question": "Vale a pena esperar o upgrade pro Rally 200/210?", "answer": "Só se o cliente realmente for usar o balanço esquerda/direita pra treino técnico. Pra quem só quer acompanhar potência total, o 100 já resolve muito bem."}
    ]}
  ]}
  $j$),
  (v_p_100, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Ciclista iniciando o treino por potência", "text": "Quer o primeiro medidor, sem precisar do pacote completo de dados.", "tags": []},
      {"title": "Cliente com orçamento mais ajustado", "text": "Prioriza precisão de potência total por um preço mais em conta.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_100, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "O Rally 100 mede cada perna separadamente?", "html": "<p>Não — mede só a potência total da pedalada (single-sensing). Pra balanço esquerda/direita, o modelo certo é o Rally 200 ou 210.</p>"},
      {"title": "Tem versão pra taquinho off-road (SPD)?", "html": "<p>A linha Rally tem variante off-road (XC) em alguns tiers — confirme a disponibilidade específica antes de prometer ao cliente.</p>"},
      {"title": "Qual a diferença entre RK100 e RS100?", "html": "<p>Só o sistema de taquinho: RK100 é LOOK KEO, RS100 é SHIMANO SPD-SL. Sensor, bateria e precisão são os mesmos.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- RALLY 200 (dual-sensing) — RK200 e RS200 + novidades vs Vector 3
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_200, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Rally 200</strong> é o pedal medidor de potência dual-sensing da Garmin, sucessor do Vector 3 — lançado em 2021 junto com toda a linha Rally, que introduziu pela primeira vez a opção off-road (SPD) na família.</p><p><strong>Disponível em dois taquinhos</strong>: <strong>RK200</strong> (compatível com LOOK KEO) e <strong>RS200</strong> (compatível com SHIMANO SPD-SL). A diferença entre os dois é só o sistema de encaixe do pedal; sensor, precisão, bateria e dinâmica de pedalada são idênticos.</p><p><strong>Público-alvo:</strong> ciclista que já pedala com regularidade e quer dados de potência independentes de cada perna, transferíveis entre bicicletas.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Dual-sensing (perna a perna)", "text": "Mede potência esquerda e direita de forma independente.", "tags": []},
      {"title": "Precisão de ±1%", "text": "Mesma precisão de medidores profissionais.", "tags": []},
      {"title": "Bateria de até 120h", "text": "Bateria substituível — treina semanas ou meses sem trocar.", "tags": []},
      {"title": "Transferível entre bicicletas", "text": "O eixo sensor troca de corpo de pedal sem perder calibração.", "tags": []},
      {"title": "Dinâmica de pedalada avançada", "text": "Balanço esquerda/direita, tempo sentado vs em pé, fase de potência e mais.", "tags": []},
      {"title": "Dois taquinhos disponíveis", "text": "RK200 (LOOK KEO) ou RS200 (SHIMANO SPD-SL) — mesmo sensor, encaixe diferente.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_200, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista competitivo", "text": "Quer dados de potência precisos pra treinar por zonas.", "tags": [{"label": "Performance", "color": "blue"}]},
      {"title": "Quem troca de bicicleta com frequência", "text": "Valoriza a transferência fácil do sensor entre corpos de pedal.", "tags": [{"label": "Praticidade", "color": "green"}]},
      {"title": "Ciclista com histórico de assimetria muscular", "text": "Usa o balanço esquerda/direita pra identificar e corrigir desequilíbrios.", "tags": [{"label": "Técnico", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer potência dual-sensing e dinâmica de pedalada avançada</li><li>Cliente prioriza bateria de longa duração (meses) sobre recarga rápida</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente só precisa de potência total, sem balanço → o Rally 100 já resolve por menos</li><li>Cliente quer bateria recarregável e giroscópio pra maior responsividade → o Rally 210 é a geração mais nova</li></ul>"}
  ]}
  $j$),
  (v_p_200, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Dual-sensing", "html": "<p>Mede potência total, cadência e dinâmica de pedalada avançada com dados independentes de cada perna — diferente do Rally 100 (single-sensing), que só dá potência total.</p>"},
      {"title": "Precisão de ±1%", "html": "<p>Mesmo padrão de precisão de medidores de potência profissionais.</p>"},
      {"title": "Bateria substituível de até 120h", "html": "<p>Permite treinar semanas ou meses sem precisar trocar a bateria.</p>"},
      {"title": "Eixo transferível", "html": "<p>O sensor de potência troca de corpo de pedal (estrada ou off-road) sem perder a calibração — dá pra usar o mesmo sensor em bicicletas diferentes.</p>"},
      {"title": "RK200 vs RS200: só o taquinho muda", "html": "<p>O RK200 é compatível com LOOK KEO. O RS200 é compatível com SHIMANO SPD-SL. Fora o sistema de encaixe do pedal, sensor, dinâmica de pedalada, bateria e precisão são idênticos nos dois.</p>"},
      {"title": "Compatível com Edge, Connect e apps de treino indoor", "html": "<p>Funciona com ciclocomputadores Edge, o app Garmin Connect e plataformas como Zwift, TrainerRoad e Tacx Training App.</p>"},
      {"title": "Resistência IPX7", "html": "<p>Protegido contra chuva e respingos.</p>"}
    ]}
  ]}
  $j$),
  (v_p_200, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "O Rally 200 substitui o <strong>Vector 3</strong> (2018) na linha de pedais medidores de potência da Garmin — não é uma sequência numérica direta (Vector → Rally é uma troca de nome de linha), mas é o produto que assumiu esse lugar no catálogo."},
    {"type": "accordion", "items": [
      {"title": "Opção off-road XC (recurso totalmente novo)", "html": "<p>O Vector 3 era só de estrada (compatível com LOOK Keo/SHIMANO SPD-SL). A família Rally introduziu o corpo de pedal XC (SHIMANO SPD, off-road) — o Vector 3 nunca teve essa opção.</p>"},
      {"title": "Corpos de pedal intercambiáveis", "html": "<p>Na Rally, o mesmo eixo sensor transfere entre corpos de pedal de estrada e off-road — o Vector 3 não tinha essa flexibilidade de trocar de sistema de encaixe no mesmo sensor.</p>"},
      {"title": "O que NÃO mudou (continua igual ao Vector 3)", "html": "<p>Medição dual-sensing, precisão de ±1%, bateria substituível e eixo transferível entre bicicletas (com o mesmo corpo de pedal) já existiam desde o Vector 3 — não são novidades do Rally.</p>"},
      {"title": "Rally 100: a versão mais simples da mesma geração", "html": "<p>O Rally 100 (single-sensing, só potência total) é um tier mais simples lançado junto com o Rally 200 em 2021 — não é um antecessor, é uma opção mais em conta da mesma geração.</p>"}
    ]}
  ]}
  $j$),
  (v_p_200, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo dual-sensing", "dialog": "Se você quer saber exatamente quanto cada perna contribui pra sua pedalada, o Rally 200 mede isso separadamente — não é só potência total, é o balanço real entre as duas pernas.", "tip": "Bom argumento pra ciclista que já treina com plano estruturado ou quer identificar desequilíbrio muscular."},
      {"title": "Confirmando o taquinho", "dialog": "Ele vem em duas versões: RK200 pra quem usa LOOK KEO, e RS200 pra quem usa SHIMANO SPD-SL. O sensor e a dinâmica de pedalada são idênticos nos dois, só muda o encaixe do pedal.", "tip": "Sempre confirme o sistema de taquinho do cliente antes de fechar."},
      {"title": "Puxando a transferência entre bicicletas", "dialog": "Se você tem mais de uma bike, o sensor do Rally troca de corpo de pedal facilmente — você não precisa comprar um medidor pra cada bicicleta.", "tip": "Ótimo argumento pra quem tem bike de estrada e de indoor/rolo."},
      {"title": "Fechamento", "dialog": "Com o Rally 200 você sai com potência dual-sensing precisa, no taquinho certo pra sua sapatilha, e bateria que dura meses.", "tip": "Confirme o sistema de taquinho antes de fechar — é a decisão mais importante."}
    ]}
  ]}
  $j$),
  (v_p_200, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "RK ou RS, como escolher?", "answer": "Depende só do taquinho da sapatilha do cliente: LOOK KEO usa o RK200, SHIMANO SPD-SL usa o RS200. Sensor, precisão e dinâmica de pedalada são idênticos nos dois."},
      {"question": "Por que não o Rally 210, que é mais novo?", "answer": "Se o cliente prioriza bateria de longa duração (meses, sem recarga) e não precisa do giroscópio pra esforços curtos, o Rally 200 continua sendo uma opção sólida e mais em conta."},
      {"question": "Qual a diferença pro Rally 100?", "answer": "O Rally 100 mede potência só de um lado (single-sensing) — o 200 mede as duas pernas de forma independente, com dinâmica de pedalada completa."},
      {"question": "E pro Vector 3?", "answer": "O Vector 3 foi o predecessor direto da linha Rally — não tinha a opção off-road (SPD) que a família Rally introduziu. Hoje o Rally é a linha atual."}
    ]}
  ]}
  $j$),
  (v_p_200, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Ciclista treinando por zonas de potência", "text": "Precisa de dados precisos e consistentes pra estruturar o treino.", "tags": []},
      {"title": "Triatleta com bike de treino e de prova", "text": "Transfere o sensor entre as duas bicicletas conforme a necessidade.", "tags": []},
      {"title": "Ciclista com histórico de assimetria muscular", "text": "Usa o balanço esquerda/direita pra identificar e corrigir desequilíbrios.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_200, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "O Rally 200 tem bateria recarregável?", "html": "<p>Não — usa bateria substituível de até 120h. A bateria recarregável é exclusiva da geração Rally 210.</p>"},
      {"title": "Qual a diferença entre RK200 e RS200?", "html": "<p>Só o sistema de taquinho: RK200 é LOOK KEO, RS200 é SHIMANO SPD-SL. Sensor, precisão e dinâmica de pedalada são os mesmos.</p>"},
      {"title": "Dá pra usar em mountain bike?", "html": "<p>O eixo sensor é transferível pro corpo de pedal off-road (XC), vendido separadamente.</p>"},
      {"title": "Qual a diferença real pro Rally 210?", "html": "<p>O 210 tem bateria recarregável, giroscópio (mais responsivo em esforços curtos), Pedal IQ (calibração automática) e novo design em polímero de carbono — mas dura menos horas por carga (90h contra 120h do 200).</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- RALLY 210 (dual-sensing, recarregável) — RK210 e RS210 + novidades vs 200
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_210, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Rally 210</strong> é a geração mais nova do medidor de potência dual-sensing da Garmin, lançada em 9 de setembro de 2025 — com bateria recarregável e giroscópio novo no sensor.</p><p><strong>Disponível em dois taquinhos</strong>: <strong>RK210</strong> (compatível com LOOK KEO) e <strong>RS210</strong> (compatível com SHIMANO SPD-SL). A diferença entre os dois é só o sistema de encaixe do pedal; sensor, bateria, giroscópio e precisão são idênticos.</p><p><strong>Público-alvo:</strong> ciclista que quer o medidor de potência mais responsivo da Garmin, com calibração automática e recarga rápida.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Bateria recarregável", "text": "Até 90h de uso, com carga rápida de 15 minutos = 12h de pedalada.", "tags": []},
      {"title": "Giroscópio novo", "text": "Sensor mais responsivo em esforços curtos, com suporte a coroa oval.", "tags": []},
      {"title": "Pedal IQ", "text": "Alerta automático de recalibração por temperatura, tempo ou troca de bike.", "tags": []},
      {"title": "Novo design em polímero de carbono", "text": "Construção atualizada, mais leve (315g contra 326g do Rally 200).", "tags": []},
      {"title": "Precisão de ±1%", "text": "Mesmo padrão de precisão profissional.", "tags": []},
      {"title": "Dois taquinhos disponíveis", "text": "RK210 (LOOK KEO) ou RS210 (SHIMANO SPD-SL) — mesmo sensor, encaixe diferente.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_210, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista que quer a tecnologia mais nova", "text": "Valoriza giroscópio, calibração automática e recarga rápida.", "tags": [{"label": "Tecnologia", "color": "blue"}]},
      {"title": "Quem pedala com coroa oval", "text": "O giroscópio novo traz suporte específico pra esse tipo de coroa.", "tags": [{"label": "Coroa oval", "color": "green"}]},
      {"title": "Usuário do Rally 200 avaliando upgrade", "text": "Quer saber se vale o upgrade pra geração mais nova.", "tags": [{"label": "Upgrade", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer bateria recarregável (sem precisar trocar bateria manualmente)</li><li>Cliente faz esforços curtos/explosivos ou pedala com coroa oval — o giroscópio ajuda nesses casos</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente prioriza bateria de longa duração acima de tudo (meses sem recarga) → o Rally 200 dura mais horas por carga</li></ul>"}
  ]}
  $j$),
  (v_p_210, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Bateria recarregável", "html": "<p>Até 90h de uso por carga, com carga rápida de 15 minutos rendendo 12h de pedalada. Modo Viagem economiza bateria durante o transporte.</p>"},
      {"title": "Giroscópio", "html": "<p>Eixo sensor redesenhado com giroscópio, entregando medição de potência mais instantânea — maior responsividade em esforços curtos e suporte a coroa oval.</p>"},
      {"title": "Pedal IQ", "html": "<p>Alerta o ciclista quando é hora de recalibrar, com base em mudança de temperatura, tempo decorrido e troca de bicicleta.</p>"},
      {"title": "Novo design em polímero de carbono", "html": "<p>Construção atualizada nos modelos de estrada — mais leve que a geração anterior.</p>"},
      {"title": "Precisão de ±1%", "html": "<p>Mesmo padrão de precisão de medidores de potência profissionais.</p>"},
      {"title": "RK210 vs RS210: só o taquinho muda", "html": "<p>O RK210 é compatível com LOOK KEO. O RS210 é compatível com SHIMANO SPD-SL. Fora o sistema de encaixe do pedal, sensor, giroscópio, bateria e precisão são idênticos nos dois.</p>"},
      {"title": "Compatível com Edge, Connect e apps de treino indoor", "html": "<p>Funciona com ciclocomputadores Edge, o app Garmin Connect e plataformas como Zwift, TrainerRoad e Tacx Training App.</p>"}
    ]}
  ]}
  $j$),
  (v_p_210, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Rally 200</strong> (2021), o modelo direto que o 210 substitui."},
    {"type": "accordion", "items": [
      {"title": "Bateria vira recarregável", "html": "<p>O Rally 200 usava bateria substituível. O 210 recarrega — com carga rápida de 15 minutos rendendo 12h de pedalada, além do Modo Viagem pra economizar energia durante o transporte.</p>"},
      {"title": "Giroscópio novo", "html": "<p>Recurso totalmente novo — o Rally 200 não tinha giroscópio no eixo sensor. O 210 ganha mais responsividade em esforços curtos e suporte a coroa oval.</p>"},
      {"title": "Pedal IQ (calibração automática)", "html": "<p>Alerta automático de recalibração — o Rally 200 não tinha esse sistema.</p>"},
      {"title": "Novo design em polímero de carbono", "html": "<p>Construção atualizada e mais leve: 315g contra 326g do Rally 200 (RK).</p>"},
      {"title": "Bateria dura menos horas por carga (atenção ao vender)", "html": "<p>Até 90h no 210 contra até 120h no 200 — só que agora é recarregável, então na prática o ciclista raramente fica sem bateria. Vale explicar essa troca com transparência: menos horas por carga, mas nunca precisa comprar bateria nova.</p>"},
      {"title": "O que NÃO mudou (continua igual ao Rally 200)", "html": "<p>Precisão de ±1%, medição dual-sensing (perna a perna), eixo transferível entre corpos de pedal, dinâmica de pedalada avançada e compatibilidade com Edge/Garmin Connect/apps de treino — tudo isso já vinha do Rally 200.</p>"}
    ]}
  ]}
  $j$),
  (v_p_210, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela bateria recarregável", "dialog": "Se você não quer se preocupar em comprar bateria nova pro seu medidor de potência, o Rally 210 recarrega — 15 minutos de carga já rendem 12 horas de pedalada.", "tip": "Bom argumento pra quem já reclamou de precisar trocar bateria de pedal antes de uma prova."},
      {"title": "Puxando o giroscópio pra quem faz esforços curtos", "dialog": "O sensor novo tem giroscópio, o que deixa a medição de potência mais instantânea — faz diferença real em sprints e esforços curtos, além de dar suporte a coroa oval.", "tip": "Bom argumento pra ciclista de prova/competição, não tanto pra quem só pedala recreativo."},
      {"title": "Confirmando o taquinho", "dialog": "Ele vem em duas versões: RK210 pra LOOK KEO, RS210 pra SHIMANO SPD-SL. Fora o encaixe do pedal, é o mesmo sensor e giroscópio nos dois.", "tip": "Sempre confirme o sistema de taquinho do cliente antes de fechar."},
      {"title": "Sendo transparente sobre a bateria", "dialog": "Uma coisa importante: por carga, a bateria dura menos horas que a geração anterior (90h contra 120h) — mas como recarrega rápido, isso raramente é um problema real no dia a dia.", "tip": "Melhor mencionar isso proativamente do que deixar o cliente descobrir depois."},
      {"title": "Fechamento", "dialog": "Com o Rally 210 você sai com bateria recarregável, giroscópio mais responsivo e calibração automática — a geração mais nova da linha Rally, no taquinho certo pra sua sapatilha.", "tip": "Confirme o sistema de taquinho antes de fechar."}
    ]}
  ]}
  $j$),
  (v_p_210, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "RK ou RS, como escolher?", "answer": "Depende só do taquinho da sapatilha do cliente: LOOK KEO usa o RK210, SHIMANO SPD-SL usa o RS210. Sensor, giroscópio e precisão são idênticos nos dois."},
      {"question": "Vale a pena trocar o Rally 200 pelo 210?", "answer": "Vale se o cliente quer bateria recarregável, giroscópio (esforços curtos/coroa oval) ou calibração automática. Se ele prioriza bateria de longa duração sem recarga, o Rally 200 continua sendo uma opção válida."},
      {"question": "Por que a bateria dura menos horas?", "answer": "É uma troca real entre bateria substituível de longa duração e bateria recarregável mais prática — vale ser transparente sobre isso, mas na prática a recarga rápida (15min = 12h) resolve bem no dia a dia."},
      {"question": "Preciso de coroa oval pra aproveitar o giroscópio?", "answer": "Não — o giroscópio melhora a responsividade da medição pra qualquer ciclista, o suporte a coroa oval é um bônus adicional pra quem usa esse tipo de componente."}
    ]}
  ]}
  $j$),
  (v_p_210, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Ciclista de prova com sprints", "text": "O giroscópio melhora a responsividade da medição em esforços curtos e explosivos.", "tags": []},
      {"title": "Cliente cansado de trocar bateria de pedal", "text": "A recarga rápida resolve esse incômodo de vez.", "tags": []},
      {"title": "Ciclista com coroa oval", "text": "Suporte específico do giroscópio pra esse tipo de componente.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_210, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Quanto tempo demora pra carregar?", "html": "<p>Uma carga rápida de 15 minutos já rende até 12h de pedalada. Carga completa dura até 90h de uso.</p>"},
      {"title": "Qual a diferença entre RK210 e RS210?", "html": "<p>Só o sistema de taquinho: RK210 é LOOK KEO, RS210 é SHIMANO SPD-SL. Sensor, giroscópio e precisão são os mesmos.</p>"},
      {"title": "O que é o Modo Viagem?", "html": "<p>Coloca os pedais em economia de bateria durante o transporte, evitando descarga desnecessária.</p>"},
      {"title": "O que é o Pedal IQ?", "html": "<p>Sistema que alerta quando é hora de recalibrar, com base em mudança de temperatura, tempo decorrido desde a última calibração e troca de bicicleta.</p>"},
      {"title": "Qual a diferença real pro Rally 200?", "html": "<p>O 210 adiciona bateria recarregável, giroscópio e Pedal IQ, mas dura menos horas por carga (90h contra 120h). Veja a aba \"O que há de novo?\" pra comparação completa.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- Quiz Especialista — 3 produtos
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-rally-100', 'Quiz Especialista: Rally 100', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Rally 100 mede potência de cada perna separadamente?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — mede só a potência total (single-sensing)', true, 1), (v_q, 'Sim, dual-sensing', false, 2), (v_q, 'Só no RK100', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual a diferença entre o RK100 e o RS100?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Só o taquinho: RK é LOOK KEO, RS é SHIMANO SPD-SL', true, 1), (v_q, 'O RK100 é dual-sensing e o RS100 não', false, 2), (v_q, 'São produtos completamente diferentes', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual a bateria do Rally 100?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Substituível, até 120h', true, 1), (v_q, 'Recarregável, até 90h', false, 2), (v_q, 'Não tem bateria', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-rally-200', 'Quiz Especialista: Rally 200', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que é "dual-sensing" no Rally 200?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Medição independente de potência em cada perna', true, 1), (v_q, 'Dois sensores de GPS', false, 2), (v_q, 'Bateria dupla', false, 3), (v_q, 'Compatibilidade com 2 taquinhos ao mesmo tempo', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual a diferença entre o RK200 e o RS200?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Só o taquinho: RK é LOOK KEO, RS é SHIMANO SPD-SL', true, 1), (v_q, 'O RK200 tem giroscópio e o RS200 não', false, 2), (v_q, 'São gerações diferentes', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Rally 200 tem bateria recarregável?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — bateria substituível de até 120h', true, 1), (v_q, 'Sim, recarregável', false, 2), (v_q, 'Não tem bateria', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-rally-210', 'Quiz Especialista: Rally 210', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que o giroscópio do Rally 210 melhora?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Responsividade em esforços curtos e suporte a coroa oval', true, 1), (v_q, 'Duração da bateria', false, 2), (v_q, 'Compatibilidade com taquinho', false, 3), (v_q, 'Peso do pedal', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual a diferença entre o RK210 e o RS210?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Só o taquinho: RK é LOOK KEO, RS é SHIMANO SPD-SL', true, 1), (v_q, 'O RK210 é recarregável e o RS210 não', false, 2), (v_q, 'São produtos de gerações diferentes', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Em relação ao Rally 200, a bateria do 210...', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Dura menos horas por carga, mas agora é recarregável', true, 1), (v_q, 'Dura mais horas e é substituível', false, 2), (v_q, 'É idêntica', false, 3), (v_q, 'Não tem bateria', false, 4);

  insert into product_quizzes (product_id, quiz_id)
  select id, (select id from quizzes where slug = 'quiz-especialista-rally-100') from products where slug = 'rally-100'
  union all
  select id, (select id from quizzes where slug = 'quiz-especialista-rally-200') from products where slug = 'rally-200'
  union all
  select id, (select id from quizzes where slug = 'quiz-especialista-rally-210') from products where slug = 'rally-210';

  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-rally-100-garmin', 'Especialista Rally 100', 'Concedido ao passar no Quiz Especialista do Rally 100.', '{"tipo": "quiz_especialista_produto", "produto": "rally-100"}'),
  (v_brand_id, 'especialista-rally-200-garmin', 'Especialista Rally 200', 'Concedido ao passar no Quiz Especialista do Rally 200.', '{"tipo": "quiz_especialista_produto", "produto": "rally-200"}'),
  (v_brand_id, 'especialista-rally-210-garmin', 'Especialista Rally 210', 'Concedido ao passar no Quiz Especialista do Rally 210.', '{"tipo": "quiz_especialista_produto", "produto": "rally-210"}');

  -- ==========================================================================
  -- Grafo de conhecimento — relacionados
  -- ==========================================================================
  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index) values
  (v_p_100, v_p_200, null, 'upgrade', 1),
  (v_p_200, v_p_100, null, 'entrada', 1),
  (v_p_200, v_p_210, null, 'upgrade', 2),
  (v_p_210, v_p_200, null, 'entrada', 1);
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 086
-- ============================================================================
