-- ============================================================================
-- GARMIN TRAINING HUB — SEED 050: LIÇÕES DOS MÓDULOS 1 E 2 (marca: garmin)
-- ============================================================================
-- Migra para a tabela `lessons` o conteúdo textual dos painéis de módulo do
-- protótipo estático index_redesign_v5.html, reescrito em português corrido
-- (não telegráfico) para leitura dentro do app. Nenhum fato, número, data ou
-- especificação foi inventado: apenas a forma do texto foi reescrita a partir
-- do conteúdo real dos painéis abaixo.
--
-- Fontes lidas integralmente no protótipo:
--   • panel-universo         (linhas ~3116-3156) — Módulo 1: DNA da marca,
--     timeline histórica, "por que a Garmin vence" e as 5 tecnologias.
--   • panel-perfis-modulo    (linhas ~3159-3295) — Módulo 2: os 11 perfis de
--     cliente (corrida, outdoor/lifestyle/especialidades) e como sondar.
--
-- Cada módulo foi dividido em lições seguindo os agrupamentos que já existem
-- no HTML fonte (card-label de cada seção), sem inventar uma divisão nova:
--   universo        -> 3 lições (história / por que vence / 5 tecnologias)
--   perfis-modulo   -> 3 lições (perfis de corrida / outdoor+lifestyle+
--                      especialidades / como sondar e identificar)
--
-- Elementos de interface do protótipo (botões de quiz, wrapper de quiz,
-- onclick, timeline visual) foram descartados: só a informação de fato
-- (datas, argumentos de venda, sinais de identificação) foi migrada.
--
-- Pré-requisito: sql/seeds/010_trilha_e_certificacoes.sql já aplicado (cria
-- os módulos com slug 'universo' e 'perfis-modulo' usados nas subqueries
-- abaixo).
--
-- Este arquivo não é idempotente: `lessons` não tem unique constraint de
-- seed prática (id é uuid gerado), então rodar duas vezes duplica as lições.
-- Assume schema limpo / primeira carga para esta tabela.
-- ============================================================================


-- ============================================================================
-- MÓDULO 1 — O UNIVERSO GARMIN (slug 'universo')
-- ============================================================================

-- 1.1 Lição: A história da marca Garmin
insert into lessons (module_id, title, content_type, body, order_index, is_published)
values (
  (select id from modules where slug = 'universo'),
  'A história da marca Garmin',
  'text',
  '{"html": "<p>Entenda a história, os valores e por que a Garmin vence a cada venda. Um consultor que conhece a marca por trás do produto vende com confiança, e o cliente sente isso.</p><h3>Como tudo começou</h3><p>A Garmin foi fundada em 1989 por Gary Burrell e Min Kao, em Lenexa, no Kansas (EUA). O próprio nome da empresa vem da junção dos nomes dos fundadores: Gary mais Min formam Garmin. O foco inicial era GPS para aviação.</p><p>Em 1991 a empresa lançou o primeiro receptor GPS portátil para consumidores, levando ao mercado civil uma tecnologia que até então era restrita ao uso militar.</p><h3>Do GPS ao pulso do atleta</h3><p>Em 2003 a Garmin lançou o primeiro Forerunner, um relógio GPS voltado para corredores, e passou a ter presença direta no pulso dos atletas. Esse salto se consolidou em 2015, com o lançamento do Forerunner 235, o primeiro relógio Garmin a combinar sensor óptico de frequência cardíaca no pulso com GPS integrado. O modelo vendeu mais de 1 milhão de unidades.</p><h3>Onde a Garmin está hoje</h3><p>Entre 2024 e 2025 a marca lançou o Fenix 8, o Forerunner 970, o Edge 1050 e os Edge 550/850, consolidando uma liderança absoluta no mercado de wearables esportivos premium.</p>"}'::jsonb,
  0,
  true
);

-- 1.2 Lição: Por que a Garmin vence
insert into lessons (module_id, title, content_type, body, order_index, is_published)
values (
  (select id from modules where slug = 'universo'),
  'Por que a Garmin vence',
  'text',
  '{"html": "<p>Quatro fatores explicam por que a Garmin lidera o mercado de wearables esportivos.</p><h3>Especialização real</h3><p>A Garmin não é uma empresa que \"também faz relógio\". GPS e precisão de posicionamento são o core business da marca há mais de 35 anos.</p><h3>Ecossistema inigualável</h3><p>Entre o Garmin Connect, o Connect IQ e mais de 50 integrações, o atleta que usa Garmin tem todos os seus dados reunidos num só lugar, ano após ano.</p><h3>Bateria que liberta</h3><p>Enquanto os concorrentes costumam durar de 1 a 2 dias, um Garmin dura semanas. Essa diferença é o que permite monitorar o sono todas as noites, em vez de precisar carregar o relógio toda noite.</p><h3>Durabilidade e confiança</h3><p>Certificação MIL-STD-810, cristal de safira nas linhas premium e resistência à água. Com cuidados básicos, um Garmin dura de 5 a 8 anos.</p>"}'::jsonb,
  1,
  true
);

-- 1.3 Lição: As 5 tecnologias que você precisa dominar
insert into lessons (module_id, title, content_type, body, order_index, is_published)
values (
  (select id from modules where slug = 'universo'),
  'As 5 tecnologias que você precisa dominar',
  'text',
  '{"html": "<p>Essas cinco tecnologias aparecem em praticamente toda conversa de venda. Domine os argumentos abaixo antes de atender o próximo cliente.</p><h3>GPS multibanda</h3><p>É o diferencial mais fácil de explicar para o cliente: o relógio traça exatamente o caminho percorrido, mesmo em cidade cercada de prédios ou dentro de mata fechada. Está disponível a partir do Forerunner 265.</p><h3>FirstBeat e VO2 Max</h3><p>O relógio calcula a capacidade aeróbica do usuário e indica se ele está evoluindo ou sobrecarregado. É o cérebro do Garmin, a base científica por trás de toda a análise de treino.</p><h3>Body Battery</h3><p>Funciona como um indicador de bateria do próprio corpo, numa escala de 0 a 100. Sobe com sono bom e cai com estresse e exercício, ajudando o usuário a saber quando treinar forte e quando descansar.</p><h3>Monitoramento de sono</h3><p>O relógio registra cada fase do sono (leve, profunda e REM) e entrega uma pontuação pela manhã. Para quem busca qualidade de vida, essa métrica costuma valer mais do que qualquer dado de treino.</p><h3>Garmin Pay</h3><p>Permite pagar no café depois do treino sem precisar tirar o celular do bolso, só com o relógio, e funciona nos principais bancos brasileiros.</p>"}'::jsonb,
  2,
  true
);


-- ============================================================================
-- MÓDULO 2 — PERFIS DE CLIENTE (slug 'perfis-modulo')
-- ============================================================================

-- 2.1 Lição: Perfis de corrida
insert into lessons (module_id, title, content_type, body, order_index, is_published)
values (
  (select id from modules where slug = 'perfis-modulo'),
  'Perfis de corrida',
  'text',
  '{"html": "<p>Identificar o perfil certo é a diferença entre vender o produto perfeito e perder a venda. Comece pelos três perfis mais comuns entre corredores.</p><h3>🏃 Corredor Iniciante</h3><p>Começa a correr agora ou está retornando ao esporte depois de um tempo parado. Nunca usou GPS e quer algo simples para monitorar tempo e distância.</p><p><strong>Como identificar:</strong></p><ul><li>Nunca usou relógio GPS</li><li>Fala em \"começar a correr\"</li><li>Pergunta qual é o modelo mais simples</li><li>Quer monitorar tempo e distância</li></ul><p><strong>Como apresentar:</strong></p><ul><li>Forerunner 55: a porta de entrada ideal</li><li>Forerunner 165: tela AMOLED já desde o início</li><li>Fale dos planos de treino adaptativos</li><li>Mostre como a sincronização com o celular é fácil</li></ul><p>Produto principal: Forerunner 55. Também considere o Forerunner 165.</p><h3>🏅 Corredor Dedicado</h3><p>Treina com frequência, corre três vezes ou mais por semana e busca evolução constante.</p><p><strong>Como identificar:</strong></p><ul><li>Fala em ritmo, pace, PR</li><li>Corre três ou mais vezes por semana</li><li>Pergunta por GPS multibanda</li><li>Menciona VO2 Max</li></ul><p><strong>Como apresentar:</strong></p><ul><li>Forerunner 265 ou 570: GPS multibanda completo</li><li>Fale do Training Readiness</li><li>PacePro para estratégia de prova</li><li>Destaque a integração com Strava e TrainingPeaks</li></ul><p>Produto principal: Forerunner 265. Também considere o Forerunner 570 e o Forerunner 955.</p><h3>🏆 Atleta de Elite / Triatleta</h3><p>Tem alto volume de treino e compete em triathlon ou provas de ultra, treinando 10 horas ou mais por semana.</p><p><strong>Como identificar:</strong></p><ul><li>Menciona triathlon, Ironman, ultra</li><li>Pede bateria de 30 horas ou mais de GPS real</li><li>Já tem relógio e está buscando um upgrade</li><li>Treina 10 horas ou mais por semana</li></ul><p><strong>Como apresentar:</strong></p><ul><li>Forerunner 965 ou 970: ferramentas de triatleta</li><li>Fenix 8 para quem também faz atividades outdoor</li><li>Bateria de 30 horas ou mais com GPS de alta precisão</li><li>Training Readiness para periodização de treino</li></ul><p>Produto principal: Forerunner 970. Também considere o Forerunner 965 e o Fenix 8.</p>"}'::jsonb,
  0,
  true
);

-- 2.2 Lição: Perfis outdoor, lifestyle e especialidades
insert into lessons (module_id, title, content_type, body, order_index, is_published)
values (
  (select id from modules where slug = 'perfis-modulo'),
  'Perfis outdoor, lifestyle e especialidades',
  'text',
  '{"html": "<p>Além dos corredores, oito outros perfis aparecem com frequência na loja. Cada um tem sinais próprios e uma forma diferente de apresentar o produto.</p><h3>🌿 Aventureiro / Trilheiro</h3><p>Ama trilhas, camping e expedições. Quer resistência de nível militar, bateria longa e mapas topográficos offline.</p><p><strong>Como identificar:</strong></p><ul><li>Fala de trilha, serra, montanha</li><li>Pede GPS com mapa topográfico</li><li>Quer resistência e bateria longa</li><li>Menciona acampamento ou expedição</li></ul><p><strong>Como apresentar:</strong></p><ul><li>Instinct 3: certificação MIL-STD-810 e 26 dias de bateria</li><li>Fenix 8 para quem quer o máximo em outdoor</li><li>Mapas TopoActive e trilhas offline</li><li>inReach para expedições sem sinal</li></ul><p><strong>MIL-STD-810</strong> é a certificação militar americana de resistência a impacto, temperatura extrema, umidade, altitude e vibração.</p><p>Produto principal: Instinct 3. Também considere o Fenix 8 e o Enduro 3.</p><h3>💎 Mulher Lifestyle</h3><p>Quer design elegante com funções inteligentes. Costuma comparar com o Apple Watch em termos de design e valoriza recursos de saúde feminina.</p><p><strong>Como identificar:</strong></p><ul><li>Pede um relógio menor ou mais bonito</li><li>Quer acompanhamento de saúde feminina, como o ciclo menstrual</li><li>Está comprando de presente</li><li>Compara com o Apple Watch no design</li></ul><p><strong>Como apresentar:</strong></p><ul><li>Lily 2: o menor e mais elegante, com design de joia</li><li>Lily 2 Active: a mesma Lily, agora com GPS integrado</li><li>Venu 4: tela AMOLED premium com saúde feminina completa</li><li>Fale sobre acompanhamento de ciclo, gravidez e menopausa no Garmin</li></ul><p>Quando o cliente disser que \"o Apple Watch tem mais funções de smartwatch\", vale responder que o Lily 2 Active tem GPS integrado e bateria de até 7 dias, enquanto o Apple Watch dura de 1 a 2 dias com GPS ligado. Para quem não quer carregar o relógio todo dia, o Garmin vence.</p><p>Produto principal: Lily 2 Active. Também considere o Lily 2, o Vivoactive 6 e o Venu 4.</p><h3>🚴 Ciclista</h3><p>Pedala com frequência, seja estrada, mountain bike ou uso casual. Quer GPS no guidão e métricas de cadência ou potência.</p><p><strong>Como identificar:</strong></p><ul><li>Menciona bike, MTB, estrada, gravel</li><li>Pergunta por GPS para o guidão</li><li>Fala de Strava, subidas, cadência</li><li>Quer medir cadência ou potência</li></ul><p><strong>Como apresentar:</strong></p><ul><li>Edge 540 ou 840: GPS no guidão</li><li>Varia RTL515: radar traseiro que detecta carros a 140 metros</li><li>Rally RK 200: pedal medidor de potência SPD</li><li>Forerunner 955 ou Fenix 8 para quem faz multiesporte</li></ul><p>Potência é a métrica mais honesta do ciclismo: não é afetada por cansaço, calor ou adrenalina.</p><p>Produto principal: Edge 850. Também considere o Edge 550, o Edge 1050, o Varia RTL515 e o Rally RK 200.</p><h3>🏊 Nadador / Triatleta</h3><p><strong>Como identificar:</strong></p><ul><li>Fala de piscina, mar, braçadas</li><li>Quer SWOLF ou eficiência de braçada</li><li>Menciona triathlon ou duathlon</li></ul><p><strong>Como apresentar:</strong></p><ul><li>Forerunner 965 ou 970: natação, ciclismo e corrida no mesmo relógio</li><li>Fenix 8 para o triatleta que quer o pacote mais completo</li><li>HRM 600 para medir a frequência cardíaca dentro da água</li></ul><p>Produto principal: Forerunner 955. Também considere o Forerunner 965, o Fenix 8 e o HRM 600.</p><h3>🤿 Mergulhador</h3><p><strong>Como identificar:</strong></p><ul><li>Menciona profundidade, NDL, nitrox</li><li>Pergunta sobre computador de mergulho</li><li>Fala de mergulho técnico</li></ul><p><strong>Como apresentar:</strong></p><ul><li>Descent G2: smartwatch completo com funções de mergulho</li><li>Descent Mk3i para quem mergulha técnico e exige mais</li><li>Descent X30 com autonomia de gás</li></ul><p>Produto principal: Descent G2. Também considere o Descent Mk3i e o Descent X30.</p><h3>⛳ Golfista</h3><p><strong>Como identificar:</strong></p><ul><li>Fala de green, par, bunker, handicap</li><li>Pergunta por GPS de golfe</li></ul><p><strong>Como apresentar:</strong></p><ul><li>Approach S44: entrada, com mais de 42 mil campos mapeados</li><li>Approach S50: tela AMOLED e experiência completa</li></ul><p>Produto principal: Approach S50. Também considere o Approach S44.</p><h3>🏍️ Motociclista</h3><p><strong>Como identificar:</strong></p><ul><li>Fala de viagem de moto, rota, estrada</li><li>Pergunta por GPS para moto</li></ul><p><strong>Como apresentar:</strong></p><ul><li>Zumo XT2: GPS específico para moto</li><li>O roteamento evita ruas proibidas para motos</li></ul><p>Produto principal: Zumo XT2.</p><h3>🎣 Pescador / Náutico</h3><p><strong>Como identificar:</strong></p><ul><li>Menciona pesca em represa, rio ou mar</li><li>Fala de barco, canoa, lancha</li></ul><p><strong>Como apresentar:</strong></p><ul><li>Striker 4: entrada para quem está começando na pesca</li><li>Striker Vivid 5cv com tecnologia ClearVü</li><li>ECHOMAP UHD2 com mapas náuticos completos</li></ul><p>Produto principal: Striker Vivid 5cv. Também considere o Striker 4 e o ECHOMAP UHD2 52cv.</p>"}'::jsonb,
  1,
  true
);

-- 2.3 Lição: Como sondar e identificar o cliente certo
insert into lessons (module_id, title, content_type, body, order_index, is_published)
values (
  (select id from modules where slug = 'perfis-modulo'),
  'Como sondar e identificar o cliente certo',
  'text',
  '{"html": "<p>Depois de conhecer os perfis, o próximo passo é saber como descobrir, na prática, qual deles está na sua frente.</p><h3>As três perguntas essenciais</h3><ul><li><strong>\"Qual atividade você pratica?\"</strong> define a linha de produto.</li><li><strong>\"Você já tem relógio GPS?\"</strong> define o nível de entrada.</li><li><strong>\"O que você quer monitorar?\"</strong> alinha a expectativa com o produto.</li></ul><h3>Erros a evitar</h3><ul><li>Oferecer o produto mais caro sem sondar o perfil do cliente</li><li>Focar em especificações técnicas antes de entender a necessidade real</li><li>Ignorar sinais visuais, como roupa, acessórios e vocabulário</li><li>Não perguntar para quem é o presente</li></ul><h3>Regra de ouro</h3><p>O cliente sempre revela o perfil dele. Preste atenção ao vocabulário que ele usa, como \"pace\", \"Ironman\", \"trilha\", \"par\" ou \"braçada\", e você já sabe qual linha indicar antes mesmo de perguntar.</p>"}'::jsonb,
  2,
  true
);


-- ============================================================================
-- FIM DA SEED 050
-- ============================================================================
