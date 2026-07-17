-- ============================================================================
-- GARMIN TRAINING HUB — 028: RECONSTRUÇÃO ESTRUTURAL DOS DEEP DIVES
-- ============================================================================
-- As seeds 060/061 migraram os 8 artigos de "Linhas Especiais" do protótipo
-- index_redesign_v5.html como um único bloco texto_rico (prosa corrida),
-- perdendo toda a estrutura visual rica do original: cards comparativos,
-- tabelas de especificação, passos de script de venda com fala literal e
-- blocos de objeção (pergunta do cliente + resposta). Esta migração
-- reconstrói os 8 artigos usando os 4 tipos de bloco novos (roteiro,
-- objecao, tabela, card_grid — ver src/components/ContentBlocks.js), lidos
-- diretamente do HTML original (linhas indicadas por artigo), sem alterar
-- nenhum dado factual (nomes, números, preços, especificações).
--
-- Usa jsonb_set (não substitui payload inteiro) para preservar cover_url
-- e qualquer outra chave já gravada em payload por fora de 'blocks'.
-- ============================================================================

-- ============================================================================
-- 1. INREACH — linhas 1735-1804 do protótipo
-- ============================================================================
update content_library
set payload = jsonb_set(payload, '{blocks}', $b1$
[
  {"type":"texto_rico","html":"<p>O inReach usa a rede de satélites Iridium® para enviar mensagens e acionar SOS de qualquer lugar do planeta, mesmo sem cobertura de celular. É o produto certo para quem sai da área urbana: trilhas longas, montanhismo, acampamento remoto, pesca em rios e reservatórios isolados, ou trabalho de campo em agronomia, pesquisa e guiamento.</p><h3>Mini 2 vs Mini 3 vs Mini 3 Plus</h3>"},
  {"type":"card_grid","columns":3,"items":[
    {"title":"Mini 2 — Modelo anterior","text":"<ul><li>✓ SOS interativo 24/7 global</li><li>✓ Mensagens bidirecionais via satélite</li><li>✓ Rastreamento compartilhável</li><li>✓ GPS multissistema</li><li>✗ Tela monocromática, sem touch</li><li>✗ Sem sirene integrada</li><li>✗ Bateria menor (1250 mAh)</li><li>✗ Sem voz ou foto via satélite</li></ul>","tags":[]},
    {"title":"Mini 3 — Modelo atual padrão","text":"<ul><li>✓ Tudo do Mini 2, mais:</li><li>✓ Tela colorida touchscreen</li><li>✓ GPS multibanda (fix mais rápido)</li><li>✓ Mapas básicos coloridos</li><li>✓ Sirene sonora integrada</li><li>✓ Bateria maior (1800 mAh)</li><li>✓ Interface muito mais intuitiva</li><li>✗ Sem voz/foto via satélite</li></ul>","tags":[{"label":"★ Recomendado","color":"blue"}]},
    {"title":"Mini 3 Plus — Uso profissional e expedições","text":"<ul><li>✓ Tudo do Mini 3, mais:</li><li>✓ Mensagens de voz de 30s via satélite</li><li>✓ Fotos via satélite</li><li>✓ Rede Iridium Certus (maior banda)</li><li>✓ Comunicação de emergência mais rica</li><li>✓ Ideal para guias e expedições longas</li></ul>","tags":[{"label":"★ Premium","color":"gold"}]}
  ]},
  {"type":"banner","tone":"info","text":"<strong>Quando indicar o Plus?</strong> Guias de expedição, profissionais em campo remoto e aventureiros que fazem viagens longas frequentes. Em emergência, uma mensagem de voz pode salvar vidas."},
  {"type":"texto_rico","html":"<h3>Planos de assinatura</h3><p>Desde junho de 2025 os planos antigos foram substituídos por 4 planos mensais mais simples. <strong>É possível suspender o plano por até 12 meses sem custo</strong> — ótimo argumento para clientes sazonais.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"Enabled — ~US$7,99/mês","text":"SOS interativo + localização básica. Sem mensagens pagas inclusas.<br><em>Para: backup de emergência</em>","tags":[]},
    {"title":"Essential — ~US$14,99/mês","text":"50 mensagens + SOS + rastreamento. Ideal para uso de fim de semana.<br><em>Para: trilheiro de fim de semana</em>","tags":[{"label":"Mais vendido","color":"blue"}]},
    {"title":"Standard — ~US$34,99/mês","text":"Mensagens ilimitadas + rastreamento + clima premium.<br><em>Para: aventureiro frequente</em>","tags":[]},
    {"title":"Expedition — ~US$64,99/mês","text":"Ilimitado completo. Para expedições longas e uso profissional intenso.<br><em>Para: guias e expedições</em>","tags":[]}
  ]},
  {"type":"banner","tone":"warning","text":"Preços em dólares, cobrados no cartão internacional. Confirme valores atuais em explore.garmin.com. Taxa de ativação única de ~US$34,99."},
  {"type":"banner","tone":"info","text":"<strong>Argumento chave:</strong> \"Se você usa só em viagens específicas, pode suspender o plano por até 12 meses sem pagar nada — reativa quando quiser, sem taxa.\""},
  {"type":"card_grid","columns":2,"items":[
    {"title":"✅ Cliente ideal","text":"<ul><li>Faz trilhas longas sem sinal de celular</li><li>Tem família que se preocupa quando viaja</li><li>Pratica montanhismo ou acampamento remoto</li><li>Pesca em rios e reservatórios isolados</li><li>Trabalha em campo (agronomia, pesquisa, guia)</li></ul>","tags":[]},
    {"title":"❌ Não é o produto certo quando...","text":"<ul><li>Só faz trilhas urbanas com cobertura de celular</li><li>Quer GPS para corrida ou ciclismo</li><li>Não aceita pagar assinatura mensal</li><li>Busca apenas um smartwatch de saúde</li></ul>","tags":[]}
  ]},
  {"type":"roteiro","steps":[
    {"title":"Crie o cenário de necessidade","dialog":"Você já foi a algum lugar sem sinal de celular? Trilha mais longa, área rural, pescaria em rio distante?","tip":"Se a resposta for sim — a venda já começou."},
    {"title":"Mostre o problema real","dialog":"Sem sinal, se você se machucar ou se perder, como alguém vai te encontrar? O inReach resolve exatamente isso — funciona em qualquer lugar do mundo, usando satélite Iridium.","tip":""},
    {"title":"Explique o plano de forma simples","dialog":"É como um seguro de vida mensal. Você pode suspender quando não for usar. Para quem vai ao campo 3-4 vezes por ano, é o investimento mais importante que existe.","tip":""}
  ]},
  {"type":"objecao","items":[
    {"question":"Meu celular já tem GPS.","answer":"GPS funciona com satélite, mas mensagens e SOS precisam de sinal de celular. No meio do Cerrado ou da Amazônia não há torre. O inReach usa satélite Iridium — funciona literalmente em qualquer ponto do planeta."},
    {"question":"É caro ter que pagar todo mês.","answer":"Você pode suspender nos meses que não for usar — fica zerado. Muita gente usa 2-3 meses por ano e economiza o resto. E um resgate de helicóptero custa dezenas de milhares de reais..."}
  ]}
]
$b1$::jsonb)
where slug = 'inreach-comunicadores-satelite';

-- ============================================================================
-- 2. GPS DE MÃO — linhas 1807-1843 do protótipo
-- ============================================================================
update content_library
set payload = jsonb_set(payload, '{blocks}', $b2$
[
  {"type":"texto_rico","html":"<p>Os GPS portáteis Garmin são dispositivos dedicados para navegação em trilha, camping, caça e aventuras fora de cobertura. Funcionam sem celular, sem internet e com bateria longa.</p><h3>Linha GPSMAP — Navegação Avançada</h3>"},
  {"type":"tabela","headers":["Modelo","Tela","GPS","Mapas","Diferencial","Para quem"],"rows":[
    ["GPSMAP 65","2.6\" Color","Multibanda","TopoActive Brasil","GPS multibanda + múltiplos satélites. Botões físicos, ótimo com luvas.","Trilheiro / Aventureiro"],
    ["GPSMAP 65s","2.6\" Color","Multibanda","TopoActive Brasil","65 + barômetro + bússola 3 eixos. Altímetro mais preciso.","Trekking avançado"],
    ["GPSMAP 67","3.0\" Color","Multibanda","TopoActive Brasil","Tela maior + altímetro + bússola + barômetro + USB-C. O mais completo da linha portátil.","Expedição / Aventureiro"],
    ["GPSMAP 79","2.6\" Color","Multi-GNSS","BlueChart G3","GPS portátil flutuante para uso náutico. Resistente à água IPX7.","Náutico / Pescador"],
    ["GPSMAP 86","3.0\" Color","Multi-GNSS","BlueChart G3","GPS náutico portátil flutuante + bússola + barômetro. Para uso em embarcações.","Náutico / Marinheiro"],
    ["GPSMAP H1i","3.5\" Color Touch","Multi-GNSS","TopoActive + Caça","GPS específico para caça. Rastreamento de animais + mapas de propriedade.","Caçador avançado"]
  ]},
  {"type":"texto_rico","html":"<h3>Linha eTrex — Robustez e Simplicidade</h3>"},
  {"type":"tabela","headers":["Modelo","Tela","GPS","Bússola/Altímetro","Diferencial","Para quem"],"rows":[
    ["eTrex 22x","2.2\" Color","GPS+GLONASS","Básico (via GPS)","Entrada da linha eTrex. Robusto, simples, mapas TopoActive. Bateria AA.","Caminhante iniciante"],
    ["eTrex 32x","2.2\" Color","GPS+GLONASS","✓ Bússola 3 eixos + Barômetro","22x + bússola real + altímetro barométrico. Para quem precisa de direção sem se mover.","Trilheiro / Trekking"],
    ["eTrex Touch","2.6\" Color Touch","GPS+GLONASS","Básico","Única versão com touchscreen na linha eTrex. Mais fácil de navegar nos menus.","Usuário casual / toque"],
    ["eTrex Solar","2.2\" Mono","Multi-GNSS (5 constelações)","Básico","Carregamento solar + bateria de até 100h. Para quem fica dias sem carregar.","Expedição / Ultra"]
  ]},
  {"type":"card_grid","columns":2,"items":[
    {"title":"🎯 Sinais de identificação","text":"<ul><li>Pergunta por \"GPS de mão\" ou \"GPS portátil\"</li><li>Menciona trilha longa, camping ou expedição</li><li>Fala de caça, pesca em local remoto</li><li>Quer algo que funcione sem celular e sem internet</li><li>Menciona bateria de pilha AA (quer trocar em campo)</li><li>Pergunta sobre mapas do Brasil offline</li></ul>","tags":[]},
    {"title":"💬 Como apresentar","text":"<ul><li>GPSMAP 65/67: trilheiros que querem o melhor com multibanda</li><li>eTrex 22x/32x: custo-benefício, bateria AA, simples de operar</li><li>eTrex Solar: quem vai a expedições longas e não quer carregar</li><li>GPSMAP 79/86: clientes que também usam em barco</li><li>H1i: caçadores — destaque rastreamento de animais e mapas de propriedade</li></ul>","tags":[]}
  ]},
  {"type":"banner","tone":"info","text":"<strong>Argumento de bateria:</strong> \"A pilha AA do eTrex muda tudo para quem vai a campo por vários dias. Você compra duas pilhas num posto de gasolina no meio do sertão e continua navegando — algo que nenhum relógio ou celular consegue fazer.\""},
  {"type":"banner","tone":"info","text":"<strong>GPSMAP 65/67 vs eTrex:</strong> O GPSMAP tem tela maior, GPS multibanda e USB-C. O eTrex é mais compacto, mais barato e usa pilha AA. Para expedições longas sem carregador, o eTrex Solar ou eTrex + pilha AA vence na praticidade."}
]
$b2$::jsonb)
where slug = 'gps-de-mao-gpsmap-etrex';

-- ============================================================================
-- 3. LINHA NÁUTICA — linhas 1847-1859 do protótipo
-- ============================================================================
update content_library
set payload = jsonb_set(payload, '{blocks}', $b3$
[
  {"type":"texto_rico","html":"<p>Sonares e chartplotters para quem leva a sério a pesca e a navegação em rios, lagos e mar.</p>"},
  {"type":"card_grid","columns":3,"items":[
    {"title":"Striker 4 — Entrada","text":"Sonar de pesca 3,5\" com GPS básico. A porta de entrada para localizar peixes com tecnologia.","tags":[{"label":"Pesca Recreativa","color":"blue"},{"label":"Rios e Represas","color":"blue"}]},
    {"title":"Striker Vivid 5cv — Intermediário","text":"Sonar 5\" colorido vívido + ClearVü + GPS. Vê peixes abaixo e ao lado do barco.","tags":[{"label":"ClearVü","color":"blue"},{"label":"Pesca Dedicada","color":"blue"}]},
    {"title":"ECHOMAP UHD2 52cv — Premium","text":"Chartplotter + sonar UHD2 5\". Mapas náuticos BlueChart G3 para o pescador e navegador sério.","tags":[{"label":"Chartplotter","color":"green"},{"label":"UHD2 Sonar","color":"green"},{"label":"Mapas Náuticos","color":"blue"}]}
  ]},
  {"type":"tabela","headers":["Recurso","Striker 4","Striker Vivid 5cv","ECHOMAP UHD2 52cv"],"rows":[
    ["Tela","3,5\" Mono","5\" Colorida Vívida","5\" Colorida HD"],
    ["Sonar","Tradicional","ClearVü","UHD2 ClearVü"],
    ["GPS integrado","✓","✓","✓"],
    ["Mapas náuticos","—","—","✓ BlueChart G3"],
    ["Para quem","Pescador iniciante","Pescador dedicado","Pescador/navegador sério"]
  ]},
  {"type":"banner","tone":"info","text":"<strong>Argumento ClearVü:</strong> \"Com o sonar ClearVü do Vivid 5cv, você vê os peixes embaixo do barco quase como numa foto — não só como manchas tradicionais.\""}
]
$b3$::jsonb)
where slug = 'linha-nautica-sonares-chartplotters';

-- ============================================================================
-- 4. EDGE CICLOCOMPUTADORES — linhas 1862-2151 do protótipo
-- ============================================================================
update content_library
set payload = jsonb_set(payload, '{blocks}', $b4$
[
  {"type":"texto_rico","html":"<p>GPS dedicado para ciclismo: estrada, MTB, gravel e cicloviagem. Tela maior que qualquer relógio, legível sob sol forte, e funcionalidades específicas impossíveis no pulso.</p><h3>Funcionalidades</h3>"},
  {"type":"roteiro","steps":[
    {"title":"⛰️ ClimbPro","dialog":"Você vai subir 4,2 km com gradiente médio de 7% — preparar o ritmo antes da subida é a diferença entre terminar forte ou explodir na metade.","tip":"Exibe dados detalhados de cada subida da rota carregada (nome, distância até o início, comprimento total, ganho de altitude e gradiente médio/máximo). Disponível em todos os modelos: 540, 550, 840, 850, 1040, 1050."},
    {"title":"⚡ Guia de Energia (Stamina)","dialog":"É como o GPS de combustível do carro — mas para o seu corpo. Você vê se vai ter energia sobrando ou se precisa economizar agora para não explodir nos últimos 20 km.","tip":"Monitora em tempo real a reserva de energia do ciclista com base em esforço, potência e distância restante. Disponível no 840, 850, 1040 e 1050 — requer rota carregada no dispositivo."},
    {"title":"📊 Dinâmicas de Ciclismo","dialog":"Com os pedais Rally, o Edge mostra se você está pedalando de forma eficiente ou desperdiçando energia — como um técnico de ciclismo analisando sua biomecânica em tempo real.","tip":"Métricas avançadas: posição da plataforma de força, suavidade de pedalada, equilíbrio esquerda/direita e fase de potência. Disponível no 840, 850, 1040 e 1050 — requer pedal Rally RS/RK/XC ou cassete Di2 compatível."},
    {"title":"👥 GroupRide","dialog":"Para grupos de pedal e treinamentos em equipe, é o fim de perder o companheiro no pelotão. Todos aparecem no mapa — você sabe se alguém furou ou se separou do grupo.","tip":"Grupo virtual em tempo real no mapa, com alertas e mensagens predefinidas. Disponível no 840, 850, 1040 e 1050 — requer celular pareado com dados ativos e Edge compatível para todos os participantes."},
    {"title":"📍 LiveTrack","dialog":"Você manda um link pelo WhatsApp antes de sair pedalando. Sua família acompanha em tempo real onde você está — sem precisar ficar ligando para saber se chegou.","tip":"Compartilha localização em tempo real via link, sem necessidade de app. Disponível em toda a linha (540 a 1050) — requer celular pareado com dados ativos."}
  ]},
  {"type":"texto_rico","html":"<h3>Modelos e comparativo</h3>"},
  {"type":"banner","tone":"info","text":"Todos os modelos têm GPS multibanda (SatIQ), ClimbPro, mapa de rota, navegação turn-by-turn e LiveTrack. A diferença está nas funcionalidades avançadas e na tela."},
  {"type":"tabela","headers":["Função","Edge 540","Edge 550 (2025)","Edge 840","Edge 850 (2025)","Edge 1040","Edge 1050"],"rows":[
    ["Tela","2.6\" Color","2.6\" · 1000 nits","3.0\" Touch+Btn","2.6\" · 1000 nits","3.5\" Touch","3.5\" · 1000 nits"],
    ["GPS Multibanda","✓","✓","✓","✓","✓","✓"],
    ["ClimbPro","✓","✓","✓","✓","✓","✓"],
    ["LiveTrack","✓","✓","✓","✓","✓","✓"],
    ["Guia de Energia","—","—","✓","✓","✓","✓"],
    ["Dinâmicas de Ciclismo","—","—","✓","✓","✓","✓"],
    ["GroupRide","—","—","✓","✓","✓","✓"],
    ["Speaker integrado","—","—","—","✓","—","✓"],
    ["Garmin Pay","—","✓","—","✓","—","✓"],
    ["Bateria GPS","~26h","~12h","~26h","~12h","~35h (+solar)","~20h"],
    ["Perfil ideal","Entrada / Compacto","Entrada / 2025","Intermediário","Intermediário / 2025","Avançado / Tela grande","Elite / Completo"]
  ]},
  {"type":"card_grid","columns":2,"items":[
    {"title":"Edge 540 & 550 — Entrada","text":"GPS multibanda, ClimbPro e navegação precisa. Compacto, botões físicos — funciona com luvas. O <strong>550</strong> é o lançamento 2025 com tela de 1000 nits e speaker integrado.","tags":[{"label":"GPS Multibanda","color":""},{"label":"ClimbPro","color":""},{"label":"LiveTrack","color":""},{"label":"Sem GroupRide","color":"blue"}]},
    {"title":"Edge 840 & 850 — Intermediário ★ Recomendado","text":"Touchscreen + botões físicos. Desbloqueia Guia de Energia, Dinâmicas de Ciclismo e GroupRide. O <strong>850</strong> (2025) tem tela 1000 nits e speaker. Melhor custo-benefício da linha.","tags":[{"label":"GroupRide","color":"green"},{"label":"Guia de Energia","color":"green"},{"label":"Dinâmicas","color":"green"}]},
    {"title":"Edge 1040 & 1050 — Premium","text":"Tela de 3.5\" — a maior da linha. O <strong>1040</strong> tem opção solar (+bateria). O <strong>1050</strong> (2025) tem tela 1000 nits, microfone, Garmin Pay e alertas de perigo. Para quem quer o máximo.","tags":[{"label":"Tela 3.5\"","color":"gold"},{"label":"Garmin Pay (1050)","color":"gold"},{"label":"Solar (1040)","color":"gold"}]},
    {"title":"540 vs 550 — Qual escolher?","text":"<ul><li><strong>540:</strong> botões físicos, sem speaker, preço de entrada</li><li><strong>550:</strong> tela 1000 nits (mais legível no sol) + speaker para alertas sonoros</li><li>Ambos têm GPS multibanda, ClimbPro e LiveTrack</li><li>Nenhum tem GroupRide, Guia de Energia ou Dinâmicas</li></ul>","tags":[]}
  ]},
  {"type":"banner","tone":"info","text":"<strong>⭐ Argumento principal:</strong> \"O celular no guidão trava no sol, esquenta, a tela apaga — e não tem as métricas específicas de ciclismo que o Edge oferece. Um ciclocomputador dedicado é a ferramenta certa para quem leva o pedal a sério.\""},
  {"type":"card_grid","columns":2,"items":[
    {"title":"🎯 Sinais de que o cliente quer um Edge","text":"<ul><li>Usa o celular no suporte e reclama que esquenta ou a tela apaga</li><li>Pedala em grupo e quer ver onde os amigos estão</li><li>Faz subidas longas e quer planejar o esforço</li><li>Já tem medidor de potência (Rally) e quer extrair mais dados</li><li>Faz pedais de mais de 5h e precisa de bateria longa</li><li>Treina com técnico e usa TrainingPeaks ou Zwift</li></ul>","tags":[]},
    {"title":"📦 Qual modelo indicar","text":"<ul><li><strong>Pedaleiro iniciante:</strong> Edge 540 ou 550 — GPS preciso e simples</li><li><strong>Grupo de pedal + treinamento sério:</strong> Edge 840 ou 850 — GroupRide + Guia de Energia</li><li><strong>Ciclista com Rally (potência):</strong> 840+ para Dinâmicas de Ciclismo</li><li><strong>Quem faz gran fondos e centuries:</strong> 1040 — bateria solar + tela grande</li><li><strong>Ciclista de elite ou tudo ou nada:</strong> Edge 1050 — o mais completo</li></ul>","tags":[]}
  ]},
  {"type":"roteiro","steps":[
    {"title":"Identifique o tipo de uso","dialog":"Você pedalada mais em estrada, MTB ou gravel? E treina sozinho ou em grupo?","tip":"Grupo de pedal = empurre o GroupRide (840+). Solo em subidas = ClimbPro (todos). Potência = Dinâmicas (840+)."},
    {"title":"Mostre o ClimbPro na prática","dialog":"Imagina você numa Gran Fondo com 3 subidas pela frente. O Edge já mostra no mapa qual a próxima, quantos quilômetros tem e qual o gradiente médio. Você não vai mais ser surpreendido por uma subida.","tip":""},
    {"title":"Para quem pedala em grupo — venda o GroupRide","dialog":"Sabe quando alguém do grupo fura ou fica para trás e você só descobre 10 km depois? Com o GroupRide, todos aparecem no mapa em tempo real. Dá até para mandar mensagem para o grupo direto pelo Edge.","tip":""}
  ]},
  {"type":"objecao","items":[
    {"question":"Meu celular com suporte já funciona.","answer":"Celular no sol esquenta, trava e a tela escurece automaticamente. O Edge tem tela de até 1000 nits feita para sol forte, não esquenta, não buga e não depende de sinal para o GPS funcionar. Além disso, o celular não tem ClimbPro, GroupRide nem Guia de Energia."},
    {"question":"Meu relógio Garmin já mede ciclismo.","answer":"O relógio é ótimo para multiesporte — mas o Edge tem tela 3x maior, navegação por mapa com visão de birdseye, ClimbPro com gráfico da subida e GroupRide. Para quem leva o ciclismo a sério, os dois se complementam."},
    {"question":"Qual a diferença do 540 para o 840?","answer":"O 540 tem GPS multibanda e ClimbPro — é excelente para navegação precisa. O 840 adiciona Guia de Energia (saber se vai ter \"gasolina\" para o final), Dinâmicas de Ciclismo (se você tem pedais de potência) e GroupRide para pedalar em grupo. Se você treina sério ou pedala em grupo, o 840 vale muito mais."}
  ]},
  {"type":"banner","tone":"info","text":"<strong>Upsell natural:</strong> Se o cliente já tem ou quer os pedais Rally RK 200 (SPD), indique Edge 840 ou superior — é a combinação que desbloqueia todas as Dinâmicas de Ciclismo e transforma os dados de potência em insights de pedalada."}
]
$b4$::jsonb)
where slug = 'edge-ciclocomputadores';

-- ============================================================================
-- 5. APPS, INTEGRAÇÕES E TECNOLOGIAS — linhas 2157-2192 do protótipo
-- ============================================================================
update content_library
set payload = jsonb_set(payload, '{blocks}', $b5$
[
  {"type":"texto_rico","html":"<h3>Apps Garmin</h3>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"📱 Garmin Connect — App principal","text":"Hub central de todos os dados. Sincroniza via Bluetooth. Histórico, insights, planos de treino e comunidade.","tags":[]},
    {"title":"🏪 Connect IQ Store — Apps para o relógio","text":"Spotify, Deezer, Woo, Wikiloc e centenas de apps que rodam direto no relógio. Acesse em apps.garmin.com.","tags":[]},
    {"title":"🛰️ Garmin Explore — Expedições e inReach","text":"Planejamento de trilhas e rotas. Integra com inReach para comunicação via satélite.","tags":[]},
    {"title":"⛳ Garmin Golf — +42.000 campos mapeados","text":"Sincroniza scorecard, distâncias e estatísticas com o relógio Approach.","tags":[]}
  ]},
  {"type":"banner","tone":"info","text":"<strong>Connect IQ</strong> = apps que rodam NO relógio (Spotify, Woo). <strong>Integrações Connect</strong> = plataformas que RECEBEM dados do relógio (Strava, TrainingPeaks)."},
  {"type":"texto_rico","html":"<h3>Integrações</h3>"},
  {"type":"tabela","headers":["Categoria","App","O que sincroniza"],"rows":[
    ["🏃 Corrida","Strava","Atividades, rotas, segmentos e comunidade"],
    ["🏃 Corrida","TrainingPeaks","Treinos planejados, atividades e métricas"],
    ["🚴 Ciclismo","Zwift","Atividades, training load e recuperação"],
    ["🚴 Ciclismo","TrainerRoad","Treinos estruturados e atividades"],
    ["🪁 Aquático","Woo","Altura de saltos em tempo real (kitesurf)"],
    ["⚡ Potência","Stryd","Potência de corrida via Connect IQ"],
    ["🗺️ Nav","Wikiloc","Trilhas + upload automático de percursos"],
    ["🎵 Música","Spotify / Deezer / YouTube Music","Playlists offline no relógio"],
    ["❤️ Saúde","Apple Health","Passos, FC, treinos, sono e calorias"],
    ["🥗 Nutrição","MyFitnessPal","Calorias, exercícios e peso"]
  ]},
  {"type":"texto_rico","html":"<h3>Tecnologias-chave</h3>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"📡 GPS Multibanda (SatIQ)","text":"Usa duas frequências de satélite simultaneamente. Traçado muito mais preciso em cidades com prédios, florestas densas e montanhas. Disponível no FR265, 570, 955, 965, 970, Fenix 8, Enduro 3.","tags":[]},
    {"title":"🧠 FirstBeat Analytics & VO2 Max","text":"Algoritmos desenvolvidos pela empresa finlandesa FirstBeat (adquirida pela Garmin em 2019). Transformam dados brutos em insights: VO2 Max, Training Load, Recovery Time, Training Readiness e muito mais.","tags":[]},
    {"title":"🔋 Body Battery™","text":"Um indicador de bateria do corpo, de 0 a 100. Sobe enquanto a pessoa dorme bem, cai com estresse e exercício — ajuda a entender quando treinar forte e quando descansar. Exclusivo Garmin.","tags":[]},
    {"title":"😴 Monitoramento de Sono","text":"Registra automaticamente fases do sono (leve, profundo, REM), SpO2 noturno, respiração e pontuação de sono. Dados disponíveis no Garmin Connect pela manhã.","tags":[]},
    {"title":"💳 Garmin Pay (NFC)","text":"Pagamento por aproximação diretamente pelo relógio. Funciona com cartões de bancos parceiros cadastrados no Garmin Connect. Disponível em: Fenix 8, FR265, 570, 955, 965, 970, Venu 4, Vivoactive 6 e outros.","tags":[]}
  ]}
]
$b5$::jsonb)
where slug = 'apps-integracoes-tecnologias-garmin';

-- ============================================================================
-- 6. NOVIDADES 2026 — linhas 5833-5942 do protótipo
-- ============================================================================
update content_library
set payload = jsonb_set(payload, '{blocks}', $b6$
[
  {"type":"texto_rico","html":"<p>Os dois lançamentos de 2026 na linha Forerunner. Conheça o que mudou frente ao modelo anterior e como apresentar cada um ao cliente.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"Forerunner 70 — Entrada Compacta · GPS Running","text":"<ul><li>GPS com suporte multissistema (GNSS)</li><li>Sensor cardíaco óptico integrado</li><li>Até 11 dias de bateria (smartwatch)</li><li>Garmin Pay — pagamento pelo relógio</li><li>Body Battery + monitoramento de sono</li><li>Design leve e compacto no pulso</li><li>Indicado: iniciante, presente, casual</li></ul>","tags":[{"label":"Novo 2026","color":""}]},
    {"title":"Forerunner 170 — AMOLED · Compacto · Recursos Avançados","text":"<ul><li>Tela AMOLED + design menor que o FR165</li><li>Sensor Elevate Gen 4</li><li>Relatório noturno + despertador inteligente</li><li>Registro de estilo de vida no relógio</li><li>App de calculadora nativa integrada</li><li>Mais perfis de atividade que o FR165</li><li>⚠️ Sem GPS multibanda · Sem triathlon</li></ul>","tags":[{"label":"Novo 2026","color":"green"}]}
  ]},
  {"type":"tabela","headers":["Recurso","Forerunner 55","Forerunner 70"],"rows":[
    ["Garmin Pay","Sem Garmin Pay","✓ Garmin Pay incluído"],
    ["Bateria","~10 dias","✓ Até 11 dias"],
    ["Design","Padrão","✓ Mais leve e compacto"],
    ["Sensor cardíaco","Sensor HR Gen 3","✓ Sensor HR atualizado"]
  ]},
  {"type":"banner","tone":"info","text":"<strong>Como vender o FR70:</strong> \"O FR70 é o companheiro perfeito pra quem está começando — GPS, frequência cardíaca, até 11 dias de bateria e ainda tem Garmin Pay. Tudo que precisa, no tamanho certo.\""},
  {"type":"tabela","headers":["Recurso","Forerunner 165","Forerunner 170"],"rows":[
    ["Sensor cardíaco","Elevate Gen 4","✓ Elevate Gen 4"],
    ["Tamanho","Maior","✓ Design mais compacto"],
    ["Relatório noturno","Sem relatório noturno","✓ Relatório noturno"],
    ["Despertador inteligente","Sem despertador inteligente","✓ Despertador inteligente"],
    ["Perfis de atividade","Menos perfis de atividade","✓ Mais perfis incluídos"]
  ]},
  {"type":"banner","tone":"info","text":"<strong>Como vender o FR170:</strong> \"O FR170 é menor, tem sensor de FC melhorado e recursos de software mais novos como relatório noturno e despertador inteligente. Se quer multiesporte ou GPS multibanda, o 265 é o próximo passo.\""},
  {"type":"banner","tone":"info","text":"<strong>Quando indicar o FR70?</strong> Iniciante, presente, cliente que nunca usou GPS e quer começar simples. <strong>Quando indicar o FR170?</strong> Corredor que quer algo mais compacto que o FR165, com recursos de software mais recentes (relatório noturno, despertador inteligente) e mais perfis de atividade — mas que não precisa de GPS multibanda nem multiesporte. Para multiesporte ou GPS multibanda, o FR265 em diante."}
]
$b6$::jsonb)
where slug = 'novidades-2026-forerunner-70-170';

-- ============================================================================
-- 7. BLAZE EQUINE WELLNESS — linhas 5947-6029 do protótipo
-- ============================================================================
update content_library
set payload = jsonb_set(payload, '{blocks}', $b7$
[
  {"type":"texto_rico","html":"<p>O primeiro sistema da Garmin dedicado ao monitoramento de saúde e desempenho de cavalos. Fixado na cauda, o sensor acompanha o animal em treinos, competições e no dia a dia do haras — e o cavaleiro vê tudo no celular ou no próprio relógio Garmin.</p><h3>O que o sensor monitora</h3>"},
  {"type":"tabela","headers":["Métrica","Como funciona","Para que serve"],"rows":[
    ["Frequência Cardíaca","Sensor óptico contínuo","Avalia esforço, recuperação e condicionamento do animal"],
    ["Passada & Andamento","Acelerômetro","Detecta assimetrias, irregularidades e evolução no treinamento"],
    ["Velocidade & Distância","Acelerômetro","Registro preciso de cada sessão de treino"],
    ["Temperatura de Pele","Sensor de temperatura","Sinaliza variações que podem indicar febre ou sobrecarga"],
    ["Tempo de Atividade","Detecção automática","Histórico de carga de trabalho e descanso"]
  ]},
  {"type":"texto_rico","html":"<h3>Especificações técnicas</h3>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"📦 Hardware","text":"<ul><li>Sensor removível em housing resistente</li><li>Protetor de cauda em neoprene — lavável e ajustável</li><li>Bateria recarregável: até <strong>25 horas</strong> de uso contínuo</li><li>Resistente à água e à sujeira — uso a campo</li><li>Compatível com múltiplos cavalos no mesmo sensor</li></ul>","tags":[]},
    {"title":"📱 Conectividade & App","text":"<ul><li>App dedicado Blaze — iOS e Android</li><li>Integração com Garmin Connect</li><li>Visualização dos dados no smartwatch Garmin via Connect IQ</li><li>Histórico e relatórios de sessão no app</li><li>Sincronização automática via Bluetooth</li></ul>","tags":[]}
  ]},
  {"type":"texto_rico","html":"<h3>Modos de uso</h3>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"🏇 Treino e Competição","text":"Monitoramento em tempo real durante sessões de adestramento, salto, enduro, corrida e hipismo. O treinador acompanha a FC e a passada enquanto o cavaleiro monta — sem interferir no animal.","tags":[]},
    {"title":"🚚 Transporte & Repouso","text":"Sensor ativo durante o transporte do animal detecta estresse cardíaco e agitação. No repouso, monitora FC e temperatura para sinalizar mudanças que possam indicar problema de saúde.","tags":[]}
  ]},
  {"type":"card_grid","columns":2,"items":[
    {"title":"🎯 Para quem indicar","text":"<ul><li>Treinadores de cavalos de esporte e competição</li><li>Proprietários de haras que acompanham saúde dos animais</li><li>Cavaleiros de enduro — onde controle de FC é fundamental</li><li>Veterinários e profissionais de reabilitação equina</li><li>Clientes que já usam relógio Garmin e têm cavalos</li></ul>","tags":[]},
    {"title":"💬 Como apresentar","text":"<ul><li>\"É um sensor que fica na cauda do cavalo e mede frequência cardíaca, passada e temperatura em tempo real\"</li><li>\"O treinador vê tudo no celular ou no relógio Garmin — durante a montaria mesmo\"</li><li>\"Serve pra treino, competição e até pra monitorar o animal durante transporte\"</li><li>\"Detecta variações de temperatura que podem indicar febre antes de virar problema\"</li></ul>","tags":[]}
  ]},
  {"type":"banner","tone":"info","text":"<strong>Conexão com o ecossistema Garmin:</strong> O cavaleiro que já usa um Fenix, Forerunner ou Epix pode ver os dados do cavalo direto no pulso via Connect IQ — sem tirar o olho da pista. É um argumento forte para clientes que já têm relógio Garmin e têm cavalos."}
]
$b7$::jsonb)
where slug = 'blaze-equine-wellness';

-- ============================================================================
-- 8. MARQ GEN 2 — linhas 6033-6111 do protótipo
-- ============================================================================
update content_library
set payload = jsonb_set(payload, '{blocks}', $b8$
[
  {"type":"texto_rico","html":"<p>Não é o Fenix mais caro. O MARQ é uma categoria à parte — fabricado à mão nos EUA com materiais que não aparecem em nenhum outro relógio Garmin. Titânio, cristal de safira e tecnologia de ponta dentro de uma peça que compete visualmente com relógios de luxo tradicionais.</p><h3>Por que é considerado luxo de verdade?</h3>"},
  {"type":"tabela","headers":["Elemento","MARQ Gen 2","Outros Garmin premium"],"rows":[
    ["Caixa","Titânio grau 5 / fibra de carbono","Aço inox ou alumínio reforçado"],
    ["Vidro","Cristal de safira","Gorilla Glass ou vidro temperado"],
    ["Fabricação","Montagem artesanal nos EUA","Produção em linha industrial"],
    ["Pulseira","Couro italiano / silicone premium / nylon premium","Silicone ou borracha padrão"],
    ["GPS","Multibanda — precisão máxima","Varia por modelo"],
    ["Mapas","TopoActive + mapas de trilha completos","Varia por modelo"]
  ]},
  {"type":"texto_rico","html":"<h3>As três versões</h3>"},
  {"type":"card_grid","columns":3,"items":[
    {"title":"MARQ Commander — Tático","text":"Titânio com pulseira em couro italiano. Estética sóbria e militar. GPS multibanda, mapas completos, modo tático, navegação avançada. Para o executivo ou militar que quer presença e tecnologia no mesmo pulso.","tags":[{"label":"Titânio · Couro Italiano","color":"gold"}]},
    {"title":"MARQ Athlete — Esportivo","text":"Focado em corrida e triathlon de alto nível. Titânio com acabamento sport premium. GPS multibanda, Training Readiness, métricas avançadas. Para o atleta que não abre mão de visual sofisticado mesmo no treino.","tags":[{"label":"Titânio · Sport Premium","color":"gold"}]},
    {"title":"MARQ Golfer Carbon — Golfe","text":"Caixa em fibra de carbono — mais leve que titânio. GPS com mais de 42.000 campos mapeados, modo caddie digital, distâncias automáticas, estatísticas de jogo. O único relógio de golfe que é de luxo de verdade.","tags":[{"label":"Fibra de Carbono · Golfe","color":"gold"}]}
  ]},
  {"type":"texto_rico","html":"<h3>Como vender</h3>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"🎯 Perfil do cliente MARQ","text":"<ul><li>Usa ou usou relógio de luxo — sabe reconhecer qualidade de material</li><li>Atleta de alto nível que quer o melhor equipamento disponível</li><li>Executivo que pratica esporte e quer o mesmo relógio nas duas situações</li><li>Golfista que valoriza o equipamento tanto quanto o jogo</li><li>Presentear alguém que já tem tudo — algo diferente e com significado</li></ul>","tags":[]},
    {"title":"💬 Como abordar naturalmente","text":"<ul><li>\"O MARQ é fabricado à mão nos EUA — não é o mesmo processo dos outros Garmin\"</li><li>\"A caixa é titânio grau 5, o vidro é safira. Os mesmos materiais de relógio de luxo, com a tecnologia da Garmin dentro\"</li><li>\"Quem tem MARQ não precisa trocar de relógio entre a reunião e o treino\"</li><li>Para o Golfer: \"Mais de 42 mil campos mapeados — e a caixa é fibra de carbono, mais leve que titânio\"</li></ul>","tags":[]}
  ]},
  {"type":"banner","tone":"info","text":"<strong>Argumento principal:</strong> A diferença entre o MARQ e um Fenix topo de linha não é só preço — é categoria de produto. O Fenix é o melhor relógio esportivo. O MARQ é um relógio de luxo com tecnologia esportiva. São coisas diferentes, para clientes diferentes."},
  {"type":"banner","tone":"info","text":"<strong>Golfer Carbon:</strong> Fibra de carbono é mais leve que titânio e mais rara como material de relógio. Para o golfista, destaque que o relógio não atrapalha o swing por ser tão leve — e que os mapas de campo são os mais completos do mercado."}
]
$b8$::jsonb)
where slug = 'marq-gen-2-linha-de-luxo';

-- ============================================================================
-- FIM DA MIGRAÇÃO 028
-- ============================================================================
