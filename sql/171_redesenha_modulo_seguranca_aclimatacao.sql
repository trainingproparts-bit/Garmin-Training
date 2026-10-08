-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 171: redesign do módulo Segurança, Aclimatação e Nutrição em Longas Distâncias
-- ============================================================================
-- Pedido do usuário (2026-10-07): reescrever o módulo seguindo o briefing
-- em 4 blocos (performance e ambiente, temperatura, segurança e
-- rastreamento, recursos da rotina) + desafio final e encerramento,
-- na sequência Entender > Reconhecer > Interpretar > Explicar > Aplicar.
-- São 17 lições: 16 do briefing + a 17 com desafio final e encerramento.
--
-- Preservação de progresso: os 4 lessons existentes são reaproveitados
-- (mesmo id):
--   c94e592d Aclimatação de calor e altitude   -> lição 1
--   9677fc60 LiveTrack, Detecção e Assistência -> lição 9
--   d1ef8a9b Hidratação e nutrição             -> lição 14 (recursos da rotina)
--   11199ce6 Aplicando isso em provas longas   -> lição 17 (desafio final)
-- O briefing não inclui nutrição/hidratação, então esse conteúdo sai do
-- módulo; o título do módulo NÃO foi alterado aqui (ele também aparece nos
-- critérios da certificação Maratonista, sql/055).
-- As outras 13 lições entram com id fixo (insert ... on conflict (id) do
-- update), então rodar de novo só atualiza. O checkpoint do módulo no GPS
-- da Carreira fica em user_progress e não é recalculado.
--
-- Regras do briefing: sem emoji, sem travessão, sem frases no formato
-- "não é X, é Y", recursos de segurança sempre como complementares e
-- dependentes de dispositivo compatível e conectividade, sem garantia de
-- socorro, prevenção de acidente ou diagnóstico. Os números de aclimatação
-- (4 dias, 10 a 14 dias, 3 dias, 800 m a 4.000 m, cerca de 21 dias) vêm do
-- próprio briefing.
-- ============================================================================

do $$
declare
  v_mod uuid := '4e4ec6a8-0279-42bf-8114-85c6bd29d336';
begin

update modules
   set summary = 'Aclimatação ao calor e à altitude, leitura correta da temperatura, recursos complementares de segurança e recursos que facilitam a rotina, sempre partindo da necessidade do cliente.'
 where id = v_mod;

insert into lessons (id, module_id, title, content_type, order_index, is_published, body) values

-- ============================================================================
-- BLOCO 1: PERFORMANCE E CONDIÇÕES AMBIENTAIS
-- ============================================================================

-- LIÇÃO 1
('c94e592d-45dd-482b-8f87-181d63d7d5e2', v_mod, 'Quando o ambiente muda o treino', 'text', 0, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Quando o ambiente muda o treino</h3><p>Revele cada etapa para entender por que o ambiente entra na conversa de venda.</p>"},
  {"type": "timeline", "reveal": true, "items": [
    {"label": "O ambiente faz parte do treino", "text": "Calor e altitude aumentam a exigência cardiovascular na atividade."},
    {"label": "O impacto no atleta", "text": "Condições difíceis podem gerar ritmo mais lento ou maior esforço, sem significar perda de condicionamento."},
    {"label": "A solução Garmin", "text": "Em condições compatíveis, os recursos de aclimatação contextualizam os dados de performance considerando o ambiente."},
    {"label": "Foco na venda", "text": "O valor está em ajudar o atleta a interpretar o desempenho dentro do contexto em que o treino aconteceu."}
  ]}
]}
$j$::jsonb),

-- LIÇÃO 2
('dec40b2f-e2e6-445d-a404-5d5c6f993853', v_mod, 'Aclimatação ao calor', 'text', 1, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Aclimatação ao calor</h3><p>Vire o card para ver como o recurso funciona e para quem ele faz mais sentido.</p>"},
  {"type": "flip_card", "columns": 1, "tall": true, "cards": [
    {
      "title": "Aclimatação ao Calor",
      "frontText": "Em ambientes mais quentes, o corpo enfrenta uma exigência maior durante o exercício.",
      "backLabel": "Como funciona",
      "backText": "<p>A Garmin utiliza informações ambientais para contextualizar métricas de performance.</p><p>O processo exige pelo menos 4 dias de treinos qualificados em ambiente quente, atingindo o nível ideal entre 10 e 14 dias. A adaptação diminui após 3 dias sem exposição ao calor.</p>",
      "practicalTip": "<p>Relevante para quem treina em regiões quentes, viaja para provas ou treina em horários de calor intenso.</p>",
      "salesTip": "<p>“Se você costuma treinar em condições de calor diferentes das habituais, a Garmin ajuda a colocar seu desempenho em contexto.”</p>"
    }
  ]}
]}
$j$::jsonb),

-- LIÇÃO 3
('b69bacc3-3e1f-4887-8836-56fc6d45114b', v_mod, 'Aclimatação à altitude', 'text', 2, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Aclimatação à altitude</h3><p>Vire o card para ver como o recurso funciona e para quem ele faz mais sentido.</p>"},
  {"type": "flip_card", "columns": 1, "tall": true, "cards": [
    {
      "title": "Aclimatação à Altitude",
      "frontText": "Treinar em regiões elevadas muda a forma como o corpo responde ao esforço.",
      "backLabel": "Como funciona",
      "backText": "<p>A altitude altera a disponibilidade de oxigênio e aumenta a exigência do organismo.</p><p>O processo considera altitudes entre 800 m e 4.000 m, com adaptação progressiva ao longo de cerca de 21 dias, diminuindo gradualmente ao retornar ao nível do mar.</p>",
      "practicalTip": "<p>Ideal para clientes que treinam em montanhas, viajam para altitude ou praticam trekking outdoor.</p>"
    }
  ]}
]}
$j$::jsonb),

-- LIÇÃO 4
('e3bce2d4-b8f2-4755-b17b-1f0bc1a4f403', v_mod, 'Calor x Altitude', 'text', 3, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Calor x Altitude</h3><p>Dois ambientes, duas exigências diferentes. Compare antes de indicar.</p>"},
  {"type": "tabs", "items": [
    {"label": "Calor", "title": "Treina em regiões quentes", "text": "<p>O ambiente aumenta a exigência do esforço.</p>"},
    {"label": "Altitude", "title": "Treina ou viaja para regiões elevadas", "text": "<p>A disponibilidade de oxigênio muda.</p>"},
    {"label": "O que investigar", "title": "Comece pelo local de treino", "text": "<p>Descubra onde o cliente treina antes de apresentar qualquer função.</p>"}
  ]}
]}
$j$::jsonb),

-- LIÇÃO 5
('92713733-063c-4f3a-b3c3-2af4d62e3c8c', v_mod, 'Argumento rápido de venda', 'text', 4, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Argumento rápido de venda</h3><p>Revele a conversa passo a passo.</p>"},
  {"type": "timeline", "reveal": true, "items": [
    {"label": "Cliente", "text": "“Eu treino em lugares diferentes e sinto muita diferença quando viajo.”"},
    {"label": "Vendedor", "text": "“Você costuma treinar mais em regiões quentes ou também em altitude?”"},
    {"label": "Conexão", "text": "Se houver mudança relevante de ambiente, apresente os recursos de aclimatação disponíveis no modelo."}
  ]},
  {"type": "banner", "tone": "success", "text": "<strong>Elevator pitch:</strong> “Se você treina para provas em outras cidades, no calor ou em altitude, a Garmin ajuda a contextualizar suas métricas para que uma mudança de ambiente seja compreendida dentro do cenário real do treino.”"}
]}
$j$::jsonb),

-- ============================================================================
-- BLOCO 2: TEMPERATURA E INTERPRETAÇÃO DOS DADOS
-- ============================================================================

-- LIÇÃO 6
('5d48380e-545d-4fbf-96ab-999104d32812', v_mod, 'Por que o relógio pode marcar uma temperatura diferente?', 'text', 5, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Por que o relógio pode marcar uma temperatura diferente?</h3>"},
  {"type": "banner", "tone": "info", "text": "<strong>A objeção:</strong> “Comprei o relógio, mas a temperatura do treino está muito mais alta do que o clima real.”"},
  {"type": "accordion", "items": [
    {"title": "Sensor interno", "html": "<p>O relógio possui sensor físico de temperatura. No pulso, a leitura sofre influência do calor corporal e de roupas.</p>"},
    {"title": "Temperatura ambiente", "html": "<p>Para dados de clima e aclimatação, o sistema utiliza dados meteorológicos recebidos pelo smartphone conectado.</p>"},
    {"title": "Explicação", "html": "<p>O sensor interno do dispositivo e os dados meteorológicos do ecossistema Garmin são fontes de informação distintas.</p>"},
    {"title": "Leitura precisa", "html": "<p>Para medir a temperatura ambiente pelo sensor físico, retire o relógio do pulso por alguns minutos ou utilize um sensor externo compatível.</p>"}
  ]}
]}
$j$::jsonb),

-- LIÇÃO 7
('2d96c023-770f-40b3-a278-e91240ba4512', v_mod, 'Sensor do relógio x clima do smartphone', 'text', 6, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Sensor do relógio x clima do smartphone</h3><p>Cada informação de temperatura tem uma origem. Compare as três.</p>"},
  {"type": "tabs", "items": [
    {"label": "Sensor interno", "title": "Sensor interno", "text": "<p>Mede a temperatura no dispositivo, sofrendo influência do calor do corpo no pulso.</p>"},
    {"label": "Dados meteorológicos", "title": "Dados meteorológicos", "text": "<p>As informações de clima vêm de serviços meteorológicos transmitidos pelo smartphone conectado.</p>"},
    {"label": "Aclimatação", "title": "Aclimatação", "text": "<p>Utiliza dados ambientais para contextualizar as métricas de treino.</p>"}
  ]},
  {"type": "banner", "tone": "info", "text": "<strong>Regra de venda:</strong> trate a temperatura medida pelo sensor do relógio e a temperatura meteorológica do ecossistema como dados de fontes diferentes."}
]}
$j$::jsonb),

-- LIÇÃO 8
('8735817b-5a1f-471a-93cd-2e07b7e46bcc', v_mod, 'Desafio de objeção', 'text', 7, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Desafio de objeção</h3><p>Escolha a resposta que explica a diferença com segurança.</p>"},
  {"type": "cenario_escolha",
   "context": "Cliente: “Meu relógio mostra 31 °C e o aplicativo de clima mostra 25 °C.”",
   "prompt": "Qual é a melhor resposta?",
   "options": [
     {"text": "O sensor do relógio está errado.", "correct": false, "feedback": "O sensor está funcionando: ele mede a temperatura no pulso, onde o calor do corpo interfere. Explicar a origem de cada dado mantém a confiança do cliente no produto."},
     {"text": "A Garmin sempre usa o sensor interno para medir a temperatura.", "correct": false, "feedback": "Os dados de clima e de aclimatação vêm das informações meteorológicas recebidas pelo smartphone conectado. O sensor interno é uma segunda fonte, separada."},
     {"text": "O sensor do relógio sofre influência da temperatura do corpo no pulso. As informações meteorológicas dos recursos vêm de dados recebidos pelo smartphone.", "correct": true, "feedback": "Explique que o relógio e o aplicativo utilizam fontes de informação distintas e que o calor corporal interfere na medição do sensor do pulso."}
   ]}
]}
$j$::jsonb),

-- ============================================================================
-- BLOCO 3: SEGURANÇA E RASTREAMENTO
-- ============================================================================

-- LIÇÃO 9
('9677fc60-1d2b-42bf-976b-d6bbb2c7271b', v_mod, 'Quando segurança também faz parte da venda', 'text', 8, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Quando segurança também faz parte da venda</h3><p>Revele a conversa passo a passo.</p>"},
  {"type": "timeline", "reveal": true, "items": [
    {"label": "O cliente diz", "text": "“Eu gosto de correr sozinho, mas minha família fica preocupada.”"},
    {"label": "A pergunta do vendedor", "text": "O que pode agregar valor nesse caso?"},
    {"label": "LiveTrack", "text": "Contatos selecionados acompanham a atividade em tempo real, em dispositivos compatíveis."},
    {"label": "Detecção de Incidentes", "text": "Em atividades compatíveis, o dispositivo pode iniciar um alerta para os contatos de emergência cadastrados."},
    {"label": "Assistência", "text": "O próprio atleta aciona manualmente um pedido de ajuda quando necessário."}
  ]},
  {"type": "banner", "tone": "info", "text": "Recursos de segurança Garmin aumentam a tranquilidade de quem treina e de quem acompanha o atleta."}
]}
$j$::jsonb),

-- LIÇÃO 10
('c0b077ce-8f57-4635-bc35-0a120fa676fd', v_mod, 'LiveTrack e Mostrar Percurso', 'text', 9, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>LiveTrack e Mostrar Percurso</h3><p>Vire cada card para ver o que o recurso entrega.</p>"},
  {"type": "flip_card", "columns": 2, "tall": true, "cards": [
    {
      "title": "LiveTrack",
      "frontText": "Quem está em casa acompanha o treino em tempo real.",
      "backLabel": "Como funciona",
      "backText": "<p>Compartilha a localização e dados da atividade em tempo real com contatos selecionados, em dispositivos compatíveis.</p>",
      "salesTip": "<p>Pergunte ao cliente: “Quem você gostaria que pudesse acompanhar seu treino?”</p>"
    },
    {
      "title": "Mostrar Percurso",
      "frontText": "Quem acompanha vê para onde o atleta está indo.",
      "backLabel": "Como funciona",
      "backText": "<p>Permite aos seguidores visualizarem o percurso planejado junto ao trajeto já realizado, em modelos compatíveis.</p>"
    }
  ]}
]}
$j$::jsonb),

-- LIÇÃO 11
('3ec932bc-00c9-4fa7-b848-f463b9d1ea15', v_mod, 'Detecção de Incidentes e Assistência', 'text', 10, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Detecção de Incidentes e Assistência</h3><p>Abra cada item para entender o funcionamento.</p>"},
  {"type": "accordion", "items": [
    {"title": "Detecção de Incidentes", "html": "<p>Em atividades compatíveis, o dispositivo identifica impactos ou eventos e inicia um alerta para os contatos de emergência cadastrados.</p>"},
    {"title": "Assistência", "html": "<p>Permite acionar manualmente um pedido de ajuda quando necessário.</p>"},
    {"title": "Contagem regressiva", "html": "<p>Exibe uma contagem que permite cancelar o envio em caso de acionamento acidental.</p>"}
  ]},
  {"type": "banner", "tone": "warning", "text": "Os dois recursos dependem de dispositivo compatível, configuração, contatos de emergência cadastrados e conectividade."}
]}
$j$::jsonb),

-- LIÇÃO 12
('87eb9af7-50c7-4851-981f-78a81fc01432', v_mod, 'A informação que o vendedor não pode esquecer', 'text', 11, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>A informação que o vendedor não pode esquecer</h3><p>Marque cada requisito que você já explica ao apresentar os recursos de segurança.</p>"},
  {"type": "checklist", "items": [
    "Recursos complementares de segurança.",
    "Não substituem os serviços públicos de emergência.",
    "Disponibilidade depende do dispositivo, atividade, configuração e conectividade.",
    "Recursos dependentes de smartphone exigem conexão ativa e sinal de rede.",
    "Exigem cadastro prévio dos contatos de emergência."
  ], "reflection": "Esses cinco pontos acompanham toda apresentação de recursos de segurança."},
  {"type": "banner", "tone": "warning", "text": "<strong>Frase obrigatória:</strong> “É um recurso de segurança complementar. Ele não substitui os serviços públicos de emergência.”"}
]}
$j$::jsonb),

-- LIÇÃO 13
('f670602f-57e9-4123-823a-4d19c7dfc275', v_mod, 'Quem tem mais potencial para esses recursos?', 'text', 12, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Quem tem mais potencial para esses recursos?</h3><p>Ligue cada perfil de cliente ao recurso que mais conversa com ele.</p>"},
  {"type": "match_quiz", "pairs": [
    {"term": "Corredor solo", "definition": "LiveTrack"},
    {"term": "Ciclista em treino solo", "definition": "LiveTrack + Detecção de Incidentes"},
    {"term": "Cliente focado na família", "definition": "Recursos de segurança"},
    {"term": "Aventureiro / Outdoor", "definition": "Rastreamento e recursos de segurança compatíveis"},
    {"term": "Viajante para regiões remotas", "definition": "Recursos de conectividade do modelo"}
  ]}
]}
$j$::jsonb),

-- ============================================================================
-- BLOCO 4: RECURSOS QUE FACILITAM A ROTINA
-- ============================================================================

-- LIÇÃO 14
('d1ef8a9b-143f-48a1-8761-b9a7c57ccc9d', v_mod, 'Pequenos recursos, grande utilidade', 'text', 13, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Pequenos recursos, grande utilidade</h3><p>Cada recurso começa com uma pergunta ao cliente. Veja as três.</p>"},
  {"type": "tabs", "items": [
    {"label": "Encontrar Meu Telefone", "title": "Encontrar Meu Telefone", "text": "<p>Faz o smartphone emitir um sinal sonoro acionado pelo relógio, dentro do alcance da conexão.</p>", "note": "Pergunta: “Você costuma perder o celular pela casa ou no trabalho?”"},
    {"label": "Morning Report", "title": "Morning Report", "text": "<p>Exibe um resumo personalizado ao acordar, com dados de sono, recuperação, treino e clima.</p>", "note": "Pergunta: “Você gosta de começar o dia sabendo como foi sua noite e os compromissos à frente?”"},
    {"label": "Gear Tracking", "title": "Gear Tracking", "text": "<p>Monitora o uso e a quilometragem acumulada de tênis e bicicletas no Garmin Connect.</p>", "note": "Pergunta: “Você costuma controlar a hora de trocar o tênis ou fazer manutenção na bike?”"}
  ]}
]}
$j$::jsonb),

-- LIÇÃO 15
('32e01c8b-ce48-4eb5-9d66-476b8f65177c', v_mod, 'Qual recurso resolve esse problema?', 'text', 14, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Qual recurso resolve esse problema?</h3><p>Ligue cada recurso à fala de cliente que ele resolve.</p>"},
  {"type": "match_quiz", "pairs": [
    {"term": "Encontrar Meu Telefone", "definition": "“Perdi meu celular dentro de casa.”"},
    {"term": "Morning Report", "definition": "“Quero saber como dormi assim que acordo.”"},
    {"term": "Gear Tracking", "definition": "“Quero acompanhar quanto já usei meu tênis.”"},
    {"term": "LiveTrack", "definition": "“Minha família quer acompanhar meus treinos.”"},
    {"term": "Detecção de Incidentes / Assistência", "definition": "“Treino sozinho e quero recursos adicionais de segurança.”"},
    {"term": "Aclimatação", "definition": "“Viajo para lugares quentes ou com altitude.”"}
  ]}
]}
$j$::jsonb),

-- LIÇÃO 16
('823a45cd-674a-4d1f-9318-7d3cf5c22871', v_mod, 'Checklist de atendimento', 'text', 15, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Checklist de atendimento</h3><p>Marque o que você já faz no balcão.</p>"},
  {"type": "checklist", "items": [
    "Perguntei onde o cliente treina e se há variação de calor ou altitude.",
    "Investiguei se o cliente treina sozinho ou se a família busca tranquilidade.",
    "Apresentei os recursos de segurança explicando os requisitos de conectividade.",
    "Reforcei que os recursos de segurança são complementares às emergências públicas.",
    "Sei diferenciar o sensor interno de temperatura dos dados meteorológicos.",
    "Identifiquei oportunidades para Encontrar Meu Telefone, Morning Report e Gear Tracking.",
    "Apresentei os recursos conectando necessidades a soluções reais."
  ], "reflection": "Com esses passos, cada recurso entra na conversa no momento em que faz sentido para o cliente."}
]}
$j$::jsonb),

-- ============================================================================
-- DESAFIO FINAL E ENCERRAMENTO
-- ============================================================================

-- LIÇÃO 17
('11199ce6-1e4a-4e4f-87be-d0d3abaad77b', v_mod, 'Desafio final', 'text', 16, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Desafio final</h3><p>Leia a fala do cliente e escolha a combinação de recursos mais alinhada.</p>"},
  {"type": "cenario_escolha",
   "context": "Cliente: “Corro três vezes por semana sozinho, treino cedo nos fins de semana e viajo para provas. Minha esposa fica preocupada e quero controlar melhor minha recuperação.”",
   "prompt": "Qual combinação você apresenta?",
   "options": [
     {"text": "Encontrar Meu Telefone + Gear Tracking", "correct": false, "feedback": "São recursos úteis para a rotina. As necessidades que o cliente trouxe pedem segurança, contexto de viagem e recuperação."},
     {"text": "LiveTrack + recursos de segurança + recursos de recuperação e contexto de treino", "correct": true, "feedback": "O cliente busca segurança ao treinar sozinho, contexto para treinos em viagens e controle de recuperação. O vendedor deve priorizar os recursos diretamente alinhados a essas necessidades."},
     {"text": "Morning Report + Encontrar Meu Telefone", "correct": false, "feedback": "O Morning Report ajuda com a recuperação, mas a preocupação da família com o treino solo fica sem resposta."},
     {"text": "Mostrar todas as funções do relógio", "correct": false, "feedback": "Uma demonstração focada nas três necessidades do cliente gera mais valor do que uma lista completa de funções."}
   ]},
  {"type": "texto_rico", "html": "<h3>Encerramento</h3><p>Alinhe a necessidade do cliente ao recurso correspondente para demonstrar valor.</p>"},
  {"type": "card_grid", "columns": 2, "items": [
    {"title": "Ambiente", "text": "Aclimatação."},
    {"title": "Segurança", "text": "LiveTrack e Assistência."},
    {"title": "Temperatura", "text": "Leitura correta dos dados."},
    {"title": "Rotina", "text": "Recursos de facilidade diária."}
  ]},
  {"type": "banner", "tone": "success", "text": "<strong>Conhecer os recursos é importante. Saber quando apresentá-los é o que transforma conhecimento de produto em atendimento consultivo.</strong>"}
]}
$j$::jsonb)

on conflict (id) do update
   set title        = excluded.title,
       order_index  = excluded.order_index,
       is_published = excluded.is_published,
       body         = excluded.body;

end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 171
-- ============================================================================
