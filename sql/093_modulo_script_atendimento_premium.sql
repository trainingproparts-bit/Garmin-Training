-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 093: novo módulo "Script de Atendimento
-- Garmin para Loja Premium" na Zona Explorador
-- ============================================================================
-- Pedido do usuário (2026-07-24): a Zona Explorador (onboarding) precisava de
-- um módulo dedicado a atendimento ao cliente, não só produto — abordagem,
-- sondagem por perfil, apresentação de valor e encantamento pós-venda.
-- Conteúdo revisado e aprovado pelo usuário no chat antes de aplicar (a
-- Lição 2 foi ampliada a pedido dele, com perguntas de sondagem separadas
-- por sinal de perfil do cliente: corrida, ciclismo, trilha/aventura,
-- natação/triathlon, saúde/bem-estar e indeciso).
--
-- Entra como 5º módulo da Zona Explorador (order_index 4, depois de
-- Concorrentes & Objeções), com quiz próprio de validação.
-- ============================================================================

do $$
declare
  v_zone_id      uuid := '9cfd688f-fcad-4a99-900d-9b6771068661'; -- Zona Explorador
  v_mod_id       uuid;
  v_quiz_id      uuid;
  v_q            uuid;
  v_next_order   integer;
begin
  insert into modules (zone_id, slug, title, summary, estimated_minutes, order_index, is_published)
  values (v_zone_id, 'script-atendimento-premium', 'Script de Atendimento Garmin para Loja Premium',
          'Abordagem, sondagem por perfil, apresentação de valor e encantamento pós-venda numa loja Garmin premium.',
          12, 4, true)
  returning id into v_mod_id;

  insert into lessons (module_id, title, content_type, order_index, is_published, body) values
  (v_mod_id, 'Abordagem: os primeiros 30 segundos', 'text', 0, true, $j${
    "blocks": [
      {"type": "texto_rico", "html": "<p>O que acontece antes de qualquer palavra sobre produto decide se o cliente vai se abrir ou se fechar. Loja premium tem um padrão de abordagem diferente de loja de departamento.</p>"},
      {"type": "banner", "tone": "warning", "text": "<strong>Evite:</strong><ul><li>\"Posso ajudar?\" (convida a um \"só olhando\" automático)</li><li>Abordar assim que o cliente entra pela porta</li><li>Ficar em pé olhando o cliente sem fazer nada até ele chamar</li></ul>"},
      {"type": "banner", "tone": "success", "text": "<strong>Faça:</strong><ul><li>Deixe o cliente circular 15 a 30 segundos antes de se aproximar</li><li>Observe pra onde o olhar dele vai primeiro, isso já é sondagem</li><li>Postura aberta, sem cruzar os braços, andando devagar até a distância certa</li></ul>"},
      {"type": "roteiro", "steps": [
        {"title": "Abertura por contexto, não pergunta fechada", "dialog": "Boa tarde! Essa linha aqui é a nossa Forerunner, focada em corrida. O senhor treina ou é mais pra uso do dia a dia?", "tip": "Nomear o produto que o cliente já está olhando mostra atenção, sem soar decorado."}
      ]}
    ]
  }$j$),
  (v_mod_id, 'Sondagem: descobrindo a necessidade real', 'text', 1, true, $j${
    "blocks": [
      {"type": "texto_rico", "html": "<p>Ninguém compra um relógio Garmin. Compra o que o relógio resolve: motivação pra treinar, segurança numa trilha, controle de uma condição de saúde, ou simplesmente status. A pergunta certa muda dependendo do sinal que o cliente já deu.</p>"},
      {"type": "banner", "tone": "info", "text": "<strong>Pergunta de abertura, sempre a mesma primeiro:</strong> \"O que te fez vir procurar um Garmin hoje?\""},
      {"type": "texto_rico", "html": "<p>A partir da resposta (ou se ela vier vaga), aprofunde por perfil:</p>"},
      {"type": "accordion", "items": [
        {"title": "Se ele mencionar corrida ou já estar treinando", "html": "<p>\"Você corre mais por saúde ou já tem prova marcada?\"<br>\"Hoje você usa o quê pra acompanhar o treino, aplicativo do celular ou nada?\"<br>\"Já correu alguma distância maior, tipo 10K ou meia?\"</p>"},
        {"title": "Se mencionar ciclismo", "html": "<p>\"Pedala mais na rua, na estrada ou também mountain bike?\"<br>\"Já usa medidor de potência ou é a primeira vez pensando nisso?\"</p>"},
        {"title": "Se mencionar trilha, montanha ou aventura", "html": "<p>\"As trilhas que você faz têm sinal de celular ou costuma ficar isolado?\"<br>\"Costuma sair sozinho ou sempre em grupo?\"</p>"},
        {"title": "Se mencionar natação ou triathlon", "html": "<p>\"Já compete em provas de triathlon ou é só treino mesmo?\"<br>\"Prefere piscina, mar aberto, ou os dois?\"</p>"},
        {"title": "Se o foco parecer mais saúde/bem-estar do que performance", "html": "<p>\"É mais pra acompanhar sono, estresse e rotina do dia a dia?\"<br>\"Alguma recomendação médica te trouxe até aqui, tipo monitorar frequência cardíaca?\"</p>"},
        {"title": "Se parecer indeciso ou só \"olhando\"", "html": "<p>\"Já usa algum relógio inteligente hoje, ou seria o primeiro?\"<br>\"É pra você ou é um presente?\"</p>"}
      ]},
      {"type": "texto_rico", "html": "<p>Depois de qualquer resposta, confirme antes de seguir: \"Então o foco principal é corrida de rua, e você já correu uma meia, é isso?\", isso mostra atenção real, não só coleta de dados pra empurrar produto. Escute mais do que fala: se o vendedor falou mais que o cliente nos primeiros 2 minutos, a sondagem falhou.</p>"}
    ]
  }$j$),
  (v_mod_id, 'Apresentação de valor: do produto pra experiência', 'text', 2, true, $j${
    "blocks": [
      {"type": "texto_rico", "html": "<p>Especificação técnica sozinha não vende. GPS multibanda sozinho não vende. \"Você vai correr no meio dos prédios do centro e o relógio não vai perder o sinal, mesmo debaixo da marquise\" vende.</p>"},
      {"type": "tabela", "headers": ["Recurso", "Benefício pro cliente"], "rows": [
        ["Bateria de 11 dias", "Nunca esquece de carregar antes de um treino"],
        ["GPS multibanda", "Rota certa mesmo em rua estreita ou mata fechada"],
        ["Training Readiness", "Sabe se hoje é dia de treinar forte ou descansar"]
      ]},
      {"type": "texto_rico", "html": "<p><strong>Deixe o cliente experimentar.</strong> Coloque o relógio no pulso dele, mostre a tela ligada, deixe folhear os mostradores. Ninguém compra o que só viu numa vitrine.</p><p><strong>Conte uma situação real</strong> (sem inventar depoimento de cliente específico, mas com um cenário plausível): \"Muita gente que treina pra prova comenta que o alerta de recuperação evita treinar demais na última semana antes da corrida.\"</p>"}
    ]
  }$j$),
  (v_mod_id, 'Encantamento: a experiência que fideliza', 'text', 3, true, $j${
    "blocks": [
      {"type": "texto_rico", "html": "<p>Fechar a venda é o meio, não o fim. Loja premium se diferencia depois que o cartão já passou.</p>"},
      {"type": "card_grid", "columns": 2, "items": [
        {"title": "Explique a caixa antes do cliente sair", "text": "O que vem na caixa e como ativar o relógio, não deixe ele decifrar sozinho em casa.", "tags": []},
        {"title": "Configure o Garmin Connect ali mesmo", "text": "Se der tempo, ofereça ajudar a configurar o app na hora.", "tags": []},
        {"title": "Garantia e suporte de forma clara", "text": "Sem parecer script decorado, explique o canal de suporte.", "tags": []},
        {"title": "Reforce o motivo de cada acessório", "text": "Se o cliente levou pulseira ou cinta HRM junto, relembre por que fez sentido pro perfil dele.", "tags": []}
      ]},
      {"type": "roteiro", "steps": [
        {"title": "Despedida que convida a voltar", "dialog": "Qualquer dúvida configurando, pode voltar aqui que a gente ajuda, viu?", "tip": "Deixa a porta aberta pra pós-venda, indicação e próxima compra, bem melhor que só \"obrigado, volte sempre\"."}
      ]}
    ]
  }$j$);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values ('2f7d8451-b279-4d69-8192-6ac9953d7da1', 'quiz-script-atendimento-premium', 'Quiz: Script de Atendimento Premium', 70, true)
  returning id into v_quiz_id;

  insert into questions (quiz_id, body, explanation, order_index) values
  (v_quiz_id, 'Por que "Posso ajudar?" não é a melhor abertura de abordagem?', 'Essa pergunta convida a um "só olhando" automático, fechando a conversa em vez de abrir.', 0) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
  (v_q, 'Convida a um "só olhando" automático', true, 0),
  (v_q, 'É uma frase malvista pela Garmin', false, 1),
  (v_q, 'Só funciona em loja de departamento', false, 2),
  (v_q, 'É longa demais pra dizer rápido', false, 3);

  insert into questions (quiz_id, body, explanation, order_index) values
  (v_quiz_id, 'Quanto tempo é recomendado deixar o cliente circular antes de abordar?', 'O texto recomenda 15 a 30 segundos antes da abordagem.', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
  (v_q, '15 a 30 segundos', true, 0),
  (v_q, 'Imediatamente ao entrar', false, 1),
  (v_q, '5 minutos', false, 2),
  (v_q, 'Só depois que ele chamar', false, 3);

  insert into questions (quiz_id, body, explanation, order_index) values
  (v_quiz_id, 'Qual é a pergunta de abertura padrão da sondagem?', 'A pergunta de abertura padrão é "O que te fez vir procurar um Garmin hoje?"', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
  (v_q, '"O que te fez vir procurar um Garmin hoje?"', true, 0),
  (v_q, '"Qual o seu orçamento?"', false, 1),
  (v_q, '"Você já é cliente Garmin?"', false, 2),
  (v_q, '"Vai levar à vista ou parcelado?"', false, 3);

  insert into questions (quiz_id, body, explanation, order_index) values
  (v_quiz_id, 'Se o vendedor fala mais que o cliente nos primeiros 2 minutos, o que isso indica?', 'A sondagem falhou; o objetivo é o cliente falar mais, revelando a necessidade real.', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
  (v_q, 'Que a sondagem falhou', true, 0),
  (v_q, 'Que o vendedor está indo bem', false, 1),
  (v_q, 'Que o cliente está desinteressado', false, 2),
  (v_q, 'Não indica nada específico', false, 3);

  insert into questions (quiz_id, body, explanation, order_index) values
  (v_quiz_id, 'Qual pergunta de sondagem é mais adequada se o cliente mencionar trilha ou aventura?', 'Perguntar sobre sinal de celular na trilha e se costuma ir sozinho ajuda a entender o perfil de segurança do cliente.', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
  (v_q, 'Se as trilhas têm sinal de celular e se costuma ir sozinho', true, 0),
  (v_q, 'Se já compete em provas de triathlon', false, 1),
  (v_q, 'Se pedala na rua ou na estrada', false, 2),
  (v_q, 'Se é a primeira vez usando medidor de potência', false, 3);

  insert into questions (quiz_id, body, explanation, order_index) values
  (v_quiz_id, 'Qual a diferença entre citar um recurso técnico e apresentar valor?', 'Apresentar valor é traduzir o recurso pro que o cliente ganha na prática, não só listar a especificação.', 5) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
  (v_q, 'Valor traduz o recurso pro benefício prático que o cliente ganha', true, 0),
  (v_q, 'Não existe diferença real entre os dois', false, 1),
  (v_q, 'Recurso técnico sempre convence mais que benefício', false, 2),
  (v_q, 'Valor só importa pra cliente que já entende de tecnologia', false, 3);

  insert into questions (quiz_id, body, explanation, order_index) values
  (v_quiz_id, 'O que fazer antes do cliente sair da loja com o relógio novo?', 'Explicar o que vem na caixa e como ativar o relógio, sem deixar o cliente decifrar sozinho em casa.', 6) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
  (v_q, 'Explicar o que vem na caixa e como ativar o relógio', true, 0),
  (v_q, 'Nada, o manual já explica tudo', false, 1),
  (v_q, 'Só entregar a nota fiscal', false, 2),
  (v_q, 'Pedir pra ele ler o site da Garmin em casa', false, 3);

  insert into questions (quiz_id, body, explanation, order_index) values
  (v_quiz_id, 'Por que deixar o cliente experimentar o relógio no pulso é importante?', 'Porque ninguém compra o que só viu numa vitrine; a experiência prática ajuda a fechar a venda.', 7) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
  (v_q, 'Porque ninguém compra o que só viu numa vitrine', true, 0),
  (v_q, 'Porque é obrigatório por política da loja', false, 1),
  (v_q, 'Porque ativa a garantia automaticamente', false, 2),
  (v_q, 'Não faz diferença real na venda', false, 3);

  -- Encadeia módulo + quiz como checkpoints da Zona Explorador, na sequência
  select coalesce(max(order_index), -1) + 1 into v_next_order from checkpoints where zone_id = v_zone_id;

  insert into checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required) values
  (v_zone_id, 'module', v_mod_id, v_next_order, true),
  (v_zone_id, 'quiz', v_quiz_id, v_next_order + 1, true);
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 093
-- ============================================================================
