-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 081: Academia de Produtos — Descent X30
-- (categoria Mergulho)
-- ============================================================================
-- Pedido do usuário (2026-07-21): "inclui o descent x30" — sem pedir
-- comparativo específico (diferente do Edge/Rally/eTrex, onde o usuário
-- nomeou o antecessor explicitamente).
--
-- IMPORTANTE — por que este produto NÃO recebe aba "O que há de novo?":
-- pesquisa oficial confirmou que o Descent X30 (25/set/2025) NÃO é sucessor
-- do Descent X50i (19/nov/2024) — são dois produtos da MESMA geração,
-- lançados ~10 meses um do outro, dentro da sub-linha "formato grande" de
-- computadores de mergulho da Garmin (o X50i foi o primeiro dessa sub-linha,
-- o X30 chegou depois como opção mais em conta, com menos recursos). Não é
-- uma relação de antecessor/sucessor — é uma relação de tier, igual ao caso
-- do Instinct E vs Instinct 3 (variante do mesmo lançamento, não substituto).
-- Por isso o X30 entra como produto próprio, sem seção "novidades", seguindo
-- o mesmo precedente já usado pro Striker 4 (modelo sem antecessor numerado).
--
-- Diferenças reais entre X50i (mais caro) e X30 (mais em conta), registradas
-- aqui só como contexto de posicionamento, não como comparação formal:
--   - X50i: tela touch de 3", 20 ATM, sonar SubWave (comunicação entre
--     mergulhadores), lanterna de backup integrada, GPS com 4.000+ pontos
--     de mergulho pré-carregados, US$ 1.499,99, 253g.
--   - X30: tela de 2,4" SEM touch (só botão), 10 ATM, sem sonar SubWave,
--     sem lanterna de backup, GPS de superfície + bússola digital de 3
--     eixos, suporte a trimix, carcaça em plástico reciclado do oceano,
--     US$ 749,99.
--
-- FONTE — só oficial: garmin.com/en-US/newsroom/press-release/outdoor/
-- see-essential-dive-data-at-a-glance-with-the-descent-x30-large-format-
-- dive-computer-from-garmin/
-- ============================================================================

do $$
declare
  v_brand_id uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_id   uuid;
  v_p_id     uuid;
  v_quiz     uuid;
  v_q        uuid;
begin
  select id into v_cat_id from product_categories where slug = 'mergulho' and brand_id = v_brand_id;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index)
  values (v_brand_id, v_cat_id, 'descent-x30', 'Descent X30', '010-02897', 'Computador de mergulho de tela grande, botão apenas, com bússola digital e suporte a trimix', true, 5)
  returning id into v_p_id;

  insert into product_sections (product_id, section_type, payload) values
  (v_p_id, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Descent X30</strong> é um computador de mergulho de tela grande da Garmin, lançado em 25 de setembro de 2025 — a opção mais em conta da sub-linha \"formato grande\" que a Garmin abriu com o Descent X50i (2024), com tela de 2,4\" controlada só por botão.</p><p><strong>Público-alvo:</strong> mergulhador que quer tela grande e fácil de ler debaixo d'água, incluindo suporte a trimix, sem pagar pelo touchscreen e sonar do X50i.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela de 2,4\" só por botão", "text": "Botões metálicos à prova de vazamento, fáceis de usar com luva.", "tags": []},
      {"title": "Resistência a 10 ATM", "text": "Classificação de profundidade adequada pra mergulho recreativo e técnico moderado.", "tags": []},
      {"title": "NDL Aware™", "text": "Mostra em tempo real como mudanças de profundidade afetam o limite de não-descompressão.", "tags": []},
      {"title": "GPS de superfície + bússola de 3 eixos", "text": "Navega até o ponto de mergulho e se orienta debaixo d'água.", "tags": []},
      {"title": "Suporte a múltiplos gases, incluindo trimix", "text": "Atende mergulhador que ultrapassa os limites recreativos.", "tags": []},
      {"title": "Bateria de até 30h", "text": "Autonomia робusta pra viagens de mergulho de vários dias.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_id, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Mergulhador recreativo frequente", "text": "Quer tela grande e fácil de ler, sem pagar pelo touchscreen premium.", "tags": [{"label": "Recreativo", "color": "blue"}]},
      {"title": "Mergulhador técnico iniciante", "text": "Usa suporte a trimix e múltiplos gases pra mergulhos além do limite recreativo.", "tags": [{"label": "Técnico", "color": "gold"}]},
      {"title": "Quem prefere botão a touchscreen embaixo d'água", "text": "Botão metálico funciona com luva grossa e não sofre com água na tela.", "tags": [{"label": "Praticidade", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer tela grande e legível debaixo d'água por um preço mais em conta que o X50i</li><li>Cliente mergulha com luva grossa (água fria) e prefere botão a touchscreen</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer se comunicar com outro mergulhador debaixo d'água (sonar SubWave) ou lanterna de backup integrada → só o Descent X50i tem esses recursos</li><li>Cliente mergulha a mais de 10 ATM de profundidade planejada com regularidade → avaliar o X50i (20 ATM)</li></ul>"}
  ]}
  $j$),
  (v_p_id, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tela de 2,4\" com botões à prova de vazamento", "html": "<p>Botões metálicos fáceis de operar mesmo com luva de mergulho — sem depender de touchscreen, que pode ser menos confiável debaixo d'água.</p>"},
      {"title": "Modo tela invertida (flip-screen)", "html": "<p>Permite orientar os botões pra cima ou pra baixo, conforme a preferência do mergulhador.</p>"},
      {"title": "NDL Aware™", "html": "<p>Métricas de profundidade em tempo real que mostram como uma mudança de profundidade afeta o limite de não-descompressão (NDL) — ajuda a planejar o mergulho com mais segurança.</p>"},
      {"title": "Suporte a múltiplos gases, incluindo trimix", "html": "<p>Atende mergulhador técnico que ultrapassa os limites recreativos de profundidade.</p>"},
      {"title": "GPS de superfície + bússola digital de 3 eixos", "html": "<p>Navega até o ponto de mergulho na superfície e se orienta debaixo d'água com a bússola.</p>"},
      {"title": "Gráfico de profundidade dinâmico e plano de subida projetado", "html": "<p>Mostra em tempo real a curva de profundidade e as paradas de segurança/descompressão projetadas.</p>"},
      {"title": "Carcaça em plástico reciclado do oceano", "html": "<p>Corpo e bezel feitos 100% de plástico reciclado de origem oceânica.</p>"},
      {"title": "Compatível com inReach para SOS", "html": "<p>Funciona com comunicadores satelitais inReach pra SOS de emergência (requer plano satelital ativo e case de mergulho específico).</p>"}
    ]}
  ]}
  $j$),
  (v_p_id, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "O X30 NÃO é sucessor do <strong>Descent X50i</strong> — são dois produtos da mesma sub-linha \"formato grande\", lançados com ~10 meses de diferença (X50i em nov/2024, X30 em set/2025), em tiers de preço diferentes. Aqui está o comparativo entre os dois, pra ajudar a posicionar a venda dentro da linha Descent."},
    {"type": "accordion", "items": [
      {"title": "Tela: touch de 3\" (X50i) vs 2,4\" só botão (X30)", "html": "<p>O X50i tem touchscreen de 3\". O X30 usa tela de 2,4\" com botões metálicos à prova de vazamento, sem touch — mais simples, mais em conta.</p>"},
      {"title": "Profundidade: 20 ATM (X50i) vs 10 ATM (X30)", "html": "<p>O X50i aguenta o dobro de profundidade classificada — relevante pra mergulho técnico mais avançado.</p>"},
      {"title": "Sonar SubWave: só no X50i", "html": "<p>Comunicação entre mergulhadores (mensagem, pressão do tanque, profundidade, distância) — recurso exclusivo do X50i, o X30 não tem.</p>"},
      {"title": "Lanterna de backup: só no X50i", "html": "<p>Lanterna integrada de emergência — o X30 não tem.</p>"},
      {"title": "NDL Aware e suporte a trimix: presentes nos dois", "html": "<p>Não é diferencial entre os dois modelos — ambos têm essas funções de mergulho técnico.</p>"},
      {"title": "Preço: quase metade no X30", "html": "<p>US$ 749,99 no X30 contra US$ 1.499,99 no X50i — a diferença de preço reflete diretamente os recursos ausentes (touch, sonar, lanterna, profundidade extra), não uma limitação de geração.</p>"}
    ]}
  ]}
  $j$),
  (v_p_id, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela tela grande e legibilidade", "dialog": "O Descent X30 tem uma tela de 2,4\", bem maior que um relógio comum de mergulho, e os botões são metálicos e à prova de vazamento — fáceis de operar mesmo com luva grossa de água fria.", "tip": "Bom argumento pra mergulhador que já reclamou de tela pequena ou touchscreen difícil de usar embaixo d'água."},
      {"title": "Puxando o NDL Aware e o trimix", "dialog": "Ele mostra em tempo real como cada metro de profundidade impacta seu limite de não-descompressão, e já vem com suporte a trimix pra quem mergulha além do limite recreativo.", "tip": "Bom argumento pra mergulhador técnico ou que está evoluindo pra certificações mais avançadas."},
      {"title": "Posicionando frente ao X50i", "dialog": "Se você não precisa se comunicar com outro mergulhador debaixo d'água ou de lanterna de backup integrada, o X30 entrega a mesma proposta de tela grande por um preço bem mais em conta que o X50i.", "tip": "Só compare com o X50i se o cliente perguntar — não é uma comparação de geração, é uma escolha de tier."},
      {"title": "Fechamento", "dialog": "Com o Descent X30 você sai com tela grande, resistência a 10 ATM, suporte a trimix e até 30h de bateria — um computador de mergulho completo com preço mais acessível.", "tip": "Confirme a profundidade típica de mergulho do cliente antes de fechar."}
    ]}
  ]}
  $j$),
  (v_p_id, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não o Descent X50i, que é mais completo?", "answer": "O X50i tem touchscreen, sonar SubWave (comunicação entre mergulhadores), lanterna de backup e resistência a 20 ATM — mas custa praticamente o dobro. Pra mergulhador recreativo ou técnico moderado que não precisa desses recursos extras, o X30 é uma opção completa e mais em conta."},
      {"question": "10 ATM é suficiente?", "answer": "Sim pra mergulho recreativo e boa parte do mergulho técnico moderado. Se o cliente planeja mergulhos regulares além desse limite, vale considerar o X50i (20 ATM)."},
      {"question": "O X30 substitui o Mk3i (relógio) pra mergulho?", "answer": "São propostas diferentes — o Mk3i é um smartwatch multiesporte que também mergulha, o X30 é um computador de mergulho dedicado, com tela maior e recursos específicos de mergulho técnico (trimix, NDL Aware). Pra quem mergulha com frequência e quer o melhor computador de mergulho, o X30 é mais indicado; pra quem quer um relógio do dia a dia que também mergulha, o Mk3i continua sendo a opção."}
    ]}
  ]}
  $j$),
  (v_p_id, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Mergulhador recreativo frequente", "text": "Quer tela grande e fácil de ler, com boa autonomia de bateria pra viagem de vários dias.", "tags": []},
      {"title": "Mergulhador técnico iniciante", "text": "Usa NDL Aware e suporte a trimix pra mergulhos mais avançados.", "tags": []},
      {"title": "Cliente com orçamento limitado que quer tela grande", "text": "Prefere o X30 ao X50i pelo custo-benefício.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_id, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "O X30 tem touchscreen?", "html": "<p>Não — é controlado só por botões metálicos à prova de vazamento. Touchscreen é exclusivo do X50i.</p>"},
      {"title": "Tem sonar pra comunicação entre mergulhadores?", "html": "<p>Não — o sonar SubWave é exclusivo do Descent X50i.</p>"},
      {"title": "Qual a resistência de profundidade?", "html": "<p>10 ATM.</p>"},
      {"title": "Funciona com inReach pra emergência?", "html": "<p>Sim, é compatível com comunicadores satelitais inReach pra SOS — requer plano satelital ativo e um case de mergulho específico.</p>"},
      {"title": "O X30 é sucessor do X50i?", "html": "<p>Não — são produtos da mesma geração, lançados poucos meses um do outro. O X50i é a opção premium (touchscreen, sonar, lanterna), o X30 é a opção mais em conta da mesma sub-linha de tela grande.</p>"}
    ]}
  ]}
  $j$);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-descent-x30', 'Quiz Especialista: Descent X30', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Descent X30 tem touchscreen?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — só botões metálicos à prova de vazamento', true, 1), (v_q, 'Sim, touchscreen completo', false, 2), (v_q, 'Só em modo mapa', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual a resistência de profundidade do X30?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '10 ATM', true, 1), (v_q, '20 ATM', false, 2), (v_q, '5 ATM', false, 3), (v_q, '50 ATM', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O X30 é sucessor do X50i?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — são produtos da mesma geração, tiers diferentes', true, 1), (v_q, 'Sim, sucessor direto', false, 2), (v_q, 'O X50i que sucede o X30', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que é o NDL Aware?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Métrica que mostra como a profundidade afeta o limite de não-descompressão', true, 1), (v_q, 'Um tipo de gás de mergulho', false, 2), (v_q, 'Um modo de navegação GPS', false, 3), (v_q, 'Um alerta de bateria fraca', false, 4);

  insert into product_quizzes (product_id, quiz_id) values (v_p_id, v_quiz);

  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-descent-x30-garmin', 'Especialista Descent X30', 'Concedido ao passar no Quiz Especialista do Descent X30.', '{"tipo": "quiz_especialista_produto", "produto": "descent-x30"}');
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 081
-- ============================================================================
