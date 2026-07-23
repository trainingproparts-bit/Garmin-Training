-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 089: conteúdo dos 4 módulos vazios da Zona Triatleta
-- ============================================================================
-- Mesma situação das migrações 087/088: os 4 módulos da Zona Triatleta
-- (O Universo Multiesporte, GPS Multibanda (SatIQ) e Cartografia Completa,
-- Ecossistema de Sensores de Elite, Fechamento de Vendas Premium) e seus
-- quizzes estavam publicados mas vazios. Esta migração preenche as 4,
-- fechando a trilha inteira Zona Atleta + Maratonista + Triatleta.
-- ============================================================================

do $$
declare
  v_mod_multiesporte uuid := '73860bf6-5d81-466f-a7dc-fc3c6098f98e';
  v_mod_satiq        uuid := '2b59a45f-8470-41bd-a934-82af2afc0a24';
  v_mod_sensores      uuid := '52a7dec7-984a-488c-bd81-cdd3eae7bf65';
  v_mod_fechamento    uuid := '6abc89b6-ed98-4ab8-8e57-ab5b43e5e942';
  v_quiz_multiesporte uuid := '30a27b5d-829a-4a9b-8c69-eb30e6f5ff3e';
  v_quiz_satiq        uuid := '18c34af7-31b0-4640-9b21-8a7814228929';
  v_quiz_sensores     uuid := '0b42b2d9-46be-4336-96a3-523b5edbd708';
  v_quiz_fechamento   uuid := '57a093ca-9eba-4eea-b365-39512c9bbede';
  v_q uuid;
begin

-- ============================================================================
-- MÓDULO 1: O Universo Multiesporte
-- ============================================================================

insert into lessons (module_id, title, content_type, order_index, is_published, body) values
(v_mod_multiesporte, 'O que é uma atividade multiesporte', 'text', 0, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>A Garmin não vende um relógio \"só de triathlon\": o perfil <strong>multiesporte</strong> é um modo de atividade disponível nos relógios com tela AMOLED da linha atual (Forerunner 970/965, Fenix 8, Epix Pro). O perfil padrão de Triathlon já vem pronto (natação, transição 1, ciclismo, transição 2, corrida), mas também dá pra montar uma sequência de esportes totalmente customizada.</p><p>A grande sacada técnica é o <strong>Auto Sport Change</strong>: o relógio detecta sozinho a troca de uma etapa pra outra, registrando o tempo de transição separado do tempo de cada esporte, sem o atleta precisar apertar botão nenhum na troca.</p>"},
    {"type": "banner", "tone": "info", "text": "O tempo total da prova soma todas as etapas mais as transições; é isso que aparece no resumo combinado da atividade no Garmin Connect."}
  ]
}$j$),
(v_mod_multiesporte, 'Métricas de natação: SWOLF e detecção de nado', 'text', 1, true, $j${
  "blocks": [
    {"type": "metric_card_grid", "columns": 2, "items": [
      {"icon": "🏊", "name": "SWOLF", "definition": "Soma o tempo (segundos) e o número de braçadas de uma piscina; quanto menor o número, mais eficiente é o nado. Em mar aberto, o cálculo é normalizado pra um intervalo de 25m."},
      {"icon": "🔄", "name": "Detecção automática de nado", "definition": "Identifica sozinho o estilo (livre, costas, peito, borboleta) ao fim de cada piscina; só funciona em piscina, não em mar aberto."}
    ]},
    {"type": "banner", "tone": "info", "text": "Auto Rest (pausa automática ao ficar parado por mais de 15 segundos) também é exclusivo de piscina."}
  ]
}$j$),
(v_mod_multiesporte, 'Treino brick: bike direto pra corrida', 'text', 2, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Treino <strong>brick</strong> (bike seguido direto de corrida, sem descanso) é uma das preparações mais específicas de triathlon. A recomendação da própria Garmin é gravar esse treino já dentro do perfil Multiesporte, pra que o tempo total e o tempo de transição fiquem registrados juntos, em vez de duas atividades soltas sem conexão entre si.</p>"},
    {"type": "objecao", "items": [
      {"question": "Por que não simplesmente gravar bike e corrida como duas atividades separadas?", "answer": "Dá pra fazer, mas separa os dados: o relógio não junta o tempo total nem calcula a transição entre as duas etapas. Gravando como Multiesporte, o atleta enxerga o treino inteiro (incluindo a transição) como uma coisa só, mais parecido com o que vai viver no dia da prova."}
    ]}
  ]
}$j$),
(v_mod_multiesporte, 'Quais relógios suportam o perfil Multiesporte', 'text', 3, true, $j${
  "blocks": [
    {"type": "banner", "tone": "warn", "text": "O perfil Multiesporte completo (com Auto Sport Change) está na linha atual AMOLED: Forerunner 970/965, Fenix 8 e Epix Pro (Gen 2). Confirme sempre o modelo específico do cliente antes de afirmar suporte total ao recurso."}
  ]
}$j$);

-- Quiz: O Universo Multiesporte (8 perguntas)
insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_multiesporte, 'O que é o Auto Sport Change?', 'É a detecção automática da troca de uma etapa pra outra dentro de uma atividade multiesporte.', 0) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Detecção automática da troca entre etapas do multiesporte', true, 0),
(v_q, 'Um sensor de temperatura', false, 1),
(v_q, 'Uma configuração de tela', false, 2),
(v_q, 'Um tipo de bateria', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_multiesporte, 'O tempo de transição entre etapas é contado como parte do tempo de cada esporte?', 'Não, o tempo de transição é registrado separadamente do tempo de cada segmento esportivo.', 1) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Não, é registrado separado', true, 0),
(v_q, 'Sim, soma direto no tempo da corrida', false, 1),
(v_q, 'Sim, soma direto no tempo do ciclismo', false, 2),
(v_q, 'O relógio descarta o tempo de transição', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_multiesporte, 'O que é SWOLF?', 'SWOLF soma tempo e número de braçadas de uma piscina; quanto menor, mais eficiente é o nado.', 2) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'A soma de tempo e braçadas de uma piscina, indicando eficiência', true, 0),
(v_q, 'A velocidade máxima de nado', false, 1),
(v_q, 'A frequência cardíaca durante o nado', false, 2),
(v_q, 'A distância total nadada no mês', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_multiesporte, 'A detecção automática de estilo de nado (livre, costas, peito, borboleta) funciona em mar aberto?', 'Não, só funciona em piscina; em mar aberto não há detecção automática de estilo.', 3) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Não, só funciona em piscina', true, 0),
(v_q, 'Sim, funciona igual nos dois ambientes', false, 1),
(v_q, 'Só funciona em mar aberto', false, 2),
(v_q, 'Não existe esse recurso em nenhum ambiente', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_multiesporte, 'O que é um treino brick?', 'Treino brick é bike seguido direto de corrida, sem descanso, uma preparação específica de triathlon.', 4) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Bike seguido direto de corrida, sem descanso', true, 0),
(v_q, 'Um treino só de natação', false, 1),
(v_q, 'Um treino de força na academia', false, 2),
(v_q, 'Um tipo de descanso ativo', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_multiesporte, 'Por que a Garmin recomenda gravar o brick como atividade Multiesporte em vez de duas atividades separadas?', 'Assim o tempo total e a transição ficam registrados juntos, mais parecido com o dia da prova.', 5) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Pra registrar tempo total e transição juntos, como no dia da prova', true, 0),
(v_q, 'Porque duas atividades separadas gastam mais bateria', false, 1),
(v_q, 'Porque o Garmin Connect não aceita duas atividades no mesmo dia', false, 2),
(v_q, 'Não há diferença real entre os dois jeitos de gravar', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_multiesporte, 'Quais relógios da linha atual suportam o perfil Multiesporte completo com Auto Sport Change?', 'Forerunner 970/965, Fenix 8 e Epix Pro (Gen 2), todos com tela AMOLED.', 6) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Forerunner 970/965, Fenix 8 e Epix Pro', true, 0),
(v_q, 'Só o Instinct 3', false, 1),
(v_q, 'Nenhum relógio atual, só via aplicativo de celular', false, 2),
(v_q, 'Só relógios com tela MIP', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_multiesporte, 'Auto Rest (pausa automática após 15 segundos parado) funciona em qual ambiente?', 'Auto Rest é exclusivo de piscina, assim como a detecção automática de estilo.', 7) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Só em piscina', true, 0),
(v_q, 'Só em mar aberto', false, 1),
(v_q, 'Em qualquer atividade de corrida', false, 2),
(v_q, 'Em qualquer atividade de ciclismo', false, 3);

-- ============================================================================
-- MÓDULO 2: GPS Multibanda (SatIQ) e Cartografia Completa
-- ============================================================================

insert into lessons (module_id, title, content_type, order_index, is_published, body) values
(v_mod_satiq, 'O que é SatIQ', 'text', 0, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p><strong>SatIQ</strong> é a tecnologia da Garmin que alterna automaticamente entre modo de satélite padrão e multibanda, dependendo do ambiente. Em céu aberto, o relógio permanece no modo padrão pra economizar bateria; em mata fechada ou entre prédios altos, ele sobe sozinho pro modo multibanda, sem o atleta precisar escolher manualmente.</p>"},
    {"type": "banner", "tone": "info", "text": "A vantagem de vender o SatIQ é justamente essa: o cliente não precisa entender de GPS pra ter a melhor precisão possível, o relógio decide sozinho."}
  ]
}$j$),
(v_mod_satiq, 'GPS multibanda: o que muda na prática', 'text', 1, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>GPS multibanda recebe duas frequências (L1 e L5) do mesmo satélite ao mesmo tempo, o que resulta numa leitura de posição mais limpa em ambientes que refletem ou bloqueiam sinal, como prédios altos, mata fechada e a superfície da água em nado de mar aberto. Relógios atuais como o Fenix 8 suportam GPS, GLONASS, Galileo, BeiDou e QZSS.</p>"},
    {"type": "banner", "tone": "warn", "text": "Multibanda consome mais bateria que o modo padrão; é exatamente esse o motivo do SatIQ existir, pra equilibrar precisão e autonomia automaticamente."}
  ]
}$j$),
(v_mod_satiq, 'Cartografia completa: TopoActive e ClimbPro', 'text', 2, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p><strong>TopoActive</strong> são os mapas coloridos e gratuitos, baseados em OpenStreetMap, pré-carregados nos relógios com mapeamento (Fenix, Epix, Forerunner 970). O <strong>ClimbPro</strong> mostra em tempo real o trecho de subida à frente: distância, inclinação média e quanto falta de elevação. O <strong>Round-Trip Routing</strong> monta na hora um percurso de ida e volta a partir da distância escolhida pelo atleta, direto no relógio.</p>"},
    {"type": "banner", "tone": "info", "text": "Relógios sem mapeamento mostram só uma trilha (breadcrumb), uma linha de GPS sem informação de rua, relevo ou pontos de interesse. Essa é a diferença que justifica \"cartografia completa\" no nome do módulo."}
  ]
}$j$),
(v_mod_satiq, 'Quando destacar isso pro cliente triatleta', 'text', 3, true, $j${
  "blocks": [
    {"type": "objecao", "items": [
      {"question": "Meu relógio atual já tem GPS, por que multibanda faz diferença?", "answer": "Faz diferença justamente nos ambientes mais difíceis pro triatleta: mar aberto (reflexo da água), mata fechada na trilha de trail e ruas estreitas entre prédios altos na parte de corrida ou ciclismo urbano. GPS padrão perde precisão exatamente nesses cenários."},
      {"question": "Preciso escolher manualmente entre GPS padrão e multibanda?", "answer": "Não, o SatIQ decide sozinho, alternando automaticamente conforme o ambiente detectado durante a atividade."}
    ]}
  ]
}$j$);

-- Quiz: GPS Multibanda (SatIQ) e Cartografia (8 perguntas)
insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_satiq, 'O que o SatIQ faz automaticamente?', 'Alterna entre modo de satélite padrão e multibanda, conforme o ambiente detectado.', 0) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Alterna entre GPS padrão e multibanda conforme o ambiente', true, 0),
(v_q, 'Desliga o GPS pra economizar bateria', false, 1),
(v_q, 'Ativa a lanterna automaticamente', false, 2),
(v_q, 'Muda o idioma do relógio', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_satiq, 'O que é GPS multibanda?', 'GPS multibanda recebe duas frequências (L1 e L5) do mesmo satélite ao mesmo tempo.', 1) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Recepção de duas frequências (L1 e L5) do mesmo satélite', true, 0),
(v_q, 'Um segundo GPS de backup', false, 1),
(v_q, 'Um sensor de altímetro extra', false, 2),
(v_q, 'A conexão Bluetooth com o celular', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_satiq, 'Em quais ambientes o GPS multibanda faz mais diferença pro triatleta?', 'Mar aberto, mata fechada e ruas estreitas entre prédios altos são os cenários onde o GPS padrão perde precisão.', 2) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Mar aberto, mata fechada e ruas entre prédios altos', true, 0),
(v_q, 'Só em pista de atletismo', false, 1),
(v_q, 'Só dentro de academia', false, 2),
(v_q, 'Nenhum ambiente faz diferença real', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_satiq, 'Por que o modo multibanda não fica sempre ligado por padrão?', 'Porque consome mais bateria que o modo padrão; o SatIQ existe pra equilibrar precisão e autonomia automaticamente.', 3) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Porque consome mais bateria que o modo padrão', true, 0),
(v_q, 'Porque não funciona em nenhum satélite', false, 1),
(v_q, 'Porque é incompatível com Bluetooth', false, 2),
(v_q, 'Não existe motivo, é só uma configuração aleatória', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_satiq, 'O que é TopoActive?', 'TopoActive são os mapas coloridos e gratuitos, baseados em OpenStreetMap, pré-carregados nos relógios com mapeamento.', 4) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Mapas coloridos gratuitos pré-carregados nos relógios com mapeamento', true, 0),
(v_q, 'Um plano pago de assinatura de mapas', false, 1),
(v_q, 'Um sensor de altitude', false, 2),
(v_q, 'Um tipo de bateria solar', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_satiq, 'O que o ClimbPro mostra em tempo real?', 'Mostra o trecho de subida à frente: distância, inclinação média e quanto falta de elevação.', 5) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Distância, inclinação média e elevação restante da subida à frente', true, 0),
(v_q, 'A velocidade máxima já atingida', false, 1),
(v_q, 'O nome da rua atual', false, 2),
(v_q, 'A previsão do tempo do dia', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_satiq, 'O que diferencia um relógio com "cartografia completa" de um relógio sem mapeamento?', 'O relógio sem mapeamento mostra só uma trilha (breadcrumb), sem informação de rua, relevo ou pontos de interesse.', 6) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'O sem mapeamento mostra só uma trilha (breadcrumb), sem detalhe de rua ou relevo', true, 0),
(v_q, 'Não existe diferença nenhuma entre os dois', false, 1),
(v_q, 'O sem mapeamento tem mais precisão de GPS', false, 2),
(v_q, 'O sem mapeamento tem bateria maior sempre', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_satiq, 'O que é o Round-Trip Routing?', 'Monta na hora um percurso de ida e volta a partir da distância escolhida pelo atleta, direto no relógio.', 7) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Um percurso de ida e volta montado na hora pela distância escolhida', true, 0),
(v_q, 'Uma rota fixa que nunca muda', false, 1),
(v_q, 'Um alerta de nutrição', false, 2),
(v_q, 'Um modo de economia de bateria', false, 3);

-- ============================================================================
-- MÓDULO 3: Ecossistema de Sensores de Elite
-- ============================================================================

insert into lessons (module_id, title, content_type, order_index, is_published, body) values
(v_mod_sensores, 'HRM-Pro Plus: a cinta que vai além da frequência cardíaca', 'text', 0, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>HRM-Pro Plus</strong> é a cinta cardíaca mais completa da Garmin: além da frequência cardíaca, calcula Dinâmica de Corrida (tempo de contato com o solo, cadência, comprimento de passada, oscilação vertical) e alimenta a Potência de Corrida no pulso. Transmite por ANT+ e Bluetooth ao mesmo tempo, e é resistente à natação: guarda o dado internamente debaixo d'água (o sinal não atravessa a água) e sincroniza com o relógio só depois que o nado termina.</p>"},
    {"type": "banner", "tone": "info", "text": "Esse armazenamento offline embaixo d'água é o que diferencia o HRM-Pro Plus de uma cinta comum: nenhuma cinta simples guarda dado sozinha durante o nado."}
  ]
}$j$),
(v_mod_sensores, 'Running Power: pulso x acessórios dedicados', 'text', 1, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>A Garmin não vende um footpod dedicado de potência de corrida: a Potência de Corrida no pulso usa o acelerômetro do relógio combinado com os dados de Dinâmica de Corrida (vindos da cinta ou do próprio relógio). Acessórios de terceiros dedicados a potência de corrida existem no mercado e costumam ser vistos como mais precisos nesse recurso específico, mas exigem comprar um footpod separado.</p>"},
    {"type": "banner", "tone": "info", "text": "Bom argumento honesto de venda: a Potência de Corrida da Garmin já vem embutida no ecossistema, sem precisar de mais um acessório pra comprar e carregar."}
  ]
}$j$),
(v_mod_sensores, 'tempe e Varia: contexto ambiental e segurança no ciclismo', 'text', 2, true, $j${
  "blocks": [
    {"type": "metric_card_grid", "columns": 2, "items": [
      {"icon": "🌡️", "name": "tempe", "definition": "Sensor ANT+ de temperatura ambiente, bateria de cerca de 1 ano, dá contexto climático pro cálculo de carga de treino em dias muito quentes ou frios."},
      {"icon": "🚨", "name": "Varia (radar/lanterna)", "definition": "Detecta veículos se aproximando por trás a até 140m e avisa o ciclista com alerta visual e sonoro; versões com câmera (RCT715) ainda gravam o trajeto em vídeo."}
    ]},
    {"type": "banner", "tone": "info", "text": "Ambos conectam via ANT+ e/ou Bluetooth ao Edge ou ao relógio, ampliando o que o aparelho sozinho não capta."}
  ]
}$j$),
(v_mod_sensores, 'Montando o ecossistema completo pro triatleta de elite', 'text', 3, true, $j${
  "blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Apresentando o ecossistema como um todo", "dialog": "O relógio sozinho já entrega muita coisa, mas o ecossistema completo é o que separa o atleta casual do sério: HRM-Pro Plus pra dinâmica de corrida e dado seguro na água, tempe pra contexto de calor no treino, e Varia se o ciclismo é feito em rua aberta com tráfego.", "tip": "Apresente o ecossistema em camadas, não tudo de uma vez: comece pelo que resolve a dor imediata do cliente."}
    ]}
  ]
}$j$);

-- Quiz: Ecossistema de Sensores de Elite (8 perguntas)
insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_sensores, 'O que o HRM-Pro Plus calcula além da frequência cardíaca?', 'Calcula Dinâmica de Corrida (tempo de contato, cadência, comprimento de passada, oscilação vertical) e alimenta a Potência de Corrida.', 0) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Dinâmica de Corrida e Potência de Corrida', true, 0),
(v_q, 'A pressão arterial', false, 1),
(v_q, 'O nível de hidratação', false, 2),
(v_q, 'A temperatura da água', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_sensores, 'Como o HRM-Pro Plus lida com dados durante a natação?', 'Guarda o dado internamente debaixo d''água (o sinal não atravessa a água) e sincroniza com o relógio depois do nado.', 1) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Guarda offline debaixo d''água e sincroniza depois', true, 0),
(v_q, 'Transmite normalmente embaixo d''água', false, 1),
(v_q, 'Não funciona em atividade de natação', false, 2),
(v_q, 'Desliga automaticamente na água', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_sensores, 'A Garmin vende um footpod dedicado só de potência de corrida?', 'Não, a Potência de Corrida no pulso usa o acelerômetro do relógio combinado com Dinâmica de Corrida, sem footpod dedicado da própria Garmin.', 2) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Não, usa acelerômetro do relógio combinado com Dinâmica de Corrida', true, 0),
(v_q, 'Sim, é obrigatório comprar o footpod Garmin', false, 1),
(v_q, 'Sim, mas só funciona com Edge', false, 2),
(v_q, 'Não existe Potência de Corrida na Garmin', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_sensores, 'O que o sensor tempe mede?', 'tempe é um sensor ANT+ de temperatura ambiente, dando contexto climático pro cálculo de carga de treino.', 3) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Temperatura ambiente', true, 0),
(v_q, 'Frequência cardíaca', false, 1),
(v_q, 'Potência de pedal', false, 2),
(v_q, 'Nível de oxigênio no sangue', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_sensores, 'O que o Varia radar detecta?', 'Detecta veículos se aproximando por trás a até 140m, avisando o ciclista com alerta visual e sonoro.', 4) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Veículos se aproximando por trás', true, 0),
(v_q, 'Buracos na pista à frente', false, 1),
(v_q, 'A temperatura do asfalto', false, 2),
(v_q, 'O nível de bateria do Edge', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_sensores, 'O que a versão Varia RCT715 tem a mais que a RTL515?', 'A RCT715 soma uma câmera que grava o trajeto em vídeo, além do radar e da luz.', 5) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Uma câmera que grava o trajeto em vídeo', true, 0),
(v_q, 'Detecção de veículos mais longe', false, 1),
(v_q, 'Conexão Wi-Fi', false, 2),
(v_q, 'Bateria solar', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_sensores, 'Como o HRM-Pro Plus transmite dados?', 'Transmite por ANT+ e Bluetooth ao mesmo tempo.', 6) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'ANT+ e Bluetooth simultaneamente', true, 0),
(v_q, 'Só Wi-Fi', false, 1),
(v_q, 'Só cabo USB', false, 2),
(v_q, 'Não transmite, só armazena', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_sensores, 'Qual a melhor forma de apresentar o ecossistema de sensores pro cliente?', 'Apresentar em camadas, começando pelo que resolve a dor imediata do cliente, não tudo de uma vez.', 7) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Em camadas, começando pela dor imediata do cliente', true, 0),
(v_q, 'Sempre oferecer todos os acessórios de uma vez', false, 1),
(v_q, 'Nunca mencionar acessórios além do relógio', false, 2),
(v_q, 'Só falar de acessórios se o cliente perguntar por nome específico', false, 3);

-- ============================================================================
-- MÓDULO 4: Fechamento de Vendas Premium
-- ============================================================================

insert into lessons (module_id, title, content_type, order_index, is_published, body) values
(v_mod_fechamento, 'Fechamento assumptivo e "qual, não se"', 'text', 0, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Em vendas de ticket alto, duas técnicas de fechamento funcionam melhor que perguntar \"você quer comprar?\". O <strong>fechamento assumptivo</strong> pula direto pra um detalhe prático, como \"vamos configurar com a pulseira de titânio ou a padrão?\", assumindo que a venda já está decidida. O <strong>\"qual, não se\"</strong> apresenta duas opções premium (por exemplo, Fenix 8 ou Forerunner 970) em vez de uma escolha binária de comprar ou não.</p>"},
    {"type": "banner", "tone": "info", "text": "Em compras acima de R$ 4.000, o cliente já espera uma postura consultiva, não uma pitch de vendas agressivo. Guie a escolha, não empurre a decisão."}
  ]
}$j$),
(v_mod_fechamento, 'Bundling: aumentando o ticket com sentido', 'text', 1, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Oferecer acessórios junto com a compra principal (pulseira extra, película, cinta HRM) é uma prática comum de varejo pra aumentar o ticket médio, desde que o pacote realmente faça sentido pro uso que o cliente descreveu, e não pareça só uma tentativa de vender mais.</p>"},
    {"type": "objecao", "items": [
      {"question": "Não preciso de mais nada além do relógio.", "answer": "Sem problema, mas já que você mencionou que treina ao ar livre com frequência, vale considerar uma cinta de frequência cardíaca: a leitura óptica de pulso varia mais em esforço intenso, e a cinta te dá um dado mais estável exatamente na hora que mais importa."}
    ]}
  ]
}$j$),
(v_mod_fechamento, 'Garmin x Apple Watch Ultra x Coros: o argumento certo', 'text', 2, true, $j${
  "blocks": [
    {"type": "tabela", "headers": ["Comparação", "Diferencial pra puxar"], "rows": [
      ["Garmin x Apple Watch Ultra", "Autonomia de bateria: semanas no Garmin contra 1-2 dias no Apple Watch, decisivo em treino/prova de múltiplos dias"],
      ["Garmin x Coros", "Coros pode vencer em horas brutas de GPS em alguns modelos, mas o ecossistema Garmin Connect é considerado mais completo em profundidade de treino e recuperação"]
    ]},
    {"type": "banner", "tone": "warn", "text": "Nunca desqualifique o concorrente (\"não presta\"). O argumento correto é diferenciação real: bateria e profundidade do ecossistema de treino, ambos verificáveis, não opinião."}
  ]
}$j$),
(v_mod_fechamento, 'Roteiro de fechamento pro triatleta premium', 'text', 3, true, $j${
  "blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Fechamento assumptivo com dois modelos premium", "dialog": "Pelo que você me contou do treino, os dois que fazem mais sentido são o Fenix 8 e o Forerunner 970. Qual dos dois combina mais com o que você busca: mais recursos multiesporte ou um corpo mais leve focado em corrida?", "tip": "Técnica \"qual, não se\": nunca pergunte se ele quer comprar, pergunte qual dos dois."},
      {"title": "Fechando com bundle relevante", "dialog": "Pra fechar junto, já recomendo uma cinta HRM-Pro Plus: com o volume de treino que você descreveu, o dado de recuperação fica muito mais preciso que só com o sensor óptico do pulso.", "tip": "Só ofereça o bundle depois de já validar a dor real do cliente (nesse caso, precisão de recuperação)."}
    ]}
  ]
}$j$);

-- Quiz: Fechamento de Vendas Premium (8 perguntas)
insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_fechamento, 'O que caracteriza o fechamento assumptivo?', 'Pula direto pra um detalhe prático da compra, assumindo que a venda já está decidida.', 0) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Assumir que a venda está decidida e ir direto a um detalhe prático', true, 0),
(v_q, 'Perguntar repetidamente se o cliente quer comprar', false, 1),
(v_q, 'Oferecer desconto antes de qualquer outra coisa', false, 2),
(v_q, 'Esperar o cliente tomar toda a iniciativa', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_fechamento, 'Como funciona a técnica "qual, não se"?', 'Apresenta duas opções premium em vez de uma escolha binária de comprar ou não.', 1) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Apresentar duas opções premium em vez de comprar ou não', true, 0),
(v_q, 'Perguntar se o cliente prefere pagar à vista ou parcelado', false, 1),
(v_q, 'Oferecer só uma opção sem alternativa', false, 2),
(v_q, 'Comparar preço com o concorrente na frente do cliente', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_fechamento, 'Por que oferecer bundling (acessórios extras) precisa fazer sentido pro cliente?', 'Pra não parecer só uma tentativa de vender mais, e sim algo relevante pro uso real descrito pelo cliente.', 2) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Pra não parecer só uma tentativa de vender mais', true, 0),
(v_q, 'Porque é obrigatório por política da loja', false, 1),
(v_q, 'Porque aumenta a comissão sem relação com o cliente', false, 2),
(v_q, 'Não precisa fazer sentido, qualquer bundle funciona', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_fechamento, 'Qual é o diferencial mais forte de Garmin contra Apple Watch Ultra pro público triatleta?', 'Autonomia de bateria: semanas no Garmin contra 1-2 dias no Apple Watch, decisivo em treino/prova de múltiplos dias.', 3) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Autonomia de bateria de semanas contra 1-2 dias', true, 0),
(v_q, 'O Apple Watch não tem GPS', false, 1),
(v_q, 'O Apple Watch é mais pesado', false, 2),
(v_q, 'Não existe diferencial real', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_fechamento, 'Onde a Coros pode levar vantagem sobre a Garmin em alguns modelos?', 'Coros pode vencer em horas brutas de GPS em alguns modelos específicos.', 4) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Em horas brutas de GPS em alguns modelos', true, 0),
(v_q, 'Na profundidade do ecossistema de treino', false, 1),
(v_q, 'No suporte a multiesporte', false, 2),
(v_q, 'Não existe nenhuma vantagem da Coros', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_fechamento, 'O que o vendedor deve evitar ao comparar com concorrentes?', 'Nunca desqualificar o concorrente; o argumento correto é diferenciação real e verificável.', 5) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Desqualificar o concorrente dizendo que "não presta"', true, 0),
(v_q, 'Mencionar a autonomia de bateria', false, 1),
(v_q, 'Falar sobre o ecossistema Garmin Connect', false, 2),
(v_q, 'Comparar dados verificáveis de especificação', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_fechamento, 'Em compras de ticket alto (acima de R$ 4.000), qual postura o cliente espera?', 'O cliente espera uma postura consultiva, não um pitch de vendas agressivo.', 6) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Postura consultiva, guiando a escolha', true, 0),
(v_q, 'Pitch agressivo com pressão de tempo', false, 1),
(v_q, 'Nenhuma interação, só a etiqueta de preço', false, 2),
(v_q, 'Comparação direta de preço com concorrentes baratos', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_fechamento, 'No roteiro de fechamento pro triatleta premium, quando o bundle (ex.: HRM-Pro Plus) deve ser oferecido?', 'Só depois de já validar a dor real do cliente, nesse caso precisão de recuperação.', 7) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Depois de validar a dor real do cliente', true, 0),
(v_q, 'Antes de qualquer outra conversa', false, 1),
(v_q, 'Só se o cliente pedir por nome', false, 2),
(v_q, 'Nunca, bundle não deve ser oferecido', false, 3);

end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 089
-- ============================================================================
