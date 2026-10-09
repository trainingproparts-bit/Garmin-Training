-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 175: quizzes dos Circuitos de Desafios revisados
-- ============================================================================
-- Pedido do usuário (2026-10-08): revisar os quizzes avulsos dos Circuitos
-- de Desafios (sem módulo por trás) pela qualidade das perguntas e deixar
-- todos com 10 perguntas.
--   - IPX & Resistência à Água: mantido (só pequenos ajustes de tamanho).
--   - Linha Edge & Abordagem Consultiva: reescrito (3 alternativas por
--     pergunta, distratores absurdos, Edge 550 com tela errada).
--   - Cintas Cardíacas (HRM): 12 -> 10 perguntas, alternativas equilibradas.
--   - Técnico Instinct 3: perguntas com 3 alternativas completadas.
--   - Script de Atendimento e Avaliação Geral: equilibradas; saem a
--     explicação com "risco de lesão" e a que tornava certa uma errada.
-- Mesmo mecanismo da sql/172: antigas ficam inativas (histórico
-- preservado), ids determinísticos, rodar de novo só atualiza.
-- ============================================================================

do $$
declare
  v_data jsonb := $q$[
 {
  "key": "ipx",
  "quiz_id": "11d264d6-2efd-4e13-9726-76efb7a3ecb5",
  "questions": [
   {
    "body": "O que significa a sigla IPX?",
    "explanation": "IPX significa Ingress Protection. O X indica que a proteção contra poeira não foi avaliada, apenas a resistência à água.",
    "active": true,
    "alternatives": [
     {
      "body": "Ingress Protection, só a resistência à água é avaliada, não a proteção contra poeira",
      "is_correct": true
     },
     {
      "body": "Impermeabilidade Por Exposição, certificação brasileira para eletrônicos em ambiente úmido",
      "is_correct": false
     },
     {
      "body": "Índice de Proteção eXtended, versão avançada do padrão IP para dispositivos submersos",
      "is_correct": false
     },
     {
      "body": "International Protection Extra, padrão que avalia poeira e resistência a jatos d’água",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual certificação os relógios Garmin usam (diferente dos GPS portáteis)?",
    "explanation": "Os relógios Garmin seguem a norma ISO 22810, medida em ATM. A norma IPX é usada em GPS portáteis, fones (Shokz) e acessórios.",
    "active": true,
    "alternatives": [
     {
      "body": "IPX, da norma Ingress Protection",
      "is_correct": false
     },
     {
      "body": "IPX8, para imersão profunda contínua",
      "is_correct": false
     },
     {
      "body": "EN 13319, padrão europeu de mergulho",
      "is_correct": false
     },
     {
      "body": "ATM, baseado na norma ISO 22810",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Um cliente chega com o Instinct 3 e diz que parou de funcionar depois de uma sauna. O que você explica?",
    "explanation": "A certificação é feita com água limpa em temperatura ambiente. Água quente, vapor e sauna alteram a pressão interna e podem vencer a vedação. Dano por água fora dos limites certificados geralmente não tem cobertura de garantia.",
    "active": true,
    "alternatives": [
     {
      "body": "Defeito de fabricação pode ocorrer em ambientes úmidos, vale acionar a garantia com laudo",
      "is_correct": false
     },
     {
      "body": "A sauna seca é tolerada até 60 °C, acima disso o vapor começa a comprometer os sensores",
      "is_correct": false
     },
     {
      "body": "A norma usa água fria; vapor e calor alteram a pressão interna e podem vencer a vedação",
      "is_correct": true
     },
     {
      "body": "O Instinct 3 é 10 ATM e inclui proteção a vapor, provavelmente foi exposição muito longa",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual a classificação mínima para um cliente que quer nadar em piscina com o relógio Garmin?",
    "explanation": "5 ATM é o mínimo para natação em piscina e uso na chuva. FR165, Venu 4 e Vivoactive 6 são exemplos com 5 ATM.",
    "active": true,
    "alternatives": [
     {
      "body": "1 ATM",
      "is_correct": false
     },
     {
      "body": "5 ATM",
      "is_correct": true
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
   },
   {
    "body": "Um cliente quer um Shokz para usar correndo na chuva forte. Qual modelo você indica?",
    "explanation": "O OpenRun tem IP67: proteção total contra poeira (nível 6) e imersão até 1 m por 30 min (nível 7). O OpenRun Pro tem IP55, que aguenta suor e chuva leve, mas não é recomendado para chuva muito forte.",
    "active": true,
    "alternatives": [
     {
      "body": "OpenRun (IP67), nível 7 de resistência à água, aguenta imersão até 1 m por 30 min",
      "is_correct": true
     },
     {
      "body": "Os dois têm proteção equivalente na chuva, IP55 e IP67 suportam o mesmo volume d’água",
      "is_correct": false
     },
     {
      "body": "OpenRun Pro (IP55), o driver de titânio garante vedação superior em condições úmidas",
      "is_correct": false
     },
     {
      "body": "Nenhum dos dois, fones de condução óssea não são certificados para chuva forte",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual a diferença entre IPX7 e IPX8?",
    "explanation": "IPX7 é imersão em até 1 metro por até 30 minutos. IPX8 é imersão além de 1 metro. Quanto maior o número, maior a proteção.",
    "active": true,
    "alternatives": [
     {
      "body": "IPX7 é para GPS portátil; IPX8 é exclusiva para relógios",
      "is_correct": false
     },
     {
      "body": "IPX7 protege de respingos; IPX8 cobre chuva forte contínua",
      "is_correct": false
     },
     {
      "body": "Na prática, os dois suportam a mesma imersão no dia a dia",
      "is_correct": false
     },
     {
      "body": "IPX7: imersão até 1 m por 30 min; IPX8: imersão além de 1 m",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Um cliente vai usar o GPS Garmin em um caiaque. Qual recurso você destaca além da certificação IPX7?",
    "explanation": "Para uso náutico, a flutuação é decisiva. O IPX7 garante 30 min a 1 m, mas em mar aberto o GPS pode afundar além disso. Modelos flutuantes ficam visíveis na superfície.",
    "active": true,
    "alternatives": [
     {
      "body": "Tela de alto contraste, visível com reflexo e óculos de sol",
      "is_correct": false
     },
     {
      "body": "Bateria longa, essencial para travessias sem recarga",
      "is_correct": false
     },
     {
      "body": "Flutuação, como no GPSMAP 79s, que volta à superfície",
      "is_correct": true
     },
     {
      "body": "GPS multibanda, mais preciso em ambientes aquáticos",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O IPX4 protege contra qual tipo de exposição à água?",
    "explanation": "IPX4 é proteção contra respingos de qualquer direção. Protege contra suor e chuva leve e não pode ser submerso.",
    "active": true,
    "alternatives": [
     {
      "body": "Submersão em água parada por até 10 minutos seguidos",
      "is_correct": false
     },
     {
      "body": "Respingos de qualquer direção, como suor e chuva leve",
      "is_correct": true
     },
     {
      "body": "Jatos de baixa pressão, como os de um chuveiro fraco",
      "is_correct": false
     },
     {
      "body": "Imersão de até 1 metro por 30 minutos, como no IPX7",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Um Garmin com 10 ATM + EN 13319: qual é o uso indicado?",
    "explanation": "10 ATM + EN 13319 é a certificação de mergulho. O Descent Mk3i e o Fenix 8 têm essa certificação, com profundidade conforme o modelo.",
    "active": true,
    "alternatives": [
     {
      "body": "Mergulho com equipamento, como no Descent Mk3i",
      "is_correct": true
     },
     {
      "body": "Natação em piscina com viradas frequentes",
      "is_correct": false
     },
     {
      "body": "Corrida com suor e respingos constantes",
      "is_correct": false
     },
     {
      "body": "Surf, porque a norma cobre impacto de ondas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como explicar corretamente a resistência à água de um produto ao cliente?",
    "explanation": "Sempre especifique o nível e os limites. “À prova d’água” não existe tecnicamente. A comunicação correta evita expectativas erradas e devoluções.",
    "active": true,
    "alternatives": [
     {
      "body": "“É à prova d’água e pode ir a qualquer profundidade.”",
      "is_correct": false
     },
     {
      "body": "“Aguenta respingos, mas evite molhar, não é resistente.”",
      "is_correct": false
     },
     {
      "body": "“Todo Garmin aguenta natação, pode usar sem se preocupar.”",
      "is_correct": false
     },
     {
      "body": "“Tem IPX7, aguenta 1 m por 30 min, mas não é para mergulho.”",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "script-circuito",
  "quiz_id": "6f47aeaf-eb3f-4040-a881-e8291aa55b13",
  "questions": [
   {
    "body": "Um cliente entra na loja e você diz “Como posso ajudar?”. Por que essa abordagem não é ideal?",
    "explanation": "É uma abertura genérica que convida a uma resposta fechada. O ideal é abrir espaço para o cliente falar sobre o que veio procurar.",
    "active": true,
    "alternatives": [
     {
      "body": "É formal demais para uma loja de esporte, que pede leveza",
      "is_correct": false
     },
     {
      "body": "É genérica, e o cliente costuma responder “só estou olhando”",
      "is_correct": true
     },
     {
      "body": "O certo é esperar o cliente se aproximar para não invadir",
      "is_correct": false
     },
     {
      "body": "O vendedor deveria falar primeiro dos lançamentos da loja",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Na sondagem, o cliente diz que já sabe o modelo que quer. Qual é a próxima pergunta ideal?",
    "explanation": "Mesmo com um modelo em mente, entender o contexto pode confirmar a escolha ou revelar um produto mais adequado.",
    "active": true,
    "alternatives": [
     {
      "body": "“É para você ou presente? Para esporte ou dia a dia?”",
      "is_correct": true
     },
     {
      "body": "“Qual é o seu orçamento para esse modelo de relógio?”",
      "is_correct": false
     },
     {
      "body": "“Tem certeza? Posso te mostrar outros modelos antes.”",
      "is_correct": false
     },
     {
      "body": "“Ótimo, vou buscar esse modelo no estoque agora.”",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Tá caro, vou pesquisar online.” Como você responde?",
    "explanation": "Valorize os diferenciais da loja: garantia oficial de 2 anos, suporte presencial e a chance de testar antes. Sem guerra de preço e sem inventar riscos.",
    "active": true,
    "alternatives": [
     {
      "body": "“Vou falar com o gerente para ver um desconto e fechar hoje.”",
      "is_correct": false
     },
     {
      "body": "“Sem problema, pode pesquisar. Me chama no WhatsApp depois.”",
      "is_correct": false
     },
     {
      "body": "“Online é arriscado, já vimos cliente receber produto falso.”",
      "is_correct": false
     },
     {
      "body": "“Entendo. Aqui você tem garantia de 2 anos, suporte e testa agora.”",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é a melhor forma de apresentar a bateria do Garmin ao cliente?",
    "explanation": "Traduza a especificação em benefício que o cliente imagina no dia a dia.",
    "active": true,
    "alternatives": [
     {
      "body": "“Dura muito mais que o Apple Watch, que carrega todo dia.”",
      "is_correct": false
     },
     {
      "body": "“São 13 dias com multibanda ativo e 26 no modo smartwatch.”",
      "is_correct": false
     },
     {
      "body": "“Você carrega uma vez por semana, sem medo de acabar no treino.”",
      "is_correct": true
     },
     {
      "body": "“A bateria Garmin é líder, nenhum concorrente chega perto.”",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente indeciso está olhando 5 modelos ao mesmo tempo. O que você faz?",
    "explanation": "Opção demais paralisa a decisão. Use a sondagem para chegar a no máximo 2 modelos.",
    "active": true,
    "alternatives": [
     {
      "body": "Apresenta os 5 com prós e contras para ele comparar",
      "is_correct": false
     },
     {
      "body": "Filtra para 2 opções pelo perfil levantado na sondagem",
      "is_correct": true
     },
     {
      "body": "Recomenda o mais caro, já que a qualidade sempre compensa",
      "is_correct": false
     },
     {
      "body": "Deixa o cliente sozinho para não criar pressão na escolha",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como usar a experiência tátil para ajudar o cliente indeciso?",
    "explanation": "Com o relógio no pulso, o cliente começa a se imaginar usando, e a decisão deixa de ser só racional.",
    "active": true,
    "alternatives": [
     {
      "body": "Convida, com naturalidade, a colocar o relógio no pulso",
      "is_correct": true
     },
     {
      "body": "Entrega a caixa fechada para ele ter a sensação de abrir",
      "is_correct": false
     },
     {
      "body": "Mostra fotos e vídeos do relógio em uso no celular",
      "is_correct": false
     },
     {
      "body": "Demonstra o relógio funcionando no próprio pulso",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “O Apple Watch faz a mesma coisa.” Como você responde?",
    "explanation": "Nunca desqualifique o concorrente. Apresente diferenciais concretos, como bateria e GPS, e deixe os fatos falarem.",
    "active": true,
    "alternatives": [
     {
      "body": "“O Apple Watch é bem inferior em tudo que envolve esporte.”",
      "is_correct": false
     },
     {
      "body": "“Depende: design e iPhone são o ponto forte do Apple Watch.”",
      "is_correct": false
     },
     {
      "body": "“O Apple Watch é para iPhone; o Garmin é melhor no esporte.”",
      "is_correct": false
     },
     {
      "body": "“No treino a diferença é real: bateria de dias e multibanda.”",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Na finalização da venda, qual ação cria um momento forte de personalização?",
    "explanation": "Com o nome configurado na hora, o produto já é dele antes de sair da loja. Mostrar o Garmin Connect garante o bom uso.",
    "active": true,
    "alternatives": [
     {
      "body": "Embalar o produto com capricho para reforçar a qualidade",
      "is_correct": false
     },
     {
      "body": "Entregar um brinde para criar memória afetiva com a marca",
      "is_correct": false
     },
     {
      "body": "Configurar o nome do cliente no relógio e mostrar o Connect",
      "is_correct": true
     },
     {
      "body": "Oferecer um parcelamento diferenciado para facilitar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente de corrida comprou o relógio. Como abordar o Shokz de forma natural?",
    "explanation": "Conectar o fone ao momento do cliente completa a experiência de corrida sem pressão.",
    "active": true,
    "alternatives": [
     {
      "body": "“Já que gosta de corrida, quer ver o Shokz, que vende bem?”",
      "is_correct": false
     },
     {
      "body": "“Corrida combina com Shokz: música sem perder o som ao redor.”",
      "is_correct": true
     },
     {
      "body": "“Se tiver interesse, temos fones que complementam o relógio.”",
      "is_correct": false
     },
     {
      "body": "“Prefiro não oferecer mais nada para não parecer insistente.”",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Cliente: “Vou pensar e volto depois.” Como responder sem pressionar?",
    "explanation": "Respeite a decisão e deixe uma ponte de contato. Isso mantém o relacionamento e aumenta a chance de fechar depois.",
    "active": true,
    "alternatives": [
     {
      "body": "“Claro! Anoto o modelo pra você? Qualquer dúvida, me chama.”",
      "is_correct": true
     },
     {
      "body": "“Consigo uma condição especial, mas só até o fim do dia.”",
      "is_correct": false
     },
     {
      "body": "“Sem comprar hoje, não garanto o estoque desse modelo.”",
      "is_correct": false
     },
     {
      "body": "“Sem problema, fique à vontade, estamos aqui quando voltar.”",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "instinct3",
  "quiz_id": "05d7febb-e05a-4944-92ac-471705409af5",
  "questions": [
   {
    "body": "Quais são as funções principais do botão CTRL (LIGHT) no Instinct 3 Solar?",
    "explanation": "O CTRL liga o relógio e a iluminação. Segurado por cerca de 2 s abre os controles, por 5 s pede assistência, e dois toques ligam a lanterna.",
    "active": true,
    "alternatives": [
     {
      "body": "Liga o relógio, abre as atividades e liga o GPS no toque longo",
      "is_correct": false
     },
     {
      "body": "Controla só a lanterna e o brilho da tela do relógio",
      "is_correct": false
     },
     {
      "body": "Liga o relógio e a luz; segurado, abre controles e assistência",
      "is_correct": true
     },
     {
      "body": "Liga o relógio e, segurado, ativa o modo de expedição",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como interpretar o gráfico de carregamento solar?",
    "explanation": "O gráfico mostra a intensidade solar das últimas 6 horas e a média da semana anterior. Ele não informa o % exato gerado, e a Power Glass não exige calibração.",
    "active": true,
    "alternatives": [
     {
      "body": "Mostra quantos % de bateria vieram da luz solar",
      "is_correct": false
     },
     {
      "body": "Mostra a exposição solar recente e a média da semana",
      "is_correct": true
     },
     {
      "body": "Indica quando a lente Power Glass precisa de calibração",
      "is_correct": false
     },
     {
      "body": "Mostra o horário de maior sol previsto para o dia",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como personalizar o visor do relógio (watch face) no Instinct 3?",
    "explanation": "No visor principal, segure MENU e selecione Visor do relógio para editar dados, fundo e cor de destaque.",
    "active": true,
    "alternatives": [
     {
      "body": "Segurando MENU no visor e escolhendo as opções",
      "is_correct": true
     },
     {
      "body": "Só pelo Garmin Connect, sem edição no relógio",
      "is_correct": false
     },
     {
      "body": "Pressionando GPS e escolhendo um tema automático",
      "is_correct": false
     },
     {
      "body": "Pelo menu de atividades, em Configurar visor",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como registrar uma captura durante a atividade de Pesca?",
    "explanation": "Na atividade Pesca, GPS e Registrar captura somam ao contador e salvam a localização para análise no Garmin Connect.",
    "active": true,
    "alternatives": [
     {
      "body": "O relógio detecta o arremesso e registra a captura sozinho",
      "is_correct": false
     },
     {
      "body": "O relógio marca a posição a cada parada longa na atividade",
      "is_correct": false
     },
     {
      "body": "As capturas são registradas no Connect ao fim da atividade",
      "is_correct": false
     },
     {
      "body": "Pressiona GPS e escolhe Registrar captura, que salva o local",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que é e para quem serve o Applied Ballistics do Instinct 3 Tactical?",
    "explanation": "É uma solução de mira para tiro de longo alcance, integrada ao app Applied Ballistics Quantum.",
    "active": true,
    "alternatives": [
     {
      "body": "Mede velocidade de impacto e força G em esportes de aventura",
      "is_correct": false
     },
     {
      "body": "Calcula a altitude de salto usando dados de queda livre",
      "is_correct": false
     },
     {
      "body": "Mira de longo alcance, com correção de elevação e vento",
      "is_correct": true
     },
     {
      "body": "Giroscópio que mede a estabilidade em alto impacto",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a vantagem do modo Jumpmaster para militares e paraquedistas?",
    "explanation": "O Jumpmaster segue diretrizes militares para calcular o ponto de salto e usa barômetro e bússola para guiar até o ponto de impacto.",
    "active": true,
    "alternatives": [
     {
      "body": "Indica o momento ideal de abrir o paraquedas por vibração",
      "is_correct": false
     },
     {
      "body": "Calcula o ponto de salto (HARP) em HAHO, HALO e Estático",
      "is_correct": true
     },
     {
      "body": "Monitora frequência cardíaca e oxigenação em altitude",
      "is_correct": false
     },
     {
      "body": "Registra altitude máxima e mínima para análise pós-salto",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que fazem o Stealth Mode e o Kill Switch da Tactical Edition?",
    "explanation": "O Stealth interrompe o registro e o compartilhamento de localização e as conexões. O Kill Switch apaga os dados e restaura o padrão de fábrica.",
    "active": true,
    "alternatives": [
     {
      "body": "Stealth corta GPS e conexões; Kill Switch apaga os dados",
      "is_correct": true
     },
     {
      "body": "Stealth escurece a tela; Kill Switch silencia os alarmes",
      "is_correct": false
     },
     {
      "body": "Stealth desliga a tela; Kill Switch bloqueia os botões",
      "is_correct": false
     },
     {
      "body": "Stealth pausa o treino; Kill Switch reinicia o relógio",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que são os sensores ABC do Instinct 3?",
    "explanation": "Altímetro, barômetro e bússola, fundamentais para navegação off-road e montanhismo.",
    "active": true,
    "alternatives": [
     {
      "body": "Atividade, Biometria e Carga",
      "is_correct": false
     },
     {
      "body": "Acelerômetro, Bluetooth e Célula solar",
      "is_correct": false
     },
     {
      "body": "Altitude, Batimento e Calorias",
      "is_correct": false
     },
     {
      "body": "Altímetro, Barômetro e Bússola",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como funciona o Storm Alert do Instinct 3?",
    "explanation": "O Storm Alert monitora a pressão barométrica e vibra quando ela cai rápido, indicando possível tempestade.",
    "active": true,
    "alternatives": [
     {
      "body": "Mede temperatura e umidade para prever chuva",
      "is_correct": false
     },
     {
      "body": "Consulta a previsão online pelo celular conectado",
      "is_correct": false
     },
     {
      "body": "Alerta quando a pressão barométrica cai rápido",
      "is_correct": true
     },
     {
      "body": "Detecta descargas de raios por interferência",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que é o Expedition Mode e qual é o principal benefício?",
    "explanation": "O Expedition Mode reduz a frequência de gravação do GPS e estende muito a bateria para expedições de vários dias.",
    "active": true,
    "alternatives": [
     {
      "body": "Prioriza a carga solar sobre as demais funções",
      "is_correct": false
     },
     {
      "body": "Grava o GPS em intervalos, para travessias de dias",
      "is_correct": true
     },
     {
      "body": "Deixa o relógio funcionando só como relógio de horas",
      "is_correct": false
     },
     {
      "body": "Desliga todos os sensores, menos o barômetro",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "avaliacao-geral",
  "quiz_id": "2d6bfc18-e64f-43ba-939d-7353da03aad2",
  "questions": [
   {
    "body": "O que é o Body Battery e como ele ajuda o atleta?",
    "explanation": "O Body Battery estima a reserva de energia do corpo. Recarrega com sono e repouso e cai com estresse e exercício.",
    "active": true,
    "alternatives": [
     {
      "body": "Pontuação baseada em passos e calorias gastas no dia",
      "is_correct": false
     },
     {
      "body": "Nota diária calculada só pela frequência cardíaca",
      "is_correct": false
     },
     {
      "body": "Métrica de recuperação baseada só no último treino",
      "is_correct": false
     },
     {
      "body": "Energia do corpo, afetada por sono, estresse e treino",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual é o requisito para gerar o Status de VFC?",
    "explanation": "O relógio analisa a VFC durante o sono e precisa de três semanas de dados para criar a linha de base pessoal.",
    "active": true,
    "alternatives": [
     {
      "body": "Sete dias de uso com o software atualizado",
      "is_correct": false
     },
     {
      "body": "Catorze dias de treinos acima de 70% da FC máxima",
      "is_correct": false
     },
     {
      "body": "Três semanas de dados consistentes de sono",
      "is_correct": true
     },
     {
      "body": "Dez dias seguidos sincronizando com o Connect",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como o PacePro ajuda na estratégia de ritmo do corredor?",
    "explanation": "O PacePro cria um plano de ritmo para o percurso, considerando as mudanças de elevação.",
    "active": true,
    "alternatives": [
     {
      "body": "Pace fixo do início ao fim, sem variações de velocidade",
      "is_correct": false
     },
     {
      "body": "Plano de ritmo que considera a elevação e a meta de tempo",
      "is_correct": true
     },
     {
      "body": "Pace médio dos últimos treinos sugerido para a prova",
      "is_correct": false
     },
     {
      "body": "Zonas cardíacas ajustadas ao cansaço ao longo da prova",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quais critérios ajudam a obter uma estimativa de VO2 Máx precisa na corrida?",
    "explanation": "Na corrida: ao ar livre, com GPS, mantendo ao menos 70% da FC máxima por 10 minutos. No ciclismo, são necessários medidor de potência e monitor cardíaco.",
    "active": true,
    "alternatives": [
     {
      "body": "Corrida ao ar livre com GPS e ao menos 70% da FC máxima",
      "is_correct": true
     },
     {
      "body": "Natação ou esteira em velocidade constante por 30 minutos",
      "is_correct": false
     },
     {
      "body": "Caminhada rápida com monitor cardíaco por 10 minutos",
      "is_correct": false
     },
     {
      "body": "Qualquer treino aeróbico com mais de 20 minutos de duração",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como interpretar as categorias do Status de Treino?",
    "explanation": "Categorias como Produtivo, Mantendo, Recuperação e Ultrapassando Limites mostram como a carga recente se relaciona com o condicionamento.",
    "active": true,
    "alternatives": [
     {
      "body": "Pela distância total percorrida nos últimos 7 dias",
      "is_correct": false
     },
     {
      "body": "Comparando a intensidade cardíaca do dia com a semana",
      "is_correct": false
     },
     {
      "body": "Avaliando só a qualidade do sono e do estresse",
      "is_correct": false
     },
     {
      "body": "Se a carga está gerando evolução, manutenção ou excesso",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que representa a Carga Aguda?",
    "explanation": "A Carga Aguda soma, com pesos, a carga dos exercícios dos últimos 7 dias e mostra como o volume recente se comporta.",
    "active": true,
    "alternatives": [
     {
      "body": "Média do esforço percebido anotado pelo usuário na semana",
      "is_correct": false
     },
     {
      "body": "Tempo estimado de recuperação antes do próximo treino forte",
      "is_correct": false
     },
     {
      "body": "Soma ponderada da carga dos exercícios dos últimos 7 dias",
      "is_correct": true
     },
     {
      "body": "Intensidade do último treino, usada para definir o descanso",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como funcionam os Treinos Sugeridos Diariamente?",
    "explanation": "A sugestão considera VO2 Máx, status de treino, recuperação e histórico recente, para usuários de diferentes níveis, em dispositivos compatíveis.",
    "active": true,
    "alternatives": [
     {
      "body": "Entregam treinos padronizados, iguais para todos os usuários",
      "is_correct": false
     },
     {
      "body": "Usam histórico, recuperação e carga para sugerir o treino",
      "is_correct": true
     },
     {
      "body": "Sincronizam o plano montado por um treinador externo no app",
      "is_correct": false
     },
     {
      "body": "Funcionam só para corredores com mais de 6 meses de uso",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Como o Descanso Automático ajuda no treino de natação em piscina?",
    "explanation": "Na piscina, se a parada passar de 15 segundos, o relógio cria o intervalo de descanso sozinho e retoma ao voltar a nadar.",
    "active": true,
    "alternatives": [
     {
      "body": "Detecta a parada na parede e cria o intervalo após 15 s",
      "is_correct": true
     },
     {
      "body": "Vibra a cada 25 metros sinalizando o início do descanso",
      "is_correct": false
     },
     {
      "body": "O nadador aperta GPS na parede para marcar cada série",
      "is_correct": false
     },
     {
      "body": "Pausa quando a frequência cardíaca cai abaixo do limiar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Para que serve o Registro de Exercícios (Drill Logging) na natação?",
    "explanation": "O Drill Logging registra manualmente tempo e distância de exercícios que o relógio não detecta, como pernada com prancha.",
    "active": true,
    "alternatives": [
     {
      "body": "Criar treinos com séries e intervalos antes de nadar",
      "is_correct": false
     },
     {
      "body": "Gravar a pernada sozinho ao detectar 10 s sem braçadas",
      "is_correct": false
     },
     {
      "body": "Mostrar na tela o treino que o treinador enviou pelo app",
      "is_correct": false
     },
     {
      "body": "Registrar à mão exercícios não detectados, como pernada",
      "is_correct": true
     }
    ]
   },
   {
    "body": "O que faz a Previsão de Corrida do Garmin?",
    "explanation": "A Previsão de Corrida estima tempos para distâncias padrão a partir do condicionamento atual. É uma referência, não uma garantia.",
    "active": true,
    "alternatives": [
     {
      "body": "Prevê o risco de lesão pela carga e sugere reduzir o treino",
      "is_correct": false
     },
     {
      "body": "Calcula a velocidade mínima para bater o recorde pessoal",
      "is_correct": false
     },
     {
      "body": "Estima tempos de 5K, 10K, meia e maratona pelo VO2 Máx",
      "is_correct": true
     },
     {
      "body": "Estima o tempo restante da corrida que está em andamento",
      "is_correct": false
     }
    ]
   }
  ]
 },
 {
  "key": "edge-circuito",
  "quiz_id": "a1b2c3d4-0001-4001-8001-000000000001",
  "questions": [
   {
    "body": "O que o recurso de alertas de perigos na estrada permite ao ciclista?",
    "explanation": "É um recurso comunitário: o ciclista recebe alertas de perigos relatados por outros ciclistas e também pode relatar.",
    "active": true,
    "alternatives": [
     {
      "body": "Receber e relatar perigos informados por outros ciclistas",
      "is_correct": true
     },
     {
      "body": "Ver os radares de velocidade dos órgãos de trânsito",
      "is_correct": false
     },
     {
      "body": "Detectar buracos sozinho pelos sensores de vibração",
      "is_correct": false
     },
     {
      "body": "Receber alertas de trânsito da prefeitura em tempo real",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual Edge junta Garmin Pay, alto-falante e Wi-Fi para atualizar mapas?",
    "explanation": "Garmin Pay, alto-falante embutido e Wi-Fi são as novidades do Edge 1050 em relação ao 1040.",
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
    "body": "Durante uma subida, o que o ciclista vê no ClimbPro?",
    "explanation": "O ClimbPro mostra a subida restante e a inclinação, para o ciclista dosar o esforço. Está em toda a linha completa.",
    "active": true,
    "alternatives": [
     {
      "body": "A potência ideal para bater o recorde da subida",
      "is_correct": false
     },
     {
      "body": "Os pontos de hidratação no topo da subida",
      "is_correct": false
     },
     {
      "body": "A distância, a inclinação e a elevação restantes",
      "is_correct": true
     },
     {
      "body": "O tempo previsto até o fim do percurso salvo",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O que acontece quando a Detecção de Incidentes do Edge é acionada?",
    "explanation": "Com celular conectado e contatos cadastrados, o Edge envia uma mensagem automática com a localização. É um recurso complementar de segurança.",
    "active": true,
    "alternatives": [
     {
      "body": "Liga para o serviço de emergência da região",
      "is_correct": false
     },
     {
      "body": "Envia a localização aos contatos de emergência",
      "is_correct": true
     },
     {
      "body": "Aciona o SOS pela rede de satélite inReach",
      "is_correct": false
     },
     {
      "body": "Dispara um alarme sonoro para pedir ajuda",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual característica física diferencia o Edge 550 dos modelos touchscreen?",
    "explanation": "O 550 tem tela LCD de 2,7\" mais brilhante e só botões. Tela MIP com versão Solar é o Edge 540; 3,5\" com Wi-Fi é o Edge 1050.",
    "active": true,
    "alternatives": [
     {
      "body": "Tela colorida brilhante, operada só por botões",
      "is_correct": true
     },
     {
      "body": "Tela sensível ao toque com alto-falante embutido",
      "is_correct": false
     },
     {
      "body": "Tela MIP refletiva com versão solar disponível",
      "is_correct": false
     },
     {
      "body": "Tela de 3,5 polegadas com Wi-Fi integrado",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Sobre o que os alertas de nutrição orientam o ciclista?",
    "explanation": "Com base no esforço e nas condições ambientais, o Edge orienta alimentação e hidratação. O Smart Fueling está no 550, e os alertas de nutrição no 850.",
    "active": true,
    "alternatives": [
     {
      "body": "As calorias exatas de cada suplemento ingerido",
      "is_correct": false
     },
     {
      "body": "Receitas de refeições para o pós-treino",
      "is_correct": false
     },
     {
      "body": "O peso perdido em suor durante o pedal",
      "is_correct": false
     },
     {
      "body": "Carboidrato e água conforme o esforço e o clima",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Qual recurso do Edge 850 e do Edge 1050 ajuda a avisar pedestres?",
    "explanation": "O Edge 850 soma campainha digital, e o 1050 tem alto-falante embutido, para sinalizar a aproximação.",
    "active": true,
    "alternatives": [
     {
      "body": "Um farol de alta potência integrado ao Edge",
      "is_correct": false
     },
     {
      "body": "Uma sirene automática ativada nas descidas",
      "is_correct": false
     },
     {
      "body": "Uma campainha digital acionada pelo Edge",
      "is_correct": true
     },
     {
      "body": "Um alerta luminoso que pisca para pedestres",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer controlar melhor o esforço nas provas. Qual pergunta abre espaço para o Edge 550 com Rally?",
    "explanation": "Perguntar sobre potência mostra se o Rally faz sentido para o perfil do cliente.",
    "active": true,
    "alternatives": [
     {
      "body": "“Você costuma fazer treinos estruturados? Em quais dias?”",
      "is_correct": false
     },
     {
      "body": "“Você já usa potência para controlar o esforço nos treinos?”",
      "is_correct": true
     },
     {
      "body": "“Em quais tipos de terreno você costuma pedalar mais?”",
      "is_correct": false
     },
     {
      "body": "“Você pretende usar o Edge também para navegação?”",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente pedala sozinho em rodovias e se preocupa com os carros. Qual pergunta identifica a oportunidade do Varia?",
    "explanation": "Transforme a preocupação do cliente em solução: o Varia passa a fazer parte da experiência com o Edge.",
    "active": true,
    "alternatives": [
     {
      "body": "“Gostaria de saber quando um carro se aproxima por trás?”",
      "is_correct": true
     },
     {
      "body": "“Você costuma fazer pedais de longa duração na estrada?”",
      "is_correct": false
     },
     {
      "body": "“Você usa algum sensor de velocidade na bike hoje?”",
      "is_correct": false
     },
     {
      "body": "“Qual é a distância média dos seus pedais na rodovia?”",
      "is_correct": false
     }
    ]
   },
   {
    "body": "O cliente quer o Edge 550, mas não disse o que mais importa para ele. Qual pergunta ajuda a montar o combo certo?",
    "explanation": "Se priorizar esforço, aprofunde em potência e Rally. Se priorizar segurança, explore o Varia.",
    "active": true,
    "alternatives": [
     {
      "body": "“Você pretende usar o Edge todos os dias da semana?”",
      "is_correct": false
     },
     {
      "body": "“Você já teve algum ciclocomputador de outra marca?”",
      "is_correct": false
     },
     {
      "body": "“Qual é o seu orçamento para o Edge e os acessórios?”",
      "is_correct": false
     },
     {
      "body": "“O que pesa mais: controlar o esforço ou a segurança?”",
      "is_correct": true
     }
    ]
   }
  ]
 },
 {
  "key": "hrm-circuito",
  "quiz_id": "1b267b48-5204-429b-aac2-cbaa2114b1dc",
  "questions": [
   {
    "body": "Qual é a diferença de resistência à água entre a HRM 200 e a HRM 600?",
    "explanation": "A HRM 200 é 3 ATM (suor e chuva). A HRM 600 é 5 ATM, resistente à natação, com armazenamento offline debaixo d’água.",
    "active": true,
    "alternatives": [
     {
      "body": "HRM 200 é 5 ATM; HRM 600 é 3 ATM, sem uso na água",
      "is_correct": false
     },
     {
      "body": "HRM 200 é 3 ATM; HRM 600 é 5 ATM e resiste à natação",
      "is_correct": true
     },
     {
      "body": "As duas são 3 ATM e nenhuma é indicada para nadar",
      "is_correct": false
     },
     {
      "body": "As duas são 5 ATM e ambas registram a natação",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Segundo o manual, a HRM 200 é indicada para registrar dados de natação?",
    "explanation": "A HRM 200 suporta exposição ocasional à água, e o manual não lista a natação como atividade suportada. Para nadar, a indicada é a HRM 600.",
    "active": true,
    "alternatives": [
     {
      "body": "Não; ela é 3 ATM e a natação não é atividade suportada",
      "is_correct": true
     },
     {
      "body": "Sim, guarda a natação na memória e sincroniza depois",
      "is_correct": false
     },
     {
      "body": "Sim, transmite por Bluetooth debaixo d’água até 3 m",
      "is_correct": false
     },
     {
      "body": "Sim, mas registra só a FC média no fim da sessão",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Para que serve a Gravação de Atividade da HRM 600 pelo app?",
    "explanation": "Permite iniciar um treino pelo Garmin Connect no celular, útil em esportes coletivos em que o relógio no pulso é proibido.",
    "active": true,
    "alternatives": [
     {
      "body": "Gravar notas de voz que vão para o resumo do treino",
      "is_correct": false
     },
     {
      "body": "Guardar 30 dias de FC em repouso para sincronizar depois",
      "is_correct": false
     },
     {
      "body": "Mapear a rota com um GPS interno de baixo consumo",
      "is_correct": false
     },
     {
      "body": "Iniciar o treino pelo app no celular, sem relógio no pulso",
      "is_correct": true
     }
    ]
   },
   {
    "body": "A gravação da HRM 600 iniciada pelo celular é indicada para natação?",
    "explanation": "Para nadar e salvar os dados, a atividade deve ser iniciada em um relógio ou ciclocomputador Garmin pareado.",
    "active": true,
    "alternatives": [
     {
      "body": "Sim, desde que o celular esteja em uma capa IPX8",
      "is_correct": false
     },
     {
      "body": "Sim, e é obrigatória em águas abertas pelo GPS",
      "is_correct": false
     },
     {
      "body": "Não; para nadar, inicie num Garmin pareado",
      "is_correct": true
     },
     {
      "body": "Sim, desde que a bateria da cinta passe de 50%",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quais métricas fazem parte da Dinâmica de Corrida calculada pela HRM 600?",
    "explanation": "Cadência, comprimento de passada, oscilação vertical, proporção vertical, tempo de contato com o solo e equilíbrio, além da Step Speed Loss.",
    "active": true,
    "alternatives": [
     {
      "body": "Cadência, velocidade, potência e VO2 Máximo estimado",
      "is_correct": false
     },
     {
      "body": "Cadência, oscilação vertical e contato com o solo",
      "is_correct": true
     },
     {
      "body": "Passos por minuto, calorias, ritmo e distância total",
      "is_correct": false
     },
     {
      "body": "Frequência máxima, altitude, ritmo e calorias gastas",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a diferença de bateria entre a HRM 200 e a HRM 600?",
    "explanation": "A HRM 200 usa bateria CR2032 substituível, com cerca de 1 ano. A HRM 600 é recarregável, com cerca de 2 meses por carga.",
    "active": true,
    "alternatives": [
     {
      "body": "HRM 200: moeda, cerca de 1 ano; HRM 600: recarregável, 2 meses",
      "is_correct": true
     },
     {
      "body": "HRM 200: recarregável, 2 meses; HRM 600: moeda, cerca de 1 ano",
      "is_correct": false
     },
     {
      "body": "As duas usam bateria de moeda CR2032, com cerca de 1 ano",
      "is_correct": false
     },
     {
      "body": "As duas são recarregáveis, com cerca de 2 meses por carga",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Quantos dispositivos podem se conectar à HRM 200 ao mesmo tempo?",
    "explanation": "A HRM 200 transmite por ANT+ (conexões ilimitadas) e Bluetooth Low Energy (até 3 dispositivos).",
    "active": true,
    "alternatives": [
     {
      "body": "Até 10 por Bluetooth e nenhum por ANT+",
      "is_correct": false
     },
     {
      "body": "Só 1 por vez, em qualquer um dos protocolos",
      "is_correct": false
     },
     {
      "body": "Ilimitados por Bluetooth e até 3 por ANT+",
      "is_correct": false
     },
     {
      "body": "Até 3 por Bluetooth e ilimitados por ANT+",
      "is_correct": true
     }
    ]
   },
   {
    "body": "Como alternar a HRM 200 entre os modos de conexão Segura e Aberta?",
    "explanation": "A HRM 200 tem um botão físico para alternar entre conexão Segura (Bluetooth SIG) e Aberta (ANT+).",
    "active": true,
    "alternatives": [
     {
      "body": "Somente pelas configurações do app Garmin Connect",
      "is_correct": false
     },
     {
      "body": "Tirando e recolocando a bateria perto do relógio",
      "is_correct": false
     },
     {
      "body": "Apertando duas vezes o botão físico do módulo",
      "is_correct": true
     },
     {
      "body": "Segurando o botão por 15 segundos até o LED apagar",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é o procedimento para ativar a HRM 600 antes do primeiro uso?",
    "explanation": "A HRM 600 sai do modo de fábrica depois de ligada a uma fonte de energia por 2 segundos.",
    "active": true,
    "alternatives": [
     {
      "body": "Agitar o módulo por 10 segundos para ativar o sensor",
      "is_correct": false
     },
     {
      "body": "Conectar o módulo a uma fonte de energia por 2 segundos",
      "is_correct": true
     },
     {
      "body": "Parear com o relógio por Bluetooth antes do primeiro treino",
      "is_correct": false
     },
     {
      "body": "Molhar os eletrodos e correr 1 km para calibrar a cinta",
      "is_correct": false
     }
    ]
   },
   {
    "body": "Qual é a rotina correta de limpeza das cintas cardíacas Garmin?",
    "explanation": "Enxágue após cada uso e lavagem manual a cada 7 usos. Evite protetor solar, repelente e produtos com EDTA ou propilenoglicol.",
    "active": true,
    "alternatives": [
     {
      "body": "Enxaguar após cada uso e lavar à mão a cada 7 usos",
      "is_correct": true
     },
     {
      "body": "Lavar na máquina após cada uso, em água até 60 °C",
      "is_correct": false
     },
     {
      "body": "Limpar com álcool isopropílico uma vez por mês",
      "is_correct": false
     },
     {
      "body": "Lavar só quando houver suor visível acumulado",
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
    select coalesce(array_agg(md5('circuitos-quiz-v2|' || (z->>'key') || '|' || g)::uuid), '{}')
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
      v_qid := md5('circuitos-quiz-v2|' || (z->>'key') || '|' || qi)::uuid;

      insert into questions (id, quiz_id, body, explanation, order_index, is_active)
      values (v_qid, (z->>'quiz_id')::uuid, q->>'body', q->>'explanation', qi, (q->>'active')::boolean)
      on conflict (id) do update
         set body = excluded.body, explanation = excluded.explanation,
             order_index = excluded.order_index, is_active = excluded.is_active;

      for a, ai in select e, (o - 1)::int from jsonb_array_elements(q->'alternatives') with ordinality as t(e, o) loop
        insert into alternatives (id, question_id, body, is_correct, order_index)
        values (md5('circuitos-quiz-v2|' || (z->>'key') || '|' || qi || '|' || ai)::uuid, v_qid,
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
-- FIM DA MIGRAÇÃO 175
-- ============================================================================
