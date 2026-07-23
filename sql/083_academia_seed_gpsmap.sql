-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 083: Academia de Produtos — GPSMAP 65,
-- GPSMAP 66sr, GPSMAP 67 e GPSMAP 86sci
-- ============================================================================
-- Pedido do usuário (2026-07-21): "gpsmap 65 67 69 e 89".
--
-- CORREÇÃO DE NOMENCLATURA IMPORTANTE (mesma disciplina de transparência já
-- usada no caso do ECHOMAP UHD 52cv → UHD2 52cv em sql/078):
--   - "GPSMAP 69" NÃO EXISTE no catálogo oficial da Garmin. A linha real de
--     GPS de mão outdoor da Garmin é 65 / 66 / 67 (confirmado inclusive por
--     página oficial de comparação da central de suporte: "Comparing the
--     GPSMAP 65, 66, and 67 Series"). O modelo real mais próximo do "69"
--     pedido é o GPSMAP 66sr — a variante de meio de linha que fica entre o
--     65 (entrada) e o 67 (topo mais recente).
--   - "GPSMAP 89" NÃO EXISTE. A linha real de GPS de mão NÁUTICO da Garmin
--     é a GPSMAP 79 e a GPSMAP 86 (não existe "89"). O modelo real mais
--     próximo é o GPSMAP 86sci — o topo de linha náutico, com inReach e
--     cartas BlueChart g3 embutidas.
--   Documentado aqui com transparência, seguindo o mesmo padrão já usado
--   antes — não é erro de digitação do usuário sendo ignorado, é a
--   correção sendo registrada abertamente.
--
-- Estrutura (três produtos outdoor da MESMA geração/lançamento + um produto
-- náutico à parte — não são todos sucessor/antecessor em linha reta):
--   - GPSMAP 65 e GPSMAP 66sr: lançados no MESMO dia (24/set/2020), como
--     tiers diferentes (65 = entrada, 66sr = topo dessa geração) — não há
--     relação de sucessão entre eles, por isso NENHUM dos dois recebe aba
--     "novidades" (mesmo tratamento dado ao Rally 100/200 nesta Academia).
--   - GPSMAP 67 (14/mar/2023): sucessor cronológico do 66sr — a própria
--     Garmin afirma oficialmente "5x mais bateria que a série GPSMAP 66" —
--     por isso o 67 SIM recebe aba "novidades" comparando com o 66sr.
--   - GPSMAP 86sci (10/set/2019): produto náutico à parte, sem comparação
--     oficial direta encontrada com outro handheld GPSMAP — entra sem
--     aba "novidades", mesmo tratamento do Striker 4 (sem antecessor
--     comparável documentado).
--
-- FONTES — só oficiais:
--   - GPSMAP 65/65s/66sr: garmin.com/en-US/newsroom/press-release/outdoor/
--     2020-adventurers-trek-with-enhanced-accuracy-with-garmin-gpsmap-66sr-
--     and-65-series-handhelds/
--   - GPSMAP 67/67i: garmin.com/en-US/newsroom/press-release/outdoor/
--     find-your-path-with-new-handheld-gps-devices-from-garmin/
--   - GPSMAP 86 series: garmin.com/en-US/newsroom/press-release/marine/
--     2019-garmin-unveils-the-all-new-gpsmap-86-marine-handheld-series-with-
--     global-communication-bluechart-g3-and-chartplotter-connectivity/
-- ============================================================================

do $$
declare
  v_brand_id uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_gps  uuid;
  v_cat_nau  uuid;
  v_p_65     uuid;
  v_p_66sr   uuid;
  v_p_67     uuid;
  v_p_86sci  uuid;
  v_quiz     uuid;
  v_q        uuid;
begin
  select id into v_cat_gps from product_categories where slug = 'gps-de-mao' and brand_id = v_brand_id;
  select id into v_cat_nau from product_categories where slug = 'pesca-nautica' and brand_id = v_brand_id;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index) values
  (v_brand_id, v_cat_gps, 'gpsmap-65', 'GPSMAP 65', '010-02451', 'GPS de mão outdoor de entrada com GNSS multibanda, tela de 2.6"', true, 3),
  (v_brand_id, v_cat_gps, 'gpsmap-66sr', 'GPSMAP 66sr', '010-02236', 'GPS de mão outdoor com sensores ABC, bateria recarregável de longa duração e download de imagem de satélite', true, 4),
  (v_brand_id, v_cat_gps, 'gpsmap-67', 'GPSMAP 67', '010-02540', 'GPS de mão outdoor topo de linha com tela de 3" e até 5x mais bateria que a geração anterior', true, 5),
  (v_brand_id, v_cat_nau, 'gpsmap-86sci', 'GPSMAP 86sci', '010-02236-02', 'GPS de mão náutico topo de linha com inReach embutido e cartas BlueChart g3', true, 6);
  select id into v_p_65 from products where slug = 'gpsmap-65';
  select id into v_p_66sr from products where slug = 'gpsmap-66sr';
  select id into v_p_67 from products where slug = 'gpsmap-67';
  select id into v_p_86sci from products where slug = 'gpsmap-86sci';

  -- ==========================================================================
  -- GPSMAP 65
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_65, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>GPSMAP 65</strong>, lançado em 24 de setembro de 2020, é o GPS de mão outdoor de entrada da Garmin — um dos primeiros handhelds da marca com GNSS multibanda.</p><p><strong>Público-alvo:</strong> trilheiro ou caçador que quer um GPS de mão robusto com tela colorida e boa precisão, sem pagar pelos sensores ABC ou pela bateria de longa duração do 66sr.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela colorida de 2.6\"", "text": "Legível sob sol direto.", "tags": []},
      {"title": "GNSS multibanda", "text": "Um dos primeiros handhelds Garmin com essa tecnologia.", "tags": []},
      {"title": "Mapas TopoActive pré-carregados", "text": "EUA e Canadá inclusos.", "tags": []},
      {"title": "Bateria de 16h em modo GPS", "text": "Boa autonomia pra trilha de um dia.", "tags": []},
      {"title": "Resistência IPX7", "text": "Protegido contra chuva e imersão acidental.", "tags": []},
      {"title": "Sem sensores ABC", "text": "Altímetro/bússola calculados por GPS — pra sensores dedicados, ver o 65s ou o 66sr.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_65, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Trilheiro casual", "text": "Quer um GPS de mão colorido e confiável, sem gastar no topo de linha.", "tags": [{"label": "Entrada", "color": "green"}]},
      {"title": "Caçador em trilha de um dia", "text": "16h de bateria já cobre a maioria dos usos.", "tags": [{"label": "Uso diário", "color": "blue"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer GPSMAP colorido com bom preço de entrada</li><li>Cliente não precisa de altímetro barométrico dedicado</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer sensores ABC dedicados → indicar o GPSMAP 65s ou o 66sr</li><li>Cliente quer bateria recarregável de longuíssima duração → indicar o 66sr</li><li>Cliente quer o modelo mais recente com mais bateria → indicar o GPSMAP 67</li></ul>"}
  ]}
  $j$),
  (v_p_65, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "GNSS multibanda", "html": "<p>Um dos primeiros handhelds Garmin a captar múltiplas frequências de satélite (GPS, GLONASS, Galileo, QZSS, IRNSS com L5), melhorando muito a precisão em terreno difícil.</p>"},
      {"title": "Tela colorida de 2.6\" legível sob sol", "html": "<p>Boa visibilidade mesmo em luz direta forte.</p>"},
      {"title": "Mapas TopoActive pré-carregados", "html": "<p>EUA e Canadá já incluídos de fábrica.</p>"},
      {"title": "Resistência IPX7", "html": "<p>Protegido contra chuva forte e imersão acidental.</p>"}
    ]}
  ]}
  $j$),
  (v_p_65, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo multibanda", "dialog": "O GPSMAP 65 foi um dos primeiros GPS de mão da Garmin a captar múltiplas frequências de satélite — muito mais preciso em mata fechada ou cânion que um GPS comum.", "tip": "Bom argumento técnico pra trilheiro exigente."},
      {"title": "Fechamento", "dialog": "Com o GPSMAP 65 você sai com tela colorida, GNSS multibanda e mapas pré-carregados — um GPS de mão robusto de entrada.", "tip": "Se o cliente quer sensores ABC, ofereça o 65s ou o 66sr."}
    ]}
  ]}
  $j$),
  (v_p_65, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não tem altímetro/bússola dedicados?", "answer": "É a versão de entrada — pra sensores ABC dedicados, existe o GPSMAP 65s (mesma base, com sensores) ou o 66sr (topo de linha dessa geração)."},
      {"question": "Por que não o GPSMAP 67, que é mais novo?", "answer": "O 67 tem até 5x mais bateria e tela maior (3\"), mas custa mais. Se o orçamento for prioridade, o 65 já entrega GNSS multibanda e boa autonomia por um preço de entrada."}
    ]}
  ]}
  $j$),
  (v_p_65, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Trilheiro de trilha de um dia", "text": "16h de bateria cobrem bem o uso típico.", "tags": []},
      {"title": "Cliente com orçamento de entrada", "text": "Quer GNSS multibanda sem pagar pelo topo de linha.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_65, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Qual a diferença pro GPSMAP 65s?", "html": "<p>O 65s adiciona altímetro barométrico, barômetro e bússola de 3 eixos — o resto é igual.</p>"},
      {"title": "Qual a diferença pro 66sr?", "html": "<p>O 66sr tem tela maior (3\"), sensores ABC de fábrica, bateria recarregável de até 450h em modo Expedição e download de imagem de satélite — mas custa mais.</p>"},
      {"title": "Usa pilha ou bateria recarregável?", "html": "<p>O material oficial do lançamento não detalha o tipo de bateria do 65/65s especificamente — o 66sr é confirmado como Li-ion recarregável.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- GPSMAP 66sr
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_66sr, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>GPSMAP 66sr</strong>, lançado em 24 de setembro de 2020 junto com o GPSMAP 65, é o topo de linha outdoor dessa geração — tela maior, sensores ABC de fábrica e bateria recarregável de longuíssima duração.</p><p><strong>Público-alvo:</strong> trilheiro ou expedicionário que quer o GPS de mão mais completo dessa geração, com altímetro/bússola dedicados e bateria pra dias de uso.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela colorida de 3\"", "text": "Maior que a do GPSMAP 65.", "tags": []},
      {"title": "Sensores ABC de fábrica", "text": "Altímetro, barômetro e bússola eletrônica de 3 eixos.", "tags": []},
      {"title": "GNSS multibanda", "text": "Máxima precisão em terreno difícil.", "tags": []},
      {"title": "Bateria de até 36h (450h Expedição)", "text": "Li-ion recarregável.", "tags": []},
      {"title": "Download de imagem de satélite", "text": "Recurso exclusivo dessa geração de topo.", "tags": []},
      {"title": "Resistência IPX7", "text": "Protegido contra chuva e imersão acidental.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_66sr, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Expedicionário de vários dias", "text": "A bateria de até 450h em modo Expedição cobre trilhas longas.", "tags": [{"label": "Expedição", "color": "blue"}]},
      {"title": "Montanhista técnico", "text": "Usa o altímetro barométrico dedicado pra controle preciso de altitude.", "tags": [{"label": "Montanhismo", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer sensores ABC de fábrica e bateria de longa duração</li><li>Cliente faz expedição de vários dias sem acesso a energia</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer o modelo mais recente com ainda mais bateria → indicar o GPSMAP 67</li><li>Cliente não precisa de sensores ABC dedicados → o GPSMAP 65 já resolve por menos</li></ul>"}
  ]}
  $j$),
  (v_p_66sr, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Sensores ABC de fábrica", "html": "<p>Altímetro barométrico, barômetro e bússola eletrônica de 3 eixos já vêm de fábrica — sem depender de cálculo via GPS.</p>"},
      {"title": "Bateria recarregável de longa duração", "html": "<p>Até 36h em modo GPS ou até 450h em modo Expedição, com bateria Li-ion interna.</p>"},
      {"title": "GNSS multibanda", "html": "<p>Captação de múltiplas frequências de satélite pra precisão máxima em terreno difícil.</p>"},
      {"title": "Download de imagem de satélite", "html": "<p>Recurso exclusivo dessa geração de topo de linha outdoor.</p>"}
    ]}
  ]}
  $j$),
  (v_p_66sr, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela bateria de expedição", "dialog": "O GPSMAP 66sr chega a 450 horas de bateria em modo Expedição — dá pra levar numa trilha de várias semanas sem se preocupar com energia.", "tip": "Ótimo argumento pra expedicionário ou guia de trilha longa."},
      {"title": "Puxando os sensores ABC", "dialog": "Ele já vem com altímetro barométrico, barômetro e bússola de 3 eixos de fábrica — dados de altitude e direção muito mais precisos que cálculo por GPS.", "tip": "Bom argumento pra montanhista técnico."},
      {"title": "Fechamento", "dialog": "Com o GPSMAP 66sr você sai com tela grande, sensores ABC completos e bateria pra semanas de expedição.", "tip": "Se o orçamento permitir e o cliente quiser o mais recente, mencione o GPSMAP 67."}
    ]}
  ]}
  $j$),
  (v_p_66sr, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Vale mais que o GPSMAP 65?", "answer": "Sim, se o cliente quer sensores ABC de fábrica, tela maior e muito mais bateria — o 65 é a opção de entrada sem esses recursos."},
      {"question": "Por que não o GPSMAP 67, que é mais novo?", "answer": "O 67 tem até 5x mais bateria que a série 66 e bateria de lítio embutida — mas custa mais. Se o cliente já está satisfeito com a autonomia de 450h do 66sr, ele continua sendo uma excelente opção."}
    ]}
  ]}
  $j$),
  (v_p_66sr, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Guia de trilha de expedição longa", "text": "Usa a bateria de até 450h em modo Expedição.", "tags": []},
      {"title": "Montanhista técnico", "text": "Depende do altímetro barométrico dedicado.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_66sr, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Qual a diferença pro GPSMAP 65s?", "html": "<p>O 66sr tem tela maior (3\" contra 2.6\"), bateria recarregável muito mais duradoura e download de imagem de satélite — o 65s tem os mesmos sensores ABC, mas em corpo menor e bateria menor.</p>"},
      {"title": "Qual a diferença pro GPSMAP 67?", "html": "<p>O 67 é a geração seguinte, com até 5x mais bateria segundo a própria Garmin. Veja a aba \"O que há de novo?\" do GPSMAP 67 pra comparação completa.</p>"},
      {"title": "Tem inReach embutido?", "html": "<p>Não — pra comunicação satelital embutida em GPS de mão, seria necessário um modelo com \"i\" no nome, como o GPSMAP 67i.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- GPSMAP 67 + novidades vs 66sr
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_67, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>GPSMAP 67</strong>, lançado em 14 de março de 2023, é o GPS de mão outdoor topo de linha mais recente da Garmin — controlado por botão, com bateria de lítio embutida e até 5 vezes mais autonomia que a série GPSMAP 66.</p><p><strong>Público-alvo:</strong> trilheiro ou expedicionário que quer o GPS de mão mais atual da Garmin, com a maior autonomia de bateria já vista na linha.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela colorida de 3\"", "text": "Legível sob sol direto, controle por botão.", "tags": []},
      {"title": "GNSS multibanda", "text": "Múltiplas frequências de satélite pra máxima precisão.", "tags": []},
      {"title": "Até 5x mais bateria que a série 66", "text": "Bateria de lítio embutida, dado confirmado pela própria Garmin.", "tags": []},
      {"title": "Versão 67i com inReach", "text": "Comunicação satelital bidirecional e SOS interativo.", "tags": []},
      {"title": "Resistência IPX7", "text": "Protegido contra chuva e imersão acidental.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_67, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Trilheiro que quer o mais recente", "text": "Valoriza a maior autonomia de bateria da linha GPSMAP.", "tags": [{"label": "Tecnologia", "color": "blue"}]},
      {"title": "Expedicionário sem acesso a energia", "text": "A bateria de lítio embutida estica a autonomia muito além do 66sr.", "tags": [{"label": "Expedição", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer o GPS de mão outdoor mais recente e com mais bateria da Garmin</li><li>Cliente quer a opção de adicionar inReach (versão 67i)</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente já está satisfeito com a autonomia do 66sr e quer economizar → o 66sr continua sendo uma opção válida e mais em conta</li></ul>"}
  ]}
  $j$),
  (v_p_67, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Até 5x mais bateria que a série GPSMAP 66", "html": "<p>Dado confirmado oficialmente pela Garmin no lançamento — a maior autonomia já vista na linha GPSMAP de mão.</p>"},
      {"title": "Bateria de lítio embutida", "html": "<p>Substitui o formato anterior por uma bateria interna de lítio recarregável.</p>"},
      {"title": "GNSS multibanda", "html": "<p>Captação de múltiplas frequências de satélite pra precisão máxima.</p>"},
      {"title": "Versão 67i com inReach", "html": "<p>Adiciona comunicação satelital bidirecional e SOS interativo, mesma tecnologia usada nos comunicadores inReach.</p>"}
    ]}
  ]}
  $j$),
  (v_p_67, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado à <strong>série GPSMAP 66</strong> (66sr), a geração anterior de topo de linha outdoor."},
    {"type": "accordion", "items": [
      {"title": "Até 5x mais bateria (dado oficial da Garmin)", "html": "<p>A própria Garmin confirma esse ganho de autonomia no material de lançamento do 67 — a maior diferença dessa geração.</p>"},
      {"title": "Bateria de lítio embutida", "html": "<p>Design de bateria atualizado em relação ao 66sr.</p>"},
      {"title": "Versão 67i com inReach (opção nova)", "html": "<p>O 66sr não tinha variante com inReach embutido — o 67i introduz essa opção na linha GPSMAP outdoor.</p>"},
      {"title": "O que NÃO mudou (continua igual ao 66sr)", "html": "<p>GNSS multibanda e sensores ABC (altímetro, barômetro, bússola) já vinham do 66sr.</p>"}
    ]}
  ]}
  $j$),
  (v_p_67, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela bateria", "dialog": "O GPSMAP 67 tem até 5 vezes mais bateria que a série 66 — é a maior autonomia já vista num GPS de mão outdoor da Garmin.", "tip": "Ótimo argumento pra expedição longa ou uso profissional (guia de trilha, resgate)."},
      {"title": "Puxando a opção 67i com inReach", "dialog": "Se o cliente quer comunicação satelital de emergência embutida no próprio GPS de mão, existe a versão 67i, com SOS interativo via inReach.", "tip": "Bom argumento pra quem pergunta sobre segurança em área remota."},
      {"title": "Fechamento", "dialog": "Com o GPSMAP 67 você sai com o GPS de mão outdoor mais recente e com mais autonomia da Garmin.", "tip": "Confirme se o cliente precisa de comunicação satelital antes de decidir entre 67 e 67i."}
    ]}
  ]}
  $j$),
  (v_p_67, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Vale a pena trocar o 66sr pelo 67?", "answer": "Vale principalmente pela bateria — o ganho de autonomia é o argumento mais forte dessa geração. Se o cliente não precisa de mais bateria, o 66sr continua completo."},
      {"question": "Qual a diferença pro 67i?", "answer": "O 67i adiciona comunicação satelital inReach com SOS interativo — o 67 comum não tem essa capacidade."}
    ]}
  ]}
  $j$),
  (v_p_67, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Guia de trilha profissional", "text": "Precisa da maior autonomia de bateria disponível na linha.", "tags": []},
      {"title": "Cliente preocupado com segurança em área remota", "text": "Considera o 67i pelo SOS interativo via inReach.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_67, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Qual a real diferença pro 66sr?", "html": "<p>Principalmente a bateria (até 5x mais autonomia) e a opção de versão com inReach (67i). Veja a aba \"O que há de novo?\" pra comparação completa.</p>"},
      {"title": "O 67 comum tem inReach?", "html": "<p>Não — inReach é exclusivo da variante 67i.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- GPSMAP 86sci
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_86sci, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>GPSMAP 86sci</strong>, lançado em 10 de setembro de 2019, é o GPS de mão náutico topo de linha da Garmin — o primeiro handheld com cartas BlueChart g3 embutidas e comunicação satelital inReach ao mesmo tempo.</p><p><strong>Público-alvo:</strong> navegador/pescador que quer um GPS de mão robusto pra embarcação pequena, com cartas náuticas completas e SOS de emergência via satélite.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Cartas BlueChart g3 embutidas", "text": "Com dados Navionics integrados — primeiro handheld da Garmin com essa combinação.", "tags": []},
      {"title": "inReach embutido", "text": "Comunicação bidirecional e SOS interativo via satélite Iridium, cobertura mundial.", "tags": []},
      {"title": "Tela transflectiva de 3\"", "text": "Legível sob sol direto na água.", "tags": []},
      {"title": "WiFi, Bluetooth e ANT+", "text": "Conectividade completa com apps e sensores.", "tags": []},
      {"title": "Bateria de até 35h (200h Expedição)", "text": "Li-ion recarregável.", "tags": []},
      {"title": "Bússola de 3 eixos", "text": "Orientação precisa mesmo parado.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_86sci, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Pescador/navegador de embarcação pequena", "text": "Quer GPS de mão completo, sem instalar chartplotter fixo.", "tags": [{"label": "Náutico", "color": "blue"}]},
      {"title": "Navegador que se afasta da costa", "text": "Depende do inReach embutido pra SOS de emergência.", "tags": [{"label": "Segurança", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer cartas náuticas completas + comunicação satelital num único aparelho de mão</li><li>Cliente navega em áreas sem cobertura de celular</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente só precisa de GPS básico sem cartas nem inReach → existem variantes mais simples da série 86 (86s, 86sc)</li><li>Cliente quer chartplotter fixo de embarcação maior → indicar a linha ECHOMAP</li></ul>"}
  ]}
  $j$),
  (v_p_86sci, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Cartas BlueChart g3 + Navionics embutidas", "html": "<p>Primeiro handheld da Garmin a vir de fábrica com essa combinação de cartografia náutica.</p>"},
      {"title": "inReach embutido", "html": "<p>Comunicação bidirecional por mensagem de texto e SOS interativo via rede de satélites Iridium, com cobertura mundial — funciona mesmo sem sinal de celular.</p>"},
      {"title": "Conectividade completa", "html": "<p>WiFi, Bluetooth e ANT+ pra sincronizar com apps e sensores externos.</p>"},
      {"title": "Bússola eletrônica de 3 eixos", "html": "<p>Orientação precisa mesmo com a embarcação parada.</p>"},
      {"title": "Bateria de até 35h (200h em modo Expedição)", "html": "<p>Bateria de lítio recarregável interna.</p>"}
    ]}
  ]}
  $j$),
  (v_p_86sci, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelas cartas + inReach juntos", "dialog": "O GPSMAP 86sci foi o primeiro handheld da Garmin a juntar cartas náuticas BlueChart g3 completas com comunicação satelital inReach no mesmo aparelho — cartografia e segurança num só lugar.", "tip": "Ótimo argumento pra quem navega longe da costa em embarcação pequena."},
      {"title": "Puxando o SOS via satélite", "dialog": "Se acontecer uma emergência longe de sinal de celular, o inReach embutido manda um SOS interativo via satélite — a central de resposta consegue se comunicar em tempo real com você.", "tip": "Argumento de segurança forte, principalmente pra pesca oceânica ou travessia."},
      {"title": "Fechamento", "dialog": "Com o GPSMAP 86sci você sai com o GPS de mão náutico mais completo da Garmin — cartas, comunicação satelital e conectividade tudo junto.", "tip": "Confirme se o cliente já tem um plano de assinatura inReach ativo ou precisa contratar."}
    ]}
  ]}
  $j$),
  (v_p_86sci, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Preciso de assinatura pra usar o inReach?", "answer": "Sim — a comunicação satelital do inReach requer um plano de assinatura ativo (mensal ou anual), contratado separadamente com a Garmin."},
      {"question": "Existe versão mais em conta da série 86?", "answer": "Sim — a série 86 tem variantes sem cartas BlueChart (86s) ou sem inReach (86sc). O 86sci é o único que reúne os dois recursos ao mesmo tempo."},
      {"question": "Funciona como chartplotter de embarcação?", "answer": "É um GPS de mão portátil, não um chartplotter fixo — pra embarcação com console e instalação fixa, o caminho é a linha ECHOMAP."}
    ]}
  ]}
  $j$),
  (v_p_86sci, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Pescador de embarcação pequena sem console fixo", "text": "Leva o GPSMAP 86sci como solução portátil completa.", "tags": []},
      {"title": "Navegador que se afasta da costa", "text": "Depende do SOS via inReach embutido em caso de emergência.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_86sci, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "É à prova d'água?", "html": "<p>O material oficial confirma resistência da série pra uso náutico, mas o dado exato de classificação IPX não foi detalhado nesta pesquisa — vale confirmar na ficha técnica do produto físico antes de garantir ao cliente.</p>"},
      {"title": "Qual a diferença pro 86i?", "html": "<p>O 86i tem inReach, mas sem as cartas BlueChart g3 — o 86sci é o único modelo com os dois recursos juntos.</p>"},
      {"title": "Funciona fora d'água, em trilha terrestre também?", "html": "<p>Sim, é um GPS de mão completo — mas o foco de cartografia é náutico (BlueChart), diferente da série outdoor (65/66/67), que vem com mapas topográficos terrestres.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- Quiz Especialista — 4 produtos
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-gpsmap-65', 'Quiz Especialista: GPSMAP 65', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O GPSMAP 65 tem sensores ABC de fábrica?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — pra sensores dedicados, ver o 65s ou o 66sr', true, 1), (v_q, 'Sim, tem', false, 2), (v_q, 'Só o altímetro', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual o tamanho da tela do GPSMAP 65?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '2.6"', true, 1), (v_q, '3"', false, 2), (v_q, '5"', false, 3), (v_q, '1.5"', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-gpsmap-66sr', 'Quiz Especialista: GPSMAP 66sr', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Quantas horas de bateria o GPSMAP 66sr atinge em modo Expedição?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 450h', true, 1), (v_q, 'Até 50h', false, 2), (v_q, 'Até 1000h', false, 3), (v_q, 'Até 16h', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que são sensores ABC?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Altímetro, Barômetro e Compass (bússola)', true, 1), (v_q, 'Antena, Bateria e Carregador', false, 2), (v_q, 'Um tipo de mapa', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-gpsmap-67', 'Quiz Especialista: GPSMAP 67', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Comparado à série GPSMAP 66, o GPSMAP 67 tem quanto mais bateria?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 5x mais', true, 1), (v_q, 'Metade da bateria', false, 2), (v_q, 'A mesma bateria', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual variante do GPSMAP 67 tem inReach?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'GPSMAP 67i', true, 1), (v_q, 'GPSMAP 67 comum', false, 2), (v_q, 'Nenhuma variante tem', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-gpsmap-86sci', 'Quiz Especialista: GPSMAP 86sci', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que torna o GPSMAP 86sci único na série 86?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Único com cartas BlueChart g3 E inReach juntos', true, 1), (v_q, 'É o único à prova d''água', false, 2), (v_q, 'É o único com GPS', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O inReach do 86sci precisa de assinatura?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Sim, plano ativo contratado à parte', true, 1), (v_q, 'Não, é gratuito', false, 2), (v_q, 'Só em emergência real', false, 3), (v_q, 'Não sei', false, 4);

  insert into product_quizzes (product_id, quiz_id)
  select id, (select id from quizzes where slug = 'quiz-especialista-gpsmap-65') from products where slug = 'gpsmap-65'
  union all select id, (select id from quizzes where slug = 'quiz-especialista-gpsmap-66sr') from products where slug = 'gpsmap-66sr'
  union all select id, (select id from quizzes where slug = 'quiz-especialista-gpsmap-67') from products where slug = 'gpsmap-67'
  union all select id, (select id from quizzes where slug = 'quiz-especialista-gpsmap-86sci') from products where slug = 'gpsmap-86sci';

  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-gpsmap-65-garmin', 'Especialista GPSMAP 65', 'Concedido ao passar no Quiz Especialista do GPSMAP 65.', '{"tipo": "quiz_especialista_produto", "produto": "gpsmap-65"}'),
  (v_brand_id, 'especialista-gpsmap-66sr-garmin', 'Especialista GPSMAP 66sr', 'Concedido ao passar no Quiz Especialista do GPSMAP 66sr.', '{"tipo": "quiz_especialista_produto", "produto": "gpsmap-66sr"}'),
  (v_brand_id, 'especialista-gpsmap-67-garmin', 'Especialista GPSMAP 67', 'Concedido ao passar no Quiz Especialista do GPSMAP 67.', '{"tipo": "quiz_especialista_produto", "produto": "gpsmap-67"}'),
  (v_brand_id, 'especialista-gpsmap-86sci-garmin', 'Especialista GPSMAP 86sci', 'Concedido ao passar no Quiz Especialista do GPSMAP 86sci.', '{"tipo": "quiz_especialista_produto", "produto": "gpsmap-86sci"}');

  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index) values
  (v_p_65, v_p_66sr, null, 'variante_topo', 1),
  (v_p_66sr, v_p_65, null, 'variante_entrada', 1),
  (v_p_66sr, v_p_67, null, 'upgrade', 2),
  (v_p_67, v_p_66sr, null, 'entrada', 1);
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 083
-- ============================================================================
