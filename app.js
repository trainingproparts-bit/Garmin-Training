// ============================================================
// app.js — Garmin Training by Proparts
// ============================================================

// ── SHEETS (registro de resultados do quiz) ──────────────────
const SHEETS_URL =
  "https://script.google.com/macros/s/AKfycbyv0UhVSiM52K-g8A31Myih_UMMGKhZIwRAAMcMW_3WwYofjgtNCV-6J7p6iv0ODSsU/exec";

// ── NAVEGAÇÃO ────────────────────────────────────────────────
function openPanel(id) {
  document.getElementById("home").style.display = "none";
  document.querySelectorAll(".panel").forEach((p) => p.classList.remove("active"));
  document.getElementById("panel-" + id).classList.add("active");
  window.scrollTo(0, 0);
}

function goHome() {
  document.querySelectorAll(".panel").forEach((p) => p.classList.remove("active"));
  document.getElementById("home").style.display = "block";
  window.scrollTo(0, 0);
}

// ── INNER TABS (Scripts) ─────────────────────────────────────
function showItab(showId, hideId, tabEl) {
  const s = document.getElementById(showId);
  const h = document.getElementById(hideId);
  if (s) s.style.display = "block";
  if (h) h.style.display = "none";
  if (tabEl) {
    tabEl.closest(".itabs").querySelectorAll(".itab").forEach((t) => t.classList.remove("active"));
    tabEl.classList.add("active");
  }
}

// ── INNER TABS (inReach) ─────────────────────────────────────
function switchIRTab(tabId, tabEl) {
  ["ir-compare", "ir-planos", "ir-venda"].forEach((id) => {
    const el = document.getElementById(id);
    if (el) el.style.display = id === tabId ? "block" : "none";
  });
  document.querySelectorAll("#panel-inreach .itabs .itab").forEach((t) => t.classList.remove("active"));
  if (tabEl) tabEl.classList.add("active");
}

// ── INNER TABS (Materiais) ───────────────────────────────────
function showMatTab(id) {
  ["m-apps", "m-int", "m-tech"].forEach((i) => {
    const el = document.getElementById(i);
    if (el) el.style.display = i === id ? "block" : "none";
  });
  document.getElementById("matTabs").querySelectorAll(".itab").forEach((t, i) => {
    t.classList.toggle("active", ["m-apps", "m-int", "m-tech"][i] === id);
  });
}

// ── ACCORDION ────────────────────────────────────────────────
function toggleAcc(el) {
  el.closest(".acc-item").classList.toggle("open");
}

// ── MODAL GENÉRICO (fechar ao clicar no overlay) ─────────────
function closeModal(id, e) {
  if (e.target === document.getElementById(id)) {
    document.getElementById(id).classList.remove("open");
  }
}

// ════════════════════════════════════════════════════════════
// DADOS
// ════════════════════════════════════════════════════════════

// ── PERFIS DE CLIENTES ───────────────────────────────────────
const profiles = [
  {
    emoji: "🏃",
    name: "Corredor Iniciante",
    tag: "Começando a correr ou indo para a primeira meia maratona",
    tags: ["Corrida", "Iniciante", "Fitness"],
    sinais: [
      "Fala de começar a correr ou de primeira corrida",
      "Pergunta sobre ritmo e distância",
      "Mencionou um aplicativo de treino",
    ],
    comunicacao: [
      "Forerunner 165 é o campeão custo-benefício para este perfil",
      "Destaque GPS sempre ligado e feedback de treino",
      "Mencione Garmin Coach — plano de treino grátis no app",
    ],
    objections: [
      { q: "O celular já tem GPS.", a: "Com celular no braço o movimento fica limitado e a bateria acaba rápido. O Forerunner 165 é leve, vai no pulso e dura 11 dias." },
      { q: "É muito caro para iniciante.", a: "O 165 é a porta de entrada Garmin com tela AMOLED. Costuma pagar seu valor em motivação — quem monitora os treinos desiste muito menos." },
    ],
    produtos: ["Forerunner 165", "Forerunner 165 Music", "Vivoactive 6"],
    primario: "Forerunner 165",
  },
  {
    emoji: "🏅",
    name: "Corredor Dedicado",
    tag: "Treina de 4 a 6x por semana, já correu maratonas",
    tags: ["Corrida", "Avançado", "Performance"],
    sinais: [
      "Fala de plano de treino, VO2 Max ou pace",
      "Já tem relógio básico e quer evoluir",
      "Menciona planilha de treino ou treinador",
    ],
    comunicacao: [
      "Forerunner 265 ou 965 dependendo do orçamento",
      "Destaque HRV Status, Training Readiness e PacePRO",
      "Forerunner 965 tem mapas coloridos — diferencial para provas longas",
    ],
    objections: [
      { q: "Meu Forerunner 55 ainda funciona.", a: "O salto para o 265 é enorme: tela AMOLED, HRV diário, Training Readiness e GPS multibanda. Você vai enxergar o treino de outro ângulo." },
    ],
    produtos: ["Forerunner 265", "Forerunner 265S", "Forerunner 965"],
    primario: "Forerunner 265",
  },
  {
    emoji: "🌲",
    name: "Aventureiro Outdoor",
    tag: "Trilhas, camping, escalada, natureza",
    tags: ["Outdoor", "Trilha", "Aventura"],
    sinais: [
      "Menciona trilhas, camping, montanhismo",
      "Pergunta sobre durabilidade, bateria",
      "Fala de bússola, altímetro, barômetro",
      "Interessa em mapas topográficos",
    ],
    comunicacao: [
      "Instinct 3 para custo-benefício outdoor robusto",
      "Fenix 8 para quem quer tudo no pulso",
      "GPSMAP 67 para quem prefere GPS de mão com topo",
      "Destaque MIL-STD-810 e bateria de dias",
    ],
    objections: [
      { q: "Uso o celular para GPS em trilha.", a: "Bateria de celular acaba rápido com GPS ativo. O Instinct 3 dura até 26 dias. Em trilha longa, o relógio é o plano principal — não o backup." },
      { q: "Para que o inReach se tenho rádio?", a: "Rádio funciona em linha de visão. O inReach usa satélite — você manda mensagem de dentro de um cânion ou da Amazônia. Se precisar de resgate, a central Garmin Response aciona em qualquer lugar do mundo." },
    ],
    produtos: ["Instinct 3", "Fenix 8", "GPSMAP 65", "GPSMAP 67", "inReach Mini 3"],
    primario: "Instinct 3",
  },
  {
    emoji: "❤️",
    name: "Foco em Saúde",
    tag: "Quer melhorar saúde geral, acompanhar atividade",
    tags: ["Saúde", "Fitness", "Bem-estar"],
    sinais: [
      "Menciona academia, caminhada como atividades",
      "Pergunta sobre calorias, passos, sono",
      "Fala de médico que recomendou monitorar FC",
      "Não se identifica como atleta",
    ],
    comunicacao: [
      "Vivoactive 6 com 80 modos esportivos perfeito",
      "Destaque Body Battery e monitoramento de sono",
      "Integração com MyFitnessPal para controle de calorias",
      "Venu 4 se quiser a experiência visual premium",
    ],
    objections: [
      { q: "A balança e o celular já me dão essas informações.", a: "O diferencial é o contexto contínuo — o relógio monitora 24 horas: como o sono afeta o estresse do dia seguinte, como a caminhada impactou a recuperação. Uma visão holística que app de celular não consegue dar." },
    ],
    produtos: ["Vivoactive 6", "Venu 4", "Forerunner 165"],
    primario: "Vivoactive 6",
  },
  {
    emoji: "🚴",
    name: "Ciclista",
    tag: "MTB ou estrada, usa bike com frequência",
    tags: ["Ciclismo", "Bike", "MTB"],
    sinais: [
      "Fala de FTP, cadência, potência",
      "Menciona Strava ou Zwift",
      "Tem bike de carbono ou quer pedal medidor de potência",
    ],
    comunicacao: [
      "Edge 540/550 para ciclista intermediário",
      "Edge 840 para tela touch + GPS multibanda",
      "Edge 1050 para elite que quer tela 3.5" e 1000 nits",
      "Rally RK200 pedal medidor de potência SPD",
    ],
    objections: [
      { q: "Uso o celular no guidão.", a: "Celular não foi feito para ciclismo. O Edge tem tela anti-reflexo, botões operáveis com luva, bateria de 26h e roteamento específico para bike — incluindo aviso de superfície de estrada." },
    ],
    produtos: ["Edge 540", "Edge 550", "Edge 840", "Edge 1050", "Rally RK200"],
    primario: "Edge 540",
  },
  {
    emoji: "🏊",
    name: "Triatleta",
    tag: "Pratica swim/bike/run, busca performance total",
    tags: ["Triathlon", "Multi-esporte", "Performance"],
    sinais: [
      "Fala de brick training, T1/T2",
      "Menciona Ironman ou 70.3",
      "Quer multiesporte em um único relógio",
    ],
    comunicacao: [
      "Forerunner 965 ou Fenix 8 são os dois pilares do triathlon Garmin",
      "Destaque troca automática de modalidade e GPS multibanda",
      "Fenix 8 AMOLED Solar para quem não abre mão de nada",
    ],
    objections: [
      { q: "O Fenix é muito caro.", a: "O Forerunner 965 entrega 95% do Fenix no triathlon a um preço menor. O Fenix adiciona construção premium em titânio, Solar e mais sensores — para quem faz Ironman isso se paga em anos de uso." },
    ],
    produtos: ["Forerunner 965", "Fenix 8", "Fenix 8 Pro"],
    primario: "Forerunner 965",
  },
  {
    emoji: "🤿",
    name: "Mergulhador",
    tag: "Pratica mergulho recreativo ou técnico",
    tags: ["Mergulho", "Dive", "Aquático"],
    sinais: [
      "Menciona profundidade, descompresso, nitrox",
      "Pergunta sobre computador de mergulho",
      "Fala de mergulho técnico ou trimix",
    ],
    comunicacao: [
      "Descent G1/G2 para mergulho recreativo",
      "Descent Mk3i para técnico sério",
      "Descent X30 com autonomia de gás e modo técnico",
      "Destaque: smartwatch completo fora da água",
    ],
    objections: [
      { q: "Prefiro um computador de mergulho separado.", a: "Computadores separados não têm GPS de superfície, mapas ou monitoramento de saúde. O Descent faz tudo isso e é um smartwatch completo no dia a dia." },
      { q: "O X30 é muito caro.", a: "Para mergulho técnico com trimix e descompressão complexa, não há comparação. É o nível do Shearwater Perdix em hardware de relógio premium." },
    ],
    produtos: ["Descent G1", "Descent G2", "Descent Mk3i", "Descent X30"],
    primario: "Descent G2",
  },
  {
    emoji: "⛳",
    name: "Golfista",
    tag: "Joga golfe com regularidade",
    tags: ["Golfe", "Golf"],
    sinais: [
      "Fala de green, par, bunker, handicap",
      "Pergunta por GPS de golfe",
      "Usa luvas de golfe ou tem look do esporte",
    ],
    comunicacao: [
      "Approach S44 para entrada com 42.000 campos",
      "Approach S50 para a experiência mais completa com AMOLED",
      "Destaque distâncias automáticas do green",
      "Scorecard digital e estatísticas de handicap",
    ],
    objections: [
      { q: "O app no celular já tem distâncias.", a: "O app serve, mas durante o swing você não vai olhar para o celular. O relógio no pulso mostra a distância instantaneamente, sem tirar o foco do jogo." },
    ],
    produtos: ["Approach S44", "Approach S50"],
    primario: "Approach S50",
  },
];

// ── PRODUTOS ─────────────────────────────────────────────────
const prods = [
  // FORERUNNER
  { name: "Forerunner 165", s: "Forerunner", cat: "forerunner", lvl: 2, para: "Corredor Iniciante", dest: "AMOLED, GPS, 11 dias de bateria. Melhor custo-benefício para quem está começando." },
  { name: "Forerunner 165 Music", s: "Forerunner", cat: "forerunner", lvl: 2, para: "Corredor Iniciante c/ Música", dest: "Forerunner 165 + música offline sem celular." },
  { name: "Forerunner 265", s: "Forerunner", cat: "forerunner", lvl: 3, para: "Corredor Intermediário", dest: "AMOLED, HRV Status, Training Readiness. GPS multibanda preciso." },
  { name: "Forerunner 265S", s: "Forerunner", cat: "forerunner", lvl: 3, para: "Corredor/Pulso menor", dest: "Forerunner 265 em caixa menor 42mm." },
  { name: "Forerunner 965", s: "Forerunner", cat: "forerunner", lvl: 4, para: "Corredor Avançado / Triatleta", dest: "Mapas coloridos, multibanda, Triathlon automático. Topo da linha Forerunner." },
  // FENIX
  { name: "Fenix 8 43mm", s: "Fenix", cat: "outdoor", lvl: 4, para: "Atleta Premium", dest: "AMOLED, Solar, multibanda. Construção premium titânio/safira." },
  { name: "Fenix 8 47mm", s: "Fenix", cat: "outdoor", lvl: 4, para: "Atleta Premium", dest: "Versão maior do Fenix 8 com mais bateria." },
  { name: "Fenix 8 Pro", s: "Fenix", cat: "outdoor", lvl: 5, para: "Atleta Elite", dest: "Fenix 8 com todas as funções de satélite e comunicação." },
  // INSTINCT
  { name: "Instinct 3 45mm", s: "Instinct", cat: "outdoor", lvl: 2, para: "Outdoor / Aventureiro", dest: "MIL-STD-810, GPS multibanda, até 26 dias. Custo-benefício outdoor." },
  { name: "Instinct 3 Solar", s: "Instinct", cat: "outdoor", lvl: 3, para: "Outdoor / Expedição", dest: "Instinct 3 + carregamento solar. Bateria quase infinita ao sol." },
  // LIFESTYLE
  { name: "Venu 4", s: "Venu", cat: "lifestyle", lvl: 3, para: "Mulher / Lifestyle / Bem-estar", dest: "AMOLED premium, saúde feminina completa. Até 9 dias de bateria." },
  { name: "Venu X1", s: "Venu", cat: "lifestyle", lvl: 4, para: "Lifestyle Premium", dest: "Design quadrado moderno. Para quem quer visual tipo Apple Watch." },
  { name: "Vivoactive 6", s: "Vivoactive", cat: "lifestyle", lvl: 2, para: "Academia / Lifestyle", dest: "80 modos esportivos, músicas offline. Versátil para academia e dia a dia." },
  { name: "Lily 2", s: "Lily", cat: "lifestyle", lvl: 1, para: "Mulher / Lifestyle / Presente", dest: "Design joia. Menor relógio Garmin. Elegância e saúde no pulso." },
  { name: "Lily 2 Active", s: "Lily", cat: "lifestyle", lvl: 2, para: "Mulher / Lifestyle / Corrida", dest: "Lily com GPS integrado + resistência à água. Corrida com estilo." },
  // MERGULHO
  { name: "Descent G1", s: "Descent", cat: "mergulho", lvl: 2, para: "Mergulhador Recreativo", dest: "Entrada no mundo Descent. Dive watch + GPS. Até 100m." },
  { name: "Descent G2", s: "Descent", cat: "mergulho", lvl: 3, para: "Mergulhador Recreativo Avançado", dest: "Multigas, AMOLED, GPS. Melhor custo-benefício Descent." },
  { name: "Descent Mk3i", s: "Descent", cat: "mergulho", lvl: 4, para: "Mergulhador Técnico", dest: "Titânio, AMOLED, multibanda. Para mergulhadores técnicos sérios." },
  { name: "Descent X30", s: "Descent", cat: "mergulho", lvl: 5, para: "Mergulhador Técnico Avançado", dest: "Autonomia de gás, trimix, modo técnico avançado." },
  // EDGE (CICLISMO)
  { name: "Edge 540", s: "Edge", cat: "edge", lvl: 2, para: "Ciclista Intermediário", dest: "GPS multibanda, botões físicos. Bateria 26h. Compacto e preciso." },
  { name: "Edge 550", s: "Edge", cat: "edge", lvl: 2, para: "Ciclista / Tela Brilhante", dest: "2025. Tela 1000 nits + speaker + Cycling Coach. Sucessor do 540." },
  { name: "Edge 840", s: "Edge", cat: "edge", lvl: 3, para: "Ciclista Dedicado", dest: "Touchscreen + botões, GPS multibanda, ClimbPro. Ideal para MTB e estrada." },
  { name: "Edge 850", s: "Edge", cat: "edge", lvl: 3, para: "Ciclista Dedicado Avançado", dest: "2025. Tela 1000 nits + speaker + bike bell. Menor que o Edge 1050." },
  { name: "Edge 1040", s: "Edge", cat: "edge", lvl: 4, para: "Ciclista Avançado", dest: "Tela 3.5", mapas, Solar disponível. Bateria 35h GPS." },
  { name: "Edge 1050", s: "Edge", cat: "edge", lvl: 5, para: "Ciclista Elite", dest: "Tela 3.5" 1000 nits, Garmin Pay, bike bell, hazard alerts." },
  // GOLF
  { name: "Approach S44", s: "Approach", cat: "golf", lvl: 2, para: "Golfista", dest: "GPS de golfe, 42.000 campos. Entrada da linha Approach." },
  { name: "Approach S50", s: "Approach", cat: "golf", lvl: 3, para: "Golfista", dest: "Approach mais completo com AMOLED. Scorecard e estatísticas avançadas." },
  // MOTO
  { name: "Zumo XT2", s: "Zumo", cat: "moto", lvl: 3, para: "Motociclista", dest: "Navegador para moto com roteamento específico e integração capacete Bluetooth." },
  // ACESSÓRIOS
  { name: "Varia RTL515", s: "Varia", cat: "acess", lvl: 3, para: "Ciclista", dest: "Radar traseiro + luz. Detecta veículos a 140m e alerta no relógio." },
  { name: "Rally RK 200", s: "Rally", cat: "acess", lvl: 4, para: "Ciclista de Performance", dest: "Pedal medidor de potência SPD. Compatível com qualquer pedivela." },
  // GPS DE MÃO
  { name: "GPSMAP 65", s: "GPSMAP", cat: "gps", lvl: 3, para: "Trilheiro / Aventureiro", dest: "GPS portátil colorido multibanda. Botões físicos." },
  { name: "GPSMAP 65s", s: "GPSMAP", cat: "gps", lvl: 3, para: "Trilheiro / Aventureiro", dest: "GPSMAP 65 + barômetro + bússola 3 eixos." },
  { name: "GPSMAP 67", s: "GPSMAP", cat: "gps", lvl: 4, para: "Aventureiro / Expedição", dest: "Tela 3" TopoAtivos Brasil, altímetro, bússola, USB-C. O mais completo." },
  { name: "GPSMAP 79", s: "GPSMAP", cat: "gps", lvl: 3, para: "Pescador / Náutico", dest: "GPS portátil flutuante para uso náutico. Mapas BlueChart." },
  { name: "GPSMAP 86", s: "GPSMAP", cat: "gps", lvl: 3, para: "Náutico / Marinheiro", dest: "GPS náutico flutuante 3", bússola, barômetro. Para embarcações." },
  { name: "GPSMAP H1i", s: "GPSMAP", cat: "gps", lvl: 3, para: "Caçador Avançado", dest: "GPS portátil para caça. Rastreamento de animais + mapas de propriedade. Com inReach." },
  { name: "eTrex 22x", s: "eTrex", cat: "gps", lvl: 1, para: "Caminhante Iniciante", dest: "Entrada da linha eTrex. Robusto, simples, mapas TopoActive. Bateria AA." },
  { name: "eTrex 32x", s: "eTrex", cat: "gps", lvl: 2, para: "Trilheiro / Trekking", dest: "eTrex 22x + bússola 3 eixos + altímetro barométrico. Para quem precisa de bússola real." },
  { name: "eTrex Touch", s: "eTrex", cat: "gps", lvl: 2, para: "Usuário Casual", dest: "Único eTrex com touchscreen. Mais fácil de navegar nos menus." },
  { name: "eTrex Solar", s: "eTrex", cat: "gps", lvl: 3, para: "Expedição / Ultra", dest: "Carregamento solar + bateria de até 100h. Para quem fica dias sem carregar." },
  // NÁUTICO
  { name: "Striker 4", s: "Striker", cat: "marine", lvl: 1, para: "Pescador Iniciante", dest: "Sonar de pesca 3,5" com GPS básico. Porta de entrada." },
  { name: "Striker Vivid 5cv", s: "Striker", cat: "marine", lvl: 2, para: "Pescador Dedicado", dest: "Sonar 5" colorido + ClearVü + SideVü + GPS. Excelente custo-benefício." },
  { name: "ECHOMAP UHD2 52cv", s: "ECHOMAP", cat: "marine", lvl: 3, para: "Pescador/Navegador Sério", dest: "Chartplotter + sonar UHD2 5". Mapas náuticos BlueChart G3." },
  // INREACH
  { name: "inReach Mini 2", s: "inReach", cat: "gps", lvl: 2, para: "Aventureiro / Backup", dest: "SOS interativo + mensagens por satélite. Modelo anterior (tela mono)." },
  { name: "inReach Mini 3", s: "inReach", cat: "gps", lvl: 3, para: "Aventureiro / Expedição", dest: "Mini 3: tela colorida touch, sirene, GPS multibanda. Modelo atual." },
  { name: "inReach Mini 3 Plus", s: "inReach", cat: "gps", lvl: 4, para: "Guias / Expedições Longas", dest: "Mini 3 + voz 30s via satélite + fotos. Premium para profissionais." },
];

// ── FAQ ───────────────────────────────────────────────────────
const faqs = [
  {
    q: "Qual a diferença entre Forerunner 265 e 965?",
    a: "O 265 é mais compacto e focado em corrida. O 965 adiciona mapas coloridos e modo triathlon. Para maratonistas e triatletas, o 965 justifica o investimento. Para corredores de rua, o 265 atende muito bem.",
  },
  {
    q: "Preciso de GPS multibanda?",
    a: "Se o cliente corre em ambientes urbanos com prédios ou em florestas, o multibanda faz diferença real — precisão de 1–2m versus 5–10m de GPS simples. Para corrida em parques abertos, o GPS padrão já é excelente.",
  },
  {
    q: "Garmin ou Apple Watch?",
    a: "Para quem usa como ferramenta de treino, a diferença é enorme: bateria de dias (Apple dura horas com GPS ativo), GPS dedicado muito mais preciso e algoritmos para atletas desenvolvidos por 30+ anos.",
  },
  {
    q: "O Garmin funciona sem celular?",
    a: "Sim. O GPS, monitoramento de saúde e armazenamento de treinos funcionam 100% sem celular. O celular é usado apenas para sincronizar dados com o Garmin Connect.",
  },
  {
    q: "Qual relógio para presente?",
    a: "Lily 2 para presente feminino elegante. Forerunner 165 para quem pratica esporte. Vivoactive 6 para quem quer versatilidade. Pergunte sempre sobre o perfil de uso para acertar na indicação.",
  },
  {
    q: "O que é Training Readiness?",
    a: "É um score de 0–100 que indica se o atleta está pronto para treinar com intensidade. Combina sono, HRV, histórico de carga e stress. Disponível a partir do Forerunner 265.",
  },
  {
    q: "O que é Body Battery?",
    a: "Indicador de energia do corpo, de 0 a 100, baseado em HRV, sono e estresse. Ajuda o usuário a saber se está recuperado para treinar ou se deve descansar.",
  },
  {
    q: "Qual a garantia Garmin no Brasil?",
    a: "2 anos para dispositivos e 1 ano para acessórios, com suporte direto pela Proparts como importadora oficial. Atendimento presencial disponível.",
  },
  {
    q: "Garmin Connect é pago?",
    a: "O Garmin Connect básico é gratuito. O Garmin Connect+ (premium) oferece análises avançadas, planos de treino personalizados e funcionalidades extras por uma assinatura mensal.",
  },
  {
    q: "O que é o inReach?",
    a: "É um comunicador via satélite Iridium que permite enviar mensagens e acionar SOS de qualquer ponto do planeta, mesmo sem cobertura de celular. Existe standalone (Mini 3) ou integrado ao relógio (GPSMAP H1i, alguns Fenix).",
  },
];

// ── CONCORRENTES ─────────────────────────────────────────────
const comps = [
  {
    name: "Apple Watch",
    badge: "Maior Concorrente",
    bc: "orange",
    desc: "Produto de moda com função de saúde. Ecossistema Apple forte, mas bateria de 1 dia com GPS e algoritmos genéricos.",
    rows: [
      { a: "Bateria com GPS", g: "10–26 dias (Instinct)", t: "4–6 horas" },
      { a: "GPS", g: "Multibanda dedicado", t: "Padrão / dependente do iPhone" },
      { a: "Algoritmos de atleta", g: "FirstBeat 30+ anos", t: "Genérico saúde/fitness" },
      { a: "Distribuição BR", g: "Rede Proparts ampla", t: "Apple Stores" },
    ],
  },
  {
    name: "Samsung Galaxy Watch",
    badge: "Concorrente Lifestyle",
    bc: "blue",
    desc: "Design bonito e integração Android. Mas GPS básico, bateria fraca e sem algoritmos de atleta.",
    rows: [
      { a: "Bateria com GPS", g: "10–26 dias", t: "1–2 dias" },
      { a: "Ecossistema de treino", g: "Garmin Connect + 50+ integrações", t: "Samsung Health limitado" },
      { a: "Para atletas", g: "Sim — ferramenta de treino", t: "Foco lifestyle" },
    ],
  },
  {
    name: "Polar",
    badge: "Concorrente Corrida",
    bc: "blue",
    desc: "Forte em monitoramento cardíaco e análise de treino. Menos recursos de navegação, ecossistema menor.",
    rows: [
      { a: "Frequência Cardíaca", g: "Elevate 5ª geração", t: "Boa qualidade" },
      { a: "Mapas", g: "Sim (Fenix/Forerunner 965)", t: "Básico ou ausente" },
      { a: "Ecossistema", g: "Connect IQ + 50 apps", t: "Polar Flow" },
      { a: "Bateria GPS", g: "Muito superior", t: "Similar mid-range" },
    ],
  },
  {
    name: "Suunto",
    badge: "Nicho Outdoor",
    bc: "blue",
    desc: "Herança em outdoor e mergulho. Qualidade, mas ecossistema menor.",
    rows: [
      { a: "Outdoor / Trilha", g: "Fenix 8, Instinct 3 — referência", t: "Suunto 9 — boa proposta" },
      { a: "Mergulho", g: "Série Descent — mais completa", t: "Tradição em dive computers" },
      { a: "Integrações", g: "Connect IQ dezenas", t: "Ecossistema mais limitado" },
      { a: "Distribuição BR", g: "Rede Proparts ampla", t: "Distribuição mais restrita" },
    ],
  },
];

// ── ESPORTES ─────────────────────────────────────────────────
const sports = [
  { emoji: "🏃", name: "Corrida", metrics: ["Distância", "Ritmo min/km", "Cadência passos/min", "Tempo de contato com solo", "FC", "Extensão da passada", "Oscilação vertical", "PacePRO", "Potência de corrida", "Elevação", "VO2 Max estimado", "Training Effect"] },
  { emoji: "🚴", name: "Ciclismo", metrics: ["Distância", "Velocidade atual/média/máx", "Cadência RPM", "Elevação acumulada", "Potência com pedal Rally", "FTP estimado", "FC", "Training Load"] },
  { emoji: "🏊", name: "Natação", metrics: ["Distância", "Ritmo min/100m", "Frequência de braçadas", "Tipo de braçada (crawl, costas, peito, borboleta)", "SWOLF (eficiência)", "Tempo de descanso entre séries"] },
  { emoji: "🏋️", name: "Academia / Força", metrics: ["Séries e repetições (detecção automática)", "Calorias ativas", "Mapa muscular", "FC", "Tempo de descanso"] },
  { emoji: "🌲", name: "Trilha / Trekking", metrics: ["Distância", "Subida total acumulada", "Velocidade média", "FC", "Elevação atual", "Mapa topográfico (modelos compatíveis)", "Wikiloc / Komoot integrado"] },
  { emoji: "🏄", name: "Surf", metrics: ["Número de ondas", "Velocidade máxima", "Distância em ondas", "Tempo de sessão", "FC"] },
  { emoji: "🪁", name: "Kitesurf", metrics: ["Distância total", "FC", "Velocidade máxima", "Altura de saltos em tempo real (app Woo)", "Dados de sessão via Hoolan"] },
  { emoji: "⛳", name: "Golfe", metrics: ["Scorecard digital", "Distância até frente/meio/fundo do green", "Detecção automática de tacadas", "Handicap", "Par do buraco"] },
  { emoji: "🤿", name: "Mergulho (Descent)", metrics: ["Profundidade atual e máxima", "Tempo de fundo", "NDL (limite sem descompressão)", "Temperatura da água", "Algoritmo Bühlmann", "Modo Nitrox", "Autonomia de gás (X30)", "Modo apneia"] },
  { emoji: "🏍️", name: "Moto (Zumo XT2)", metrics: ["Roteamento específico para moto", "Evita estradas proibidas", "Integração capacete Bluetooth", "Rastreamento de rota"] },
];

// ── RANKING ───────────────────────────────────────────────────
const rankingData = [
  { pos: 1, nome: "Beatriz Ferreira",  nivel: "Explorador ⭐",    pts: 0, medal: "🥇" },
  { pos: 2, nome: "Daniel Lucena",    nivel: "Explorador ⭐",    pts: 0, medal: "🥈" },
  { pos: 3, nome: "Joyce Souza",      nivel: "Explorador ⭐",    pts: 0, medal: "🥉" },
  { pos: 4, nome: "Renato Dias",      nivel: "Explorador ⭐",    pts: 0, medal: "4" },
  { pos: 5, nome: "Mayara Araújo",    nivel: "Explorador ⭐",    pts: 0, medal: "5" },
  { pos: 6, nome: "Ailma Ferraz",     nivel: "Explorador ⭐",    pts: 0, medal: "6" },
  { pos: 7, nome: "Dayane",           nivel: "Explorador ⭐",    pts: 0, medal: "7" },
  { pos: 8, nome: "Ribs",             nivel: "Explorador ⭐",    pts: 0, medal: "8" },
  { pos: 9, nome: "Gustavo Morais",   nivel: "Explorador ⭐",    pts: 0, medal: "9" },
];

// ── CERTIFICAÇÕES ─────────────────────────────────────────────
const certs = [
  {
    emoji: "🌟",
    level: "Nível 1",
    name: "Universo Garmin",
    color: "var(--g)",
    unlocked: true,
    obj: "Entender a história, DNA e posicionamento da Garmin. Vender com confiança e autoridade.",
    skills: ["Contar a história da Garmin de forma envolvente", "Explicar o diferencial FirstBeat e os sensores", "Posicionar Garmin vs concorrentes com argumentos sólidos"],
    mods: [
      { n: 1, t: "História e DNA", c: "Fundação em 1989, foco em GPS desde o início, 35+ anos de expertise." },
      { n: 2, t: "Tecnologia FirstBeat", c: "Algoritmos de atleta: HRV, Training Readiness, Body Battery e mais." },
      { n: 3, t: "Ecossistema Garmin", c: "Garmin Connect, Connect IQ, 50+ integrações. Lock-in positivo." },
    ],
  },
  {
    emoji: "🏃",
    level: "Nível 2",
    name: "Corrida e Performance",
    color: "var(--acc)",
    unlocked: false,
    obj: "Dominar a linha Forerunner e vender para corredores de todos os níveis.",
    skills: ["Identificar o perfil corredor", "Comparar Forerunner 165/265/965", "Usar argumentos de PacePRO e Training Readiness"],
    mods: [
      { n: 1, t: "Linha Forerunner", c: "Da entrada ao topo: 165, 265, 965. Quando indicar cada um." },
      { n: 2, t: "Métricas de corrida", c: "VO2 Max, cadência, potência, contato com solo. O que significa cada um." },
    ],
  },
  {
    emoji: "🌲",
    level: "Nível 3",
    name: "Outdoor e Aventura",
    color: "#2e7d32",
    unlocked: false,
    obj: "Vender Fenix, Instinct, GPS de mão e inReach com autoridade.",
    skills: ["Diferenciar Fenix vs Instinct", "Vender GPS de mão para trilheiros e pescadores", "Apresentar inReach com o script de satélite"],
    mods: [
      { n: 1, t: "Fenix e Instinct", c: "Robustez MIL-STD-810, bateria de semanas, GPS multibanda." },
      { n: 2, t: "GPS Portáteis", c: "GPSMAP e eTrex: quando recomendar cada linha." },
      { n: 3, t: "inReach", c: "Comunicação via satélite Iridium. Script e planos." },
    ],
  },
  {
    emoji: "🏆",
    level: "Nível 4 — Triatleta",
    name: "Elite",
    color: "var(--gold)",
    unlocked: false,
    obj: "Consultor completo: domina todas as linhas e perfis de clientes.",
    skills: ["Vender qualquer produto Garmin para qualquer perfil", "Conduzir o atendimento do início ao fechamento", "Responder objeções com confiança"],
    mods: [
      { n: 1, t: "Mergulho e Descent", c: "Linha Descent, algoritmos de mergulho, público técnico." },
      { n: 2, t: "Náutico", c: "Striker e ECHOMAP: sonar, chartplotter e pesca." },
      { n: 3, t: "Ciclismo e Edge", c: "Edge 540 a 1050, pedais Rally, integração Zwift/Strava." },
    ],
  },
];

// ── QUIZ ─────────────────────────────────────────────────────
const quizQuestions = [
  {
    q: "Há quantos anos a Garmin atua com GPS?",
    opts: ["15 anos", "25 anos", "35+ anos", "45 anos"],
    correct: 2,
    feedback: "A Garmin foi fundada em 1989 e tem mais de 35 anos de expertise em GPS e navegação.",
  },
  {
    q: "O que é o Body Battery?",
    opts: [
      "Nível de bateria do relógio",
      "Score de energia do corpo baseado em HRV, sono e estresse",
      "Sensor de frequência cardíaca",
      "Plano de assinatura premium",
    ],
    correct: 1,
    feedback: "Body Battery é um indicador de 0–100 que mostra o nível de energia do corpo, combinando HRV, qualidade do sono e estresse.",
  },
  {
    q: "Qual o principal argumento do Garmin vs Apple Watch para um corredor?",
    opts: [
      "Garmin tem mais aplicativos",
      "Garmin é mais barato",
      "Garmin tem bateria de dias e GPS dedicado com algoritmos de atleta",
      "Garmin tem design mais bonito",
    ],
    correct: 2,
    feedback: "A bateria de dias (vs horas com GPS) e os algoritmos FirstBeat para atletas são os diferenciais decisivos.",
  },
  {
    q: "Para um cliente que pergunta sobre trilhas longas sem sinal de celular, qual produto é o mais indicado como argumento de segurança?",
    opts: ["Fenix 8", "inReach Mini 3", "GPSMAP 67", "Forerunner 965"],
    correct: 1,
    feedback: "O inReach Mini 3 é o único que permite comunicação e SOS via satélite Iridium, de qualquer ponto do planeta.",
  },
  {
    q: "O que é o GPS multibanda?",
    opts: [
      "GPS que funciona em múltiplos países",
      "GPS que usa múltiplas constelações de satélite simultaneamente para maior precisão",
      "GPS com múltiplas frequências de rádio",
      "GPS com suporte a múltiplos apps",
    ],
    correct: 1,
    feedback: "GPS multibanda usa múltiplas constelações (GPS, GLONASS, Galileo, etc.) ao mesmo tempo, resultando em precisão de 1–2m.",
  },
  {
    q: "Qual relógio Garmin é focado em mergulho técnico com trimix?",
    opts: ["Fenix 8 Pro", "Descent G2", "Descent X30", "Instinct 3 Solar"],
    correct: 2,
    feedback: "O Descent X30 é o topo da linha com suporte a trimix, autonomia de gás e modo técnico avançado.",
  },
  {
    q: "Um cliente diz 'Vou pensar e volto depois.' Qual a melhor resposta?",
    opts: [
      "Ok, até logo!",
      "Não tem outro igual aqui.",
      "Claro! Posso deixar meu contato? Qualquer dúvida, me chama no WhatsApp.",
      "Esse modelo pode acabar hoje.",
    ],
    correct: 2,
    feedback: "Respeite a decisão, mas garanta que o contato fique — isso mantém a relação e abre espaço para o fechamento depois.",
  },
  {
    q: "Qual o plano inReach mais vendido em 2025?",
    opts: ["Enabled (US$7,99/mês)", "Essential (US$14,99/mês)", "Standard (US$34,99/mês)", "Expedition (US$64,99/mês)"],
    correct: 1,
    feedback: "O Essential com US$14,99/mês é o mais vendido: inclui 50 mensagens, SOS e rastreamento — ideal para trilheiros de fim de semana.",
  },
  {
    q: "Qual a certificação de resistência presente em relógios Garmin outdoor como o Instinct?",
    opts: ["ISO 9001", "MIL-STD-810", "IP68", "CE Mark"],
    correct: 1,
    feedback: "MIL-STD-810 é o padrão militar norte-americano de resistência a impactos, temperaturas extremas e umidade.",
  },
  {
    q: "O Garmin Connect+ (premium) é:",
    opts: [
      "Obrigatório para usar o relógio",
      "Gratuito para todos os usuários",
      "Opcional — versão básica é gratuita, premium oferece análises avançadas por assinatura",
      "Disponível apenas para Fenix",
    ],
    correct: 2,
    feedback: "O Garmin Connect básico é gratuito e funcional. O Connect+ adiciona insights avançados, planos personalizados e funcionalidades extras.",
  },
];

// ════════════════════════════════════════════════════════════
// RENDERIZAÇÃO
// ════════════════════════════════════════════════════════════

// ── Ranking ──────────────────────────────────────────────────
function renderRanking() {
  document.getElementById("rankMini").innerHTML = rankingData.slice(0, 3).map((r) => `
    <div class="rank-mini-row">
      <div class="rank-medal">${r.medal}</div>
      <div class="rank-name-text">${r.nome}</div>
      <div class="rank-level-badge">${r.nivel}</div>
      <div class="rank-pts-mini">${r.pts}</div>
    </div>`).join("");

  document.getElementById("rankingList").innerHTML = rankingData.map((r) => `
    <div class="rank-row">
      <div class="rank-pos-num ${r.pos <= 3 ? "g" + r.pos : ""}">${r.pos <= 3 ? r.medal : r.pos}</div>
      <div class="rank-info">
        <div class="rank-pname">${r.nome}</div>
        <div class="rank-plevel">${r.nivel}</div>
      </div>
      <div class="rank-ppts">${r.pts} pts</div>
    </div>`).join("");
}

// ── Perfis ────────────────────────────────────────────────────
function renderProfiles(arr) {
  document.getElementById("profilesGrid").innerHTML = arr.map((p) => `
    <div class="profile-card" onclick="openProfileModal(${profiles.indexOf(p)})">
      <div class="profile-card-top">
        <div class="p-emoji">${p.emoji}</div>
        <div class="p-name">${p.name}</div>
        <div class="p-tag">${p.tag}</div>
      </div>
      <div class="profile-card-body">
        <div class="p-sinais-label">Sinais de identificação</div>
        <ul class="p-sinais">${p.sinais.slice(0, 3).map((s) => `<li>${s}</li>`).join("")}</ul>
      </div>
      <div class="profile-card-footer">
        <div class="p-prods-label">Produtos indicados</div>
        ${p.produtos.map((pr) => `<span class="prod-pill ${pr === p.primario ? "main" : ""}">${pr}</span>`).join("")}
      </div>
    </div>`).join("");
}

function filterProfiles() {
  const q = document.getElementById("profileSearch").value.toLowerCase();
  renderProfiles(q
    ? profiles.filter((p) =>
        p.name.toLowerCase().includes(q) ||
        p.tag.toLowerCase().includes(q) ||
        p.tags.some((t) => t.toLowerCase().includes(q)) ||
        p.produtos.some((pr) => pr.toLowerCase().includes(q)))
    : profiles);
}

function openProfileModal(i) {
  const p = profiles[i];
  document.getElementById("profileModalContent").innerHTML = `
    <div class="modal-emoji">${p.emoji}</div>
    <div class="modal-title">${p.name}</div>
    <div class="modal-sub">${p.tag}</div>
    <div style="margin-bottom:14px">${p.tags.map((t) => `<span class="tag blue">${t}</span>`).join("")}</div>
    <div class="modal-section">
      <h4>Como identificar</h4>
      <ul>${p.sinais.map((s) => `<li>${s}</li>`).join("")}</ul>
    </div>
    <div class="modal-section">
      <h4>Como se comunicar</h4>
      <ul>${p.comunicacao.map((c) => `<li>${c}</li>`).join("")}</ul>
    </div>
    <div class="modal-section">
      <h4>Objeções comuns</h4>
      ${p.objections.map((o) => `
        <div class="obj-block">
          <div class="obj-q">${o.q}</div>
          <div class="obj-a">${o.a}</div>
        </div>`).join("")}
    </div>
    <div class="modal-section">
      <h4>Produtos indicados</h4>
      <div>${p.produtos.map((pr) => `<span class="prod-pill ${pr === p.primario ? "main" : ""}">${pr}</span>`).join("")}</div>
      <p style="font-size:11px;color:var(--text3);margin-top:8px">Azul = recomendação principal</p>
    </div>`;
  document.getElementById("profileModal").classList.add("open");
}

// ── Produtos ──────────────────────────────────────────────────
function renderProds(filter) {
  const f = filter === "todos" ? prods : prods.filter((p) => p.cat === filter);
  document.getElementById("prodsBody").innerHTML = f.map((p) => {
    const dots = Array.from({ length: 5 }, (_, i) => `<div class="ld ${i < p.lvl ? "on" : ""}"></div>`).join("");
    return `<tr>
      <td><div class="prod-name">${p.name}</div><span class="prod-series">${p.s}</span></td>
      <td><div class="level-dots">${dots}</div></td>
      <td style="font-size:12px;color:var(--text3)">${p.para}</td>
      <td style="font-size:12.5px;color:var(--text);max-width:220px">${p.dest}</td>
    </tr>`;
  }).join("");
}

function filterProds(cat, btn) {
  document.querySelectorAll(".fbtn").forEach((b) => b.classList.remove("active"));
  btn.classList.add("active");
  renderProds(cat);
}

// ── FAQ ───────────────────────────────────────────────────────
function renderFaq(arr) {
  document.getElementById("faqList").innerHTML = arr.map((f) => `
    <div class="acc-item">
      <button class="acc-btn" onclick="toggleAcc(this)">
        <span class="acc-icon">❓</span>
        <span style="flex:1">${f.q}</span>
        <span class="acc-chevron">▼</span>
      </button>
      <div class="acc-body">${f.a}</div>
    </div>`).join("");
}

function filterFaq() {
  const q = document.getElementById("faqSearch").value.toLowerCase();
  renderFaq(q ? faqs.filter((f) => f.q.toLowerCase().includes(q) || f.a.toLowerCase().includes(q)) : faqs);
}

// ── Concorrentes ──────────────────────────────────────────────
function renderComps() {
  document.getElementById("compList").innerHTML = comps.map((c) => `
    <div class="comp-card">
      <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:6px">
        <div class="comp-brand">${c.name}</div>
        <span class="tag ${c.bc}">${c.badge}</span>
      </div>
      <p style="font-size:13px;color:var(--text2);margin-bottom:12px;line-height:1.6">${c.desc}</p>
      <table class="vs-table">
        <tr><th>Aspecto</th><th class="ours">Garmin · Proparts</th><th class="theirs">${c.name}</th></tr>
        ${c.rows.map((r) => `<tr><td style="color:var(--text3)">${r.a}</td><td class="ours">${r.g}</td><td class="theirs">${r.t}</td></tr>`).join("")}
      </table>
    </div>`).join("");
}

// ── Esportes ─────────────────────────────────────────────────
function renderSports() {
  document.getElementById("sportsList").innerHTML = sports.map((s) => `
    <div class="sport-card">
      <div class="sport-header">
        <div class="sport-emoji">${s.emoji}</div>
        <div class="sport-name">${s.name}</div>
      </div>
      <div class="metrics-wrap">${s.metrics.map((m) => `<span class="tag">${m}</span>`).join("")}</div>
    </div>`).join("");
}

// ── Certificações ─────────────────────────────────────────────
function renderCerts() {
  document.getElementById("certList").innerHTML = certs.map((c, i) => `
    <div class="cert-card ${c.unlocked ? "unlocked" : "locked"}" ${c.unlocked ? `onclick="openCertModal(${i})"` : ""}>
      <div class="cert-header">
        <div class="cert-emoji">${c.emoji}</div>
        <div>
          <div class="cert-level-text">${c.level}</div>
          <div class="cert-name-text">${c.name}</div>
        </div>
        ${c.unlocked ? `<div style="margin-left:auto;font-size:12px;font-weight:600;color:var(--g)">Disponível ✓</div>` : `<div style="margin-left:auto;font-size:20px">🔒</div>`}
      </div>
      <div class="cert-stripe" style="background:linear-gradient(90deg,${c.color},transparent)"></div>
      <div class="cert-body">
        <div class="cert-obj">${c.obj}</div>
        <div class="cert-modules">${c.mods.map((m) => `<span class="cert-mod-pill">Módulo ${m.n} — ${m.t}</span>`).join("")}</div>
        ${c.unlocked ? `<div style="font-size:12px;font-weight:600;color:var(--g);margin-top:12px">Toque para ver os módulos →</div>` : ""}
      </div>
    </div>`).join("");
}

function openCertModal(i) {
  const c = certs[i];
  document.getElementById("certModalContent").innerHTML = `
    <div style="font-size:40px;margin-bottom:8px">${c.emoji}</div>
    <div style="font-size:10px;letter-spacing:2px;text-transform:uppercase;color:var(--text3);margin-bottom:2px">${c.level}</div>
    <div style="font-family:Rajdhani,sans-serif;font-weight:700;font-size:24px;text-transform:uppercase;color:var(--text);margin-bottom:6px">${c.name}</div>
    <div style="height:3px;background:linear-gradient(90deg,${c.color},transparent);border-radius:2px;margin-bottom:16px"></div>
    <div class="modal-section">
      <h4>Objetivo</h4>
      <p style="font-size:13px;color:var(--text);line-height:1.6">${c.obj}</p>
    </div>
    <div class="modal-section">
      <h4>Habilidades desenvolvidas</h4>
      <ul>${c.skills.map((s) => `<li>${s}</li>`).join("")}</ul>
    </div>
    <div class="modal-section">
      <h4>Módulos</h4>
      ${c.mods.map((m) => `
        <div style="background:var(--off);border-radius:8px;padding:12px;margin-bottom:8px">
          <div style="font-family:Rajdhani,sans-serif;font-weight:700;color:var(--g);font-size:14px;margin-bottom:3px">Módulo ${m.n} — ${m.t}</div>
          <div style="font-size:12px;color:var(--text2);line-height:1.6">${m.c}</div>
        </div>`).join("")}
    </div>`;
  document.getElementById("certModal").classList.add("open");
}

// ════════════════════════════════════════════════════════════
// QUIZ
// ════════════════════════════════════════════════════════════
let quizState = { current: 0, score: 0, answered: false };

function renderQuiz() {
  const { current } = quizState;
  if (current >= quizQuestions.length) {
    showQuizResult();
    return;
  }
  const q = quizQuestions[current];
  const pct = (current / quizQuestions.length) * 100;
  document.getElementById("quizBar").style.width = pct + "%";
  document.getElementById("quizContent").innerHTML = `
    <div class="quiz-q-num">Pergunta ${current + 1} de ${quizQuestions.length}</div>
    <div class="quiz-q">${q.q}</div>
    <div class="quiz-options">
      ${q.opts.map((opt, i) => `
        <button class="quiz-opt" onclick="answerQuiz(${i})">${opt}</button>`).join("")}
    </div>
    <div class="quiz-feedback" id="quizFeedback"></div>
    <div class="quiz-nav">
      <button class="quiz-btn" id="quizNextBtn" style="display:none" onclick="nextQuizQuestion()">
        ${current + 1 < quizQuestions.length ? "Próxima →" : "Ver Resultado"}
      </button>
    </div>`;
  quizState.answered = false;
}

function answerQuiz(idx) {
  if (quizState.answered) return;
  quizState.answered = true;
  const q = quizQuestions[quizState.current];
  const opts = document.querySelectorAll(".quiz-opt");
  const feedback = document.getElementById("quizFeedback");
  const isCorrect = idx === q.correct;
  if (isCorrect) quizState.score++;
  opts.forEach((btn, i) => {
    btn.classList.add("disabled");
    if (i === q.correct) btn.classList.add("correct");
    else if (i === idx && !isCorrect) btn.classList.add("wrong");
  });
  feedback.textContent = (isCorrect ? "✅ Correto! " : "❌ Quase! ") + q.feedback;
  feedback.className = "quiz-feedback show " + (isCorrect ? "ok" : "fail");
  document.getElementById("quizNextBtn").style.display = "inline-flex";
}

function nextQuizQuestion() {
  quizState.current++;
  renderQuiz();
}

function showQuizResult() {
  const { score } = quizState;
  const total = quizQuestions.length;
  const pct = Math.round((score / total) * 100);
  const passed = pct >= 70;
  document.getElementById("quizBar").style.width = "100%";
  document.getElementById("quizContent").innerHTML = `
    <div class="quiz-result">
      <div class="quiz-result-emoji">${passed ? "🏆" : "📚"}</div>
      <div class="quiz-result-title" style="color:${passed ? "var(--acc)" : "var(--warn)"}">${passed ? "Aprovado!" : "Continue Estudando!"}</div>
      <div class="quiz-result-score">Você acertou <strong>${score}</strong> de ${total} — <strong>${pct}%</strong></div>
      ${passed ? `<div class="tip">Parabéns! Você completou o Módulo 1 — Universo Garmin. Registre seu resultado abaixo para pontuar no ranking.</div>` : `<div class="warn-tip">Você precisa de 70% para ser aprovado. Revise os conteúdos e tente novamente.</div>`}
      ${passed ? renderRegisterForm(score, total, pct) : ""}
      <button class="quiz-btn" style="margin-top:16px" onclick="restartQuiz()">Tentar Novamente</button>
    </div>`;
}

function renderRegisterForm(score, total, pct) {
  return `
    <div class="register-form">
      <label class="register-label">Seu nome para o ranking</label>
      <input class="register-input" id="regName" type="text" placeholder="Digite seu nome completo...">
      <button class="register-btn" onclick="submitResult(${score},${total},${pct})">Registrar Resultado 🏅</button>
      <div class="register-success" id="regSuccess">✅ Resultado registrado! Você ganhou ${pct >= 100 ? 50 : 25} pts no ranking.</div>
    </div>`;
}

function submitResult(score, total, pct) {
  const name = document.getElementById("regName").value.trim();
  if (!name) { alert("Por favor, insira seu nome."); return; }
  const pts = pct === 100 ? 50 : 25;
  const payload = { name, score, total, pct, pts, ts: new Date().toISOString() };
  fetch(SHEETS_URL, { method: "POST", body: JSON.stringify(payload) })
    .then(() => {
      document.getElementById("regSuccess").style.display = "block";
      document.querySelector(".register-btn").disabled = true;
    })
    .catch(() => {
      document.getElementById("regSuccess").style.display = "block";
    });
}

function restartQuiz() {
  quizState = { current: 0, score: 0, answered: false };
  renderQuiz();
}

// ════════════════════════════════════════════════════════════
// INIT
// ════════════════════════════════════════════════════════════
document.addEventListener("DOMContentLoaded", () => {
  renderProfiles(profiles);
  renderProds("todos");
  renderFaq(faqs);
  renderComps();
  renderSports();
  renderRanking();
  renderCerts();
  renderQuiz();

  // Expõe funções globais usadas no HTML (onclick="...")
  Object.assign(window, {
    openPanel, goHome, showItab, switchIRTab, showMatTab,
    toggleAcc, closeModal, filterProfiles, openProfileModal,
    filterProds, filterFaq, answerQuiz, nextQuizQuestion,
    restartQuiz, openCertModal,
  });
});
