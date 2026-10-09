-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 173: quizzes das zonas Atleta, Maratonista, Triatleta e Aventureiro refeitos
-- ============================================================================
-- Pedido do usuário (2026-10-08): mesma revisão feita na Zona Explorador
-- (sql/172) para as demais zonas da trilha. Os quizzes foram comparados
-- com o conteúdo atual das lições e reescritos. Problemas encontrados:
--   - respostas "certas" que contradizem as lições: Status de Treinamento
--     "antes de virar lesão" (Garmin Connect); Coach "gratuito", "adapta
--     automaticamente" e "evita lesão"; Galloway indicado para quem volta
--     de lesão, quando a lição indica Amy Parkerson-Mitchell;
--   - conteúdo que saiu das lições (bancos do Garmin Pay, MyFitnessPal,
--     "Auto Sport Change", Earthmate) e os 3 módulos da Zona Maratonista
--     redesenhados em sql/168, 169 e 171 com quiz antigo;
--   - alternativas erradas absurdas e resposta certa sempre a mais longa;
--   - quiz Cartografia e Navegação Avançada estava vazio (0 perguntas).
--
-- 17 quizzes: Garmin Connect, Garmin Coach, Métricas de Corrida, Linha
-- Edge, Potência e Dinâmica de Pedal, Objeções de Preço, Portfólio de
-- Endurance, Triângulo da Prontidão, Ferramentas de Ritmo, Segurança e
-- Aclimatação, Universo Multiesporte, GPS Multibanda, Ecossistema de
-- Sensores, Fechamento Premium, Portfólio inReach, Cartografia (novo) e
-- Diferenciais inReach.
--
-- Limite de 10 perguntas ativas por quiz (pedido de 2026-10-08): as
-- perguntas listadas em drops.mjs continuam gravadas, com is_active = false.
-- O Fechamento de Vendas Premium ganhou uma 10a pergunta.
--
-- Mesmo mecanismo da sql/172: perguntas antigas ficam is_active = false
-- (histórico de tentativas preservado), ids determinísticos (rodar de novo
-- só atualiza), nota de corte e configurações dos quizzes não mudam.
-- Gerado a partir de quiz_data_zonas.mjs, com checagem automática de
-- tamanho das alternativas, travessão e emoji.
-- ============================================================================

do $$
declare
  v_data jsonb := $q$[
 {
  "key": "connect",
  "quiz_id": "6fceb4b1-c342-4a07-9dff-51a77abf6d27",
  "questions": [
   {
    "body": "Cliente: “Se eu não instalar o aplicativo, o relógio funciona?” Qual resposta segue o módulo?",
    "explanation": "O relógio funciona normalmente sem o aplicativo. O Garmin Connect organiza histórico, tendências e informações.",
    "active": true,
    "alternatives": [
     {
      "body": "Funciona, e o app amplia a experiência com histórico e tendências",
      "is_correct": true
     },
     {
      "body": "Funciona só para ver as horas até a primeira sincronização",
      "is_correct": false
     },
     {
      "body": "Funciona, mas os treinos deixam de ser registrados no relógio",
      "is_correct": false
     },
     {
      "body": "Precisa do app para ativar os sensores de frequência cardíaca",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Esse Body Battery serve para quê?” Qual explicação funciona melhor?",
    "explanation": "Uma definição técnica, como “de 0 a 100”, explica pouco. O cliente precisa entender o significado da informação na própria rotina.",
    "active": true,
    "alternatives": [
     {
      "body": "É uma métrica que vai de 0 a 100 pontos no relógio",
      "is_correct": false
     },
     {
      "body": "Mostra se a sua saúde está em dia com base nos dados",
      "is_correct": false
     },
     {
      "body": "Indica quanto tempo falta para recarregar o relógio",
      "is_correct": false
     },
     {
      "body": "Mostra como a sua energia se comporta ao longo do dia",
      "is_correct": true
     }
    ]
   },
   {
    "body": "No que se baseia a estimativa de Estresse do relógio?",
    "explanation": "O Estresse é uma estimativa baseada na variabilidade da frequência cardíaca durante períodos de repouso.",
    "active": false,
    "alternatives": [
     {
      "body": "Na contagem de passos acumulada ao longo do dia",
      "is_correct": false
     },
     {
      "body": "Na temperatura da pele medida durante o dia",
      "is_correct": false
     },
     {
      "body": "Na variabilidade da frequência cardíaca em repouso",
      "is_correct": true
     },
     {
      "body": "Na quantidade de horas dormidas na noite anterior",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Em que momento o Status de VFC acompanha a variabilidade da frequência cardíaca?",
    "explanation": "O Status de VFC acompanha a variabilidade durante o sono e mostra o comportamento dela ao longo do tempo.",
    "active": false,
    "alternatives": [
     {
      "body": "Durante os treinos",
      "is_correct": false
     },
     {
      "body": "Durante o sono",
      "is_correct": true
     },
     {
      "body": "Em uma medição manual",
      "is_correct": false
     },
     {
      "body": "A cada hora do dia",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Ana trabalha em home office, nunca treinou com regularidade e quer se movimentar mais. O que mostrar primeiro?",
    "explanation": "Ana ainda não procura performance. A demonstração começa pelo que tem relação direta com a rotina que ela quer melhorar.",
    "active": true,
    "alternatives": [
     {
      "body": "Body Battery, Passos, Estresse e Sono",
      "is_correct": true
     },
     {
      "body": "VO2 Max, Status de Treinamento e Potência",
      "is_correct": false
     },
     {
      "body": "Minutos de Intensidade, VFC e Calorias",
      "is_correct": false
     },
     {
      "body": "Mapas, navegação e altímetro barométrico",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Rafael treina na academia quatro vezes por semana e quer começar a correr e evoluir. Quais informações fazem mais sentido?",
    "explanation": "Rafael já demonstra interesse em treinamento e evolução, então a conversa aprofunda carga, treinamento e recuperação.",
    "active": true,
    "alternatives": [
     {
      "body": "Passos, Hidratação e Monitoramento de Hábitos",
      "is_correct": false
     },
     {
      "body": "Body Battery, Passos e Sleep Score no dia a dia",
      "is_correct": false
     },
     {
      "body": "Garmin Pay, Música e Monitoramento de Hábitos",
      "is_correct": false
     },
     {
      "body": "Minutos de Intensidade, Status de Treinamento e VFC",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cláudia é executiva, viaja muito, quer acompanhar a recuperação e valoriza praticidade. Como conduzir a demonstração?",
    "explanation": "A necessidade principal define o início: Sleep Score, Body Battery e Estresse. Garmin Pay e Música complementam depois, se o modelo tiver.",
    "active": true,
    "alternatives": [
     {
      "body": "Começar por Garmin Pay e Música e depois a recuperação",
      "is_correct": false
     },
     {
      "body": "Começar pelas métricas de corrida, que mostram o cansaço",
      "is_correct": false
     },
     {
      "body": "Começar pela recuperação e depois mostrar praticidade",
      "is_correct": true
     },
     {
      "body": "Começar pelo design, que pesa mais para quem viaja",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Bruno, 55 anos, está começando a se exercitar e tem pouca familiaridade com tecnologia. Qual é a melhor abordagem?",
    "explanation": "Conhecer o produto também é saber o que deixar para depois. O iniciante entende o básico primeiro.",
    "active": false,
    "alternatives": [
     {
      "body": "Começar pelo Status de Treinamento do relógio",
      "is_correct": false
     },
     {
      "body": "Começar por passos, sono e frequência cardíaca",
      "is_correct": true
     },
     {
      "body": "Mostrar todas as métricas para ele escolher",
      "is_correct": false
     },
     {
      "body": "Começar pelas configurações mais avançadas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual frase sobre o Status de Treinamento respeita o que o módulo ensina?",
    "explanation": "O Status de Treinamento relaciona a carga recente com a evolução. A lição orienta a nunca dizer que ele prevê ou evita lesões.",
    "active": true,
    "alternatives": [
     {
      "body": "Coloca seus treinos recentes em contexto e mostra a evolução",
      "is_correct": true
     },
     {
      "body": "Avisa quando você está treinando demais, antes de virar lesão",
      "is_correct": false
     },
     {
      "body": "Compara o seu condicionamento com o de outros atletas da idade",
      "is_correct": false
     },
     {
      "body": "Define sozinho qual é o treino ideal para o dia seguinte",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como apresentar o SpO2 a um cliente?",
    "explanation": "O SpO2 aparece em modelos com o sensor e o recurso correspondente e nunca deve ser apresentado como diagnóstico.",
    "active": true,
    "alternatives": [
     {
      "body": "Como recurso que identifica apneia durante o sono",
      "is_correct": false
     },
     {
      "body": "Como medição presente em toda a linha Garmin",
      "is_correct": false
     },
     {
      "body": "Como alerta que avisa sobre doenças respiratórias",
      "is_correct": false
     },
     {
      "body": "Como informação adicional em modelos compatíveis",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “Gosto de correr sem levar o celular.” Qual resposta segue o módulo?",
    "explanation": "Música no relógio depende do modelo, do serviço e de um fone Bluetooth separado. O argumento precisa estar ligado ao modelo certo.",
    "active": true,
    "alternatives": [
     {
      "body": "Qualquer Garmin com Bluetooth toca música sem o celular",
      "is_correct": false
     },
     {
      "body": "Todo Garmin tem Spotify, basta conectar o seu fone",
      "is_correct": false
     },
     {
      "body": "Alguns modelos guardam música; vamos ver qual faz sentido",
      "is_correct": true
     },
     {
      "body": "Você vai precisar de um fone da Garmin para ouvir música",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Antes de usar o Garmin Pay como argumento, o que o vendedor confirma?",
    "explanation": "Nem todos os modelos têm NFC, e a compatibilidade de cartões e bancos varia. Confirme antes de prometer.",
    "active": true,
    "alternatives": [
     {
      "body": "Se o cliente tem conta em algum banco digital brasileiro",
      "is_correct": false
     },
     {
      "body": "Se o modelo tem NFC e se o cartão do cliente é elegível",
      "is_correct": true
     },
     {
      "body": "Se o celular do cliente tem NFC com aproximação ativa",
      "is_correct": false
     },
     {
      "body": "Se o cliente assina o plano pago do Garmin Connect",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Durmo bem, mas me sinto cansado o dia inteiro.” Qual combinação de dados ajuda a contextualizar?",
    "explanation": "O sono mostra como o dia começou e o Body Battery mostra como a energia se comporta depois.",
    "active": true,
    "alternatives": [
     {
      "body": "Sono + Body Battery",
      "is_correct": true
     },
     {
      "body": "Passos + Hábitos",
      "is_correct": false
     },
     {
      "body": "Treinamento + VFC",
      "is_correct": false
     },
     {
      "body": "Estresse + Calorias",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "coach",
  "quiz_id": "0048a818-d7f3-4766-8196-8e9e948f734a",
  "questions": [
   {
    "body": "Qual frase resume o Garmin Coach para o cliente?",
    "explanation": "Objetivo, plano e treinos no relógio, tudo integrado ao Garmin Connect. Sem prometer ajuste automático nem gratuidade vitalícia.",
    "active": true,
    "alternatives": [
     {
      "body": "“É um aplicativo separado que monta planilhas fixas de treino para você.”",
      "is_correct": false
     },
     {
      "body": "“Você define o objetivo, escolhe um plano e recebe os treinos no relógio.”",
      "is_correct": true
     },
     {
      "body": "“É um treinador que ajusta sozinho cada treino conforme o seu cansaço.”",
      "is_correct": false
     },
     {
      "body": "“É um serviço de consultoria esportiva gratuito e vitalício no relógio.”",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que diferencia o Garmin Coach de uma planilha fixa de treinos?",
    "explanation": "Na planilha fixa, a sequência não muda. No Coach, objetivo, treino, resultado e acompanhamento orientam os próximos passos.",
    "active": true,
    "alternatives": [
     {
      "body": "O acompanhamento dos treinos orienta os próximos passos",
      "is_correct": true
     },
     {
      "body": "O plano reduz a intensidade sozinho quando o sono é ruim",
      "is_correct": false
     },
     {
      "body": "Os treinos são os mesmos, só que aparecem no relógio",
      "is_correct": false
     },
     {
      "body": "Um treinador revisa o plano por mensagem toda semana",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Quero começar a treinar, mas não sei montar meus treinos.” O que fazer?",
    "explanation": "Descobrir o objetivo permite indicar o plano certo e conecta a necessidade do cliente ao produto.",
    "active": true,
    "alternatives": [
     {
      "body": "Mostrar as métricas de treino que o relógio registra",
      "is_correct": false
     },
     {
      "body": "Apresentar todos os recursos do Garmin Connect",
      "is_correct": false
     },
     {
      "body": "Montar com ele um treino estruturado na própria loja",
      "is_correct": false
     },
     {
      "body": "Perguntar o objetivo e apresentar o Garmin Coach",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente quer correr, mas está preocupado com dores e com a mecânica da corrida. Qual treinador Expert indicar?",
    "explanation": "Amy Parkerson-Mitchell trabalha mecânica corporal e atenção a dores e lesões.",
    "active": true,
    "alternatives": [
     {
      "body": "Jeff Galloway",
      "is_correct": false
     },
     {
      "body": "Greg McMillan",
      "is_correct": false
     },
     {
      "body": "Amy Parkerson-Mitchell",
      "is_correct": true
     },
     {
      "body": "Run Coach sem treinador Expert",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente está voltando a correr depois de um tempo parado e quer recomeçar de forma gradual. Qual treinador Expert indicar?",
    "explanation": "Jeff Galloway usa o método Run Walk Run, que alterna corrida e caminhada, indicado para iniciantes e retomada.",
    "active": true,
    "alternatives": [
     {
      "body": "Greg McMillan",
      "is_correct": false
     },
     {
      "body": "Jeff Galloway",
      "is_correct": true
     },
     {
      "body": "Amy Parkerson-Mitchell",
      "is_correct": false
     },
     {
      "body": "Plano de força antes da corrida",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente já corre há anos e quer baixar o tempo nos 10 km. Qual treinador Expert faz mais sentido?",
    "explanation": "Greg McMillan trabalha ritmo, zonas de treino e fisiologia aplicada, para quem quer melhorar o desempenho.",
    "active": true,
    "alternatives": [
     {
      "body": "Greg McMillan",
      "is_correct": true
     },
     {
      "body": "Jeff Galloway",
      "is_correct": false
     },
     {
      "body": "Amy Parkerson-Mitchell",
      "is_correct": false
     },
     {
      "body": "Garmin Cycling Coach",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que determinados planos do Garmin Cycling Coach exigem?",
    "explanation": "Determinados planos de ciclismo exigem monitor de frequência cardíaca ou medidor de potência. Usar os dois juntos é recomendado.",
    "active": false,
    "alternatives": [
     {
      "body": "Assinatura ativa do Garmin Connect+ no aplicativo",
      "is_correct": false
     },
     {
      "body": "Um smart trainer Tacx conectado ao Edge ou relógio",
      "is_correct": false
     },
     {
      "body": "Um Edge com tela sensível ao toque e mapas completos",
      "is_correct": false
     },
     {
      "body": "Monitor de frequência cardíaca ou medidor de potência",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como o cliente monta um plano de treinamento de força no Garmin Coach?",
    "explanation": "Objetivo (hipertrofia, força ou condicionamento), equipamento (halteres, barras ou peso corporal) e foco muscular.",
    "active": true,
    "alternatives": [
     {
      "body": "Escolhendo um treinador Expert de musculação",
      "is_correct": false
     },
     {
      "body": "Importando a planilha da academia para o app",
      "is_correct": false
     },
     {
      "body": "Escolhendo objetivo, equipamento e foco muscular",
      "is_correct": true
     },
     {
      "body": "Escolhendo a distância e o ritmo-alvo do plano",
      "is_correct": false
     }
    ]
   },
   {
    "body": "No plano de triatlo, o que são as sessões two-a-day?",
    "explanation": "Two-a-day são dois treinos estruturados no mesmo dia, ao lado dos dias de piscina do plano de triatlo.",
    "active": false,
    "alternatives": [
     {
      "body": "Dois planos Garmin Coach ativos juntos",
      "is_correct": false
     },
     {
      "body": "Dois treinos estruturados no mesmo dia",
      "is_correct": true
     },
     {
      "body": "Um treino que une natação e corrida",
      "is_correct": false
     },
     {
      "body": "Duas semanas de polimento antes da prova",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente vai viajar por duas semanas e quer interromper o plano sem perder o progresso. O que ele deve fazer?",
    "explanation": "Pausar mantém o progresso. Sair remove os treinos futuros, e para retomar é preciso começar um plano do zero.",
    "active": true,
    "alternatives": [
     {
      "body": "Pausar o plano",
      "is_correct": true
     },
     {
      "body": "Sair do plano",
      "is_correct": false
     },
     {
      "body": "Apagar os treinos futuros",
      "is_correct": false
     },
     {
      "body": "Criar outro plano na volta",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Onde o cliente reagenda treinos de um plano de ciclismo autoguiado?",
    "explanation": "Planos de ciclismo autoguiado exigem o Garmin Connect Web para reagendar treinos.",
    "active": false,
    "alternatives": [
     {
      "body": "No app Garmin Connect",
      "is_correct": false
     },
     {
      "body": "Direto no próprio Edge",
      "is_correct": false
     },
     {
      "body": "No Garmin Express no PC",
      "is_correct": false
     },
     {
      "body": "No Garmin Connect Web",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O plano foi criado só para completar a distância, sem meta de tempo. O que acontece com o Confidence Score?",
    "explanation": "O Confidence Score depende de uma meta de tempo ou ritmo. Sem ela, o indicador não aparece da mesma forma.",
    "active": true,
    "alternatives": [
     {
      "body": "Fica vermelho até o atleta definir meta",
      "is_correct": false
     },
     {
      "body": "Passa a medir só a distância percorrida",
      "is_correct": false
     },
     {
      "body": "Deixa de ser exibido da mesma forma",
      "is_correct": true
     },
     {
      "body": "Aparece sempre em roxo, por falta de meta",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Durante um treino guiado de corrida, o que a barra de ritmo mostra?",
    "explanation": "A barra mostra o ritmo médio da etapa ou da volta atual, e não o ritmo instantâneo.",
    "active": false,
    "alternatives": [
     {
      "body": "O ritmo instantâneo de cada passada",
      "is_correct": false
     },
     {
      "body": "O ritmo médio da etapa ou volta atual",
      "is_correct": true
     },
     {
      "body": "O ritmo médio da atividade inteira",
      "is_correct": false
     },
     {
      "body": "O ritmo previsto para a prova-alvo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Garmin Coach não aparece no relógio do cliente. Qual é o primeiro passo?",
    "explanation": "O Garmin Express atualiza o software do relógio pelo computador. Se o Coach não aparece, atualizar é o primeiro passo.",
    "active": true,
    "alternatives": [
     {
      "body": "Atualizar o software do relógio pelo Garmin Express",
      "is_correct": true
     },
     {
      "body": "Reinstalar o aplicativo Garmin Connect no celular",
      "is_correct": false
     },
     {
      "body": "Refazer o pareamento do relógio por Bluetooth",
      "is_correct": false
     },
     {
      "body": "Verificar se existe algum plano pausado na conta",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quantos planos Garmin Coach o cliente pode ter ativos ao mesmo tempo?",
    "explanation": "Apenas um plano Garmin Coach fica ativo por vez.",
    "active": false,
    "alternatives": [
     {
      "body": "Um por modalidade",
      "is_correct": false
     },
     {
      "body": "Até três planos",
      "is_correct": false
     },
     {
      "body": "Ilimitados no Connect+",
      "is_correct": false
     },
     {
      "body": "Um plano por vez",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "metricas",
  "quiz_id": "032d0cd4-dc60-4c7d-b0eb-6d103883636f",
  "questions": [
   {
    "body": "O relógio mostra 5:00 min/km. O que isso significa?",
    "explanation": "Pace é o tempo para percorrer 1 km. Quanto menor o número, mais rápido o ritmo.",
    "active": true,
    "alternatives": [
     {
      "body": "Corre a uma velocidade média de 5 km por hora",
      "is_correct": false
     },
     {
      "body": "Completou os primeiros 5 km em menos de uma hora",
      "is_correct": false
     },
     {
      "body": "Leva 5 minutos para percorrer cada quilômetro",
      "is_correct": true
     },
     {
      "body": "Faz cerca de 500 passadas a cada quilômetro",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Em um treino de cinco tiros de 1 km, qual referência de ritmo é mais útil?",
    "explanation": "O Pace da Volta mostra o ritmo de um trecho específico, especialmente útil em treinos intervalados.",
    "active": false,
    "alternatives": [
     {
      "body": "Pace Médio da atividade",
      "is_correct": false
     },
     {
      "body": "Pace da Volta (Lap)",
      "is_correct": true
     },
     {
      "body": "Pace Instantâneo",
      "is_correct": false
     },
     {
      "body": "Cadência em spm",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que uma cadência baixa costuma sinalizar?",
    "explanation": "Cadência baixa sinaliza overstride. Elevar a cadência reduz o efeito de frenagem e a sobrecarga nos joelhos.",
    "active": true,
    "alternatives": [
     {
      "body": "Passada larga, com o pé tocando o solo à frente do corpo",
      "is_correct": true
     },
     {
      "body": "Passada curta demais, com excesso de passos por minuto",
      "is_correct": false
     },
     {
      "body": "Frequência cardíaca abaixo da zona ideal de treino",
      "is_correct": false
     },
     {
      "body": "Perda de sinal do GPS em trechos com muitos prédios",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Por que o GPS dedicado no pulso supera o celular entre prédios e árvores?",
    "explanation": "O receptor dedicado no pulso sofre menos com a atenuação de sinal causada por edifícios altos e vegetação.",
    "active": true,
    "alternatives": [
     {
      "body": "Usa a internet móvel para corrigir o trajeto feito",
      "is_correct": false
     },
     {
      "body": "Conecta a satélites diferentes dos do celular",
      "is_correct": false
     },
     {
      "body": "Calcula o trajeto a partir da contagem de passos",
      "is_correct": false
     },
     {
      "body": "Reduz a atenuação de sinal do efeito multi-caminho",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como apresentar o VO2 Máx na venda?",
    "explanation": "O VO2 Máx estima a capacidade de captar e usar oxigênio e ajuda a acompanhar a evolução do condicionamento.",
    "active": true,
    "alternatives": [
     {
      "body": "Como medida da recuperação depois de cada treino",
      "is_correct": false
     },
     {
      "body": "Como contagem das horas de descanso necessárias",
      "is_correct": false
     },
     {
      "body": "Para acompanhar a evolução do condicionamento",
      "is_correct": true
     },
     {
      "body": "Como indicador da energia disponível na corrida",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que uma VFC mais baixa que o habitual costuma indicar?",
    "explanation": "Variações maiores indicam boa recuperação. Variações reduzidas apontam fadiga acumulada.",
    "active": true,
    "alternatives": [
     {
      "body": "Bom estado de recuperação depois do treino",
      "is_correct": false
     },
     {
      "body": "Fadiga acumulada ou mais estresse fisiológico",
      "is_correct": true
     },
     {
      "body": "Condicionamento aeróbico em plena evolução",
      "is_correct": false
     },
     {
      "body": "Ritmo de corrida acima do habitual do atleta",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O maratonista quer saber, durante a prova, se vai conseguir manter o ritmo até o fim. Qual métrica responde a isso?",
    "explanation": "A Estamina funciona como um tanque de combustível durante a atividade. O Tempo de Recuperação vale para depois do treino.",
    "active": true,
    "alternatives": [
     {
      "body": "Estamina",
      "is_correct": true
     },
     {
      "body": "Tempo de Recuperação",
      "is_correct": false
     },
     {
      "body": "VO2 Máx",
      "is_correct": false
     },
     {
      "body": "Status de VFC",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Na Estamina, o que é a Reserva Potencial?",
    "explanation": "A Reserva Atual é a energia do momento. A Reserva Potencial é o limite sustentável se o ritmo for dosado.",
    "active": false,
    "alternatives": [
     {
      "body": "A energia disponível exatamente naquele momento",
      "is_correct": false
     },
     {
      "body": "As horas que faltam para recuperar após a prova",
      "is_correct": false
     },
     {
      "body": "A carga acumulada nos treinos daquela semana",
      "is_correct": false
     },
     {
      "body": "O limite máximo sustentável com ritmo dosado",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “O relógio sugeriu descanso, mas estou me sentindo bem.” Como explicar o Tempo de Recuperação?",
    "explanation": "O Tempo de Recuperação é o intervalo estimado, em horas, antes da próxima sessão de alta intensidade.",
    "active": true,
    "alternatives": [
     {
      "body": "É uma sugestão genérica que pode ser desligada no menu",
      "is_correct": false
     },
     {
      "body": "Indica que o sensor de pulso teve uma falha de leitura",
      "is_correct": false
     },
     {
      "body": "É uma estimativa de horas antes de outro treino intenso",
      "is_correct": true
     },
     {
      "body": "Indica que o VO2 Máx caiu desde o último treino feito",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer acompanhar Economia de Corrida e SSL. O que ele precisa levar?",
    "explanation": "As duas métricas exigem a HRM 600, por isso o combo Forerunner 970 + HRM 600 é a oportunidade de venda.",
    "active": true,
    "alternatives": [
     {
      "body": "Qualquer relógio, só com o sensor de pulso",
      "is_correct": false
     },
     {
      "body": "Relógio compatível com a cinta HRM 600",
      "is_correct": true
     },
     {
      "body": "A cinta HRM 200 com qualquer relógio",
      "is_correct": false
     },
     {
      "body": "Um sensor de cadência preso ao tênis",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que um valor mais baixo de Economia de Corrida indica?",
    "explanation": "Quanto menor o consumo de energia para manter o ritmo, mais eficiente é a técnica do atleta.",
    "active": true,
    "alternatives": [
     {
      "body": "Técnica mais eficiente para o mesmo ritmo",
      "is_correct": true
     },
     {
      "body": "Ritmo mais lento que o habitual do atleta",
      "is_correct": false
     },
     {
      "body": "Frequência cardíaca acima do esperado",
      "is_correct": false
     },
     {
      "body": "Necessidade de mais tempo de recuperação",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que a SSL (Perda de Velocidade na Passada) quantifica?",
    "explanation": "A SSL mede o “freio natural” de cada passada. As outras opções definem Economia de Corrida, Cadência e VFC.",
    "active": true,
    "alternatives": [
     {
      "body": "O consumo de oxigênio para manter o mesmo ritmo",
      "is_correct": false
     },
     {
      "body": "O número de passadas dadas a cada minuto",
      "is_correct": false
     },
     {
      "body": "A variação de tempo entre os batimentos cardíacos",
      "is_correct": false
     },
     {
      "body": "A perda de velocidade a cada contato com o solo",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "edge",
  "quiz_id": "144ac946-1bf8-487e-b606-ce77d149acc1",
  "questions": [
   {
    "body": "Qual é a troca principal entre o Edge 540 e o Edge 550?",
    "explanation": "Os dois têm o mesmo motor de treino. A diferença está na tela e na bateria: até 26h no 540 contra 12h em uso intenso no 550.",
    "active": true,
    "alternatives": [
     {
      "body": "O 550 tem touchscreen; o 540 só tem botões físicos",
      "is_correct": false
     },
     {
      "body": "O 540 tem GPS multibanda; o 550 usa GPS padrão",
      "is_correct": false
     },
     {
      "body": "O 550 lê Dinâmica de Pedal; o 540 só lê potência",
      "is_correct": false
     },
     {
      "body": "O 550 tem tela mais brilhante; o 540 dura bem mais",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente está entre o 540 e o 550, mas pergunta por tela sensível ao toque. O que fazer?",
    "explanation": "Nenhum dos dois tem touchscreen. Esse recurso aparece a partir do Edge 840/850.",
    "active": true,
    "alternatives": [
     {
      "body": "Mostrar como ativar o modo de toque no Edge 550",
      "is_correct": false
     },
     {
      "body": "Explicar que nenhum Edge tem tela sensível ao toque",
      "is_correct": false
     },
     {
      "body": "Apresentar o degrau seguinte, Edge 840 ou 850",
      "is_correct": true
     },
     {
      "body": "Indicar o 540 Solar, que tem tela de toque própria",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que muda de um degrau para o outro na linha Edge completa?",
    "explanation": "Do 540 ao 1050 o motor de treino é o mesmo. O preço muda por tela, touchscreen, conectividade e bateria.",
    "active": true,
    "alternatives": [
     {
      "body": "A profundidade das métricas de treino",
      "is_correct": false
     },
     {
      "body": "Tela, touch, conectividade e bateria",
      "is_correct": true
     },
     {
      "body": "O acesso ao ClimbPro e ao multibanda",
      "is_correct": false
     },
     {
      "body": "A leitura de potência e de pedalada",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente faz pedais muito longos e prioriza autonomia acima de tudo. Qual topo de linha indicar?",
    "explanation": "O Edge 1040 tem a maior bateria da linha: 35h em uso intenso, contra 20h do 1050.",
    "active": true,
    "alternatives": [
     {
      "body": "Edge 1040",
      "is_correct": true
     },
     {
      "body": "Edge 1050",
      "is_correct": false
     },
     {
      "body": "Edge 850",
      "is_correct": false
     },
     {
      "body": "Edge 550",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Por que o Edge 1050 dura menos que o 1040, mesmo sendo mais novo?",
    "explanation": "O 1050 soma WiFi, Garmin Pay, alto-falante e roteamento social, e paga isso em autonomia.",
    "active": false,
    "alternatives": [
     {
      "body": "O 1050 tem tela menor e menos eficiente que o 1040",
      "is_correct": false
     },
     {
      "body": "O 1050 não oferece modo de economia de bateria",
      "is_correct": false
     },
     {
      "body": "O 1050 mantém o GPS multibanda ligado sem pausa",
      "is_correct": false
     },
     {
      "body": "WiFi, Garmin Pay e alto-falante gastam mais energia",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que o ClimbPro mostra durante o pedal?",
    "explanation": "O ClimbPro mostra em tempo real a subida que vem pela frente: distância, inclinação média e quanto falta de elevação.",
    "active": true,
    "alternatives": [
     {
      "body": "A potência ideal para manter na próxima subida",
      "is_correct": false
     },
     {
      "body": "O tempo previsto até o fim do percurso salvo",
      "is_correct": false
     },
     {
      "body": "A subida à frente, com distância e inclinação",
      "is_correct": true
     },
     {
      "body": "O ganho de elevação acumulado no pedal todo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Para que serve o Power Match?",
    "explanation": "O Power Match sincroniza a leitura de potência do pedal com o computador e evita divergência entre os dois.",
    "active": false,
    "alternatives": [
     {
      "body": "Calibrar o pedal Rally antes de cada pedalada",
      "is_correct": false
     },
     {
      "body": "Sincronizar a potência do pedal com o computador",
      "is_correct": true
     },
     {
      "body": "Combinar potência e frequência cardíaca no treino",
      "is_correct": false
     },
     {
      "body": "Comparar a sua potência com a de outros ciclistas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Speed Sensor 2 consegue fazer sem o Edge por perto?",
    "explanation": "O Speed Sensor 2 guarda até 300 horas de dados sozinho e sincroniza depois.",
    "active": false,
    "alternatives": [
     {
      "body": "Guardar até 300 horas de dados",
      "is_correct": true
     },
     {
      "body": "Calcular a Dinâmica de Pedal",
      "is_correct": false
     },
     {
      "body": "Substituir o GPS do computador",
      "is_correct": false
     },
     {
      "body": "Medir a potência da pedalada",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O ciclista quer frequência cardíaca mais estável no pedal e não precisa de métricas de corrida nem de natação. O que indicar?",
    "explanation": "A HRM 200 é a cinta de entrada, para quem quer FC mais precisa que a leitura óptica. A HRM 600 soma Dinâmica de Corrida e natação.",
    "active": true,
    "alternatives": [
     {
      "body": "HRM 600",
      "is_correct": false
     },
     {
      "body": "Speed Sensor 2",
      "is_correct": false
     },
     {
      "body": "Rally 110",
      "is_correct": false
     },
     {
      "body": "HRM 200",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “Meu relógio já mede frequência cardíaca no pulso, pra que uma cinta?” Qual resposta segue o módulo?",
    "explanation": "A leitura óptica sofre mais em esforço alto e no frio. A cinta lê direto do músculo cardíaco e fica mais estável.",
    "active": true,
    "alternatives": [
     {
      "body": "O sensor de pulso para de medir em esforço alto",
      "is_correct": false
     },
     {
      "body": "A cinta é obrigatória para registrar o pedal",
      "is_correct": false
     },
     {
      "body": "A cinta é mais estável quando a intensidade sobe",
      "is_correct": true
     },
     {
      "body": "A cinta também mede a potência da pedalada",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “O radar substitui olhar por cima do ombro?” Qual resposta segue o módulo?",
    "explanation": "O Varia avisa antes de o ciclista perceber o carro, e o hábito de checar visualmente continua parte da segurança.",
    "active": true,
    "alternatives": [
     {
      "body": "Substitui, porque detecta todos os veículos que vêm atrás",
      "is_correct": false
     },
     {
      "body": "Complementa, avisando antes e dando mais tempo de reação",
      "is_correct": true
     },
     {
      "body": "Substitui só de dia, quando a luz está em Day Flash",
      "is_correct": false
     },
     {
      "body": "Substitui quando está pareado com um Edge de topo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer equilíbrio esquerda/direita e Dinâmica de Pedal completa. Qual Rally indicar?",
    "explanation": "O Rally 110 é single-sensing. O Rally 210 é dual-sensing e soma equilíbrio esquerda/direita e Dinâmica de Pedal.",
    "active": true,
    "alternatives": [
     {
      "body": "Rally 210",
      "is_correct": true
     },
     {
      "body": "Rally 110",
      "is_correct": false
     },
     {
      "body": "Speed Sensor 2",
      "is_correct": false
     },
     {
      "body": "Varia RTL515",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Só uso o celular no pedal, funciona bem.” Como conduzir?",
    "explanation": "Valide o que o cliente já faz. Depois mostre autonomia em GPS contínuo e sensores pareados mais estáveis.",
    "active": true,
    "alternatives": [
     {
      "body": "Dizer que o celular não registra o treino corretamente",
      "is_correct": false
     },
     {
      "body": "Mostrar que a tela do Edge é maior que a do celular",
      "is_correct": false
     },
     {
      "body": "Explicar que o Strava só funciona bem com um Edge",
      "is_correct": false
     },
     {
      "body": "Validar e mostrar autonomia de GPS e sensores estáveis",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "potencia",
  "quiz_id": "b994a0c9-aa8a-450c-9a33-f39cd8a0f6ed",
  "questions": [
   {
    "body": "Por que a potência é considerada a métrica mais objetiva do ciclismo?",
    "explanation": "A FC muda com cansaço, calor e hidratação, e a velocidade muda com vento e inclinação. A potência mede o esforço direto no pedal.",
    "active": true,
    "alternatives": [
     {
      "body": "Mede o esforço mecânico direto, sem influência de clima",
      "is_correct": true
     },
     {
      "body": "Considera cansaço e hidratação no cálculo do esforço",
      "is_correct": false
     },
     {
      "body": "Junta GPS, frequência cardíaca e velocidade num dado",
      "is_correct": false
     },
     {
      "body": "Usa a inclinação do terreno para corrigir a velocidade",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente pergunta se o Edge calcula watts reais sem nenhum sensor. Qual é a resposta?",
    "explanation": "Nenhum relógio ou Edge calcula watts reais sozinho, sem um medidor dedicado pareado.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, a partir da velocidade e da inclinação da via",
      "is_correct": false
     },
     {
      "body": "Sim, sempre que o GPS multibanda estiver ativo",
      "is_correct": false
     },
     {
      "body": "Sim, desde que uma cinta HRM esteja pareada",
      "is_correct": false
     },
     {
      "body": "Não, é preciso um medidor no pedal ou no pedivela",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “Meu Edge já mostra velocidade, por que eu preciso de potência?” Qual resposta segue o módulo?",
    "explanation": "Velocidade varia com vento, inclinação e superfície. Potência mostra o esforço aplicado, independente do terreno.",
    "active": true,
    "alternatives": [
     {
      "body": "A velocidade do Edge fica imprecisa sem um sensor instalado na roda",
      "is_correct": false
     },
     {
      "body": "A potência mostra a mesma velocidade, só que com mais precisão",
      "is_correct": false
     },
     {
      "body": "Velocidade muda com vento e subida; potência mostra o esforço real",
      "is_correct": true
     },
     {
      "body": "A potência substitui a frequência cardíaca em qualquer tipo de treino",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer treinar só por zonas de esforço, sem análise da pedalada. Qual Rally resolve?",
    "explanation": "O Rally 110 entrega potência total e cadência, suficiente para treinar por zona de esforço.",
    "active": true,
    "alternatives": [
     {
      "body": "Rally 210",
      "is_correct": false
     },
     {
      "body": "Rally 110",
      "is_correct": true
     },
     {
      "body": "Speed Sensor 2",
      "is_correct": false
     },
     {
      "body": "HRM 600",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Por que a Dinâmica de Pedal só existe no Rally 210?",
    "explanation": "O Rally 210 é dual-sensing. Entender a mecânica completa da pedalada exige medir os dois pedais.",
    "active": true,
    "alternatives": [
     {
      "body": "Precisa medir os dois lados ao mesmo tempo",
      "is_correct": true
     },
     {
      "body": "Exige a bateria maior que só o 210 possui",
      "is_correct": false
     },
     {
      "body": "Só o 210 se conecta ao Edge por Bluetooth",
      "is_correct": false
     },
     {
      "body": "Só o 210 tem a calibração com Pedal IQ",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que é o Pedal IQ?",
    "explanation": "O Pedal IQ avisa quando é hora de recalibrar os pedais Rally.",
    "active": true,
    "alternatives": [
     {
      "body": "Modo que sugere a cadência ideal nas subidas",
      "is_correct": false
     },
     {
      "body": "App que monta zonas de treino por potência",
      "is_correct": false
     },
     {
      "body": "Sensor que mede a temperatura do pedal",
      "is_correct": false
     },
     {
      "body": "Calibração que avisa quando recalibrar",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente tem uma bike de estrada e outra de off-road. Qual vantagem do Rally faz sentido mostrar?",
    "explanation": "O corpo do pedal é intercambiável, então o mesmo conjunto de sensores muda de bike sem comprar tudo de novo.",
    "active": true,
    "alternatives": [
     {
      "body": "Um único Rally lê as duas bikes ao mesmo tempo",
      "is_correct": false
     },
     {
      "body": "O Rally 210 já vem com dois pares de sensores",
      "is_correct": false
     },
     {
      "body": "O corpo do pedal troca entre estrada e off-road",
      "is_correct": true
     },
     {
      "body": "O Rally ajusta a leitura sozinho a cada terreno",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual métrica mostra em que ponto do pedal a força é aplicada?",
    "explanation": "O PCO mostra onde no pedal a força é aplicada e se o pé está bem posicionado.",
    "active": true,
    "alternatives": [
     {
      "body": "Power Phase",
      "is_correct": false
     },
     {
      "body": "PCO (Platform Center Offset)",
      "is_correct": true
     },
     {
      "body": "Tempo sentado x em pé",
      "is_correct": false
     },
     {
      "body": "Equilíbrio entre esquerda e direita",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que é a Power Phase?",
    "explanation": "Power Phase é a faixa de ângulo do pedivela em que o ciclista produz potência positiva.",
    "active": true,
    "alternatives": [
     {
      "body": "A faixa do pedivela com potência positiva",
      "is_correct": true
     },
     {
      "body": "O ponto do pedal onde a força é aplicada",
      "is_correct": false
     },
     {
      "body": "O tempo pedalando sentado e em pé",
      "is_correct": false
     },
     {
      "body": "A diferença de força entre as pernas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer usar o Rally com um relógio Garmin. O que fazer antes de afirmar a compatibilidade?",
    "explanation": "Todos os Edge da linha completa leem. Nos relógios, a compatibilidade muda entre gerações e deve ser confirmada no manual.",
    "active": true,
    "alternatives": [
     {
      "body": "Afirmar que todo relógio lê como os Edge",
      "is_correct": false
     },
     {
      "body": "Confirmar se o relógio tem touchscreen",
      "is_correct": false
     },
     {
      "body": "Avisar que relógio nenhum lê potência",
      "is_correct": false
     },
     {
      "body": "Confirmar no manual do modelo específico",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Quanto rende uma carga rápida de 15 minutos na linha Rally?",
    "explanation": "A bateria interna dura até 90 horas, e 15 minutos de carga rápida rendem 12 horas de pedal.",
    "active": false,
    "alternatives": [
     {
      "body": "90 horas de pedal",
      "is_correct": false
     },
     {
      "body": "6 horas de pedal",
      "is_correct": false
     },
     {
      "body": "12 horas de pedal",
      "is_correct": true
     },
     {
      "body": "24 horas de pedal",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "preco",
  "quiz_id": "76854546-2f5e-45a1-b20e-992f7a946b8b",
  "questions": [
   {
    "body": "Cliente: “Tá caro.” O que geralmente está por trás dessa frase?",
    "explanation": "Raramente o problema é o número em si. O cliente ainda não enxergou valor suficiente para justificar o preço.",
    "active": true,
    "alternatives": [
     {
      "body": "Interesse apenas em comparar preços entre lojas",
      "is_correct": false
     },
     {
      "body": "Falta de percepção do valor que o produto entrega",
      "is_correct": true
     },
     {
      "body": "Orçamento abaixo de qualquer modelo da linha",
      "is_correct": false
     },
     {
      "body": "Desconfiança sobre a garantia oferecida pela loja",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que é a técnica de value-stacking?",
    "explanation": "Primeiro se constrói o que o produto resolve, substitui e evita. O preço vem depois.",
    "active": true,
    "alternatives": [
     {
      "body": "Construir valor percebido antes de falar de preço",
      "is_correct": true
     },
     {
      "body": "Somar acessórios à venda para aumentar o ticket",
      "is_correct": false
     },
     {
      "body": "Comparar preços com concorrentes diante do cliente",
      "is_correct": false
     },
     {
      "body": "Oferecer desconto progressivo a cada item somado",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a sequência da técnica Feel-Felt-Found?",
    "explanation": "Empatiza com o sentimento, normaliza com a experiência de outros clientes e reforça com uma prova concreta.",
    "active": true,
    "alternatives": [
     {
      "body": "Normalizar, oferecer desconto e fechar a venda",
      "is_correct": false
     },
     {
      "body": "Reforçar com prova, empatizar e parcelar",
      "is_correct": false
     },
     {
      "body": "Empatizar, comparar preços e oferecer brinde",
      "is_correct": false
     },
     {
      "body": "Empatizar, normalizar e reforçar com prova",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como usar a comparação de custo por dia de forma correta?",
    "explanation": "A técnica transforma “gasto único alto” em “investimento diluído”, sem prometer um número fechado de anos.",
    "active": true,
    "alternatives": [
     {
      "body": "Para garantir ao cliente quantos anos o relógio vai durar",
      "is_correct": false
     },
     {
      "body": "Para mostrar que o parcelamento sai mais barato no fim",
      "is_correct": false
     },
     {
      "body": "Para mudar a percepção, sem prometer anos exatos de uso",
      "is_correct": true
     },
     {
      "body": "Para comparar o preço da loja com o de outras lojas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “O Apple Watch é mais barato e faz a mesma coisa.” Qual argumento segue o módulo?",
    "explanation": "O argumento é diferenciação de proposta: bateria de muitos dias e Prontidão, Carga de Treino e Body Battery. Nunca desqualificar o concorrente.",
    "active": true,
    "alternatives": [
     {
      "body": "O Apple Watch não serve para quem treina de verdade",
      "is_correct": false
     },
     {
      "body": "Autonomia de bateria e a ciência de treino da Garmin",
      "is_correct": true
     },
     {
      "body": "O Apple Watch não tem GPS integrado para treinos",
      "is_correct": false
     },
     {
      "body": "Um desconto para igualar o preço do Apple Watch",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Achei mais barato num marketplace.” Qual argumento usar?",
    "explanation": "O preço de fora normalmente não inclui garantia de 2 anos, suporte pós-venda nem procedência de importadora oficial.",
    "active": true,
    "alternatives": [
     {
      "body": "Garantia de 2 anos, suporte e procedência oficial",
      "is_correct": true
     },
     {
      "body": "Produtos de marketplace costumam ser falsificados",
      "is_correct": false
     },
     {
      "body": "O preço da loja já inclui um acessório de brinde",
      "is_correct": false
     },
     {
      "body": "Relógio comprado fora não funciona no Garmin Connect",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como oferecer o parcelamento ao cliente?",
    "explanation": "O parcelamento tem os juros normais do cartão. Nunca prometa “sem juros”.",
    "active": true,
    "alternatives": [
     {
      "body": "Em até 18x sem juros em qualquer cartão de crédito",
      "is_correct": false
     },
     {
      "body": "Em até 12x sem juros, à escolha do cliente",
      "is_correct": false
     },
     {
      "body": "Em até 10x sem juros só para a linha topo",
      "is_correct": false
     },
     {
      "body": "Em até 18x no cartão, com os juros da operadora",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual frase representa um fechamento por escolha?",
    "explanation": "O fechamento por escolha assume a venda e pergunta qual opção o cliente leva, em vez de perguntar se ele compra.",
    "active": true,
    "alternatives": [
     {
      "body": "“Você quer levar o relógio hoje ou prefere pensar melhor?”",
      "is_correct": false
     },
     {
      "body": "“Se eu conseguir um desconto, você fecha a compra agora?”",
      "is_correct": false
     },
     {
      "body": "“Prefere o modelo que conversamos ou já leva com a cinta?”",
      "is_correct": true
     },
     {
      "body": "“Posso separar o relógio para você pagar lá no caixa?”",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Além da garantia de 2 anos, o que a loja oferece depois da compra?",
    "explanation": "O cliente pode procurar a loja sempre que tiver dúvida, e há um time de suporte técnico disponível.",
    "active": true,
    "alternatives": [
     {
      "body": "Desconto automático na próxima compra da loja",
      "is_correct": false
     },
     {
      "body": "Pós-atendimento e suporte técnico para dúvidas",
      "is_correct": true
     },
     {
      "body": "Um treinador pessoal gratuito por três meses",
      "is_correct": false
     },
     {
      "body": "Troca por um modelo novo depois de um ano",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quando o argumento da garantia ganha mais força na conversa?",
    "explanation": "Quando o cliente traz o preço de fora, é o momento de mostrar o que esse preço menor não inclui.",
    "active": true,
    "alternatives": [
     {
      "body": "Quando o cliente menciona um preço de fora",
      "is_correct": true
     },
     {
      "body": "Logo na abertura, antes de fazer a sondagem",
      "is_correct": false
     },
     {
      "body": "Quando o cliente pergunta sobre a bateria",
      "is_correct": false
     },
     {
      "body": "Depois que o pagamento já foi concluído",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "endurance",
  "quiz_id": "fb53a75c-7e77-48b9-8326-dacd93d49ff6",
  "questions": [
   {
    "body": "O cliente quer o relógio mais completo da linha endurance, sem abrir mão de nada. O que indicar?",
    "explanation": "O Fenix 8 é o topo de linha multiesporte: AMOLED, multibanda, ECG, mergulho, alto-falante, microfone e lanterna.",
    "active": true,
    "alternatives": [
     {
      "body": "Enduro 3",
      "is_correct": false
     },
     {
      "body": "Forerunner 970",
      "is_correct": false
     },
     {
      "body": "Fenix 8",
      "is_correct": true
     },
     {
      "body": "Instinct 3 Solar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente faz ultramaratonas de vários dias e prioriza bateria acima de tudo. O que indicar?",
    "explanation": "O Enduro 3 chega a 320 horas de GPS com a lente solar e foi pensado para provas de múltiplos dias.",
    "active": true,
    "alternatives": [
     {
      "body": "Fenix 8 Solar",
      "is_correct": false
     },
     {
      "body": "Enduro 3",
      "is_correct": true
     },
     {
      "body": "Forerunner 970",
      "is_correct": false
     },
     {
      "body": "Instinct 3 Solar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O foco do cliente é corrida, e ele quer tela bonita num relógio leve. O que indicar?",
    "explanation": "O Forerunner 970 tem AMOLED e as métricas avançadas do Fenix num corpo mais leve, focado em corrida.",
    "active": true,
    "alternatives": [
     {
      "body": "Forerunner 970",
      "is_correct": true
     },
     {
      "body": "Fenix 8 de 43 mm",
      "is_correct": false
     },
     {
      "body": "Enduro 3",
      "is_correct": false
     },
     {
      "body": "Instinct 3 Solar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer entrar na linha endurance gastando menos, com bateria solar longa. O que indicar?",
    "explanation": "O Instinct 3 Solar é a entrada mais acessível, com bateria solar longa e formato rústico.",
    "active": true,
    "alternatives": [
     {
      "body": "Enduro 3",
      "is_correct": false
     },
     {
      "body": "Fenix 8 Solar 47 mm",
      "is_correct": false
     },
     {
      "body": "Forerunner 970",
      "is_correct": false
     },
     {
      "body": "Instinct 3 Solar",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Por que o Enduro 3 usa tela MIP em vez de AMOLED?",
    "explanation": "A tela MIP consome menos energia. O Enduro 3 abre mão da AMOLED em troca de autonomia real.",
    "active": true,
    "alternatives": [
     {
      "body": "Porque a AMOLED não suporta GPS multibanda",
      "is_correct": false
     },
     {
      "body": "Para custar menos que o Fenix 8 equivalente",
      "is_correct": false
     },
     {
      "body": "Para economizar energia e estender a bateria",
      "is_correct": true
     },
     {
      "body": "Para permitir o uso em mergulho profundo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer um Fenix 8 Solar, mas prefere a caixa menor. O que dizer?",
    "explanation": "A versão Solar existe no 47 e no 51 mm. A caixa de 43 mm não tem opção solar.",
    "active": true,
    "alternatives": [
     {
      "body": "O 43 mm Solar tem a mesma autonomia do 47 mm",
      "is_correct": false
     },
     {
      "body": "A opção Solar existe só nas caixas de 47 e 51 mm",
      "is_correct": true
     },
     {
      "body": "Todas as caixas do Fenix 8 têm versão Solar",
      "is_correct": false
     },
     {
      "body": "Só a caixa de 51 mm do Fenix 8 tem versão Solar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente pergunta pelo Fenix 8 Pro, com inReach no pulso. O que dizer?",
    "explanation": "O Fenix 8 Pro é o primeiro Garmin com inReach embutido, mas essa versão não está disponível no Brasil.",
    "active": true,
    "alternatives": [
     {
      "body": "A versão Pro não está disponível no Brasil",
      "is_correct": true
     },
     {
      "body": "O Pro vem com plano de satélite já incluso",
      "is_correct": false
     },
     {
      "body": "O inReach do Pro depende do celular por perto",
      "is_correct": false
     },
     {
      "body": "O Pro só é vendido na caixa de 51 mm aqui",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Antes de informar a bateria do Forerunner 970, o que o vendedor deve fazer?",
    "explanation": "Os números de horas e dias mudam por versão. Confirme no manual antes de repassar ao cliente.",
    "active": true,
    "alternatives": [
     {
      "body": "Usar os mesmos números do Fenix 8 Solar",
      "is_correct": false
     },
     {
      "body": "Informar a autonomia do modo de economia",
      "is_correct": false
     },
     {
      "body": "Comparar com a bateria do Instinct 3",
      "is_correct": false
     },
     {
      "body": "Confirmar os números no manual do modelo",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Sem ajuda do sol, quantos dias em modo smartwatch o Instinct 3 Solar de 50 mm alcança?",
    "explanation": "Sem sol: 28 dias na caixa de 45 mm e 40 dias na de 50 mm. Com luz solar suficiente, o modo smartwatch fica ilimitado.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 28 dias",
      "is_correct": false
     },
     {
      "body": "Até 90 dias",
      "is_correct": false
     },
     {
      "body": "Até 40 dias",
      "is_correct": true
     },
     {
      "body": "Ilimitado",
      "is_correct": false
     }
    ]
   },
   {
    "body": "No Enduro 3, o SatIQ estende o quê por até 120 horas?",
    "explanation": "O SatIQ estende a precisão multibanda por até 120 horas no Enduro 3.",
    "active": true,
    "alternatives": [
     {
      "body": "A bateria em modo smartwatch",
      "is_correct": false
     },
     {
      "body": "A precisão do GPS multibanda",
      "is_correct": true
     },
     {
      "body": "A duração da lanterna de LED",
      "is_correct": false
     },
     {
      "body": "O tempo de GPS com a lente solar",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "prontidao",
  "quiz_id": "a9bf1478-e8b6-4001-aab3-878ac4a2d8d1",
  "questions": [
   {
    "body": "Qual pergunta a Prontidão de Treino ajuda a responder?",
    "explanation": "Prontidão olha para a preparação. Carga, VO2 Máx e Tempo de Recuperação respondem às outras perguntas.",
    "active": true,
    "alternatives": [
     {
      "body": "Quanto treinamento eu acumulei nas semanas?",
      "is_correct": false
     },
     {
      "body": "Qual é minha capacidade cardiorrespiratória?",
      "is_correct": false
     },
     {
      "body": "Quanto tempo falta para eu me recuperar?",
      "is_correct": false
     },
     {
      "body": "Como está minha preparação para treinar agora?",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual conjunto de sinais entra na Prontidão de Treino?",
    "explanation": "Pontuação e histórico de sono, Tempo de Recuperação, Carga de Treino, Estado da VFC e histórico de estresse.",
    "active": true,
    "alternatives": [
     {
      "body": "VO2 Máx, pace, cadência e distância",
      "is_correct": false
     },
     {
      "body": "Passos, calorias, hidratação e hábitos",
      "is_correct": false
     },
     {
      "body": "Sono, recuperação, carga, VFC e estresse",
      "is_correct": true
     },
     {
      "body": "Altitude, temperatura, GPS e clima",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Minha Prontidão estava 78 ontem e hoje está 42. Eu piorei?” Qual é a melhor resposta?",
    "explanation": "A Prontidão é uma visão dinâmica da preparação e não mede condicionamento físico.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, a queda mostra que o condicionamento caiu nesse período",
      "is_correct": false
     },
     {
      "body": "Não necessariamente; ela muda com sono, recuperação e carga",
      "is_correct": true
     },
     {
      "body": "Sim, porque o VO2 Máx caiu junto com a pontuação de hoje",
      "is_correct": false
     },
     {
      "body": "Não, porque a pontuação só tem validade no período da manhã",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Minha Prontidão está baixa. Então não posso treinar?” Qual é a melhor resposta?",
    "explanation": "A Prontidão é uma orientação e não substitui a percepção individual, o planejamento ou um profissional.",
    "active": true,
    "alternatives": [
     {
      "body": "Não necessariamente; vale olhar o que influenciou a pontuação",
      "is_correct": true
     },
     {
      "body": "Sim, o relógio está indicando que você não deve treinar hoje",
      "is_correct": false
     },
     {
      "body": "Sim, até a pontuação voltar para a faixa Moderate ou acima",
      "is_correct": false
     },
     {
      "body": "Não, porque essa métrica não tem utilidade prática no treino",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual rótulo corresponde à faixa de 75 a 94?",
    "explanation": "95 a 100 Prime, 75 a 94 High, 50 a 74 Moderate, 25 a 49 Low e 1 a 24 Poor.",
    "active": false,
    "alternatives": [
     {
      "body": "Prime",
      "is_correct": false
     },
     {
      "body": "Moderate",
      "is_correct": false
     },
     {
      "body": "Low",
      "is_correct": false
     },
     {
      "body": "High",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Por que a Prontidão pode mudar ao longo do dia?",
    "explanation": "A avaliação começa ao acordar e muda com novos dados, com a evolução da recuperação e depois de um treino.",
    "active": true,
    "alternatives": [
     {
      "body": "O relógio recalibra os sensores a cada hora",
      "is_correct": false
     },
     {
      "body": "A nota da manhã é sempre corrigida à tarde",
      "is_correct": false
     },
     {
      "body": "Entram novos dados e a recuperação evolui",
      "is_correct": true
     },
     {
      "body": "O GPS atualiza os dados de localização",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual pergunta o Tempo de Recuperação responde?",
    "explanation": "Prontidão é a visão da preparação. Tempo de Recuperação é o tempo após o esforço.",
    "active": true,
    "alternatives": [
     {
      "body": "Como está a preparação geral para treinar hoje",
      "is_correct": false
     },
     {
      "body": "Quanto tempo de recuperação resta após o esforço",
      "is_correct": true
     },
     {
      "body": "Como a carga recente de treino se comporta",
      "is_correct": false
     },
     {
      "body": "Qual é a capacidade aeróbica estimada do atleta",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que a carga crônica representa?",
    "explanation": "A carga aguda é o recente. A crônica é o histórico. Comparar as duas mostra como o volume atual se comporta.",
    "active": true,
    "alternatives": [
     {
      "body": "O histórico de treino num período maior",
      "is_correct": true
     },
     {
      "body": "O impacto dos treinos mais recentes",
      "is_correct": false
     },
     {
      "body": "A divisão entre aeróbico e anaeróbico",
      "is_correct": false
     },
     {
      "body": "O tempo desde o último esforço intenso",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Foco da Carga de Treino mostra?",
    "explanation": "O Foco da Carga mostra a distribuição dos estímulos, como aeróbico e anaeróbico.",
    "active": false,
    "alternatives": [
     {
      "body": "Quanto treino está acumulado na semana",
      "is_correct": false
     },
     {
      "body": "Se o atleta está preparado para hoje",
      "is_correct": false
     },
     {
      "body": "Quanto oxigênio o corpo usa no esforço",
      "is_correct": false
     },
     {
      "body": "Como os estímulos se distribuem por tipo",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como explicar o EPOC ao cliente sem exagerar?",
    "explanation": "O EPOC ajuda a explicar por que o treino não termina quando o cliente para. Ele não é promessa de resultado.",
    "active": true,
    "alternatives": [
     {
      "body": "Ele garante a supercompensação após o esforço",
      "is_correct": false
     },
     {
      "body": "Ele mede quanto o atleta evoluiu em cada treino",
      "is_correct": false
     },
     {
      "body": "O corpo segue consumindo oxigênio após o treino",
      "is_correct": true
     },
     {
      "body": "Ele indica o melhor horário do próximo treino",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente corre uma vez por semana e só quer acompanhar distância e pace. Como conduzir?",
    "explanation": "A Prontidão ganha relevância com quem busca treino estruturado e recuperação. Para esse cliente, ela não é prioridade.",
    "active": true,
    "alternatives": [
     {
      "body": "Começar pela Prontidão, a métrica mais avançada",
      "is_correct": false
     },
     {
      "body": "Entender o objetivo e mostrar o mais relevante",
      "is_correct": true
     },
     {
      "body": "Mostrar a Carga de Treino para motivar evolução",
      "is_correct": false
     },
     {
      "body": "Apresentar o EPOC para explicar a recuperação",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Todo Garmin tem Prontidão de Treino?” Qual é a resposta correta?",
    "explanation": "A disponibilidade depende do modelo, da geração e dos sensores. Nunca diga “todo Garmin tem”.",
    "active": true,
    "alternatives": [
     {
      "body": "Depende do modelo; vamos confirmar este",
      "is_correct": true
     },
     {
      "body": "Sim, todo Garmin com GPS tem o recurso",
      "is_correct": false
     },
     {
      "body": "Sim, do Forerunner 55 em diante",
      "is_correct": false
     },
     {
      "body": "Só os modelos com tela AMOLED têm",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "ferramentas",
  "quiz_id": "61a01093-b310-48f3-b5d8-0b0b2e2818fe",
  "questions": [
   {
    "body": "Cliente: “Minha prova tem muita subida e eu não consigo controlar o ritmo.” Qual ferramenta apresentar?",
    "explanation": "O PacePro cria uma estratégia de ritmo para o percurso considerando o perfil de elevação.",
    "active": true,
    "alternatives": [
     {
      "body": "PacePro",
      "is_correct": true
     },
     {
      "body": "Trajeto",
      "is_correct": false
     },
     {
      "body": "Previsão de Corrida",
      "is_correct": false
     },
     {
      "body": "Treino Estruturado",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Vou correr uma prova em outra cidade e nunca fiz esse percurso.” Qual ferramenta abre a conversa?",
    "explanation": "O problema é navegação. O trajeto prepara o percurso para ser seguido no dispositivo compatível.",
    "active": true,
    "alternatives": [
     {
      "body": "PacePro",
      "is_correct": false
     },
     {
      "body": "Previsão de Corrida",
      "is_correct": false
     },
     {
      "body": "Treinos Sugeridos",
      "is_correct": false
     },
     {
      "body": "Trajeto",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “Não sei o que faz sentido treinar hoje.” Qual ferramenta responde a isso?",
    "explanation": "Os Treinos Sugeridos dão uma recomendação para o momento. O Garmin Coach é um plano para um objetivo.",
    "active": true,
    "alternatives": [
     {
      "body": "Plano Garmin Coach",
      "is_correct": false
     },
     {
      "body": "Treino Estruturado",
      "is_correct": false
     },
     {
      "body": "Treinos Sugeridos",
      "is_correct": true
     },
     {
      "body": "Estratégia PacePro",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Quero fazer 5 x 1 km com 400 m de recuperação e que o relógio avise cada etapa.” O que apresentar?",
    "explanation": "O cliente precisa de orientação sobre o que fazer em cada etapa: é um treino estruturado criado por ele.",
    "active": true,
    "alternatives": [
     {
      "body": "Trajeto salvo",
      "is_correct": false
     },
     {
      "body": "Treino Estruturado",
      "is_correct": true
     },
     {
      "body": "Treinos Sugeridos",
      "is_correct": false
     },
     {
      "body": "Estratégia PacePro",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O percurso tem relevo bem irregular. Qual divisão do PacePro faz mais sentido?",
    "explanation": "A divisão por elevação acompanha melhor as mudanças do terreno.",
    "active": false,
    "alternatives": [
     {
      "body": "Por elevação",
      "is_correct": true
     },
     {
      "body": "Por quilômetro",
      "is_correct": false
     },
     {
      "body": "Por milha",
      "is_correct": false
     },
     {
      "body": "Por tempo de prova",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como explicar o PacePro ao cliente?",
    "explanation": "O PacePro distribui o ritmo-alvo ao longo do percurso. As outras opções descrevem pace fixo, Trajeto e Previsão.",
    "active": true,
    "alternatives": [
     {
      "body": "Um pace automático igual do começo ao fim da prova",
      "is_correct": false
     },
     {
      "body": "Uma rota que guia o atleta pelo caminho da prova",
      "is_correct": false
     },
     {
      "body": "Uma estimativa do tempo final para aquela distância",
      "is_correct": false
     },
     {
      "body": "Estratégia de ritmo que considera a elevação da prova",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como apresentar a Previsão de Corrida?",
    "explanation": "É uma estimativa baseada nos dados atuais. O tempo real depende de percurso, clima, estratégia e execução.",
    "active": true,
    "alternatives": [
     {
      "body": "Como tempo garantido para a próxima prova",
      "is_correct": false
     },
     {
      "body": "Como meta definida pelo plano de treino",
      "is_correct": false
     },
     {
      "body": "Como estimativa que serve de referência",
      "is_correct": true
     },
     {
      "body": "Como média de tempos de outros atletas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a diferença entre Treinos Sugeridos Diariamente e Garmin Coach?",
    "explanation": "Treinos Sugeridos orientam o dia. O Garmin Coach organiza semanas de treino rumo a um objetivo.",
    "active": true,
    "alternatives": [
     {
      "body": "Recurso pago x recurso incluso em todo relógio",
      "is_correct": false
     },
     {
      "body": "Sugestão para o momento x plano para um objetivo",
      "is_correct": true
     },
     {
      "body": "Monta trajetos x monta treinos de ritmo e força",
      "is_correct": false
     },
     {
      "body": "Só para ciclismo x só para corrida e natação",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual regra diferencia treino estruturado de trajeto?",
    "explanation": "O treino orienta a execução. O trajeto orienta o caminho.",
    "active": true,
    "alternatives": [
     {
      "body": "Treino diz o que fazer; trajeto diz por onde ir",
      "is_correct": true
     },
     {
      "body": "Treino é para corrida; trajeto é para ciclismo",
      "is_correct": false
     },
     {
      "body": "Treino é criado no relógio; trajeto, no app",
      "is_correct": false
     },
     {
      "body": "Treino usa GPS; trajeto usa apenas a bússola",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Na demonstração, o menu do aplicativo do cliente está diferente do roteiro. O que fazer?",
    "explanation": "Os nomes dos menus podem mudar conforme a versão do Garmin Connect. O passo a passo não é universal.",
    "active": false,
    "alternatives": [
     {
      "body": "Informar que esse modelo não tem o recurso de treinos",
      "is_correct": false
     },
     {
      "body": "Reinstalar o aplicativo para voltar ao menu anterior",
      "is_correct": false
     },
     {
      "body": "Encerrar a demonstração e mostrar só no relógio",
      "is_correct": false
     },
     {
      "body": "Procurar a área de treinos em Treinamento e Planejamento",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “Treino para uma meia, quero melhorar meu tempo, não sei o que fazer a cada dia e a prova tem muita subida.” Qual necessidade aparece primeiro?",
    "explanation": "“Não sei o que fazer a cada dia” é planejamento. Depois entram PacePro para as subidas e Trajeto, se ele quiser seguir o percurso.",
    "active": true,
    "alternatives": [
     {
      "body": "Estratégia de ritmo na prova",
      "is_correct": false
     },
     {
      "body": "Navegação pelo percurso",
      "is_correct": false
     },
     {
      "body": "Planejamento de treinamento",
      "is_correct": true
     },
     {
      "body": "Referência de tempo final",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O mesmo cliente quer seguir o percurso oficial da prova. Qual recurso complementa a solução?",
    "explanation": "Seguir um caminho definido é navegação, e o trajeto resolve isso em dispositivos compatíveis.",
    "active": true,
    "alternatives": [
     {
      "body": "Estamina",
      "is_correct": false
     },
     {
      "body": "Trajeto",
      "is_correct": true
     },
     {
      "body": "Body Battery",
      "is_correct": false
     },
     {
      "body": "Previsão de Corrida",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "seguranca",
  "quiz_id": "d470f7b8-ad69-4926-92c0-88d67f04a56d",
  "questions": [
   {
    "body": "Cliente: “Comecei a treinar no calor e meu ritmo caiu. Perdi condicionamento?” Qual é a melhor resposta?",
    "explanation": "Condições difíceis podem gerar ritmo mais lento ou maior esforço, sem significar perda de condicionamento.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, a queda de ritmo mostra que o condicionamento caiu",
      "is_correct": false
     },
     {
      "body": "O calor aumenta a exigência e pode deixar o ritmo mais lento",
      "is_correct": true
     },
     {
      "body": "O sensor do relógio costuma errar a leitura em dias quentes",
      "is_correct": false
     },
     {
      "body": "Sim, e por isso o VO2 Máx precisa ser medido de novo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quantos dias de treinos qualificados no calor a aclimatação exige, no mínimo?",
    "explanation": "Pelo menos 4 dias, com nível ideal entre 10 e 14 dias. A adaptação diminui após 3 dias sem calor.",
    "active": true,
    "alternatives": [
     {
      "body": "4 dias",
      "is_correct": true
     },
     {
      "body": "10 dias",
      "is_correct": false
     },
     {
      "body": "3 dias",
      "is_correct": false
     },
     {
      "body": "21 dias",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Que faixa de altitude a aclimatação considera?",
    "explanation": "Entre 800 m e 4.000 m, com adaptação progressiva ao longo de cerca de 21 dias.",
    "active": false,
    "alternatives": [
     {
      "body": "Acima de 2.000 m",
      "is_correct": false
     },
     {
      "body": "Entre 400 m e 2.500 m",
      "is_correct": false
     },
     {
      "body": "Acima de 4.000 m",
      "is_correct": false
     },
     {
      "body": "Entre 800 m e 4.000 m",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Antes de apresentar os recursos de aclimatação, o que o vendedor descobre?",
    "explanation": "Descubra o local de treino do cliente antes de apresentar qualquer função.",
    "active": true,
    "alternatives": [
     {
      "body": "Qual relógio o cliente usa hoje nos treinos",
      "is_correct": false
     },
     {
      "body": "Qual é a meta de tempo do cliente na prova",
      "is_correct": false
     },
     {
      "body": "Onde o cliente treina e se viaja para provas",
      "is_correct": true
     },
     {
      "body": "Se o cliente já usa uma cinta cardíaca",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Meu relógio mostra 31 °C e o app de clima mostra 25 °C.” Qual é a melhor resposta?",
    "explanation": "O sensor interno e os dados meteorológicos do smartphone são fontes distintas, e o calor do corpo interfere no sensor.",
    "active": true,
    "alternatives": [
     {
      "body": "O sensor do relógio está descalibrado e precisa de ajuste",
      "is_correct": false
     },
     {
      "body": "O sensor sente o calor do pulso; o clima vem do celular",
      "is_correct": true
     },
     {
      "body": "A Garmin sempre usa o sensor interno para o clima",
      "is_correct": false
     },
     {
      "body": "O aplicativo de clima do celular está desatualizado",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como medir a temperatura ambiente pelo sensor do próprio relógio?",
    "explanation": "Retire o relógio do pulso por alguns minutos ou use um sensor externo compatível.",
    "active": true,
    "alternatives": [
     {
      "body": "Tirar o relógio do pulso por alguns minutos",
      "is_correct": true
     },
     {
      "body": "Ativar o modo de aclimatação ao calor",
      "is_correct": false
     },
     {
      "body": "Sincronizar o relógio com o smartphone",
      "is_correct": false
     },
     {
      "body": "Recalibrar o sensor pelo menu do relógio",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Corro sozinho e minha família fica preocupada.” Qual recurso abre a conversa?",
    "explanation": "O LiveTrack compartilha localização e dados da atividade em tempo real com contatos selecionados.",
    "active": true,
    "alternatives": [
     {
      "body": "Morning Report",
      "is_correct": false
     },
     {
      "body": "Gear Tracking",
      "is_correct": false
     },
     {
      "body": "Aclimatação",
      "is_correct": false
     },
     {
      "body": "LiveTrack",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como apresentar Detecção de Incidentes e Assistência ao cliente?",
    "explanation": "“É um recurso de segurança complementar. Ele não substitui os serviços públicos de emergência.”",
    "active": true,
    "alternatives": [
     {
      "body": "Como garantia de socorro em qualquer lugar",
      "is_correct": false
     },
     {
      "body": "Como substitutos do serviço de emergência",
      "is_correct": false
     },
     {
      "body": "Como recursos complementares de segurança",
      "is_correct": true
     },
     {
      "body": "Como recursos que dispensam qualquer conexão",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que os recursos de segurança exigem para funcionar?",
    "explanation": "A disponibilidade depende do dispositivo, da atividade, da configuração e da conectividade.",
    "active": true,
    "alternatives": [
     {
      "body": "Apenas o relógio ligado, sem nenhuma configuração prévia",
      "is_correct": false
     },
     {
      "body": "Dispositivo compatível, contatos cadastrados e conexão",
      "is_correct": true
     },
     {
      "body": "Assinatura de um serviço de emergência particular",
      "is_correct": false
     },
     {
      "body": "Uma cinta cardíaca pareada durante a atividade",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Para que serve a contagem regressiva da Detecção de Incidentes?",
    "explanation": "A contagem permite cancelar o alerta se ele foi acionado sem querer.",
    "active": false,
    "alternatives": [
     {
      "body": "Cancelar o envio se o acionamento for acidental",
      "is_correct": true
     },
     {
      "body": "Calcular o tempo estimado até a chegada do socorro",
      "is_correct": false
     },
     {
      "body": "Medir há quanto tempo o atleta está parado",
      "is_correct": false
     },
     {
      "body": "Avisar que a bateria do relógio está no fim",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Quero saber a hora de trocar o tênis.” Qual recurso resolve?",
    "explanation": "O Gear Tracking monitora o uso e a quilometragem de tênis e bicicletas no Garmin Connect.",
    "active": true,
    "alternatives": [
     {
      "body": "Morning Report",
      "is_correct": false
     },
     {
      "body": "Encontrar Meu Telefone",
      "is_correct": false
     },
     {
      "body": "LiveTrack",
      "is_correct": false
     },
     {
      "body": "Gear Tracking",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente corre sozinho, viaja para provas, a esposa se preocupa e ele quer controlar a recuperação. Qual combinação apresentar?",
    "explanation": "Segurança no treino solo, contexto para viagens e recuperação: o vendedor prioriza o que atende essas três necessidades.",
    "active": true,
    "alternatives": [
     {
      "body": "Encontrar Meu Telefone e Gear Tracking juntos",
      "is_correct": false
     },
     {
      "body": "Morning Report e Encontrar Meu Telefone",
      "is_correct": false
     },
     {
      "body": "LiveTrack, segurança e recursos de recuperação",
      "is_correct": true
     },
     {
      "body": "Todas as funções do relógio, uma a uma",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "multiesporte",
  "quiz_id": "30a27b5d-829a-4a9b-8c69-eb30e6f5ff3e",
  "questions": [
   {
    "body": "O que a transição automática faz em uma atividade multiesporte?",
    "explanation": "O relógio detecta sozinho a troca de etapa e registra a transição separada do tempo de cada esporte.",
    "active": true,
    "alternatives": [
     {
      "body": "Pausa a atividade enquanto o atleta troca o equipamento",
      "is_correct": false
     },
     {
      "body": "Soma o tempo de transição ao esporte da etapa seguinte",
      "is_correct": false
     },
     {
      "body": "Detecta a troca de etapa e separa o tempo de transição",
      "is_correct": true
     },
     {
      "body": "Troca o mostrador do relógio a cada nova etapa da prova",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como o tempo total da prova aparece no resumo do Garmin Connect?",
    "explanation": "O tempo total soma todas as etapas e as transições no resumo combinado da atividade.",
    "active": true,
    "alternatives": [
     {
      "body": "Soma das três etapas, sem transições",
      "is_correct": false
     },
     {
      "body": "Soma das etapas mais as transições",
      "is_correct": true
     },
     {
      "body": "Tempo da etapa mais longa da prova",
      "is_correct": false
     },
     {
      "body": "Média dos tempos de cada etapa",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a sequência do perfil padrão de Triathlon?",
    "explanation": "Natação, transição 1, ciclismo, transição 2 e corrida.",
    "active": true,
    "alternatives": [
     {
      "body": "Natação, T1, ciclismo, T2, corrida",
      "is_correct": true
     },
     {
      "body": "Ciclismo, T1, natação, T2, corrida",
      "is_correct": false
     },
     {
      "body": "Natação, ciclismo, corrida, T1, T2",
      "is_correct": false
     },
     {
      "body": "Corrida, T1, ciclismo, T2, natação",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O atleta vai fazer um duathlon. Como registrar a prova no relógio?",
    "explanation": "Além do perfil padrão de Triathlon, dá para montar uma sequência de esportes totalmente customizada.",
    "active": true,
    "alternatives": [
     {
      "body": "Usar o perfil de Triathlon e pular a natação",
      "is_correct": false
     },
     {
      "body": "Gravar cada esporte como atividade separada",
      "is_correct": false
     },
     {
      "body": "Usar o perfil de corrida com voltas manuais",
      "is_correct": false
     },
     {
      "body": "Montar uma sequência de esportes personalizada",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O SWOLF de um nadador caiu de 45 para 40. O que isso indica?",
    "explanation": "O SWOLF soma tempo e braçadas de uma piscina. Quanto menor, mais eficiente é o nado.",
    "active": true,
    "alternatives": [
     {
      "body": "Nado menos eficiente",
      "is_correct": false
     },
     {
      "body": "Mais braçadas por piscina",
      "is_correct": false
     },
     {
      "body": "Nado mais eficiente",
      "is_correct": true
     },
     {
      "body": "Frequência cardíaca menor",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como o SWOLF é calculado em mar aberto?",
    "explanation": "Em mar aberto, o cálculo é normalizado para um intervalo de 25 m.",
    "active": true,
    "alternatives": [
     {
      "body": "Ele deixa de ser calculado fora da piscina",
      "is_correct": false
     },
     {
      "body": "Normalizado para um intervalo de 25 m",
      "is_correct": true
     },
     {
      "body": "Pela distância total nadada na atividade",
      "is_correct": false
     },
     {
      "body": "A cada boia contornada durante o percurso",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Onde a detecção automática de estilo de nado funciona?",
    "explanation": "A detecção de estilo funciona só em piscina. O Auto Rest também é exclusivo de piscina.",
    "active": true,
    "alternatives": [
     {
      "body": "Só em piscina",
      "is_correct": true
     },
     {
      "body": "Só em mar aberto",
      "is_correct": false
     },
     {
      "body": "Nos dois ambientes",
      "is_correct": false
     },
     {
      "body": "Só com a HRM 600",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que é um treino brick?",
    "explanation": "Brick é bike seguida direto de corrida, uma das preparações mais específicas de triathlon.",
    "active": true,
    "alternatives": [
     {
      "body": "Natação seguida de bike, com uma pausa curta",
      "is_correct": false
     },
     {
      "body": "Corrida intervalada com tiros de bicicleta",
      "is_correct": false
     },
     {
      "body": "Sessão de força logo depois da natação",
      "is_correct": false
     },
     {
      "body": "Bike seguida direto de corrida, sem descanso",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “Por que não gravar bike e corrida do brick como duas atividades separadas?” Qual resposta segue o módulo?",
    "explanation": "Gravando como Multiesporte, o atleta vê o treino inteiro com a transição, como no dia da prova.",
    "active": true,
    "alternatives": [
     {
      "body": "Separado, o Connect não aceita duas no mesmo dia",
      "is_correct": false
     },
     {
      "body": "Separado, o relógio gasta o dobro de bateria",
      "is_correct": false
     },
     {
      "body": "Separado, não há tempo total nem transição",
      "is_correct": true
     },
     {
      "body": "Separado, a bike fica sem os dados de potência",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Auto Rest, que pausa sozinho após mais de 15 segundos parado, funciona onde?",
    "explanation": "O Auto Rest é exclusivo de piscina.",
    "active": true,
    "alternatives": [
     {
      "body": "Em mar aberto e piscina",
      "is_correct": false
     },
     {
      "body": "Só em piscina",
      "is_correct": true
     },
     {
      "body": "Em qualquer pedal",
      "is_correct": false
     },
     {
      "body": "Na corrida em esteira",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "gps",
  "quiz_id": "18c34af7-31b0-4640-9b21-8a7814228929",
  "questions": [
   {
    "body": "O que o SatIQ faz?",
    "explanation": "O SatIQ alterna automaticamente entre os modos conforme o ambiente, sem o atleta escolher.",
    "active": true,
    "alternatives": [
     {
      "body": "Mantém o multibanda ligado na atividade toda",
      "is_correct": false
     },
     {
      "body": "Desliga o GPS quando o atleta fica parado",
      "is_correct": false
     },
     {
      "body": "Escolhe o melhor entre GPS e GLONASS",
      "is_correct": false
     },
     {
      "body": "Alterna sozinho entre GPS padrão e multibanda",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O atleta está correndo em céu aberto. O que o SatIQ faz?",
    "explanation": "Em céu aberto, o relógio fica no padrão. Em mata fechada ou entre prédios, sobe sozinho para o multibanda.",
    "active": false,
    "alternatives": [
     {
      "body": "Liga o multibanda para máxima precisão",
      "is_correct": false
     },
     {
      "body": "Desliga o GPS e usa só os sensores",
      "is_correct": false
     },
     {
      "body": "Fica no modo padrão para poupar bateria",
      "is_correct": true
     },
     {
      "body": "Alterna entre os modos a cada minuto",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que caracteriza o GPS multibanda?",
    "explanation": "O multibanda recebe duas frequências (L1 e L5) do mesmo satélite ao mesmo tempo.",
    "active": true,
    "alternatives": [
     {
      "body": "Dois receptores de GPS funcionando em paralelo",
      "is_correct": false
     },
     {
      "body": "Duas frequências do mesmo satélite ao mesmo tempo",
      "is_correct": true
     },
     {
      "body": "Conexão simultânea com o GPS e com o celular",
      "is_correct": false
     },
     {
      "body": "Mais satélites conectados ao mesmo tempo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Para um triatleta, onde o multibanda faz mais diferença?",
    "explanation": "Reflexo da água, mata fechada e prédios altos são os cenários em que o GPS padrão perde precisão.",
    "active": true,
    "alternatives": [
     {
      "body": "Mar aberto, mata fechada e ruas entre prédios",
      "is_correct": true
     },
     {
      "body": "Piscina coberta, esteira e rolo de treino",
      "is_correct": false
     },
     {
      "body": "Pista de atletismo e estrada em campo aberto",
      "is_correct": false
     },
     {
      "body": "Academia, piscina olímpica e parques planos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Por que o multibanda não fica ligado o tempo todo?",
    "explanation": "O multibanda gasta mais bateria. O SatIQ existe para equilibrar precisão e autonomia.",
    "active": true,
    "alternatives": [
     {
      "body": "Perde precisão em ambientes abertos",
      "is_correct": false
     },
     {
      "body": "Não funciona junto com o Bluetooth",
      "is_correct": false
     },
     {
      "body": "Só funciona com o mapa carregado",
      "is_correct": false
     },
     {
      "body": "Consome mais bateria que o modo padrão",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “Preciso escolher entre GPS padrão e multibanda?” Qual é a resposta?",
    "explanation": "O cliente não precisa entender de GPS para ter a melhor precisão: o relógio decide sozinho.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, antes de cada atividade, no menu de GPS",
      "is_correct": false
     },
     {
      "body": "Sim, pelo Garmin Connect antes de cada treino",
      "is_correct": false
     },
     {
      "body": "Não, o SatIQ alterna sozinho conforme o ambiente",
      "is_correct": true
     },
     {
      "body": "Não, o multibanda fica ligado o tempo inteiro",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que são os mapas TopoActive?",
    "explanation": "TopoActive são mapas coloridos e gratuitos, baseados em OpenStreetMap, pré-carregados nos relógios com mapeamento.",
    "active": true,
    "alternatives": [
     {
      "body": "Mapas pagos baixados por assinatura mensal",
      "is_correct": false
     },
     {
      "body": "Mapas coloridos gratuitos, já pré-carregados",
      "is_correct": true
     },
     {
      "body": "Mapas de relevo usados só pelo ClimbPro",
      "is_correct": false
     },
     {
      "body": "Mapas que dependem do celular conectado",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que um relógio sem mapeamento mostra na navegação?",
    "explanation": "Sem mapeamento, o relógio mostra só o breadcrumb, uma linha de GPS sem rua, relevo ou pontos de interesse.",
    "active": true,
    "alternatives": [
     {
      "body": "Só uma trilha, sem ruas nem relevo",
      "is_correct": true
     },
     {
      "body": "Mapa de ruas, sem curvas de nível",
      "is_correct": false
     },
     {
      "body": "Mapa completo, em preto e branco",
      "is_correct": false
     },
     {
      "body": "Nenhuma informação de navegação",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O atleta está numa cidade nova e quer correr 10 km saindo do hotel e voltando para ele. Qual recurso ajuda?",
    "explanation": "O Round-Trip Routing monta na hora um percurso de ida e volta pela distância escolhida.",
    "active": true,
    "alternatives": [
     {
      "body": "Mapas TopoActive",
      "is_correct": false
     },
     {
      "body": "SatIQ multibanda",
      "is_correct": false
     },
     {
      "body": "Trilha breadcrumb",
      "is_correct": false
     },
     {
      "body": "Round-Trip Routing",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O ciclista quer saber, durante a subida, quanto ainda falta de elevação. Qual recurso mostra isso?",
    "explanation": "O ClimbPro mostra a subida à frente: distância, inclinação média e quanto falta de elevação.",
    "active": true,
    "alternatives": [
     {
      "body": "Round-Trip Routing",
      "is_correct": false
     },
     {
      "body": "SatIQ",
      "is_correct": false
     },
     {
      "body": "ClimbPro",
      "is_correct": true
     },
     {
      "body": "TopoActive",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Meu relógio atual já tem GPS, por que multibanda faz diferença?” Qual resposta segue o módulo?",
    "explanation": "A diferença aparece em mar aberto, mata fechada e ruas estreitas entre prédios altos.",
    "active": true,
    "alternatives": [
     {
      "body": "O multibanda faz a bateria durar mais tempo",
      "is_correct": false
     },
     {
      "body": "Faz diferença onde o GPS padrão perde precisão",
      "is_correct": true
     },
     {
      "body": "O GPS comum perde o sinal com frequência",
      "is_correct": false
     },
     {
      "body": "O multibanda dispensa o celular nos treinos",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "acessorios",
  "quiz_id": "0b42b2d9-46be-4336-96a3-523b5edbd708",
  "questions": [
   {
    "body": "O cliente só quer frequência cardíaca mais precisa no peito, gastando menos. O que indicar?",
    "explanation": "A decisão é sempre a mesma: só FC precisa (HRM 200) ou dados avançados de corrida e natação (HRM 600).",
    "active": true,
    "alternatives": [
     {
      "body": "HRM 200",
      "is_correct": true
     },
     {
      "body": "HRM 600",
      "is_correct": false
     },
     {
      "body": "Sensor óptico do relógio",
      "is_correct": false
     },
     {
      "body": "Cadence Sensor 2",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como a HRM 600 lida com os dados durante a natação?",
    "explanation": "O sinal ANT+/Bluetooth não atravessa a água. A cinta guarda tudo e sincroniza quando o nado termina.",
    "active": true,
    "alternatives": [
     {
      "body": "Transmite ao relógio por ANT+ debaixo d’água",
      "is_correct": false
     },
     {
      "body": "Pausa a gravação até o atleta sair da água",
      "is_correct": false
     },
     {
      "body": "Envia os dados direto ao celular por Bluetooth",
      "is_correct": false
     },
     {
      "body": "Guarda os dados na água e sincroniza depois",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como a Garmin calcula a Potência de Corrida exibida no pulso?",
    "explanation": "A Garmin não vende footpod para isso. A potência combina o acelerômetro do relógio com os dados da HRM 600.",
    "active": false,
    "alternatives": [
     {
      "body": "Com um footpod dedicado preso ao cadarço do tênis",
      "is_correct": false
     },
     {
      "body": "Só pelo GPS multibanda do relógio, sem sensores",
      "is_correct": false
     },
     {
      "body": "Acelerômetro do relógio com os dados da HRM 600",
      "is_correct": true
     },
     {
      "body": "Com a HRM 200 somada ao sensor óptico do pulso",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer uma cinta que grave o treino sozinha, sem relógio nem celular por perto. Qual opção é correta?",
    "explanation": "A HRM 600 grava sozinha por até 24h, em mais de 18 modalidades. A HRM 200 não faz isso. As 300h são do Speed Sensor 2.",
    "active": true,
    "alternatives": [
     {
      "body": "HRM 200, que grava até 24h sozinha",
      "is_correct": false
     },
     {
      "body": "HRM 600, que grava até 24h sozinha",
      "is_correct": true
     },
     {
      "body": "HRM 600, que grava até 300h sozinha",
      "is_correct": false
     },
     {
      "body": "HRM 200, que grava sem limite de tempo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Varia RCT715 soma em relação ao RTL515?",
    "explanation": "A RCT715 grava o trajeto em vídeo, além do radar e da luz.",
    "active": false,
    "alternatives": [
     {
      "body": "Câmera que grava o trajeto",
      "is_correct": true
     },
     {
      "body": "Alcance de radar maior",
      "is_correct": false
     },
     {
      "body": "Bateria solar integrada",
      "is_correct": false
     },
     {
      "body": "Conexão Wi-Fi com o Edge",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual QuickFit usa o Fenix 8 de 47 mm?",
    "explanation": "Fenix 8: 20 mm na caixa de 42/43 mm, 22 mm na de 47 mm e 26 mm na de 51 mm.",
    "active": true,
    "alternatives": [
     {
      "body": "QuickFit 20 mm",
      "is_correct": false
     },
     {
      "body": "QuickFit 26 mm",
      "is_correct": false
     },
     {
      "body": "Watchband 22 mm",
      "is_correct": false
     },
     {
      "body": "QuickFit 22 mm",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente tem um Forerunner 970 e quer usar pulseira QuickFit. O que dizer?",
    "explanation": "O 970 vem com Watchband. Reposicionando o pino nos encaixes da caixa, ele passa a aceitar QuickFit de 22 mm.",
    "active": true,
    "alternatives": [
     {
      "body": "Encaixa direto, porque o 970 tem QuickFit de fábrica",
      "is_correct": false
     },
     {
      "body": "Não funciona, porque o 970 só aceita Watchband",
      "is_correct": false
     },
     {
      "body": "Funciona com a de 22 mm, depois de adaptar o pino",
      "is_correct": true
     },
     {
      "body": "Funciona com a de 26 mm, sem nenhuma adaptação",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente tem um Forerunner 165 e quer comprar uma pulseira QuickFit de 22 mm. O que dizer?",
    "explanation": "Forerunner 55, 165, 170 e 570 usam Quick Release, o pino de mola padrão, diferente do QuickFit mesmo com a mesma largura.",
    "active": true,
    "alternatives": [
     {
      "body": "Encaixa, porque a largura de 22 mm é igual",
      "is_correct": false
     },
     {
      "body": "Ele usa Quick Release, um sistema diferente",
      "is_correct": true
     },
     {
      "body": "Encaixa após a mesma adaptação feita no 970",
      "is_correct": false
     },
     {
      "body": "Encaixa, mas só a QuickFit de 20 mm serve",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente não sabe o tamanho do relógio e não trouxe a pulseira. Como descobrir a QuickFit certa?",
    "explanation": "Com o modelo e o tamanho da caixa em mm, dá para cruzar direto com a tabela de QuickFit por modelo.",
    "active": true,
    "alternatives": [
     {
      "body": "Perguntar o modelo e o tamanho da caixa",
      "is_correct": true
     },
     {
      "body": "Medir o pulso do cliente com uma fita",
      "is_correct": false
     },
     {
      "body": "Indicar a de 22 mm, a mais vendida",
      "is_correct": false
     },
     {
      "body": "Pedir que ele volte com a pulseira antiga",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente treina muito e sua bastante. Qual material de pulseira indicar?",
    "explanation": "Silicone e nylon UltraFit resistem ao suor e secam rápido. Couro e metal são para o dia a dia e ocasiões sociais.",
    "active": true,
    "alternatives": [
     {
      "body": "Couro, que é mais elegante",
      "is_correct": false
     },
     {
      "body": "Metal, que é mais durável",
      "is_correct": false
     },
     {
      "body": "Couro ou metal, os premium",
      "is_correct": false
     },
     {
      "body": "Silicone ou nylon UltraFit",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente perdeu o cabo do relógio novo e já tem carregador USB-C em casa. O que dizer?",
    "explanation": "O clipe magnético é sempre igual. Relógios de 2022 em diante usam ponta USB-C, e os mais antigos, USB-A.",
    "active": false,
    "alternatives": [
     {
      "body": "Cada relógio da linha usa um clipe magnético próprio",
      "is_correct": false
     },
     {
      "body": "A linha atual usa ponta USB-A, então não vai servir",
      "is_correct": false
     },
     {
      "body": "O clipe é o mesmo, e a linha atual usa ponta USB-C",
      "is_correct": true
     },
     {
      "body": "O relógio só carrega com o cabo que veio na caixa",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “O carregador não pega no meu relógio.” O que verificar primeiro?",
    "explanation": "Suor, água salgada e sujeira oxidam os contatos traseiros, e isso costuma causar o “carregador não pega”.",
    "active": true,
    "alternatives": [
     {
      "body": "Se o cabo usa ponta USB-A ou USB-C",
      "is_correct": false
     },
     {
      "body": "Oxidação ou sujeira nos pinos traseiros",
      "is_correct": true
     },
     {
      "body": "Se o software do relógio está atualizado",
      "is_correct": false
     },
     {
      "body": "Se o modo de economia está ativado",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como apresentar o ecossistema de acessórios para o triatleta?",
    "explanation": "Comece pelo que resolve a dor imediata do cliente e amplie o ecossistema aos poucos.",
    "active": true,
    "alternatives": [
     {
      "body": "Em camadas, começando pela dor imediata",
      "is_correct": true
     },
     {
      "body": "Todos os acessórios juntos, num pacote",
      "is_correct": false
     },
     {
      "body": "Só quando o cliente citar um acessório",
      "is_correct": false
     },
     {
      "body": "Pelo acessório de maior valor da loja",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "fechamento",
  "quiz_id": "57a093ca-9eba-4eea-b365-39512c9bbede",
  "questions": [
   {
    "body": "Qual frase é um fechamento assumptivo?",
    "explanation": "O fechamento assumptivo vai direto a um detalhe prático, como se a venda já estivesse decidida.",
    "active": true,
    "alternatives": [
     {
      "body": "“Você quer levar o relógio hoje ou prefere esperar?”",
      "is_correct": false
     },
     {
      "body": "“Vamos configurar com a pulseira de titânio ou a padrão?”",
      "is_correct": true
     },
     {
      "body": "“Posso te mostrar mais algum modelo da linha Fenix?”",
      "is_correct": false
     },
     {
      "body": "“Se eu conseguir um desconto, você fecha agora?”",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual frase aplica a técnica “qual, não se”?",
    "explanation": "Duas opções premium no lugar de uma escolha entre comprar ou não comprar.",
    "active": true,
    "alternatives": [
     {
      "body": "“Qual combina mais com você: Fenix 8 ou Forerunner 970?”",
      "is_correct": true
     },
     {
      "body": "“Você prefere pensar um pouco mais antes de decidir?”",
      "is_correct": false
     },
     {
      "body": "“Você vai levar o Fenix 8 ou prefere deixar para depois?”",
      "is_correct": false
     },
     {
      "body": "“Já pesquisou o preço do Fenix 8 em outras lojas?”",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Em compras acima de R$ 4.000, qual postura o cliente espera do vendedor?",
    "explanation": "Em ticket alto, o cliente espera uma postura consultiva, não um pitch agressivo.",
    "active": true,
    "alternatives": [
     {
      "body": "Insistente, com urgência de prazo",
      "is_correct": false
     },
     {
      "body": "Discreta, deixando ele decidir só",
      "is_correct": false
     },
     {
      "body": "Focada no desconto disponível",
      "is_correct": false
     },
     {
      "body": "Consultiva, guiando a escolha",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente que treina ao ar livre: “Não preciso de mais nada além do relógio.” Qual resposta segue o módulo?",
    "explanation": "O bundle precisa fazer sentido para o uso que o cliente descreveu. A cinta resolve a variação da leitura óptica em esforço intenso.",
    "active": true,
    "alternatives": [
     {
      "body": "Insistir no pacote, porque ele aumenta o ticket da venda",
      "is_correct": false
     },
     {
      "body": "Oferecer desconto no pacote com película e pulseira",
      "is_correct": false
     },
     {
      "body": "Mostrar como a cinta deixa a FC mais estável no esforço",
      "is_correct": true
     },
     {
      "body": "Explicar que o relógio perde recursos sem os acessórios",
      "is_correct": false
     }
    ]
   },
   {
    "body": "No roteiro do triatleta premium, quando oferecer a HRM 600 junto?",
    "explanation": "O bundle entra depois de validar a dor real, que no roteiro é a precisão do dado de recuperação.",
    "active": true,
    "alternatives": [
     {
      "body": "Logo na abertura, antes de fazer a sondagem",
      "is_correct": false
     },
     {
      "body": "Depois de validar a dor real do cliente",
      "is_correct": true
     },
     {
      "body": "Antes de apresentar os dois modelos",
      "is_correct": false
     },
     {
      "body": "Só quando o cliente pedir pelo nome",
      "is_correct": false
     }
    ]
   },
   {
    "body": "No roteiro, como o vendedor diferencia o Fenix 8 do Forerunner 970?",
    "explanation": "“Mais recursos multiesporte ou um corpo mais leve focado em corrida?”",
    "active": true,
    "alternatives": [
     {
      "body": "Mais recursos multiesporte x corpo mais leve",
      "is_correct": true
     },
     {
      "body": "Bateria solar x bateria sem carregamento solar",
      "is_correct": false
     },
     {
      "body": "Tela AMOLED x tela MIP de baixo consumo",
      "is_correct": false
     },
     {
      "body": "Mapas completos x navegação só por trilha",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é o diferencial mais forte da Garmin contra o Apple Watch Ultra para o triatleta?",
    "explanation": "A bateria é decisiva em treinos e provas de múltiplos dias.",
    "active": true,
    "alternatives": [
     {
      "body": "Tela maior e mais brilhante no Garmin",
      "is_correct": false
     },
     {
      "body": "Pagamento por aproximação no relógio",
      "is_correct": false
     },
     {
      "body": "Preço sempre menor que o do Ultra",
      "is_correct": false
     },
     {
      "body": "Autonomia de semanas contra 1 a 2 dias",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Em que ponto o Coros pode levar vantagem sobre a Garmin?",
    "explanation": "O Coros pode vencer em horas brutas de GPS em alguns modelos. As outras opções são pontos fortes da Garmin.",
    "active": true,
    "alternatives": [
     {
      "body": "Profundidade de treino e recuperação",
      "is_correct": false
     },
     {
      "body": "Ecossistema de apps e integrações",
      "is_correct": false
     },
     {
      "body": "Horas brutas de GPS em alguns modelos",
      "is_correct": true
     },
     {
      "body": "Suporte presencial aqui no Brasil",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual argumento usar na comparação com o Coros?",
    "explanation": "Diferenciação real e verificável: o Garmin Connect é mais completo em treino e recuperação. Sem desqualificar o concorrente.",
    "active": true,
    "alternatives": [
     {
      "body": "O Coros não tem GPS multibanda em nenhum modelo",
      "is_correct": false
     },
     {
      "body": "A profundidade do ecossistema de treino e recuperação",
      "is_correct": true
     },
     {
      "body": "O Coros sempre dura menos horas de GPS que a Garmin",
      "is_correct": false
     },
     {
      "body": "O Coros não registra provas de triathlon completas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O triatleta está entre um Garmin e um Apple Watch Ultra. Qual frase compara sem desqualificar o concorrente?",
    "explanation": "O argumento correto é diferenciação real e verificável, como a bateria. Dizer que o concorrente “não presta” enfraquece a venda.",
    "active": true,
    "alternatives": [
     {
      "body": "“O Garmin dura semanas; o Ultra costuma durar de 1 a 2 dias.”",
      "is_correct": true
     },
     {
      "body": "“O Apple Watch Ultra não serve para quem treina de verdade.”",
      "is_correct": false
     },
     {
      "body": "“Quem leva triathlon a sério não compete com Apple Watch.”",
      "is_correct": false
     },
     {
      "body": "“O Apple Watch Ultra é só um celular caro no seu pulso.”",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "inreach",
  "quiz_id": "0e86bed3-67c6-467d-a47a-45d7e9734016",
  "questions": [
   {
    "body": "O cliente quer o comunicador satelital mais leve, só precisa de texto e SOS e tem orçamento ajustado. Qual indicar?",
    "explanation": "O Mini 2 é o mais leve da linha, com ótimo custo-benefício para quem precisa só de texto e SOS.",
    "active": true,
    "alternatives": [
     {
      "body": "inReach Mini 3",
      "is_correct": false
     },
     {
      "body": "inReach Mini 3 Plus",
      "is_correct": false
     },
     {
      "body": "inReach Mini 2",
      "is_correct": true
     },
     {
      "body": "inReach Messenger",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer tela colorida touch e mais bateria, mas só vai mandar texto. Qual indicar?",
    "explanation": "O Mini 3 tem touchscreen colorido, mais bateria e IP67, e continua só com texto.",
    "active": true,
    "alternatives": [
     {
      "body": "inReach Mini 2",
      "is_correct": false
     },
     {
      "body": "inReach Mini 3",
      "is_correct": true
     },
     {
      "body": "inReach Mini 3 Plus",
      "is_correct": false
     },
     {
      "body": "inReach Messenger Plus",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer mandar foto e nota de voz via satélite. Qual indicar?",
    "explanation": "Só o Mini 3 Plus manda foto e nota de voz de até 30 segundos, graças ao Iridium Certus.",
    "active": true,
    "alternatives": [
     {
      "body": "inReach Mini 3 Plus",
      "is_correct": true
     },
     {
      "body": "inReach Mini 3",
      "is_correct": false
     },
     {
      "body": "inReach Mini 2",
      "is_correct": false
     },
     {
      "body": "Mini 3 com o Messenger",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Entre os dois modelos touch, o cliente só precisa de texto e SOS e quer a maior bateria. O que dizer?",
    "explanation": "O Mini 3 dura um pouco mais (350h) e custa menos. O Plus troca um pouco de bateria por voz e foto.",
    "active": false,
    "alternatives": [
     {
      "body": "Mini 3 Plus, com 350h contra 330h do 3",
      "is_correct": false
     },
     {
      "body": "Mini 3 Plus, que dura o dobro do Mini 3",
      "is_correct": false
     },
     {
      "body": "Mini 3, que dura o dobro do Mini 3 Plus",
      "is_correct": false
     },
     {
      "body": "Mini 3, com 350h contra 330h do Plus",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “Preciso de assinatura para usar o inReach?” Qual é a resposta?",
    "explanation": "O inReach só funciona com plano de satélite ativo, contratado à parte. Isso precisa ficar claro antes da compra.",
    "active": true,
    "alternatives": [
     {
      "body": "Não, o satélite vem incluso por toda a vida",
      "is_correct": false
     },
     {
      "body": "Só para o SOS; as mensagens são gratuitas",
      "is_correct": false
     },
     {
      "body": "Sim, um plano de satélite contratado à parte",
      "is_correct": true
     },
     {
      "body": "Só se for usar o aparelho fora do Brasil",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Eu só usaria quando fosse viajar.” Qual opção de plano faz sentido?",
    "explanation": "O plano mês a mês permite ativar antes de uma viagem e pausar depois, sem compromisso anual.",
    "active": true,
    "alternatives": [
     {
      "body": "O plano anual, mesmo para uso esporádico",
      "is_correct": false
     },
     {
      "body": "O plano mensal, que dá para ativar e pausar",
      "is_correct": true
     },
     {
      "body": "Nenhum, fora de temporada ele funciona sem",
      "is_correct": false
     },
     {
      "body": "Um plano cobrado por mensagem enviada",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que acontece quando o cliente aciona o SOS interativo?",
    "explanation": "O SOS aciona a central de resposta da Garmin (GEOS), com coordenação profissional em tempo real.",
    "active": true,
    "alternatives": [
     {
      "body": "A central GEOS coordena o caso com mensagens em duas vias",
      "is_correct": true
     },
     {
      "body": "O aparelho liga para a emergência local pelo celular",
      "is_correct": false
     },
     {
      "body": "A localização vai só para os contatos cadastrados",
      "is_correct": false
     },
     {
      "body": "O aparelho dispara um alarme sonoro para chamar ajuda",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente se perde numa trilha com a visibilidade piorando. Qual recurso ajuda a voltar pelo mesmo caminho?",
    "explanation": "O TracBack retraça o caminho já percorrido para voltar com segurança.",
    "active": true,
    "alternatives": [
     {
      "body": "LiveTrack",
      "is_correct": false
     },
     {
      "body": "Garmin Explore",
      "is_correct": false
     },
     {
      "body": "Garmin Messenger",
      "is_correct": false
     },
     {
      "body": "TracBack",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Por que o inReach vale mais que só o celular em área remota?",
    "explanation": "Cobertura via satélite onde não há sinal, semanas de bateria em rastreio e resistência a clima extremo.",
    "active": true,
    "alternatives": [
     {
      "body": "Tela maior e mais nítida que a de qualquer celular",
      "is_correct": false
     },
     {
      "body": "Ligações de voz mais baratas que as do celular",
      "is_correct": false
     },
     {
      "body": "Satélite sem sinal, bateria longa e resistência",
      "is_correct": true
     },
     {
      "body": "Comunicação sem precisar de nenhum plano ativo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente pratica stand-up paddle e vai levar um inReach. Qual acessório faz sentido oferecer?",
    "explanation": "O cordão de neoprene mantém o inReach flutuando e por perto em atividades aquáticas.",
    "active": true,
    "alternatives": [
     {
      "body": "Estojo de Mergulho",
      "is_correct": false
     },
     {
      "body": "Cordão de Flutuação",
      "is_correct": true
     },
     {
      "body": "Mosquetão extra",
      "is_correct": false
     },
     {
      "body": "Suporte de guidão",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente pergunta pelo inReach Messenger. O que dizer?",
    "explanation": "A Garmin vende o Messenger globalmente, mas o portfólio da loja é Mini 2, Mini 3 e Mini 3 Plus.",
    "active": true,
    "alternatives": [
     {
      "body": "Não faz parte do catálogo atual da loja",
      "is_correct": true
     },
     {
      "body": "É vendido aqui apenas sob encomenda",
      "is_correct": false
     },
     {
      "body": "É o mesmo produto que o inReach Mini 3",
      "is_correct": false
     },
     {
      "body": "Foi substituído pelo inReach Mini 2",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o inReach faz quando pareado com um relógio Garmin compatível?",
    "explanation": "Pareado com mais de 80 dispositivos Garmin compatíveis, o inReach estende mensagens e SOS para o pulso.",
    "active": false,
    "alternatives": [
     {
      "body": "Transforma o relógio em um celular",
      "is_correct": false
     },
     {
      "body": "Recarrega a bateria do relógio",
      "is_correct": false
     },
     {
      "body": "Dispensa o plano de satélite ativo",
      "is_correct": false
     },
     {
      "body": "Leva mensagens e SOS para o pulso",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "cartografia",
  "quiz_id": "aa478f42-bd88-48b0-bf88-6904433307a8",
  "questions": [
   {
    "body": "Antes de indicar uma cartografia, o que o vendedor descobre?",
    "explanation": "Marítimo ou terrestre, modelo exato, regiões e se precisa de recursos avançados. A partir disso, a solução compatível.",
    "active": true,
    "alternatives": [
     {
      "body": "Qual mapa o cliente viu no site da Garmin",
      "is_correct": false
     },
     {
      "body": "Se o cliente prefere mapa físico ou digital",
      "is_correct": false
     },
     {
      "body": "Quanto espaço livre o equipamento ainda tem",
      "is_correct": false
     },
     {
      "body": "O uso, o modelo exato e a região de navegação",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O equipamento marítimo do cliente é compatível com Navionics+. O que priorizar?",
    "explanation": "O Navionics+ é a geração atual, com dados Garmin e Navionics e downloads diários.",
    "active": true,
    "alternatives": [
     {
      "body": "BlueChart g3",
      "is_correct": false
     },
     {
      "body": "City Navigator",
      "is_correct": false
     },
     {
      "body": "Garmin Navionics+",
      "is_correct": true
     },
     {
      "body": "BlueChart g3 Vision",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente tem um equipamento marítimo antigo, sem suporte ao Navionics+. O que considerar?",
    "explanation": "O BlueChart g3 é a geração anterior, indicada para equipamentos sem suporte ao Navionics+.",
    "active": true,
    "alternatives": [
     {
      "body": "Garmin Navionics+",
      "is_correct": false
     },
     {
      "body": "BlueChart g3",
      "is_correct": true
     },
     {
      "body": "City Navigator NT",
      "is_correct": false
     },
     {
      "body": "Navionics Vision+",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O equipamento tem os dois mapeamentos e as coberturas se sobrepõem. Qual carta aparece?",
    "explanation": "Na sobreposição, o Navionics+ tem prioridade, e a troca acontece automaticamente conforme a cobertura.",
    "active": true,
    "alternatives": [
     {
      "body": "Navionics+, de forma automática",
      "is_correct": true
     },
     {
      "body": "BlueChart g3, por ser a anterior",
      "is_correct": false
     },
     {
      "body": "A que o cliente escolher no menu",
      "is_correct": false
     },
     {
      "body": "As duas, sobrepostas na tela",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que a linha Vision acrescenta à cartografia marítima?",
    "explanation": "As versões Vision são premium: relevo de alta resolução, cartas em 3D e fotos aéreas.",
    "active": true,
    "alternatives": [
     {
      "body": "Downloads diários e atualização ilimitada",
      "is_correct": false
     },
     {
      "body": "Mapas de ruas, rodovias e pontos de interesse",
      "is_correct": false
     },
     {
      "body": "Rotas rodoviárias até endereços e cruzamentos",
      "is_correct": false
     },
     {
      "body": "Relevo em alta resolução, 3D e fotos aéreas",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente quer a BlueChart g3 Vision. O que é importante informar?",
    "explanation": "A BlueChart g3 Vision não é recebida no Brasil. Compras diretas com a Garmin são tratadas com o fabricante.",
    "active": true,
    "alternatives": [
     {
      "body": "Está disponível na loja com garantia de 2 anos da operação",
      "is_correct": false
     },
     {
      "body": "Só é vendida junto com um equipamento marítimo novo",
      "is_correct": false
     },
     {
      "body": "Não é recebida aqui; a compra direta fica sem nossa garantia",
      "is_correct": true
     },
     {
      "body": "Pode ser baixada gratuitamente pelo Garmin Express",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a cobertura do City Navigator South America NT?",
    "explanation": "Países da América do Sul, incluindo Brasil, Argentina e Chile, e o estado da Flórida.",
    "active": true,
    "alternatives": [
     {
      "body": "Só o Brasil, com todas as capitais",
      "is_correct": false
     },
     {
      "body": "América do Sul e o estado da Flórida",
      "is_correct": true
     },
     {
      "body": "América do Sul e América Central",
      "is_correct": false
     },
     {
      "body": "América do Sul e os Estados Unidos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente está comprando um zūmo XT2 e quer navegação rodoviária. O que fazer antes de fechar?",
    "explanation": "No zūmo XT2 e no Drive 53, o City Navigator é adquirido separadamente. Aparelho e mapa são uma solução única.",
    "active": true,
    "alternatives": [
     {
      "body": "Confirmar e oferecer o City Navigator à parte",
      "is_correct": true
     },
     {
      "body": "Avisar que o mapa rodoviário já vem de fábrica",
      "is_correct": false
     },
     {
      "body": "Indicar o Navionics+ para usar nas estradas",
      "is_correct": false
     },
     {
      "body": "Orientar a baixar o mapa grátis pelo Connect",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Como eu atualizo o City Navigator depois?” Qual é a resposta?",
    "explanation": "O City Navigator não é atualizado após a compra. Para dados mais recentes, é preciso uma nova licença.",
    "active": true,
    "alternatives": [
     {
      "body": "Com downloads diários pelo Garmin Express",
      "is_correct": false
     },
     {
      "body": "Automaticamente, sempre que conectar ao Wi-Fi",
      "is_correct": false
     },
     {
      "body": "Pelo aplicativo Garmin Connect, sem custo",
      "is_correct": false
     },
     {
      "body": "Adquirindo uma nova licença da versão recente",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como o Navionics+ se mantém atualizado?",
    "explanation": "O Navionics+ trabalha com downloads frequentes. Esse é o ponto que o diferencia do City Navigator.",
    "active": true,
    "alternatives": [
     {
      "body": "Com nova licença anual",
      "is_correct": false
     },
     {
      "body": "Trocando o equipamento",
      "is_correct": false
     },
     {
      "body": "Com downloads diários",
      "is_correct": true
     },
     {
      "body": "Ele não é atualizado",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente pergunta quanto espaço precisa para baixar os mapas. O que dizer?",
    "explanation": "A necessidade de armazenamento varia, e dependendo do modelo os mapas vão na memória interna ou em cartão microSD/SD.",
    "active": false,
    "alternatives": [
     {
      "body": "Todo mapa ocupa no máximo 1 GB em qualquer aparelho",
      "is_correct": false
     },
     {
      "body": "Varia por produto e mapa, e pode usar cartão compatível",
      "is_correct": true
     },
     {
      "body": "Os mapas só podem ficar na memória interna do aparelho",
      "is_correct": false
     },
     {
      "body": "Os mapas não ocupam espaço, porque ficam na nuvem",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "difinreach",
  "quiz_id": "54935f4e-df07-438a-a6e2-5730ba2f7ee3",
  "questions": [
   {
    "body": "Qual é o portfólio de inReach que a loja trabalha?",
    "explanation": "O portfólio da loja é Mini 2, Mini 3 e Mini 3 Plus. Messenger e Messenger Plus não fazem parte do catálogo.",
    "active": true,
    "alternatives": [
     {
      "body": "Mini 2, Mini 3 e Mini 3 Plus",
      "is_correct": true
     },
     {
      "body": "Mini 2, Messenger e Messenger Plus",
      "is_correct": false
     },
     {
      "body": "Mini 3, Mini 3 Plus e Messenger",
      "is_correct": false
     },
     {
      "body": "Mini 2, Mini 3 e Messenger Plus",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que os três modelos inReach da loja têm em comum?",
    "explanation": "Os três são comunicadores via satélite com SOS interativo, mensagens bidirecionais e compartilhamento de localização.",
    "active": true,
    "alternatives": [
     {
      "body": "Tela colorida touch e envio de fotos por satélite",
      "is_correct": false
     },
     {
      "body": "Nota de voz de 30 segundos e envio de fotos",
      "is_correct": false
     },
     {
      "body": "Mapas TopoActive e rotas direto no aparelho",
      "is_correct": false
     },
     {
      "body": "SOS interativo, texto em duas vias e localização",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual rede leva a comunicação do inReach a lugares sem sinal de celular?",
    "explanation": "A comunicação do inReach usa a rede de satélites Iridium. GPS e GLONASS são sistemas de posicionamento.",
    "active": true,
    "alternatives": [
     {
      "body": "Rede GPS",
      "is_correct": false
     },
     {
      "body": "Rede 5G rural",
      "is_correct": false
     },
     {
      "body": "Rede Iridium",
      "is_correct": true
     },
     {
      "body": "Rede GLONASS",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o módulo Iridium Certus permite no Mini 3 Plus?",
    "explanation": "O Iridium Certus é o que permite ao Mini 3 Plus mandar foto e nota de voz de até 30 segundos.",
    "active": true,
    "alternatives": [
     {
      "body": "Usar o SOS sem plano ativo",
      "is_correct": false
     },
     {
      "body": "Enviar foto e nota de voz",
      "is_correct": true
     },
     {
      "body": "Dobrar a autonomia da bateria",
      "is_correct": false
     },
     {
      "body": "Navegar com mapas detalhados",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Por que o SOS do inReach é chamado de interativo?",
    "explanation": "Durante a emergência, a central GEOS e o cliente trocam mensagens em duas vias.",
    "active": true,
    "alternatives": [
     {
      "body": "Permite trocar mensagens com a central",
      "is_correct": true
     },
     {
      "body": "Acende uma luz que pisca para o resgate",
      "is_correct": false
     },
     {
      "body": "Liga por voz para os contatos cadastrados",
      "is_correct": false
     },
     {
      "body": "Publica a localização nas redes sociais",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a diferença de resistência entre o Mini 2 e o Mini 3?",
    "explanation": "O Mini 2 é IPX7 (água). O Mini 3 e o Mini 3 Plus são IP67 (poeira e água).",
    "active": true,
    "alternatives": [
     {
      "body": "Mini 2 é IP67; o Mini 3 é IPX7, só água",
      "is_correct": false
     },
     {
      "body": "Os dois têm IP67 contra poeira e água",
      "is_correct": false
     },
     {
      "body": "Só o Mini 3 Plus tem resistência à água",
      "is_correct": false
     },
     {
      "body": "Mini 2 é IPX7; o Mini 3 é IP67, com poeira",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é o inReach mais leve da linha?",
    "explanation": "O Mini 2 pesa cerca de 100 g, contra 122 g do Mini 3 e 139 g do Mini 3 Plus.",
    "active": false,
    "alternatives": [
     {
      "body": "Mini 3",
      "is_correct": false
     },
     {
      "body": "Mini 3 Plus",
      "is_correct": false
     },
     {
      "body": "Mini 2",
      "is_correct": true
     },
     {
      "body": "Os três pesam igual",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual aplicativo o Mini 3 Plus usa para mandar foto e nota de voz?",
    "explanation": "O Garmin Messenger envia e recebe foto, voz e texto via satélite no Mini 3 Plus.",
    "active": false,
    "alternatives": [
     {
      "body": "Garmin Explore",
      "is_correct": false
     },
     {
      "body": "Garmin Messenger",
      "is_correct": true
     },
     {
      "body": "Garmin Connect IQ",
      "is_correct": false
     },
     {
      "body": "Garmin Express",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Para que serve o app Garmin Explore com o inReach?",
    "explanation": "O Explore reúne planejamento de rota, previsão do tempo e histórico de mensagens, sincronizado com o inReach.",
    "active": true,
    "alternatives": [
     {
      "body": "Planejar rotas, ver o tempo e o histórico",
      "is_correct": true
     },
     {
      "body": "Enviar foto e nota de voz pelo satélite",
      "is_correct": false
     },
     {
      "body": "Contratar e pausar o plano de satélite",
      "is_correct": false
     },
     {
      "body": "Atualizar o software do inReach pelo PC",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Por que não levar o modelo mais simples, que é mais barato?” Qual resposta segue o módulo?",
    "explanation": "A diferença de preço compra touchscreen e bateria (Mini 3) ou voz e foto (Mini 3 Plus). Para texto e SOS, o Mini 2 resolve.",
    "active": true,
    "alternatives": [
     {
      "body": "O modelo mais simples não tem o SOS interativo",
      "is_correct": false
     },
     {
      "body": "O modelo mais simples não funciona sem celular",
      "is_correct": false
     },
     {
      "body": "O Mini 2 só envia mensagens, sem receber",
      "is_correct": false
     },
     {
      "body": "Se só precisa de texto e SOS, o Mini 2 resolve",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “Vale trocar meu Mini 2 pelo Mini 3?” Qual resposta segue o módulo?",
    "explanation": "O Mini 3 ganha touchscreen colorido, mais bateria e IP67, mas continua só com texto. Foto e voz são do Mini 3 Plus.",
    "active": true,
    "alternatives": [
     {
      "body": "Vale pela foto e voz, que o Mini 2 não tem",
      "is_correct": false
     },
     {
      "body": "Vale pelo SOS, que o Mini 2 não oferece",
      "is_correct": false
     },
     {
      "body": "Vale pelo touch colorido, bateria e resistência",
      "is_correct": true
     },
     {
      "body": "Vale pela rede de satélite, mais rápida no 3",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Na hora de falar do valor do plano de satélite, o que o vendedor faz?",
    "explanation": "Os planos partem de US$ 11,95/mês, mas os preços podem mudar. Confirme sempre com o time de assinaturas.",
    "active": true,
    "alternatives": [
     {
      "body": "Informa US$ 11,95 como preço fixo do plano anual",
      "is_correct": false
     },
     {
      "body": "Confirma os valores vigentes com o time de assinaturas",
      "is_correct": true
     },
     {
      "body": "Diz que o plano custa o mesmo que um plano de celular",
      "is_correct": false
     },
     {
      "body": "Informa que o primeiro ano de plano é gratuito",
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
    select coalesce(array_agg(md5('zonas-quiz-v2|' || (z->>'key') || '|' || g)::uuid), '{}')
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
      v_qid := md5('zonas-quiz-v2|' || (z->>'key') || '|' || qi)::uuid;

      insert into questions (id, quiz_id, body, explanation, order_index, is_active)
      values (v_qid, (z->>'quiz_id')::uuid, q->>'body', q->>'explanation', qi, (q->>'active')::boolean)
      on conflict (id) do update
         set body = excluded.body, explanation = excluded.explanation,
             order_index = excluded.order_index, is_active = excluded.is_active;

      for a, ai in select e, (o - 1)::int from jsonb_array_elements(q->'alternatives') with ordinality as t(e, o) loop
        insert into alternatives (id, question_id, body, is_correct, order_index)
        values (md5('zonas-quiz-v2|' || (z->>'key') || '|' || qi || '|' || ai)::uuid, v_qid,
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
-- FIM DA MIGRAÇÃO 173
-- ============================================================================
