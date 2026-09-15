-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 119: Revisão editorial dos Perfis de Cliente
-- ============================================================================
-- Pedido do usuário (2026-09-15): texto original dos 11 perfis (sql/seeds/040)
-- passado por revisão editorial antes de entrar na nova ficha de consulta
-- rápida (LibraryContent.js/renderPerfis). Troca tag/tags/sinais/comunicacao
-- por versões revisadas, atualiza a pergunta-chave (sql/118) com a redação
-- final, e em dois perfis também o nome:
--   - "Atleta de Elite / Triatleta" -> "Atleta de Alto Desempenho / Triatleta"
--   - "Mulher Lifestyle" -> "Cliente Lifestyle" (descrição deixa de presumir
--     gênero do cliente)
-- Corredor Iniciante também troca a recomendação principal de Forerunner 55
-- para Forerunner 70 (lançamento 2026, já cadastrado no catálogo de produtos
-- — sql/seeds/040 categoria 'produto') e ganha Forerunner 170 como 2ª
-- alternativa.
--
-- `payload || jsonb_build_object(...)` faz merge raso: só as chaves listadas
-- abaixo são substituídas, tudo o resto do payload (emoji, objections)
-- continua exatamente como estava. slugs não mudam mesmo nos 2 perfis
-- renomeados — nada mais no código referencia esses slugs além do nome.
-- ============================================================================

update content_library set
  title = 'Corredor Iniciante',
  summary = 'Está começando a correr ou voltando ao esporte',
  payload = payload || jsonb_build_object(
    'name', 'Corredor Iniciante',
    'tag', 'Está começando a correr ou voltando ao esporte',
    'tags', jsonb_build_array('Corrida', 'Iniciante', 'GPS'),
    'sinais', jsonb_build_array(
      'Nunca teve um relógio para corrida',
      'Diz que está começando a correr',
      'Procura um modelo simples',
      'Quer saber distância, tempo e ritmo'
    ),
    'pergunta_chave', 'Você já usa algum relógio para treinar ou seria o primeiro?',
    'primario', 'Forerunner 70',
    'produtos', jsonb_build_array('Forerunner 70', 'Forerunner 165', 'Forerunner 170'),
    'comunicacao', jsonb_build_array(
      'Forerunner 70: opção simples para quem está entrando no universo da corrida',
      'Forerunner 165: para quem quer uma experiência mais completa e uma tela AMOLED',
      'Forerunner 170: alternativa para quem busca mais recursos desde o início',
      'Mostre os planos de treino adaptativos, que ajudam a organizar os treinos de acordo com o nível da pessoa',
      'Mostre como o relógio sincroniza com o celular para acompanhar as atividades'
    )
  ),
  updated_at = now()
where category = 'perfil_cliente' and slug = 'corredor-iniciante';

update content_library set
  summary = 'Corre com frequência e quer evoluir',
  payload = payload || jsonb_build_object(
    'tag', 'Corre com frequência e quer evoluir',
    'tags', jsonb_build_array('Corrida', 'Intermediário', 'Métricas'),
    'sinais', jsonb_build_array(
      'Já usa ou já usou relógio com GPS',
      'Corre várias vezes por semana',
      'Fala sobre ritmo, treinos ou provas',
      'Quer entender melhor seu desempenho',
      'Pergunta sobre precisão e métricas'
    ),
    'pergunta_chave', 'Com que frequência você corre e já usa algum relógio com GPS hoje?',
    'comunicacao', jsonb_build_array(
      'Forerunner 265: para quem quer evoluir na corrida e acompanhar mais informações',
      'Forerunner 570: para quem busca recursos ainda mais avançados',
      'Forerunner 965: opção para quem quer uma experiência mais completa',
      'Mostre como o relógio ajuda a entender se o corpo está preparado para determinado treino',
      'Apresente recursos que ajudam a planejar ritmo e estratégia para provas',
      'Mostre a integração com aplicativos de treino que o cliente já pode utilizar, como Strava e TrainingPeaks'
    )
  ),
  updated_at = now()
where category = 'perfil_cliente' and slug = 'corredor-dedicado';

update content_library set
  title = 'Atleta de Alto Desempenho / Triatleta',
  summary = 'Treina muito e participa de provas',
  payload = payload || jsonb_build_object(
    'name', 'Atleta de Alto Desempenho / Triatleta',
    'tag', 'Treina muito e participa de provas',
    'tags', jsonb_build_array('Corrida', 'Triathlon', 'Natação', 'Ciclismo', 'Performance'),
    'sinais', jsonb_build_array(
      'Fala sobre triathlon, Ironman, maratona ou ultramaratona',
      'Treina várias horas por semana',
      'Já possui um relógio e está procurando um upgrade',
      'Se preocupa com bateria e precisão',
      'Quer acompanhar diferentes esportes no mesmo dispositivo'
    ),
    'pergunta_chave', 'Você compete ou está treinando para alguma prova específica?',
    'comunicacao', jsonb_build_array(
      'Forerunner 970: para quem busca o máximo de recursos para corrida e triathlon',
      'Forerunner 955 e 965: alternativas para quem quer recursos avançados de treinamento',
      'Fenix 8: para quem também pratica atividades outdoor e busca um relógio mais versátil',
      'Destaque a bateria para treinos longos',
      'Mostre os recursos de treinamento, recuperação e acompanhamento de desempenho',
      'Para triatletas, explique que o relógio acompanha diferentes modalidades em um único dispositivo'
    )
  ),
  updated_at = now()
where category = 'perfil_cliente' and slug = 'atleta-de-elite-triatleta';

update content_library set
  summary = 'Gosta de trilhas, montanhas e atividades ao ar livre',
  payload = payload || jsonb_build_object(
    'tag', 'Gosta de trilhas, montanhas e atividades ao ar livre',
    'sinais', jsonb_build_array(
      'Fala sobre trilhas, montanhas ou viagens',
      'Pergunta sobre mapas e navegação',
      'Procura resistência e longa duração de bateria',
      'Faz camping, trekking ou expedições',
      'Pode praticar esportes além da corrida'
    ),
    'pergunta_chave', 'Você costuma fazer trilhas ou atividades em lugares onde pode ficar sem sinal de celular?',
    'comunicacao', jsonb_build_array(
      'Instinct 3: para quem prioriza resistência, aventura e praticidade',
      'Fenix 8: para quem quer combinar recursos outdoor com uma experiência mais sofisticada',
      'Enduro 3: para quem coloca bateria de longa duração entre as principais prioridades',
      'Mostre os recursos de navegação e mapas',
      'Explique que o relógio pode ajudar o usuário a se orientar mesmo longe do celular',
      'Destaque resistência e autonomia para atividades mais longas'
    )
  ),
  updated_at = now()
where category = 'perfil_cliente' and slug = 'aventureiro-trilheiro';

update content_library set
  title = 'Cliente Lifestyle',
  summary = 'Quer um relógio elegante para o dia a dia',
  payload = payload || jsonb_build_object(
    'name', 'Cliente Lifestyle',
    'tag', 'Quer um relógio elegante para o dia a dia',
    'tags', jsonb_build_array('Lifestyle', 'Design', 'Saúde', 'Presente'),
    'sinais', jsonb_build_array(
      'Procura um relógio menor ou mais discreto',
      'Compara o relógio com smartwatches tradicionais',
      'Dá importância ao design',
      'Quer acompanhar saúde e bem-estar',
      'Pode estar procurando um presente'
    ),
    'pergunta_chave', 'Você procura algo mais discreto para o dia a dia ou também quer usar para atividades físicas?',
    'comunicacao', jsonb_build_array(
      'Lily 2: para quem prioriza tamanho compacto e estilo',
      'Lily 2 Active: para quem quer manter o visual delicado e também ter recursos para atividades físicas',
      'Venu 4: para quem prefere uma tela maior e uma experiência mais completa',
      'Mostre os recursos de saúde e bem-estar',
      'Explique que o relógio acompanha a rotina durante o dia e também os treinos',
      'Para clientes interessados, apresente os recursos voltados à saúde feminina'
    )
  ),
  updated_at = now()
where category = 'perfil_cliente' and slug = 'mulher-lifestyle';

update content_library set
  summary = 'Pedala com frequência e quer acompanhar o desempenho',
  payload = payload || jsonb_build_object(
    'tag', 'Pedala com frequência e quer acompanhar o desempenho',
    'sinais', jsonb_build_array(
      'Fala sobre bike, mountain bike, estrada ou gravel',
      'Procura um equipamento para colocar no guidão',
      'Usa ou conhece o Strava',
      'Fala sobre rotas, subidas ou desempenho',
      'Tem interesse em medir velocidade, cadência ou potência'
    ),
    'pergunta_chave', 'Você pedala mais por lazer ou treina pensando em desempenho?',
    'comunicacao', jsonb_build_array(
      'Edge: computadores específicos para acompanhar o pedal diretamente no guidão',
      'Varia: acessórios que aumentam a segurança e ajudam o ciclista a perceber veículos se aproximando',
      'Rally: pedais que permitem medir a potência produzida durante o pedal',
      'Pergunte primeiro o tipo de ciclismo e o nível de experiência',
      'Depois identifique se a prioridade é navegação, segurança ou desempenho'
    )
  ),
  updated_at = now()
where category = 'perfil_cliente' and slug = 'ciclista';

update content_library set
  summary = 'Nada com frequência ou está treinando para triathlon',
  payload = payload || jsonb_build_object(
    'tag', 'Nada com frequência ou está treinando para triathlon',
    'sinais', jsonb_build_array(
      'Fala sobre natação em piscina ou mar',
      'Pergunta sobre treinos na água',
      'Quer acompanhar distância, tempo e número de braçadas',
      'Está treinando para triathlon',
      'Quer acompanhar evolução da técnica'
    ),
    'pergunta_chave', 'Você nada com frequência ou está treinando para alguma prova?',
    'comunicacao', jsonb_build_array(
      'Mostre que os relógios Garmin conseguem acompanhar informações específicas da natação',
      'Para triatletas, destaque a possibilidade de acompanhar natação, ciclismo e corrida',
      'HRM 600: cinta cardíaca para quem precisa de informações de frequência cardíaca mais completas durante os treinos',
      'Explique que as métricas ajudam o atleta a acompanhar sua evolução ao longo do tempo'
    )
  ),
  updated_at = now()
where category = 'perfil_cliente' and slug = 'nadador-triatleta';

update content_library set
  payload = payload || jsonb_build_object(
    'sinais', jsonb_build_array(
      'Fala sobre mergulho',
      'Pergunta sobre profundidade e tempo de mergulho',
      'Já usa ou procura um computador de mergulho',
      'Fala sobre diferentes tipos de gases ou mergulho técnico'
    ),
    'pergunta_chave', 'Você já mergulha? Usa algum computador de mergulho hoje?',
    'comunicacao', jsonb_build_array(
      'Descent: linha Garmin desenvolvida especificamente para mergulho',
      'Explique que esses equipamentos acompanham informações importantes durante o mergulho',
      'Existem opções para diferentes níveis e necessidades de mergulho',
      'Depois do mergulho, o equipamento também pode ser usado no dia a dia, dependendo do modelo',
      'Atenção: não entre em explicações técnicas sobre descompressão ou gases se o cliente não demonstrar esse nível de conhecimento — primeiro entenda qual tipo de mergulho ele pratica'
    )
  ),
  updated_at = now()
where category = 'perfil_cliente' and slug = 'mergulhador';

update content_library set
  summary = 'Joga golfe e quer melhorar seu jogo',
  payload = payload || jsonb_build_object(
    'tag', 'Joga golfe e quer melhorar seu jogo',
    'sinais', jsonb_build_array(
      'Fala sobre campo, tacadas ou handicap',
      'Pergunta sobre distância até o green',
      'Procura equipamentos específicos para golfe',
      'Quer acompanhar o desempenho durante a partida'
    ),
    'comunicacao', jsonb_build_array(
      'Explique que os relógios Approach são desenvolvidos especificamente para golfe',
      'Mostre como o relógio ajuda a saber a distância até diferentes pontos do campo',
      'Apresente os recursos para registrar a partida e acompanhar o desempenho',
      'Destaque a praticidade de ter essas informações no pulso durante o jogo'
    )
  ),
  updated_at = now()
where category = 'perfil_cliente' and slug = 'golfista';

update content_library set
  summary = 'Viaja de moto e precisa de navegação',
  payload = payload || jsonb_build_object(
    'tag', 'Viaja de moto e precisa de navegação',
    'sinais', jsonb_build_array(
      'Fala sobre viagens de moto',
      'Pergunta sobre rotas e navegação',
      'Procura um GPS para instalar na motocicleta',
      'Preocupa-se com visibilidade e facilidade de uso durante a pilotagem'
    ),
    'pergunta_chave', 'Você costuma fazer viagens longas de moto ou usa mais no dia a dia?',
    'comunicacao', jsonb_build_array(
      'Explique que o Zumo XT2 é um GPS desenvolvido especificamente para motociclistas',
      'A tela foi pensada para facilitar a visualização durante a pilotagem',
      'Mostre os recursos de planejamento de rotas',
      'Explique que ele pode ser integrado a acessórios e comunicadores usados pelo motociclista',
      'Pergunte primeiro como e onde o cliente costuma viajar antes de apresentar os recursos'
    )
  ),
  updated_at = now()
where category = 'perfil_cliente' and slug = 'motociclista';

update content_library set
  summary = 'Pesca e navegação em rios, represas ou mar',
  payload = payload || jsonb_build_object(
    'tag', 'Pesca e navegação em rios, represas ou mar',
    'sinais', jsonb_build_array(
      'Fala sobre pesca esportiva ou recreativa',
      'Pesca em rio, represa ou mar',
      'Possui ou utiliza barco',
      'Pergunta sobre sonar, mapas ou navegação'
    ),
    'pergunta_chave', 'Você costuma pescar onde: rio, represa ou mar? Usa barco?',
    'comunicacao', jsonb_build_array(
      'Striker: equipamentos voltados principalmente para quem quer localizar e visualizar informações abaixo da água',
      'ECHOMAP: opção para quem busca uma solução mais completa para navegação e pesca',
      'GPSMAP: equipamentos voltados para navegação, especialmente em atividades outdoor e náuticas',
      'Explique primeiro a diferença entre sonar, que ajuda a visualizar o que está abaixo da embarcação, e GPS, que ajuda na localização e navegação',
      'Depois entenda se o cliente busca principalmente pesca, navegação ou os dois'
    )
  ),
  updated_at = now()
where category = 'perfil_cliente' and slug = 'pescador-nautico';

-- ============================================================================
-- FIM DA MIGRAÇÃO 119
-- ============================================================================
