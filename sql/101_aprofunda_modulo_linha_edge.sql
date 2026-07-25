-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 101: aprofunda o módulo "Linha Edge de
-- Entrada e Sensores", adiciona Edge 1040/1050, Varia RTL515, integração
-- com Rally 110/210, e uma dinâmica de encerramento (jogo de associação)
-- ============================================================================
-- Pedido do usuário: "no modulo do edge tambem faltou falar do 1040 e 1050
-- e do varia rtl515 e do rally 210 e 110. acho que vale a integração nesse
-- modulo pra eles entenderem o ecossistema completo" + "e aprofunde mais
-- nas informações do edge, tá muito basicão" + "faça tambem no final do
-- modulo uma dinamica criativa".
--
-- Specs pesquisadas e confirmadas em fontes oficiais (manuais Garmin,
-- newsroom, DC Rainmaker, the5krunner, Cyclists Hub, BikeRadar):
--   Edge 1040: tela 3.5", bateria 35h (70h economia), 32GB, sem WiFi.
--   Edge 1050: mesma tela, bateria MENOR (20h/60h) por ter WiFi, Garmin Pay
--     e alto-falante embutidos, soma Trendline Popularity Routing/GroupRide.
--   Varia RTL515: radar detecta veículos a até 140m, luz traseira com 5
--     modos (Solid/Peloton/Night Flash/Day Flash/Standby), até 65 lumens no
--     Day Flash visível a 1,6km, bateria de 6 a 16h conforme o modo (até 3
--     meses em standby).
--   Rally 110/210: já coberto em profundidade no módulo "Potência e
--     Dinâmica de Pedal" (migração 087) — aqui a cobertura é de integração
--     com o Edge, não duplicação.
--
-- Reestrutura o módulo de 4 pra 7 lições: aprofunda as lições 1 e 2
-- existentes (specs de peso/preço, extensão até 1040/1050), adiciona 3
-- lições novas (Varia RTL515, integração com Rally, e um jogo de
-- associação de encerramento usando o bloco match_quiz), e adiciona 4
-- perguntas novas ao quiz (INSERT, não edita as 8 perguntas já existentes).
-- ============================================================================

begin;

-- ============================================================================
-- Lição 1 (order_index 0) — aprofundada: soma peso e preço de lançamento
-- ============================================================================
update lessons set
  body = $j${
    "blocks": [
      {"type": "texto_rico", "html": "<p>O Edge 540 e o Edge 550 são as duas portas de entrada da linha Edge completa hoje. Não são versões limitadas: os dois rodam o mesmo motor de treino dos modelos de topo (ClimbPro, sugestão de treino, GPS multibanda e leitura de Dinâmica de Pedal quando pareados com Rally). A diferença entre eles está na tela e na bateria, não na profundidade de treino.</p>"},
      {"type": "tabela", "headers": ["Recurso", "Edge 540", "Edge 550"], "rows": [
        ["Tela", "2,6\" MIP refletiva", "2,7\" LCD transmissiva, mais brilhante"],
        ["Touchscreen", "Não, só botão", "Não, só botão"],
        ["Bateria", "Até 26h (32h na versão Solar)", "Até 12h em uso intenso (36h no modo economia)"],
        ["Armazenamento", "16 GB", "32 GB"],
        ["Peso", "80 g", "112 g"],
        ["Preço de lançamento (USD)", "US$ 349", "US$ 499"],
        ["Diferencial extra", "Versão Solar disponível", "Smart Fueling, Garmin Cycle Coach expandido, timing gates"]
      ]},
      {"type": "banner", "tone": "info", "text": "Nenhum dos dois tem touchscreen, isso só aparece a partir do Edge 840/850. Se o cliente pergunta por tela sensível ao toque nesse momento da conversa, já é sinal pra apresentar o degrau seguinte."}
    ]
  }$j$
where id = '884d595c-46d3-45bf-be4f-e276c27b6641';

-- ============================================================================
-- Lição 2 (order_index 1) — estendida até o topo de linha (1040/1050)
-- ============================================================================
update lessons set
  title = 'Do 540/550 ao topo de linha: 840/850, 1040 e 1050',
  body = $j${
    "blocks": [
      {"type": "texto_rico", "html": "<p>Quem já decidiu entre o 540 e o 550 costuma perguntar se vale subir pro 840 ou 850. A resposta curta: o motor de treino é o mesmo (ClimbPro, sugestão de treino, GPS multibanda, leitura de potência e Dinâmica de Pedal via Rally). O que muda de verdade é a experiência de navegação e uso no dia a dia: 840 e 850 têm touchscreen, mais armazenamento e, no 850, alto-falante com Garmin Pay.</p><p>No topo da linha estão o Edge 1040 e o Edge 1050, com a maior tela (3,5\") e mais bateria que qualquer outro Edge, mesmo o 1050. Isso não é engano: o 1050 soma WiFi (atualiza mapas sem cabo), Garmin Pay, alto-falante embutido e roteamento social (Trendline Popularity Routing, GroupRide aprimorado), mas paga um preço em autonomia por causa disso, 20h em uso intenso contra 35h do 1040. Pra quem já pedala rota conhecida ou importa a rota pronta, qualquer degrau da linha entrega o mesmo treino, a escolha é sobre navegação, conectividade e bateria.</p>"},
      {"type": "tabela", "headers": ["Tier", "Tela", "Touchscreen", "Bateria (uso intenso / economia)", "Diferencial"], "rows": [
        ["540 / 550", "2,6\" ou 2,7\"", "Não", "26h / 32h · 12h / 36h", "Entrada, sem touch"],
        ["840 / 850", "2,6\" ou 2,7\"", "Sim", "26h / 32h · 12h / 36h", "850 soma campainha digital, fueling e clima em tempo real"],
        ["1040", "3,5\"", "Sim", "35h / 70h", "Maior bateria de toda a linha"],
        ["1050", "3,5\"", "Sim", "20h / 60h", "WiFi, Garmin Pay, alto-falante, roteamento social"]
      ]},
      {"type": "metric_card_grid", "columns": 3, "items": [
        {"icon": "🛰️", "name": "GPS multibanda", "definition": "Recepção em duas frequências de satélite, melhora a precisão em áreas com sinal difícil (mata fechada, prédios altos). Presente em toda a linha completa."},
        {"icon": "⛰️", "name": "ClimbPro", "definition": "Mostra em tempo real a subida que vem pela frente: distância, inclinação média e o quanto falta de elevação."},
        {"icon": "💪", "name": "Power Match", "definition": "Sincroniza a leitura de potência do pedal com o computador, evitando divergência entre os dois."}
      ]},
      {"type": "banner", "tone": "info", "text": "O 540, o 550, o 840, o 850, o 1040 e o 1050 leem Dinâmica de Pedal do mesmo jeito quando pareados com pedais Rally. A diferença de preço é tela, touchscreen, conectividade e bateria, nunca profundidade de treino."}
    ]
  }$j$
where id = '99ce4530-f2af-4f99-acf5-f9521c791d1f';

-- ============================================================================
-- Lição 3 (order_index 2) — Sensores externos, sem alteração de conteúdo
-- ============================================================================

-- ============================================================================
-- NOVA Lição (order_index 3) — Varia RTL515
-- ============================================================================
insert into lessons (module_id, title, content_type, order_index, is_published, body) values
('b961aa86-8cb7-47ea-aed7-7862aac0a9d6', 'Varia RTL515: radar traseiro e luz que trabalham juntos', 'text', 3, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Varia RTL515</strong> combina radar traseiro e luz num único acessório: detecta veículos se aproximando por trás a até 140 metros de distância e avisa o ciclista com um alerta visual (barra de LED que aparece na tela do Edge) e sonoro, além de intensificar o pisca da luz conforme o carro se aproxima.</p><p>A luz sozinha já é um diferencial: no modo Day Flash chega a 65 lúmens, visível a até 1,6 km de distância, com ângulo de visão de 220 graus. São 5 modos ao todo (Solid, Peloton pra pedal em grupo, Night Flash, Day Flash e Standby), com bateria que varia de 6 a 16 horas dependendo do modo escolhido, e até 3 meses em standby.</p>"},
    {"type": "metric_card_grid", "columns": 2, "items": [
      {"icon": "📡", "name": "Alcance do radar", "definition": "Até 140 metros, detectando múltiplos veículos ao mesmo tempo e mostrando a distância aproximada na tela do Edge."},
      {"icon": "💡", "name": "5 modos de luz", "definition": "Solid, Peloton, Night Flash, Day Flash (65 lúmens, visível a 1,6km) e Standby, cada um com autonomia diferente de bateria."}
    ]},
    {"type": "objecao", "items": [
      {"question": "O radar substitui olhar por cima do ombro?", "answer": "Não, complementa: o Varia avisa antes mesmo do ciclista perceber o carro, dando mais tempo de reação, mas o hábito de checar visualmente continua sendo parte da segurança no trânsito."}
    ]},
    {"type": "banner", "tone": "info", "text": "Existe também a versão RCT715, com câmera embutida que grava o trajeto além do radar e da luz, coberta em profundidade no módulo Ecossistema de Sensores de Elite."}
  ]
}$j$);

-- ============================================================================
-- NOVA Lição (order_index 4) — integração com Rally 110/210
-- ============================================================================
insert into lessons (module_id, title, content_type, order_index, is_published, body) values
('b961aa86-8cb7-47ea-aed7-7862aac0a9d6', 'Rally 110 e 210: potência de pedal integrada ao Edge', 'text', 4, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Um Edge completa o ecossistema de treino de ciclismo quando pareado com um medidor de potência Rally. A linha atual tem dois níveis: o <strong>Rally 110</strong> (single-sensing, mede potência total e cadência num só pedal) e o <strong>Rally 210</strong> (dual-sensing, mede os dois pedais e soma equilíbrio esquerda/direita e Dinâmica de Pedal completa). Os dois têm bateria interna recarregável com Pedal IQ, a calibração inteligente que avisa quando é hora de recalibrar.</p>"},
    {"type": "banner", "tone": "info", "text": "Todo Edge da linha completa (540 ao 1050) lê potência e Dinâmica de Pedal do mesmo jeito quando pareado com Rally, a profundidade completa sobre Power Phase, PCO e as diferenças entre 110 e 210 está no módulo Potência e Dinâmica de Pedal."}
  ]
}$j$);

-- ============================================================================
-- Lição "Por que um Edge dedicado bate o app do celular" — passa a order_index 5
-- ============================================================================
update lessons set order_index = 5 where id = '3f7c150e-115f-492f-ac26-5cfd74b29509';

-- ============================================================================
-- NOVA Lição (order_index 6) — dinâmica de encerramento (jogo de associação)
-- ============================================================================
insert into lessons (module_id, title, content_type, order_index, is_published, body) values
('b961aa86-8cb7-47ea-aed7-7862aac0a9d6', 'Desafio: monte o ecossistema completo', 'text', 6, true, $j${
  "blocks": [
    {"type": "banner", "tone": "info", "text": "Antes do quiz, teste se você já organizou o ecossistema Edge na cabeça: associe cada item ao que realmente o diferencia."},
    {"type": "match_quiz", "pairs": [
      {"term": "Edge 540 / 550", "definition": "Portas de entrada da linha completa, sem touchscreen"},
      {"term": "Edge 840 / 850", "definition": "Somam touchscreen; o 850 soma campainha digital e fueling"},
      {"term": "Edge 1040", "definition": "Maior bateria de toda a linha (35h / 70h)"},
      {"term": "Edge 1050", "definition": "WiFi, Garmin Pay e alto-falante, com bateria menor que o 1040"},
      {"term": "Speed/Cadence Sensor 2", "definition": "Guardam até 300h de dado sozinhos, sem o Edge por perto"},
      {"term": "HRM 200", "definition": "Cinta de entrada: só frequência cardíaca e HRV"},
      {"term": "HRM 600", "definition": "Cinta completa: Dinâmica de Corrida e resistente à natação"},
      {"term": "Varia RTL515", "definition": "Radar e luz traseiros, detecta carros a até 140m"},
      {"term": "Rally 110 / 210", "definition": "Medidores de potência; o 210 soma Dinâmica de Pedal"}
    ]}
  ]
}$j$);

-- ============================================================================
-- Quiz: 4 perguntas novas sobre 1040/1050, Varia RTL515 e Rally (INSERT,
-- não mexe nas 8 perguntas já existentes)
-- ============================================================================
do $$
declare
  v_quiz_edge uuid := '144ac946-1bf8-487e-b606-ce77d149acc1';
  v_q uuid;
begin

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_edge, 'Por que o Edge 1050 tem MENOS autonomia de bateria que o Edge 1040, mesmo sendo o modelo mais novo?', 'O 1050 soma WiFi, Garmin Pay e alto-falante embutido, recursos que consomem mais energia. Por isso dura 20h em uso intenso contra 35h do 1040.', 8) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Porque os recursos novos (WiFi, Garmin Pay, alto-falante) consomem mais energia', true, 0),
(v_q, 'Porque o 1050 tem uma tela menor e menos eficiente', false, 1),
(v_q, 'Não é verdade, o 1050 tem mais bateria que o 1040', false, 2),
(v_q, 'Porque o 1050 não tem GPS multibanda', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_edge, 'A que distância o radar do Varia RTL515 detecta veículos se aproximando por trás?', 'O Varia RTL515 detecta veículos a até 140 metros de distância, mostrando o alerta na tela do Edge.', 9) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Até 140 metros', true, 0),
(v_q, 'Até 20 metros', false, 1),
(v_q, 'Até 500 metros', false, 2),
(v_q, 'Não tem alcance fixo, depende do GPS do Edge', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_edge, 'Qual a diferença entre o Rally 110 e o Rally 210?', 'O 110 é single-sensing (potência total e cadência, só 1 pedal); o 210 é dual-sensing e soma equilíbrio esquerda/direita e Dinâmica de Pedal completa.', 10) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, '110 é single-sensing; 210 é dual-sensing com Dinâmica de Pedal', true, 0),
(v_q, 'Só muda a cor do pedal', false, 1),
(v_q, '110 é recarregável e o 210 usa bateria de moeda', false, 2),
(v_q, 'O 210 não é compatível com Edge', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz_edge, 'O Edge 1040 tem WiFi integrado pra atualizar mapas sem cabo?', 'Não. WiFi integrado é exclusivo do Edge 1050; o 1040 precisa de app ou computador pra atualizar mapas.', 11) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Não, isso é exclusivo do Edge 1050', true, 0),
(v_q, 'Sim, os dois têm WiFi', false, 1),
(v_q, 'Sim, mas só o 1040 tem, o 1050 não', false, 2),
(v_q, 'Nenhum Edge tem WiFi', false, 3);

end $$;

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 101
-- ============================================================================
