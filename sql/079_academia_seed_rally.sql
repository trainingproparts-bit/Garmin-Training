-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 079: Academia de Produtos — Rally RK200,
-- RS200, RK210 e RS210 (linha Ciclismo)
-- ============================================================================
-- Pedido do usuário (2026-07-21): "faz tambem do rally RK200 E 210, RS200 E
-- 210 com comparativo com o rally 100 e anteriores" — 4 produtos completos.
-- Categoria nova "Ciclismo".
--
-- Estrutura da linha Rally (confirmada via pesquisa oficial, importante pra
-- não confundir gerações):
--   - Vector 3 (2018): predecessor histórico, só pedal de estrada
--     (Keo/SPD-SL), bateria substituível.
--   - Rally 100/200 (2021): sucessor do Vector 3, introduziu a opção
--     off-road SPD (XC). RK100/RS100/XC100 = sensor num lado só (potência
--     total). RK200/RS200/XC200 = dual-sensing (perna esquerda e direita
--     independentes). Bateria substituível, até 120h.
--   - Rally 110/210 (setembro/2025): geração atual, mesma divisão de
--     tiers (110 = single-sensing, 210 = dual-sensing), mas com bateria
--     RECARREGÁVEL (90h, carga rápida de 15min = 12h de uso), giroscópio
--     novo no sensor e Pedal IQ (calibração automática).
--
-- O pedido do usuário nomeia RK200/RS200 (2021) E RK210/RS210 (2025) como
-- produtos próprios — não é erro de digitação, são duas gerações reais
-- coexistindo no catálogo (a 210 é mais nova, mas a 200 continua sendo
-- referência de comparação relevante). "Rally 100 e anteriores" (Vector 3
-- e Rally 100) entram só como contexto nas seções, não como produtos
-- próprios — mesmo tratamento de antecessores usado no resto da Academia.
--
-- FONTES — só oficiais:
--   - Rally 100/200 (lançamento original): garmin.com/en-US/newsroom/
--     press-release/sports-fitness/garmin-introduces-the-rally-power-
--     meters-sleek-pedals-that-deliver-reliable-power-measurements-and-
--     advanced-cycling-dynamics/
--   - Rally 110/210 (setembro/2025): garmin.com/en-US/newsroom/press-
--     release/sports-fitness/garmin-rally-110-and-210-power-meters-for-
--     cyclists-are-rechargeable-and-easy-to-transfer/
--
-- Achado que vale registrar: a bateria do Rally 210 dura MENOS horas em
-- número absoluto que o 200 (90h contra 120h) — só que agora é recarregável
-- com carga rápida, então na prática o cliente nunca fica sem bateria de
-- verdade. Reportado com transparência, sem esconder o número menor.
-- ============================================================================

do $$
declare
  v_brand_id   uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_id     uuid;
  v_p_rk200    uuid;
  v_p_rs200    uuid;
  v_p_rk210    uuid;
  v_p_rs210    uuid;
  v_quiz       uuid;
  v_q          uuid;
begin
  insert into product_categories (brand_id, slug, name, icon, order_index)
  values (v_brand_id, 'ciclismo', 'Ciclismo', '🚴', 6)
  returning id into v_cat_id;

  -- ==========================================================================
  -- 1. Produtos
  -- ==========================================================================
  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index)
  values (v_brand_id, v_cat_id, 'rally-rk200', 'Rally RK200', '010-02388', 'Pedal medidor de potência dual-sensing, compatível com taquinho LOOK KEO', true, 1)
  returning id into v_p_rk200;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index)
  values (v_brand_id, v_cat_id, 'rally-rs200', 'Rally RS200', '010-02387', 'Pedal medidor de potência dual-sensing, compatível com taquinho SHIMANO SPD-SL', true, 2)
  returning id into v_p_rs200;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index)
  values (v_brand_id, v_cat_id, 'rally-rk210', 'Rally RK210', '010-02875', 'Pedal medidor de potência dual-sensing com bateria recarregável e giroscópio, compatível com LOOK KEO', true, 3)
  returning id into v_p_rk210;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index)
  values (v_brand_id, v_cat_id, 'rally-rs210', 'Rally RS210', '010-02876', 'Pedal medidor de potência dual-sensing com bateria recarregável e giroscópio, compatível com SHIMANO SPD-SL', true, 4)
  returning id into v_p_rs210;

  -- ==========================================================================
  -- 2. RALLY RK200 — seções completas
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_rk200, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Rally RK200</strong> é o pedal medidor de potência dual-sensing da Garmin compatível com taquinho LOOK KEO, sucessor do Vector 3 — lançado em 2021 junto com toda a linha Rally, que introduziu pela primeira vez a opção off-road (SPD) na família.</p><p><strong>Público-alvo:</strong> ciclista que já pedala com regularidade e quer dados de potência independentes de cada perna, transferíveis entre bicicletas.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Dual-sensing (perna a perna)", "text": "Mede potência esquerda e direita de forma independente.", "tags": []},
      {"title": "Precisão de ±1%", "text": "Mesma precisão de medidores profissionais.", "tags": []},
      {"title": "Bateria de até 120h", "text": "Bateria substituível — treina semanas ou meses sem trocar.", "tags": []},
      {"title": "Transferível entre bicicletas", "text": "O eixo sensor troca de corpo de pedal sem perder calibração.", "tags": []},
      {"title": "Dinâmica de pedalada avançada", "text": "Balanço esquerda/direita, tempo sentado vs em pé, fase de potência e mais.", "tags": []},
      {"title": "Resistência IPX7", "text": "Protegido contra chuva e respingos.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_rk200, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista competitivo", "text": "Quer dados de potência precisos pra treinar por zonas.", "tags": [{"label": "Performance", "color": "blue"}]},
      {"title": "Quem troca de bicicleta com frequência", "text": "Valoriza a transferência fácil do sensor entre corpos de pedal.", "tags": [{"label": "Praticidade", "color": "green"}]},
      {"title": "Usuário de taquinho LOOK KEO", "text": "Já usa esse sistema de encaixe e não quer trocar.", "tags": [{"label": "Compatibilidade", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente usa taquinho LOOK KEO e quer potência dual-sensing</li><li>Cliente prioriza bateria de longa duração (meses) sobre recarga rápida</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente usa taquinho SHIMANO SPD-SL → indicar o RS200 (ou RS210)</li><li>Cliente quer bateria recarregável e giroscópio pra maior responsividade → o RK210 é a geração mais nova</li></ul>"}
  ]}
  $j$),
  (v_p_rk200, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Dual-sensing", "html": "<p>Mede potência total, cadência e dinâmica de pedalada avançada com dados independentes de cada perna — diferente dos modelos single-sensing (Rally 100), que só dão potência total.</p>"},
      {"title": "Precisão de ±1%", "html": "<p>Mesmo padrão de precisão de medidores de potência profissionais.</p>"},
      {"title": "Bateria substituível de até 120h", "html": "<p>Permite treinar semanas ou meses sem precisar trocar a bateria.</p>"},
      {"title": "Eixo transferível", "html": "<p>O sensor de potência troca de corpo de pedal (estrada ou off-road) sem perder a calibração — dá pra usar o mesmo sensor em bicicletas diferentes.</p>"},
      {"title": "Compatível com Edge, Connect e apps de treino indoor", "html": "<p>Funciona com ciclocomputadores Edge, o app Garmin Connect e plataformas como Zwift, TrainerRoad e Tacx Training App.</p>"},
      {"title": "Resistência IPX7", "html": "<p>Protegido contra chuva e respingos.</p>"}
    ]}
  ]}
  $j$),
  (v_p_rk200, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "O RK200 substitui o <strong>Vector 3</strong> (2018) na linha de pedais medidores de potência da Garmin — não é uma sequência numérica direta (Vector → Rally é uma troca de nome de linha), mas é o produto que assumiu esse lugar no catálogo."},
    {"type": "accordion", "items": [
      {"title": "Opção off-road XC (recurso totalmente novo)", "html": "<p>O Vector 3 era só de estrada (compatível com LOOK Keo/SHIMANO SPD-SL). A família Rally introduziu o corpo de pedal XC (SHIMANO SPD, off-road) — o Vector 3 nunca teve essa opção.</p>"},
      {"title": "Corpos de pedal intercambiáveis", "html": "<p>Na Rally, o mesmo eixo sensor transfere entre corpos de pedal de estrada e off-road — o Vector 3 não tinha essa flexibilidade de trocar de sistema de encaixe no mesmo sensor.</p>"},
      {"title": "O que NÃO mudou (continua igual ao Vector 3)", "html": "<p>Medição dual-sensing, precisão de ±1%, bateria substituível e eixo transferível entre bicicletas (com o mesmo corpo de pedal) já existiam desde o Vector 3 — não são novidades do Rally.</p>"},
      {"title": "Rally 100: a versão mais simples da mesma geração", "html": "<p>Vale lembrar que o Rally 100 (single-sensing, só potência total) é um tier mais simples lançado junto com o RK200/RS200 em 2021 — não é um antecessor, é uma opção mais em conta da mesma geração.</p>"}
    ]}
  ]}
  $j$),
  (v_p_rk200, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo dual-sensing", "dialog": "Se você quer saber exatamente quanto cada perna contribui pra sua pedalada, o Rally RK200 mede isso separadamente — não é só potência total, é o balanço real entre as duas pernas.", "tip": "Bom argumento pra ciclista que já treina com plano estruturado ou quer identificar desequilíbrio muscular."},
      {"title": "Puxando a transferência entre bicicletas", "dialog": "Se você tem mais de uma bike, o sensor do Rally troca de corpo de pedal facilmente — você não precisa comprar um medidor pra cada bicicleta.", "tip": "Ótimo argumento pra quem tem bike de estrada e de indoor/rolo."},
      {"title": "Fechamento", "dialog": "Com o Rally RK200 você sai com potência dual-sensing precisa, compatível com taquinho LOOK KEO, e bateria que dura meses.", "tip": "Confirme o sistema de taquinho (Keo vs SPD-SL) antes de fechar — é a decisão mais importante."}
    ]}
  ]}
  $j$),
  (v_p_rk200, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não o RK210, que é mais novo?", "answer": "Se o cliente prioriza bateria de longa duração (meses, sem recarga) e não precisa do giroscópio pra esforços curtos, o RK200 continua sendo uma opção sólida e mais em conta."},
      {"question": "Qual a diferença pro Rally 100?", "answer": "O Rally 100 mede potência só de um lado (single-sensing) — o RK200 mede as duas pernas de forma independente, com dinâmica de pedalada completa."},
      {"question": "E pro Vector 3?", "answer": "O Vector 3 foi o predecessor direto da linha Rally — não tinha a opção off-road (SPD) que a família Rally introduziu. Hoje o Rally é a linha atual."}
    ]}
  ]}
  $j$),
  (v_p_rk200, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Ciclista treinando por zonas de potência", "text": "Precisa de dados precisos e consistentes pra estruturar o treino.", "tags": []},
      {"title": "Triatleta com bike de treino e de prova", "text": "Transfere o sensor entre as duas bicicletas conforme a necessidade.", "tags": []},
      {"title": "Ciclista com histórico de assimetria muscular", "text": "Usa o balanço esquerda/direita pra identificar e corrigir desequilíbrios.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_rk200, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "O RK200 tem bateria recarregável?", "html": "<p>Não — usa bateria substituível de até 120h. A bateria recarregável é exclusiva da geração RK210.</p>"},
      {"title": "Funciona com qualquer taquinho?", "html": "<p>Não — é compatível especificamente com LOOK KEO. Pra SHIMANO SPD-SL, o modelo correto é o RS200.</p>"},
      {"title": "Dá pra usar em mountain bike?", "html": "<p>O eixo sensor é transferível pro corpo de pedal off-road (XC), vendido separadamente.</p>"},
      {"title": "Qual a diferença real pro RK210?", "html": "<p>O RK210 tem bateria recarregável, giroscópio (mais responsivo em esforços curtos), Pedal IQ (calibração automática) e novo design em polímero de carbono — mas dura menos horas por carga (90h contra 120h do RK200).</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 3. RALLY RS200 — seções completas (mesma estrutura do RK200, taquinho SPD-SL)
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_rs200, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Rally RS200</strong> é o pedal medidor de potência dual-sensing da Garmin compatível com taquinho SHIMANO SPD-SL, sucessor do Vector 3 — mesma tecnologia do RK200, com sistema de encaixe diferente.</p><p><strong>Público-alvo:</strong> ciclista que já pedala com regularidade, usa taquinho SPD-SL e quer dados de potência independentes de cada perna.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Dual-sensing (perna a perna)", "text": "Mede potência esquerda e direita de forma independente.", "tags": []},
      {"title": "Precisão de ±1%", "text": "Mesma precisão de medidores profissionais.", "tags": []},
      {"title": "Bateria de até 120h", "text": "Bateria substituível — treina semanas ou meses sem trocar.", "tags": []},
      {"title": "Transferível entre bicicletas", "text": "O eixo sensor troca de corpo de pedal sem perder calibração.", "tags": []},
      {"title": "Dinâmica de pedalada avançada", "text": "Balanço esquerda/direita, tempo sentado vs em pé, fase de potência e mais.", "tags": []},
      {"title": "Compatível com SHIMANO SPD-SL", "text": "Sistema de taquinho mais comum entre ciclistas de estrada.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_rs200, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista competitivo", "text": "Quer dados de potência precisos pra treinar por zonas.", "tags": [{"label": "Performance", "color": "blue"}]},
      {"title": "Usuário de taquinho SHIMANO SPD-SL", "text": "Sistema de encaixe mais popular entre ciclistas de estrada.", "tags": [{"label": "Compatibilidade", "color": "gold"}]},
      {"title": "Quem troca de bicicleta com frequência", "text": "Valoriza a transferência fácil do sensor entre corpos de pedal.", "tags": [{"label": "Praticidade", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente usa taquinho SHIMANO SPD-SL e quer potência dual-sensing</li><li>Cliente prioriza bateria de longa duração (meses) sobre recarga rápida</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente usa taquinho LOOK KEO → indicar o RK200 (ou RK210)</li><li>Cliente quer bateria recarregável e giroscópio → o RS210 é a geração mais nova</li></ul>"}
  ]}
  $j$),
  (v_p_rs200, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Dual-sensing", "html": "<p>Mede potência total, cadência e dinâmica de pedalada avançada com dados independentes de cada perna.</p>"},
      {"title": "Precisão de ±1%", "html": "<p>Mesmo padrão de precisão de medidores de potência profissionais.</p>"},
      {"title": "Bateria substituível de até 120h", "html": "<p>Permite treinar semanas ou meses sem precisar trocar a bateria.</p>"},
      {"title": "Eixo transferível", "html": "<p>O sensor de potência troca de corpo de pedal sem perder a calibração.</p>"},
      {"title": "Compatível com Edge, Connect e apps de treino indoor", "html": "<p>Funciona com ciclocomputadores Edge, o app Garmin Connect e plataformas como Zwift, TrainerRoad e Tacx Training App.</p>"},
      {"title": "Resistência IPX7", "html": "<p>Protegido contra chuva e respingos.</p>"}
    ]}
  ]}
  $j$),
  (v_p_rs200, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "O RS200 substitui o <strong>Vector 3</strong> (2018) na linha de pedais medidores de potência da Garmin — não é uma sequência numérica direta (Vector → Rally é uma troca de nome de linha), mas é o produto que assumiu esse lugar no catálogo."},
    {"type": "accordion", "items": [
      {"title": "Opção off-road XC (recurso totalmente novo)", "html": "<p>O Vector 3 era só de estrada (compatível com LOOK Keo/SHIMANO SPD-SL). A família Rally introduziu o corpo de pedal XC (SHIMANO SPD, off-road) — o Vector 3 nunca teve essa opção.</p>"},
      {"title": "Corpos de pedal intercambiáveis", "html": "<p>Na Rally, o mesmo eixo sensor transfere entre corpos de pedal de estrada e off-road — o Vector 3 não tinha essa flexibilidade de trocar de sistema de encaixe no mesmo sensor.</p>"},
      {"title": "O que NÃO mudou (continua igual ao Vector 3)", "html": "<p>Medição dual-sensing, precisão de ±1%, bateria substituível e eixo transferível entre bicicletas (com o mesmo corpo de pedal) já existiam desde o Vector 3 — não são novidades do Rally.</p>"},
      {"title": "Rally 100: a versão mais simples da mesma geração", "html": "<p>Vale lembrar que o Rally 100 (single-sensing, só potência total) é um tier mais simples lançado junto com o RK200/RS200 em 2021 — não é um antecessor, é uma opção mais em conta da mesma geração.</p>"}
    ]}
  ]}
  $j$),
  (v_p_rs200, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo dual-sensing", "dialog": "Se você quer saber exatamente quanto cada perna contribui pra sua pedalada, o Rally RS200 mede isso separadamente — balanço real entre as duas pernas, não só potência total.", "tip": "Bom argumento pra ciclista que já treina com plano estruturado."},
      {"title": "Confirmando o sistema de taquinho", "dialog": "Esse modelo é compatível com SHIMANO SPD-SL — o sistema mais comum entre ciclistas de estrada. Se você já usa esse taquinho, não precisa trocar nada.", "tip": "Sempre confirme o sistema de taquinho do cliente antes de recomendar RK ou RS."},
      {"title": "Fechamento", "dialog": "Com o Rally RS200 você sai com potência dual-sensing precisa, compatível com SPD-SL, e bateria que dura meses.", "tip": "Pergunte se o cliente tem mais de uma bicicleta — o eixo transferível pode ser um argumento decisivo."}
    ]}
  ]}
  $j$),
  (v_p_rs200, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não o RS210, que é mais novo?", "answer": "Se o cliente prioriza bateria de longa duração (meses, sem recarga) e não precisa do giroscópio pra esforços curtos, o RS200 continua sendo uma opção sólida e mais em conta."},
      {"question": "Qual a diferença pro Rally 100?", "answer": "O Rally 100 mede potência só de um lado (single-sensing) — o RS200 mede as duas pernas de forma independente."},
      {"question": "Funciona com taquinho LOOK KEO?", "answer": "Não — pra Keo, o modelo correto é o RK200 (ou RK210)."}
    ]}
  ]}
  $j$),
  (v_p_rs200, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Ciclista treinando por zonas de potência", "text": "Precisa de dados precisos e consistentes pra estruturar o treino.", "tags": []},
      {"title": "Triatleta com bike de treino e de prova", "text": "Transfere o sensor entre as duas bicicletas conforme a necessidade.", "tags": []},
      {"title": "Cliente vindo de outra marca de pedal SPD-SL", "text": "Quer manter o mesmo taquinho e sapatilha, só adicionando o medidor de potência.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_rs200, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "O RS200 tem bateria recarregável?", "html": "<p>Não — usa bateria substituível de até 120h. A bateria recarregável é exclusiva da geração RS210.</p>"},
      {"title": "Funciona com qualquer taquinho?", "html": "<p>Não — é compatível especificamente com SHIMANO SPD-SL. Pra LOOK KEO, o modelo correto é o RK200.</p>"},
      {"title": "Qual a diferença real pro RS210?", "html": "<p>O RS210 tem bateria recarregável, giroscópio (mais responsivo em esforços curtos), Pedal IQ (calibração automática) e novo design em polímero de carbono — mas dura menos horas por carga (90h contra 120h do RS200).</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 4. RALLY RK210 — seções completas + novidades vs RK200
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_rk210, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Rally RK210</strong> é a geração mais nova do medidor de potência dual-sensing da Garmin compatível com LOOK KEO, lançada em 9 de setembro de 2025 — com bateria recarregável e giroscópio novo no sensor.</p><p><strong>Público-alvo:</strong> ciclista que quer o medidor de potência mais responsivo da Garmin, com calibração automática e recarga rápida.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Bateria recarregável", "text": "Até 90h de uso, com carga rápida de 15 minutos = 12h de pedalada.", "tags": []},
      {"title": "Giroscópio novo", "text": "Sensor mais responsivo em esforços curtos, com suporte a coroa oval.", "tags": []},
      {"title": "Pedal IQ", "text": "Alerta automático de recalibração por temperatura, tempo ou troca de bike.", "tags": []},
      {"title": "Novo design em polímero de carbono", "text": "Construção atualizada, mais leve (315g contra 326g do RK200).", "tags": []},
      {"title": "Precisão de ±1%", "text": "Mesmo padrão de precisão profissional.", "tags": []},
      {"title": "Modo Viagem", "text": "Coloca os pedais em modo de economia de bateria durante o transporte.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_rk210, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista que quer a tecnologia mais nova", "text": "Valoriza giroscópio, calibração automática e recarga rápida.", "tags": [{"label": "Tecnologia", "color": "blue"}]},
      {"title": "Quem pedala com coroa oval", "text": "O giroscópio novo traz suporte específico pra esse tipo de coroa.", "tags": [{"label": "Coroa oval", "color": "green"}]},
      {"title": "Usuário de LOOK KEO que já tem o RK200", "text": "Quer saber se vale o upgrade pra geração mais nova.", "tags": [{"label": "Upgrade", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer bateria recarregável (sem precisar trocar bateria manualmente)</li><li>Cliente faz esforços curtos/explosivos ou pedala com coroa oval — o giroscópio ajuda nesses casos</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente prioriza bateria de longa duração acima de tudo (meses sem recarga) → o RK200 dura mais horas por carga</li><li>Cliente usa taquinho SHIMANO SPD-SL → indicar o RS210</li></ul>"}
  ]}
  $j$),
  (v_p_rk210, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Bateria recarregável", "html": "<p>Até 90h de uso por carga, com carga rápida de 15 minutos rendendo 12h de pedalada. Modo Viagem economiza bateria durante o transporte.</p>"},
      {"title": "Giroscópio", "html": "<p>Eixo sensor redesenhado com giroscópio, entregando medição de potência mais instantânea — maior responsividade em esforços curtos e suporte a coroa oval.</p>"},
      {"title": "Pedal IQ", "html": "<p>Alerta o ciclista quando é hora de recalibrar, com base em mudança de temperatura, tempo decorrido e troca de bicicleta.</p>"},
      {"title": "Novo design em polímero de carbono", "html": "<p>Construção atualizada nos modelos de estrada (RK/RS) — mais leve que a geração anterior.</p>"},
      {"title": "Precisão de ±1%", "html": "<p>Mesmo padrão de precisão de medidores de potência profissionais.</p>"},
      {"title": "Compatível com Edge, Connect e apps de treino indoor", "html": "<p>Funciona com ciclocomputadores Edge, o app Garmin Connect e plataformas como Zwift, TrainerRoad e Tacx Training App.</p>"}
    ]}
  ]}
  $j$),
  (v_p_rk210, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Rally RK200</strong> (2021), o modelo direto que o RK210 substitui."},
    {"type": "accordion", "items": [
      {"title": "Bateria vira recarregável", "html": "<p>O RK200 usava bateria substituível. O RK210 recarrega — com carga rápida de 15 minutos rendendo 12h de pedalada, além do Modo Viagem pra economizar energia durante o transporte.</p>"},
      {"title": "Giroscópio novo", "html": "<p>Recurso totalmente novo — o RK200 não tinha giroscópio no eixo sensor. O RK210 ganha mais responsividade em esforços curtos e suporte a coroa oval.</p>"},
      {"title": "Pedal IQ (calibração automática)", "html": "<p>Alerta automático de recalibração — o RK200 não tinha esse sistema.</p>"},
      {"title": "Novo design em polímero de carbono", "html": "<p>Construção atualizada e mais leve: 315g contra 326g do RK200.</p>"},
      {"title": "Bateria dura menos horas por carga (atenção ao vender)", "html": "<p>Até 90h no RK210 contra até 120h no RK200 — só que agora é recarregável, então na prática o ciclista raramente fica sem bateria. Vale explicar essa troca com transparência: menos horas por carga, mas nunca precisa comprar bateria nova.</p>"},
      {"title": "O que NÃO mudou (continua igual ao RK200)", "html": "<p>Precisão de ±1%, medição dual-sensing (perna a perna), eixo transferível entre corpos de pedal, dinâmica de pedalada avançada e compatibilidade com Edge/Garmin Connect/apps de treino — tudo isso já vinha do RK200.</p>"}
    ]}
  ]}
  $j$),
  (v_p_rk210, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela bateria recarregável", "dialog": "Se você não quer se preocupar em comprar bateria nova pro seu medidor de potência, o Rally RK210 recarrega — 15 minutos de carga já rendem 12 horas de pedalada.", "tip": "Bom argumento pra quem já reclamou de precisar trocar bateria de pedal antes de uma prova."},
      {"title": "Puxando o giroscópio pra quem faz esforços curtos", "dialog": "O sensor novo tem giroscópio, o que deixa a medição de potência mais instantânea — faz diferença real em sprints e esforços curtos, além de dar suporte a coroa oval.", "tip": "Bom argumento pra ciclista de prova/competição, não tanto pra quem só pedala recreativo."},
      {"title": "Sendo transparente sobre a bateria", "dialog": "Uma coisa importante: por carga, a bateria dura menos horas que a geração anterior (90h contra 120h) — mas como recarrega rápido, isso raramente é um problema real no dia a dia.", "tip": "Melhor mencionar isso proativamente do que deixar o cliente descobrir depois."},
      {"title": "Fechamento", "dialog": "Com o Rally RK210 você sai com bateria recarregável, giroscópio mais responsivo, calibração automática e um design mais leve — a geração mais nova da linha Rally.", "tip": "Confirme o sistema de taquinho (Keo) antes de fechar."}
    ]}
  ]}
  $j$),
  (v_p_rk210, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Vale a pena trocar o RK200 pelo RK210?", "answer": "Vale se o cliente quer bateria recarregável, giroscópio (esforços curtos/coroa oval) ou calibração automática. Se ele prioriza bateria de longa duração sem recarga, o RK200 continua sendo uma opção válida."},
      {"question": "Por que a bateria dura menos horas?", "answer": "É uma troca real entre bateria substituível de longa duração e bateria recarregável mais prática — vale ser transparente sobre isso, mas na prática a recarga rápida (15min = 12h) resolve bem no dia a dia."},
      {"question": "Preciso de coroa oval pra aproveitar o giroscópio?", "answer": "Não — o giroscópio melhora a responsividade da medição pra qualquer ciclista, o suporte a coroa oval é um bônus adicional pra quem usa esse tipo de componente."}
    ]}
  ]}
  $j$),
  (v_p_rk210, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Ciclista de prova com sprints", "text": "O giroscópio melhora a responsividade da medição em esforços curtos e explosivos.", "tags": []},
      {"title": "Cliente cansado de trocar bateria de pedal", "text": "A recarga rápida resolve esse incômodo de vez.", "tags": []},
      {"title": "Ciclista com coroa oval", "text": "Suporte específico do giroscópio pra esse tipo de componente.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_rk210, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Quanto tempo demora pra carregar?", "html": "<p>Uma carga rápida de 15 minutos já rende até 12h de pedalada. Carga completa dura até 90h de uso.</p>"},
      {"title": "O que é o Modo Viagem?", "html": "<p>Coloca os pedais em economia de bateria durante o transporte, evitando descarga desnecessária.</p>"},
      {"title": "O que é o Pedal IQ?", "html": "<p>Sistema que alerta quando é hora de recalibrar, com base em mudança de temperatura, tempo decorrido desde a última calibração e troca de bicicleta.</p>"},
      {"title": "Funciona com qualquer taquinho?", "html": "<p>Não — é compatível especificamente com LOOK KEO. Pra SHIMANO SPD-SL, o modelo correto é o RS210.</p>"},
      {"title": "Qual a diferença real pro RK200?", "html": "<p>O RK210 adiciona bateria recarregável, giroscópio e Pedal IQ, mas dura menos horas por carga (90h contra 120h). Veja a aba \"O que há de novo?\" pra comparação completa.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 5. RALLY RS210 — seções completas + novidades vs RS200 (mesma estrutura do RK210)
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_rs210, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Rally RS210</strong> é a geração mais nova do medidor de potência dual-sensing da Garmin compatível com SHIMANO SPD-SL, lançada em 9 de setembro de 2025 — com bateria recarregável e giroscópio novo no sensor.</p><p><strong>Público-alvo:</strong> ciclista que quer o medidor de potência mais responsivo da Garmin, com calibração automática e recarga rápida.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Bateria recarregável", "text": "Até 90h de uso, com carga rápida de 15 minutos = 12h de pedalada.", "tags": []},
      {"title": "Giroscópio novo", "text": "Sensor mais responsivo em esforços curtos, com suporte a coroa oval.", "tags": []},
      {"title": "Pedal IQ", "text": "Alerta automático de recalibração por temperatura, tempo ou troca de bike.", "tags": []},
      {"title": "Novo design em polímero de carbono", "text": "Construção atualizada e mais leve.", "tags": []},
      {"title": "Precisão de ±1%", "text": "Mesmo padrão de precisão profissional.", "tags": []},
      {"title": "Compatível com SHIMANO SPD-SL", "text": "Sistema de taquinho mais comum entre ciclistas de estrada.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_rs210, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista que quer a tecnologia mais nova", "text": "Valoriza giroscópio, calibração automática e recarga rápida.", "tags": [{"label": "Tecnologia", "color": "blue"}]},
      {"title": "Usuário de SHIMANO SPD-SL que já tem o RS200", "text": "Quer saber se vale o upgrade pra geração mais nova.", "tags": [{"label": "Upgrade", "color": "gold"}]},
      {"title": "Quem pedala com coroa oval", "text": "O giroscópio novo traz suporte específico pra esse tipo de coroa.", "tags": [{"label": "Coroa oval", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer bateria recarregável (sem precisar trocar bateria manualmente)</li><li>Cliente faz esforços curtos/explosivos ou pedala com coroa oval</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente prioriza bateria de longa duração acima de tudo → o RS200 dura mais horas por carga</li><li>Cliente usa taquinho LOOK KEO → indicar o RK210</li></ul>"}
  ]}
  $j$),
  (v_p_rs210, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Bateria recarregável", "html": "<p>Até 90h de uso por carga, com carga rápida de 15 minutos rendendo 12h de pedalada. Modo Viagem economiza bateria durante o transporte.</p>"},
      {"title": "Giroscópio", "html": "<p>Eixo sensor redesenhado com giroscópio, entregando medição de potência mais instantânea — maior responsividade em esforços curtos e suporte a coroa oval.</p>"},
      {"title": "Pedal IQ", "html": "<p>Alerta o ciclista quando é hora de recalibrar, com base em mudança de temperatura, tempo decorrido e troca de bicicleta.</p>"},
      {"title": "Novo design em polímero de carbono", "html": "<p>Construção atualizada nos modelos de estrada — mais leve que a geração anterior.</p>"},
      {"title": "Precisão de ±1%", "html": "<p>Mesmo padrão de precisão de medidores de potência profissionais.</p>"},
      {"title": "Compatível com Edge, Connect e apps de treino indoor", "html": "<p>Funciona com ciclocomputadores Edge, o app Garmin Connect e plataformas como Zwift, TrainerRoad e Tacx Training App.</p>"}
    ]}
  ]}
  $j$),
  (v_p_rs210, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Rally RS200</strong> (2021), o modelo direto que o RS210 substitui."},
    {"type": "accordion", "items": [
      {"title": "Bateria vira recarregável", "html": "<p>O RS200 usava bateria substituível. O RS210 recarrega — com carga rápida de 15 minutos rendendo 12h de pedalada, além do Modo Viagem.</p>"},
      {"title": "Giroscópio novo", "html": "<p>Recurso totalmente novo — o RS200 não tinha giroscópio no eixo sensor. O RS210 ganha mais responsividade em esforços curtos e suporte a coroa oval.</p>"},
      {"title": "Pedal IQ (calibração automática)", "html": "<p>Alerta automático de recalibração — o RS200 não tinha esse sistema.</p>"},
      {"title": "Novo design em polímero de carbono", "html": "<p>Construção atualizada e mais leve.</p>"},
      {"title": "Bateria dura menos horas por carga (atenção ao vender)", "html": "<p>Até 90h no RS210 contra até 120h no RS200 — só que agora é recarregável. Vale explicar essa troca com transparência.</p>"},
      {"title": "O que NÃO mudou (continua igual ao RS200)", "html": "<p>Precisão de ±1%, medição dual-sensing, eixo transferível entre corpos de pedal, dinâmica de pedalada avançada e compatibilidade com Edge/Garmin Connect/apps de treino — tudo isso já vinha do RS200.</p>"}
    ]}
  ]}
  $j$),
  (v_p_rs210, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela bateria recarregável", "dialog": "Se você não quer se preocupar em comprar bateria nova pro seu medidor de potência, o Rally RS210 recarrega — 15 minutos de carga já rendem 12 horas de pedalada.", "tip": "Bom argumento pra quem já reclamou de precisar trocar bateria de pedal antes de uma prova."},
      {"title": "Puxando o giroscópio pra quem faz esforços curtos", "dialog": "O sensor novo tem giroscópio, deixando a medição de potência mais instantânea — faz diferença em sprints e esforços curtos, além de suporte a coroa oval.", "tip": "Bom argumento pra ciclista de prova/competição."},
      {"title": "Fechamento", "dialog": "Com o Rally RS210 você sai com bateria recarregável, giroscópio mais responsivo e calibração automática — a geração mais nova da linha Rally, compatível com SPD-SL.", "tip": "Confirme o sistema de taquinho antes de fechar."}
    ]}
  ]}
  $j$),
  (v_p_rs210, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Vale a pena trocar o RS200 pelo RS210?", "answer": "Vale se o cliente quer bateria recarregável, giroscópio ou calibração automática. Se prioriza bateria de longa duração sem recarga, o RS200 continua válido."},
      {"question": "Por que a bateria dura menos horas?", "answer": "Troca real entre bateria substituível de longa duração e recarregável mais prática — a recarga rápida (15min = 12h) resolve bem no dia a dia."},
      {"question": "Funciona com taquinho LOOK KEO?", "answer": "Não — pra Keo, o modelo correto é o RK210."}
    ]}
  ]}
  $j$),
  (v_p_rs210, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Ciclista de prova com sprints", "text": "O giroscópio melhora a responsividade da medição em esforços curtos.", "tags": []},
      {"title": "Cliente cansado de trocar bateria de pedal", "text": "A recarga rápida resolve esse incômodo de vez.", "tags": []},
      {"title": "Cliente vindo de outra marca, quer manter SPD-SL", "text": "Mantém o taquinho/sapatilha, só adiciona o medidor de potência.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_rs210, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Quanto tempo demora pra carregar?", "html": "<p>Uma carga rápida de 15 minutos já rende até 12h de pedalada. Carga completa dura até 90h de uso.</p>"},
      {"title": "Funciona com qualquer taquinho?", "html": "<p>Não — é compatível especificamente com SHIMANO SPD-SL. Pra LOOK KEO, o modelo correto é o RK210.</p>"},
      {"title": "Qual a diferença real pro RS200?", "html": "<p>O RS210 adiciona bateria recarregável, giroscópio e Pedal IQ, mas dura menos horas por carga (90h contra 120h). Veja a aba \"O que há de novo?\" pra comparação completa.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 6. Quiz Especialista — 4 produtos
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-rally-rk200', 'Quiz Especialista: Rally RK200', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Rally RK200 é compatível com qual taquinho?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'LOOK KEO', true, 1), (v_q, 'SHIMANO SPD-SL', false, 2), (v_q, 'SPD off-road', false, 3), (v_q, 'Qualquer um', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O RK200 tem bateria recarregável?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — bateria substituível de até 120h', true, 1), (v_q, 'Sim, recarregável', false, 2), (v_q, 'Sim, mas só a versão XC', false, 3), (v_q, 'Não tem bateria', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que é "dual-sensing"?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Medição independente de potência em cada perna', true, 1), (v_q, 'Dois sensores de GPS', false, 2), (v_q, 'Bateria dupla', false, 3), (v_q, 'Compatibilidade com 2 taquinhos', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-rally-rs200', 'Quiz Especialista: Rally RS200', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Rally RS200 é compatível com qual taquinho?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'SHIMANO SPD-SL', true, 1), (v_q, 'LOOK KEO', false, 2), (v_q, 'SPD off-road', false, 3), (v_q, 'Qualquer um', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual a precisão de medição do RS200?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '±1%', true, 1), (v_q, '±5%', false, 2), (v_q, '±10%', false, 3), (v_q, 'Não é informado', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O eixo sensor do RS200 é transferível entre bicicletas?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Sim, entre corpos de pedal diferentes', true, 1), (v_q, 'Não, é fixo', false, 2), (v_q, 'Só com kit especial vendido separadamente', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-rally-rk210', 'Quiz Especialista: Rally RK210', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que o giroscópio do RK210 melhora?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Responsividade em esforços curtos e suporte a coroa oval', true, 1), (v_q, 'Duração da bateria', false, 2), (v_q, 'Compatibilidade com taquinho', false, 3), (v_q, 'Peso do pedal', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Em relação ao RK200, a bateria do RK210...', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Dura menos horas por carga, mas agora é recarregável', true, 1), (v_q, 'Dura mais horas e é substituível', false, 2), (v_q, 'É idêntica', false, 3), (v_q, 'Não tem bateria', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que é o Pedal IQ?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Alerta automático de recalibração', true, 1), (v_q, 'Um app de treino', false, 2), (v_q, 'Um tipo de taquinho', false, 3), (v_q, 'Um sensor de cadência', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-rally-rs210', 'Quiz Especialista: Rally RS210', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Quanto tempo de carga rápida rende 12h de pedalada no RS210?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '15 minutos', true, 1), (v_q, '1 hora', false, 2), (v_q, '5 minutos', false, 3), (v_q, '3 horas', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O RS210 é compatível com qual taquinho?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'SHIMANO SPD-SL', true, 1), (v_q, 'LOOK KEO', false, 2), (v_q, 'SPD off-road', false, 3), (v_q, 'Qualquer um', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que é o Modo Viagem do RS210?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Economiza bateria durante o transporte', true, 1), (v_q, 'Modo de navegação GPS', false, 2), (v_q, 'Ativa o giroscópio', false, 3), (v_q, 'Desliga a calibração', false, 4);

  insert into product_quizzes (product_id, quiz_id)
  select id, (select id from quizzes where slug = 'quiz-especialista-rally-rk200') from products where slug = 'rally-rk200'
  union all
  select id, (select id from quizzes where slug = 'quiz-especialista-rally-rs200') from products where slug = 'rally-rs200'
  union all
  select id, (select id from quizzes where slug = 'quiz-especialista-rally-rk210') from products where slug = 'rally-rk210'
  union all
  select id, (select id from quizzes where slug = 'quiz-especialista-rally-rs210') from products where slug = 'rally-rs210';

  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-rally-rk200-garmin', 'Especialista Rally RK200', 'Concedido ao passar no Quiz Especialista do Rally RK200.', '{"tipo": "quiz_especialista_produto", "produto": "rally-rk200"}'),
  (v_brand_id, 'especialista-rally-rs200-garmin', 'Especialista Rally RS200', 'Concedido ao passar no Quiz Especialista do Rally RS200.', '{"tipo": "quiz_especialista_produto", "produto": "rally-rs200"}'),
  (v_brand_id, 'especialista-rally-rk210-garmin', 'Especialista Rally RK210', 'Concedido ao passar no Quiz Especialista do Rally RK210.', '{"tipo": "quiz_especialista_produto", "produto": "rally-rk210"}'),
  (v_brand_id, 'especialista-rally-rs210-garmin', 'Especialista Rally RS210', 'Concedido ao passar no Quiz Especialista do Rally RS210.', '{"tipo": "quiz_especialista_produto", "produto": "rally-rs210"}');

  -- ==========================================================================
  -- 7. Grafo de conhecimento — relacionados
  -- ==========================================================================
  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index) values
  (v_p_rk200, v_p_rk210, null, 'upgrade', 1),
  (v_p_rk200, v_p_rs200, null, 'variante_spd_sl', 2),
  (v_p_rs200, v_p_rs210, null, 'upgrade', 1),
  (v_p_rs200, v_p_rk200, null, 'variante_keo', 2),
  (v_p_rk210, v_p_rk200, null, 'entrada', 1),
  (v_p_rk210, v_p_rs210, null, 'variante_spd_sl', 2),
  (v_p_rs210, v_p_rs200, null, 'entrada', 1),
  (v_p_rs210, v_p_rk210, null, 'variante_keo', 2);
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 079
-- ============================================================================
