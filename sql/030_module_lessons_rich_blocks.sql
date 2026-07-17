-- ============================================================================
-- GARMIN TRAINING HUB — 030: RECONSTRUÇÃO ESTRUTURAL DAS LIÇÕES DOS 6 MÓDULOS
-- ============================================================================
-- Mesma correção já aplicada em content_library (028/029), agora nas 22
-- lições reais dos 6 módulos de treinamento (Universo Garmin, Perfis de
-- Cliente, Portfólio de Produtos, Concorrentes & Objeções, Garmin Connect,
-- Garmin Coach). Todas estavam achatadas num único bloco texto_rico de
-- prosa corrida — esta migração reestrutura o MESMO texto (sem inventar
-- conteúdo novo) usando os 12 tipos de bloco já existentes em
-- ContentBlocks.js: timeline, card_grid, tabela, roteiro, objecao, banner,
-- card, texto_rico.
--
-- Widgets genuinamente interativos do protótipo original (simulador de
-- ritmo com slider, árvore de decisão de diagnóstico, flip-cards 3D,
-- accordion de marca com abertura exclusiva, quiz de cenários) não têm
-- equivalente direto no schema de blocos — são ferramentas com lógica
-- própria, não estrutura de conteúdo. Preservamos a INFORMAÇÃO deles de
-- forma fiel (ex.: a árvore de decisão de 7 desfechos vira uma tabela
-- "situação → plano indicado"; os 3 treinadores viram card_grid), mas não
-- recriamos a interação em si — mesma abordagem já usada para os flip-cards
-- de "Novidades 2026" em 028/029.
--
-- Garmin Connect e Garmin Coach têm cada lição triplicada (bug de dados
-- pré-existente, documentado no ROADMAP.md) — 3 UUIDs por título, mesmo
-- conteúdo. Esta migração atualiza as 3 linhas de cada título com blocos
-- idênticos (não deduplica; isso é uma limpeza separada, fora de escopo
-- aqui).
-- ============================================================================

-- ============================================================================
-- MÓDULO 1 — O UNIVERSO GARMIN
-- ============================================================================

-- 1.1 A história da marca Garmin
update lessons set body = jsonb_build_object('blocks', $m1a$
[
  {"type":"texto_rico","html":"<p>Entenda a história, os valores e por que a Garmin vence a cada venda. Um consultor que conhece a marca por trás do produto vende com confiança, e o cliente sente isso.</p>"},
  {"type":"timeline","items":[
    {"label":"1989","text":"Gary Burrell e Min Kao fundam a empresa em Lenexa, no Kansas (EUA). O próprio nome da empresa vem da junção dos nomes dos fundadores: Gary mais Min formam Garmin. O foco inicial era GPS para aviação."},
    {"label":"1991","text":"A empresa lança o primeiro receptor GPS portátil para consumidores, levando ao mercado civil uma tecnologia que até então era restrita ao uso militar."},
    {"label":"2003","text":"A Garmin lança o primeiro Forerunner, um relógio GPS voltado para corredores, e passa a ter presença direta no pulso dos atletas."},
    {"label":"2015","text":"Lançamento do Forerunner 235, o primeiro relógio Garmin a combinar sensor óptico de frequência cardíaca no pulso com GPS integrado. O modelo vendeu mais de 1 milhão de unidades."},
    {"label":"2024–25","text":"A marca lança o Fenix 8, o Forerunner 970, o Edge 1050 e os Edge 550/850, consolidando uma liderança absoluta no mercado de wearables esportivos premium."}
  ]}
]
$m1a$::jsonb)
where id = 'd36bd707-2b10-4567-9b43-62f8451a24cf';

-- 1.2 Por que a Garmin vence
update lessons set body = jsonb_build_object('blocks', $m1b$
[
  {"type":"texto_rico","html":"<p>Quatro fatores explicam por que a Garmin lidera o mercado de wearables esportivos.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"Especialização real","text":"A Garmin não é uma empresa que \"também faz relógio\". GPS e precisão de posicionamento são o core business da marca há mais de 35 anos.","tags":[]},
    {"title":"Ecossistema inigualável","text":"Entre o Garmin Connect, o Connect IQ e mais de 50 integrações, o atleta que usa Garmin tem todos os seus dados reunidos num só lugar, ano após ano.","tags":[]},
    {"title":"Bateria que liberta","text":"Enquanto os concorrentes costumam durar de 1 a 2 dias, um Garmin dura semanas. Essa diferença é o que permite monitorar o sono todas as noites, em vez de precisar carregar o relógio toda noite.","tags":[]},
    {"title":"Durabilidade e confiança","text":"Certificação MIL-STD-810, cristal de safira nas linhas premium e resistência à água. Com cuidados básicos, um Garmin dura de 5 a 8 anos.","tags":[]}
  ]}
]
$m1b$::jsonb)
where id = '56c27271-7b9c-4b2e-a68c-f4076cf1480d';

-- 1.3 As 5 tecnologias que você precisa dominar
update lessons set body = jsonb_build_object('blocks', $m1c$
[
  {"type":"texto_rico","html":"<p>Essas cinco tecnologias aparecem em praticamente toda conversa de venda. Domine os argumentos abaixo antes de atender o próximo cliente.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"📡 GPS multibanda","text":"É o diferencial mais fácil de explicar para o cliente: o relógio traça exatamente o caminho percorrido, mesmo em cidade cercada de prédios ou dentro de mata fechada. Está disponível a partir do Forerunner 265.","tags":[]},
    {"title":"🧠 FirstBeat e VO2 Max","text":"O relógio calcula a capacidade aeróbica do usuário e indica se ele está evoluindo ou sobrecarregado. É o cérebro do Garmin, a base científica por trás de toda a análise de treino.","tags":[]},
    {"title":"🔋 Body Battery","text":"Funciona como um indicador de bateria do próprio corpo, numa escala de 0 a 100. Sobe com sono bom e cai com estresse e exercício, ajudando o usuário a saber quando treinar forte e quando descansar.","tags":[]},
    {"title":"😴 Monitoramento de sono","text":"O relógio registra cada fase do sono (leve, profunda e REM) e entrega uma pontuação pela manhã. Para quem busca qualidade de vida, essa métrica costuma valer mais do que qualquer dado de treino.","tags":[]},
    {"title":"💳 Garmin Pay","text":"Permite pagar no café depois do treino sem precisar tirar o celular do bolso, só com o relógio, e funciona nos principais bancos brasileiros.","tags":[]}
  ]}
]
$m1c$::jsonb)
where id = '6bb615c1-d4f1-41e3-a3c3-e8c2929a8a94';

-- ============================================================================
-- MÓDULO 2 — PERFIS DE CLIENTE
-- ============================================================================

-- 2.1 Perfis de corrida
update lessons set body = jsonb_build_object('blocks', $m2a$
[
  {"type":"texto_rico","html":"<p>Identificar o perfil certo é a diferença entre vender o produto perfeito e perder a venda. Comece pelos três perfis mais comuns entre corredores.</p>"},
  {"type":"card","icon":"🏃","title":"Corredor Iniciante","text":"Começa a correr agora ou está retornando ao esporte depois de um tempo parado. Nunca usou GPS e quer algo simples para monitorar tempo e distância.<br><br><strong>Como identificar:</strong><ul><li>Nunca usou relógio GPS</li><li>Fala em \"começar a correr\"</li><li>Pergunta qual é o modelo mais simples</li><li>Quer monitorar tempo e distância</li></ul><strong>Como apresentar:</strong><ul><li>Forerunner 55: a porta de entrada ideal</li><li>Forerunner 165: tela AMOLED já desde o início</li><li>Fale dos planos de treino adaptativos</li><li>Mostre como a sincronização com o celular é fácil</li></ul>Produto principal: <strong>Forerunner 55</strong>. Também considere o Forerunner 165."},
  {"type":"card","icon":"🏅","title":"Corredor Dedicado","text":"Treina com frequência, corre três vezes ou mais por semana e busca evolução constante.<br><br><strong>Como identificar:</strong><ul><li>Fala em ritmo, pace, PR</li><li>Corre três ou mais vezes por semana</li><li>Pergunta por GPS multibanda</li><li>Menciona VO2 Max</li></ul><strong>Como apresentar:</strong><ul><li>Forerunner 265 ou 570: GPS multibanda completo</li><li>Fale do Training Readiness</li><li>PacePro para estratégia de prova</li><li>Destaque a integração com Strava e TrainingPeaks</li></ul>Produto principal: <strong>Forerunner 265</strong>. Também considere o Forerunner 570 e o Forerunner 955."},
  {"type":"card","icon":"🏆","title":"Atleta de Elite / Triatleta","text":"Tem alto volume de treino e compete em triathlon ou provas de ultra, treinando 10 horas ou mais por semana.<br><br><strong>Como identificar:</strong><ul><li>Menciona triathlon, Ironman, ultra</li><li>Pede bateria de 30 horas ou mais de GPS real</li><li>Já tem relógio e está buscando um upgrade</li><li>Treina 10 horas ou mais por semana</li></ul><strong>Como apresentar:</strong><ul><li>Forerunner 965 ou 970: ferramentas de triatleta</li><li>Fenix 8 para quem também faz atividades outdoor</li><li>Bateria de 30 horas ou mais com GPS de alta precisão</li><li>Training Readiness para periodização de treino</li></ul>Produto principal: <strong>Forerunner 970</strong>. Também considere o Forerunner 965 e o Fenix 8."}
]
$m2a$::jsonb)
where id = '94bb47ef-1fd6-4d07-97ff-e5c6b226e47f';

-- 2.2 Perfis outdoor, lifestyle e especialidades
update lessons set body = jsonb_build_object('blocks', $m2b$
[
  {"type":"texto_rico","html":"<p>Além dos corredores, oito outros perfis aparecem com frequência na loja. Cada um tem sinais próprios e uma forma diferente de apresentar o produto.</p>"},
  {"type":"card","icon":"🌿","title":"Aventureiro / Trilheiro","text":"Ama trilhas, camping e expedições. Quer resistência de nível militar, bateria longa e mapas topográficos offline.<br><br><strong>Como identificar:</strong><ul><li>Fala de trilha, serra, montanha</li><li>Pede GPS com mapa topográfico</li><li>Quer resistência e bateria longa</li><li>Menciona acampamento ou expedição</li></ul><strong>Como apresentar:</strong><ul><li>Instinct 3: certificação MIL-STD-810 e 26 dias de bateria</li><li>Fenix 8 para quem quer o máximo em outdoor</li><li>Mapas TopoActive e trilhas offline</li><li>inReach para expedições sem sinal</li></ul><strong>MIL-STD-810</strong> é a certificação militar americana de resistência a impacto, temperatura extrema, umidade, altitude e vibração.<br><br>Produto principal: <strong>Instinct 3</strong>. Também considere o Fenix 8 e o Enduro 3."},
  {"type":"card","icon":"💎","title":"Mulher Lifestyle","text":"Quer design elegante com funções inteligentes. Costuma comparar com o Apple Watch em termos de design e valoriza recursos de saúde feminina.<br><br><strong>Como identificar:</strong><ul><li>Pede um relógio menor ou mais bonito</li><li>Quer acompanhamento de saúde feminina, como o ciclo menstrual</li><li>Está comprando de presente</li><li>Compara com o Apple Watch no design</li></ul><strong>Como apresentar:</strong><ul><li>Lily 2: o menor e mais elegante, com design de joia</li><li>Lily 2 Active: a mesma Lily, agora com GPS integrado</li><li>Venu 4: tela AMOLED premium com saúde feminina completa</li><li>Fale sobre acompanhamento de ciclo, gravidez e menopausa no Garmin</li></ul>Produto principal: <strong>Lily 2 Active</strong>. Também considere o Lily 2, o Vivoactive 6 e o Venu 4."},
  {"type":"objecao","items":[
    {"question":"O Apple Watch tem mais funções de smartwatch.","answer":"O Lily 2 Active tem GPS integrado e bateria de até 7 dias, enquanto o Apple Watch dura de 1 a 2 dias com GPS ligado. Para quem não quer carregar o relógio todo dia, o Garmin vence."}
  ]},
  {"type":"card","icon":"🚴","title":"Ciclista","text":"Pedala com frequência, seja estrada, mountain bike ou uso casual. Quer GPS no guidão e métricas de cadência ou potência.<br><br><strong>Como identificar:</strong><ul><li>Menciona bike, MTB, estrada, gravel</li><li>Pergunta por GPS para o guidão</li><li>Fala de Strava, subidas, cadência</li><li>Quer medir cadência ou potência</li></ul><strong>Como apresentar:</strong><ul><li>Edge 540 ou 840: GPS no guidão</li><li>Varia RTL515: radar traseiro que detecta carros a 140 metros</li><li>Rally RK 200: pedal medidor de potência SPD</li><li>Forerunner 955 ou Fenix 8 para quem faz multiesporte</li></ul>Potência é a métrica mais honesta do ciclismo: não é afetada por cansaço, calor ou adrenalina.<br><br>Produto principal: <strong>Edge 850</strong>. Também considere o Edge 550, o Edge 1050, o Varia RTL515 e o Rally RK 200."},
  {"type":"card","icon":"🏊","title":"Nadador / Triatleta","text":"<strong>Como identificar:</strong><ul><li>Fala de piscina, mar, braçadas</li><li>Quer SWOLF ou eficiência de braçada</li><li>Menciona triathlon ou duathlon</li></ul><strong>Como apresentar:</strong><ul><li>Forerunner 965 ou 970: natação, ciclismo e corrida no mesmo relógio</li><li>Fenix 8 para o triatleta que quer o pacote mais completo</li><li>HRM 600 para medir a frequência cardíaca dentro da água</li></ul>Produto principal: <strong>Forerunner 955</strong>. Também considere o Forerunner 965, o Fenix 8 e o HRM 600."},
  {"type":"card","icon":"🤿","title":"Mergulhador","text":"<strong>Como identificar:</strong><ul><li>Menciona profundidade, NDL, nitrox</li><li>Pergunta sobre computador de mergulho</li><li>Fala de mergulho técnico</li></ul><strong>Como apresentar:</strong><ul><li>Descent G2: smartwatch completo com funções de mergulho</li><li>Descent Mk3i para quem mergulha técnico e exige mais</li><li>Descent X30 com autonomia de gás</li></ul>Produto principal: <strong>Descent G2</strong>. Também considere o Descent Mk3i e o Descent X30."},
  {"type":"card","icon":"⛳","title":"Golfista","text":"<strong>Como identificar:</strong><ul><li>Fala de green, par, bunker, handicap</li><li>Pergunta por GPS de golfe</li></ul><strong>Como apresentar:</strong><ul><li>Approach S44: entrada, com mais de 42 mil campos mapeados</li><li>Approach S50: tela AMOLED e experiência completa</li></ul>Produto principal: <strong>Approach S50</strong>. Também considere o Approach S44."},
  {"type":"card","icon":"🏍️","title":"Motociclista","text":"<strong>Como identificar:</strong><ul><li>Fala de viagem de moto, rota, estrada</li><li>Pergunta por GPS para moto</li></ul><strong>Como apresentar:</strong><ul><li>Zumo XT2: GPS específico para moto</li><li>O roteamento evita ruas proibidas para motos</li></ul>Produto principal: <strong>Zumo XT2</strong>."},
  {"type":"card","icon":"🎣","title":"Pescador / Náutico","text":"<strong>Como identificar:</strong><ul><li>Menciona pesca em represa, rio ou mar</li><li>Fala de barco, canoa, lancha</li></ul><strong>Como apresentar:</strong><ul><li>Striker 4: entrada para quem está começando na pesca</li><li>Striker Vivid 5cv com tecnologia ClearVü</li><li>ECHOMAP UHD2 com mapas náuticos completos</li></ul>Produto principal: <strong>Striker Vivid 5cv</strong>. Também considere o Striker 4 e o ECHOMAP UHD2 52cv."}
]
$m2b$::jsonb)
where id = '745d31e5-6b31-411c-bbe0-c7e5b2ef3919';

-- 2.3 Como sondar e identificar o cliente certo
update lessons set body = jsonb_build_object('blocks', $m2c$
[
  {"type":"texto_rico","html":"<p>Depois de conhecer os perfis, o próximo passo é saber como descobrir, na prática, qual deles está na sua frente.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"🎯 As três perguntas essenciais","text":"<ul><li><strong>\"Qual atividade você pratica?\"</strong> define a linha de produto.</li><li><strong>\"Você já tem relógio GPS?\"</strong> define o nível de entrada.</li><li><strong>\"O que você quer monitorar?\"</strong> alinha a expectativa com o produto.</li></ul>","tags":[]},
    {"title":"⚡ Erros a evitar","text":"<ul><li>Oferecer o produto mais caro sem sondar o perfil do cliente</li><li>Focar em especificações técnicas antes de entender a necessidade real</li><li>Ignorar sinais visuais, como roupa, acessórios e vocabulário</li><li>Não perguntar para quem é o presente</li></ul>","tags":[]}
  ]},
  {"type":"banner","tone":"info","text":"<strong>Regra de ouro:</strong> O cliente sempre revela o perfil dele. Preste atenção ao vocabulário que ele usa, como \"pace\", \"Ironman\", \"trilha\", \"par\" ou \"braçada\", e você já sabe qual linha indicar antes mesmo de perguntar."}
]
$m2c$::jsonb)
where id = '4e259942-be34-46f3-b264-42c681a29e8c';

-- ============================================================================
-- MÓDULO 3 — PORTFÓLIO DE PRODUTOS
-- ============================================================================

-- 3.1 Linha Forerunner: do iniciante ao elite
update lessons set body = jsonb_build_object('blocks', $m3a$
[
  {"type":"texto_rico","html":"<p>Dominar o portfólio Garmin é saber indicar o produto certo sem hesitar. Este módulo passa por cada linha, seus modelos e para quem cada um serve.</p><p>A linha Forerunner é voltada para corrida, triathlon e fitness, cobrindo do iniciante ao atleta de elite. É a porta de entrada mais natural para quem está começando com GPS esportivo, mas também tem modelos de ponta para quem compete sério.</p>"},
  {"type":"tabela","headers":["Modelo","Tier","Descrição"],"rows":[
    ["Forerunner 70","Entrada","Modelo novo, com GPS, monitor de frequência cardíaca e Garmin Pay. Compacto e com até 11 dias de bateria — porta de entrada com estilo."],
    ["Forerunner 55","Entrada","O clássico da entrada, com GPS, sensor óptico de frequência cardíaca, planos de treino, Body Battery e monitoramento de sono."],
    ["Forerunner 165","Intermediário","Tela AMOLED, planos de treino adaptativos e treino de força. Boa relação custo-benefício com tela premium."],
    ["Forerunner 170","Intermediário","Modelo novo, com tela AMOLED e sensor Elevate Gen 4, mais compacto que o 165. Relatório noturno, despertador inteligente, registro de estilo de vida e calculadora, além de mais perfis de atividade. Não tem GPS multibanda nem modo triathlon."],
    ["Forerunner 265","Intermediário","Tela AMOLED, GPS multibanda e Training Readiness. É o melhor modelo intermediário da linha."],
    ["Forerunner 570","Dedicado / Elite","Lançado em 2025, com tela AMOLED, GPS SatIQ e sensor Elevate Gen 5. Feito para treino intervalado de alta precisão."],
    ["Forerunner 955","Elite","Até 30h de GPS, mapas topográficos e solar opcional. É a referência de custo-benefício para triatletas."],
    ["Forerunner 965","Elite","Tela AMOLED, caixa em titânio, mapas e até 31h de GPS. É o modelo top de corrida com tela premium."],
    ["Forerunner 970","Elite","Cristal de safira, lanterna LED e 32GB de armazenamento. É o topo absoluto da linha Forerunner."]
  ]}
]
$m3a$::jsonb)
where id = '3405fe07-5dd7-4599-9392-17c9155a1400';

-- 3.2 Linha Fenix: multiesporte premium para outdoor
update lessons set body = jsonb_build_object('blocks', $m3b$
[
  {"type":"texto_rico","html":"<p>A linha Fenix é o multiesporte premium da Garmin, pensada para quem pratica atividades outdoor, aventura e busca alta performance.</p>"},
  {"type":"tabela","headers":["Modelo","Tier","Descrição"],"rows":[
    ["Fenix E","Entrada","Modelo novo e entrada da linha Fenix. Tela AMOLED, GPS padrão e mapas TopoActive, com design robusto. Não tem alto-falante, microfone nem GPS multibanda — a porta de entrada para quem quer um Fenix com orçamento menor."],
    ["Fenix 8 (47mm / 51mm)","Elite / Outdoor","O multiesporte definitivo da linha. Tela AMOLED, alto-falante, microfone, modo mergulho de até 10 ATM e mapas completos. A versão 51mm tem opção solar."],
    ["Fenix 8 AMOLED Sapphire","Elite Premium","Versão top da linha, com cristal de safira para máxima resistência a arranhões e acabamento premium, reunindo todos os recursos do Fenix 8."]
  ]}
]
$m3b$::jsonb)
where id = '2aa7a7af-19e2-4d02-94b6-81de1bc9460f';

-- 3.3 Linha MARQ (Gen 2): relógios de luxo Garmin
update lessons set body = jsonb_build_object('blocks', $m3c$
[
  {"type":"texto_rico","html":"<p>A linha MARQ reúne os relógios de luxo artesanais da Garmin, para quem quer o melhor dos dois mundos: alta performance esportiva e a presença de um relógio premium no pulso.</p>"},
  {"type":"card_grid","columns":3,"items":[
    {"title":"MARQ Commander (Gen 2)","text":"Caixa em titânio e pulseira em couro italiano, com estética militar sofisticada. GPS multibanda, mapas completos e modo tático. Indicado para quem combina alto desempenho com presença no pulso.","tags":[]},
    {"title":"MARQ Athlete (Gen 2)","text":"Focado em corrida e triathlon de alto nível, em titânio com pulseira sport premium. GPS multibanda, métricas avançadas de treino e Training Readiness. Visual sofisticado para atletas que não abrem mão de estilo.","tags":[]},
    {"title":"MARQ Golfer Carbon (Gen 2)","text":"Caixa em fibra de carbono com acabamento premium. Mapas de mais de 42.000 campos de golfe, modo caddie digital, estatísticas de jogo e distâncias automáticas. É o único relógio de golfe no patamar de luxo real.","tags":[]}
  ]}
]
$m3c$::jsonb)
where id = '7d5e81d0-21a1-426a-9938-7bb667723d3c';

-- ============================================================================
-- MÓDULO 4 — CONCORRENTES & OBJEÇÕES
-- ============================================================================

-- 4.1 A regra de ouro e o Apple Watch
update lessons set body = jsonb_build_object('blocks', $m4a$
[
  {"type":"texto_rico","html":"<h3>Entenda o mercado, vença a comparação</h3><p>Cada concorrente tem um público real. Saber para quem cada marca faz sentido e onde o Garmin vence é o que separa um atendimento mediano de um atendimento que fecha venda.</p>"},
  {"type":"banner","tone":"warning","text":"<strong>A regra antes de tudo:</strong> Nunca fale mal de concorrente. Quando você ataca outra marca, o cliente pensa: \"será que ele tá me enganando?\". Apresente fatos e deixe o cliente concluir sozinho. Quem conduz com confiança vende mais, não quem grita mais alto."},
  {"type":"texto_rico","html":"<h3>Apple Watch: o mais citado, e o mais mal comparado</h3><p>O Apple Watch é o principal concorrente da Garmin, com público voltado a lifestyle e usuários de iPhone.</p><h3>Para quem o Apple Watch faz sentido</h3><p>O usuário de iPhone que quer uma extensão do celular no pulso, com notificações, Apple Pay, Siri e integração total com o ecossistema Apple, é o público natural do Apple Watch. Também faz sentido para quem tem um perfil de lifestyle urbano, que usa o relógio no dia a dia e não como ferramenta de treino, praticando esporte apenas ocasionalmente, como uma caminhada ou corrida casual. Some a esse grupo quem valoriza praticidade acima de tudo, carregando o relógio toda noite sem se incomodar e sem fazer atividades longas (então a bateria curta não é um problema real para ele), e quem busca um presente de status: um produto premium, reconhecível, de design moderno, para quem já usa iPhone.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"✅ Garmin vence em","text":"<ul><li>Bateria: 30h a mais de 70h com GPS ativo, contra 6 a 18h do Apple Watch</li><li>Autonomia no dia a dia: 7 a 26 dias, contra 1 a 2 dias</li><li>GPS multibanda, mais preciso em mata fechada e áreas urbanas</li><li>Compatibilidade com iOS e Android</li><li>Análise de treino com FirstBeat, em nível profissional</li><li>Resistência: até 100 metros de profundidade + certificação MIL-STD</li></ul>","tags":[]},
    {"title":"❌ Apple Watch leva em","text":"<ul><li>Integração total com iPhone e apps Apple</li><li>Interface mais intuitiva para quem não é atleta</li><li>Apple Pay amplamente adotado</li><li>Design reconhecido como símbolo de status social</li></ul>","tags":[]}
  ]},
  {"type":"objecao","items":[
    {"question":"O Apple Watch faz a mesma coisa.","answer":"Para uso do dia a dia e notificações, sim, os dois funcionam bem. A diferença aparece quando o cliente vai para a atividade física: o Garmin tem bateria de dias com GPS ligado, enquanto o Apple Watch precisa ser carregado todo dia. Quem corre, pedala ou vai para a trilha sente essa diferença já na primeira semana. 💡 Vale perguntar antes: \"você usa mais para esporte ou no dia a dia?\". Assim a resposta fica ainda mais direcionada."},
    {"question":"O Apple Watch é mais bonito.","answer":"O design dele é realmente muito bom. Se o uso for mais social e de dia a dia, pode fazer sentido escolher o Apple Watch. Mas se o cliente pratica esporte com frequência, o Garmin foi construído para isso, e também tem modelos com tela AMOLED bonita, como o Venu 4 ou o Forerunner 265. Vale a pena mostrar como fica no pulso."},
    {"question":"Só uso iPhone, o Apple Watch não integra melhor?","answer":"O Garmin Connect funciona perfeitamente no iPhone, com notificações, chamadas e músicas, e ainda conecta com Strava, TrainingPeaks, Spotify e outros apps que o cliente já usa. O que muda é que, no treino, o Garmin entrega muito mais dados do que o Apple Watch consegue."}
  ]}
]
$m4a$::jsonb)
where id = 'bf62691d-d5b5-4a40-9c85-801840daa203';

-- 4.2 Polar: o rival técnico
update lessons set body = jsonb_build_object('blocks', $m4b$
[
  {"type":"texto_rico","html":"<h3>Polar: o rival técnico</h3><p>A Polar tem tradição em análise de treino e é o concorrente técnico da Garmin, com público de atletas que já têm algum histórico de treino estruturado.</p><h3>Para quem a Polar faz sentido</h3><p>O atleta mais científico, que quer análise profunda de frequência cardíaca e zonas de treino e já está acostumado com o Polar Flow, é o perfil típico. Também se encaixam o corredor ou ciclista dedicado, focado em métricas avançadas e que costuma treinar com coach e precisar exportar dados; o cliente fidelizado à marca, que já teve um Polar antes, está satisfeito com a análise e pode estar comparando antes de comprar a próxima versão; e o usuário do cinto cardíaco Polar H10, considerado o mais preciso do mercado, que busca um relógio compatível com ele.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"✅ Garmin vence em","text":"<ul><li>Ecossistema Connect IQ, com centenas de apps e mostradores de relógio</li><li>GPS multibanda já em modelos intermediários</li><li>Variedade de modalidades: corrida, mergulho, golfe, náutica e aviação</li><li>Mais de 50 integrações, incluindo Strava, Spotify, TrainingPeaks e Garmin Pay</li><li>Suporte presencial no Brasil via Proparts</li><li>FirstBeat, o padrão de análise de treino em nível profissional</li></ul>","tags":[]},
    {"title":"❌ Polar leva em","text":"<ul><li>O cinto H10, ainda referência em precisão de frequência cardíaca</li><li>O Polar Flow, com boa visualização de dados históricos</li><li>Tradição acadêmica da marca em fisiologia do exercício</li></ul>","tags":[]}
  ]},
  {"type":"objecao","items":[
    {"question":"Já usei Polar e gostei bastante.","answer":"Faz sentido, a Polar tem boa tradição em análise de treino. O Garmin seguiu na mesma direção com o FirstBeat, a mesma tecnologia usada por times profissionais, e o ecossistema Connect é bem mais amplo: apps, mostradores de relógio e integrações com tudo que o cliente já usa. Vale convidar para experimentar um Garmin na mão e comparar. 💡 Nessa conversa, não force a migração: ouça, reconheça o que a pessoa já gosta e mostre o que o Garmin oferece. Quem decide é o cliente, sua função é informar bem."},
    {"question":"A análise de frequência cardíaca da Polar é melhor.","answer":"O cinto H10 deles é muito bom mesmo, continua sendo referência. Mas o Garmin também tem cintos de peito compatíveis para quem quer máxima precisão, e os sensores de pulso Elevate Gen 5 melhoraram bastante. Para uma análise completa, com zonas de treino, VO2 Max e Training Readiness, o Garmin está no mesmo nível ou acima."}
  ]}
]
$m4b$::jsonb)
where id = '9aff06b8-cbd7-4464-889f-5f3c2b3be8f3';

-- 4.3 Coros: o rival de preço
update lessons set body = jsonb_build_object('blocks', $m4c$
[
  {"type":"texto_rico","html":"<h3>Coros: o rival de preço</h3><p>O Coros é uma marca em crescimento no Brasil e costuma aparecer na conversa pelo gatilho do preço. É um argumento fácil de contornar quando você conhece bem os diferenciais do Garmin.</p><h3>Para quem o Coros faz sentido</h3><p>O cliente sensível a preço, que quer funcionalidades avançadas mas tem orçamento limitado, é o público principal: o Coros entrega bastante por um valor menor, e esse é o argumento central da marca. Também se encaixam o corredor de rua ou de trilha, que não precisa de mergulho, golfe ou navegação e quer GPS preciso com métricas de corrida sem pagar por recursos premium que não vai usar; quem está comprando o primeiro relógio esportivo, nunca usou GPS e quer começar sem investir muito, já que a interface do Coros é simples e não assusta iniciantes; e quem é menos apegado a ecossistema, sem muito interesse em apps, mostradores de relógio ou integrações, e quer apenas o básico funcionando bem.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"✅ Garmin vence em","text":"<ul><li>Mais de 35 anos de mercado, contra uma marca fundada em 2012</li><li>Ecossistema Connect IQ maduro, com mais de 50 integrações</li><li>Variedade de modalidades: corrida, ciclismo, mergulho, golfe e náutica</li><li>FirstBeat, com análise de treino em nível profissional</li><li>Suporte presencial da Proparts, com garantia oficial no Brasil</li><li>Valor de revenda mais alto no mercado</li></ul>","tags":[]},
    {"title":"❌ Coros leva em","text":"<ul><li>Preço de 30% a 40% menor em modelos equivalentes</li><li>Boa bateria mesmo nos modelos mais básicos</li><li>Interface simples, com curva de aprendizado menor</li></ul>","tags":[]}
  ]},
  {"type":"objecao","items":[
    {"question":"O Coros é muito mais barato.","answer":"É verdade que o preço inicial é menor, isso é real, e vale reconhecer isso antes de qualquer coisa. Nunca minimize o argumento de preço do cliente: valide primeiro, depois mostre o valor. A diferença aparece no longo prazo: a Garmin tem mais de 35 anos de algoritmos de treino, suporte presencial aqui na Proparts e um ecossistema muito mais completo. Além disso, o valor de revenda do Garmin é bem maior. Para quem vai usar de verdade, o retorno compensa, e a marca também tem modelos de entrada que encaixam em vários orçamentos."},
    {"question":"Vi review dizendo que o Coros é melhor para trilha.","answer":"O Coros tem bons modelos de trilha, sim, seria desonesto dizer o contrário. Mas o Garmin Instinct 3 e o Fenix 8 foram desenvolvidos com certificação militar MIL-STD-810, altímetro barométrico, bússola e bateria de semanas, e são usados por atletas profissionais de montanha no mundo inteiro. Vale oferecer para mostrar as diferenças técnicas entre os dois."}
  ]}
]
$m4c$::jsonb)
where id = 'b1dbffb6-50d3-442e-a14a-3efa109f4f29';

-- 4.4 Samsung Galaxy Watch: o equivalente Android
update lessons set body = jsonb_build_object('blocks', $m4d$
[
  {"type":"texto_rico","html":"<h3>Samsung Galaxy Watch: o equivalente Android do Apple Watch</h3><p>O Galaxy Watch ocupa no universo Android o mesmo papel que o Apple Watch ocupa no iOS, com foco em ecossistema.</p><h3>Para quem o Galaxy Watch faz sentido</h3><p>O usuário fiel à Samsung, que já tem Galaxy S, talvez um tablet da marca e usa Samsung Pay, quer um relógio que integre perfeitamente com tudo isso. Também se encaixa quem tem um perfil mais de lifestyle e smartwatch, priorizando notificações, pagamentos e aplicativos acima de métricas de treino, já que o esporte é secundário para esse público.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"✅ Garmin vence em","text":"<ul><li>Bateria de vários dias, contra 1 a 2 dias do Galaxy Watch</li><li>Análise de treino com FirstBeat, contra métricas mais básicas</li><li>GPS preciso, com multibanda nos modelos intermediários</li><li>Compatibilidade com qualquer Android, não só aparelhos Samsung</li><li>Resistência e durabilidade em ambiente outdoor</li></ul>","tags":[]},
    {"title":"❌ Galaxy Watch leva em","text":"<ul><li>Integração nativa com Samsung DeX e Galaxy AI</li><li>Design mais parecido com um smartwatch tradicional</li><li>Integração muito boa com o Samsung Pay</li></ul>","tags":[]}
  ]},
  {"type":"objecao","items":[
    {"question":"Tenho Samsung, não seria melhor o Galaxy Watch?","answer":"O Galaxy Watch é ótimo para quem realmente usa o smartwatch como smartwatch, para notificações, Samsung Pay e esse tipo de recurso. Para treino, o Garmin entrega bem mais: bateria de dias, GPS multibanda e uma análise de performance que o Galaxy Watch não tem. Se o cliente pratica esporte com frequência, o Garmin vale muito mais a pena. Se o uso for mais geral, no dia a dia, o ideal é ajudar a decidir com base no que a pessoa mais usa no relógio."}
  ]}
]
$m4d$::jsonb)
where id = '6e65193c-18db-4f8c-a75e-e30757f9eed6';

-- 4.5 Objeções gerais que aparecem em qualquer venda
update lessons set body = jsonb_build_object('blocks', $m4e$
[
  {"type":"texto_rico","html":"<p>Além das comparações com marcas específicas, algumas objeções aparecem o tempo todo, independente do concorrente que o cliente está pensando. Vale ter uma resposta pronta para cada uma delas.</p>"},
  {"type":"objecao","items":[
    {"question":"Tá caro, vou pesquisar online.","answer":"Faz sentido comparar, é um investimento. Aqui na Proparts o cliente tem garantia de 2 anos com assistência técnica oficial, pode experimentar o relógio na hora e sair com ele já configurado no seu nome. Comprando online, qualquer problema vira um processo bem mais trabalhoso. Esse suporte presencial tem valor real, e vale destacar isso. Nunca diga que comprar online é golpe ou que o produto pode ser falso: o caminho é mostrar o valor do que você oferece, não inventar um risco que não existe."},
    {"question":"Vou pensar e volto depois.","answer":"Não tem problema nenhum. O importante é garantir que o cliente saia com tudo que precisa para decidir bem. Vale perguntar se pode anotar o modelo conversado e deixar o WhatsApp disponível para tirar dúvidas na hora de comparar especificações. O cliente que diz \"vou pensar\" muitas vezes só precisa de mais segurança, então manter o canal aberto costuma funcionar melhor do que insistir na hora."},
    {"question":"Não sei se vou usar mesmo.","answer":"Essa dúvida é honesta e comum. O que costuma acontecer com quem compra é que o relógio motiva mais do que a pessoa imaginava: ver os dados no pulso muda o hábito. Para não errar na indicação, vale perguntar sobre a rotina da pessoa, se ela pratica alguma atividade hoje, para indicar o que realmente faz sentido para o estilo de vida dela."},
    {"question":"Nunca usei smartwatch, acho complicado.","answer":"A maioria das pessoas fala exatamente isso antes de usar, e depois conta que é a coisa mais simples que já usaram. O Garmin Connect é bem intuitivo, e o ideal é configurar tudo junto com o cliente antes de ele sair da loja. Se surgir qualquer dúvida depois, o WhatsApp resolve."}
  ]}
]
$m4e$::jsonb)
where id = '5717cdd7-18fa-45eb-9111-5e1ad3c5e0a7';

-- ============================================================================
-- MÓDULO 5 — GARMIN CONNECT (cada título triplicado — 3 UUIDs, mesmo conteúdo)
-- ============================================================================

-- 5.1 O que é o Garmin Connect e o que você consegue visualizar
update lessons set body = jsonb_build_object('blocks', $m5a$
[
  {"type":"texto_rico","html":"<h3>A central de tudo</h3><p>O Garmin Connect é o aplicativo que transforma os dados do relógio em informação útil. Sem ele, o relógio ainda funciona normalmente no pulso, mas o cliente perde o histórico, os gráficos e toda a inteligência por trás das métricas. É no app que os números realmente fazem sentido.</p><p>O relógio coleta os dados: registra as atividades, o sono e os batimentos cardíacos, e calcula as métricas em tempo real direto no pulso, ao longo do dia e durante o treino. Já o app entra depois, mostrando o histórico e as tendências ao longo do tempo, traduzindo os números em análises e recomendações, e sincronizando tudo com outros aplicativos como Strava, Apple Health e MyFitnessPal.</p><p><strong>Na venda:</strong> explique para o cliente que ele não precisa fazer nada além de usar o relógio. Quando chegar em casa, basta abrir o app que já vai estar tudo registrado: treino, sono, batimentos, estresse do dia. É como um diário de saúde que se escreve sozinho.</p>"},
  {"type":"texto_rico","html":"<h3>O que você consegue visualizar</h3><p>As métricas disponíveis variam conforme o modelo do relógio. Quanto mais completo o modelo, mais informação o app exibe, e isso entra naturalmente como argumento de upsell na venda.</p>"},
  {"type":"card_grid","columns":3,"items":[
    {"title":"❤️ Batimento cardíaco","text":"Acompanha a frequência cardíaca em repouso, durante o treino e ao longo do dia, e alerta quando os valores saem do padrão habitual. Se a FC de repouso subir sem motivo aparente, pode ser sinal de que o corpo está sobrecarregado.","tags":[]},
    {"title":"🔋 Body Battery","text":"Indicador de 0 a 100 que sobe com sono de qualidade e cai com estresse e exercício intenso, mostrando o nível de energia disponível no momento. O cliente para de adivinhar quando treinar forte e quando descansar.","tags":[]},
    {"title":"🧘 Estresse","text":"Calculado pela variabilidade da frequência cardíaca ao longo do dia, mostra em gráfico os momentos de maior tensão, mesmo quando o usuário não percebe. Útil para quem tem rotina pesada.","tags":[]},
    {"title":"⚡ HRV Status","text":"A variabilidade cardíaca medida durante o sono indica se o sistema nervoso autônomo está em equilíbrio. É a métrica mais honesta de recuperação, hoje disponível para qualquer pessoa.","tags":[]},
    {"title":"😴 Sleep Score","text":"Pontuação baseada nas fases do sono (leve, profundo, REM), na duração, no SpO2 noturno e na frequência respiratória, que aparece todas as manhãs no app. De manhã o cliente já sabe se dormiu bem, com número, não com achismo.","tags":[]},
    {"title":"📈 Status de Treinamento","text":"Cruza a carga recente de treinos com a evolução do VO2 Máx e classifica o estado do atleta (produtivo, descansado, sobrecarregado etc.), avisando antes de virar lesão.","tags":[]},
    {"title":"👣 Passos","text":"Contagem diária com meta configurável. O histórico semanal e mensal mostra a consistência, e o relógio avisa quando a pessoa fica parada por muito tempo.","tags":[]},
    {"title":"🔥 Calorias","text":"Gasto calórico dividido em repouso (BMR) e ativo, com integração ao MyFitnessPal para fechar o ciclo entre o que a pessoa gasta e o que ela come.","tags":[]},
    {"title":"⏱️ Minutos de Intensidade","text":"Meta semanal baseada na recomendação da OMS de 150 minutos de atividade moderada ou 75 minutos vigorosa por semana. O relógio conta isso automaticamente.","tags":[]},
    {"title":"🩸 SpO2 (oximetria)","text":"Mede a saturação de oxigênio no sangue durante o sono, disponível em modelos com sensor Pulse Ox. Pode indicar queda de saturação noturna — leitura reveladora para suspeita de apneia ou altitude.","tags":[]},
    {"title":"🌸 Ciclo menstrual","text":"Registro e previsão do ciclo, com correlação real entre as fases e métricas como HRV, sono e Body Battery, mostrando como o corpo responde de forma diferente em cada fase.","tags":[]},
    {"title":"💧 Hidratação","text":"Registro manual de consumo de água, com lembretes configuráveis no relógio. Quem esquece de beber água ao longo do dia costuma sentir diferença já na primeira semana.","tags":[]},
    {"title":"📅 Monitoramento de hábitos","text":"Metas pessoais de sono, hidratação e movimento, com um calendário visual de consistência mês a mês. Um jeito motivador de acompanhar isso, sem pressão, com foco em consistência.","tags":[]}
  ]}
]
$m5a$::jsonb)
where id in ('41e3caf6-0827-4750-a31d-747052b7d658','730510a6-c1fd-4b6c-a9e8-681014d820b7','e5dfe60a-b0ad-4dc8-a5a8-6e904ef4ee1e');

-- 5.2 Música no relógio: Spotify, Deezer, Amazon Music e arquivos MP3
update lessons set body = jsonb_build_object('blocks', $m5b$
[
  {"type":"texto_rico","html":"<h3>Treinar sem celular, sem abrir mão da música</h3><p>Em modelos com armazenamento interno, como FR265, FR570, FR955, FR965, FR970, Fenix 8 e Venu 4, entre outros, é possível baixar playlists direto para o relógio e ouvir conectado a um fone Bluetooth. O celular fica em casa.</p><p><strong>Na venda:</strong> mostre ao cliente que ele pode correr sem o celular, sem peso no bolso, e ainda ouvir as próprias músicas, já que a playlist fica salva no próprio relógio.</p><p>Um detalhe importante: usar música no relógio exige um fone Bluetooth separado. Se o cliente ainda não tem um, essa é uma venda natural de acessório complementar.</p>"},
  {"type":"tabela","headers":["Serviço","Como funciona"],"rows":[
    ["Spotify","Requer assinatura Premium. Sincroniza playlists via app e elas ficam disponíveis offline no relógio, sem precisar de internet durante o treino."],
    ["Deezer","Disponível via Connect IQ, também exige assinatura ativa. Alternativa para quem já usa Deezer no dia a dia."],
    ["Amazon Music","Disponível em modelos selecionados, compatível com Prime Music e Unlimited, ideal para quem já é cliente Amazon."],
    ["Arquivos pessoais em MP3","Nos modelos FR970 e Fenix 8, com até 32 GB de armazenamento, permite transferência direta via computador, sem depender de streaming."]
  ]}
]
$m5b$::jsonb)
where id in ('16847b04-0fc3-435d-94b5-5e2020cee09b','232c0ff3-d75f-435f-9d8b-629fcb02eb55','3f4c7257-350a-44e9-9929-c79a64548506');

-- 5.3 Garmin Pay: pagando só com o relógio
update lessons set body = jsonb_build_object('blocks', $m5c$
[
  {"type":"texto_rico","html":"<h3>Pagar com o relógio</h3><p>O Garmin Pay usa NFC para pagamento por aproximação direto no pulso. O cliente cadastra o cartão no Garmin Connect, define um PIN de 4 dígitos no relógio e pronto: basta aproximar o relógio da maquininha.</p><p><strong>Na venda:</strong> quem vai correr ou pedalar não quer sair de casa com carteira. Com o Garmin Pay, dá para pagar o café só com o relógio no pulso.</p>"},
  {"type":"banner","tone":"warning","text":"Os bancos compatíveis no Brasil são <strong>BTG, Banco do Brasil e Santander</strong>. Confirme com o cliente antes de usar esse argumento na venda. Nem todos os modelos têm NFC, então verifique isso antes de incluir o Garmin Pay na apresentação."}
]
$m5c$::jsonb)
where id in ('4f9f93a1-439f-401f-a764-d491c21e6cd2','517b2576-37de-400a-9392-28bb68f302e0','fc76e020-38c1-4d59-bd5a-b90bbebdc621');

-- 5.4 Estudo de caso: aplicando os recursos com 4 perfis de cliente
update lessons set body = jsonb_build_object('blocks', $m5d$
[
  {"type":"texto_rico","html":"<h3>Como usar este estudo de caso</h3><p>A ideia aqui é sair sabendo ligar recurso a benefício real para o cliente, entendendo por que aquela função faz diferença naquele caso específico. Abaixo estão 4 perfis de cliente com o roteiro de apresentação sugerido para cada um deles no Garmin Connect. Se possível, pratique em dupla: um lê os passos, o outro navega no app de verdade.</p>"},
  {"type":"texto_rico","html":"<h3>Ana, 34 anos, home office, São Paulo</h3><p>Mãe de dois filhos, trabalha em casa o dia todo. Percebeu que fica sentada demais e quer começar a se mover, sem pressão e sem metas absurdas. Nunca praticou esporte com regularidade. As métricas mais relevantes para o perfil dela são Body Battery, Passos, Estresse e Sono.</p>"},
  {"type":"roteiro","steps":[
    {"title":"Mostre o Body Battery","dialog":"Abra o app e mostre o Body Battery, explicando que o número representa a energia disponível naquele momento.","tip":""},
    {"title":"Explore o gráfico de estresse","dialog":"Abra o gráfico de estresse do dia, identifique um pico e ligue isso ao ritmo de trabalho dela (reuniões, prazos, e-mails).","tip":""},
    {"title":"Configure a meta de passos","dialog":"Configure a meta de passos em 6.000, um valor realista para começar, e mostre o alerta de sedentarismo do relógio.","tip":""},
    {"title":"Mostre o Sleep Score","dialog":"Abra o Sleep Score e mostre que dormir mal resulta em Body Battery baixo no dia seguinte.","tip":""},
    {"title":"Feche com o Monitoramento de Hábitos","dialog":"Acesse o Monitoramento de Hábitos e mostre o calendário visual de consistência do mês.","tip":""}
  ]},
  {"type":"texto_rico","html":"<h3>Rafael, 28 anos, treina na academia 4 vezes por semana, São Paulo</h3><p>Malha com frequência e quer evoluir para a corrida de rua. Entende de treino, mas nunca usou dados avançados. Quer treinar melhor, não só treinar mais. As métricas mais relevantes para ele são Minutos de Intensidade, HRV Status e Status de Treinamento.</p>"},
  {"type":"roteiro","steps":[
    {"title":"Mostre o gráfico de FC por zona","dialog":"Abra uma atividade já registrada e mostre o gráfico de frequência cardíaca por zona ao longo do treino.","tip":""},
    {"title":"Compare Minutos de Intensidade com a meta da OMS","dialog":"Acesse Minutos de Intensidade e compare com a meta semanal da OMS, de 150 minutos.","tip":""},
    {"title":"Explique o Status de Treinamento","dialog":"Vá ao Status de Treinamento e explique cada classificação (produtivo, descansado, sobrecarregado).","tip":""},
    {"title":"Mostre o HRV Status semanal","dialog":"Acesse o HRV Status semanal e explique que variabilidade alta indica boa recuperação, enquanto variabilidade baixa indica que o corpo está pedindo uma pausa.","tip":""},
    {"title":"Feche com gasto calórico e MyFitnessPal","dialog":"Mostre o gasto calórico e sugira a integração com o MyFitnessPal para fechar o ciclo de nutrição.","tip":""}
  ]},
  {"type":"texto_rico","html":"<h3>Cláudia, 42 anos, executiva, viaja com frequência</h3><p>Agenda lotada, viagens frequentes, pouco tempo para descansar. Quer saber se está se recuperando entre os compromissos. Aprecia praticidade: quer pagar o café pós-treino sem carteira e correr no hotel sem celular. As métricas mais relevantes para ela são Body Battery, Garmin Pay e Música.</p>"},
  {"type":"roteiro","steps":[
    {"title":"Compare o Sleep Score viagem x casa","dialog":"Abra o Sleep Score de uma noite de viagem e compare com uma noite em casa, mostrando o impacto no Body Battery.","tip":""},
    {"title":"Compare o Body Battery dia tranquilo x dia cheio","dialog":"Compare o Body Battery de um dia tranquilo com um dia cheio de reuniões, mostrando em que momento a energia cai.","tip":""},
    {"title":"Mostre o pico de estresse","dialog":"Abra o gráfico de estresse e identifique o horário de pico, ligando isso ao momento de mais compromissos.","tip":""},
    {"title":"Configure o Garmin Pay","dialog":"Acesse o Garmin Pay no app, mostre o cadastro do cartão e o PIN, e simule um pagamento de café pós-treino só com o relógio.","tip":""},
    {"title":"Sincronize uma playlist do Spotify","dialog":"Mostre como sincronizar uma playlist do Spotify para ela correr no hotel sem celular e sem internet.","tip":""}
  ]},
  {"type":"texto_rico","html":"<h3>Bruno, 55 anos, aposentado, São Paulo</h3><p>Aposentou há 6 meses. O médico pediu atividade física leve para controlar a pressão. Nunca praticou esporte, tem resistência à tecnologia, mas foi convencido pelo filho a experimentar. Quer algo simples que realmente ajude. As métricas mais relevantes para ele são Batimento Cardíaco, SpO2, Passos e Sono.</p>"},
  {"type":"roteiro","steps":[
    {"title":"Mostre o batimento cardíaco em repouso","dialog":"Mostre o batimento cardíaco em repouso, explicando o que é um valor saudável e por que acompanhar a tendência semanal importa.","tip":""},
    {"title":"Explique o Sleep Score e o SpO2","dialog":"Acesse o Sleep Score junto com o SpO2 e explique de forma simples que, se essa linha cair muito, vale conversar com o médico.","tip":""},
    {"title":"Configure a meta de passos","dialog":"Configure a meta de passos em 5.000, reforçando que o objetivo é consistência, não velocidade.","tip":""},
    {"title":"Ative os lembretes de hidratação","dialog":"Ative os lembretes de hidratação e mostre como registrar o consumo de água em dois toques no relógio.","tip":""},
    {"title":"Feche com o histórico semanal","dialog":"Mostre o histórico semanal de passos e sono em gráfico, explicando que o médico consegue acompanhar essa evolução junto com ele.","tip":""}
  ]}
]
$m5d$::jsonb)
where id in ('8a6d87d8-7d9b-4afa-9643-7ffebb12cde5','9ef84701-4a33-4008-b123-e90ef2ea1172','c64d9bbe-22c8-4bb3-9050-526ebc6fec00');

-- ============================================================================
-- MÓDULO 6 — GARMIN COACH (cada título triplicado — 3 UUIDs, mesmo conteúdo)
-- ============================================================================

-- 6.1 O que é o Garmin Coach e a ciência por trás dele
update lessons set body = jsonb_build_object('blocks', $m6a$
[
  {"type":"texto_rico","html":"<h3>Consultoria esportiva gratuita, direto no pulso</h3><p>O Garmin Coach é uma plataforma de planos de treinamento dinâmicos e adaptáveis, gratuita dentro do Garmin Connect. Vale pensar nele como um serviço de consultoria esportiva que agrega valor direto à venda e ajuda a fidelizar o cliente.</p><p>Os planos cobrem quatro pilares de valor: treinar para um evento específico, alcançar um marco como o primeiro 5K, melhorar o condicionamento físico geral ou ganhar força. O diferencial técnico está em quem constrói esses planos: fisiologistas esportivos aplicam ciência do esporte real, equilibrando carga e recuperação, com sincronização bidirecional entre o relógio e o plano.</p><p><strong>Na venda:</strong> vale lembrar que um treinador pessoal custa em média entre R$150 e R$300 por mês. Com o Garmin Coach, o cliente leva esse serviço de forma vitalícia e gratuita, direto no relógio.</p>"},
  {"type":"texto_rico","html":"<h3>Diferente de planilha de PDF: o treinamento adaptativo</h3><p>O Coach usa algoritmos que leem sono, estresse e HRV (variabilidade da frequência cardíaca) e cruzam essas informações com o desempenho real nos treinos. O plano reage ao que está acontecendo com o corpo do atleta, em vez de seguir uma sequência fixa.</p><p>Um exemplo prático: se o relógio detecta sono ruim ou o atleta perde dois treinos na semana, o plano reduz automaticamente a intensidade ou sugere descanso, evitando lesão e mantendo o caminho até a meta.</p>"},
  {"type":"banner","tone":"info","text":"<strong>Tapering (polimento):</strong> perto da prova, o volume de treino diminui propositalmente para o corpo recuperar energia e chegar no ápice da performance no dia do evento."}
]
$m6a$::jsonb)
where id in ('66df6b3a-4d20-495e-adc9-7502fc230d39','94785ff3-42ed-4d73-8fb3-0c975cbebe3c','bb84c347-cabb-43a8-bbc2-16a3a6300c5e');

-- 6.2 Modalidades e especialistas: corrida, ciclismo, força e triatlo
update lessons set body = jsonb_build_object('blocks', $m6b$
[
  {"type":"texto_rico","html":"<h3>Corrida</h3><p>Dentro da modalidade de corrida existem dois caminhos. O Run Coach oferece treinos totalmente personalizados que mudam diariamente conforme o desempenho do atleta. Já os Planos Expert permitem que o cliente escolha um treinador pela filosofia de treino dele.</p>"},
  {"type":"card_grid","columns":3,"items":[
    {"title":"Jeff Galloway — Método Run Walk Run","text":"Indicado para quem é iniciante ou está voltando de uma lesão. O método alterna corrida e caminhada para reduzir o impacto e dar confiança. Vale dizer ao cliente que esse plano foi feito para quem quer voltar a correr sem se machucar de novo.","tags":[]},
    {"title":"Amy Parkerson-Mitchell — Fisioterapeuta","text":"Indicada para quem já sofreu lesões recorrentes ou se preocupa com a mecânica da corrida. O foco dela é a mecânica corporal e a prevenção de lesões, priorizando uma corrida mais segura, não necessariamente mais rápida. Reforçar que ela é fisioterapeuta costuma ajudar a fechar a venda com clientes mais cautelosos.","tags":[]},
    {"title":"Greg McMillan — Fisiologia e Ritmo","text":"Indicado para quem já corre e quer evoluir tempo e performance com método. O foco é a fisiologia aplicada, entendendo a dinâmica do ritmo, as zonas de treino e o porquê de cada sessão. Funciona bem com clientes mais analíticos, que gostam de entender dados e métricas.","tags":[]}
  ]},
  {"type":"banner","tone":"info","text":"Distâncias disponíveis: 5K, 10K e Meia Maratona, com suporte a ritmos entre 4:24 e 7:30 min/km."},
  {"type":"texto_rico","html":"<h3>Ciclismo</h3><p>O Garmin Cycling Coach oferece planos autoguiados nos tipos Century (160 km), Gran Fondo, Metric Century (100 km), MTB, Race e Time Trial. Para treino indoor, o ecossistema é compatível com Smart Trainers Tacx através do app Tacx Training, integrando o treino indoor ao plano do relógio. O requisito obrigatório é ter um monitor de frequência cardíaca ou um medidor de potência, e usar os dois juntos é recomendado para máxima precisão.</p><h3>Força</h3><p>O treinamento de força tem planos configuráveis com base em três variáveis que o próprio cliente escolhe no app: o objetivo (hipertrofia, força ou condicionamento), o equipamento disponível (dumbbells, barras ou peso corporal) e o foco muscular em grupos específicos.</p><h3>Triatlo</h3><p>O plano de triatlo cobre as três disciplinas e permite agendar dias específicos de piscina, além de sessões Two-a-day, com dois treinos no mesmo dia. O Garmin Connect+ é um upgrade de experiência que inclui vídeos exclusivos e conteúdo educacional de especialistas sobre técnica de transição e natação.</p>"}
]
$m6b$::jsonb)
where id in ('1435a4aa-8d7f-4d08-b745-cf500e2f75eb','a0ab75ba-8b1c-498d-8cad-7f78586a4c04','fd0b94d8-97ac-42eb-a9a0-abc0fd744a5a');

-- 6.3 Usando o Coach na prática: ritmo no relógio, requisitos e gerenciamento do plano
update lessons set body = jsonb_build_object('blocks', $m6c$
[
  {"type":"texto_rico","html":"<h3>A barra de ritmo durante o treino</h3><p>Durante o treino, o relógio mostra uma barra de ritmo que indica se o atleta está dentro da zona ideal definida pelo treinador. É importante deixar claro para o cliente que essa barra mostra o ritmo médio da etapa ou volta atual, não o ritmo instantâneo. Isso é fundamental para manter constância em intervalos longos.</p><h3>Confidence Score</h3><p>O Confidence Score é uma métrica preditiva baseada no histórico de treinos do plano atual, representada por cores (roxo, verde, laranja e vermelho). Ele só aparece quando o cliente define uma meta de tempo ou de ritmo. Se o plano estiver configurado apenas para completar a distância, sem meta de tempo, o Confidence Score não é exibido.</p>"},
  {"type":"texto_rico","html":"<h3>Requisitos técnicos e ecossistema</h3><p>O app Garmin Connect é usado para configuração, vídeos educativos e acompanhamento das métricas. O Garmin Express é essencial para atualizar o software do relógio: se o Coach não aparecer no dispositivo, o primeiro passo é atualizar via computador. Para planos de ciclismo é preciso ter cintas de frequência cardíaca ou medidores de potência, como o Rally, e para ciclismo indoor a linha Tacx de Smart Trainers garante a integração.</p><p>Os dispositivos compatíveis incluem toda a linha Forerunner (do 45 ao 970), a linha fēnix (do 5 ao fēnix 8/E), Venu (do Sq ao Venu 4/X1), Instinct em todas as gerações incluindo o Instinct 3, vívoactive 5/6 e os ciclocomputadores Edge.</p><p>Para mostrar ao cliente onde encontrar o Coach, o caminho no app é: App Garmin Connect &gt; Mais &gt; Treinamento &amp; Planejamento &gt; Planos Garmin Coach.</p>"},
  {"type":"texto_rico","html":"<h3>Gerenciando o plano</h3><p>Reagendar um treino de corrida ou de força pode ser feito direto pelo app. Já o reagendamento de um plano de ciclismo autoguiado exige obrigatoriamente o uso do Garmin Connect Web.</p><p>Vale explicar bem a diferença entre pausar e sair de um plano: pausar mantém todo o progresso do cliente. Sair remove todos os treinos futuros do plano, embora os treinos já concluídos continuem aparecendo no calendário. Para retomar depois de sair, é preciso começar um plano do zero.</p>"},
  {"type":"tabela","headers":["Termo","Significado"],"rows":[
    ["Tapering (polimento)","Redução estratégica da carga de treino antes de uma prova, para garantir descanso."],
    ["Two-a-day","Dois treinos estruturados no mesmo dia, comum no triatlo."],
    ["Confidence Score","Métrica preditiva baseada no histórico de treinos do plano atual."],
    ["HRV / Carga","Variabilidade da frequência cardíaca, a base da ciência adaptativa do Coach."]
  ]},
  {"type":"objecao","items":[
    {"question":"O cliente pode usar os alertas de ritmo habituais do relógio?","answer":"Não: os alertas do Coach substituem os padrões do perfil de atividade para garantir a precisão da orientação do treinador."},
    {"question":"O que acontece se o atleta pular as partes opcionais de um treino?","answer":"Basta apertar o botão Lap (volta). O plano é inteligente: se o atleta pular muitas sessões, ele sugere pausar ou ajusta a carga para baixo automaticamente."},
    {"question":"Quantos planos o cliente pode ter ativos ao mesmo tempo?","answer":"Apenas um plano Garmin Coach ativo por vez."},
    {"question":"Quais idiomas são suportados?","answer":"Português, inglês, espanhol, francês, alemão, chinês, japonês, coreano, holandês, dinamarquês, norueguês, sueco, italiano, tailandês, vietnamita, indonésio e checo."}
  ]},
  {"type":"banner","tone":"info","text":"<strong>⭐ Dica de ouro:</strong> Não finalize a venda sem abrir o app do cliente e mostrar a aba Treinamento e Planejamento. Configure com ele o primeiro plano, seja de 5K ou de força. Um cliente que entende que o relógio pensa por ele dificilmente vai trocar a Garmin por outra marca."}
]
$m6c$::jsonb)
where id in ('1702bda8-0836-4572-8e9a-87ba091f3aec','6982e821-a58d-4f33-960a-8781407c4c91','a1ec530b-966b-4f7d-9e7f-6d9b402d968b');

-- 6.4 Como escolher o plano certo para o cliente
update lessons set body = jsonb_build_object('blocks', $m6d$
[
  {"type":"texto_rico","html":"<p>Antes de recomendar um plano, vale seguir um raciocínio simples com o cliente, começando pelo objetivo principal dele.</p>"},
  {"type":"tabela","headers":["Situação do cliente","Plano indicado"],"rows":[
    ["Nunca correu ou está voltando de lesão","Plano Expert — Jeff Galloway (Run Walk Run), configurável no app com distância 5K ou 10K"],
    ["Já corre mas se preocupa com dores e lesões","Plano Expert — Amy Parkerson-Mitchell (fisioterapeuta) — reforça segurança, bom para clientes cautelosos"],
    ["Já corre bem e quer evoluir tempo com método","Plano Expert — Greg McMillan (fisiologia e ritmo) — bom para clientes analíticos"],
    ["Prova longa (Century/Gran Fondo, 100–160km) ou trilha/MTB","Garmin Cycling Coach por distância — requer monitor de FC ou medidor de potência; reagendar exige Garmin Connect Web"],
    ["Quer treinar indoor com Smart Trainer","Garmin Cycling Coach + ecossistema Tacx — boa venda cruzada relógio + Smart Trainer"],
    ["Quer ganhar força ou massa muscular","Garmin Coach de Treinamento de Força — configurável por objetivo, equipamento e grupo muscular"],
    ["Está se preparando para um Triatlo","Garmin Coach de Triatlo + Garmin Connect+ — dias de piscina, sessões two-a-day, upgrade com vídeos exclusivos"]
  ]}
]
$m6d$::jsonb)
where id in ('551cd08f-7c54-4c8c-8482-a6607fd7b6c5','682bdcab-e094-4352-9b2a-3069f2aed479','a4331acf-2f63-4d32-b664-1f31ddaab0e3');

-- ============================================================================
-- FIM DA MIGRAÇÃO 030
-- ============================================================================
