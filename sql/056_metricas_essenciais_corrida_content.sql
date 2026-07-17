-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 056: conteúdo completo do Módulo 4
-- "Métricas Essenciais de Corrida" (Zona Atleta, Certificação 2)
-- ============================================================================
-- Único módulo com conteúdo REAL entre os criados em sql/055 — os outros 18
-- continuam "prateleira vazia". Usa os 2 tipos de bloco novos adicionados em
-- ContentBlocks.js: metric_card_grid (card curto+expansível por métrica) e
-- match_quiz (aquecimento de associação por clique, sem drag-and-drop — ver
-- comentário no topo do arquivo, decisão de arquitetura já tomada antes).
-- Dicionário Rápido usa o bloco "tabela" já existente (2 colunas encaixam
-- perfeitamente). Comparativo Estamina×Recuperação é HTML self-contido
-- dentro de um texto_rico (não justificava um tipo de bloco novo só pra isso).
-- ============================================================================

update public.modules
   set summary = 'As métricas que aparecem na tela do relógio durante e depois da corrida, e como explicar cada uma para o cliente de forma simples.'
 where slug = 'metricas-essenciais-corrida';

do $$
declare
  v_module_id uuid := 'd35b508e-2caa-49ed-b2ed-62bdc5bfd607';
  v_quiz_id   uuid := '032d0cd4-dc60-4c7d-b0eb-6d103883636f';
  v_q_id      uuid;
begin
  -- ==========================================================================
  -- Lição 1: Pace, cadência e distância
  -- ==========================================================================
  insert into public.lessons (module_id, title, content_type, body, order_index, is_published)
  values (
    v_module_id, 'Pace, cadência e distância', 'text',
    jsonb_build_object('blocks', jsonb_build_array(
      jsonb_build_object(
        'type', 'texto_rico',
        'html', '<p>O pace mostra o ritmo da corrida em minutos por quilômetro e é a métrica que a maioria dos corredores já conhece, mesmo vindo de um app de celular. A cadência mede quantas passadas o corredor dá por minuto e ajuda a identificar padrões de corrida mais eficientes ao longo do tempo. A distância é calculada pelo GPS do próprio relógio, o que garante uma leitura confiável mesmo em locais onde o sinal do celular costuma falhar, como ruas com prédios altos ou trechos de mata.</p>'
      ),
      jsonb_build_object(
        'type', 'metric_card_grid', 'columns', 3,
        'items', jsonb_build_array(
          jsonb_build_object('icon', '🏃', 'name', 'Pace', 'definition', 'Ritmo da corrida em minutos por quilômetro — a métrica mais familiar ao cliente.', 'tip', 'É a métrica que o cliente já espera ver — comece a demonstração por ela.'),
          jsonb_build_object('icon', '👣', 'name', 'Cadência', 'definition', 'Passadas por minuto — indicador de eficiência de corrida.', 'tip', 'Use pra mostrar evolução técnica ao longo do tempo, não só no dia do treino.'),
          jsonb_build_object('icon', '📍', 'name', 'Distância (GPS)', 'definition', 'Medição via GPS dedicado do relógio, mais confiável que o do celular em áreas com sinal fraco.', 'tip', 'Destaque isso pra quem já reclamou que o GPS do celular "perdeu o sinal" correndo na cidade.')
        )
      )
    )),
    0, true
  );

  -- ==========================================================================
  -- Lição 2: VO2 máximo
  -- ==========================================================================
  insert into public.lessons (module_id, title, content_type, body, order_index, is_published)
  values (
    v_module_id, 'VO2 máximo', 'text',
    jsonb_build_object('blocks', jsonb_build_array(
      jsonb_build_object(
        'type', 'texto_rico',
        'html', '<p>O VO2 máximo é o volume máximo de oxigênio que o corpo consegue consumir por minuto, por quilograma de peso corporal, durante o esforço máximo. O relógio estima esse valor combinando frequência cardíaca e ritmo de corrida ao longo de várias atividades, sem precisar de um teste de laboratório. Essa estimativa é fornecida pela tecnologia Firstbeat Analytics, parceira da Garmin nesse tipo de métrica, e tende a ficar mais precisa conforme o relógio acumula mais atividades do usuário.</p>'
      ),
      jsonb_build_object(
        'type', 'metric_card_grid', 'columns', 2,
        'items', jsonb_build_array(
          jsonb_build_object('icon', '🫁', 'name', 'VO2 Máx', 'definition', 'Volume máximo de oxigênio consumido por minuto/kg no esforço máximo, estimado via Firstbeat Analytics.', 'tip', 'Explique que é uma estimativa, não um exame de laboratório — e melhora com o uso.')
        )
      )
    )),
    1, true
  );

  -- ==========================================================================
  -- Lição 3: Tempo de recuperação
  -- ==========================================================================
  insert into public.lessons (module_id, title, content_type, body, order_index, is_published)
  values (
    v_module_id, 'Tempo de recuperação', 'text',
    jsonb_build_object('blocks', jsonb_build_array(
      jsonb_build_object(
        'type', 'texto_rico',
        'html', '<p>Depois de cada atividade, o relógio recomenda quanto tempo o corpo precisa descansar antes do próximo treino de alta intensidade. Esse cálculo também usa a estimativa de VO2 máximo, junto com a intensidade e duração do esforço realizado. É uma forma prática do cliente entender por que às vezes o relógio sugere um dia de descanso mesmo quando ele se sente disposto a treinar.</p>'
      ),
      jsonb_build_object(
        'type', 'metric_card_grid', 'columns', 2,
        'items', jsonb_build_array(
          jsonb_build_object('icon', '😴', 'name', 'Tempo de Recuperação', 'definition', 'Quanto o corpo precisa descansar após o esforço, calculado com base em intensidade e duração.', 'tip', 'Use pra justificar por que o relógio "manda descansar" mesmo quando o cliente se sente bem.')
        )
      )
    )),
    2, true
  );

  -- ==========================================================================
  -- Lição 4 (explicação extra): Estamina em tempo real
  -- ==========================================================================
  insert into public.lessons (module_id, title, content_type, body, order_index, is_published)
  values (
    v_module_id, 'Estamina em tempo real', 'text',
    jsonb_build_object('blocks', jsonb_build_array(
      jsonb_build_object(
        'type', 'texto_rico',
        'html', '<p>A estamina em tempo real mostra, em porcentagem, quanto o corredor ainda tem de reserva de energia para manter um bom desempenho durante a atividade. O cálculo usa a estimativa de VO2 máximo junto com a frequência cardíaca e o histórico de treinos recente, incluindo duração, distância percorrida e carga acumulada de treinamento.</p><p>Quanto mais forte o esforço, mais rápido a estamina é consumida. Em provas longas, esse dado ajuda o corredor a dosar o ritmo: se a estamina está caindo rápido demais no início do percurso, é sinal de que o esforço está acima do que o corpo consegue sustentar até o final. O relógio também estima o tempo e a distância restantes até o momento de exaustão, atualizando esses números continuamente conforme a corrida avança.</p>'
      ),
      jsonb_build_object(
        'type', 'metric_card_grid', 'columns', 2,
        'items', jsonb_build_array(
          jsonb_build_object('icon', '🔋', 'name', 'Estamina em Tempo Real', 'definition', 'Percentual (0-100%) de reserva de energia disponível durante a atividade — cai mais rápido quanto mais forte o esforço.', 'tip', 'Foco em quem corre prova longa — mostra como não "estourar" antes da chegada.')
        )
      ),
      jsonb_build_object(
        'type', 'texto_rico',
        'html', '<div style="margin:16px 0;padding:16px;background:var(--off);border-radius:var(--r4);border:1px solid var(--border);"><p style="margin:0 0 12px;font-size:13px;font-weight:700;color:var(--text);">⚖️ Estamina vs. Tempo de Recuperação — não confunda os dois</p><div style="margin-bottom:14px;"><div style="display:flex;justify-content:space-between;font-size:12px;color:var(--text2);margin-bottom:4px;"><span>🔋 Estamina em Tempo Real</span><span>65%</span></div><div style="height:10px;border-radius:999px;background:var(--border);overflow:hidden;"><div style="height:100%;width:65%;background:var(--acc);border-radius:999px;"></div></div><p style="margin:4px 0 0;font-size:11.5px;color:var(--text3);">Energia disponível AGORA, durante a atividade — cai conforme você se esforça.</p></div><div><div style="display:flex;justify-content:space-between;font-size:12px;color:var(--text2);margin-bottom:4px;"><span>😴 Tempo de Recuperação</span><span>18h</span></div><div style="height:10px;border-radius:999px;background:var(--border);overflow:hidden;"><div style="height:100%;width:40%;background:var(--gold);border-radius:999px;"></div></div><p style="margin:4px 0 0;font-size:11.5px;color:var(--text3);">Descanso necessário DEPOIS do treino — quanto maior a barra, mais tempo o corpo pede pra se recuperar.</p></div><p style="margin:12px 0 0;font-size:11px;color:var(--text3);font-style:italic;">Valores ilustrativos, só para mostrar a diferença entre as duas métricas.</p></div>'
      )
    )),
    3, true
  );

  -- ==========================================================================
  -- Lição 5 (explicação extra): Economia de corrida + Métricas Avançadas +
  -- Dicionário Rápido + aquecimento de associação
  -- ==========================================================================
  insert into public.lessons (module_id, title, content_type, body, order_index, is_published)
  values (
    v_module_id, 'Economia de corrida', 'text',
    jsonb_build_object('blocks', jsonb_build_array(
      jsonb_build_object(
        'type', 'texto_rico',
        'html', '<p>A economia de corrida indica a eficiência do corredor, medida em mililitros de oxigênio consumidos por quilograma de peso corporal a cada quilômetro percorrido. Quanto menor o número, mais eficiente é a técnica de corrida, já que o corpo está gastando menos energia para manter o mesmo ritmo.</p><p>Esse dado é calculado a partir da frequência cardíaca, da oscilação vertical e de outras métricas de dinâmica de corrida durante a atividade, e por isso funciona melhor com o uso de uma cinta de frequência cardíaca no peito. É um dos recursos mais recentes na linha de corrida da Garmin, disponível a partir do Forerunner 970, e pode ser consultado tanto no relógio quanto no aplicativo Garmin Connect, na seção de estatísticas de desempenho.</p>'
      ),
      jsonb_build_object('type', 'banner', 'tone', 'info', 'text', '⚙️ Métricas Avançadas — Forerunner 970 + HRM 600. As duas métricas abaixo compartilham o mesmo requisito de hardware — um combo natural de venda (relógio + cinta).'),
      jsonb_build_object(
        'type', 'metric_card_grid', 'columns', 2,
        'items', jsonb_build_array(
          jsonb_build_object('icon', '⚡', 'name', 'Economia de Corrida', 'definition', 'Eficiência medida em ml de oxigênio/kg/km — quanto menor, mais eficiente.', 'tip', 'Só funciona com a cinta HRM 600 — ótimo gancho pra vender relógio + acessório juntos.', 'badge', 'Requer HRM 600'),
          jsonb_build_object('icon', '📉', 'name', 'SSL (Perda de Velocidade de Passo)', 'definition', 'Mede em cm/s a queda de velocidade da passada — quanto menor, mais eficiente a técnica. Também existe em % (SSL%).', 'tip', 'Métrica avançada, mesmo requisito da Economia de Corrida — parte do mesmo combo de venda técnica.', 'badge', 'Requer HRM 600')
        )
      ),
      jsonb_build_object(
        'type', 'tabela',
        'headers', jsonb_build_array('Termo', 'Definição'),
        'rows', jsonb_build_array(
          jsonb_build_array('Cadência', 'Passadas por minuto durante a corrida; indica eficiência do movimento.'),
          jsonb_build_array('Distância (GPS)', 'Medição via GPS dedicado do relógio, mais confiável que o do celular em áreas de sinal fraco.'),
          jsonb_build_array('Economia de Corrida', 'Eficiência medida em ml de oxigênio/kg a cada km percorrido; quanto menor, mais eficiente.'),
          jsonb_build_array('Estamina em Tempo Real', 'Percentual (0-100%) de reserva de energia disponível durante a atividade.'),
          jsonb_build_array('Pace', 'Ritmo da corrida em minutos por quilômetro.'),
          jsonb_build_array('SSL (Perda de Velocidade de Passo)', 'Mede a queda de velocidade da passada em cm/s; quanto menor, mais eficiente é a técnica de corrida.'),
          jsonb_build_array('Tempo de Recuperação', 'Tempo que o corpo precisa descansar após o esforço, com base na intensidade e duração do treino.'),
          jsonb_build_array('VO2 Máx', 'Volume máximo de oxigênio que o corpo consome por minuto, por kg de peso, no esforço máximo.')
        )
      ),
      jsonb_build_object(
        'type', 'match_quiz',
        'pairs', jsonb_build_array(
          jsonb_build_object('term', 'Pace', 'definition', 'Ritmo em minutos por quilômetro'),
          jsonb_build_object('term', 'Cadência', 'definition', 'Passadas por minuto'),
          jsonb_build_object('term', 'Distância (GPS)', 'definition', 'Medição via GPS dedicado do relógio'),
          jsonb_build_object('term', 'VO2 Máx', 'definition', 'Consumo máximo de oxigênio por minuto/kg'),
          jsonb_build_object('term', 'Tempo de Recuperação', 'definition', 'Descanso necessário após o esforço'),
          jsonb_build_object('term', 'Estamina em Tempo Real', 'definition', 'Reserva de energia disponível agora, em %'),
          jsonb_build_object('term', 'Economia de Corrida', 'definition', 'Eficiência em ml de O2/kg/km'),
          jsonb_build_object('term', 'SSL', 'definition', 'Perda de velocidade de passo, em cm/s')
        )
      )
    )),
    4, true
  );

  -- ==========================================================================
  -- Quiz do módulo (9 perguntas — 6 técnicas incluindo SSL + 3 de atendimento)
  -- ==========================================================================

  insert into public.questions (quiz_id, body, explanation, order_index, is_active)
  values (v_quiz_id, 'O que a métrica de cadência mede durante a corrida?', 'Cadência é o número de passadas por minuto — um indicador de eficiência do movimento.', 0, true)
  returning id into v_q_id;
  insert into public.alternatives (question_id, body, is_correct, order_index) values
    (v_q_id, 'A distância total percorrida', false, 0),
    (v_q_id, 'O número de passadas por minuto', true, 1),
    (v_q_id, 'O consumo de oxigênio por quilômetro', false, 2),
    (v_q_id, 'O tempo estimado de recuperação', false, 3);

  insert into public.questions (quiz_id, body, explanation, order_index, is_active)
  values (v_quiz_id, 'Como o relógio calcula a estimativa de VO2 máximo?', 'O relógio combina frequência cardíaca e ritmo de corrida ao longo de várias atividades, via Firstbeat Analytics, sem precisar de teste de laboratório.', 1, true)
  returning id into v_q_id;
  insert into public.alternatives (question_id, body, is_correct, order_index) values
    (v_q_id, 'Usando apenas a distância percorrida', false, 0),
    (v_q_id, 'Combinando frequência cardíaca e ritmo de corrida ao longo de várias atividades', true, 1),
    (v_q_id, 'Perguntando a idade do usuário no aplicativo', false, 2),
    (v_q_id, 'Medindo a temperatura da pele durante o esforço', false, 3);

  insert into public.questions (quiz_id, body, explanation, order_index, is_active)
  values (v_quiz_id, 'O que a estamina em tempo real (0 a 100%) representa durante uma corrida?', 'A estamina mostra, em porcentagem, quanto o corredor ainda tem de reserva de energia para manter um bom desempenho.', 2, true)
  returning id into v_q_id;
  insert into public.alternatives (question_id, body, is_correct, order_index) values
    (v_q_id, 'O ritmo médio da corrida até o momento', false, 0),
    (v_q_id, 'Quanto o corredor ainda tem de reserva de energia para manter um bom desempenho', true, 1),
    (v_q_id, 'A quantidade de calorias já queimadas', false, 2),
    (v_q_id, 'A distância que falta para o final da prova', false, 3);

  insert into public.questions (quiz_id, body, explanation, order_index, is_active)
  values (v_quiz_id, 'O que significa um número mais baixo na economia de corrida?', 'Um número menor significa que o corredor gasta menos energia para manter o mesmo ritmo — ou seja, é mais eficiente.', 3, true)
  returning id into v_q_id;
  insert into public.alternatives (question_id, body, is_correct, order_index) values
    (v_q_id, 'O corredor está correndo mais devagar', false, 0),
    (v_q_id, 'O corredor está gastando menos energia para manter o mesmo ritmo, ou seja, é mais eficiente', true, 1),
    (v_q_id, 'O relógio está com pouca bateria', false, 2),
    (v_q_id, 'A frequência cardíaca está muito alta', false, 3);

  insert into public.questions (quiz_id, body, explanation, order_index, is_active)
  values (v_quiz_id, 'Por que a economia de corrida funciona melhor com uma cinta de frequência cardíaca no peito?', 'O cálculo usa frequência cardíaca, oscilação vertical e outras métricas de dinâmica de corrida — dados mais precisos com a cinta.', 4, true)
  returning id into v_q_id;
  insert into public.alternatives (question_id, body, is_correct, order_index) values
    (v_q_id, 'Porque a cinta calcula a distância com mais precisão', false, 0),
    (v_q_id, 'Porque o cálculo usa frequência cardíaca, oscilação vertical e outras métricas de dinâmica de corrida', true, 1),
    (v_q_id, 'Porque o sensor óptico de pulso não funciona durante a corrida', false, 2),
    (v_q_id, 'Porque a cinta substitui o GPS do relógio', false, 3);

  insert into public.questions (quiz_id, body, explanation, order_index, is_active)
  values (v_quiz_id, 'O que a métrica de Perda de Velocidade de Passo (SSL) mede?', 'SSL mede, em cm/s, a diferença entre a velocidade de avanço no toque do pé no solo e a velocidade mínima de avanço durante a passada.', 5, true)
  returning id into v_q_id;
  insert into public.alternatives (question_id, body, is_correct, order_index) values
    (v_q_id, 'O tempo total de recuperação após o treino', false, 0),
    (v_q_id, 'A diferença entre a velocidade de avanço no toque do pé e a velocidade mínima durante a passada', true, 1),
    (v_q_id, 'A distância total percorrida na atividade', false, 2),
    (v_q_id, 'A frequência cardíaca máxima atingida', false, 3);

  insert into public.questions (quiz_id, body, explanation, order_index, is_active)
  values (v_quiz_id, 'Um cliente pergunta por que o relógio sugeriu um dia de descanso mesmo ele se sentindo bem disposto. Qual é a melhor forma de explicar?', 'O tempo de recuperação é calculado com base na intensidade e duração do treino anterior, independente de como o cliente se sente no momento.', 6, true)
  returning id into v_q_id;
  insert into public.alternatives (question_id, body, is_correct, order_index) values
    (v_q_id, 'Dizer que é só uma sugestão genérica e pode ser ignorada sem problema', false, 0),
    (v_q_id, 'Explicar que o tempo de recuperação é calculado com base na intensidade e duração do treino anterior, mesmo que o cliente não sinta cansaço aparente', true, 1),
    (v_q_id, 'Sugerir que ele desligue essa função do relógio', false, 2),
    (v_q_id, 'Afirmar que o relógio está com defeito', false, 3);

  insert into public.questions (quiz_id, body, explanation, order_index, is_active)
  values (v_quiz_id, 'Um cliente corredor de prova longa (maratona) está decidindo entre um modelo básico e um com estamina em tempo real. Qual argumento é mais relevante para esse perfil?', 'O modelo com estamina ajuda a dosar o ritmo ao longo da prova, evitando que o corredor "estoure" antes do final.', 7, true)
  returning id into v_q_id;
  insert into public.alternatives (question_id, body, is_correct, order_index) values
    (v_q_id, 'O modelo com estamina ajuda a dosar o ritmo ao longo da prova, evitando que ele "estoure" antes do final', true, 0),
    (v_q_id, 'O modelo com estamina tem uma tela maior', false, 1),
    (v_q_id, 'Ambos os modelos são idênticos, a diferença é só estética', false, 2),
    (v_q_id, 'O modelo básico é sempre melhor por ser mais simples de usar', false, 3);

  insert into public.questions (quiz_id, body, explanation, order_index, is_active)
  values (v_quiz_id, 'Um cliente pergunta se realmente precisa de uma cinta de frequência cardíaca, já que o relógio mede pelo pulso. Qual resposta é mais adequada?', 'O sensor de pulso funciona bem no geral, mas a cinta é necessária para métricas específicas como a economia de corrida e a SSL.', 8, true)
  returning id into v_q_id;
  insert into public.alternatives (question_id, body, is_correct, order_index) values
    (v_q_id, 'Dizer que a cinta é obrigatória para qualquer uso do relógio', false, 0),
    (v_q_id, 'Explicar que o sensor de pulso funciona bem no geral, mas a cinta é necessária para métricas específicas como a economia de corrida', true, 1),
    (v_q_id, 'Afirmar que o sensor de pulso não funciona para nenhuma métrica', false, 2),
    (v_q_id, 'Recomendar que ele não use nenhum sensor de frequência cardíaca', false, 3);

end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 056
-- ============================================================================
