-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 088: conteúdo dos 4 módulos vazios da Zona Maratonista
-- ============================================================================
-- Mesma situação da Zona Atleta (ver 087): os 4 módulos da Zona Maratonista
-- (Portfólio de Endurance, O Triângulo da Prontidão, Ferramentas de Ritmo e
-- Planejamento de Prova, Segurança/Aclimatação/Nutrição) e seus quizzes
-- estavam publicados mas vazios. Esta migração preenche as 4.
-- ============================================================================

do $$
declare
  v_mod_endurance   uuid := '1af99bf4-bd3b-4af0-9bac-f7129bcf4037';
  v_mod_prontidao   uuid := '6430619b-7653-4926-a92c-3586804b2cc4';
  v_mod_ritmo       uuid := 'a25bd64b-60fd-41b3-a132-651285a16d50';
  v_mod_seguranca   uuid := '4e4ec6a8-0279-42bf-8114-85c6bd29d336';
  v_quiz_endurance  uuid := 'fb53a75c-7e77-48b9-8326-dacd93d49ff6';
  v_quiz_prontidao  uuid := 'a9bf1478-e8b6-4001-aab3-878ac4a2d8d1';
  v_quiz_ritmo      uuid := '61a01093-b310-48f3-b5d8-0b0b2e2818fe';
  v_quiz_seguranca  uuid := 'd470f7b8-ad69-4926-92c0-88d67f04a56d';
  v_q uuid;
begin

-- ============================================================================
-- MÓDULO 1: Portfólio de Endurance
-- ============================================================================

insert into lessons (module_id, title, content_type, order_index, is_published, body) values
(v_mod_endurance, 'Fenix 8: o topo de linha multiesporte', 'text', 0, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Fenix 8</strong> é o topo de linha multiesporte da Garmin, com tela AMOLED (versões 43, 47 e 51mm, sendo 47 e 51mm também com opção Solar), GPS multibanda com SatIQ, sensor cardíaco Elevate Gen 5, ECG, profundidade de mergulho até 40m, alto-falante e microfone embutidos, lanterna LED e 32GB de armazenamento.</p><p>A versão <strong>Fenix 8 Pro</strong> vai além: é o primeiro relógio Garmin com inReach embutido, conectividade satélite e celular direto no pulso, mensagens de texto bidirecionais via Garmin Messenger e SOS roteado pro centro de resposta Garmin, disponível em mais de 150 países.</p>"},
    {"type": "banner", "tone": "info", "text": "A versão Solar (47/51mm) estende bastante a autonomia; a 43mm não tem opção solar. Confirme sempre o tamanho de caixa e a versão Pro antes de falar de inReach com o cliente."}
  ]
}$j$),
(v_mod_endurance, 'Enduro 3: o ultra-endurance dedicado', 'text', 1, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Enduro 3</strong> é a aposta da Garmin pra quem prioriza bateria acima de tudo: tela MIP (não AMOLED, justamente pra economizar energia), com até 320 horas de GPS usando a lente solar, e até 90 dias em modo smartwatch com sol suficiente. GPS multibanda também está presente, com o SatIQ estendendo a precisão multibanda por até 120 horas.</p><p>É mais leve que o Fenix 8 e abre mão da tela AMOLED e de parte do polimento de mapa em troca de autonomia real pra ultramaratonas e provas de múltiplos dias.</p>"},
    {"type": "banner", "tone": "info", "text": "Posicionamento de venda: Fenix 8 pra quem quer tela bonita e recursos completos; Enduro 3 pra quem está preocupado, acima de tudo, em não ficar sem bateria no meio de uma prova longa."}
  ]
}$j$),
(v_mod_endurance, 'Forerunner 970 e Instinct 3: opções por perfil', 'text', 2, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Forerunner 970</strong> é o topo de linha voltado pra corrida, com tela AMOLED e as mesmas métricas avançadas de recuperação e performance do Fenix, só que num corpo mais leve, sem solar e com menos dias de bateria em modo smartwatch (confirme o número exato de horas/dias no manual do modelo específico antes de repassar ao cliente, já que essa tabela muda por versão).</p><p>O <strong>Instinct 3 Solar</strong> é a opção mais rústica e acessível da linha endurance: tela MIP, GPS multibanda, e com a lente solar chega a 28 dias (caixa 45mm) ou 40 dias (caixa 50mm) em modo smartwatch, além de até 130 horas em GPS padrão com ajuda do sol.</p>"},
    {"type": "banner", "tone": "info", "text": "Instinct 3 Solar é uma ótima entrada pra quem quer bateria solar longa sem pagar o preço do Fenix ou Enduro."}
  ]
}$j$),
(v_mod_endurance, 'Qual entregar pra cada perfil de atleta endurance', 'text', 3, true, $j${
  "blocks": [
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Quer o relógio mais completo, sem abrir mão de nada", "text": "Fenix 8 (ou Fenix 8 Pro se valorizar conectividade satélite em áreas sem sinal de celular).", "tags": []},
      {"title": "Prioriza bateria acima de qualquer outra coisa", "text": "Enduro 3, pensado pra ultramaratonas e expedições de múltiplos dias.", "tags": []},
      {"title": "Foco é corrida, quer tela bonita e leve", "text": "Forerunner 970, com métricas avançadas de performance num corpo mais leve que o Fenix.", "tags": []},
      {"title": "Quer entrar na linha endurance gastando menos", "text": "Instinct 3 Solar, com bateria solar longa e resistência no formato mais rústico da Garmin.", "tags": []}
    ]}
  ]
}$j$);

-- Quiz: Portfólio de Endurance (8 perguntas)
insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_endurance, 'O que o Fenix 8 Pro tem que o Fenix 8 normal não tem?', 'O Fenix 8 Pro é o primeiro relógio Garmin com inReach embutido, com conectividade satélite e celular.', 0) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'inReach embutido, com conectividade satélite e celular', true, 0),
(v_q, 'Tela maior', false, 1),
(v_q, 'GPS multibanda', false, 2),
(v_q, 'Sensor cardíaco Elevate', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_endurance, 'Por que o Enduro 3 usa tela MIP em vez de AMOLED?', 'A tela MIP consome muito menos energia, permitindo autonomia de até 320 horas de GPS com a lente solar.', 1) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Pra economizar energia e estender a autonomia de bateria', true, 0),
(v_q, 'Porque AMOLED não suporta GPS multibanda', false, 1),
(v_q, 'Porque é mais barato de fabricar', false, 2),
(v_q, 'Porque o Enduro 3 não tem tela colorida em nenhuma versão', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_endurance, 'Qual relógio é o mais indicado pra quem prioriza bateria acima de tudo, como em ultramaratonas?', 'O Enduro 3 foi pensado justamente pra esse perfil: autonomia extrema com a lente solar.', 2) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Enduro 3', true, 0),
(v_q, 'Forerunner 970', false, 1),
(v_q, 'Fenix 8 (sem solar)', false, 2),
(v_q, 'Instinct 3 sem solar', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_endurance, 'O Forerunner 970 se diferencia do Fenix 8 principalmente por quê?', 'O 970 é focado em corrida, com corpo mais leve e sem opção solar, mas compartilha as métricas avançadas de recuperação.', 3) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Corpo mais leve, focado em corrida, sem opção solar', true, 0),
(v_q, 'Não tem GPS', false, 1),
(v_q, 'Não calcula VO2 Max', false, 2),
(v_q, 'É mais caro que o Fenix 8', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_endurance, 'Qual é a proposta do Instinct 3 Solar dentro da linha endurance?', 'É a entrada mais acessível da linha endurance, com bateria solar longa e formato rústico.', 4) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Entrada acessível com bateria solar longa e formato rústico', true, 0),
(v_q, 'É o modelo mais caro da linha endurance', false, 1),
(v_q, 'Só funciona em ambientes urbanos', false, 2),
(v_q, 'Não tem GPS multibanda', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_endurance, 'Até quantos dias em modo smartwatch o Instinct 3 Solar 50mm alcança com sol suficiente?', 'A caixa 50mm do Instinct 3 Solar chega a até 40 dias em modo smartwatch com sol suficiente.', 5) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Até 40 dias', true, 0),
(v_q, 'Até 5 dias', false, 1),
(v_q, 'Até 10 dias', false, 2),
(v_q, 'Até 90 dias', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_endurance, 'Qual detalhe deve sempre ser confirmado no manual antes de falar de bateria do Forerunner 970?', 'Os números exatos de horas/dias por modo variam por versão e devem ser confirmados no manual antes de repassar ao cliente.', 6) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'O número exato de horas/dias por modo de bateria', true, 0),
(v_q, 'A cor da caixa', false, 1),
(v_q, 'O preço em dólar', false, 2),
(v_q, 'O nome do sensor cardíaco', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_endurance, 'Qual recurso o SatIQ estende por até 120 horas no Enduro 3?', 'O SatIQ estende a precisão multibanda por até 120 horas no Enduro 3 quando combinado com a lente solar.', 7) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'A precisão multibanda do GPS', true, 0),
(v_q, 'A duração da lanterna LED', false, 1),
(v_q, 'A conexão Bluetooth', false, 2),
(v_q, 'O armazenamento de música', false, 3);

-- ============================================================================
-- MÓDULO 2: O Triângulo da Prontidão
-- ============================================================================

insert into lessons (module_id, title, content_type, order_index, is_published, body) values
(v_mod_prontidao, 'O que é Training Readiness', 'text', 0, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p><strong>Training Readiness</strong> é, na definição oficial da Garmin, \"um score e uma mensagem curta que ajudam a determinar o quão pronto você está pra treinar a cada dia\". O score combina seis entradas: sono da noite anterior, Tempo de Recuperação, HRV Status, carga aguda de treino, histórico de sono das últimas 3 noites e dados de estresse dos últimos 3 dias.</p><p>O histórico do score fica disponível no Garmin Connect, então dá pra acompanhar a tendência ao longo do tempo, não só o número do dia.</p>"},
    {"type": "banner", "tone": "info", "text": "Training Readiness exige Firstbeat Analytics, presente na maioria dos Forerunner (55 em diante), Fenix, Epix, Enduro e parte da linha Instinct. Confirme o modelo específico antes de prometer o recurso."}
  ]
}$j$),
(v_mod_prontidao, 'Os rótulos oficiais do score', 'text', 1, true, $j${
  "blocks": [
    {"type": "tabela", "headers": ["Faixa", "Rótulo", "Mensagem"], "rows": [
      ["95-100", "Prime", "Melhor condição possível"],
      ["75-94", "High", "Pronto pra desafios"],
      ["50-74", "Moderate", "Tudo certo pra treinar"],
      ["25-49", "Low", "Hora de reduzir o ritmo"],
      ["1-24", "Poor", "Deixe o corpo se recuperar"]
    ]},
    {"type": "banner", "tone": "info", "text": "Use essa tabela pra explicar ao cliente que o número sozinho não diz muita coisa: o valor está em entender o rótulo e ajustar o treino do dia."}
  ]
}$j$),
(v_mod_prontidao, 'Training Load e Training Load Focus', 'text', 2, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p><strong>Training Load</strong> compara a carga aguda de treino (dias recentes) com a carga crônica (semanas recentes), mostrando se o volume atual está subindo rápido demais ou estável. O <strong>Training Load Focus</strong> detalha essa carga por tipo de estímulo (aeróbico e anaeróbico), ajudando a enxergar se o treino está desequilibrado pra um lado só.</p>"},
    {"type": "banner", "tone": "info", "text": "Training Load e Training Load Focus alimentam o cálculo de Training Readiness junto com sono, HRV e estresse; nenhum desses dados funciona isolado."}
  ]
}$j$),
(v_mod_prontidao, 'Quais relógios suportam o recurso', 'text', 3, true, $j${
  "blocks": [
    {"type": "objecao", "items": [
      {"question": "Todo Garmin mostra Training Readiness?", "answer": "Não. O recurso depende do Firstbeat Analytics, presente na maioria da linha Forerunner (a partir do 55), Fenix, Epix, Enduro e em parte da linha Instinct. Sempre confirme o modelo exato antes de afirmar que o relógio tem o recurso."},
      {"question": "Training Readiness substitui o VO2 Max?", "answer": "Não, são coisas diferentes. VO2 Max mede capacidade aeróbica; Training Readiness mede o quanto o corpo está pronto pra treinar hoje, combinando sono, recuperação, HRV, carga e estresse."}
    ]}
  ]
}$j$);

-- Quiz: O Triângulo da Prontidão (8 perguntas)
insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_prontidao, 'O que Training Readiness ajuda a determinar?', 'É um score e mensagem que ajudam a determinar o quão pronto o corpo está pra treinar naquele dia.', 0) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'O quão pronto o corpo está pra treinar naquele dia', true, 0),
(v_q, 'A distância total percorrida na semana', false, 1),
(v_q, 'O preço do relógio', false, 2),
(v_q, 'A capacidade de armazenamento de música', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_prontidao, 'Quantas entradas compõem o score de Training Readiness?', 'Seis: sono da noite anterior, Tempo de Recuperação, HRV Status, carga aguda, histórico de sono de 3 noites e estresse de 3 dias.', 1) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Seis', true, 0),
(v_q, 'Duas', false, 1),
(v_q, 'Dez', false, 2),
(v_q, 'Apenas uma, o sono da noite anterior', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_prontidao, 'Qual rótulo corresponde à faixa 95-100 do score?', 'A faixa 95-100 corresponde ao rótulo oficial "Prime", com a mensagem de melhor condição possível.', 2) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Prime', true, 0),
(v_q, 'High', false, 1),
(v_q, 'Moderate', false, 2),
(v_q, 'Poor', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_prontidao, 'O que a faixa "Low" (25-49) recomenda ao atleta?', 'A mensagem oficial da faixa Low é "hora de reduzir o ritmo".', 3) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Reduzir o ritmo de treino', true, 0),
(v_q, 'Treinar mais forte que o normal', false, 1),
(v_q, 'Ignorar o score e seguir o plano original', false, 2),
(v_q, 'Trocar de relógio', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_prontidao, 'O que é Training Load Focus?', 'Training Load Focus detalha a carga de treino por tipo de estímulo, aeróbico e anaeróbico.', 4) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'O detalhamento da carga de treino por estímulo aeróbico e anaeróbico', true, 0),
(v_q, 'O total de calorias queimadas na semana', false, 1),
(v_q, 'A previsão de tempo de prova', false, 2),
(v_q, 'O nome do plano de treino escolhido', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_prontidao, 'Training Load compara o quê?', 'Training Load compara a carga aguda (dias recentes) com a carga crônica (semanas recentes) de treino.', 5) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Carga aguda de dias recentes com a carga crônica de semanas recentes', true, 0),
(v_q, 'A velocidade média com a cadência média', false, 1),
(v_q, 'O preço do relógio com o do concorrente', false, 2),
(v_q, 'A frequência cardíaca de repouso com a máxima', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_prontidao, 'Training Readiness é o mesmo que VO2 Max?', 'Não, são métricas diferentes: VO2 Max mede capacidade aeróbica, Training Readiness mede prontidão do dia.', 6) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Não, medem coisas diferentes', true, 0),
(v_q, 'Sim, são exatamente a mesma métrica', false, 1),
(v_q, 'Sim, mas Training Readiness é só uma versão simplificada do VO2 Max', false, 2),
(v_q, 'Não existe relação nenhuma entre as duas métricas', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_prontidao, 'O que é necessário pra um relógio calcular Training Readiness?', 'É necessário Firstbeat Analytics, presente na maioria dos Forerunner (55+), Fenix, Epix, Enduro e parte da linha Instinct.', 7) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Firstbeat Analytics', true, 0),
(v_q, 'Um plano pago do Garmin Connect', false, 1),
(v_q, 'Um sensor de potência externo', false, 2),
(v_q, 'Conexão com o Apple Health', false, 3);

-- ============================================================================
-- MÓDULO 3: Ferramentas de Ritmo e Planejamento de Prova
-- ============================================================================

insert into lessons (module_id, title, content_type, order_index, is_published, body) values
(v_mod_ritmo, 'PacePro: estratégia de ritmo pro percurso inteiro', 'text', 0, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p><strong>PacePro</strong> é a ferramenta da Garmin pra montar uma estratégia de ritmo personalizada pro percurso de uma prova, criada no Garmin Connect e sincronizada com o relógio. Em vez de sugerir um ritmo fixo, o PacePro lê o perfil de elevação do percurso e ajusta o ritmo alvo por trecho, considerando as subidas e descidas.</p><p>Existem três modos de divisão: a cada quilômetro, a cada milha, ou por elevação, esse último dividindo os trechos a partir do início de cada subida, em vez de usar distâncias fixas.</p>"},
    {"type": "banner", "tone": "info", "text": "O modo por elevação é o mais indicado pra provas com relevo irregular, já que evita diluir a inclinação real numa média de trecho."}
  ]
}$j$),
(v_mod_ritmo, 'Race Predictor: previsão de tempo de prova', 'text', 1, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p><strong>Race Predictor</strong> estima o tempo de prova em 5K, 10K, meia maratona e maratona a partir do VO2 Max atual e do histórico recente de treino, atualizando sozinho sem precisar de um teste separado.</p>"},
    {"type": "banner", "tone": "warn", "text": "A previsão de maratona costuma ser a menos confiável das quatro distâncias, já que fatores como pacing e nutrição durante a prova pesam mais numa distância tão longa. Trate a previsão como uma referência, nunca como garantia de tempo."}
  ]
}$j$),
(v_mod_ritmo, 'Sugestões de treino diário (Daily Suggested Workouts)', 'text', 2, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p><strong>Daily Suggested Workouts</strong> combina VO2 Max, Training Status, Training Load (agudo/crônico), Tempo de Recuperação e, quando disponível, Training Readiness, pra recomendar um treino específico do dia (recuperação, base, tempo forte, intervalado). O relógio sugere um treino mais puxado quando a carga aguda está baixa em relação à crônica e a recuperação já terminou, e algo mais leve quando a carga subiu rápido ou a recuperação ainda está contando.</p>"},
    {"type": "banner", "tone": "info", "text": "É um recurso padrão na linha Forerunner, Fenix, Epix e Instinct atual; veio de uma introdução original no Forerunner 745."}
  ]
}$j$),
(v_mod_ritmo, 'Garmin Coach: planos guiados por treinador', 'text', 3, true, $j${
  "blocks": [
    {"type": "metric_card_grid", "columns": 3, "items": [
      {"icon": "🏅", "name": "Jeff Galloway", "definition": "Ex-olímpico, criador do método run-walk-run, focado em prevenir lesão e fadiga combinando corrida e caminhada."},
      {"icon": "🎓", "name": "Greg McMillan", "definition": "Fisiologista do exercício, com planos mais técnicos de periodização."},
      {"icon": "💚", "name": "Amy Parkerson-Mitchell", "definition": "Fisioterapeuta, com foco em prevenção de lesão dentro do plano de treino."}
    ]},
    {"type": "texto_rico", "html": "<p>Os planos são gratuitos dentro do Garmin Connect, pra 5K, 10K, meia e maratona, e se adaptam automaticamente com base no desempenho registrado, sincronizando os treinos estruturados direto pro relógio.</p>"}
  ]
}$j$);

-- Quiz: Ferramentas de Ritmo e Planejamento de Prova (8 perguntas)
insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_ritmo, 'O que o PacePro ajusta ao longo do percurso?', 'PacePro ajusta o ritmo alvo por trecho considerando o perfil de elevação do percurso.', 0) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'O ritmo alvo por trecho, considerando subidas e descidas', true, 0),
(v_q, 'A frequência cardíaca máxima do atleta', false, 1),
(v_q, 'O preço da inscrição na prova', false, 2),
(v_q, 'A cor da tela do relógio', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_ritmo, 'Qual modo de divisão do PacePro é mais indicado pra um percurso com relevo irregular?', 'O modo por elevação divide os trechos a partir do início de cada subida, evitando diluir a inclinação numa média de distância fixa.', 1) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Divisão por elevação', true, 0),
(v_q, 'Divisão a cada quilômetro', false, 1),
(v_q, 'Divisão a cada milha', false, 2),
(v_q, 'Não existe diferença entre os modos', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_ritmo, 'O que o Race Predictor usa pra estimar o tempo de prova?', 'Usa o VO2 Max atual e o histórico recente de treino, sem precisar de um teste separado.', 2) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'VO2 Max atual e histórico recente de treino', true, 0),
(v_q, 'Só a idade cadastrada no perfil', false, 1),
(v_q, 'Um teste de esforço obrigatório em laboratório', false, 2),
(v_q, 'O clima do dia da prova', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_ritmo, 'Qual das quatro previsões do Race Predictor costuma ser a menos confiável?', 'A previsão de maratona é a menos confiável, já que pacing e nutrição pesam mais numa distância tão longa.', 3) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Maratona', true, 0),
(v_q, '5K', false, 1),
(v_q, '10K', false, 2),
(v_q, 'Meia maratona', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_ritmo, 'O que compõe a recomendação do Daily Suggested Workouts?', 'Combina VO2 Max, Training Status, Training Load, Tempo de Recuperação e, quando disponível, Training Readiness.', 4) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'VO2 Max, Training Status, Training Load, Recuperação e Training Readiness', true, 0),
(v_q, 'Só a distância total da semana anterior', false, 1),
(v_q, 'Apenas o clima previsto pro dia', false, 2),
(v_q, 'Só o horário do treino anterior', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_ritmo, 'Quando o Daily Suggested Workouts sugere um treino mais leve?', 'Quando a carga aguda subiu rápido demais ou a recuperação ainda está contando.', 5) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Quando a carga aguda subiu rápido ou a recuperação ainda não terminou', true, 0),
(v_q, 'Sempre nos fins de semana', false, 1),
(v_q, 'Quando o clima está quente', false, 2),
(v_q, 'Nunca, o recurso só sugere treinos fortes', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_ritmo, 'Qual treinador do Garmin Coach é conhecido pelo método run-walk-run?', 'Jeff Galloway, ex-olímpico, criou o método run-walk-run combinando corrida e caminhada pra prevenir lesão e fadiga.', 6) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Jeff Galloway', true, 0),
(v_q, 'Greg McMillan', false, 1),
(v_q, 'Amy Parkerson-Mitchell', false, 2),
(v_q, 'Nenhum dos três usa esse método', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_ritmo, 'Os planos do Garmin Coach têm algum custo extra?', 'Não, os planos são gratuitos dentro do Garmin Connect.', 7) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Não, são gratuitos dentro do Garmin Connect', true, 0),
(v_q, 'Sim, é preciso assinatura mensal separada', false, 1),
(v_q, 'Sim, só disponível pra quem compra o Fenix', false, 2),
(v_q, 'Sim, cobrado por prova cadastrada', false, 3);

-- ============================================================================
-- MÓDULO 4: Segurança, Aclimatação e Nutrição em Longas Distâncias
-- ============================================================================

insert into lessons (module_id, title, content_type, order_index, is_published, body) values
(v_mod_seguranca, 'LiveTrack, Detecção de Incidente e Assistência', 'text', 0, true, $j${
  "blocks": [
    {"type": "metric_card_grid", "columns": 3, "items": [
      {"icon": "📍", "name": "LiveTrack", "definition": "Compartilha a localização em tempo real durante uma atividade cronometrada, pra contatos acompanharem o treino ou a prova ao vivo."},
      {"icon": "🚨", "name": "Detecção de Incidente", "definition": "Detecta uma mudança brusca de movimento (como uma queda) durante atividade GPS ao ar livre e envia um alerta automático com nome, localização e link do LiveTrack pros contatos de emergência."},
      {"icon": "🆘", "name": "Assistência", "definition": "Acionada manualmente pelo próprio atleta, envia o mesmo tipo de alerta (nome, localização, LiveTrack) pros contatos de emergência."}
    ]},
    {"type": "banner", "tone": "warn", "text": "Os dois recursos de segurança dependem do relógio estar pareado por Bluetooth com um celular com plano de dados ativo. São recursos complementares, nunca o método principal de emergência."}
  ]
}$j$),
(v_mod_seguranca, 'Aclimatação de calor e altitude', 'text', 1, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>A Garmin tem recursos de <strong>Aclimatação de Calor</strong> e <strong>Aclimatação de Altitude</strong>, que acompanham a adaptação do corpo do atleta a treinar em condições de calor ou altitude ao longo dos dias. É um recurso relevante pra quem está se preparando pra uma prova em clima ou altitude diferente do que treina normalmente.</p>"},
    {"type": "banner", "tone": "warn", "text": "Confirme sempre no manual do modelo específico os detalhes exatos de como o recurso apresenta essa informação antes de repassar número ou prazo ao cliente; o importante pro discurso de venda é que o relógio acompanha essa adaptação ao longo do tempo, não um número fixo de dias que vale pra todo mundo."}
  ]
}$j$),
(v_mod_seguranca, 'Hidratação e nutrição durante o treino', 'text', 2, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>O widget de <strong>Hidratação</strong> registra o consumo diário de líquido, com tamanhos de recipiente personalizáveis e meta que sobe automaticamente em dias de atividade. Durante o treino, é possível configurar alertas de nutrição por tempo ou distância (por exemplo, a cada 45 minutos ou a cada 5km), lembrando o atleta de se alimentar em provas e treinos longos.</p>"},
    {"type": "banner", "tone": "info", "text": "Bom argumento de venda pra quem já treina longas distâncias e esquece de se alimentar durante o esforço: o alerta tira essa decisão da cabeça do atleta no meio do cansaço."}
  ]
}$j$),
(v_mod_seguranca, 'Aplicando isso em provas longas', 'text', 3, true, $j${
  "blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abordando quem vai correr a primeira ultra ou maratona em local desconhecido", "dialog": "Pra uma prova assim, o relógio ajuda em três frentes: segurança com LiveTrack e Detecção de Incidente, aclimatação se o clima ou altitude for diferente do que você treina, e alerta de nutrição pra não esquecer de se alimentar no meio do esforço.", "tip": "Bom roteiro pra cliente que já demonstrou nervosismo com uma prova de distância ou terreno desconhecido."}
    ]}
  ]
}$j$);

-- Quiz: Segurança, Aclimatação e Nutrição (8 perguntas)
insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_seguranca, 'O que é LiveTrack?', 'LiveTrack compartilha a localização em tempo real durante uma atividade cronometrada.', 0) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Compartilhamento de localização em tempo real durante a atividade', true, 0),
(v_q, 'Um plano de treino guiado', false, 1),
(v_q, 'Um sensor de temperatura', false, 2),
(v_q, 'Um tipo de bateria solar', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_seguranca, 'O que a Detecção de Incidente faz automaticamente?', 'Detecta mudança brusca de movimento e envia alerta automático com nome, localização e link do LiveTrack.', 1) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Envia alerta automático com nome, localização e link do LiveTrack', true, 0),
(v_q, 'Liga direto pro serviço de emergência local', false, 1),
(v_q, 'Para o relógio de funcionar', false, 2),
(v_q, 'Envia mensagem só depois que o atleta confirma manualmente', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_seguranca, 'Qual a diferença entre Detecção de Incidente e Assistência?', 'Detecção de Incidente é automática; Assistência é acionada manualmente pelo próprio atleta.', 2) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Detecção é automática; Assistência é acionada manualmente', true, 0),
(v_q, 'São exatamente a mesma coisa', false, 1),
(v_q, 'Assistência é automática; Detecção é manual', false, 2),
(v_q, 'Só um dos dois funciona ao ar livre', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_seguranca, 'Do que os recursos de segurança do relógio dependem pra funcionar?', 'Dependem do relógio estar pareado por Bluetooth com um celular com plano de dados ativo.', 3) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Pareamento Bluetooth com celular com plano de dados ativo', true, 0),
(v_q, 'Assinatura extra do Garmin Connect', false, 1),
(v_q, 'Estar em modo avião', false, 2),
(v_q, 'Nenhuma dependência, funciona sempre sozinho', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_seguranca, 'O que os recursos de Aclimatação de Calor e Altitude acompanham?', 'Acompanham a adaptação do corpo do atleta a treinar em condições de calor ou altitude ao longo dos dias.', 4) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'A adaptação do corpo a calor ou altitude ao longo dos dias', true, 0),
(v_q, 'A velocidade máxima atingida na prova', false, 1),
(v_q, 'O consumo de bateria do relógio', false, 2),
(v_q, 'A distância total percorrida no mês', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_seguranca, 'O que o widget de Hidratação permite personalizar?', 'Permite personalizar o tamanho do recipiente e ajusta a meta automaticamente em dias de atividade.', 5) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'O tamanho do recipiente, com meta que sobe em dias de atividade', true, 0),
(v_q, 'Só a cor do ícone na tela', false, 1),
(v_q, 'O tipo de bebida esportiva consumida', false, 2),
(v_q, 'Não é possível personalizar nada', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_seguranca, 'Como funcionam os alertas de nutrição durante um treino longo?', 'Podem ser configurados por tempo ou distância, por exemplo a cada 45 minutos ou a cada 5km.', 6) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Configurados por tempo ou distância, como a cada 45 minutos ou 5km', true, 0),
(v_q, 'Disparam só uma vez no início do treino', false, 1),
(v_q, 'Só funcionam em corridas oficiais cadastradas', false, 2),
(v_q, 'Precisam ser ativados manualmente a cada minuto', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_seguranca, 'Pra quem esses recursos combinados (segurança, aclimatação, nutrição) são especialmente relevantes?', 'São relevantes pra atletas se preparando pra provas longas ou em condições/terrenos diferentes do que treinam normalmente.', 7) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Atletas se preparando pra provas longas em condições diferentes do treino habitual', true, 0),
(v_q, 'Só corredores de 5km em pista', false, 1),
(v_q, 'Apenas ciclistas urbanos', false, 2),
(v_q, 'Só quem já é profissional', false, 3);

end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 088
-- ============================================================================
