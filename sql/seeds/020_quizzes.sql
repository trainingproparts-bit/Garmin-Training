-- ============================================================================
-- GARMIN TRAINING HUB — SEED 020: bancos de quiz
-- ============================================================================
-- Migra os 11 bancos de perguntas hardcoded em index_redesign_v5.html para
-- quizzes/questions/alternatives. Texto de pergunta/alternativa/explicação
-- preservado fielmente (extraído por script, não digitado à mão).
--
-- Técnica usada: cada quiz é um bloco PL/pgSQL "do $$ ... $$" que insere o
-- quiz, depois cada pergunta (capturando o id gerado em uma variável via
-- "returning id into"), e então suas alternativas usando essa variável —
-- evita CTEs aninhadas, que ficariam ilegíveis com ~10+ perguntas por quiz.
--
-- Pré-requisito de execução: garmin_training_hub_migrations.sql (schema base).
-- alternatives.feedback é preenchido quando o banco de origem tinha feedback
-- por alternativa (fb[]); os demais ficam null.
-- ============================================================================

-- ── Módulo 1 — Universo Garmin (10 perguntas) ──
insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
values ((select id from brands where slug = 'garmin'), 'universo-garmin', 'Módulo 1 — Universo Garmin', 70.00, true)
on conflict (brand_id, slug) do nothing;

do $$
declare
  v_quiz_id uuid;
  v_q_id uuid;
begin
  select id into v_quiz_id from quizzes where brand_id = (select id from brands where slug = 'garmin') and slug = 'universo-garmin';

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Em que ano a Garmin foi fundada?', 'A Garmin foi fundada em 1989 por Gary Burrell e Min Kao em Lenexa, Kansas, EUA.', 0)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '1985', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '1989', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '1993', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '1999', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que significa o nome "Garmin"?', 'GAR + MIN = GARMIN. O nome vem das iniciais dos dois fundadores: Gary Burrell e Min Kao.', 1)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Acrônimo de GPS Advanced Routing Monitoring & Intelligence Navigation', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Junção das iniciais de Gary Burrell e Min Kao (GAR + MIN)', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Nome de uma cidade no Kansas onde foi fundada', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Palavra de origem japonesa que significa "precisão"', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Quais são os 5 segmentos oficiais da Garmin?', 'Os 5 segmentos oficiais são: Fitness, Outdoor, Aviation (Aviação), Marine (Náutico) e Auto (Automotivo).', 2)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Fitness, Outdoor, Aviation, Marine e Auto', true, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Sports, Adventure, Navigation, Diving e Cycling', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Watches, GPS, Cycling, Marine e Automotive', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Running, Cycling, Swimming, Hiking e Driving', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual rede de satélites o inReach utiliza para comunicação?', 'O inReach usa a rede Iridium®, que oferece cobertura global de 100% do planeta.', 3)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Starlink (SpaceX)', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'GPS americano (NAVSTAR)', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Iridium®', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Galileo (europeu)', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que é o Body Battery™?', 'Body Battery é um indicador exclusivo Garmin que mede a energia disponível do corpo (0-100) com base em HRV, qualidade do sono e níveis de estresse.', 4)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Indicador da capacidade da bateria do relógio', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Indicador de energia do corpo de 0-100 baseado em HRV, sono e estresse', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Medidor de força muscular durante treinos de academia', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Estimativa de calorias restantes para consumir no dia', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual a principal diferença do GPS multibanda para o GPS comum?', 'O GPS multibanda usa duas frequências (L1 e L5) simultaneamente, resultando em muito mais precisão de traçado.', 5)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O multibanda conecta a mais satélites ao mesmo tempo, chegando a 50', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O multibanda usa duas frequências de satélite (L1 e L5) resultando em traçado muito mais preciso em cidades e florestas', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O multibanda funciona sem bateria usando energia solar', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O multibanda é exclusivo para atividades aquáticas', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que é o VO2 Max no contexto Garmin?', 'O VO2 Max do Garmin é uma estimativa calculada pelo algoritmo FirstBeat baseada na relação entre FC e velocidade durante treinos.', 6)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Velocidade máxima registrada em uma corrida', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Volume máximo de batimentos cardíacos por minuto', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Estimativa do consumo máximo de oxigênio calculada pelo algoritmo FirstBeat', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Medição de oxigenação do sangue durante o sono', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que diferencia o Garmin Connect do Connect IQ?', 'Garmin Connect = app que recebe e sincroniza dados do relógio. Connect IQ = loja de apps que instalam e rodam diretamente no relógio.', 7)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Connect é para relógios e Connect IQ é para ciclocomputadores', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Connect é o app de sincronização de dados; Connect IQ é a loja de apps que rodam dentro do relógio', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Connect é gratuito e Connect IQ é pago', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Connect é para iOS e Connect IQ é para Android', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual a política de garantia da Proparts para dispositivos Garmin?', 'A Proparts oferece 2 anos de garantia para dispositivos e 1 ano para acessórios.', 8)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '6 meses de garantia para todos os produtos', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '1 ano para dispositivos e 6 meses para acessórios', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '2 anos para dispositivos e 1 ano para acessórios', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '1 ano para todos os produtos sem distinção', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual das afirmações sobre a Garmin é CORRETA?', 'Correto! A Garmin foi fundada em 1989 nos EUA, tem mais de 35 anos de expertise em GPS e atua em 5 segmentos oficiais.', 9)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'A Garmin foi fundada no Japão e é uma empresa asiática', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'A Garmin é especializada exclusivamente em relógios esportivos desde 1989', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'A Garmin tem mais de 35 anos de expertise em GPS e atua em 5 segmentos: Fitness, Outdoor, Aviation, Marine e Auto', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'A Garmin foi a primeira empresa a criar um smartphone com GPS integrado', false, null, 3);

end $$;

-- ── Módulo 2 — Perfis de Cliente (15 perguntas) ──
insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
values ((select id from brands where slug = 'garmin'), 'perfis-cliente', 'Módulo 2 — Perfis de Cliente', 70.00, true)
on conflict (brand_id, slug) do nothing;

do $$
declare
  v_quiz_id uuid;
  v_q_id uuid;
begin
  select id into v_quiz_id from quizzes where brand_id = (select id from brands where slug = 'garmin') and slug = 'perfis-cliente';

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente chega à loja e diz: "Estou começando a correr agora e quero monitorar minha distância e tempo." Qual produto você indica primeiro?', 'O Forerunner 55 é a porta de entrada perfeita para o Corredor Iniciante: GPS, frequência cardíaca e treinos básicos sem complicação.', 0)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Fenix 8 — o melhor da linha', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Forerunner 55 ou 165 — porta de entrada ideal para iniciantes', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Instinct 3 — robusto e com GPS', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Venu 4 — tela AMOLED bonita', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual é o sinal mais claro de que o cliente à sua frente é um "Corredor Dedicado"?', 'O Corredor Dedicado treina com frequência e usa vocabulário técnico: ritmo, distância, PR, VO2 Max.', 1)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Nunca usou relógio GPS antes', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Fala em ritmo, treino intervalado, PR (recorde pessoal) e treina 3+ vezes por semana', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Pergunta por relógio elegante para o dia a dia', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Quer um relógio para usar na piscina', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente menciona "Ironman", "Triathlon" e pergunta por "bateria de 30h+ GPS real". Qual é o perfil dele?', 'Ironman, triathlon e bateria longa são sinais claros do Atleta de Elite / Triatleta.', 2)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Aventureiro / Trilheiro', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Corredor Iniciante', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Atleta de Elite / Triatleta', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Golfista', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Para o perfil "Mulher Lifestyle", qual objeção é mais comum e qual é a resposta correta?', 'A objeção mais comum é a comparação com Apple Watch. O Lily 2 Active tem GPS integrado e bateria de até 7 dias — enquanto o Apple Watch dura 1-2 dias.', 3)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"São muito esportivos e grandes para o meu pulso" — Apresente a Forerunner', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"O Apple Watch tem mais funções de smartwatch" — responda que o Garmin tem bateria muito superior', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Não vou me adaptar" — responda que a Garmin é mais indicada para corredores', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"É muito pesado" — responda que o Fenix 8 é leve', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual produto é a recomendação principal para o perfil "Aventureiro / Trilheiro"?', 'O Instinct 3 é a indicação principal para trilheiros: certificação MIL-STD-810, bateria de até 26 dias.', 4)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Forerunner 265', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Venu 4', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Instinct 3', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Edge 840', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que é MIL-STD-810 e por que é importante para o perfil Aventureiro?', 'MIL-STD-810 é a certificação militar americana que testa impacto, temperatura extrema, umidade, altitude e vibração.', 5)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É uma certificação de resistência à água apenas', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É a certificação militar americana de resistência: impacto, temperatura extrema, umidade, altitude e vibração', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É o nível de precisão do GPS em trilhas', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É o padrão de duração de bateria em GPS militar', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um ciclista pergunta sobre um produto que detecta carros se aproximando por trás. O que você indica?', 'O Varia RTL515 é o radar traseiro Garmin que detecta veículos a 140m e alerta no relógio ou Edge.', 6)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Edge 1050 com alerta de tráfego', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Varia RTL515 — radar traseiro que detecta veículos a 140m', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'HRM 600 com sensor traseiro', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Rally RK 200 com sensores de proximidade', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Para o perfil "Ciclista", qual é a diferença que justifica recomendar o medidor de potência Rally RK 200?', 'Potência é a métrica mais honesta do ciclismo — não é afetada por cansaço, calor ou adrenalina.', 7)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Ele monitora a frequência cardíaca com mais precisão do que o pulso', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Potência é a métrica mais honesta do ciclismo — não é afetada por cansaço ou adrenalina, permitindo treino nas zonas certas', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Rally tem GPS integrado, dispensando o Edge', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Rally sincroniza com Strava automaticamente', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual é a métrica de natação que o Garmin registra e que encanta nadadores dedicados?', 'SWOLF combina o número de braçadas com o tempo por volta — quanto menor, mais eficiente.', 8)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'VO2 Max aquático', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'SWOLF — indicador de eficiência de braçada (quanto menor, mais eficiente)', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Training Readiness subaquático', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Body Battery de piscina', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente pergunta por um "computador de mergulho". O que diferencia o Descent de um computador dedicado?', 'Computadores dedicados não têm GPS de superfície, mapas ou monitoramento de saúde. O Descent faz tudo isso E é um smartwatch completo no dia a dia.', 9)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Descent é mais barato que computadores dedicados', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Descent tem mais autonomia de gás do que qualquer outro', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Descent é um smartwatch completo no dia a dia: GPS, monitoramento de saúde e mergulho em um único dispositivo', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Descent não precisa de certificação para uso em mergulho técnico', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual produto indicar para um golfista que pergunta por distâncias automáticas do green e experiência premium?', 'O Approach S50 é a experiência mais completa para golfistas: AMOLED, +42.000 campos, visão aérea do buraco.', 10)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Forerunner 165 com modo golfe', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Approach S50 — AMOLED com +42.000 campos e experiência mais completa', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Instinct 3 com modo golfe', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Forerunner 265 com app de golfe', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual é o principal argumento para rebater "o celular no suporte não é suficiente?" para um ciclista?', 'O celular no sol trava, esquenta e a tela escurece. O Edge foi construído especificamente para uso em bike.', 11)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Edge tem Garmin Pay integrado, o celular não', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Edge foi feito para isso: tela legível sob sol forte, não esquenta, modo específico para MTB e bateria que dura toda a etapa', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Edge tem GPS multibanda, o celular não', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Edge sincroniza com Strava em tempo real, o celular não', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Para o perfil "Pescador / Náutico", qual a diferença principal entre o Striker Vivid 5cv e o ECHOMAP UHD2?', 'O Striker tem GPS básico. O ECHOMAP adiciona mapas náuticos BlueChart G3 com profundidade de canais e pontos de referência.', 12)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O ECHOMAP é mais barato que o Striker', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Striker tem GPS, o ECHOMAP não', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O ECHOMAP adiciona mapas náuticos detalhados com profundidade de canais e pontos de referência', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O ECHOMAP tem sonar mais fraco que o Striker', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente diz "eu uso as sapatilhas SPD". Qual produto Garmin específico você pode oferecer para ele?', 'O Rally RK 200 é o pedal medidor de potência Garmin com sistema de encaixe SPD.', 13)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Varia RTL515 — radar traseiro', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Edge 1050 com suporte SPD integrado', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Rally RK 200 — pedal medidor de potência SPD compatível com qualquer pedivela', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'HRM 600 com sensor de cadência SPD', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual perfil de cliente é mais provável de comparar o Garmin com o Apple Watch no design?', 'O perfil "Mulher Lifestyle" frequentemente compara o Garmin com Apple Watch pelo design. O Lily 2 tem design joia e o Venu 4 tem AMOLED com saúde feminina completa.', 14)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Atleta de Elite / Triatleta', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Aventureiro / Trilheiro', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Mulher Lifestyle', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Mergulhador', false, null, 3);

end $$;

-- ── Quiz Especial — IPX & Resistência à Água (10 perguntas) ──
insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
values ((select id from brands where slug = 'garmin'), 'ipx-resistencia-agua', 'Quiz Especial — IPX & Resistência à Água', 70.00, true)
on conflict (brand_id, slug) do nothing;

do $$
declare
  v_quiz_id uuid;
  v_q_id uuid;
begin
  select id into v_quiz_id from quizzes where brand_id = (select id from brands where slug = 'garmin') and slug = 'ipx-resistencia-agua';

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que significa a sigla IPX?', 'IPX significa Ingress Protection. O X indica que a proteção contra poeira não foi avaliada — apenas a resistência à água.', 0)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Ingress Protection — só a resistência à água é avaliada, não a proteção contra poeira', true, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'International Protection Extra — padrão que avalia poeira e resistência a jatos d''água', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Impermeabilidade Por Exposição — certificação brasileira para eletrônicos em ambiente úmido', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Índice de Proteção eXtended — versão avançada do padrão IP para dispositivos submersos', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual certificação os relógios Garmin usam (diferente dos GPS portáteis)?', 'Os relógios Garmin seguem a norma ISO 22810, medida em ATM. A norma IPX é usada em GPS portáteis, fones (Shokz) e acessórios.', 1)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'IPX — Ingress Protection', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'IPX8 — imersão profunda', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'EN 13319 — padrão europeu', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'ATM — baseado na norma ISO 22810', true, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente chega com o Instinct 3 e diz que parou de funcionar depois de uma sauna. O que você explica?', 'A certificação é realizada com água limpa em temperatura ambiente. Água quente, vapor e sauna alteram a pressão interna e podem vencer a vedação. Dano por água fora dos limites certificados geralmente não tem cobertura de garantia.', 2)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'A sauna seca é tolerada até 60°C — acima disso o vapor começa a comprometer os sensores', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Instinct 3 é 10 ATM e inclui proteção a vapor — provavelmente foi exposição muito prolongada', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'A norma usa água fria — vapor e calor alteram a pressão interna e podem vencer a vedação', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Defeito de fabricação pode ocorrer em ambientes úmidos — vale acionar a garantia com laudo', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual a classificação mínima para um cliente que quer nadar em piscina com o relógio Garmin?', '5 ATM é o mínimo para natação em piscina e uso na chuva. FR165, Venu 4 e Vivoactive 6 são exemplos com 5 ATM.', 3)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '10 ATM', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '5 ATM', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '1 ATM', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'IPX4', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente quer um Shokz para usar correndo na chuva forte. Qual modelo você indica?', 'O OpenRun tem IP67 — proteção total contra poeira (nível 6) e imersão até 1m por 30min (nível 7). O OpenRun Pro tem IP55, que aguenta suor e chuva leve, mas não é recomendado para chuva muito forte.', 4)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'OpenRun (IP67) — nível 7 de resistência à água, aguenta imersão até 1m por 30min', true, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Ambos têm proteção equivalente na chuva — IP55 e IP67 suportam o mesmo volume d''água', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Nenhum dos dois é indicado — fones de condução óssea não são certificados para chuva forte', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'OpenRun Pro (IP55) — driver de titânio garante vedação superior em condições úmidas', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual a diferença entre IPX7 e IPX8?', 'IPX7 = imersão em até 1 metro por até 30 minutos. IPX8 = imersão além de 1 metro. Quanto maior o número, maior a proteção.', 5)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Não há diferença prática — ambos suportam o mesmo tipo de imersão em uso cotidiano', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'IPX7 é para GPS portátil, IPX8 é certificação exclusiva para relógios esportivos', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'IPX7 protege contra respingos intensos, IPX8 cobre exposição contínua à chuva forte', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'IPX7: imersão até 1m por 30min; IPX8: imersão além de 1m', true, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente vai usar o GPS Garmin em um caiaque. Qual recurso você destaca além da certificação IPX7?', 'Para uso náutico, a flutuação é decisiva. IPX7 garante sobrevivência à imersão por 30min em 1m, mas em mar aberto o GPS pode afundar além desse limite. Modelos flutuantes ficam visíveis na superfície.', 6)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Modelos com flutuação como o GPSMAP 79s — se cair na água, sobe à superfície', true, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'GPS multibanda — sinal mais preciso mesmo em ambientes aquáticos e sob cobertura densa', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Bateria de longa duração — essencial para travessias sem possibilidade de recarga', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Tela de alto contraste — visível mesmo com reflexo da água e uso com óculos de sol', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O IPX4 protege contra qual tipo de exposição à água?', 'IPX4 = respingos de água de qualquer direção. Protege contra suor e chuva leve. Não pode ser submerso. É o nível mais básico de proteção.', 7)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Submersão em água parada por até 10 minutos — ideal para lavagem rápida do produto', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Imersão até 1 metro por 30 minutos — equivalente ao IPX7 em condições controladas', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Respingos de qualquer direção — protege contra suor e chuva leve', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Jatos de água de baixa pressão em qualquer ângulo — inclui uso sob chuveiro fraco', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um Garmin com 10 ATM + EN 13319 — qual o uso indicado?', '10 ATM + EN 13319 é a certificação de mergulho técnico real. O Descent MK3i e o Fenix 8 têm essa certificação, suportando profundidades de até 200m dependendo do modelo.', 8)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Corrida intensa com exposição constante a respingos e suor em ambiente externo', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Mergulho com equipamento — modelos como Descent MK3i suportam até 200m de profundidade', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Natação em piscina com treinamentos intervalados de alta intensidade e viradas frequentes', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Surf com exposição a ondas — a norma EN 13319 cobre impacto de água salgada', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Como você explica corretamente a resistência à água de um produto ao cliente?', 'Sempre especifique o nível e os limites. ''À prova de água'' não existe tecnicamente. A comunicação correta evita expectativas erradas e devoluções.', 9)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Resistente a respingos e suor, mas evite submersão mesmo breve — não é à prova d''água.', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Depende do modelo — alguns suportam natação, outros só chuva leve. Confira a ficha técnica.', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'À prova d''água e pode ser usado em qualquer profundidade — a certificação garante isso.', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Tem certificação IPX7 — aguenta imersão até 1m por 30min, mas não é indicado para mergulho.', true, null, 3);

end $$;

-- ── Quiz Especial — Script de Atendimento (10 perguntas) ──
insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
values ((select id from brands where slug = 'garmin'), 'atendimento-cenarios', 'Quiz Especial — Script de Atendimento', 70.00, true)
on conflict (brand_id, slug) do nothing;

do $$
declare
  v_quiz_id uuid;
  v_q_id uuid;
begin
  select id into v_quiz_id from quizzes where brand_id = (select id from brands where slug = 'garmin') and slug = 'atendimento-cenarios';

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente entra na loja e você diz "Como posso ajudar?". Por que essa abordagem não é ideal?', '"Como posso ajudar?" é uma abertura genérica que convida respostas fechadas. O ideal é apresentar seu nome e convidar o cliente a falar sobre o que veio ver — abrindo espaço para a sondagem.', 0)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É muito formal para uma loja de esporte — o ideal é uma abordagem mais descontraída', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O correto é aguardar o cliente se aproximar para não invadir seu espaço de escolha', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É genérica — o cliente costuma responder "só estou olhando" e a conversa trava', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Deveria primeiro se apresentar pelo nome antes de fazer qualquer pergunta ao cliente', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Na sondagem, um cliente diz que já sabe o modelo que quer. Qual é a próxima pergunta ideal?', 'Mesmo quando o cliente já tem um modelo em mente, é essencial entender o contexto: é presente ou para ele? Esporte ou dia a dia? Essas respostas podem confirmar a escolha ou revelar um produto mais adequado.', 1)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"É pra você ou é presente? Esporte ou dia a dia?"', true, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Ir direto buscar o produto sem perguntar mais nada', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Você tem certeza? Posso te mostrar outros modelos."', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Qual é o seu orçamento?"', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente diz "Tá caro, vou pesquisar online." Como você responde?', 'O argumento correto valoriza os diferenciais da Proparts: garantia oficial de 2 anos, suporte presencial e a experiência de testar antes de comprar. Não entre em guerra de preço — venda a segurança e o serviço.', 2)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Vou falar com o gerente pra ver se consigo um desconto especial pra fechar hoje."', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Entendo. Aqui tem garantia de 2 anos, suporte presencial e você experimenta agora — resolver problemas online é muito mais difícil."', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Online é arriscado — já tivemos clientes que receberam produto falsificado sem suporte."', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Sem problema, pode pesquisar. Se decidir, pode me chamar no WhatsApp."', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual é a melhor forma de apresentar a bateria do Garmin ao cliente?', 'Traduza especificações em benefícios reais. "13 dias" é um número — "carrega uma vez na semana sem ansiedade no treino" é uma experiência que o cliente imagina e deseja. Sempre conecte a função ao dia a dia do cliente.', 3)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"A bateria Garmin é líder de mercado — nenhum concorrente chega perto da durabilidade."', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Dura muito mais que o Apple Watch, que precisa ser carregado praticamente todo dia."', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Tem 13 dias de duração com GPS multibanda ativo e 26 dias no modo smartwatch."', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Você carrega uma vez na semana — sem aquela ansiedade de a bateria acabar no treino."', true, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O cliente indeciso está vendo 5 modelos ao mesmo tempo. O que você faz?', 'Muita opção paralisa a decisão. Com base na sondagem, você já sabe o perfil do cliente — use isso para eliminar opções e apresentar no máximo 2 modelos. Isso demonstra expertise e facilita o fechamento.', 4)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Filtra para 2 opções pelo perfil levantado — "Pra você, o melhor é um destes dois"', true, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Apresenta todos os 5 modelos com prós e contras para o cliente escolher com informação', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Deixa o cliente em paz para não criar pressão — ele vai decidir quando estiver pronto', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Recomenda o modelo mais caro, já que qualidade sempre justifica o investimento', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Como você usa a experiência tátil para derrubar a indecisão do cliente?', 'A experiência tátil é uma das ferramentas mais poderosas do atendimento presencial. Quando o cliente coloca o relógio no pulso, ele começa a se imaginar usando — e a decisão se torna emocional, não só racional.', 5)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Mostra fotos e vídeos do produto no celular para ilustrar as funções em uso real', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Entrega a caixa fechada para ele ter a experiência de abrir como se fosse o produto dele', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Pergunta ao cliente se poderia colocar o relógio no pulso dele — de forma natural e simpática', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Demonstra o relógio funcionando e pergunta se ele quer experimentar por conta própria', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente diz "O Apple Watch faz a mesma coisa." Como você responde?', 'Nunca desqualifique o concorrente diretamente. Apresente diferenciais concretos: bateria (dias vs horas), precisão de GPS (multibanda vs básico) e especialização esportiva. Deixe os fatos falarem.', 6)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Depende do que você prioriza — design e iPhone têm seu ponto forte no Apple Watch."', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Para treino a diferença é real: bateria de dias, GPS multibanda e 35 anos de algoritmos para atletas."', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"O Apple Watch é um produto muito inferior em tudo que envolve performance esportiva."', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"O Apple Watch é bom pra quem usa iPhone, mas o Garmin é melhor para esporte."', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Na finalização da venda, qual ação cria um momento poderoso de personalização?', 'Configurar o nome do cliente no relógio na hora cria um momento de pertencimento — o produto já é dele antes de sair da loja. Apresentar o Garmin Connect brevemente garante que ele vai usar o produto corretamente.', 7)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Entregar um brinde personalizado para criar memória afetiva com a marca Garmin', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Embalar o produto com cuidado e capricho para reforçar a qualidade na entrega', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Oferecer condições de parcelamento diferenciadas para facilitar a decisão de compra', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Configurar o nome do cliente no relógio e mostrar o Garmin Connect rapidamente', true, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente de corrida comprou o relógio. Como você aborda a venda do Shokz de forma natural?', '"Para completar a experiência de corrida" conecta o produto ao momento do cliente. O convite para mostrar abre a conversa sem pressão. Não é forçar venda — é completar a experiência.', 8)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Corrida é com Shokz — condução óssea, você ouve música e ainda escuta o ambiente. Posso mostrar?"', true, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Se tiver interesse em acessórios, temos fones que podem complementar sua experiência."', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Aproveitando que gosta de corrida, o Shokz é bem popular — quer que eu mostre?"', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Prefiro não mencionar outros produtos para não parecer que estou forçando mais vendas."', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente diz "Vou pensar e volto depois." Como você responde sem pressionar?', 'Respeite a decisão sem pressionar. O objetivo é garantir que o cliente saia com informação suficiente e com uma ponte de contato (WhatsApp). Isso mantém o relacionamento e aumenta a chance de fechar por mensagem.', 9)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Se sair sem comprar não garantimos estoque — esse modelo está saindo bastante esta semana."', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Consigo uma condição especial de preço hoje, mas só consigo manter até o fim do dia."', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Claro! Posso anotar o modelo pra você? Se surgir dúvida, me chama no WhatsApp."', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Sem problema, fique à vontade — a gente está aqui quando você decidir voltar."', false, null, 3);

end $$;

-- ── Quiz Técnico — Instinct 3 (10 perguntas) ──
insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
values ((select id from brands where slug = 'garmin'), 'instinct-3', 'Quiz Técnico — Instinct 3', 70.00, true)
on conflict (brand_id, slug) do nothing;

do $$
declare
  v_quiz_id uuid;
  v_q_id uuid;
begin
  select id into v_quiz_id from quizzes where brand_id = (select id from brands where slug = 'garmin') and slug = 'instinct-3';

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Quais são as funções principais do botão CTRL (LIGHT) no Instinct 3 Solar?', 'O botão CTRL (LIGHT) liga o dispositivo e a iluminação da tela. Mantê-lo pressionado por ~2s abre o menu de controles. 5s ativa a solicitação de assistência. Duas pressões rápidas ligam/desligam a lanterna (Torch).', 0)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Liga o dispositivo, controla a iluminação e, ao manter pressionado, abre controles rápidos e assistência', true, 'Acertou! Você já está no nível de pegar o relógio da mão do cliente e sair mostrando função escondida.', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Liga o relógio, abre automaticamente o menu de atividades e ativa GPS em toque longo', false, 'Quase convenceu! Parece função premium, mas o GPS não manda no relógio inteiro.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É responsável apenas pela lanterna e brilho da tela', false, 'O CTRL ficou levemente ofendido de ser reduzido a um botão de brilho.', 2);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Como o usuário deve interpretar o gráfico de carregamento solar?', 'O Instinct 3 Solar mostra a intensidade de exposição solar das últimas 6 horas e a média da semana anterior. Não informa % exata de bateria gerada. A Power Glass™ não exige calibração pelo usuário.', 1)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Mostra exatamente quantos % de bateria foram gerados pela luz solar', false, 'Parece técnico o bastante pra soar convincente numa conversa rápida 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Exibe intensidade de exposição solar recente e média, ajudando a entender eficiência do ambiente para carga', true, 'Boa! Agora você já consegue explicar o Solar sem cair no ''ele carrega sozinho e pronto''.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Indica quando a lente Power Glass™ precisa de calibração', false, 'Se tivesse que calibrar lente solar, metade das pessoas desistia no primeiro dia.', 2);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Como personalizar o visor do relógio (Watch Face)?', 'No visor principal, mantenha MENU pressionado e selecione ''Visor do relógio''. Com UP/DOWN navegue pelas opções. Selecione ''Adicionar'' para criar um visor personalizado, ajustando dados exibidos, cor de fundo e cor de destaque.', 2)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Pelo Garmin Connect apenas, sem possibilidade de edição no relógio', false, 'Quase! O app ajuda bastante, mas o relógio também gosta de independência.', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Mantendo MENU pressionado no visor principal e escolhendo opções de personalização', true, 'Acertou! Essa é daquelas demonstrações que fazem o cliente ficar mexendo no relógio por 10 minutos.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Pressionando GPS e escolhendo um tema automático', false, 'O GPS entrou numa função que nem era dele 😭', 2);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Como o usuário registra uma captura durante a atividade de Pesca no Instinct 3?', 'Na atividade Pesca, pressione GPS e selecione ''Registrar captura''. Isso incrementa o contador de peixes e salva a localização geográfica exata para análise posterior no Garmin Connect.', 3)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O relógio detecta o movimento de lançada automaticamente e registra cada captura', false, 'O relógio ainda não aprendeu a interpretar gesto de lançada — por enquanto precisa de ajuda humana 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Pressiona GPS e seleciona ''Registrar captura'' — incrementa o contador e salva a localização no GPS', true, 'Acertou! Você já pode ajudar o pescador a mapear os melhores pontos do lago.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O relógio marca automaticamente a posição a cada parada prolongada durante a atividade', false, 'Parada prolongada seria uma armadilha — o pescador fica parado a tarde toda esperando mordida 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Sincroniza com o app Garmin Connect ao final para registrar as capturas por coordenadas', false, 'Sincronizar só no final perderia a localização exata de cada ponto — e esse é o pulo do gato.', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que é e para quem serve o Applied Ballistics® presente no Instinct 3 Solar Tactical Edition?', 'O Applied Ballistics® é uma solução de mira para tiro de precisão de longo alcance. O relógio calcula correções de elevação e vento, integrando-se ao app Applied Ballistics Quantum para gerenciar perfis complexos de armas e munições.', 4)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É um giroscópio avançado para medir estabilidade do relógio em atividades de alto impacto', false, 'O giroscópio agradece a menção, mas ele não resolve correção de vento pra 1km de distância 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Calcula a altitude de salto em paraquedas usando dados balísticos de queda livre', false, 'Boa tentativa misturando dois modos táticos — mas o Jumpmaster já cuida dos saltos.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Solução de mira para tiro de longo alcance — calcula correções de elevação e vento integrada ao app Applied Ballistics Quantum', true, 'Acertou! Esse é o tipo de função que faz o cliente militar entrar em modo ''eu preciso disso''.', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Mede velocidade de impacto e força G em esportes de contato como mountain bike e trail', false, 'O ciclista agradece, mas para isso já existem sensores de impacto muito mais simples.', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual a vantagem do modo Jumpmaster para o público militar e paraquedista?', 'O modo Jumpmaster segue diretrizes militares para calcular o ponto de salto de alta altitude (HARP) em três modalidades: HAHO, HALO e Estático. Usa o barômetro e a bússola para guiar o usuário até o ponto de impacto desejado (DIP).', 5)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Segue diretrizes militares para calcular o ponto de salto (HARP) em modalidades HAHO, HALO e Estático, usando barômetro e bússola', true, 'Acertou! Você já pode convencer um militar de que o relógio dele faz mais do que ele imaginava.', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Registra altitude máxima e mínima durante o salto para análise de performance pós-voo', false, 'Analisar performance do salto é bacana, mas o Jumpmaster é sobre navegar até o ponto certo, não medir o voo 😭', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Monitora frequência cardíaca e saturação de oxigênio em altitude para segurança do paraquedista', false, 'O oxímetro ajuda em altitude, mas o Jumpmaster é sobre chegar no lugar certo, não sobre como o coração está 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Calcula automaticamente o momento ideal para abrir o paraquedas e emite um alerta de vibração', false, 'O relógio seria responsabilizado por muita coisa se errasse o timing aí 😭', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Quais são os diferenciais exclusivos do Stealth Mode e do Kill Switch na Tactical Edition?', 'O Modo Stealth interrompe o armazenamento e compartilhamento de localização GPS e desativa conexões sem fio. O Kill Switch (Interruptor de Bloqueio) limpa todos os dados do usuário e restaura o padrão de fábrica em 10 segundos, protegendo informações sensíveis.', 6)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Stealth Mode escurece a tela para uso noturno; o Kill Switch desativa o alarme sonoro em campo', false, 'Parece configuração de relógio casual — nada contra, mas a Tactical Edition é outra dimensão 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Stealth Mode pausa as atividades de treino; o Kill Switch reinicia o relógio em caso de travamento', false, 'O Kill Switch como botão de reinício seria um reset bem radical pro cliente 😭', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Stealth Mode desativa a tela para economia; o Kill Switch bloqueia os botões contra acionamento acidental', false, 'Bloquear botões é função de qualquer relógio — o Kill Switch vai muito além disso.', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Stealth Mode interrompe GPS e conexões sem fio; o Kill Switch limpa todos os dados e restaura o padrão de fábrica em 10 segundos', true, 'Acertou! Esse é o tipo de função que faz o cliente de operações especiais parar de olhar o catálogo.', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que são os sensores ABC do Instinct 3 e para que servem?', 'Os sensores ABC do Instinct 3 são: Altímetro (mede altitude pela pressão do ar), Barômetro (monitora variações de pressão para prever clima) e Bússola (orientação magnética). São fundamentais para navegação off-road e montanhismo.', 7)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Altímetro, Barômetro e Bússola — usados para navegação e monitoramento de variações climáticas', true, 'Acertou! ABC é clássico e qualquer cliente que adora trilha vai amar saber disso.', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Acelerômetro, Bluetooth e Capacitor solar — sistema de conectividade e recarga integrada', false, 'Bluetooth não é sensor — ele só conversa com outros aparelhos, não mede o ambiente 😭', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Altitude Beacon Controller — sistema integrado de alerta de altitude e variação de pressão', false, 'Altitude Beacon Controller soa como função de farol de aeronave 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Monitor de Atividade, Biometria e Controle de Carga — sensores de bem-estar integrados', false, 'Biometria, Atividade e Controle seria um bom nome, mas os sensores reais são outros.', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Como funciona o Storm Alert (Alerta de Tempestade) do Instinct 3?', 'O Storm Alert monitora continuamente a pressão barométrica. Quando detecta uma queda rápida de pressão (≥4 mbar em 3 horas), emite uma vibração de alerta indicando possibilidade de tempestade iminente.', 8)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Usa o GPS para verificar a previsão do tempo online e exibe alertas baseados em dados meteorológicos', false, 'O relógio não tem internet — seria ótimo, mas ele mede o ambiente, não consulta app de tempo 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Mede temperatura e umidade do ar para prever precipitação nas próximas 6 horas', false, 'Temperatura e umidade ajudam, mas a variação de pressão é o indicador mais confiável de tempestade.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Emite um alerta quando a pressão barométrica cai rapidamente, indicando possível tempestade', true, 'Acertou! Agora você sabe explicar por que o Instinct 3 é mais esperto que a maioria dos apps de tempo.', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Detecta interferência eletromagnética de raios e ativa o modo de emergência com localização', false, 'Detector de raios seria incrível, mas por enquanto o barômetro ainda cuida desse trabalho 😭', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que é o Expedition Mode e qual o seu principal benefício?', 'O Expedition Mode reduz a frequência de gravação de GPS (registra posição a cada minuto ou mais), eliminando a atualização contínua. Isso estende drasticamente a duração da bateria para expedições de múltiplos dias.', 9)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Desativa todos os sensores exceto o barômetro para máxima economia em campo', false, 'Só o barômetro sozinho não guia ninguém por uma expedição de 10 dias 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Reduz a frequência de gravação do GPS para marcações periódicas — ideal para travessias de vários dias', true, 'Acertou! Agora já dá pra explicar por que o Instinct 3 dura semanas em uso real de campo.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Entra em modo de carregamento contínuo, priorizando a bateria solar sobre as funções', false, 'Modo de carregamento prioritário seria ótimo no inverno, mas o sol não trabalha por agendamento 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Limita o relógio ao modo básico de horas, desativando funções esportivas e de saúde', false, 'Desativar tudo seria triste demais pra um relógio desse nível 😭', 3);

end $$;

-- ── Quiz Técnico Garmin (10 perguntas) ──
insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
values ((select id from brands where slug = 'garmin'), 'metricas-tecnicas', 'Quiz Técnico Garmin', 70.00, true)
on conflict (brand_id, slug) do nothing;

do $$
declare
  v_quiz_id uuid;
  v_q_id uuid;
begin
  select id into v_quiz_id from quizzes where brand_id = (select id from brands where slug = 'garmin') and slug = 'metricas-tecnicas';

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que é o Body Battery™ e como ele auxilia no gerenciamento de energia do atleta?', 'O Body Battery™ é uma métrica de 5 a 100 que estima a reserva de energia corporal. Recarrega com sono e repouso, sendo reduzida por estresse e exercícios intensos. Sono de qualidade é o principal fator de recarga.', 0)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Uma métrica de recuperação baseada apenas na intensidade do treino recente', false, 'Faz sentido à primeira vista, mas o relógio repara quando a pessoa dormiu 4 horas e quer agir como atleta olímpico 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Um indicador de energia corporal influenciado por sono, estresse e atividade física', true, 'Boa! Essa costuma ser uma das funções que faz o cliente pensar: ''ok… talvez eu precise desse relógio''.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Uma nota diária calculada exclusivamente pela frequência cardíaca média', false, 'O coração ajuda, mas ele sozinho não segura toda a responsabilidade 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Uma pontuação baseada no número de passos e calorias gastas no dia', false, 'Passos e calorias contribuem, mas o sono é o principal motor de recarga do Body Battery.', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual o requisito para gerar o Status de VFC (Variabilidade da Frequência Cardíaca)?', 'O relógio analisa a variabilidade cardíaca durante o sono. Para criar uma linha de base pessoal e gerar um status (equilibrado, baixo ou desequilibrado) são necessárias três semanas de dados consistentes de sono.', 1)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Três semanas de dados consistentes de sono', true, 'Acertou! O relógio primeiro conhece o dono antes de sair julgando a fisiologia dele.', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Quatorze dias de treinos acima de 70% da frequência cardíaca máxima', false, 'Você misturou um pouco com os requisitos do VO2 Máximo 😭', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Sete dias de uso contínuo com atualização recente do software', false, 'Atualizar o relógio sempre ajuda, mas aqui o segredo é paciência e sono regular.', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Sincronização diária com o Garmin Connect por pelo menos 10 dias', false, 'Sincronizar ajuda, mas o dado que importa é o que acontece à noite, não a transferência.', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Como o PacePro™ otimiza a estratégia de pace de um corredor?', 'O PacePro™ cria um plano de ritmo personalizado baseado no percurso. Analisa mudanças de elevação e sugere ajustes de velocidade em tempo real, ajudando o corredor a atingir a meta sem esgotamento nas subidas.', 2)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Ajusta automaticamente as zonas cardíacas conforme o cansaço do atleta ao longo do percurso', false, 'Parece função premium o suficiente pra existir, confesso 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Cria um plano de ritmo considerando a elevação do percurso e a meta de tempo final', true, 'Boa! O corredor ainda sofre na subida, mas agora sofre com planejamento.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Mantém um pace fixo e constante do início ao fim para evitar variações de velocidade', false, 'Pace fixo em corrida com desnível positivo seria uma conversa difícil com as pernas 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Calcula o pace médio dos últimos 5 treinos e sugere esse ritmo para a próxima corrida', false, 'Média dos últimos treinos é dado útil, mas o PacePro olha para o percurso à frente, não para o passado.', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Quais são os critérios técnicos para obter estimativas de VO2 Máximo precisas?', 'Para corrida: ao ar livre com GPS ativo, mantendo ≥70% da FC máxima por 10 minutos. Para ciclismo: obrigatório medidor de potência + monitor cardíaco, por pelo menos 20 minutos em intensidade moderada a alta.', 3)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Corrida ao ar livre com GPS ativo e intensidade mínima de 70% da FC máxima; no ciclismo, medidor de potência e FC', true, 'Acertou! Agora já dá pra responder aquele cliente que pergunta ''mas esse dado é confiável?'' 😌', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Qualquer treino cardiovascular acima de 20 minutos com frequência cardíaca ativa no relógio', false, 'Parece convincente, mas o relógio é um pouco mais exigente que isso 😭', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Caminhada rápida com monitor cardíaco por pelo menos 10 minutos consecutivos em ritmo estável', false, 'Se fosse tão fácil, toda caminhada até a padaria virava dado de performance avançada 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Natação em piscina ou corrida em esteira com velocidade constante por no mínimo 30 minutos', false, 'Esteira sem GPS externo e natação sem os critérios corretos não geram VO2 Máximo preciso.', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Como interpretar as categorias do Status de Treino?', 'O Status de Treino avalia o impacto da carga no condicionamento. Categorias: Produtivo (evolução consistente), Mantendo (carga estável), Recuperação (estímulo leve), Ultrapassando Limites (carga excessiva, risco de fadiga/lesão).', 4)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O recurso mostra se a carga está ajudando, mantendo ou prejudicando a evolução física do usuário', true, 'Boa! O relógio basicamente responde: ''você está evoluindo ou só colecionando cansaço?'' 😄', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É uma classificação da intensidade cardíaca diária comparada com a média da semana anterior', false, 'O coração participa da conversa, mas ele não toma todas as decisões sozinho 😭', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O resultado depende principalmente da distância total percorrida nos últimos sete dias', false, 'O velocista e o maratonista com a mesma distância poderiam ter statuses bem diferentes 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Avalia exclusivamente a qualidade do sono e do estresse para indicar o estado de recuperação', false, 'Sono e estresse são fatores do Body Battery — o Status de Treino olha para a carga de exercício.', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que representa a métrica de Carga Aguda?', 'A Carga Aguda é a soma ponderada das pontuações de carga de exercícios dos últimos 7 dias. Ajuda a entender se o volume atual de treino está dentro de uma faixa ideal para melhorar o condicionamento sem causar exaustão.', 5)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'A intensidade do treino mais recente, usada para calcular o intervalo mínimo de descanso', false, 'Faz sentido pensar assim, mas o relógio gosta de olhar o filme da semana, não só o episódio do dia 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'A soma ponderada das pontuações de carga dos exercícios realizados nos últimos sete dias', true, 'Acertou! Agora você sabe explicar por que treinar forte todo dia nem sempre significa treinar melhor.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O tempo estimado necessário para recuperação muscular antes do próximo treino intenso', false, 'Recuperação e carga até são parentes próximos, mas moram em abas diferentes 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'A média de esforço percebido registrado manualmente pelo usuário na semana', false, 'Esforço percebido manual é útil, mas a Carga Aguda é calculada automaticamente pelo relógio.', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Como funciona o recurso de Treino Sugerido Diariamente?', 'O algoritmo considera VO2 Máximo, Status de Treino, tempo de recuperação e histórico recente para sugerir um treino de corrida ou ciclismo específico para aquele dia. Não é exclusivo para avançados — usuários de diferentes níveis recebem recomendações adaptadas.', 6)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O relógio entrega treinos padronizados iguais para qualquer usuário independente do perfil', false, 'Se fosse assim, sedentário e maratonista iam sofrer juntos por igualdade esportiva 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O sistema analisa histórico, recuperação, VO2 máximo e carga recente para sugerir treinos específicos', true, 'Boa! É praticamente um treinador pessoal… só que sem bronca quando você ignora o treino.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O recurso funciona apenas para atletas avançados ou corredores com pelo menos 6 meses de uso', false, 'O iniciante pediu inclusão e o relógio atendeu — é para todos os níveis.', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Sincroniza planos de treino do Garmin Connect criados por um treinador externo para o dia', false, 'Sincronizar plano de treinador é função separada — o Treino Sugerido é gerado pelo algoritmo do relógio.', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Como o Descanso Automático facilita o treino de natação em piscina?', 'Exclusivo para natação em piscina, o relógio detecta quando o usuário para na parede. Se o repouso exceder 15 segundos, um intervalo de descanso é criado automaticamente. Ao retomar o nado, inicia um novo intervalo sem apertar nenhum botão.', 7)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O relógio vibra a cada 25 metros para sinalizar que o intervalo de descanso deve começar', false, 'Vibrar a cada 25 metros seria um treino de reflexo condicionado além da natação 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O usuário pressiona GPS na parede para registrar o intervalo manualmente a cada série', false, 'Se precisasse apertar botão molhado na parede a cada série, metade das pessoas desistiria do treino.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O relógio detecta a parada na parede — se ultrapassar 15 segundos, cria um intervalo automático', true, 'Acertou! Essa é uma das funções que faz o nadador largar o cronômetro do celular de vez.', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O modo pausa é ativado quando a frequência cardíaca cai abaixo do limiar aeróbico', false, 'Frequência cardíaca na piscina funciona, mas não é ela que define o intervalo aqui 😭', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Para que serve o Registro de Exercícios (Drill Logging) na natação?', 'O Drill Logging permite registrar manualmente o tempo e a distância de exercícios que o relógio não detecta automaticamente, como trabalho de pernas com prancha ou nado lateral, garantindo que o esforço total seja contabilizado.', 8)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Permite criar treinos estruturados com séries e intervalos programados antes de entrar na piscina', false, 'Isso seria o modo de treino estruturado — o Drill Logging resolve um problema diferente 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Grava automaticamente exercícios de perna detectando a ausência de braçadas por mais de 10 segundos', false, 'Detectar ausência de braçadas seria criativo, mas o relógio precisaria entender de pedagogia aquática 😭', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Sincroniza treinos do treinador pelo Garmin Connect e os exibe na tela durante a atividade', false, 'Sincronizar treino do professor é função separada — o Drill Logging é sobre o que o relógio não mede.', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Registra manualmente tempo e distância de exercícios que o relógio não detecta, como nado com prancha', true, 'Acertou! Essa função garante que o esforço real do treino seja contabilizado, mesmo fora do padrão.', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que faz o Race Predictor (Previsor de Corrida) do Garmin?', 'O Race Predictor usa o VO2 Máximo estimado para calcular tempos de chegada previstos em distâncias padrão (5K, 10K, meia maratona e maratona). Fica disponível após o relógio ter dados suficientes de corrida para estimar o condicionamento atual.', 9)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Estima tempos de chegada para 5K, 10K, meia e maratona com base no VO2 Máximo atual do usuário', true, 'Acertou! É o tipo de dado que faz o cliente olhar pro relógio e pensar ''minha meta de maratona está mais perto''.', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Calcula a velocidade mínima necessária para bater um recorde pessoal com base no histórico', false, 'Bater recorde exige mais do que matemática de velocidade — o Race Predictor não trabalha com histórico assim 😭', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Usa o GPS e a frequência cardíaca para estimar o tempo restante de qualquer corrida em andamento', false, 'Tempo restante da atividade existe, mas não é o Race Predictor — ele olha pro futuro, não pro momento.', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Prevê o risco de lesão com base na carga de treino e sugere redução de intensidade preventiva', false, 'Previsão de lesão seria o recurso mais temido por quem prefere treinar na raça 😭', 3);

end $$;

-- ── Quiz Especial — Cintas Cardíacas (HRM) (12 perguntas) ──
insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
values ((select id from brands where slug = 'garmin'), 'cintas-hrm', 'Quiz Especial — Cintas Cardíacas (HRM)', 70.00, true)
on conflict (brand_id, slug) do nothing;

do $$
declare
  v_quiz_id uuid;
  v_q_id uuid;
begin
  select id into v_quiz_id from quizzes where brand_id = (select id from brands where slug = 'garmin') and slug = 'cintas-hrm';

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual é a principal diferenciação técnica entre o HRM-Fit e o HRM-Pro Plus em relação ao ambiente aquático?', 'O HRM-Fit possui resistência de 3 ATM e não é indicado para natação. O HRM-Pro Plus tem resistência de 5 ATM e suporte oficial para registrar frequência cardíaca durante atividades subaquáticas.', 0)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O HRM-Fit foi desenvolvido com vedação especial de 10 ATM para suportar mergulhos profundos, enquanto o HRM-Pro Plus é limitado a 5 ATM para natação de superfície', false, '10 ATM seria nível de mergulho profissional — nenhum dos dois chega nem perto disso 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O HRM-Fit possui resistência de 3 ATM e não é indicado para natação, enquanto o HRM-Pro Plus tem resistência de 5 ATM e possui suporte oficial para registrar dados de FC subaquática', true, 'Exato! 3 ATM no HRM-Fit (sem natação) vs 5 ATM no Pro Plus (com suporte oficial subaquático).', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Ambos os monitores possuem exatamente a mesma classificação de 5 ATM, porém o HRM-Fit só transmite dados de natação via Bluetooth, enquanto o Pro Plus utiliza exclusivamente ANT+', false, '5 ATM nos dois e a diferença sendo só o protocolo de transmissão? O HRM-Fit nem chega a essa classificação 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O HRM-Fit e o HRM-Pro Plus possuem a mesma resistência de 3 ATM, sendo ambos indicados apenas para exposição ocasional a respingos de água', false, '3 ATM nos dois empataria a resistência, mas o Pro Plus vai além — tem 5 ATM e suporte à natação 😭', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'De acordo com o manual do proprietário, o HRM 200 é tecnicamente indicado para o registro de dados de natação?', 'O HRM 200 possui resistência de 3 ATM, suportando apenas exposição ocasional a água e produtos químicos de limpeza. O manual não lista a natação como atividade suportada para o registro de dados — diferente do HRM-Pro Plus e HRM 600.', 1)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Sim, ele possui memória interna dedicada para gravar sessões de natação em águas abertas, com sincronização automática ao sair da água', false, 'Memória dedicada para natação seria um recurso e tanto, mas o HRM 200 não tem esse propósito 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Sim, ele sincroniza os dados via Bluetooth em tempo real mesmo durante mergulhos, desde que o relógio esteja a menos de 3 metros do monitor', false, 'Bluetooth funcionando durante mergulho contraria a própria física da transmissão de rádio na água 😭', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Não; embora suporte exposição ocasional a produtos químicos para limpeza, sua resistência é de 3 ATM e o manual não lista a natação como atividade suportada para registro de dados', true, 'Correto! O HRM 200 tem resistência de 3 ATM e a natação não está entre as atividades suportadas pelo manual.', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Sim, mas apenas em modo limitado, registrando exclusivamente a frequência cardíaca média ao final da sessão, sem dados em tempo real', false, 'Mesmo em modo limitado, a natação simplesmente não está na lista de atividades suportadas pelo manual 😭', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual é o objetivo e a funcionalidade do recurso ''Gravação de Atividade'' mencionado no manual do HRM 600?', 'O recurso ''Gravação de Atividade'' do HRM 600 permite iniciar e registrar um treino cronometrado diretamente pelo app Garmin Connect no celular — útil em esportes coletivos onde o uso de relógio no pulso é proibido pelas regras da modalidade.', 2)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Permite que o usuário inicie e registre um treino cronometrado diretamente pelo app Garmin Connect no celular, ideal para esportes coletivos onde o uso de relógio no pulso é proibido', true, 'Exato! O recurso permite gravar a atividade direto pelo app no celular — ótimo para esportes coletivos sem relógio no pulso.', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Funciona como um sistema de captura de voz integrado ao módulo, permitindo gravar notas durante o treino que são anexadas ao resumo da atividade', false, 'Captura de voz seria criativo, mas o HRM 600 não tem microfone para isso 😭', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Ativa um GPS interno de baixo consumo que mapeia a rota do atleta de forma independente, dispensando conexão com smartphone ou smartwatch', false, 'GPS interno autônomo no módulo de peito ainda não existe nessa linha de produtos 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Permite armazenar até 30 dias de histórico de frequência cardíaca em repouso, sincronizando automaticamente ao reconectar com qualquer dispositivo Garmin', false, '30 dias de histórico em repouso é um recurso de relógios Garmin, não do módulo HRM 600 isoladamente 😭', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Sobre o HRM 600, qual é a orientação do manual quanto ao uso do recurso de gravação em treinos de natação?', 'O recurso de gravação direta pelo celular não é indicado para natação. Para nadar e salvar os dados corretamente, o usuário deve iniciar a atividade cronometrada em um dispositivo Garmin emparelhado (relógio ou ciclocomputador).', 3)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O recurso de gravação via celular deve ser usado obrigatoriamente na natação em águas abertas, garantindo a precisão do GPS do telefone nos dados cardíacos', false, 'GPS do celular dentro d''água nem captaria sinal — e essa não é a orientação do manual para natação 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Esse recurso de gravação direta pelo celular não é indicado para natação; para nadar e salvar os dados, o usuário deve iniciar a atividade cronometrada em um dispositivo Garmin emparelhado', true, 'Correto! Para natação, a gravação precisa ser feita por um dispositivo Garmin emparelhado, não pelo app do celular.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O HRM 600 só permite gravação da natação se a bateria interna estiver acima de 50%, caso contrário o módulo desativa o armazenamento para priorizar transmissão em tempo real', false, 'Limite de bateria de 50% para natação é uma regra que não existe no manual do HRM 600 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'A gravação via celular funciona normalmente na natação, desde que o smartphone esteja protegido em capa impermeável certificada IPX8', false, 'Capa impermeável no celular não resolve — o problema é a indicação do recurso, não a proteção do aparelho 😭', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O acelerômetro interno do HRM-Pro Plus calcula seis métricas de Dinâmica de Corrida. Quais são elas?', 'Estas seis métricas formam o conjunto avançado de Dinâmicas de Corrida, utilizando o movimento do torso para análise de biomecânica. O HRM-Pro Plus as transmite via ANT+ ou tecnologia Bluetooth SIG.', 4)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Cadência, Velocidade, Potência, VO2 Máximo, Altitude e Frequência Máxima', false, 'Potência e altitude não fazem parte das 6 dinâmicas de corrida do HRM-Pro Plus 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Cadência, Oscilação Vertical, Tempo de Contato com o Solo, Equilíbrio, Comprimento de Passo e Proporção Vertical', true, 'Exato! Essas seis métricas formam o conjunto completo de Dinâmicas de Corrida via torso.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Passos por Minuto, Calorias, TrueUp, GPS Interno, Ritmo e Distância', false, 'TrueUp e GPS são recursos diferentes — não são métricas de biomecânica 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Frequência Cardíaca, Step Speed Loss, Cadência, Potência, VO2 e Altitude', false, 'Step Speed Loss é exclusiva do HRM 600, não do Pro Plus 😭', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Como o HRM-Pro Plus gerencia a transmissão de dados durante atividades de natação?', 'Dados de natação não são transmitidos em tempo real sob a água devido à atenuação do sinal de rádio no meio líquido. O monitor armazena as informações e as descarrega automaticamente ao salvar a atividade fora da água.', 5)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Transmite dados em tempo real via Bluetooth SIG mesmo sob a água', false, 'Bluetooth e água não são amigos — o sinal não atravessa o meio líquido 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Armazena os dados e os transmite para o relógio durante os intervalos de descanso fora da água', true, 'Perfeito! O monitor armazena tudo e descarrega ao salvar a atividade fora da água.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Utiliza a frequência de 2,4 GHz para transmissão contínua enquanto submerso', false, '2,4 GHz também não viaja bem embaixo d''água — valeu pela criatividade 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Sincroniza os dados automaticamente via Wi-Fi ao sair da piscina', false, 'O HRM-Pro Plus não usa Wi-Fi para essa sincronização 😭', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Quais métricas podem ser sincronizadas via TrueUp™ quando o HRM-Pro Plus é utilizado sem um relógio Garmin?', 'O recurso TrueUp™ permite a sincronização independente de passos, calorias e minutos de intensidade com o Garmin Connect. O sensor funciona de forma autônoma quando o usuário não está vestindo o relógio.', 6)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Apenas a frequência cardíaca média da atividade', false, 'Só frequência cardíaca média seria desperdiçar o potencial do TrueUp™ 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Mapa de calor da atividade e oscilação lateral do torso', false, 'Mapa de calor e oscilação lateral não são sincronizados pelo TrueUp™ 😭', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Passos, calorias, minutos de intensidade e frequência cardíaca diária', true, 'Exato! O sensor funciona de forma autônoma e sincroniza essas métricas de bem-estar.', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Dinâmicas de corrida completas incluindo proporção vertical e equilíbrio', false, 'As dinâmicas de corrida precisam do relógio para serem transmitidas em tempo real 😭', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'No HRM 200, como o usuário alterna entre os modos de conexão ''Segura'' (Bluetooth SIG) e ''Aberta'' (ANT+)?', 'O HRM 200 introduz um botão físico para alternar entre conexões Seguras (Bluetooth SIG) e Abertas (ANT+). Isso aumenta a flexibilidade de pareamento com diversos ecossistemas de dispositivos.', 7)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Realizar a troca exclusivamente pelo aplicativo Garmin Connect™', false, 'O app ajuda em muita coisa, mas aqui o botão físico é o caminho 😅', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Pressionar o botão físico no módulo duas vezes rapidamente', true, 'Certo! Dois toques rápidos no botão físico do módulo fazem a alternância.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Manter o botão pressionado por 15 segundos até o LED desligar', false, '15 segundos seria um reset, não uma troca de modo de conexão 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Remover e reinserir a bateria com o módulo próximo ao relógio', false, 'Reinserir a bateria é para manutenção, não para trocar o protocolo 😭', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual inovação de design facilita a substituição da bateria na faixa do HRM 200?', 'O design inovador do HRM 200 integra a ferramenta de abertura no controle deslizante de ajuste da própria faixa. Esta solução elimina a necessidade de chaves externas para trocar a bateria CR2032.', 8)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Acompanha uma chave de fenda de precisão na embalagem para abrir a tampa', false, 'Chave de fenda na embalagem seria prático, mas a Garmin foi além 😅', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Possui uma tampa de abertura manual que dispensa qualquer ferramenta', false, 'Manual sem ferramenta seria ótimo, mas aqui tem uma ferramenta camuflada no design 😭', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O controle deslizante de ajuste de tamanho da faixa funciona como ferramenta para abrir a tampa da bateria', true, 'Correto! O slider de ajuste da faixa dupla função: ajuste de tamanho e abertura da tampa.', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'A tampa é removida por pressão com a própria thumbnail (unha do polegar)', false, 'Usar a própria unha seria solução improvável para um produto de engenharia Garmin 😭', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual é o procedimento obrigatório para ativar o HRM 600 antes do primeiro uso?', 'O HRM 600 exige uma conexão a uma fonte de energia por 2 segundos para sair do modo de fábrica. Este procedimento é único deste modelo devido ao seu sistema de bateria interna recarregável.', 9)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Agitar o módulo por 10 segundos para despertar o acelerômetro', false, 'Agitar o acelerômetro é uma interpretação criativa, mas não é o procedimento oficial 😅', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Molhar os eletrodos e correr por 1 quilômetro para calibração inicial', false, 'Correr 1 km seria um aquecimento com propósito, mas não é o que o manual pede 😭', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Conectar o módulo a uma fonte de energia por 2 segundos', true, 'Exato! 2 segundos conectado à energia tira o HRM 600 do modo de fábrica. Único do 600.', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Parear o módulo ao relógio via Bluetooth antes de qualquer atividade', false, 'Parear sem ativar primeiro não funciona — o modo de fábrica bloqueia o dispositivo 😭', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual métrica de dinâmica de corrida é exclusiva do HRM 600 e qual sua unidade de medida?', 'A ''Perda de velocidade dos passos'' (Step Speed Loss) é exclusiva do HRM 600, medida em cm/s. Ela indica o quanto o corredor desacelera no impacto, auxiliando na melhoria da eficiência propulsiva.', 10)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Comprimento de passo, medida em milímetros', false, 'Comprimento de passo existe no Pro Plus também — não é exclusividade do 600 😭', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Proporção Vertical, medida em batimentos por minuto', false, 'Proporção Vertical é medida em % (percentual), não em BPM 😭', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Perda de velocidade dos passos (Step Speed Loss), medida em cm/s', true, 'Correto! Step Speed Loss em cm/s é a exclusividade do HRM 600 — mede a desaceleração no impacto.', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Oscilação Vertical, medida em graus por segundo', false, 'Oscilação Vertical é medida em milímetros, e também está no Pro Plus 😭', 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual é a frequência correta de higienização dos sensores de frequência cardíaca Garmin e quais substâncias devem ser evitadas?', 'O enxágue após cada uso remove o sal do suor; a lavagem manual após cada 7 usos preserva a elasticidade. Máquina de lavar/secar é proibida. Substâncias como EDTA e propilenoglicol (presentes em cosméticos e repelentes) degradam quimicamente a faixa.', 11)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Lavagem na máquina após cada uso; evitar apenas água quente acima de 60°C', false, 'Máquina de lavar é terminantemente proibida pelos manuais Garmin 🚫', 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Enxágue após cada uso, lavagem manual após cada sete utilizações; evitar protetor solar, repelente e produtos com EDTA ou propilenoglicol', true, 'Perfeito! Enxágue frequente + lavagem a cada 7 usos + evitar cosméticos corrosivos. Manual ao pé da letra.', 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Lavagem com álcool isopropílico uma vez por mês; evitar sabão neutro e água morna', false, 'Álcool isopropílico danifica os materiais — o manual também proíbe isso 😭', 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Higienização apenas quando visível suor acumulado; evitar tecidos abrasivos no esfregão', false, 'Esperar o suor acumular é o caminho mais rápido para corroer os eletrodos 😭', 3);

end $$;

-- ── Módulo 3 — Linha de Produtos (10 perguntas) ──
insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
values ((select id from brands where slug = 'garmin'), 'produtos', 'Módulo 3 — Linha de Produtos', 70.00, true)
on conflict (brand_id, slug) do nothing;

do $$
declare
  v_quiz_id uuid;
  v_q_id uuid;
begin
  select id into v_quiz_id from quizzes where brand_id = (select id from brands where slug = 'garmin') and slug = 'produtos';

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual Forerunner é a opção mais compacta e leve para quem está começando a correr em 2026?', 'O Forerunner 70 é o lançamento 2026 mais compacto da linha, com GPS, HR óptico, Garmin Pay e até 11 dias de bateria. Ideal para iniciantes e como presente.', 0)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Forerunner 55', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Forerunner 165', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Forerunner 70', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Forerunner 265', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O Forerunner 170 se diferencia do FR165 principalmente por qual conjunto de recursos?', 'O FR170 (2025) é mais compacto que o FR165, traz sensor Elevate Gen 5, relatório noturno, despertador inteligente, registro de estilo de vida e mais perfis de atividade. Não tem GPS multibanda nem modo triathlon — para isso o FR265 em diante.', 1)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'GPS multibanda SatIQ e maior autonomia de bateria', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Design mais compacto, relatório noturno, despertador inteligente e mais perfis de atividade', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Cristal de safira, armazenamento de 32GB e modo triathlon', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Alto-falante integrado e modos de multiesporte avançados', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Para um corredor de alta performance que precisa de pelo menos 10h de bateria + de GPS com mapas, qual linha indicar?', 'O FR965 e FR970 são a referência da linha triatleta: mapas topográficos, multiesporte completo. O FR970 é o topo com cristal de safira.', 2)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Instinct 3 — Certificação militar e bateria de 26 dias', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Forerunner 965 ou 970 — linha triatleta com GPS de longa duração', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Fenix 8 — tela AMOLED e alto-falante', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Edge 1050 — GPS no guidão com tela 3.5"', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual é o principal diferencial do Enduro 3 em relação ao Fenix 8?', 'O Enduro 3 é especializado em endurance extremo — sua bateria de 70h+ em GPS contínuo é projetada para ultramaratonistas e expedições de múltiplos dias.', 3)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Tela AMOLED com maior resolução', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Resistência a mergulho técnico com nitrox', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Bateria de 70h+ em GPS contínuo para ultramaratonistas', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Alto-falante e microfone integrados', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Para um aventureiro que quer robustez e bateria de até 26 dias com GPS, qual modelo indicar?', 'O Instinct 3 tem certificação MIL-STD-810, bateria de até 26 dias, sensores ABC (altímetro, barômetro, bússola) e é o custo-benefício outdoor da Garmin.', 4)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Forerunner 570', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Instinct 3', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Venu 4', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Edge 850', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual ciclocomputador Edge é indicado para o ciclista que quer a maior tela, Garmin Pay e os recursos mais avançados?', 'O Edge 1050 tem tela 3.5" de 1000 nits, Garmin Pay, buzina e alerta de perigo — é o topo absoluto da linha Edge, indicado para ciclistas de alto nível.', 5)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Edge 540', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Edge 840', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Edge 850', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Edge 1050', true, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual linha Garmin é indicada para uma mulher que valoriza design elegante e monitoramento de saúde feminina?', 'A linha Lily 2 (design joia, a menor da Garmin) e a Venu 4 (AMOLED premium + saúde feminina completa) são as escolhas para o perfil mulher lifestyle.', 6)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Forerunner 55', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Instinct E', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Lily 2 ou Venu 4', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Edge 540', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente quer um relógio Garmin para academia e dia a dia, com 80+ modos esportivos e músicas offline. Qual indicar?', 'O Vivoactive 6 tem 80+ modos esportivos, músicas offline e é versátil para academia e uso diário — perfil lifestyle e fitness casual.', 7)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Forerunner 55', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Vivoactive 6', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Instinct 3', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Fenix 8', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual é a diferença principal entre o Edge 540 e o Edge 550?', 'Ambos têm GPS multibanda e são compactos, mas o Edge 550 (2025) adiciona tela de alta resolução, speaker e o Garmin Cycling Coach — o 540 é o modelo anterior mais básico.', 8)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O 550 tem GPS multibanda, o 540 não', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O 540 é touchscreen, o 550 tem apenas botões físicos', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O 550 adiciona tela de 1000 nits, alto-falante e Cycling Coach', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O 550 tem bateria de 50h, o 540 fica em 20h', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual relógio Garmin tem alto-falante, microfone, modo mergulho e mapas completos — sendo considerado o multiesporte definitivo?', 'O Fenix 8 é o multiesporte definitivo da Garmin: alto-falante, microfone, modo mergulho certificado, mapas topográficos completos e suporte a todas as atividades.', 9)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Forerunner 970', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Instinct 3 Solar Tactical', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Fenix 8', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Enduro 3', false, null, 3);

end $$;

-- ── Módulo 4 — Cenários de Concorrência (8 perguntas) ──
insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
values ((select id from brands where slug = 'garmin'), 'concorrencia-cenarios', 'Módulo 4 — Cenários de Concorrência', 70.00, true)
on conflict (brand_id, slug) do nothing;

do $$
declare
  v_quiz_id uuid;
  v_q_id uuid;
begin
  select id into v_quiz_id from quizzes where brand_id = (select id from brands where slug = 'garmin') and slug = 'concorrencia-cenarios';

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um casal entra na loja. O marido quer comprar um relógio pra esposa começar a correr. Ela usa iPhone e fala logo de cara: "Eu tava pensando no Apple Watch, não é mais fácil já que uso iPhone?"

Qual é a melhor forma de conduzir essa conversa?', 'A pergunta sobre a rotina dela direciona naturalmente a conversa. Quando o cliente entende que vai correr 3x por semana, carregar o relógio todo dia vira um incômodo real — e aí a bateria do Garmin faz sentido sem você precisar atacar o Apple Watch.

Dica: Perguntas abertas sobre a rotina do cliente valem mais do que qualquer argumento técnico.', 0)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Perguntar quantos dias por semana ela pretende treinar e mostrar, a partir disso, onde o Garmin faz mais sentido pra ela', true, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Concordar — já que ela usa iPhone, o Apple Watch realmente integra melhor', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Falar direto que o Apple Watch não serve pra esporte e mostrar o Forerunner 265', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Ignorar a comparação e apresentar os modelos disponíveis sem contexto', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente de uns 30 anos, visual despojado, está olhando os modelos na vitrine. Você chega perto e ele fala: "Só uso iPhone. Não seria melhor o Apple Watch pra sincronizar direto?"

Como você responde sem perder a venda?', 'O cliente está com um argumento de compatibilidade — que é real, mas resolve fácil. A resposta certa valida o ponto (sim, o Garmin funciona com iPhone) e redireciona pro que diferencia de verdade: bateria e análise de treino.

Dica: Nunca deixe um argumento técnico do cliente no ar sem responder. Valide e redirecione.', 1)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Concordar que pra quem tem iPhone o Apple Watch é a escolha mais lógica', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Explicar o protocolo Bluetooth e as diferenças técnicas de sincronização', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Dizer que o Apple Watch tem muitas limitações e que ele vai se arrepender', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Mostrar que o Garmin Connect funciona perfeitamente no iPhone — e que a diferença real aparece no treino, na bateria e nos dados', true, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Uma mulher em roupa de corrida entra na loja. Ela fala com segurança: "Usei Polar por 5 anos, quero ver as opções de vocês mas honestamente ainda tô na dúvida."

Qual é a abordagem que constrói confiança e aumenta a chance de venda?', 'Quem já usou Polar por 5 anos entende de treino. Atacar a marca anterior cria resistência. O caminho é respeitar o histórico, entender o que ela valoriza e mostrar o que o Garmin acrescenta — FirstBeat, ecossistema, suporte presencial. Ela decide com segurança.

Dica: Atacar a marca que o cliente usou é atacar a escolha que ele mesmo fez. Nunca faça isso.', 2)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Dizer que a Polar ficou pra trás e que ela vai notar a diferença logo de cara', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Reconhecer o histórico dela com a Polar, perguntar o que mais usa no dia a dia e mostrar o que o Garmin acrescenta — sem diminuir o que ela já teve', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Oferecer um desconto direto pra fechar na hora, antes que ela vá embora', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Falar bem da Polar e sugerir que ela volte quando tiver mais decidida', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um jovem está com o celular na mão comparando preços. Ele mostra a tela pra você: "Olha, esse Coros aqui tem as mesmas funcionalidades e custa R$800 a menos. Por que eu pagaria mais no Garmin?"

Como você responde ao argumento de preço sem soar defensivo?', 'O argumento de preço é legítimo — não dá pra ignorar ou fingir que não existe. A resposta certa reconhece a diferença e apresenta o valor real: algoritmos maduros, suporte local e valor de revenda. O cliente decide com informação completa.

Dica: Nunca ataque o produto mais barato. Mostre o valor do mais caro.', 3)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Dizer que o Coros tem qualidade inferior e que preço baixo tem um motivo', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Oferecer parcelamento extra pra chegar no mesmo valor e fechar na hora', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Reconhecer a diferença de preço e mostrar o que justifica o investimento: 35 anos de algoritmos, ecossistema completo e suporte presencial aqui na Proparts', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Ignorar a comparação e falar das especificações técnicas do Garmin', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente que parece atleta experiente fala: "Vi um review no YouTube dizendo que o Coros Vertix 3 é melhor que qualquer Garmin pra corrida de montanha. O criador do canal correu 100km com ele."

Como você lida com um argumento baseado em review externo?', 'Desacreditar o review cria atrito — o cliente pesquisou, achou relevante. A abordagem certa é validar o Coros como concorrente sério e mostrar onde o Garmin vai além com dados concretos. Quem conhece o produto vende com confiança, não com ceticismo.

Dica: Atacar a fonte do cliente é atacar o cliente. Use os fatos do produto a seu favor.', 4)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Validar que o Coros tem bons modelos de trail e mostrar onde o Fenix 8 ou Instinct 3 vão além: certificação MIL-STD-810, altímetro barométrico e bateria de semanas', true, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Dizer que o criador do canal provavelmente foi patrocinado pela marca', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Concordar com o review e explicar que o Garmin é melhor pra outros esportes', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Falar que YouTube não é fonte confiável e que o cliente não deve se basear nisso', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um homem com Galaxy S24 na mão está na loja. Ele fala: "Tenho Samsung, então o Galaxy Watch não seria mais lógico? Tudo integra direto."

Como você conduz sem empurrar?', 'A pergunta sobre a rotina esportiva qualifica o cliente. Se ele pratica esporte de verdade, a bateria de 1–2 dias do Galaxy Watch vira um problema real. Se ele quer mais smartwatch do que relógio esportivo, talvez o Galaxy Watch seja a escolha certa mesmo — e honestidade aqui gera confiança.

Dica: Qualifique antes de argumentar. A pergunta certa vale mais que o melhor argumento.', 5)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Dizer que o Galaxy Watch não presta pra treino e que o Garmin é claramente melhor', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Concordar que pra quem tem Samsung o Galaxy Watch faz mais sentido', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Mostrar direto os modelos mais avançados do Garmin sem perguntar sobre a rotina dele', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Perguntar se ele pratica esporte com frequência — e mostrar que o Garmin Connect funciona perfeitamente no Android, com bateria de dias e análise de treino real', true, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Uma mulher de uns 40 anos viu o Forerunner 265 que você mostrou e gostou. Mas na hora H ela pega o celular e fala: "Deixa eu ver o preço na Amazon antes. Às vezes tá bem mais barato."

Qual é a melhor reação nesse momento?', 'Proibir ou ignorar a pesquisa afasta. A resposta certa reforça o valor tangível da compra presencial sem inventar riscos sobre o online. Suporte presencial, configuração na hora e garantia oficial são argumentos reais — use-os com confiança.

Dica: Nunca crie medo sobre o online sem embasamento. Venda o seu diferencial, não o medo do concorrente.', 6)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Pedir que ela guarde o celular e fale que os preços são os mesmos', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Sugerir que ela compre online mesmo se achar mais barato — e volte se tiver problema', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Deixar ela pesquisar à vontade e reforçar o que a compra presencial inclui: configuração na hora, garantia de 2 anos com assistência técnica aqui mesmo e suporte quando precisar', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Alertar que produtos na Amazon podem não ter garantia oficial no Brasil', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Você passou 20 minutos com um cliente, mostrou dois modelos, ele gostou do Venu 4. Na hora de fechar ele fala: "Cara, adorei o relógio mas preciso pensar um pouco. Posso voltar amanhã?"

O que você faz nesse momento?', 'Pressão artificial — estoque limitado, preço subindo — queima a relação e ainda pode ser mentira. A resposta certa mantém o canal aberto sem forçar. O WhatsApp resolve muita dúvida que o cliente teria sozinho em casa, e aumenta muito a chance de fechar.

Dica: Quem realmente quer compra. Sua função é estar disponível quando ele decidir — não criar urgência falsa.', 7)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Avisar que o estoque é limitado e que o modelo pode não estar disponível amanhã', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Respeitar a decisão, anotar o modelo e passar o WhatsApp — para que ele possa tirar dúvidas antes de voltar', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Deixar ele ir sem falar mais nada para não pressionar', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Oferecer um desconto extra na hora para tentar fechar antes que ele saia', false, null, 3);

end $$;

-- ── Corredor — Garmin Connect (12 perguntas) ──
insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
values ((select id from brands where slug = 'garmin'), 'corredor-garmin-connect', 'Corredor — Garmin Connect', 70.00, true)
on conflict (brand_id, slug) do nothing;

do $$
declare
  v_quiz_id uuid;
  v_q_id uuid;
begin
  select id into v_quiz_id from quizzes where brand_id = (select id from brands where slug = 'garmin') and slug = 'corredor-garmin-connect';

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Uma cliente diz: "Acordo cansada todo dia, mesmo dormindo 8 horas." Qual recurso do Garmin Connect você mostraria primeiro?', 'Dormir 8 horas mas acordar cansada pode indicar sono de baixa qualidade. O Sleep Score mostra as fases e o SpO2 noturno, enquanto o HRV Status revela se o sistema nervoso está se recuperando de verdade — muito mais preciso do que só olhar a duração.', 0)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Minutos de Intensidade — ela provavelmente não está se exercitando o suficiente', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Sleep Score + HRV Status — O HRV mostra o estado real de recuperação do sistema nervoso', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Body Battery — e diria que ela deveria dormir mais cedo', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Status de Treinamento — para ver se ela está sobrecarregada', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente pergunta qual a diferença entre Body Battery e estresse. Como você explica?', 'O Body Battery é um indicador de energia acumulado, ele considera sono, estresse e atividade das últimas horas. O estresse, medido pela variabilidade da FC, mostra os picos de tensão momento a momento. Um impacta diretamente o outro.', 1)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'São a mesma coisa — o Body Battery é outro nome para o nível de estresse', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Body Battery é o resultado acumulado de sono, estresse e atividade ao longo do tempo. O estresse mostra os picos de tensão em tempo real', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O estresse mede a atividade física e o Body Battery mede o sono isoladamente', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Body Battery é calculado pela contagem de passos e o estresse pelo batimento cardíaco médio', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O HRV Status é monitorado principalmente em qual momento?', 'O HRV Status é medido durante o sono porque é nesse período que o corpo está em repouso e a variabilidade cardíaca reflete de forma honesta o equilíbrio do sistema nervoso autônomo. É uma das métricas mais confiáveis do ecossistema Garmin.', 2)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Durante o treino, para ajustar a intensidade em tempo real', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Durante o dia, com leituras automáticas a cada hora', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Durante o sono, porque é quando o corpo está em repouso', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Apenas quando o usuário ativa manualmente no relógio', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente quer emagrecer e pergunta se o Garmin ajuda. Qual é a melhor resposta?', 'A integração com MyFitnessPal é um argumento forte para quem quer emagrecer ou ganhar massa. Fecha o ciclo de gasto e consumo calórico em um ecossistema só', 3)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Não diretamente.. O Garmin é mais voltado para atletas de corrida"', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Ele conta calorias queimadas, mas você teria que usar outro app separado, sem integração"', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"O Garmin mede o gasto calórico diário, o relógio mede o que você gasta, e é só integrar com o app que mede o que você come"', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"O Garmin Pay facilita comprar alimentos saudáveis sem sair do ritmo"', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'É possível baixar músicas via MP3 no Garmin?', 'O Bluetooth sozinho não garante música offline — O relógio precisa ter memória interna para armazenar as playlists. e além dos streamings de música, também é possível transferir as músicas MP3 diretamente para o relógio', 4)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Apenas o Fenix 8 e o Forerunner 970', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Sim, em modelos com armazenamento interno', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Qualquer relógio Garmin que tenha Bluetooth', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Somente na linha Venu 4 ', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Uma cliente quer usar o Garmin Pay para pagar o café após a corrida. Quais bancos são compatíveis no Brasil?', 'No Brasil, os bancos compatíveis com Garmin Pay são BTG, Banco do Brasil e Santander. Vale confirmar com a cliente antes de usar esse argumento — e lembrar que nem todos os modelos têm NFC.', 5)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Nubank, Itaú e Inter', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'BTG, Banco do Brasil e Santander', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Bradesco, Caixa e C6 Bank', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Qualquer banco com app de pagamento por aproximação', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O Status de Treinamento classifica o atleta como "Sobrecarregado". Como você traduz isso em benefício de venda?', 'Traduzir métrica em benefício é o que separa uma venda técnica de uma venda consultiva. "Sobrecarregado" não é um problema, é uma vantagem: o relógio antecipa o que o corpo ainda não sinalizou visivelmente.', 6)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Significa que o relógio está com problema de leitura"', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Quer dizer que ele está treinando demais e precisa de um modelo mais avançado"', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Avisa quando você está além da conta antes de virar lesão"', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Significa que o firmware precisa de atualização"', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Por que o monitoramento de Ciclo Menstrual no Garmin vai além de um simples calendário?', 'A diferença é a integração com os dados de saúde do dia a dia. É possivel  entender como cada fase impacta o sono, a energia e o desempenho nos treinos. Isso é argumento de venda  para o público feminino.', 7)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Porque envia lembretes automáticos por SMS', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Porque correlaciona as fases do ciclo com HRV, sono e Body Battery', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Porque funciona sem internet', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Porque é exclusivo dos modelos Fenix', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente diz que não vai usar o Garmin Connect, só o relógio para correr. Como você responde?', 'O Connect não é obrigatório para o relógio funcionar no pulso, mas é onde os dados ganham contexto e se tornam úteis ao longo das semanas. Mostrar isso posiciona o ecossistema como diferencial.', 8)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Tudo bem, você pode usar normalmente sem o app"', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Sem o app o relógio não funciona! é obrigatório"', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"O relógio funciona, mas você perde o histórico e as análises que mostram se você está evoluindo ou não"', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, '"Nesse caso o Forerunner 55 já é suficiente"', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Uma pessoa sedentária compra um Garmin pela primeira vez. Quais métricas têm mais valor para ela no começo?', 'Para quem ainda não treina, as métricas de vida cotidiana são as mais impactantes. Ver os passos, o sono, a energia do dia e a consistência ao longo das semanas cria o hábito antes do esporte.', 9)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'HRV Status, VO2 Máx e Status de Treinamento', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Passos, Body Battery, Sleep Score e Monitoramento de Hábitos', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Garmin Pay e armazenamento de música', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'SpO2 durante o treino e zonas de frequência cardíaca', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que acontece quando o relógio sincroniza com o Garmin Connect?', 'A sincronização transfere os dados para o app, que os organiza em histórico, gráficos e insights ao longo do tempo. A integração com outras plataformas é um dos grandes diferenciais do ecossistema Garmin.', 10)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Os dados do relógio são apagados para liberar espaço', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O app envia automaticamente um relatório para o médico cadastrado', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Os dados são organizados em histórico, gráficos e análises', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Garmin Pay é reativado automaticamente', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Para usar música offline no relógio com o Spotify, o que o cliente precisa ter?', 'Três requisitos juntos: relógio com armazenamento interno, Spotify Premium para download offline e fone Bluetooth para ouvir. Identificar o fone como acessório complementar na venda é uma boa oportunidade de ticket.', 11)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Apenas o Garmin Connect instalado no celular', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Assinatura Spotify Premium e um fone de ouvido Bluetooth', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Somente um fone Bluetooth. Qualquer relógio Garmin funciona', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Uma assinatura do plano Garmin Connect Premium', false, null, 3);

end $$;

-- ── Corredor — Garmin Coach (14 perguntas) ──
insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
values ((select id from brands where slug = 'garmin'), 'corredor-coaches', 'Corredor — Garmin Coach', 70.00, true)
on conflict (brand_id, slug) do nothing;

do $$
declare
  v_quiz_id uuid;
  v_q_id uuid;
begin
  select id into v_quiz_id from quizzes where brand_id = (select id from brands where slug = 'garmin') and slug = 'corredor-coaches';

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que é o Garmin Coach, em uma frase para o cliente?', 'O Garmin Coach é uma plataforma de planos de treinamento dinâmicos e adaptáveis, gratuita, disponível no app Garmin Connect — não é só um recurso, é um serviço de consultoria esportiva que fideliza o cliente.', 0)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Um conjunto de planilhas de treino em PDF que vêm com o relógio', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Um serviço de consultoria esportiva gratuito, com planos de treino adaptativos dentro do Garmin Connect', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Um curso pago dentro do Connect IQ Store', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Um aplicativo separado que precisa ser comprado', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual é a principal diferença entre o Garmin Coach e uma planilha de treino estática em PDF?', 'O Coach lê métricas de saúde (sono, estresse, HRV) e cruza com o desempenho nos treinos para adaptar o plano em tempo real — algo impossível numa planilha estática.', 1)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Coach é mais bonito visualmente, mas o conteúdo é o mesmo', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Coach usa algoritmos que leem sono, estresse e HRV para adaptar o plano automaticamente ao desempenho real', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'A planilha em PDF é mais precisa porque foi feita por um humano', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Não há diferença real, ambos seguem o calendário fixo', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente perdeu dois treinos na semana e dormiu mal na véspera. O que o Garmin Coach faz?', 'Esse é o cenário clássico de adaptação: o plano reage ao sono ruim ou aos treinos perdidos, ajustando a carga para baixo e evitando lesões — sem tirar o usuário do caminho da meta.', 2)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Mantém o plano idêntico, sem considerar isso', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Cancela o plano automaticamente', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Adapta o plano reduzindo a intensidade ou sugerindo descanso, para evitar lesão e manter o caminho até a meta', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Envia uma notificação de erro pedindo para reiniciar o app', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que é o Tapering (Polimento) e por que ele é importante perto da prova?', 'O Tapering reduz o volume propositalmente nos dias antes da prova, permitindo que o corpo recupere energia e chegue no auge de performance no dia do evento.', 3)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É um aumento de volume de treino na última semana para "chegar afiado"', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É a redução estratégica do volume de treino conforme a prova se aproxima, para o corpo recuperar energia e atingir o ápice da performance', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É um tipo de alongamento feito só no dia da prova', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É a fase em que o atleta troca de treinador no plano', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Quais são os 4 pilares de valor do Garmin Coach para o cliente?', 'Os 4 pilares são: treinar para um evento específico, alcançar um marco (como o primeiro 5K), melhorar o condicionamento físico geral e ganhar força.', 4)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Emagrecer, dormir melhor, comer melhor e gastar menos', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Treinar para um evento, alcançar um marco, melhorar o condicionamento físico e ganhar força', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Comprar acessórios, sincronizar música, usar Garmin Pay e configurar notificações', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Correr mais rápido, pedalar mais, nadar melhor e jogar golfe', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente está voltando de uma lesão e quer recomeçar a correr com segurança. Qual treinador dos Planos Expert você indica?', 'Jeff Galloway é o mais indicado para iniciantes ou retorno de lesões, usando o método Run Walk Run corrida-caminhada-corrida) — alterna corrida e caminhada para reduzir o impacto.', 5)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Greg McMillan, focado em fisiologia avançada de ritmo', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Amy Parkerson-Mitchell, fisioterapeuta focada em mecânica corporal', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Jeff Galloway, com o método Run Walk Run (corrida-caminhada-corrida)', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Não existe um treinador específico para esse caso', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Para planos de ciclismo no Garmin Coach, qual é o requisito técnico obrigatório?', 'É obrigatório o uso de Monitor de FC ou Medidor de Potência para planos de ciclismo — usar os dois juntos é recomendado para máxima precisão dos dados.', 6)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Ter um smartwatch Garmin com tela AMOLED', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Estar conectado ao Wi-Fi durante todo o pedal', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Usar Monitor de Frequência Cardíaca ou Medidor de Potência (o uso de ambos é recomendado)', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Ter assinatura do Garmin Connect+', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que diferencia o Garmin Connect+ no contexto do Triatlo?', 'O Garmin Connect+ é um upgrade de experiência que adiciona vídeos exclusivos e conteúdo educacional de especialistas, voltado para ajudar na técnica de transição e natação no Triatlo.', 7)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Permite criar planos de mais de um esporte ao mesmo tempo, sem limite', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Oferece vídeos exclusivos e conteúdo educacional de especialistas para técnica de transição e natação', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É obrigatório para qualquer plano de corrida', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Substitui a necessidade de monitor de FC', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O que são as sessões "Two-a-day (Dois por dia)" mencionadas no módulo de Triatlo?', 'Two-a-day são dois treinos estruturados no mesmo dia — algo comum na rotina de triatletas, que o Garmin Coach permite agendar, incluindo dias específicos de piscina.', 8)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Dois planos de Garmin Coach ativos ao mesmo tempo', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Dois treinos estruturados realizados no mesmo dia', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Um treino que dura duas horas seguidas', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Uma função exclusiva do Connect+ para revisão de vídeo', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O cliente diz que o Garmin Coach não aparece no app dele. Qual é o primeiro passo para solucionar o problema?', 'O Garmin Express é essencial para atualizar o software do relógio. Se o Coach não aparece, a primeira orientação é atualizar via PC/Mac antes de qualquer outra ação.', 9)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Reinstalar o aplicativo do zero', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Comprar um relógio novo, pois o modelo dele é incompatível', false, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Atualizar o software do relógio via Garmin Express no PC/Mac', true, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Desativar o Bluetooth do celular e reconectar', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'O cliente quer mover um treino de ciclismo autoguiado para outro dia no calendário. Como ele faz isso?', 'Para Corrida e Força o reagendamento pode ser feito direto pelo app, mas para Ciclismo Autoguiado é obrigatório usar o Garmin Connect Web para mover treinos no calendário.', 10)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Direto pelo aplicativo no celular, como qualquer outro treino', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É obrigatório usar o Garmin Connect Web para mover treinos de ciclismo autoguiado', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Não é possível reagendar treinos de ciclismo, apenas de corrida', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Precisa entrar em contato com o suporte Garmin', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Qual é a diferença prática entre "Pausar" e "Sair" de um plano Garmin Coach?', 'Pausar mantém o progresso intacto. Sair do plano remove todos os treinos futuros — os já concluídos continuam no calendário, mas para voltar é necessário iniciar um plano novo do zero.', 11)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Pausar e Sair têm exatamente o mesmo efeito', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Pausar mantém o progresso; Sair remove todos os treinos futuros, e o usuário precisa começar um plano do zero para voltar', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Pausar é só para planos de corrida; Sair é só para planos de ciclismo', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Sair mantém o progresso; Pausar apaga todo o histórico', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Durante um treino guiado, por que o relógio mostra o ritmo médio da etapa/lap atual, e não o ritmo instantâneo?', 'Mostrar a média da etapa/lap atual (em vez do ritmo instantâneo ou por km fechado) ajuda o atleta a manter constância em treinos de intervalo longos, sem reagir a oscilações momentâneas.', 12)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Porque o GPS multibanda não permite leitura instantânea', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Isso é vital para manter a constância em intervalos longos, evitando que pequenas variações de passo distorçam a leitura', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'É uma limitação de bateria do relógio', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Só ocorre em modelos de entrada, como o Forerunner 55', false, null, 3);

  insert into questions (quiz_id, body, explanation, order_index)
  values (v_quiz_id, 'Um cliente configurou um plano de Garmin Coach só com o objetivo de "completar a distância", sem meta de tempo. O que acontece com o Confidence Score?', 'O Confidence Score só aparece se o usuário definir uma Meta de Tempo/Ritmo. Se o objetivo for apenas completar a distância, o score fica oculto — é uma nota técnica importante para não gerar confusão na demonstração ao cliente.', 13)
  returning id into v_q_id;

  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Ele aparece em vermelho automaticamente', false, null, 0);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Ele fica oculto, pois o Confidence Score só aparece quando há uma Meta de Tempo/Ritmo definida', true, null, 1);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'Ele aparece sempre em roxo, indicando que está excedendo a meta', false, null, 2);
  insert into alternatives (question_id, body, is_correct, feedback, order_index)
  values (v_q_id, 'O Confidence Score não existe no Garmin Coach, apenas em planos Expert', false, null, 3);

end $$;

-- ============================================================================
-- FIM DO SEED 020
-- ============================================================================
