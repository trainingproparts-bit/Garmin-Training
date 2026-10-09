-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 176: Quizzes Especialista da Academia de Produtos
-- ============================================================================
-- Pedido do usuário (2026-10-08): padronizar os 42 Quizzes Especialista
-- (um por produto, ligados em product_quizzes) com 10 perguntas cada,
-- corrigir as alternativas absurdas e misturar três tipos de pergunta:
-- especificação técnica, comparativo entre modelos e argumento de venda.
-- Antes, a maioria tinha de 2 a 6 perguntas.
--
-- Fonte: só a ficha de cada produto (seções e comparativos da Academia).
-- Pontos em que as fichas se contradizem ficaram fora (ex.: música no
-- Forerunner 70, Status de Treino no 165, bateria do Edge 540 Solar,
-- Garmin Pay no Edge 850, lavagem das cintas na máquina).
--
-- Mesmo mecanismo das sql/172 a 175: perguntas antigas ficam inativas
-- (histórico preservado), ids determinísticos, rodar de novo só atualiza.
-- Gerado a partir de quiz_data_esp.mjs, com checagem automática de
-- tamanho das alternativas, travessão e emoji.
-- ============================================================================

do $$
declare
  v_data jsonb := $q$[
 {
  "key": "forerunner-55",
  "quiz_id": "81f6bf88-25fb-4e74-a75c-faec195e364a",
  "questions": [
   {
    "body": "Que tipo de tela o Forerunner 55 tem?",
    "explanation": "O 55 tem tela MIP transflectiva de 1,04\", controlada só pelos 5 botões físicos.",
    "active": true,
    "alternatives": [
     {
      "body": "MIP de 1,04\", sem touchscreen",
      "is_correct": true
     },
     {
      "body": "AMOLED de 1,2\", com touchscreen",
      "is_correct": false
     },
     {
      "body": "MIP de 1,2\", com touchscreen",
      "is_correct": false
     },
     {
      "body": "AMOLED de 1,04\", só com botões",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a autonomia do Forerunner 55?",
    "explanation": "Até 14 dias no modo smartwatch e até 20 h só com GPS. As outras opções são do 70, do 165 e do antigo 45.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 13 dias no smartwatch e 23 h de GPS",
      "is_correct": false
     },
     {
      "body": "Até 11 dias no smartwatch e 19 h de GPS",
      "is_correct": false
     },
     {
      "body": "Até 7 dias no smartwatch e 13 h de GPS",
      "is_correct": false
     },
     {
      "body": "Até 14 dias no smartwatch e 20 h de GPS",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Quantos painéis de luz tem o sensor cardíaco do Forerunner 55?",
    "explanation": "O 55 tem 2 painéis de luz, contra 4 no Forerunner 70.",
    "active": true,
    "alternatives": [
     {
      "body": "4 painéis",
      "is_correct": false
     },
     {
      "body": "3 painéis",
      "is_correct": false
     },
     {
      "body": "2 painéis",
      "is_correct": true
     },
     {
      "body": "6 painéis",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Forerunner 70 adiciona em relação ao 55?",
    "explanation": "O salto do 55 para o 70 é a tela AMOLED touchscreen e a chegada de Prontidão e Status de Treino, além de potência de corrida no pulso.",
    "active": true,
    "alternatives": [
     {
      "body": "Garmin Pay, altímetro barométrico e bússola",
      "is_correct": false
     },
     {
      "body": "Tela AMOLED touch, Prontidão e Status de Treino",
      "is_correct": true
     },
     {
      "body": "Bateria mais longa e uma tela MIP maior",
      "is_correct": false
     },
     {
      "body": "Mapas embarcados, lanterna e GPS multibanda",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Em bateria, como o Forerunner 55 se compara ao 70?",
    "explanation": "A tela MIP gasta menos energia: até 14 dias no 55 contra 13 dias no 70, praticamente empatado.",
    "active": true,
    "alternatives": [
     {
      "body": "O 55 dura um pouco mais, com tela mais simples",
      "is_correct": true
     },
     {
      "body": "O 70 dura o dobro, graças à tela AMOLED",
      "is_correct": false
     },
     {
      "body": "Os dois têm a mesma bateria em todos os modos",
      "is_correct": false
     },
     {
      "body": "O 55 dura menos, por usar um sensor mais antigo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual argumento vende melhor o Forerunner 55?",
    "explanation": "O 55 vende bem quando o argumento é simplicidade e preço, sem empurrar recursos que o cliente não pediu.",
    "active": true,
    "alternatives": [
     {
      "body": "Prontidão de Treino e métricas avançadas",
      "is_correct": false
     },
     {
      "body": "Tela AMOLED com touchscreen responsivo",
      "is_correct": false
     },
     {
      "body": "Música offline e pagamento pelo pulso",
      "is_correct": false
     },
     {
      "body": "Simplicidade, bateria de semanas e menor preço",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “A tela desse aqui é ruim?” Qual resposta segue a ficha?",
    "explanation": "A tela MIP é funcional e tem ótima leitura ao sol, sem o brilho e o toque das telas mais caras. Mostrar antes evita expectativa errada.",
    "active": true,
    "alternatives": [
     {
      "body": "É igual à AMOLED do 70, só que com menos cores",
      "is_correct": false
     },
     {
      "body": "É ruim mesmo, então indique sempre o 70",
      "is_correct": false
     },
     {
      "body": "É MIP, lê bem ao sol; vale mostrar antes de vender",
      "is_correct": true
     },
     {
      "body": "É touchscreen, mas com um pouco menos de brilho",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Para qual cliente o Forerunner 55 faz mais sentido?",
    "explanation": "Iniciantes, quem tem o orçamento como prioridade e quem valoriza bateria acima de recursos.",
    "active": true,
    "alternatives": [
     {
      "body": "Quem quer pagar com o pulso no treino",
      "is_correct": false
     },
     {
      "body": "Quem começa do zero e prioriza o preço",
      "is_correct": true
     },
     {
      "body": "Quem treina com Prontidão de Treino",
      "is_correct": false
     },
     {
      "body": "Quem quer o visual AMOLED no dia a dia",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como tratar o Forerunner 55 no catálogo atual?",
    "explanation": "O 55 foi substituído pelo Forerunner 70. Trate como referência de comparação ou venda enquanto durar o estoque.",
    "active": true,
    "alternatives": [
     {
      "body": "Foi substituído pelo 70; é referência ou estoque",
      "is_correct": true
     },
     {
      "body": "É o lançamento mais recente da faixa de entrada",
      "is_correct": false
     },
     {
      "body": "Foi substituído pelo 165 na linha atual",
      "is_correct": false
     },
     {
      "body": "É vendido junto com o 70 como versão Pro",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Forerunner 55 trouxe de novo em relação ao Forerunner 45?",
    "explanation": "O 55 foi uma evolução de bateria e software: mais autonomia, sugestão diária de treino e detecção de corrida/caminhada.",
    "active": true,
    "alternatives": [
     {
      "body": "Tela AMOLED touch e música offline",
      "is_correct": false
     },
     {
      "body": "Mapas e altímetro barométrico",
      "is_correct": false
     },
     {
      "body": "Prontidão de Treino e Status de Treino",
      "is_correct": false
     },
     {
      "body": "Mais bateria e treino sugerido todo dia",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "forerunner-70",
  "quiz_id": "82cd0d76-39d0-49dd-810c-ed2eda890078",
  "questions": [
   {
    "body": "Qual é a tela do Forerunner 70?",
    "explanation": "Tela AMOLED de 1,2\" com touchscreen responsivo e o tradicional controle por 5 botões.",
    "active": true,
    "alternatives": [
     {
      "body": "MIP de 1,04\", só com 5 botões",
      "is_correct": false
     },
     {
      "body": "AMOLED de 1,2\", touch e 5 botões",
      "is_correct": true
     },
     {
      "body": "AMOLED de 1,3\", só touchscreen",
      "is_correct": false
     },
     {
      "body": "MIP de 1,2\", touch e 5 botões",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a autonomia do Forerunner 70?",
    "explanation": "Até 13 dias no modo smartwatch, 28 dias em economia, 23 h só com GPS e 16 h com todos os sistemas GNSS.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 13 dias no smartwatch e 23 h de GPS",
      "is_correct": true
     },
     {
      "body": "Até 14 dias no smartwatch e 20 h de GPS",
      "is_correct": false
     },
     {
      "body": "Até 11 dias no smartwatch e 19 h de GPS",
      "is_correct": false
     },
     {
      "body": "Até 10 dias no smartwatch e 26 h de GPS",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Até quantos dias o Forerunner 70 chega no modo de economia de bateria?",
    "explanation": "No modo economia, o 70 chega a até 28 dias.",
    "active": true,
    "alternatives": [
     {
      "body": "13 dias",
      "is_correct": false
     },
     {
      "body": "20 dias",
      "is_correct": false
     },
     {
      "body": "40 dias",
      "is_correct": false
     },
     {
      "body": "28 dias",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que o Forerunner 170 tem e o 70 não tem?",
    "explanation": "O 170 soma Garmin Pay, altímetro barométrico, bússola, giroscópio, termômetro, potência de ciclismo, águas abertas e música na versão Music.",
    "active": true,
    "alternatives": [
     {
      "body": "Prontidão de Treino e Status de Treino",
      "is_correct": false
     },
     {
      "body": "Tela AMOLED touchscreen com 5 botões",
      "is_correct": false
     },
     {
      "body": "Garmin Pay, altímetro e águas abertas",
      "is_correct": true
     },
     {
      "body": "Potência e dinâmica de corrida no pulso",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é o maior salto do Forerunner 70 sobre o 55?",
    "explanation": "Tela AMOLED touchscreen e Prontidão e Status de Treino, recursos que não existiam na geração do 55.",
    "active": true,
    "alternatives": [
     {
      "body": "Bateria bem mais longa que a do 55",
      "is_correct": false
     },
     {
      "body": "Tela AMOLED touch e Prontidão de Treino",
      "is_correct": true
     },
     {
      "body": "Garmin Pay e música offline no pulso",
      "is_correct": false
     },
     {
      "body": "Mapas e GPS multibanda completos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Esse não é o modelo básico?” Qual resposta segue a ficha?",
    "explanation": "É o mais acessível da linha nova, mas traz métricas que só apareciam em Forerunners bem mais caros.",
    "active": true,
    "alternatives": [
     {
      "body": "Já vem com Prontidão e Status, antes só em modelos caros",
      "is_correct": true
     },
     {
      "body": "É o básico, então vale mostrar logo o Forerunner 170",
      "is_correct": false
     },
     {
      "body": "É básico, mas tem a maior bateria da linha Forerunner",
      "is_correct": false
     },
     {
      "body": "Não, é o topo de linha da nova geração Forerunner",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer pagar por aproximação com o relógio. O que fazer?",
    "explanation": "Na faixa de entrada nova, o Garmin Pay é exclusivo do Forerunner 170.",
    "active": true,
    "alternatives": [
     {
      "body": "Indicar o 70, que tem Garmin Pay",
      "is_correct": false
     },
     {
      "body": "Dizer que nenhum Forerunner tem",
      "is_correct": false
     },
     {
      "body": "Indicar o 55, que é mais barato",
      "is_correct": false
     },
     {
      "body": "Indicar o 170, que tem Garmin Pay",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente nunca correu. Qual recurso do Forerunner 70 você destaca?",
    "explanation": "O Garmin Coach com run/walk monta um plano progressivo para chegar aos 5 km.",
    "active": true,
    "alternatives": [
     {
      "body": "Potência de corrida para treinar por watts",
      "is_correct": false
     },
     {
      "body": "Status de Treino para ajustar a carga semanal",
      "is_correct": false
     },
     {
      "body": "Garmin Coach com opção de corrida e caminhada",
      "is_correct": true
     },
     {
      "body": "Navegação por mapas em percursos novos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Forerunner 70 é indicado para natação?",
    "explanation": "É 5 ATM, mas o modo dedicado de natação em águas abertas é exclusivo do 170.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, com modo de águas abertas incluído",
      "is_correct": false
     },
     {
      "body": "Sim, 5 ATM, mas sem modo de águas abertas",
      "is_correct": true
     },
     {
      "body": "Não, ele só resiste a respingos e chuva",
      "is_correct": false
     },
     {
      "body": "Sim, até 100 metros de profundidade",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como o Forerunner 70 mede potência e dinâmica de corrida?",
    "explanation": "Potência e dinâmica (cadência e tempo de contato) são estimadas direto no pulso.",
    "active": true,
    "alternatives": [
     {
      "body": "Direto no sensor de pulso, sem cinta",
      "is_correct": true
     },
     {
      "body": "Só com a cinta HRM 600 pareada",
      "is_correct": false
     },
     {
      "body": "Com um pod preso ao cadarço do tênis",
      "is_correct": false
     },
     {
      "body": "Só com a HRM 200 pareada ao relógio",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "forerunner-165",
  "quiz_id": "ed9acab3-5f55-409c-9a43-5aa8841891c5",
  "questions": [
   {
    "body": "Qual é a autonomia do Forerunner 165?",
    "explanation": "Até 11 dias no modo smartwatch e até 19 h só com GPS.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 13 dias no smartwatch e 23 h de GPS",
      "is_correct": false
     },
     {
      "body": "Até 14 dias no smartwatch e 20 h de GPS",
      "is_correct": false
     },
     {
      "body": "Até 11 dias no smartwatch e 19 h de GPS",
      "is_correct": true
     },
     {
      "body": "Até 7 dias no smartwatch e 24 h de GPS",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como o cliente tem música no Forerunner 165?",
    "explanation": "O armazenamento de música, de até 4 GB, está na versão Forerunner 165 Music.",
    "active": true,
    "alternatives": [
     {
      "body": "Em todas as versões, com até 8 GB",
      "is_correct": false
     },
     {
      "body": "Na versão 165 Music, com até 4 GB",
      "is_correct": true
     },
     {
      "body": "Só pelo celular, sem guardar no relógio",
      "is_correct": false
     },
     {
      "body": "Na versão 165 Music, com até 32 GB",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Forerunner 165 tem Garmin Pay?",
    "explanation": "Sim. O 165 tem Garmin Pay, um dos argumentos para quem quer treinar sem carteira.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, tem Garmin Pay",
      "is_correct": true
     },
     {
      "body": "Só na versão Music",
      "is_correct": false
     },
     {
      "body": "Não, só a partir do 170",
      "is_correct": false
     },
     {
      "body": "Não, só a partir do 265",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Forerunner 170 adiciona em relação ao 165?",
    "explanation": "O 170 soma Prontidão e Status de Treino, barômetro, bússola, giroscópio, termômetro e potência de ciclismo. Garmin Pay, águas abertas e potência no pulso os dois têm.",
    "active": true,
    "alternatives": [
     {
      "body": "Garmin Pay e natação em águas abertas",
      "is_correct": false
     },
     {
      "body": "Uma tela AMOLED maior e mais brilhante",
      "is_correct": false
     },
     {
      "body": "Potência de corrida medida no pulso",
      "is_correct": false
     },
     {
      "body": "Prontidão de Treino e barômetro",
      "is_correct": true
     }
    ]
   },
   {
    "body": "A tela do Forerunner 170 é diferente da do 165?",
    "explanation": "O 170 herda a tela AMOLED de 1,2\" e o sensor Elevate Gen 4 do 165. A diferença está no software e nos sensores extras.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, o 170 tem AMOLED de 1,3\"",
      "is_correct": false
     },
     {
      "body": "Sim, o 165 usa uma tela MIP",
      "is_correct": false
     },
     {
      "body": "Não, é a mesma AMOLED de 1,2\"",
      "is_correct": true
     },
     {
      "body": "Sim, só o 170 é touchscreen",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Forerunner 165 precisa de acessório para medir dinâmica de corrida?",
    "explanation": "Diferente do antigo 245, que exigia pod ou cinta, o 165 mede a dinâmica direto no sensor de pulso.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, um pod preso ao tênis",
      "is_correct": false
     },
     {
      "body": "Não, ele mede tudo no pulso",
      "is_correct": true
     },
     {
      "body": "Sim, a cinta HRM 600",
      "is_correct": false
     },
     {
      "body": "Só para o tempo de contato",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como a bateria do 165 se compara à do Forerunner 245, que ele substituiu?",
    "explanation": "Smartwatch: 11 dias contra 7. Só GPS: 19 h contra 24 h, porque a AMOLED gasta mais. Vale ser transparente.",
    "active": true,
    "alternatives": [
     {
      "body": "Mais dias no smartwatch, menos horas de GPS",
      "is_correct": true
     },
     {
      "body": "Mais dias no smartwatch e mais horas de GPS",
      "is_correct": false
     },
     {
      "body": "Menos dias no smartwatch, mais horas de GPS",
      "is_correct": false
     },
     {
      "body": "É igual nos dois modos de uso do relógio",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente faz provas longas. O que mencionar sobre a bateria do 165?",
    "explanation": "Em treinos longos só com GPS, a bateria dura um pouco menos que modelos antigos por causa da AMOLED. No dia a dia, dura mais.",
    "active": true,
    "alternatives": [
     {
      "body": "Dura mais que qualquer Forerunner só com GPS",
      "is_correct": false
     },
     {
      "body": "Não precisa recarregar em nenhuma prova longa",
      "is_correct": false
     },
     {
      "body": "A tela AMOLED economiza bateria no modo GPS",
      "is_correct": false
     },
     {
      "body": "Em GPS puro, dura menos que modelos MIP antigos",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente quer visual AMOLED sem pagar o topo de linha e valoriza pagar com o pulso. Qual modelo?",
    "explanation": "O 165 junta AMOLED touchscreen e Garmin Pay. O 70 tem AMOLED, mas sem Garmin Pay.",
    "active": true,
    "alternatives": [
     {
      "body": "Forerunner 70",
      "is_correct": false
     },
     {
      "body": "Forerunner 55",
      "is_correct": false
     },
     {
      "body": "Forerunner 165",
      "is_correct": true
     },
     {
      "body": "Forerunner 970",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual recurso de treino o 165 oferece para quem prepara uma meia maratona?",
    "explanation": "O 165 traz planos de treino adaptativos com previsão de tempo de prova. Prontidão de Treino só chegou com o 170.",
    "active": true,
    "alternatives": [
     {
      "body": "Prontidão de Treino com aviso diário de descanso",
      "is_correct": false
     },
     {
      "body": "Planos adaptativos com previsão de tempo de prova",
      "is_correct": true
     },
     {
      "body": "PacePro com os mapas da prova já embarcados",
      "is_correct": false
     },
     {
      "body": "Status de Treino com carga aguda e crônica",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "forerunner-170",
  "quiz_id": "27c4171b-0e97-4170-8aed-df77e369684f",
  "questions": [
   {
    "body": "Qual é a autonomia do Forerunner 170?",
    "explanation": "Até 10 dias no modo smartwatch (19 em economia), 20 h só com GPS e 14 h com todos os sistemas.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 13 dias no smartwatch e 23 h de GPS",
      "is_correct": false
     },
     {
      "body": "Até 11 dias no smartwatch e 19 h de GPS",
      "is_correct": false
     },
     {
      "body": "Até 14 dias no smartwatch e 20 h de GPS",
      "is_correct": false
     },
     {
      "body": "Até 10 dias no smartwatch e 20 h de GPS",
      "is_correct": true
     }
    ]
   },
   {
    "body": "No Forerunner 170 Music, quanto dura o GPS ouvindo música?",
    "explanation": "Com música, o GPS dura até 7,5 h, e todos os sistemas, até 6,5 h.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 20 h",
      "is_correct": false
     },
     {
      "body": "Até 14 h",
      "is_correct": false
     },
     {
      "body": "Até 7,5 h",
      "is_correct": true
     },
     {
      "body": "Até 3 h",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quais serviços de música o Forerunner 170 Music aceita?",
    "explanation": "O 170 Music baixa playlists do Spotify, Amazon Music ou Deezer e toca em fones sem fio.",
    "active": true,
    "alternatives": [
     {
      "body": "Spotify, Apple Music e YouTube Music",
      "is_correct": false
     },
     {
      "body": "Spotify, Amazon Music e Deezer",
      "is_correct": true
     },
     {
      "body": "Só Spotify, com plano Premium",
      "is_correct": false
     },
     {
      "body": "Deezer, Tidal e Apple Music",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quais sensores o Forerunner 170 tem e o 70 não tem?",
    "explanation": "O 170 soma altímetro barométrico, bússola, giroscópio e termômetro, úteis em navegação e métricas ambientais.",
    "active": true,
    "alternatives": [
     {
      "body": "Barômetro, bússola, giroscópio e termômetro",
      "is_correct": true
     },
     {
      "body": "ECG, lanterna e sensor de temperatura de pele",
      "is_correct": false
     },
     {
      "body": "Oxímetro, ECG e sensor de profundidade",
      "is_correct": false
     },
     {
      "body": "Bússola, lanterna, ECG e sensor solar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente corre, pedala e quer estrear em águas abertas, sem pagar o topo de linha. O que indicar?",
    "explanation": "O 170 cobre os três esportes com potência de ciclismo e modo de águas abertas, sem precisar do 970.",
    "active": true,
    "alternatives": [
     {
      "body": "Forerunner 70",
      "is_correct": false
     },
     {
      "body": "Forerunner 165",
      "is_correct": false
     },
     {
      "body": "Forerunner 970",
      "is_correct": false
     },
     {
      "body": "Forerunner 170",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que o Forerunner 970 adiciona em relação ao 170?",
    "explanation": "O 970 é o topo: mapa colorido com navegação, ECG, lanterna, titânio/safira e compatibilidade com a HRM 600.",
    "active": true,
    "alternatives": [
     {
      "body": "Garmin Pay e natação em águas abertas",
      "is_correct": false
     },
     {
      "body": "Prontidão de Treino e Status de Treino",
      "is_correct": false
     },
     {
      "body": "Mapas coloridos, ECG, lanterna e titânio",
      "is_correct": true
     },
     {
      "body": "Potência de ciclismo e Cycling Coach",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente sempre treina com o celular no bolso. Ele precisa da versão Music?",
    "explanation": "A versão Music só vale para quem quer ouvir música no relógio sem o celular.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, só a Music tem Garmin Pay",
      "is_correct": false
     },
     {
      "body": "Não, a versão sem música já resolve",
      "is_correct": true
     },
     {
      "body": "Sim, só a Music tem Prontidão",
      "is_correct": false
     },
     {
      "body": "Sim, a Music tem bateria maior",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quando vale pagar mais pelo 170 em vez do 70?",
    "explanation": "Prontidão, Status, AMOLED e potência de corrida os dois têm. O 170 vale pelos recursos extras.",
    "active": true,
    "alternatives": [
     {
      "body": "Se usar Garmin Pay, potência de bike ou águas abertas",
      "is_correct": true
     },
     {
      "body": "Se quiser Prontidão de Treino e Status de Treino",
      "is_correct": false
     },
     {
      "body": "Se quiser tela AMOLED com touchscreen e botões",
      "is_correct": false
     },
     {
      "body": "Se quiser potência de corrida medida no pulso",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como começar a venda do Forerunner 170?",
    "explanation": "Nunca comece comparando com o 70. Puxe essa comparação só se o cliente perguntar.",
    "active": true,
    "alternatives": [
     {
      "body": "Comparando logo de cara com o Forerunner 70",
      "is_correct": false
     },
     {
      "body": "Pela lista completa de sensores do relógio",
      "is_correct": false
     },
     {
      "body": "Pelo preço em comparação com o Forerunner 970",
      "is_correct": false
     },
     {
      "body": "Pela necessidade multiesporte ou pelo Garmin Pay",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que o Forerunner 170 oferece para quem também pedala?",
    "explanation": "O 170 conecta com medidor de potência ou rolo inteligente, com o Cycling Coach guiando o treino.",
    "active": true,
    "alternatives": [
     {
      "body": "Mapas coloridos com rotas de ciclismo",
      "is_correct": false
     },
     {
      "body": "Radar traseiro integrado ao relógio",
      "is_correct": false
     },
     {
      "body": "Medidor de potência e Garmin Cycling Coach",
      "is_correct": true
     },
     {
      "body": "Modo Edge com tela maior no guidão",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "forerunner-570",
  "quiz_id": "cbcac118-7987-4e1e-8ddb-9202f7e280c1",
  "questions": [
   {
    "body": "Em quais tamanhos de caixa o Forerunner 570 existe?",
    "explanation": "O 570 vem em 42 e 47 mm com bisel de alumínio. O 970 só existe em 47 mm, com titânio e safira.",
    "active": true,
    "alternatives": [
     {
      "body": "42 mm e 47 mm, com bisel de alumínio",
      "is_correct": true
     },
     {
      "body": "Só 47 mm, com bisel de titânio",
      "is_correct": false
     },
     {
      "body": "43, 47 e 51 mm, com lente de safira",
      "is_correct": false
     },
     {
      "body": "42 mm e 47 mm, com bisel de titânio",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a autonomia do Forerunner 570 no modo smartwatch?",
    "explanation": "Até 11 dias na caixa de 47 mm e 10 dias na de 42 mm. Só GPS: até 18 h.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 15 dias nas duas caixas",
      "is_correct": false
     },
     {
      "body": "Até 13 dias (47 mm) ou 11 dias (42 mm)",
      "is_correct": false
     },
     {
      "body": "Até 10 dias (47 mm) ou 8 dias (42 mm)",
      "is_correct": false
     },
     {
      "body": "Até 11 dias (47 mm) ou 10 dias (42 mm)",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é o armazenamento de música do Forerunner 570?",
    "explanation": "Até 8 GB para Spotify, Deezer ou Amazon Music. O 970 tem 32 GB.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 32 GB, com Spotify, Deezer e Amazon",
      "is_correct": false
     },
     {
      "body": "Até 4 GB, só com Spotify Premium",
      "is_correct": false
     },
     {
      "body": "Até 8 GB, com Spotify, Deezer e Amazon",
      "is_correct": true
     },
     {
      "body": "Até 8 GB, com Apple Music e Spotify",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Relatório da Noite (Evening Report) mostra?",
    "explanation": "É exibido pouco antes de dormir. Sono da noite e HRV da madrugada aparecem no Relatório Matinal.",
    "active": true,
    "alternatives": [
     {
      "body": "O sono da noite anterior e o status de HRV da madrugada",
      "is_correct": false
     },
     {
      "body": "Body Battery, treino e tempo de amanhã e o Sleep Coach",
      "is_correct": true
     },
     {
      "body": "O resumo de calorias e passos do dia inteiro",
      "is_correct": false
     },
     {
      "body": "A carga aguda e a previsão do tempo de prova",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como funciona o Alarme Inteligente (Smart Wake)?",
    "explanation": "O aviso suave pode vir até 30 minutos antes. O alarme principal sempre toca no horário marcado.",
    "active": true,
    "alternatives": [
     {
      "body": "Desperta suave até 30 min antes, no melhor momento",
      "is_correct": true
     },
     {
      "body": "Adia o alarme até o fim do ciclo de sono atual",
      "is_correct": false
     },
     {
      "body": "Toca só quando o Body Battery estiver recuperado",
      "is_correct": false
     },
     {
      "body": "Desperta 1 hora antes se o sono estiver profundo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o 570 trouxe que o Forerunner 265 não tinha?",
    "explanation": "Ligações e assistente de voz, Relatório da Noite, Smart Wake, temperatura de pele e Triathlon Coach. AMOLED, multibanda e música já vinham do 265.",
    "active": true,
    "alternatives": [
     {
      "body": "Tela AMOLED e GPS multibanda com SatIQ",
      "is_correct": false
     },
     {
      "body": "Armazenamento de música e PacePro",
      "is_correct": false
     },
     {
      "body": "Body Battery e monitoramento de sono",
      "is_correct": false
     },
     {
      "body": "Alto-falante, microfone e sensor de pele",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Quando vender o Forerunner 570 em vez do 970?",
    "explanation": "O 570 entrega quase a mesma experiência de treino por menos, e ainda tem a caixa de 42 mm.",
    "active": true,
    "alternatives": [
     {
      "body": "Cliente que treina em trilha sem sinal de celular",
      "is_correct": false
     },
     {
      "body": "Cliente que quer acompanhar a saúde cardíaca com ECG",
      "is_correct": false
     },
     {
      "body": "Cliente sensível a preço, sem uso de mapa, lanterna ou ECG",
      "is_correct": true
     },
     {
      "body": "Cliente que treina de madrugada e quer lanterna",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Tá caro pra um relógio.” Qual resposta segue a ficha?",
    "explanation": "GPS, monitor cardíaco, treinador e música offline num aparelho só, com bateria de até 11 dias.",
    "active": true,
    "alternatives": [
     {
      "body": "Oferecer desconto para igualar a um modelo de entrada",
      "is_correct": false
     },
     {
      "body": "Mostrar que ele substitui GPS, cardíaco, treinador e música",
      "is_correct": true
     },
     {
      "body": "Avisar que o preço vai subir no mês que vem",
      "is_correct": false
     },
     {
      "body": "Indicar o 970, que tem mais recursos pelo mesmo preço",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Dá para usar a cinta HRM 600 no Forerunner 570?",
    "explanation": "A compatibilidade oficial confirmada é só com o Forerunner 970.",
    "active": true,
    "alternatives": [
     {
      "body": "Não há confirmação oficial; só no 970",
      "is_correct": true
     },
     {
      "body": "Sim, com todas as métricas da cinta",
      "is_correct": false
     },
     {
      "body": "Sim, mas só para frequência cardíaca",
      "is_correct": false
     },
     {
      "body": "Sim, depois de atualizar o software",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como abrir a venda do Forerunner 570 para quem já treina?",
    "explanation": "A rotina de treino personaliza todo o pitch. Os diferenciais vêm antes do preço.",
    "active": true,
    "alternatives": [
     {
      "body": "Listar todos os sensores logo de início",
      "is_correct": false
     },
     {
      "body": "Comparar logo de cara com o Forerunner 970",
      "is_correct": false
     },
     {
      "body": "Começar pelo preço e pelo parcelamento",
      "is_correct": false
     },
     {
      "body": "Deixar o cliente contar a rotina antes das specs",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "forerunner-970",
  "quiz_id": "9649f41c-b9b2-48be-9dc9-91373850ae3d",
  "questions": [
   {
    "body": "Como é a construção do Forerunner 970?",
    "explanation": "O 970 só existe em 47 mm, com bisel de titânio e lente de safira.",
    "active": true,
    "alternatives": [
     {
      "body": "42 e 47 mm, com alumínio e vidro",
      "is_correct": false
     },
     {
      "body": "Só 47 mm, com titânio e safira",
      "is_correct": true
     },
     {
      "body": "43, 47 e 51 mm, com titânio",
      "is_correct": false
     },
     {
      "body": "47 e 51 mm, com alumínio e safira",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a autonomia do Forerunner 970?",
    "explanation": "Até 15 dias no modo smartwatch, 26 h só com GPS e 21 h com todos os sistemas e multibanda.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 15 dias no smartwatch e 26 h de GPS",
      "is_correct": true
     },
     {
      "body": "Até 11 dias no smartwatch e 18 h de GPS",
      "is_correct": false
     },
     {
      "body": "Até 13 dias no smartwatch e 23 h de GPS",
      "is_correct": false
     },
     {
      "body": "Até 20 dias no smartwatch e 30 h de GPS",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quanto armazenamento de música o Forerunner 970 tem?",
    "explanation": "Até 32 GB, quatro vezes os 8 GB do Forerunner 570.",
    "active": true,
    "alternatives": [
     {
      "body": "8 GB",
      "is_correct": false
     },
     {
      "body": "16 GB",
      "is_correct": false
     },
     {
      "body": "64 GB",
      "is_correct": false
     },
     {
      "body": "32 GB",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como apresentar o app de ECG do Forerunner 970?",
    "explanation": "O ECG detecta sinais de fibrilação atrial e ritmo sinusal normal, mas é ferramenta de monitoramento, não diagnóstico.",
    "active": true,
    "alternatives": [
     {
      "body": "Como diagnóstico que dispensa o cardiologista",
      "is_correct": false
     },
     {
      "body": "Como exame que substitui o eletrocardiograma",
      "is_correct": false
     },
     {
      "body": "Como monitoramento, sem substituir exame médico",
      "is_correct": true
     },
     {
      "body": "Como recurso que previne problemas cardíacos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que a Economia de Corrida do 970 exige?",
    "explanation": "Economia de Corrida e Perda de Velocidade do Passo exigem a HRM 600, vendida separadamente.",
    "active": true,
    "alternatives": [
     {
      "body": "A cinta HRM 200 pareada",
      "is_correct": false
     },
     {
      "body": "A cinta HRM 600 pareada",
      "is_correct": true
     },
     {
      "body": "Só o sensor de pulso",
      "is_correct": false
     },
     {
      "body": "Um pod preso ao tênis",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que é novo no 970 em relação ao Forerunner 965?",
    "explanation": "Titânio, mapa colorido, multibanda, PacePro e música já vinham do 965.",
    "active": true,
    "alternatives": [
     {
      "body": "Safira, ECG, lanterna e alto-falante",
      "is_correct": true
     },
     {
      "body": "Bisel de titânio e mapa colorido",
      "is_correct": false
     },
     {
      "body": "GPS multibanda e o PacePro",
      "is_correct": false
     },
     {
      "body": "Armazenamento de música e Coach",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quando vender o Forerunner 970 em vez do 570?",
    "explanation": "Mapa e navegação, lanterna, ECG ou a decisão já tomada pelo topo de linha.",
    "active": true,
    "alternatives": [
     {
      "body": "Cliente sensível a preço que só corre na rua",
      "is_correct": false
     },
     {
      "body": "Cliente que prefere a caixa menor, de 42 mm",
      "is_correct": false
     },
     {
      "body": "Cliente que só quer Prontidão de Treino e VO2",
      "is_correct": false
     },
     {
      "body": "Trilha sem sinal, treino no escuro ou ECG",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “Eu não uso mapa nem lanterna, não preciso do 970.” O que fazer?",
    "explanation": "Nesse caso o 570 entrega a mesma experiência de treino. O 970 só vale se algum recurso exclusivo importar para ele.",
    "active": true,
    "alternatives": [
     {
      "body": "Insistir, porque o 970 tem mais bateria",
      "is_correct": false
     },
     {
      "body": "Dizer que ele vai precisar de mapa no futuro",
      "is_correct": false
     },
     {
      "body": "Concordar: o 570 entrega o treino por menos",
      "is_correct": true
     },
     {
      "body": "Explicar que o 570 não tem Prontidão de Treino",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que mede a Perda de Velocidade do Passo?",
    "explanation": "É a diferença entre a velocidade no primeiro contato e a mínima na fase de apoio, em cm/s. Quanto menor, melhor.",
    "active": true,
    "alternatives": [
     {
      "body": "Quanto o pace cai no fim da prova",
      "is_correct": false
     },
     {
      "body": "Quanto ele desacelera ao tocar o solo",
      "is_correct": true
     },
     {
      "body": "Quanto oxigênio o corpo gasta por km",
      "is_correct": false
     },
     {
      "body": "Quanto impacto as pernas acumulam",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente sai para correr às 5h, ainda no escuro. Qual recurso do 970 você destaca?",
    "explanation": "A lanterna integrada, exclusiva do 970 nesta linha, resolve sem carregar equipamento extra.",
    "active": true,
    "alternatives": [
     {
      "body": "Lanterna LED branca e vermelha",
      "is_correct": true
     },
     {
      "body": "Tela AMOLED em modo noturno",
      "is_correct": false
     },
     {
      "body": "Mapa colorido com rota salva",
      "is_correct": false
     },
     {
      "body": "Alarme Inteligente antes do treino",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "venu-3",
  "quiz_id": "a83df0f5-096a-43d8-b3e9-034e10bdb2f2",
  "questions": [
   {
    "body": "Qual é a bateria do Venu 3 e do Venu 3S no modo smartwatch?",
    "explanation": "O Venu 3 chega a 14 dias e o 3S, a 10 dias.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 12 dias (Venu 3) e 10 dias (3S)",
      "is_correct": false
     },
     {
      "body": "Até 11 dias nas duas versões",
      "is_correct": false
     },
     {
      "body": "Até 14 dias (Venu 3) e 10 dias (3S)",
      "is_correct": true
     },
     {
      "body": "Até 14 dias nas duas versões",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Venu 3 trouxe de fábrica que, no Venu 2, só existia numa versão à parte?",
    "explanation": "No Venu 2, ligação pelo relógio só existia no Venu 2 Plus. No Venu 3, já vem de fábrica.",
    "active": true,
    "alternatives": [
     {
      "body": "Garmin Pay no relógio",
      "is_correct": false
     },
     {
      "body": "Alto-falante e microfone",
      "is_correct": true
     },
     {
      "body": "Música offline no relógio",
      "is_correct": false
     },
     {
      "body": "Tela AMOLED colorida",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Modo Cadeira de Rodas do Venu 3 oferece?",
    "explanation": "Rastreia impulsos, avisa mudança de peso e traz apps e treinos específicos para cadeirantes.",
    "active": true,
    "alternatives": [
     {
      "body": "Impulsos, alerta de peso e treinos",
      "is_correct": true
     },
     {
      "body": "Navegação por rotas acessíveis na cidade",
      "is_correct": false
     },
     {
      "body": "Detecção automática de rampas e escadas",
      "is_correct": false
     },
     {
      "body": "Mostrador ampliado com letras maiores",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Venu 3 tem Prontidão de Treino?",
    "explanation": "O Venu 3 foca em saúde e bem-estar, sem métricas avançadas de treino como a Prontidão.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, igual à do Forerunner 570",
      "is_correct": false
     },
     {
      "body": "Só na versão menor, o Venu 3S",
      "is_correct": false
     },
     {
      "body": "Sim, liberada por atualização",
      "is_correct": false
     },
     {
      "body": "Não, é recurso da linha Forerunner",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que o Venu 3 tem a mais que o Venu 4?",
    "explanation": "O Venu 4 soma lanterna, ECG, Health Status e multibanda, mas dura 2 dias a menos.",
    "active": true,
    "alternatives": [
     {
      "body": "Lanterna de LED integrada",
      "is_correct": false
     },
     {
      "body": "App de ECG e Health Status",
      "is_correct": false
     },
     {
      "body": "14 dias de bateria, contra 12",
      "is_correct": true
     },
     {
      "body": "GPS multibanda com SatIQ",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quais recursos de sono o Venu 3 trouxe como novidade?",
    "explanation": "Sleep Coach, detecção de soneca e Relatório Matinal. As outras opções são do Venu 4 e do Forerunner 570.",
    "active": true,
    "alternatives": [
     {
      "body": "Sleep Alignment e Sleep Consistency",
      "is_correct": false
     },
     {
      "body": "Sleep Coach, soneca e Relatório Matinal",
      "is_correct": true
     },
     {
      "body": "Smart Wake e Relatório da Noite",
      "is_correct": false
     },
     {
      "body": "Health Status e Lifestyle Logging",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como abrir a venda do Venu 3?",
    "explanation": "Se a resposta for treino avançado, o Venu não é o produto certo: puxe para a linha Forerunner.",
    "active": true,
    "alternatives": [
     {
      "body": "Perguntando se o foco é bem-estar ou treino",
      "is_correct": true
     },
     {
      "body": "Mostrando as métricas avançadas de corrida",
      "is_correct": false
     },
     {
      "body": "Comparando de cara com o Forerunner 570",
      "is_correct": false
     },
     {
      "body": "Começando pelo preço e pelo parcelamento",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Esse aqui serve pra corrida também?” Qual resposta segue a ficha?",
    "explanation": "Tem GPS e VO2 Max para corridas casuais, mas sem Prontidão, potência no pulso nem multibanda.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, tem as mesmas métricas do Forerunner 570",
      "is_correct": false
     },
     {
      "body": "Não, ele não tem GPS para registrar a corrida",
      "is_correct": false
     },
     {
      "body": "Sim, tem GPS multibanda e potência de corrida",
      "is_correct": false
     },
     {
      "body": "Para corridas casuais; para treino sério, Forerunner",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é a diferença entre o Venu 3 e o Venu 3S?",
    "explanation": "Muda a caixa (45 mm no Venu 3), as cores e a bateria: 14 dias contra 10 do 3S.",
    "active": true,
    "alternatives": [
     {
      "body": "Só o 3S tem alto-falante e microfone",
      "is_correct": false
     },
     {
      "body": "Só o Venu 3 tem Garmin Pay no relógio",
      "is_correct": false
     },
     {
      "body": "Tamanho da caixa, cores e um pouco de bateria",
      "is_correct": true
     },
     {
      "body": "O 3S tem tela MIP e o Venu 3, AMOLED",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quais treinos o Venu 3 traz animados na tela?",
    "explanation": "Treinos pré-carregados de força, HIIT, Pilates e yoga com animação, mais de 1.600 exercícios no Garmin Connect.",
    "active": true,
    "alternatives": [
     {
      "body": "Águas abertas e triathlon",
      "is_correct": false
     },
     {
      "body": "Força, HIIT, Pilates e yoga",
      "is_correct": true
     },
     {
      "body": "Corrida com PacePro e ClimbPro",
      "is_correct": false
     },
     {
      "body": "Mergulho livre e apneia",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "venu-4",
  "quiz_id": "c2bdc72e-0f19-45cd-9cc5-f052d0f56413",
  "questions": [
   {
    "body": "Qual é a bateria do Venu 4 no modo smartwatch?",
    "explanation": "Até 12 dias, um pouco menos que os 14 do Venu 3, por causa dos novos sensores.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 14 dias",
      "is_correct": false
     },
     {
      "body": "Até 11 dias",
      "is_correct": false
     },
     {
      "body": "Até 15 dias",
      "is_correct": false
     },
     {
      "body": "Até 12 dias",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Quantos botões físicos o Venu 4 tem?",
    "explanation": "Ação no topo e Voltar/Lanterna embaixo, um a menos que os 3 do Venu 3. A navegação é principalmente por toque.",
    "active": true,
    "alternatives": [
     {
      "body": "3 botões",
      "is_correct": false
     },
     {
      "body": "5 botões",
      "is_correct": false
     },
     {
      "body": "2 botões",
      "is_correct": true
     },
     {
      "body": "Nenhum",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Venu 4 tem GPS multibanda?",
    "explanation": "O Venu 4 capta L1+L5, com o SatIQ escolhendo o melhor modo conforme o ambiente.",
    "active": true,
    "alternatives": [
     {
      "body": "Não, só a linha Forerunner tem",
      "is_correct": false
     },
     {
      "body": "Sim, L1+L5 com SatIQ",
      "is_correct": true
     },
     {
      "body": "Só na caixa de 45 mm",
      "is_correct": false
     },
     {
      "body": "Sim, mas sem o SatIQ",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como posicionar o Health Status do Venu 4?",
    "explanation": "Acompanha tendências de FC, HRV, respiração, temperatura e Pulse Ox no sono e avisa desvios. Está em beta.",
    "active": true,
    "alternatives": [
     {
      "body": "Tendências em beta, sem diagnóstico",
      "is_correct": true
     },
     {
      "body": "Diagnóstico completo de saúde durante o sono",
      "is_correct": false
     },
     {
      "body": "Alerta médico que substitui as consultas",
      "is_correct": false
     },
     {
      "body": "Exame cardíaco equivalente ao app de ECG",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer saber se o café da tarde afeta o sono dele. Qual recurso mostra isso?",
    "explanation": "O Lifestyle Logging registra hábitos como cafeína e álcool e mostra o impacto no sono, no estresse e na HRV.",
    "active": true,
    "alternatives": [
     {
      "body": "Sleep Coach diário",
      "is_correct": false
     },
     {
      "body": "Health Status beta",
      "is_correct": false
     },
     {
      "body": "Body Battery 24h",
      "is_correct": false
     },
     {
      "body": "Lifestyle Logging",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente tem baixa visão. Qual recurso do Venu 4 ajuda mais?",
    "explanation": "A Tela Falada anuncia hora, dados de saúde e alertas. Os filtros de cor são para daltonismo.",
    "active": true,
    "alternatives": [
     {
      "body": "Filtros de cor",
      "is_correct": false
     },
     {
      "body": "Modo cadeira de rodas",
      "is_correct": false
     },
     {
      "body": "Tela Falada",
      "is_correct": true
     },
     {
      "body": "Lanterna de LED",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Em quais tamanhos de caixa o Venu 4 existe?",
    "explanation": "41 e 45 mm, com pulseiras de couro ou silicone trocáveis.",
    "active": true,
    "alternatives": [
     {
      "body": "Só 42 mm",
      "is_correct": false
     },
     {
      "body": "41 mm e 45 mm",
      "is_correct": true
     },
     {
      "body": "42 mm e 47 mm",
      "is_correct": false
     },
     {
      "body": "43, 47 e 51 mm",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Venu 4 adiciona em relação ao Venu 3?",
    "explanation": "Alto-falante, Sleep Coach, Body Battery, Garmin Pay e 5 ATM já vinham do Venu 3.",
    "active": true,
    "alternatives": [
     {
      "body": "Lanterna, ECG, Health Status e multibanda",
      "is_correct": true
     },
     {
      "body": "Alto-falante, microfone e Sleep Coach",
      "is_correct": false
     },
     {
      "body": "Body Battery, Garmin Pay e 5 ATM",
      "is_correct": false
     },
     {
      "body": "Bateria maior e mais um botão físico",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente prefere controlar tudo por botão, inclusive de luva. O que fazer?",
    "explanation": "O Venu 4 tem só 2 botões e navega principalmente por toque. Para controle total por botão, Forerunner ou Fenix.",
    "active": true,
    "alternatives": [
     {
      "body": "Indicar o Venu 4, que é touch-first",
      "is_correct": false
     },
     {
      "body": "Indicar o Venu 4 com a Tela Falada",
      "is_correct": false
     },
     {
      "body": "Indicar o Venu 4 com pulseira de couro",
      "is_correct": false
     },
     {
      "body": "Considerar um Forerunner ou Fenix",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente treina sério, mas prefere um relógio de visual casual. Qual faz sentido?",
    "explanation": "O Venu 4 tem Prontidão, Status, Running Dynamics, VO2 Max e Previsão de Corrida num perfil lifestyle.",
    "active": true,
    "alternatives": [
     {
      "body": "Venu 3, com Prontidão de Treino completa",
      "is_correct": false
     },
     {
      "body": "Vivoactive 6, com Previsão de Corrida",
      "is_correct": false
     },
     {
      "body": "Venu 4, com métricas perto do Forerunner 570",
      "is_correct": true
     },
     {
      "body": "Venu 3S, com GPS multibanda e potência",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "vivoactive-6",
  "quiz_id": "71263879-4f7d-4a4c-b807-ca6fcca7a05c",
  "questions": [
   {
    "body": "Como é a caixa do Vivoactive 6?",
    "explanation": "Caixa única de 42 mm, bisel de alumínio e pulseira de silicone.",
    "active": true,
    "alternatives": [
     {
      "body": "Caixa única de 42 mm, em alumínio",
      "is_correct": true
     },
     {
      "body": "Duas caixas, de 41 mm e 45 mm",
      "is_correct": false
     },
     {
      "body": "Duas caixas, de 42 mm e 47 mm",
      "is_correct": false
     },
     {
      "body": "Caixa única de 45 mm, em aço",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a autonomia do Vivoactive 6?",
    "explanation": "Até 11 dias no smartwatch, 21 dias em economia e 21 h só com GPS.",
    "active": true,
    "alternatives": [
     {
      "body": "12 dias, 28 em economia e 23 h de GPS",
      "is_correct": false
     },
     {
      "body": "14 dias, 20 em economia e 20 h de GPS",
      "is_correct": false
     },
     {
      "body": "10 dias, 19 em economia e 20 h de GPS",
      "is_correct": false
     },
     {
      "body": "11 dias, 21 em economia e 21 h de GPS",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Quantos apps esportivos o Vivoactive 6 traz pré-carregados?",
    "explanation": "Mais de 80, contra mais de 30 no Vivoactive 5.",
    "active": true,
    "alternatives": [
     {
      "body": "Mais de 30",
      "is_correct": false
     },
     {
      "body": "Mais de 25",
      "is_correct": false
     },
     {
      "body": "Mais de 80",
      "is_correct": true
     },
     {
      "body": "Mais de 100",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que mudou do Vivoactive 5 para o 6?",
    "explanation": "Bateria e resistência não mudaram. Entraram mais apps, treinos prontos, métricas de corrida, PacePro e alarme inteligente.",
    "active": true,
    "alternatives": [
     {
      "body": "Bateria maior e resistência à água de 10 ATM",
      "is_correct": false
     },
     {
      "body": "Mais apps, treinos guiados prontos e PacePro",
      "is_correct": true
     },
     {
      "body": "ECG, lanterna e GPS multibanda com SatIQ",
      "is_correct": false
     },
     {
      "body": "Duas caixas e alto-falante com microfone",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que só o Venu 4 tem, quando comparado ao Vivoactive 6?",
    "explanation": "Garmin Pay, música, Body Battery, Sleep Coach, cadeira de rodas e 5 ATM o Vivoactive 6 também tem.",
    "active": true,
    "alternatives": [
     {
      "body": "Lanterna, ECG, multibanda e alto-falante",
      "is_correct": true
     },
     {
      "body": "Garmin Pay e download de música offline",
      "is_correct": false
     },
     {
      "body": "Body Battery, Sleep Coach e status de HRV",
      "is_correct": false
     },
     {
      "body": "Modo cadeira de rodas e resistência 5 ATM",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como é a bateria do Vivoactive 6 frente à do Venu 4?",
    "explanation": "Até 11 dias no Vivoactive 6 contra 12 no Venu 4, em modo smartwatch.",
    "active": true,
    "alternatives": [
     {
      "body": "O Vivoactive dura o dobro do Venu 4",
      "is_correct": false
     },
     {
      "body": "O Venu 4 dura o dobro do Vivoactive",
      "is_correct": false
     },
     {
      "body": "Os dois duram exatamente 14 dias",
      "is_correct": false
     },
     {
      "body": "Diferença pequena: 11 contra 12 dias",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O Vivoactive 6 tem app de ECG?",
    "explanation": "A Garmin não anunciou ECG no Vivoactive 6. Na linha lifestyle, ele é exclusivo do Venu 4.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, igual ao app do Venu 4",
      "is_correct": false
     },
     {
      "body": "Sim, por uma atualização futura",
      "is_correct": false
     },
     {
      "body": "Não, é exclusivo do Venu 4 na linha",
      "is_correct": true
     },
     {
      "body": "Só com uma cinta HRM pareada",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer o primeiro smartwatch, com AMOLED e saúde, gastando o mínimo. O que indicar?",
    "explanation": "O Vivoactive 6 é a porta de entrada AMOLED, com recursos essenciais por quase metade do preço do Venu 4.",
    "active": true,
    "alternatives": [
     {
      "body": "Venu 4",
      "is_correct": false
     },
     {
      "body": "Vivoactive 6",
      "is_correct": true
     },
     {
      "body": "Venu 3",
      "is_correct": false
     },
     {
      "body": "Forerunner 570",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o acompanhamento de saúde da mulher do Vivoactive 6 inclui?",
    "explanation": "O Vivoactive 6 acompanha ciclo menstrual e gravidez, junto com Body Battery, HRV e Sleep Coach.",
    "active": true,
    "alternatives": [
     {
      "body": "Ciclo menstrual e gravidez",
      "is_correct": true
     },
     {
      "body": "Só o ciclo menstrual",
      "is_correct": false
     },
     {
      "body": "Ciclo menstrual e ECG",
      "is_correct": false
     },
     {
      "body": "Gravidez e Health Status",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente não sabe montar rotina de treino sozinho. O que destacar no Vivoactive 6?",
    "explanation": "Treinos prontos de força, HIIT, yoga e Pilates, e o Garmin Coach ajustando o plano conforme desempenho e recuperação.",
    "active": true,
    "alternatives": [
     {
      "body": "Status de Treino e Prontidão de Treino",
      "is_correct": false
     },
     {
      "body": "PacePro com os mapas da prova salvos",
      "is_correct": false
     },
     {
      "body": "Health Status com alertas de desvio",
      "is_correct": false
     },
     {
      "body": "Treinos prontos e o Garmin Coach adaptativo",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "fenix-8",
  "quiz_id": "bf471697-34e2-49b3-b197-ed8cf359a200",
  "questions": [
   {
    "body": "Em quais tamanhos o Fenix 8 existe?",
    "explanation": "AMOLED em 43, 47 e 51 mm. A opção Solar existe no 47 e no 51 mm.",
    "active": true,
    "alternatives": [
     {
      "body": "AMOLED e Solar nos três: 43, 47 e 51 mm",
      "is_correct": false
     },
     {
      "body": "AMOLED em 43, 47 e 51 mm; Solar em 47 e 51 mm",
      "is_correct": true
     },
     {
      "body": "AMOLED em 47 e 51 mm; Solar só em 51 mm",
      "is_correct": false
     },
     {
      "body": "AMOLED só em 47 mm; Solar em 43 e 51 mm",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a bateria do Fenix 8 de 51 mm no modo smartwatch?",
    "explanation": "Até 29 dias no AMOLED e até 48 dias no Solar, com 3 h diárias ao ar livre.",
    "active": true,
    "alternatives": [
     {
      "body": "29 dias (AMOLED) ou 48 dias (Solar)",
      "is_correct": true
     },
     {
      "body": "15 dias (AMOLED) ou 29 dias (Solar)",
      "is_correct": false
     },
     {
      "body": "48 dias (AMOLED) ou 29 dias (Solar)",
      "is_correct": false
     },
     {
      "body": "21 dias (AMOLED) ou 35 dias (Solar)",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quais recursos de mergulho o Fenix 8 tem?",
    "explanation": "Case com classificação de 40 m, botões metálicos à prova de vazamento, apneia e scuba.",
    "active": true,
    "alternatives": [
     {
      "body": "10 ATM, só natação em piscina",
      "is_correct": false
     },
     {
      "body": "100 m, com mergulho técnico e ar",
      "is_correct": false
     },
     {
      "body": "5 ATM, sem modo de mergulho",
      "is_correct": false
     },
     {
      "body": "40 m, com apneia e scuba",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente faz mergulho técnico com integração de ar. O que indicar?",
    "explanation": "O Fenix 8 cobre mergulho recreativo e apneia. Integração de ar, SubWave e DiveView são do Descent Mk3i.",
    "active": true,
    "alternatives": [
     {
      "body": "Fenix 8, que já tem integração de ar",
      "is_correct": false
     },
     {
      "body": "Fenix 8 Pro, com o inReach embutido",
      "is_correct": false
     },
     {
      "body": "Descent Mk3i, mais especializado",
      "is_correct": true
     },
     {
      "body": "Instinct 3, com modo de mergulho",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como orientar a escolha entre Fenix 8 AMOLED e Solar?",
    "explanation": "AMOLED para quem prioriza visual e carrega com mais frequência. Solar para quem fica semanas longe da tomada.",
    "active": true,
    "alternatives": [
     {
      "body": "Solar pelo visual; AMOLED para expedições longas",
      "is_correct": false
     },
     {
      "body": "AMOLED pelo visual; Solar para expedições longas",
      "is_correct": true
     },
     {
      "body": "AMOLED sempre, porque dura mais que o Solar",
      "is_correct": false
     },
     {
      "body": "Solar só para quem nunca usa o GPS",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que é novo no Fenix 8 em relação ao Fenix 7?",
    "explanation": "Titânio, safira, multibanda, TopoActive, Body Battery, Garmin Pay e música já vinham do Fenix 7.",
    "active": true,
    "alternatives": [
     {
      "body": "AMOLED, alto-falante, mergulho e ECG",
      "is_correct": true
     },
     {
      "body": "Titânio, safira e GPS multibanda com L5",
      "is_correct": false
     },
     {
      "body": "Mapas TopoActive e o Garmin Pay",
      "is_correct": false
     },
     {
      "body": "Body Battery e música offline",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que mudou na lanterna do Fenix 8 em relação ao Fenix 7?",
    "explanation": "No Fenix 7, a lanterna existia só no 7X. No Fenix 8, ela deixa de ser restrita a um tamanho.",
    "active": true,
    "alternatives": [
     {
      "body": "Apareceu pela primeira vez na linha Fenix",
      "is_correct": false
     },
     {
      "body": "Passou a ter só luz vermelha noturna",
      "is_correct": false
     },
     {
      "body": "Ficou exclusiva da versão Solar",
      "is_correct": false
     },
     {
      "body": "Deixou de ser exclusiva do maior tamanho",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente só corre e acha o Fenix 8 caro. Como conduzir?",
    "explanation": "O Fenix 8 se justifica para quem usa vários esportes e ambientes. Para quem só corre, o Forerunner é mais eficiente.",
    "active": true,
    "alternatives": [
     {
      "body": "Insistir no Fenix pelo acabamento premium",
      "is_correct": false
     },
     {
      "body": "Oferecer o Fenix 8 Pro pelo inReach",
      "is_correct": false
     },
     {
      "body": "Indicar um Forerunner, mais eficiente para ele",
      "is_correct": true
     },
     {
      "body": "Indicar o Fenix 8 Solar, que custa menos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Fenix 8 Pro adiciona ao Fenix 8 padrão?",
    "explanation": "O Fenix 8 Pro traz inReach embutido. Lembre que a versão Pro não está disponível no Brasil.",
    "active": true,
    "alternatives": [
     {
      "body": "App de ECG e lanterna de LED",
      "is_correct": false
     },
     {
      "body": "inReach para satélite e celular",
      "is_correct": true
     },
     {
      "body": "Tela AMOLED maior e mais brilhante",
      "is_correct": false
     },
     {
      "body": "Mergulho até 100 metros",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Fenix 8 oferece para treino de força?",
    "explanation": "Planos de força de 4 a 6 semanas, com treinos animados de cardio, yoga e Pilates na tela.",
    "active": true,
    "alternatives": [
     {
      "body": "Planos estruturados de 4 a 6 semanas",
      "is_correct": true
     },
     {
      "body": "Cálculo da carga ideal em cada série",
      "is_correct": false
     },
     {
      "body": "Contagem de repetições pelo app do celular",
      "is_correct": false
     },
     {
      "body": "Só o registro avulso de cada série",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "fenix-9",
  "quiz_id": "e5161a15-33c7-49ac-a3ba-e3337fa34bdf",
  "questions": [
   {
    "body": "O que mudou na categoria oficial do Fenix 9 em relação ao Fenix 8?",
    "explanation": "A Garmin redefiniu a categoria: o Fenix 8 é relógio GPS multiesportivo, e o Fenix 9 é smartwatch.",
    "active": true,
    "alternatives": [
     {
      "body": "Passou de smartwatch a relógio GPS",
      "is_correct": false
     },
     {
      "body": "Passou a ser da linha de mergulho",
      "is_correct": false
     },
     {
      "body": "Passou de GPS multiesportivo a smartwatch",
      "is_correct": true
     },
     {
      "body": "Continua na mesma categoria do 8",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como funcionam os comandos de voz do Fenix 9?",
    "explanation": "O OK Garmin aciona comandos sem apertar botões, e os básicos funcionam sem internet.",
    "active": true,
    "alternatives": [
     {
      "body": "Só com o celular pareado por perto",
      "is_correct": false
     },
     {
      "body": "Mãos-livres com OK Garmin, sem botão",
      "is_correct": true
     },
     {
      "body": "Só com internet ativa no relógio",
      "is_correct": false
     },
     {
      "body": "Acionados por botão, como no Fenix 8",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a bateria do Fenix 9 Solar de 51 mm no modo Bateria Máxima GPS?",
    "explanation": "Um salto grande: de 653 h no Fenix 8 para até 1.000 h no Fenix 9 Solar de 51 mm.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 1.000 h, contra 653 h do Fenix 8",
      "is_correct": true
     },
     {
      "body": "Até 653 h, contra 1.000 h do Fenix 8",
      "is_correct": false
     },
     {
      "body": "Até 500 h, contra 320 h do Fenix 8",
      "is_correct": false
     },
     {
      "body": "Até 1.000 h, igual ao Fenix 8",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Existe Fenix 9 Pro à venda no Brasil?",
    "explanation": "A versão Pro depende de LTE, que não está disponível para essa linha no Brasil. Aqui são vendidos AMOLED e Solar.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, com LTE das grandes operadoras",
      "is_correct": false
     },
     {
      "body": "Sim, mas só na caixa de 51 mm",
      "is_correct": false
     },
     {
      "body": "Sim, com inReach no lugar do LTE",
      "is_correct": false
     },
     {
      "body": "Não, depende de LTE indisponível aqui",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que faz o Modo Jaqueta do Fenix 9?",
    "explanation": "Desativa o sensor de FC no pulso para economizar energia, mantendo GPS e os demais sensores.",
    "active": true,
    "alternatives": [
     {
      "body": "Aumenta a sensibilidade do toque com luva",
      "is_correct": false
     },
     {
      "body": "Aquece a bateria em temperaturas negativas",
      "is_correct": false
     },
     {
      "body": "Desliga a FC de pulso sob roupas grossas",
      "is_correct": true
     },
     {
      "body": "Bloqueia a tela durante o frio extremo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente pratica tiro com arco. Qual recurso do Fenix 9 fala com ele?",
    "explanation": "O ArcheryX acompanha estabilidade da mira e tempo de tiro, com integração ao ShotView.",
    "active": true,
    "alternatives": [
     {
      "body": "Field Tools",
      "is_correct": false
     },
     {
      "body": "ArcheryX",
      "is_correct": true
     },
     {
      "body": "Garmin Epic",
      "is_correct": false
     },
     {
      "body": "Zonas de Stamina",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que é o Garmin Epic?",
    "explanation": "O Epic reúne atividades, trajetos e dados de saúde de vários dias. Bússola e waypoints ficam no Field Tools.",
    "active": true,
    "alternatives": [
     {
      "body": "Diário de vários dias de expedição",
      "is_correct": true
     },
     {
      "body": "App com bússola, altura e waypoints",
      "is_correct": false
     },
     {
      "body": "Modo de economia para expedições",
      "is_correct": false
     },
     {
      "body": "Mapa em perspectiva 3D no relógio",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quem assina a análise de performance do Fenix 9?",
    "explanation": "O Fenix 9 passa a creditar as métricas ao Garmin Human Performance Lab, no lugar da Firstbeat usada no Fenix 8.",
    "active": true,
    "alternatives": [
     {
      "body": "Laboratório Firstbeat Analytics",
      "is_correct": false
     },
     {
      "body": "Equipe do Garmin Coach Expert",
      "is_correct": false
     },
     {
      "body": "Plataforma TrainingPeaks Pro",
      "is_correct": false
     },
     {
      "body": "Garmin Human Performance Lab",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como ficou a configuração do GNSS no Fenix 9?",
    "explanation": "Em vez de termos técnicos, modos como Precisão máxima, Normal, Bateria estendida e Máximo de bateria, todos com SatIQ.",
    "active": true,
    "alternatives": [
     {
      "body": "Só multibanda, ligado o tempo todo",
      "is_correct": false
     },
     {
      "body": "Escolha manual de cada constelação",
      "is_correct": false
     },
     {
      "body": "Modos por objetivo, todos com SatIQ",
      "is_correct": true
     },
     {
      "body": "GPS padrão, sem o recurso SatIQ",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer fazer ligações sem o celular por perto. Como conduzir?",
    "explanation": "Ligar sem o celular depende da versão Pro com LTE, que ainda não é vendida no Brasil.",
    "active": true,
    "alternatives": [
     {
      "body": "Indicar o Fenix 9 AMOLED, que liga sem celular",
      "is_correct": false
     },
     {
      "body": "Explicar que a versão LTE não é vendida aqui",
      "is_correct": true
     },
     {
      "body": "Indicar o Fenix 9 Solar com inReach embutido",
      "is_correct": false
     },
     {
      "body": "Mostrar o OK Garmin, que liga sem o celular",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "enduro-3",
  "quiz_id": "10f3158a-787c-46b8-9db0-6c35d512871e",
  "questions": [
   {
    "body": "Qual é a bateria do Enduro 3 em modo GPS?",
    "explanation": "Até 120 h em uso típico e 320 h com carregamento solar. 70/80 h era o Enduro original, e 150 h com sol, o Enduro 2.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 70 h, ou 80 h com sol",
      "is_correct": false
     },
     {
      "body": "Até 120 h, ou 150 h com sol",
      "is_correct": false
     },
     {
      "body": "Até 320 h, ou 1.000 h com sol",
      "is_correct": false
     },
     {
      "body": "Até 120 h, ou 320 h com sol",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é a bateria do Enduro 3 em modo smartwatch?",
    "explanation": "Até 36 dias em uso típico e 90 dias com energia solar. Os 77 dias são do modo expedição.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 29 dias, ou 48 dias com sol",
      "is_correct": false
     },
     {
      "body": "Até 24 dias, ou ilimitada com sol",
      "is_correct": false
     },
     {
      "body": "Até 36 dias, ou 90 dias com sol",
      "is_correct": true
     },
     {
      "body": "Até 77 dias, ou ilimitada com sol",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quanto dura o modo expedição GPS do Enduro 3?",
    "explanation": "Pensado para vários dias: até 77 dias de uso típico, e ilimitado com sol suficiente.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 36 dias, sem uso do sol",
      "is_correct": false
     },
     {
      "body": "Até 77 dias, ilimitado com sol",
      "is_correct": true
     },
     {
      "body": "Até 120 horas de uso típico",
      "is_correct": false
     },
     {
      "body": "Até 30 dias, com sol direto",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como é a construção do Enduro 3?",
    "explanation": "Bisel de titânio de 51 mm, lente de safira, pulseira UltraFit e só 63 g, em caixa única.",
    "active": true,
    "alternatives": [
     {
      "body": "Titânio de 51 mm, safira e 63 g",
      "is_correct": true
     },
     {
      "body": "Alumínio de 47 mm, vidro e 79 g",
      "is_correct": false
     },
     {
      "body": "Titânio de 47 e 51 mm e 70 g",
      "is_correct": false
     },
     {
      "body": "Polímero de 50 mm, MIL-STD e 60 g",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “O Enduro 3 serve para mergulho?” Qual é a resposta?",
    "explanation": "É 10 ATM, mas o manual indica natação de superfície. Mergulhar pode danificar o relógio e anular a garantia.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, até 100 metros de profundidade",
      "is_correct": false
     },
     {
      "body": "Sim, mas só para apneia recreativa",
      "is_correct": false
     },
     {
      "body": "Sim, com o mesmo modo do Fenix 8",
      "is_correct": false
     },
     {
      "body": "Não, é indicado para natação de superfície",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Por que escolher o Enduro 3 em vez do Fenix 8?",
    "explanation": "O Enduro 3 foca em autonomia, com boa parte do treino e da navegação do Fenix 8, em caixa e cor únicas.",
    "active": true,
    "alternatives": [
     {
      "body": "Tem mais recursos de mergulho que o Fenix 8",
      "is_correct": false
     },
     {
      "body": "Tem tela AMOLED maior e mais brilhante",
      "is_correct": false
     },
     {
      "body": "Prioriza bateria e mantém boa parte dos recursos",
      "is_correct": true
     },
     {
      "body": "É vendido em mais tamanhos e mais cores",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que mudou do Enduro 2 para o Enduro 3?",
    "explanation": "A lente solar gera mais que o dobro de energia, e chegam o ECG e o Garmin Messenger. Touch e mapas vieram no Enduro 2.",
    "active": true,
    "alternatives": [
     {
      "body": "Tela touchscreen e mapas pré-carregados",
      "is_correct": false
     },
     {
      "body": "Lente solar mais eficiente, ECG e Messenger",
      "is_correct": true
     },
     {
      "body": "A primeira lente solar da linha Enduro",
      "is_correct": false
     },
     {
      "body": "Pulse Ox e Body Battery inéditos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente precisa de assinatura para usar mapas no Enduro 3?",
    "explanation": "Os mapas TopoActive vêm pré-carregados. A Outdoor Maps+ libera conteúdo extra, como imagens de satélite.",
    "active": true,
    "alternatives": [
     {
      "body": "Não; TopoActive vem pronto e Maps+ é opcional",
      "is_correct": true
     },
     {
      "body": "Sim, todo mapa exige a assinatura Maps+",
      "is_correct": false
     },
     {
      "body": "Sim, mas só para mapas fora do Brasil",
      "is_correct": false
     },
     {
      "body": "Não, mas os mapas dependem do celular",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que a atividade Ultra Run oferece?",
    "explanation": "Cronômetro de descanso e registro do tempo gasto nos pontos de apoio em provas longas.",
    "active": true,
    "alternatives": [
     {
      "body": "Previsão de chegada em cada checkpoint",
      "is_correct": false
     },
     {
      "body": "Mapa com os postos de hidratação",
      "is_correct": false
     },
     {
      "body": "Alerta de alimentação a cada 45 minutos",
      "is_correct": false
     },
     {
      "body": "Cronômetro de descanso e tempo em apoios",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O app de ECG do Enduro 3 funciona para qualquer cliente?",
    "explanation": "O app não é destinado a menores de 22 anos e não está disponível em todas as regiões.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, para qualquer idade e em qualquer região",
      "is_correct": false
     },
     {
      "body": "Só funciona com a cinta HRM 600 pareada",
      "is_correct": false
     },
     {
      "body": "Não; fora para menores de 22 e algumas regiões",
      "is_correct": true
     },
     {
      "body": "Só funciona na versão sem a lente solar",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "instinct-3",
  "quiz_id": "9e2953e1-85b5-4f0a-874e-281d4b0711fb",
  "questions": [
   {
    "body": "Quais são as opções de tela e tamanho do Instinct 3?",
    "explanation": "AMOLED ou Solar (MIP), nas caixas de 45 e 50 mm.",
    "active": true,
    "alternatives": [
     {
      "body": "AMOLED ou Solar, em 45 e 50 mm",
      "is_correct": true
     },
     {
      "body": "Só Solar, em 40 e 45 mm",
      "is_correct": false
     },
     {
      "body": "AMOLED ou Solar, em 43, 47 e 51 mm",
      "is_correct": false
     },
     {
      "body": "Só AMOLED, em caixa de 45 mm",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a bateria do Instinct 3 AMOLED no modo smartwatch?",
    "explanation": "Até 24 dias. A versão Solar tem bateria praticamente ilimitada com sol suficiente.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 29 dias",
      "is_correct": false
     },
     {
      "body": "Até 14 dias",
      "is_correct": false
     },
     {
      "body": "Até 40 dias",
      "is_correct": false
     },
     {
      "body": "Até 24 dias",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que o Instinct 3 trouxe que o Instinct 2 não tinha?",
    "explanation": "MIL-STD 810, 100 m, Body Battery, VO2 e os sensores ABC já vinham do Instinct 2.",
    "active": true,
    "alternatives": [
     {
      "body": "MIL-STD 810 e 100 m de resistência à água",
      "is_correct": false
     },
     {
      "body": "Body Battery, VO2 Max e Sleep Score",
      "is_correct": false
     },
     {
      "body": "AMOLED, lanterna, multibanda e Messenger",
      "is_correct": true
     },
     {
      "body": "Altímetro, barômetro e bússola",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que é o Instinct E?",
    "explanation": "O Instinct E é da mesma geração 3 e abre mão de lanterna e multibanda para ser mais acessível.",
    "active": true,
    "alternatives": [
     {
      "body": "O modelo anterior ao Instinct 3",
      "is_correct": false
     },
     {
      "body": "Variante mais simples da geração 3",
      "is_correct": true
     },
     {
      "body": "A versão premium, com titânio",
      "is_correct": false
     },
     {
      "body": "A versão para pulsos mais finos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer mapas coloridos com navegação turn-by-turn. O que indicar?",
    "explanation": "Mapa colorido com navegação turn-by-turn é exclusivo do Fenix 8 nessa comparação.",
    "active": true,
    "alternatives": [
     {
      "body": "Fenix 8",
      "is_correct": true
     },
     {
      "body": "Instinct 3 Solar",
      "is_correct": false
     },
     {
      "body": "Instinct 3 AMOLED",
      "is_correct": false
     },
     {
      "body": "Instinct E",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como é a construção do Instinct 3?",
    "explanation": "Case de polímero reforçado com fibra, bisel reforçado com metal, MIL-STD 810 e resistência de 100 m.",
    "active": true,
    "alternatives": [
     {
      "body": "Titânio, safira e mergulho até 40 m",
      "is_correct": false
     },
     {
      "body": "Alumínio, vidro comum e 5 ATM",
      "is_correct": false
     },
     {
      "body": "Aço inoxidável, safira e 10 ATM",
      "is_correct": false
     },
     {
      "body": "Polímero com fibra, MIL-STD 810 e 100 m",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O Instinct 3 tem tela touchscreen?",
    "explanation": "A interação principal segue pelos botões físicos, padrão histórico da linha Instinct.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, em todas as versões do relógio",
      "is_correct": false
     },
     {
      "body": "Só na versão AMOLED do relógio",
      "is_correct": false
     },
     {
      "body": "Não confirmado; usa os botões físicos",
      "is_correct": true
     },
     {
      "body": "Só na versão Solar do relógio",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como é a bateria do Instinct 3 Solar?",
    "explanation": "Com 3 h diárias ao ar livre, a bateria é praticamente ilimitada. O 50 mm Solar tem 5x a autonomia em GPS do Instinct 2 Solar.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 24 dias, com ou sem exposição ao sol",
      "is_correct": false
     },
     {
      "body": "Praticamente ilimitada com 3 h de sol por dia",
      "is_correct": true
     },
     {
      "body": "Até 48 dias, com 3 h de sol por dia",
      "is_correct": false
     },
     {
      "body": "Até 90 dias, mesmo sem exposição ao sol",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual recurso de navegação leva o cliente de volta ao ponto de partida?",
    "explanation": "O TracBack refaz o caminho até o ponto de partida, junto com altímetro, barômetro e bússola de 3 eixos.",
    "active": true,
    "alternatives": [
     {
      "body": "TracBack",
      "is_correct": true
     },
     {
      "body": "ClimbPro",
      "is_correct": false
     },
     {
      "body": "NextFork",
      "is_correct": false
     },
     {
      "body": "PacePro",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual argumento abre bem a venda do Instinct 3?",
    "explanation": "Robustez MIL-STD com lanterna e multibanda de série, por bem menos que o Fenix.",
    "active": true,
    "alternatives": [
     {
      "body": "Mapas coloridos com navegação completa",
      "is_correct": false
     },
     {
      "body": "Titânio, safira e acabamento premium",
      "is_correct": false
     },
     {
      "body": "Mergulho autônomo até 40 metros",
      "is_correct": false
     },
     {
      "body": "Robustez militar sem pagar o preço do Fenix",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "descent-mk3i",
  "quiz_id": "8d626482-d8ef-44a8-8df1-f338a2b9f7bc",
  "questions": [
   {
    "body": "Qual é a classificação de mergulho do Descent Mk3i?",
    "explanation": "200 m, o dobro da geração anterior. O G2 tem 100 m e o Fenix 8, 40 m.",
    "active": true,
    "alternatives": [
     {
      "body": "100 metros",
      "is_correct": false
     },
     {
      "body": "200 metros",
      "is_correct": true
     },
     {
      "body": "40 metros",
      "is_correct": false
     },
     {
      "body": "300 metros",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o “i” do Descent Mk3i indica?",
    "explanation": "O “i” é a integração de ar, com monitoramento da pressão do tanque. O Mk3 sem integração só existe em 43 mm.",
    "active": true,
    "alternatives": [
     {
      "body": "Integração de ar",
      "is_correct": true
     },
     {
      "body": "Interface touchscreen",
      "is_correct": false
     },
     {
      "body": "inReach embutido",
      "is_correct": false
     },
     {
      "body": "Iluminação por LED",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual versão do Descent Mk3 tem lanterna de LED?",
    "explanation": "A lanterna, com modo estroboscópio, é exclusiva do Mk3i de 51 mm.",
    "active": true,
    "alternatives": [
     {
      "body": "Todas as versões",
      "is_correct": false
     },
     {
      "body": "Só o Mk3 de 43 mm",
      "is_correct": false
     },
     {
      "body": "Só o Mk3i de 43 mm",
      "is_correct": false
     },
     {
      "body": "Só o Mk3i de 51 mm",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como é a bateria do Mk3i em modo mergulho, comparada à do Mk2?",
    "explanation": "A tela AMOLED touchscreen consome mais. Vale ser transparente com quem faz viagens longas de mergulho.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 80 h, mais que as 66 h do Mk2",
      "is_correct": false
     },
     {
      "body": "Até 66 h, a mesma do Mk2",
      "is_correct": false
     },
     {
      "body": "Até 66 h, menos que as 80 h do Mk2",
      "is_correct": true
     },
     {
      "body": "Até 30 h, metade da do Mk2",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quantos mergulhadores o Mk3i acompanha no rastreamento de grupo?",
    "explanation": "Com o transmissor Descent T2, mostra pressão de tanque e posição de até 8 mergulhadores, com alcance de 10 m.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 4, com o Descent T1, a 30 m",
      "is_correct": false
     },
     {
      "body": "Até 8, com o Descent T2, a 10 m",
      "is_correct": true
     },
     {
      "body": "Até 8, com o Descent T1, a 100 m",
      "is_correct": false
     },
     {
      "body": "Ilimitados, sem transmissor algum",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Antes de prometer as mensagens SubWave ao cliente, o que o vendedor faz?",
    "explanation": "Mensagens e assistência entre mergulhadores chegam por atualização de software.",
    "active": true,
    "alternatives": [
     {
      "body": "Confirma a versão de software mais recente",
      "is_correct": true
     },
     {
      "body": "Confirma o plano de satélite inReach ativo",
      "is_correct": false
     },
     {
      "body": "Confirma se o cliente tem o Descent T1",
      "is_correct": false
     },
     {
      "body": "Nada, o recurso já vem ativo de fábrica",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente mergulha poucas vezes por ano e não precisa de integração de ar. O que indicar?",
    "explanation": "Para mergulho ocasional, o G2 é suficiente e mais em conta. O Mk3i se justifica para o mergulhador técnico ou frequente.",
    "active": true,
    "alternatives": [
     {
      "body": "Descent Mk3i 51 mm",
      "is_correct": false
     },
     {
      "body": "Descent X50i",
      "is_correct": false
     },
     {
      "body": "Mk3i com Descent T2",
      "is_correct": false
     },
     {
      "body": "Descent G2",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Cliente: “Preciso da integração de ar?” Qual é a resposta?",
    "explanation": "Para mergulho livre e apneia, o Mk3 sem integração de ar já resolve.",
    "active": true,
    "alternatives": [
     {
      "body": "Sempre, em qualquer tipo de mergulho",
      "is_correct": false
     },
     {
      "body": "Só para apneia e mergulho livre",
      "is_correct": false
     },
     {
      "body": "Só se mergulha com cilindro ou em grupo",
      "is_correct": true
     },
     {
      "body": "Só para mergulhos abaixo de 40 m",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o DiveView oferece?",
    "explanation": "Mapas com contornos batimétricos e mais de 4.000 pontos de mergulho, mais GPS de superfície.",
    "active": true,
    "alternatives": [
     {
      "body": "Câmera para fotografar debaixo d’água",
      "is_correct": false
     },
     {
      "body": "Mapas batimétricos e 4.000+ pontos de mergulho",
      "is_correct": true
     },
     {
      "body": "Previsão de marés e correntes do local",
      "is_correct": false
     },
     {
      "body": "Lista de escolas de mergulho próximas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Dive Readiness avalia?",
    "explanation": "Ele combina sono, exercício, estresse e jet lag para sugerir se o momento é adequado para mergulhar.",
    "active": true,
    "alternatives": [
     {
      "body": "Sono, exercício, estresse e jet lag",
      "is_correct": true
     },
     {
      "body": "Pressão do tanque e profundidade",
      "is_correct": false
     },
     {
      "body": "Temperatura e visibilidade da água",
      "is_correct": false
     },
     {
      "body": "Velocidade de subida do último mergulho",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "descent-g2",
  "quiz_id": "91ce0ec5-c81c-49b0-adc5-0f6901e6bd7c",
  "questions": [
   {
    "body": "Qual é a classificação de mergulho do Descent G2?",
    "explanation": "100 m, contra 200 m do Mk3i.",
    "active": true,
    "alternatives": [
     {
      "body": "200 metros",
      "is_correct": false
     },
     {
      "body": "40 metros",
      "is_correct": false
     },
     {
      "body": "100 metros",
      "is_correct": true
     },
     {
      "body": "50 metros",
      "is_correct": false
     }
    ]
   },
   {
    "body": "De que é feito o corpo do Descent G2?",
    "explanation": "100% do plástico da caixa, do bisel e dos botões vem de plástico reciclado do oceano.",
    "active": true,
    "alternatives": [
     {
      "body": "Titânio reciclado na caixa e no bisel",
      "is_correct": false
     },
     {
      "body": "Plástico reciclado retirado do oceano",
      "is_correct": true
     },
     {
      "body": "Alumínio reciclado com vidro comum",
      "is_correct": false
     },
     {
      "body": "Aço inoxidável com pulseira de couro",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a tela do Descent G2?",
    "explanation": "AMOLED de 1,2\", que facilita ler os dados de relance debaixo d’água.",
    "active": true,
    "alternatives": [
     {
      "body": "AMOLED de 1,2\"",
      "is_correct": true
     },
     {
      "body": "MIP de 1,2\"",
      "is_correct": false
     },
     {
      "body": "AMOLED de 1,4\"",
      "is_correct": false
     },
     {
      "body": "Touchscreen de 3\"",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a bateria do Descent G2 no modo smartwatch?",
    "explanation": "Até 10 dias. O G1 durava até 3 semanas, e a variante Solar dele, até 4 meses.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 3 semanas",
      "is_correct": false
     },
     {
      "body": "Até 4 meses",
      "is_correct": false
     },
     {
      "body": "Até 24 dias",
      "is_correct": false
     },
     {
      "body": "Até 10 dias",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como a bateria do G2 se compara à do Descent G1?",
    "explanation": "A tela AMOLED consome bem mais energia. Seja transparente, principalmente com quem viaja para mergulhar.",
    "active": true,
    "alternatives": [
     {
      "body": "Bem maior, graças à tela AMOLED",
      "is_correct": false
     },
     {
      "body": "É a mesma nos dois modelos",
      "is_correct": false
     },
     {
      "body": "Bem menor, por causa da tela AMOLED",
      "is_correct": true
     },
     {
      "body": "Maior, porque o G2 tem versão Solar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Descent G2 tem integração de ar?",
    "explanation": "Integração de ar e SubWave são exclusivos do Descent Mk3i.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, com o Descent T2",
      "is_correct": false
     },
     {
      "body": "Não, é exclusiva do Mk3i",
      "is_correct": true
     },
     {
      "body": "Sim, com o Descent T1",
      "is_correct": false
     },
     {
      "body": "Sim, por atualização",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Descent G2 tem versão Solar?",
    "explanation": "O G1 tinha uma variante Solar. O G2 não oferece essa opção.",
    "active": true,
    "alternatives": [
     {
      "body": "Não, diferente do G1",
      "is_correct": true
     },
     {
      "body": "Sim, igual ao G1 Solar",
      "is_correct": false
     },
     {
      "body": "Só na versão preta",
      "is_correct": false
     },
     {
      "body": "Sim, com 4 meses de bateria",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “O G2 serve para mergulho técnico?” Qual é a resposta?",
    "explanation": "Tem nitrox, trimix e CCR, mas para integração de ar e SubWave o produto certo é o Mk3i.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, com integração de ar e mensagens SubWave",
      "is_correct": false
     },
     {
      "body": "Não, ele serve só para snorkel e piscina",
      "is_correct": false
     },
     {
      "body": "Sim, com classificação de mergulho de 200 m",
      "is_correct": false
     },
     {
      "body": "Cobre o básico, sem integração de ar nem SubWave",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente mergulha e se preocupa com a saúde dos oceanos. Qual argumento do G2 conversa com ele?",
    "explanation": "O corpo feito de plástico retirado do oceano é um argumento real para quem mergulha e valoriza sustentabilidade.",
    "active": true,
    "alternatives": [
     {
      "body": "Lente de safira resistente",
      "is_correct": false
     },
     {
      "body": "Pagamento com Garmin Pay",
      "is_correct": false
     },
     {
      "body": "Plástico reciclado do oceano",
      "is_correct": true
     },
     {
      "body": "Modo de números grandes",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quais pulseiras o Descent G2 aceita?",
    "explanation": "O G2 é compatível com pulseiras QuickFit intercambiáveis, nas cores preta e paloma/rosa shell.",
    "active": true,
    "alternatives": [
     {
      "body": "Só a pulseira original",
      "is_correct": false
     },
     {
      "body": "QuickFit intercambiáveis",
      "is_correct": true
     },
     {
      "body": "Quick Release de mola",
      "is_correct": false
     },
     {
      "body": "Watchband com pino fixo",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "descent-x30",
  "quiz_id": "b34eddf5-1d57-4e55-a023-baa485e02a59",
  "questions": [
   {
    "body": "Qual é a tela do Descent X30?",
    "explanation": "Tela de 2,4\" controlada por botões metálicos à prova de vazamento. O touch de 3\" é do X50i.",
    "active": true,
    "alternatives": [
     {
      "body": "3\", com touchscreen",
      "is_correct": false
     },
     {
      "body": "1,2\", AMOLED touch",
      "is_correct": false
     },
     {
      "body": "2,4\", com touchscreen",
      "is_correct": false
     },
     {
      "body": "2,4\", só com botões",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é a resistência do Descent X30?",
    "explanation": "10 ATM, adequada a mergulho recreativo e técnico moderado. O X50i tem 20 ATM.",
    "active": true,
    "alternatives": [
     {
      "body": "20 ATM",
      "is_correct": false
     },
     {
      "body": "5 ATM",
      "is_correct": false
     },
     {
      "body": "10 ATM",
      "is_correct": true
     },
     {
      "body": "200 m",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a bateria anunciada do Descent X30?",
    "explanation": "Até 30 h de bateria, robusta para viagens de mergulho de vários dias.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 66 h",
      "is_correct": false
     },
     {
      "body": "Até 30 h",
      "is_correct": true
     },
     {
      "body": "Até 10 dias",
      "is_correct": false
     },
     {
      "body": "Até 80 h",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Descent X30 é sucessor do X50i?",
    "explanation": "São dois produtos da mesma sub-linha de tela grande, lançados com cerca de 10 meses de diferença, em faixas de preço diferentes.",
    "active": true,
    "alternatives": [
     {
      "body": "Não, são tiers da mesma geração",
      "is_correct": true
     },
     {
      "body": "Sim, substituiu o X50i em 2025",
      "is_correct": false
     },
     {
      "body": "Sim, é a versão nova com touch",
      "is_correct": false
     },
     {
      "body": "Não, o X50i é que sucede o X30",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que só o Descent X50i tem, comparado ao X30?",
    "explanation": "NDL Aware e trimix estão nos dois. O X50i soma touch, sonar, lanterna de backup e 20 ATM.",
    "active": true,
    "alternatives": [
     {
      "body": "NDL Aware e suporte a trimix",
      "is_correct": false
     },
     {
      "body": "GPS de superfície e bússola",
      "is_correct": false
     },
     {
      "body": "Corpo de plástico reciclado",
      "is_correct": false
     },
     {
      "body": "Touch de 3\", sonar e lanterna",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que faz o NDL Aware?",
    "explanation": "Métricas em tempo real mostram como mudar de profundidade afeta o NDL, ajudando a planejar o mergulho.",
    "active": true,
    "alternatives": [
     {
      "body": "Mede a pressão do tanque do mergulhador em tempo real",
      "is_correct": false
     },
     {
      "body": "Envia mensagens para outros mergulhadores do grupo",
      "is_correct": false
     },
     {
      "body": "Mostra como a profundidade afeta o limite de não-descompressão",
      "is_correct": true
     },
     {
      "body": "Calcula a velocidade de subida mais segura no mergulho",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente mergulha em água fria, sempre com luva grossa. O que indicar?",
    "explanation": "Botões metálicos funcionam com luva grossa e não sofrem com água na tela.",
    "active": true,
    "alternatives": [
     {
      "body": "Descent X50i, com touch grande",
      "is_correct": false
     },
     {
      "body": "Descent X30, com botões metálicos",
      "is_correct": true
     },
     {
      "body": "Descent Mk3i, com AMOLED touch",
      "is_correct": false
     },
     {
      "body": "Descent G2, com tela AMOLED",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Descent X30 funciona com inReach?",
    "explanation": "É compatível com comunicadores inReach para SOS, com plano satelital ativo e case de mergulho específico.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, para SOS, com plano ativo e case",
      "is_correct": true
     },
     {
      "body": "Não, nenhum Descent é compatível",
      "is_correct": false
     },
     {
      "body": "Sim, sem precisar de plano ativo",
      "is_correct": false
     },
     {
      "body": "Só para mensagens, sem o SOS",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a diferença de proposta entre o Descent X30 e o Mk3i?",
    "explanation": "Para o melhor computador de mergulho, o X30. Para um relógio do dia a dia que também mergulha, o Mk3i.",
    "active": true,
    "alternatives": [
     {
      "body": "X30 é relógio do dia a dia; Mk3i é computador dedicado",
      "is_correct": false
     },
     {
      "body": "Os dois são relógios para usar no dia a dia",
      "is_correct": false
     },
     {
      "body": "X30 é só para apneia; Mk3i, para mergulho com cilindro",
      "is_correct": false
     },
     {
      "body": "X30 é computador dedicado; Mk3i é relógio que mergulha",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como o preço do Descent X30 se compara ao do X50i?",
    "explanation": "US$ 749,99 contra US$ 1.499,99: a diferença reflete touch, sonar, lanterna e profundidade extra.",
    "active": true,
    "alternatives": [
     {
      "body": "Quase o dobro",
      "is_correct": false
     },
     {
      "body": "O mesmo preço",
      "is_correct": false
     },
     {
      "body": "Quase a metade",
      "is_correct": true
     },
     {
      "body": "Um quarto dele",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "edge-540",
  "quiz_id": "7b2d3ee2-ae79-4ffc-996a-899601091d39",
  "questions": [
   {
    "body": "Como o Edge 540 é controlado?",
    "explanation": "O 540 é controlado só por botões, que funcionam com chuva, luva e dedo molhado.",
    "active": true,
    "alternatives": [
     {
      "body": "Só por botões, sem touch",
      "is_correct": true
     },
     {
      "body": "Por touchscreen e botões",
      "is_correct": false
     },
     {
      "body": "Só por touchscreen",
      "is_correct": false
     },
     {
      "body": "Por botões e por voz",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a bateria do Edge 540 (sem Solar) em uso intenso?",
    "explanation": "Até 26 h em uso intenso. O Edge 550 faz até 12 h.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 12 h",
      "is_correct": false
     },
     {
      "body": "Até 20 h",
      "is_correct": false
     },
     {
      "body": "Até 35 h",
      "is_correct": false
     },
     {
      "body": "Até 26 h",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é a diferença entre o Edge 540 e o Edge 840?",
    "explanation": "Multibanda, coaching e ClimbPro estão nos dois. O 840 soma o touchscreen.",
    "active": true,
    "alternatives": [
     {
      "body": "O 840 tem multibanda e o 540 não",
      "is_correct": false
     },
     {
      "body": "O 840 tem ClimbPro e o 540 não",
      "is_correct": false
     },
     {
      "body": "Só o touchscreen; o resto é igual",
      "is_correct": true
     },
     {
      "body": "O 840 tem coaching e o 540 não",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Edge 540 trouxe que o Edge 530 não tinha?",
    "explanation": "GNSS multibanda, coaching adaptativo, monitor de resistência, métricas de MTB e a opção Solar são novos.",
    "active": true,
    "alternatives": [
     {
      "body": "Controle por botão e tela parecida",
      "is_correct": false
     },
     {
      "body": "Multibanda, coaching adaptativo e MTB",
      "is_correct": true
     },
     {
      "body": "Touchscreen e Garmin Pay no guidão",
      "is_correct": false
     },
     {
      "body": "Alto-falante e campainha digital",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quais métricas de mountain bike o Edge 540 registra?",
    "explanation": "Contagem e distância de saltos, Grit (dificuldade técnica) e Flow (fluidez da trilha).",
    "active": true,
    "alternatives": [
     {
      "body": "Saltos, Grit e Flow",
      "is_correct": true
     },
     {
      "body": "Potência e cadência",
      "is_correct": false
     },
     {
      "body": "Velocidade e distância",
      "is_correct": false
     },
     {
      "body": "Altitude e inclinação",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Power Guide faz?",
    "explanation": "Dá a potência-alvo para gerenciar o esforço ao longo do percurso.",
    "active": true,
    "alternatives": [
     {
      "body": "Calibra o medidor de potência",
      "is_correct": false
     },
     {
      "body": "Compara a potência com o grupo",
      "is_correct": false
     },
     {
      "body": "Mede o equilíbrio entre as pernas",
      "is_correct": false
     },
     {
      "body": "Orienta a potência-alvo no percurso",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que mostra o monitor de resistência em tempo real?",
    "explanation": "Mostra quanta “gasolina” ainda resta durante o pedal, para dosar o esforço.",
    "active": true,
    "alternatives": [
     {
      "body": "A resistência do vento contra a bike",
      "is_correct": false
     },
     {
      "body": "A pressão dos pneus durante o pedal",
      "is_correct": false
     },
     {
      "body": "A reserva de energia estimada no pedal",
      "is_correct": true
     },
     {
      "body": "O desgaste estimado da corrente",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Por que o 540 não tem touchscreen?” Qual resposta segue a ficha?",
    "explanation": "É escolha de design. Quem prefere touch tem as mesmas funções no Edge 840.",
    "active": true,
    "alternatives": [
     {
      "body": "Porque é o modelo mais antigo da linha Edge",
      "is_correct": false
     },
     {
      "body": "Botão funciona com chuva e luva; touch é no 840",
      "is_correct": true
     },
     {
      "body": "Porque o touchscreen gastaria muita bateria",
      "is_correct": false
     },
     {
      "body": "Porque o touch chega por atualização futura",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Edge 540 tem versão Solar?",
    "explanation": "O Edge 540 Solar, com Power Glass, é vendido separadamente.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, vendida separadamente",
      "is_correct": true
     },
     {
      "body": "Não, só o 1040 tem Solar",
      "is_correct": false
     },
     {
      "body": "Sim, todo 540 já é Solar",
      "is_correct": false
     },
     {
      "body": "Não, nenhum Edge é Solar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Entre o Edge 540 e o 550, o cliente prioriza horas de bateria em uso intenso. Qual indicar?",
    "explanation": "O 540 faz até 26 h em uso intenso, contra 12 h do 550.",
    "active": true,
    "alternatives": [
     {
      "body": "Edge 550",
      "is_correct": false
     },
     {
      "body": "Edge 850",
      "is_correct": false
     },
     {
      "body": "Edge 1050",
      "is_correct": false
     },
     {
      "body": "Edge 540",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "edge-550",
  "quiz_id": "b9faead3-0d45-4fd6-8ab7-5feec38ebab6",
  "questions": [
   {
    "body": "Qual é a tela do Edge 550?",
    "explanation": "Tela de 2,7\", maior e mais brilhante que a de 2,6\" do 540, controlada por botão.",
    "active": true,
    "alternatives": [
     {
      "body": "2,6\", MIP refletiva",
      "is_correct": false
     },
     {
      "body": "2,7\", mais brilhante",
      "is_correct": true
     },
     {
      "body": "3,5\", com touchscreen",
      "is_correct": false
     },
     {
      "body": "2,7\", com touchscreen",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a bateria do Edge 550?",
    "explanation": "Até 12 h em uso intenso e 36 h em economia. O 540 faz 26 h e 42 h.",
    "active": true,
    "alternatives": [
     {
      "body": "12 h intenso e 36 h economia",
      "is_correct": true
     },
     {
      "body": "26 h intenso e 42 h economia",
      "is_correct": false
     },
     {
      "body": "35 h intenso e 70 h economia",
      "is_correct": false
     },
     {
      "body": "20 h intenso e 60 h economia",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que são os alertas inteligentes de fueling do Edge 550?",
    "explanation": "Recomendações personalizadas de nutrição e hidratação durante o pedal, novidade do 550.",
    "active": true,
    "alternatives": [
     {
      "body": "Aviso de bateria baixa no Edge",
      "is_correct": false
     },
     {
      "body": "Postos de combustível na rota",
      "is_correct": false
     },
     {
      "body": "Lembretes de lubrificar a corrente",
      "is_correct": false
     },
     {
      "body": "Lembretes de comer e beber no pedal",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que o clima em tempo real do Edge 550 mostra?",
    "explanation": "Vento e radar de chuva sobrepostos ao mapa, para planejar o pedal.",
    "active": true,
    "alternatives": [
     {
      "body": "Temperatura do asfalto na rota",
      "is_correct": false
     },
     {
      "body": "A previsão para a semana toda",
      "is_correct": false
     },
     {
      "body": "Vento e radar de chuva no mapa",
      "is_correct": true
     },
     {
      "body": "A umidade do ar no guidão",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Edge 550 oferece para enduro e downhill?",
    "explanation": "Gravação de GPS a 5 Hz e cronometragem por trecho para MTB de descida.",
    "active": true,
    "alternatives": [
     {
      "body": "Ajuste eletrônico da suspensão",
      "is_correct": false
     },
     {
      "body": "GPS a 5 Hz e timing gates",
      "is_correct": true
     },
     {
      "body": "Contagem de saltos por câmera",
      "is_correct": false
     },
     {
      "body": "Alerta de freio nas descidas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer os recursos do 550, mas com touchscreen. O que indicar?",
    "explanation": "Para touchscreen nesta geração, o modelo correto é o Edge 850.",
    "active": true,
    "alternatives": [
     {
      "body": "Edge 850",
      "is_correct": true
     },
     {
      "body": "Edge 550",
      "is_correct": false
     },
     {
      "body": "Edge 540",
      "is_correct": false
     },
     {
      "body": "Edge 540 Solar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Edge 550 tem versão Solar?",
    "explanation": "O material do lançamento do 550/850 não menciona Solar, diferente do 540/840.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, vendida separadamente",
      "is_correct": false
     },
     {
      "body": "Sim, toda unidade é Solar",
      "is_correct": false
     },
     {
      "body": "Sim, só no mercado brasileiro",
      "is_correct": false
     },
     {
      "body": "O lançamento não menciona Solar",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que fazem as comparações de GroupRide?",
    "explanation": "Comparam as métricas do grupo de pedal em tempo real.",
    "active": true,
    "alternatives": [
     {
      "body": "Enviam a rota do pedal para o grupo todo",
      "is_correct": false
     },
     {
      "body": "Fazem ligações para o grupo pelo Edge",
      "is_correct": false
     },
     {
      "body": "Comparam métricas do grupo em tempo real",
      "is_correct": true
     },
     {
      "body": "Contam quantos ciclistas estão no grupo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como falar da bateria do Edge 550 com transparência?",
    "explanation": "12 h contra 26 h em uso intenso. Em economia a diferença é pequena: 36 h contra 42 h.",
    "active": true,
    "alternatives": [
     {
      "body": "Dura mais que o 540 em qualquer modo de uso do Edge",
      "is_correct": false
     },
     {
      "body": "Dura menos que o 540 no uso intenso; na economia, pouco",
      "is_correct": true
     },
     {
      "body": "Dura exatamente o mesmo que o 540 em todos os modos",
      "is_correct": false
     },
     {
      "body": "Só funciona bem quando o modo economia está ativo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente tem um Edge 540. Quando vale trocar pelo 550?",
    "explanation": "Se a prioridade é bateria em uso intenso, o 540 ainda é uma opção válida.",
    "active": true,
    "alternatives": [
     {
      "body": "Se quiser fueling, clima ou perfis de enduro",
      "is_correct": true
     },
     {
      "body": "Sempre, porque a bateria do 550 é maior",
      "is_correct": false
     },
     {
      "body": "Só se ele quiser um Edge com touchscreen",
      "is_correct": false
     },
     {
      "body": "Nunca, porque os dois são idênticos",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "edge-840",
  "quiz_id": "f646fb31-b687-4397-ab1f-ca95bf3526b7",
  "questions": [
   {
    "body": "Como o Edge 840 é controlado?",
    "explanation": "Touchscreen responsivo para mapas e zoom, além do controle por botão.",
    "active": true,
    "alternatives": [
     {
      "body": "Só por botões físicos",
      "is_correct": false
     },
     {
      "body": "Só por touchscreen",
      "is_correct": false
     },
     {
      "body": "Por touchscreen e botões",
      "is_correct": true
     },
     {
      "body": "Por botões e por voz",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a bateria do Edge 840 (sem Solar) em uso intenso?",
    "explanation": "Até 26 h em uso intenso. O Edge 850 faz até 12 h.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 12 h",
      "is_correct": false
     },
     {
      "body": "Até 26 h",
      "is_correct": true
     },
     {
      "body": "Até 35 h",
      "is_correct": false
     },
     {
      "body": "Até 20 h",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a diferença entre o Edge 840 e o Edge 540?",
    "explanation": "O 540 é só por botão. O resto das funções é idêntico.",
    "active": true,
    "alternatives": [
     {
      "body": "Só o touchscreen",
      "is_correct": true
     },
     {
      "body": "O GPS multibanda",
      "is_correct": false
     },
     {
      "body": "O coaching adaptativo",
      "is_correct": false
     },
     {
      "body": "O ClimbPro",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Edge 840 trouxe que o Edge 830 não tinha?",
    "explanation": "O touchscreen já vinha do 830. Multibanda, coaching, monitor de resistência, MTB e Solar são novos.",
    "active": true,
    "alternatives": [
     {
      "body": "Touchscreen com controle por botões",
      "is_correct": false
     },
     {
      "body": "Campainha digital e alto-falante",
      "is_correct": false
     },
     {
      "body": "Garmin Pay e Wi-Fi integrados",
      "is_correct": false
     },
     {
      "body": "Multibanda, coaching adaptativo e MTB",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente navega muito por mapas e gosta de dar zoom tocando a tela. O que indicar?",
    "explanation": "O 840 permite navegar, dar zoom e planejar rota tocando a tela.",
    "active": true,
    "alternatives": [
     {
      "body": "Edge 540",
      "is_correct": false
     },
     {
      "body": "Edge 550",
      "is_correct": false
     },
     {
      "body": "Edge 840",
      "is_correct": true
     },
     {
      "body": "Edge 540 Solar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a bateria do Edge 840 Solar em uso intenso?",
    "explanation": "O 840 Solar faz até 32 h em uso intenso e 60 h em economia.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 26 h",
      "is_correct": false
     },
     {
      "body": "Até 32 h",
      "is_correct": true
     },
     {
      "body": "Até 12 h",
      "is_correct": false
     },
     {
      "body": "Até 70 h",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Por que não o Edge 850, que é mais novo?” Qual resposta segue a ficha?",
    "explanation": "O 850 tem tela de 2,7\", campainha digital, fueling e clima, mas custa mais e faz 12 h em uso intenso.",
    "active": true,
    "alternatives": [
     {
      "body": "O 850 tem campainha e tela melhor, mas menos bateria",
      "is_correct": true
     },
     {
      "body": "O 850 tem mais bateria, mas perde o touchscreen",
      "is_correct": false
     },
     {
      "body": "O 850 é mais simples e custa menos que o 840",
      "is_correct": false
     },
     {
      "body": "O 850 não tem coaching adaptativo nem ClimbPro",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Vale a diferença de preço para o Edge 540?” O que responder?",
    "explanation": "A diferença é só o touchscreen. Sem isso, o 540 entrega as mesmas funções por menos.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, o 840 tem mais métricas de treino",
      "is_correct": false
     },
     {
      "body": "Sim, o 840 tem uma bateria bem maior",
      "is_correct": false
     },
     {
      "body": "Sim, o 840 tem Garmin Pay no guidão",
      "is_correct": false
     },
     {
      "body": "Só se ele valoriza navegar por toque",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente tem um Edge 830 e quer manter a navegação por toque. O que indicar?",
    "explanation": "O 840 mantém o touchscreen do 830 e soma multibanda e coaching adaptativo.",
    "active": true,
    "alternatives": [
     {
      "body": "Edge 540",
      "is_correct": false
     },
     {
      "body": "Edge 550",
      "is_correct": false
     },
     {
      "body": "Edge 840",
      "is_correct": true
     },
     {
      "body": "Edge 540 Solar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o ClimbPro mostra no Edge 840?",
    "explanation": "Planejador de subida com o perfil de elevação em tempo real do trecho à frente.",
    "active": true,
    "alternatives": [
     {
      "body": "A marcha ideal para encarar a subida",
      "is_correct": false
     },
     {
      "body": "O perfil de elevação da subida à frente",
      "is_correct": true
     },
     {
      "body": "Os watts por quilo necessários na subida",
      "is_correct": false
     },
     {
      "body": "As subidas que devem ser evitadas na rota",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "edge-850",
  "quiz_id": "773159a2-6eb9-4e1c-98da-42f351352571",
  "questions": [
   {
    "body": "O que o Edge 850 tem e o Edge 550 não tem?",
    "explanation": "O 550 é só por botão e não tem campainha. Os recursos de treino são os mesmos.",
    "active": true,
    "alternatives": [
     {
      "body": "Fueling e clima em tempo real",
      "is_correct": false
     },
     {
      "body": "Garmin Cycling Coach adaptativo",
      "is_correct": false
     },
     {
      "body": "Análise de relação de marcha",
      "is_correct": false
     },
     {
      "body": "Touchscreen e campainha digital",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é a bateria do Edge 850?",
    "explanation": "Até 12 h em uso intenso e 36 h em economia. O 840 faz 26 h e 42 h.",
    "active": true,
    "alternatives": [
     {
      "body": "26 h intenso e 42 h economia",
      "is_correct": false
     },
     {
      "body": "20 h intenso e 60 h economia",
      "is_correct": false
     },
     {
      "body": "12 h intenso e 36 h economia",
      "is_correct": true
     },
     {
      "body": "35 h intenso e 70 h economia",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a tela do Edge 850?",
    "explanation": "Tela de 2,7\" com touchscreen, maior e mais brilhante que a de 2,6\" do 840.",
    "active": true,
    "alternatives": [
     {
      "body": "2,6\", touch e refletiva",
      "is_correct": false
     },
     {
      "body": "2,7\", touch e mais brilhante",
      "is_correct": true
     },
     {
      "body": "3,5\", touch e de alto contraste",
      "is_correct": false
     },
     {
      "body": "2,7\", só com botões",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Edge 850 trouxe que o Edge 840 não tinha?",
    "explanation": "Touchscreen e multibanda já vinham do 840.",
    "active": true,
    "alternatives": [
     {
      "body": "Campainha, fueling e clima",
      "is_correct": true
     },
     {
      "body": "Touchscreen e GPS multibanda",
      "is_correct": false
     },
     {
      "body": "Garmin Pay e Wi-Fi integrado",
      "is_correct": false
     },
     {
      "body": "Versão Solar e 32 GB de memória",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “A campainha digital substitui uma campainha física?” Qual resposta segue a ficha?",
    "explanation": "É um recurso adicional de segurança e não elimina a sinalização visual ou manual em algumas situações.",
    "active": true,
    "alternatives": [
     {
      "body": "Substitui totalmente, em qualquer situação de trânsito",
      "is_correct": false
     },
     {
      "body": "Substitui, mas só dentro de ciclovias compartilhadas",
      "is_correct": false
     },
     {
      "body": "Substitui quando o volume está configurado no máximo",
      "is_correct": false
     },
     {
      "body": "Complementa, sem eliminar outras formas de sinalizar",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O ciclista urbano pedala em ciclovia compartilhada e quer touchscreen. O que indicar?",
    "explanation": "O 850 junta touchscreen e a campainha digital para avisar pedestres sem tirar a mão do guidão.",
    "active": true,
    "alternatives": [
     {
      "body": "Edge 550",
      "is_correct": false
     },
     {
      "body": "Edge 840",
      "is_correct": false
     },
     {
      "body": "Edge 850",
      "is_correct": true
     },
     {
      "body": "Edge 540",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer touchscreen, mas prioriza horas de bateria em uso intenso. O que indicar?",
    "explanation": "O 840 faz até 26 h em uso intenso, contra 12 h do 850.",
    "active": true,
    "alternatives": [
     {
      "body": "Edge 850",
      "is_correct": false
     },
     {
      "body": "Edge 840",
      "is_correct": true
     },
     {
      "body": "Edge 550",
      "is_correct": false
     },
     {
      "body": "Edge 1050",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a diferença entre o Edge 850 e o Edge 550?",
    "explanation": "O 550 é controlado só por botão. O resto dos recursos de treino é o mesmo.",
    "active": true,
    "alternatives": [
     {
      "body": "O 550 não tem touch nem campainha",
      "is_correct": true
     },
     {
      "body": "O 550 tem mais recursos de treino que o 850",
      "is_correct": false
     },
     {
      "body": "O 850 tem GPS multibanda e o 550 não tem",
      "is_correct": false
     },
     {
      "body": "O 550 tem a tela maior e mais brilhante",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente tem um Edge 840. Quando vale trocar pelo 850?",
    "explanation": "Se a prioridade for bateria em uso intenso, o 840 ainda é válido.",
    "active": true,
    "alternatives": [
     {
      "body": "Sempre, porque a bateria do 850 é maior",
      "is_correct": false
     },
     {
      "body": "Só para ganhar o touchscreen",
      "is_correct": false
     },
     {
      "body": "Nunca, porque os dois são iguais",
      "is_correct": false
     },
     {
      "body": "Se quiser campainha, fueling ou clima",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Para que serve o touchscreen do Edge 850?",
    "explanation": "Pan e zoom em mapas, denúncia de riscos na via e navegação entre telas.",
    "active": true,
    "alternatives": [
     {
      "body": "Pagar compras por aproximação no pedal",
      "is_correct": false
     },
     {
      "body": "Ajustar as marchas eletrônicas da bike",
      "is_correct": false
     },
     {
      "body": "Zoom em mapas, relatar riscos e trocar telas",
      "is_correct": true
     },
     {
      "body": "Atender ligações durante o pedal",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "edge-1040",
  "quiz_id": "d7c3760f-fc0c-4f22-b72b-2501720726a0",
  "questions": [
   {
    "body": "Qual foi o pioneirismo do Edge 1040?",
    "explanation": "O 1040 trouxe o multibanda um ano antes do 540/840.",
    "active": true,
    "alternatives": [
     {
      "body": "Primeiro Edge com GNSS multibanda",
      "is_correct": true
     },
     {
      "body": "Primeiro Edge com Garmin Pay",
      "is_correct": false
     },
     {
      "body": "Primeiro Edge com touchscreen",
      "is_correct": false
     },
     {
      "body": "Primeiro Edge com alto-falante",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a bateria do Edge 1040?",
    "explanation": "Até 35 h em uso intenso e 70 h em economia, a maior da linha.",
    "active": true,
    "alternatives": [
     {
      "body": "20 h intenso e 60 h economia",
      "is_correct": false
     },
     {
      "body": "26 h intenso e 42 h economia",
      "is_correct": false
     },
     {
      "body": "12 h intenso e 36 h economia",
      "is_correct": false
     },
     {
      "body": "35 h intenso e 70 h economia",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Quanto de memória o Edge 1040 tem?",
    "explanation": "32 GB internos, com suporte a cartão de memória externo.",
    "active": true,
    "alternatives": [
     {
      "body": "16 GB, sem cartão externo",
      "is_correct": false
     },
     {
      "body": "64 GB, com cartão externo",
      "is_correct": false
     },
     {
      "body": "32 GB, com cartão externo",
      "is_correct": true
     },
     {
      "body": "32 GB, sem cartão externo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Edge 1040 tem Garmin Pay?",
    "explanation": "O Garmin Pay é exclusivo da geração Edge 1050.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, desde o lançamento",
      "is_correct": false
     },
     {
      "body": "Não, é exclusivo do 1050",
      "is_correct": true
     },
     {
      "body": "Só na versão Solar",
      "is_correct": false
     },
     {
      "body": "Sim, por atualização",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a tela do Edge 1040?",
    "explanation": "A tela de 3,5\" é a maior da linha Edge.",
    "active": true,
    "alternatives": [
     {
      "body": "Touchscreen de 3,5\"",
      "is_correct": true
     },
     {
      "body": "Touchscreen de 2,7\"",
      "is_correct": false
     },
     {
      "body": "Touchscreen de 3\"",
      "is_correct": false
     },
     {
      "body": "Só botões, de 3,5\"",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quando faz sentido indicar o Edge 1040 Solar?",
    "explanation": "O Power Glass estende a autonomia em pedais longos sob luz do dia, mas custa mais.",
    "active": true,
    "alternatives": [
     {
      "body": "Pedais quase sempre à noite, na cidade",
      "is_correct": false
     },
     {
      "body": "Quando o cliente quer a tela mais brilhante",
      "is_correct": false
     },
     {
      "body": "Quando o cliente quer pagar com o Edge",
      "is_correct": false
     },
     {
      "body": "Pedais de muitas horas sob luz do dia",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que o Edge 1040 trouxe que o 1030 Plus não tinha?",
    "explanation": "Touchscreen de tamanho parecido e proposta topo de linha já vinham do 1030 Plus.",
    "active": true,
    "alternatives": [
     {
      "body": "Touchscreen grande e proposta topo de linha",
      "is_correct": false
     },
     {
      "body": "Garmin Pay e Wi-Fi para atualizar mapas",
      "is_correct": false
     },
     {
      "body": "Multibanda, Solar, rotas mais rápidas e USB-C",
      "is_correct": true
     },
     {
      "body": "Alto-falante embutido e campainha digital",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O ciclista faz brevets e quer a maior tela com a maior bateria. O que indicar?",
    "explanation": "Tela de 3,5\" e até 35 h em uso intenso, mais em conta que o 1050.",
    "active": true,
    "alternatives": [
     {
      "body": "Edge 1050",
      "is_correct": false
     },
     {
      "body": "Edge 1040",
      "is_correct": true
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
    "body": "Cliente: “Por que não o Edge 1050, que é mais novo?” Qual resposta segue a ficha?",
    "explanation": "Se o cliente prioriza autonomia, o 1040 continua sendo uma opção sólida.",
    "active": true,
    "alternatives": [
     {
      "body": "O 1050 tem Pay e som, mas dura 20 h contra 35 h",
      "is_correct": true
     },
     {
      "body": "O 1050 dura mais, mas tem menos recursos",
      "is_correct": false
     },
     {
      "body": "O 1050 não tem tela sensível ao toque",
      "is_correct": false
     },
     {
      "body": "O 1050 tem uma tela menor que a do 1040",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual conector de carregamento o Edge 1040 usa?",
    "explanation": "O 1030 Plus usava micro-USB. O 1040 traz USB-C.",
    "active": true,
    "alternatives": [
     {
      "body": "Micro-USB",
      "is_correct": false
     },
     {
      "body": "Lightning",
      "is_correct": false
     },
     {
      "body": "Magnético",
      "is_correct": false
     },
     {
      "body": "USB-C",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "edge-1050",
  "quiz_id": "a1b5a5c5-ab65-429a-a9ff-78b634a2ffd1",
  "questions": [
   {
    "body": "Qual é a bateria do Edge 1050?",
    "explanation": "Até 20 h em uso intenso e 60 h em economia, menos que o 1040.",
    "active": true,
    "alternatives": [
     {
      "body": "35 h intenso e 70 h economia",
      "is_correct": false
     },
     {
      "body": "20 h intenso e 60 h economia",
      "is_correct": true
     },
     {
      "body": "12 h intenso e 36 h economia",
      "is_correct": false
     },
     {
      "body": "26 h intenso e 42 h economia",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Edge 1050 tem e o 1040 não tem?",
    "explanation": "Multibanda, 32 GB e tela de 3,5\" já vinham do 1040.",
    "active": true,
    "alternatives": [
     {
      "body": "Garmin Pay, alto-falante e Wi-Fi",
      "is_correct": true
     },
     {
      "body": "GPS multibanda e 32 GB de memória",
      "is_correct": false
     },
     {
      "body": "Touchscreen de 3,5\" de alto contraste",
      "is_correct": false
     },
     {
      "body": "Versão Solar e conector USB-C",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Para que serve o Wi-Fi do Edge 1050?",
    "explanation": "Atualiza os mapas de ciclismo, com dados do Trailforks, sem cabo nem computador.",
    "active": true,
    "alternatives": [
     {
      "body": "Navegar pelo mapa sem precisar de GPS",
      "is_correct": false
     },
     {
      "body": "Transmitir o vídeo do pedal ao vivo",
      "is_correct": false
     },
     {
      "body": "Fazer ligações direto pelo Edge",
      "is_correct": false
     },
     {
      "body": "Atualizar mapas sem computador",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que é o Trendline Popularity Routing?",
    "explanation": "Sugere rotas com base no que outros ciclistas mais usam.",
    "active": true,
    "alternatives": [
     {
      "body": "Rotas sugeridas pelo menor ganho de elevação",
      "is_correct": false
     },
     {
      "body": "Rotas sugeridas pelo menor tráfego de carros",
      "is_correct": false
     },
     {
      "body": "Rotas sugeridas pela popularidade entre ciclistas",
      "is_correct": true
     },
     {
      "body": "Rotas sugeridas pelos pontos de café no caminho",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Edge 1050 tem versão Solar?",
    "explanation": "O material oficial do lançamento do 1050 não menciona variante Solar.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, vendida separadamente na loja",
      "is_correct": false
     },
     {
      "body": "O lançamento não menciona Solar",
      "is_correct": true
     },
     {
      "body": "Sim, toda unidade já é Solar",
      "is_correct": false
     },
     {
      "body": "Só na versão com 64 GB de memória",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “O Garmin Pay funciona em qualquer lugar?” Qual é a resposta?",
    "explanation": "Depende da adesão do estabelecimento e do banco emissor, como nos relógios com Garmin Pay.",
    "active": true,
    "alternatives": [
     {
      "body": "Depende do estabelecimento e do banco",
      "is_correct": true
     },
     {
      "body": "Sim, em qualquer loja do Brasil",
      "is_correct": false
     },
     {
      "body": "Só em postos parceiros da Garmin",
      "is_correct": false
     },
     {
      "body": "Só com um cartão emitido pela Garmin",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O ciclista faz paradas em postos e lojas e não quer levar carteira. O que indicar?",
    "explanation": "O 1050 permite pagar por aproximação direto pelo ciclocomputador.",
    "active": true,
    "alternatives": [
     {
      "body": "Edge 1040",
      "is_correct": false
     },
     {
      "body": "Edge 840",
      "is_correct": false
     },
     {
      "body": "Edge 540",
      "is_correct": false
     },
     {
      "body": "Edge 1050",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente faz provas muito longas e prioriza bateria acima de tudo. O que indicar?",
    "explanation": "O 1040 entrega mais horas por carga: 35 h contra 20 h do 1050.",
    "active": true,
    "alternatives": [
     {
      "body": "Edge 1050",
      "is_correct": false
     },
     {
      "body": "Edge 850",
      "is_correct": false
     },
     {
      "body": "Edge 1040",
      "is_correct": true
     },
     {
      "body": "Edge 550",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quanto de memória o Edge 1050 tem?",
    "explanation": "A mesma capacidade do 1040: 32 GB, com suporte a cartão externo.",
    "active": true,
    "alternatives": [
     {
      "body": "64 GB, o dobro do 1040",
      "is_correct": false
     },
     {
      "body": "32 GB com cartão, como o 1040",
      "is_correct": true
     },
     {
      "body": "16 GB, sem cartão externo",
      "is_correct": false
     },
     {
      "body": "128 GB, com cartão externo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Para que serve o alto-falante embutido do Edge 1050?",
    "explanation": "Funciona como campainha e emite avisos sonoros de treino e navegação.",
    "active": true,
    "alternatives": [
     {
      "body": "Campainha e avisos sonoros",
      "is_correct": true
     },
     {
      "body": "Ouvir música durante o pedal",
      "is_correct": false
     },
     {
      "body": "Fazer e receber ligações",
      "is_correct": false
     },
     {
      "body": "Dar comandos por voz ao Edge",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "rally-100",
  "quiz_id": "a2eff595-0f05-4f11-bf82-f0e50a88996c",
  "questions": [
   {
    "body": "Como o Rally 100 mede a potência?",
    "explanation": "Mede a potência total, sem separar as pernas. Balanço esquerda/direita é do Rally 200/210.",
    "active": true,
    "alternatives": [
     {
      "body": "Dual-sensing, perna a perna",
      "is_correct": false
     },
     {
      "body": "Single-sensing, com balanço E/D",
      "is_correct": false
     },
     {
      "body": "Single-sensing, só a potência total",
      "is_correct": true
     },
     {
      "body": "Dual-sensing, sem medir cadência",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a precisão do Rally 100?",
    "explanation": "±1%, o mesmo padrão de medidores profissionais.",
    "active": true,
    "alternatives": [
     {
      "body": "±2%",
      "is_correct": false
     },
     {
      "body": "±1%",
      "is_correct": true
     },
     {
      "body": "±5%",
      "is_correct": false
     },
     {
      "body": "±0,5%",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como é a bateria do Rally 100?",
    "explanation": "Bateria substituível de até 120 h. A recarregável chegou no Rally 210.",
    "active": true,
    "alternatives": [
     {
      "body": "Substituível, até 120 h",
      "is_correct": true
     },
     {
      "body": "Recarregável, até 90 h",
      "is_correct": false
     },
     {
      "body": "Substituível, até 90 h",
      "is_correct": false
     },
     {
      "body": "Recarregável, até 120 h",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a diferença entre o RK100 e o RS100?",
    "explanation": "Só muda o encaixe do pedal. Sensor, bateria e precisão são idênticos.",
    "active": true,
    "alternatives": [
     {
      "body": "RK é SPD-SL; RS é LOOK KEO",
      "is_correct": false
     },
     {
      "body": "RK é de estrada; RS é de MTB",
      "is_correct": false
     },
     {
      "body": "RK é single; RS é dual-sensing",
      "is_correct": false
     },
     {
      "body": "RK é LOOK KEO; RS é SHIMANO SPD-SL",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é a decisão mais importante antes de fechar a venda de um Rally?",
    "explanation": "LOOK KEO usa o RK, SHIMANO SPD-SL usa o RS. Confirme antes de fechar.",
    "active": true,
    "alternatives": [
     {
      "body": "A marca do pedivela da bicicleta",
      "is_correct": false
     },
     {
      "body": "O modelo de Edge que o cliente usa",
      "is_correct": false
     },
     {
      "body": "O sistema de taquinho da sapatilha",
      "is_correct": true
     },
     {
      "body": "O peso do ciclista para calibrar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer saber quanto cada perna contribui na pedalada. O que indicar?",
    "explanation": "O Rally 200 é dual-sensing e mede cada perna de forma independente.",
    "active": true,
    "alternatives": [
     {
      "body": "Rally 100",
      "is_correct": false
     },
     {
      "body": "Rally 200",
      "is_correct": true
     },
     {
      "body": "RS100",
      "is_correct": false
     },
     {
      "body": "Rally 100 com Edge",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que significa o eixo transferível do Rally?",
    "explanation": "Dá para usar o mesmo sensor em bicicletas diferentes.",
    "active": true,
    "alternatives": [
     {
      "body": "O sensor troca de corpo de pedal sem perder a calibração",
      "is_correct": true
     },
     {
      "body": "O pedal se adapta a qualquer modelo de sapatilha",
      "is_correct": false
     },
     {
      "body": "O eixo ajusta sozinho a largura entre os pedais",
      "is_correct": false
     },
     {
      "body": "O sensor continua medindo mesmo sem bateria",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Com o que o Rally 100 é compatível?",
    "explanation": "Funciona com Edge, Garmin Connect e plataformas como Zwift, TrainerRoad e Tacx Training App.",
    "active": true,
    "alternatives": [
     {
      "body": "Só com os ciclocomputadores Edge",
      "is_correct": false
     },
     {
      "body": "Só com os relógios da linha Forerunner",
      "is_correct": false
     },
     {
      "body": "Só com o aplicativo Garmin Connect",
      "is_correct": false
     },
     {
      "body": "Edge, Connect, Zwift, TrainerRoad e Tacx",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é a resistência à água do Rally 100?",
    "explanation": "IPX7, protegido contra chuva e respingos.",
    "active": true,
    "alternatives": [
     {
      "body": "IPX4",
      "is_correct": false
     },
     {
      "body": "5 ATM",
      "is_correct": false
     },
     {
      "body": "IPX7",
      "is_correct": true
     },
     {
      "body": "IP67",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Rally 100 sucede qual produto da Garmin?",
    "explanation": "O Rally 100 sucede o Vector 3S. O Rally 200 sucede o Vector 3.",
    "active": true,
    "alternatives": [
     {
      "body": "Vector 3",
      "is_correct": false
     },
     {
      "body": "Vector 3S",
      "is_correct": true
     },
     {
      "body": "Rally 200",
      "is_correct": false
     },
     {
      "body": "Edge 530",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "rally-200",
  "quiz_id": "1a27b80f-443a-4a88-aa13-26d39b164e48",
  "questions": [
   {
    "body": "Como o Rally 200 mede a potência?",
    "explanation": "Mede potência total, cadência e dinâmica com dados independentes de cada perna.",
    "active": true,
    "alternatives": [
     {
      "body": "Single-sensing, só o total",
      "is_correct": false
     },
     {
      "body": "Dual-sensing, só a cadência",
      "is_correct": false
     },
     {
      "body": "Single-sensing, com giroscópio",
      "is_correct": false
     },
     {
      "body": "Dual-sensing, perna a perna",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como é a bateria do Rally 200?",
    "explanation": "Bateria substituível de até 120 h. A recarregável é exclusiva do Rally 210.",
    "active": true,
    "alternatives": [
     {
      "body": "Recarregável, até 90 h",
      "is_correct": false
     },
     {
      "body": "Substituível, até 90 h",
      "is_correct": false
     },
     {
      "body": "Substituível, até 120 h",
      "is_correct": true
     },
     {
      "body": "Recarregável, até 120 h",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Rally 210 adiciona em relação ao 200?",
    "explanation": "Dual-sensing, eixo transferível, ±1% e off-road já estavam no Rally 200.",
    "active": true,
    "alternatives": [
     {
      "body": "Dual-sensing e balanço esquerda/direita",
      "is_correct": false
     },
     {
      "body": "Bateria recarregável, giroscópio e Pedal IQ",
      "is_correct": true
     },
     {
      "body": "Eixo transferível e precisão de ±1%",
      "is_correct": false
     },
     {
      "body": "A primeira opção off-road da linha",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente pergunta se dá para usar o Rally 200 na mountain bike. O que dizer?",
    "explanation": "O eixo sensor é transferível para o corpo de pedal off-road XC, vendido separadamente.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, com o corpo de pedal XC vendido à parte",
      "is_correct": true
     },
     {
      "body": "Não, ele é só para pedais de estrada",
      "is_correct": false
     },
     {
      "body": "Sim, ele já vem com o corpo XC na caixa",
      "is_correct": false
     },
     {
      "body": "Só com o taquinho LOOK KEO instalado",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que a família Rally trouxe em relação ao antigo Vector 3?",
    "explanation": "Dual-sensing, ±1% e bateria substituível já existiam no Vector 3.",
    "active": true,
    "alternatives": [
     {
      "body": "Medição dual-sensing com precisão de ±1%",
      "is_correct": false
     },
     {
      "body": "Bateria recarregável com carga rápida",
      "is_correct": false
     },
     {
      "body": "Giroscópio para esforços curtos",
      "is_correct": false
     },
     {
      "body": "Opção off-road e corpos de pedal trocáveis",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Quando o Rally 200 faz mais sentido que o 210?",
    "explanation": "O 200 dura mais horas por carga (120 h) e custa menos, sem o giroscópio.",
    "active": true,
    "alternatives": [
     {
      "body": "Quando o cliente quer recarga rápida",
      "is_correct": false
     },
     {
      "body": "Quando o cliente usa coroa oval",
      "is_correct": false
     },
     {
      "body": "Quando o cliente quer meses sem recarga",
      "is_correct": true
     },
     {
      "body": "Quando o cliente faz muitos sprints",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quais dados a dinâmica de pedalada avançada traz?",
    "explanation": "Balanço esquerda/direita, tempo sentado e em pé, fase de potência e mais.",
    "active": true,
    "alternatives": [
     {
      "body": "Velocidade, distância e ganho de elevação",
      "is_correct": false
     },
     {
      "body": "Balanço E/D, sentado x em pé e fase de potência",
      "is_correct": true
     },
     {
      "body": "Frequência cardíaca e calorias gastas",
      "is_correct": false
     },
     {
      "body": "Apenas a cadência média da pedalada",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O ciclista quer identificar e corrigir um desequilíbrio entre as pernas. O que indicar?",
    "explanation": "O balanço esquerda/direita do dual-sensing mostra a assimetria.",
    "active": true,
    "alternatives": [
     {
      "body": "Rally 200",
      "is_correct": true
     },
     {
      "body": "Rally 100",
      "is_correct": false
     },
     {
      "body": "RS100",
      "is_correct": false
     },
     {
      "body": "Speed Sensor 2",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente usa sapatilha com taquinho SHIMANO SPD-SL. Qual versão?",
    "explanation": "RS200 é SHIMANO SPD-SL. RK200 é LOOK KEO.",
    "active": true,
    "alternatives": [
     {
      "body": "RK200",
      "is_correct": false
     },
     {
      "body": "XC200",
      "is_correct": false
     },
     {
      "body": "RK100",
      "is_correct": false
     },
     {
      "body": "RS200",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O triatleta tem uma bike de treino e outra de prova. Como aproveitar o Rally 200?",
    "explanation": "O sensor troca de corpo de pedal: não é preciso um medidor por bicicleta.",
    "active": true,
    "alternatives": [
     {
      "body": "Comprando um Rally para cada bike",
      "is_correct": false
     },
     {
      "body": "Usando o Rally só na bike de prova",
      "is_correct": false
     },
     {
      "body": "Trocando o sensor entre as bikes",
      "is_correct": true
     },
     {
      "body": "Trocando para o Rally 100",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "rally-210",
  "quiz_id": "398bcc28-e4bc-4831-8ce7-896d6fed6607",
  "questions": [
   {
    "body": "Como é a bateria do Rally 210?",
    "explanation": "Até 90 h por carga, e 15 minutos de carga rápida rendem 12 h de pedal.",
    "active": true,
    "alternatives": [
     {
      "body": "Recarregável, 90 h; 15 min = 12 h",
      "is_correct": true
     },
     {
      "body": "Substituível, até 120 h de uso",
      "is_correct": false
     },
     {
      "body": "Recarregável, 120 h; 15 min = 20 h",
      "is_correct": false
     },
     {
      "body": "Recarregável, 60 h; 30 min = 12 h",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Para que serve o giroscópio do Rally 210?",
    "explanation": "Deixa a potência mais responsiva em esforços curtos e dá suporte a coroa oval.",
    "active": true,
    "alternatives": [
     {
      "body": "Medir a inclinação da bike nas subidas",
      "is_correct": false
     },
     {
      "body": "Detectar quedas e avisar os contatos",
      "is_correct": false
     },
     {
      "body": "Calibrar o ClimbPro do Edge pareado",
      "is_correct": false
     },
     {
      "body": "Medição mais rápida e coroa oval",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que é o Pedal IQ?",
    "explanation": "O Pedal IQ alerta quando é hora de recalibrar.",
    "active": true,
    "alternatives": [
     {
      "body": "Calibração feita sozinha a cada pedalada do ciclista",
      "is_correct": false
     },
     {
      "body": "Ajuste automático da tensão do taquinho no pedal",
      "is_correct": false
     },
     {
      "body": "Aviso de recalibrar por temperatura, tempo e troca de bike",
      "is_correct": true
     },
     {
      "body": "Medição do desgaste do rolamento do pedal",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Modo Viagem faz?",
    "explanation": "Coloca os pedais em economia durante o transporte, evitando descarga.",
    "active": true,
    "alternatives": [
     {
      "body": "Ativa o GPS durante a viagem",
      "is_correct": false
     },
     {
      "body": "Economiza bateria no transporte",
      "is_correct": true
     },
     {
      "body": "Trava o pedal contra furtos",
      "is_correct": false
     },
     {
      "body": "Reduz a precisão para durar mais",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quanto pesa o Rally 210 de estrada, comparado ao Rally 200?",
    "explanation": "O novo design em polímero de carbono deixou o RK210 mais leve: 315 g contra 326 g.",
    "active": true,
    "alternatives": [
     {
      "body": "315 g contra 326 g do 200",
      "is_correct": true
     },
     {
      "body": "326 g contra 315 g do 200",
      "is_correct": false
     },
     {
      "body": "290 g contra 326 g do 200",
      "is_correct": false
     },
     {
      "body": "315 g contra 350 g do 200",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Preciso ter coroa oval para aproveitar o giroscópio?” Qual é a resposta?",
    "explanation": "O giroscópio melhora a responsividade para todos. O suporte a coroa oval é um extra.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, ele só funciona com coroa oval",
      "is_correct": false
     },
     {
      "body": "Sim, sem a oval ele não mede potência",
      "is_correct": false
     },
     {
      "body": "Não, mas ele fica desativado sem a oval",
      "is_correct": false
     },
     {
      "body": "Não; ajuda qualquer ciclista, e a oval é bônus",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como falar da bateria do Rally 210 com transparência?",
    "explanation": "90 h contra 120 h do 200, mas a recarga rápida resolve no dia a dia e não exige comprar bateria.",
    "active": true,
    "alternatives": [
     {
      "body": "Dura mais horas por carga que o Rally 200",
      "is_correct": false
     },
     {
      "body": "Dura o mesmo que o Rally 200 por carga",
      "is_correct": false
     },
     {
      "body": "Menos horas por carga, mas recarrega rápido",
      "is_correct": true
     },
     {
      "body": "Não precisa ser recarregada nunca",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O ciclista compete e faz muitos sprints. Qual pedal indicar?",
    "explanation": "O giroscópio do 210 deixa a medição mais instantânea em esforços curtos.",
    "active": true,
    "alternatives": [
     {
      "body": "Rally 200",
      "is_correct": false
     },
     {
      "body": "Rally 210",
      "is_correct": true
     },
     {
      "body": "Rally 100",
      "is_correct": false
     },
     {
      "body": "RS100",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente prioriza ficar meses sem pensar em bateria. Qual pedal indicar?",
    "explanation": "O Rally 200 dura mais horas por carga, com bateria substituível.",
    "active": true,
    "alternatives": [
     {
      "body": "Rally 200",
      "is_correct": true
     },
     {
      "body": "Rally 210",
      "is_correct": false
     },
     {
      "body": "RK210",
      "is_correct": false
     },
     {
      "body": "RS210",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente usa taquinho LOOK KEO. Qual versão do Rally 210?",
    "explanation": "RK210 é LOOK KEO. RS210 é SHIMANO SPD-SL.",
    "active": true,
    "alternatives": [
     {
      "body": "RS210",
      "is_correct": false
     },
     {
      "body": "XC210",
      "is_correct": false
     },
     {
      "body": "RK100",
      "is_correct": false
     },
     {
      "body": "RK210",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "hrm-200",
  "quiz_id": "444eafa1-a879-40a5-881c-12642065e9b1",
  "questions": [
   {
    "body": "O que a HRM 200 mede?",
    "explanation": "A HRM 200 é só frequência cardíaca e HRV. Dinâmica de Corrida e Step Speed Loss são da HRM 600.",
    "active": true,
    "alternatives": [
     {
      "body": "FC, HRV e Dinâmica de Corrida",
      "is_correct": false
     },
     {
      "body": "Frequência cardíaca e HRV",
      "is_correct": true
     },
     {
      "body": "FC e Step Speed Loss",
      "is_correct": false
     },
     {
      "body": "FC, HRV e potência de corrida",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como é a bateria da HRM 200?",
    "explanation": "Bateria de moeda CR2032 substituível, com cerca de 1 ano a 1 h de uso por dia.",
    "active": true,
    "alternatives": [
     {
      "body": "CR2032, dura cerca de 1 ano",
      "is_correct": true
     },
     {
      "body": "Recarregável, cerca de 2 meses",
      "is_correct": false
     },
     {
      "body": "CR2032, dura cerca de 6 meses",
      "is_correct": false
     },
     {
      "body": "Recarregável, cerca de 1 ano",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a resistência à água da HRM 200?",
    "explanation": "3 ATM cobre suor e chuva. Para nadar, a cinta certa é a HRM 600 (5 ATM).",
    "active": true,
    "alternatives": [
     {
      "body": "5 ATM, resistente à natação",
      "is_correct": false
     },
     {
      "body": "10 ATM, própria para mergulho",
      "is_correct": false
     },
     {
      "body": "IPX4, só contra respingos",
      "is_correct": false
     },
     {
      "body": "3 ATM, sem indicação para nadar",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Quantos dispositivos se conectam à HRM 200 ao mesmo tempo?",
    "explanation": "ANT+ aceita conexões ilimitadas, e o Bluetooth Low Energy, até 3 dispositivos.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 3 por ANT+ e ilimitados por Bluetooth",
      "is_correct": false
     },
     {
      "body": "Só 1 por vez, em qualquer protocolo",
      "is_correct": false
     },
     {
      "body": "Ilimitados por ANT+ e até 3 por Bluetooth",
      "is_correct": true
     },
     {
      "body": "Até 10 por Bluetooth e nenhum por ANT+",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Para que serve o Bluetooth seguro da HRM 200?",
    "explanation": "Evita que a cinta se conecte por acidente a outro aparelho, comum em academias cheias.",
    "active": true,
    "alternatives": [
     {
      "body": "Criptografar os dados de saúde",
      "is_correct": false
     },
     {
      "body": "Evitar conexão com o aparelho errado",
      "is_correct": true
     },
     {
      "body": "Aumentar o alcance da conexão",
      "is_correct": false
     },
     {
      "body": "Economizar a bateria da cinta",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quais tamanhos de cinta vêm na caixa da HRM 200?",
    "explanation": "Duas cintas, XS-S e M-XL, incluídas na caixa.",
    "active": true,
    "alternatives": [
     {
      "body": "XS-S e M-XL",
      "is_correct": true
     },
     {
      "body": "Tamanho único",
      "is_correct": false
     },
     {
      "body": "S, M e L",
      "is_correct": false
     },
     {
      "body": "Só M-XL",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Meu relógio já mede FC no pulso, pra que uma cinta?” Qual resposta segue a ficha?",
    "explanation": "A leitura óptica varia mais em esforço intenso. A cinta capta o sinal direto do músculo cardíaco.",
    "active": true,
    "alternatives": [
     {
      "body": "O sensor de pulso para de medir em treinos intensos",
      "is_correct": false
     },
     {
      "body": "A cinta é obrigatória para registrar qualquer treino",
      "is_correct": false
     },
     {
      "body": "A cinta também mede a potência e o VO2 Max",
      "is_correct": false
     },
     {
      "body": "A cinta lê o sinal elétrico, mais estável na intensidade",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente vai usar a cinta também na natação. O que indicar?",
    "explanation": "A HRM 200 é 3 ATM e não é indicada para nado. A HRM 600 é 5 ATM e guarda os dados debaixo d’água.",
    "active": true,
    "alternatives": [
     {
      "body": "HRM 200",
      "is_correct": false
     },
     {
      "body": "HRM 200 com capa",
      "is_correct": false
     },
     {
      "body": "HRM 600",
      "is_correct": true
     },
     {
      "body": "Sensor óptico",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O ciclista treina no Zwift e quer FC estável gastando o mínimo. O que indicar?",
    "explanation": "A HRM 200 entrega FC confiável no treino indoor, com o menor investimento da linha.",
    "active": true,
    "alternatives": [
     {
      "body": "HRM 600",
      "is_correct": false
     },
     {
      "body": "HRM 200",
      "is_correct": true
     },
     {
      "body": "Speed Sensor 2",
      "is_correct": false
     },
     {
      "body": "Rally 100",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que a HRM 600 soma em relação à HRM 200?",
    "explanation": "Bluetooth seguro, ANT+ e módulo destacável as duas têm. A 600 soma Dinâmica completa, Step Speed Loss, gravação sozinha e 5 ATM.",
    "active": true,
    "alternatives": [
     {
      "body": "Dinâmica, gravação sozinha e natação",
      "is_correct": true
     },
     {
      "body": "Bluetooth seguro e transmissão por ANT+",
      "is_correct": false
     },
     {
      "body": "Bateria de moeda e módulo destacável",
      "is_correct": false
     },
     {
      "body": "FC e HRV mais precisas que as da 200",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "hrm-600",
  "quiz_id": "029a3b38-fd88-4e92-b488-0676816a7b93",
  "questions": [
   {
    "body": "Quanto a HRM 600 grava sozinha, sem relógio nem celular?",
    "explanation": "Grava até 24 h por sessão em mais de 18 modalidades e sincroniza depois com o Garmin Connect.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 12 h, só em atividades de corrida",
      "is_correct": false
     },
     {
      "body": "Até 300 h, em qualquer modalidade",
      "is_correct": false
     },
     {
      "body": "Até 24 h, em mais de 18 modalidades",
      "is_correct": true
     },
     {
      "body": "Até 24 h, só em atividades de natação",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como é a bateria da HRM 600?",
    "explanation": "Recarregável, com cerca de 2 meses a 1 h de uso por dia.",
    "active": true,
    "alternatives": [
     {
      "body": "CR2032, dura cerca de 1 ano",
      "is_correct": false
     },
     {
      "body": "Recarregável, cerca de 2 meses",
      "is_correct": true
     },
     {
      "body": "Recarregável, cerca de 1 ano",
      "is_correct": false
     },
     {
      "body": "Recarregável, cerca de 2 semanas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que a métrica Step Speed Loss mostra?",
    "explanation": "É exclusiva da HRM 600 e mostra onde a técnica perde eficiência em cada passada.",
    "active": true,
    "alternatives": [
     {
      "body": "A perda de velocidade em cada passada",
      "is_correct": true
     },
     {
      "body": "A oscilação vertical do corpo na corrida",
      "is_correct": false
     },
     {
      "body": "O tempo de contato do pé com o solo",
      "is_correct": false
     },
     {
      "body": "O comprimento médio de cada passada",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Dá para nadar com a HRM 600?",
    "explanation": "É 5 ATM. Como o sinal não atravessa a água, ela guarda os dados e sincroniza depois.",
    "active": true,
    "alternatives": [
     {
      "body": "Não, ela é 3 ATM, só suor e chuva",
      "is_correct": false
     },
     {
      "body": "Sim, mas só em piscina de água doce",
      "is_correct": false
     },
     {
      "body": "Não, só com uma capa à prova d’água",
      "is_correct": false
     },
     {
      "body": "Sim, 5 ATM, e ela guarda os dados na água",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O jogador de futebol amador não usa relógio em campo e quer registrar o jogo. O que indicar?",
    "explanation": "A gravação autônoma registra o jogo inteiro sem relógio no pulso.",
    "active": true,
    "alternatives": [
     {
      "body": "HRM 200",
      "is_correct": false
     },
     {
      "body": "Forerunner 970",
      "is_correct": false
     },
     {
      "body": "HRM 600",
      "is_correct": true
     },
     {
      "body": "Instinct 3",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “A bateria recarregável não é pior que a de moeda?” Qual resposta segue a ficha?",
    "explanation": "Cerca de 2 meses por carga contra cerca de 1 ano da moeda, mas sem comprar bateria nova e com carga rápida.",
    "active": true,
    "alternatives": [
     {
      "body": "É pior, porque dura bem menos em qualquer uso",
      "is_correct": false
     },
     {
      "body": "Dura menos por carga, mas nunca exige comprar bateria",
      "is_correct": true
     },
     {
      "body": "É igual à de moeda em duração e manutenção",
      "is_correct": false
     },
     {
      "body": "Dura mais que a de moeda e carrega sozinha",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente só precisa de FC e HRV, sem métricas de corrida. O que indicar?",
    "explanation": "Sem Dinâmica de Corrida nem gravação autônoma, a HRM 200 cobre bem por um preço menor.",
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
      "body": "HRM 600 com relógio",
      "is_correct": false
     },
     {
      "body": "Sensor de cadência",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como a HRM 600 recebe atualizações de firmware?",
    "explanation": "A HRM 600 recebe melhorias por atualização sem fio.",
    "active": true,
    "alternatives": [
     {
      "body": "Por cabo USB",
      "is_correct": false
     },
     {
      "body": "Só na assistência",
      "is_correct": false
     },
     {
      "body": "Ela não recebe",
      "is_correct": false
     },
     {
      "body": "Sem fio",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Quais métricas formam a Dinâmica de Corrida completa da HRM 600?",
    "explanation": "Cadência, comprimento de passada, oscilação e proporção vertical, tempo de contato e equilíbrio.",
    "active": true,
    "alternatives": [
     {
      "body": "Potência, VO2 Max e limiar de lactato",
      "is_correct": false
     },
     {
      "body": "Distância, pace e calorias gastas",
      "is_correct": false
     },
     {
      "body": "Cadência, oscilação e contato com o solo",
      "is_correct": true
     },
     {
      "body": "FC máxima e zonas de frequência",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Por que pagar mais na HRM 600 se já tenho relógio?” O que responder?",
    "explanation": "Se ele sempre usa relógio e não precisa desses dois recursos, a HRM 200 já cobre.",
    "active": true,
    "alternatives": [
     {
      "body": "Porque o relógio não consegue medir a FC no treino",
      "is_correct": false
     },
     {
      "body": "Vale pela gravação sem relógio ou pelo Step Speed Loss",
      "is_correct": true
     },
     {
      "body": "Porque a 600 é mais confortável que a HRM 200",
      "is_correct": false
     },
     {
      "body": "Porque só a 600 transmite os dados por ANT+",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "index-s2",
  "quiz_id": "59d033a7-793f-4935-9e2f-84ac0d7bbfe6",
  "questions": [
   {
    "body": "O que a Index S2 mede além do peso?",
    "explanation": "Por bioimpedância: IMC, % de gordura, % de água, massa muscular esquelética e massa óssea.",
    "active": true,
    "alternatives": [
     {
      "body": "IMC, pressão arterial e frequência cardíaca",
      "is_correct": false
     },
     {
      "body": "Gordura, frequência cardíaca e glicemia",
      "is_correct": false
     },
     {
      "body": "IMC, glicemia e saturação de oxigênio",
      "is_correct": false
     },
     {
      "body": "IMC, gordura, água, massa muscular e óssea",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como a Index S2 sincroniza os dados?",
    "explanation": "Conecta direto por Wi-Fi e envia os dados ao Garmin Connect sozinha.",
    "active": true,
    "alternatives": [
     {
      "body": "Por Bluetooth, com o celular perto",
      "is_correct": false
     },
     {
      "body": "Por cabo USB ligado ao computador",
      "is_correct": false
     },
     {
      "body": "Por Wi-Fi, sem o celular por perto",
      "is_correct": true
     },
     {
      "body": "Pelo relógio Garmin pareado",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quantos perfis de usuário a Index S2 reconhece automaticamente?",
    "explanation": "Até 16 perfis, cada um com o próprio histórico.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 8",
      "is_correct": false
     },
     {
      "body": "Até 16",
      "is_correct": true
     },
     {
      "body": "Até 4",
      "is_correct": false
     },
     {
      "body": "Até 32",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a carga máxima da Index S2?",
    "explanation": "181,4 kg, suficiente para a maioria dos usuários domésticos.",
    "active": true,
    "alternatives": [
     {
      "body": "181,4 kg",
      "is_correct": true
     },
     {
      "body": "158,8 kg",
      "is_correct": false
     },
     {
      "body": "204,1 kg",
      "is_correct": false
     },
     {
      "body": "136,1 kg",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Essa medição de bioimpedância é precisa?” Qual resposta segue a ficha?",
    "explanation": "É uma estimativa doméstica útil para ver a evolução ao longo do tempo. Não substitui exame clínico.",
    "active": true,
    "alternatives": [
     {
      "body": "Tem a mesma precisão de um exame clínico de laboratório",
      "is_correct": false
     },
     {
      "body": "Serve para diagnosticar obesidade e sobrepeso",
      "is_correct": false
     },
     {
      "body": "É mais precisa que qualquer exame de densitometria",
      "is_correct": false
     },
     {
      "body": "É estimativa para acompanhar a tendência, sem ser exame",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como a Index S2 funciona para uma família inteira?",
    "explanation": "Identifica quem subiu pelo peso e pelo padrão de bioimpedância, sem seleção manual.",
    "active": true,
    "alternatives": [
     {
      "body": "Cada pessoa escolhe o usuário antes de pesar",
      "is_correct": false
     },
     {
      "body": "Guarda um único perfil para toda a casa",
      "is_correct": false
     },
     {
      "body": "Reconhece quem subiu e separa o histórico",
      "is_correct": true
     },
     {
      "body": "Exige uma balança para cada pessoa da casa",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Em qual caso a Index S2 não é a melhor indicação?",
    "explanation": "Sem o Garmin Connect, a balança perde a maior parte da utilidade.",
    "active": true,
    "alternatives": [
     {
      "body": "O cliente já tem um relógio Garmin no pulso",
      "is_correct": false
     },
     {
      "body": "O cliente não usa nem vai usar o Garmin Connect",
      "is_correct": true
     },
     {
      "body": "A família tem várias pessoas que vão se pesar",
      "is_correct": false
     },
     {
      "body": "O cliente quer ver a tendência ao longo do tempo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que a tela da Index S2 mostra?",
    "explanation": "A tela colorida mostra peso e tendência sem precisar abrir o app.",
    "active": true,
    "alternatives": [
     {
      "body": "Peso e tendência na hora, em cores",
      "is_correct": true
     },
     {
      "body": "Nada, os dados aparecem só no app",
      "is_correct": false
     },
     {
      "body": "Só o peso, numa tela monocromática",
      "is_correct": false
     },
     {
      "body": "Os dados, em uma tela touchscreen",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como abrir a venda da Index S2 para quem já usa o Garmin Connect?",
    "explanation": "Peso e composição aparecem junto dos dados de treino e recuperação, sem digitar nada.",
    "active": true,
    "alternatives": [
     {
      "body": "Ela substitui o relógio no acompanhamento de treino e de sono",
      "is_correct": false
     },
     {
      "body": "Ela mede a pressão arterial junto com os dados do relógio",
      "is_correct": false
     },
     {
      "body": "Ela calcula o VO2 Max a partir da composição corporal",
      "is_correct": false
     },
     {
      "body": "Ela completa o quadro com composição corporal, sozinha por Wi-Fi",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente já usa relógio Garmin e quer acompanhar o peso no mesmo app. O que indicar?",
    "explanation": "A Index S2 soma composição corporal ao histórico do Garmin Connect.",
    "active": true,
    "alternatives": [
     {
      "body": "HRM 200",
      "is_correct": false
     },
     {
      "body": "Venu 4",
      "is_correct": false
     },
     {
      "body": "Index S2",
      "is_correct": true
     },
     {
      "body": "HRM 600",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "inreach-mini-2",
  "quiz_id": "75337628-7347-45f1-847e-ba8554bd217e",
  "questions": [
   {
    "body": "Qual é a bateria do inReach Mini 2?",
    "explanation": "Até 30 dias com rastreio a cada 30 min e 14 dias a cada 10 min. 350 h é o Mini 3, e 330 h, o Mini 3 Plus.",
    "active": true,
    "alternatives": [
     {
      "body": "30 dias (rastreio 30 min) ou 14 dias (10 min)",
      "is_correct": true
     },
     {
      "body": "14 dias (rastreio 30 min) ou 30 dias (10 min)",
      "is_correct": false
     },
     {
      "body": "Até 350 h, com rastreio a cada 10 minutos",
      "is_correct": false
     },
     {
      "body": "Até 330 h, com rastreio a cada 10 minutos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quanto pesa o inReach Mini 2?",
    "explanation": "3,5 oz, cerca de 100 g, um dos comunicadores mais leves da Garmin.",
    "active": true,
    "alternatives": [
     {
      "body": "Cerca de 122 g",
      "is_correct": false
     },
     {
      "body": "Cerca de 139 g",
      "is_correct": false
     },
     {
      "body": "Cerca de 200 g",
      "is_correct": false
     },
     {
      "body": "Cerca de 100 g",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como é a tela do inReach Mini 2?",
    "explanation": "Tela monocromática transflectiva, controlada só por botão físico.",
    "active": true,
    "alternatives": [
     {
      "body": "Colorida, com touchscreen",
      "is_correct": false
     },
     {
      "body": "Colorida, só com botões",
      "is_correct": false
     },
     {
      "body": "Monocromática, só com botões",
      "is_correct": true
     },
     {
      "body": "Monocromática, com touch",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a resistência do inReach Mini 2?",
    "explanation": "IPX7, contra chuva e imersão acidental. O Mini 3 sobe para IP67, com proteção contra poeira.",
    "active": true,
    "alternatives": [
     {
      "body": "IP67",
      "is_correct": false
     },
     {
      "body": "IPX7",
      "is_correct": true
     },
     {
      "body": "5 ATM",
      "is_correct": false
     },
     {
      "body": "IPX4",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Por qual rede o inReach Mini 2 se comunica?",
    "explanation": "Rede de satélites Iridium, com cobertura mundial.",
    "active": true,
    "alternatives": [
     {
      "body": "Iridium",
      "is_correct": true
     },
     {
      "body": "GPS",
      "is_correct": false
     },
     {
      "body": "GLONASS",
      "is_correct": false
     },
     {
      "body": "4G rural",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Preciso de assinatura para usar o Mini 2?” Qual é a resposta?",
    "explanation": "Os planos são contratados à parte, a partir de US$ 11,95/mês, com opção mensal ou anual.",
    "active": true,
    "alternatives": [
     {
      "body": "Não, o uso do satélite já vem incluso",
      "is_correct": false
     },
     {
      "body": "Só para o SOS; o texto é gratuito",
      "is_correct": false
     },
     {
      "body": "Só para usar fora do território nacional",
      "is_correct": false
     },
     {
      "body": "Sim, um plano de satélite contratado à parte",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que acontece com a bateria do Mini 2 desligado?",
    "explanation": "Desligado, o Mini 2 mantém a carga por até um ano.",
    "active": true,
    "alternatives": [
     {
      "body": "Descarrega em cerca de uma semana",
      "is_correct": false
     },
     {
      "body": "Precisa ficar ligado na tomada",
      "is_correct": false
     },
     {
      "body": "Mantém a carga por até um ano",
      "is_correct": true
     },
     {
      "body": "Mantém a carga por até 30 dias",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O mochileiro de longa distância quer o comunicador mais leve possível. O que indicar?",
    "explanation": "O Mini 2 é o mais leve da linha, com bateria de semanas.",
    "active": true,
    "alternatives": [
     {
      "body": "inReach Mini 3 Plus",
      "is_correct": false
     },
     {
      "body": "inReach Mini 2",
      "is_correct": true
     },
     {
      "body": "inReach Mini 3",
      "is_correct": false
     },
     {
      "body": "GPSMAP 67",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer mandar foto e mensagem de voz durante a trilha. O que indicar?",
    "explanation": "Foto e voz são exclusivos do inReach Mini 3 Plus.",
    "active": true,
    "alternatives": [
     {
      "body": "inReach Mini 3 Plus",
      "is_correct": true
     },
     {
      "body": "inReach Mini 2 padrão",
      "is_correct": false
     },
     {
      "body": "inReach Mini 3 comum",
      "is_correct": false
     },
     {
      "body": "Mini 2 com o app Explore",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Mini 2 faz quando pareado com aparelhos Garmin compatíveis?",
    "explanation": "Pode ser pareado com mais de 80 dispositivos Garmin para estender a funcionalidade inReach.",
    "active": true,
    "alternatives": [
     {
      "body": "Recarrega a bateria do relógio pareado",
      "is_correct": false
     },
     {
      "body": "Dispensa o plano de satélite ativo",
      "is_correct": false
     },
     {
      "body": "Transforma o relógio num celular",
      "is_correct": false
     },
     {
      "body": "Estende os recursos inReach para eles",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "inreach-mini-3",
  "quiz_id": "6be70baf-98e7-4ba6-aa1d-fdb95b881a3f",
  "questions": [
   {
    "body": "Como é a tela do inReach Mini 3?",
    "explanation": "Tela de 1,9\" MIP transflectiva colorida, com toque e boa leitura sob sol.",
    "active": true,
    "alternatives": [
     {
      "body": "1,9\", AMOLED e touch",
      "is_correct": false
     },
     {
      "body": "1,9\", MIP colorida e touch",
      "is_correct": true
     },
     {
      "body": "Monocromática, com botões",
      "is_correct": false
     },
     {
      "body": "2,4\", colorida e com botões",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a bateria do Mini 3 em rastreio a cada 10 minutos?",
    "explanation": "Até 350 h, contra 336 h do Mini 2 e 330 h do Mini 3 Plus.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 350 h",
      "is_correct": true
     },
     {
      "body": "Até 336 h",
      "is_correct": false
     },
     {
      "body": "Até 330 h",
      "is_correct": false
     },
     {
      "body": "Até 170 h",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quanto dura a bateria do Mini 3 navegando com GPS?",
    "explanation": "Cerca de 170 h em modo GPS ou 120 h usando todos os sistemas de satélite.",
    "active": true,
    "alternatives": [
     {
      "body": "350 h em GPS ou 170 h com todos os sistemas",
      "is_correct": false
     },
     {
      "body": "120 h em GPS ou 90 h com todos os sistemas",
      "is_correct": false
     },
     {
      "body": "330 h em GPS ou 120 h com todos os sistemas",
      "is_correct": false
     },
     {
      "body": "170 h em GPS ou 120 h com todos os sistemas",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é a resistência do inReach Mini 3?",
    "explanation": "IP67, contra poeira, chuva forte e imersão acidental. O Mini 2 era IPX7.",
    "active": true,
    "alternatives": [
     {
      "body": "IPX7",
      "is_correct": false
     },
     {
      "body": "5 ATM",
      "is_correct": false
     },
     {
      "body": "IP67",
      "is_correct": true
     },
     {
      "body": "IP55",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual foi a novidade principal do Mini 3 na linha Mini?",
    "explanation": "SOS interativo e Iridium já vinham do Mini 2. Mensagem de voz é do Mini 3 Plus.",
    "active": true,
    "alternatives": [
     {
      "body": "O primeiro SOS interativo",
      "is_correct": false
     },
     {
      "body": "O primeiro touchscreen colorido",
      "is_correct": true
     },
     {
      "body": "A primeira conexão Iridium",
      "is_correct": false
     },
     {
      "body": "A primeira mensagem de voz",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Mini 3 Plus tem e o Mini 3 não tem?",
    "explanation": "O Mini 3 custa menos e dura um pouco mais. O Plus soma voz, foto e grupo.",
    "active": true,
    "alternatives": [
     {
      "body": "Voz, foto e texto em grupo",
      "is_correct": true
     },
     {
      "body": "Touchscreen colorido e IP67",
      "is_correct": false
     },
     {
      "body": "SOS interativo e TracBack",
      "is_correct": false
     },
     {
      "body": "Mais horas de bateria",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Vale trocar meu Mini 2 pelo Mini 3?” Qual resposta segue a ficha?",
    "explanation": "Se o cliente está satisfeito com botão e tela monocromática, o Mini 2 continua funcional.",
    "active": true,
    "alternatives": [
     {
      "body": "Vale pela mensagem de voz que chega no Mini 3",
      "is_correct": false
     },
     {
      "body": "Vale pela troca de fotos, que o Mini 2 não faz",
      "is_correct": false
     },
     {
      "body": "Não vale, porque os dois são praticamente iguais",
      "is_correct": false
     },
     {
      "body": "Vale pelo touch colorido, pela bateria e pelo IP67",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O trilheiro anda em ambiente com muita poeira. Qual inReach faz mais sentido entre Mini 2 e Mini 3?",
    "explanation": "O IP67 do Mini 3 protege contra poeira, além da água.",
    "active": true,
    "alternatives": [
     {
      "body": "Mini 2, com IPX7",
      "is_correct": false
     },
     {
      "body": "Os dois, igual",
      "is_correct": false
     },
     {
      "body": "Mini 3, com IP67",
      "is_correct": true
     },
     {
      "body": "Nenhum dos dois",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o app Garmin Explore oferece com o Mini 3?",
    "explanation": "Planejamento de rota, clima e mais recursos via smartphone.",
    "active": true,
    "alternatives": [
     {
      "body": "Envio de foto e de voz via satélite",
      "is_correct": false
     },
     {
      "body": "Rota e clima pelo celular",
      "is_correct": true
     },
     {
      "body": "Contratação automática do plano",
      "is_correct": false
     },
     {
      "body": "Atualização sem fio do firmware",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer o comunicador mais em conta possível. Qual inReach indicar?",
    "explanation": "O Mini 2 continua sendo uma opção válida para quem quer o menor investimento.",
    "active": true,
    "alternatives": [
     {
      "body": "inReach Mini 2",
      "is_correct": true
     },
     {
      "body": "inReach Mini 3",
      "is_correct": false
     },
     {
      "body": "inReach Mini 3 Plus",
      "is_correct": false
     },
     {
      "body": "Mini 3 com plano anual",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "inreach-mini-3-plus",
  "quiz_id": "2adfb76d-a189-41da-9fbf-52e64800d155",
  "questions": [
   {
    "body": "Como funciona a mensagem de voz do inReach Mini 3 Plus?",
    "explanation": "Grava até 30 s de áudio e o destinatário recebe o áudio e a transcrição, nos dois sentidos.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 60 s, sem nenhuma transcrição",
      "is_correct": false
     },
     {
      "body": "Até 30 s, só quando há Wi-Fi",
      "is_correct": false
     },
     {
      "body": "Até 30 s, com transcrição em texto",
      "is_correct": true
     },
     {
      "body": "Até 10 s, com transcrição em texto",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Por qual aplicativo o Mini 3 Plus envia e recebe fotos?",
    "explanation": "As fotos vão e vêm pelo app Garmin Messenger.",
    "active": true,
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
      "body": "Garmin Connect",
      "is_correct": false
     },
     {
      "body": "Garmin Express",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como é o texto do inReach Mini 3 Plus?",
    "explanation": "Mensagens de até 1.600 caracteres, com emoji, reações e conversas em grupo.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 1.600 caracteres, emoji e grupo",
      "is_correct": true
     },
     {
      "body": "Até 160 caracteres, sem emoji",
      "is_correct": false
     },
     {
      "body": "Até 500 caracteres, com emoji",
      "is_correct": false
     },
     {
      "body": "Até 1.600 caracteres, sem grupo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a bateria do Mini 3 Plus em rastreio a cada 10 minutos?",
    "explanation": "Até 330 h, um pouco menos que as 350 h do Mini 3.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 350 h",
      "is_correct": false
     },
     {
      "body": "Até 336 h",
      "is_correct": false
     },
     {
      "body": "Até 170 h",
      "is_correct": false
     },
     {
      "body": "Até 330 h",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Por que o Mini 3 Plus dura um pouco menos que o Mini 3?",
    "explanation": "O hardware de áudio consome energia extra. Ainda assim, 330 h é ótimo para semanas de expedição.",
    "active": true,
    "alternatives": [
     {
      "body": "Tela maior e mais brilhante",
      "is_correct": false
     },
     {
      "body": "GPS multibanda sempre ativo",
      "is_correct": false
     },
     {
      "body": "Alto-falante e microfone",
      "is_correct": true
     },
     {
      "body": "Câmera embutida no aparelho",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Mini 3 Plus é sucessor do Mini 3?",
    "explanation": "Os dois saíram no mesmo dia. O Plus é a versão mais completa, e o Mini 3, a mais enxuta.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, chegou meses depois do Mini 3",
      "is_correct": false
     },
     {
      "body": "Não, foram lançados juntos, como tiers",
      "is_correct": true
     },
     {
      "body": "Sim, substituiu o Mini 3 no catálogo",
      "is_correct": false
     },
     {
      "body": "Não, o Mini 3 é que sucede o Plus",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que muda no SOS do Mini 3 Plus?",
    "explanation": "Na emergência, além do texto, dá para compartilhar foto e voz com a central de resposta.",
    "active": true,
    "alternatives": [
     {
      "body": "Pode enviar foto e voz à central",
      "is_correct": true
     },
     {
      "body": "Liga direto para a polícia local",
      "is_correct": false
     },
     {
      "body": "Funciona sem plano de satélite",
      "is_correct": false
     },
     {
      "body": "Passa a depender do celular",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Preciso de um plano diferente para usar voz e foto?” O que fazer?",
    "explanation": "O material oficial não detalha planos por recurso. Confirme com o time de assinaturas antes de prometer.",
    "active": true,
    "alternatives": [
     {
      "body": "Dizer que qualquer plano libera tudo",
      "is_correct": false
     },
     {
      "body": "Dizer que só o plano anual libera",
      "is_correct": false
     },
     {
      "body": "Dizer que voz e foto dispensam plano",
      "is_correct": false
     },
     {
      "body": "Confirmar com o time de assinaturas",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O expedicionário quer mandar áudio e fotos para a família durante a viagem. O que indicar?",
    "explanation": "Voz e foto via satélite são exclusivos do Mini 3 Plus.",
    "active": true,
    "alternatives": [
     {
      "body": "inReach Mini 3 comum",
      "is_correct": false
     },
     {
      "body": "inReach Mini 2 padrão",
      "is_correct": false
     },
     {
      "body": "inReach Mini 3 Plus",
      "is_correct": true
     },
     {
      "body": "GPSMAP 67i com inReach",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente só precisa de texto simples e SOS e quer gastar menos. O que indicar?",
    "explanation": "Para texto e SOS, o Mini 3 ou até o Mini 2 resolvem por menos.",
    "active": true,
    "alternatives": [
     {
      "body": "Mini 3 Plus",
      "is_correct": false
     },
     {
      "body": "Mini 3 ou Mini 2",
      "is_correct": true
     },
     {
      "body": "Mini 3 Plus anual",
      "is_correct": false
     },
     {
      "body": "GPSMAP 67i",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "gpsmap-65",
  "quiz_id": "7498a326-62f8-442f-aecd-0f1a0e6f376c",
  "questions": [
   {
    "body": "Qual é a tela do GPSMAP 65?",
    "explanation": "Tela colorida de 2,6\", legível sob sol direto. O 66sr e o 67 têm 3\".",
    "active": true,
    "alternatives": [
     {
      "body": "Colorida de 3\"",
      "is_correct": false
     },
     {
      "body": "Monocromática de 2,2\"",
      "is_correct": false
     },
     {
      "body": "Touchscreen de 3,5\"",
      "is_correct": false
     },
     {
      "body": "Colorida de 2,6\"",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é a bateria do GPSMAP 65 em modo GPS?",
    "explanation": "Cerca de 16 h, que cobre bem uma trilha de um dia.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 36 h",
      "is_correct": false
     },
     {
      "body": "Até 450 h",
      "is_correct": false
     },
     {
      "body": "Até 16 h",
      "is_correct": true
     },
     {
      "body": "Até 35 h",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é o destaque técnico do GPSMAP 65?",
    "explanation": "Foi um dos primeiros GPS de mão Garmin a captar múltiplas frequências, mais preciso em mata fechada e cânion.",
    "active": true,
    "alternatives": [
     {
      "body": "O primeiro handheld com inReach embutido",
      "is_correct": false
     },
     {
      "body": "Um dos primeiros handhelds com multibanda",
      "is_correct": true
     },
     {
      "body": "O primeiro handheld com touchscreen",
      "is_correct": false
     },
     {
      "body": "O primeiro handheld com cartas náuticas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O GPSMAP 65 tem sensores ABC dedicados?",
    "explanation": "Altímetro e bússola são calculados por GPS. Para sensores dedicados, existe o 65s ou o 66sr.",
    "active": true,
    "alternatives": [
     {
      "body": "Não; altitude e direção vêm do GPS",
      "is_correct": true
     },
     {
      "body": "Sim, os três já vêm de fábrica",
      "is_correct": false
     },
     {
      "body": "Só a bússola eletrônica de 3 eixos",
      "is_correct": false
     },
     {
      "body": "Só o altímetro barométrico",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o GPSMAP 65s adiciona ao 65?",
    "explanation": "O 65s soma os sensores ABC. O resto é igual ao 65.",
    "active": true,
    "alternatives": [
     {
      "body": "Uma tela maior, de 3 polegadas",
      "is_correct": false
     },
     {
      "body": "Comunicação satelital inReach",
      "is_correct": false
     },
     {
      "body": "Bateria recarregável de 450 h",
      "is_correct": false
     },
     {
      "body": "Altímetro, barômetro e bússola",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que o GPSMAP 66sr tem a mais que o 65?",
    "explanation": "O 66sr tem tela maior, sensores ABC, bateria recarregável de até 450 h em Expedição e imagem de satélite.",
    "active": true,
    "alternatives": [
     {
      "body": "inReach embutido e cartas náuticas",
      "is_correct": false
     },
     {
      "body": "Touchscreen e Wi-Fi para mapas",
      "is_correct": false
     },
     {
      "body": "Tela de 3\", sensores ABC e até 450 h",
      "is_correct": true
     },
     {
      "body": "Câmera e alto-falante embutidos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quais mapas vêm pré-carregados no GPSMAP 65?",
    "explanation": "Mapas TopoActive dos EUA e do Canadá já incluídos de fábrica.",
    "active": true,
    "alternatives": [
     {
      "body": "TopoActive do Brasil inteiro",
      "is_correct": false
     },
     {
      "body": "TopoActive dos EUA e Canadá",
      "is_correct": true
     },
     {
      "body": "Cartas náuticas BlueChart g3",
      "is_correct": false
     },
     {
      "body": "City Navigator South America",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a resistência do GPSMAP 65?",
    "explanation": "IPX7, contra chuva forte e imersão acidental.",
    "active": true,
    "alternatives": [
     {
      "body": "IPX7",
      "is_correct": true
     },
     {
      "body": "IP67",
      "is_correct": false
     },
     {
      "body": "5 ATM",
      "is_correct": false
     },
     {
      "body": "IPX4",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O trilheiro faz trilhas de um dia e tem orçamento de entrada. Qual GPS de mão indicar?",
    "explanation": "Tela colorida, multibanda e boa autonomia para o dia, pelo menor preço da linha.",
    "active": true,
    "alternatives": [
     {
      "body": "GPSMAP 66sr",
      "is_correct": false
     },
     {
      "body": "GPSMAP 67",
      "is_correct": false
     },
     {
      "body": "GPSMAP 86sci",
      "is_correct": false
     },
     {
      "body": "GPSMAP 65",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente quer o GPS de mão mais recente e com mais bateria. Qual indicar?",
    "explanation": "O 67 tem até 5x mais bateria que a série 66 e tela de 3\".",
    "active": true,
    "alternatives": [
     {
      "body": "GPSMAP 65",
      "is_correct": false
     },
     {
      "body": "GPSMAP 65s",
      "is_correct": false
     },
     {
      "body": "GPSMAP 67",
      "is_correct": true
     },
     {
      "body": "GPSMAP 66sr",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "gpsmap-66sr",
  "quiz_id": "bc1c7823-e65d-40b9-a73f-22f9231da8c7",
  "questions": [
   {
    "body": "Qual é a tela do GPSMAP 66sr?",
    "explanation": "Tela colorida de 3\", maior que a de 2,6\" do GPSMAP 65.",
    "active": true,
    "alternatives": [
     {
      "body": "Colorida de 3\"",
      "is_correct": true
     },
     {
      "body": "Colorida de 2,6\"",
      "is_correct": false
     },
     {
      "body": "Touchscreen de 3,5\"",
      "is_correct": false
     },
     {
      "body": "Colorida de 2,4\"",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a bateria do GPSMAP 66sr?",
    "explanation": "Bateria Li-ion recarregável: até 36 h em GPS ou 450 h em modo Expedição.",
    "active": true,
    "alternatives": [
     {
      "body": "16 h em GPS ou 200 h em Expedição",
      "is_correct": false
     },
     {
      "body": "35 h em GPS ou 200 h em Expedição",
      "is_correct": false
     },
     {
      "body": "36 h em GPS ou 100 h em Expedição",
      "is_correct": false
     },
     {
      "body": "36 h em GPS ou 450 h em Expedição",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Quais sensores o GPSMAP 66sr traz de fábrica?",
    "explanation": "Os sensores ABC vêm de fábrica, sem depender de cálculo por GPS.",
    "active": true,
    "alternatives": [
     {
      "body": "Frequência cardíaca, SpO2 e temperatura",
      "is_correct": false
     },
     {
      "body": "Sonar, temperatura da água e profundidade",
      "is_correct": false
     },
     {
      "body": "Altímetro, barômetro e bússola",
      "is_correct": true
     },
     {
      "body": "Acelerômetro, giroscópio e luz ambiente",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual recurso é exclusivo do GPSMAP 66sr nessa geração?",
    "explanation": "O download de imagem de satélite é exclusivo do topo de linha outdoor dessa geração.",
    "active": true,
    "alternatives": [
     {
      "body": "Comunicação satelital inReach",
      "is_correct": false
     },
     {
      "body": "Download de imagem de satélite",
      "is_correct": true
     },
     {
      "body": "Cartas náuticas BlueChart g3",
      "is_correct": false
     },
     {
      "body": "Mensagem de voz via satélite",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O GPSMAP 66sr tem inReach embutido?",
    "explanation": "Para comunicação satelital embutida, o cliente precisa de um modelo “i”, como o GPSMAP 67i.",
    "active": true,
    "alternatives": [
     {
      "body": "Não; só modelos com “i”, como o 67i",
      "is_correct": true
     },
     {
      "body": "Sim, com SOS interativo de fábrica",
      "is_correct": false
     },
     {
      "body": "Sim, liberado pelo app no celular",
      "is_correct": false
     },
     {
      "body": "Sim, desde que tenha plano ativo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o GPSMAP 66sr tem a mais que o 65s?",
    "explanation": "Os dois têm sensores ABC. O 66sr soma tela de 3\", bateria muito maior e imagem de satélite.",
    "active": true,
    "alternatives": [
     {
      "body": "Os sensores ABC, que o 65s não tem",
      "is_correct": false
     },
     {
      "body": "GPS multibanda, que o 65s não tem",
      "is_correct": false
     },
     {
      "body": "Resistência IPX7, que o 65s não tem",
      "is_correct": false
     },
     {
      "body": "Tela maior, bateria e imagem de satélite",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como o GPSMAP 67 se compara ao 66sr?",
    "explanation": "Multibanda e sensores ABC já vinham do 66sr. O grande ganho do 67 é a bateria.",
    "active": true,
    "alternatives": [
     {
      "body": "O 67 tem uma tela bem maior",
      "is_correct": false
     },
     {
      "body": "Só o 67 tem os sensores ABC",
      "is_correct": false
     },
     {
      "body": "O 67 tem até 5x mais bateria",
      "is_correct": true
     },
     {
      "body": "O 67 perde o GPS multibanda",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O montanhista técnico precisa de altímetro barométrico dedicado e bateria para dias. Qual indicar?",
    "explanation": "Sensores ABC de fábrica e até 450 h em Expedição.",
    "active": true,
    "alternatives": [
     {
      "body": "GPSMAP 65",
      "is_correct": false
     },
     {
      "body": "GPSMAP 66sr",
      "is_correct": true
     },
     {
      "body": "eTrex SE",
      "is_correct": false
     },
     {
      "body": "Instinct E",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Que tipo de bateria o GPSMAP 66sr usa?",
    "explanation": "Bateria Li-ion recarregável interna.",
    "active": true,
    "alternatives": [
     {
      "body": "Li-ion recarregável",
      "is_correct": true
     },
     {
      "body": "Pilhas AA comuns",
      "is_correct": false
     },
     {
      "body": "Bateria de moeda",
      "is_correct": false
     },
     {
      "body": "Só energia solar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a resistência do GPSMAP 66sr?",
    "explanation": "IPX7, contra chuva e imersão acidental.",
    "active": true,
    "alternatives": [
     {
      "body": "IP67",
      "is_correct": false
     },
     {
      "body": "5 ATM",
      "is_correct": false
     },
     {
      "body": "IPX4",
      "is_correct": false
     },
     {
      "body": "IPX7",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "gpsmap-67",
  "quiz_id": "1cbb4933-990d-4622-bf9a-cc9f14b9d256",
  "questions": [
   {
    "body": "Qual é o maior ganho do GPSMAP 67 sobre a série 66?",
    "explanation": "A própria Garmin confirma até 5x mais bateria, a maior autonomia da linha GPSMAP de mão.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 2x mais bateria",
      "is_correct": false
     },
     {
      "body": "Até 5x mais bateria",
      "is_correct": true
     },
     {
      "body": "Tela sensível ao toque",
      "is_correct": false
     },
     {
      "body": "Cartas náuticas embutidas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o GPSMAP 67i adiciona ao 67?",
    "explanation": "O 67i soma comunicação satelital bidirecional e SOS interativo via inReach.",
    "active": true,
    "alternatives": [
     {
      "body": "inReach com SOS interativo",
      "is_correct": true
     },
     {
      "body": "Cartas náuticas BlueChart g3",
      "is_correct": false
     },
     {
      "body": "Tela touchscreen de 3\"",
      "is_correct": false
     },
     {
      "body": "Sensores ABC de fábrica",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O GPSMAP 67 comum tem inReach?",
    "explanation": "O inReach é exclusivo da variante 67i.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, igual ao do 67i",
      "is_correct": false
     },
     {
      "body": "Só com o plano anual",
      "is_correct": false
     },
     {
      "body": "Só após atualização",
      "is_correct": false
     },
     {
      "body": "Não, é exclusivo do 67i",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como é a tela do GPSMAP 67?",
    "explanation": "Tela colorida de 3\", legível sob sol, com controle por botão.",
    "active": true,
    "alternatives": [
     {
      "body": "3\", colorida e touch",
      "is_correct": false
     },
     {
      "body": "2,6\", colorida, por botão",
      "is_correct": false
     },
     {
      "body": "3\", colorida, por botão",
      "is_correct": true
     },
     {
      "body": "3,5\", colorida e touch",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Que tipo de bateria o GPSMAP 67 usa?",
    "explanation": "Bateria interna de lítio recarregável.",
    "active": true,
    "alternatives": [
     {
      "body": "Pilhas AA substituíveis",
      "is_correct": false
     },
     {
      "body": "Lítio embutida recarregável",
      "is_correct": true
     },
     {
      "body": "Bateria de moeda CR2032",
      "is_correct": false
     },
     {
      "body": "Bateria solar sem recarga",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que não mudou do GPSMAP 66sr para o 67?",
    "explanation": "Multibanda e sensores ABC já vinham do 66sr. Bateria e opção 67i mudaram.",
    "active": true,
    "alternatives": [
     {
      "body": "Multibanda e sensores ABC",
      "is_correct": true
     },
     {
      "body": "A autonomia de bateria",
      "is_correct": false
     },
     {
      "body": "A ausência de opção inReach",
      "is_correct": false
     },
     {
      "body": "O tipo de bateria",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Vale trocar meu 66sr pelo 67?” Qual resposta segue a ficha?",
    "explanation": "Se o cliente não precisa de mais bateria, o 66sr continua completo.",
    "active": true,
    "alternatives": [
     {
      "body": "Vale pela tela, que é bem maior",
      "is_correct": false
     },
     {
      "body": "Vale pelos sensores ABC novos",
      "is_correct": false
     },
     {
      "body": "Não vale, os dois são iguais",
      "is_correct": false
     },
     {
      "body": "Vale principalmente pela bateria",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O guia de trilha profissional precisa da maior autonomia da linha. Qual indicar?",
    "explanation": "O 67 tem a maior autonomia já vista num GPSMAP de mão.",
    "active": true,
    "alternatives": [
     {
      "body": "GPSMAP 65",
      "is_correct": false
     },
     {
      "body": "GPSMAP 66sr",
      "is_correct": false
     },
     {
      "body": "GPSMAP 67",
      "is_correct": true
     },
     {
      "body": "GPSMAP 86sci",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Antes de decidir entre o GPSMAP 67 e o 67i, o que confirmar?",
    "explanation": "O 67i só faz sentido se o cliente quer SOS e mensagens via satélite no próprio GPS.",
    "active": true,
    "alternatives": [
     {
      "body": "Se ele prefere tela maior ou menor",
      "is_correct": false
     },
     {
      "body": "Se ele precisa de comunicação satelital",
      "is_correct": true
     },
     {
      "body": "Qual cor de carcaça ele prefere",
      "is_correct": false
     },
     {
      "body": "Qual operadora de celular ele usa",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a resistência do GPSMAP 67?",
    "explanation": "IPX7, contra chuva e imersão acidental.",
    "active": true,
    "alternatives": [
     {
      "body": "IPX7",
      "is_correct": true
     },
     {
      "body": "IP67",
      "is_correct": false
     },
     {
      "body": "10 ATM",
      "is_correct": false
     },
     {
      "body": "IPX4",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "gpsmap-86sci",
  "quiz_id": "897d777e-4572-42d8-a021-9fdb7d51e8d7",
  "questions": [
   {
    "body": "Quais cartas vêm embutidas no GPSMAP 86sci?",
    "explanation": "Cartas BlueChart g3 com dados Navionics integrados.",
    "active": true,
    "alternatives": [
     {
      "body": "TopoActive dos EUA e do Canadá",
      "is_correct": false
     },
     {
      "body": "City Navigator South America",
      "is_correct": false
     },
     {
      "body": "BlueChart g3 com dados Navionics",
      "is_correct": true
     },
     {
      "body": "Só mapa-base, sem cartas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual foi o pioneirismo do GPSMAP 86sci?",
    "explanation": "Foi o primeiro handheld Garmin a juntar cartas BlueChart g3 e comunicação satelital inReach.",
    "active": true,
    "alternatives": [
     {
      "body": "Primeiro GPS de mão com touchscreen colorido",
      "is_correct": false
     },
     {
      "body": "Primeiro com cartas BlueChart e inReach juntos",
      "is_correct": true
     },
     {
      "body": "Primeiro GPS de mão com GPS multibanda",
      "is_correct": false
     },
     {
      "body": "Primeiro GPS de mão com bateria solar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a bateria do GPSMAP 86sci?",
    "explanation": "Bateria de lítio recarregável: até 35 h, ou 200 h em modo Expedição.",
    "active": true,
    "alternatives": [
     {
      "body": "35 h, ou 200 h em Expedição",
      "is_correct": true
     },
     {
      "body": "36 h, ou 450 h em Expedição",
      "is_correct": false
     },
     {
      "body": "16 h, ou 100 h em Expedição",
      "is_correct": false
     },
     {
      "body": "20 h, ou 200 h em Expedição",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quais conexões o GPSMAP 86sci oferece?",
    "explanation": "Wi-Fi, Bluetooth e ANT+ para sincronizar com apps e sensores.",
    "active": true,
    "alternatives": [
     {
      "body": "Só Bluetooth com o celular",
      "is_correct": false
     },
     {
      "body": "4G com chip próprio",
      "is_correct": false
     },
     {
      "body": "Só cabo USB no computador",
      "is_correct": false
     },
     {
      "body": "Wi-Fi, Bluetooth e ANT+",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é a diferença entre o GPSMAP 86sci e o 86i?",
    "explanation": "O 86sci é o único da série 86 com cartas BlueChart e inReach juntos.",
    "active": true,
    "alternatives": [
     {
      "body": "O 86i tem as cartas, mas não tem o inReach",
      "is_correct": false
     },
     {
      "body": "O 86i tem tela touch e o 86sci, só botões",
      "is_correct": false
     },
     {
      "body": "O 86i tem inReach, mas não tem as cartas BlueChart",
      "is_correct": true
     },
     {
      "body": "O 86i é a versão mais nova, com mais bateria",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O inReach do GPSMAP 86sci precisa de assinatura?",
    "explanation": "A comunicação satelital requer plano ativo, contratado à parte com a Garmin.",
    "active": true,
    "alternatives": [
     {
      "body": "Não, o plano vem incluso",
      "is_correct": false
     },
     {
      "body": "Sim, plano mensal ou anual",
      "is_correct": true
     },
     {
      "body": "Só o SOS precisa de plano",
      "is_correct": false
     },
     {
      "body": "Só para usar fora do Brasil",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O 86sci funciona como chartplotter fixo de embarcação?",
    "explanation": "É um GPS de mão. Para embarcação com console e instalação fixa, o caminho é a linha ECHOMAP.",
    "active": true,
    "alternatives": [
     {
      "body": "Não; é portátil, e para console fixo vale ECHOMAP",
      "is_correct": true
     },
     {
      "body": "Sim, substitui qualquer chartplotter de painel",
      "is_correct": false
     },
     {
      "body": "Sim, desde que instalado com suporte náutico",
      "is_correct": false
     },
     {
      "body": "Não, porque ele não traz cartas náuticas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente pergunta a classificação de água do 86sci. O que fazer?",
    "explanation": "A série é feita para uso náutico, mas a classificação exata deve ser confirmada antes de garantir.",
    "active": true,
    "alternatives": [
     {
      "body": "Garantir IPX8 para qualquer profundidade",
      "is_correct": false
     },
     {
      "body": "Garantir 10 ATM, igual aos relógios Garmin",
      "is_correct": false
     },
     {
      "body": "Dizer que ele não resiste à água",
      "is_correct": false
     },
     {
      "body": "Confirmar na ficha técnica antes de garantir",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O GPSMAP 86sci serve também em trilha terrestre?",
    "explanation": "É um GPS de mão completo, mas o foco de cartografia é náutico, diferente da série 65/66/67.",
    "active": true,
    "alternatives": [
     {
      "body": "Não, ele só funciona na água",
      "is_correct": false
     },
     {
      "body": "Sim, já vem com TopoActive",
      "is_correct": false
     },
     {
      "body": "Sim, mas com cartas náuticas",
      "is_correct": true
     },
     {
      "body": "Só com um mapa pago extra",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O pescador de barco pequeno vai longe da costa e quer cartas e SOS num aparelho de mão. O que indicar?",
    "explanation": "Cartas náuticas completas e inReach no mesmo GPS de mão.",
    "active": true,
    "alternatives": [
     {
      "body": "GPSMAP 67",
      "is_correct": false
     },
     {
      "body": "GPSMAP 86sci",
      "is_correct": true
     },
     {
      "body": "ECHOMAP UHD2",
      "is_correct": false
     },
     {
      "body": "inReach Mini 2",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "etrex-se",
  "quiz_id": "ba8e805b-a035-4f8c-beb5-36e7aff4dd06",
  "questions": [
   {
    "body": "Qual é a bateria do eTrex SE?",
    "explanation": "Até 168 h com duas pilhas AA, quase 7 vezes as 25 h do eTrex 10.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 25 h, com duas pilhas AA",
      "is_correct": false
     },
     {
      "body": "Até 1.800 h, com carga solar",
      "is_correct": false
     },
     {
      "body": "Até 36 h, com bateria interna",
      "is_correct": false
     },
     {
      "body": "Até 168 h, com duas pilhas AA",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como é a tela do eTrex SE?",
    "explanation": "Tela transflectiva monocromática de 2,2\" (240x320), otimizada para sol forte.",
    "active": true,
    "alternatives": [
     {
      "body": "2,6\", colorida e legível sob o sol",
      "is_correct": false
     },
     {
      "body": "2,2\", colorida e com touchscreen",
      "is_correct": false
     },
     {
      "body": "2,2\", monocromática e de alto contraste",
      "is_correct": true
     },
     {
      "body": "3\", colorida e controlada por botão",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o eTrex SE trouxe que o eTrex 10 não tinha?",
    "explanation": "Bússola digital, multi-GNSS, conexão com o Garmin Explore, mais resolução e bateria muito maior.",
    "active": true,
    "alternatives": [
     {
      "body": "Tela colorida com touchscreen",
      "is_correct": false
     },
     {
      "body": "Bússola, multi-GNSS e Bluetooth",
      "is_correct": true
     },
     {
      "body": "Altímetro barométrico dedicado",
      "is_correct": false
     },
     {
      "body": "GPS multibanda e carga solar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O eTrex SE tem altímetro barométrico?",
    "explanation": "O material oficial não confirma altímetro barométrico. A altitude é estimada pelo GPS.",
    "active": true,
    "alternatives": [
     {
      "body": "Não confirmado; a altitude vem do GPS",
      "is_correct": true
     },
     {
      "body": "Sim, com altímetro barométrico dedicado",
      "is_correct": false
     },
     {
      "body": "Sim, mas só na versão com Bluetooth",
      "is_correct": false
     },
     {
      "body": "Sim, com sensores ABC completos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O eTrex SE precisa do smartphone para funcionar?",
    "explanation": "Funciona sozinho. O celular libera clima e geocaching ao vivo pelo Garmin Explore.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, para todas as funções do aparelho",
      "is_correct": false
     },
     {
      "body": "Sim, para captar o sinal de GPS",
      "is_correct": false
     },
     {
      "body": "Sim, para mostrar o mapa na tela",
      "is_correct": false
     },
     {
      "body": "Não; o celular só libera extras no Explore",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que o eTrex Solar tem a mais que o eTrex SE?",
    "explanation": "O Solar soma carga solar e multibanda. O SE não tem nenhum dos dois, mas custa menos.",
    "active": true,
    "alternatives": [
     {
      "body": "Tela colorida de alta resolução",
      "is_correct": false
     },
     {
      "body": "Altímetro barométrico dedicado",
      "is_correct": false
     },
     {
      "body": "Carregamento solar e GPS multibanda",
      "is_correct": true
     },
     {
      "body": "Touchscreen e Wi-Fi integrado",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “A tela não é colorida, isso é ruim?” Qual resposta segue a ficha?",
    "explanation": "Para rota, waypoint e bússola, o alto contraste é até mais legível sob sol que muita tela colorida.",
    "active": true,
    "alternatives": [
     {
      "body": "É ruim mesmo; por isso vale levar o eTrex Solar",
      "is_correct": false
     },
     {
      "body": "Lê bem ao sol; para mapa colorido, um GPSMAP",
      "is_correct": true
     },
     {
      "body": "A tela fica colorida quando conectada ao celular",
      "is_correct": false
     },
     {
      "body": "Não faz diferença, porque ele não mostra mapa",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O caçador faz expedições de dias e quer o GPS de mão mais em conta. O que indicar?",
    "explanation": "O eTrex SE é o GPS de mão mais em conta da Garmin, com bateria de mais de uma semana.",
    "active": true,
    "alternatives": [
     {
      "body": "eTrex SE",
      "is_correct": true
     },
     {
      "body": "eTrex Solar",
      "is_correct": false
     },
     {
      "body": "GPSMAP 67",
      "is_correct": false
     },
     {
      "body": "GPSMAP 66sr",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quais recursos o app Garmin Explore libera no eTrex SE?",
    "explanation": "Via Bluetooth, o Explore traz clima em tempo real e geocaching ao vivo.",
    "active": true,
    "alternatives": [
     {
      "body": "Fotos e voz via satélite",
      "is_correct": false
     },
     {
      "body": "SOS interativo com central",
      "is_correct": false
     },
     {
      "body": "Mapas coloridos na tela",
      "is_correct": false
     },
     {
      "body": "Clima e geocaching ao vivo",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é a resistência do eTrex SE?",
    "explanation": "IPX7, contra chuva forte e imersão acidental.",
    "active": true,
    "alternatives": [
     {
      "body": "IP67",
      "is_correct": false
     },
     {
      "body": "5 ATM",
      "is_correct": false
     },
     {
      "body": "IPX7",
      "is_correct": true
     },
     {
      "body": "IPX4",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "etrex-solar",
  "quiz_id": "173e613a-275f-4579-890e-57af5c9c1f92",
  "questions": [
   {
    "body": "Como funciona o carregamento solar do eTrex Solar?",
    "explanation": "O painel solar é integrado à tela. Sob sol contínuo de 75.000 lux, a bateria não se esgota.",
    "active": true,
    "alternatives": [
     {
      "body": "Power Glass na tela; com 75.000 lux não acaba",
      "is_correct": true
     },
     {
      "body": "Painel solar dobrável que vem na caixa",
      "is_correct": false
     },
     {
      "body": "Carrega pelo sol só quando está desligado",
      "is_correct": false
     },
     {
      "body": "Power Glass na traseira; carrega em 1 hora",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quanto dura o eTrex Solar sem nenhum sol?",
    "explanation": "Mesmo sem sol, o modo Expedição chega a até 1.800 h.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 168 h com pilhas AA",
      "is_correct": false
     },
     {
      "body": "Até 450 h em Expedição",
      "is_correct": false
     },
     {
      "body": "Até 25 h em modo GPS",
      "is_correct": false
     },
     {
      "body": "Até 1.800 h em Expedição",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual recurso de GPS o eTrex Solar estreou na linha eTrex?",
    "explanation": "Nenhum eTrex anterior (10, 22x, 32x) tinha GPS multibanda.",
    "active": true,
    "alternatives": [
     {
      "body": "Multi-GNSS",
      "is_correct": false
     },
     {
      "body": "Bússola digital",
      "is_correct": false
     },
     {
      "body": "GPS multibanda",
      "is_correct": true
     },
     {
      "body": "Geocaching ao vivo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O eTrex Solar tem altímetro barométrico?",
    "explanation": "Confirmado pela central de suporte: o Solar não tem barômetro dedicado. Vale avisar com transparência.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, o mesmo do eTrex 32x",
      "is_correct": false
     },
     {
      "body": "Não; o 32x tinha e o Solar perdeu",
      "is_correct": true
     },
     {
      "body": "Sim, um sensor novo e mais preciso",
      "is_correct": false
     },
     {
      "body": "Só quando há sol suficiente",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O montanhista técnico depende de altitude precisa. O que indicar?",
    "explanation": "Para altitude precisa, o caminho é um GPSMAP com altímetro barométrico, como o 66sr ou o 67.",
    "active": true,
    "alternatives": [
     {
      "body": "Um GPSMAP com sensores ABC",
      "is_correct": true
     },
     {
      "body": "O eTrex Solar com multibanda",
      "is_correct": false
     },
     {
      "body": "O eTrex SE com bússola",
      "is_correct": false
     },
     {
      "body": "O eTrex Solar com o Explore",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Bateria infinita não é exagero?” Qual resposta segue a ficha?",
    "explanation": "É condicional: praticamente infinita só sob 75.000 lux. Em condições variáveis, ainda é excepcional.",
    "active": true,
    "alternatives": [
     {
      "body": "É exagero; na prática ele dura poucos dias",
      "is_correct": false
     },
     {
      "body": "É verdade em qualquer condição, até no escuro",
      "is_correct": false
     },
     {
      "body": "É verdade só quando ligado na tomada",
      "is_correct": false
     },
     {
      "body": "Depende de sol contínuo; sem sol, são até 1.800 h",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que o eTrex Solar perdeu em relação ao eTrex 32x?",
    "explanation": "Ganhou carga solar e multibanda, mas perdeu o altímetro barométrico e a tela colorida do 32x.",
    "active": true,
    "alternatives": [
     {
      "body": "A bússola digital e o multi-GNSS",
      "is_correct": false
     },
     {
      "body": "A resistência à água IPX7",
      "is_correct": false
     },
     {
      "body": "Altímetro e tela colorida",
      "is_correct": true
     },
     {
      "body": "A conexão com o app Explore",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O expedicionário passa semanas sob o sol e não quer pensar em bateria. O que indicar?",
    "explanation": "Com Power Glass, a bateria praticamente não acaba sob sol contínuo.",
    "active": true,
    "alternatives": [
     {
      "body": "eTrex SE",
      "is_correct": false
     },
     {
      "body": "eTrex Solar",
      "is_correct": true
     },
     {
      "body": "GPSMAP 65",
      "is_correct": false
     },
     {
      "body": "GPSMAP 86sci",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quando vale pagar mais pelo eTrex Solar em vez do SE?",
    "explanation": "Sem esses dois recursos, o SE entrega ótima autonomia por menos.",
    "active": true,
    "alternatives": [
     {
      "body": "Se precisa de carga solar e multibanda",
      "is_correct": true
     },
     {
      "body": "Se quer uma tela colorida maior",
      "is_correct": false
     },
     {
      "body": "Se precisa de altímetro barométrico",
      "is_correct": false
     },
     {
      "body": "Se quer usar pilhas AA comuns",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Que tipo de bússola o eTrex Solar tem?",
    "explanation": "Bússola digital, que mostra a direção mesmo parado.",
    "active": true,
    "alternatives": [
     {
      "body": "Nenhuma bússola",
      "is_correct": false
     },
     {
      "body": "Só calculada pelo GPS",
      "is_correct": false
     },
     {
      "body": "Bússola analógica acoplada",
      "is_correct": false
     },
     {
      "body": "Bússola digital",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "blaze",
  "quiz_id": "3b9b972c-c8ce-4104-a373-fcd0ad8785be",
  "questions": [
   {
    "body": "O que o Blaze monitora no cavalo?",
    "explanation": "Frequência cardíaca, temperatura de pele, passadas e análise de marcha.",
    "active": true,
    "alternatives": [
     {
      "body": "FC, glicemia e peso do animal",
      "is_correct": false
     },
     {
      "body": "FC, temperatura de pele e passadas",
      "is_correct": true
     },
     {
      "body": "Temperatura, hidratação e sono",
      "is_correct": false
     },
     {
      "body": "Velocidade, peso e pressão",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Onde o sensor do Blaze fica no cavalo?",
    "explanation": "Numa manga de neoprene enrolada na base do rabo, com o sensor contra a parte de baixo.",
    "active": true,
    "alternatives": [
     {
      "body": "Numa manga na base do rabo",
      "is_correct": true
     },
     {
      "body": "Numa cinta presa ao peito",
      "is_correct": false
     },
     {
      "body": "Numa tornozeleira na pata",
      "is_correct": false
     },
     {
      "body": "Numa presilha na sela",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual preparo o Blaze exige na pele do animal?",
    "explanation": "A manga simplesmente enrola na base do rabo, sem tosa nem gel.",
    "active": true,
    "alternatives": [
     {
      "body": "Tosar o pelo da região",
      "is_correct": false
     },
     {
      "body": "Aplicar gel condutor",
      "is_correct": false
     },
     {
      "body": "Raspar a pele e usar gel",
      "is_correct": false
     },
     {
      "body": "Nenhum: sem tosa e sem gel",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como é a bateria do sensor do Blaze?",
    "explanation": "Até 25 h, e o sensor sai da manga para recarregar e limpar.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 1 ano, com bateria de moeda",
      "is_correct": false
     },
     {
      "body": "Até 90 h, presa dentro da manga",
      "is_correct": false
     },
     {
      "body": "Até 25 h, removível e recarregável",
      "is_correct": true
     },
     {
      "body": "Até 10 h, com troca de pilhas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que é o Heat Score do Blaze?",
    "explanation": "Combina temperatura e umidade do ar para ajudar a decidir se é seguro montar naquele momento.",
    "active": true,
    "alternatives": [
     {
      "body": "Medição da febre do cavalo durante o treino",
      "is_correct": false
     },
     {
      "body": "Orientação de segurança com temperatura e umidade",
      "is_correct": true
     },
     {
      "body": "Cálculo da velocidade ideal para o percurso",
      "is_correct": false
     },
     {
      "body": "Lembrete de hidratar o cavalo no treino",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O treinador tem vários cavalos. Como usar o Blaze?",
    "explanation": "O mesmo wrap e sensor servem a cavalos diferentes, cada um com seu perfil salvo.",
    "active": true,
    "alternatives": [
     {
      "body": "Com perfis individuais no app",
      "is_correct": true
     },
     {
      "body": "Comprando um kit por cavalo",
      "is_correct": false
     },
     {
      "body": "Usando um cavalo por vez no app",
      "is_correct": false
     },
     {
      "body": "Exportando planilhas manuais",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Blaze funciona sem relógio Garmin?",
    "explanation": "Funciona pelo app Blaze no celular. O app no relógio é um recurso a mais.",
    "active": true,
    "alternatives": [
     {
      "body": "Não, depende de um relógio Garmin",
      "is_correct": false
     },
     {
      "body": "Sim, mas só com o Edge pareado",
      "is_correct": false
     },
     {
      "body": "Não, depende do Garmin Explore",
      "is_correct": false
     },
     {
      "body": "Sim, pelo app; o Connect IQ é um extra",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que confirmar antes de vender o Blaze?",
    "explanation": "A manga é feita para rabos de 7,5 a 11 polegadas de circunferência na base.",
    "active": true,
    "alternatives": [
     {
      "body": "O peso total do cavalo",
      "is_correct": false
     },
     {
      "body": "A raça e a idade do cavalo",
      "is_correct": false
     },
     {
      "body": "A medida do rabo na base",
      "is_correct": true
     },
     {
      "body": "O modelo da sela utilizada",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Blaze precisa de assinatura?",
    "explanation": "O app Blaze acompanha o produto sem custo de assinatura nas funções básicas.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, uma assinatura mensal",
      "is_correct": false
     },
     {
      "body": "Não, o básico não tem custo",
      "is_correct": true
     },
     {
      "body": "Sim, um plano anual de dados",
      "is_correct": false
     },
     {
      "body": "Só para cadastrar mais cavalos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Em qual caso o Blaze não é indicado?",
    "explanation": "O Blaze faz sentido para quem tem ou acompanha um cavalo com regularidade.",
    "active": true,
    "alternatives": [
     {
      "body": "Cliente sem cavalo nem acesso regular a um",
      "is_correct": true
     },
     {
      "body": "Cavaleiro que compete em clima quente",
      "is_correct": false
     },
     {
      "body": "Treinador que prepara vários cavalos",
      "is_correct": false
     },
     {
      "body": "Usuário Garmin que monitora o próprio treino",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "striker-4",
  "quiz_id": "1d322440-675e-4976-b073-876e1cb6a2e9",
  "questions": [
   {
    "body": "Qual é a tela do Striker 4?",
    "explanation": "Tela colorida compacta de 3,5\", fácil de instalar em embarcação pequena.",
    "active": true,
    "alternatives": [
     {
      "body": "5\"",
      "is_correct": false
     },
     {
      "body": "2,6\"",
      "is_correct": false
     },
     {
      "body": "3,5\"",
      "is_correct": true
     },
     {
      "body": "7\"",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é o sonar do Striker 4?",
    "explanation": "CHIRP tradicional 77/200 kHz com 200 W RMS. ClearVü com 500 W é do Striker Vivid 5cv.",
    "active": true,
    "alternatives": [
     {
      "body": "CHIRP e ClearVü, com 500 W",
      "is_correct": false
     },
     {
      "body": "CHIRP 77/200 kHz, 200 W RMS",
      "is_correct": true
     },
     {
      "body": "UHD de 800 kHz, com 1.000 W",
      "is_correct": false
     },
     {
      "body": "CHIRP 50/200 kHz, com 100 W",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a profundidade máxima de leitura do Striker 4?",
    "explanation": "Até 490 m (1.600 pés) em água doce, conforme as condições.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 490 m em água doce",
      "is_correct": true
     },
     {
      "body": "Até 700 m em água doce",
      "is_correct": false
     },
     {
      "body": "Até 335 m em água doce",
      "is_correct": false
     },
     {
      "body": "Até 150 m em água doce",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Striker 4 tem mapas pré-carregados?",
    "explanation": "Sem cartografia. Para navegar com mapas, o produto certo é o ECHOMAP UHD2 52cv.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, mapas de lago LakeVü",
      "is_correct": false
     },
     {
      "body": "Sim, cartas BlueChart g3",
      "is_correct": false
     },
     {
      "body": "Sim, Quickdraw já carregado",
      "is_correct": false
     },
     {
      "body": "Não; foca em sonar e waypoints",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Para que serve o Sonar History Rewind?",
    "explanation": "Permite voltar nas imagens do sonar e marcar pontos que passaram despercebidos.",
    "active": true,
    "alternatives": [
     {
      "body": "Gravar um vídeo contínuo do fundo",
      "is_correct": false
     },
     {
      "body": "Refazer o mesmo percurso do barco",
      "is_correct": false
     },
     {
      "body": "Voltar no histórico para marcar waypoints",
      "is_correct": true
     },
     {
      "body": "Desfazer o último waypoint marcado",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Para que tipo de pesca o flasher integrado do Striker 4 é útil?",
    "explanation": "O modo flasher atende bem a pesca vertical e no gelo.",
    "active": true,
    "alternatives": [
     {
      "body": "Pesca de arrasto em alto-mar",
      "is_correct": false
     },
     {
      "body": "Pesca vertical e no gelo",
      "is_correct": true
     },
     {
      "body": "Pesca com mosca em rio raso",
      "is_correct": false
     },
     {
      "body": "Pesca de praia com molinete",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Striker Vivid 5cv tem e o Striker 4 não tem?",
    "explanation": "GPS, CHIRP e IPX7 os dois têm. O Vivid soma tela maior, ClearVü, cores Vivid e Wi-Fi.",
    "active": true,
    "alternatives": [
     {
      "body": "Tela de 5\", ClearVü, paletas Vivid e Wi-Fi",
      "is_correct": true
     },
     {
      "body": "GPS para marcar e voltar aos pontos",
      "is_correct": false
     },
     {
      "body": "Sonar CHIRP com boa separação de alvos",
      "is_correct": false
     },
     {
      "body": "Resistência IPX7 contra imersão",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Vale a pena, sendo um modelo de 2016?” Qual resposta segue a ficha?",
    "explanation": "Continua vendido porque entrega o essencial (CHIRP + GPS) de forma confiável e por um preço competitivo.",
    "active": true,
    "alternatives": [
     {
      "body": "Não, ele está obsoleto e fora de linha",
      "is_correct": false
     },
     {
      "body": "Só se for usado como peça de reposição",
      "is_correct": false
     },
     {
      "body": "Só para quem já tem um Striker antigo",
      "is_correct": false
     },
     {
      "body": "Sim, é a entrada pelo custo-benefício",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente tem um caiaque e quer o menor investimento em sonar com GPS. O que indicar?",
    "explanation": "O Striker 4 é compacto e tem o menor preço da linha.",
    "active": true,
    "alternatives": [
     {
      "body": "Striker Vivid 5cv",
      "is_correct": false
     },
     {
      "body": "ECHOMAP UHD2 52cv",
      "is_correct": false
     },
     {
      "body": "Striker 4",
      "is_correct": true
     },
     {
      "body": "GPSMAP 86sci",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a resistência à água do Striker 4?",
    "explanation": "IPX7: respingos e imersão acidental de até 1 m por até 30 minutos.",
    "active": true,
    "alternatives": [
     {
      "body": "IP67, contra poeira e água",
      "is_correct": false
     },
     {
      "body": "IPX7, até 1 m por 30 min",
      "is_correct": true
     },
     {
      "body": "IPX4, só contra respingos",
      "is_correct": false
     },
     {
      "body": "10 ATM, até 100 metros",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "striker-vivid-5cv",
  "quiz_id": "1c6310ab-b5d3-4611-bebc-29b98a759728",
  "questions": [
   {
    "body": "O que são as paletas Vivid?",
    "explanation": "Sete opções de cor com contraste máximo entre peixe, estrutura e fundo, a novidade que dá nome à linha.",
    "active": true,
    "alternatives": [
     {
      "body": "Uma tela AMOLED de cores vivas",
      "is_correct": false
     },
     {
      "body": "Filtros para daltonismo na tela",
      "is_correct": false
     },
     {
      "body": "Modos de brilho para o sol forte",
      "is_correct": false
     },
     {
      "body": "7 paletas de cor de alto contraste",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é o sonar do Striker Vivid 5cv?",
    "explanation": "CHIRP 77/200 kHz e ClearVü 455/800 kHz, com 500 W RMS.",
    "active": true,
    "alternatives": [
     {
      "body": "Só CHIRP 77/200 kHz, com 200 W",
      "is_correct": false
     },
     {
      "body": "ClearVü 260/455/800 kHz e CHIRP 70/83/200",
      "is_correct": false
     },
     {
      "body": "CHIRP 77/200 e ClearVü 455/800 kHz",
      "is_correct": true
     },
     {
      "body": "UHD de 1.000 W com Panoptix",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a profundidade máxima do Striker Vivid 5cv?",
    "explanation": "Até 700 m em água doce e 335 m em água salgada, conforme as condições.",
    "active": true,
    "alternatives": [
     {
      "body": "490 m em água doce",
      "is_correct": false
     },
     {
      "body": "700 m doce / 335 m salgada",
      "is_correct": true
     },
     {
      "body": "335 m doce / 700 m salgada",
      "is_correct": false
     },
     {
      "body": "1.000 m em qualquer água",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Quickdraw Contours faz?",
    "explanation": "Cria e armazena até 2 milhões de acres de mapas próprios, com contornos de 1 pé.",
    "active": true,
    "alternatives": [
     {
      "body": "Cria mapas próprios de profundidade",
      "is_correct": true
     },
     {
      "body": "Baixa cartas náuticas prontas",
      "is_correct": false
     },
     {
      "body": "Mostra os peixes em 3D na tela",
      "is_correct": false
     },
     {
      "body": "Calcula a rota até o ponto",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a tela do Striker Vivid 5cv?",
    "explanation": "Tela de 5\" WVGA com 800x480 pixels.",
    "active": true,
    "alternatives": [
     {
      "body": "3,5\", 480x320",
      "is_correct": false
     },
     {
      "body": "7\" WVGA, 800x480",
      "is_correct": false
     },
     {
      "body": "5\" touch, 800x480",
      "is_correct": false
     },
     {
      "body": "5\" WVGA, 800x480",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual transdutor vem com o Striker Vivid 5cv?",
    "explanation": "O GT20-TM vem de fábrica e entrega CHIRP e ClearVü no mesmo transdutor.",
    "active": true,
    "alternatives": [
     {
      "body": "Nenhum, vendido à parte",
      "is_correct": false
     },
     {
      "body": "GT24UHD-TM, incluso",
      "is_correct": false
     },
     {
      "body": "GT20-TM 2 em 1, incluso",
      "is_correct": true
     },
     {
      "body": "Panoptix LiveScope",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Para que serve o Wi-Fi do Striker Vivid 5cv?",
    "explanation": "Conecta ao app ActiveCaptain para atualizações e compartilhamento. Compartilhar sonar entre telas é do ECHOMAP UHD2.",
    "active": true,
    "alternatives": [
     {
      "body": "Compartilhar sonar entre duas telas",
      "is_correct": false
     },
     {
      "body": "Conectar ao app ActiveCaptain",
      "is_correct": true
     },
     {
      "body": "Enviar fotos da pesca às redes",
      "is_correct": false
     },
     {
      "body": "Navegar com mapas online",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o ECHOMAP UHD2 52cv tem e o Striker Vivid 5cv não tem?",
    "explanation": "O ECHOMAP é chartplotter completo. O Striker Vivid foca em sonar e GPS de waypoints.",
    "active": true,
    "alternatives": [
     {
      "body": "Mapas prontos e cartão SD",
      "is_correct": true
     },
     {
      "body": "Sonar ClearVü de varredura",
      "is_correct": false
     },
     {
      "body": "GPS para marcar os pontos",
      "is_correct": false
     },
     {
      "body": "Paletas de cor Vivid",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o Striker Vivid trouxe em relação ao Striker Plus 5cv?",
    "explanation": "ClearVü, Quickdraw, tela de 5\", IPX7 e 500 W já vinham do Striker Plus 5cv.",
    "active": true,
    "alternatives": [
     {
      "body": "ClearVü e o Quickdraw Contours",
      "is_correct": false
     },
     {
      "body": "Tela de 5\" e resistência IPX7",
      "is_correct": false
     },
     {
      "body": "Sonar CHIRP de 500 W",
      "is_correct": false
     },
     {
      "body": "Cores Vivid, transdutor e Wi-Fi",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente pesca sempre no mesmo lago e quer um mapa de profundidade só dele. O que indicar?",
    "explanation": "O Quickdraw Contours permite criar o próprio mapa de profundidade dos spots.",
    "active": true,
    "alternatives": [
     {
      "body": "Striker 4 padrão",
      "is_correct": false
     },
     {
      "body": "GPSMAP 86sci náutico",
      "is_correct": false
     },
     {
      "body": "Striker Vivid 5cv",
      "is_correct": true
     },
     {
      "body": "GPSMAP 67 outdoor",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "echomap-uhd2-52cv",
  "quiz_id": "90f4c23e-aeaa-4765-b392-ce72f6f93838",
  "questions": [
   {
    "body": "Qual cartografia vem pré-carregada no ECHOMAP UHD2 52cv?",
    "explanation": "BlueChart g3 para costa ou LakeVü g3 para águas interiores, com dados Navionics.",
    "active": true,
    "alternatives": [
     {
      "body": "BlueChart g3 ou LakeVü g3",
      "is_correct": true
     },
     {
      "body": "TopoActive dos EUA e do Canadá",
      "is_correct": false
     },
     {
      "body": "Só mapa-base, sem cartas náuticas",
      "is_correct": false
     },
     {
      "body": "City Navigator South America NT",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como o ECHOMAP UHD2 52cv é controlado?",
    "explanation": "É um modelo keyed, bom com luva molhada e sol forte. Vale mostrar antes de vender.",
    "active": true,
    "alternatives": [
     {
      "body": "Por touchscreen e botões",
      "is_correct": false
     },
     {
      "body": "Só por touchscreen",
      "is_correct": false
     },
     {
      "body": "Por controle remoto sem fio",
      "is_correct": false
     },
     {
      "body": "Por botões, sem touch",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que o Wi-Fi do ECHOMAP UHD2 permite?",
    "explanation": "Compartilha sonar, waypoints e rotas entre duas unidades ECHOMAP UHD2, além do ActiveCaptain.",
    "active": true,
    "alternatives": [
     {
      "body": "Navegar com mapas online pelo celular",
      "is_correct": false
     },
     {
      "body": "Transmitir o sonar para uma TV a bordo",
      "is_correct": false
     },
     {
      "body": "Compartilhar sonar e rotas entre dois UHD2",
      "is_correct": true
     },
     {
      "body": "Atualizar o motor da embarcação",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a antena de posição do ECHOMAP UHD2 52cv?",
    "explanation": "Atualiza a posição até 5x mais rápido que antenas comuns de 1 Hz.",
    "active": true,
    "alternatives": [
     {
      "body": "GPS comum de 1 Hz",
      "is_correct": false
     },
     {
      "body": "GPS/GLONASS de 5 Hz",
      "is_correct": true
     },
     {
      "body": "Multibanda de 10 Hz",
      "is_correct": false
     },
     {
      "body": "GPS de 2 Hz",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a capacidade de cartão e de waypoints do ECHOMAP UHD2 52cv?",
    "explanation": "Cartão SD de até 32 GB e até 5.000 waypoints.",
    "active": true,
    "alternatives": [
     {
      "body": "SD até 32 GB e 5.000 waypoints",
      "is_correct": true
     },
     {
      "body": "SD até 64 GB e 10.000 waypoints",
      "is_correct": false
     },
     {
      "body": "Sem SD e 1.000 waypoints",
      "is_correct": false
     },
     {
      "body": "SD até 16 GB e 2.000 waypoints",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o tamanho de 5\" representa na linha ECHOMAP UHD?",
    "explanation": "A geração UHD original só tinha 6\", 7\" e 9\". O 52cv é exclusivo da UHD2.",
    "active": true,
    "alternatives": [
     {
      "body": "Já existia na primeira geração UHD",
      "is_correct": false
     },
     {
      "body": "É o maior tamanho da linha UHD2",
      "is_correct": false
     },
     {
      "body": "É exclusivo dos modelos touch",
      "is_correct": false
     },
     {
      "body": "É inédito, chegou com a geração UHD2",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente quer imagem de sonar ainda mais detalhada. Qual upgrade oferecer?",
    "explanation": "O GT24UHD-TM traz varredura Ultra Alta Definição. O GT20-TM já vem incluso.",
    "active": true,
    "alternatives": [
     {
      "body": "Transdutor GT20-TM",
      "is_correct": false
     },
     {
      "body": "Cartão SD de 32 GB",
      "is_correct": false
     },
     {
      "body": "Transdutor GT24UHD-TM",
      "is_correct": true
     },
     {
      "body": "Antena GPS externa",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que é o upgrade para Garmin Navionics+?",
    "explanation": "Opção de cartografia premium com atualizações diárias, nova nesta geração.",
    "active": true,
    "alternatives": [
     {
      "body": "Um sonar com mais potência",
      "is_correct": false
     },
     {
      "body": "Cartas com atualização diária",
      "is_correct": true
     },
     {
      "body": "Uma tela com touchscreen",
      "is_correct": false
     },
     {
      "body": "Um segundo transdutor",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Por que não o Striker Vivid 5cv, que é mais barato?” Qual resposta segue a ficha?",
    "explanation": "Se o cliente precisa de mapa pronto para navegação, o ECHOMAP entrega de fábrica.",
    "active": true,
    "alternatives": [
     {
      "body": "Só o ECHOMAP traz cartografia pronta para navegar",
      "is_correct": true
     },
     {
      "body": "O Striker Vivid não tem sonar de varredura ClearVü",
      "is_correct": false
     },
     {
      "body": "O Striker Vivid não marca waypoints no GPS",
      "is_correct": false
     },
     {
      "body": "O ECHOMAP tem tela maior que a do Striker Vivid",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que perguntar antes de fechar a venda do ECHOMAP UHD2 52cv?",
    "explanation": "Água doce pede LakeVü, e salgada, BlueChart.",
    "active": true,
    "alternatives": [
     {
      "body": "Qual é o tamanho do motor do barco",
      "is_correct": false
     },
     {
      "body": "Qual cor de carcaça ele prefere",
      "is_correct": false
     },
     {
      "body": "Se ele usa iPhone ou Android",
      "is_correct": false
     },
     {
      "body": "Se pesca em água doce ou salgada",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "cirqa",
  "quiz_id": "d9fb2705-0195-4599-9934-a3f61b875989",
  "questions": [
   {
    "body": "Qual é a bateria e o peso do Cirqa?",
    "explanation": "Até 10 dias de bateria, com 20 g de peso.",
    "active": true,
    "alternatives": [
     {
      "body": "Até 14 dias e 30 g",
      "is_correct": false
     },
     {
      "body": "Até 10 dias e 20 g",
      "is_correct": true
     },
     {
      "body": "Até 7 dias e 15 g",
      "is_correct": false
     },
     {
      "body": "Até 10 dias e 40 g",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual sensor o Cirqa usa?",
    "explanation": "Sensor óptico Elevate Gen 4 e Pulse Ox, sem ECG.",
    "active": true,
    "alternatives": [
     {
      "body": "Elevate Gen 4 com Pulse Ox",
      "is_correct": true
     },
     {
      "body": "Elevate Gen 5 com ECG",
      "is_correct": false
     },
     {
      "body": "Elevate Gen 4 com ECG",
      "is_correct": false
     },
     {
      "body": "Elevate Gen 5 sem Pulse Ox",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Preciso pagar assinatura para usar o Cirqa?” Qual é a resposta?",
    "explanation": "Prontidão, VO2 Max, sono e estresse vêm inclusos. O Connect+ só soma treinos guiados e coaching.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, uma mensalidade para ver qualquer dado",
      "is_correct": false
     },
     {
      "body": "Sim, mas só no primeiro ano de uso",
      "is_correct": false
     },
     {
      "body": "Não, e o Connect+ também vem incluso",
      "is_correct": false
     },
     {
      "body": "Não para o principal; o Connect+ é opcional",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é a principal diferença do Cirqa para o Whoop?",
    "explanation": "O Cirqa é comprado uma vez. O Whoop segue o modelo de assinatura contínua.",
    "active": true,
    "alternatives": [
     {
      "body": "Os dois funcionam com assinatura mensal",
      "is_correct": false
     },
     {
      "body": "O Cirqa tem tela e o Whoop não tem",
      "is_correct": false
     },
     {
      "body": "Compra única, sem mensalidade no principal",
      "is_correct": true
     },
     {
      "body": "O Whoop dura mais e tem botão físico",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que o botão físico do Cirqa faz?",
    "explanation": "Inicia ou pausa atividades, adia o alarme, transmite FC e ajuda no Encontrar Minha Pulseira.",
    "active": true,
    "alternatives": [
     {
      "body": "Liga uma tela escondida na pulseira",
      "is_correct": false
     },
     {
      "body": "Inicia treino, adia alarme e transmite FC",
      "is_correct": true
     },
     {
      "body": "Aciona um pedido de SOS aos contatos",
      "is_correct": false
     },
     {
      "body": "Faz pagamentos por aproximação",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como transmitir a frequência cardíaca do Cirqa para outro aparelho?",
    "explanation": "Pressione e segure o botão por 2 segundos para transmitir por ANT+ e Bluetooth.",
    "active": true,
    "alternatives": [
     {
      "body": "Segurando o botão por 2 segundos",
      "is_correct": true
     },
     {
      "body": "Tocando duas vezes no módulo",
      "is_correct": false
     },
     {
      "body": "Só pelo app, sem usar o botão",
      "is_correct": false
     },
     {
      "body": "Segurando o botão por 10 segundos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O Cirqa pode ser usado na natação?",
    "explanation": "É 5 ATM, resistente o suficiente para nadar.",
    "active": true,
    "alternatives": [
     {
      "body": "Não, só chuva",
      "is_correct": false
     },
     {
      "body": "Só na piscina",
      "is_correct": false
     },
     {
      "body": "Sim, é IPX4",
      "is_correct": false
     },
     {
      "body": "Sim, é 5 ATM",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O cliente faz treinos de alta intensidade. Como usar o Cirqa?",
    "explanation": "A banda de bíceps, mais elástica, é indicada para treinos intensos e vendida separadamente.",
    "active": true,
    "alternatives": [
     {
      "body": "Com a pulseira padrão presa bem apertada",
      "is_correct": false
     },
     {
      "body": "Ele não pode ser usado em treino intenso",
      "is_correct": false
     },
     {
      "body": "Com a banda própria de bíceps, vendida à parte",
      "is_correct": true
     },
     {
      "body": "Com a banda de bíceps que vem na caixa",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer ver os dados na tela durante o treino. O que fazer?",
    "explanation": "O Cirqa não tem tela. Para ver dados no pulso durante o treino, um Forerunner atende melhor.",
    "active": true,
    "alternatives": [
     {
      "body": "Indicar o Cirqa com o app aberto",
      "is_correct": false
     },
     {
      "body": "Indicar um Forerunner básico",
      "is_correct": true
     },
     {
      "body": "Indicar o Cirqa na banda de bíceps",
      "is_correct": false
     },
     {
      "body": "Indicar o Cirqa com Connect+",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Por que eu usaria o Cirqa se já tenho um Garmin?” Qual resposta segue a ficha?",
    "explanation": "Pode monitorar saúde e recuperação sem usar o relógio principal o dia todo, ou em contextos mais discretos.",
    "active": true,
    "alternatives": [
     {
      "body": "Como complemento discreto para saúde e recuperação",
      "is_correct": true
     },
     {
      "body": "Porque ele substitui totalmente o relógio Garmin",
      "is_correct": false
     },
     {
      "body": "Porque ele é mais preciso que qualquer relógio",
      "is_correct": false
     },
     {
      "body": "Ele não faz sentido para quem já tem um Garmin",
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
    select coalesce(array_agg(md5('especialista-quiz-v2|' || (z->>'key') || '|' || g)::uuid), '{}')
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
      v_qid := md5('especialista-quiz-v2|' || (z->>'key') || '|' || qi)::uuid;

      insert into questions (id, quiz_id, body, explanation, order_index, is_active)
      values (v_qid, (z->>'quiz_id')::uuid, q->>'body', q->>'explanation', qi, (q->>'active')::boolean)
      on conflict (id) do update
         set body = excluded.body, explanation = excluded.explanation,
             order_index = excluded.order_index, is_active = excluded.is_active;

      for a, ai in select e, (o - 1)::int from jsonb_array_elements(q->'alternatives') with ordinality as t(e, o) loop
        insert into alternatives (id, question_id, body, is_correct, order_index)
        values (md5('especialista-quiz-v2|' || (z->>'key') || '|' || qi || '|' || ai)::uuid, v_qid,
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
-- FIM DA MIGRAÇÃO 176
-- ============================================================================
