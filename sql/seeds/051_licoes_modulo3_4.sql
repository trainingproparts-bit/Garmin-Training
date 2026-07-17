-- ============================================================================
-- GARMIN TRAINING HUB - SEED 051: LIÇÕES DOS MÓDULOS 3 E 4 (lessons.body)
-- ============================================================================
-- Migração de conteúdo real do protótipo estático index_redesign_v5.html para
-- a tabela lessons (ver garmin_training_hub_migrations.sql). Cobre o texto
-- rico dos painéis de treinamento que ainda não tinha lesson.body migrado
-- (item listado no backlog de sql/README.md).
--
-- Fontes no protótipo:
--   Módulo 3 (Produtos)      -> panel-produtos-modulo,     linhas ~6115-6242
--   Módulo 4 (Concorrentes)  -> panel-concorrentes-modulo,  linhas ~6369-6798
--
-- Cada módulo foi dividido em lições seguindo o agrupamento que já existe no
-- HTML original (uma "linha" de produto por lição no Módulo 3; um card de
-- concorrente por lição no Módulo 4, com a lição final reunindo as objeções
-- gerais que não são específicas de nenhuma marca). Nenhum fato, número ou
-- especificação foi inventado: tudo vem do texto/descrições originais do
-- protótipo, apenas reescrito em prosa corrida no tom de um instrutor.
--
-- Pré-requisito: garmin_training_hub_migrations.sql e
-- sql/seeds/010_trilha_e_certificacoes.sql (cria os módulos 'produtos-modulo'
-- e 'concorrentes-modulo' referenciados abaixo) já aplicados.
-- ============================================================================

-- ============================================================================
-- MÓDULO 3 - PRODUTOS (slug do módulo: produtos-modulo)
-- ============================================================================

-- Lição 1: Linha Forerunner
insert into lessons (module_id, title, content_type, body, order_index, is_published)
values (
  (select id from modules where slug = 'produtos-modulo'),
  'Linha Forerunner: do iniciante ao elite',
  'text',
  '{"html": "<h3>Sobre este módulo</h3><p>Dominar o portfólio Garmin é saber indicar o produto certo sem hesitar. Este módulo passa por cada linha, seus modelos e para quem cada um serve.</p><h3>Linha Forerunner</h3><p>A linha Forerunner é voltada para corrida, triathlon e fitness, cobrindo do iniciante ao atleta de elite. É a porta de entrada mais natural para quem está começando com GPS esportivo, mas também tem modelos de ponta para quem compete sério.</p><h3>Modelos de entrada</h3><p>No início da linha estão o <strong>Forerunner 70</strong>, modelo novo com GPS, monitor de frequência cardíaca e Garmin Pay, compacto e com até 11 dias de bateria, pensado como porta de entrada com estilo; e o <strong>Forerunner 55</strong>, o clássico da entrada, com GPS, sensor óptico de frequência cardíaca, planos de treino, Body Battery e monitoramento de sono. Os dois são indicados para quem está começando.</p><h3>Modelos intermediários (dedicados)</h3><ul><li><strong>Forerunner 165:</strong> tela AMOLED, planos de treino adaptativos e treino de força. Boa relação custo-benefício com tela premium. Indicado para o perfil iniciante ou dedicado.</li><li><strong>Forerunner 170:</strong> modelo novo, com tela AMOLED e sensor Elevate Gen 4, mais compacto que o 165. Traz relatório noturno, despertador inteligente, registro de estilo de vida e calculadora, além de mais perfis de atividade. Não tem GPS multibanda nem modo triathlon. Indicado para o perfil iniciante ou dedicado.</li><li><strong>Forerunner 265:</strong> tela AMOLED, GPS multibanda e Training Readiness. É o melhor modelo intermediário da linha, indicado para o perfil dedicado.</li><li><strong>Forerunner 570:</strong> lançado em 2025, com tela AMOLED, GPS SatIQ e sensor Elevate Gen 5. Feito para treino intervalado de alta precisão, indicado para dedicado ou elite.</li></ul><h3>Modelos de elite</h3><ul><li><strong>Forerunner 955:</strong> até 30h de GPS, mapas topográficos e solar opcional. É a referência de custo-benefício para triatletas.</li><li><strong>Forerunner 965:</strong> tela AMOLED, caixa em titânio, mapas e até 31h de GPS. É o modelo top de corrida com tela premium.</li><li><strong>Forerunner 970:</strong> cristal de safira, lanterna LED e 32GB de armazenamento. É o topo absoluto da linha Forerunner.</li></ul>"}'::jsonb,
  0,
  true
);

-- Lição 2: Linha Fenix
insert into lessons (module_id, title, content_type, body, order_index, is_published)
values (
  (select id from modules where slug = 'produtos-modulo'),
  'Linha Fenix: multiesporte premium para outdoor',
  'text',
  '{"html": "<h3>Linha Fenix</h3><p>A linha Fenix é o multiesporte premium da Garmin, pensada para quem pratica atividades outdoor, aventura e busca alta performance.</p><ul><li><strong>Fenix E:</strong> modelo novo e entrada da linha Fenix. Tela AMOLED, GPS padrão e mapas TopoActive, com design robusto. Não tem alto-falante, microfone nem GPS multibanda. É a porta de entrada para quem quer um Fenix com orçamento menor.</li><li><strong>Fenix 8 (47mm / 51mm):</strong> o multiesporte definitivo da linha. Tela AMOLED, alto-falante, microfone, modo mergulho de até 10 ATM e mapas completos. A versão 51mm tem opção solar. Indicado para o perfil elite/outdoor.</li><li><strong>Fenix 8 AMOLED Sapphire:</strong> versão top da linha, com cristal de safira para máxima resistência a arranhões e acabamento premium, reunindo todos os recursos do Fenix 8. Indicado para quem busca elite com um toque de luxo esportivo.</li></ul>"}'::jsonb,
  1,
  true
);

-- Lição 3: Linha MARQ (Gen 2)
insert into lessons (module_id, title, content_type, body, order_index, is_published)
values (
  (select id from modules where slug = 'produtos-modulo'),
  'Linha MARQ (Gen 2): relógios de luxo Garmin',
  'text',
  '{"html": "<h3>Linha MARQ (Gen 2)</h3><p>A linha MARQ reúne os relógios de luxo artesanais da Garmin, para quem quer o melhor dos dois mundos: alta performance esportiva e a presença de um relógio premium no pulso.</p><ul><li><strong>MARQ Commander (Gen 2):</strong> caixa em titânio e pulseira em couro italiano, com estética militar sofisticada. Traz GPS multibanda, mapas completos e modo tático. Indicado para quem combina alto desempenho com presença no pulso.</li><li><strong>MARQ Athlete (Gen 2):</strong> focado em corrida e triathlon de alto nível, em titânio com pulseira sport premium. Tem GPS multibanda, métricas avançadas de treino e Training Readiness. Visual sofisticado para atletas que não abrem mão de estilo.</li><li><strong>MARQ Golfer Carbon (Gen 2):</strong> caixa em fibra de carbono com acabamento premium. Traz mapas de mais de 42.000 campos de golfe, modo caddie digital, estatísticas de jogo e distâncias automáticas. É o único relógio de golfe no patamar de luxo real.</li></ul>"}'::jsonb,
  2,
  true
);

-- ============================================================================
-- MÓDULO 4 - CONCORRENTES & OBJEÇÕES (slug do módulo: concorrentes-modulo)
-- ============================================================================

-- Lição 1: A regra de ouro e o Apple Watch
insert into lessons (module_id, title, content_type, body, order_index, is_published)
values (
  (select id from modules where slug = 'concorrentes-modulo'),
  'A regra de ouro e o Apple Watch',
  'text',
  '{"html": "<h3>Entenda o mercado, vença a comparação</h3><p>Cada concorrente tem um público real. Saber para quem cada marca faz sentido e onde o Garmin vence é o que separa um atendimento mediano de um atendimento que fecha venda.</p><h3>A regra antes de tudo</h3><p>Nunca fale mal de concorrente. Quando você ataca outra marca, o cliente pensa: \"será que ele tá me enganando?\". Apresente fatos e deixe o cliente concluir sozinho. Quem conduz com confiança vende mais, não quem grita mais alto.</p><h3>Apple Watch: o mais citado, e o mais mal comparado</h3><p>O Apple Watch é o principal concorrente da Garmin, com público voltado a lifestyle e usuários de iPhone.</p><h3>Para quem o Apple Watch faz sentido</h3><p>O usuário de iPhone que quer uma extensão do celular no pulso, com notificações, Apple Pay, Siri e integração total com o ecossistema Apple, é o público natural do Apple Watch. Também faz sentido para quem tem um perfil de lifestyle urbano, que usa o relógio no dia a dia e não como ferramenta de treino, praticando esporte apenas ocasionalmente, como uma caminhada ou corrida casual. Some a esse grupo quem valoriza praticidade acima de tudo, carregando o relógio toda noite sem se incomodar e sem fazer atividades longas (então a bateria curta não é um problema real para ele), e quem busca um presente de status: um produto premium, reconhecível, de design moderno, para quem já usa iPhone.</p><h3>Onde cada um leva vantagem</h3><p><strong>Garmin vence em:</strong> bateria (de 30h a mais de 70h com GPS ativo, contra 6 a 18h do Apple Watch); autonomia no dia a dia (de 7 a 26 dias, contra 1 a 2 dias); GPS multibanda, mais preciso em mata fechada e em áreas urbanas; compatibilidade com iOS e Android; análise de treino com FirstBeat, em nível profissional; e resistência, com modelos que chegam a 100 metros de profundidade e certificação MIL-STD.</p><p><strong>Apple Watch leva em:</strong> integração total com iPhone e apps Apple; interface mais intuitiva para quem não é atleta; Apple Pay amplamente adotado; e um design reconhecido como símbolo de status social.</p><h3>Objeções mais comuns sobre o Apple Watch</h3><p><strong>\"O Apple Watch faz a mesma coisa.\"</strong> Para uso do dia a dia e notificações, sim, os dois funcionam bem. A diferença aparece quando o cliente vai para a atividade física: o Garmin tem bateria de dias com GPS ligado, enquanto o Apple Watch precisa ser carregado todo dia. Quem corre, pedala ou vai para a trilha sente essa diferença já na primeira semana. Vale perguntar antes: \"você usa mais para esporte ou no dia a dia?\". Assim a resposta fica ainda mais direcionada.</p><p><strong>\"O Apple Watch é mais bonito.\"</strong> O design dele é realmente muito bom. Se o uso for mais social e de dia a dia, pode fazer sentido escolher o Apple Watch. Mas se o cliente pratica esporte com frequência, o Garmin foi construído para isso, e também tem modelos com tela AMOLED bonita, como o Venu 4 ou o Forerunner 265. Vale a pena mostrar como fica no pulso.</p><p><strong>\"Só uso iPhone, o Apple Watch não integra melhor?\"</strong> O Garmin Connect funciona perfeitamente no iPhone, com notificações, chamadas e músicas, e ainda conecta com Strava, TrainingPeaks, Spotify e outros apps que o cliente já usa. O que muda é que, no treino, o Garmin entrega muito mais dados do que o Apple Watch consegue.</p>"}'::jsonb,
  0,
  true
);

-- Lição 2: Polar
insert into lessons (module_id, title, content_type, body, order_index, is_published)
values (
  (select id from modules where slug = 'concorrentes-modulo'),
  'Polar: o rival técnico',
  'text',
  '{"html": "<h3>Polar: o rival técnico</h3><p>A Polar tem tradição em análise de treino e é o concorrente técnico da Garmin, com público de atletas que já têm algum histórico de treino estruturado.</p><h3>Para quem a Polar faz sentido</h3><p>O atleta mais científico, que quer análise profunda de frequência cardíaca e zonas de treino e já está acostumado com o Polar Flow, é o perfil típico. Também se encaixam o corredor ou ciclista dedicado, focado em métricas avançadas e que costuma treinar com coach e precisar exportar dados; o cliente fidelizado à marca, que já teve um Polar antes, está satisfeito com a análise e pode estar comparando antes de comprar a próxima versão; e o usuário do cinto cardíaco Polar H10, considerado o mais preciso do mercado, que busca um relógio compatível com ele.</p><h3>Onde cada um leva vantagem</h3><p><strong>Garmin vence em:</strong> ecossistema Connect IQ, com centenas de apps e mostradores de relógio disponíveis; GPS multibanda já em modelos intermediários; variedade de modalidades, cobrindo corrida, mergulho, golfe, náutica e aviação; mais de 50 integrações, incluindo Strava, Spotify, TrainingPeaks e Garmin Pay; suporte presencial no Brasil via Proparts; e o FirstBeat, que é o padrão de análise de treino em nível profissional.</p><p><strong>Polar leva em:</strong> o cinto H10, que ainda é referência em precisão de frequência cardíaca; o Polar Flow, com boa visualização de dados históricos; e a tradição acadêmica da marca em fisiologia do exercício.</p><h3>Objeções mais comuns sobre a Polar</h3><p><strong>\"Já usei Polar e gostei bastante.\"</strong> Faz sentido, a Polar tem boa tradição em análise de treino. O Garmin seguiu na mesma direção com o FirstBeat, a mesma tecnologia usada por times profissionais, e o ecossistema Connect é bem mais amplo: apps, mostradores de relógio e integrações com tudo que o cliente já usa. Vale convidar para experimentar um Garmin na mão e comparar. Nessa conversa, não force a migração: ouça, reconheça o que a pessoa já gosta e mostre o que o Garmin oferece. Quem decide é o cliente, sua função é informar bem.</p><p><strong>\"A análise de frequência cardíaca da Polar é melhor.\"</strong> O cinto H10 deles é muito bom mesmo, continua sendo referência. Mas o Garmin também tem cintos de peito compatíveis para quem quer máxima precisão, e os sensores de pulso Elevate Gen 5 melhoraram bastante. Para uma análise completa, com zonas de treino, VO2 Max e Training Readiness, o Garmin está no mesmo nível ou acima.</p>"}'::jsonb,
  1,
  true
);

-- Lição 3: Coros
insert into lessons (module_id, title, content_type, body, order_index, is_published)
values (
  (select id from modules where slug = 'concorrentes-modulo'),
  'Coros: o rival de preço',
  'text',
  '{"html": "<h3>Coros: o rival de preço</h3><p>O Coros é uma marca em crescimento no Brasil e costuma aparecer na conversa pelo gatilho do preço. É um argumento fácil de contornar quando você conhece bem os diferenciais do Garmin.</p><h3>Para quem o Coros faz sentido</h3><p>O cliente sensível a preço, que quer funcionalidades avançadas mas tem orçamento limitado, é o público principal: o Coros entrega bastante por um valor menor, e esse é o argumento central da marca. Também se encaixam o corredor de rua ou de trilha, que não precisa de mergulho, golfe ou navegação e quer GPS preciso com métricas de corrida sem pagar por recursos premium que não vai usar; quem está comprando o primeiro relógio esportivo, nunca usou GPS e quer começar sem investir muito, já que a interface do Coros é simples e não assusta iniciantes; e quem é menos apegado a ecossistema, sem muito interesse em apps, mostradores de relógio ou integrações, e quer apenas o básico funcionando bem.</p><h3>Onde cada um leva vantagem</h3><p><strong>Garmin vence em:</strong> mais de 35 anos de mercado, contra uma marca fundada em 2012; ecossistema Connect IQ maduro, com mais de 50 integrações; variedade de modalidades, cobrindo corrida, ciclismo, mergulho, golfe e náutica; FirstBeat, com análise de treino em nível profissional; suporte presencial da Proparts, com garantia oficial no Brasil; e valor de revenda mais alto no mercado.</p><p><strong>Coros leva em:</strong> preço de 30% a 40% menor em modelos equivalentes; boa bateria mesmo nos modelos mais básicos; e interface simples, com curva de aprendizado menor.</p><h3>Objeções mais comuns sobre o Coros</h3><p><strong>\"O Coros é muito mais barato.\"</strong> É verdade que o preço inicial é menor, isso é real, e vale reconhecer isso antes de qualquer coisa. Nunca minimize o argumento de preço do cliente: valide primeiro, depois mostre o valor. A diferença aparece no longo prazo: a Garmin tem mais de 35 anos de algoritmos de treino, suporte presencial aqui na Proparts e um ecossistema muito mais completo. Além disso, o valor de revenda do Garmin é bem maior. Para quem vai usar de verdade, o retorno compensa, e a marca também tem modelos de entrada que encaixam em vários orçamentos.</p><p><strong>\"Vi review dizendo que o Coros é melhor para trilha.\"</strong> O Coros tem bons modelos de trilha, sim, seria desonesto dizer o contrário. Mas o Garmin Instinct 3 e o Fenix 8 foram desenvolvidos com certificação militar MIL-STD-810, altímetro barométrico, bússola e bateria de semanas, e são usados por atletas profissionais de montanha no mundo inteiro. Vale oferecer para mostrar as diferenças técnicas entre os dois.</p>"}'::jsonb,
  2,
  true
);

-- Lição 4: Samsung Galaxy Watch
insert into lessons (module_id, title, content_type, body, order_index, is_published)
values (
  (select id from modules where slug = 'concorrentes-modulo'),
  'Samsung Galaxy Watch: o equivalente Android',
  'text',
  '{"html": "<h3>Samsung Galaxy Watch: o equivalente Android do Apple Watch</h3><p>O Galaxy Watch ocupa no universo Android o mesmo papel que o Apple Watch ocupa no iOS, com foco em ecossistema.</p><h3>Para quem o Galaxy Watch faz sentido</h3><p>O usuário fiel à Samsung, que já tem Galaxy S, talvez um tablet da marca e usa Samsung Pay, quer um relógio que integre perfeitamente com tudo isso. Também se encaixa quem tem um perfil mais de lifestyle e smartwatch, priorizando notificações, pagamentos e aplicativos acima de métricas de treino, já que o esporte é secundário para esse público.</p><h3>Onde cada um leva vantagem</h3><p><strong>Garmin vence em:</strong> bateria de vários dias, contra 1 a 2 dias do Galaxy Watch; análise de treino com FirstBeat, contra métricas mais básicas; GPS preciso, com multibanda nos modelos intermediários; compatibilidade com qualquer Android, não só aparelhos Samsung; e resistência e durabilidade em ambiente outdoor.</p><p><strong>Galaxy Watch leva em:</strong> integração nativa com Samsung DeX e Galaxy AI; design mais parecido com um smartwatch tradicional, esteticamente menos esportivo; e uma integração muito boa com o Samsung Pay.</p><h3>Objeção mais comum sobre o Galaxy Watch</h3><p><strong>\"Tenho Samsung, não seria melhor o Galaxy Watch?\"</strong> O Galaxy Watch é ótimo para quem realmente usa o smartwatch como smartwatch, para notificações, Samsung Pay e esse tipo de recurso. Para treino, o Garmin entrega bem mais: bateria de dias, GPS multibanda e uma análise de performance que o Galaxy Watch não tem. Se o cliente pratica esporte com frequência, o Garmin vale muito mais a pena. Se o uso for mais geral, no dia a dia, o ideal é ajudar a decidir com base no que a pessoa mais usa no relógio.</p>"}'::jsonb,
  3,
  true
);

-- Lição 5: Objeções gerais (não ligadas a nenhuma marca específica)
insert into lessons (module_id, title, content_type, body, order_index, is_published)
values (
  (select id from modules where slug = 'concorrentes-modulo'),
  'Objeções gerais que aparecem em qualquer venda',
  'text',
  '{"html": "<h3>Objeções que aparecem em qualquer venda</h3><p>Além das comparações com marcas específicas, algumas objeções aparecem o tempo todo, independente do concorrente que o cliente está pensando. Vale ter uma resposta pronta para cada uma delas.</p><p><strong>\"Tá caro, vou pesquisar online.\"</strong> Faz sentido comparar, é um investimento. Aqui na Proparts o cliente tem garantia de 2 anos com assistência técnica oficial, pode experimentar o relógio na hora e sair com ele já configurado no seu nome. Comprando online, qualquer problema vira um processo bem mais trabalhoso. Esse suporte presencial tem valor real, e vale destacar isso. Nunca diga que comprar online é golpe ou que o produto pode ser falso: o caminho é mostrar o valor do que você oferece, não inventar um risco que não existe.</p><p><strong>\"Vou pensar e volto depois.\"</strong> Não tem problema nenhum. O importante é garantir que o cliente saia com tudo que precisa para decidir bem. Vale perguntar se pode anotar o modelo conversado e deixar o WhatsApp disponível para tirar dúvidas na hora de comparar especificações. O cliente que diz \"vou pensar\" muitas vezes só precisa de mais segurança, então manter o canal aberto costuma funcionar melhor do que insistir na hora.</p><p><strong>\"Não sei se vou usar mesmo.\"</strong> Essa dúvida é honesta e comum. O que costuma acontecer com quem compra é que o relógio motiva mais do que a pessoa imaginava: ver os dados no pulso muda o hábito. Para não errar na indicação, vale perguntar sobre a rotina da pessoa, se ela pratica alguma atividade hoje, para indicar o que realmente faz sentido para o estilo de vida dela.</p><p><strong>\"Nunca usei smartwatch, acho complicado.\"</strong> A maioria das pessoas fala exatamente isso antes de usar, e depois conta que é a coisa mais simples que já usaram. O Garmin Connect é bem intuitivo, e o ideal é configurar tudo junto com o cliente antes de ele sair da loja. Se surgir qualquer dúvida depois, o WhatsApp resolve.</p>"}'::jsonb,
  4,
  true
);
