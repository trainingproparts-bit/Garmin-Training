-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 114: revisão editorial completa da plataforma
-- ============================================================================
-- Pedido do usuário: revisão editorial de todo o material (módulos, quizzes,
-- microcopy) pra ficar mais natural, mais humano e mais profissional, sem
-- criar conteúdo novo. Regras: sem travessão, sem "além disso"/"com isso"/
-- "vale ressaltar", vocabulário simples (utilizar->usar, realizar->fazer
-- etc), parágrafos curtos, alternativas de quiz plausíveis e de tamanho
-- parecido, sem padrão óbvio de posição da resposta certa.
--
-- Varredura feita em toda a base (85 lições, 396 perguntas, 1581
-- alternativas, 103 artigos da Biblioteca) por travessão, frases banidas e
-- vocabulário rebuscado. A maior parte do conteúdo já estava em bom estado
-- (tom casual, direto, sem jargão acadêmico) — os problemas encontrados se
-- concentraram nas lições mais recentes desta sessão. "Monitoramento"
-- aparece bastante no corpus, mas quase sempre como nome literal de recurso
-- do Garmin Connect ("Monitoramento de Hábitos", "Monitoramento de Sono"),
-- não como verbo de escrita corrida — não foi trocado por não ser erro de
-- estilo, seria erro de nomenclatura do produto.
--
-- Também corrigido nesta migração, achado ao auditar qualidade de quiz:
-- 89% das respostas certas do banco inteiro caíam nas posições 0 ou 1 (de 4
-- alternativas), um padrão de posição que deixa a resposta certa adivinhável
-- sem saber o conteúdo. Resolvido embaralhando order_index de todas as
-- alternativas (sem alterar nenhum texto, só a ordem de exibição). Além
-- disso, 12 perguntas tinham a alternativa certa nitidamente mais longa e
-- detalhada que as erradas (uma delas com a certa 177 caracteres contra
-- distratores de 65-83) — um "giveaway" clássico de tamanho. Os distratores
-- dessas 12 foram reescritos pra ficarem mais parecidos em tamanho e mais
-- plausíveis, sem mudar qual é a resposta certa nem os fatos.
-- ============================================================================

-- ============================================================
-- 1. Lições — remove travessão, divide parágrafo longo, corrige vocabulário
-- ============================================================

update lessons
set body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<p>Estas são as três métricas que praticamente todo corredor já conhece, mesmo vindo de um app de celular. Elas são a base de qualquer demonstração de relógio de corrida, e é aqui que o vendedor prova, na prática, por que um GPS dedicado no pulso vale mais do que o GPS do celular.</p>"},
  {"type":"texto_rico","html":"<p><strong>Ritmo de Corrida (Pace)</strong> mostra a velocidade da corrida em minutos por quilômetro. Existem três formas de ver esse número no relógio, e explicar a diferença evita confusão na hora da venda:</p><ul><li><strong>Ritmo Instantâneo:</strong> atualiza a cada poucos segundos, mostra a velocidade agora mesmo. É mais sensível e pode variar bastante a cada passada.</li><li><strong>Ritmo Médio:</strong> a média desde o início da atividade. Mais estável, melhor pra saber se está dentro da meta geral do treino.</li><li><strong>Ritmo da Volta (Lap):</strong> a média só do trecho atual (o \"lap\" corrente), útil pra quem treina em blocos, tipo 5 tiros de 1km.</li></ul><p>O <strong>GPS dedicado</strong> do relógio é bem mais confiável que o GPS do celular em áreas urbanas com prédios altos ou trechos com muitas árvores. O sinal de satélite sofre reflexo e bloqueio nesses ambientes (o chamado efeito de multi-caminho), e o celular, geralmente preso ao braço ou no bolso, capta o sinal pior do que um receptor dedicado no pulso, ajustado especificamente pra corrida.</p>"},
  {"type":"texto_rico","html":"<p><strong>Cadência de Passadas</strong> mede quantas passadas o corredor dá por minuto, em <strong>Passadas Por Minuto (spm)</strong>. Uma cadência baixa geralmente é sinal de \"passada muito larga\" (overstride): o corredor pisa com o pé bem à frente do corpo, criando um efeito de freio a cada passada e aumentando o impacto e a sobrecarga nos joelhos.</p><p>Uma cadência ajustada, com passadas mais curtas e mais frequentes, reduz esse impacto de frenagem e melhora a eficiência geral da corrida. É uma métrica ótima pra mostrar evolução técnica ao longo dos meses, não só no dia do treino.</p>"},
  {"type":"texto_rico","html":"<p><strong>Distância e Altimetria por GPS Dedicado</strong> conta mais do que a distância percorrida: o GPS do relógio também mede o ganho de elevação (altimetria) durante o percurso. Isso é essencial pra quem treina com meta real de prova. Uma corrida de 10km plana tem uma exigência física bem diferente de uma com 300m de ganho de elevação, e o relógio registra esse dado com precisão pra ajudar o corredor a planejar o treino certo pro perfil da prova que ele vai enfrentar.</p>"},
  {"type":"metric_card_grid","columns":3,"items":[
    {"icon":"🏃","name":"Ritmo de Corrida (Pace)","tip":"É a métrica que o cliente já espera ver, comece a demonstração por ela.","definition":"Velocidade da corrida em min/km. No relógio dá pra ver o Ritmo Instantâneo, o Ritmo Médio e o Ritmo da Volta (Lap)."},
    {"icon":"👣","name":"Cadência (spm)","tip":"Cadência baixa = passada larga = mais impacto no joelho. Use isso pra vender ajuste técnico, não só velocidade.","definition":"Passadas por minuto. Cadência ajustada reduz o efeito de frenagem da passada larga (overstride)."},
    {"icon":"📍","name":"Distância e Altimetria (GPS)","tip":"Destaque isso pra quem já reclamou que o GPS do celular \"perdeu o sinal\" correndo na cidade.","definition":"Medição via GPS dedicado do relógio, incluindo ganho de elevação, mais confiável que o celular em áreas com sinal fraco."}
  ]}
]}
$j$::jsonb
where id = '1072a42a-bc8e-4e21-91f7-1f23f3855a86';

update lessons
set body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<p><strong>Capacidade Cardiorrespiratória (VO2 Máx)</strong> é o volume máximo de oxigênio que o corpo consegue consumir por minuto, por quilograma de peso corporal, durante o esforço máximo. É o indicador clássico de condicionamento físico.</p><p>O relógio estima esse valor combinando frequência cardíaca e ritmo de corrida ao longo de várias atividades, sem precisar de um teste de laboratório. Essa estimativa é fornecida pela tecnologia <strong>Firstbeat Analytics</strong>, parceira da Garmin nesse tipo de métrica, e fica mais precisa conforme o relógio acumula mais atividades do usuário. É um ótimo argumento de venda de longo prazo: ao longo dos meses, esse número sobe conforme o cliente evolui fisicamente, e o relógio guarda esse histórico pra provar a evolução dele com dado real, não só sensação.</p>"},
  {"type":"texto_rico","html":"<p><strong>Variabilidade da Frequência Cardíaca (VFC / HRV)</strong> mede a variação nos microintervalos de tempo entre um batimento cardíaco e outro. Parece contraintuitivo, mas um coração saudável e bem recuperado NÃO bate num ritmo perfeitamente constante: ele varia levemente a cada batimento.</p><p>Quando essa variação é maior, é sinal de que o corpo está bem recuperado e com baixo estresse. Quando a variação cai, é sinal de estresse acumulado, sono ruim ou fadiga de treino. O relógio mede isso principalmente durante o sono ou em repouso, e é uma das formas mais diretas de mostrar pro cliente que o corpo dele está pedindo descanso, mesmo antes de ele sentir isso conscientemente.</p>"},
  {"type":"texto_rico","html":"<p><strong>Tempo de Recuperação Recomendado</strong> é a contagem regressiva, em horas, de quanto o corpo precisa descansar antes do próximo treino de alta intensidade. Esse cálculo cruza a intensidade e duração do esforço feito com os dados fisiológicos recentes (incluindo a Capacidade Cardiorrespiratória e, em relógios com VFC, a qualidade do sono).</p><p>É uma forma prática de explicar pro cliente por que o relógio às vezes sugere um dia de descanso mesmo quando ele se sente disposto a treinar. Treinar puxado demais, com pouco descanso, é o caminho direto pro desgaste excessivo (overtraining), que derruba desempenho em vez de melhorar.</p>"},
  {"type":"texto_rico","html":"<p><strong>Reserva de Energia em Tempo Real (Estamina)</strong> mostra, em porcentagem, quanto o corredor ainda tem de \"combustível\" disponível pra manter um bom desempenho durante a atividade. Pensa num tanque de combustível esvaziando conforme o esforço aumenta.</p><p>O cálculo cruza a Capacidade Cardiorrespiratória com a frequência cardíaca e o histórico de treino recente (duração, distância e carga acumulada). Existem duas leituras diferentes que não podem ser confundidas: a <strong>Reserva Atual</strong>, que é o nível de energia agora mesmo, e a <strong>Reserva Potencial</strong>, que é o máximo que o corpo ainda consegue sustentar se o ritmo for dosado com inteligência.</p><p>Quanto mais forte o esforço, mais rápido o tanque esvazia. Em provas longas, esse dado ajuda o corredor a dosar o ritmo: se a reserva está caindo rápido demais logo no início do percurso, é sinal de que o esforço está acima do que o corpo consegue sustentar até o final. O relógio também estima o tempo e a distância restantes até o momento de exaustão, atualizando esses números continuamente conforme a corrida avança.</p>"},
  {"type":"banner","tone":"info","text":"Reserva de Energia (Estamina) e Tempo de Recuperação são coisas diferentes, e o vendedor precisa saber separar as duas na hora de explicar: a Reserva de Energia é o combustível disponível AGORA, DURANTE a atividade, e cai conforme o corredor se esforça. O Tempo de Recuperação é o descanso necessário DEPOIS do treino, pra evitar o desgaste excessivo no treino seguinte."},
  {"type":"texto_rico","html":"<div style=\"margin:16px 0;padding:16px;background:var(--off);border-radius:var(--r4);border:1px solid var(--border);\"><p style=\"margin:0 0 12px;font-size:13px;font-weight:700;color:var(--text);\">⚖️ Quadro comparativo: Reserva de Energia (Estamina) vs. Tempo de Recuperação</p><div style=\"margin-bottom:14px;\"><div style=\"display:flex;justify-content:space-between;font-size:12px;color:var(--text2);margin-bottom:4px;\"><span>🔋 Reserva de Energia em Tempo Real (Estamina)</span><span>65%</span></div><div style=\"height:10px;border-radius:999px;background:var(--border);overflow:hidden;\"><div style=\"height:100%;width:65%;background:var(--acc);border-radius:999px;\"></div></div><p style=\"margin:4px 0 0;font-size:11.5px;color:var(--text3);\">Energia disponível AGORA, durante a atividade. Cai conforme o esforço, como um tanque de combustível esvaziando.</p></div><div><div style=\"display:flex;justify-content:space-between;font-size:12px;color:var(--text2);margin-bottom:4px;\"><span>😴 Tempo de Recuperação</span><span>18h</span></div><div style=\"height:10px;border-radius:999px;background:var(--border);overflow:hidden;\"><div style=\"height:100%;width:40%;background:var(--gold);border-radius:999px;\"></div></div><p style=\"margin:4px 0 0;font-size:11.5px;color:var(--text3);\">Descanso necessário DEPOIS do treino. Quanto maior a barra, mais tempo o corpo pede pra se recuperar antes do próximo esforço forte.</p></div><p style=\"margin:12px 0 0;font-size:11px;color:var(--text3);font-style:italic;\">Valores ilustrativos, só pra mostrar a diferença entre as duas métricas.</p></div>"}
]}
$j$::jsonb
where id = '342f0472-cd16-409c-aa13-80777d400f2f';

update lessons
set body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<p><strong>Economia de Corrida</strong> mostra se o atleta consegue manter o mesmo ritmo gastando menos oxigênio e energia. Pensa em dois carros que andam a 100 km/h, mas um gasta menos combustível: na corrida é a mesma lógica. Quanto menor o gasto pra manter a mesma velocidade, mais eficiente é o corredor.</p><p>Esse dado é calculado a partir da frequência cardíaca, da oscilação vertical (quanto o corpo sobe e desce a cada passada) e de outras métricas de dinâmica de corrida durante a atividade. Por isso funciona melhor com o uso de uma cinta de frequência cardíaca no peito. É um dos recursos mais recentes da linha de corrida Garmin, disponível a partir do Forerunner 970, e pode ser consultado tanto no relógio quanto no aplicativo Garmin Connect, na seção de estatísticas de desempenho.</p>"},
  {"type":"texto_rico","html":"<p><strong>Perda de Velocidade na Passada / Frenagem (SSL)</strong> mede, em centímetros por segundo (ou em porcentagem, SSL%), o quanto o atleta \"freia\" o próprio corpo toda vez que o pé toca o chão. Toda passada tem um pequeno momento de frenagem natural: o pé toca o chão um pouco à frente do centro de massa do corpo, e isso desacelera o corredor por uma fração de segundo antes do próximo impulso. Quanto menor essa frenagem, menos energia é desperdiçada freando o próprio corpo a cada passo, e mais rápido o atleta consegue correr sem gastar energia extra. Reduzir a frenagem é uma forma direta de melhorar o desempenho sem precisar aumentar o condicionamento físico.</p>"},
  {"type":"banner","tone":"info","text":"Argumento de venda casada: Economia de Corrida e Perda de Velocidade na Passada (SSL) só funcionam com um relógio compatível (por exemplo, o Forerunner 970) combinado com a cinta HRM 600. Um atleta que já busca performance e eficiência de treino é exatamente o perfil de cliente que precisa levar o combo completo, relógio + cinta, não só o relógio sozinho."},
  {"type":"metric_card_grid","columns":2,"items":[
    {"icon":"⚡","name":"Economia de Corrida","badge":"Requer HRM 600","tip":"Ótimo gancho pra vender relógio + acessório juntos.","definition":"Eficiência medida em ml de oxigênio por kg a cada km percorrido. Quanto menor, mais eficiente."},
    {"icon":"📉","name":"Perda de Velocidade na Passada (SSL)","badge":"Requer HRM 600","tip":"Explique como o \"freio\" que o próprio corpo aplica a cada passada. Reduzir isso é ganhar velocidade de graça.","definition":"Mede em cm/s (ou %) a queda de velocidade a cada passada. Quanto menor, mais eficiente a técnica."}
  ]}
]}
$j$::jsonb
where id = 'e0863e72-e7ae-46c0-b199-fa0331c57852';

update lessons
set body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<p>O portfólio Garmin usa <strong>três sistemas de fixação de pulseira diferentes</strong>, e confundir um com o outro é o erro mais comum na hora de vender uma pulseira certa pro cliente errado.</p>"},
  {"type":"card_grid","columns":3,"items":[
    {"title":"QuickFit","tags":[{"label":"Sem ferramenta","color":"green"}],"text":"Sistema Garmin de troca por alavanca: encaixa e destrava em segundos, sem ferramenta nenhuma. Usado na linha Fenix, Instinct e outros relógios de aventura, em 3 larguras: 20mm, 22mm e 26mm."},
    {"title":"Quick Release","tags":[{"label":"Sem ferramenta","color":"blue"}],"text":"Pino de mola padrão da indústria (spring bar), também sem ferramenta obrigatória: sai com a unha ou uma ferramenta pequena. Usado nos Forerunner 55, 165, 170 e 570. É um sistema diferente do QuickFit, mesmo quando a largura coincide (20 ou 22mm)."},
    {"title":"Watchband","tags":[{"label":"Precisa de ferramenta","color":"gold"}],"text":"Pulseira presa por um pino fixo, que exige uma ferramenta (pino/pushpin) pra remover. É o sistema de fábrica do Forerunner 970."}
  ]},
  {"type":"banner","tone":"warning","text":"Correção importante: o Forerunner 970 NÃO vem com QuickFit nativo de fábrica. Ele vem com o sistema Watchband (pulseira presa por pino, precisa de ferramenta pra soltar). É possível adaptar o relógio pra aceitar uma pulseira QuickFit de 22mm, mas isso exige um procedimento manual. Não é plug-and-play como no Fenix ou no Instinct."},
  {"type":"roteiro","steps":[
    {"title":"Passo 1: Remover a pulseira Watchband original","dialog":"Solte e remova a pulseira Watchband que veio de fábrica no Forerunner 970, usando a ferramenta apropriada pra soltar o pino que a prende.","tip":"Não force o pino sem a ferramenta certa. O sistema Watchband foi projetado pra ser removido só com ela."},
    {"title":"Passo 2: Soltar o pino da pulseira removida","dialog":"Extraia o pino que prendia a pulseira Watchband. Esse mesmo pino é reaproveitado no próximo passo, não é descartado.","tip":"Guarde o pino, ele é pequeno e fácil de perder."},
    {"title":"Passo 3: Reposicionar o pino direto nos encaixes da caixa","dialog":"Coloque esse pino diretamente nos encaixes (lugs) da caixa do relógio, sem nenhuma pulseira presa a ele dessa vez.","tip":"É esse passo que faz a diferença: o pino passa a funcionar como o eixo que a pulseira QuickFit vai travar."},
    {"title":"Passo 4: Encaixar a pulseira QuickFit de 22mm","dialog":"Com o pino já posicionado nos encaixes da caixa, encaixe a pulseira QuickFit de 22mm nele. Ela trava sozinha, sem ferramenta, exatamente como travaria num Fenix ou Instinct.","tip":"Depois desse procedimento, a troca entre pulseiras QuickFit no Forerunner 970 passa a ser tão rápida quanto em qualquer outro modelo QuickFit."}
  ]},
  {"type":"tabela","headers":["Modelo","Tamanho da caixa","Sistema de fábrica","QuickFit compatível"],"rows":[
    ["Fenix 8","42/43mm","QuickFit nativo","20mm"],
    ["Fenix 8","47mm","QuickFit nativo","22mm"],
    ["Fenix 8","51mm","QuickFit nativo","26mm"],
    ["Instinct 3","45mm","QuickFit nativo","22mm"],
    ["Instinct 3","50mm","QuickFit nativo","26mm"],
    ["Forerunner 970","47mm","Watchband (pino)","22mm, só após adaptação manual"],
    ["Forerunner 55 / 165 / 170 / 570","Variados","Quick Release (pino de mola padrão)","Não aplicável, sistema diferente"]
  ]},
  {"type":"texto_rico","html":"<p><strong>Guia de materiais:</strong> a mesma largura (20/22/26mm) existe em materiais diferentes, e cada um resolve uma necessidade distinta do cliente.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"Silicone","tags":[{"label":"Performance","color":"green"}],"text":"Material padrão QuickFit. Impermeável, resiste bem ao suor e à água, fácil de limpar. Custo menor, mas o visual é mais esportivo do que elegante."},
    {"title":"Nylon / UltraFit","tags":[{"label":"Esportiva","color":"blue"}],"text":"Trançado, respirável, ótimo pra quem treina muito e sua bastante. Seca mais rápido que o silicone e não gruda na pele. Mesmas 3 larguras QuickFit (20/22/26mm)."},
    {"title":"Couro","tags":[{"label":"Estilo","color":"gold"}],"text":"Visual premium e discreto, ideal pra usar no trabalho ou em ocasião social. Não é recomendado pra treino intenso, suor constante ou natação: o couro não foi feito pra isso."},
    {"title":"Metal","tags":[{"label":"Lifestyle","color":"gold"}],"text":"Visual mais sofisticado e durável, mas mais pesado que silicone ou nylon. Melhor indicado pro dia a dia e uso casual do que pra treino de alta intensidade."}
  ]},
  {"type":"texto_rico","html":"<p>O jeito mais rápido de confirmar o tamanho de uma pulseira QuickFit é olhar a própria peça: o tamanho vem gravado na parte de baixo, a que fica encostada no pulso (ex.: \"QuickFit 22\"). Sem a pulseira em mãos, o tamanho é definido pelo modelo e pela caixa do relógio, conforme a tabela acima.</p>"},
  {"type":"objecao","items":[
    {"question":"O cliente não sabe o tamanho do relógio dele, e não trouxe a pulseira","answer":"Pergunte o modelo e o tamanho da caixa (em mm, geralmente no nome do produto ou na caixa de venda). Com isso dá pra cruzar direto com a tabela de QuickFit por modelo."}
  ]},
  {"type":"card_grid","columns":3,"items":[
    {"title":"Treina muito e sua bastante","tags":[{"label":"Performance","color":"green"}],"text":"Silicone ou Nylon/UltraFit, secam rápido e resistem ao suor."},
    {"title":"Quer usar no trabalho ou em ocasião social","tags":[{"label":"Estilo","color":"gold"}],"text":"Couro ou metal, visual mais discreto e sofisticado."},
    {"title":"Quer trocar o visual sem trocar de relógio","tags":[{"label":"Venda casada","color":"blue"}],"text":"O próprio sistema QuickFit já é o argumento: troca em segundos, sem ferramenta, vale ter mais de uma pulseira."}
  ]}
]}
$j$::jsonb
where id = '254c2894-176b-43e5-9f56-6bdd4691db06';

update lessons
set body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<p>Pra carregar qualquer relógio ou cinta recarregável, o clipe magnético que encaixa no aparelho é sempre igual. Muda só a ponta que liga na tomada ou no computador: relógios 2022 em diante (praticamente toda a linha atual) usam cabo com ponta <strong>USB-C</strong>; aparelhos mais antigos usam ponta <strong>USB-A</strong> tradicional.</p>"},
  {"type":"banner","tone":"info","text":"Bom item de venda casada: cliente que carrega o carro ou já tem carregador USB-C em casa aproveita o mesmo cabo pro relógio."},
  {"type":"texto_rico","html":"<p><strong>Conservação dos contatos traseiros:</strong> os pinos metálicos na parte de trás do relógio (e da cinta cardíaca) são o ponto mais sensível do carregamento. Suor, água salgada e sujeira acumulada ali causam oxidação e, com o tempo, falha no carregamento.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"Limpe os contatos regularmente","tags":[{"label":"Rotina","color":"blue"}],"text":"Passe um pano seco ou levemente úmido nos pinos traseiros antes de carregar, principalmente depois de treinos com muito suor."},
    {"title":"Seque completamente após suor ou água salgada","tags":[{"label":"Antes de carregar","color":"green"}],"text":"Nunca carregue o relógio ainda molhado ou com suor fresco nos contatos. Deixe secar por completo primeiro."},
    {"title":"Enxágue após natação em água salgada","tags":[{"label":"Pós-treino","color":"blue"}],"text":"Água do mar acelera a oxidação dos contatos. Enxágue com água doce e seque bem antes de guardar ou carregar."},
    {"title":"Fique de olho em oxidação visível","tags":[{"label":"Manutenção","color":"gold"}],"text":"Se aparecer uma camada esverdeada ou esbranquiçada nos pinos, limpe com cuidado antes de tentar carregar. É isso que normalmente causa \"carregador não pega\"."}
  ]}
]}
$j$::jsonb
where id = 'ef644ba5-7905-4fa3-8a79-e90f256bdd62';

update lessons
set body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<p>A loja trabalha com exatamente duas cintas cardíacas: <strong>HRM 200</strong> (entrada) e <strong>HRM 600</strong> (topo de linha). Esta lição junta tudo sobre as duas num só lugar, porque na prática a decisão de venda é sempre a mesma pergunta: o cliente só quer frequência cardíaca precisa no peito, ou quer dados avançados de corrida e resistência real à natação?</p>"},
  {"type":"tabela","headers":["Recurso","HRM 200","HRM 600"],"rows":[
    ["Frequência cardíaca + HRV","Sim","Sim"],
    ["Dinâmica de Corrida completa","Não","Sim"],
    ["Alimenta a Potência de Corrida no pulso","Não","Sim"],
    ["Armazenamento offline debaixo d'água","Não","Sim"],
    ["Gravação autônoma sem relógio/celular por perto","Não","Até 24h, em mais de 18 modalidades"],
    ["Transmissão","ANT+ e Bluetooth","ANT+ e Bluetooth ao mesmo tempo"],
    ["Perfil de cliente","Quer só FC precisa, custo menor","Corredor sério que quer dados avançados e resistência real à natação"]
  ]},
  {"type":"texto_rico","html":"<p>O HRM 600 calcula a <strong>Dinâmica de Corrida</strong> completa: cadência, comprimento de passada, oscilação vertical, proporção vertical, tempo de contato com o solo e equilíbrio do tempo de contato, além da métrica exclusiva <strong>Step Speed Loss</strong> (perda de velocidade por passada). Ele também alimenta a <strong>Potência de Corrida</strong> exibida no pulso. A Garmin não vende um footpod dedicado só pra isso: a potência é calculada combinando o acelerômetro do relógio com os dados do HRM 600.</p>"},
  {"type":"banner","tone":"info","text":"O diferencial real do HRM 600 é o armazenamento offline debaixo d'água: como o sinal ANT+/Bluetooth não atravessa a água, a cinta guarda os dados internamente durante a natação e só sincroniza com o relógio depois que o nado termina. A cinta ainda grava sozinha por até 24h, sem relógio nem celular por perto, em mais de 18 modalidades. Nenhuma cinta de entrada como a HRM 200 faz isso."}
]}
$j$::jsonb
where id = '8ef170f6-2ccc-475b-9fc4-f236cedfc023';

update lessons
set body = $j$
{"blocks":[
  {"type":"objecao","items":[
    {"question":"O Apple Watch é mais barato e faz a mesma coisa.","answer":"Bateria é a diferença mais concreta: um Garmin de linha esportiva aguenta muitos dias sem carregar, enquanto o Apple Watch normalmente pede carga todo dia ou no máximo a cada dois. Pra quem treina ou viaja, isso muda a rotina inteira. A Garmin também construiu, ao longo de mais de dez anos, uma camada própria de ciência de treino (Training Readiness, Training Load, Body Battery). O Apple Watch até registra o treino, mas não calcula com a mesma profundidade."}
  ]},
  {"type":"banner","tone":"info","text":"Nunca afirme que o Apple Watch \"não presta\": o argumento correto é diferenciação de proposta, autonomia de bateria e profundidade de ciência de treino, não desqualificar o concorrente."}
]}
$j$::jsonb
where id = '301d11f6-ec7a-4a8a-b527-93ee1e93e316';

update lessons
set body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<h3>Coros: o rival de preço</h3><p>O Coros é uma marca em crescimento no Brasil e costuma aparecer na conversa pelo gatilho do preço. É um argumento fácil de contornar quando você conhece bem os diferenciais do Garmin.</p><h3>Para quem o Coros faz sentido</h3><p>O cliente sensível a preço, que quer funcionalidades avançadas mas tem orçamento limitado, é o público principal: o Coros entrega bastante por um valor menor, e esse é o argumento central da marca.</p><p>Também se encaixam o corredor de rua ou de trilha, que não precisa de mergulho, golfe ou navegação e quer GPS preciso com métricas de corrida sem pagar por recursos premium que não vai usar; quem está comprando o primeiro relógio esportivo, nunca usou GPS e quer começar sem investir muito, já que a interface do Coros é simples e não assusta iniciantes; e quem é menos apegado a ecossistema, sem muito interesse em apps, mostradores de relógio ou integrações, e quer apenas o básico funcionando bem.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"✅ Garmin vence em","tags":[],"text":"<ul><li>Mais de 35 anos de mercado, contra uma marca fundada em 2012</li><li>Ecossistema Connect IQ maduro, com mais de 50 integrações</li><li>Variedade de modalidades: corrida, ciclismo, mergulho, golfe e náutica</li><li>FirstBeat, com análise de treino em nível profissional</li><li>Suporte presencial da Proparts, com garantia oficial no Brasil</li><li>Valor de revenda mais alto no mercado</li></ul>"},
    {"title":"❌ Coros leva em","tags":[],"text":"<ul><li>Preço de 30% a 40% menor em modelos equivalentes</li><li>Boa bateria mesmo nos modelos mais básicos</li><li>Interface simples, com curva de aprendizado menor</li></ul>"}
  ]},
  {"type":"objecao","items":[
    {"question":"O Coros é muito mais barato.","answer":"É verdade, o preço inicial é menor mesmo, e vale reconhecer isso de cara. Nunca minimize o argumento de preço do cliente: valide primeiro, depois mostre o valor. A diferença aparece no longo prazo: a Garmin tem mais de 35 anos de algoritmos de treino, suporte presencial aqui na Proparts, um ecossistema muito mais completo e o valor de revenda também é bem maior. Para quem vai usar de verdade, o retorno compensa, e a marca também tem modelos de entrada que encaixam em vários orçamentos."},
    {"question":"Vi review dizendo que o Coros é melhor para trilha.","answer":"O Coros tem bons modelos de trilha, sim, seria desonesto dizer o contrário. Mas o Garmin Instinct 3 e o Fenix 8 foram desenvolvidos com certificação militar MIL-STD-810, altímetro barométrico, bússola e bateria de semanas, e são usados por atletas profissionais de montanha no mundo inteiro. Vale mostrar essa comparação lado a lado pra ele ver a diferença técnica entre os dois."}
  ]}
]}
$j$::jsonb
where id = 'b1dbffb6-50d3-442e-a14a-3efa109f4f29';

update lessons
set body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<h3>Entenda o mercado, vença a comparação</h3><p>Cada concorrente tem um público real. Saber para quem cada marca faz sentido e onde o Garmin vence é o que separa um atendimento mediano de um atendimento que fecha venda.</p>"},
  {"type":"banner","tone":"warning","text":"A regra antes de tudo: nunca fale mal de concorrente. Quando você ataca outra marca, o cliente pensa: \"será que ele tá me enganando?\". Apresente fatos e deixe o cliente concluir sozinho. Quem conduz com confiança vende mais, não quem grita mais alto."},
  {"type":"texto_rico","html":"<h3>Apple Watch: o mais citado, e o mais mal comparado</h3><p>O Apple Watch é o principal concorrente da Garmin, com público voltado a lifestyle e usuários de iPhone.</p><h3>Para quem o Apple Watch faz sentido</h3><p>O usuário de iPhone que quer uma extensão do celular no pulso, com notificações, Apple Pay, Siri e integração total com o ecossistema Apple, é o público natural do Apple Watch.</p><p>Também faz sentido para quem tem um perfil de lifestyle urbano, que usa o relógio no dia a dia e não como ferramenta de treino, praticando esporte apenas ocasionalmente, como uma caminhada ou corrida casual. Some a esse grupo quem valoriza praticidade acima de tudo, carregando o relógio toda noite sem se incomodar e sem fazer atividades longas (então a bateria curta não é um problema real para ele), e quem busca um presente de status: um produto premium, reconhecível, de design moderno, para quem já usa iPhone.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"✅ Garmin vence em","tags":[],"text":"<ul><li>Bateria: 30h a mais de 70h com GPS ativo, contra 6 a 18h do Apple Watch</li><li>Autonomia no dia a dia: 7 a 26 dias, contra 1 a 2 dias</li><li>GPS multibanda, mais preciso em mata fechada e áreas urbanas</li><li>Compatibilidade com iOS e Android</li><li>Análise de treino com FirstBeat, em nível profissional</li><li>Resistência: até 100 metros de profundidade + certificação MIL-STD</li></ul>"},
    {"title":"❌ Apple Watch leva em","tags":[],"text":"<ul><li>Integração total com iPhone e apps Apple</li><li>Interface mais intuitiva para quem não é atleta</li><li>Apple Pay amplamente adotado</li><li>Design reconhecido como símbolo de status social</li></ul>"}
  ]},
  {"type":"objecao","items":[
    {"question":"O Apple Watch faz a mesma coisa.","answer":"Para uso do dia a dia e notificações, sim, os dois funcionam bem. A diferença aparece quando o cliente vai para a atividade física: o Garmin tem bateria de dias com GPS ligado, enquanto o Apple Watch precisa ser carregado todo dia. Quem corre, pedala ou vai para a trilha sente essa diferença já na primeira semana. 💡 Vale perguntar antes: \"você usa mais para esporte ou no dia a dia?\". Assim a resposta fica ainda mais direcionada."},
    {"question":"O Apple Watch é mais bonito.","answer":"O design dele é realmente muito bom. Se o uso for mais social e de dia a dia, pode fazer sentido escolher o Apple Watch. Mas se o cliente pratica esporte com frequência, o Garmin foi construído para isso, e também tem modelos com tela AMOLED bonita, como o Venu 4 ou o Forerunner 265. Vale a pena mostrar como fica no pulso."},
    {"question":"Só uso iPhone, o Apple Watch não integra melhor?","answer":"O Garmin Connect funciona perfeitamente no iPhone, com notificações, chamadas e músicas, e ainda conecta com Strava, TrainingPeaks, Spotify e outros apps que o cliente já usa. O que muda é que, no treino, o Garmin entrega muito mais dados do que o Apple Watch consegue."}
  ]}
]}
$j$::jsonb
where id = 'bf62691d-d5b5-4a40-9c85-801840daa203';

update lessons
set body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<h3>Polar: o rival técnico</h3><p>A Polar tem tradição em análise de treino e é o concorrente técnico da Garmin, com público de atletas que já têm algum histórico de treino estruturado.</p><h3>Para quem a Polar faz sentido</h3><p>O atleta mais científico, que quer análise profunda de frequência cardíaca e zonas de treino e já está acostumado com o Polar Flow, é o perfil típico.</p><p>Também se encaixam o corredor ou ciclista dedicado, focado em métricas avançadas e que costuma treinar com coach e precisar exportar dados; o cliente fidelizado à marca, que já teve um Polar antes, está satisfeito com a análise e pode estar comparando antes de comprar a próxima versão; e o usuário do cinto cardíaco Polar H10, considerado o mais preciso do mercado, que busca um relógio compatível com ele.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"✅ Garmin vence em","tags":[],"text":"<ul><li>Ecossistema Connect IQ, com centenas de apps e mostradores de relógio</li><li>GPS multibanda já em modelos intermediários</li><li>Variedade de modalidades: corrida, mergulho, golfe, náutica e aviação</li><li>Mais de 50 integrações, incluindo Strava, Spotify, TrainingPeaks e Garmin Pay</li><li>Suporte presencial no Brasil via Proparts</li><li>FirstBeat, o padrão de análise de treino em nível profissional</li></ul>"},
    {"title":"❌ Polar leva em","tags":[],"text":"<ul><li>O cinto H10, ainda referência em precisão de frequência cardíaca</li><li>O Polar Flow, com boa visualização de dados históricos</li><li>Tradição acadêmica da marca em fisiologia do exercício</li></ul>"}
  ]},
  {"type":"objecao","items":[
    {"question":"Já usei Polar e gostei bastante.","answer":"Faz sentido, a Polar tem boa tradição em análise de treino. O Garmin seguiu na mesma direção com o FirstBeat, a mesma tecnologia usada por times profissionais, e o ecossistema Connect é bem mais amplo: apps, mostradores de relógio e integrações com tudo que o cliente já usa. Vale convidar para experimentar um Garmin na mão e comparar. 💡 Nessa conversa, não force a migração: ouça, reconheça o que a pessoa já gosta e mostre o que o Garmin oferece. Quem decide é o cliente, sua função é informar bem."},
    {"question":"A análise de frequência cardíaca da Polar é melhor.","answer":"O cinto H10 deles é muito bom mesmo, continua sendo referência. Mas o Garmin também tem cintos de peito compatíveis para quem quer máxima precisão, e os sensores de pulso Elevate Gen 5 melhoraram bastante. Para uma análise completa, com zonas de treino, VO2 Max e Training Readiness, o Garmin está no mesmo nível ou acima."}
  ]}
]}
$j$::jsonb
where id = '9aff06b8-cbd7-4464-889f-5f3c2b3be8f3';

-- ============================================================
-- 2. Perguntas de quiz — corrige travessão e vocabulário nas explicações
-- ============================================================

update questions set explanation = 'Silicone ou Nylon/UltraFit: impermeáveis, resistem ao suor e secam rápido. Couro e metal não são recomendados pra treino intenso.'
where id = 'a1b2c3d4-0002-4a1a-9a1a-110000000002';

update questions set explanation = 'Não: usam Quick Release, o pino de mola padrão da indústria. É um sistema diferente do QuickFit, mesmo quando a largura coincide.'
where id = 'a1b2c3d4-0004-4a1a-9a1a-110000000004';

update questions set explanation = 'Um relógio compatível, como o Forerunner 970, combinado com a cinta HRM 600: as duas métricas exigem esse combo de hardware.'
where id = 'b2c3d4e5-0005-4b2b-9b2b-111000000005';

update questions set explanation = 'A certificação é feita com água limpa em temperatura ambiente. Água quente, vapor e sauna alteram a pressão interna e podem vencer a vedação. Dano por água fora dos limites certificados geralmente não tem cobertura de garantia.'
where id = '151f163b-e1dc-4d04-a367-1d599297fdf9';

-- ============================================================
-- 3. Biblioteca (content_library) — corrige travessão e vocabulário
-- ============================================================

update content_library
set summary = 'Garmin Connect é o app de sincronização: recebe dados do relógio e integra com Strava, Apple Health etc.',
    payload = jsonb_set(payload, '{a}', to_jsonb('Garmin Connect é o app de sincronização, recebe dados do relógio e integra com Strava, Apple Health etc. Connect IQ é a loja de apps que rodam DENTRO do relógio, como Spotify, Wikiloc e Woo.'::text))
where id = '4d3409f4-fc35-469e-9cf6-2a65f1bf2287';

update content_library
set summary = 'O HRM 200 é para corrida e ciclismo, não armazena atividades.'
where id = '4abe7a6c-b1c0-4bc0-aa50-d7094ba05aa3';

update content_library
set summary = 'O inReach usa a rede de satélites Iridium®, que oferece cobertura global de 100% do planeta, incluindo oceanos, polos e áreas sem qualquer cobertura de celular.',
    payload = jsonb_set(payload, '{q}', to_jsonb('Qual rede de satélites o inReach usa?'::text))
where id = '720ee621-19a8-44fc-8310-12c0937f955d';

update content_library
set summary = 'Pedala com frequência: estrada, MTB ou casual',
    payload = jsonb_set(payload, '{tag}', to_jsonb('Pedala com frequência, estrada, MTB ou casual'::text))
where id = 'bdedd53d-b20a-4d69-a7b8-4151d08a5eaf';

-- Guia completo do Edge (JSON grande demais pra reescrever por inteiro com
-- segurança) — troca pontual da única ocorrência de "Além disso" por texto
-- corrido, via replace() no payload inteiro.
update content_library
set payload = (replace(
  payload::text,
  'e não depende de sinal para o GPS funcionar. Além disso, o celular não tem ClimbPro, GroupRide nem Guia de Energia.',
  'e não depende de sinal para o GPS funcionar. O celular também não tem ClimbPro, GroupRide nem Guia de Energia.'
))::jsonb
where id = '56f1fd07-f877-4288-8362-710dd9300c19';

-- ============================================================
-- 4. Quiz — corrige padrão de posição da resposta certa (embaralha
--    order_index de todas as alternativas, sem alterar nenhum texto).
-- ============================================================

with shuffled as (
  select id, row_number() over (partition by question_id order by random()) - 1 as new_order
  from alternatives
)
update alternatives a
set order_index = s.new_order
from shuffled s
where a.id = s.id;

-- ============================================================
-- 5. Quiz — reescreve distratores das 12 perguntas com maior desequilíbrio
--    de tamanho entre a resposta certa e as erradas (giveaway de tamanho),
--    deixando as alternativas erradas mais plausíveis e parecidas em tamanho
--    com a certa, sem mudar qual é a resposta certa nem os fatos.
-- ============================================================

update alternatives set body = 'Pedir pra ela guardar o celular na hora e insistir que os preços são idênticos em qualquer lugar' where id = 'c3b2b3e9-fb87-48be-95ee-2dfef676400d';
update alternatives set body = 'Sugerir que ela compre online mesmo se achar mais barato, e volte à loja depois se tiver algum problema com o produto' where id = 'aa1c93eb-caf6-4864-8978-dfb47798f07e';
update alternatives set body = 'Alertar de forma alarmista que qualquer compra pela Amazon corre risco de não ter garantia nenhuma no Brasil' where id = 'caaae463-bbf4-4dc8-aa4d-bfe788f80f43';

update alternatives set body = 'Dizer que o Coros tem qualidade inferior e que preço baixo esconde algum motivo, sem citar nenhum dado concreto' where id = '36eea475-a19d-4d12-99dd-a9cbf856ec99';
update alternatives set body = 'Oferecer parcelamento extra só pra igualar o valor do Coros e fechar a venda o mais rápido possível' where id = '0bf4b85c-4355-4bae-9ad8-177a3c9439b1';
update alternatives set body = 'Ignorar a comparação de preço e só listar as especificações técnicas do Garmin, sem responder ao que ele perguntou' where id = '06954841-3f1f-4aff-8e54-cbcf37bacb12';

update alternatives set body = 'Dizer que o criador do canal provavelmente foi patrocinado pela marca, sem ter como provar isso' where id = '6eda34b2-6d0a-4420-a417-f5514bcb0f46';
update alternatives set body = 'Concordar totalmente com o review e mudar de assunto pra outro esporte onde o Garmin se destaca mais' where id = '683c48b6-bbdc-4fd4-bcbf-921aa1038fd4';
update alternatives set body = 'Falar que vídeo de YouTube não é fonte confiável e que ele não deveria se basear nesse tipo de conteúdo' where id = '5a4c6d55-fa0b-45ed-825e-cfca1513c744';

update alternatives set body = 'Dizer que é só uma sugestão genérica do relógio e que pode ser ignorada sem problema nenhum' where id = '43c86600-db36-4e79-9aec-fb81e4f9c81d';
update alternatives set body = 'Sugerir que ele desligue essa função do relógio, já que ela está incomodando sem necessidade' where id = 'd8c23e46-63fe-4d8d-ac2b-7b600c004d21';
update alternatives set body = 'Afirmar que o relógio está com defeito e sugerir que ele leve pra assistência técnica' where id = '015e7755-7791-455b-9c20-f9a60e059a0f';

update alternatives set body = 'Dizer sem rodeios que o Galaxy Watch não presta pra treino e que o Garmin é claramente superior em tudo' where id = '12d805ea-476c-464a-892c-92ac761e6bdf';
update alternatives set body = 'Concordar de cara que pra quem já tem Samsung o Galaxy Watch é sempre a escolha que faz mais sentido' where id = '3a4dd3a4-ecbc-43ff-bcde-69fec119a6eb';

update alternatives set body = 'É o modelo mais barato de toda a linha MARQ, focado em quem quer economizar' where id = '752d9b46-e97e-4404-b045-1f5d624279f3';
update alternatives set body = 'Não tem modo caddie digital, só mostra distância básica até a bandeira' where id = 'c03bf180-5327-4c19-8d54-ccdfa84be028';
update alternatives set body = 'É feito do mesmo titânio usado no MARQ Commander, sem nenhuma diferença de material' where id = 'c1220ecf-3034-4117-8a61-20faaa3f58a6';

update alternatives set body = 'Dizer sem rodeios que a Polar ficou pra trás no mercado e que ela vai notar a diferença logo de cara' where id = '5cd9dcbb-150c-4e3f-94c2-81da035ab36f';
update alternatives set body = 'Oferecer um desconto direto pra fechar a venda na hora, antes que ela saia da loja pra pensar' where id = '40eb6273-de34-491c-bdf9-c15fe800dde4';
update alternatives set body = 'Falar só bem da Polar e sugerir que ela volte outro dia quando estiver mais decidida' where id = '1503cd95-2066-4e15-918b-1601979d8f8f';

update alternatives set body = 'Dizer que a cinta é obrigatória pra qualquer uso do relógio, mesmo sem métrica avançada nenhuma' where id = '445ca1f5-5131-48c4-acf6-28c951fa1500';
update alternatives set body = 'Afirmar que o sensor de pulso não funciona pra nenhuma métrica, nem frequência cardíaca básica' where id = '3fd0ef82-f4d1-4af9-bd3d-fabe7cff7800';
update alternatives set body = 'Recomendar que ele não use nenhum sensor de frequência cardíaca, já que o pulso resolveria tudo' where id = 'ee774fe3-9807-4fdc-8dd5-787c5f3a3349';

update alternatives set body = 'É um tipo de alongamento específico, feito só na manhã do dia da prova' where id = '7ae0341e-fdfb-4b41-835a-6086a3196414';
update alternatives set body = 'É a fase do plano em que o atleta troca de treinador pra variar o estímulo' where id = '80b8b320-2b2c-4741-b09b-4ec915878837';

update alternatives set body = 'Porque o GPS multibanda não permite leitura instantânea durante o treino guiado' where id = '84f8d5d0-11b2-4216-a7fe-f71d3884119c';
update alternatives set body = 'É uma limitação de bateria do relógio nesse tipo específico de treino' where id = 'ccea6b55-7886-4578-9be9-85b20eb12cb0';
update alternatives set body = 'Só ocorre em modelos de entrada, como o Forerunner 55, não nos modelos mais avançados' where id = '3fceec32-0049-4b71-9027-4bbb73355cbb';

update alternatives set body = 'Sim, o Forerunner 55 tem 4 GB de armazenamento de música interno' where id = '80aa2934-eded-45e8-965c-c58ddf1683f6';
update alternatives set body = 'Sim, o Forerunner 55 tem 8 GB de armazenamento de música interno' where id = 'dede012b-d96b-43e9-80a1-bf64ff75624d';
update alternatives set body = 'Sim, mas só consegue tocar música via Bluetooth, sem armazenar nada internamente' where id = '10846799-a246-40c9-85b7-3f1ffd110f69';

update alternatives set body = 'É uma certificação só de resistência à água, sem cobrir impacto ou temperatura' where id = '2b64d2a5-7944-4a58-ac87-a5434174ea3e';
update alternatives set body = 'É o nível de precisão do GPS em trilhas fechadas, medido em metros' where id = 'e91b0a4a-181c-4715-9369-a94c93c223d9';
update alternatives set body = 'É o padrão oficial de duração de bateria usado em relógios de uso militar' where id = 'b0a391f1-0cb9-45be-be8a-a701f1b020a4';

-- ============================================================================
-- FIM DA MIGRAÇÃO 114
-- ============================================================================
