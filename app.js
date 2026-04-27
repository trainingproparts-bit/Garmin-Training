const SHEETS_URL = 'https://script.google.com/macros/s/AKfycbyv0UhVSiM52K-g8A31Myih_UMMGKhZIwRAAMcMW_3WwYofjgtNCV-6J7p6iv0ODSsU/exec';

// NAV
function openPanel(id){document.getElementById('home').style.display='none';document.querySelectorAll('.panel').forEach(p=>p.classList.remove('active'));document.getElementById('panel-'+id).classList.add('active');window.scrollTo(0,0);}
function goHome(){document.querySelectorAll('.panel').forEach(p=>p.classList.remove('active'));document.getElementById('home').style.display='block';window.scrollTo(0,0);}
function showItab(showId,hideId,tabEl){const s=document.getElementById(showId),h=document.getElementById(hideId);if(s)s.style.display='block';if(h)h.style.display='none';if(tabEl){tabEl.closest('.itabs').querySelectorAll('.itab').forEach(t=>t.classList.remove('active'));tabEl.classList.add('active');}}
function switchIRTab(tabId,tabEl){['ir-compare','ir-planos','ir-venda'].forEach(id=>{const el=document.getElementById(id);if(el)el.style.display=id===tabId?'block':'none';});document.querySelector('#panel-inreach .itabs').querySelectorAll('.itab').forEach(t=>t.classList.remove('active'));if(tabEl)tabEl.classList.add('active');}
function showMatTab(id){['m-apps','m-int','m-tech'].forEach(i=>{const el=document.getElementById(i);if(el)el.style.display=i===id?'block':'none';});document.getElementById('matTabs').querySelectorAll('.itab').forEach((t,i)=>{t.classList.toggle('active',['m-apps','m-int','m-tech'][i]===id);});}
function toggleAcc(el){el.closest('.acc-item').classList.toggle('open');}
function closeModal(id,e){if(e.target===document.getElementById(id))document.getElementById(id).classList.remove('open');}

// RANKING
const rankingData=[
  {pos:1,nome:'Beatriz Ferreira',nivel:'Explorador 🧭',pts:0,medal:'🥇'},
  {pos:2,nome:'Daniel Lucena',nivel:'Explorador 🧭',pts:0,medal:'🥈'},
  {pos:3,nome:'Joyce Souza',nivel:'Explorador 🧭',pts:0,medal:'🥉'},
  {pos:4,nome:'Renato Dias',nivel:'Explorador 🧭',pts:0,medal:'4'},
  {pos:5,nome:'Mayara Araújo',nivel:'Explorador 🧭',pts:0,medal:'5'},
  {pos:6,nome:'Ailma Ferraz',nivel:'Explorador 🧭',pts:0,medal:'6'},
  {pos:7,nome:'Dayane',nivel:'Explorador 🧭',pts:0,medal:'7'},
  {pos:8,nome:'Ribs',nivel:'Explorador 🧭',pts:0,medal:'8'},
  {pos:9,nome:'Gustavo Morais',nivel:'Explorador 🧭',pts:0,medal:'9'},
];
document.getElementById('rankMini').innerHTML=rankingData.slice(0,3).map(r=>`<div class="rank-mini-row"><div class="rank-medal">${r.medal}</div><div class="rank-name-text">${r.nome}</div><div class="rank-level-badge">${r.nivel}</div><div class="rank-pts-mini">${r.pts}</div></div>`).join('');
document.getElementById('rankingList').innerHTML=rankingData.map(r=>`<div class="rank-row"><div class="rank-pos-num ${r.pos<=3?'g'+r.pos:''}">${r.pos<=3?r.medal:r.pos}</div><div class="rank-info"><div class="rank-pname">${r.nome}</div><div class="rank-plevel">${r.nivel}</div></div><div class="rank-ppts">${r.pts} pts</div></div>`).join('');

// PROFILES
const profiles=[
  {emoji:'🏃',name:'Corredor Iniciante',tag:'Está começando a correr, quer monitorar progresso',tags:['Corrida','Iniciante','GPS'],sinais:['Menciona que começou a correr recentemente','Usa tênis de corrida mas não tem relógio esportivo','Fala em 5km, 10km, primeira corrida de rua','Nunca usou GPS ou frequencímetro'],comunicacao:['Foque em GPS + frequência cardíaca — os dois mais úteis para começar','Mostre o Garmin Connect e como registra a evolução','Evite features avançadas — vai confundir','Forerunner 165 é a porta de entrada ideal'],produtos:['Forerunner 55','Forerunner 165'],primario:'Forerunner 55',objections:[{q:'Preciso mesmo de GPS se o celular já tem?',a:'O GPS do celular no bolso perde precisão. No relógio fica no pulso e mostra o ritmo em tempo real sem tirar o celular do bolso.'},{q:'O FR165 vale a diferença de preço?',a:'Sim, se sabe que vai continuar correndo. O 165 tem tela AMOLED muito mais vívida e planos de treino integrados.'}]},
  {emoji:'⚡',name:'Corredor Dedicado',tag:'Corre 3–5x por semana, quer dados para evoluir',tags:['Corrida','Performance','Intermediário'],sinais:['Menciona pace, intervalado, corrida de rua','Já usou Garmin ou Polar antes','Pergunta sobre zona de FC ou VO2 max','Fala em meia maratona, maratona'],comunicacao:['Use termos técnicos — ele sabe o que é','Compare com o modelo que ele já tem','Destaque GPS multibanda e Elevate Gen 5','Fale do Connect e análise de treino'],produtos:['Forerunner 265','Forerunner 570','Forerunner 955'],primario:'Forerunner 265',objections:[{q:'O Polar tem os mesmos dados.',a:'O Polar é bom para análise, mas o ecossistema Garmin é muito maior: Connect IQ, Wikiloc, Zwift, TrainingPeaks nativos. E a bateria dura muito mais.'},{q:'Meu Garmin ainda funciona, por que trocar?',a:'O 265/570 tem AMOLED mais legível no sol, GPS multibanda mais preciso e sensor novo. Você sente a diferença no primeiro treino.'}]},
  {emoji:'🏆',name:'Atleta de Elite',tag:'Triatleta, ultramaratonista ou ciclista competitivo',tags:['Triathlon','Elite','Performance'],sinais:['Fala em Ironman, ultratrail, gran fondo','Menciona potenciômetro, Zwift, TrainingPeaks','Compara Garmin com Suunto, Polar ou Coros','Pergunta sobre mapas ou navegação off-line'],comunicacao:['Não simplifique — ele sabe mais do que parece','Foque em GPS multibanda, mapas, bateria','Fale sobre integração com Zwift e TrainingPeaks','O preço alto é justificado pela vida útil e precisão'],produtos:['Forerunner 955','Forerunner 965','Forerunner 970','Fenix 8','Enduro 3'],primario:'Forerunner 965',objections:[{q:'"O Coros Vale Apex 2 Pro é mais barato e tem as mesmas funções"',a:'O Coros é bom, mas o ecossistema Garmin (Connect, IQ, 100+ integrações) e o suporte no Brasil são incomparáveis. Para treino sério, a diferença de dados é real.'},{q:'"Para que pagar mais no 970 se o 965 tem quase tudo?"',a:'O 970 traz cristal de safira, lanterna LED e 32GB. Para provas noturnas ou leitura cardíaca ainda mais precisa, faz sentido.'}]},
  {emoji:'🌿',name:'Mulher Lifestyle',tag:'Busca saúde, bem-estar e design elegante no dia a dia',tags:['Lifestyle','Saúde','Feminino'],sinais:['Prioriza estética e design do relógio','Menciona pilates, yoga, caminhada, academia','Pergunta sobre sono, ciclo menstrual, estresse','Compara com Apple Watch ou Galaxy Watch'],comunicacao:['Lily 2 para quem quer design joia no pulso','Venu 4 para AMOLED premium + saúde feminina completa','Destaque monitoramento de ciclo menstrual e Body Battery','Mostre o app — é intuitivo e visual'],produtos:['Lily 2','Lily 2 Active','Venu 4','Vivoactive 6'],primario:'Venu 4',objections:[{q:'O Apple Watch tem design mais bonito.',a:'O Apple tem ótimo design, mas a bateria dura 1-2 dias. Para monitorar sono, ciclo e estresse de verdade, você precisa de um relógio que não descarrega toda noite.'},{q:'É caro.',a:'O Lily 2 começa abaixo do Apple Watch SE. E o Garmin dura muito mais — sem precisar trocar de modelo todo ano.'}]},
  {emoji:'🏔️',name:'Aventureiro Outdoor',tag:'Trilhas, camping, escalada, natureza',tags:['Outdoor','Trilha','Aventura'],sinais:['Menciona trilhas, camping, montanhismo','Pergunta sobre durabilidade, bateria','Fala de bússola, altímetro, barômetro','Interessa em mapas topográficos'],comunicacao:['Instinct 3 para custo-benefício outdoor robusto','Fenix 8 para quem quer tudo no pulso','GPSMAP 67 para quem prefere GPS de mão com topo','Destaque MIL-STD-810 e bateria de dias'],produtos:['Instinct 3','Fenix 8','GPSMAP 65','GPSMAP 67','inReach Mini 3'],primario:'Instinct 3',objections:[{q:'Uso o celular para GPS em trilha.',a:'Bateria de celular acaba rápido com GPS ativo. O Instinct 3 dura até 26 dias. Em trilha longa, o relógio é o plano principal — não o backup.'},{q:'Para que o inReach se tenho rádio?',a:'Rádio funciona em linha de visão. O inReach usa satélite — você manda mensagem de dentro de um cânion ou da Amazônia. Se precisar de resgate, a central Garmin Response aciona em qualquer lugar do mundo.'}]},
  {emoji:'🧘',name:'Foco em Saúde',tag:'Quer melhorar saúde geral, acompanhar atividade',tags:['Saúde','Fitness','Bem-estar'],sinais:['Menciona academia, caminhada como atividades','Pergunta sobre calorias, passos, sono','Fala de médico que recomendou monitorar FC','Não se identifica como atleta'],comunicacao:['Vivoactive 6 com 80+ modos esportivos é perfeito','Destaque Body Battery e monitoramento de sono','Integração com MyFitnessPal para controle de calorias','Venu 4 se quiser a experiência visual premium'],produtos:['Vivoactive 6','Venu 4','Forerunner 165'],primario:'Vivoactive 6',objections:[{q:'A balança + o celular já me dão essas informações.',a:'O diferencial é o contexto contínuo: o relógio monitora 24 horas — como o sono afeta o estresse do dia seguinte, como a caminhada impactou a recuperação. É uma visão holística que app de celular não consegue dar.'}]},
  {emoji:'🎁',name:'Presenteador',tag:'Compra para outra pessoa',tags:['Presente','Gift'],sinais:['Diz "é pra minha esposa/filho/pai"','Pergunta qual é o mais bonito ou completo','Não sabe o tamanho do pulso da pessoa','Tem orçamento definido'],comunicacao:['Pergunte o perfil da pessoa presenteada, não do presenteador','Mostre opções dentro do orçamento','Mencione a política de troca da Proparts','Lily 2 para mulher elegante, e Fenix 8 para aventureiro'],produtos:['Lily 2','Forerunner 165','Instinct 3','Vivoactive 6'],primario:'Forerunner 165',objections:[{q:'E se ela não gostar?',a:'Efetuando cadastro em nossas lojas, poderá trocar pelo modelo que ela preferir após experimentar. Aqui na Proparts a gente ajuda nesse processo.'}]},
  {emoji:'🚴',name:'Ciclista',tag:'Pedala com frequência, quer dados de performance',tags:['Ciclismo','Bike','Edge'],sinais:['Fala de watts, FTP, cadência','Menciona Zwift, TrainerRoad, rolo de treino','Pergunta sobre ciclocomputador (Edge)','Usa clipless ou tem bike de estrada/gravel'],comunicacao:['Edge 540/840 para ciclocomputador dedicado no guidão','Edge 1040/1050 para ciclista mais exigente','Pedais Rally para medir potência no pedal','Varia RTL515 — radar traseiro é diferencial de segurança'],produtos:['Edge 540','Edge 840','Edge 1040','Edge 1050','Rally RK 200','Varia RTL515'],primario:'Edge 840',objections:[{q:'Prefiro usar o relógio no pulso.',a:'O relógio é ótimo para multiesporte. Mas o Edge no guidão tem tela maior, navegação mais fácil em velocidade. Para ciclista focado, os dois se complementam.'}]},
  {emoji:'🤿',name:'Mergulhador',tag:'Pratica mergulho recreativo ou técnico',tags:['Mergulho','Dive','Aquático'],sinais:['Menciona profundidade, descompressão, nitrox','Pergunta sobre computador de mergulho','Fala de mergulho técnico ou trimix'],comunicacao:['Descent G1/G2 para mergulho recreativo','Descent Mk3i para técnico sério','Descent X30 com autonomia de gás e modo técnico','Destaque: smartwatch completo fora da água'],produtos:['Descent G1','Descent G2','Descent Mk3i','Descent X30'],primario:'Descent G2',objections:[{q:'Prefiro um computador de mergulho separado.',a:'Computadores separados não têm GPS de superfície, mapas ou monitoramento de saúde. O Descent faz tudo isso e é um smartwatch completo no dia a dia.'},{q:'O X30 é muito caro.',a:'Para mergulho técnico com trimix e descompressão complexa, não há comparação. É o nível do Shearwater Perdix em hardware de relógio premium.'}]},
  {emoji:'⛳',name:'Golfista',tag:'Joga golfe com regularidade',tags:['Golfe','Golf'],sinais:['Fala de green, par, bunker, handicap','Pergunta por GPS de golfe','Usa luvas de golfe ou tem look do esporte'],comunicacao:['Approach S44 para entrada com +42.000 campos','Approach S50 para a experiência mais completa com AMOLED','Destaque distâncias automáticas do green','Scorecard digital e estatísticas de handicap'],produtos:['Approach S44','Approach S50'],primario:'Approach S50',objections:[{q:'O app no celular já tem distâncias.',a:'O app serve, mas durante o swing você não vai olhar para o celular. O relógio no pulso mostra a distância instantaneamente, sem tirar o foco do jogo.'}]},
  {emoji:'🏍️',name:'Motociclista',tag:'Piloto de moto, quer GPS robusto para viagens',tags:['Moto','Viagem','GPS'],sinais:['Fala de viagem de moto, rota, estrada','Pergunta por GPS para moto','Usa roupas ou acessórios de motociclismo'],comunicacao:['Zumo XT2 é o GPS específico para moto da Garmin','Tela resistente a luvas, antirreflexo, suporta chuva','Roteamento evita ruas proibidas para motos','Integração com capacete Bluetooth'],produtos:['Zumo XT2'],primario:'Zumo XT2',objections:[{q:'O celular no suporte não é suficiente?',a:'O Zumo XT2 é feito para ser visto com luvas sob sol forte. Não esquenta, não buga, não depende de plano de dados — e o roteamento é específico para moto.'},{q:'Para que GPS se sei a rota?',a:'Para rotas conhecidas talvez não precise. Mas para explorar rotas novas com segurança, o Zumo XT2 garante a chegada mesmo se cair o sinal no interior.'}]},
  {emoji:'🎣',name:'Pescador / Náutico',tag:'Pesca em rios, represas ou mar — quer sonar e GPS',tags:['Pesca','Náutico','GPS'],sinais:['Menciona pesca em represa, rio ou mar','Fala de barco, canoa, lancha','Pergunta sobre sonar ou ecobatímetro','Quer saber profundidade e localização de cardumes'],comunicacao:['Striker 4 para pescador que quer o básico','Striker Vivid 5cv para quem quer ClearVü e SideVü','ECHOMAP UHD2 para navegador sério com mapas náuticos','Destaque: GPS marca os pontos de pesca para voltar depois'],produtos:['Striker 4','Striker Vivid 5cv','ECHOMAP UHD2 52cv','GPSMAP 79','GPSMAP 86'],primario:'Striker Vivid 5cv',objections:[{q:'Uso o celular para mapas no barco.',a:'Celular não tem sonar e a tela não aguenta sol forte, maresia e vibrações. O Striker e ECHOMAP são feitos para isso — e marcam os pontos de pesca que o celular não consegue.'},{q:'Preciso mesmo do ECHOMAP se o Vivid já tem GPS?',a:'O Vivid tem GPS básico. O ECHOMAP adiciona mapas náuticos detalhados com profundidade de canais, marinas e pontos de referência — essencial para quem navega em locais desconhecidos.'}]},
];

function renderProfiles(arr){document.getElementById('profilesGrid').innerHTML=arr.map(p=>`<div class="profile-card" onclick="openProfileModal(${profiles.indexOf(p)})"><div class="profile-card-top"><div class="p-emoji">${p.emoji}</div><div class="p-name">${p.name}</div><div class="p-tag">${p.tag}</div></div><div class="profile-card-body"><div class="p-sinais-label">Sinais de identificação</div><ul class="p-sinais">${p.sinais.slice(0,3).map(s=>`<li>${s}</li>`).join('')}</ul></div><div class="profile-card-footer"><div class="p-prods-label">Produtos indicados</div>${p.produtos.map(pr=>`<span class="prod-pill ${pr===p.primario?'main':''}">${pr}</span>`).join('')}</div></div>`).join('');}
function filterProfiles(){const q=document.getElementById('profileSearch').value.toLowerCase();renderProfiles(q?profiles.filter(p=>p.name.toLowerCase().includes(q)||p.tag.toLowerCase().includes(q)||p.tags.some(t=>t.toLowerCase().includes(q))||p.produtos.some(pr=>pr.toLowerCase().includes(q))):profiles);}
function openProfileModal(i){const p=profiles[i];document.getElementById('profileModalContent').innerHTML=`<div class="modal-emoji">${p.emoji}</div><div class="modal-title">${p.name}</div><div class="modal-sub">${p.tag}</div><div style="margin-bottom:14px;">${p.tags.map(t=>`<span class="tag blue">${t}</span>`).join('')}</div><div class="modal-section"><h4>Como identificar</h4><ul>${p.sinais.map(s=>`<li>${s}</li>`).join('')}</ul></div><div class="modal-section"><h4>Como se comunicar</h4><ul>${p.comunicacao.map(c=>`<li>${c}</li>`).join('')}</ul></div><div class="modal-section"><h4>Objeções comuns</h4>${p.objections.map(o=>`<div class="obj-block"><div class="obj-q">🗣️ ${o.q}</div><div class="obj-a">✅ ${o.a}</div></div>`).join('')}</div><div class="modal-section"><h4>Produtos indicados</h4><div>${p.produtos.map(pr=>`<span class="prod-pill ${pr===p.primario?'main':''}">${pr}</span>`).join('')}</div><p style="font-size:11px;color:var(--text3);margin-top:8px;">Azul = recomendação principal</p></div>`;document.getElementById('profileModal').classList.add('open');}
renderProfiles(profiles);

// PRODUCTS
const prods=[
  {name:'Forerunner 55',s:'Forerunner',cat:'forerunner',lvl:1,para:'Corredor Iniciante',dest:'GPS + cardíaco óptico. Porta de entrada perfeita para quem começa a correr.'},
  {name:'Forerunner 165',s:'Forerunner',cat:'forerunner',lvl:2,para:'Corredor Iniciante / Dedicado',dest:'AMOLED + planos de treino. Ótimo custo-benefício com tela premium.'},
  {name:'Forerunner 265',s:'Forerunner',cat:'forerunner',lvl:3,para:'Corredor Dedicado',dest:'AMOLED + mapas + GPS multibanda. Melhor da faixa intermediária.'},
  {name:'Forerunner 570',s:'Forerunner',cat:'forerunner',lvl:3,para:'Corredor Dedicado / Elite',dest:'Lançamento 2025. AMOLED + GPS SatIQ + Elevate Gen 5.'},
  {name:'Forerunner 955',s:'Forerunner',cat:'forerunner',lvl:4,para:'Atleta de Elite / Triatleta',dest:'30h GPS + mapas topográficos + solar. Referência triatleta.'},
  {name:'Forerunner 965',s:'Forerunner',cat:'forerunner',lvl:4,para:'Atleta de Elite / Triatleta',dest:'AMOLED + titânio + mapas + 31h GPS. Top de corrida com tela premium.'},
  {name:'Forerunner 970',s:'Forerunner',cat:'forerunner',lvl:5,para:'Atleta de Elite',dest:'Cristal safira + ECG + lanterna LED + 32GB. Top absoluto da linha.'},
  {name:'Fenix 8',s:'Fenix',cat:'outdoor',lvl:5,para:'Atleta Elite / Aventureiro',dest:'O multiesporte definitivo. Alto-falante, mic, mergulho, trilha, corrida.'},
  {name:'Enduro 3',s:'Enduro',cat:'outdoor',lvl:5,para:'Ultra / Expedição',dest:'Bateria 70h+ GPS. Para ultramaratonistas e expedições longas.'},
  {name:'Instinct 3',s:'Instinct',cat:'outdoor',lvl:3,para:'Aventureiro / Corredor',dest:'MIL-STD-810. Bateria até 26 dias. Custo-benefício outdoor.'},
  {name:'Instinct E',s:'Instinct',cat:'outdoor',lvl:2,para:'Aventureiro Iniciante',dest:'Versão entrada do Instinct. Robustez com preço acessível.'},
  {name:'Instinct Crossover',s:'Instinct',cat:'outdoor',lvl:3,para:'Aventureiro / Lifestyle',dest:'GPS + ponteiros analógicos. Estética clássica + tecnologia.'},
  {name:'Venu 4',s:'Venu',cat:'lifestyle',lvl:3,para:'Mulher Lifestyle / Bem-estar',dest:'AMOLED premium + saúde feminina completa. Até 9 dias de bateria.'},
  {name:'Venu X1',s:'Venu',cat:'lifestyle',lvl:4,para:'Lifestyle Premium',dest:'Design quadrado moderno. Para quem quer visual tipo Apple Watch.'},
  {name:'Vivoactive 6',s:'Vivoactive',cat:'lifestyle',lvl:2,para:'Academia / Lifestyle',dest:'80+ modos esportivos + músicas offline. Versátil para academia e dia a dia.'},
  {name:'Lily 2',s:'Lily',cat:'lifestyle',lvl:1,para:'Mulher Lifestyle / Presente',dest:'Design joia. Menor relógio Garmin. Elegância e saúde no pulso.'},
  {name:'Lily 2 Active',s:'Lily',cat:'lifestyle',lvl:2,para:'Mulher Lifestyle / Corrida',dest:'Lily com GPS integrado + resistência à água. Corrida + estilo.'},
  {name:'Descent G1',s:'Descent',cat:'mergulho',lvl:2,para:'Mergulhador Recreativo',dest:'Entrada no mundo Descent. Dive watch + GPS. Até 100m.'},
  {name:'Descent G2',s:'Descent',cat:'mergulho',lvl:3,para:'Mergulhador Recreativo / Avançado',dest:'Multigas + AMOLED + GPS. Melhor custo-benefício Descent.'},
  {name:'Descent Mk3i',s:'Descent',cat:'mergulho',lvl:4,para:'Mergulhador Técnico',dest:'Titânio + AMOLED + multibanda. Para mergulhadores técnicos sérios.'},
  {name:'Descent X30',s:'Descent',cat:'mergulho',lvl:5,para:'Mergulhador Técnico Avançado',dest:'Autonomia de gás + trimix + modo técnico avançado.'},
  {name:'Edge 540',s:'Edge',cat:'edge',lvl:2,para:'Ciclista Intermediário',dest:'GPS multibanda + botões físicos. Bateria 26h. Compacto e preciso.'},
  {name:'Edge 550',s:'Edge',cat:'edge',lvl:2,para:'Ciclista / Tela Brilhante',dest:'2025. Tela 1000 nits + speaker + Cycling Coach. Sucessor do 540.'},
  {name:'Edge 840',s:'Edge',cat:'edge',lvl:3,para:'Ciclista Dedicado',dest:'Touchscreen + botões + GPS multibanda + ClimbPro. Ideal para MTB e estrada.'},
  {name:'Edge 850',s:'Edge',cat:'edge',lvl:3,para:'Ciclista Dedicado / Avançado',dest:'2025. Tela 1000 nits + speaker + bike bell. Menor Edge 1050.'},
  {name:'Edge 1040',s:'Edge',cat:'edge',lvl:4,para:'Ciclista Avançado',dest:'Tela 3.5" + mapas + solar disponível. Bateria 35h+ GPS.'},
  {name:'Edge 1050',s:'Edge',cat:'edge',lvl:5,para:'Ciclista Elite',dest:'Tela 3.5" 1000 nits + Garmin Pay + bike bell + hazard alerts.'},
  {name:'GPSMAP 65',s:'GPSMAP',cat:'gps',lvl:3,para:'Trilheiro / Aventureiro',dest:'GPS portátil colorido + multibanda. Botões físicos.'},
  {name:'GPSMAP 65s',s:'GPSMAP',cat:'gps',lvl:3,para:'Trilheiro / Aventureiro',dest:'GPSMAP 65 + barômetro + bússola 3 eixos.'},
  {name:'GPSMAP 67',s:'GPSMAP',cat:'gps',lvl:4,para:'Aventureiro / Expedição',dest:'Tela 3" + TopoAtivos Brasil + altímetro + bússola + USB-C. O mais completo.'},
  {name:'GPSMAP 79',s:'GPSMAP',cat:'gps',lvl:3,para:'Pescador / Náutico',dest:'GPS portátil flutuante para uso náutico. Mapas BlueChart.'},
  {name:'GPSMAP 86',s:'GPSMAP',cat:'gps',lvl:3,para:'Náutico / Marinheiro',dest:'GPS náutico flutuante 3" + bússola + barômetro. Para embarcações.'},
  {name:'GPSMAP H1i',s:'GPSMAP',cat:'gps',lvl:3,para:'Caçador Avançado',dest:'GPS portátil para caça. Rastreamento de animais + mapas de propriedade. Com tecnologia InReach.'},
  {name:'eTrex 22x',s:'eTrex',cat:'gps',lvl:1,para:'Caminhante / Iniciante',dest:'Entrada da linha eTrex. Robusto, simples, mapas TopoActive. Bateria AA.'},
  {name:'eTrex 32x',s:'eTrex',cat:'gps',lvl:2,para:'Trilheiro / Trekking',dest:'eTrex 22x + bússola 3 eixos + altímetro barométrico. Para quem precisa de bússola real.'},
  {name:'eTrex Touch',s:'eTrex',cat:'gps',lvl:2,para:'Usuário Casual',dest:'Único eTrex com touchscreen. Mais fácil de navegar nos menus.'},
  {name:'eTrex Solar',s:'eTrex',cat:'gps',lvl:3,para:'Expedição / Ultra',dest:'Carregamento solar + bateria de até 100h. Para quem fica dias sem carregar.'},
  {name:'inReach Mini 2',s:'inReach',cat:'gps',lvl:3,para:'Aventureiro / Expedição',dest:'Comunicador satélite bidirecional. SOS + mensagens sem sinal de celular.'},
  {name:'inReach Mini 3',s:'inReach',cat:'gps',lvl:3,para:'Aventureiro / Expedição',dest:'Mini 2 + tela colorida touch + GPS multibanda + sirene. Versão atual.'},
  {name:'inReach Mini 3 Plus',s:'inReach',cat:'gps',lvl:4,para:'Profissional / Expedição',dest:'Mini 3 + mensagens de voz (30s) + fotos via satélite. Para uso profissional.'},
  {name:'Drive 53',s:'Drive',cat:'gps',lvl:1,para:'Motorista / Navegador',dest:'GPS veicular 5". Mapas do Brasil podem ser adquiridos a parte. Offline, sem internet.'},
  {name:'Approach S44',s:'Approach',cat:'golf',lvl:2,para:'Golfista Iniciante',dest:'+42.000 campos. Distâncias automáticas. Entrada ideal no golfe Garmin.'},
  {name:'Approach S50',s:'Approach',cat:'golf',lvl:3,para:'Golfista Dedicado',dest:'AMOLED + +42.000 campos + visão aérea. Melhor experiência de golfe.'},
  {name:'Zumo XT2',s:'Zumo',cat:'moto',lvl:4,para:'Motociclista',dest:'GPS para moto. Tela resistente a luvas, chuva e sol. Roteamento anti-pedágio.'},
  {name:'Striker 4',s:'Striker',cat:'marine',lvl:1,para:'Pescador Iniciante',dest:'Sonar 3.5" com GPS básico. Entrada acessível para pesca.'},
  {name:'Striker Vivid 5cv',s:'Striker',cat:'marine',lvl:2,para:'Pescador',dest:'Sonar 5" colorido + ClearVü + SideVü + GPS. Ótimo custo-benefício.'},
  {name:'ECHOMAP UHD2 52cv',s:'ECHOMAP',cat:'marine',lvl:3,para:'Pescador/Navegador',dest:'Chartplotter + sonar UHD2 5". Mapas BlueChart G3.'},
  {name:'HRM 200',s:'HRM',cat:'acess',lvl:2,para:'Corredor / Ciclista',dest:'Monitor cardíaco de peito. Precisão superior ao óptico de pulso. Não armazena atividades.'},
  {name:'HRM 600',s:'HRM',cat:'acess',lvl:4,para:'Corredor / Nadador / Triatleta',dest:'Monitor cardíaco premium com dinâmicas de corrida, HRV e armazenamento de atividades.'},
  {name:'Varia RTL515',s:'Varia',cat:'acess',lvl:3,para:'Ciclista',dest:'Radar traseiro + luz. Detecta veículos a 140m e alerta no relógio.'},
  {name:'Rally RK 200',s:'Rally',cat:'acess',lvl:4,para:'Ciclista de Performance',dest:'Pedal medidor de potência SPD. Compatível com qualquer pedivela.'},
];
function renderProds(filter){const f=filter==='todos'?prods:prods.filter(p=>p.cat===filter);document.getElementById('prodsBody').innerHTML=f.map(p=>{const dots=Array.from({length:5},(_,i)=>`<div class="ld ${i<p.lvl?'on':''}"></div>`).join('');return`<tr><td><div class="prod-name">${p.name}</div><span class="prod-series">${p.s}</span></td><td><div class="level-dots">${dots}</div></td><td style="font-size:12px;color:var(--text3);">${p.para}</td><td style="font-size:12.5px;color:var(--text);max-width:220px;">${p.dest}</td></tr>`;}).join('');}
function filterProds(cat,btn){document.querySelectorAll('.fbtn').forEach(b=>b.classList.remove('active'));btn.classList.add('active');renderProds(cat);}
renderProds('todos');

// FAQ
const faqs=[
  {q:'Qual a diferença entre Garmin Connect e Connect IQ?',a:'Garmin Connect é o app de sincronização — recebe dados do relógio e integra com Strava, Apple Health etc. Connect IQ é a loja de apps que rodam DENTRO do relógio, como Spotify, Wikiloc e Woo. São coisas completamente diferentes!'},
  {q:'O Garmin tem Spotify?',a:'Sim! Nos modelos com armazenamento interno (FR265, 570, 955, 965, 970, Fenix 8, Venu 4 e outros). Baixe o app Spotify pela Connect IQ Store, sincronize playlists via Wi-Fi e ouça offline com fones Bluetooth conectados direto ao relógio.'},
  {q:'O Garmin funciona sem celular?',a:'Sim. O GPS é embutido no relógio. Você sai para correr sem celular e registra todos os dados. A sincronização acontece depois, quando você conecta via Bluetooth.'},
  {q:'Quanto tempo dura a bateria?',a:'Em smartwatch (sem GPS): FR55 ~2 semanas, Instinct 3 ~26 dias, Fenix 8 ~18 dias. Em GPS ativo: FR55 ~20h, FR955 ~30h, Enduro 3 ~70h. GPS multibanda consome ~30-40% mais que o GPS padrão.'},
  {q:'Qual a diferença entre GPS multibanda e GPS comum?',a:'O GPS comum usa uma frequência de satélite. O multibanda usa duas (L1 e L5) simultaneamente, resultando em traçado muito mais preciso em cidades com prédios, florestas e montanhas. Disponível no FR265, 570, 955, 965, 970, Fenix 8, Enduro 3.'},
  {q:'O sensor de FC no pulso é preciso?',a:'Preciso em intensidade moderada (corrida, caminhada, ciclismo constante). Em atividades de alta intensidade, recomendamos o HRM de peito (HRM 200 ou HRM 600) para máxima precisão.'},
  {q:'O que é o VO2 Max da Garmin?',a:'Estimativa do consumo máximo de oxigênio calculada pelo algoritmo FirstBeat, baseada na relação entre FC e velocidade. Não é medição laboratorial, mas é muito correlacionada ao VO2 Max real e serve como excelente indicador de evolução aeróbica.'},
  {q:'O que é o Body Battery?',a:'Indicador de energia de 0-100 baseado em HRV, sono, estresse e atividade. Sobe com sono de qualidade, cai com estresse e exercício. Ajuda o atleta a saber o melhor momento para treinar forte ou descansar.'},
  {q:'O Garmin monitora sono?',a:'Sim. Todos os modelos com sensor de FC monitoram sono automaticamente: fases (leve, profundo, REM), SpO2 noturno (em modelos compatíveis) e pontuação de sono. Os dados ficam disponíveis no Garmin Connect pela manhã.'},
  {q:'O Garmin funciona com Android e iPhone?',a:'Sim. O Garmin Connect é compatível com iOS e Android. Apple Health sincroniza apenas em iPhones. Todas as funcionalidades principais funcionam em ambas as plataformas.'},
  {q:'O Garmin tem NFC para pagamento?',a:'Sim, via Garmin Pay nos modelos compatíveis: Fenix 8, FR265, 570, 955, 965, 970, Venu 4, Vivoactive 6 e outros. Funciona com cartões de bancos parceiros (BTG, BB e Santander) cadastrados no Garmin Connect.'},
  {q:'Qual a garantia oferecida pela Proparts?',a:'A Proparts oferece 2 anos de garantia para todos os dispositivos Garmin. Para acessórios, a garantia é de 1 ano. Sempre direcione o cliente a criar/completar o cadastro, isso garante que trocas e garantias sejam acionadas sem problemas.'},
  {q:'O Edge é diferente do relógio para ciclismo?',a:'Sim. O Edge é um ciclocomputador fixado no guidão — tela maior, ideal para ver dados em velocidade. Relógios como FR955 ou Fenix 8 também registram ciclismo com precisão. Para ciclista focado, os dois se complementam.'},
  {q:'Qual a diferença entre Edge 540/840 e Edge 550/850?',a:'Os modelos x50 (550/850, lançados em 2025) são a nova geração: tela mais brilhante (1000 nits), speaker integrado e Cycling Coach. A bateria dos x50 é menor (~10-12h) em troca da tela mais brilhante.'},
  {q:'O inReach Mini precisa de assinatura para funcionar?',a:'Sim. Sem assinatura ativa, as funções via satélite (SOS, mensagens, rastreamento) ficam desativadas. Existe o plano Enabled (~US$7,99/mês) para SOS de emergência. É possível suspender por até 12 meses sem custo.'},
  {q:'Qual a diferença entre HRM 200 e HRM 600?',a:'O HRM 200 é para corrida e ciclismo — não armazena atividades, precisa estar conectado ao relógio para registrar dados. O HRM 600 é para corrida, natação e triatlo — armazena as atividades internamente, inclusive embaixo da água, e transmite para o relógio depois.'},
  {q:'Qual rede de satélites o inReach utiliza para comunicação?',a:'O inReach usa a rede de satélites Iridium®, que oferece cobertura global de 100% do planeta — incluindo oceanos, polos e áreas sem qualquer cobertura de celular.'},
];
function renderFaq(){document.getElementById('faqList').innerHTML=faqs.map((f,i)=>`<div class="acc-item" id="faq-${i}"><button class="acc-btn" onclick="toggleAcc(this)"><span><span class="acc-icon">❓</span>${f.q}</span><span class="acc-chevron">▼</span></button><div class="acc-body">${f.a}</div></div>`).join('');}
function filterFaq(){const q=document.getElementById('faqSearch').value.toLowerCase();faqs.forEach((f,i)=>{const el=document.getElementById('faq-'+i);if(el)el.style.display=(!q||f.q.toLowerCase().includes(q)||f.a.toLowerCase().includes(q))?'':'none';});}
renderFaq();

// COMPETITORS
const comps=[
  {name:'Apple Watch',badge:'⚠️ Principal',bc:'orange',desc:'O concorrente mais citado. Forte em design e integração com iPhone. Fraco em bateria e precisão esportiva.',rows:[{a:'Bateria GPS',g:'30h+ (FR955) / 70h (Enduro)',t:'~6-18h dependendo do modelo'},{a:'Precisão GPS',g:'Multibanda + múltiplos satélites',t:'GPS básico (Ultra tem dual frequency)'},{a:'Foco esportivo',g:'Ferramenta de atleta — FirstBeat',t:'Smartwatch com função esportiva'},{a:'Bateria diária',g:'Dias ou semanas',t:'1-2 dias'},{a:'Compatibilidade',g:'iOS e Android',t:'Exclusivo iPhone'}]},
  {name:'Polar',badge:'⚠️ Principal',bc:'orange',desc:'Referência em análise científica de treino. Boa análise, mas ecossistema menor.',rows:[{a:'Análise de treino',g:'FirstBeat — líder de mercado',t:'Excelente — base acadêmica'},{a:'GPS',g:'Multibanda nos modelos avançados',t:'Preciso mas sem multibanda na maioria'},{a:'Apps no relógio',g:'Connect IQ com centenas de apps',t:'Ecossistema menor'},{a:'Bateria',g:'Dias ou semanas',t:'Até ~40h GPS nos top'}]},
  {name:'Coros',badge:'⚡ Crescente',bc:'blue',desc:'Marca chinesa com preço agressivo. Principal argumento do cliente sensível a preço.',rows:[{a:'Preço',g:'Premium — qualidade justifica',t:'Até 30-40% mais barato'},{a:'Ecossistema',g:'Connect IQ + 50+ integrações',t:'Ecossistema em desenvolvimento'},{a:'Suporte no Brasil',g:'Rede oficial Proparts',t:'Suporte mais limitado'},{a:'Histórico',g:'+35 anos no mercado',t:'Marca recente (2012)'}]},
  {name:'Samsung Galaxy Watch',badge:'💡 Lifestyle',bc:'blue',desc:'Forte em design e Android. Não compete em esporte de performance.',rows:[{a:'Bateria',g:'Dias ou semanas com GPS',t:'1-3 dias com GPS ativo'},{a:'Esportes avançados',g:'Algoritmos específicos por modalidade',t:'Modo esportivo básico'},{a:'Compatibilidade',g:'iOS e Android',t:'Melhor com Samsung Android'}]},
  {name:'Suunto',badge:'🌿 Nicho Outdoor',bc:'blue',desc:'Herança em outdoor e mergulho. Qualidade, mas ecossistema menor.',rows:[{a:'Outdoor / Trilha',g:'Fenix 8, Instinct 3 — referência',t:'Suunto 9 é boa proposta'},{a:'Mergulho',g:'Série Descent — mais completa',t:'Tradição em dive computers'},{a:'Integrações',g:'Connect IQ + dezenas',t:'Ecossistema mais limitado'},{a:'Distribuição BR',g:'Rede Proparts ampla',t:'Distribuição mais restrita'}]},
];
document.getElementById('compList').innerHTML=comps.map(c=>`<div class="comp-card"><div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:6px;"><div class="comp-brand">${c.name}</div><span class="tag ${c.bc}">${c.badge}</span></div><p style="font-size:13px;color:var(--text2);margin-bottom:12px;line-height:1.6;">${c.desc}</p><table class="vs-table"><tr><th>Aspecto</th><th class="ours">✅ Garmin / Proparts</th><th class="theirs">○ ${c.name}</th></tr>${c.rows.map(r=>`<tr><td style="color:var(--text3);">${r.a}</td><td class="ours">${r.g}</td><td class="theirs">${r.t}</td></tr>`).join('')}</table></div>`).join('');

// SPORTS
const sports=[
  {emoji:'🏃',name:'Corrida',metrics:['Distância','Ritmo (min/km)','Cadência (passos/min)','Tempo de contato com solo','FC','Extensão da passada','Oscilação vertical','PacePRO','Potência de corrida','Elevação','VO2 Max estimado','Training Effect']},
  {emoji:'🚴',name:'Ciclismo',metrics:['Distância','Velocidade (atual/média/máx)','Cadência (RPM)','Elevação acumulada','Potência (com pedal Rally)','FTP estimado','FC','Training Load']},
  {emoji:'🏊',name:'Natação',metrics:['Distância','Ritmo (min/100m)','Frequência de braçadas','Tipo de braçada (crawl, costas, peito, borboleta)','SWOLF (eficiência)','Tempo de descanso entre séries']},
  {emoji:'💪',name:'Academia / Força',metrics:['Séries e repetições (detecção automática)','Calorias ativas','Mapa muscular','FC','Tempo de descanso']},
  {emoji:'🥾',name:'Trilha / Trekking',metrics:['Distância','Subida total acumulada','Velocidade média','FC','Elevação atual','Mapa topográfico (modelos compatíveis)','Wikiloc / Komoot integrado']},
  {emoji:'🏄',name:'Surf',metrics:['Número de ondas','Velocidade máxima','Distância em ondas','Tempo de sessão','FC']},
  {emoji:'🪁',name:'Kitesurf',metrics:['Distância total','FC','Velocidade máxima','Altura de saltos em tempo real (app Woo)','Dados de sessão via Hoolan']},
  {emoji:'⛳',name:'Golfe',metrics:['Scorecard digital','Distância até frente/meio/fundo do green','Detecção automática de tacadas','Handicap','Par do buraco']},
  {emoji:'🤿',name:'Mergulho (Descent)',metrics:['Profundidade atual e máxima','Tempo de fundo','NDL (limite sem descompressão)','Temperatura da água','Algoritmo Bühlmann','Modo Nitrox','Autonomia de gás (X30)','Modo apneia']},
  {emoji:'🏍️',name:'Moto (Zumo XT2)',metrics:['Roteamento específico para moto','Evita estradas proibidas','Integração capacete Bluetooth','Rastreamento de rota']},
];
document.getElementById('sportsList').innerHTML=sports.map(s=>`<div class="sport-card"><div class="sport-header"><div class="sport-emoji">${s.emoji}</div><div class="sport-name">${s.name}</div></div><div class="metrics-wrap">${s.metrics.map(m=>`<span class="tag">${m}</span>`).join('')}</div></div>`).join('');

// CERTIFICATION
const certs=[
  {emoji:'🧭',level:'Nível 1',name:'Explorador',color:'#007CC3',unlocked:true,obj:'Dominar o portfólio básico Garmin, entender os perfis de cliente mais comuns e realizar um atendimento estruturado do início ao fim.',skills:['Identificar os perfis de cliente mais frequentes','Apresentar o produto certo baseado na sondagem','Usar o script de atendimento com confiança','Explicar o Garmin Connect e a sincronização','Contornar as 3 objeções mais comuns'],mods:[{n:1,t:'O Universo Garmin',c:'História, posicionamento e DNA da marca.'},{n:2,t:'Perfis de Cliente',c:'Os 12 perfis: como identificar e comunicar.'},{n:3,t:'Script de Atendimento',c:'Os 5 passos do atendimento presencial.'},{n:4,t:'Objeções Comuns',c:'As principais objeções e como respondê-las.'},{n:5,t:'Quiz Explorador',c:'10 questões. Mínimo 70%. (+100 pts no ranking)'}]},
  {emoji:'🏃',level:'Nível 2',name:'Corredor',color:'#00C2A8',unlocked:false,obj:'Dominar tecnicamente toda a linha Forerunner e vender para corredores de todos os níveis com autoridade.',skills:['Diferenciar cada modelo Forerunner','Explicar GPS multibanda e FirstBeat','Apresentar PacePRO, Training Readiness e Body Battery','Integrar Garmin com Strava e TrainingPeaks'],mods:[{n:1,t:'Linha Forerunner Completa',c:'FR55 ao FR970: diferenças técnicas.'},{n:2,t:'Métricas de Corrida',c:'PacePRO, potência, VO2 Max, Training Effect.'},{n:3,t:'Ecossistema do Corredor',c:'Strava, TrainingPeaks, Stryd, planos adaptativos.'},{n:4,t:'Quiz Corredor',c:'25 questões. Mínimo 70%. (+100 pts no ranking)'}]},
  {emoji:'🏅',level:'Nível 3',name:'Maratonista',color:'#F0A500',unlocked:false,obj:'Dominar linhas premium (Fenix, Instinct, Descent, Edge) e vender para atletas de alta performance.',skills:['Apresentar Fenix 8 e Descent com autoridade','Dominar linha Edge de ciclocomputadores','Conduzir comparação Garmin vs concorrentes'],mods:[{n:1,t:'Linha Premium: Fenix, Enduro, Instinct',c:'Diferenciais técnicos e argumentação.'},{n:2,t:'Mergulho: Série Descent',c:'Bühlmann, nitrox e modos técnicos.'},{n:3,t:'Ciclismo: Edge + Rally + Varia',c:'Edge 540/840/1050 + pedais de potência + radar.'},{n:4,t:'Concorrentes em Profundidade',c:'Apple Watch, Polar, Coros — argumentação.'},{n:5,t:'Quiz Maratonista',c:'30 questões. Mínimo 75%. (+100 pts no ranking)'}]},
  {emoji:'🏆',level:'Nível 4',name:'Triatleta',color:'#FF6B35',unlocked:false,obj:'Tornar-se referência técnica da equipe e ter capacidade de treinar novos colaboradores.',skills:['Dominar 100% do portfólio incluindo náutico e GPS portátil','Conduzir treinamentos para novos colaboradores','Configurar qualquer produto Garmin ao vivo'],mods:[{n:1,t:'Portfólio Completo: Náutico, inReach, GPS',c:'ECHOMAP, Striker, GPSMAP, inReach, Zumo.'},{n:2,t:'Configuração Avançada',c:'Configurar qualquer modelo, Connect IQ, planos.'},{n:3,t:'Mentoria e Liderança',c:'Como transmitir o conhecimento para novos.'},{n:4,t:'Quiz Final Triatleta',c:'40 questões. Mínimo 80%. (+100 pts no ranking)'}]},
];
document.getElementById('certList').innerHTML=certs.map((c,i)=>`<div class="cert-card ${c.unlocked?'unlocked':'locked'}" ${c.unlocked?`onclick="openCertModal(${i})"`:''} ><div class="cert-header"><div class="cert-emoji">${c.emoji}</div><div><div class="cert-level-text">${c.level}</div><div class="cert-name-text">${c.name}</div></div>${c.unlocked?`<div style="margin-left:auto;font-size:12px;font-weight:600;color:var(--g);">Disponível →</div>`:`<div style="margin-left:auto;font-size:20px;">🔒</div>`}</div><div class="cert-stripe" style="background:linear-gradient(90deg,${c.color},transparent);"></div><div class="cert-body"><div class="cert-obj">${c.obj}</div><div class="cert-modules">${c.mods.map(m=>`<span class="cert-mod-pill">Módulo ${m.n}: ${m.t}</span>`).join('')}</div>${c.unlocked?'<div style="font-size:12px;font-weight:600;color:var(--g);margin-top:12px;">Toque para ver os módulos →</div>':''}</div></div>`).join('');
function openCertModal(i){const c=certs[i];document.getElementById('certModalContent').innerHTML=`<div style="font-size:40px;margin-bottom:8px;">${c.emoji}</div><div style="font-size:10px;letter-spacing:2px;text-transform:uppercase;color:var(--text3);margin-bottom:2px;">${c.level}</div><div style="font-family:'Rajdhani',sans-serif;font-weight:700;font-size:24px;text-transform:uppercase;color:var(--text);margin-bottom:6px;">${c.name}</div><div style="height:3px;background:linear-gradient(90deg,${c.color},transparent);border-radius:2px;margin-bottom:16px;"></div><div class="modal-section"><h4>Objetivo</h4><p style="font-size:13px;color:var(--text);line-height:1.6;">${c.obj}</p></div><div class="modal-section"><h4>Habilidades desenvolvidas</h4><ul>${c.skills.map(s=>`<li>${s}</li>`).join('')}</ul></div><div class="modal-section"><h4>Módulos</h4>${c.mods.map(m=>`<div style="background:var(--off);border-radius:8px;padding:12px;margin-bottom:8px;"><div style="font-family:'Rajdhani',sans-serif;font-weight:700;color:var(--g);font-size:14px;margin-bottom:3px;">Módulo ${m.n}: ${m.t}</div><div style="font-size:12px;color:var(--text2);line-height:1.6;">${m.c}</div></div>`).join('')}</div>`;document.getElementById('certModal').classList.add('open');}
function closeCertModal(e){if(e.target===document.getElementById('certModal'))document.getElementById('certModal').classList.remove('open');}

// ===== QUIZ =====
const quizData=[
  {q:'Em que ano a Garmin foi fundada?',opts:['1985','1989','1993','1999'],correct:1,exp:'A Garmin foi fundada em 1989 por Gary Burrell e Min Kao em Lenexa, Kansas, EUA.'},
  {q:'O que significa o nome "Garmin"?',opts:['Acrônimo de GPS Advanced Routing Monitoring & Intelligence Navigation','Junção das iniciais de Gary Burrell e Min Kao (GAR + MIN)','Nome de uma cidade no Kansas onde foi fundada','Palavra de origem japonesa que significa "precisão"'],correct:1,exp:'GAR + MIN = GARMIN. O nome vem das iniciais dos dois fundadores: Gary Burrell e Min Kao.'},
  {q:'Quais são os 5 segmentos oficiais da Garmin?',opts:['Fitness, Outdoor, Aviation, Marine e Auto','Sports, Adventure, Navigation, Diving e Cycling','Watches, GPS, Cycling, Marine e Automotive','Running, Cycling, Swimming, Hiking e Driving'],correct:0,exp:'Os 5 segmentos oficiais são: Fitness, Outdoor, Aviation (Aviação), Marine (Náutico) e Auto (Automotivo).'},
  {q:'Qual rede de satélites o inReach utiliza para comunicação?',opts:['Starlink (SpaceX)','GPS americano (NAVSTAR)','Iridium®','Galileo (europeu)'],correct:2,exp:'O inReach usa a rede Iridium®, que oferece cobertura global de 100% do planeta — incluindo oceanos e polos.'},
  {q:'O que é o Body Battery™?',opts:['Indicador da capacidade da bateria do relógio','Indicador de energia do corpo de 0-100 baseado em HRV, sono e estresse','Medidor de força muscular durante treinos de academia','Estimativa de calorias restantes para consumir no dia'],correct:1,exp:'Body Battery é um indicador exclusivo Garmin que mede a energia disponível do corpo (0-100) com base em HRV, qualidade do sono e níveis de estresse.'},
  {q:'Qual a principal diferença do GPS multibanda para o GPS comum?',opts:['O multibanda conecta a mais satélites ao mesmo tempo, chegando a 50','O multibanda usa duas frequências de satélite (L1 e L5) resultando em traçado muito mais preciso em cidades e florestas','O multibanda funciona sem bateria usando energia solar','O multibanda é exclusivo para atividades aquáticas'],correct:1,exp:'O GPS multibanda usa duas frequências (L1 e L5) simultaneamente, resultando em muito mais precisão de traçado em ambientes com interferência como cidades com prédios altos e florestas densas.'},
  {q:'O que é o VO2 Max no contexto Garmin?',opts:['Velocidade máxima registrada em uma corrida','Volume máximo de batimentos cardíacos por minuto','Estimativa do consumo máximo de oxigênio calculada pelo algoritmo FirstBeat','Medição de oxigenação do sangue durante o sono'],correct:2,exp:'O VO2 Max do Garmin é uma estimativa calculada pelo algoritmo FirstBeat baseada na relação entre FC e velocidade durante treinos. É um excelente indicador de evolução da capacidade aeróbica.'},
  {q:'O que diferencia o Garmin Connect do Connect IQ?',opts:['Connect é para relógios e Connect IQ é para ciclocomputadores','Connect é o app de sincronização de dados; Connect IQ é a loja de apps que rodam dentro do relógio','Connect é gratuito e Connect IQ é pago','Connect é para iOS e Connect IQ é para Android'],correct:1,exp:'Garmin Connect = app que recebe e sincroniza dados do relógio. Connect IQ = loja de apps que instalam e rodam diretamente no relógio, como Spotify, Woo e Wikiloc.'},
  {q:'Qual a política de garantia da Proparts para dispositivos Garmin?',opts:['6 meses de garantia para todos os produtos','1 ano para dispositivos e 6 meses para acessórios','2 anos para dispositivos e 1 ano para acessórios','1 ano para todos os produtos sem distinção'],correct:2,exp:'A Proparts oferece 2 anos de garantia para dispositivos e 1 ano para acessórios. Sempre guarde a nota fiscal para acionar a garantia.'},
  {q:'Qual das afirmações sobre a Garmin é CORRETA?',opts:['A Garmin foi fundada no Japão e é uma empresa asiática','A Garmin é especializada exclusivamente em relógios esportivos desde 1989','A Garmin tem mais de 35 anos de expertise em GPS e atua em 5 segmentos: Fitness, Outdoor, Aviation, Marine e Auto','A Garmin foi a primeira empresa a criar um smartphone com GPS integrado'],correct:2,exp:'Correto! A Garmin foi fundada em 1989 nos EUA, tem mais de 35 anos de expertise em GPS e atua em 5 segmentos oficiais: Fitness, Outdoor, Aviation, Marine e Auto.'},
];

let currentQ=0,score=0,answered=false;
function initQuiz(){currentQ=0;score=0;answered=false;renderQuestion();}
function renderQuestion(){
  const q=quizData[currentQ];
  const pct=((currentQ)/quizData.length)*100;
  document.getElementById('quizBar').style.width=pct+'%';
  document.getElementById('quizContent').innerHTML=`
    <div class="quiz-q-num">Pergunta ${currentQ+1} de ${quizData.length}</div>
    <div class="quiz-q">${q.q}</div>
    <div class="quiz-options">
      ${q.opts.map((o,i)=>`<button class="quiz-opt" onclick="answerQ(${i})" id="opt-${i}">${o}</button>`).join('')}
    </div>
    <div class="quiz-feedback" id="quizFeedback"></div>
    <div class="quiz-nav"><button class="quiz-btn" id="nextBtn" onclick="nextQ()" disabled>${currentQ<quizData.length-1?'Próxima →':'Ver Resultado'}</button></div>
  `;
  answered=false;
}
function answerQ(i){
  if(answered)return;
  answered=true;
  const q=quizData[currentQ];
  document.querySelectorAll('.quiz-opt').forEach(b=>b.classList.add('disabled'));
  const opts=document.querySelectorAll('.quiz-opt');
  const fb=document.getElementById('quizFeedback');
  if(i===q.correct){
    opts[i].classList.add('correct');
    fb.className='quiz-feedback show ok';
    fb.textContent='✅ Correto! '+q.exp;
    score++;
  } else {
    opts[i].classList.add('wrong');
    opts[q.correct].classList.add('correct');
    fb.className='quiz-feedback show fail';
    fb.textContent='❌ Incorreto. '+q.exp;
  }
  document.getElementById('nextBtn').disabled=false;
}
function nextQ(){
  currentQ++;
  if(currentQ<quizData.length){renderQuestion();}
  else{showResult();}
}
function showResult(){
  const pct=Math.round((score/quizData.length)*100);
  const passed=pct>=70;
  document.getElementById('quizBar').style.width='100%';
  document.getElementById('quizContent').innerHTML=`
    <div class="quiz-result">
      <div class="quiz-result-emoji">${passed?'🎉':'📚'}</div>
      <div class="quiz-result-title" style="color:${passed?'var(--acc)':'var(--warn)'};">${passed?'Parabéns! Aprovado!':'Continue estudando!'}</div>
      <div class="quiz-result-score">Você acertou <strong>${score}</strong> de ${quizData.length} questões — <strong>${pct}%</strong></div>
      ${passed?`
        <div class="register-form">
          <label class="register-label">📝 Registre sua conclusão — informe seu nome ou código</label>
          <input type="text" class="register-input" id="regName" placeholder="Ex: Leticia Castro ou 05" maxlength="60">
          <button class="register-btn" onclick="registerResult(${pct})">Registrar Conclusão ✓</button>
          <div class="register-success" id="regSuccess">✅ Registrado com sucesso! Resultado enviado para a liderança da Proparts.</div>
          <div class="quiz-feedback fail" id="regError" style="display:none;margin-top:10px;"></div>
        </div>
      `:''}
      <div style="margin-top:16px;display:flex;gap:10px;justify-content:center;flex-wrap:wrap;">
        <button class="quiz-btn" onclick="initQuiz()" style="background:var(--text2);">Refazer Quiz</button>
        ${passed?'':'<button class="quiz-btn" onclick="goHome();setTimeout(()=>openPanel(\'universo\'),100)">Revisar Conteúdo</button>'}
      </div>
    </div>
  `;
}

async function registerResult(pct){
  const name=document.getElementById('regName').value.trim();
  const input=document.getElementById('regName');
  const btn=document.querySelector('.register-btn');
  const err=document.getElementById('regError');

  if(!name){
    input.style.borderColor='var(--warn)';
    if(err){err.style.display='block';err.textContent='Informe seu nome ou código antes de registrar.';}
    return;
  }

  input.style.borderColor='';
  if(err){err.style.display='none';err.textContent='';}
  btn.textContent='Enviando...';
  btn.disabled=true;

  try{
    const response = await fetch(SHEETS_URL,{
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body:JSON.stringify({
        nome:name,
        modulo:'Módulo 1 — Universo Garmin',
        nota:pct,
        acertos:score,
        total:quizData.length,
        origem:'Garmin Training Site'
      })
    });

    let data = {};
    try { data = await response.json(); } catch(e) {}

    if(!response.ok || data.success === false){
      throw new Error(data.error || 'Falha ao registrar resultado');
    }

    document.querySelector('.register-form').style.display='none';
    document.getElementById('regSuccess').style.display='block';
  }catch(e){
    btn.textContent='Registrar Conclusão ✓';
    btn.disabled=false;
    if(err){
      err.style.display='block';
      err.textContent='Erro ao registrar no Google Sheets. Verifique a publicação do Apps Script e a URL configurada.';
    }else{
      alert('Erro ao registrar. Verifique a publicação do Apps Script e tente novamente.');
    }
  }
}
initQuiz();

// HASH ROUTING SIMPLES
window.addEventListener('load',()=>{
  const hash=window.location.hash.replace('#','');
  if(hash){
    const panel=document.getElementById('panel-'+hash);
    if(panel) openPanel(hash);
  }
});
window.addEventListener('hashchange',()=>{
  const hash=window.location.hash.replace('#','');
  if(hash){
    const panel=document.getElementById('panel-'+hash);
    if(panel) openPanel(hash);
  }
});
