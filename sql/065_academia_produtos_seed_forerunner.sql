-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 065: Academia de Produtos — seed Forerunner 570/970
-- ============================================================================
-- Conteúdo de exemplo pedido pelo usuário (2026-07-20) pra ver a Academia de
-- Produtos funcionando de ponta a ponta: 1 categoria, 2 produtos (Forerunner
-- 570 e 970), as 7 seções de bloco rico de cada um, 1 comparativo entre os
-- dois, 1 game de comparativo (reaproveitando o motor de Duelo já existente),
-- 1 Quiz Especialista por produto, materiais de download e o grafo de
-- relacionados.
--
-- FONTES — só site oficial garmin.com (US) e blog oficial da Garmin (US/AU,
-- mesmo texto do lançamento), por exigência explícita do usuário:
--   - Press release de lançamento: garmin.com/en-US/newsroom/press-release/
--     sports-fitness/garmin-unveils-the-forerunner-570-and-forerunner-970-...
--   - Blog oficial "The difference between Garmin Forerunner 965 and 970":
--     garmin.com/en-US/blog/fitness/the-difference-between-garmin-forerunner-965-and-970/
--   - Manuais oficiais do proprietário (www8.garmin.com/manuals/webhelp/...)
--     para as tabelas de bateria por modo, armazenamento e resistência à água.
-- Specs físicas não confirmadas nessas fontes (dimensões exatas em mm, peso em
-- gramas, resolução exata da tela) foram deliberadamente OMITIDAS do conteúdo
-- abaixo, em vez de inventadas — ver nota no relatório de pesquisa.
-- ============================================================================

do $$
declare
  v_brand_id     uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_id       uuid;
  v_p570         uuid;
  v_p970         uuid;
  v_quiz570      uuid;
  v_quiz970      uuid;
  v_q            uuid;
  v_comparison   uuid;
  v_game         uuid;
begin

  -- ==========================================================================
  -- 1. Categoria + produtos
  -- ==========================================================================
  insert into product_categories (brand_id, slug, name, icon, order_index)
  values (v_brand_id, 'corrida-triathlon', 'Corrida & Triathlon', '🏃', 1)
  returning id into v_cat_id;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, price_usd, is_published, order_index)
  values (v_brand_id, v_cat_id, 'forerunner-570', 'Forerunner 570', '010-02922', 'Smartwatch avançado de GPS para corrida e triathlon', 549.99, true, 1)
  returning id into v_p570;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, price_usd, is_published, order_index)
  values (v_brand_id, v_cat_id, 'forerunner-970', 'Forerunner 970', '010-02969-01', 'Smartwatch premium de GPS para corrida e triathlon', 749.99, true, 2)
  returning id into v_p970;

  -- ==========================================================================
  -- 2. FORERUNNER 570 — seções
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p570, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Forerunner 570</strong> é o smartwatch avançado de GPS para corrida e triathlon lançado pela Garmin em 21 de maio de 2025, junto do Forerunner 970. Disponível em dois tamanhos de caixa — <strong>42mm e 47mm</strong> — com bisel de alumínio.</p><p><strong>Posicionamento oficial da Garmin</strong> (Susan Lyman, VP de Vendas e Marketing ao Consumidor): a nova linha foi criada \"para todo atleta que está atrás de metas e apaixonado pelos próprios dados\", trazendo ferramentas de treino, métricas de recuperação e recursos conectados para ajudá-lo a performar no seu melhor.</p><p><strong>Público-alvo:</strong> corredores e triatletas que já treinam com constância e querem métricas avançadas de performance e recuperação — o modelo de entrada da nova geração Forerunner, pra quem não precisa do mapeamento colorido, lanterna e ECG do 970.</p><p><strong>Preço sugerido:</strong> US$ 549,99 (garmin.com, lançamento em maio/2025).</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela AMOLED premium", "text": "A tela touchscreen AMOLED mais brilhante já lançada pela Garmin até o momento, com controle também por 5 botões físicos.", "tags": []},
      {"title": "GPS multibanda SatIQ™", "text": "Tecnologia SatIQ ajusta automaticamente entre bandas de satélite pra equilibrar precisão e economia de bateria.", "tags": []},
      {"title": "Bateria de até 11 dias", "text": "Modo smartwatch: até 11 dias (caixa 47mm) ou 10 dias (42mm). Só GPS: até 18 horas.", "tags": []},
      {"title": "Garmin Triathlon Coach", "text": "Planos de treino personalizados pros 3 esportes, com perfis de atividade multisport customizáveis.", "tags": []},
      {"title": "Training Readiness + VO2 max", "text": "Métricas avançadas de performance: potência de corrida no pulso, dinâmica de corrida e Training Readiness.", "tags": []},
      {"title": "Música offline", "text": "Armazenamento de até 8 GB pra músicas do Spotify, Deezer ou Amazon Music, sem precisar do celular por perto.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p570, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "O Corredor Consistente", "text": "Treina toda semana buscando evoluir o tempo de prova. Quer ver VO2 max e Training Readiness sem pagar pelo topo de linha.", "tags": [{"label": "Corrida", "color": "blue"}]},
      {"title": "O Triatleta em Formação", "text": "Já pratica os 3 esportes com regularidade. Precisa de perfis multisport e Triathlon Coach, mas não exige mapas coloridos ou ECG.", "tags": [{"label": "Triathlon", "color": "green"}]},
      {"title": "Quem troca de relógio básico", "text": "Migrando de um Forerunner mais simples (ou de outra marca). Quer o salto de recursos sem pagar o preço do 970.", "tags": [{"label": "Upgrade", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Quer performance e recuperação sem pagar por mapeamento colorido, lanterna ou ECG</li><li>Ainda não decidiu entre focar em 1 ou 2 esportes de endurance</li><li>Sensível a preço, mas não quer abrir mão de bateria boa e tela AMOLED</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente pede navegação com mapa colorido nas trilhas → indicar o 970</li><li>Cliente com histórico cardíaco quer monitorar arritmia (ECG) → só o 970 tem</li><li>Cliente quer o menor peso possível ou prefere titânio/safira → indicar o 970</li></ul>"}
  ]}
  $j$),
  (v_p570, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tela AMOLED touchscreen + 5 botões", "html": "<p>A tela AMOLED mais brilhante já lançada pela Garmin até hoje, com touchscreen E controle físico por 5 botões — funciona bem de luva ou suado, sem depender só do toque.</p>"},
      {"title": "GPS multibanda com SatIQ™", "html": "<p>SatIQ ajusta automaticamente entre bandas de satélite pra equilibrar precisão de posicionamento e economia de bateria, sem o usuário precisar escolher manualmente o modo de GPS.</p>"},
      {"title": "Bateria por modo de uso", "html": "<p>Só GPS: até 18h. Todos os sistemas + multibanda: até 13-14h. Modo smartwatch (atividade, notificações, FC de pulso): até 10 dias (42mm) ou 11 dias (47mm).</p>"},
      {"title": "Garmin Triathlon Coach", "html": "<p>Planos de treino guiados pros 3 esportes do triathlon, com perfis de atividade multisport customizáveis.</p>"},
      {"title": "Relatório da Noite (Evening Report)", "html": "<p>Resumo único reunindo sono, treino do dia e previsão do tempo — pra planejar o dia seguinte sem abrir vários apps.</p>"},
      {"title": "Temperatura de pele + Pulse Ox", "html": "<p>Sensor de temperatura de pele e Pulse Ox (variações respiratórias durante o sono), alimentando as métricas de recuperação.</p>"},
      {"title": "Training Readiness + métricas avançadas", "html": "<p>VO2 max, potência de corrida direto no pulso e dinâmica de corrida, combinados no score de Training Readiness.</p>"},
      {"title": "Auto lap + previsão de tempo de prova", "html": "<p>Detecção automática de linha de chegada por timing gate e previsão de tempo de prova com base no treino recente.</p>"},
      {"title": "Garmin Pay + notificações inteligentes", "html": "<p>Pagamento por aproximação e notificações do celular direto no pulso.</p>"},
      {"title": "Música offline (até 8 GB)", "html": "<p>Download de playlists do Spotify, Deezer ou Amazon Music pra ouvir sem o celular — armazenamento de até 8 GB.</p>"},
      {"title": "Detecção de incidente + LiveTrack", "html": "<p>Detecta quedas/acidentes durante o treino e avisa contatos de emergência com localização ao vivo.</p>"},
      {"title": "Resistência à água 5 ATM", "html": "<p>Classificação para natação, equivalente à pressão de uma profundidade de 50 metros.</p>"}
    ]}
  ]}
  $j$),
  (v_p570, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pra quem já treina com regularidade", "dialog": "Você treina toda semana e já sente na pele os resultados, né? O Forerunner 570 foi feito exatamente pra isso: ele traduz esse esforço em dados — Training Readiness, VO2 max, potência de corrida, tudo direto no pulso.", "tip": "Deixe o cliente contar a rotina de treino ANTES de falar de specs — personaliza todo o resto do pitch."},
      {"title": "Ancorando o valor antes do preço", "dialog": "Antes de falar em valor, olha só o que ele entrega: tela AMOLED mais brilhante que a Garmin já lançou, GPS multibanda que ajusta sozinho pra não gastar bateria à toa, e até 11 dias de uso no dia a dia sem carregar.", "tip": "Sempre entregar 2-3 diferenciais concretos antes de mencionar o preço."},
      {"title": "Se o cliente pratica mais de um esporte", "dialog": "Se você já pensa em triathlon ou já treina os três esportes, o 570 vem com o Garmin Triathlon Coach — um plano de treino guiado pros três, com perfis de atividade pensados pra transição entre eles.", "tip": "Bom gancho pra quem só corre hoje mas já demonstrou curiosidade por triathlon."},
      {"title": "Comparando com o 970 sem empurrar o topo de linha", "dialog": "O 970 é o topo da linha, com mapeamento colorido, lanterna e ECG — mas se o seu foco é performance e recuperação no dia a dia de treino, o 570 entrega isso tudo por um preço mais acessível.", "tip": "Só puxe essa comparação se o cliente perguntar sobre o 970 — não plante a dúvida sozinho."},
      {"title": "Fechamento", "dialog": "Com o 570 você sai hoje com um dos relógios mais completos da Garmin pra corrida e triathlon, num tamanho que cabe no seu pulso — 42 ou 47mm.", "tip": "Sempre reforce a escolha de tamanho — é uma decisão real que o cliente precisa tomar antes de fechar."}
    ]}
  ]}
  $j$),
  (v_p570, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Tá caro pra um relógio.", "answer": "Entendo — mas compara com o que ele substitui: GPS dedicado, monitor cardíaco, treinador de corrida e até o Spotify offline, tudo em um aparelho só, com bateria de até 11 dias. Muita gente compra 3-4 aparelhos separados pra ter isso."},
      {"question": "Vou esperar cair de preço.", "answer": "Faz sentido esperar por promoção, mas é lançamento recente (maio/2025) — a Garmin raramente derruba preço de linha nova rápido. Se o treino é hoje, os dados que você perde nesse meio tempo não voltam."},
      {"question": "Meu relógio atual já faz tudo isso.", "answer": "Ótimo que já rastreia treino! A diferença aqui é a profundidade dos dados: Training Readiness, potência de corrida no pulso e dinâmica de corrida são recursos avançados que a maioria dos relógios básicos não calcula — vale comparar as métricas dos dois lado a lado."},
      {"question": "Por que não levar o 970 direto?", "answer": "Se mapeamento colorido, lanterna ou ECG não são prioridade hoje, o 570 entrega praticamente a mesma experiência de treino e recuperação por um preço bem mais acessível — ele é o modelo mais equilibrado da linha nova."}
    ]}
  ]}
  $j$),
  (v_p570, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Preparação pra primeira prova de 21km", "text": "Cliente corre há 1 ano sem monitorar recuperação. O 570 entra com Training Readiness e Evening Report pra evitar treino em excesso na reta final da preparação.", "tags": []},
      {"title": "Upgrade de um Forerunner mais antigo", "text": "Cliente já tem um modelo de entrada e quer dar o salto de tela e bateria sem pagar pelo topo de linha — o 570 é o próximo degrau natural.", "tags": []},
      {"title": "Primeiro triathlon sprint", "text": "Cliente corre e pedala, mas nunca nadou competindo. O Garmin Triathlon Coach guia o plano combinado pros 3 esportes.", "tags": []},
      {"title": "Treino com música, sem celular", "text": "Cliente corre de manhã sem levar o celular. Com playlists baixadas do Spotify direto no relógio, resolve o treino sem depender de mais nada no bolso.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p570, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Qual a autonomia de bateria com música e GPS ligados?", "html": "<p>Com todos os sistemas + multibanda GNSS e música: até 8 horas (nas duas caixas). Só GPS + música: até 9 horas.</p>"},
      {"title": "Quais tamanhos de caixa existem?", "html": "<p>42mm e 47mm, ambos com bisel de alumínio. O 970 é vendido só em 47mm.</p>"},
      {"title": "Tem resistência à água pra nadar?", "html": "<p>Sim, classificação 5 ATM — equivalente à pressão de uma profundidade de 50 metros.</p>"},
      {"title": "Quais serviços de música offline são suportados?", "html": "<p>Spotify, Deezer e Amazon Music, com até 8 GB de armazenamento.</p>"},
      {"title": "Tem pagamento por aproximação?", "html": "<p>Sim, via Garmin Pay.</p>"},
      {"title": "Qual a diferença real pro Forerunner 970?", "html": "<p>O 970 adiciona lanterna LED, mapeamento colorido com navegação turn-by-turn, ECG, compatibilidade com a cinta HRM 600, métricas exclusivas de corrida (tolerância, economia e perda de velocidade do passo), bisel de titânio com lente de safira, mais armazenamento de música (32 GB) e bateria maior — por um preço US$ 200 mais alto.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 3. FORERUNNER 970 — seções
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p970, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Forerunner 970</strong> é o smartwatch premium de GPS para corrida e triathlon da Garmin, lançado em 21 de maio de 2025 ao lado do Forerunner 570. Vendido só em caixa de <strong>47mm</strong>, com bisel de titânio e lente de cristal de safira.</p><p><strong>Posicionamento oficial:</strong> é o topo da nova geração Forerunner — o blog oficial da Garmin descreve o salto do modelo anterior (965) pro 970 como \"durabilidade aprimorada\" e a proposta de \"levar seu esporte a outro patamar\".</p><p><strong>Público-alvo:</strong> atletas que querem o pacote completo de treino, recuperação e navegação num só relógio — incluindo mapeamento colorido, lanterna integrada e monitoramento de ECG.</p><p><strong>Preço sugerido:</strong> US$ 749,99 (garmin.com, lançamento em maio/2025).</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Bisel de titânio + safira", "text": "Lente de cristal de safira (mais resistente a risco que o vidro comum) com bisel de titânio.", "tags": []},
      {"title": "Lanterna LED integrada", "text": "Luz branca e vermelha embutida no relógio, exclusiva do 970 nesta linha.", "tags": []},
      {"title": "Mapeamento colorido + navegação", "text": "Mapas completos coloridos com navegação turn-by-turn direto no pulso.", "tags": []},
      {"title": "App de ECG", "text": "Detecção de fibrilação atrial e ritmo sinusal normal — recurso novo que a Garmin está introduzindo na linha Forerunner.", "tags": []},
      {"title": "Compatível com HRM 600", "text": "Suporte à cinta cardíaca HRM 600 (vendida separadamente), a mais avançada da Garmin.", "tags": []},
      {"title": "Bateria de até 15 dias", "text": "Modo smartwatch: até 15 dias. Armazenamento de música: até 32 GB.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p970, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "O Atleta que Navega", "text": "Corre ou pedala em trilhas sem sinal de celular. Precisa de mapa colorido e navegação turn-by-turn no próprio pulso.", "tags": [{"label": "Trail/Outdoor", "color": "green"}]},
      {"title": "Quem monitora saúde cardíaca", "text": "Já teve ou quer prevenir episódios de arritmia. O app de ECG do 970 é um diferencial de saúde, não só performance.", "tags": [{"label": "Saúde", "color": "blue"}]},
      {"title": "O Atleta que já decidiu pelo topo de linha", "text": "Não quer comparar — quer o relógio mais completo da linha Forerunner, com titânio, safira e todos os recursos.", "tags": [{"label": "Topo de linha", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente treina em trilha/outdoor e precisa de mapa colorido e navegação</li><li>Cliente pede monitoramento de ECG ou tem histórico cardíaco na família</li><li>Cliente já decidiu que quer o topo de linha e não está comparando preço</li><li>Cliente treina de noite/madrugada e valoriza a lanterna integrada</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente é sensível a preço e não usaria mapa colorido, lanterna ou ECG no dia a dia → indicar o 570</li><li>Cliente quer opção de caixa menor (42mm) → só o 570 tem esse tamanho</li></ul>"}
  ]}
  $j$),
  (v_p970, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Bisel de titânio + lente de safira", "html": "<p>Construção mais robusta que o alumínio/vidro do 570 — a safira resiste melhor a riscos no dia a dia.</p>"},
      {"title": "Lanterna LED integrada", "html": "<p>Luz branca e vermelha embutida no próprio relógio — útil em treinos de madrugada ou em trilha, sem precisar de lanterna separada.</p>"},
      {"title": "Mapeamento colorido + navegação turn-by-turn", "html": "<p>Mapas completos e coloridos com instruções de navegação passo a passo direto no pulso — recurso que o 570 não tem.</p>"},
      {"title": "App de ECG", "html": "<p>Detecta fibrilação atrial e ritmo sinusal normal. É um recurso novo sendo introduzido na linha Forerunner pela primeira vez.</p>"},
      {"title": "Métricas exclusivas de corrida", "html": "<p>Tolerância de corrida, economia de corrida e perda de velocidade do passo — três métricas novas, disponíveis só no 970.</p>"},
      {"title": "Compatibilidade com HRM 600", "html": "<p>Suporta a cinta cardíaca mais avançada da Garmin (vendida separadamente), com dados mais precisos de frequência cardíaca e dinâmica de corrida.</p>"},
      {"title": "Armazenamento de música (32 GB)", "html": "<p>4x o espaço do 570 (8 GB) — cabe uma biblioteca bem maior de playlists baixadas.</p>"},
      {"title": "Bateria por modo de uso", "html": "<p>Só GPS: até 26h. Todos os sistemas + multibanda: até 21h. Modo smartwatch: até 15 dias.</p>"},
      {"title": "Recursos compartilhados com o 570", "html": "<p>Tela AMOLED touchscreen + 5 botões, SatIQ GPS multibanda, Triathlon Coach, Evening Report, temperatura de pele, Pulse Ox, Training Readiness, Garmin Pay, resistência à água 5 ATM.</p>"}
    ]}
  ]}
  $j$),
  (v_p970, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pra quem quer o pacote completo", "dialog": "Se você quer o relógio mais completo que a Garmin já fez pra corrida e triathlon, é o 970: titânio, safira, mapa colorido, lanterna e até monitoramento de ECG, tudo no mesmo pulso.", "tip": "Use essa abertura só quando o cliente já sinalizar que quer o topo de linha — senão, comece pelo 570 e suba se fizer sentido."},
      {"title": "Puxando o ECG como diferencial de saúde", "dialog": "Um recurso novo que a Garmin tá trazendo pela primeira vez pra linha Forerunner é o app de ECG — ele consegue identificar sinais de fibrilação atrial direto no relógio.", "tip": "Ótimo gancho pra clientes 40+ ou com histórico familiar de arritmia — não é só sobre performance esportiva."},
      {"title": "Justificando o preço com a bateria e a tela", "dialog": "Ele aguenta até 15 dias no modo smartwatch e até 26 horas só de GPS — quase 50% a mais que o 570 em cada modo. Isso muda o jogo em provas longas de ultramaratona ou ironman.", "tip": "Sempre cite os números de bateria lado a lado com o 570 — é a comparação mais tangível pro cliente."},
      {"title": "Fechamento pra quem treina em trilha", "dialog": "Com mapa colorido e navegação turn-by-turn, você não precisa mais parar pra olhar o celular no meio da trilha — e ainda tem lanterna embutida pros treinos de madrugada.", "tip": "Combine bem com clientes que mencionaram trail running, hiking ou provas noturnas."}
    ]}
  ]}
  $j$),
  (v_p970, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "US$ 200 a mais que o 570 é muita diferença.", "answer": "É real — mas nesse valor você leva titânio e safira (mais resistente), lanterna, mapa colorido com navegação, ECG, cinta HRM 600 compatível, o dobro de bateria e 4x mais espaço de música. Se algum desses recursos resolve uma dor real do cliente, o valor se justifica sozinho."},
      {"question": "Eu não uso mapa nem lanterna, não preciso do 970.", "answer": "Faz sentido — nesse caso o 570 realmente entrega a mesma experiência de treino e recuperação por um preço mais baixo. O 970 só vale a diferença se algum dos recursos exclusivos (ECG, HRM 600, bateria maior) importar pra rotina do cliente."},
      {"question": "ECG em relógio é só modismo?", "answer": "É um recurso de saúde real — a Garmin está introduzindo o app de ECG pela primeira vez na linha Forerunner justamente porque a demanda por monitoramento cardíaco cresceu. Vale posicionar como prevenção, não só como número bonito no app."}
    ]}
  ]}
  $j$),
  (v_p970, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Ultramaratonista em prova de 24h", "text": "Precisa de bateria que aguente o dia inteiro em GPS multibanda e ainda quer navegação no meio da trilha sem depender do celular — o 970 cobre os dois.", "tags": []},
      {"title": "Cliente com histórico familiar de arritmia", "text": "Quer monitorar a saúde do coração além da performance esportiva. O app de ECG é o diferencial decisivo na conversa.", "tags": []},
      {"title": "Treino de madrugada antes do trabalho", "text": "Sai de casa às 5h ainda escuro. A lanterna integrada resolve sem precisar carregar equipamento extra.", "tags": []},
      {"title": "Upgrade de quem já tem o 965", "text": "Cliente satisfeito com o modelo anterior quer saber se vale trocar — o ECG, a lanterna e a bateria maior costumam ser os argumentos decisivos.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p970, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Qual a autonomia de bateria com música e GPS ligados?", "html": "<p>Com todos os sistemas + multibanda GNSS e música: até 12 horas. Só GPS + música: até 14 horas.</p>"},
      {"title": "Só existe em um tamanho de caixa?", "html": "<p>Sim, só 47mm — diferente do 570, que também vem em 42mm.</p>"},
      {"title": "O app de ECG substitui um exame médico?", "html": "<p>Não é mencionado como substituto de avaliação médica nas fontes oficiais consultadas — trate como uma ferramenta de triagem/monitoramento, não como diagnóstico.</p>"},
      {"title": "A cinta HRM 600 vem incluída?", "html": "<p>Não, é vendida separadamente. O 970 é compatível com ela; o 570 não tem essa compatibilidade confirmada nas fontes oficiais.</p>"},
      {"title": "Quanto armazenamento de música tem?", "html": "<p>Até 32 GB — 4x mais que o Forerunner 570 (8 GB).</p>"},
      {"title": "Tem resistência à água pra nadar?", "html": "<p>Sim, classificação 5 ATM — equivalente à pressão de uma profundidade de 50 metros, igual ao 570.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 4. Materiais de download (links oficiais reais — sem PDFs inventados)
  -- ==========================================================================
  insert into product_materials (product_id, type, title, url, order_index) values
  (v_p570, 'folder', 'Página oficial do produto (garmin.com)', 'https://www.garmin.com/en-US/p/1464001/', 1),
  (v_p570, 'folder', 'Manual do proprietário (specs oficiais de bateria/armazenamento)', 'https://www8.garmin.com/manuals/webhelp/GUID-25E3235D-44D2-4384-A591-DD1D71BEBCB1/EN-US/GUID-6E1935AD-17DC-48E6-8C54-B2FC79917B0B.html', 2),
  (v_p970, 'folder', 'Página oficial do produto (garmin.com)', 'https://www.garmin.com/en-US/p/1462801/', 1),
  (v_p970, 'folder', 'Manual do proprietário (specs oficiais de bateria/armazenamento)', 'https://www8.garmin.com/manuals/webhelp/GUID-025D75CF-3445-49E1-8D81-1AA74AB4E00F/EN-US/GUID-1933DAC3-8171-4995-A1F0-CD298E1F5A33.html', 2),
  (v_p970, 'folder', 'Blog oficial Garmin — diferenças 965 vs 970', 'https://www.garmin.com/en-US/blog/fitness/the-difference-between-garmin-forerunner-965-and-970/', 3);

  -- ==========================================================================
  -- 5. Quiz Especialista — Forerunner 570
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-forerunner-570', 'Quiz Especialista: Forerunner 570', 70, true)
  returning id into v_quiz570;

  insert into questions (quiz_id, body, order_index) values (v_quiz570, 'Em quais tamanhos de caixa o Forerunner 570 é vendido?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '42mm e 47mm', true, 1), (v_q, 'Só 47mm', false, 2), (v_q, '40mm e 45mm', false, 3), (v_q, 'Só 45mm', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz570, 'Qual a autonomia máxima em modo smartwatch (caixa 47mm)?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 11 dias', true, 1), (v_q, 'Até 15 dias', false, 2), (v_q, 'Até 7 dias', false, 3), (v_q, 'Até 20 dias', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz570, 'Quanto armazenamento de música o Forerunner 570 tem?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 8 GB', true, 1), (v_q, 'Até 32 GB', false, 2), (v_q, 'Não tem música offline', false, 3), (v_q, 'Até 16 GB', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz570, 'O Forerunner 570 tem lanterna LED integrada?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é exclusiva do Forerunner 970', true, 1), (v_q, 'Sim, igual ao 970', false, 2), (v_q, 'Só na versão 47mm', false, 3), (v_q, 'Só em cor branca', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz570, 'Qual tecnologia de GPS o Forerunner 570 usa pra equilibrar precisão e bateria?', 5) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'SatIQ™ (multibanda)', true, 1), (v_q, 'Só GPS de banda única', false, 2), (v_q, 'GLONASS exclusivo', false, 3), (v_q, 'Não tem GPS embutido', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz570, 'Qual é o material do bisel do Forerunner 570?', 6) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Alumínio', true, 1), (v_q, 'Titânio', false, 2), (v_q, 'Aço inoxidável', false, 3), (v_q, 'Cerâmica', false, 4);

  -- ==========================================================================
  -- 6. Quiz Especialista — Forerunner 970
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-forerunner-970', 'Quiz Especialista: Forerunner 970', 70, true)
  returning id into v_quiz970;

  insert into questions (quiz_id, body, order_index) values (v_quiz970, 'Qual recurso de saúde o Forerunner 970 introduz pela primeira vez na linha Forerunner?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'App de ECG (detecção de fibrilação atrial)', true, 1), (v_q, 'Oxímetro de pulso', false, 2), (v_q, 'Medição de pressão arterial', false, 3), (v_q, 'Glicemia sem picada', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz970, 'Quanto armazenamento de música o Forerunner 970 tem?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 32 GB', true, 1), (v_q, 'Até 8 GB', false, 2), (v_q, 'Até 16 GB', false, 3), (v_q, 'Não tem música offline', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz970, 'Qual cinta cardíaca o Forerunner 970 é compatível (vendida separadamente)?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'HRM 600', true, 1), (v_q, 'HRM-Dual', false, 2), (v_q, 'HRM dos anos 2010 (modelo antigo)', false, 3), (v_q, 'Não é compatível com nenhuma cinta', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz970, 'Em qual(is) tamanho(s) de caixa o Forerunner 970 é vendido?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Só 47mm', true, 1), (v_q, '42mm e 47mm', false, 2), (v_q, '40mm e 45mm', false, 3), (v_q, 'Só 45mm', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz970, 'Qual a autonomia máxima em modo smartwatch do Forerunner 970?', 5) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 15 dias', true, 1), (v_q, 'Até 11 dias', false, 2), (v_q, 'Até 20 dias', false, 3), (v_q, 'Até 7 dias', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz970, 'Quais materiais compõem o bisel e a lente do Forerunner 970?', 6) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Titânio + cristal de safira', true, 1), (v_q, 'Alumínio + vidro comum', false, 2), (v_q, 'Aço inoxidável + acrílico', false, 3), (v_q, 'Plástico reforçado + policarbonato', false, 4);

  -- ==========================================================================
  -- 7. Ligação produto → quiz
  -- ==========================================================================
  insert into product_quizzes (product_id, quiz_id) values (v_p570, v_quiz570), (v_p970, v_quiz970);

  -- ==========================================================================
  -- 8. Badges "Especialista em <produto>" (reaproveita fn_grant_badge, sql/023/064)
  -- ==========================================================================
  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-forerunner-570-garmin', 'Especialista Forerunner 570', 'Concedido ao passar no Quiz Especialista do Forerunner 570.', '{"tipo": "quiz_especialista_produto", "produto": "forerunner-570"}'),
  (v_brand_id, 'especialista-forerunner-970-garmin', 'Especialista Forerunner 970', 'Concedido ao passar no Quiz Especialista do Forerunner 970.', '{"tipo": "quiz_especialista_produto", "produto": "forerunner-970"}');

  -- ==========================================================================
  -- 9. Game de comparativo (reaproveita o motor de Duelo já existente —
  --    games/game_sessions/fn_submit_game_round/fn_finalize_game_session).
  --    gabarito usa as MESMAS chaves de reveal/opcoes_resposta (fr570/fr970),
  --    então fn_submit_game_round resolve certo sem precisar de nenhum mapa
  --    de abreviação novo (só instinct3/instincte têm mapa hoje, sql/021).
  -- ==========================================================================
  insert into games (brand_id, slug, title, config, is_published) values (
    v_brand_id,
    'duelo-forerunner-570-vs-970',
    'Duelo de Especificações: Forerunner 570 vs Forerunner 970',
    $j$
    {
      "meta": {
        "modo": "duelo_1v1",
        "titulo": "Forerunner 570 vs Forerunner 970",
        "opcoes_resposta": ["fr570", "fr970", "ambos", "nenhum"],
        "rodadas_por_partida": 9,
        "total_perguntas_no_pool": 9
      },
      "rounds": [
        {"cat": {"nome": "Preço Sugerido", "descr": "Valor de lançamento em garmin.com", "icone": "💵"}, "texto": "Qual modelo tem o preço sugerido mais baixo?", "gabarito": "fr570", "acerto": "✅ Correto! O Forerunner 570 custa US$ 549,99, contra US$ 749,99 do Forerunner 970 — uma diferença de US$ 200.", "erro": "❌ É o Forerunner 570, a US$ 549,99. O 970 custa US$ 749,99.", "reveal": {"fr570": "<strong>US$ 549,99</strong>", "fr970": "US$ 749,99"}},
        {"cat": {"nome": "Tamanhos de Caixa", "descr": "Opções de tamanho disponíveis", "icone": "⌚"}, "texto": "Qual modelo é vendido em dois tamanhos de caixa (42mm e 47mm)?", "gabarito": "fr570", "acerto": "✅ Isso mesmo! O Forerunner 570 vem em 42mm ou 47mm. O 970 é vendido só em 47mm.", "erro": "❌ É o Forerunner 570. O 970 só existe em 47mm.", "reveal": {"fr570": "<strong>42mm e 47mm</strong>", "fr970": "Só 47mm"}},
        {"cat": {"nome": "Material do Bisel e Lente", "descr": "Construção física do relógio", "icone": "💎"}, "texto": "Qual modelo tem bisel de titânio com lente de cristal de safira?", "gabarito": "fr970", "acerto": "✅ Correto! O Forerunner 970 tem titânio + safira. O 570 tem bisel de alumínio.", "erro": "❌ É o Forerunner 970. O 570 usa bisel de alumínio.", "reveal": {"fr570": "Bisel de <strong>alumínio</strong>", "fr970": "Bisel de <strong>titânio</strong> + lente de <strong>safira</strong>"}},
        {"cat": {"nome": "Armazenamento de Música", "descr": "Espaço pra playlists offline", "icone": "🎵"}, "texto": "Qual modelo tem 4x mais espaço de armazenamento de música?", "gabarito": "fr970", "acerto": "✅ Exato! O 970 tem até 32 GB, contra 8 GB do 570.", "erro": "❌ É o Forerunner 970, com até 32 GB. O 570 tem até 8 GB.", "reveal": {"fr570": "Até <strong>8 GB</strong>", "fr970": "Até <strong>32 GB</strong>"}},
        {"cat": {"nome": "Bateria — Modo Smartwatch", "descr": "Autonomia no uso diário (atividade + notificações)", "icone": "🔋"}, "texto": "Qual modelo dura mais em modo smartwatch (uso diário)?", "gabarito": "fr970", "acerto": "✅ Correto! O 970 aguenta até 15 dias, contra até 11 dias do 570 (caixa 47mm).", "erro": "❌ É o Forerunner 970, com até 15 dias. O 570 (47mm) aguenta até 11 dias.", "reveal": {"fr570": "Até <strong>11 dias</strong> (47mm) / 10 dias (42mm)", "fr970": "Até <strong>15 dias</strong>"}},
        {"cat": {"nome": "Lanterna Integrada", "descr": "Iluminação embutida no relógio", "icone": "🔦"}, "texto": "Qual modelo tem lanterna LED integrada (branca e vermelha)?", "gabarito": "fr970", "acerto": "✅ Correto! A lanterna LED é exclusiva do Forerunner 970 nesta linha.", "erro": "❌ É o Forerunner 970. O 570 não tem lanterna integrada.", "reveal": {"fr570": "Sem lanterna integrada ✗", "fr970": "<strong>Lanterna LED</strong> (branca/vermelha) ✓"}},
        {"cat": {"nome": "Mapeamento e Navegação", "descr": "Mapas completos com rota", "icone": "🗺️"}, "texto": "Qual modelo tem mapeamento colorido completo com navegação turn-by-turn?", "gabarito": "fr970", "acerto": "✅ Isso aí! Só o 970 tem mapa colorido completo com navegação passo a passo.", "erro": "❌ É o Forerunner 970. O 570 não tem esse recurso.", "reveal": {"fr570": "Sem mapeamento colorido completo", "fr970": "<strong>Mapas coloridos + navegação turn-by-turn</strong> ✓"}},
        {"cat": {"nome": "App de ECG", "descr": "Monitoramento de ritmo cardíaco", "icone": "❤️"}, "texto": "Qual modelo tem o app de ECG (detecção de fibrilação atrial)?", "gabarito": "fr970", "acerto": "✅ Correto! O ECG é um recurso novo, exclusivo do 970 nesta linha.", "erro": "❌ É o Forerunner 970. O 570 não tem app de ECG.", "reveal": {"fr570": "Sem app de ECG", "fr970": "<strong>App de ECG</strong> ✓ (novo na linha Forerunner)"}},
        {"cat": {"nome": "Recursos Compartilhados", "descr": "Especificações presentes nos dois modelos", "icone": "🤝"}, "texto": "Tela AMOLED touchscreen, GPS multibanda SatIQ™ e resistência à água 5 ATM — em quais modelos?", "gabarito": "ambos", "acerto": "✅ Exato! Essas três especificações são a base compartilhada dos dois modelos — a diferença está nos recursos extras do 970.", "erro": "❌ Essas três especificações estão presentes NOS DOIS modelos — AMOLED, SatIQ e 5 ATM são a base comum da linha.", "reveal": {"fr570": "AMOLED ✓ · SatIQ™ ✓ · 5 ATM ✓", "fr970": "AMOLED ✓ · SatIQ™ ✓ · 5 ATM ✓"}}
      ]
    }
    $j$,
    true
  ) returning id into v_game;

  -- ==========================================================================
  -- 10. Comparativo FR570 x FR970
  -- ==========================================================================
  insert into product_comparisons (brand_id, product_a_id, product_b_id, slug, title, resumo_executivo, blocks, comparison_game_id, is_published)
  values (
    v_brand_id, v_p570, v_p970, 'forerunner-570-vs-forerunner-970',
    'Forerunner 570 vs Forerunner 970',
    'Lançados juntos em maio de 2025, os dois compartilham a mesma base de recursos de treino (tela AMOLED, SatIQ GPS multibanda, Training Readiness, Triathlon Coach) — a diferença está em construção física, navegação e saúde. O 970 é o topo de linha: titânio, safira, mapa colorido, lanterna, ECG e compatibilidade com a cinta HRM 600, por US$ 200 a mais. O 570 é o ponto de entrada da nova geração, com quase os mesmos recursos de treino por um preço mais acessível e a opção extra de caixa 42mm.',
    $j$
    [
      {"type": "card_grid", "columns": 2, "items": [
        {"title": "Vantagens do Forerunner 570", "text": "Preço US$ 200 mais baixo · Opção de caixa 42mm (o 970 só tem 47mm) · Mesmos recursos de treino essenciais (Training Readiness, VO2 max, Triathlon Coach, SatIQ GPS)", "tags": [{"label": "570", "color": "blue"}]},
        {"title": "Vantagens do Forerunner 970", "text": "Bateria maior em todos os modos · Bisel de titânio + safira (mais resistente) · Lanterna LED, mapa colorido e ECG · 4x mais armazenamento de música · Compatível com a cinta HRM 600", "tags": [{"label": "970", "color": "gold"}]}
      ]},
      {"type": "card_grid", "columns": 2, "items": [
        {"title": "Limitações do Forerunner 570", "text": "Sem lanterna, sem mapa colorido, sem ECG · Não é compatível com a cinta HRM 600 (não confirmado nas fontes oficiais) · Bateria menor que o 970 em todos os modos", "tags": []},
        {"title": "Limitações do Forerunner 970", "text": "US$ 200 mais caro · Só existe em 47mm (sem opção de caixa menor)", "tags": []}
      ]},
      {"type": "objecao", "items": [
        {"question": "Quando vender o 570 em vez do 970?", "answer": "Quando o cliente é sensível a preço, não precisa de mapa colorido/lanterna/ECG no dia a dia, ou prefere uma caixa menor (42mm)."},
        {"question": "Quando vender o 970 em vez do 570?", "answer": "Quando o cliente treina em trilha sem sinal (precisa de mapa/navegação), treina de madrugada (lanterna), quer monitorar saúde cardíaca (ECG) ou já decidiu que quer o topo de linha."},
        {"question": "Quando NÃO vender o 570?", "answer": "Se o cliente já demonstrou interesse explícito em mapa colorido, ECG ou lanterna — empurrar o 570 nesse caso gera frustração e possível troca depois."},
        {"question": "Quando NÃO vender o 970?", "answer": "Se o cliente deixou claro que o orçamento é limitado e não usaria os recursos extras — o 570 entrega quase a mesma experiência de treino por menos."}
      ]},
      {"type": "roteiro", "steps": [
        {"title": "Argumento de venda — abertura pela dor do cliente", "dialog": "Antes de te mostrar as diferenças entre os dois, me conta: você treina mais em trilha/outdoor ou mais na rua/esteira? E já pensou em monitorar sua saúde cardíaca além da performance?", "tip": "As respostas aqui decidem se o pitch vai puxar pro 570 ou pro 970 — não recite a comparação inteira de cor."},
        {"title": "Argumento de venda — se o cliente hesitar no preço", "dialog": "Se o orçamento for o fator decisivo, o 570 entrega praticamente a mesma experiência de treino e recuperação do 970, só sem mapa colorido, lanterna e ECG — por US$ 200 a menos.", "tip": "Nunca desvalorize o 570 pra vender o 970 — ele é um produto completo por si só, não uma versão \"fraca\"."}
      ]},
      {"type": "accordion", "items": [
        {"title": "Os dois têm o mesmo GPS?", "html": "<p>Sim — os dois usam SatIQ™ com GPS multibanda. A diferença de autonomia em modo GPS vem da bateria maior do 970, não da tecnologia de GPS em si.</p>"},
        {"title": "O 570 vai receber ECG numa atualização futura?", "html": "<p>Não há confirmação disso nas fontes oficiais consultadas — trate como recurso exclusivo do 970 até haver anúncio oficial em contrário.</p>"},
        {"title": "Dá pra usar a cinta HRM 600 no Forerunner 570?", "html": "<p>A compatibilidade oficial confirmada é só com o Forerunner 970 — não foi encontrada confirmação oficial de suporte no 570.</p>"}
      ]}
    ]
    $j$,
    v_game,
    true
  ) returning id into v_comparison;

  -- ==========================================================================
  -- 11. Tabela comparativa spec-a-spec (comparison_items)
  -- ==========================================================================
  insert into comparison_items (comparison_id, spec_label, value_a, value_b, winner, order_index) values
  (v_comparison, 'Preço sugerido', 'US$ 549,99', 'US$ 749,99', 'a', 1),
  (v_comparison, 'Tamanhos de caixa', '42mm e 47mm', 'Só 47mm', 'a', 2),
  (v_comparison, 'Material do bisel / lente', 'Alumínio', 'Titânio + cristal de safira', 'b', 3),
  (v_comparison, 'Armazenamento de música', 'Até 8 GB', 'Até 32 GB', 'b', 4),
  (v_comparison, 'Bateria — só GPS', 'Até 18h', 'Até 26h', 'b', 5),
  (v_comparison, 'Bateria — todos os sistemas + multibanda', 'Até 13-14h', 'Até 21h', 'b', 6),
  (v_comparison, 'Bateria — modo smartwatch', 'Até 10-11 dias', 'Até 15 dias', 'b', 7),
  (v_comparison, 'Lanterna LED integrada', 'Não', 'Sim (branca/vermelha)', 'b', 8),
  (v_comparison, 'Mapeamento colorido + navegação', 'Não', 'Sim, turn-by-turn', 'b', 9),
  (v_comparison, 'App de ECG', 'Não', 'Sim', 'b', 10),
  (v_comparison, 'Compatível com HRM 600', 'Não confirmado', 'Sim', 'b', 11),
  (v_comparison, 'Métricas exclusivas de corrida', '—', 'Tolerância, economia e perda de velocidade do passo', 'b', 12),
  (v_comparison, 'Tela AMOLED touchscreen + 5 botões', 'Sim', 'Sim', 'tie', 13),
  (v_comparison, 'GPS multibanda SatIQ™', 'Sim', 'Sim', 'tie', 14),
  (v_comparison, 'Resistência à água', '5 ATM', '5 ATM', 'tie', 15),
  (v_comparison, 'Garmin Triathlon Coach', 'Sim', 'Sim', 'tie', 16);

  -- ==========================================================================
  -- 12. Grafo de conhecimento — relacionados
  -- ==========================================================================
  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index) values
  (v_p570, v_p970, null, 'upgrade', 1),
  (v_p570, null, 'Running Dynamics', 'metrica', 2),
  (v_p570, null, 'VO2 Max', 'metrica', 3),
  (v_p570, null, 'Garmin Coach', 'funcionalidade', 4),
  (v_p570, null, 'Training Readiness', 'metrica', 5),
  (v_p970, v_p570, null, 'entrada', 1),
  (v_p970, null, 'HRM 600', 'acessorio', 2),
  (v_p970, null, 'Running Dynamics', 'metrica', 3),
  (v_p970, null, 'VO2 Max', 'metrica', 4),
  (v_p970, null, 'Training Readiness', 'metrica', 5),
  (v_p970, null, 'Garmin Coach', 'funcionalidade', 6);

end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 065
-- ============================================================================
