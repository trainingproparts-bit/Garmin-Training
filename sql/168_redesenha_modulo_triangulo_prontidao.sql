-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 168: redesign do módulo O Triângulo da Prontidão
-- ============================================================================
-- Pedido do usuário (2026-10-07): redesenhar por completo o módulo de
-- Prontidão de Treino e Carga de Treino, na sequência pedagógica
-- ENTENDER > DIFERENCIAR > INTERPRETAR > EXPLICAR > APLICAR NA VENDA,
-- em 18 lições (o encerramento entra no fim da lição 18).
--
-- Preservação de progresso: os 4 lessons que já existiam são reaproveitados
-- (mesmo id, só título/ordem/body mudam), cada um na lição nova de mesmo
-- assunto:
--   f7c70616 O que é Prontidão de Treino   -> lição 1
--   e875fd20 Os rótulos oficiais do score  -> lição 3
--   0ccee087 Carga de Treino e Foco        -> lição 6
--   bddfaccb Quais relógios suportam       -> lição 15
-- As outras 14 lições entram com id fixo, então rodar de novo só atualiza
-- (insert ... on conflict (id) do update). O checkpoint do módulo no GPS da
-- Carreira fica em user_progress e não é recalculado: quem já concluiu o
-- módulo continua com ele concluído e com o quiz liberado.
--
-- Usa só blocos que já existem em ContentBlocks.js. O flip_card ganhou os
-- campos opcionais `image` (imagem inteira acima do título) e `practicalTip`
-- (destaque "Na prática" no verso). A imagem que já estava na lição 1 foi
-- mantida como imagem do flip card dessa lição; os outros flip cards ficam
-- sem imagem até os screenshots do Garmin Connect serem enviados pelo editor.
--
-- Regras de conteúdo do briefing: sem emoji, sem travessão, sem afirmação
-- médica, sem lista fixa de modelos compatíveis (a antiga citava Forerunner
-- 55, que não tem o recurso), sem EPOC como garantia de supercompensação, e
-- os rótulos oficiais Prime/High/Moderate/Low/Poor mantidos como estavam.
-- ============================================================================

do $$
declare
  v_mod uuid := '6430619b-7653-4926-a92c-3586804b2cc4';
begin

update modules
   set summary = 'Como ler Prontidão de Treino, Carga de Treino, Tempo de Recuperação, EPOC e VO2 Máx, e transformar essas métricas em uma conversa de venda sem tratar o relógio como diagnóstico.'
 where id = v_mod;

insert into lessons (id, module_id, title, content_type, order_index, is_published, body) values

-- ----------------------------------------------------------------------------
-- LIÇÃO 1: O que é Prontidão de Treino?
-- ----------------------------------------------------------------------------
('f7c70616-8129-450c-bf23-867f007c3cf5', v_mod, 'O que é Prontidão de Treino?', 'text', 0, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Prontidão de Treino</h3><p><strong>Uma visão mais completa de como você está preparado para o treino.</strong></p><p>A Prontidão de Treino ajuda a contextualizar o quanto você está preparado para realizar um treino naquele momento.</p><p>Em vez de olhar apenas para o treino anterior, ela considera diferentes informações relacionadas ao sono, recuperação, carga recente, VFC e estresse.</p><p>O resultado é apresentado como uma pontuação acompanhada de uma classificação.</p>"},
  {"type": "banner", "tone": "info", "text": "<strong>O ponto mais importante para o vendedor:</strong> a Prontidão de Treino não responde apenas “quanto você treinou”. Ela ajuda a responder: “Como está minha preparação para treinar hoje?”"},
  {"type": "flip_card", "columns": 1, "cards": [
    {
      "title": "Prontidão de Treino",
      "subtitle": "Uma visão do seu estado atual",
      "frontText": "Toque para entender.",
      "image": "https://i.ibb.co/6RMR1t6S/Chat-GPT-Image-11-de-set-de-2026-11-48-40.png",
      "backLabel": "Prontidão de Treino",
      "backText": "<p>A Prontidão de Treino reúne diferentes informações relacionadas à recuperação e ao treinamento para ajudar a contextualizar sua preparação para o esforço.</p>",
      "practicalTip": "<p>Uma boa pontuação pode indicar um momento mais favorável para um treino exigente.</p><p>Uma pontuação mais baixa pode indicar que vale considerar recuperação ou menor intensidade.</p>"
    }
  ]},
  {"type": "banner", "tone": "warning", "text": "<strong>Importante:</strong> a métrica é uma orientação baseada nos dados disponíveis. Ela não determina sozinha se uma pessoa deve ou não treinar."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 2: O que entra na Prontidão?
-- ----------------------------------------------------------------------------
('a3c000ab-2a72-47fd-ac10-17220c7ecd1b', v_mod, 'De onde vem essa pontuação?', 'text', 1, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>De onde vem essa pontuação?</h3><p>A Prontidão de Treino não depende de uma única informação.</p><p>Ela reúne diferentes sinais para formar uma visão mais ampla.</p>"},
  {"type": "accordion", "items": [
    {"title": "Pontuação do Sono", "html": "<p>A qualidade e a quantidade do sono recente ajudam a contextualizar a recuperação do organismo.</p>"},
    {"title": "Tempo de Recuperação", "html": "<p>Indica a estimativa de tempo restante antes de outro esforço intenso, considerando o treino realizado e os dados disponíveis.</p>"},
    {"title": "Carga de Treino", "html": "<p>Ajuda a entender o impacto dos treinos recentes e como o volume de atividade vem se comportando.</p>"},
    {"title": "Estado da VFC", "html": "<p>Acompanha a VFC em relação à linha de base pessoal, quando o dispositivo oferece esse recurso.</p>"},
    {"title": "Histórico de Sono", "html": "<p>Não considera apenas uma noite isolada.</p><p>O histórico recente ajuda a contextualizar a recuperação ao longo dos dias.</p>"},
    {"title": "Histórico de Estresse", "html": "<p>Considera informações relacionadas ao estresse registrado durante os períodos de vigília.</p>"}
  ]},
  {"type": "banner", "tone": "info", "text": "É justamente a combinação dessas informações que torna a Prontidão mais útil do que olhar apenas para uma métrica isolada."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 3: Como ler o score
-- ----------------------------------------------------------------------------
('e875fd20-33c6-49ef-9b28-fdae1182a0f3', v_mod, 'O número conta uma história', 'text', 2, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>O número conta uma história</h3><p>A pontuação da Prontidão de Treino é acompanhada por uma classificação.</p><p>Não ensine o cliente apenas a olhar para o número. O vendedor deve explicar o contexto.</p>"},
  {"type": "tabela", "headers": ["Faixa", "Rótulo", "Mensagem"], "rows": [
    ["95-100", "Prime", "Melhor condição possível"],
    ["75-94", "High", "Pronto para desafios"],
    ["50-74", "Moderate", "Tudo certo para treinar"],
    ["25-49", "Low", "Hora de reduzir o ritmo"],
    ["1-24", "Poor", "Deixe o corpo se recuperar"]
  ]},
  {"type": "flip_card", "columns": 2, "compact": true, "cards": [
    {"title": "O que o número mostra", "frontText": "Uma pontuação e uma classificação.", "backLabel": "O número", "backText": "Um resumo da preparação naquele momento, a partir dos dados disponíveis."},
    {"title": "O que o vendedor explica", "frontText": "O contexto por trás da pontuação.", "backLabel": "O contexto", "backText": "Quais fatores contribuíram para aquele resultado: sono, recuperação, carga, VFC e estresse."}
  ]},
  {"type": "banner", "tone": "info", "text": "<strong>O valor do score não está apenas no número.</strong> Está na interpretação em conjunto com os fatores que contribuíram para aquele resultado."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 4: A Prontidão muda durante o dia
-- ----------------------------------------------------------------------------
('6d5b08f3-f0a7-480a-a158-7aea269ef8fd', v_mod, 'Por que minha Prontidão mudou?', 'text', 3, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Por que minha Prontidão mudou?</h3><p>A Prontidão de Treino não precisa permanecer igual durante todo o dia.</p>"},
  {"type": "timeline", "reveal": true, "items": [
    {"label": "Ao acordar", "text": "Os dados do sono e outras informações disponíveis durante a noite ajudam a formar a avaliação inicial. Esse contexto pode aparecer no Relatório Matinal."},
    {"label": "Ao longo do dia", "text": "A pontuação pode mudar conforme novos dados são registrados e conforme o tempo de recuperação evolui."},
    {"label": "Após um treino", "text": "Uma atividade mais exigente pode alterar a avaliação de preparação e aumentar a necessidade estimada de recuperação."}
  ]},
  {"type": "banner", "tone": "info", "text": "<strong>A Prontidão é dinâmica.</strong> Ela não é uma nota definitiva dada pela manhã."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 5: Prontidão x Recuperação
-- ----------------------------------------------------------------------------
('fafb5e04-e561-4bd1-a7f3-2c39361376d7', v_mod, 'Não confunda Prontidão com Tempo de Recuperação', 'text', 4, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Não confunda Prontidão com Tempo de Recuperação</h3><p>As duas métricas aparecem juntas no relógio, mas respondem perguntas diferentes.</p>"},
  {"type": "tabs", "items": [
    {"label": "Prontidão de Treino", "title": "“Como está minha preparação para treinar?”", "text": "<p><strong>Considera:</strong> sono, histórico de sono, VFC, estresse, carga e recuperação.</p><p><strong>Momento:</strong> visão mais ampla da preparação atual.</p>"},
    {"label": "Tempo de Recuperação", "title": "“Quanto tempo de recuperação ainda é estimado após esse esforço?”", "text": "<p><strong>Momento:</strong> principalmente após uma atividade.</p><p><strong>Foco:</strong> recuperação do esforço realizado.</p>"}
  ]},
  {"type": "card_grid", "columns": 2, "items": [
    {"title": "Prontidão", "text": "Visão da preparação."},
    {"title": "Recuperação", "text": "Tempo após o esforço."}
  ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 6: Carga de Treino
-- ----------------------------------------------------------------------------
('0ccee087-f03b-4f0a-8ad1-1b7ab2f39158', v_mod, 'Quanto treinamento está acumulado?', 'text', 5, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Quanto treinamento está acumulado?</h3><p>A Carga de Treino ajuda a entender o impacto dos treinos recentes e como esse volume vem evoluindo ao longo do tempo.</p><p>Ela não responde diretamente: “Estou pronto para treinar hoje?”</p><p>Ela ajuda a responder: <strong>“Como meu treinamento recente está se comportando?”</strong></p>"},
  {"type": "flip_card", "columns": 1, "tall": true, "cards": [
    {
      "title": "Carga de Treino",
      "subtitle": "Impacto do treinamento recente",
      "frontText": "Toque para entender.",
      "backLabel": "Carga de Treino",
      "backText": "<p>A Carga de Treino ajuda a acompanhar o impacto dos treinos realizados ao longo do tempo.</p><p>Ela permite observar se o volume de treinamento está aumentando, diminuindo ou permanecendo mais estável.</p>",
      "practicalTip": "<p>Na venda, é uma informação especialmente relevante para quem treina regularmente e quer entender a evolução da própria rotina de treinamento.</p>"
    }
  ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 7: Foco da Carga de Treino
-- ----------------------------------------------------------------------------
('fa9835a0-cc1e-4719-afed-daf32640f53b', v_mod, 'Não é só quanto você treina. É como você treina.', 'text', 6, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Não é só quanto você treina. É como você treina.</h3><p>O Foco da Carga de Treino ajuda a visualizar como os estímulos dos treinos estão distribuídos.</p>"},
  {"type": "tabs", "items": [
    {"label": "Aeróbico", "title": "Estímulos aeróbicos", "text": "<p>Relaciona-se aos estímulos associados ao desenvolvimento da resistência e capacidade aeróbica.</p>"},
    {"label": "Anaeróbico", "title": "Estímulos anaeróbicos", "text": "<p>Relaciona-se aos estímulos de maior intensidade.</p>"}
  ]},
  {"type": "banner", "tone": "info", "text": "O objetivo não é dizer que um tipo é melhor que o outro. O objetivo é entender como os diferentes estímulos estão distribuídos dentro da rotina de treinamento."},
  {"type": "banner", "tone": "success", "text": "<strong>Argumento de venda:</strong> “Além de saber quanto você está treinando, dá para entender melhor em que tipo de estímulo seu treinamento está concentrado.”"}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 8: Carga aguda e carga crônica
-- ----------------------------------------------------------------------------
('2515a4e8-3e3c-4b57-a022-9963daa51b73', v_mod, 'Como interpretar a evolução da carga?', 'text', 7, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Como interpretar a evolução da carga?</h3><p>Revele cada etapa para entender a lógica da comparação.</p>"},
  {"type": "timeline", "reveal": true, "items": [
    {"label": "Carga aguda", "text": "Representa o impacto dos treinos mais recentes."},
    {"label": "Carga crônica", "text": "Representa uma visão do histórico de treinamento ao longo de um período maior."},
    {"label": "Por que comparar?", "text": "A comparação ajuda a entender como o volume atual está se comportando em relação ao histórico recente de treinamento."}
  ]},
  {"type": "banner", "tone": "info", "text": "O objetivo não é simplesmente aumentar a carga. O objetivo é entender a relação entre estímulo, recuperação e evolução."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 9: EPOC sem complicar
-- ----------------------------------------------------------------------------
('d8e3fd82-9233-4b72-8a92-0e1abe6ef8fb', v_mod, 'O que é EPOC?', 'text', 8, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>O que é EPOC?</h3><p>Um conceito que ajuda a explicar o que acontece depois do treino.</p>"},
  {"type": "flip_card", "columns": 1, "tall": true, "cards": [
    {
      "title": "EPOC",
      "subtitle": "Excesso de Consumo de Oxigênio Pós-Exercício",
      "frontText": "Toque para entender.",
      "backLabel": "EPOC",
      "backText": "<p>Depois de um exercício, o organismo continua consumindo oxigênio acima dos níveis de repouso enquanto trabalha para retornar ao estado normal. Esse fenômeno é chamado de EPOC.</p><p><strong>Na lógica do treinamento:</strong></p><p>Treino → estímulo<br>Recuperação → organismo responde ao esforço<br>Adaptação → organismo se ajusta ao estímulo</p>",
      "practicalTip": "<p>Na venda, o conceito ajuda a explicar por que um treino não termina exatamente quando o cliente para de correr.</p>"
    }
  ]},
  {"type": "banner", "tone": "warning", "text": "<strong>Importante:</strong> não transforme EPOC em uma promessa de resultado. O EPOC sozinho não determina adaptação ou evolução."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 10: Prontidão x Carga x VO2 Máx
-- ----------------------------------------------------------------------------
('b8565f9d-3dd5-4fa2-a9d9-6fe22b56b7d4', v_mod, 'Três métricas. Três perguntas.', 'text', 9, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Três métricas. Três perguntas.</h3><p>Antes de explicar uma métrica, saiba qual pergunta ela responde.</p>"},
  {"type": "tabs", "items": [
    {"label": "Prontidão de Treino", "title": "“Como está minha preparação para treinar agora?”", "text": "<p>Olha para a preparação naquele momento.</p>"},
    {"label": "Carga de Treino", "title": "“Como meu treinamento recente está se comportando?”", "text": "<p>Olha para o impacto acumulado do treinamento.</p>"},
    {"label": "VO2 Máx", "title": "“Qual é minha capacidade cardiorrespiratória estimada?”", "text": "<p>Olha para a capacidade cardiorrespiratória.</p>"}
  ]},
  {"type": "banner", "tone": "info", "text": "<strong>Essas métricas não competem entre si.</strong> Elas respondem perguntas diferentes."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 11: Desafio de interpretação
-- ----------------------------------------------------------------------------
('5be8c128-6475-40ce-8336-15041c5b13f3', v_mod, 'O relógio diz “Low”. E agora?', 'text', 10, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>O relógio diz “Low”. E agora?</h3><p>O cliente olha para o relógio e faz a pergunta abaixo.</p>"},
  {"type": "cenario_escolha",
   "context": "Cliente: “Minha Prontidão está baixa. Então significa que eu não posso treinar?”",
   "prompt": "Qual é a melhor resposta?",
   "options": [
     {"text": "“Sim. O relógio está dizendo que você não pode treinar.”", "correct": false, "feedback": "A Prontidão é uma orientação, não uma ordem. Transformar o score em proibição coloca o relógio no lugar de um diagnóstico."},
     {"text": "“Não necessariamente. A Prontidão reúne diferentes sinais para contextualizar sua preparação. Vale olhar também para os fatores que estão influenciando essa pontuação.”", "correct": true, "feedback": "A Prontidão de Treino é uma ferramenta de orientação. Ela não substitui a percepção individual, o planejamento do treinamento ou a orientação de um profissional. O papel do vendedor é explicar o que a métrica representa sem transformar o score em uma ordem médica ou esportiva."},
     {"text": "“Isso acontece porque seu VO2 Máx está baixo.”", "correct": false, "feedback": "VO2 Máx e Prontidão respondem perguntas diferentes. Uma Prontidão baixa não indica, por si só, nada sobre a capacidade cardiorrespiratória."},
     {"text": "“É melhor ignorar porque essas métricas não servem para nada.”", "correct": false, "feedback": "Desqualificar o recurso tira do cliente uma informação útil. O caminho é explicar o contexto, não descartar o dado."}
   ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 12: Desafio de venda
-- ----------------------------------------------------------------------------
('b15fabcf-b0e3-4d92-b961-79ab5b770724', v_mod, 'Quando apresentar Prontidão?', 'text', 11, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Quando apresentar Prontidão?</h3><p>Conhecer bem um recurso não significa abrir a conversa com ele.</p>"},
  {"type": "cenario_escolha",
   "context": "Cliente: “Eu corro uma vez por semana. Só quero acompanhar distância e pace.”",
   "prompt": "O vendedor deveria começar falando de Prontidão de Treino?",
   "options": [
     {"text": "Sim. É uma das métricas mais avançadas.", "correct": false, "feedback": "Ser avançada não torna a métrica relevante para esse cliente. Ele acabou de dizer o que quer acompanhar."},
     {"text": "Não como prioridade. Primeiro entenda o objetivo do cliente e apresente os recursos mais relevantes para sua rotina.", "correct": true, "feedback": "Conhecer um recurso não significa que ele precisa aparecer em toda venda. A Prontidão tende a ganhar mais relevância quando o cliente demonstra interesse em treinamento estruturado, recuperação e acompanhamento de evolução."}
   ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 13: Perfil de cliente
-- ----------------------------------------------------------------------------
('e0511d0a-9639-425b-b97a-9bb92bd8a0db', v_mod, 'Quem valoriza esse tipo de informação?', 'text', 12, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Quem valoriza esse tipo de informação?</h3><p>A relevância da Prontidão muda conforme a rotina e o objetivo do cliente. Conheça os três perfis e depois teste a leitura.</p>"},
  {"type": "tabs", "items": [
    {"label": "Corredor iniciante", "title": "Corredor iniciante", "text": "<p>Corre uma ou duas vezes por semana. Quer acompanhar distância, tempo e ritmo.</p><p><strong>Necessidade principal:</strong> entender o básico.</p>", "note": "Abordagem: começar pelas métricas fundamentais. Não despejar métricas avançadas."},
    {"label": "Corredor dedicado", "title": "Corredor dedicado", "text": "<p>Treina várias vezes por semana. Acompanha evolução. Tem metas de performance.</p><p><strong>Necessidade:</strong> entender carga, recuperação e evolução.</p>", "note": "Abordagem: Prontidão, Tempo de Recuperação, Carga e métricas de performance podem ganhar relevância."},
    {"label": "Atleta de performance", "title": "Atleta de performance", "text": "<p>Treina com estrutura. Participa de provas. Acompanha diferentes indicadores.</p><p><strong>Necessidade:</strong> analisar treinamento de forma mais aprofundada.</p>", "note": "Abordagem: explorar a relação entre carga, recuperação, prontidão e outras métricas avançadas compatíveis com o produto."}
  ]},
  {"type": "cenario_escolha",
   "context": "Cliente: “Treino quatro vezes por semana, gosto de ver se estou evoluindo e quero baixar meu tempo nos 10 km.”",
   "prompt": "Qual perfil mais se aproxima desse cliente?",
   "options": [
     {"text": "Corredor iniciante", "correct": false, "feedback": "O cliente já treina com frequência e tem meta de performance. Ficar só no básico deixaria a necessidade dele sem resposta."},
     {"text": "Corredor dedicado", "correct": true, "feedback": "Treina várias vezes por semana, acompanha evolução e tem meta. Prontidão, Tempo de Recuperação e Carga podem ganhar relevância nessa conversa."},
     {"text": "Atleta de performance", "correct": false, "feedback": "Ele não mencionou treino estruturado, provas ou vários indicadores. Comece pelo que ele trouxe e aprofunde se o interesse aparecer."}
   ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 14: Estudo de caso
-- ----------------------------------------------------------------------------
('46d32190-df9b-4ec5-a143-c44429b909ef', v_mod, 'Você está no balcão', 'text', 13, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Você está no balcão</h3><p>Leia a fala do cliente e escolha a conversa que faz mais sentido.</p>"},
  {"type": "cenario_escolha",
   "context": "Cliente: “Eu treino cinco vezes por semana e estou me preparando para uma prova. Nas últimas semanas aumentei bastante meu volume e comecei a perceber que alguns dias rendo muito e outros não.”",
   "prompt": "Qual conversa faz mais sentido?",
   "options": [
     {"text": "“Você precisa de um relógio com mais bateria.”", "correct": false, "feedback": "Bateria não tem relação com o que o cliente descreveu: aumento de volume e variação de rendimento."},
     {"text": "“Vamos olhar como você está treinando, o que acompanha hoje e se recursos como carga, recuperação e Prontidão podem ajudar a contextualizar essa variação.”", "correct": true, "feedback": "O cliente apresentou uma necessidade clara relacionada à gestão do treinamento. A oportunidade não é vender uma métrica isolada. É mostrar como diferentes informações podem ajudar o cliente a entender melhor sua rotina."},
     {"text": "“Seu VO2 Máx deve estar baixo.”", "correct": false, "feedback": "É um palpite sem dado, e VO2 Máx não explica a variação de um dia para o outro que o cliente descreveu."},
     {"text": "“É só aumentar ainda mais o volume.”", "correct": false, "feedback": "Orientar o treino não é papel do vendedor, e a sugestão ignora justamente a relação entre carga e recuperação."}
   ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 15: Compatibilidade
-- ----------------------------------------------------------------------------
('bddfaccb-7216-4749-bfa4-a853164fb084', v_mod, 'Todo Garmin tem Prontidão de Treino?', 'text', 14, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Todo Garmin tem Prontidão de Treino?</h3><p><strong>Não.</strong></p><p>A disponibilidade dos recursos depende do modelo, geração, sensores e funcionalidades compatíveis.</p>"},
  {"type": "accordion", "items": [
    {"title": "Antes de afirmar", "html": "<p>Sempre confirme o modelo exato.</p>"},
    {"title": "Prontidão", "html": "<p>Não apresentar como recurso universal de toda a linha Garmin.</p>"},
    {"title": "Carga de Treino", "html": "<p>Também pode variar conforme o dispositivo e os recursos disponíveis.</p>"},
    {"title": "VFC (HRV)", "html": "<p>A disponibilidade e a forma de apresentação também dependem do dispositivo e dos recursos compatíveis.</p>"}
  ]},
  {"type": "banner", "tone": "warning", "text": "<strong>Regra de ouro:</strong> nunca diga “Todo Garmin tem.” Prefira “Esse modelo oferece esse recurso.” ou “Vamos confirmar a compatibilidade desse modelo.”"},
  {"type": "banner", "tone": "info", "text": "Para confirmar um modelo específico, consulte a ficha do produto na Academia de Produtos ou o site oficial da Garmin."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 16: Checklist de domínio
-- ----------------------------------------------------------------------------
('3d4c314d-7949-4e9b-bfa9-f8cf0f4bf152', v_mod, 'Eu consigo explicar?', 'text', 15, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Eu consigo explicar?</h3><p>Marque cada item que você já consegue explicar com segurança.</p>"},
  {"type": "checklist", "items": [
    "Sei explicar o que é Prontidão de Treino.",
    "Sei explicar o que influencia a pontuação.",
    "Sei explicar que a Prontidão pode mudar durante o dia.",
    "Sei diferenciar Prontidão de Tempo de Recuperação.",
    "Sei explicar Carga de Treino.",
    "Sei explicar Foco da Carga de Treino.",
    "Sei diferenciar carga recente de histórico de treinamento.",
    "Sei explicar o conceito de EPOC sem exagerar.",
    "Sei diferenciar Prontidão, Carga e VO2 Máx.",
    "Sei identificar quando a Prontidão é relevante para o cliente.",
    "Sei evitar apresentar a métrica como diagnóstico.",
    "Sei evitar dizer que o relógio determina se o cliente pode ou não treinar.",
    "Sei confirmar compatibilidade antes de prometer um recurso.",
    "Sei transformar a métrica em benefício para o cliente."
  ], "reflection": "Se algum item ficou sem marcar, volte à lição correspondente antes do desafio final."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 17: Glossário
-- ----------------------------------------------------------------------------
('d542577c-a168-4370-9f44-4c81274a3483', v_mod, 'Associe o conceito', 'text', 16, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Associe o conceito</h3><p>Ligue cada métrica ao que ela representa.</p>"},
  {"type": "match_quiz", "pairs": [
    {"term": "Prontidão de Treino", "definition": "Visão da preparação atual para o treinamento."},
    {"term": "Carga de Treino", "definition": "Impacto e evolução do treinamento recente."},
    {"term": "Foco da Carga", "definition": "Distribuição dos estímulos de treinamento."},
    {"term": "Tempo de Recuperação", "definition": "Estimativa relacionada ao período necessário após um esforço."},
    {"term": "VFC", "definition": "Variação dos intervalos entre os batimentos cardíacos."},
    {"term": "EPOC", "definition": "Consumo de oxigênio acima dos níveis de repouso após o exercício."},
    {"term": "VO2 Máx", "definition": "Estimativa relacionada à capacidade cardiorrespiratória."}
  ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 18: Desafio final + encerramento
-- ----------------------------------------------------------------------------
('e1ca9a08-21b0-457f-b333-142884899481', v_mod, 'Transforme dados em conversa', 'text', 17, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Transforme dados em conversa</h3><p>Último desafio do módulo.</p>"},
  {"type": "cenario_escolha",
   "context": "Cliente: “Meu relógio mostrou Prontidão 42 hoje. Ontem estava 78. Isso significa que eu piorei?”",
   "prompt": "Qual é a melhor resposta?",
   "options": [
     {"text": "“Sim. Seu condicionamento caiu.”", "correct": false, "feedback": "A Prontidão não mede condicionamento físico. Uma queda no score não quer dizer perda de condicionamento."},
     {"text": "“Não necessariamente. A Prontidão considera diferentes fatores e pode mudar conforme sono, recuperação, carga e outros dados disponíveis.”", "correct": true, "feedback": "A Prontidão não representa uma medida direta de condicionamento físico. Ela é uma visão dinâmica da preparação para o treinamento. Uma mudança no score não significa automaticamente perda de condicionamento."},
     {"text": "“Seu VO2 Máx caiu.”", "correct": false, "feedback": "Prontidão e VO2 Máx são métricas diferentes. Uma não indica a outra."},
     {"text": "“Isso significa que você não pode treinar.”", "correct": false, "feedback": "Uma pontuação mais baixa pode sugerir considerar recuperação ou menor intensidade, mas não é uma proibição."}
   ]},
  {"type": "texto_rico", "html": "<h3>O vendedor não vende a pontuação. Ele explica o contexto.</h3><p>Prontidão de Treino, Carga de Treino, Recuperação e VO2 Máx são informações diferentes. O valor está em entender como elas se relacionam.</p><p>Um bom vendedor não olha para um número e simplesmente repete o que ele significa. Ele entende:</p><ul><li>O que mudou?</li><li>Por que essa informação pode ser relevante?</li><li>O que o cliente quer alcançar?</li><li>Qual recurso ajuda a responder essa necessidade?</li></ul><p>E, principalmente: <strong>esse recurso faz sentido para esse cliente?</strong></p>"},
  {"type": "banner", "tone": "success", "text": "<strong>“Conhecer a métrica é importante. Saber interpretar o contexto é o que transforma dado em orientação.”</strong>"}
]}
$j$::jsonb)

on conflict (id) do update
   set title        = excluded.title,
       order_index  = excluded.order_index,
       is_published = excluded.is_published,
       body         = excluded.body;

end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 168
-- ============================================================================
