-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 078: Academia de Produtos — Striker 4,
-- Striker Vivid 5cv e ECHOMAP UHD2 52cv (linha Pesca & Náutica)
-- ============================================================================
-- Pedido do usuário (2026-07-21): "...incluindo o striker 4, striker vivid
-- 5cv e echomap uhd 52cv" — primeira leva de produtos náuticos/pesca, fora
-- do universo de relógios. Categoria nova "Pesca & Náutica".
--
-- CORREÇÃO IMPORTANTE (o usuário pediu cuidado redobrado depois de um erro
-- anterior no Venu 4): o produto pedido como "ECHOMAP UHD 52cv" não existe
-- como esse nome exato — pesquisa confirmou que a linha ECHOMAP UHD
-- ORIGINAL (2019) só veio em 6", 7" e 9" (nunca 5"). O tamanho 5" ("52cv")
-- só passou a existir na geração seguinte, ECHOMAP UHD2 (lançada em
-- 03/05/2022, press release confirma "a newly introduced 5-inch keyed
-- combo unit"). Por isso o produto criado aqui é "ECHOMAP UHD2 52cv" —
-- o nome real do aparelho de 5" que a Garmin vende — não a sigla exata que
-- o usuário digitou, mas o produto real correspondente ao "52cv" pedido.
--
-- Striker 4 (2016) é o modelo ORIGINAL/fundador da linha Striker — não tem
-- um "Striker 3" ou antecessor numerado pra comparar. Por isso não recebe
-- aba "O que há de novo?" (schema já suporta produto sem essa seção, mesmo
-- tratamento usado quando uma seção ainda não tem conteúdo).
--
-- FONTES — só oficiais (garmin.com, manuais do proprietário):
--   - Striker 4: garmin.com/en-US/p/528812/ (página oficial do produto)
--   - Striker Plus 5cv (predecessor do Vivid): garmin.com/en-IE/p/592101/
--   - Striker Vivid 5cv: garmin.com/en-US/p/738993/ + manual oficial
--     www8.garmin.com/manuals/webhelp/GUID-C3C9935A-.../GUID-D1D8C086-...
--   - ECHOMAP UHD (2019, geração original): garmin.com/en-US/newsroom/
--     press-release/marine/2019-garmin-introduces-echomap-uhd-series-
--     with-best-in-class-sonar/
--   - ECHOMAP UHD2 (03/05/2022): garmin.com/en-US/newsroom/press-release/
--     marine/garmin-introduces-echomap-uhd2-chartplotter-series-with-
--     brand-new-hardware-and-modern-features/
--
-- Sem preços em US$ (padrão já adotado nesta sessão).
-- ============================================================================

do $$
declare
  v_brand_id   uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_id     uuid;
  v_p_striker4 uuid;
  v_p_vivid5cv uuid;
  v_p_echomap  uuid;
  v_quiz       uuid;
  v_q          uuid;
begin
  insert into product_categories (brand_id, slug, name, icon, order_index)
  values (v_brand_id, 'pesca-nautica', 'Pesca & Náutica', '🎣', 5)
  returning id into v_cat_id;

  -- ==========================================================================
  -- 1. Produtos
  -- ==========================================================================
  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index)
  values (v_brand_id, v_cat_id, 'striker-4', 'Striker 4', '010-01550', 'Sonar/GPS de pesca de entrada, com CHIRP e tela de 3,5"', true, 1)
  returning id into v_p_striker4;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index)
  values (v_brand_id, v_cat_id, 'striker-vivid-5cv', 'Striker Vivid 5cv', '010-02551', 'Sonar/GPS de pesca com paletas de cor Vivid de alto contraste', true, 2)
  returning id into v_p_vivid5cv;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index)
  values (v_brand_id, v_cat_id, 'echomap-uhd2-52cv', 'ECHOMAP UHD2 52cv', '010-02589', 'Chartplotter + sonar de 5" com cartografia integrada e Wi-Fi', true, 3)
  returning id into v_p_echomap;

  -- ==========================================================================
  -- 2. STRIKER 4 — seções completas (sem aba de novidades — é o modelo
  --    fundador da linha, não tem antecessor numerado)
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_striker4, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Striker 4</strong> é o sonar/GPS de pesca de entrada da Garmin, no mercado desde 2016 — o modelo fundador de toda a linha Striker, ainda vendido hoje pelo custo-benefício.</p><p><strong>Público-alvo:</strong> pescador que quer o primeiro sonar com GPS, sem gastar muito — barco pequeno, caiaque ou início na pesca com eletrônicos.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela de 3,5\"", "text": "Tela colorida compacta, fácil de instalar em qualquer embarcação pequena.", "tags": []},
      {"title": "Sonar CHIRP 77/200 kHz", "text": "Imagens nítidas de peixe e fundo, com boa separação de alvos.", "tags": []},
      {"title": "GPS de alta sensibilidade", "text": "Marca e volta pros pontos de pesca favoritos.", "tags": []},
      {"title": "Profundidade até 490m", "text": "Alcance de até 1.600 pés (490m) em água doce.", "tags": []},
      {"title": "Resistência IPX7", "text": "Suporta respingos e imersão acidental de até 1 metro por 30 minutos.", "tags": []},
      {"title": "Flasher integrado", "text": "Modo flasher pra pesca no gelo/vertical.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_striker4, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Pescador iniciante em eletrônicos", "text": "Primeira vez comprando um sonar/GPS — quer simplicidade e preço baixo.", "tags": [{"label": "Iniciante", "color": "blue"}]},
      {"title": "Dono de caiaque ou barco pequeno", "text": "Precisa de um aparelho compacto que caiba em qualquer embarcação.", "tags": [{"label": "Compacto", "color": "green"}]},
      {"title": "Cliente com orçamento apertado", "text": "Quer sonar com GPS pelo menor investimento da loja.", "tags": [{"label": "Custo-benefício", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer o menor investimento pra ter sonar + GPS de verdade</li><li>Cliente tem caiaque, barco pequeno ou vai usar de forma portátil</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer cartografia/navegação completa (mapas de lago, cartas náuticas) → indicar o ECHOMAP UHD2 52cv</li><li>Cliente quer imagem de sonar de altíssima definição (ClearVü) → o Striker Vivid 5cv é mais indicado</li></ul>"}
  ]}
  $j$),
  (v_p_striker4, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Sonar CHIRP tradicional", "html": "<p>Frequências 77/200 kHz, com potência de transmissão de 200W RMS (1.600W pico a pico) — imagens nítidas de arcos de peixe e boa separação de alvos.</p>"},
      {"title": "GPS de alta sensibilidade", "html": "<p>Marca e volta pros pontos de pesca favoritos, sem depender de referência visual.</p>"},
      {"title": "Smooth Scaling", "html": "<p>Gráficos contínuos ao trocar a escala de profundidade, sem interrupção na imagem do sonar.</p>"},
      {"title": "Sonar History Rewind", "html": "<p>Volta no histórico de imagens do sonar pra marcar waypoints que passaram despercebidos na hora.</p>"},
      {"title": "Flasher integrado", "html": "<p>Modo flasher embutido, útil pra pesca vertical/no gelo.</p>"},
      {"title": "Exibição de velocidade", "html": "<p>Mostra a velocidade da embarcação direto na tela.</p>"},
      {"title": "Resistência IPX7", "html": "<p>Protegido contra respingos e imersão acidental de até 1 metro por até 30 minutos.</p>"}
    ]}
  ]}
  $j$),
  (v_p_striker4, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo primeiro sonar", "dialog": "Se essa é a sua primeira vez com sonar e GPS de pesca, o Striker 4 é a porta de entrada — simples de instalar e usar, com o essencial pra você começar a marcar seus pontos.", "tip": "Não empurre recursos avançados (cartografia, ClearVü) — o cliente do Striker 4 quer simplicidade."},
      {"title": "Puxando o GPS como diferencial real", "dialog": "Com o GPS de alta sensibilidade, você marca o ponto exato onde pescou bem e volta lá quando quiser — isso sozinho já muda o jogo pra quem nunca teve um aparelho assim.", "tip": "Bom argumento pra quem só usava sonar sem GPS antes."},
      {"title": "Fechamento", "dialog": "Com o Striker 4 você sai hoje com sonar CHIRP, GPS e uma tela compacta que cabe em qualquer barco ou caiaque, pelo menor investimento da linha.", "tip": "Pergunte sobre o tipo de embarcação antes de fechar — ajuda a confirmar que o tamanho da tela atende."}
    ]}
  ]}
  $j$),
  (v_p_striker4, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "A tela não é pequena demais?", "answer": "Pra quem tá começando ou usa embarcação pequena, 3,5\" é suficiente pra ver arcos de peixe e profundidade com clareza. Se o cliente quer mais espaço de tela, o Striker Vivid 5cv é o próximo degrau."},
      {"question": "Não tem mapa de lago/carta náutica?", "answer": "Não — o Striker 4 é focado em sonar + GPS de waypoints, sem cartografia. Pra navegação com mapas, o ECHOMAP UHD2 52cv é o produto certo."},
      {"question": "Vale a pena mesmo sendo um modelo de 2016?", "answer": "Sim — ele continua sendo vendido justamente porque entrega o essencial (CHIRP + GPS) de forma confiável e num preço muito competitivo. Não é obsoleto, é o ponto de entrada intencional da linha."}
    ]}
  ]}
  $j$),
  (v_p_striker4, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Cliente com caiaque de pesca", "text": "Precisa de um aparelho compacto e barato que caiba na embarcação pequena.", "tags": []},
      {"title": "Pai comprando pro filho iniciante", "text": "Quer que o filho aprenda a usar sonar/GPS sem investir muito de cara.", "tags": []},
      {"title": "Cliente pescando de gelo no inverno", "text": "O modo flasher integrado atende bem esse uso específico.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_striker4, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "O Striker 4 tem mapas pré-carregados?", "html": "<p>Não — é focado em sonar e GPS de waypoints, sem cartografia de lago/carta náutica.</p>"},
      {"title": "Qual a profundidade máxima de leitura?", "html": "<p>Até 490 metros (1.600 pés) em água doce, dependendo das condições.</p>"},
      {"title": "É resistente à água?", "html": "<p>Sim, classificação IPX7 — resiste a respingos e imersão acidental de até 1 metro por 30 minutos.</p>"},
      {"title": "Qual a diferença pro Striker Vivid 5cv?", "html": "<p>O Vivid tem tela maior (5\"), sonar ClearVü de varredura (imagem quase fotográfica), paletas de cor de alto contraste e Wi-Fi — recursos que o Striker 4 não tem.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 3. STRIKER VIVID 5CV — seções completas
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_vivid5cv, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Striker Vivid 5cv</strong> é o sonar/GPS de pesca com as novas paletas de cor \"Vivid\" da Garmin — maior contraste pra identificar peixe e estrutura com mais clareza.</p><p><strong>Público-alvo:</strong> pescador que já tem alguma experiência e quer sonar de varredura (ClearVü) com uma tela maior, sem pagar por cartografia completa.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela de 5\" WVGA", "text": "800x480 px, maior que o Striker 4.", "tags": []},
      {"title": "7 paletas de cor Vivid", "text": "Alto contraste pra identificar peixe e estrutura com mais clareza.", "tags": []},
      {"title": "CHIRP + ClearVü", "text": "Sonar tradicional (77/200 kHz) e varredura de alta definição (455/800 kHz).", "tags": []},
      {"title": "Garmin Quickdraw Contours", "text": "Cria e armazena até 2 milhões de acres de mapas de profundidade com contornos de 1 pé.", "tags": []},
      {"title": "Wi-Fi integrado", "text": "Conecta com o app ActiveCaptain.", "tags": []},
      {"title": "Transdutor GT20-TM incluso", "text": "2 em 1: sonar tradicional CHIRP + ClearVü no mesmo transdutor.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_vivid5cv, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Pescador que quer ver mais detalhe", "text": "Já usa sonar básico e quer o salto pro ClearVü de varredura.", "tags": [{"label": "Intermediário", "color": "blue"}]},
      {"title": "Quem cria os próprios mapas de pesca", "text": "Valoriza o Quickdraw Contours pra mapear os próprios spots.", "tags": [{"label": "Mapeamento", "color": "green"}]},
      {"title": "Quem quer conectividade", "text": "Usa o Wi-Fi/ActiveCaptain pra atualizar e compartilhar dados.", "tags": [{"label": "Conectado", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer sonar de varredura (ClearVü) com tela maior que o Striker 4</li><li>Cliente quer criar seus próprios mapas de profundidade (Quickdraw Contours)</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer cartografia pronta (cartas náuticas, mapas de lago prontos) → o ECHOMAP UHD2 52cv já vem com isso</li><li>Cliente quer o menor preço possível → o Striker 4 é mais em conta</li></ul>"}
  ]}
  $j$),
  (v_p_vivid5cv, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Paletas de cor Vivid", "html": "<p>7 novas opções de cor com contraste máximo pra identificar peixe e estrutura — a principal novidade que dá nome à linha.</p>"},
      {"title": "Sonar CHIRP + ClearVü", "html": "<p>CHIRP tradicional 77/200 kHz e ClearVü de varredura 455/800 kHz, com potência de 500W RMS — profundidade de até 700m em água doce / 335m em água salgada.</p>"},
      {"title": "Garmin Quickdraw Contours", "html": "<p>Cria e armazena até 2 milhões de acres de mapas próprios de profundidade, com contornos de 1 pé.</p>"},
      {"title": "Wi-Fi + ActiveCaptain", "html": "<p>Conectividade sem fio integrada pra atualizações e compartilhamento com o app ActiveCaptain.</p>"},
      {"title": "Transdutor GT20-TM 2 em 1", "html": "<p>Incluso de fábrica, entrega sonar tradicional CHIRP e ClearVü no mesmo transdutor.</p>"},
      {"title": "GPS de alta sensibilidade", "html": "<p>Marca e volta pros pontos de pesca favoritos.</p>"},
      {"title": "Resistência IPX7", "html": "<p>Protegido contra respingos e imersão acidental de até 1 metro por até 30 minutos.</p>"}
    ]}
  ]}
  $j$),
  (v_p_vivid5cv, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Striker Plus 5cv</strong>, o modelo direto que o Vivid substitui no tamanho de 5\"."},
    {"type": "accordion", "items": [
      {"title": "Paletas de cor Vivid", "html": "<p>A principal novidade — 7 opções de cor com contraste muito maior. O Striker Plus 5cv usava a paleta de cores padrão, sem essa tecnologia.</p>"},
      {"title": "Transdutor atualizado", "html": "<p>O Vivid recebeu uma atualização significativa de transdutor em relação à geração Plus, melhorando a qualidade da imagem do sonar.</p>"},
      {"title": "Wi-Fi confirmado no manual oficial", "html": "<p>O Striker Vivid 5cv tem Wi-Fi integrado (2,4 GHz) — recurso que não era destaque no Striker Plus 5cv.</p>"},
      {"title": "O que NÃO mudou (continua igual ao Plus)", "html": "<p>Sonar CHIRP 77/200 kHz + ClearVü 455/800 kHz, potência de 500W, transdutor GT20-TM, Quickdraw Contours, tela de 5\" WVGA 800x480 e resistência IPX7 — tudo isso já vinha do Striker Plus 5cv.</p>"}
    ]}
  ]}
  $j$),
  (v_p_vivid5cv, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela clareza da imagem", "dialog": "Se você já usou sonar antes e sentiu dificuldade de diferenciar peixe de estrutura na tela, o Striker Vivid resolve isso — as paletas de cor Vivid dão um contraste muito maior.", "tip": "Bom argumento pra quem já reclamou de \"não conseguir ler a tela direito\" em outro aparelho."},
      {"title": "Puxando o Quickdraw Contours", "dialog": "Você pode criar seu próprio mapa de profundidade dos seus spots preferidos, com contornos de até 1 pé — ninguém mais vai ter esse mapa, só você.", "tip": "Ótimo argumento pra quem pesca sempre nos mesmos lugares."},
      {"title": "Fechamento", "dialog": "Com o Striker Vivid 5cv você sai com sonar CHIRP + ClearVü, tela de 5\" com cores de alto contraste, Wi-Fi e a possibilidade de criar seus próprios mapas.", "tip": "Pergunte se o cliente já usa o app ActiveCaptain antes de destacar o Wi-Fi."}
    ]}
  ]}
  $j$),
  (v_p_vivid5cv, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Vale a pena sobre o Striker 4?", "answer": "Vale se o cliente quer sonar de varredura (ClearVü), tela maior e as cores de alto contraste Vivid — recursos que o Striker 4 não tem."},
      {"question": "Por que não o ECHOMAP UHD2 52cv?", "answer": "Se o cliente não precisa de cartografia pronta (cartas náuticas/mapas de lago) e só quer sonar + GPS de qualidade, o Striker Vivid entrega isso por um investimento menor."},
      {"question": "O Wi-Fi serve pra quê na prática?", "answer": "Conecta com o app ActiveCaptain pra atualizações de software e, dependendo do uso, compartilhamento de dados — não é essencial, mas é um diferencial de conveniência."}
    ]}
  ]}
  $j$),
  (v_p_vivid5cv, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Pescador que sobe do Striker 4", "text": "Quer o salto pra ClearVü e tela maior, sem ir direto pro topo de linha.", "tags": []},
      {"title": "Cliente que pesca sempre no mesmo lago", "text": "Quer criar o próprio mapa de profundidade com o Quickdraw Contours.", "tags": []},
      {"title": "Cliente com dificuldade de leitura de tela", "text": "As paletas Vivid resolvem problemas de contraste em sonares mais antigos.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_vivid5cv, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "O que são as paletas Vivid?", "html": "<p>7 opções de cor desenvolvidas pra dar o máximo de contraste entre peixe, estrutura e fundo na tela do sonar.</p>"},
      {"title": "Tem cartografia (mapa de lago/carta náutica)?", "html": "<p>Não vem pré-carregado — mas o Quickdraw Contours permite criar mapas próprios de profundidade.</p>"},
      {"title": "Qual a profundidade máxima?", "html": "<p>Até 700 metros em água doce / 335 metros em água salgada, dependendo das condições.</p>"},
      {"title": "Tem Wi-Fi?", "html": "<p>Sim, confirmado no manual oficial (2,4 GHz), pra conectar com o app ActiveCaptain.</p>"},
      {"title": "Qual a diferença real pro ECHOMAP UHD2 52cv?", "html": "<p>O ECHOMAP vem com cartografia pronta (BlueChart/LakeVü/Navionics), suporte a cartão SD e recursos de chartplotter completo — o Striker Vivid foca só em sonar + GPS de waypoints, sem navegação por mapas prontos.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 4. ECHOMAP UHD2 52cv — seções completas
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_echomap, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>ECHOMAP UHD2 52cv</strong> é o chartplotter + sonar de 5\" da Garmin, lançado em 3 de maio de 2022 — a geração UHD2 introduziu o tamanho de 5\" pela primeira vez na linha UHD (a geração original, de 2019, só vinha em 6\", 7\" e 9\").</p><p><strong>Público-alvo:</strong> pescador/navegador que quer sonar de alta definição JUNTO com cartografia completa (mapas de lago ou cartas náuticas) — não só sonar avulso.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela de 5\" com interface por botões", "text": "Modelo \"keyed\" (controle físico), resistente ao sol.", "tags": []},
      {"title": "Sonar de 500W: CHIRP + ClearVü", "text": "CHIRP tradicional 70/83/200 kHz e ClearVü 260/455/800 kHz.", "tags": []},
      {"title": "Cartografia integrada", "text": "BlueChart g3 (costa) ou LakeVü g3 (interior) pré-carregados, com dados Navionics.", "tags": []},
      {"title": "Wi-Fi entre 2 unidades", "text": "Compartilha sonar e dados entre dois ECHOMAP UHD2 a bordo.", "tags": []},
      {"title": "GPS/GLONASS de 5 Hz", "text": "Atualização de posição até 5x mais rápida que antenas comuns de 1 Hz.", "tags": []},
      {"title": "Cartão SD até 32 GB", "text": "Armazena até 5.000 waypoints.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_echomap, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Quem quer sonar + navegação num só aparelho", "text": "Não quer comprar sonar avulso e GPS separado — quer os dois juntos.", "tags": [{"label": "Completo", "color": "blue"}]},
      {"title": "Quem navega com carta náutica ou mapa de lago", "text": "Precisa de cartografia pronta pra planejar rota, não só waypoints soltos.", "tags": [{"label": "Navegação", "color": "green"}]},
      {"title": "Dono de barco com mais de uma unidade", "text": "Aproveita o Wi-Fi pra compartilhar dados entre duas telas ECHOMAP UHD2.", "tags": [{"label": "Multi-unidade", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer chartplotter completo (mapas prontos), não só sonar de waypoints</li><li>Cliente tem ou vai ter mais de uma unidade a bordo (Wi-Fi entre telas)</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente só quer sonar simples, sem cartografia → Striker 4 ou Striker Vivid 5cv custam menos</li><li>Cliente quer tela touchscreen → este modelo é por botões (\"keyed\")</li></ul>"}
  ]}
  $j$),
  (v_p_echomap, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Sonar de 500W: CHIRP + ClearVü", "html": "<p>CHIRP tradicional em 70/83/200 kHz (com opções L/M/H CHIRP) e ClearVü de varredura em 260/455/800 kHz, com o transdutor GT20-TM incluso.</p>"},
      {"title": "Upgrade pra GT24UHD-TM", "html": "<p>Transdutor opcional com sonar de varredura Ultra Alta Definição, com CHIRP tradicional e ClearVü em maior clareza.</p>"},
      {"title": "Cartografia integrada", "html": "<p>BlueChart g3 (costa) ou LakeVü g3 (águas interiores) pré-carregados, com dados Navionics — upgrade disponível pra Garmin Navionics+ com atualizações diárias.</p>"},
      {"title": "Wi-Fi entre unidades", "html": "<p>Compartilha sonar, waypoints e rotas sem fio entre dois ECHOMAP UHD2 a bordo.</p>"},
      {"title": "GPS/GLONASS de 5 Hz", "html": "<p>Atualização de posição até 5x mais rápida que antenas comuns de 1 Hz do mercado.</p>"},
      {"title": "Cartão SD até 32 GB", "html": "<p>Armazena até 5.000 waypoints.</p>"},
      {"title": "ActiveCaptain", "html": "<p>Acesso à comunidade ActiveCaptain (conhecimento local de pescadores/navegadores) e atualização de cartas pelo app.</p>"},
      {"title": "Interface por botões (keyed)", "html": "<p>Controle físico, sem touchscreen — herdado do design consagrado da linha ECHOMAP UHD original.</p>"}
    ]}
  ]}
  $j$),
  (v_p_echomap, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado à geração <strong>ECHOMAP UHD original</strong> (2019) — o tamanho de 5\" (\"52cv\") é NOVO da geração UHD2: a linha UHD original só existia em 6\", 7\" e 9\"."},
    {"type": "accordion", "items": [
      {"title": "Tamanho de 5\" inédito na linha UHD", "html": "<p>A geração UHD original (2019) não tinha opção de 5\" — só 6\", 7\" e 9\". O UHD2 introduziu esse tamanho compacto pela primeira vez, oficialmente descrito como \"a newly introduced 5-inch keyed combo unit\".</p>"},
      {"title": "Wi-Fi entre duas unidades", "html": "<p>Recurso de compartilhamento sonar/dados entre dois ECHOMAP UHD2 a bordo — a geração UHD original tinha Wi-Fi pro ActiveCaptain, mas não esse compartilhamento direto entre unidades.</p>"},
      {"title": "Upgrade pra Garmin Navionics+", "html": "<p>Opção de cartografia com atualizações diárias — recurso novo desta geração.</p>"},
      {"title": "Design modernizado", "html": "<p>A Garmin descreve o UHD2 como mantendo \"a interface clássica por botões dos modelos UHD legado\", só que com visual atualizado.</p>"},
      {"title": "O que NÃO mudou", "html": "<p>Sonar UHD (Ultra Alta Definição), cartografia BlueChart g3/LakeVü g3 pré-carregada, compatibilidade com transdutores Panoptix (nos tamanhos maiores) e a interface por botões — tudo isso já vinha da geração UHD original.</p>"}
    ]}
  ]}
  $j$),
  (v_p_echomap, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo combo completo", "dialog": "Se você quer sonar de alta definição E navegação com mapa pronto no mesmo aparelho, o ECHOMAP UHD2 52cv resolve os dois — sem precisar comprar peças separadas.", "tip": "Bom argumento pra quem já tentou montar um sistema com peças avulsas e achou complicado."},
      {"title": "Puxando a cartografia integrada", "dialog": "Ele já vem com mapa de costa ou de águas interiores pré-carregado, com dados Navionics — você não precisa comprar cartão de mapa separado pra começar a navegar.", "tip": "Pergunte se o cliente pesca em água doce (LakeVü) ou salgada (BlueChart) antes de fechar."},
      {"title": "Se o cliente tem mais de uma unidade", "dialog": "Se você já tem ou vai ter outra tela ECHOMAP UHD2 a bordo, o Wi-Fi compartilha sonar e waypoints entre as duas automaticamente.", "tip": "Só puxe esse argumento se o cliente mencionar mais de um ponto de instalação."},
      {"title": "Fechamento", "dialog": "Com o ECHOMAP UHD2 52cv você sai com sonar de 500W, cartografia pronta, GPS de alta velocidade e Wi-Fi — o combo completo de navegação e pesca.", "tip": "Pergunte sobre upgrade de transdutor (GT24UHD-TM) se o cliente quiser sonar ainda mais detalhado."}
    ]}
  ]}
  $j$),
  (v_p_echomap, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não o Striker Vivid 5cv, que é mais barato?", "answer": "Se o cliente precisa de cartografia pronta (mapa de lago, carta náutica) pra navegação, o ECHOMAP entrega isso de fábrica — o Striker fica só no sonar + GPS de waypoints, sem mapa pronto."},
      {"question": "Não tem touchscreen?", "answer": "Não — é um modelo \"keyed\", controlado por botões físicos. Funciona bem com luva molhada e sol forte, mas quem espera touch pode se surpreender. Vale mostrar antes de vender."},
      {"question": "Precisa comprar cartão de mapa separado?", "answer": "Não pra começar — já vem com BlueChart g3 ou LakeVü g3 pré-carregado. O cartão SD é só pra quem quer fazer upgrade pra cartografia premium (Navionics+) ou salvar mais waypoints."}
    ]}
  ]}
  $j$),
  (v_p_echomap, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Cliente navegando em lago desconhecido", "text": "Precisa de mapa pronto (LakeVü) pra não se perder — o ECHOMAP já vem com isso.", "tags": []},
      {"title": "Pescador de costa/mar aberto", "text": "Usa BlueChart g3 pra navegação costeira segura.", "tags": []},
      {"title": "Cliente com barco de dois postos de comando", "text": "Instala dois ECHOMAP UHD2 e compartilha dados via Wi-Fi entre eles.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_echomap, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "É touchscreen?", "html": "<p>Não — é um modelo \"keyed\", controlado por botões físicos.</p>"},
      {"title": "Vem com mapa pré-carregado?", "html": "<p>Sim, BlueChart g3 (costa) ou LakeVü g3 (águas interiores), com dados Navionics.</p>"},
      {"title": "Qual a diferença pro ECHOMAP UHD (sem o \"2\")?", "html": "<p>A geração UHD original não tinha tamanho de 5\" — só existia em 6\", 7\" e 9\". O 52cv é exclusivo da geração UHD2.</p>"},
      {"title": "Tem Wi-Fi?", "html": "<p>Sim, incluindo compartilhamento de sonar e dados entre duas unidades ECHOMAP UHD2 a bordo.</p>"},
      {"title": "Qual a diferença real pro Striker Vivid 5cv?", "html": "<p>O ECHOMAP vem com cartografia pronta (mapas/cartas), suporte a cartão SD e compartilhamento Wi-Fi entre unidades — o Striker Vivid foca só em sonar + GPS de waypoints, sem navegação por mapa pronto.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 5. Quiz Especialista — 3 produtos
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-striker-4', 'Quiz Especialista: Striker 4', 70, true)
  returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Striker 4 tem cartografia pré-carregada (mapa de lago/carta náutica)?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é focado em sonar + GPS de waypoints', true, 1), (v_q, 'Sim, BlueChart g3', false, 2), (v_q, 'Sim, LakeVü g3', false, 3), (v_q, 'Sim, Navionics+', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual a frequência do sonar CHIRP do Striker 4?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '77/200 kHz', true, 1), (v_q, '260/455/800 kHz', false, 2), (v_q, '70/83/200 kHz', false, 3), (v_q, '1 MHz', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Striker 4 tem um "Striker 3" como antecessor direto?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é o modelo fundador da linha Striker (2016)', true, 1), (v_q, 'Sim', false, 2), (v_q, 'Só na versão Plus', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual o tamanho da tela do Striker 4?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '3,5"', true, 1), (v_q, '5"', false, 2), (v_q, '7"', false, 3), (v_q, '9"', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-striker-vivid-5cv', 'Quiz Especialista: Striker Vivid 5cv', 70, true)
  returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que são as paletas de cor "Vivid"?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '7 opções de cor com alto contraste pra identificar peixe/estrutura', true, 1), (v_q, 'Um tipo de transdutor', false, 2), (v_q, 'Um app de navegação', false, 3), (v_q, 'Um tipo de bateria', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Striker Vivid 5cv tem sonar de varredura ClearVü?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Sim, além do CHIRP tradicional', true, 1), (v_q, 'Não, só CHIRP', false, 2), (v_q, 'Só na versão UHD', false, 3), (v_q, 'Não tem sonar', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que é o Garmin Quickdraw Contours?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Ferramenta pra criar e salvar mapas próprios de profundidade', true, 1), (v_q, 'Um modo de pesca no gelo', false, 2), (v_q, 'Um tipo de tela touchscreen', false, 3), (v_q, 'Um acessório de bateria', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Striker Vivid 5cv tem cartografia pronta (carta náutica/mapa de lago)?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — só o Quickdraw Contours (mapas criados pelo próprio usuário)', true, 1), (v_q, 'Sim, BlueChart g3', false, 2), (v_q, 'Sim, LakeVü g3', false, 3), (v_q, 'Sim, Navionics+', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-echomap-uhd2-52cv', 'Quiz Especialista: ECHOMAP UHD2 52cv', 70, true)
  returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'A geração ECHOMAP UHD original (sem o "2") tinha tamanho de 5"?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — só existia em 6", 7" e 9". O 5" é exclusivo da geração UHD2', true, 1), (v_q, 'Sim, em todos os tamanhos', false, 2), (v_q, 'Sim, só o 5"', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O ECHOMAP UHD2 52cv é touchscreen?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é um modelo "keyed", controlado por botões', true, 1), (v_q, 'Sim', false, 2), (v_q, 'Sim, mas só com luva', false, 3), (v_q, 'Depende da versão', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O ECHOMAP UHD2 52cv vem com cartografia pré-carregada?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Sim, BlueChart g3 ou LakeVü g3', true, 1), (v_q, 'Não, precisa comprar separado', false, 2), (v_q, 'Só sob encomenda', false, 3), (v_q, 'Só em cartão SD à parte', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que o Wi-Fi do ECHOMAP UHD2 permite fazer entre duas unidades?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Compartilhar sonar, waypoints e rotas sem fio', true, 1), (v_q, 'Fazer ligações telefônicas', false, 2), (v_q, 'Nada, é só decorativo', false, 3), (v_q, 'Só atualizar firmware', false, 4);

  insert into product_quizzes (product_id, quiz_id)
  select id, (select id from quizzes where slug = 'quiz-especialista-striker-4') from products where slug = 'striker-4'
  union all
  select id, (select id from quizzes where slug = 'quiz-especialista-striker-vivid-5cv') from products where slug = 'striker-vivid-5cv'
  union all
  select id, (select id from quizzes where slug = 'quiz-especialista-echomap-uhd2-52cv') from products where slug = 'echomap-uhd2-52cv';

  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-striker-4-garmin', 'Especialista Striker 4', 'Concedido ao passar no Quiz Especialista do Striker 4.', '{"tipo": "quiz_especialista_produto", "produto": "striker-4"}'),
  (v_brand_id, 'especialista-striker-vivid-5cv-garmin', 'Especialista Striker Vivid 5cv', 'Concedido ao passar no Quiz Especialista do Striker Vivid 5cv.', '{"tipo": "quiz_especialista_produto", "produto": "striker-vivid-5cv"}'),
  (v_brand_id, 'especialista-echomap-uhd2-52cv-garmin', 'Especialista ECHOMAP UHD2 52cv', 'Concedido ao passar no Quiz Especialista do ECHOMAP UHD2 52cv.', '{"tipo": "quiz_especialista_produto", "produto": "echomap-uhd2-52cv"}');

  -- ==========================================================================
  -- 6. Grafo de conhecimento — relacionados
  -- ==========================================================================
  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index)
  values (v_p_striker4, v_p_vivid5cv, null, 'upgrade', 1);
  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index)
  values (v_p_vivid5cv, v_p_striker4, null, 'entrada', 1);
  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index)
  values (v_p_vivid5cv, v_p_echomap, null, 'topo_de_linha', 2);
  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index)
  values (v_p_echomap, v_p_vivid5cv, null, 'alternativa_mais_em_conta', 1);
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 078
-- ============================================================================
