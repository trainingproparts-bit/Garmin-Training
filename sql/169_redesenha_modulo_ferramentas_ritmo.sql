-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 169: redesign do módulo Ferramentas de Ritmo e Planejamento de Prova
-- ============================================================================
-- Pedido do usuário (2026-10-07): redesenhar por completo o módulo, na
-- sequência NECESSIDADE > FERRAMENTA > COMO FUNCIONA > DEMONSTRAÇÃO >
-- APLICAÇÃO NA VENDA, em 20 lições (encerramento e glossário no fim da 20).
--
-- Preservação de progresso: os 5 lessons existentes são reaproveitados
-- (mesmo id), cada um na lição nova de mesmo assunto:
--   9a1eac18 PacePro                       -> lição 2
--   2cf0b773 Previsão de Corrida           -> lição 5
--   7f7dd332 Treinos Sugeridos Diariamente -> lição 7
--   4a6d04e8 Treino estruturado, passo a passo -> lição 10
--   003d7d08 Trajetos, passo a passo       -> lição 13
-- As outras 15 entram com id fixo (insert ... on conflict (id) do update),
-- então rodar de novo só atualiza. O checkpoint do módulo no GPS da Carreira
-- fica em user_progress e não é recalculado.
--
-- Usa só blocos que já existem em ContentBlocks.js. Os flip cards usam os
-- campos opcionais `image` e `salesTip` (ver sql/168); ficam sem imagem até
-- os screenshots serem enviados pelo editor. O passo a passo operacional do
-- módulo antigo foi mantido, agora como timeline de revelação.
--
-- Regras de conteúdo do briefing: sem emoji, sem travessão, sem lista de
-- modelos compatíveis (sai a frase "praticamente toda a linha atual suporta
-- trajetos"), menus apresentados como podendo variar por versão, previsão
-- sempre como estimativa.
-- ============================================================================

do $$
declare
  v_mod uuid := 'a25bd64b-60fd-41b3-a132-651285a16d50';
begin

update modules
   set summary = 'PacePro, Previsão de Corrida, Treinos Sugeridos Diariamente, Treino Estruturado e Trajetos: qual ferramenta resolve qual necessidade do cliente, e como demonstrar cada uma no balcão.'
 where id = v_mod;

insert into lessons (id, module_id, title, content_type, order_index, is_published, body) values

-- ----------------------------------------------------------------------------
-- LIÇÃO 1: A caixa de ferramentas do atleta
-- ----------------------------------------------------------------------------
('0ff7addc-926e-4ca8-b6d9-e54948426811', v_mod, 'Qual ferramenta resolve qual problema?', 'text', 0, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Qual ferramenta resolve qual problema?</h3><p>O Garmin Connect não serve apenas para registrar o que aconteceu no treino.</p><p>Ele também ajuda o atleta a planejar, executar e analisar.</p><p>As ferramentas desta lição respondem perguntas diferentes.</p>"},
  {"type": "tabs", "items": [
    {"label": "PacePro", "title": "“Como devo distribuir meu ritmo ao longo do percurso?”", "text": "<p>Estratégia de ritmo durante o percurso.</p>"},
    {"label": "Previsão de Corrida", "title": "“Qual tempo posso usar como referência para uma prova?”", "text": "<p>Referência de tempo de prova.</p>"},
    {"label": "Treinos Sugeridos", "title": "“O que faz sentido treinar hoje?”", "text": "<p>Recomendação de treino.</p>"},
    {"label": "Treino Estruturado", "title": "“Como faço exatamente o treino que quero executar?”", "text": "<p>Criação de um treino específico.</p>"},
    {"label": "Trajeto", "title": "“Por onde devo seguir?”", "text": "<p>Navegação por um caminho definido.</p>"}
  ]},
  {"type": "banner", "tone": "info", "text": "<strong>Não são ferramentas concorrentes.</strong> Elas podem fazer parte do mesmo ecossistema de treinamento."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 2: PacePro
-- ----------------------------------------------------------------------------
('9a1eac18-3f23-405e-878b-d2b33989fa3d', v_mod, 'PacePro', 'text', 1, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>PacePro</h3><p><strong>Estratégia de ritmo para o percurso inteiro.</strong></p>"},
  {"type": "flip_card", "columns": 1, "tall": true, "cards": [
    {
      "title": "PacePro",
      "subtitle": "Estratégia de ritmo",
      "frontText": "Toque para entender.",
      "backLabel": "O que é",
      "backText": "<p>O PacePro é uma ferramenta da Garmin para criar uma estratégia de ritmo personalizada para um percurso.</p><p>A estratégia é criada no Garmin Connect e pode ser sincronizada com um dispositivo compatível.</p><p>Em vez de trabalhar apenas com um ritmo fixo para toda a prova, o PacePro considera o perfil de elevação e distribui o ritmo-alvo ao longo do percurso.</p>",
      "practicalTip": "<p>O ritmo pode ser ajustado de acordo com as subidas e descidas.</p><p>Isso ajuda o atleta a planejar melhor como pretende correr cada trecho.</p>"
    }
  ]},
  {"type": "texto_rico", "html": "<h3>Do percurso ao relógio</h3><p>Revele cada etapa.</p>"},
  {"type": "timeline", "reveal": true, "items": [
    {"label": "Percurso", "text": "O atleta escolhe o percurso que vai correr."},
    {"label": "Perfil de elevação", "text": "O PacePro considera as subidas e descidas desse percurso."},
    {"label": "Ritmo por trecho", "text": "O ritmo-alvo é distribuído ao longo do percurso, em vez de um único pace do início ao fim."},
    {"label": "No pulso", "text": "A estratégia é sincronizada com um dispositivo compatível e acompanha o atleta durante a prova."}
  ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 3: Como o PacePro divide o percurso
-- ----------------------------------------------------------------------------
('61d785aa-233e-4aa2-8cdf-97e2afffc47f', v_mod, 'Três formas de dividir a estratégia', 'text', 2, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Três formas de dividir a estratégia</h3><p>O PacePro organiza o percurso em trechos. A forma de dividir muda a leitura da estratégia.</p>"},
  {"type": "tabs", "items": [
    {"label": "Por quilômetro", "title": "Por quilômetro", "text": "<p>A estratégia é dividida em trechos de um quilômetro.</p>"},
    {"label": "Por milha", "title": "Por milha", "text": "<p>A estratégia é dividida em trechos de uma milha.</p>"},
    {"label": "Por elevação", "title": "Por elevação", "text": "<p>Os trechos são definidos considerando as mudanças de elevação do percurso.</p>"}
  ]},
  {"type": "banner", "tone": "info", "text": "Para um percurso com relevo irregular, a divisão por elevação pode fazer mais sentido porque a estratégia acompanha melhor as mudanças do terreno."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 4: PacePro na venda
-- ----------------------------------------------------------------------------
('a2d08272-d814-4704-8c82-f21e9955eddb', v_mod, 'Quando apresentar o PacePro?', 'text', 3, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Quando apresentar o PacePro?</h3><p>Ouça a necessidade antes de escolher a ferramenta.</p>"},
  {"type": "cenario_escolha",
   "context": "Cliente: “Vou correr uma prova com bastante subida e tenho dificuldade para controlar o ritmo.”",
   "prompt": "Qual ferramenta merece ser apresentada?",
   "options": [
     {"text": "Garmin Pay", "correct": false, "feedback": "Pagamento por aproximação não tem relação com o problema que o cliente trouxe."},
     {"text": "PacePro", "correct": true, "feedback": "O cliente apresentou uma necessidade diretamente relacionada à distribuição de ritmo ao longo de um percurso com variação de elevação. O vendedor deve conectar a ferramenta ao problema apresentado."},
     {"text": "Monitoramento de Sono", "correct": false, "feedback": "Sono é um dado de recuperação. O cliente falou de controle de ritmo durante a prova."},
     {"text": "Música", "correct": false, "feedback": "Música pode ser um diferencial do produto, mas não responde à dificuldade de controlar o ritmo nas subidas."}
   ]},
  {"type": "banner", "tone": "success", "text": "<strong>Argumento:</strong> “Como o percurso tem bastante variação de elevação, podemos montar uma estratégia de ritmo que considera essas mudanças em vez de simplesmente tentar manter o mesmo pace do início ao fim.”"}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 5: Previsão de Corrida
-- ----------------------------------------------------------------------------
('2cf0b773-381a-458f-9e5c-3b40ed8e900b', v_mod, 'Previsão de Corrida', 'text', 4, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Previsão de Corrida</h3><p><strong>Uma referência para o tempo de prova.</strong></p>"},
  {"type": "flip_card", "columns": 1, "tall": true, "cards": [
    {
      "title": "Previsão de Corrida",
      "subtitle": "Quanto tempo posso esperar?",
      "frontText": "Toque para entender.",
      "backLabel": "O que é",
      "backText": "<p>A Previsão de Corrida apresenta uma estimativa de tempo para diferentes distâncias de prova com base nos dados de condicionamento e treinamento disponíveis.</p><p>Pode apresentar referências para 5 km, 10 km, meia maratona e maratona.</p>",
      "practicalTip": "<p>A previsão ajuda o atleta a acompanhar como sua evolução de treinamento pode refletir em diferentes distâncias.</p>"
    }
  ]},
  {"type": "banner", "tone": "warning", "text": "<strong>Importante:</strong> é uma estimativa. Não é uma garantia do tempo que o atleta fará na prova."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 6: Como explicar uma previsão
-- ----------------------------------------------------------------------------
('377bc5a3-ccf7-4add-a058-746ec299e07f', v_mod, 'Estimativa não é promessa', 'text', 5, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Estimativa não é promessa</h3><p>Revele cada etapa para montar a explicação.</p>"},
  {"type": "timeline", "reveal": true, "items": [
    {"label": "O relógio estima", "text": "A previsão é baseada nos dados disponíveis e nas informações de condicionamento e treinamento."},
    {"label": "A prova é real", "text": "Condições de percurso, clima, estratégia, alimentação, experiência e execução podem influenciar o resultado."},
    {"label": "Use como referência", "text": "A previsão deve ser apresentada como uma referência para o atleta acompanhar sua evolução e estabelecer expectativas."}
  ]},
  {"type": "banner", "tone": "success", "text": "<strong>Frase para o cliente:</strong> “É uma estimativa baseada nos seus dados atuais. Serve como referência, mas o tempo real da prova depende de vários fatores.”"}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 7: Treinos Sugeridos Diariamente
-- ----------------------------------------------------------------------------
('7f7dd332-46e9-4762-bbd7-207dbcbe4ac8', v_mod, 'Treinos Sugeridos Diariamente', 'text', 6, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Treinos Sugeridos Diariamente</h3><p><strong>Uma recomendação de treino baseada no seu momento.</strong></p>"},
  {"type": "flip_card", "columns": 1, "tall": true, "cards": [
    {
      "title": "Treinos Sugeridos Diariamente",
      "subtitle": "O que treinar hoje?",
      "frontText": "Toque para entender.",
      "backLabel": "O que é",
      "backText": "<p>Os Treinos Sugeridos Diariamente são recomendações de treinamento geradas automaticamente em dispositivos compatíveis.</p><p>As sugestões consideram dados disponíveis relacionados ao condicionamento físico, atividades recentes e recuperação.</p>",
      "practicalTip": "<p>Em vez de o atleta precisar montar cada treino do zero, o dispositivo pode apresentar uma sugestão adequada ao momento e ao objetivo de treinamento.</p>",
      "salesTip": "<p>“Se você não sabe exatamente o que fazer em cada dia, o relógio pode sugerir uma sessão com base nos seus dados.”</p>"
    }
  ]},
  {"type": "banner", "tone": "warning", "text": "<strong>Importante:</strong> a disponibilidade depende do dispositivo e do esporte."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 8: TSD x Garmin Coach
-- ----------------------------------------------------------------------------
('015ae68c-b093-4821-87da-7feeacd2af63', v_mod, 'Não confunda recomendação diária com plano de treinamento', 'text', 7, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Não confunda recomendação diária com plano de treinamento</h3><p>Os dois orientam o treino, mas em escalas de tempo diferentes.</p>"},
  {"type": "tabs", "items": [
    {"label": "Treinos Sugeridos Diariamente", "title": "“O que faz sentido fazer hoje?”", "text": "<p><strong>O que é:</strong> sugestões de treino apresentadas de acordo com o momento do atleta.</p><p><strong>Formato:</strong> orientação diária.</p>"},
    {"label": "Garmin Coach", "title": "“Como vou chegar preparado para esse objetivo?”", "text": "<p><strong>O que é:</strong> planos de treinamento estruturados para um objetivo específico.</p><p><strong>Formato:</strong> programa de treinamento ao longo de várias semanas.</p>"}
  ]},
  {"type": "card_grid", "columns": 2, "items": [
    {"title": "Treinos Sugeridos", "text": "Sugestão para o momento."},
    {"title": "Garmin Coach", "text": "Plano para um objetivo."}
  ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 9: Treino estruturado
-- ----------------------------------------------------------------------------
('792bc570-64c0-45d9-be66-4013e2160f9a', v_mod, 'Monte exatamente o treino que você quer fazer', 'text', 8, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Monte exatamente o treino que você quer fazer</h3><p>Treino estruturado é diferente de um treino sugerido.</p><p>Aqui, o próprio usuário monta a sessão que deseja executar.</p>"},
  {"type": "banner", "tone": "info", "text": "<strong>Exemplo:</strong> 5 x 1 km forte + 400 m de recuperação."},
  {"type": "texto_rico", "html": "<p>Revele as etapas que um treino estruturado pode incluir.</p>"},
  {"type": "timeline", "reveal": true, "items": [
    {"label": "Aquecimento", "text": "Preparação antes da parte principal do treino."},
    {"label": "Blocos de trabalho", "text": "A parte principal, como os 5 tiros de 1 km forte do exemplo."},
    {"label": "Recuperações", "text": "Os intervalos entre os blocos, como os 400 m de recuperação."},
    {"label": "Desaquecimento", "text": "O fechamento da sessão."}
  ]},
  {"type": "banner", "tone": "info", "text": "As metas de cada etapa podem variar conforme a atividade e os recursos compatíveis."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 10: Criando um treino no Garmin Connect
-- ----------------------------------------------------------------------------
('4a6d04e8-33ac-4827-90a8-7f60c2ca7c10', v_mod, 'Crie um treino em poucos minutos', 'text', 9, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Crie um treino em poucos minutos</h3><p>Use este roteiro como demonstração prática no balcão. Revele uma etapa por vez.</p>"},
  {"type": "timeline", "reveal": true, "items": [
    {"label": "Abra o Garmin Connect", "text": "Abra o Garmin Connect e acesse Treinamento e Planejamento → Treinos → Criar um Treino.<br><strong>Argumento:</strong> “Vamos criar um treino simples para você ver como funciona.”"},
    {"label": "Escolha a atividade", "text": "Selecione a modalidade, por exemplo Corrida. Depois, monte as etapas do treino. As etapas podem utilizar metas compatíveis, como tempo, distância, frequência cardíaca, ritmo e potência."},
    {"label": "Monte o treino", "text": "Exemplo: aquecimento; 5 x (1 km forte + 400 m de recuperação); desaquecimento.<br><strong>Argumento:</strong> “Você pode deixar o relógio orientar cada etapa em vez de precisar lembrar o treino durante a atividade.”"},
    {"label": "Salve", "text": "Salve o treino e dê um nome para identificá-lo posteriormente."},
    {"label": "Envie para o dispositivo", "text": "Selecione o treino e envie para o dispositivo compatível. Após a sincronização, o treino fica disponível para execução no relógio."}
  ]},
  {"type": "banner", "tone": "warning", "text": "<strong>Atenção aos menus:</strong> os nomes podem mudar conforme a versão do aplicativo Garmin Connect. Se a tela do cliente estiver diferente, procure a área de treinos dentro de Treinamento e Planejamento."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 11: Treino estruturado x Trajeto
-- ----------------------------------------------------------------------------
('2ce7c72f-a80c-4160-b538-5730504325a5', v_mod, 'Uma diferença que o vendedor precisa saber', 'text', 10, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Uma diferença que o vendedor precisa saber</h3><p>Os dois aparecem no relógio durante a atividade, mas guiam coisas diferentes.</p>"},
  {"type": "tabs", "items": [
    {"label": "Treino Estruturado", "title": "Guia: o que fazer", "text": "<p><strong>Exemplo:</strong> corra 1 km forte. Depois faça 400 m de recuperação.</p><p><strong>Foco:</strong> execução do treino.</p>"},
    {"label": "Trajeto", "title": "Guia: por onde ir", "text": "<p><strong>Exemplo:</strong> siga a rota de 10 km criada para a prova.</p><p><strong>Foco:</strong> navegação.</p>"}
  ]},
  {"type": "card_grid", "columns": 2, "items": [
    {"title": "Treino", "text": "O que fazer."},
    {"title": "Trajeto", "text": "Por onde ir."}
  ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 12: Trajetos
-- ----------------------------------------------------------------------------
('ddf64e0d-9f6e-4364-b1bf-b60f7415bb1b', v_mod, 'Trajetos', 'text', 11, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Trajetos</h3><p><strong>Quando o relógio precisa saber para onde você está indo.</strong></p>"},
  {"type": "flip_card", "columns": 1, "tall": true, "cards": [
    {
      "title": "Trajeto",
      "subtitle": "Navegação por uma rota definida",
      "frontText": "Toque para entender.",
      "backLabel": "O que é",
      "backText": "<p>Um trajeto é um percurso salvo que pode ser seguido em um dispositivo compatível.</p><p>Pode ser útil para:</p><ul><li>Percursos de prova</li><li>Rotas novas</li><li>Trilhas</li><li>Pedais</li><li>Exploração de uma região</li></ul>",
      "practicalTip": "<p>O treino orienta a execução. O trajeto orienta o caminho.</p>"
    }
  ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 13: Criando um trajeto
-- ----------------------------------------------------------------------------
('003d7d08-944e-4c48-848e-f1ab70cffd07', v_mod, 'Crie uma rota e envie para o dispositivo', 'text', 12, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Crie uma rota e envie para o dispositivo</h3><p>Use este roteiro como demonstração prática. Revele uma etapa por vez.</p>"},
  {"type": "timeline", "reveal": true, "items": [
    {"label": "Crie o trajeto", "text": "No Garmin Connect, acesse a área de Treinamento e Planejamento e encontre a opção de Trajetos. Crie uma nova rota e escolha a atividade correspondente. Dependendo da ferramenta disponível, o percurso pode ser criado manualmente ou com sugestões automáticas."},
    {"label": "Revise", "text": "Confira distância, ganho de elevação e percurso. Depois salve o trajeto."},
    {"label": "Envie para o dispositivo", "text": "Selecione o trajeto e envie para um dispositivo compatível."},
    {"label": "Siga o trajeto", "text": "No dispositivo, abra a navegação e selecione o trajeto salvo."}
  ]},
  {"type": "banner", "tone": "warning", "text": "<strong>Importante:</strong> os nomes exatos dos menus podem variar conforme o aplicativo, o dispositivo e a versão do software. Este passo a passo não é universal para todos os modelos."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 14: Trajeto na venda
-- ----------------------------------------------------------------------------
('e88dad06-1713-457a-8a85-a4a48a24da66', v_mod, 'Qual ferramenta você apresentaria?', 'text', 13, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Qual ferramenta você apresentaria?</h3><p>Dois clientes, dois problemas parecidos. Responda os dois.</p>"},
  {"type": "cenario_escolha",
   "context": "Cliente: “Vou correr uma prova em outra cidade e nunca fiz esse percurso.”",
   "prompt": "A melhor ferramenta para começar a conversa é:",
   "options": [
     {"text": "Trajeto", "correct": true, "feedback": "O problema apresentado é navegação. O trajeto permite preparar o percurso e utilizá-lo como referência durante a atividade em dispositivos compatíveis."},
     {"text": "Garmin Pay", "correct": false, "feedback": "Pagamento não resolve o fato de o cliente não conhecer o percurso."},
     {"text": "VO2 Máx", "correct": false, "feedback": "VO2 Máx é uma estimativa de capacidade cardiorrespiratória. O cliente falou de um caminho que não conhece."}
   ]},
  {"type": "cenario_escolha",
   "context": "Cliente: “Tenho uma prova cheia de subidas e quero saber como distribuir meu ritmo.”",
   "prompt": "E agora?",
   "options": [
     {"text": "Trajeto", "correct": false, "feedback": "Aqui o problema não é encontrar o caminho. É definir uma estratégia de ritmo para o percurso."},
     {"text": "PacePro", "correct": true, "feedback": "Aqui o problema não é encontrar o caminho. É definir uma estratégia de ritmo para o percurso, considerando as subidas."},
     {"text": "Previsão de Corrida", "correct": false, "feedback": "A previsão dá uma referência de tempo final, mas não distribui o ritmo ao longo das subidas."}
   ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 15: Qual ferramenta?
-- ----------------------------------------------------------------------------
('f5513532-d362-4594-aab5-9403be9bf0a3', v_mod, 'Associe a necessidade à ferramenta', 'text', 14, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Associe a necessidade à ferramenta</h3><p>Ligue cada fala de cliente à ferramenta que resolve a necessidade.</p>"},
  {"type": "match_quiz", "pairs": [
    {"term": "PacePro", "definition": "“Quero distribuir meu ritmo de acordo com as subidas.”"},
    {"term": "Previsão de Corrida", "definition": "“Quero ter uma referência de tempo para uma prova.”"},
    {"term": "Treinos Sugeridos Diariamente", "definition": "“Não sei o que treinar hoje.”"},
    {"term": "Treino Estruturado", "definition": "“Quero criar meu próprio treino de intervalados.”"},
    {"term": "Trajeto", "definition": "“Quero seguir o percurso de uma prova.”"}
  ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 16: Desafio de atendimento
-- ----------------------------------------------------------------------------
('fb5ff92b-e56f-4632-9032-d0fb39251b76', v_mod, 'Você está no balcão', 'text', 15, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Você está no balcão</h3><p>Leia a fala do cliente e escolha a conversa que faz mais sentido.</p>"},
  {"type": "cenario_escolha",
   "context": "Cliente: “Vou fazer minha primeira meia maratona. Quero me preparar melhor, mas também tenho dificuldade para controlar o ritmo durante as provas.”",
   "prompt": "Qual conversa faz mais sentido?",
   "options": [
     {"text": "Mostrar apenas PacePro.", "correct": false, "feedback": "O PacePro responde ao controle de ritmo, mas deixa de fora a preparação para a prova, que o cliente também trouxe."},
     {"text": "Mostrar apenas Garmin Coach.", "correct": false, "feedback": "O Garmin Coach ajuda na preparação, mas não resolve sozinho a dificuldade de distribuir o ritmo na prova."},
     {"text": "Entender o objetivo do cliente e apresentar as ferramentas conforme as necessidades: plano de preparação, referência de desempenho e estratégia de ritmo.", "correct": true, "feedback": "Uma necessidade pode envolver mais de uma ferramenta. O papel do vendedor é construir a solução a partir do objetivo do cliente, e não escolher uma função isoladamente."},
     {"text": "Mostrar todas as funções do relógio.", "correct": false, "feedback": "Uma lista de funções esconde justamente o que resolve o problema do cliente."}
   ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 17: Desafio de diferenciação
-- ----------------------------------------------------------------------------
('c54f180a-afdf-4858-a138-d4a706c19a71', v_mod, 'Treino ou trajeto?', 'text', 16, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Treino ou trajeto?</h3><p>Duas falas, duas respostas diferentes.</p>"},
  {"type": "cenario_escolha",
   "context": "Cliente: “Quero fazer 5 x 1 km forte com 400 m de recuperação e quero que o relógio me avise quando mudar cada etapa.”",
   "prompt": "O que você apresenta?",
   "options": [
     {"text": "Trajeto", "correct": false, "feedback": "O trajeto orienta o caminho. O cliente quer orientação sobre o que fazer em cada etapa."},
     {"text": "Treino Estruturado", "correct": true, "feedback": "O cliente precisa de orientação sobre o que fazer durante o treino."}
   ]},
  {"type": "cenario_escolha",
   "context": "Cliente: “Quero fazer uma rota de 20 km que nunca percorri.”",
   "prompt": "E agora?",
   "options": [
     {"text": "Trajeto", "correct": true, "feedback": "O problema agora é navegação."},
     {"text": "Treino Estruturado", "correct": false, "feedback": "O treino estruturado orienta a execução, não o caminho. Aqui o cliente não conhece a rota."}
   ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 18: Argumentos de venda
-- ----------------------------------------------------------------------------
('9c180067-fc77-4f0d-8687-39038a9ebc1b', v_mod, 'Como transformar ferramenta em benefício', 'text', 17, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Como transformar ferramenta em benefício</h3><p>Abra cada ferramenta e compare a frase que descreve a função com a frase que mostra o benefício.</p>"},
  {"type": "accordion", "items": [
    {"title": "PacePro", "html": "<p><strong>Evite:</strong> “Esse relógio tem PacePro.”</p><p><strong>Prefira:</strong> “Se você vai correr um percurso com subidas, podemos montar uma estratégia de ritmo que considere o relevo da prova.”</p>"},
    {"title": "Previsão de Corrida", "html": "<p><strong>Evite:</strong> “Ele prevê seu tempo.”</p><p><strong>Prefira:</strong> “Você consegue acompanhar uma estimativa de tempo para diferentes distâncias com base nos seus dados atuais.”</p>"},
    {"title": "Treinos Sugeridos", "html": "<p><strong>Evite:</strong> “Ele cria treino sozinho.”</p><p><strong>Prefira:</strong> “Se você não sabe exatamente o que fazer hoje, o relógio pode sugerir uma sessão com base nos seus dados.”</p>"},
    {"title": "Treino Estruturado", "html": "<p><strong>Evite:</strong> “Você consegue criar treino.”</p><p><strong>Prefira:</strong> “Você pode montar exatamente a sessão que quer fazer e deixar o relógio orientar cada etapa.”</p>"},
    {"title": "Trajeto", "html": "<p><strong>Evite:</strong> “Tem mapa.”</p><p><strong>Prefira:</strong> “Você pode preparar uma rota e seguir o percurso diretamente no dispositivo compatível.”</p>"}
  ]}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 19: Checklist de domínio
-- ----------------------------------------------------------------------------
('60b1e031-8ab7-43c6-b55d-09fe821481f6', v_mod, 'Eu sei escolher a ferramenta certa?', 'text', 18, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Eu sei escolher a ferramenta certa?</h3><p>Marque cada item que você já consegue fazer com segurança.</p>"},
  {"type": "checklist", "items": [
    "Sei explicar o PacePro.",
    "Sei explicar para que serve a Previsão de Corrida.",
    "Sei explicar os Treinos Sugeridos Diariamente.",
    "Sei diferenciar Treinos Sugeridos Diariamente de Garmin Coach.",
    "Sei criar ou demonstrar um treino estruturado.",
    "Sei diferenciar treino estruturado de trajeto.",
    "Sei explicar o que é um trajeto.",
    "Sei identificar quando apresentar PacePro.",
    "Sei identificar quando apresentar Trajeto.",
    "Sei identificar quando apresentar Treino Estruturado.",
    "Sei explicar que uma previsão não é garantia.",
    "Sei relacionar a ferramenta à necessidade do cliente.",
    "Sei evitar apresentar todas as funções de uma vez.",
    "Sei confirmar compatibilidade antes de prometer um recurso."
  ], "reflection": "Se algum item ficou sem marcar, volte à lição correspondente antes do desafio final."}
]}
$j$::jsonb),

-- ----------------------------------------------------------------------------
-- LIÇÃO 20: Desafio final + encerramento + glossário
-- ----------------------------------------------------------------------------
('f98374df-43b0-45ef-8afe-a5af1c9b1e5d', v_mod, 'Qual solução você construiria?', 'text', 19, true, $j$
{"blocks": [
  {"type": "texto_rico", "html": "<h3>Qual solução você construiria?</h3><p>Um cliente, três decisões. Responda na ordem.</p>"},
  {"type": "banner", "tone": "info", "text": "Cliente: “Estou treinando para uma meia maratona. Quero melhorar meu tempo, não sei muito bem o que fazer em cada dia e a prova tem bastante subida.”"},
  {"type": "cenario_escolha",
   "context": "Decisão 1",
   "prompt": "Qual necessidade aparece primeiro?",
   "options": [
     {"text": "Navegação", "correct": false, "feedback": "O cliente não falou de caminho. Ele disse que não sabe o que fazer em cada dia."},
     {"text": "Planejamento de treinamento", "correct": true, "feedback": "“Não sei muito bem o que fazer em cada dia” é uma necessidade de planejamento de treinamento."},
     {"text": "Garmin Pay", "correct": false, "feedback": "Nada na fala do cliente aponta para pagamento."}
   ]},
  {"type": "cenario_escolha",
   "context": "Decisão 2",
   "prompt": "Qual ferramenta pode ajudar com uma estratégia de ritmo para o percurso?",
   "options": [
     {"text": "PacePro", "correct": true, "feedback": "A prova tem bastante subida, e o PacePro distribui o ritmo-alvo considerando o perfil de elevação."},
     {"text": "Trajeto", "correct": false, "feedback": "O trajeto orienta o caminho, não o ritmo."},
     {"text": "Garmin Pay", "correct": false, "feedback": "Pagamento não tem relação com estratégia de ritmo."}
   ]},
  {"type": "cenario_escolha",
   "context": "Decisão 3",
   "prompt": "Se o cliente quiser seguir o percurso oficial da prova, qual recurso pode complementar a solução?",
   "options": [
     {"text": "Trajeto", "correct": true, "feedback": "Seguir um percurso definido é navegação, e o trajeto resolve isso em dispositivos compatíveis."},
     {"text": "Estamina", "correct": false, "feedback": "Estamina olha para a energia disponível durante a atividade, não para o caminho."},
     {"text": "Body Battery", "correct": false, "feedback": "Body Battery olha para a energia ao longo do dia, não para o caminho."}
   ]},
  {"type": "card_grid", "columns": 3, "items": [
    {"title": "Planejamento", "text": "Treinamento."},
    {"title": "Estratégia", "text": "PacePro."},
    {"title": "Navegação", "text": "Trajeto."}
  ]},
  {"type": "banner", "tone": "info", "text": "Esse cliente não precisa de uma lista de funções. Ele precisa de uma solução. O vendedor deve conectar cada ferramenta a uma necessidade real."},
  {"type": "texto_rico", "html": "<h3>Uma boa demonstração começa com uma necessidade</h3><p>O Garmin Connect oferece diferentes ferramentas para diferentes momentos do treinamento.</p><p>O vendedor não precisa mostrar todas. Precisa identificar qual problema o cliente quer resolver.</p><ul><li>Se ele quer controlar o ritmo: <strong>PacePro</strong>.</li><li>Se quer uma referência de tempo: <strong>Previsão de Corrida</strong>.</li><li>Se não sabe o que treinar: <strong>Treinos Sugeridos Diariamente</strong>.</li><li>Se quer montar uma sessão específica: <strong>Treino Estruturado</strong>.</li><li>Se precisa seguir um caminho: <strong>Trajeto</strong>.</li></ul>"},
  {"type": "banner", "tone": "success", "text": "<strong>“Conhecer as ferramentas é importante. Saber qual delas resolve o problema do cliente é o que transforma demonstração em venda.”</strong>"},
  {"type": "texto_rico", "html": "<h3>Glossário</h3>"},
  {"type": "accordion", "items": [
    {"title": "PacePro", "html": "<p>Estratégia de ritmo personalizada para um percurso.</p>"},
    {"title": "Previsão de Corrida", "html": "<p>Estimativa de tempo para diferentes distâncias de prova.</p>"},
    {"title": "Treinos Sugeridos Diariamente", "html": "<p>Recomendações automáticas de treinamento em dispositivos compatíveis.</p>"},
    {"title": "Garmin Coach", "html": "<p>Planos de treinamento estruturados para objetivos específicos.</p>"},
    {"title": "Treino Estruturado", "html": "<p>Sessão de treinamento criada pelo usuário com etapas e metas.</p>"},
    {"title": "Trajeto", "html": "<p>Percurso salvo para navegação.</p>"}
  ]}
]}
$j$::jsonb)

on conflict (id) do update
   set title        = excluded.title,
       order_index  = excluded.order_index,
       is_published = excluded.is_published,
       body         = excluded.body;

end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 169
-- ============================================================================
