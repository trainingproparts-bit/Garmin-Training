-- ============================================================================
-- GARMIN TRAINING HUB — 029: ABAS INTERNAS (itabs) PARA OS 3 GUIAS MAIS DENSOS
-- ============================================================================
-- Complementa 028_deep_dive_rich_blocks.sql. Os 3 guias mais extensos —
-- inReach, Edge e Apps/Integrações/Tecnologias — usavam um seletor de abas
-- (.itabs) no protótipo original (index_redesign_v5.html) para evitar
-- rolagem infinita: inReach tinha "Mini 2 vs 3 vs Plus" / "Planos de
-- Assinatura" / "Como Vender"; Edge tinha "Funcionalidades" / "Modelos &
-- Comparativo" / "Como Vender"; Materiais tinha "Apps Garmin" / "Integrações"
-- / "Tecnologias". A migração 028 preservou o conteúdo mas achatou tudo numa
-- lista sequencial única — esta migração reagrupa os mesmos blocos (sem
-- alterar nenhum texto) na estrutura `{ intro, tabs: [{label, blocks}] }`
-- que `src/pages/deepDiveDetail.js` sabe renderizar como abas clicáveis.
--
-- Os outros 5 guias (GPS de mão, Náutica, Novidades 2026, Blaze, MARQ) não
-- tinham abas no protótipo original — continuam com `{ blocks: [...] }` liso.
--
-- `payload - 'blocks' || jsonb_build_object(...)` remove a chave antiga e
-- adiciona 'intro'/'tabs', preservando cover_url ou qualquer outra chave.
-- ============================================================================

-- ============================================================================
-- 1. INREACH
-- ============================================================================
update content_library
set payload = (payload - 'blocks') || jsonb_build_object(
  'intro', '<p>O inReach usa a rede de satélites Iridium® para enviar mensagens e acionar SOS de qualquer lugar do planeta, mesmo sem cobertura de celular. É o produto certo para quem sai da área urbana: trilhas longas, montanhismo, acampamento remoto, pesca em rios e reservatórios isolados, ou trabalho de campo em agronomia, pesquisa e guiamento.</p>',
  'tabs', $t1$
[
  {"label":"Mini 2 vs 3 vs Plus","blocks":[
    {"type":"card_grid","columns":3,"items":[
      {"title":"Mini 2 — Modelo anterior","text":"<ul><li>✓ SOS interativo 24/7 global</li><li>✓ Mensagens bidirecionais via satélite</li><li>✓ Rastreamento compartilhável</li><li>✓ GPS multissistema</li><li>✗ Tela monocromática, sem touch</li><li>✗ Sem sirene integrada</li><li>✗ Bateria menor (1250 mAh)</li><li>✗ Sem voz ou foto via satélite</li></ul>","tags":[]},
      {"title":"Mini 3 — Modelo atual padrão","text":"<ul><li>✓ Tudo do Mini 2, mais:</li><li>✓ Tela colorida touchscreen</li><li>✓ GPS multibanda (fix mais rápido)</li><li>✓ Mapas básicos coloridos</li><li>✓ Sirene sonora integrada</li><li>✓ Bateria maior (1800 mAh)</li><li>✓ Interface muito mais intuitiva</li><li>✗ Sem voz/foto via satélite</li></ul>","tags":[{"label":"★ Recomendado","color":"blue"}]},
      {"title":"Mini 3 Plus — Uso profissional e expedições","text":"<ul><li>✓ Tudo do Mini 3, mais:</li><li>✓ Mensagens de voz de 30s via satélite</li><li>✓ Fotos via satélite</li><li>✓ Rede Iridium Certus (maior banda)</li><li>✓ Comunicação de emergência mais rica</li><li>✓ Ideal para guias e expedições longas</li></ul>","tags":[{"label":"★ Premium","color":"gold"}]}
    ]},
    {"type":"banner","tone":"info","text":"<strong>Quando indicar o Plus?</strong> Guias de expedição, profissionais em campo remoto e aventureiros que fazem viagens longas frequentes. Em emergência, uma mensagem de voz pode salvar vidas."}
  ]},
  {"label":"Planos de Assinatura","blocks":[
    {"type":"texto_rico","html":"<p>Desde junho de 2025 os planos antigos foram substituídos por 4 planos mensais mais simples. <strong>É possível suspender o plano por até 12 meses sem custo</strong> — ótimo argumento para clientes sazonais.</p>"},
    {"type":"card_grid","columns":2,"items":[
      {"title":"Enabled — ~US$7,99/mês","text":"SOS interativo + localização básica. Sem mensagens pagas inclusas.<br><em>Para: backup de emergência</em>","tags":[]},
      {"title":"Essential — ~US$14,99/mês","text":"50 mensagens + SOS + rastreamento. Ideal para uso de fim de semana.<br><em>Para: trilheiro de fim de semana</em>","tags":[{"label":"Mais vendido","color":"blue"}]},
      {"title":"Standard — ~US$34,99/mês","text":"Mensagens ilimitadas + rastreamento + clima premium.<br><em>Para: aventureiro frequente</em>","tags":[]},
      {"title":"Expedition — ~US$64,99/mês","text":"Ilimitado completo. Para expedições longas e uso profissional intenso.<br><em>Para: guias e expedições</em>","tags":[]}
    ]},
    {"type":"banner","tone":"warning","text":"Preços em dólares, cobrados no cartão internacional. Confirme valores atuais em explore.garmin.com. Taxa de ativação única de ~US$34,99."},
    {"type":"banner","tone":"info","text":"<strong>Argumento chave:</strong> \"Se você usa só em viagens específicas, pode suspender o plano por até 12 meses sem pagar nada — reativa quando quiser, sem taxa.\""}
  ]},
  {"label":"Como Vender","blocks":[
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
  ]}
]
$t1$::jsonb
)
where slug = 'inreach-comunicadores-satelite';

-- ============================================================================
-- 2. EDGE CICLOCOMPUTADORES
-- ============================================================================
update content_library
set payload = (payload - 'blocks') || jsonb_build_object(
  'intro', '<p>GPS dedicado para ciclismo: estrada, MTB, gravel e cicloviagem. Tela maior que qualquer relógio, legível sob sol forte, e funcionalidades específicas impossíveis no pulso.</p>',
  'tabs', $t2$
[
  {"label":"Funcionalidades","blocks":[
    {"type":"roteiro","steps":[
      {"title":"⛰️ ClimbPro","dialog":"Você vai subir 4,2 km com gradiente médio de 7% — preparar o ritmo antes da subida é a diferença entre terminar forte ou explodir na metade.","tip":"Exibe dados detalhados de cada subida da rota carregada (nome, distância até o início, comprimento total, ganho de altitude e gradiente médio/máximo). Disponível em todos os modelos: 540, 550, 840, 850, 1040, 1050."},
      {"title":"⚡ Guia de Energia (Stamina)","dialog":"É como o GPS de combustível do carro — mas para o seu corpo. Você vê se vai ter energia sobrando ou se precisa economizar agora para não explodir nos últimos 20 km.","tip":"Monitora em tempo real a reserva de energia do ciclista com base em esforço, potência e distância restante. Disponível no 840, 850, 1040 e 1050 — requer rota carregada no dispositivo."},
      {"title":"📊 Dinâmicas de Ciclismo","dialog":"Com os pedais Rally, o Edge mostra se você está pedalando de forma eficiente ou desperdiçando energia — como um técnico de ciclismo analisando sua biomecânica em tempo real.","tip":"Métricas avançadas: posição da plataforma de força, suavidade de pedalada, equilíbrio esquerda/direita e fase de potência. Disponível no 840, 850, 1040 e 1050 — requer pedal Rally RS/RK/XC ou cassete Di2 compatível."},
      {"title":"👥 GroupRide","dialog":"Para grupos de pedal e treinamentos em equipe, é o fim de perder o companheiro no pelotão. Todos aparecem no mapa — você sabe se alguém furou ou se separou do grupo.","tip":"Grupo virtual em tempo real no mapa, com alertas e mensagens predefinidas. Disponível no 840, 850, 1040 e 1050 — requer celular pareado com dados ativos e Edge compatível para todos os participantes."},
      {"title":"📍 LiveTrack","dialog":"Você manda um link pelo WhatsApp antes de sair pedalando. Sua família acompanha em tempo real onde você está — sem precisar ficar ligando para saber se chegou.","tip":"Compartilha localização em tempo real via link, sem necessidade de app. Disponível em toda a linha (540 a 1050) — requer celular pareado com dados ativos."}
    ]}
  ]},
  {"label":"Modelos & Comparativo","blocks":[
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
    ]}
  ]},
  {"label":"Como Vender","blocks":[
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
  ]}
]
$t2$::jsonb
)
where slug = 'edge-ciclocomputadores';

-- ============================================================================
-- 3. APPS, INTEGRAÇÕES E TECNOLOGIAS
-- ============================================================================
update content_library
set payload = (payload - 'blocks') || jsonb_build_object(
  'intro', '',
  'tabs', $t3$
[
  {"label":"Apps Garmin","blocks":[
    {"type":"card_grid","columns":2,"items":[
      {"title":"📱 Garmin Connect — App principal","text":"Hub central de todos os dados. Sincroniza via Bluetooth. Histórico, insights, planos de treino e comunidade.","tags":[]},
      {"title":"🏪 Connect IQ Store — Apps para o relógio","text":"Spotify, Deezer, Woo, Wikiloc e centenas de apps que rodam direto no relógio. Acesse em apps.garmin.com.","tags":[]},
      {"title":"🛰️ Garmin Explore — Expedições e inReach","text":"Planejamento de trilhas e rotas. Integra com inReach para comunicação via satélite.","tags":[]},
      {"title":"⛳ Garmin Golf — +42.000 campos mapeados","text":"Sincroniza scorecard, distâncias e estatísticas com o relógio Approach.","tags":[]}
    ]}
  ]},
  {"label":"Integrações","blocks":[
    {"type":"banner","tone":"info","text":"<strong>Connect IQ</strong> = apps que rodam NO relógio (Spotify, Woo). <strong>Integrações Connect</strong> = plataformas que RECEBEM dados do relógio (Strava, TrainingPeaks)."},
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
    ]}
  ]},
  {"label":"Tecnologias","blocks":[
    {"type":"card_grid","columns":2,"items":[
      {"title":"📡 GPS Multibanda (SatIQ)","text":"Usa duas frequências de satélite simultaneamente. Traçado muito mais preciso em cidades com prédios, florestas densas e montanhas. Disponível no FR265, 570, 955, 965, 970, Fenix 8, Enduro 3.","tags":[]},
      {"title":"🧠 FirstBeat Analytics & VO2 Max","text":"Algoritmos desenvolvidos pela empresa finlandesa FirstBeat (adquirida pela Garmin em 2019). Transformam dados brutos em insights: VO2 Max, Training Load, Recovery Time, Training Readiness e muito mais.","tags":[]},
      {"title":"🔋 Body Battery™","text":"Um indicador de bateria do corpo, de 0 a 100. Sobe enquanto a pessoa dorme bem, cai com estresse e exercício — ajuda a entender quando treinar forte e quando descansar. Exclusivo Garmin.","tags":[]},
      {"title":"😴 Monitoramento de Sono","text":"Registra automaticamente fases do sono (leve, profundo, REM), SpO2 noturno, respiração e pontuação de sono. Dados disponíveis no Garmin Connect pela manhã.","tags":[]},
      {"title":"💳 Garmin Pay (NFC)","text":"Pagamento por aproximação diretamente pelo relógio. Funciona com cartões de bancos parceiros cadastrados no Garmin Connect. Disponível em: Fenix 8, FR265, 570, 955, 965, 970, Venu 4, Vivoactive 6 e outros.","tags":[]}
    ]}
  ]}
]
$t3$::jsonb
)
where slug = 'apps-integracoes-tecnologias-garmin';

-- ============================================================================
-- FIM DA MIGRAÇÃO 029
-- ============================================================================
