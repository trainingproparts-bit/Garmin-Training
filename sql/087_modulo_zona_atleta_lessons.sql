-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 087: conteúdo dos 3 módulos vazios da Zona Atleta
-- ============================================================================
-- Zona Atleta já tinha 6 módulos com checkpoint publicado, mas 3 deles
-- (Linha Edge de Entrada e Sensores, Potência e Dinâmica de Pedal,
-- Contornando Objeções de Preço) e seus quizzes correspondentes existiam
-- como cascas vazias: is_published=true, zero lessons, zero questions.
-- Colaborador clicava e não via nada. Esta migração preenche as 3.
--
-- Rally: pesquisa oficial (garmin.com/newsroom, julho/2026) confirma que a
-- Garmin renomeou a linha pra só 2 níveis, Rally 110 (single-sensing) e
-- Rally 210 (dual-sensing), com bateria recarregável nova e Pedal IQ — o
-- catálogo da Academia de Produtos ainda usa a nomenclatura antiga
-- (rally-100/200/210) e precisa de correção à parte (fora do escopo desta
-- migração, que só cobre o conteúdo do módulo de treinamento).
-- ============================================================================

do $$
declare
  v_mod_edge      uuid := 'b961aa86-8cb7-47ea-aed7-7862aac0a9d6';
  v_mod_potencia  uuid := '023bbd82-161a-4e5c-b3d7-cd3bbf76bfbd';
  v_mod_objecoes  uuid := '00ced86e-4e45-4f95-b932-1899ad8e8cbe';
  v_quiz_edge     uuid := '144ac946-1bf8-487e-b606-ce77d149acc1';
  v_quiz_potencia uuid := 'b994a0c9-aa8a-450c-9a33-f39cd8a0f6ed';
  v_quiz_objecoes uuid := '76854546-2f5e-45a1-b20e-992f7a946b8b';
  v_q uuid;
begin

-- ============================================================================
-- MÓDULO 1: O Próximo Passo na Bike, Linha Edge de Entrada e Sensores
-- ============================================================================

insert into lessons (module_id, title, content_type, order_index, is_published, body) values
(v_mod_edge, 'Edge Explore 2 e Edge 130 Plus: as portas de entrada na bike', 'text', 0, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Antes de falar do topo de linha, vale entender onde o ciclista costuma começar. O <strong>Edge Explore 2</strong> é o ciclocomputador voltado pra quem quer navegação e registro de rota sem entrar em métricas de treino: tela touchscreen de 3\", USB-C e boa autonomia de bateria. Ele já traz ClimbPro (aviso de subidas no percurso), mas não suporta Dinâmica de Pedal nem treinos estruturados.</p><p>O <strong>Edge 130 Plus</strong> é o ciclocomputador Garmin mais compacto e barato: tela de 1,8\", só com botões, sem mapa colorido. Também tem ClimbPro e aceita treinos estruturados baixados do Garmin Connect, mas o mapeamento é bem mais simples que o Explore 2.</p>"},
    {"type": "tabela", "headers": ["Recurso", "Edge Explore 2", "Edge 130 Plus"], "rows": [
      ["Tela", "3\" touchscreen colorida", "1,8\" só botão"],
      ["Foco principal", "Navegação e rota", "Registro de treino básico"],
      ["ClimbPro", "Sim", "Sim"],
      ["Treinos estruturados", "Não", "Sim"],
      ["Dinâmica de Pedal / potência", "Não", "Não"],
      ["Conectividade", "Bluetooth + USB-C", "Bluetooth + ANT+"]
    ]},
    {"type": "banner", "tone": "info", "text": "Nenhum dos dois lê potência ou Dinâmica de Pedal. Se o cliente já fala em treinar com watts, o próximo degrau (Edge 540) é o caminho, não esses dois modelos de entrada."}
  ]
}$j$),
(v_mod_edge, 'Edge 540: o próximo degrau natural', 'text', 1, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Quando o cliente já treina com regularidade e quer dados de verdade, o <strong>Edge 540</strong> é o ponto de entrada da linha completa: mesmo conjunto de recursos de treino do Edge 840 e 1050 (ClimbPro, sugestão de treinos, GPS multibanda, compatibilidade com Dinâmica de Pedal), só sem touchscreen e sem o mapeamento mais avançado do 840.</p><p>A diferença do 540 pro 840 não é o motor de treino, é a experiência de navegação: o 840 tem tela touch e busca de pontos de interesse melhor pra quem está explorando rota nova. Pra quem já pedala rotas conhecidas ou segue rota importada, o 540 entrega o mesmo treino por um preço mais baixo.</p>"},
    {"type": "metric_card_grid", "columns": 3, "items": [
      {"icon": "🛰️", "name": "GPS multibanda", "definition": "Recepção em duas frequências de satélite, melhora a precisão em áreas com sinal difícil (mata fechada, prédios altos)."},
      {"icon": "⛰️", "name": "ClimbPro", "definition": "Mostra em tempo real a subida que vem pela frente: distância, inclinação média e o quanto falta de elevação."},
      {"icon": "💪", "name": "Power Match", "definition": "Sincroniza a leitura de potência do pedal com o computador, evitando divergência entre os dois."}
    ]},
    {"type": "banner", "tone": "info", "text": "O 540 e o 840 leem Dinâmica de Pedal do mesmo jeito quando pareados com pedais Rally. A diferença de preço é tela e mapa, não profundidade de treino."}
  ]
}$j$),
(v_mod_edge, 'Sensores externos: velocidade, cadência e frequência cardíaca', 'text', 2, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Um Edge sozinho já calcula velocidade e distância por GPS, mas sensores dedicados aumentam a precisão e liberam métricas que o GPS não entrega.</p>"},
    {"type": "metric_card_grid", "columns": 2, "items": [
      {"icon": "🚴", "name": "Speed Sensor 2 / Cadence Sensor 2", "definition": "Instalados no cubo da roda e no pedivela. Transmitem por ANT+ e Bluetooth ao mesmo tempo, com bateria de cerca de 1 ano. O Speed Sensor 2 ainda guarda até 300 horas de dado sozinho, sem precisar do computador por perto."},
      {"icon": "❤️", "name": "HRM-Dual", "definition": "Cinta de frequência cardíaca simples, ANT+ e Bluetooth, sem dinâmica de corrida. Ideal só pra quem quer FC mais precisa que a leitura óptica do pulso."},
      {"icon": "🏃", "name": "HRM-Pro Plus", "definition": "Cinta mais completa: além da FC, calcula Dinâmica de Corrida (tempo de contato com o solo, oscilação vertical, cadência, equilíbrio esquerda/direita) e resiste à natação, guardando dado offline debaixo d'água até sincronizar depois."}
    ]},
    {"type": "objecao", "items": [
      {"question": "Meu relógio já mede frequência cardíaca no pulso, pra que uma cinta?", "answer": "A leitura óptica de pulso sofre mais em esforço alto e em dias frios. Uma cinta como a HRM-Dual ou HRM-Pro Plus lê direto do músculo cardíaco, é mais estável exatamente na hora que a intensidade sobe."}
    ]}
  ]
}$j$),
(v_mod_edge, 'Por que um Edge dedicado bate o app do celular', 'text', 3, true, $j${
  "blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pra quem hoje só usa o celular", "dialog": "Você já treina com o Strava no celular, né? Isso é ótimo pra começar, mas repara: o GPS do celular não foi feito pra ficar preso no guidão horas seguidas, e a bateria dele derrete rápido tocando GPS o treino inteiro.", "tip": "Valide o que o cliente já faz antes de questionar; ninguém gosta de ouvir que a solução atual é ruim."},
      {"title": "Autonomia como diferencial concreto", "dialog": "Um Edge de entrada como o 130 Plus roda o dia inteiro de treino com o GPS ligado, enquanto boa parte dos celulares não passa de 3 ou 4 horas de GPS contínuo sem descarregar.", "tip": "Bom argumento pra quem já reclamou do celular morrendo no meio do pedal."},
      {"title": "Sensor pareado é o que o celular não faz bem", "dialog": "E tem outra coisa: dá pra parear sensor de velocidade, cadência e frequência cardíaca direto no Edge, com dado muito mais estável que o que um app de celular consegue captar sozinho.", "tip": "Sempre puxe esse ponto se o cliente já mencionou usar sensor com o celular e reclamar de falha de conexão."}
    ]},
    {"type": "objecao", "items": [
      {"question": "Só uso o celular, funciona bem, pra que gastar mais?", "answer": "Funciona pra registrar o treino, mas o celular guardado no bolso ou na bolsa de quadro não capta rota com a mesma precisão de um GPS dedicado no guidão, e some a bateria rápido usando tela e GPS ao mesmo tempo. Um Edge é feito só pra isso, então dura o pedal inteiro sem drama."}
    ]}
  ]
}$j$);

-- Quiz: Linha Edge de Entrada e Sensores (8 perguntas)
insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_edge, 'Qual é o foco principal do Edge Explore 2?', 'O Explore 2 é voltado pra navegação e registro de rota, com tela touchscreen colorida de 3".', 0) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Navegação e registro de rota', true, 0),
(v_q, 'Potência e Dinâmica de Pedal', false, 1),
(v_q, 'Treinos estruturados avançados', false, 2),
(v_q, 'Cartografia colorida de topo de linha', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_edge, 'O Edge 130 Plus aceita treinos estruturados baixados do Garmin Connect?', 'Sim, mesmo sendo o modelo mais compacto e sem tela colorida, o 130 Plus aceita treinos estruturados.', 1) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Sim', true, 0),
(v_q, 'Não, só o Explore 2 aceita', false, 1),
(v_q, 'Só com assinatura extra do Garmin Connect', false, 2),
(v_q, 'Só se pareado com um Rally', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_edge, 'O que realmente diferencia o Edge 540 do Edge 840?', 'Os dois compartilham o mesmo motor de treino (ClimbPro, sugestão de treino, GPS multibanda, Dinâmica de Pedal); a diferença é touchscreen e mapeamento mais avançado no 840.', 2) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Touchscreen e profundidade de mapeamento', true, 0),
(v_q, 'Só o 840 lê potência do pedal', false, 1),
(v_q, 'Só o 840 tem ClimbPro', false, 2),
(v_q, 'O 540 não aceita sensores externos', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_edge, 'Power Match serve pra quê?', 'Power Match sincroniza a leitura de potência do pedal com o computador, evitando divergência entre as duas fontes.', 3) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Sincronizar a leitura de potência entre pedal e computador', true, 0),
(v_q, 'Calibrar o GPS multibanda', false, 1),
(v_q, 'Ativar o ClimbPro automaticamente', false, 2),
(v_q, 'Conectar o Edge ao Garmin Pay', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_edge, 'O que o Speed Sensor 2 consegue fazer sozinho, sem o Edge por perto?', 'O Speed Sensor 2 guarda até 300 horas de dado internamente, sincronizando depois quando reconecta.', 4) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Guardar até 300 horas de dado internamente', true, 0),
(v_q, 'Calcular Dinâmica de Pedal sozinho', false, 1),
(v_q, 'Substituir o GPS do Edge', false, 2),
(v_q, 'Emitir alerta de ClimbPro', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_edge, 'Qual a diferença prática entre HRM-Dual e HRM-Pro Plus?', 'HRM-Dual só mede frequência cardíaca; HRM-Pro Plus soma Dinâmica de Corrida e resiste à natação com dado guardado offline.', 5) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'HRM-Pro Plus soma Dinâmica de Corrida e resiste à natação', true, 0),
(v_q, 'Só muda a cor da cinta', false, 1),
(v_q, 'HRM-Dual é mais preciso em frequência cardíaca', false, 2),
(v_q, 'HRM-Pro Plus não transmite por ANT+', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_edge, 'Por que a leitura óptica de pulso costuma falhar mais em esforço alto?', 'A leitura óptica de pulso é mais sensível a variações em esforço intenso e clima frio; uma cinta capta o sinal elétrico direto do músculo cardíaco, mais estável.', 6) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Porque ela é mais sensível a esforço intenso e frio que a leitura da cinta', true, 0),
(v_q, 'Porque o pulso não tem bateria suficiente', false, 1),
(v_q, 'Porque só cintas Garmin funcionam em esforço alto', false, 2),
(v_q, 'Não há diferença real entre as duas', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_edge, 'Qual argumento mais concreto justifica um Edge dedicado no lugar do celular?', 'Autonomia de bateria em GPS contínuo e leitura de sensor pareado mais estável são os diferenciais práticos mais fortes.', 7) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Autonomia de bateria em GPS contínuo e sensor pareado mais estável', true, 0),
(v_q, 'O celular não consegue rodar aplicativo de treino', false, 1),
(v_q, 'Só o Edge tem tela colorida', false, 2),
(v_q, 'O celular não aceita fone bluetooth durante o treino', false, 3);

-- ============================================================================
-- MÓDULO 2: Introdução à Potência e Dinâmica de Pedal
-- ============================================================================

insert into lessons (module_id, title, content_type, order_index, is_published, body) values
(v_mod_potencia, 'O que é potência e por que treinar com watts', 'text', 0, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Potência mede, em watts, o esforço real que o ciclista aplica no pedal, no momento exato em que pedala. É considerada a métrica mais objetiva de treino de ciclismo porque não sofre as variações que frequência cardíaca e velocidade têm: FC muda com cansaço acumulado, calor e hidratação; velocidade muda com vento e inclinação. Potência mostra o esforço mecânico puro, direto na fonte.</p><p>Isso permite montar zonas de treino muito mais consistentes (zona 2, limiar, tiros de potência) e comparar sessões em dias e percursos diferentes com precisão que pulso ou velocímetro não entregam sozinhos.</p>"},
    {"type": "banner", "tone": "info", "text": "Pra ler potência é preciso um medidor dedicado no pedal ou pedivela; nenhum relógio ou Edge calcula watts reais sozinho, sem sensor pareado."}
  ]
}$j$),
(v_mod_potencia, 'Rally 110 e 210: a atual geração de pedais Garmin', 'text', 1, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>A linha Rally é a atual geração de pedais medidores de potência da Garmin, com bateria interna recarregável (até 90 horas de uso, 15 minutos de carga rápida rendem 12 horas de pedal) e Pedal IQ, calibração inteligente que avisa quando é hora de recalibrar. O corpo do pedal é intercambiável entre estrada e off-road, então o mesmo conjunto de sensores muda de bike sem comprar tudo de novo.</p>"},
    {"type": "tabela", "headers": ["Modelo", "Sensor", "Mede", "Preço de lançamento (USD)"], "rows": [
      ["Rally 110", "Single-sensing (1 pedal)", "Potência total e cadência", "US$ 749,99"],
      ["Rally 210", "Dual-sensing (os 2 pedais)", "Potência total, equilíbrio esquerda/direita e Dinâmica de Pedal", "US$ 1.199,99"]
    ]},
    {"type": "banner", "tone": "info", "text": "Confirme sempre o preço em reais no ponto de venda: os valores oficiais divulgados pela Garmin são em dólar."}
  ]
}$j$),
(v_mod_potencia, 'Dinâmica de Pedal: Power Phase, PCO e tempo sentado ou em pé', 'text', 2, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Dinâmica de Pedal só existe no Rally 210 (o dual-sensing), porque precisa medir os dois lados ao mesmo tempo pra entender a mecânica completa da pedalada.</p>"},
    {"type": "metric_card_grid", "columns": 3, "items": [
      {"icon": "🔄", "name": "Power Phase", "definition": "A faixa de ângulo do pedivela em que o ciclista produz potência positiva durante a pedalada."},
      {"icon": "🎯", "name": "Platform Center Offset (PCO)", "definition": "Onde no pedal a força é aplicada, mostra se o pé está posicionado de forma eficiente ou desalinhado."},
      {"icon": "🪑", "name": "Sentado x em pé", "definition": "Tempo e transições entre pedalar sentado e em pé, útil pra entender como o ciclista ataca uma subida."}
    ]},
    {"type": "banner", "tone": "info", "text": "Essas métricas só aparecem no relógio ou Edge quando pareadas com um medidor dual-sensing como o Rally 210, via ANT+."}
  ]
}$j$),
(v_mod_potencia, 'Compatibilidade: quais relógios e Edge leem essas métricas', 'text', 3, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Todos os Edge da linha completa (540, 840, 850, 1040, 1050) leem potência e Dinâmica de Pedal quando pareados com Rally. Entre os relógios, confirme sempre no manual do modelo específico antes de afirmar compatibilidade, já que isso muda entre gerações.</p>"},
    {"type": "objecao", "items": [
      {"question": "Meu Edge já mostra velocidade, por que preciso de um medidor de potência?", "answer": "Velocidade varia com vento, inclinação e superfície; potência mostra o esforço real que você aplica, independente do terreno. É o dado que treinadores usam pra montar plano de treino de verdade."},
      {"question": "Rally 110 já resolve ou preciso do 210?", "answer": "Depende do objetivo: o 110 já entrega potência total e cadência, ótimo pra quem só quer treinar por zona de esforço. O 210 é pra quem quer entender a mecânica da pedalada com Dinâmica de Pedal e equilíbrio entre as pernas."}
    ]}
  ]
}$j$);

-- Quiz: Potência e Dinâmica de Pedal (8 perguntas)
insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_potencia, 'Por que potência é considerada mais objetiva que frequência cardíaca pra treino?', 'FC varia com cansaço, calor e hidratação; potência mede o esforço mecânico real aplicado no pedal.', 0) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Porque mede o esforço mecânico direto, sem sofrer variação de cansaço ou clima', true, 0),
(v_q, 'Porque não precisa de sensor nenhum', false, 1),
(v_q, 'Porque é mais barata de medir', false, 2),
(v_q, 'Porque substitui o GPS', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_potencia, 'É possível ler potência real sem nenhum sensor dedicado?', 'Não, potência sempre exige um medidor dedicado no pedal ou pedivela; nenhum relógio calcula watts reais sozinho.', 1) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Não, sempre precisa de um medidor dedicado', true, 0),
(v_q, 'Sim, todo relógio Garmin calcula sozinho', false, 1),
(v_q, 'Sim, mas só em bikes elétricas', false, 2),
(v_q, 'Sim, usando só o GPS multibanda', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_potencia, 'Qual a diferença entre Rally 110 e Rally 210?', 'O 110 é single-sensing (potência total e cadência); o 210 é dual-sensing e soma equilíbrio esquerda/direita e Dinâmica de Pedal.', 2) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, '110 é single-sensing; 210 é dual-sensing com Dinâmica de Pedal', true, 0),
(v_q, 'Só muda a cor do pedal', false, 1),
(v_q, '110 tem bateria recarregável e 210 não', false, 2),
(v_q, '210 não é compatível com Edge', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_potencia, 'O que é Pedal IQ?', 'Pedal IQ é a calibração inteligente da linha Rally, que avisa automaticamente quando é hora de recalibrar.', 3) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Calibração inteligente que avisa quando recalibrar', true, 0),
(v_q, 'Um app separado de treino', false, 1),
(v_q, 'O nome do corpo do pedal off-road', false, 2),
(v_q, 'Um sensor de temperatura embutido', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_potencia, 'Quanto tempo de carga rápida rende 12 horas de pedal na linha Rally atual?', 'A bateria recarregável da linha Rally 110/210 rende 12 horas de pedal após 15 minutos de carga rápida.', 4) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, '15 minutos', true, 0),
(v_q, '1 hora', false, 1),
(v_q, '5 minutos', false, 2),
(v_q, '30 segundos', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_potencia, 'O que é Power Phase?', 'Power Phase é a faixa de ângulo do pedivela em que o ciclista produz potência positiva.', 5) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'A faixa de ângulo do pedivela com potência positiva', true, 0),
(v_q, 'O total de watts médios da sessão', false, 1),
(v_q, 'O tempo total pedalando em pé', false, 2),
(v_q, 'A distância percorrida em zona 2', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_potencia, 'Platform Center Offset (PCO) indica o quê?', 'PCO mostra onde no pedal a força é aplicada, revelando se o posicionamento do pé é eficiente.', 6) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Onde no pedal a força é aplicada', true, 0),
(v_q, 'A cadência média da pedalada', false, 1),
(v_q, 'A altura do selim', false, 2),
(v_q, 'O ângulo do guidão', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_potencia, 'Quais Edge leem potência e Dinâmica de Pedal quando pareados com Rally?', 'Toda a linha completa de Edge (540, 840, 850, 1040, 1050) lê potência e Dinâmica de Pedal quando pareada com Rally.', 7) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Toda a linha completa: 540, 840, 850, 1040 e 1050', true, 0),
(v_q, 'Só o Edge 1050', false, 1),
(v_q, 'Só o Edge Explore 2', false, 2),
(v_q, 'Nenhum Edge lê isso, só relógios', false, 3);

-- ============================================================================
-- MÓDULO 3: Contornando Objeções de Preço
-- ============================================================================

insert into lessons (module_id, title, content_type, order_index, is_published, body) values
(v_mod_objecoes, 'Por que objeção de preço quase sempre é objeção de valor', 'text', 0, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Quando o cliente diz \"tá caro\", raramente o problema é o número em si: é que ele ainda não enxergou valor suficiente pra justificar aquele número. A técnica clássica de vendas pra isso é <strong>value-stacking</strong>: construir a percepção de valor primeiro (o que o produto resolve, o que substitui, o que evita), e só depois falar de preço. Quem começa a conversa pelo preço perde a chance de construir esse valor antes.</p>"},
    {"type": "roteiro", "steps": [
      {"title": "Feel-Felt-Found", "dialog": "Entendo que pareça um investimento alto de início. Muita gente que já passou por essa loja sentiu a mesma coisa no primeiro contato, e depois de usar por um tempo, percebeu que o que ele entrega junto (GPS, monitor cardíaco, treinador, música offline) substitui vários aparelhos separados.", "tip": "Empatiza, normaliza e só depois reforça com prova concreta. Nunca pule direto pro desconto."}
    ]}
  ]
}$j$),
(v_mod_objecoes, 'Reformulando o preço: custo por dia e comparação de mercado', 'text', 1, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Uma forma eficaz de reduzir a objeção é dividir o preço total pela vida útil esperada do produto (geralmente vários anos de uso diário), transformando um valor alto de uma vez em um custo por dia muito menor, e comparável a gastos que o cliente já considera normais no dia a dia.</p>"},
    {"type": "banner", "tone": "info", "text": "Use essa comparação como técnica de reformulação de valor, não como promessa de economia exata: o objetivo é mudar a percepção de \"gasto único alto\" pra \"investimento diluído\", nunca prometer um número fechado de anos de uso."}
  ]
}$j$),
(v_mod_objecoes, 'Rebatendo "o Apple Watch faz a mesma coisa"', 'text', 2, true, $j${
  "blocks": [
    {"type": "objecao", "items": [
      {"question": "O Apple Watch é mais barato e faz a mesma coisa.", "answer": "Bateria é a diferença mais concreta: um Garmin de linha esportiva aguenta muitos dias sem carregar, enquanto o Apple Watch normalmente pede carga todo dia ou no máximo a cada dois. Pra quem treina ou viaja, isso muda a rotina inteira. Além disso, a Garmin construiu ao longo de mais de dez anos uma camada própria de ciência de treino (Training Readiness, Training Load, Body Battery) que o Apple Watch registra o treino mas não calcula com a mesma profundidade."}
    ]},
    {"type": "banner", "tone": "info", "text": "Nunca afirme que o Apple Watch \"não presta\": o argumento correto é diferenciação de proposta, autonomia de bateria e profundidade de ciência de treino, não desqualificar o concorrente."}
  ]
}$j$),
(v_mod_objecoes, 'Roteiro de fechamento com parcelamento', 'text', 3, true, $j${
  "blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Oferecendo parcelamento sem parecer desespero de venda", "dialog": "Se o valor à vista pesar agora, dá pra parcelar sem juros em várias vezes, o que deixa o valor mensal bem mais leve que o total. Quer que eu já calcule como fica no seu cartão?", "tip": "Só ofereça parcelamento depois de já ter construído o valor; oferecer cedo demais passa a impressão de que o preço é o problema, não a falta de percepção de valor."},
      {"title": "Fechando com escolha, não com sim ou não", "dialog": "Prefere fechar no modelo que a gente conversou ou prefere já levar com a cinta extra também, pra já sair rodando sem precisar voltar depois?", "tip": "Técnica de fechamento assumindo a venda: a pergunta não é se compra, é qual opção leva."}
    ]}
  ]
}$j$);

-- Quiz: Contornando Objeções de Preço (8 perguntas)
insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_objecoes, 'Quando o cliente diz "tá caro", o que geralmente está por trás disso?', 'Na maioria das vezes o problema é falta de percepção de valor, não o número em si.', 0) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Falta de percepção de valor sobre o que o produto entrega', true, 0),
(v_q, 'O cliente sempre quer o produto mais barato da loja', false, 1),
(v_q, 'O vendedor errou o preço', false, 2),
(v_q, 'O cliente não tem interesse real na compra', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_objecoes, 'O que é a técnica de value-stacking?', 'Value-stacking constrói a percepção de valor antes de falar de preço, em vez de abrir a conversa pelo número.', 1) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Construir valor percebido antes de falar de preço', true, 0),
(v_q, 'Empilhar vários produtos na mesma venda', false, 1),
(v_q, 'Oferecer desconto progressivo', false, 2),
(v_q, 'Comparar preços com concorrentes na frente do cliente', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_objecoes, 'Como funciona a técnica Feel-Felt-Found?', 'Empatiza com o sentimento do cliente, normaliza (outros sentiram o mesmo) e reforça com uma descoberta concreta.', 2) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Empatiza, normaliza com outros clientes e reforça com um fato concreto', true, 0),
(v_q, 'Oferece desconto imediato', false, 1),
(v_q, 'Ignora a objeção e muda de assunto', false, 2),
(v_q, 'Compara o preço com o concorrente mais caro do mercado', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_objecoes, 'Por que dividir o preço total em custo por dia ajuda na conversa?', 'Transforma um valor alto único em um número menor e mais familiar ao cliente, mudando a percepção sem prometer economia exata.', 3) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Muda a percepção de gasto único alto pra investimento diluído no dia a dia', true, 0),
(v_q, 'Reduz o preço final de fato', false, 1),
(v_q, 'É uma promessa oficial de economia da Garmin', false, 2),
(v_q, 'Só funciona se o cliente pagar à vista', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_objecoes, 'Qual é o argumento tecnicamente mais forte contra "o Apple Watch faz a mesma coisa"?', 'Autonomia de bateria de vários dias e a camada própria de ciência de treino são os diferenciais concretos, não uma desqualificação do concorrente.', 4) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Autonomia de bateria de vários dias e ciência de treino própria da Garmin', true, 0),
(v_q, 'O Apple Watch não tem GPS', false, 1),
(v_q, 'O Apple Watch quebra fácil', false, 2),
(v_q, 'Nenhum argumento técnico funciona, só o preço decide', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_objecoes, 'Ao comparar com o Apple Watch, o que o vendedor deve evitar?', 'Nunca desqualificar o concorrente, o argumento correto é diferenciação real de proposta.', 5) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Afirmar que o concorrente "não presta"', true, 0),
(v_q, 'Mencionar a autonomia de bateria', false, 1),
(v_q, 'Falar sobre Training Readiness', false, 2),
(v_q, 'Comparar profundidade de ciência de treino', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_objecoes, 'Quando é o melhor momento pra oferecer parcelamento?', 'Só depois de já ter construído o valor percebido; oferecer cedo demais passa a impressão de que o preço é o problema central.', 6) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Depois de já ter construído a percepção de valor', true, 0),
(v_q, 'Assim que o cliente entra na loja', false, 1),
(v_q, 'Antes de mostrar qualquer recurso do produto', false, 2),
(v_q, 'Nunca oferecer, só se o cliente perguntar', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_objecoes, 'O que caracteriza a técnica de fechamento por escolha ("qual opção, não se compra")?', 'A pergunta assume que a venda vai acontecer e oferece uma escolha entre opções, em vez de perguntar se o cliente quer comprar.', 7) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Assumir a venda e oferecer uma escolha entre opções', true, 0),
(v_q, 'Perguntar diretamente se o cliente quer comprar', false, 1),
(v_q, 'Oferecer desconto até o cliente aceitar', false, 2),
(v_q, 'Esperar o cliente tomar a iniciativa de fechar', false, 3);

end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 087
-- ============================================================================
