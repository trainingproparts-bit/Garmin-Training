-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 070: Academia de Produtos — Forerunner 70/170
-- ============================================================================
-- Pedido do usuário (2026-07-20): adicionar Forerunner 70 e 170 (mesma
-- profundidade do 570/970 — 7 seções + quiz especialista) e comparativos
-- deles com os modelos anteriores (Forerunner 55 e Forerunner 165). Os
-- antecessores entram como produtos "de referência" — visão geral +
-- diferenciais só, não as 7 seções completas — servindo de base real pro
-- comparativo, já que o pedido era "faça o comparativo... com os modelos
-- anteriores", não documentar o 55/165 por inteiro.
--
-- FONTES — só oficiais (site garmin.com/newsroom, blog e manual do
-- proprietário em www8.garmin.com), mesma regra de sql/065/069:
--   - Press release Forerunner 70/170: garmin.com/en-US/newsroom/press-release/
--     sports-fitness/run-further-with-forerunner-70-and-forerunner-170-from-garmin/
--   - Manual do 70 (specs/bateria): www8.garmin.com/manuals/webhelp/
--     GUID-E3AB50C9-.../GUID-908C47B7-... e GUID-93113D62-...
--   - Manual do 170 (specs/bateria): www8.garmin.com/manuals/webhelp/
--     GUID-4A2FC8FE-.../GUID-3426BC21-...
--   - Press release Forerunner 165: garmin.com/en-US/newsroom/press-release/
--     sports-fitness/light-up-your-run-with-the-garmin-forerunner-165-series-...
--   - Manual do 165 (specs): www8.garmin.com/manuals/webhelp/GUID-607F08F6-...
--   - Press release Forerunner 55: garmin.com/en-US/newsroom (2021-06-02)
--   - Manual do 55 (specs): www8.garmin.com/manuals/webhelp/GUID-3A791586-...
-- Não existe post oficial "diferença entre X e Y" pro par 70/55 nem 170/165
-- (só existe pro 965/970) — specs comparativas aqui vêm direto dos manuais/
-- press releases de cada um, não de um post comparativo pronto.
-- Dimensões físicas exatas (mm/peso) não confirmadas nas fontes acessadas —
-- omitidas de propósito, mesma regra já seguida pro 570/970.
-- ============================================================================

do $$
declare
  v_brand_id   uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_id     uuid;
  v_p70        uuid;
  v_p170       uuid;
  v_p55        uuid;
  v_p165       uuid;
  v_quiz70     uuid;
  v_quiz170    uuid;
  v_q          uuid;
  v_comp70x55  uuid;
  v_comp170x165 uuid;
begin
  select id into v_cat_id from product_categories where brand_id = v_brand_id and slug = 'corrida-triathlon';

  -- ==========================================================================
  -- 1. Produtos
  -- ==========================================================================
  insert into products (brand_id, category_id, slug, name, model_code, tagline, price_usd, is_published, order_index)
  values (v_brand_id, v_cat_id, 'forerunner-70', 'Forerunner 70', '010-02997', 'Smartwatch de GPS para corrida, entrada da nova geração', 249.99, true, 3)
  returning id into v_p70;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, price_usd, is_published, order_index)
  values (v_brand_id, v_cat_id, 'forerunner-170', 'Forerunner 170', '010-02998', 'Smartwatch de GPS para corrida com recursos avançados puxados dos Forerunners de ponta', 299.99, true, 4)
  returning id into v_p170;

  -- Produtos de referência (antecessores) — só visão geral + diferenciais,
  -- servem de base real pro comparativo, não recebem as 7 seções completas.
  insert into products (brand_id, category_id, slug, name, model_code, tagline, price_usd, is_published, order_index)
  values (v_brand_id, v_cat_id, 'forerunner-55', 'Forerunner 55', '010-02427', 'Smartwatch de GPS básico para corrida (modelo anterior ao 70)', 199.99, true, 5)
  returning id into v_p55;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, price_usd, is_published, order_index)
  values (v_brand_id, v_cat_id, 'forerunner-165', 'Forerunner 165', '010-02863', 'Smartwatch de GPS para corrida com tela AMOLED (modelo anterior ao 170)', 249.99, true, 6)
  returning id into v_p165;

  -- ==========================================================================
  -- 2. FORERUNNER 70 — seções completas
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p70, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Forerunner 70</strong> é o smartwatch de GPS para corrida mais acessível da nova geração Forerunner, lançado pela Garmin em 15 de maio de 2026 (anunciado em 12/05) ao lado do Forerunner 170.</p><p><strong>Posicionamento oficial da Garmin</strong> (Susan Lyman, VP de Vendas e Marketing ao Consumidor): \"Feito com tudo que um corredor precisa pra começar sua jornada na corrida, o Forerunner 70 e o Forerunner 170 trazem recursos avançados de corrida e treino puxados dos nossos Forerunners mais avançados, além das métricas populares de saúde e bem-estar.\"</p><p><strong>Público-alvo:</strong> quem está começando a correr ou quer um GPS de corrida direto ao ponto, com métricas de treino que antes só existiam em modelos mais caros.</p><p><strong>Preço sugerido:</strong> US$ 249,99 (garmin.com, lançamento em maio/2026).</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela AMOLED touchscreen + 5 botões", "text": "Tela de 1,2\" com touchscreen responsivo e controle físico por 5 botões.", "tags": []},
      {"title": "Bateria de até 13 dias", "text": "Modo smartwatch: até 13 dias (28 dias em modo economia). Só GPS: até 23h.", "tags": []},
      {"title": "Training Readiness + Training Status", "text": "Métricas de treino avançadas puxadas dos Forerunners de ponta, antes só disponíveis em modelos mais caros.", "tags": []},
      {"title": "Garmin Coach", "text": "Planos de treino guiados, incluindo opções de corrida/caminhada pra quem tá começando.", "tags": []},
      {"title": "80+ apps esportivos", "text": "Perfis de atividade pra dezenas de esportes, além da corrida.", "tags": []},
      {"title": "6 cores", "text": "Citron, rosa suave, azul maré, lavanda, preto e whitestone.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p70, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Quem tá começando a correr", "text": "Nunca usou um relógio de corrida ou vem de um app no celular. Quer orientação (Garmin Coach) sem se afogar em configuração.", "tags": [{"label": "Iniciante", "color": "blue"}]},
      {"title": "Quem quer treino guiado sem complicação", "text": "Já corre, mas quer entender Training Readiness e Training Status sem pagar o preço de um modelo de ponta.", "tags": [{"label": "Treino guiado", "color": "green"}]},
      {"title": "Quem troca de um relógio básico", "text": "Já tem um Forerunner mais antigo (ex.: 55) e quer o salto de tela AMOLED e métricas de treino sem ainda precisar do 170.", "tags": [{"label": "Upgrade", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer o menor preço de entrada da linha nova, mesmo assim com tela AMOLED e Training Readiness/Status</li><li>Cliente só corre (não pratica ciclismo/natação em águas abertas com medidor de potência)</li><li>Cliente não precisa de Garmin Pay nem de música offline no relógio</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer pagar por aproximação com o relógio (Garmin Pay) → só o 170</li><li>Cliente quer ouvir música direto do relógio sem o celular → só o 170 Music</li><li>Cliente pratica ciclismo com medidor de potência ou natação em águas abertas → só o 170 tem altímetro barométrico, bússola e suporte a esses recursos</li></ul>"}
  ]}
  $j$),
  (v_p70, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tela AMOLED touchscreen + 5 botões", "html": "<p>Tela de 1,2\" com touchscreen responsivo e o tradicional controle por 5 botões físicos.</p>"},
      {"title": "Bateria por modo de uso", "html": "<p>Modo smartwatch: até 13 dias. Modo economia de bateria: até 28 dias. Só GPS: até 23h. Todos os sistemas GNSS: até 16h.</p>"},
      {"title": "Garmin Coach", "html": "<p>Planos de treino guiados, incluindo opções de corrida/caminhada (run/walk) pra quem tá começando — e Quick Workouts com sugestões adaptativas do próprio relógio.</p>"},
      {"title": "Training Readiness + Training Status", "html": "<p>Métricas de treino puxadas diretamente dos Forerunners mais avançados da Garmin — antes só disponíveis em modelos de preço mais alto.</p>"},
      {"title": "Potência e Dinâmica de Corrida no pulso", "html": "<p>Estimativa de potência de corrida e dinâmica (cadência, tempo de contato com o solo) direto no sensor de pulso, sem precisar de cinta cardíaca.</p>"},
      {"title": "80+ apps esportivos", "html": "<p>Perfis de atividade pra dezenas de esportes além da corrida — monitoramento 24/7 incluído.</p>"},
      {"title": "Sono avançado + Sleep Coach", "html": "<p>Rastreamento de sono avançado com recomendações do Sleep Coach, variações respiratórias, status de HRV e Pulse Ox.</p>"},
      {"title": "Notificações inteligentes + LiveTrack", "html": "<p>Notificações do celular no pulso e recursos de segurança/rastreamento em tempo real (LiveTrack).</p>"},
      {"title": "Resistência à água 5 ATM", "html": "<p>Classificação para natação, equivalente à pressão de uma profundidade de 50 metros.</p>"},
      {"title": "O que o 70 NÃO tem (fica só no 170)", "html": "<p>Sem Garmin Pay, sem armazenamento de música, sem altímetro barométrico/bússola/giroscópio/termômetro, sem suporte a medidor de potência de ciclismo e sem modo de natação em águas abertas — todos exclusivos do Forerunner 170.</p>"}
    ]}
  ]}
  $j$),
  (v_p70, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pra quem tá começando", "dialog": "Se essa é sua primeira vez com um relógio de corrida, o Forerunner 70 já entra com o Garmin Coach te guiando treino a treino — inclusive com opção de corrida/caminhada, sem exigir que você já saiba correr direto.", "tip": "Pergunte se o cliente já correu com algum app antes de oferecer o Coach — ajuda a calibrar o quanto de orientação ele já tem."},
      {"title": "Ancorando o valor: recursos de ponta por um preço de entrada", "dialog": "Esse aqui traz Training Readiness e Training Status, recursos que até pouco tempo só existiam nos Forerunners mais caros — e você leva por US$ 249,99.", "tip": "Bom argumento pra quem acha que 'relógio bom é caro' — o 70 quebra essa expectativa."},
      {"title": "Se o cliente perguntar sobre o 170", "dialog": "O 170 adiciona Garmin Pay, música offline e sensores extras pra quem pedala ou nada em águas abertas — se você só corre, o 70 já entrega praticamente a mesma experiência de treino por menos.", "tip": "Não desvalorize o 70 — ele é o produto completo pra quem só corre, não uma versão 'faltando coisa'."},
      {"title": "Fechamento", "dialog": "Com o 70 você sai hoje com um GPS de corrida completo, bateria de até 13 dias e ainda escolhe entre 6 cores.", "tip": "Cor costuma ser o último empurrão numa venda de relógio esportivo — vale mostrar as opções."}
    ]}
  ]}
  $j$),
  (v_p70, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não levar o 170 direto?", "answer": "Se você não precisa pagar por aproximação com o relógio, não pedala com medidor de potência e não nada em águas abertas, o 70 entrega a mesma experiência de treino e recuperação por US$ 50 a menos."},
      {"question": "Esse aqui não é o modelo 'básico'?", "answer": "É o mais acessível da linha nova, mas já vem com Training Readiness e Training Status — recursos que só apareciam em Forerunners bem mais caros até pouco tempo atrás."},
      {"question": "Meu relógio atual já conta passos e calorias, por que trocar?", "answer": "A diferença é a profundidade: Training Readiness te diz se você tá pronto pra treinar forte hoje ou se precisa recuperar, e o Garmin Coach monta o plano pra você — não é só contagem, é orientação de treino de verdade."}
    ]}
  ]}
  $j$),
  (v_p70, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Primeira corrida de 5km", "text": "Cliente nunca correu com regularidade. O Garmin Coach com run/walk monta o plano progressivo pra chegar aos 5km sem se machucar.", "tags": []},
      {"title": "Upgrade de um Forerunner 55", "text": "Cliente já corre há anos com um modelo básico e quer o salto de tela AMOLED e Training Readiness sem pagar o preço do topo de linha.", "tags": []},
      {"title": "Corredor que quer entender melhor a recuperação", "text": "Treina por conta própria e vive treinando cansado. Training Readiness mostra quando é dia de treino forte ou de descanso.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p70, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "O Forerunner 70 tem Garmin Pay?", "html": "<p>Não — pagamento por aproximação é exclusivo do Forerunner 170 nesta linha.</p>"},
      {"title": "Dá pra guardar música no relógio?", "html": "<p>Não, o armazenamento de música é exclusivo da versão Forerunner 170 Music.</p>"},
      {"title": "Qual a autonomia de bateria?", "html": "<p>Modo smartwatch: até 13 dias (28 dias em modo economia). Só GPS: até 23h. Todos os sistemas GNSS: até 16h.</p>"},
      {"title": "Tem resistência à água pra nadar?", "html": "<p>Sim, classificação 5 ATM — mas sem o modo dedicado de natação em águas abertas, que é exclusivo do 170.</p>"},
      {"title": "Quais cores estão disponíveis?", "html": "<p>Citron, rosa suave, azul maré, lavanda, preto e whitestone.</p>"},
      {"title": "Qual a diferença real pro Forerunner 170?", "html": "<p>O 170 adiciona Garmin Pay, altímetro barométrico, bússola, giroscópio, termômetro, suporte a medidor de potência de ciclismo, natação em águas abertas e (na versão Music) armazenamento de música — por US$ 50 a mais (170) ou US$ 100 a mais (170 Music).</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 3. FORERUNNER 170 — seções completas
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p170, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Forerunner 170</strong> é o smartwatch de GPS para corrida da nova geração Forerunner com o pacote mais completo de recursos, lançado em 15 de maio de 2026 ao lado do Forerunner 70. Disponível também na versão <strong>Forerunner 170 Music</strong>, com armazenamento de música.</p><p><strong>Posicionamento oficial:</strong> mesma mensagem do 70 — \"recursos avançados de corrida e treino puxados dos Forerunners mais avançados da Garmin, além das métricas populares de saúde e bem-estar\" (Susan Lyman, VP de Vendas e Marketing ao Consumidor).</p><p><strong>Público-alvo:</strong> corredores que também pedalam ou nadam em águas abertas, ou que querem o pacote completo (Garmin Pay, sensores extras) sem pular pro topo de linha (Forerunner 570/970).</p><p><strong>Preço sugerido:</strong> US$ 299,99 (170) ou US$ 349,99 (170 Music), garmin.com, lançamento em maio/2026.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tudo do Forerunner 70", "text": "Mesma tela AMOLED, Training Readiness/Status, Garmin Coach e Potência de Corrida no pulso.", "tags": []},
      {"title": "Garmin Pay", "text": "Pagamento por aproximação direto do pulso — recurso exclusivo do 170 nesta dupla.", "tags": []},
      {"title": "Sensores extras", "text": "Altímetro barométrico, bússola, giroscópio e termômetro — o 70 não tem nenhum desses.", "tags": []},
      {"title": "Ciclismo e natação em águas abertas", "text": "Suporte a medidor de potência/rolo inteligente de ciclismo e modo dedicado de natação em águas abertas.", "tags": []},
      {"title": "Garmin Cycling Coach", "text": "Planos de treino guiados também pro ciclismo, não só pra corrida.", "tags": []},
      {"title": "170 Music: música offline", "text": "Download de playlists (Spotify, Amazon Music, Deezer) e suporte a fone de ouvido sem fio.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p170, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "O Multiesportista de entrada", "text": "Corre e também pedala ou nada em águas abertas, mas não quer pagar o preço do 970 pra isso.", "tags": [{"label": "Multisport", "color": "green"}]},
      {"title": "Quem quer pagar com o pulso", "text": "Valoriza sair pra treinar sem carteira nem celular — Garmin Pay resolve isso.", "tags": [{"label": "Praticidade", "color": "blue"}]},
      {"title": "Quem quer música sem o celular", "text": "Treina sem levar o telefone e quer ouvir playlists direto do relógio — indicar a versão Music.", "tags": [{"label": "Música", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente pratica mais de um esporte (corrida + ciclismo ou natação em águas abertas)</li><li>Cliente quer Garmin Pay ou navegação com bússola/altímetro em trilha</li><li>Cliente quer música offline (indicar a versão Music)</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente só corre na rua/esteira e não usaria os sensores extras nem Garmin Pay → o 70 entrega o essencial por menos</li><li>Cliente quer mapeamento colorido completo ou ECG → só o Forerunner 970 tem esses recursos</li></ul>"}
  ]}
  $j$),
  (v_p170, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Garmin Pay", "html": "<p>Pagamento por aproximação direto do pulso — recurso que o Forerunner 70 não tem.</p>"},
      {"title": "Altímetro barométrico + bússola + giroscópio + termômetro", "html": "<p>Conjunto de sensores extras que o 70 não tem — ajuda na navegação e em métricas ambientais durante o treino.</p>"},
      {"title": "Suporte a medidor de potência de ciclismo", "html": "<p>Conecta com medidor de potência ou rolo inteligente de ciclismo, com o Garmin Cycling Coach guiando o treino.</p>"},
      {"title": "Natação em águas abertas", "html": "<p>Modo de atividade dedicado pra natação em águas abertas, além da piscina.</p>"},
      {"title": "Bateria por modo de uso", "html": "<p>Modo smartwatch: até 10 dias (19 dias em modo economia). Só GPS: até 20h. Todos os sistemas GNSS: até 14h. (170 Music, com música: GPS até 7,5h / todos os sistemas até 6,5h.)</p>"},
      {"title": "170 Music: armazenamento de música", "html": "<p>Download de playlists via Spotify, Amazon Music ou Deezer, com suporte a fones de ouvido sem fio — exclusivo da versão Music.</p>"},
      {"title": "Recursos compartilhados com o 70", "html": "<p>Tela AMOLED touchscreen + 5 botões, bateria de longa duração, Garmin Coach, Training Readiness, Training Status, Potência e Dinâmica de Corrida no pulso, 80+ apps esportivos, sono avançado + Sleep Coach, HRV, Pulse Ox, resistência à água 5 ATM.</p>"}
    ]}
  ]}
  $j$),
  (v_p170, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pra quem pratica mais de um esporte", "dialog": "Se você corre e também pedala ou nada em águas abertas, o 170 já vem preparado pra isso — suporte a medidor de potência de ciclismo e modo dedicado de natação em águas abertas.", "tip": "Bom gancho pra clientes que mencionarem triathlon ou treino cruzado."},
      {"title": "Puxando o Garmin Pay como praticidade do dia a dia", "dialog": "Imagina sair pra correr sem levar carteira nem celular e ainda conseguir pagar uma água no caminho — é só encostar o pulso.", "tip": "Funciona bem com clientes que já mencionaram \"queria sair mais leve pra treinar\"."},
      {"title": "Se o cliente quer música", "dialog": "Se música é importante no seu treino, a versão 170 Music baixa suas playlists do Spotify, Amazon Music ou Deezer direto no relógio — sem precisar do celular no bolso.", "tip": "Sempre confirmar se o cliente já usa algum desses serviços antes de empurrar a versão Music."},
      {"title": "Fechamento comparando com o 70", "dialog": "A diferença pro 70 é justamente isso: Garmin Pay, sensores extras pra trilha e ciclismo, e a opção de música — se algum desses resolve uma necessidade sua, o 170 vale a diferença de preço.", "tip": "Nunca comece a venda comparando com o 70 — só puxe essa comparação se o cliente perguntar."}
    ]}
  ]}
  $j$),
  (v_p170, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "US$ 50 a mais que o 70 vale a pena?", "answer": "Vale se você usar Garmin Pay, pedalar com medidor de potência, nadar em águas abertas ou precisar de bússola/altímetro — se nenhum desses te interessa, o 70 já entrega o essencial de treino igual."},
      {"question": "Por que não o 970 direto?", "answer": "O 970 adiciona mapeamento colorido completo, ECG e lanterna — recursos de topo de linha. Se o seu foco é ter um pacote completo de corrida com alguns esportes extras sem pagar o preço do topo, o 170 é o ponto de equilíbrio."},
      {"question": "Preciso da versão Music?", "answer": "Só se você quiser ouvir música direto do relógio sem o celular. Se você sempre treina com o celular por perto, a versão sem música (mais barata) já resolve."}
    ]}
  ]}
  $j$),
  (v_p170, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Primeiro triathlon sprint", "text": "Cliente corre e pedala, quer estrear na natação em águas abertas. O 170 cobre os três sem precisar do 970.", "tags": []},
      {"title": "Treino sem carteira nem celular", "text": "Cliente quer sair pra correr mais leve e ainda conseguir pagar algo no caminho — Garmin Pay resolve.", "tags": []},
      {"title": "Upgrade de um Forerunner 165", "text": "Cliente satisfeito com o 165 quer saber se vale trocar — Garmin Pay, sensores extras e o pacote de ciclismo/natação costumam ser os argumentos decisivos.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p170, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Qual a diferença entre 170 e 170 Music?", "html": "<p>A versão Music adiciona armazenamento de música offline (Spotify, Amazon Music, Deezer) e suporte a fones sem fio, por US$ 50 a mais.</p>"},
      {"title": "Qual a autonomia de bateria?", "html": "<p>Modo smartwatch: até 10 dias (19 dias em economia). Só GPS: até 20h. Todos os sistemas: até 14h. Na versão Music, com música: GPS até 7,5h / todos os sistemas até 6,5h.</p>"},
      {"title": "Tem suporte a medidor de potência de bike?", "html": "<p>Sim, com o Garmin Cycling Coach guiando o treino — recurso que o Forerunner 70 não tem.</p>"},
      {"title": "Quais cores estão disponíveis?", "html": "<p>Preto/amarelo âmbar, whitestone/azul nuvem, verde-azulado/citron, vermelho-rosa/manga.</p>"},
      {"title": "Qual a diferença real pro Forerunner 970?", "html": "<p>O 970 é o topo de linha: mapeamento colorido completo com navegação, ECG, lanterna, titânio/safira e compatibilidade com a cinta HRM 600 — recursos bem além do 170, que foca em ser o pacote completo de entrada/intermediário.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 4. Forerunner 55 (referência) — visão geral + diferenciais só
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p55, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Forerunner 55</strong> é o smartwatch de GPS de entrada da Garmin, lançado em 2 de junho de 2021 — o modelo que o Forerunner 70 substitui na linha. Preço sugerido: US$ 199,99.</p><p><strong>Posicionamento original da Garmin:</strong> \"pra pessoas de todos os níveis de habilidade — especialmente quem tá começando a correr.\"</p><p>Referência aqui só pra comparação com o Forerunner 70 (modelo atual da mesma faixa) — não é mais o produto vendido pela loja.</p>"}
  ]}
  $j$),
  (v_p55, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tela MIP (não é touchscreen)", "html": "<p>Tela MIP (Memory-in-Pixel) transflativa de 1,04\", sem touchscreen — só os 5 botões físicos. Diferente da tela AMOLED do Forerunner 70.</p>"},
      {"title": "Bateria de até 2 semanas", "html": "<p>Modo smartwatch: até 14 dias. Só GPS: até 20h.</p>"},
      {"title": "Sensor cardíaco de 2 painéis", "html": "<p>Sensor óptico de frequência cardíaca com 2 painéis de luz, contra 4 painéis no Forerunner 70.</p>"},
      {"title": "Treino guiado básico", "html": "<p>Treinos sugeridos diariamente e detecção de corrida/caminhada — sem Training Readiness nem Training Status, recursos que só chegaram em gerações posteriores.</p>"},
      {"title": "Recursos de saúde", "html": "<p>Monitoramento de estresse, Body Battery e minutos de intensidade.</p>"},
      {"title": "Cores originais", "html": "<p>Preto, branco ou aqua.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 5. Forerunner 165 (referência) — visão geral + diferenciais só
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p165, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Forerunner 165</strong> é o smartwatch de GPS com tela AMOLED que o Forerunner 170 substitui na linha, lançado em 20 de fevereiro de 2024. Também vendido na versão Forerunner 165 Music. Preço sugerido: US$ 249,99 (165) / US$ 299,99 (165 Music).</p><p><strong>Posicionamento original da Garmin:</strong> smartwatch de GPS acessível com planos de treino adaptativos personalizados, pra atletas de todos os níveis, do primeiro 5km à busca por recorde pessoal.</p><p>Referência aqui só pra comparação com o Forerunner 170 (modelo atual da mesma faixa) — não é mais o produto vendido pela loja.</p>"}
  ]}
  $j$),
  (v_p165, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tela AMOLED touchscreen + 5 botões", "html": "<p>Tela de 1,2\" AMOLED com touchscreen — a mesma base de tela que o Forerunner 170 herda.</p>"},
      {"title": "Bateria de até 11 dias", "html": "<p>Modo smartwatch: até 11 dias. Só GPS: até 19h.</p>"},
      {"title": "Armazenamento de música (até 4 GB)", "html": "<p>Na versão 165 Music — armazenamento de até 4 GB de playlists.</p>"},
      {"title": "Planos de treino adaptativos", "html": "<p>Planos de treino guiados com previsão de tempo de prova, e dinâmica de corrida básica (cadência, comprimento de passada, tempo de contato com o solo) — sem Training Readiness, Training Status nem Potência de Corrida completos, que chegaram só com o Forerunner 170.</p>"},
      {"title": "25+ perfis de atividade", "html": "<p>Incluindo corrida em trilha e natação em piscina.</p>"},
      {"title": "Recursos de saúde", "html": "<p>Monitoramento de sono com pontuação e detecção de soneca, Pulse Ox, Body Battery, Garmin Pay e rastreamento do ciclo menstrual.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 6. Quiz Especialista — Forerunner 70
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-forerunner-70', 'Quiz Especialista: Forerunner 70', 70, true)
  returning id into v_quiz70;

  insert into questions (quiz_id, body, order_index) values (v_quiz70, 'O Forerunner 70 tem Garmin Pay?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é exclusivo do Forerunner 170', true, 1), (v_q, 'Sim, igual ao 170', false, 2), (v_q, 'Só na cor preta', false, 3), (v_q, 'Sim, mas só com assinatura', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz70, 'Qual a autonomia máxima em modo smartwatch do Forerunner 70?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 13 dias', true, 1), (v_q, 'Até 10 dias', false, 2), (v_q, 'Até 20 dias', false, 3), (v_q, 'Até 7 dias', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz70, 'Quais recursos de treino o Forerunner 70 traz dos Forerunners mais avançados?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Training Readiness e Training Status', true, 1), (v_q, 'ECG e mapeamento colorido', false, 2), (v_q, 'Lanterna e bússola', false, 3), (v_q, 'Nenhum recurso avançado', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz70, 'O Forerunner 70 suporta medidor de potência de ciclismo?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é exclusivo do Forerunner 170', true, 1), (v_q, 'Sim, igual ao 170', false, 2), (v_q, 'Só com acessório extra vendido separadamente', false, 3), (v_q, 'Sim, mas sem o Cycling Coach', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz70, 'Quantas cores o Forerunner 70 tem disponíveis?', 5) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '6 cores', true, 1), (v_q, '2 cores', false, 2), (v_q, '4 cores', false, 3), (v_q, 'Só 1 cor', false, 4);

  -- ==========================================================================
  -- 7. Quiz Especialista — Forerunner 170
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-forerunner-170', 'Quiz Especialista: Forerunner 170', 70, true)
  returning id into v_quiz170;

  insert into questions (quiz_id, body, order_index) values (v_quiz170, 'Qual recurso de pagamento o Forerunner 170 tem que o 70 não tem?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Garmin Pay', true, 1), (v_q, 'Nenhum, os dois têm', false, 2), (v_q, 'Cartão NFC separado', false, 3), (v_q, 'PIX pelo relógio', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz170, 'Quais sensores o Forerunner 170 tem a mais que o 70?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Altímetro barométrico, bússola, giroscópio e termômetro', true, 1), (v_q, 'ECG e oxímetro', false, 2), (v_q, 'Nenhum sensor extra', false, 3), (v_q, 'Só o giroscópio', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz170, 'O que a versão Forerunner 170 Music adiciona?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Armazenamento de música offline e suporte a fones sem fio', true, 1), (v_q, 'Bateria maior', false, 2), (v_q, 'Tela maior', false, 3), (v_q, 'GPS multibanda', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz170, 'Qual a autonomia máxima em modo smartwatch do Forerunner 170?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 10 dias', true, 1), (v_q, 'Até 13 dias', false, 2), (v_q, 'Até 20 dias', false, 3), (v_q, 'Até 5 dias', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz170, 'O Forerunner 170 suporta natação em águas abertas?', 5) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Sim, com modo dedicado — o 70 não tem esse modo', true, 1), (v_q, 'Não, nenhum dos dois tem', false, 2), (v_q, 'Só na piscina', false, 3), (v_q, 'Sim, mas o 70 também tem', false, 4);

  -- ==========================================================================
  -- 8. Ligação produto → quiz
  -- ==========================================================================
  insert into product_quizzes (product_id, quiz_id) values (v_p70, v_quiz70), (v_p170, v_quiz170);

  -- ==========================================================================
  -- 9. Badges "Especialista em <produto>"
  -- ==========================================================================
  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-forerunner-70-garmin', 'Especialista Forerunner 70', 'Concedido ao passar no Quiz Especialista do Forerunner 70.', '{"tipo": "quiz_especialista_produto", "produto": "forerunner-70"}'),
  (v_brand_id, 'especialista-forerunner-170-garmin', 'Especialista Forerunner 170', 'Concedido ao passar no Quiz Especialista do Forerunner 170.', '{"tipo": "quiz_especialista_produto", "produto": "forerunner-170"}');

  -- ==========================================================================
  -- 10. Comparativo Forerunner 70 x Forerunner 55
  -- ==========================================================================
  insert into product_comparisons (brand_id, product_a_id, product_b_id, slug, title, resumo_executivo, blocks, is_published)
  values (
    v_brand_id, v_p70, v_p55, 'forerunner-70-vs-forerunner-55',
    'Forerunner 70 vs Forerunner 55',
    'O Forerunner 70 (2026) é o sucessor direto do Forerunner 55 (2021) na faixa de entrada da Garmin. O salto principal é a tela — de MIP sem touch pra AMOLED touchscreen — e a chegada de Training Readiness e Training Status, recursos que não existiam quando o 55 foi lançado. Em troca, o 55 tem bateria bem mais longa (até 2 semanas contra 13 dias do 70), por consumir bem menos energia com a tela mais simples.',
    $j$
    [
      {"type": "card_grid", "columns": 2, "items": [
        {"title": "Vantagens do Forerunner 70", "text": "Tela AMOLED touchscreen (contra MIP sem touch) · Training Readiness e Training Status (o 55 não tem) · Sensor cardíaco com mais painéis (4 vs 2) · Potência e dinâmica de corrida no pulso", "tags": [{"label": "70", "color": "blue"}]},
        {"title": "Vantagens do Forerunner 55", "text": "Bateria bem mais longa (até 14 dias vs 13 dias — praticamente empatado, mas com tela mais simples que gasta menos) · Preço mais baixo (US$ 199,99 vs US$ 249,99) — quando ainda disponível", "tags": [{"label": "55", "color": "gold"}]}
      ]},
      {"type": "objecao", "items": [
        {"question": "Vale a pena trocar o 55 pelo 70?", "answer": "Sim, se o cliente quer tela touchscreen mais moderna e Training Readiness/Status — recursos que simplesmente não existiam na geração do 55. Se o cliente só quer contar km e não liga pra tela, o 55 (enquanto durar estoque) ainda cumpre o básico."},
        {"question": "O 55 ainda é vendido oficialmente?", "answer": "Foi substituído pelo Forerunner 70 na linha atual da Garmin — trate como referência de comparação/legado, não como produto ativo de catálogo."}
      ]}
    ]
    $j$,
    true
  ) returning id into v_comp70x55;

  insert into comparison_items (comparison_id, spec_label, value_a, value_b, winner, order_index) values
  (v_comp70x55, 'Preço sugerido (lançamento)', 'US$ 249,99', 'US$ 199,99', 'b', 1),
  (v_comp70x55, 'Tela', 'AMOLED touchscreen 1,2"', 'MIP transflativa 1,04" (sem touch)', 'a', 2),
  (v_comp70x55, 'Bateria — modo smartwatch', 'Até 13 dias', 'Até 14 dias', 'b', 3),
  (v_comp70x55, 'Bateria — só GPS', 'Até 23h', 'Até 20h', 'a', 4),
  (v_comp70x55, 'Training Readiness / Training Status', 'Sim', 'Não', 'a', 5),
  (v_comp70x55, 'Potência de corrida no pulso', 'Sim', 'Não', 'a', 6),
  (v_comp70x55, 'Sensor cardíaco', '4 painéis de luz', '2 painéis de luz', 'a', 7),
  (v_comp70x55, 'Garmin Coach', 'Sim', 'Treino sugerido básico', 'a', 8),
  (v_comp70x55, 'Resistência à água', '5 ATM', '5 ATM', 'tie', 9);

  -- ==========================================================================
  -- 11. Comparativo Forerunner 170 x Forerunner 165
  -- ==========================================================================
  insert into product_comparisons (brand_id, product_a_id, product_b_id, slug, title, resumo_executivo, blocks, is_published)
  values (
    v_brand_id, v_p170, v_p165, 'forerunner-170-vs-forerunner-165',
    'Forerunner 170 vs Forerunner 165',
    'O Forerunner 170 (2026) herda a caixa, a tela AMOLED de 1,2" e o sensor Elevate Gen 4 do Forerunner 165 (2024), mas chega com uma camada de software bem mais avançada: Training Readiness, Training Status, Potência e Dinâmica de Corrida completos e Garmin Cycling Coach — recursos que o 165 não tem. Também adiciona Garmin Pay, altímetro barométrico, bússola, giroscópio, termômetro, suporte a medidor de potência de ciclismo e natação em águas abertas.',
    $j$
    [
      {"type": "card_grid", "columns": 2, "items": [
        {"title": "Vantagens do Forerunner 170", "text": "Training Readiness, Training Status e Potência de Corrida completos (o 165 só tem dinâmica básica) · Altímetro barométrico, bússola, giroscópio, termômetro · Suporte a medidor de potência de ciclismo · Natação em águas abertas · Garmin Cycling Coach", "tags": [{"label": "170", "color": "blue"}]},
        {"title": "Vantagens do Forerunner 165", "text": "Preço mais baixo enquanto disponível (US$ 249,99 vs US$ 299,99) · Bateria similar (11 dias vs 10 dias do 170) — praticamente empatado", "tags": [{"label": "165", "color": "gold"}]}
      ]},
      {"type": "objecao", "items": [
        {"question": "Vale a pena trocar o 165 pelo 170?", "answer": "Vale se o cliente quer Training Readiness/Status, pratica ciclismo com medidor de potência, nada em águas abertas ou quer pagar com o pulso (Garmin Pay) — recursos que o 165 não tem. Se o cliente só corre e não usa nenhum desses, a diferença é menor."},
        {"question": "A tela do 170 é diferente da do 165?", "answer": "Não — o 170 herda a mesma tela AMOLED de 1,2\" e o mesmo sensor cardíaco Elevate Gen 4 do 165. A diferença real está no software (Training Readiness/Status/Power) e nos sensores extras (barômetro, bússola, giroscópio, termômetro)."}
      ]}
    ]
    $j$,
    true
  ) returning id into v_comp170x165;

  insert into comparison_items (comparison_id, spec_label, value_a, value_b, winner, order_index) values
  (v_comp170x165, 'Preço sugerido (lançamento)', 'US$ 299,99', 'US$ 249,99', 'b', 1),
  (v_comp170x165, 'Tela', 'AMOLED touchscreen 1,2"', 'AMOLED touchscreen 1,2"', 'tie', 2),
  (v_comp170x165, 'Bateria — modo smartwatch', 'Até 10 dias', 'Até 11 dias', 'b', 3),
  (v_comp170x165, 'Bateria — só GPS', 'Até 20h', 'Até 19h', 'a', 4),
  (v_comp170x165, 'Training Readiness / Training Status', 'Sim', 'Não', 'a', 5),
  (v_comp170x165, 'Potência de corrida no pulso (completa)', 'Sim', 'Só dinâmica básica', 'a', 6),
  (v_comp170x165, 'Garmin Pay', 'Sim', 'Sim', 'tie', 7),
  (v_comp170x165, 'Altímetro barométrico / bússola / giroscópio / termômetro', 'Sim', 'Não', 'a', 8),
  (v_comp170x165, 'Suporte a medidor de potência de ciclismo', 'Sim', 'Não', 'a', 9),
  (v_comp170x165, 'Natação em águas abertas', 'Sim', 'Só piscina', 'a', 10),
  (v_comp170x165, 'Resistência à água', '5 ATM', '5 ATM', 'tie', 11);

  -- ==========================================================================
  -- 12. Grafo de conhecimento — relacionados
  -- ==========================================================================
  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index) values
  (v_p70, v_p170, null, 'upgrade', 1),
  (v_p70, v_p55, null, 'antecessor', 2),
  (v_p70, null, 'Training Readiness', 'metrica', 3),
  (v_p70, null, 'Garmin Coach', 'funcionalidade', 4),
  (v_p170, v_p70, null, 'entrada', 1),
  (v_p170, v_p165, null, 'antecessor', 2),
  (v_p170, null, 'Garmin Pay', 'funcionalidade', 3),
  (v_p170, null, 'Ciclismo + Natação em águas abertas', 'funcionalidade', 4);

  -- Liga também o 70/170 aos irmãos de topo de linha (570/970), quando já
  -- existirem no banco (seed de sql/065) — não falha se não existirem.
  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index)
  select v_p170, id, null, 'upgrade', 5 from products where slug = 'forerunner-570';
  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index)
  select v_p70, id, null, 'topo_de_linha', 5 from products where slug = 'forerunner-970';
end $$;
