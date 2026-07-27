-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 106: popula o módulo "Portfólio GPSMAP e
-- Diferencial do GPS Dedicado" (Zona Aventureiro), vazio desde a criação
-- ============================================================================
-- Pedido do usuário: "tem modulo do inreach? se não tiver, pode incluir um
-- que tenha além dos modulos inreach mini 2, mini 3 e mini 3 plus, e tem
-- tambem o gpsmap h1i plus que possui a tecnologia. explica brevemente
-- algumas versões nao importadas e explica os acessórios (cordão de
-- flutuação e estojo de mergulho pra inreach)".
--
-- Não existia módulo de inReach na trilha (só entradas na Academia de
-- Produtos). Este módulo já existia como casca vazia (migração 055/087,
-- Zona Aventureiro, mesma família das outras 4 ainda vazias, ver task
-- #155) — populado agora em vez de criar um módulo novo do zero.
--
-- "GPSMAP H1i Plus" não é um produto real da Garmin (pesquisado e não
-- encontrado em nenhuma fonte oficial). O produto real mais próximo do que
-- foi descrito ("GPSMAP que possui a tecnologia [inReach]") é o
-- <strong>GPSMAP 67i</strong>: GPS de mão robusto com inReach embutido,
-- já existe no catálogo desta loja o GPSMAP 67 (sem "i", sem inReach) na
-- Academia de Produtos. Usado aqui como o produto correto; sinalizado ao
-- usuário na resposta pra confirmar ou corrigir.
--
-- Specs pesquisadas e confirmadas (garmin.com, DC Rainmaker, GPS
-- training/comparativos especializados, julho/2026):
--   Mini 3 e Mini 3 Plus somam tela colorida touch (Mini 2 é monocromática
--   pequena). Mini 3 usa Iridium SBD (só texto, igual ao Mini 2). Mini 3
--   Plus usa o novo módulo Iridium Certus (IMT), manda foto e nota de voz
--   de até 30s, mensagens até 300x maiores, antena mais potente, sirene,
--   inclui carabiner (peso 139g com ele; Mini 3 base 122g sem nada).
--   GPSMAP 67i: tela colorida de 3" visível ao sol, GNSS multibanda,
--   mapas TopoActive pré-carregados, bateria até 165h rastreamento / 425h
--   modo expedição, inReach embutido completo (SOS, mensagens 2 vias,
--   compartilhamento de localização via Iridium).
--   Acessórios reais confirmados: Floating Lanyard (cordão de flutuação,
--   neoprene) e Dive Case (estojo de mergulho, resistente à água),
--   ambos vendidos pela Garmin pra linha inReach Mini.
--   inReach Messenger e Messenger Plus são produtos reais da Garmin
--   (comunicadores sem GPS de mapa, mais simples que o Mini) que esta
--   loja NÃO importa/vende — usados aqui como "versão não trabalhada".
-- ============================================================================

begin;

insert into lessons (module_id, title, content_type, order_index, is_published, body) values
('86586e9f-d91c-4b0f-8456-995a03866394', 'inReach Mini 2, Mini 3 e Mini 3 Plus: qual é qual', 'text', 0, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Os três são comunicadores via satélite, pequenos e leves, focados em segurança fora de área de cobertura de celular: SOS interativo, mensagens de texto bidirecionais e compartilhamento de localização, tudo via rede Iridium.</p>"},
    {"type": "tabela", "headers": ["Recurso", "Mini 2", "Mini 3", "Mini 3 Plus"], "rows": [
      ["Tela", "Monocromática pequena", "Colorida, touch", "Colorida, touch"],
      ["Mensagens", "Texto (Iridium SBD)", "Texto (Iridium SBD)", "Texto, foto e nota de voz de até 30s (Iridium Certus)"],
      ["Antena e sirene", "Padrão", "Padrão", "Antena mais potente e sirene"],
      ["Peso", "Mais leve", "122g (base)", "139g, já com carabiner incluso"]
    ]},
    {"type": "banner", "tone": "info", "text": "O Mini 3 Plus é o único da família que manda foto e nota de voz, graças a um módulo de transmissão novo (Iridium Certus) que envia mensagens até 300x maiores que as gerações anteriores. O Mini 3 comum continua só com texto, igual ao Mini 2, a diferença dele pro Mini 2 é a tela colorida touch."}
  ]
}$j$),
('86586e9f-d91c-4b0f-8456-995a03866394', 'GPSMAP 67i: navegação robusta com inReach embutido', 'text', 1, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>GPSMAP 67i</strong> soma tudo que o inReach oferece (SOS interativo, mensagens bidirecionais, compartilhamento de localização via satélite) com um GPS de mão completo: tela colorida de 3\" visível ao sol, GNSS multibanda, mapas TopoActive pré-carregados, e bateria de até 165h em modo rastreamento ou até 425h em modo expedição.</p>"},
    {"type": "objecao", "items": [
      {"question": "Por que pagar mais no 67i se o Mini já tem SOS?", "answer": "O Mini é um comunicador primeiro, com mapa mínimo. O 67i soma um GPS de navegação completo (mapas detalhados, rotas, waypoints) que o Mini não tem sozinho, ideal pra quem realmente navega no mato sem depender do celular como mapa principal."}
    ]},
    {"type": "banner", "tone": "info", "text": "Já existe o GPSMAP 67 (sem inReach) no catálogo, o 67i é a versão com o comunicador via satélite embutido."}
  ]
}$j$),
('86586e9f-d91c-4b0f-8456-995a03866394', 'Por que um GPS dedicado vale mais que o celular', 'text', 2, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Um celular com aplicativo de mapa parece resolver, até faltar sinal ou bateria. Três diferenças concretas justificam o GPS dedicado:</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Bateria", "text": "Um GPS dedicado dura dias ou semanas; um celular com GPS ligado costuma não passar de um dia.", "tags": [{"label": "Autonomia", "color": "green"}]},
      {"title": "Clima extremo", "text": "Bateria de celular perde performance rápido em frio intenso; GPS dedicado é feito pra aguentar essas condições.", "tags": [{"label": "Resistência", "color": "blue"}]},
      {"title": "Cobertura", "text": "Comunicação via satélite (Iridium) funciona onde não existe sinal de celular nenhum.", "tags": [{"label": "Segurança", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "warning", "text": "Argumento chave pra objeção de preço: em emergência real, o celular sem sinal é só um peso morto na mochila. O inReach sempre tem cobertura via satélite, em qualquer lugar do planeta."}
  ]
}$j$),
('86586e9f-d91c-4b0f-8456-995a03866394', 'Acessórios inReach: cordão de flutuação e estojo de mergulho', 'text', 3, true, $j${
  "blocks": [
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Cordão de Flutuação (Floating Lanyard)", "text": "Cordão de neoprene que mantém o inReach flutuando e por perto durante atividades aquáticas, evita perder o aparelho na água.", "tags": [{"label": "Náutica", "color": "blue"}]},
      {"title": "Estojo de Mergulho (Dive Case)", "text": "Estojo resistente à água feito pra proteger o inReach Mini durante mergulhos.", "tags": [{"label": "Mergulho", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "info", "text": "Bons itens de venda casada pra cliente que já mencionou vela, pesca, stand-up paddle ou mergulho na conversa."}
  ]
}$j$),
('86586e9f-d91c-4b0f-8456-995a03866394', 'Versões que não trabalhamos', 'text', 4, true, $j${
  "blocks": [
    {"type": "banner", "tone": "warning", "text": "A Garmin também vende globalmente o inReach Messenger e o inReach Messenger Plus: comunicadores via satélite sem GPS de mapa, mais simples que o Mini. Esta loja não trabalha com essas versões, o portfólio aqui é só inReach Mini 2, Mini 3, Mini 3 Plus e GPSMAP 67i. Se o cliente perguntar por elas, explique que não fazem parte do catálogo atual."}
  ]
}$j$);

do $$
declare
  v_quiz uuid := '0e86bed3-67c6-467d-a47a-45d7e9734016';
  v_q uuid;
begin

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'Qual a principal diferença de tela entre o inReach Mini 2 e os Mini 3/Mini 3 Plus?', 'O Mini 2 tem tela monocromática pequena; o Mini 3 e o Mini 3 Plus têm tela colorida touch.', 0) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Mini 2 é monocromática pequena; Mini 3 e Mini 3 Plus são coloridas touch', true, 0),
(v_q, 'Não existe diferença de tela entre os três', false, 1),
(v_q, 'Só o Mini 3 Plus tem tela, os outros dois não têm', false, 2),
(v_q, 'Mini 2 é colorida e os Mini 3 são monocromáticos', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'O que só o inReach Mini 3 Plus consegue enviar, entre os três modelos?', 'Só o Mini 3 Plus manda foto e nota de voz de até 30s, graças ao módulo Iridium Certus. O Mini 3 comum continua só com texto, igual ao Mini 2.', 1) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Foto e nota de voz de até 30 segundos', true, 0),
(v_q, 'Mensagem de texto', false, 1),
(v_q, 'Localização em tempo real', false, 2),
(v_q, 'SOS interativo', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'O que o GPSMAP 67i tem que o inReach Mini não tem sozinho?', 'O 67i soma um GPS de navegação completo (mapas TopoActive, rotas, waypoints) ao comunicador inReach embutido.', 2) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'GPS de navegação completo, com mapas detalhados e rotas', true, 0),
(v_q, 'SOS interativo via satélite', false, 1),
(v_q, 'Mensagens de texto bidirecionais', false, 2),
(v_q, 'Compartilhamento de localização', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'Qual a bateria do GPSMAP 67i em modo expedição?', 'Até 425 horas em modo expedição (165h em modo rastreamento).', 3) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Até 425 horas', true, 0),
(v_q, 'Até 24 horas', false, 1),
(v_q, 'Até 50 horas', false, 2),
(v_q, 'Até 1000 horas', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'Por que um GPS dedicado costuma valer mais que só usar o celular em uma trilha?', 'Bateria de GPS dedicado dura dias/semanas, aguenta clima extremo melhor, e a comunicação via satélite funciona onde não tem sinal de celular nenhum.', 4) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Bateria mais duradoura, resistência a clima extremo e cobertura via satélite sem depender de sinal de celular', true, 0),
(v_q, 'O celular não tem GPS embutido', false, 1),
(v_q, 'Não há diferença real, é só uma questão de preferência', false, 2),
(v_q, 'O GPS dedicado é mais barato que qualquer celular', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'Pra que serve o Cordão de Flutuação (Floating Lanyard) do inReach?', 'Mantém o inReach flutuando e por perto durante atividades aquáticas, evitando que o cliente perca o aparelho na água.', 5) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Mantém o inReach flutuando e por perto na água', true, 0),
(v_q, 'Carrega a bateria do inReach', false, 1),
(v_q, 'Aumenta o alcance do sinal de satélite', false, 2),
(v_q, 'Serve só como suporte de mesa', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'O que o Estojo de Mergulho (Dive Case) faz pro inReach Mini?', 'É um estojo resistente à água feito pra proteger o inReach Mini durante mergulhos.', 6) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Protege o inReach Mini durante mergulhos, resistente à água', true, 0),
(v_q, 'Permite enviar mensagens debaixo d''água', false, 1),
(v_q, 'Substitui a bateria original do aparelho', false, 2),
(v_q, 'Serve só pra guardar o cabo de carregamento', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'A loja trabalha com o inReach Messenger e o Messenger Plus?', 'Não. São produtos reais da Garmin, mas esta loja não importa essas versões, o portfólio é só Mini 2, Mini 3, Mini 3 Plus e GPSMAP 67i.', 7) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Não, não fazem parte do portfólio desta loja', true, 0),
(v_q, 'Sim, são os modelos mais vendidos aqui', false, 1),
(v_q, 'Sim, mas só sob encomenda especial', false, 2),
(v_q, 'Esses produtos não existem na Garmin', false, 3);

end $$;

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 106
-- ============================================================================
