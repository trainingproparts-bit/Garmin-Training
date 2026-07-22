-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 076: Fenix 8, Descent Mk3i e Descent G2
-- ============================================================================
-- Pedido do usuário (2026-07-21): "cria agora da linha fenix e e fenix 8, do
-- mesmo jeito. e do mk3i que o pessoal tem muita duvida, e pra comparativo
-- pode usar o mk2, e tambem do descent g2 (comparativo descent g1)" — 3
-- produtos completos (7 seções + aba "O que há de novo?" + quiz especialista
-- + badge), mesmo padrão de profundidade já usado nos Forerunners/Venu.
-- Predecessores (Fenix 7, Descent Mk2, Descent G1) só entram como
-- referência de pesquisa pra sustentar a aba de novidades — não viram
-- produtos próprios (mesmo tratamento do Forerunner 265/965/45/245/Venu 2).
--
-- Duas categorias novas: "Aventura & Multiesporte" (Fenix 8) e "Mergulho"
-- (Descent Mk3i + Descent G2) — linhas de produto bem diferentes da
-- Forerunner/Venu já existentes.
--
-- Sem preços em US$ (padrão já adotado nesta sessão).
--
-- FONTES — só oficiais (garmin.com/newsroom, manuais do proprietário):
--   - Fenix 8 (27/08/2024): garmin.com/en-US/newsroom/press-release/outdoor/
--     garmin-adds-amoled-displays-to-fenix-8-series-its-most-capable-
--     lineup-of-premium-multisport-gps-smartwatches-with-something-for-
--     everyone/
--   - Fenix 7 (18/01/2022): garmin.com/en-US/newsroom/press-release/
--     featured/garmin-unveils-sweeping-updates-to-its-flagship-fenix-
--     lineup-of-rugged-multisport-smartwatches/
--   - Descent Mk3/Mk3i (14/11/2023): garmin.com/en-US/newsroom/press-
--     release/outdoor/garmins-new-descent-mk3-series-dive-computers-
--     have-200-meter-dive-ratings-bright-amoled-displays-and-options-
--     with-a-built-in-flashlight/
--   - Descent Mk2/Mk2i (21/10/2020): garmin.com/en-US/newsroom/press-
--     release/outdoor/2020-garmin-announces-its-next-generation-
--     ecosystem-for-divers-featuring-descent-mk2-series-and-descent-t1-
--     transmitter/
--   - Descent G2 (12/02/2025): garmin.com/en-US/newsroom/press-release/
--     outdoor/garmin-announces-the-descent-g2-watch-style-dive-computer/
--   - Descent G1 (abril/2022): ph.garmin.com/news/press-release/
--     news-2022-apr-descentg1/ (subdomínio oficial Garmin Filipinas)
--
-- Achados que valem registrar (nenhum escondido, todos na aba de novidades):
--   - O Fenix 7 já tinha lanterna LED — só que exclusiva do tamanho 7X. O
--     Fenix 8 não restringe a um tamanho só (não é "lanterna nova", é
--     "lanterna em mais opções de tamanho").
--   - O Descent Mk3i tem MENOS bateria em modo mergulho que o Mk2 (66h
--     contra 80h) — a tela AMOLED touchscreen consome mais energia.
--   - O Descent G2 tem BEM menos bateria que o G1 (10 dias smartwatch
--     contra até 3 semanas no G1 padrão, ou até 4 meses na variante Solar
--     — que o G2 nem tem opção solar). Trade-off real de AMOLED por
--     autonomia, reportado com transparência.
-- ============================================================================

do $$
declare
  v_brand_id    uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_aventura uuid;
  v_cat_mergulho uuid;
  v_p_fenix8    uuid;
  v_p_mk3i      uuid;
  v_p_g2        uuid;
  v_quiz_fenix8 uuid;
  v_quiz_mk3i   uuid;
  v_quiz_g2     uuid;
  v_q           uuid;
begin
  insert into product_categories (brand_id, slug, name, icon, order_index)
  values (v_brand_id, 'aventura-multiesporte', 'Aventura & Multiesporte', '🏔️', 3)
  returning id into v_cat_aventura;

  insert into product_categories (brand_id, slug, name, icon, order_index)
  values (v_brand_id, 'mergulho', 'Mergulho', '🤿', 4)
  returning id into v_cat_mergulho;

  -- ==========================================================================
  -- 1. Produtos
  -- ==========================================================================
  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index)
  values (v_brand_id, v_cat_aventura, 'fenix-8', 'Fenix 8', '010-02904', 'Smartwatch multiesporte premium com AMOLED, lanterna, ECG e mergulho', true, 1)
  returning id into v_p_fenix8;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index)
  values (v_brand_id, v_cat_mergulho, 'descent-mk3i', 'Descent Mk3i', '010-02947', 'Computador de mergulho premium com AMOLED touchscreen e integração de ar', true, 1)
  returning id into v_p_mk3i;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index)
  values (v_brand_id, v_cat_mergulho, 'descent-g2', 'Descent G2', '010-02972', 'Computador de mergulho acessível com AMOLED e plástico reciclado do oceano', true, 2)
  returning id into v_p_g2;

  -- ==========================================================================
  -- 2. FENIX 8 — seções completas
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_fenix8, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Fenix 8</strong> é o smartwatch multiesporte premium da Garmin, lançado em 27 de agosto de 2024 — o topo de linha pensado pra aventura, outdoor e multiesporte, com opção de tela AMOLED ou Solar.</p><p><strong>Posicionamento oficial da Garmin</strong> (Dan Bartel, VP de Vendas ao Consumidor Global): \"Por anos, a linha Fenix foi celebrada por seus recursos premium, materiais e design. E agora estamos animados em apresentar nosso Fenix mais capaz até hoje.\"</p><p><strong>Público-alvo:</strong> atletas e aventureiros que querem o pacote mais completo da Garmin — multiesporte, navegação avançada, mergulho e recursos de comunicação — num relógio robusto.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela AMOLED ou Solar", "text": "Escolha entre tela AMOLED vibrante (43/47/51mm) ou carregamento solar pra bateria ainda mais longa (47/51mm).", "tags": []},
      {"title": "Alto-falante + microfone + Garmin Messenger", "text": "Ligações, comandos de voz e mensagens de texto bidirecionais direto do pulso.", "tags": []},
      {"title": "Lanterna LED", "text": "Luz branca, vermelha e modo estroboscópio com intensidade variável.", "tags": []},
      {"title": "Recursos de mergulho", "text": "Case com classificação de 40 metros, suporte a apneia e mergulho autônomo (scuba).", "tags": []},
      {"title": "App de ECG", "text": "Detecção de fibrilação atrial, aprovado pela FDA.", "tags": []},
      {"title": "Bateria de até 29 dias (AMOLED) ou 48 dias (Solar)", "text": "Modo smartwatch, tamanho 51mm.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_fenix8, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "O aventureiro premium", "text": "Quer o topo de linha multiesporte da Garmin, sem abrir mão de nenhum recurso.", "tags": [{"label": "Premium", "color": "gold"}]},
      {"title": "Quem mergulha ocasionalmente", "text": "Quer um relógio multiesporte que também mergulha, sem comprar um Descent separado.", "tags": [{"label": "Mergulho", "color": "blue"}]},
      {"title": "Quem quer ligar do meio da trilha", "text": "Valoriza alto-falante, microfone e Garmin Messenger pra ficar conectado em qualquer lugar.", "tags": [{"label": "Conectividade", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer o Garmin multiesporte mais completo, incluindo navegação, mergulho e comunicação</li><li>Cliente valoriza durabilidade militar e materiais premium (titânio, safira)</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente só corre e não precisa de navegação/mergulho → a linha Forerunner é mais indicada e mais em conta</li><li>Cliente quer inReach embutido (satélite) → só o Fenix 8 Pro tem essa tecnologia</li></ul>"}
  ]}
  $j$),
  (v_p_fenix8, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tela AMOLED ou Solar (escolha do cliente)", "html": "<p>AMOLED nos tamanhos 43mm, 47mm e 51mm, ou Solar (47mm/51mm) pra bateria ainda mais longa. O 51mm Solar recebe 50% mais energia solar que o modelo anterior.</p>"},
      {"title": "Alto-falante + microfone + Garmin Messenger", "html": "<p>Ligações telefônicas, ativação por comando de voz (treino de força, cronômetro, waypoints) e o app Garmin Messenger pra mensagens de texto bidirecionais.</p>"},
      {"title": "Lanterna LED", "html": "<p>Luz branca e vermelha com intensidade variável e modo estroboscópio.</p>"},
      {"title": "Recursos de mergulho", "html": "<p>Case com classificação de 40 metros, botões metálicos à prova de vazamento, suporte a apneia e mergulho autônomo (scuba).</p>"},
      {"title": "App de ECG", "html": "<p>Detecção de fibrilação atrial, aprovado pela FDA — não disponível pra menores de 22 anos nem em todas as regiões.</p>"},
      {"title": "Planos de treino de força estruturados", "html": "<p>Planos de 4 a 6 semanas com foco em força, além de treinos animados de cardio, yoga e Pilates direto na tela.</p>"},
      {"title": "Endurance Score + Hill Score", "html": "<p>Métricas avançadas de performance, além de VO2 max e Training Status.</p>"},
      {"title": "Nap Detection + Relatório Matinal", "html": "<p>Detecção automática de sonecas e resumo matinal com sono, previsão de treino e status de HRV.</p>"},
      {"title": "Mapas TopoActive + navegação avançada", "html": "<p>Mapas multi-continente, cursos de golfe e resorts de esqui pré-carregados, roteamento circular dinâmico e NextFork Map Guide.</p>"},
      {"title": "GPS multibanda SatIQ + sensores embutidos", "html": "<p>Altímetro, barômetro e bússola eletrônica de 3 eixos integrados.</p>"},
      {"title": "Materiais premium opcionais", "html": "<p>Bisel de titânio e lente de safira resistente a risco, com proteção reforçada dos sensores (sensor guard) e testes em padrão militar americano.</p>"},
      {"title": "Resistência à água", "html": "<p>Case com classificação de mergulho de 40 metros — muito além do 5 ATM padrão da maioria dos relógios Garmin.</p>"}
    ]}
  ]}
  $j$),
  (v_p_fenix8, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Fenix 7</strong> (2022), o modelo direto que o Fenix 8 substitui."},
    {"type": "accordion", "items": [
      {"title": "Opção de tela AMOLED", "html": "<p>O Fenix 7 só tinha tela MIP (com ou sem solar). O Fenix 8 introduz a opção de tela AMOLED — recurso totalmente novo na linha.</p>"},
      {"title": "Alto-falante + microfone + Garmin Messenger", "html": "<p>O Fenix 7 não tinha ligações nem mensagens bidirecionais — recursos novos do Fenix 8.</p>"},
      {"title": "Recursos de mergulho (scuba e apneia)", "html": "<p>Case com classificação de 40m e suporte a mergulho autônomo/apneia — o Fenix 7 não tinha esses modos.</p>"},
      {"title": "App de ECG", "html": "<p>Recurso novo, aprovado pela FDA — o Fenix 7 não tinha.</p>"},
      {"title": "Planos de força estruturados (4-6 semanas)", "html": "<p>O Fenix 7 tinha treino de força como atividade avulsa, sem planos estruturados de várias semanas.</p>"},
      {"title": "Endurance Score + Hill Score", "html": "<p>Métricas novas de performance — não constavam no Fenix 7.</p>"},
      {"title": "Nap Detection + Relatório Matinal", "html": "<p>O Fenix 7 tinha sugestão diária de treino e pontuação de sono, mas não detecção de soneca nem Relatório Matinal.</p>"},
      {"title": "Lanterna em mais tamanhos", "html": "<p>O Fenix 7 já tinha lanterna LED, mas só no tamanho 7X. O Fenix 8 não restringe a lanterna a um único tamanho — não é a lanterna em si que é nova, é ela deixar de ser exclusiva do maior tamanho.</p>"},
      {"title": "Sensor guard reforçado", "html": "<p>Proteção física nova para os sensores ópticos — detalhe de design que o Fenix 7 não tinha.</p>"},
      {"title": "Bateria solar melhorou", "html": "<p>Modo Solar 51mm: até 48 dias no Fenix 8 contra até 35 dias (5 semanas) no Fenix 7X Solar. A opção AMOLED é nova — não existia no Fenix 7 pra comparar bateria diretamente.</p>"},
      {"title": "O que NÃO mudou (continua igual ao Fenix 7)", "html": "<p>Titânio e safira opcionais, GPS multibanda com frequência L5, mapas TopoActive, Body Battery, Pulse Ox, monitoramento de sono e estresse, Garmin Pay, música offline, PacePro — tudo isso já vinha do Fenix 7 (e de gerações anteriores), não é novidade do 8.</p>"}
    ]}
  ]}
  $j$),
  (v_p_fenix8, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo topo de linha", "dialog": "Se você quer o Garmin mais completo que existe — multiesporte, navegação, mergulho e comunicação num relógio só —, o Fenix 8 é o produto.", "tip": "Não comece pelo preço — comece pelo que o cliente já usa hoje e o que está faltando."},
      {"title": "Puxando o mergulho como diferencial real", "dialog": "Se você mergulha de vez em quando, não precisa comprar um Descent separado — o Fenix 8 já tem case de 40 metros e suporte a apneia e mergulho autônomo.", "tip": "Bom argumento pra quem pratica mais de um esporte e não quer múltiplos relógios."},
      {"title": "Se o cliente perguntar sobre AMOLED vs Solar", "dialog": "AMOLED tem o visual mais bonito e vibrante. Solar dura muito mais tempo sem carregar — pra quem faz expedições longas, o Solar costuma ganhar.", "tip": "Pergunte sobre o tipo de uso antes de recomendar uma opção sobre a outra."},
      {"title": "Fechamento", "dialog": "Com o Fenix 8 você sai com AMOLED ou Solar, alto-falante e microfone, lanterna, ECG e recursos completos de navegação e mergulho — o pacote mais completo da Garmin.", "tip": "Tamanho (43/47/51mm) e material (padrão, titânio, safira) costumam ser a última decisão."}
    ]}
  ]}
  $j$),
  (v_p_fenix8, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não levar um Forerunner, que é mais em conta?", "answer": "Se o cliente só corre e não precisa de navegação avançada, mergulho ou construção premium, o Forerunner realmente é a opção mais eficiente. O Fenix 8 se justifica quando o cliente usa múltiplos esportes/ambientes (trilha, mergulho, navegação)."},
      {"question": "AMOLED ou Solar, qual recomendar?", "answer": "AMOLED pra quem prioriza visual e não se importa de carregar com mais frequência. Solar pra quem faz atividades longas/expedições e quer bateria de semanas sem se preocupar."},
      {"question": "Vale a pena pro mergulho, ou é melhor levar um Descent?", "answer": "O Fenix 8 cobre bem mergulho recreativo e apneia. Pra mergulho técnico mais sério (integração de ar, SubWave, DiveView), o Descent Mk3i é mais especializado."}
    ]}
  ]}
  $j$),
  (v_p_fenix8, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Cliente multiesportista", "text": "Corre, pedala, faz trilha e mergulha ocasionalmente — quer um relógio só pra tudo isso.", "tags": []},
      {"title": "Cliente de expedição longa", "text": "Vai passar dias sem acesso à energia — a autonomia do modo Solar resolve.", "tags": []},
      {"title": "Cliente que quer ficar conectado na trilha", "text": "Precisa fazer e receber ligações mesmo longe de sinal de celular direto — Garmin Messenger e alto-falante/microfone ajudam.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_fenix8, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Qual a diferença entre Fenix 8 e Fenix 8 Pro?", "html": "<p>O Fenix 8 Pro (lançado depois, em setembro de 2025) adiciona tecnologia inReach embutida pra conectividade via satélite e celular — recurso que o Fenix 8 padrão não tem.</p>"},
      {"title": "Tem opção sem AMOLED?", "html": "<p>Sim — a linha também tem a opção Solar (47mm/51mm), com tela sempre ativa e carregamento solar.</p>"},
      {"title": "Qual a autonomia de bateria?", "html": "<p>Até 29 dias em modo smartwatch (AMOLED, 51mm) ou até 48 dias (Solar, 51mm, com 3h diárias ao ar livre).</p>"},
      {"title": "Serve pra mergulho técnico?", "html": "<p>Cobre mergulho recreativo, apneia e scuba — pra mergulho técnico mais avançado (integração de ar, SubWave), o Descent Mk3i é mais especializado.</p>"},
      {"title": "Tem ECG?", "html": "<p>Sim, aprovado pela FDA — não disponível pra menores de 22 anos nem em todas as regiões.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 3. DESCENT MK3I — seções completas
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_mk3i, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Descent Mk3i</strong> é o computador de mergulho premium em formato de relógio da Garmin, lançado em 14 de novembro de 2023 — descrito pela própria Garmin como \"construído com uma abordagem mergulho-primeiro\".</p><p><strong>Público-alvo:</strong> mergulhadores técnicos e recreativos sérios que querem um único dispositivo completo pra mergulho e vida no dia a dia.</p><p>Disponível em 43mm (sem integração de ar) e 43mm/51mm com integração de ar (Mk3i) — o 51mm Mk3i é o único com lanterna LED integrada.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela touchscreen AMOLED", "text": "Primeira geração Descent com tela touchscreen e AMOLED vibrante.", "tags": []},
      {"title": "Classificação de mergulho de 200m", "text": "O dobro da profundidade da geração anterior.", "tags": []},
      {"title": "Integração de ar + SubWave", "text": "Monitoramento de pressão do tanque e, em breve, mensagens entre mergulhadores e assistência de emergência via SubWave.", "tags": []},
      {"title": "DiveView + 4.000 pontos de mergulho", "text": "Mapas com contornos batimétricos e milhares de pontos de mergulho pré-carregados no mundo todo.", "tags": []},
      {"title": "Lanterna LED (51mm)", "text": "Luz integrada com modo estroboscópio, dentro ou fora d'água.", "tags": []},
      {"title": "Bateria de até 66h em modo mergulho", "text": "Estimativa pro modelo 51mm Mk3i.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_mk3i, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Mergulhador técnico/sério", "text": "Faz mergulhos com múltiplos gases, trimix ou rebreather e quer o computador mais completo da Garmin.", "tags": [{"label": "Técnico", "color": "blue"}]},
      {"title": "Quem mergulha em grupo", "text": "Quer acompanhar pressão de tanque e posição de outros mergulhadores com o Descent T2.", "tags": [{"label": "Grupo", "color": "green"}]},
      {"title": "Quem quer 1 relógio pra tudo", "text": "Usa o Mk3i também como smartwatch no dia a dia — VO2 max, sono, notificações.", "tags": [{"label": "Multiuso", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente mergulha com regularidade e quer o computador de mergulho mais avançado da Garmin</li><li>Cliente quer integração de ar e/ou mergulho em grupo com SubWave</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente mergulha só ocasionalmente e quer economizar → o Descent G2 é mais em conta</li><li>Cliente não mergulha de verdade, só quer um relógio robusto → o Fenix 8 já cobre mergulho recreativo</li></ul>"}
  ]}
  $j$),
  (v_p_mk3i, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tela touchscreen AMOLED", "html": "<p>Sapphire lens resistente a risco, botões metálicos à prova de vazamento, funcionais mesmo na profundidade máxima.</p>"},
      {"title": "Classificação de mergulho de 200m", "html": "<p>O dobro da profundidade da geração anterior.</p>"},
      {"title": "Integração de ar (só Mk3i)", "html": "<p>Monitoramento de pressão de tanque e rastreamento de grupo (até 8 mergulhadores com Descent T2, alcance de 10m).</p>"},
      {"title": "SubWave: mensagens e assistência entre mergulhadores", "html": "<p>Via atualização de software: troca de mensagens pré-definidas (até 30m de alcance, entrega em até 45s) e sistema de alerta de emergência que mostra profundidade e distância de quem pediu ajuda.</p>"},
      {"title": "DiveView + pontos de mergulho", "html": "<p>Mapas com contornos batimétricos e mais de 4.000 pontos de mergulho pré-carregados no mundo todo, GPS de superfície pra marcar entrada/saída.</p>"},
      {"title": "Lanterna LED (51mm)", "html": "<p>Com modo estroboscópio, dentro ou fora d'água.</p>"},
      {"title": "Modos de mergulho completos", "html": "<p>Gás único e múltiplo, nitrox, trimix, gauge, apneia, apneia hunt e rebreather de circuito fechado (CCR).</p>"},
      {"title": "Sensores embutidos", "html": "<p>Altímetro, barômetro, bússola (superfície e debaixo d'água) e variômetro pra monitorar velocidade de descida/subida em freedive.</p>"},
      {"title": "Dive Readiness (prontidão pro mergulho)", "html": "<p>Avalia sono, exercício, estresse e jet lag pra sugerir se o momento é adequado pra mergulhar.</p>"},
      {"title": "Recursos de smartwatch", "html": "<p>VO2 max, Endurance Score, Hill Score, treinos sugeridos diários, Pulse Ox, sono, Garmin Pay e música offline (Spotify/Deezer/Amazon Music).</p>"}
    ]}
  ]}
  $j$),
  (v_p_mk3i, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Descent Mk2</strong> (2020), o modelo direto que o Mk3i substitui."},
    {"type": "accordion", "items": [
      {"title": "Tela touchscreen AMOLED", "html": "<p>O Mk2 tinha uma tela colorida de alto contraste, sem touchscreen e sem AMOLED. O Mk3i traz as duas coisas — o maior salto visual da geração.</p>"},
      {"title": "Classificação de mergulho dobrou", "html": "<p>200 metros no Mk3i contra a classificação da geração anterior — o dobro de profundidade, segundo a própria Garmin.</p>"},
      {"title": "Lanterna LED", "html": "<p>Recurso novo no 51mm Mk3i — o Mk2 não tinha lanterna.</p>"},
      {"title": "DiveView + pontos de mergulho pré-carregados", "html": "<p>Mapas com contornos batimétricos e 4.000+ pontos de mergulho — o Mk2 não tinha esse recurso de mapeamento.</p>"},
      {"title": "Variômetro dedicado", "html": "<p>Sensor específico pra monitorar velocidade de descida/subida em freedive — não constava no Mk2.</p>"},
      {"title": "Endurance Score + Hill Score", "html": "<p>Métricas novas de performance — o Mk2 não tinha.</p>"},
      {"title": "Dive Readiness Score", "html": "<p>Conceito novo — avaliar sono/estresse/exercício/jet lag pra sugerir prontidão de mergulho não existia no Mk2.</p>"},
      {"title": "SubWave expandido: mensagens + assistência de emergência", "html": "<p>O Mk2 usava SubWave só pra monitorar pressão de tanque (com o Descent T1). O Mk3i (com o Descent T2) adiciona troca de mensagens entre mergulhadores e alerta de assistência de emergência.</p>"},
      {"title": "Lente de safira", "html": "<p>O Mk2 não especificava lente de safira — o Mk3i confirma esse material mais resistente a risco.</p>"},
      {"title": "Bateria em modo mergulho caiu (atenção ao vender)", "html": "<p>Até 66h no Mk3i (51mm) contra até 80h no Mk2 — a tela touchscreen AMOLED consome mais energia que a tela do Mk2. Vale ser transparente sobre essa troca com mergulhadores que fazem viagens longas.</p>"},
      {"title": "O que NÃO mudou (continua igual ao Mk2)", "html": "<p>Frequência cardíaca no pulso, Pulse Ox, GPS multi-GNSS, Garmin Pay, música offline e os modos de mergulho (nitrox, trimix, gauge, apneia, CCR) — tudo isso já vinha do Mk2, não é novidade do Mk3i.</p>"}
    ]}
  ]}
  $j$),
  (v_p_mk3i, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo tipo de mergulho", "dialog": "Me conta que tipo de mergulho você mais faz — recreativo, técnico com múltiplos gases, ou mergulho em grupo? Isso muda bastante o que vale destacar no Mk3i.", "tip": "Não recite todos os recursos de uma vez — priorize o que resolve a necessidade real do cliente."},
      {"title": "Puxando a integração de ar e o SubWave", "dialog": "Se você mergulha em grupo, o Mk3i com o Descent T2 mostra a pressão de tanque e a posição de até 8 mergulhadores ao mesmo tempo — e em breve vai poder trocar mensagens e pedir ajuda por sonar, mesmo debaixo d'água.", "tip": "Bom argumento pra clubes de mergulho ou grupos que mergulham juntos com frequência."},
      {"title": "Sendo transparente sobre a bateria", "dialog": "Uma coisa importante: em modo mergulho, a bateria dura um pouco menos que a geração anterior por causa da tela touchscreen AMOLED — mas o ganho em profundidade, mapas e mensagens costuma compensar pra quem mergulha sério.", "tip": "Melhor mencionar isso proativamente pra quem faz viagens de mergulho de vários dias."},
      {"title": "Fechamento", "dialog": "Com o Mk3i você sai com tela touchscreen AMOLED, mergulho até 200m, DiveView com milhares de pontos de mergulho, e ainda funciona como smartwatch completo no dia a dia.", "tip": "Tamanho (43mm ou 51mm) e integração de ar costumam ser a decisão final."}
    ]}
  ]}
  $j$),
  (v_p_mk3i, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não o Descent G2, que é mais em conta?", "answer": "Se o cliente mergulha ocasionalmente e não precisa de integração de ar, mensagens SubWave ou classificação de 200m, o G2 realmente é suficiente e mais em conta. O Mk3i se justifica pro mergulhador técnico ou frequente."},
      {"question": "A bateria piorou em relação ao Mk2?", "answer": "Em modo mergulho, sim — a tela touchscreen AMOLED consome mais energia. Vale explicar essa troca com transparência, mas o ganho em recursos (profundidade, mapas, mensagens) costuma justificar."},
      {"question": "Preciso da integração de ar?", "answer": "Só se você mergulha com cilindro e quer monitorar pressão de tanque no pulso, ou mergulha em grupo e quer rastrear outros mergulhadores. Pra mergulho livre/apneia, o modelo sem integração de ar (Mk3, sem o 'i') já resolve."}
    ]}
  ]}
  $j$),
  (v_p_mk3i, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Instrutor de mergulho", "text": "Precisa acompanhar vários alunos ao mesmo tempo — integração de ar e rastreamento de grupo resolvem.", "tags": []},
      {"title": "Mergulhador técnico com trimix", "text": "Faz mergulhos profundos com múltiplos gases e precisa de um computador que aguente 200m.", "tags": []},
      {"title": "Cliente que viaja pra mergulhar", "text": "Quer descobrir novos pontos de mergulho — o DiveView com 4.000+ pontos pré-carregados ajuda no planejamento.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_mk3i, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Qual a diferença entre Mk3 e Mk3i?", "html": "<p>O \"i\" indica integração de ar (monitoramento de pressão de tanque). O Mk3 (sem integração) só existe no tamanho 43mm.</p>"},
      {"title": "Qual o tamanho com lanterna?", "html": "<p>Só o Mk3i de 51mm tem lanterna LED integrada.</p>"},
      {"title": "Qual a profundidade máxima?", "html": "<p>Classificação de 200 metros.</p>"},
      {"title": "O SubWave já funciona pra mensagens?", "html": "<p>O recurso de mensagens entre mergulhadores e assistência de emergência chega via atualização de software — confirme a versão mais recente antes de prometer ao cliente.</p>"},
      {"title": "Qual a autonomia em modo mergulho?", "html": "<p>Até 66 horas (estimativa pro 51mm Mk3i).</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 4. DESCENT G2 — seções completas
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_g2, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Descent G2</strong> é o computador de mergulho mais acessível da linha Descent, lançado em 12 de fevereiro de 2025 — pensado pra quem quer um dive computer com cara de smartwatch do dia a dia.</p><p><strong>Público-alvo:</strong> mergulhadores recreativos e ocasionais que não precisam do pacote técnico completo do Mk3i (integração de ar, SubWave), mas querem tela AMOLED e recursos completos de smartwatch.</p><p>100% do plástico usado na caixa, bisel e botões vem de plástico reciclado retirado do oceano.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela AMOLED de 1,2\"", "text": "Facilita ler dados debaixo d'água.", "tags": []},
      {"title": "Plástico reciclado do oceano", "text": "100% da caixa, bisel e botões vêm de plástico reciclado retirado do oceano.", "tags": []},
      {"title": "Classificação de mergulho de 100m", "text": "Lente de safira e botões à prova de vazamento.", "tags": []},
      {"title": "Modos técnico e freediving", "text": "Do mergulho técnico ao freediving, com pontuação de prontidão pro mergulho.", "tags": []},
      {"title": "Saúde 24/7", "text": "HRV Status, Pulse Ox, hidratação, sono com estágios e pontuação.", "tags": []},
      {"title": "Bateria de até 10 dias", "text": "Modo smartwatch.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_g2, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Mergulhador recreativo/ocasional", "text": "Mergulha em viagem ou passeio, sem precisar de integração de ar ou recursos técnicos avançados.", "tags": [{"label": "Recreativo", "color": "blue"}]},
      {"title": "Quem quer estilo + sustentabilidade", "text": "Valoriza o design com plástico reciclado do oceano e as cores diferenciadas.", "tags": [{"label": "Sustentável", "color": "green"}]},
      {"title": "Quem quer entrar na linha Descent com menos investimento", "text": "Quer o essencial de mergulho com AMOLED, sem pagar o preço do Mk3i.", "tags": [{"label": "Entrada Descent", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente mergulha ocasionalmente e não precisa de integração de ar ou SubWave</li><li>Cliente quer tela AMOLED e um design mais acessível/sustentável</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente mergulha com frequência ou faz mergulho técnico → o Mk3i é mais indicado</li><li>Cliente prioriza bateria de semanas → o G1 (modelo anterior) durava bem mais</li></ul>"}
  ]}
  $j$),
  (v_p_g2, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tela AMOLED de 1,2\"", "html": "<p>Facilita ler mais dados de relance, mesmo debaixo d'água.</p>"},
      {"title": "Plástico reciclado do oceano", "html": "<p>100% do plástico da caixa, bisel e botões vem de plástico reciclado retirado do oceano — pegada de sustentabilidade real, não só marketing.</p>"},
      {"title": "Classificação de mergulho de 100m", "html": "<p>Lente de safira e botões à prova de vazamento.</p>"},
      {"title": "Modos de mergulho completos", "html": "<p>Gás único e múltiplo, nitrox, trimix, rebreather de circuito fechado (CCR), gauge, freediving/apneia com rastreamento dinâmico e treino de mergulho em piscina.</p>"},
      {"title": "Dive Readiness (prontidão pro mergulho)", "html": "<p>Considera sono, estresse, exercício e jet lag pra sugerir o momento adequado de mergulhar.</p>"},
      {"title": "Alertas de apneia + modo números grandes", "html": "<p>Alertas sonoros e por vibração de profundidade, intervalo, direção e flutuabilidade neutra; modo com texto ampliado pros dados mais críticos.</p>"},
      {"title": "Variômetro", "html": "<p>Monitora velocidade de descida/subida.</p>"},
      {"title": "Saúde 24/7", "html": "<p>HRV Status, Pulse Ox (acordado e dormindo), sono com estágios e pontuação, estresse, hidratação e respiração.</p>"},
      {"title": "Recursos de smartwatch", "html": "<p>VO2 max, minutos de intensidade, Garmin Coach, GPS de superfície pra entrada/saída, notificações, Garmin Pay e Connect IQ.</p>"},
      {"title": "Cores e pulseiras QuickFit", "html": "<p>Disponível em preto e paloma/rosa shell, com compatibilidade a pulseiras QuickFit intercambiáveis.</p>"}
    ]}
  ]}
  $j$),
  (v_p_g2, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Descent G1</strong> (2022), o modelo direto que o G2 substitui."},
    {"type": "accordion", "items": [
      {"title": "Tela AMOLED", "html": "<p>O G1 tinha uma tela de alto contraste, sem confirmação oficial de AMOLED ou touchscreen. O G2 traz AMOLED de 1,2\" — o maior salto visual da geração.</p>"},
      {"title": "Plástico reciclado do oceano", "html": "<p>Recurso novo de sustentabilidade — o G1 não usava esse material.</p>"},
      {"title": "HRV Status explícito", "html": "<p>O G1 tinha Training Status geral; o G2 adiciona o status de HRV como métrica própria.</p>"},
      {"title": "Monitoramento de hidratação", "html": "<p>Recurso novo — não constava no G1.</p>"},
      {"title": "Modo números grandes", "html": "<p>Tela simplificada com dados ampliados — recurso novo do G2.</p>"},
      {"title": "Variômetro dedicado", "html": "<p>Sensor específico de velocidade de descida/subida — não constava no G1.</p>"},
      {"title": "Dive Readiness Score", "html": "<p>Conceito novo — avaliação de sono/estresse/exercício/jet lag pra sugerir prontidão de mergulho não existia no G1.</p>"},
      {"title": "Bateria caiu bastante (atenção ao vender)", "html": "<p>Até 10 dias em modo smartwatch no G2, contra até 3 semanas no G1 padrão — e o G1 ainda tinha uma variante Solar com até 4 meses de autonomia, opção que o G2 não oferece. A tela AMOLED consome bem mais energia. Vale ser muito transparente sobre essa troca, principalmente com clientes que valorizam autonomia.</p>"},
      {"title": "O que NÃO mudou (continua igual ao G1)", "html": "<p>Lente de safira, botões à prova de vazamento, classificação de mergulho de 100m, os modos de mergulho (nitrox, trimix, gauge, apneia, CCR), bússola de 3 eixos, Garmin Pay e Connect IQ — tudo isso já vinha do G1, não é novidade do G2.</p>"}
    ]}
  ]}
  $j$),
  (v_p_g2, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo perfil de mergulhador", "dialog": "Você mergulha com que frequência? Se for mais recreativo, sem precisar de integração de ar ou recursos técnicos avançados, o Descent G2 já entrega tudo que você precisa com uma tela linda.", "tip": "Se o cliente mergulha sério/frequente, considere puxar pro Mk3i em vez de insistir no G2."},
      {"title": "Puxando a sustentabilidade", "dialog": "Todo o plástico da caixa, bisel e botões desse relógio vem de plástico reciclado retirado do oceano — faz sentido pra quem mergulha e se importa com a saúde dos oceanos.", "tip": "Bom argumento emocional pra fechar a venda com clientes engajados em sustentabilidade."},
      {"title": "Sendo transparente sobre a bateria", "dialog": "Uma coisa importante: a bateria dura até 10 dias em modo smartwatch — bem menos que a geração anterior, por causa da tela AMOLED. Se autonomia é prioridade máxima, vale considerar essa troca.", "tip": "Melhor avisar antes de vender do que deixar o cliente descobrir depois."},
      {"title": "Fechamento", "dialog": "Com o Descent G2 você sai com tela AMOLED, mergulho até 100m, prontidão de mergulho e todos os recursos de saúde 24/7 — o jeito mais acessível de entrar na linha Descent.", "tip": "Cor (preto ou paloma/rosa shell) costuma ser a última decisão."}
    ]}
  ]}
  $j$),
  (v_p_g2, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não o Mk3i direto?", "answer": "Se o cliente mergulha ocasionalmente e não precisa de integração de ar, SubWave ou 200m de profundidade, o G2 entrega o essencial por um investimento bem menor."},
      {"question": "A bateria é mesmo bem menor que a do modelo anterior?", "answer": "Sim — até 10 dias contra até 3 semanas (ou até 4 meses na variante Solar do G1, que o G2 nem tem). É uma troca real por causa da tela AMOLED. Vale ser transparente, principalmente com quem viaja pra mergulhar por vários dias sem acesso a carregador."},
      {"question": "Serve pra mergulho técnico?", "answer": "Cobre mergulho técnico básico (nitrox, trimix, CCR), mas sem integração de ar nem SubWave — pra isso, o Mk3i é o produto certo."}
    ]}
  ]}
  $j$),
  (v_p_g2, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Mergulhador de férias/viagem", "text": "Mergulha algumas vezes por ano em viagens — não precisa do pacote técnico completo do Mk3i.", "tags": []},
      {"title": "Cliente engajado em sustentabilidade", "text": "Valoriza o plástico reciclado do oceano como parte da decisão de compra.", "tags": []},
      {"title": "Cliente entrando na linha Descent", "text": "Quer experimentar um computador de mergulho da Garmin sem o investimento do Mk3i.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_g2, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tem integração de ar?", "html": "<p>Não — esse recurso é exclusivo do Descent Mk3i.</p>"},
      {"title": "Qual a profundidade máxima?", "html": "<p>Classificação de 100 metros.</p>"},
      {"title": "Qual a autonomia de bateria?", "html": "<p>Até 10 dias em modo smartwatch.</p>"},
      {"title": "Tem opção solar?", "html": "<p>Não — diferente do Descent G1, que tinha uma variante Solar.</p>"},
      {"title": "Quais cores estão disponíveis?", "html": "<p>Preto e paloma/rosa shell, com pulseiras QuickFit intercambiáveis.</p>"},
      {"title": "Qual a diferença real pro Descent Mk3i?", "html": "<p>O Mk3i adiciona integração de ar, SubWave (mensagens e assistência entre mergulhadores), 200m de profundidade (contra 100m do G2), DiveView com pontos de mergulho e lanterna LED (51mm) — recursos pra mergulhador mais técnico/frequente.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 5. Quiz Especialista — Fenix 8
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-fenix-8', 'Quiz Especialista: Fenix 8', 70, true)
  returning id into v_quiz_fenix8;

  insert into questions (quiz_id, body, order_index) values (v_quiz_fenix8, 'O Fenix 8 tem opção de tela?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Sim — AMOLED ou Solar, à escolha do cliente', true, 1), (v_q, 'Só AMOLED', false, 2), (v_q, 'Só Solar', false, 3), (v_q, 'Nenhuma das duas', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz_fenix8, 'Qual profundidade de mergulho o case do Fenix 8 suporta?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '40 metros', true, 1), (v_q, '5 ATM (50 metros)', false, 2), (v_q, '100 metros', false, 3), (v_q, 'Não é resistente à água', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz_fenix8, 'O que é novo no Fenix 8 em relação ao Fenix 7?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'App de ECG', true, 1), (v_q, 'GPS multibanda', false, 2), (v_q, 'Mapas TopoActive', false, 3), (v_q, 'Bisel de titânio', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz_fenix8, 'O Fenix 8 tem tecnologia inReach embutida?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é exclusivo do Fenix 8 Pro', true, 1), (v_q, 'Sim, em todos os tamanhos', false, 2), (v_q, 'Sim, só na versão Solar', false, 3), (v_q, 'Sim, mas precisa de assinatura', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz_fenix8, 'A lanterna LED é exclusiva do Fenix 8?', 5) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — o Fenix 7X já tinha, só que exclusiva desse tamanho', true, 1), (v_q, 'Sim, totalmente nova', false, 2), (v_q, 'Não, nenhum Fenix teve lanterna', false, 3), (v_q, 'Sim, só no Fenix 8 Pro', false, 4);

  -- ==========================================================================
  -- 6. Quiz Especialista — Descent Mk3i
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-descent-mk3i', 'Quiz Especialista: Descent Mk3i', 70, true)
  returning id into v_quiz_mk3i;

  insert into questions (quiz_id, body, order_index) values (v_quiz_mk3i, 'Qual a classificação de profundidade do Descent Mk3i?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '200 metros', true, 1), (v_q, '100 metros', false, 2), (v_q, '40 metros', false, 3), (v_q, '5 ATM', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz_mk3i, 'Qual tamanho do Mk3i tem lanterna LED?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Só o 51mm', true, 1), (v_q, 'Só o 43mm', false, 2), (v_q, 'Os dois tamanhos', false, 3), (v_q, 'Nenhum tamanho', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz_mk3i, 'Em relação ao Descent Mk2, a bateria do Mk3i em modo mergulho...', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Piorou — a tela AMOLED touchscreen consome mais energia', true, 1), (v_q, 'Melhorou em todos os modos', false, 2), (v_q, 'Ficou idêntica', false, 3), (v_q, 'O Mk3i não tem modo mergulho', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz_mk3i, 'O que o SubWave permite fazer no Mk3i (via atualização de software)?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Trocar mensagens entre mergulhadores e pedir assistência de emergência', true, 1), (v_q, 'Só monitorar pressão de tanque', false, 2), (v_q, 'Fazer ligações telefônicas', false, 3), (v_q, 'Nenhuma das opções', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz_mk3i, 'O que significa o "i" no nome Mk3i?', 5) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Integração de ar (monitoramento de pressão de tanque)', true, 1), (v_q, 'Inteligência artificial', false, 2), (v_q, 'Internacional', false, 3), (v_q, 'Não significa nada específico', false, 4);

  -- ==========================================================================
  -- 7. Quiz Especialista — Descent G2
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-descent-g2', 'Quiz Especialista: Descent G2', 70, true)
  returning id into v_quiz_g2;

  insert into questions (quiz_id, body, order_index) values (v_quiz_g2, 'O Descent G2 tem integração de ar?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é exclusivo do Descent Mk3i', true, 1), (v_q, 'Sim, igual ao Mk3i', false, 2), (v_q, 'Só na cor preta', false, 3), (v_q, 'Sim, mas sem SubWave', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz_g2, 'De que material é feita a caixa, bisel e botões do Descent G2?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '100% plástico reciclado do oceano', true, 1), (v_q, 'Titânio', false, 2), (v_q, 'Alumínio reciclado', false, 3), (v_q, 'Fibra de carbono', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz_g2, 'Em relação ao Descent G1, a bateria do G2...', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Caiu bastante — de até 3 semanas (ou 4 meses no Solar) pra até 10 dias', true, 1), (v_q, 'Melhorou bastante', false, 2), (v_q, 'Ficou igual', false, 3), (v_q, 'O G1 não tinha bateria', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz_g2, 'Qual a classificação de profundidade do Descent G2?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '100 metros', true, 1), (v_q, '200 metros', false, 2), (v_q, '40 metros', false, 3), (v_q, '5 ATM', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz_g2, 'O Descent G2 tem opção de carregamento solar?', 5) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — diferente do G1, que tinha variante Solar', true, 1), (v_q, 'Sim, em todas as cores', false, 2), (v_q, 'Sim, só na cor preta', false, 3), (v_q, 'Sim, mas precisa comprar separado', false, 4);

  -- ==========================================================================
  -- 8. Ligação produto → quiz + badges
  -- ==========================================================================
  insert into product_quizzes (product_id, quiz_id) values
    (v_p_fenix8, v_quiz_fenix8), (v_p_mk3i, v_quiz_mk3i), (v_p_g2, v_quiz_g2);

  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-fenix-8-garmin', 'Especialista Fenix 8', 'Concedido ao passar no Quiz Especialista do Fenix 8.', '{"tipo": "quiz_especialista_produto", "produto": "fenix-8"}'),
  (v_brand_id, 'especialista-descent-mk3i-garmin', 'Especialista Descent Mk3i', 'Concedido ao passar no Quiz Especialista do Descent Mk3i.', '{"tipo": "quiz_especialista_produto", "produto": "descent-mk3i"}'),
  (v_brand_id, 'especialista-descent-g2-garmin', 'Especialista Descent G2', 'Concedido ao passar no Quiz Especialista do Descent G2.', '{"tipo": "quiz_especialista_produto", "produto": "descent-g2"}');

  -- ==========================================================================
  -- 9. Grafo de conhecimento — relacionados
  -- ==========================================================================
  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index) values
  (v_p_mk3i, v_p_g2, null, 'alternativa_mais_em_conta', 1),
  (v_p_g2, v_p_mk3i, null, 'topo_de_linha', 1),
  (v_p_fenix8, null, 'Mergulho recreativo', 'funcionalidade', 1),
  (v_p_fenix8, null, 'Garmin Messenger', 'funcionalidade', 2);
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 076
-- ============================================================================
