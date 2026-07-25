-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 099: restaura conteúdo perdido do módulo
-- "Linha Edge de Entrada e Sensores" e corrige menção a produtos fora de linha
-- ============================================================================
-- Um agente em background (auditoria de qualidade rodando nesta sessão) foi
-- interrompido no meio da reescrita deste módulo por limite de sessão da API,
-- deixando as 4 lições com body = {"blocks": []} (conteúdo apagado, nunca
-- reinserido). Esta migração restaura o conteúdo original (migração 087),
-- já aplicando a correção que o usuário pediu:
--
-- "a linha edge já tá toda errada. os modelos mais atuais que temos são
-- linha edge 540/550 840/850 1040/1050. não trabalhamos mais com edge
-- explorer nem 130 plus"
--
-- A Lição 1 original usava Edge Explore 2 e Edge 130 Plus como "portas de
-- entrada" — produtos que a loja não trabalha mais. Reescrita do zero para
-- usar Edge 540 e Edge 550 (a dupla de entrada real da linha completa hoje),
-- com specs pesquisadas e confirmadas em fontes oficiais/especializadas
-- (garmin.com newsroom, DC Rainmaker, Cyclists Hub, BikeRadar, Cyclingnews,
-- julho/2026): 540 é 2.6" MIP refletiva/26h bateria/16GB, 550 é 2.7" LCD
-- transmissiva mais brilhante/12h bateria/32GB — os dois só com botão, sem
-- touchscreen (só a partir do 840/850 tem touch). A Lição 4 (roteiro de
-- vendas) também citava o 130 Plus como exemplo de bateria longa; trocado
-- por Edge 540 (mesmo argumento, produto real da linha).
-- ============================================================================

begin;

-- Lição 1 (era: Edge Explore 2 / Edge 130 Plus) — Edge 540 vs Edge 550
update lessons set
  title = 'Edge 540 e Edge 550: as portas de entrada da linha completa',
  body = $j${
    "blocks": [
      {"type": "texto_rico", "html": "<p>O Edge 540 e o Edge 550 são as duas portas de entrada da linha Edge completa hoje. Não são versões limitadas: os dois rodam o mesmo motor de treino dos modelos de topo (ClimbPro, sugestão de treino, GPS multibanda e leitura de Dinâmica de Pedal quando pareados com Rally). A diferença entre eles está na tela e na bateria, não na profundidade de treino.</p>"},
      {"type": "tabela", "headers": ["Recurso", "Edge 540", "Edge 550"], "rows": [
        ["Tela", "2,6\" MIP refletiva", "2,7\" LCD transmissiva, mais brilhante"],
        ["Touchscreen", "Não, só botão", "Não, só botão"],
        ["Bateria", "Até 26h (32h na versão Solar)", "Até 12h em uso intenso (36h no modo economia)"],
        ["Armazenamento", "16 GB", "32 GB"],
        ["Diferencial extra", "Versão Solar disponível", "Smart Fueling, Garmin Cycle Coach expandido, timing gates"]
      ]},
      {"type": "banner", "tone": "info", "text": "Nenhum dos dois tem touchscreen, isso só aparece a partir do Edge 840/850. Se o cliente pergunta por tela sensível ao toque nesse momento da conversa, já é sinal pra apresentar o degrau seguinte."}
    ]
  }$j$
where id = '884d595c-46d3-45bf-be4f-e276c27b6641';

-- Lição 2 — ajustada pra não reapresentar o 540 (já coberto na Lição 1) e
-- cobrir 540/550 → 840/850 juntos
update lessons set
  title = 'Do 540/550 ao 840/850: o que realmente muda',
  body = $j${
    "blocks": [
      {"type": "texto_rico", "html": "<p>Quem já decidiu entre o 540 e o 550 costuma perguntar se vale subir pro 840 ou 850. A resposta curta: o motor de treino é o mesmo (ClimbPro, sugestão de treino, GPS multibanda, leitura de potência e Dinâmica de Pedal via Rally). O que muda de verdade é a experiência de navegação e uso no dia a dia: 840 e 850 têm touchscreen, mais armazenamento e, no 850, alto-falante com Garmin Pay.</p><p>Pra quem já pedala rota conhecida ou importa a rota pronta, o 540 ou o 550 entregam o mesmo treino por um preço mais baixo.</p>"},
      {"type": "metric_card_grid", "columns": 3, "items": [
        {"icon": "🛰️", "name": "GPS multibanda", "definition": "Recepção em duas frequências de satélite, melhora a precisão em áreas com sinal difícil (mata fechada, prédios altos)."},
        {"icon": "⛰️", "name": "ClimbPro", "definition": "Mostra em tempo real a subida que vem pela frente: distância, inclinação média e o quanto falta de elevação."},
        {"icon": "💪", "name": "Power Match", "definition": "Sincroniza a leitura de potência do pedal com o computador, evitando divergência entre os dois."}
      ]},
      {"type": "banner", "tone": "info", "text": "O 540, o 550, o 840 e o 850 leem Dinâmica de Pedal do mesmo jeito quando pareados com pedais Rally. A diferença de preço é tela, touchscreen e bateria, não profundidade de treino."}
    ]
  }$j$
where id = '99ce4530-f2af-4f99-acf5-f9521c791d1f';

-- Lição 3 (Sensores externos) — restaurada sem alteração, não citava produto fora de linha
update lessons set
  body = $j${
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
  }$j$
where id = '93e274cf-aa29-4cb2-8b6c-bb66528604e5';

-- Lição 4 (Edge dedicado vs celular) — restaurada, trocando o exemplo de
-- bateria do Edge 130 Plus (fora de linha) pelo Edge 540 (mesma métrica real, 26h)
update lessons set
  body = $j${
    "blocks": [
      {"type": "roteiro", "steps": [
        {"title": "Abertura pra quem hoje só usa o celular", "dialog": "Você já treina com o Strava no celular, né? Isso é ótimo pra começar, mas repara: o GPS do celular não foi feito pra ficar preso no guidão horas seguidas, e a bateria dele derrete rápido tocando GPS o treino inteiro.", "tip": "Valide o que o cliente já faz antes de questionar; ninguém gosta de ouvir que a solução atual é ruim."},
        {"title": "Autonomia como diferencial concreto", "dialog": "Um Edge de entrada como o 540 roda até 26 horas de GPS contínuo, enquanto boa parte dos celulares não passa de 3 ou 4 horas de GPS contínuo sem descarregar.", "tip": "Bom argumento pra quem já reclamou do celular morrendo no meio do pedal."},
        {"title": "Sensor pareado é o que o celular não faz bem", "dialog": "E tem outra coisa: dá pra parear sensor de velocidade, cadência e frequência cardíaca direto no Edge, com dado muito mais estável que o que um app de celular consegue captar sozinho.", "tip": "Sempre puxe esse ponto se o cliente já mencionou usar sensor com o celular e reclamar de falha de conexão."}
      ]},
      {"type": "objecao", "items": [
        {"question": "Só uso o celular, funciona bem, pra que gastar mais?", "answer": "Funciona pra registrar o treino, mas o celular guardado no bolso ou na bolsa de quadro não capta rota com a mesma precisão de um GPS dedicado no guidão, e some a bateria rápido usando tela e GPS ao mesmo tempo. Um Edge é feito só pra isso, então dura o pedal inteiro sem drama."}
      ]}
    ]
  }$j$
where id = '3f7c150e-115f-492f-ac26-5cfd74b29509';

-- Quiz Q0 (era: foco do Edge Explore 2) → diferença 540 vs 550
update questions set
  body = 'Qual é a principal troca (trade-off) entre o Edge 540 e o Edge 550?',
  explanation = 'O Edge 550 tem tela mais brilhante e de maior resolução, mas dura bem menos (12h) que o Edge 540 (26h, ou 32h na versão Solar).'
where id = 'c3ed07d3-e978-4af9-8709-b8648f90d44e';
update alternatives set body = 'Tela mais brilhante e rápida no 550, contra bateria bem mais longa no 540', is_correct = true where id = 'adb27ced-e3e1-4737-bee2-78bdd65bded0';
update alternatives set body = 'Só o 550 lê Dinâmica de Pedal', is_correct = false where id = 'e296bfdf-7374-422a-8e88-805f2c7e14d2';
update alternatives set body = 'Só o 540 tem GPS multibanda', is_correct = false where id = '5f721d29-6d50-44ee-9b62-612081ac96d0';
update alternatives set body = 'O 540 tem touchscreen e o 550 não', is_correct = false where id = 'f71f30cb-0a07-4673-b6af-54c2d52a2b45';

-- Quiz Q1 (era: Edge 130 Plus aceita treino estruturado?) → 540/550 têm o
-- mesmo motor de treino dos modelos de topo
update questions set
  body = 'O Edge 540 e o Edge 550 leem potência e Dinâmica de Pedal quando pareados com Rally, igual aos modelos 840/850/1040/1050?',
  explanation = 'Sim, o motor de treino é o mesmo em toda a linha completa. A diferença entre os tiers é tela, touchscreen, armazenamento e bateria, não profundidade de treino.'
where id = '52e146ed-6612-4e53-b3ab-cd0054173d10';
update alternatives set body = 'Sim, o motor de treino é o mesmo em toda a linha', is_correct = true where id = '1bfe3288-914c-43de-ad54-c3a288836702';
update alternatives set body = 'Não, potência só nos modelos com touchscreen', is_correct = false where id = 'b5869139-6a19-4d8a-babc-6384f3482612';
update alternatives set body = 'Só o 550 lê Dinâmica de Pedal, o 540 não', is_correct = false where id = '69840787-07d6-4145-aaa1-235be86c85d5';
update alternatives set body = 'Não, isso é exclusivo dos modelos 1040/1050', is_correct = false where id = 'ca63dd9b-e2c7-46c6-8906-60548f853ad5';

-- Quiz do módulo "Potência e Dinâmica de Pedal" também tinha o Edge Explore 2
-- como alternativa errada de uma pergunta (não afeta a resposta correta, mas
-- reforça o nome de um produto fora de linha) e não incluía o 550 na lista de
-- modelos corretos
update questions set explanation = 'Toda a linha completa de Edge (540, 550, 840, 850, 1040, 1050) lê potência e Dinâmica de Pedal quando pareada com Rally.'
where id = 'b97b2ec2-d999-4f3d-a977-99cc54e00d2e';
update alternatives set body = 'Toda a linha completa: 540, 550, 840, 850, 1040 e 1050' where id = '18855f04-35ec-4fa8-a51b-845c7bbd666c';
update alternatives set body = 'Só os modelos com touchscreen (840, 850, 1050)' where id = 'b1f69167-e78f-4dc0-92ae-b94a2d4b591f';

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 099
-- ============================================================================
