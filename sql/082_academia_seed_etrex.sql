-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 082: Academia de Produtos — eTrex SE e
-- eTrex Solar (nova categoria GPS de Mão)
-- ============================================================================
-- Pedido do usuário (2026-07-21): "da linha etrex com comparativo etrex 10
-- etrex 22x e 32x" — linha eTrex atual (SE e Solar) comparada aos modelos
-- antigos nomeados.
--
-- Estrutura da linha eTrex (confirmada via pesquisa oficial):
--   - eTrex 10 (2011, fundador da linha moderna): tela monocromática 2.2"
--     (128x160), só GPS (sem GLONASS confirmado), SEM bússola, SEM
--     altímetro, 25h de bateria.
--   - eTrex 22x/32x (linha intermediária): tela COLORIDA 2.2", GPS+GLONASS,
--     142g, 25h de bateria com 2 pilhas AA. O 32x adiciona altímetro
--     barométrico e bússola eletrônica de 3 eixos; o 22x usa bússola/
--     altímetro calculados por GPS (sem sensor dedicado).
--   - eTrex SE (2024, lançado junto com o GPSMAP 67): sucessor de entrada
--     da linha — tela monocromática transflectiva 2.2" (240x320), bússola
--     digital, suporte multi-GNSS, até 168h de bateria, conectividade sem
--     fio com o app Garmin Explore (clima e geocaching ao vivo).
--   - eTrex Solar (16/nov/2023): topo da linha atual — primeiro eTrex com
--     carregamento solar da Garmin, GPS multibanda (novo pra essa faixa de
--     preço), bússola digital, bateria "infinita" sob sol (75.000 lux) ou
--     até 1.800h em modo Expedição sem sol.
--
-- ACHADO IMPORTANTE que exige transparência (mesmo cuidado do aviso do
-- usuário sobre o Venu 4): o eTrex Solar NÃO tem altímetro barométrico —
-- confirmado via central de suporte oficial da Garmin ("The eTrex Solar
-- does not have a barometer"). Isso é uma REGRESSÃO de recurso em relação
-- ao eTrex 32x, que tinha altímetro barométrico dedicado. Reportado com
-- honestidade na aba "O que há de novo?", sem esconder.
--
-- Categoria nova: "GPS de Mão" (reaproveitada depois pro GPSMAP 65/67/69/89).
--
-- FONTES — só oficiais:
--   - eTrex Solar: garmin.com/en-US/newsroom/press-release/outdoor/never-
--     run-out-of-power-with-the-all-new-etrex-solar-from-garmin/
--   - eTrex SE: garmin.com/en-US/newsroom/press-release/outdoor/find-your-
--     path-with-new-handheld-gps-devices-from-garmin/
--   - eTrex Solar sem altímetro: support.garmin.com (central de suporte
--     oficial, pergunta sobre elevação/altímetro).
--   - eTrex 22x/32x, eTrex 10: páginas oficiais de manual/specs
--     (www8.garmin.com/manuals).
-- ============================================================================

do $$
declare
  v_brand_id uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_id   uuid;
  v_p_se     uuid;
  v_p_solar  uuid;
  v_quiz     uuid;
  v_q        uuid;
begin
  insert into product_categories (brand_id, slug, name, icon, order_index)
  values (v_brand_id, 'gps-de-mao', 'GPS de Mão', '🧭', 7)
  returning id into v_cat_id;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index) values
  (v_brand_id, v_cat_id, 'etrex-se', 'eTrex SE', '010-02734', 'GPS de mão de entrada, multi-GNSS, bateria de até 168h', true, 1),
  (v_brand_id, v_cat_id, 'etrex-solar', 'eTrex Solar', '010-02747', 'GPS de mão com carregamento solar e GPS multibanda, bateria praticamente infinita sob sol', true, 2);
  select id into v_p_se from products where slug = 'etrex-se';
  select id into v_p_solar from products where slug = 'etrex-solar';

  -- ==========================================================================
  -- ETREX SE
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_se, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>eTrex SE</strong> é o GPS de mão de entrada da Garmin, lançado em 2024 junto com o GPSMAP 67 — sucessor direto do eTrex 10, com tela monocromática legível sob sol forte e bateria de longuíssima duração.</p><p><strong>Público-alvo:</strong> trilheiro, caçador ou pescador que quer um GPS de mão simples, durável e com bateria que dura dias, sem gastar no topo de linha.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Bateria de até 168h", "text": "Mais de uma semana de uso contínuo com duas pilhas AA.", "tags": []},
      {"title": "Suporte multi-GNSS", "text": "Mais de um sistema de satélite pra rastreamento mais preciso.", "tags": []},
      {"title": "Bússola digital", "text": "Direção precisa mesmo parado — o eTrex 10 não tinha isso.", "tags": []},
      {"title": "Tela monocromática de alto contraste", "text": "Legível sob sol direto, 2.2\" (240x320).", "tags": []},
      {"title": "Geocaching e clima ao vivo", "text": "Via Bluetooth com o app Garmin Explore.", "tags": []},
      {"title": "Resistência IPX7", "text": "Protegido contra chuva e imersão acidental.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_se, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Trilheiro iniciante", "text": "Quer um GPS de mão simples e confiável, sem gastar muito.", "tags": [{"label": "Entrada", "color": "green"}]},
      {"title": "Caçador ou pescador", "text": "Precisa de bateria que dure a expedição inteira.", "tags": [{"label": "Bateria", "color": "blue"}]},
      {"title": "Geocacher casual", "text": "Usa a integração com Garmin Explore pra geocaching ao vivo.", "tags": [{"label": "Geocaching", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer o GPS de mão mais em conta da Garmin, com bateria de dias</li><li>Cliente não precisa de mapa colorido nem touchscreen</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer tela colorida ou touchscreen → indicar eTrex 22x/32x (linha anterior) ou GPSMAP</li><li>Cliente quer carregamento solar e GPS multibanda → indicar o eTrex Solar</li></ul>"}
  ]}
  $j$),
  (v_p_se, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Bateria de até 168h", "html": "<p>Com duas pilhas AA, dura mais de uma semana de uso contínuo — bem além das 25h do eTrex 10.</p>"},
      {"title": "Suporte multi-GNSS", "html": "<p>Rastreia mais de um sistema de satélite ao mesmo tempo, melhorando a precisão de posicionamento em relação ao GPS único do eTrex 10.</p>"},
      {"title": "Bússola digital", "html": "<p>Mostra direção precisa mesmo parado — recurso que o eTrex 10 não tinha.</p>"},
      {"title": "Conectividade sem fio com Garmin Explore", "html": "<p>Clima em tempo real e sincronização de geocaching ao vivo, via Bluetooth com o smartphone.</p>"},
      {"title": "Tela transflectiva de alto contraste", "html": "<p>2.2\" monocromática, 240x320 pixels, otimizada pra leitura sob sol forte.</p>"},
      {"title": "Resistência IPX7", "html": "<p>Protegido contra chuva forte e imersão acidental.</p>"}
    ]}
  ]}
  $j$),
  (v_p_se, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>eTrex 10</strong>, o modelo de entrada que o SE substitui."},
    {"type": "accordion", "items": [
      {"title": "Bússola digital (recurso totalmente novo)", "html": "<p>O eTrex 10 não tinha bússola — só direção calculada pelo movimento do GPS. O SE ganha bússola digital dedicada.</p>"},
      {"title": "Suporte multi-GNSS (recurso totalmente novo)", "html": "<p>O eTrex 10 usava só GPS. O SE rastreia mais de um sistema de satélite, com mais precisão.</p>"},
      {"title": "Bateria muito mais longa", "html": "<p>Até 168h no SE contra 25h no eTrex 10 — quase 7 vezes mais autonomia.</p>"},
      {"title": "Conectividade sem fio (recurso totalmente novo)", "html": "<p>O eTrex 10 não tinha Bluetooth nem integração com app — o SE sincroniza clima e geocaching ao vivo com o Garmin Explore.</p>"},
      {"title": "Resolução de tela maior", "html": "<p>240x320 pixels no SE contra 128x160 no eTrex 10, mesma diagonal de 2.2\".</p>"},
      {"title": "O que NÃO mudou (continua igual ao eTrex 10)", "html": "<p>Tela monocromática (não colorida), proposta de GPS de mão simples e resistente, e uso de pilhas AA já vinham do eTrex 10.</p>"}
    ]}
  ]}
  $j$),
  (v_p_se, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela bateria", "dialog": "O eTrex SE dura até 168 horas com duas pilhas AA comuns — mais de uma semana de uso contínuo, sem se preocupar em recarregar em trilha longa.", "tip": "Ótimo argumento pra caçador, pescador ou trilheiro de expedição longa."},
      {"title": "Puxando a bússola digital", "dialog": "Diferente do modelo antigo, o SE tem bússola digital de verdade — mostra sua direção mesmo parado, sem precisar estar em movimento pro GPS calcular.", "tip": "Bom argumento comparando com o eTrex 10 antigo, se o cliente já teve um."},
      {"title": "Fechamento", "dialog": "Com o eTrex SE você sai com bateria de mais de uma semana, bússola digital e suporte multi-GNSS — o GPS de mão mais em conta e confiável da Garmin.", "tip": "Se o cliente quiser tela colorida, pergunte se prefere o eTrex 22x/32x ou um GPSMAP."}
    ]}
  ]}
  $j$),
  (v_p_se, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "A tela não é colorida — isso é uma desvantagem?", "answer": "Pra quem só precisa de rota, waypoint e bússola, o preto-e-branco de alto contraste é até mais legível sob sol forte que muita tela colorida. Se o cliente quer mapa colorido detalhado, o caminho é um GPSMAP."},
      {"question": "Vale mais que o eTrex 10 antigo?", "answer": "Sim, muito — o SE adiciona bússola digital, suporte multi-GNSS, conectividade com app e bateria 7 vezes mais longa."},
      {"question": "Por que não o eTrex Solar?", "answer": "O Solar tem carregamento solar e GPS multibanda, custando mais. Se o cliente não precisa de autonomia infinita nem da precisão extra do multibanda, o SE já resolve muito bem."}
    ]}
  ]}
  $j$),
  (v_p_se, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Caçador em expedição de vários dias", "text": "A bateria de 168h elimina a preocupação com recarga.", "tags": []},
      {"title": "Trilheiro iniciante com orçamento limitado", "text": "Quer o GPS de mão mais em conta da Garmin.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_se, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tem altímetro barométrico?", "html": "<p>O material oficial não confirma altímetro barométrico dedicado no SE — a altitude é estimada via GPS.</p>"},
      {"title": "Qual a diferença pro eTrex Solar?", "html": "<p>O Solar tem carregamento solar e GPS multibanda; o SE não tem nenhum dos dois, mas custa menos.</p>"},
      {"title": "Precisa de smartphone pra funcionar?", "html": "<p>Não — funciona standalone. O smartphone só é necessário pra recursos extras (clima ao vivo, geocaching ao vivo) via Garmin Explore.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- ETREX SOLAR
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_solar, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>eTrex Solar</strong>, lançado em 16 de novembro de 2023, é o primeiro GPS de mão da Garmin com carregamento solar — topo da linha eTrex atual, com GPS multibanda pra maior precisão.</p><p><strong>Público-alvo:</strong> trilheiro ou expedicionário que passa muitos dias em campo sob luz do sol e não quer se preocupar em recarregar em nenhuma circunstância.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Carregamento solar", "text": "Bateria praticamente infinita sob sol contínuo de 75.000 lux.", "tags": []},
      {"title": "Até 1.800h em modo Expedição", "text": "Mesmo sem sol, semanas de autonomia.", "tags": []},
      {"title": "GPS multibanda", "text": "Maior precisão de posicionamento em terreno difícil.", "tags": []},
      {"title": "Bússola digital", "text": "Direção precisa mesmo parado.", "tags": []},
      {"title": "Tela de alto contraste 2.2\"", "text": "Legível sob sol direto.", "tags": []},
      {"title": "Resistência IPX7", "text": "Protegido contra chuva e imersão acidental.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_solar, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Expedicionário de longa duração", "text": "Passa semanas em campo, sem acesso a energia elétrica.", "tags": [{"label": "Expedição", "color": "blue"}]},
      {"title": "Trilheiro que pedala sob sol forte", "text": "Aproveita o Power Glass pra recarga contínua.", "tags": [{"label": "Solar", "color": "gold"}]},
      {"title": "Quem já teve o eTrex 32x", "text": "Quer saber se vale trocar pelo Solar (atenção: perde o altímetro barométrico).", "tags": [{"label": "Upgrade", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente passa dias/semanas em campo sob sol e quer nunca se preocupar com bateria</li><li>Cliente quer a maior precisão de GPS da linha eTrex (multibanda)</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente precisa de altímetro barométrico dedicado (ex: montanhismo com controle preciso de altitude) → o Solar NÃO tem, diferente do eTrex 32x antigo — nesse caso avaliar um GPSMAP</li></ul>"}
  ]}
  $j$),
  (v_p_solar, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Carregamento solar (Power Glass)", "html": "<p>Painel solar integrado à tela — em condições de sol contínuo (75.000 lux), a bateria não se esgota. É o primeiro eTrex da Garmin com esse recurso.</p>"},
      {"title": "Até 1.800h em modo Expedição sem sol", "html": "<p>Mesmo sem exposição solar, o modo Expedição estica a autonomia pra semanas de uso.</p>"},
      {"title": "GPS multibanda", "html": "<p>Capta mais de uma frequência de sinal de satélite, melhorando a precisão em terreno difícil — recurso que nenhum eTrex anterior (10, 22x, 32x) tinha.</p>"},
      {"title": "Bússola digital", "html": "<p>Direção precisa mesmo parado.</p>"},
      {"title": "Resistência IPX7", "html": "<p>Protegido contra chuva forte e imersão acidental.</p>"}
    ]}
  ]}
  $j$),
  (v_p_solar, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>eTrex 32x</strong>, o modelo de topo da geração anterior."},
    {"type": "accordion", "items": [
      {"title": "Carregamento solar (recurso totalmente novo)", "html": "<p>O 32x não tinha nenhuma forma de recarga em campo — o Solar introduz o Power Glass, permitindo autonomia praticamente infinita sob sol.</p>"},
      {"title": "GPS multibanda (recurso totalmente novo)", "html": "<p>O 32x usava GPS+GLONASS, sem captação de múltiplas frequências. O Solar traz multibanda, com precisão bem maior em terreno difícil.</p>"},
      {"title": "Bateria muito mais longa mesmo sem sol", "html": "<p>Até 1.800h em modo Expedição no Solar, bem acima das 25h do 32x (com pilhas AA).</p>"},
      {"title": "PERDE o altímetro barométrico (atenção ao vender)", "html": "<p>O eTrex 32x tinha altímetro barométrico dedicado e bússola eletrônica de 3 eixos. O eTrex Solar tem bússola digital, mas <strong>não tem altímetro barométrico</strong> — confirmado pela própria central de suporte da Garmin. É uma regressão real de recurso que vale mencionar com transparência pra quem depende de altitude precisa (ex: montanhismo técnico).</p>"},
      {"title": "Tela colorida some (atenção ao vender)", "html": "<p>O 32x tinha tela colorida; o eTrex Solar usa tela de alto contraste otimizada pra legibilidade sob sol, sem confirmação de cor no material oficial — funcionalmente prioriza legibilidade em vez de cor.</p>"}
    ]}
  ]}
  $j$),
  (v_p_solar, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela bateria solar", "dialog": "O eTrex Solar tem um painel solar integrado à tela — sob sol contínuo, a bateria simplesmente não acaba. Mesmo sem sol, dá pra usar até 1.800 horas em modo Expedição.", "tip": "Ótimo argumento pra expedição longa ou trilha de vários dias sem acesso a energia."},
      {"title": "Puxando o GPS multibanda", "dialog": "Ele também tem GPS multibanda, algo que nenhum eTrex anterior tinha — muito mais preciso em terreno difícil, como cânions ou mata fechada.", "tip": "Bom argumento técnico."},
      {"title": "Sendo transparente sobre o altímetro", "dialog": "Uma coisa importante pra quem já teve o eTrex 32x: o Solar não tem altímetro barométrico dedicado, diferente do 32x. Se o cliente depende de altitude precisa pra montanhismo técnico, vale considerar um GPSMAP.", "tip": "Melhor mencionar isso proativamente — é uma regressão real de recurso."},
      {"title": "Fechamento", "dialog": "Com o eTrex Solar você sai com bateria praticamente infinita sob sol e a maior precisão de GPS já vista na linha eTrex.", "tip": "Confirme se o cliente precisa de altímetro antes de fechar."}
    ]}
  ]}
  $j$),
  (v_p_solar, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que o Solar não tem altímetro se o 32x tinha?", "answer": "É uma troca de foco de engenharia — o Solar prioriza autonomia extrema e GPS multibanda. Se o cliente depende de altitude precisa, o caminho certo é um GPSMAP, não o eTrex Solar."},
      {"question": "\"Bateria infinita\" é exagero de marketing?", "answer": "É condicional: só é praticamente infinita sob exposição solar contínua de 75.000 lux (dia claro, sem sombra). Em condições variáveis, ainda assim entrega até 1.800h em modo Expedição, o que já é excepcional."},
      {"question": "Vale mais que o eTrex SE?", "answer": "Sim, se o cliente precisa de carregamento solar e GPS multibanda. Se não precisa desses dois recursos específicos, o SE já entrega ótima autonomia por um preço menor."}
    ]}
  ]}
  $j$),
  (v_p_solar, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Expedicionário de várias semanas", "text": "Nunca precisa se preocupar com bateria sob sol contínuo.", "tags": []},
      {"title": "Trilheiro em terreno difícil (cânion, mata fechada)", "text": "Aproveita a precisão extra do GPS multibanda.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_solar, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tem altímetro barométrico?", "html": "<p>Não — confirmado pela central de suporte oficial da Garmin. A altitude é exibida durante a navegação, mas sem um barômetro dedicado.</p>"},
      {"title": "A bateria realmente nunca acaba?", "html": "<p>Sob exposição solar contínua de 75.000 lux, sim, na prática não acaba. Sem sol, o modo Expedição ainda entrega até 1.800h.</p>"},
      {"title": "Qual a diferença pro eTrex SE?", "html": "<p>O Solar adiciona carregamento solar e GPS multibanda — o SE não tem nenhum dos dois, mas custa menos.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- Quiz Especialista — 2 produtos
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-etrex-se', 'Quiz Especialista: eTrex SE', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Quantas horas de bateria o eTrex SE oferece?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 168h', true, 1), (v_q, 'Até 25h', false, 2), (v_q, 'Até 500h', false, 3), (v_q, 'Até 10h', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O eTrex 10 (predecessor) tinha bússola digital?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — recurso novo do SE', true, 1), (v_q, 'Sim, já tinha', false, 2), (v_q, 'Só em modo mapa', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O eTrex SE tem carregamento solar?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — solar é exclusivo do eTrex Solar', true, 1), (v_q, 'Sim, tem', false, 2), (v_q, 'Só em edição especial', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-etrex-solar', 'Quiz Especialista: eTrex Solar', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O eTrex Solar tem altímetro barométrico?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — mesmo o eTrex 32x antigo tendo, o Solar não tem', true, 1), (v_q, 'Sim, tem', false, 2), (v_q, 'Só em modo Expedição', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que torna a bateria do eTrex Solar quase infinita?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Carregamento solar via Power Glass sob sol contínuo', true, 1), (v_q, 'Uma bateria maior', false, 2), (v_q, 'Modo avião permanente', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O eTrex 32x (predecessor) tinha GPS multibanda?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — só GPS+GLONASS, sem multibanda', true, 1), (v_q, 'Sim, já tinha', false, 2), (v_q, 'Não tinha GPS', false, 3), (v_q, 'Não sei', false, 4);

  insert into product_quizzes (product_id, quiz_id)
  select id, (select id from quizzes where slug = 'quiz-especialista-etrex-se') from products where slug = 'etrex-se'
  union all
  select id, (select id from quizzes where slug = 'quiz-especialista-etrex-solar') from products where slug = 'etrex-solar';

  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-etrex-se-garmin', 'Especialista eTrex SE', 'Concedido ao passar no Quiz Especialista do eTrex SE.', '{"tipo": "quiz_especialista_produto", "produto": "etrex-se"}'),
  (v_brand_id, 'especialista-etrex-solar-garmin', 'Especialista eTrex Solar', 'Concedido ao passar no Quiz Especialista do eTrex Solar.', '{"tipo": "quiz_especialista_produto", "produto": "etrex-solar"}');

  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index) values
  (v_p_se, v_p_solar, null, 'upgrade', 1),
  (v_p_solar, v_p_se, null, 'entrada', 1);
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 082
-- ============================================================================
