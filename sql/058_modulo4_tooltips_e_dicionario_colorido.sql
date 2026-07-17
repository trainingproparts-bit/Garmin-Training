-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 058: tooltips de termo técnico + Dicionário
-- Rápido colorido no Módulo 4 "Métricas Essenciais de Corrida" (sql/056)
-- ============================================================================
-- Fecha os 2 itens do checklist do usuário que sql/056 realmente deixou de
-- fora (os outros 3 — cards expansíveis, quiz de associação, comparativo
-- Estamina×Recuperação — já estavam implementados e verificados ao vivo):
--   1) Dicionário Rápido "todo cinza/preto" -> vira colorido (block.colorful,
--      ver ContentBlocks.js renderTabelaBlock) e ganha 3 termos de apoio que
--      apareciam no texto mas não estavam listados (Firstbeat Analytics,
--      HRM 600, Oscilação Vertical) — "TODOS os termos técnicos", não só as
--      métricas.
--   2) Tooltip em termo técnico fora dos cards — <span class="term-tip"
--      data-tip="...">termo</span>, renderizado como HTML de verdade tanto
--      em texto_rico (ContentBlocks.js) quanto no enunciado de questão
--      (QuizRunner.js usa innerHTML pro body da pergunta, então o span
--      funciona igual nos dois lugares). CSS + wireTermTips (hover/click)
--      já adicionados em contentBlocks.css/ContentBlocks.js/QuizRunner.js.
-- Só a 1ª menção de cada termo por parágrafo ganhou tooltip (evita poluir o
-- texto com sublinhado pontilhado repetido); os "toques práticos" dentro dos
-- próprios cards de métrica não mudam (o pedido era tooltip FORA dos cards).
-- ============================================================================

do $$
declare
  v_module_id uuid := 'd35b508e-2caa-49ed-b2ed-62bdc5bfd607';
  v_quiz_id   uuid := '032d0cd4-dc60-4c7d-b0eb-6d103883636f';
begin
  -- ==========================================================================
  -- Lição 1 (order_index 0): Pace, cadência e distância
  -- ==========================================================================
  update public.lessons
     set body = jsonb_build_object('blocks', jsonb_build_array(
      jsonb_build_object(
        'type', 'texto_rico',
        'html', '<p>O <span class="term-tip" tabindex="0" data-tip="Ritmo da corrida em minutos por quilômetro.">pace</span> mostra o ritmo da corrida em minutos por quilômetro e é a métrica que a maioria dos corredores já conhece, mesmo vindo de um app de celular. A <span class="term-tip" tabindex="0" data-tip="Passadas por minuto durante a corrida; indica eficiência do movimento.">cadência</span> mede quantas passadas o corredor dá por minuto e ajuda a identificar padrões de corrida mais eficientes ao longo do tempo. A <span class="term-tip" tabindex="0" data-tip="Medição via GPS dedicado do relógio, mais confiável que o do celular em áreas de sinal fraco.">distância</span> é calculada pelo GPS do próprio relógio, o que garante uma leitura confiável mesmo em locais onde o sinal do celular costuma falhar, como ruas com prédios altos ou trechos de mata.</p>'
      ),
      jsonb_build_object(
        'type', 'metric_card_grid', 'columns', 3,
        'items', jsonb_build_array(
          jsonb_build_object('icon', '🏃', 'name', 'Pace', 'definition', 'Ritmo da corrida em minutos por quilômetro — a métrica mais familiar ao cliente.', 'tip', 'É a métrica que o cliente já espera ver — comece a demonstração por ela.'),
          jsonb_build_object('icon', '👣', 'name', 'Cadência', 'definition', 'Passadas por minuto — indicador de eficiência de corrida.', 'tip', 'Use pra mostrar evolução técnica ao longo do tempo, não só no dia do treino.'),
          jsonb_build_object('icon', '📍', 'name', 'Distância (GPS)', 'definition', 'Medição via GPS dedicado do relógio, mais confiável que o do celular em áreas com sinal fraco.', 'tip', 'Destaque isso pra quem já reclamou que o GPS do celular "perdeu o sinal" correndo na cidade.')
        )
      )
    ))
   where module_id = v_module_id and order_index = 0;

  -- ==========================================================================
  -- Lição 2 (order_index 1): VO2 máximo
  -- ==========================================================================
  update public.lessons
     set body = jsonb_build_object('blocks', jsonb_build_array(
      jsonb_build_object(
        'type', 'texto_rico',
        'html', '<p>O <span class="term-tip" tabindex="0" data-tip="Volume máximo de oxigênio que o corpo consome por minuto, por kg de peso, no esforço máximo.">VO2 máximo</span> é o volume máximo de oxigênio que o corpo consegue consumir por minuto, por quilograma de peso corporal, durante o esforço máximo. O relógio estima esse valor combinando frequência cardíaca e ritmo de corrida ao longo de várias atividades, sem precisar de um teste de laboratório. Essa estimativa é fornecida pela tecnologia <span class="term-tip" tabindex="0" data-tip="Tecnologia parceira da Garmin usada para estimar métricas fisiológicas como VO2 Máx e Tempo de Recuperação.">Firstbeat Analytics</span>, parceira da Garmin nesse tipo de métrica, e tende a ficar mais precisa conforme o relógio acumula mais atividades do usuário.</p>'
      ),
      jsonb_build_object(
        'type', 'metric_card_grid', 'columns', 2,
        'items', jsonb_build_array(
          jsonb_build_object('icon', '🫁', 'name', 'VO2 Máx', 'definition', 'Volume máximo de oxigênio consumido por minuto/kg no esforço máximo, estimado via Firstbeat Analytics.', 'tip', 'Explique que é uma estimativa, não um exame de laboratório — e melhora com o uso.')
        )
      )
    ))
   where module_id = v_module_id and order_index = 1;

  -- ==========================================================================
  -- Lição 3 (order_index 2): Tempo de recuperação
  -- ==========================================================================
  update public.lessons
     set body = jsonb_build_object('blocks', jsonb_build_array(
      jsonb_build_object(
        'type', 'texto_rico',
        'html', '<p>Depois de cada atividade, o relógio recomenda quanto tempo o corpo precisa descansar antes do próximo treino de alta intensidade. Esse cálculo também usa a estimativa de <span class="term-tip" tabindex="0" data-tip="Volume máximo de oxigênio que o corpo consome por minuto, por kg de peso, no esforço máximo.">VO2 máximo</span>, junto com a intensidade e duração do esforço realizado. É uma forma prática do cliente entender por que às vezes o relógio sugere um dia de descanso mesmo quando ele se sente disposto a treinar.</p>'
      ),
      jsonb_build_object(
        'type', 'metric_card_grid', 'columns', 2,
        'items', jsonb_build_array(
          jsonb_build_object('icon', '😴', 'name', 'Tempo de Recuperação', 'definition', 'Quanto o corpo precisa descansar após o esforço, calculado com base em intensidade e duração.', 'tip', 'Use pra justificar por que o relógio "manda descansar" mesmo quando o cliente se sente bem.')
        )
      )
    ))
   where module_id = v_module_id and order_index = 2;

  -- ==========================================================================
  -- Lição 4 (order_index 3): Estamina em tempo real
  -- ==========================================================================
  update public.lessons
     set body = jsonb_build_object('blocks', jsonb_build_array(
      jsonb_build_object(
        'type', 'texto_rico',
        'html', '<p>A <span class="term-tip" tabindex="0" data-tip="Percentual (0-100%) de reserva de energia disponível durante a atividade.">estamina em tempo real</span> mostra, em porcentagem, quanto o corredor ainda tem de reserva de energia para manter um bom desempenho durante a atividade. O cálculo usa a estimativa de <span class="term-tip" tabindex="0" data-tip="Volume máximo de oxigênio que o corpo consome por minuto, por kg de peso, no esforço máximo.">VO2 máximo</span> junto com a frequência cardíaca e o histórico de treinos recente, incluindo duração, distância percorrida e carga acumulada de treinamento.</p><p>Quanto mais forte o esforço, mais rápido a estamina é consumida. Em provas longas, esse dado ajuda o corredor a dosar o ritmo: se a estamina está caindo rápido demais no início do percurso, é sinal de que o esforço está acima do que o corpo consegue sustentar até o final. O relógio também estima o tempo e a distância restantes até o momento de exaustão, atualizando esses números continuamente conforme a corrida avança.</p>'
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
    ))
   where module_id = v_module_id and order_index = 3;

  -- ==========================================================================
  -- Lição 5 (order_index 4): Economia de corrida + Métricas Avançadas +
  -- Dicionário Rápido (agora colorido, +3 termos de apoio) + aquecimento
  -- ==========================================================================
  update public.lessons
     set body = jsonb_build_object('blocks', jsonb_build_array(
      jsonb_build_object(
        'type', 'texto_rico',
        'html', '<p>A <span class="term-tip" tabindex="0" data-tip="Eficiência medida em ml de oxigênio/kg a cada km percorrido; quanto menor, mais eficiente.">economia de corrida</span> indica a eficiência do corredor, medida em mililitros de oxigênio consumidos por quilograma de peso corporal a cada quilômetro percorrido. Quanto menor o número, mais eficiente é a técnica de corrida, já que o corpo está gastando menos energia para manter o mesmo ritmo.</p><p>Esse dado é calculado a partir da frequência cardíaca, da <span class="term-tip" tabindex="0" data-tip="Quanto o corpo sobe e desce a cada passada; uma das métricas usadas no cálculo da Economia de Corrida.">oscilação vertical</span> e de outras métricas de dinâmica de corrida durante a atividade, e por isso funciona melhor com o uso de uma cinta de frequência cardíaca no peito. É um dos recursos mais recentes na linha de corrida da Garmin, disponível a partir do Forerunner 970, e pode ser consultado tanto no relógio quanto no aplicativo Garmin Connect, na seção de estatísticas de desempenho.</p>'
      ),
      jsonb_build_object('type', 'banner', 'tone', 'info', 'text', '⚙️ Métricas Avançadas — Forerunner 970 + <span class="term-tip" tabindex="0" data-tip="Cinta de frequência cardíaca da Garmin necessária para métricas avançadas como Economia de Corrida e SSL.">HRM 600</span>. As duas métricas abaixo compartilham o mesmo requisito de hardware — um combo natural de venda (relógio + cinta).'),
      jsonb_build_object(
        'type', 'metric_card_grid', 'columns', 2,
        'items', jsonb_build_array(
          jsonb_build_object('icon', '⚡', 'name', 'Economia de Corrida', 'definition', 'Eficiência medida em ml de oxigênio/kg/km — quanto menor, mais eficiente.', 'tip', 'Só funciona com a cinta HRM 600 — ótimo gancho pra vender relógio + acessório juntos.', 'badge', 'Requer HRM 600'),
          jsonb_build_object('icon', '📉', 'name', 'SSL (Perda de Velocidade de Passo)', 'definition', 'Mede em cm/s a queda de velocidade da passada — quanto menor, mais eficiente a técnica. Também existe em % (SSL%).', 'tip', 'Métrica avançada, mesmo requisito da Economia de Corrida — parte do mesmo combo de venda técnica.', 'badge', 'Requer HRM 600')
        )
      ),
      jsonb_build_object(
        'type', 'tabela', 'colorful', true,
        'headers', jsonb_build_array('Termo', 'Definição'),
        'rows', jsonb_build_array(
          jsonb_build_array('Cadência', 'Passadas por minuto durante a corrida; indica eficiência do movimento.'),
          jsonb_build_array('Distância (GPS)', 'Medição via GPS dedicado do relógio, mais confiável que o do celular em áreas de sinal fraco.'),
          jsonb_build_array('Economia de Corrida', 'Eficiência medida em ml de oxigênio/kg a cada km percorrido; quanto menor, mais eficiente.'),
          jsonb_build_array('Estamina em Tempo Real', 'Percentual (0-100%) de reserva de energia disponível durante a atividade.'),
          jsonb_build_array('Firstbeat Analytics', 'Tecnologia parceira da Garmin usada para estimar métricas fisiológicas como VO2 Máx e Tempo de Recuperação.'),
          jsonb_build_array('HRM 600', 'Cinta de frequência cardíaca da Garmin necessária para métricas avançadas como Economia de Corrida e SSL.'),
          jsonb_build_array('Oscilação Vertical', 'Quanto o corpo sobe e desce a cada passada; uma das métricas usadas no cálculo da Economia de Corrida.'),
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
    ))
   where module_id = v_module_id and order_index = 4;

  -- ==========================================================================
  -- Quiz do módulo — tooltip no termo técnico do enunciado (não muda
  -- alternativas/explicações/gabarito, só o texto da pergunta)
  -- ==========================================================================
  update public.questions set body = 'O que a métrica de <span class="term-tip" tabindex="0" data-tip="Passadas por minuto durante a corrida; indica eficiência do movimento.">cadência</span> mede durante a corrida?'
   where quiz_id = v_quiz_id and order_index = 0;

  update public.questions set body = 'Como o relógio calcula a estimativa de <span class="term-tip" tabindex="0" data-tip="Volume máximo de oxigênio que o corpo consome por minuto, por kg de peso, no esforço máximo.">VO2 máximo</span>?'
   where quiz_id = v_quiz_id and order_index = 1;

  update public.questions set body = 'O que a <span class="term-tip" tabindex="0" data-tip="Percentual (0-100%) de reserva de energia disponível durante a atividade.">estamina em tempo real</span> (0 a 100%) representa durante uma corrida?'
   where quiz_id = v_quiz_id and order_index = 2;

  update public.questions set body = 'O que significa um número mais baixo na <span class="term-tip" tabindex="0" data-tip="Eficiência medida em ml de oxigênio/kg a cada km percorrido; quanto menor, mais eficiente.">economia de corrida</span>?'
   where quiz_id = v_quiz_id and order_index = 3;

  update public.questions set body = 'Por que a <span class="term-tip" tabindex="0" data-tip="Eficiência medida em ml de oxigênio/kg a cada km percorrido; quanto menor, mais eficiente.">economia de corrida</span> funciona melhor com uma cinta de frequência cardíaca no peito?'
   where quiz_id = v_quiz_id and order_index = 4;

  update public.questions set body = 'O que a métrica de <span class="term-tip" tabindex="0" data-tip="Mede em cm/s a queda de velocidade da passada; quanto menor, mais eficiente a técnica.">Perda de Velocidade de Passo (SSL)</span> mede?'
   where quiz_id = v_quiz_id and order_index = 5;

  update public.questions set body = 'Um cliente corredor de prova longa (maratona) está decidindo entre um modelo básico e um com <span class="term-tip" tabindex="0" data-tip="Percentual (0-100%) de reserva de energia disponível durante a atividade.">estamina em tempo real</span>. Qual argumento é mais relevante para esse perfil?'
   where quiz_id = v_quiz_id and order_index = 7;

  update public.questions set body = 'Um cliente pergunta se realmente precisa de uma <span class="term-tip" tabindex="0" data-tip="Cinta de frequência cardíaca da Garmin necessária para métricas avançadas como Economia de Corrida e SSL.">cinta de frequência cardíaca</span>, já que o relógio mede pelo pulso. Qual resposta é mais adequada?'
   where quiz_id = v_quiz_id and order_index = 8;

end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 058
-- ============================================================================
