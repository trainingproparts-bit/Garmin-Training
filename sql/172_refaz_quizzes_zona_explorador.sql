-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 172: quizzes da Zona Explorador refeitos
-- ============================================================================
-- Pedido do usuário (2026-10-08): os quizzes da Zona Explorador cobravam
-- conteúdo que já saiu das lições (ex.: perfil "Mulher Lifestyle", radar a
-- 140 m, pedal SPD, "15 a 30 segundos", "L1 e L5"), tinham alternativas
-- erradas absurdas e a resposta certa quase sempre era a mais longa. O quiz
-- Linha de Produtos ainda tinha 18 perguntas duplicadas (6 perguntas x 3).
--
-- Os 5 quizzes foram reescritos só com o que está nas lições hoje:
--   Universo Garmin 10, Perfis de Cliente 11, Linha de Produtos 12,
--   Cenários de Concorrência 11, Script de Atendimento Premium 12.
-- Perguntas em formato de situação de balcão, alternativas erradas
-- plausíveis (em geral a resposta certa de OUTRA situação, ou um erro comum
-- de vendedor) e com tamanho parecido com o da certa. A posição da correta
-- varia entre A, B, C e D.
--
-- Histórico preservado: as perguntas antigas NÃO são apagadas, só ficam
-- is_active = false (e vão para order_index + 100000, por causa da
-- constraint uq_questions_quiz_order). Assim quiz_answers e as tentativas antigas continuam
-- válidas; o QuizRunner só carrega perguntas ativas, e o trigger da
-- Revisão Inteligente (sql/066) tira as inativas do catálogo.
--
-- Limite de 10 perguntas ativas por quiz (pedido de 2026-10-08): as
-- perguntas listadas em drops.mjs continuam gravadas, mas com
-- is_active = false.
--
-- Ids determinísticos (md5 da chave quiz + posição): rodar de novo só
-- atualiza, não duplica. Nota de corte (70%) e demais configurações dos
-- quizzes não mudam.
--
-- Gerado a partir de quiz_data.mjs (checagem automática de tamanho das
-- alternativas, travessão e emoji antes de gerar).
-- ============================================================================

do $$
declare
  v_data jsonb := $q$[
 {
  "key": "universo",
  "quiz_id": "746043c7-4efe-465a-b270-d13b24dc0725",
  "questions": [
   {
    "body": "De onde vem o nome Garmin?",
    "explanation": "Gary Burrell e Min Kao fundaram a empresa, e o nome junta os dois: Gary mais Min.",
    "active": true,
    "alternatives": [
     {
      "body": "Da junção dos nomes dos fundadores, Gary e Min",
      "is_correct": true
     },
     {
      "body": "Da cidade do Kansas onde a empresa foi fundada",
      "is_correct": false
     },
     {
      "body": "De um sistema de navegação usado na aviação",
      "is_correct": false
     },
     {
      "body": "Da sigla do primeiro receptor GPS da marca",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual era o foco inicial da Garmin quando foi fundada?",
    "explanation": "A empresa nasceu com foco em GPS para aviação. Os relógios vieram depois, com o primeiro Forerunner.",
    "active": true,
    "alternatives": [
     {
      "body": "Relógios para corrida",
      "is_correct": false
     },
     {
      "body": "Ciclocomputadores",
      "is_correct": false
     },
     {
      "body": "Sonares para pesca",
      "is_correct": false
     },
     {
      "body": "GPS para aviação",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Em que momento a Garmin passou a estar diretamente no pulso dos atletas?",
    "explanation": "O primeiro Forerunner, de 2003, foi o relógio GPS para corredores que colocou a marca no pulso dos atletas.",
    "active": true,
    "alternatives": [
     {
      "body": "Com o receptor GPS portátil, em 1991",
      "is_correct": false
     },
     {
      "body": "Com o Forerunner 235, em 2015",
      "is_correct": false
     },
     {
      "body": "Com o primeiro Forerunner, em 2003",
      "is_correct": true
     },
     {
      "body": "Com o lançamento do fēnix 8, em 2024",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Um cliente diz: “A Garmin é só mais uma marca que resolveu fazer relógio.” Qual argumento do módulo responde melhor?",
    "explanation": "O argumento de especialização real: GPS e precisão de posicionamento são o negócio central da Garmin há mais de 35 anos.",
    "active": true,
    "alternatives": [
     {
      "body": "A Garmin vende mais relógios do que qualquer outra marca do mundo",
      "is_correct": false
     },
     {
      "body": "GPS e posicionamento são o core business da marca há mais de 35 anos",
      "is_correct": true
     },
     {
      "body": "Todos os relógios Garmin têm GPS multibanda e mapas embarcados",
      "is_correct": false
     },
     {
      "body": "A Garmin fabrica todos os componentes dos relógios no Brasil",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Por que a bateria longa da Garmin também vira um argumento de saúde?",
    "explanation": "Como o relógio dura semanas, o cliente não precisa carregá-lo toda noite e pode monitorar o sono todos os dias.",
    "active": true,
    "alternatives": [
     {
      "body": "Permite dormir com o relógio e monitorar o sono toda noite",
      "is_correct": true
     },
     {
      "body": "Permite usar o GPS multibanda o dia todo sem perder precisão",
      "is_correct": false
     },
     {
      "body": "Permite medir a temperatura do corpo de forma contínua",
      "is_correct": false
     },
     {
      "body": "Permite atualizar o relógio sem conectar ao celular",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Um cliente dormiu mal e teve um dia estressante. O que tende a acontecer com o Body Battery dele?",
    "explanation": "O Body Battery funciona como a bateria do corpo, de 0 a 100: sobe com sono bom e cai com estresse e exercício.",
    "active": true,
    "alternatives": [
     {
      "body": "Tende a subir, porque o estresse eleva a frequência cardíaca do corpo",
      "is_correct": false
     },
     {
      "body": "Fica igual, porque o indicador só considera os treinos registrados",
      "is_correct": false
     },
     {
      "body": "Zera e só volta a ser calculado depois do próximo treino registrado",
      "is_correct": false
     },
     {
      "body": "Tende a ficar mais baixo, porque sono ruim e estresse reduzem o indicador",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Para qual cliente o monitoramento de sono costuma pesar mais do que os dados de treino?",
    "explanation": "Para quem busca qualidade de vida, a pontuação do sono pela manhã costuma valer mais do que qualquer dado de treino.",
    "active": true,
    "alternatives": [
     {
      "body": "Quem treina para provas de longa distância na estrada",
      "is_correct": false
     },
     {
      "body": "Quem pratica mergulho ou outros esportes náuticos",
      "is_correct": false
     },
     {
      "body": "Quem busca qualidade de vida e acompanha a rotina",
      "is_correct": true
     },
     {
      "body": "Quem pedala em estrada com tráfego intenso de carros",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Uma cliente corre entre prédios altos e reclama que o traçado do app “pula” no mapa. Qual tecnologia responde a essa dor?",
    "explanation": "O GPS multibanda traça o caminho percorrido com precisão mesmo em cidade cercada de prédios ou em mata fechada.",
    "active": true,
    "alternatives": [
     {
      "body": "Body Battery",
      "is_correct": false
     },
     {
      "body": "GPS multibanda",
      "is_correct": true
     },
     {
      "body": "FirstBeat e VO2 Max",
      "is_correct": false
     },
     {
      "body": "Monitoramento de sono",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual conjunto de fatores sustenta o argumento de durabilidade da Garmin?",
    "explanation": "Certificação MIL-STD-810, cristal de safira nas linhas premium e resistência à água. Com cuidados básicos, um Garmin dura de 5 a 8 anos.",
    "active": true,
    "alternatives": [
     {
      "body": "MIL-STD-810, safira nas linhas premium e resistência à água",
      "is_correct": true
     },
     {
      "body": "Carregamento solar em todos os modelos e pulseiras de titânio",
      "is_correct": false
     },
     {
      "body": "Tela AMOLED em toda a linha e atualizações automáticas de software",
      "is_correct": false
     },
     {
      "body": "Garantia de 5 anos e troca gratuita de bateria na loja",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Em qual situação o Garmin Pay ganha força como argumento?",
    "explanation": "O Garmin Pay permite pagar no café depois do treino só com o relógio, sem tirar o celular do bolso.",
    "active": true,
    "alternatives": [
     {
      "body": "Quem quer parcelar a compra do relógio direto na loja",
      "is_correct": false
     },
     {
      "body": "Quem precisa transferir dinheiro usando o relógio",
      "is_correct": false
     },
     {
      "body": "Quem quer acompanhar os gastos no Garmin Connect",
      "is_correct": false
     },
     {
      "body": "Quem treina sem o celular e quer pagar algo no caminho",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "perfis",
  "quiz_id": "f8ea414f-e5d8-4328-86d7-3b44a5dc82f3",
  "questions": [
   {
    "body": "Cliente: “Quero um Garmin para correr.” Qual é o próximo passo?",
    "explanation": "“Quero um Garmin para correr” ainda não basta para indicar um produto. Primeiro vem o nível, o objetivo e o que ele quer acompanhar.",
    "active": true,
    "alternatives": [
     {
      "body": "Apresentar o Forerunner mais vendido para observar a reação dele",
      "is_correct": false
     },
     {
      "body": "Descobrir se ele está começando, se já treina e o que quer acompanhar",
      "is_correct": true
     },
     {
      "body": "Perguntar o orçamento e filtrar os modelos pela faixa de preço",
      "is_correct": false
     },
     {
      "body": "Mostrar um modelo de entrada e um topo de linha para comparar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual sequência representa a lógica do atendimento ensinada no módulo?",
    "explanation": "Quem está na sua frente, o que pratica, o que quer alcançar, o que precisa acompanhar e, só então, qual solução faz sentido.",
    "active": false,
    "alternatives": [
     {
      "body": "Pessoa, atividade, objetivo, necessidade, produto",
      "is_correct": true
     },
     {
      "body": "Produto, preço, atividade, objetivo, fechamento",
      "is_correct": false
     },
     {
      "body": "Atividade, produto, necessidade, objetivo, pessoa",
      "is_correct": false
     },
     {
      "body": "Necessidade, produto, pessoa, atividade, objetivo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente usa termos como pace, VO2 Max e GPS multibanda. Como tratar esse vocabulário?",
    "explanation": "O vocabulário é um sinal, e a conclusão vem das perguntas. Sempre confirme antes de recomendar.",
    "active": true,
    "alternatives": [
     {
      "body": "Como prova de que ele é atleta de performance",
      "is_correct": false
     },
     {
      "body": "Como indicação para apresentar o topo de linha",
      "is_correct": false
     },
     {
      "body": "Como sinal de que ele dispensa a sondagem",
      "is_correct": false
     },
     {
      "body": "Como um sinal de perfil a confirmar com perguntas",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual fala indica mais claramente um Corredor Dedicado?",
    "explanation": "O Corredor Dedicado já corre com frequência e busca evolução: fala de pace, ritmo e provas.",
    "active": true,
    "alternatives": [
     {
      "body": "“Estou começando a correr e nunca usei um relógio com GPS.”",
      "is_correct": false
     },
     {
      "body": "“Estou treinando para o Ironman e treino todos os dias.”",
      "is_correct": false
     },
     {
      "body": "“Corro três vezes por semana e quero melhorar meu pace.”",
      "is_correct": true
     },
     {
      "body": "“Quero acompanhar meu sono e minha rotina no trabalho.”",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Com um Atleta de Performance, qual pergunta passa a guiar a conversa?",
    "explanation": "Com esse perfil, a pergunta deixa de ser qual atividade ele pratica e passa a ser o que ele precisa acompanhar melhor.",
    "active": true,
    "alternatives": [
     {
      "body": "“Qual atividade você pratica com mais frequência hoje em dia?”",
      "is_correct": false
     },
     {
      "body": "“O que você precisa acompanhar melhor no seu treinamento?”",
      "is_correct": true
     },
     {
      "body": "“Você já utilizou algum relógio com GPS nos seus treinos?”",
      "is_correct": false
     },
     {
      "body": "“Quantas vezes por semana você pretende treinar este ano?”",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Um cliente fala de serra, montanha e expedições. Qual pergunta inicial ajuda a entender a necessidade dele?",
    "explanation": "Para o Aventureiro, saber se há sinal de celular na trilha revela a necessidade de navegação e autonomia.",
    "active": true,
    "alternatives": [
     {
      "body": "“As trilhas que você faz têm sinal de celular?”",
      "is_correct": true
     },
     {
      "body": "“Pedala mais na rua, na estrada ou também mountain bike?”",
      "is_correct": false
     },
     {
      "body": "“Já compete em provas de triathlon ou é só treino?”",
      "is_correct": false
     },
     {
      "body": "“É mais pra acompanhar sono, estresse e rotina?”",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que a pergunta “Você já usa algum Garmin ou outro relógio?” ajuda a descobrir?",
    "explanation": "Ela mostra se é uma primeira compra, uma comparação ou uma oportunidade de upgrade. As outras opções são o que revelam as demais perguntas do módulo.",
    "active": true,
    "alternatives": [
     {
      "body": "O nível de envolvimento com a atividade",
      "is_correct": false
     },
     {
      "body": "O critério de decisão para o novo relógio",
      "is_correct": false
     },
     {
      "body": "Em qual universo de produto ele se encaixa",
      "is_correct": false
     },
     {
      "body": "Se é primeira compra, comparação ou upgrade",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Mariana corre três vezes por semana, faz trilhas nos fins de semana e quer um relógio mais completo. Como conduzir?",
    "explanation": "Mariana tem mais de um perfil. O vendedor descobre o que pesa mais antes de restringir a recomendação.",
    "active": true,
    "alternatives": [
     {
      "body": "Seguir pelo perfil de corrida, a primeira atividade que ela citou",
      "is_correct": false
     },
     {
      "body": "Apresentar de imediato o modelo mais completo disponível na loja",
      "is_correct": false
     },
     {
      "body": "Entender qual atividade e necessidade pesam mais na decisão dela",
      "is_correct": true
     },
     {
      "body": "Mostrar todos os relógios que atendem corrida e outdoor juntos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Quero um relógio bonito para o trabalho, mas também quero acompanhar meu sono.” Qual abordagem faz mais sentido?",
    "explanation": "Antes de apresentar uma linha lifestyle, entenda a rotina, as prioridades de saúde e como ele pretende usar o relógio.",
    "active": true,
    "alternatives": [
     {
      "body": "Apresentar direto o modelo mais elegante da linha lifestyle",
      "is_correct": false
     },
     {
      "body": "Investigar rotina, prioridades de saúde e preferência de uso",
      "is_correct": true
     },
     {
      "body": "Mostrar um Forerunner, que tem recursos de saúde mais completos",
      "is_correct": false
     },
     {
      "body": "Perguntar o orçamento antes de falar sobre qualquer recurso",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Um cliente fala em profundidade, NDL e nitrox. Qual universo de produto entra na conversa?",
    "explanation": "Profundidade, NDL e nitrox são sinais de quem precisa de um computador de mergulho: linha Descent.",
    "active": true,
    "alternatives": [
     {
      "body": "Mergulho, com a linha Descent",
      "is_correct": true
     },
     {
      "body": "Náutico, com Striker e ECHOMAP",
      "is_correct": false
     },
     {
      "body": "Outdoor, com Instinct e fēnix",
      "is_correct": false
     },
     {
      "body": "Natação, com Forerunner e HRM",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é o papel do perfil de cliente no atendimento?",
    "explanation": "O perfil serve para orientar a conversa. Um mesmo cliente pode pertencer a mais de um universo.",
    "active": true,
    "alternatives": [
     {
      "body": "Definir o produto antes das perguntas de sondagem",
      "is_correct": false
     },
     {
      "body": "Classificar o cliente em uma única categoria fixa",
      "is_correct": false
     },
     {
      "body": "Substituir a sondagem quando o cliente tem pressa",
      "is_correct": false
     },
     {
      "body": "Orientar a conversa, deixando a recomendação aberta",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "produtos",
  "quiz_id": "1522a9c2-bff5-415b-95a0-dd1995f52d45",
  "questions": [
   {
    "body": "O cliente já corre com regularidade e quer uma tela melhor e mais dados de treino, sem pagar pelo GPS multibanda. Por onde começar?",
    "explanation": "É o perfil intermediário: tela AMOLED e mais recursos de treino, ainda sem GPS multibanda.",
    "active": true,
    "alternatives": [
     {
      "body": "Forerunner 70 e 55",
      "is_correct": false
     },
     {
      "body": "Forerunner 265 e 570",
      "is_correct": false
     },
     {
      "body": "Forerunner 165 e 170",
      "is_correct": true
     },
     {
      "body": "Forerunner 965 e 970",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente compete, já tem um Garmin e busca upgrade de bateria, mapas e acabamento. Qual faixa de Forerunner faz sentido?",
    "explanation": "Alta performance a topo de linha: bateria longa, mapas topográficos e materiais premium.",
    "active": false,
    "alternatives": [
     {
      "body": "Forerunner 265, 570 e 170",
      "is_correct": false
     },
     {
      "body": "Forerunner 955, 965 e 970",
      "is_correct": true
     },
     {
      "body": "Forerunner 165, 170 e 265",
      "is_correct": false
     },
     {
      "body": "Forerunner 70, 55 e 165",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer entrar na linha Fēnix sem pagar pelos recursos mais avançados. Do que ele abre mão no Fēnix E?",
    "explanation": "O Fēnix E mantém AMOLED e mapas TopoActive, sem alto-falante nem GPS multibanda.",
    "active": true,
    "alternatives": [
     {
      "body": "Alto-falante e GPS multibanda",
      "is_correct": true
     },
     {
      "body": "Tela AMOLED e mapas TopoActive",
      "is_correct": false
     },
     {
      "body": "Monitoramento cardíaco e de sono",
      "is_correct": false
     },
     {
      "body": "Resistência à água e GPS padrão",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Em qual situação o módulo orienta a deixar o Fēnix 9 de lado?",
    "explanation": "Para quem só corre, o Forerunner é mais em conta. Remo indoor, arco e flecha, voz e expedição são justamente motivos para indicar o Fēnix 9.",
    "active": true,
    "alternatives": [
     {
      "body": "Quando o cliente pratica remo indoor ou arco e flecha",
      "is_correct": false
     },
     {
      "body": "Quando o cliente quer usar comandos por voz",
      "is_correct": false
     },
     {
      "body": "Quando o cliente quer ferramentas de expedição",
      "is_correct": false
     },
     {
      "body": "Quando o cliente só corre e quer pagar menos",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente pensaria num Forerunner topo de linha, mas também quer exclusividade de material. Qual MARQ apresentar?",
    "explanation": "A MARQ Athlete é voltada para performance esportiva de corrida e triathlon, com materiais premium.",
    "active": true,
    "alternatives": [
     {
      "body": "MARQ Commander (Gen 2)",
      "is_correct": false
     },
     {
      "body": "MARQ Golfer Carbon (Gen 2)",
      "is_correct": false
     },
     {
      "body": "MARQ Athlete (Gen 2)",
      "is_correct": true
     },
     {
      "body": "Fēnix 8 AMOLED Sapphire",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como posicionar a linha MARQ para o cliente?",
    "explanation": "O diferencial da MARQ está na combinação de tecnologia Garmin, materiais premium e posicionamento de luxo.",
    "active": true,
    "alternatives": [
     {
      "body": "O relógio Garmin com a maior quantidade de recursos esportivos",
      "is_correct": false
     },
     {
      "body": "Tecnologia Garmin com materiais premium e posicionamento de luxo",
      "is_correct": true
     },
     {
      "body": "Uma versão do Forerunner com caixa de titânio e couro italiano",
      "is_correct": false
     },
     {
      "body": "A linha mais robusta da Garmin, feita para uso militar extremo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente alterna entre academia, caminhada e outras atividades, sem foco em corrida, e quer um relógio “para tudo”. O que indicar?",
    "explanation": "O Vivoactive 6 tem mais de 80 modos esportivos e música offline, versátil para academia e dia a dia.",
    "active": true,
    "alternatives": [
     {
      "body": "Vivoactive 6",
      "is_correct": true
     },
     {
      "body": "Lily 2 Active",
      "is_correct": false
     },
     {
      "body": "Venu 4",
      "is_correct": false
     },
     {
      "body": "Forerunner 165",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Antes de falar de modelos de Edge, o que o vendedor deve investigar?",
    "explanation": "No Edge, o raciocínio começa pelo uso: lazer ou treino, estrada, MTB ou gravel, navegação, potência e duração dos pedais.",
    "active": true,
    "alternatives": [
     {
      "body": "Qual Edge o cliente viu na internet e o preço que ele encontrou",
      "is_correct": false
     },
     {
      "body": "Qual é o modelo da bicicleta e a marca dos componentes dela",
      "is_correct": false
     },
     {
      "body": "Se ele prefere tela sensível ao toque ou navegação por botões",
      "is_correct": false
     },
     {
      "body": "Se pedala por lazer ou treina, o terreno e se precisa de navegação",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Um ciclista que já usa Edge pedala em estrada com tráfego. Qual venda complementar investigar primeiro?",
    "explanation": "O radar Varia detecta veículos se aproximando por trás e alerta no Edge ou no relógio.",
    "active": true,
    "alternatives": [
     {
      "body": "Rally",
      "is_correct": false
     },
     {
      "body": "HRM 600",
      "is_correct": false
     },
     {
      "body": "Varia",
      "is_correct": true
     },
     {
      "body": "Edge 1050",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente treina de forma estruturada e quer métricas avançadas, inclusive na natação. Qual sensor cardíaco indicar?",
    "explanation": "O HRM 600 traz dinâmicas de corrida, HRV e armazenamento próprio, gravando mesmo debaixo d’água.",
    "active": true,
    "alternatives": [
     {
      "body": "HRM 200",
      "is_correct": false
     },
     {
      "body": "HRM 600",
      "is_correct": true
     },
     {
      "body": "Sensor óptico do relógio",
      "is_correct": false
     },
     {
      "body": "Rally RK 200",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Na lógica “do produto para a necessidade”, o que vem logo depois de identificar a necessidade do cliente?",
    "explanation": "Cliente fala, você identifica a necessidade, escolhe a categoria, compara modelos, apresenta o benefício e avalia a venda complementar.",
    "active": false,
    "alternatives": [
     {
      "body": "Escolher a categoria",
      "is_correct": true
     },
     {
      "body": "Comparar os modelos",
      "is_correct": false
     },
     {
      "body": "Avaliar venda complementar",
      "is_correct": false
     },
     {
      "body": "Apresentar o benefício",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como explicar a tela AMOLED de forma honesta?",
    "explanation": "AMOLED é a tela de cores vivas, parecida com a de um smartphone, e costuma gastar mais bateria. Resistência a arranhões é argumento do cristal de safira.",
    "active": true,
    "alternatives": [
     {
      "body": "Tela mais resistente a arranhões do que o vidro comum",
      "is_correct": false
     },
     {
      "body": "Tela que se lê melhor no sol forte e economiza bateria",
      "is_correct": false
     },
     {
      "body": "Tela que carrega o relógio com luz solar durante o dia",
      "is_correct": false
     },
     {
      "body": "Tela mais bonita e nítida, que costuma gastar mais bateria",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "concorrentes",
  "quiz_id": "4418d2b8-4fdc-4a9a-b485-405526581739",
  "questions": [
   {
    "body": "Cliente: “Estou entre Garmin e Apple Watch.” Qual é a primeira reação recomendada?",
    "explanation": "A pergunta “o que fez você considerar essa outra marca?” revela o critério real de decisão.",
    "active": true,
    "alternatives": [
     {
      "body": "Listar as vantagens da Garmin sobre o Apple Watch",
      "is_correct": false
     },
     {
      "body": "Mostrar a diferença de bateria entre os dois relógios",
      "is_correct": false
     },
     {
      "body": "Apresentar um Garmin com tela AMOLED parecida",
      "is_correct": false
     },
     {
      "body": "Perguntar o que fez ele considerar a outra marca",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual cliente é o público natural do Apple Watch, segundo o módulo?",
    "explanation": "O Apple Watch atende quem quer uma extensão do iPhone no pulso. As outras opções descrevem os públicos de Polar, Coros e Galaxy Watch.",
    "active": true,
    "alternatives": [
     {
      "body": "Atleta que analisa zonas de frequência cardíaca com um coach",
      "is_correct": false
     },
     {
      "body": "Corredor sensível a preço que quer funções avançadas de treino",
      "is_correct": false
     },
     {
      "body": "Usuário de iPhone que quer notificações e Apple Pay no pulso",
      "is_correct": true
     },
     {
      "body": "Usuário de Galaxy S que já usa Samsung Pay no dia a dia",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “O Apple Watch é mais bonito.” Qual resposta segue o módulo?",
    "explanation": "A percepção estética do cliente é respeitada. O que define o rumo da conversa é o uso principal do relógio.",
    "active": true,
    "alternatives": [
     {
      "body": "Explicar que o Garmin entrega bem mais dados de treino que o Apple Watch",
      "is_correct": false
     },
     {
      "body": "Concordar e perguntar se o uso será no dia a dia ou também em treinos",
      "is_correct": true
     },
     {
      "body": "Mostrar que a bateria do Apple Watch dura só um ou dois dias de uso",
      "is_correct": false
     },
     {
      "body": "Apresentar o Garmin mais caro da loja para mostrar o acabamento dele",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “A análise de frequência cardíaca da Polar é melhor.” O que o vendedor faz primeiro?",
    "explanation": "Primeiro se reconhece o mérito da Polar. Depois se mostra onde a Garmin também atende essa necessidade.",
    "active": true,
    "alternatives": [
     {
      "body": "Reconhecer que o cinto H10 é referência em precisão",
      "is_correct": true
     },
     {
      "body": "Mostrar que o sensor Elevate Gen 5 supera o cinto H10",
      "is_correct": false
     },
     {
      "body": "Explicar que o FirstBeat é usado por times profissionais",
      "is_correct": false
     },
     {
      "body": "Sugerir que ele compare os dados dos dois em casa",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “O Coros é muito mais barato.” Qual pergunta leva a conversa para o valor?",
    "explanation": "Preço não se combate com desconto automático. A pergunta sobre o investimento leva a conversa para o que o cliente pretende fazer com o relógio.",
    "active": true,
    "alternatives": [
     {
      "body": "“Quanto você está disposto a pagar no relógio?”",
      "is_correct": false
     },
     {
      "body": "“Você já viu o nosso modelo Garmin de entrada?”",
      "is_correct": false
     },
     {
      "body": "“Se eu conseguir um desconto, você fecha hoje?”",
      "is_correct": false
     },
     {
      "body": "“O que você espera receber desse investimento?”",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual ponto forte do Coros o vendedor deve reconhecer com honestidade?",
    "explanation": "Preço de 30% a 40% menor, boa bateria e interface simples são pontos reais do Coros. As outras opções são diferenciais da Garmin.",
    "active": true,
    "alternatives": [
     {
      "body": "Ecossistema mais amplo de apps e integrações externas",
      "is_correct": false
     },
     {
      "body": "Suporte presencial e garantia oficial aqui no Brasil",
      "is_correct": false
     },
     {
      "body": "Preço menor em modelos equivalentes e interface simples",
      "is_correct": true
     },
     {
      "body": "Mais modalidades atendidas, incluindo mergulho e golfe",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Tenho Samsung, o Galaxy Watch não seria melhor?” O que define a recomendação?",
    "explanation": "Ter Samsung não define a melhor escolha. O que define é como o relógio será usado.",
    "active": true,
    "alternatives": [
     {
      "body": "O modelo do celular e a versão do Android instalada",
      "is_correct": false
     },
     {
      "body": "Como ele usa o relógio e o peso do treino na rotina",
      "is_correct": true
     },
     {
      "body": "A preferência que ele tem pela marca Samsung",
      "is_correct": false
     },
     {
      "body": "O valor que ele pretende investir no relógio",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente cita um review dizendo que o Coros é melhor para trilha. Como responder?",
    "explanation": "A fonte que o cliente trouxe é respeitada, e a resposta vem com dado técnico, como certificação, altímetro, bússola e bateria.",
    "active": true,
    "alternatives": [
     {
      "body": "Validar os bons modelos do Coros e comparar dados técnicos lado a lado",
      "is_correct": true
     },
     {
      "body": "Questionar se o review foi patrocinado pela marca concorrente",
      "is_correct": false
     },
     {
      "body": "Explicar que reviews da internet costumam ser pouco confiáveis",
      "is_correct": false
     },
     {
      "body": "Levar a conversa para um esporte em que a Garmin se destaca mais",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a ordem do tratamento de objeções?",
    "explanation": "Deixe o cliente terminar, descubra a causa, responda a essa causa e confirme que a dúvida foi resolvida.",
    "active": false,
    "alternatives": [
     {
      "body": "Entender, responder, ouvir, confirmar",
      "is_correct": false
     },
     {
      "body": "Ouvir, responder, confirmar, entender",
      "is_correct": false
     },
     {
      "body": "Responder, ouvir, entender, confirmar",
      "is_correct": false
     },
     {
      "body": "Ouvir, entender, responder, confirmar",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “Tá caro, vou pesquisar online.” Qual condução segue o módulo?",
    "explanation": "O caminho é mostrar o valor da compra presencial, como garantia de 2 anos, assistência oficial e configuração na hora, sem inventar risco.",
    "active": true,
    "alternatives": [
     {
      "body": "Alertar que produtos vendidos online podem ser falsificados",
      "is_correct": false
     },
     {
      "body": "Igualar o preço da internet para não perder a venda",
      "is_correct": false
     },
     {
      "body": "Mostrar a garantia, a assistência e a configuração na loja",
      "is_correct": true
     },
     {
      "body": "Explicar que o preço da loja segue a tabela oficial",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente gostou do relógio, mas diz: “Vou pensar e volto depois.” Qual conduta o módulo recomenda?",
    "explanation": "Muitas vezes falta segurança, não tempo. Manter o canal aberto funciona melhor do que pressionar.",
    "active": true,
    "alternatives": [
     {
      "body": "Avisar que o estoque é limitado para acelerar a decisão",
      "is_correct": false
     },
     {
      "body": "Anotar o modelo e deixar um canal aberto para dúvidas",
      "is_correct": true
     },
     {
      "body": "Oferecer um desconto para fechar a venda na mesma hora",
      "is_correct": false
     },
     {
      "body": "Reapresentar todos os recursos para reforçar o valor",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "script",
  "quiz_id": "dd42dee7-ce12-4ef2-a937-603e005f3fe9",
  "questions": [
   {
    "body": "Qual é o objetivo da etapa de recepção?",
    "explanation": "A recepção abre espaço para uma conversa. A apresentação vem depois da descoberta.",
    "active": true,
    "alternatives": [
     {
      "body": "Abrir espaço para uma conversa",
      "is_correct": true
     },
     {
      "body": "Iniciar a apresentação do produto",
      "is_correct": false
     },
     {
      "body": "Descobrir o orçamento do cliente",
      "is_correct": false
     },
     {
      "body": "Mostrar os lançamentos da loja",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Um cliente acabou de entrar e está olhando os produtos. Qual é a postura recomendada?",
    "explanation": "Quem está explorando não precisa de uma apresentação completa. O vendedor fica disponível sem invadir.",
    "active": true,
    "alternatives": [
     {
      "body": "Apresentar os lançamentos antes que ele perca o interesse",
      "is_correct": false
     },
     {
      "body": "Perguntar logo qual modelo ele veio procurar na loja",
      "is_correct": false
     },
     {
      "body": "Esperar em silêncio até que ele chame algum vendedor",
      "is_correct": false
     },
     {
      "body": "Ficar disponível sem invadir e observar o comportamento",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual pergunta abre melhor a descoberta?",
    "explanation": "Uma boa pergunta inicial abre a conversa, em vez de fechar o cliente numa resposta de sim ou não.",
    "active": true,
    "alternatives": [
     {
      "body": "“Você está procurando um relógio de corrida ou de ciclismo?”",
      "is_correct": false
     },
     {
      "body": "“Você já conhece o Forerunner 265 que acabou de chegar?”",
      "is_correct": false
     },
     {
      "body": "“Qual atividade tem mais espaço na sua rotina hoje?”",
      "is_correct": true
     },
     {
      "body": "“Você quer um relógio com GPS e monitor cardíaco?”",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Procuro um relógio para correr, mas também quero usar no dia a dia.” Qual é a melhor continuação?",
    "explanation": "A pergunta considera as duas coisas que o cliente falou e descobre qual deve pesar mais na recomendação.",
    "active": true,
    "alternatives": [
     {
      "body": "Perguntar quantas vezes por semana ele costuma correr hoje",
      "is_correct": false
     },
     {
      "body": "Perguntar se a prioridade é a evolução na corrida ou a rotina",
      "is_correct": true
     },
     {
      "body": "Mostrar os modelos de corrida que mais vendem aqui na loja",
      "is_correct": false
     },
     {
      "body": "Apresentar um smartwatch pensado para o uso no dia a dia",
      "is_correct": false
     }
    ]
   },
   {
    "body": "A pergunta “Você corre por saúde, performance ou para uma prova?” aprofunda qual dimensão?",
    "explanation": "Objetivo é o que o cliente quer alcançar. Frequência, experiência e prioridade são as outras três dimensões do aprofundamento.",
    "active": false,
    "alternatives": [
     {
      "body": "Objetivo",
      "is_correct": true
     },
     {
      "body": "Frequência",
      "is_correct": false
     },
     {
      "body": "Experiência",
      "is_correct": false
     },
     {
      "body": "Prioridade",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Corro três vezes por semana, já tenho relógio e quero melhorar meu desempenho.” O que descobrir antes de recomendar?",
    "explanation": "“Melhorar o desempenho” pode significar coisas muito diferentes, e cada uma aponta para um produto diferente.",
    "active": true,
    "alternatives": [
     {
      "body": "Há quanto tempo ele usa o relógio atual e se ainda funciona bem",
      "is_correct": false
     },
     {
      "body": "Qual marca de relógio ele usa hoje e quanto pagou por ele",
      "is_correct": false
     },
     {
      "body": "Se ele prefere uma caixa maior ou menor que a do relógio atual",
      "is_correct": false
     },
     {
      "body": "O que exatamente ele quer melhorar: ritmo, resistência ou prova",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual estrutura a recomendação segue?",
    "explanation": "O produto específico aparece por último, depois da necessidade, da característica relevante e do benefício.",
    "active": false,
    "alternatives": [
     {
      "body": "Produto, característica, benefício, preço",
      "is_correct": false
     },
     {
      "body": "Característica, produto, necessidade, benefício",
      "is_correct": false
     },
     {
      "body": "Necessidade, característica, benefício, produto",
      "is_correct": true
     },
     {
      "body": "Benefício, produto, preço, necessidade",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Depois da descoberta, três critérios reduziram as opções a dois modelos. O que fazer?",
    "explanation": "O vendedor atua como curador. Um atendimento premium reduz a complexidade da escolha.",
    "active": true,
    "alternatives": [
     {
      "body": "Apresentar cinco modelos para ampliar a comparação",
      "is_correct": false
     },
     {
      "body": "Apresentar os dois e explicar por que cada um atende",
      "is_correct": true
     },
     {
      "body": "Mostrar a linha completa para o cliente escolher",
      "is_correct": false
     },
     {
      "body": "Apresentar só o mais caro para valorizar a venda",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Meu maior problema é saber se estou recuperado para treinar.” Por onde começar a demonstração?",
    "explanation": "Quando o cliente apresenta uma necessidade clara, a demonstração começa exatamente por ela.",
    "active": true,
    "alternatives": [
     {
      "body": "Pelos recursos de prontidão, recuperação e carga",
      "is_correct": true
     },
     {
      "body": "Pelo mostrador e pela navegação entre os menus",
      "is_correct": false
     },
     {
      "body": "Pela lista completa de funções do relógio",
      "is_correct": false
     },
     {
      "body": "Pelos modos esportivos disponíveis no relógio",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Meu celular já faz isso.” O que provavelmente está por trás dessa frase?",
    "explanation": "Cada frase tem uma causa provável. “Meu celular já faz isso” costuma indicar que o cliente ainda não conhece a diferença.",
    "active": true,
    "alternatives": [
     {
      "body": "Falta de segurança para tomar a decisão",
      "is_correct": false
     },
     {
      "body": "Uma necessidade que ainda não foi identificada",
      "is_correct": false
     },
     {
      "body": "Falta de percepção de valor no preço",
      "is_correct": false
     },
     {
      "body": "Falta de conhecimento sobre a diferença real",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “Achei caro.” Qual é a primeira resposta recomendada?",
    "explanation": "Primeiro se entende o que está por trás da objeção. A partir da resposta, o vendedor escolhe o argumento.",
    "active": true,
    "alternatives": [
     {
      "body": "Listar as funções que justificam o preço deste relógio",
      "is_correct": false
     },
     {
      "body": "Oferecer parcelamento para reduzir o valor de cada mês",
      "is_correct": false
     },
     {
      "body": "Entender se pesa o investimento inicial ou o uso esperado",
      "is_correct": true
     },
     {
      "body": "Mostrar um modelo mais barato dentro da mesma linha",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Antes de o cliente sair da loja, o que faz parte do pós-venda?",
    "explanation": "Orientar a ativação, apresentar o Garmin Connect quando fizer sentido e confirmar dúvidas transforma a venda em relacionamento.",
    "active": true,
    "alternatives": [
     {
      "body": "Entregar a nota e indicar o manual que vem na caixa",
      "is_correct": false
     },
     {
      "body": "Orientar os primeiros passos e confirmar as dúvidas",
      "is_correct": true
     },
     {
      "body": "Oferecer a extensão de garantia e os acessórios",
      "is_correct": false
     },
     {
      "body": "Indicar o site da Garmin para tirar dúvidas depois",
      "is_correct": false
     }
    ]
   }
  ]
 }
]$q$::jsonb;
  z jsonb;
  q jsonb;
  a jsonb;
  qi int;
  ai int;
  v_qid uuid;
  v_new_ids uuid[];
begin
  for z in select * from jsonb_array_elements(v_data) loop
    -- Ids das perguntas novas (determinísticos) calculados antes de inserir.
    select coalesce(array_agg(md5('explorador-quiz-v2|' || (z->>'key') || '|' || g)::uuid), '{}')
      into v_new_ids
      from generate_series(0, jsonb_array_length(z->'questions') - 1) as g;

    -- uq_questions_quiz_order impede duas perguntas do mesmo quiz na mesma
    -- posição, inclusive as inativas. As antigas saem do caminho (posição
    -- + 100000, com o histórico intacto) antes de as novas ocuparem 0..n.
    update questions
       set is_active = false,
           order_index = order_index + 100000
     where quiz_id = (z->>'quiz_id')::uuid
       and order_index < 100000
       and id <> all (v_new_ids);

    for q, qi in select e, (o - 1)::int from jsonb_array_elements(z->'questions') with ordinality as t(e, o) loop
      v_qid := md5('explorador-quiz-v2|' || (z->>'key') || '|' || qi)::uuid;

      insert into questions (id, quiz_id, body, explanation, order_index, is_active)
      values (v_qid, (z->>'quiz_id')::uuid, q->>'body', q->>'explanation', qi, (q->>'active')::boolean)
      on conflict (id) do update
         set body = excluded.body, explanation = excluded.explanation,
             order_index = excluded.order_index, is_active = excluded.is_active;

      for a, ai in select e, (o - 1)::int from jsonb_array_elements(q->'alternatives') with ordinality as t(e, o) loop
        insert into alternatives (id, question_id, body, is_correct, order_index)
        values (md5('explorador-quiz-v2|' || (z->>'key') || '|' || qi || '|' || ai)::uuid, v_qid,
                a->>'body', (a->>'is_correct')::boolean, ai)
        on conflict (id) do update
           set body = excluded.body, is_correct = excluded.is_correct, order_index = excluded.order_index;
      end loop;
    end loop;

    -- Perguntas antigas do quiz saem de cena, sem apagar o histórico.
    update questions
       set is_active = false
     where quiz_id = (z->>'quiz_id')::uuid
       and id <> all (v_new_ids)
       and is_active;
  end loop;
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 172
-- ============================================================================
