-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 075: eleva Forerunner 55 e 165 à profundidade
-- completa (ainda são vendidos na loja)
-- ============================================================================
-- Pedido do usuário (2026-07-21): "vi que no 55 e no 165 vc n colocou oq há
-- de novo e nem outras informações. nós ainda vendemos eles na loja." — até
-- aqui, 55/165 só tinham visão geral + diferenciais (tratamento de produto
-- "de referência", pensado só pra sustentar os comparativos 70-vs-55 e
-- 170-vs-165). Como ainda são vendidos, ganham as seções que faltavam:
-- personas, scripts_venda, objecoes, casos_uso, faq, quiz especialista +
-- badge, e a aba "O que há de novo?" comparando com o antecessor indicado
-- pelo usuário: FR55 vs FR45, FR165 vs FR245.
--
-- FONTES — só oficiais:
--   - Press release oficial do lançamento da linha Forerunner 45/45S/245/
--     245 Music/945 (30/04/2019): garmin.com/en-US/newsroom/press-release/
--     sports-fitness/2019-garmin-announces-an-all-new-forerunner-series-
--     with-gps-running-smartwatches-created-for-all-runners/
--
-- Achados que valem registrar:
--   - O FR45 já tinha Body Battery e monitoramento de estresse — não é
--     novidade do FR55 (só a bateria maior e o treino guiado diário são).
--   - O FR245 JÁ TINHA Pulse Ox no pulso e VO2 max/Training Status — não são
--     novidade do FR165. O que É novo: dinâmica de corrida no pulso (sem
--     precisar de pod/cinta externa, que o 245 exigia), Garmin Pay (o 245
--     não tinha, confirmado explicitamente na fonte oficial) e planos
--     adaptativos com previsão de tempo de prova.
--   - Bateria do FR165 é um caso misto: modo smartwatch melhorou (11 dias
--     vs 7 do 245), mas modo GPS piorou (19h vs 24h do 245) — a tela AMOLED
--     consome mais energia que a MIP do 245. Reportado com transparência,
--     não escondido.
-- ============================================================================

do $$
declare
  v_p55       uuid := '03ded40a-2ff2-4e7c-bd5a-eb572692f976';
  v_p165      uuid := '9a8f3755-70ce-45ec-8ae5-3cf4fe4adca0';
  v_quiz55    uuid;
  v_quiz165   uuid;
  v_q         uuid;
begin
  -- ==========================================================================
  -- 1. FORERUNNER 55 — seções que faltavam
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p55, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Quem tá começando do zero", "text": "Nunca correu com regularidade e quer o mais simples possível pra começar.", "tags": [{"label": "Iniciante", "color": "blue"}]},
      {"title": "Quem quer o preço mais baixo da loja", "text": "Já sabe que quer um Garmin de corrida, mas o orçamento é a prioridade número um.", "tags": [{"label": "Custo-benefício", "color": "gold"}]},
      {"title": "Quem valoriza bateria acima de recursos", "text": "Não quer carregar o relógio toda semana — prefere simplicidade a tela bonita.", "tags": [{"label": "Bateria", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer o preço de entrada da loja, sem abrir mão de GPS e monitoramento básico de saúde</li><li>Cliente prioriza bateria de longa duração acima de tela bonita ou recursos avançados</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer tela touchscreen ou AMOLED → o 70 é o próximo degrau</li><li>Cliente quer Training Readiness, Training Status ou música offline → nenhum desses o 55 tem</li></ul>"}
  ]}
  $j$),
  (v_p55, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Forerunner 45</strong> (2019), o modelo direto que o 55 substitui."},
    {"type": "accordion", "items": [
      {"title": "Bateria bem maior", "html": "<p>Até 14 dias em modo smartwatch (contra até 7 dias do 45) e até 20h só de GPS (contra até 13h do 45) — o maior salto entre os dois modelos.</p>"},
      {"title": "Treino guiado diário automático", "html": "<p>Sugestão de treino do dia sem precisar configurar um plano — o 45 só tinha compatibilidade com planos estruturados do Garmin Coach, sem sugestão automática diária.</p>"},
      {"title": "Detecção automática de corrida/caminhada", "html": "<p>Recurso novo — não constava entre os recursos do 45 na época do lançamento.</p>"},
      {"title": "O que NÃO mudou (continua igual ao 45)", "html": "<p>Tela MIP sem touchscreen, sem música, sem mapeamento, sem Pulse Ox, Body Battery e monitoramento de estresse (esses dois já vinham do 45) — o 55 é uma evolução de bateria e software, não um salto de hardware.</p>"}
    ]}
  ]}
  $j$),
  (v_p55, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo orçamento", "dialog": "Se o seu foco agora é o menor investimento pra ter um Garmin de corrida de verdade, o Forerunner 55 é a porta de entrada da loja — com GPS, monitoramento de saúde e uma bateria que dura semanas.", "tip": "Não tente empurrar recursos que o cliente não pediu — o 55 vende bem quando o argumento é simplicidade e preço, não recursos."},
      {"title": "Puxando a bateria como diferencial real", "dialog": "Uma das coisas que mais gente comenta é a bateria: até 14 dias sem precisar carregar — pra quem não quer ficar de olho nisso toda semana, é um baita diferencial.", "tip": "Bom argumento pra quem já reclamou de smartwatch que precisa carregar todo dia."},
      {"title": "Fechamento", "dialog": "Com o Forerunner 55 você sai hoje com GPS, monitoramento de estresse e Body Battery, treino guiado automático, e bateria que dura semanas — tudo pelo menor preço da linha.", "tip": "Cor (preto, branco ou aqua) costuma ser a última decisão."}
    ]}
  ]}
  $j$),
  (v_p55, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não levar o 70 direto?", "answer": "Se o cliente não precisa de tela touchscreen, música offline ou Training Readiness, o 55 entrega o essencial (GPS, monitoramento de saúde, treino guiado) por bem menos."},
      {"question": "Esse aqui não é fraco demais?", "answer": "Pro que ele se propõe — GPS de corrida com monitoramento de saúde básico — ele entrega bem. A diferença pro 70 é profundidade de métricas de treino, não capacidade básica."},
      {"question": "A tela é ruim?", "answer": "É uma tela MIP (sem touch, sem AMOLED) — funcional e com ótima leitura ao sol, mas sem o brilho e o toque das telas mais caras. Vale mostrar ao cliente antes de vender, pra não gerar expectativa errada."}
    ]}
  ]}
  $j$),
  (v_p55, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Primeira corrida de 5km", "text": "Cliente nunca correu com regularidade e quer o caminho mais simples e barato pra começar.", "tags": []},
      {"title": "Cliente trocando de relógio comum", "text": "Já usa um relógio básico ou fitness tracker simples e quer o salto pro GPS de corrida sem gastar muito.", "tags": []},
      {"title": "Cliente cansado de carregar o smartwatch toda semana", "text": "Vem de um smartwatch genérico que precisa carregar todo dia — a bateria do 55 resolve isso.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p55, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "O Forerunner 55 tem touchscreen?", "html": "<p>Não — a tela é MIP, controlada só pelos 5 botões físicos.</p>"},
      {"title": "Tem armazenamento de música?", "html": "<p>Não — música offline é exclusiva do Forerunner 70 nesta comparação.</p>"},
      {"title": "Qual a autonomia de bateria?", "html": "<p>Modo smartwatch: até 14 dias. Só GPS: até 20h.</p>"},
      {"title": "Tem resistência à água pra nadar?", "html": "<p>Sim, classificação 5 ATM.</p>"},
      {"title": "Quais cores estão disponíveis?", "html": "<p>Preto, branco ou aqua.</p>"},
      {"title": "Qual a diferença real pro Forerunner 70?", "html": "<p>O 70 adiciona tela AMOLED touchscreen, Training Readiness, Training Status, potência de corrida no pulso e música offline — recursos que o 55 não tem. Veja o comparativo completo na aba Comparativos.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 2. FORERUNNER 165 — seções que faltavam
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p165, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Quem quer tela bonita sem pagar o topo de linha", "text": "Gosta do visual AMOLED, mas não precisa dos sensores extras do 170.", "tags": [{"label": "Estilo", "color": "blue"}]},
      {"title": "Quem já corre com regularidade", "text": "Quer planos de treino adaptativos com previsão de tempo de prova, sem precisar de acessório externo.", "tags": [{"label": "Corredor regular", "color": "green"}]},
      {"title": "Quem quer pagar com o pulso", "text": "Valoriza Garmin Pay no dia a dia do treino.", "tags": [{"label": "Praticidade", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer tela AMOLED touchscreen sem pagar o preço do 170</li><li>Cliente quer Garmin Pay e dinâmica de corrida no pulso, sem precisar de ciclismo/natação em águas abertas</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer Training Readiness/Status ou potência de corrida completa → só o 170 tem</li><li>Cliente pedala com medidor de potência ou nada em águas abertas → só o 170 tem sensores pra isso</li></ul>"}
  ]}
  $j$),
  (v_p165, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Forerunner 245</strong> (2019), o modelo direto que o 165 substitui."},
    {"type": "accordion", "items": [
      {"title": "Tela AMOLED touchscreen", "html": "<p>O 245 tinha tela MIP sem touch. O 165 chega com AMOLED touchscreen de 1,2\" — o maior salto visual entre os dois.</p>"},
      {"title": "Dinâmica de corrida direto no pulso", "html": "<p>O 245 media dinâmica de corrida (cadência, comprimento de passada, tempo de contato com o solo) só com um pod ou cinta cardíaca externa. O 165 mede isso direto no sensor de pulso, sem acessório extra.</p>"},
      {"title": "Garmin Pay", "html": "<p>O 245 não tinha pagamento por aproximação (confirmado na fonte oficial do lançamento). O 165 tem Garmin Pay.</p>"},
      {"title": "Planos de treino adaptativos com previsão de tempo de prova", "html": "<p>O 245 tinha planos estruturados do Garmin Coach, mas sem previsão adaptativa de tempo de prova. O 165 adiciona essa previsão.</p>"},
      {"title": "Bateria — um caso misto (atenção ao vender)", "html": "<p>Modo smartwatch melhorou: até 11 dias no 165 contra até 7 dias no 245. Mas modo só GPS piorou: até 19h no 165 contra até 24h no 245 — a tela AMOLED consome mais energia que a MIP do 245. Vale ser transparente sobre essa troca.</p>"},
      {"title": "O que NÃO mudou (continua igual ao 245)", "html": "<p>VO2 max, Training Status, Pulse Ox no pulso (o 245 já tinha) e monitoramento 24/7 — esses recursos já vinham do 245, não são novidade do 165.</p>"}
    ]}
  ]}
  $j$),
  (v_p165, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela tela", "dialog": "Se você quer o visual AMOLED touchscreen sem pagar o preço do topo de linha, o Forerunner 165 é o ponto de equilíbrio da loja.", "tip": "Bom gancho visual — vale mostrar a tela ligada antes de falar de qualquer outro recurso."},
      {"title": "Puxando o Garmin Pay e a dinâmica de corrida", "dialog": "Ele já vem com Garmin Pay pra pagar sem carteira, e mede sua dinâmica de corrida direto no pulso — sem precisar de nenhum acessório extra.", "tip": "Se o cliente já tem um relógio mais antigo com pod externo, esse é um argumento forte de simplificação."},
      {"title": "Sendo transparente sobre a bateria em modo GPS", "dialog": "Uma coisa importante: em treinos longos só com GPS, a bateria dura um pouco menos que modelos mais antigos por causa da tela AMOLED — mas no dia a dia (modo smartwatch) ela dura mais.", "tip": "Melhor mencionar isso proativamente, principalmente pra quem faz provas longas (ultras, por exemplo)."},
      {"title": "Fechamento comparando com o 170", "dialog": "A diferença pro 170 é Training Readiness, Training Status, potência de corrida completa e sensores pra ciclismo/natação em águas abertas — se nenhum desses te interessa, o 165 já entrega bastante.", "tip": "Só puxe essa comparação se o cliente perguntar sobre o 170."}
    ]}
  ]}
  $j$),
  (v_p165, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não levar o 170 direto?", "answer": "Se o cliente não precisa de Training Readiness/Status, potência de corrida completa ou sensores de ciclismo/natação, o 165 entrega tela AMOLED e Garmin Pay por um preço menor."},
      {"question": "A bateria piorou em relação ao modelo anterior?", "answer": "Em modo GPS puro, sim — a tela AMOLED consome mais energia. Mas em modo smartwatch (uso diário), a bateria do 165 dura mais que a do 245. Vale explicar essa troca com transparência."},
      {"question": "Preciso de acessório externo pra dinâmica de corrida?", "answer": "Não — diferente do modelo anterior (que exigia um pod ou cinta cardíaca), o 165 mede dinâmica de corrida direto no sensor de pulso."}
    ]}
  ]}
  $j$),
  (v_p165, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Cliente vindo de um relógio com pod externo", "text": "Cansado de carregar acessório extra pra dinâmica de corrida — o 165 mede tudo no pulso.", "tags": []},
      {"title": "Cliente treinando pra uma prova de meia maratona", "text": "Quer previsão de tempo de prova adaptativa, sem precisar do pacote completo do 170.", "tags": []},
      {"title": "Cliente que quer pagar sem carteira", "text": "Valoriza sair pra correr mais leve e ainda conseguir pagar algo no caminho — Garmin Pay resolve.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p165, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "O Forerunner 165 tem Training Readiness?", "html": "<p>Não — esse recurso é exclusivo do Forerunner 170 nesta comparação.</p>"},
      {"title": "Precisa de acessório externo pra dinâmica de corrida?", "html": "<p>Não, mede tudo direto no sensor de pulso.</p>"},
      {"title": "Qual a autonomia de bateria?", "html": "<p>Modo smartwatch: até 11 dias. Só GPS: até 19h.</p>"},
      {"title": "Tem Garmin Pay?", "html": "<p>Sim.</p>"},
      {"title": "Tem armazenamento de música?", "html": "<p>Sim, na versão Forerunner 165 Music (até 4 GB).</p>"},
      {"title": "Qual a diferença real pro Forerunner 170?", "html": "<p>O 170 adiciona Training Readiness, Training Status, potência de corrida completa, altímetro barométrico, bússola, giroscópio, termômetro, suporte a medidor de potência de ciclismo e natação em águas abertas. Veja o comparativo completo na aba Comparativos.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 3. Quiz Especialista — Forerunner 55
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values ('2f7d8451-b279-4d69-8192-6ac9953d7da1', 'quiz-especialista-forerunner-55', 'Quiz Especialista: Forerunner 55', 70, true)
  returning id into v_quiz55;

  insert into questions (quiz_id, body, order_index) values (v_quiz55, 'O Forerunner 55 tem tela touchscreen?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é tela MIP controlada só pelos 5 botões', true, 1), (v_q, 'Sim, AMOLED touchscreen', false, 2), (v_q, 'Sim, mas só na cor preta', false, 3), (v_q, 'Sim, MIP touchscreen', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz55, 'Qual a autonomia máxima em modo smartwatch do Forerunner 55?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 14 dias', true, 1), (v_q, 'Até 7 dias', false, 2), (v_q, 'Até 20 dias', false, 3), (v_q, 'Até 3 dias', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz55, 'O que já vinha do Forerunner 45 e NÃO é novidade do 55?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Body Battery e monitoramento de estresse', true, 1), (v_q, 'Bateria de 14 dias', false, 2), (v_q, 'Treino guiado diário automático', false, 3), (v_q, 'Detecção de corrida/caminhada', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz55, 'O Forerunner 55 tem armazenamento de música?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é exclusivo do Forerunner 70', true, 1), (v_q, 'Sim, até 4 GB', false, 2), (v_q, 'Sim, até 8 GB', false, 3), (v_q, 'Sim, mas só via Bluetooth', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz55, 'Quais cores o Forerunner 55 tem disponíveis?', 5) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Preto, branco ou aqua', true, 1), (v_q, 'Só preto', false, 2), (v_q, '6 cores', false, 3), (v_q, 'Preto e dourado', false, 4);

  -- ==========================================================================
  -- 4. Quiz Especialista — Forerunner 165
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values ('2f7d8451-b279-4d69-8192-6ac9953d7da1', 'quiz-especialista-forerunner-165', 'Quiz Especialista: Forerunner 165', 70, true)
  returning id into v_quiz165;

  insert into questions (quiz_id, body, order_index) values (v_quiz165, 'O Forerunner 165 precisa de acessório externo pra medir dinâmica de corrida?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — mede direto no sensor de pulso', true, 1), (v_q, 'Sim, precisa de um pod', false, 2), (v_q, 'Sim, precisa de cinta cardíaca', false, 3), (v_q, 'Não mede dinâmica de corrida', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz165, 'O Forerunner 165 tem Garmin Pay?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Sim', true, 1), (v_q, 'Não', false, 2), (v_q, 'Só na versão Music', false, 3), (v_q, 'Só nos EUA', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz165, 'Em relação ao Forerunner 245, a bateria do 165 em modo só GPS...', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Piorou — a tela AMOLED consome mais energia', true, 1), (v_q, 'Melhorou em todos os modos', false, 2), (v_q, 'Ficou idêntica', false, 3), (v_q, 'O 165 não tem modo só GPS', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz165, 'O Pulse Ox no pulso é novidade do Forerunner 165?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — o Forerunner 245 já tinha', true, 1), (v_q, 'Sim, é exclusivo do 165', false, 2), (v_q, 'Sim, mas só na versão Music', false, 3), (v_q, 'Nenhum dos dois tem Pulse Ox', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz165, 'O Forerunner 165 tem Training Readiness?', 5) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é exclusivo do Forerunner 170', true, 1), (v_q, 'Sim, igual ao 170', false, 2), (v_q, 'Só na versão Music', false, 3), (v_q, 'Sim, mas sem Training Status', false, 4);

  -- ==========================================================================
  -- 5. Ligação produto → quiz + badges
  -- ==========================================================================
  insert into product_quizzes (product_id, quiz_id) values (v_p55, v_quiz55), (v_p165, v_quiz165);

  insert into badges (brand_id, slug, title, description, rule) values
  ('2f7d8451-b279-4d69-8192-6ac9953d7da1', 'especialista-forerunner-55-garmin', 'Especialista Forerunner 55', 'Concedido ao passar no Quiz Especialista do Forerunner 55.', '{"tipo": "quiz_especialista_produto", "produto": "forerunner-55"}'),
  ('2f7d8451-b279-4d69-8192-6ac9953d7da1', 'especialista-forerunner-165-garmin', 'Especialista Forerunner 165', 'Concedido ao passar no Quiz Especialista do Forerunner 165.', '{"tipo": "quiz_especialista_produto", "produto": "forerunner-165"}');
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 075
-- ============================================================================
