-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 077: Academia de Produtos — Instinct 3
-- ============================================================================
-- Pedido do usuário (2026-07-21): "faça o mesmo que vc fez pro fenix e pra
-- linha instinct" — produto completo (7 seções + aba "O que há de novo?" +
-- quiz especialista + badge), mesmo padrão do Fenix 8. Instinct 2 (2022) só
-- entra como referência de pesquisa pra sustentar a aba de novidades — não
-- vira produto próprio (mesmo tratamento do Fenix 7/Descent Mk2/G1).
--
-- Categoria: reaproveita "Aventura & Multiesporte" (mesma do Fenix 8) —
-- Instinct é linha rugged/outdoor, mesmo segmento.
--
-- Sem preços em US$ (padrão já adotado nesta sessão).
--
-- FONTES — só oficiais:
--   - Instinct 3 (06/01/2025): garmin.com/en-US/newsroom/press-release/
--     outdoor/introducing-the-instinct-3-series-from-garmin-rugged-
--     smartwatches-now-with-amoled-displays/
--   - Instinct 2 (09/02/2022): garmin.com/en-US/newsroom/press-release/
--     sports-fitness/stand-out-in-a-crowd-with-garmin-instinct-2-series/
--
-- Achado crítico que vale registrar (o usuário já pegou um erro parecido
-- antes — bateria/multibanda do Venu 4 — então isso foi checado com
-- cuidado redobrado): o Instinct 2 NÃO tem GPS multibanda, lanterna LED
-- nem touchscreen — nenhum desses três recursos é mencionado no press
-- release oficial do Instinct 2. Os três chegam como PADRÃO em todos os
-- modelos do Instinct 3 (confirmado explicitamente: "built-in Flashlight
-- and Multi-Band GNSS with SatIQ technology as standard features"). Não
-- confundir com o Instinct E (variante mais simples DENTRO da geração 3,
-- não um antecessor) — o jogo "Duelo Instinct 3 vs Instinct E" já existente
-- no app (sql/seeds/030) documenta essa comparação à parte, sem relação
-- com a aba de novidades deste produto (que compara 3 contra 2).
-- ============================================================================

do $$
declare
  v_brand_id     uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_id       uuid;
  v_p_instinct3  uuid;
  v_quiz         uuid;
  v_q            uuid;
begin
  select id into v_cat_id from product_categories where brand_id = v_brand_id and slug = 'aventura-multiesporte';

  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index)
  values (v_brand_id, v_cat_id, 'instinct-3', 'Instinct 3', '010-02785', 'Smartwatch rugged com AMOLED ou Solar, lanterna e GPS multibanda de série', true, 2)
  returning id into v_p_instinct3;

  insert into product_sections (product_id, section_type, payload) values
  (v_p_instinct3, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Instinct 3</strong> é o smartwatch rugged de entrada premium da Garmin, lançado em 6 de janeiro de 2025 — o primeiro Instinct com opção de tela AMOLED, além da tradicional versão Solar.</p><p><strong>Público-alvo:</strong> quem quer um relógio outdoor extremamente resistente, com GPS multibanda e lanterna já de série, sem pagar o preço do Fenix.</p><p>Disponível em 45mm e 50mm, nas versões AMOLED ou Solar (MIP), com edição limitada Tropical Pulse Collection.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "AMOLED ou Solar", "text": "Duas opções de tela — AMOLED vibrante ou Solar com bateria praticamente ilimitada.", "tags": []},
      {"title": "Lanterna LED de série", "text": "Intensidade variável, luz vermelha e modo estroboscópio — em todos os modelos.", "tags": []},
      {"title": "GPS multibanda SatIQ de série", "text": "Mais precisão e economia de bateria automáticas, sem exigir modelo top de linha.", "tags": []},
      {"title": "Garmin Messenger", "text": "Mensagens de texto bidirecionais direto do relógio.", "tags": []},
      {"title": "MIL-STD 810 + 100m de resistência à água", "text": "Construído pra aguentar impacto, temperatura extrema e submersão.", "tags": []},
      {"title": "Bateria de até 24 dias (AMOLED)", "text": "Ou praticamente ilimitada na versão Solar.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_instinct3, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Quem quer robustez sem pagar o Fenix", "text": "Precisa de um relógio que aguente qualquer ambiente, com orçamento mais enxuto.", "tags": [{"label": "Custo-benefício", "color": "gold"}]},
      {"title": "Quem faz expedição longa", "text": "A versão Solar oferece bateria praticamente ilimitada pra quem passa dias fora de tomada.", "tags": [{"label": "Expedição", "color": "green"}]},
      {"title": "Quem quer lanterna e GPS multibanda sem topo de linha", "text": "Recursos que antes eram exclusivos de relógios mais caros, agora de série no Instinct 3.", "tags": [{"label": "Outdoor", "color": "blue"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer robustez militar (MIL-STD 810) sem pagar o preço do Fenix</li><li>Cliente valoriza autonomia de bateria acima de tudo → indicar a versão Solar</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer mapas coloridos com navegação turn-by-turn ou mergulho → só o Fenix 8 tem</li><li>Cliente quer o visual mais premium (titânio, safira) → Fenix é mais indicado</li></ul>"}
  ]}
  $j$),
  (v_p_instinct3, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tela AMOLED ou Solar", "html": "<p>AMOLED vibrante (45mm/50mm) ou Solar MIP com carregamento solar (45mm/50mm) — o cliente escolhe.</p>"},
      {"title": "Lanterna LED (todos os modelos)", "html": "<p>Intensidade variável, luz vermelha pra não atrapalhar a visão noturna e modo estroboscópio.</p>"},
      {"title": "GPS multibanda SatIQ (todos os modelos)", "html": "<p>Ajusta automaticamente entre bandas de satélite pra equilibrar precisão e economia de bateria.</p>"},
      {"title": "Garmin Messenger", "html": "<p>Mensagens de texto bidirecionais direto do relógio (exige o app instalado nos dois celulares pareados).</p>"},
      {"title": "Garmin Pay", "html": "<p>Pagamento por aproximação em provedores participantes.</p>"},
      {"title": "Construção MIL-STD 810", "html": "<p>Case de polímero reforçado com fibra e bisel reforçado com metal, testado contra impacto térmico e mecânico. Resistência à água de 100 metros.</p>"},
      {"title": "Bateria por modo de uso", "html": "<p>AMOLED: até 24 dias em modo smartwatch. Solar: bateria praticamente ilimitada (com 3h diárias ao ar livre em 50.000 lux) — o 50mm Solar tem mais de 5x a autonomia em modo GPS do Instinct 2 Solar.</p>"},
      {"title": "Relatório Matinal + Status de HRV", "html": "<p>Resumo de sono, agenda e status de variabilidade da frequência cardíaca ao acordar.</p>"},
      {"title": "Saúde da mulher", "html": "<p>Rastreamento de ciclo menstrual, gravidez e orientação de exercício/nutrição.</p>"},
      {"title": "Navegação embutida", "html": "<p>Altímetro, barômetro, bússola eletrônica de 3 eixos e roteamento TracBack (retorno ao ponto de partida).</p>"},
      {"title": "80+ apps esportivos", "html": "<p>Trilha, corrida, ciclismo, golfe, pesca, esqui, HIIT, cardio, pickleball, basquete e mais — com Garmin Coach e 1.600+ exercícios via Garmin Connect.</p>"}
    ]}
  ]}
  $j$),
  (v_p_instinct3, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Instinct 2</strong> (2022), o modelo direto que o Instinct 3 substitui. Não confundir com o Instinct E — essa é uma variante mais simples DENTRO da própria geração 3, não um antecessor."},
    {"type": "accordion", "items": [
      {"title": "Opção de tela AMOLED", "html": "<p>O Instinct 2 não tinha opção AMOLED — só tela de alto contraste (com ou sem solar). O Instinct 3 introduz o AMOLED como opção nova.</p>"},
      {"title": "Lanterna LED de série", "html": "<p>Recurso totalmente novo — o press release oficial do Instinct 2 não menciona lanterna em nenhum modelo.</p>"},
      {"title": "GPS multibanda com SatIQ", "html": "<p>Também novo — o Instinct 2 não tinha GPS multibanda (o press release oficial não menciona essa tecnologia).</p>"},
      {"title": "Garmin Messenger", "html": "<p>Mensagens de texto bidirecionais — recurso novo, não existia no Instinct 2.</p>"},
      {"title": "Relatório Matinal + Status de HRV explícito", "html": "<p>O Instinct 2 tinha monitoramento de saúde geral, mas sem esses dois recursos específicos.</p>"},
      {"title": "Garmin Pay deixa de ser exclusivo do Solar", "html": "<p>No Instinct 2, Garmin Pay só vinha nos modelos Solar. No Instinct 3, o recurso aparece de forma mais ampla entre os modelos.</p>"},
      {"title": "Bateria em modo GPS melhorou muito (versão Solar)", "html": "<p>O 50mm Solar do Instinct 3 tem mais de 5x a autonomia em modo GPS do Instinct 2 Solar, segundo a própria Garmin.</p>"},
      {"title": "Tamanhos mudaram", "html": "<p>O Instinct 2 vinha em 45mm (padrão) e 40mm (Instinct 2S, pulsos menores). O Instinct 3 vem em 45mm e 50mm — a opção de tamanho menor (2S) não tem equivalente direto na nova geração.</p>"},
      {"title": "O que NÃO mudou (continua igual ao Instinct 2)", "html": "<p>Construção MIL-STD 810, resistência à água de 100 metros, VO2 max, Sleep Score, Body Battery, altímetro/barômetro/bússola, Garmin Coach, detecção de incidente e LiveTrack — tudo isso já vinha do Instinct 2, não é novidade do 3.</p>"}
    ]}
  ]}
  $j$),
  (v_p_instinct3, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela robustez com preço acessível", "dialog": "Se você quer um relógio que aguenta qualquer situação — impacto, temperatura extrema, água — sem pagar o preço do Fenix, o Instinct 3 é a porta de entrada da linha rugged.", "tip": "Bom gancho pra quem já mencionou orçamento como fator decisivo."},
      {"title": "Puxando lanterna e GPS multibanda como diferencial de série", "dialog": "Recursos que até pouco tempo só existiam em relógios bem mais caros — lanterna LED e GPS multibanda — já vêm de série em todos os modelos do Instinct 3.", "tip": "Compare com o Instinct 2 se o cliente já tiver um: nenhum desses dois recursos existia na geração anterior."},
      {"title": "Se o cliente perguntar sobre AMOLED vs Solar", "dialog": "AMOLED tem visual mais bonito. Solar dura muito mais — pra quem faz expedição de vários dias, a bateria praticamente ilimitada do Solar costuma pesar mais que o visual.", "tip": "Pergunte sobre o tipo de uso antes de recomendar."},
      {"title": "Fechamento", "dialog": "Com o Instinct 3 você sai com lanterna, GPS multibanda, Garmin Pay e Messenger — recursos de ponta numa construção militar, por um preço mais acessível que o Fenix.", "tip": "Tamanho (45mm/50mm) e tipo de tela costumam ser a última decisão."}
    ]}
  ]}
  $j$),
  (v_p_instinct3, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não levar o Fenix 8 direto?", "answer": "Se o cliente não precisa de mapas coloridos com navegação, mergulho ou materiais premium (titânio/safira), o Instinct 3 entrega robustez e os recursos essenciais por um investimento bem menor."},
      {"question": "AMOLED ou Solar, qual recomendar?", "answer": "AMOLED pra quem prioriza visual. Solar pra quem faz expedições longas e quer bateria praticamente ilimitada."},
      {"question": "Qual a diferença pro Instinct E?", "answer": "O Instinct E é uma variante mais simples dentro da MESMA geração 3, não o modelo anterior — ele abre mão de recursos como lanterna e GPS multibanda pra ser ainda mais acessível. Já o Instinct 2 é o modelo que o Instinct 3 realmente substitui."}
    ]}
  ]}
  $j$),
  (v_p_instinct3, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Cliente de trilha/montanha", "text": "Precisa de navegação, lanterna e resistência a impacto — tudo de série no Instinct 3.", "tags": []},
      {"title": "Cliente de expedição longa", "text": "Vai passar dias sem energia — a versão Solar resolve com bateria praticamente ilimitada.", "tags": []},
      {"title": "Cliente vindo do Instinct 2", "text": "Satisfeito com a robustez, quer saber se vale trocar — lanterna, GPS multibanda e AMOLED costumam ser os argumentos decisivos.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_instinct3, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "O Instinct 3 tem tela touchscreen?", "html": "<p>Não confirmado oficialmente como touchscreen — a interação principal continua pelos botões físicos, mesmo padrão histórico da linha Instinct.</p>"},
      {"title": "Qual a diferença entre AMOLED e Solar?", "html": "<p>AMOLED tem tela colorida vibrante e bateria de até 24 dias. Solar usa tela MIP com carregamento solar e bateria praticamente ilimitada em uso normal ao ar livre.</p>"},
      {"title": "Tem mapas coloridos?", "html": "<p>Não — mapeamento colorido com navegação turn-by-turn é exclusivo do Fenix 8 nesta comparação.</p>"},
      {"title": "Qual a resistência à água?", "html": "<p>100 metros, testado em padrão militar MIL-STD 810.</p>"},
      {"title": "Qual a diferença real pro Instinct 2?", "html": "<p>O Instinct 3 adiciona opção AMOLED, lanterna LED, GPS multibanda com SatIQ e Garmin Messenger — todos ausentes no Instinct 2. Veja a aba \"O que há de novo?\" pra comparação completa.</p>"}
    ]}
  ]}
  $j$);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-instinct-3', 'Quiz Especialista: Instinct 3', 70, true)
  returning id into v_quiz;

  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Instinct 2 tinha GPS multibanda?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é um recurso novo do Instinct 3, de série em todos os modelos', true, 1), (v_q, 'Sim, em todos os modelos', false, 2), (v_q, 'Sim, só no Solar', false, 3), (v_q, 'Sim, só no Tactical', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz, 'A lanterna LED do Instinct 3 é exclusiva de qual versão?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Nenhuma — vem de série em todos os modelos', true, 1), (v_q, 'Só na versão AMOLED', false, 2), (v_q, 'Só na versão Solar', false, 3), (v_q, 'Só no tamanho 50mm', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual a diferença entre Instinct 3 e Instinct E?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'São da mesma geração — o E é uma variante mais simples, não um modelo anterior', true, 1), (v_q, 'O E é o modelo anterior ao 3', false, 2), (v_q, 'O E é mais caro que o 3', false, 3), (v_q, 'Não há diferença', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual a autonomia do Instinct 3 AMOLED em modo smartwatch?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 24 dias', true, 1), (v_q, 'Até 7 dias', false, 2), (v_q, 'Até 48 dias', false, 3), (v_q, 'Até 3 dias', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Instinct 3 tem mapeamento colorido com navegação turn-by-turn?', 5) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — esse recurso é exclusivo do Fenix 8', true, 1), (v_q, 'Sim, em todos os modelos', false, 2), (v_q, 'Sim, só no AMOLED', false, 3), (v_q, 'Sim, só no 50mm', false, 4);

  insert into product_quizzes (product_id, quiz_id) values (v_p_instinct3, v_quiz);

  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-instinct-3-garmin', 'Especialista Instinct 3', 'Concedido ao passar no Quiz Especialista do Instinct 3.', '{"tipo": "quiz_especialista_produto", "produto": "instinct-3"}');

  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index)
  select v_p_instinct3, id, null, 'topo_de_linha', 1 from products where slug = 'fenix-8';
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 077
-- ============================================================================
