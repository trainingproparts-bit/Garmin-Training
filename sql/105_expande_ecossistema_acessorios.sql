-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 105: expande "Ecossistema de Sensores de
-- Elite" pro inventário real de acessórios da loja + pulseiras QuickFit
-- ============================================================================
-- Pedido do usuário: módulo tava simples demais, faltava HRM 200 (já coberto
-- em profundidade no módulo HRM, aqui só cross-referenciado), sensor de
-- cadência e velocidade, Varia RTL515 com specs reais, carregadores USB-C e
-- USB, e principalmente pulseiras (QuickFit do Fenix/Instinct 3/Forerunner
-- do portfólio, UltraFit de nylon, tamanhos e como identificar qual é qual).
--
-- Specs pesquisadas e confirmadas (garmin.com, manuais oficiais, StrapsCo,
-- watchband.direct, julho/2026):
--   QuickFit tem 3 larguras (20/22/26mm), definidas pelo tamanho da caixa:
--     Fenix 8 42/43mm→20mm, 47mm→22mm, 51mm→26mm
--     Instinct 3 45mm→22mm, 50mm→26mm
--     Forerunner 970→22mm (único Forerunner do portfólio com QuickFit real;
--       55/165/170/570 usam pino de troca rápida padrão, não QuickFit)
--   UltraFit (pulseira de nylon trançado) vem nas mesmas 3 larguras.
--   O tamanho vem gravado na parte de baixo/interna da pulseira (ex.:
--     "QuickFit 22").
--   Cabo de carregamento: clipe magnético proprietário é igual em qualquer
--     cabo, mas a ponta que liga na tomada/computador varia — USB-C nos
--     relógios 2022+ (linha atual inteira), USB-A em modelos mais antigos.
-- ============================================================================

begin;

update modules set title = 'Ecossistema de Acessórios: Sensores, Carregadores e Pulseiras' where id = '52a7dec7-984a-488c-bd81-cdd3eae7bf65';

-- Lição 2 (era "tempe e Varia") — soma sensores de cadência/velocidade e specs reais do Varia RTL515
update lessons set
  title = 'Sensores externos: cadência, velocidade e Varia RTL515',
  body = $j${
    "blocks": [
      {"type": "metric_card_grid", "columns": 2, "items": [
        {"icon": "🚴", "name": "Speed Sensor 2 / Cadence Sensor 2", "definition": "Instalados no cubo da roda e no pedivela. Transmitem por ANT+ e Bluetooth ao mesmo tempo, com bateria de cerca de 1 ano. O Speed Sensor 2 ainda guarda até 300 horas de dado sozinho, sem precisar do relógio ou Edge por perto."},
        {"icon": "🌡️", "name": "tempe", "definition": "Sensor ANT+ de temperatura ambiente, bateria de cerca de 1 ano, dá contexto climático pro cálculo de carga de treino em dias muito quentes ou frios."}
      ]},
      {"type": "texto_rico", "html": "<p>O <strong>Varia RTL515</strong> combina radar traseiro e luz: detecta veículos se aproximando por trás a até 140 metros e avisa o ciclista com alerta visual (barra de LED na tela do Edge ou relógio) e sonoro. A luz tem 5 modos (Solid, Peloton, Night Flash, Day Flash e Standby), chegando a 65 lúmens no Day Flash, visível a até 1,6km. A versão com câmera (RCT715) ainda grava o trajeto em vídeo, além do radar e da luz.</p>"},
      {"type": "banner", "tone": "info", "text": "Todos esses sensores conectam via ANT+ e/ou Bluetooth ao Edge ou ao relógio, ampliando o que o aparelho sozinho não capta."}
    ]
  }$j$
where id = 'b5bfa1c1-0e98-4cf9-9b0f-2fc1968343d8';

-- Lição nova (order_index 3): HRM 200 (cross-ref) + carregadores USB-C/USB-A
insert into lessons (module_id, title, content_type, order_index, is_published, body) values
('52a7dec7-984a-488c-bd81-cdd3eae7bf65', 'HRM 200 e carregadores: completando o kit', 'text', 3, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Nem todo cliente precisa do HRM 600. O <strong>HRM 200</strong> é a cinta de entrada do portfólio: só frequência cardíaca e HRV, sem Dinâmica de Corrida nem resistência à natação, num preço bem menor (detalhes completos no módulo HRM 200/600).</p><p>Pra carregar qualquer relógio ou cinta recarregável, o clipe magnético que encaixa no aparelho é sempre igual, mas a ponta que liga na tomada ou no computador muda: relógios 2022 em diante (praticamente toda a linha atual) usam cabo com ponta <strong>USB-C</strong>; aparelhos mais antigos usam ponta <strong>USB-A</strong> tradicional.</p>"},
    {"type": "banner", "tone": "info", "text": "Bom item de venda casada: cliente que carrega o carro ou já tem carregador USB-C em casa aproveita o mesmo cabo pro relógio."}
  ]
}$j$);

-- Lição nova (order_index 4): tamanhos de pulseira QuickFit
insert into lessons (module_id, title, content_type, order_index, is_published, body) values
('52a7dec7-984a-488c-bd81-cdd3eae7bf65', 'Pulseiras QuickFit: tamanhos e quais relógios usam', 'text', 4, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>QuickFit é o sistema que troca a pulseira em segundos, sem ferramenta nenhuma. Vem em 3 larguras, 20mm, 22mm e 26mm, definidas pelo tamanho da caixa do relógio.</p>"},
    {"type": "tabela", "headers": ["Modelo", "Tamanho da caixa", "QuickFit"], "rows": [
      ["Fenix 8", "42/43mm", "20mm"],
      ["Fenix 8", "47mm", "22mm"],
      ["Fenix 8", "51mm", "26mm"],
      ["Instinct 3", "45mm", "22mm"],
      ["Instinct 3", "50mm", "26mm"],
      ["Forerunner 970", "47mm", "22mm"]
    ]},
    {"type": "banner", "tone": "warning", "text": "Atenção: dos Forerunner do portfólio, só o 970 tem QuickFit de verdade. O 55, 165, 170 e 570 usam pino de troca rápida padrão (também sem ferramenta, mas é um sistema diferente do QuickFit, mesmo em larguras parecidas como 20 ou 22mm)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "QuickFit silicone/couro", "text": "O material padrão, disponível nas 3 larguras.", "tags": [{"label": "Padrão", "color": "blue"}]},
      {"title": "UltraFit (nylon trançado)", "text": "Alternativa esportiva, respirável, também nas mesmas 3 larguras (20/22/26mm).", "tags": [{"label": "Esportiva", "color": "green"}]}
    ]}
  ]
}$j$);

-- Lição nova (order_index 5): como identificar e escolher a pulseira certa
insert into lessons (module_id, title, content_type, order_index, is_published, body) values
('52a7dec7-984a-488c-bd81-cdd3eae7bf65', 'Como identificar e escolher a pulseira certa pro cliente', 'text', 5, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>O jeito mais rápido de confirmar o tamanho é olhar a própria pulseira: o tamanho vem gravado na parte de baixo, a que fica encostada no pulso (ex.: \"QuickFit 22\"). Sem a pulseira em mãos, o tamanho é definido pelo modelo e pela caixa do relógio, conforme a tabela da lição anterior.</p>"},
    {"type": "objecao", "items": [
      {"question": "O cliente não sabe o tamanho do relógio dele, e não trouxe a pulseira", "answer": "Pergunte o modelo e o tamanho da caixa (em mm, geralmente no nome do produto ou na caixa de venda). Com isso dá pra cruzar direto com a tabela de QuickFit por modelo."}
    ]},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Treina muito e sua bastante", "text": "Silicone ou UltraFit nylon, secam rápido e resistem ao suor.", "tags": [{"label": "Performance", "color": "green"}]},
      {"title": "Quer usar no trabalho ou em ocasião social", "text": "Couro ou material premium, visual mais discreto.", "tags": [{"label": "Estilo", "color": "gold"}]},
      {"title": "Quer trocar o visual sem trocar de relógio", "text": "O próprio sistema QuickFit já é o argumento: troca em segundos, sem ferramenta, vale ter mais de uma pulseira.", "tags": [{"label": "Venda casada", "color": "blue"}]}
    ]}
  ]
}$j$);

-- Roteiro final atualizado (era order_index 3, agora 6) com o ecossistema completo
update lessons set
  order_index = 6,
  body = $j${
    "blocks": [
      {"type": "roteiro", "steps": [
        {"tip": "Apresente o ecossistema em camadas, não tudo de uma vez: comece pelo que resolve a dor imediata do cliente.", "title": "Apresentando o ecossistema como um todo", "dialog": "O relógio sozinho já entrega muita coisa, mas o ecossistema completo é o que separa o atleta casual do sério: HRM 600 ou HRM 200 pra frequência cardíaca, sensores de cadência e velocidade pro ciclismo, tempe e Varia pra contexto e segurança, e ainda dá pra personalizar com pulseiras QuickFit diferentes pra cada ocasião."}
      ]}
    ]
  }$j$
where id = 'f5221f03-52cb-47d2-a010-eb50f3b11f0f';

-- Quiz: 6 perguntas novas
do $$
declare
  v_quiz uuid := '0b42b2d9-46be-4336-96a3-523b5edbd708';
  v_q uuid;
begin

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'O Speed Sensor 2 consegue guardar dado sozinho, sem o Edge ou relógio por perto?', 'Sim, guarda até 300 horas de dado internamente, sincronizando depois quando reconecta.', 8) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Sim, até 300 horas de dado', true, 0),
(v_q, 'Não, precisa estar sempre conectado', false, 1),
(v_q, 'Sim, mas só 10 minutos', false, 2),
(v_q, 'Não existe essa função nesse sensor', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'Até que distância o radar do Varia RTL515 detecta um veículo se aproximando?', 'Até 140 metros, mostrando o alerta na tela do Edge ou do relógio.', 9) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Até 140 metros', true, 0),
(v_q, 'Até 20 metros', false, 1),
(v_q, 'Até 1 quilômetro', false, 2),
(v_q, 'Não tem alcance definido', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'Qual a diferença entre os cabos de carregamento USB-C e USB-A da Garmin?', 'O clipe magnético que encaixa no relógio é igual; muda a ponta que liga na tomada ou no computador. Relógios 2022+ usam USB-C, modelos mais antigos usam USB-A.', 10) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'O clipe é igual, muda só a ponta que liga na tomada/computador', true, 0),
(v_q, 'São clipes completamente diferentes e incompatíveis entre si', false, 1),
(v_q, 'USB-A é mais rápido que USB-C', false, 2),
(v_q, 'Não existe cabo USB-A, só USB-C', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'Qual QuickFit usa o Fenix 8 de 47mm?', 'O Fenix 8 de 47mm usa QuickFit 22mm (o 42/43mm usa 20mm, o 51mm usa 26mm).', 11) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'QuickFit 22mm', true, 0),
(v_q, 'QuickFit 18mm', false, 1),
(v_q, 'QuickFit 26mm', false, 2),
(v_q, 'Não usa QuickFit', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'Qual Forerunner do portfólio realmente usa o sistema QuickFit?', 'Só o Forerunner 970. O 55, 165, 170 e 570 usam pino de troca rápida padrão, um sistema diferente mesmo em larguras parecidas.', 12) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Só o Forerunner 970', true, 0),
(v_q, 'Todos os Forerunner do portfólio', false, 1),
(v_q, 'Nenhum Forerunner usa QuickFit', false, 2),
(v_q, 'Só o Forerunner 55', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'Como confirmar rapidamente o tamanho de uma pulseira QuickFit que o cliente já tem?', 'O tamanho vem gravado na parte de baixo/interna da pulseira, por exemplo "QuickFit 22".', 13) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Olhando a gravação na parte de baixo/interna da pulseira', true, 0),
(v_q, 'Não tem como saber sem medir com régua', false, 1),
(v_q, 'O tamanho vem gravado na tela do relógio', false, 2),
(v_q, 'Todas as pulseiras QuickFit são do mesmo tamanho', false, 3);

end $$;

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 105
-- ============================================================================
