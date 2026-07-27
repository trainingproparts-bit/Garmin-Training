-- 111_refaz_metricas_corrida.sql
-- Reescreve do zero o modulo "Metricas Essenciais de Corrida" (Zona Atleta),
-- renomeado pra "Metricas Essenciais e Avancadas de Corrida", conforme spec
-- do usuario:
--   1. Linguagem: proibido sigla solta em ingles sem explicacao. Sempre
--      termo em portugues primeiro, sigla entre parenteses.
--   2. Cintas oficiais: so HRM 600 e HRM 200 (ja estava correto, mantido).
--   3. Profundidade didatica nos "Toques Praticos" e dicas de atendimento.
--
-- Estrutura final: exatamente 4 licoes (de 5), reaproveitando 4 dos 5 IDs
-- existentes (UPDATE in place, preserva historico de progresso) e removendo
-- so 1 licao (Estamina em tempo real, cujo conteudo foi fundido na nova
-- licao 2 de fisiologia). A antiga licao "Tempo de recuperacao" e reaproveitada
-- como a nova licao 4 de Glossario/Jogo de Associacao, em vez de criar uma
-- linha nova, pra preservar o progresso ja registrado nela.

update modules
set title = 'Métricas Essenciais e Avançadas de Corrida'
where id = 'd35b508e-2caa-49ed-b2ed-62bdc5bfd607';

-- ============================================================
-- Licao 1 (order_index 0) — Metricas Fundamentais de Corrida (A Base do Treino)
-- ============================================================
update lessons
set
  title = 'Métricas Fundamentais de Corrida (A Base do Treino)',
  order_index = 0,
  body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<p>Estas são as três métricas que praticamente todo corredor já conhece, mesmo vindo de um app de celular. Elas são a base de qualquer demonstração de relógio de corrida, e é aqui que o vendedor prova, na prática, por que um GPS dedicado no pulso vale mais do que o GPS do celular.</p>"},
  {"type":"texto_rico","html":"<p><strong>Ritmo de Corrida (Pace)</strong> mostra a velocidade da corrida em minutos por quilômetro. Existem três formas de ver esse número no relógio, e explicar a diferença evita confusão na hora da venda:</p><ul><li><strong>Ritmo Instantâneo</strong> — atualiza a cada poucos segundos, mostra a velocidade agora mesmo. É mais sensível e pode variar bastante a cada passada.</li><li><strong>Ritmo Médio</strong> — a média desde o início da atividade. Mais estável, melhor pra saber se está dentro da meta geral do treino.</li><li><strong>Ritmo da Volta (Lap)</strong> — a média só do trecho atual (o \"lap\" corrente), útil pra quem treina em blocos, tipo 5 tiros de 1km.</li></ul><p>O <strong>GPS dedicado</strong> do relógio é significativamente mais confiável que o GPS do celular em áreas urbanas com prédios altos ou trechos com muitas árvores: o sinal de satélite sofre reflexo e bloqueio nesses ambientes (o chamado efeito de multi-caminho), e o celular, geralmente preso ao braço ou no bolso, capta o sinal pior do que um receptor dedicado no pulso, ajustado especificamente pra corrida.</p>"},
  {"type":"texto_rico","html":"<p><strong>Cadência de Passadas</strong> mede quantas passadas o corredor dá por minuto, em <strong>Passadas Por Minuto (spm)</strong>. Uma cadência baixa geralmente é sinal de \"passada muito larga\" (overstride): o corredor pisa com o pé bem à frente do corpo, criando um efeito de freio a cada passada e aumentando o impacto e a sobrecarga nos joelhos. Uma cadência ajustada, com passadas mais curtas e mais frequentes, reduz esse impacto de frenagem e melhora a eficiência geral da corrida. É uma métrica ótima pra mostrar evolução técnica ao longo dos meses, não só no dia do treino.</p>"},
  {"type":"texto_rico","html":"<p><strong>Distância e Altimetria por GPS Dedicado</strong> — além da distância percorrida, o GPS do relógio também mede o ganho de elevação (altimetria) durante o percurso. Isso é essencial pra quem treina com meta real de prova: uma corrida de 10km plana tem uma exigência física bem diferente de uma com 300m de ganho de elevação, e o relógio registra esse dado com precisão pra ajudar o corredor a planejar o treino certo pro perfil da prova que ele vai enfrentar.</p>"},
  {"type":"metric_card_grid","columns":3,"items":[
    {"icon":"🏃","name":"Ritmo de Corrida (Pace)","tip":"É a métrica que o cliente já espera ver, comece a demonstração por ela.","definition":"Velocidade da corrida em min/km. No relógio dá pra ver o Ritmo Instantâneo, o Ritmo Médio e o Ritmo da Volta (Lap)."},
    {"icon":"👣","name":"Cadência (spm)","tip":"Cadência baixa = passada larga = mais impacto no joelho. Use isso pra vender ajuste técnico, não só velocidade.","definition":"Passadas por minuto. Cadência ajustada reduz o efeito de frenagem da passada larga (overstride)."},
    {"icon":"📍","name":"Distância e Altimetria (GPS)","tip":"Destaque isso pra quem já reclamou que o GPS do celular \"perdeu o sinal\" correndo na cidade.","definition":"Medição via GPS dedicado do relógio, incluindo ganho de elevação, mais confiável que o celular em áreas com sinal fraco."}
  ]}
]}
$j$::jsonb
where id = '1072a42a-bc8e-4e21-91f7-1f23f3855a86';

-- ============================================================
-- Licao 2 (order_index 1) — Metricas Fisiologicas e Gestao de Esforco
-- Funde VO2 Max + HRV (novo) + Tempo de Recuperacao + Estamina numa so licao.
-- ============================================================
update lessons
set
  title = 'Métricas Fisiológicas e Gestão de Esforço',
  order_index = 1,
  body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<p><strong>Capacidade Cardiorrespiratória (VO2 Máx)</strong> é o volume máximo de oxigênio que o corpo consegue consumir por minuto, por quilograma de peso corporal, durante o esforço máximo — em resumo, o indicador clássico de condicionamento físico. O relógio estima esse valor combinando frequência cardíaca e ritmo de corrida ao longo de várias atividades, sem precisar de um teste de laboratório. Essa estimativa é fornecida pela tecnologia <strong>Firstbeat Analytics</strong>, parceira da Garmin nesse tipo de métrica, e fica mais precisa conforme o relógio acumula mais atividades do usuário. É um ótimo argumento de venda de longo prazo: ao longo dos meses, esse número sobe conforme o cliente evolui fisicamente, e o relógio guarda esse histórico pra provar a evolução dele com dado real, não só sensação.</p>"},
  {"type":"texto_rico","html":"<p><strong>Variabilidade da Frequência Cardíaca (VFC / HRV)</strong> mede a variação nos microintervalos de tempo entre um batimento cardíaco e outro. Parece contraintuitivo, mas um coração saudável e bem recuperado NÃO bate num ritmo perfeitamente constante — ele varia levemente a cada batimento. Quando essa variação é maior, é sinal de que o corpo está bem recuperado e com baixo estresse. Quando a variação cai, é sinal de estresse acumulado, sono ruim ou fadiga de treino. O relógio mede isso principalmente durante o sono ou em repouso, e é uma das formas mais diretas de mostrar pro cliente que o corpo dele está pedindo descanso, mesmo antes de ele sentir isso conscientemente.</p>"},
  {"type":"texto_rico","html":"<p><strong>Tempo de Recuperação Recomendado</strong> é a contagem regressiva, em horas, de quanto o corpo precisa descansar antes do próximo treino de alta intensidade. Esse cálculo cruza a intensidade e duração do esforço realizado com os dados fisiológicos recentes (incluindo a Capacidade Cardiorrespiratória e, em relógios com VFC, a qualidade do sono). É uma forma prática de explicar pro cliente por que o relógio às vezes sugere um dia de descanso mesmo quando ele se sente disposto a treinar — treinar puxado demais, com pouco descanso, é o caminho direto pro desgaste excessivo (overtraining), que derruba desempenho em vez de melhorar.</p>"},
  {"type":"texto_rico","html":"<p><strong>Reserva de Energia em Tempo Real (Estamina)</strong> mostra, em porcentagem, quanto o corredor ainda tem de \"combustível\" disponível pra manter um bom desempenho durante a atividade — pensa num tanque de combustível que vai esvaziando conforme o esforço aumenta. O cálculo cruza a Capacidade Cardiorrespiratória com a frequência cardíaca e o histórico de treino recente (duração, distância e carga acumulada). Existem duas leituras diferentes que não podem ser confundidas: a <strong>Reserva Atual</strong>, que é o nível de energia agora mesmo, e a <strong>Reserva Potencial</strong>, que é o máximo que o corpo ainda consegue sustentar se o ritmo for dosado com inteligência. Quanto mais forte o esforço, mais rápido o tanque esvazia. Em provas longas, esse dado ajuda o corredor a dosar o ritmo: se a reserva está caindo rápido demais logo no início do percurso, é sinal de que o esforço está acima do que o corpo consegue sustentar até o final. O relógio também estima o tempo e a distância restantes até o momento de exaustão, atualizando esses números continuamente conforme a corrida avança.</p>"},
  {"type":"banner","tone":"info","text":"Reserva de Energia (Estamina) e Tempo de Recuperação são coisas diferentes, e o vendedor precisa saber separar as duas na hora de explicar: a Reserva de Energia é o combustível disponível AGORA, DURANTE a atividade, e cai conforme o corredor se esforça. O Tempo de Recuperação é o descanso necessário DEPOIS do treino, pra evitar o desgaste excessivo no treino seguinte."},
  {"type":"texto_rico","html":"<div style=\"margin:16px 0;padding:16px;background:var(--off);border-radius:var(--r4);border:1px solid var(--border);\"><p style=\"margin:0 0 12px;font-size:13px;font-weight:700;color:var(--text);\">⚖️ Quadro comparativo: Reserva de Energia (Estamina) vs. Tempo de Recuperação</p><div style=\"margin-bottom:14px;\"><div style=\"display:flex;justify-content:space-between;font-size:12px;color:var(--text2);margin-bottom:4px;\"><span>🔋 Reserva de Energia em Tempo Real (Estamina)</span><span>65%</span></div><div style=\"height:10px;border-radius:999px;background:var(--border);overflow:hidden;\"><div style=\"height:100%;width:65%;background:var(--acc);border-radius:999px;\"></div></div><p style=\"margin:4px 0 0;font-size:11.5px;color:var(--text3);\">Energia disponível AGORA, durante a atividade. Cai conforme o esforço, como um tanque de combustível esvaziando.</p></div><div><div style=\"display:flex;justify-content:space-between;font-size:12px;color:var(--text2);margin-bottom:4px;\"><span>😴 Tempo de Recuperação</span><span>18h</span></div><div style=\"height:10px;border-radius:999px;background:var(--border);overflow:hidden;\"><div style=\"height:100%;width:40%;background:var(--gold);border-radius:999px;\"></div></div><p style=\"margin:4px 0 0;font-size:11.5px;color:var(--text3);\">Descanso necessário DEPOIS do treino. Quanto maior a barra, mais tempo o corpo pede pra se recuperar antes do próximo esforço forte.</p></div><p style=\"margin:12px 0 0;font-size:11px;color:var(--text3);font-style:italic;\">Valores ilustrativos, só pra mostrar a diferença entre as duas métricas.</p></div>"}
]}
$j$::jsonb
where id = '342f0472-cd16-409c-aa13-80777d400f2f';

-- ============================================================
-- Licao 3 (order_index 2) — Biomecanica e Metricas Avancadas (Combo: Relogio + HRM 600)
-- Remove a tabela de glossario e o match_quiz, que viram a nova licao 4.
-- ============================================================
update lessons
set
  title = 'Biomecânica e Métricas Avançadas (Combo: Relógio + HRM 600)',
  order_index = 2,
  body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<p><strong>Economia de Corrida</strong> — pensa em dois carros que andam a 100 km/h, mas um gasta menos combustível: na corrida é a mesma lógica. A economia de corrida mostra se o atleta consegue manter o mesmo ritmo gastando menos oxigênio e energia. Quanto menor o gasto pra manter a mesma velocidade, mais eficiente é o corredor. Esse dado é calculado a partir da frequência cardíaca, da oscilação vertical (quanto o corpo sobe e desce a cada passada) e de outras métricas de dinâmica de corrida durante a atividade — por isso funciona melhor com o uso de uma cinta de frequência cardíaca no peito. É um dos recursos mais recentes da linha de corrida Garmin, disponível a partir do Forerunner 970, e pode ser consultado tanto no relógio quanto no aplicativo Garmin Connect, na seção de estatísticas de desempenho.</p>"},
  {"type":"texto_rico","html":"<p><strong>Perda de Velocidade na Passada / Frenagem (SSL)</strong> mede, em centímetros por segundo (ou em porcentagem, SSL%), o quanto o atleta \"freia\" o próprio corpo toda vez que o pé toca o chão. Toda passada tem um pequeno momento de frenagem natural — o pé toca o chão um pouco à frente do centro de massa do corpo, e isso desacelera o corredor por uma fração de segundo antes do próximo impulso. Quanto menor essa frenagem, menos energia é desperdiçada freando o próprio corpo a cada passo, e mais rápido o atleta consegue correr sem gastar energia extra. Reduzir a frenagem é uma forma direta de melhorar o desempenho sem precisar aumentar o condicionamento físico.</p>"},
  {"type":"banner","tone":"info","text":"Argumento de venda casada: Economia de Corrida e Perda de Velocidade na Passada (SSL) só funcionam com um relógio compatível (por exemplo, o Forerunner 970) combinado com a cinta HRM 600. Um atleta que já busca performance e eficiência de treino é exatamente o perfil de cliente que precisa levar o combo completo, relógio + cinta, não só o relógio sozinho."},
  {"type":"metric_card_grid","columns":2,"items":[
    {"icon":"⚡","name":"Economia de Corrida","badge":"Requer HRM 600","tip":"Só funciona com a cinta HRM 600, ótimo gancho pra vender relógio + acessório juntos.","definition":"Eficiência medida em ml de oxigênio por kg a cada km percorrido. Quanto menor, mais eficiente."},
    {"icon":"📉","name":"Perda de Velocidade na Passada (SSL)","badge":"Requer HRM 600","tip":"Explique como o \"freio\" que o próprio corpo aplica a cada passada — reduzir isso é ganhar velocidade de graça.","definition":"Mede em cm/s (ou %) a queda de velocidade a cada passada. Quanto menor, mais eficiente a técnica."}
  ]}
]}
$j$::jsonb
where id = 'e0863e72-e7ae-46c0-b199-fa0331c57852';

-- ============================================================
-- Licao 4 (order_index 3) — Glossario Traduzido e Jogo de Associacao.
-- Reaproveita a antiga licao "Tempo de recuperacao" (415c3b5f) em vez de criar
-- uma linha nova, pra preservar o progresso ja registrado nela.
-- ============================================================
update lessons
set
  title = 'Glossário Traduzido e Jogo de Associação',
  order_index = 3,
  body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<p>Tabela de referência rápida com todos os termos desta trilha, sempre em português primeiro e a sigla em inglês entre parênteses, exatamente como devem ser explicados pro cliente no balcão.</p>"},
  {"type":"tabela","headers":["Termo","Definição"],"rows":[
    ["Ritmo de Corrida (Pace)","Velocidade da corrida em minutos por quilômetro. Pode ser visto como Ritmo Instantâneo, Ritmo Médio ou Ritmo da Volta (Lap)."],
    ["Cadência (spm)","Passadas por minuto durante a corrida. Cadência baixa costuma indicar passada larga (overstride) e mais impacto no joelho."],
    ["Distância e Altimetria (GPS)","Medição via GPS dedicado do relógio, incluindo ganho de elevação, mais confiável que o celular em áreas de sinal fraco."],
    ["Capacidade Cardiorrespiratória (VO2 Máx)","Volume máximo de oxigênio que o corpo consome por minuto, por kg de peso, no esforço máximo. Estimado via Firstbeat Analytics."],
    ["Variabilidade da Frequência Cardíaca (VFC / HRV)","Variação nos microintervalos entre os batimentos cardíacos. Maior variação indica boa recuperação; menor variação indica estresse acumulado."],
    ["Tempo de Recuperação","Tempo que o corpo precisa descansar após o esforço, com base na intensidade e duração do treino, pra evitar desgaste excessivo (overtraining)."],
    ["Reserva de Energia em Tempo Real (Estamina)","Percentual (0-100%) de reserva de energia disponível durante a atividade, como um tanque de combustível. Reserva Atual x Reserva Potencial."],
    ["Economia de Corrida","Eficiência medida em ml de oxigênio/kg a cada km percorrido. Quanto menor, mais eficiente. Requer HRM 600."],
    ["Perda de Velocidade na Passada (SSL)","Mede em cm/s (ou %) a queda de velocidade a cada passada, o \"freio\" que o corpo aplica sozinho. Quanto menor, mais eficiente a técnica. Requer HRM 600."],
    ["Firstbeat Analytics","Tecnologia parceira da Garmin usada pra estimar métricas fisiológicas como VO2 Máx e Tempo de Recuperação."],
    ["HRM 600","Cinta de frequência cardíaca topo de linha da Garmin: métricas avançadas, gravação na água e armazenamento offline."],
    ["HRM 200","Cinta de frequência cardíaca de entrada da Garmin: foco em frequência cardíaca e Variabilidade da Frequência Cardíaca (VFC/HRV)."]
  ]},
  {"type":"match_quiz","pairs":[
    {"term":"Ritmo de Corrida (Pace)","definition":"Velocidade da corrida em minutos por quilômetro"},
    {"term":"Cadência (spm)","definition":"Passadas por minuto durante a corrida"},
    {"term":"Distância e Altimetria (GPS)","definition":"Medição via GPS dedicado do relógio, incluindo elevação"},
    {"term":"Capacidade Cardiorrespiratória (VO2 Máx)","definition":"Consumo máximo de oxigênio por minuto/kg no esforço máximo"},
    {"term":"Variabilidade da Frequência Cardíaca (VFC/HRV)","definition":"Variação nos microintervalos entre os batimentos cardíacos"},
    {"term":"Tempo de Recuperação","definition":"Descanso necessário após o esforço, pra evitar overtraining"},
    {"term":"Reserva de Energia em Tempo Real (Estamina)","definition":"Reserva de energia disponível agora, em porcentagem"},
    {"term":"Economia de Corrida","definition":"Eficiência em ml de oxigênio por kg a cada km"},
    {"term":"Perda de Velocidade na Passada (SSL)","definition":"Frenagem da própria passada, medida em cm/s"},
    {"term":"HRM 600","definition":"Cinta topo de linha, necessária pra Economia de Corrida e SSL"}
  ]}
]}
$j$::jsonb
where id = '415c3b5f-3b5f-4ad4-afa4-0399c6dc6c96';

-- ============================================================
-- Remove a licao "Estamina em tempo real" (conteudo fundido na licao 2).
-- Limpa dependentes antes, seguindo o padrao de cascade ja usado no modulo
-- de Ecossistema de Acessorios (sql/110).
-- ============================================================
delete from review_session_items
where catalog_item_id in (
  select id from review_catalog
  where source_table = 'lessons' and source_id = 'd971d35c-a9da-49ef-b3eb-cf7719454643'
);

delete from review_catalog
where source_table = 'lessons' and source_id = 'd971d35c-a9da-49ef-b3eb-cf7719454643';

delete from lesson_progress
where lesson_id = 'd971d35c-a9da-49ef-b3eb-cf7719454643';

delete from lessons
where id = 'd971d35c-a9da-49ef-b3eb-cf7719454643';

-- ============================================================
-- Quiz "Metricas Essenciais de Corrida" — padroniza a nomenclatura de SSL
-- pro termo preferido do usuario e adiciona 5 perguntas novas cobrindo o
-- aprofundamento desta rodada (Ritmo Instantaneo/Medio/Volta, GPS urbano,
-- overstride, VFC/HRV, combo Forerunner 970 + HRM 600).
-- ============================================================
update questions
set body = replace(body, 'Perda de Velocidade de Passo (SSL)', 'Perda de Velocidade na Passada (SSL)')
where quiz_id = '032d0cd4-dc60-4c7d-b0eb-6d103883636f' and body ilike '%Perda de Velocidade de Passo%';

insert into questions (id, quiz_id, body, explanation, order_index, is_active)
values
  ('b2c3d4e5-0001-4b2b-9b2b-111000000001', '032d0cd4-dc60-4c7d-b0eb-6d103883636f', 'Qual a diferença entre Ritmo Instantâneo e Ritmo Médio no relógio?', 'O Ritmo Instantâneo atualiza a cada poucos segundos e mostra a velocidade agora; o Ritmo Médio é a média desde o início da atividade, mais estável pra avaliar a meta geral do treino.', 9, true),
  ('b2c3d4e5-0002-4b2b-9b2b-111000000002', '032d0cd4-dc60-4c7d-b0eb-6d103883636f', 'Por que o GPS do relógio costuma ser mais confiável que o do celular em áreas urbanas com prédios altos?', 'O sinal de satélite sofre reflexo e bloqueio nesses ambientes, e o receptor dedicado no pulso do relógio capta o sinal melhor do que o celular preso ao braço ou no bolso.', 10, true),
  ('b2c3d4e5-0003-4b2b-9b2b-111000000003', '032d0cd4-dc60-4c7d-b0eb-6d103883636f', 'O que costuma causar uma cadência de passadas baixa durante a corrida?', 'Passada muito larga (overstride): o pé toca o chão bem à frente do corpo, criando um efeito de freio a cada passada e aumentando a sobrecarga nos joelhos.', 11, true),
  ('b2c3d4e5-0004-4b2b-9b2b-111000000004', '032d0cd4-dc60-4c7d-b0eb-6d103883636f', 'O que a Variabilidade da Frequência Cardíaca (VFC / HRV) indica?', 'A variação nos microintervalos entre os batimentos cardíacos. Maior variação indica boa recuperação e baixo estresse; menor variação indica estresse acumulado ou fadiga.', 12, true),
  ('b2c3d4e5-0005-4b2b-9b2b-111000000005', '032d0cd4-dc60-4c7d-b0eb-6d103883636f', 'Um cliente quer treinar Economia de Corrida e Perda de Velocidade na Passada (SSL). O que ele precisa levar?', 'Um relógio compatível, como o Forerunner 970, combinado com a cinta HRM 600 — as duas métricas exigem esse combo de hardware.', 13, true);

insert into alternatives (question_id, body, is_correct, order_index)
values
  ('b2c3d4e5-0001-4b2b-9b2b-111000000001', 'Instantâneo mostra a velocidade agora; Médio é a média desde o início da atividade', true, 0),
  ('b2c3d4e5-0001-4b2b-9b2b-111000000001', 'São exatamente a mesma coisa, só com nomes diferentes', false, 1),
  ('b2c3d4e5-0001-4b2b-9b2b-111000000001', 'Instantâneo é a média da prova inteira', false, 2),
  ('b2c3d4e5-0001-4b2b-9b2b-111000000001', 'Médio só existe em corridas de mais de 21km', false, 3),

  ('b2c3d4e5-0002-4b2b-9b2b-111000000002', 'Porque o receptor dedicado do relógio capta melhor o sinal, que sofre reflexo e bloqueio nesses ambientes', true, 0),
  ('b2c3d4e5-0002-4b2b-9b2b-111000000002', 'Porque o celular não tem GPS', false, 1),
  ('b2c3d4e5-0002-4b2b-9b2b-111000000002', 'Não existe diferença real entre os dois', false, 2),
  ('b2c3d4e5-0002-4b2b-9b2b-111000000002', 'Porque o relógio usa internet móvel em vez de satélite', false, 3),

  ('b2c3d4e5-0003-4b2b-9b2b-111000000003', 'Passada muito larga (overstride), com o pé tocando o chão à frente do corpo', true, 0),
  ('b2c3d4e5-0003-4b2b-9b2b-111000000003', 'Excesso de hidratação durante a corrida', false, 1),
  ('b2c3d4e5-0003-4b2b-9b2b-111000000003', 'Frequência cardíaca muito baixa', false, 2),
  ('b2c3d4e5-0003-4b2b-9b2b-111000000003', 'Uso de tênis muito leve', false, 3),

  ('b2c3d4e5-0004-4b2b-9b2b-111000000004', 'A variação nos microintervalos entre os batimentos cardíacos, ligada a recuperação e estresse', true, 0),
  ('b2c3d4e5-0004-4b2b-9b2b-111000000004', 'A frequência cardíaca máxima do usuário', false, 1),
  ('b2c3d4e5-0004-4b2b-9b2b-111000000004', 'O número de vezes que o relógio mede o pulso por dia', false, 2),
  ('b2c3d4e5-0004-4b2b-9b2b-111000000004', 'A distância percorrida durante o treino de força', false, 3),

  ('b2c3d4e5-0005-4b2b-9b2b-111000000005', 'Um relógio compatível (ex: Forerunner 970) combinado com a cinta HRM 600', true, 0),
  ('b2c3d4e5-0005-4b2b-9b2b-111000000005', 'Só o relógio, qualquer modelo já mede as duas métricas', false, 1),
  ('b2c3d4e5-0005-4b2b-9b2b-111000000005', 'Só a cinta HRM 600, sem precisar de relógio nenhum', false, 2),
  ('b2c3d4e5-0005-4b2b-9b2b-111000000005', 'Um sensor de cadência, nada relacionado à cinta cardíaca', false, 3);
