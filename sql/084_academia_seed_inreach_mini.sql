-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 084: Academia de Produtos — inReach Mini 2,
-- inReach Mini 3 e inReach Mini 3 Plus (nova categoria Comunicação Satelital)
-- ============================================================================
-- Pedido do usuário (2026-07-21): "inreach mini 2 mini 3 e mini 3 plus" —
-- último item da lista, fecha o lote grande desta rodada.
--
-- Estrutura da linha inReach Mini (confirmada via pesquisa oficial):
--   - inReach Mini 2 (2/fev/2022): tela monocromática transflectiva MIP, SEM
--     touchscreen (só botão), até 14 dias de bateria (rastreio a cada 10min)
--     ou até 30 dias (rastreio a cada 30min), IPX7, US$ 399,99.
--   - inReach Mini 3 e inReach Mini 3 Plus (ambos lançados no MESMO dia,
--     2/dez/2025): geração seguinte, com tela COLORIDA TOUCHSCREEN de
--     1.88"/1.9" — recurso totalmente novo em relação ao Mini 2. Os dois
--     são variantes de TIER da mesma geração (não um sucede o outro):
--       - Mini 3 (básico): texto bidirecional, SOS interativo, até 350h de
--         bateria (rastreio 10min). SEM mensagem de voz, SEM foto.
--       - Mini 3 Plus (topo): adiciona mensagem de voz (30s + transcrição),
--         compartilhamento de foto, texto com emoji/reações/grupo, alto-
--         falante e microfone embutidos — só que com bateria um pouco menor
--         (até 330h) por causa do hardware extra de áudio.
--
-- Por isso, igual ao caso Rally 100/200 e GPSMAP 65/66sr nesta Academia: o
-- Mini 3 e o Mini 3 Plus NÃO têm relação de sucessão entre si (mesma
-- geração, tiers diferentes) — só o Mini 3 recebe aba "novidades" (compa-
-- rando com o Mini 2, seu antecessor real). O Mini 3 Plus entra sem aba
-- "novidades" formal, mas com posicionamento claro frente ao Mini 3 nas
-- seções de personas/objeções.
--
-- FONTES — só oficiais:
--   - inReach Mini 2: garmin.com/en-US/newsroom/press-release/outdoor/
--     new-garmin-inreach-mini-2-delivers-up-to-30-days-of-global-satellite-
--     communication-emergency-services-and-enhanced-location-tracking/
--   - inReach Mini 3 Plus: garmin.com/en-US/newsroom/press-release/outdoor/
--     built-for-the-backcountry-garmin-introduces-inreach-mini-3-plus-
--     satellite-communicator-with-voice-text-and-photo-sharing/
--   - inReach Mini 3 (specs): página oficial do produto (garmin.com/en-US/p/)
--     e manual do Mini 2 (www8.garmin.com/manuals) pra confirmar ausência
--     de touchscreen no Mini 2.
-- ============================================================================

do $$
declare
  v_brand_id uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_id   uuid;
  v_p_m2     uuid;
  v_p_m3     uuid;
  v_p_m3p    uuid;
  v_quiz     uuid;
  v_q        uuid;
begin
  insert into product_categories (brand_id, slug, name, icon, order_index)
  values (v_brand_id, 'comunicacao-satelite', 'Comunicação Satelital', '📡', 8)
  returning id into v_cat_id;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index) values
  (v_brand_id, v_cat_id, 'inreach-mini-2', 'inReach Mini 2', '010-02602', 'Comunicador satelital compacto, só botão, até 30 dias de bateria', true, 1),
  (v_brand_id, v_cat_id, 'inreach-mini-3', 'inReach Mini 3', '010-03387', 'Comunicador satelital compacto com touchscreen colorido, texto bidirecional e SOS interativo', true, 2),
  (v_brand_id, v_cat_id, 'inreach-mini-3-plus', 'inReach Mini 3 Plus', '010-03388', 'Comunicador satelital com touchscreen, mensagem de voz, foto e texto em grupo', true, 3)
  returning id into v_p_m2;
  select id into v_p_m2 from products where slug = 'inreach-mini-2';
  select id into v_p_m3 from products where slug = 'inreach-mini-3';
  select id into v_p_m3p from products where slug = 'inreach-mini-3-plus';

  -- ==========================================================================
  -- INREACH MINI 2
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_m2, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>inReach Mini 2</strong>, lançado em 2 de fevereiro de 2022, é um comunicador satelital compacto controlado só por botão — comunicação bidirecional e SOS de emergência em qualquer lugar do planeta, mesmo sem sinal de celular.</p><p><strong>Público-alvo:</strong> quem entra em área remota sem cobertura de celular e precisa de um jeito confiável e leve de se comunicar e pedir socorro.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Texto bidirecional via satélite", "text": "Rede Iridium, cobertura mundial.", "tags": []},
      {"title": "SOS interativo 24/7", "text": "Central de coordenação profissional em tempo real.", "tags": []},
      {"title": "Bateria de até 30 dias", "text": "Rastreio a cada 30min; até 14 dias com rastreio a cada 10min.", "tags": []},
      {"title": "Peso de 3.5 oz (~100g)", "text": "Um dos comunicadores satelitais mais leves da Garmin.", "tags": []},
      {"title": "TracBack", "text": "Navegação de volta pela rota já percorrida.", "tags": []},
      {"title": "Resistência IPX7", "text": "Protegido contra chuva e imersão acidental.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_m2, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Trilheiro/mochileiro leve", "text": "Quer o comunicador mais compacto e leve possível.", "tags": [{"label": "Ultraleve", "color": "green"}]},
      {"title": "Quem entra em área sem sinal de celular", "text": "Precisa de comunicação e SOS confiáveis via satélite.", "tags": [{"label": "Segurança", "color": "blue"}]},
      {"title": "Cliente com orçamento mais ajustado", "text": "Quer inReach funcional sem pagar pelo touchscreen do Mini 3.", "tags": [{"label": "Custo-benefício", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer o comunicador satelital mais leve e compacto</li><li>Cliente não precisa de touchscreen, foto ou mensagem de voz</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer touchscreen colorido e mais bateria → indicar o inReach Mini 3</li><li>Cliente quer mandar mensagem de voz ou foto durante a trilha → indicar o inReach Mini 3 Plus</li></ul>"}
  ]}
  $j$),
  (v_p_m2, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Texto bidirecional via rede Iridium", "html": "<p>Comunicação por satélite com cobertura mundial, funciona mesmo sem sinal de celular.</p>"},
      {"title": "SOS interativo 24/7", "html": "<p>Aciona a central de resposta de emergência da Garmin, com coordenação profissional em tempo real durante toda a emergência.</p>"},
      {"title": "Bateria de até 30 dias", "html": "<p>Com rastreio a cada 30 minutos; até 14 dias com rastreio a cada 10 minutos. Mantém carga por até um ano quando desligado.</p>"},
      {"title": "TracBack", "html": "<p>Permite retraçar o caminho já percorrido pra voltar com segurança.</p>"},
      {"title": "Compatível com 80+ dispositivos Garmin", "html": "<p>Pode ser pareado com relógios e outros aparelhos Garmin compatíveis pra estender a funcionalidade inReach.</p>"}
    ]}
  ]}
  $j$),
  (v_p_m2, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela segurança em área remota", "dialog": "O inReach Mini 2 te mantém comunicável em qualquer lugar do planeta, mesmo sem sinal de celular — e se acontecer uma emergência, o SOS interativo aciona uma central profissional que acompanha você em tempo real.", "tip": "Ótimo argumento de segurança pra trilha, caça ou pesca em área remota."},
      {"title": "Puxando o peso e a bateria", "dialog": "Ele pesa menos de 100 gramas e a bateria dura até 30 dias — praticamente não pesa na mochila e não te preocupa com recarga.", "tip": "Bom argumento pra quem valoriza peso de mochila (ultraleve/thru-hiking)."},
      {"title": "Fechamento", "dialog": "Com o inReach Mini 2 você sai com comunicação satelital confiável, SOS de emergência e bateria de semanas — o comunicador mais leve da linha.", "tip": "Confirme se o cliente já tem plano de assinatura ativo ou precisa contratar."}
    ]}
  ]}
  $j$),
  (v_p_m2, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Preciso de assinatura pra usar?", "answer": "Sim — os planos de satélite são contratados à parte, com opções a partir de US$ 11,95/mês, incluindo opções flexíveis mês a mês ou pacote anual."},
      {"question": "Por que não o Mini 3, que é mais novo?", "answer": "O Mini 3 tem touchscreen colorido e mais bateria, mas custa mais. Se o cliente só precisa de texto e SOS, o Mini 2 já resolve com ótimo custo-benefício."},
      {"question": "Funciona sem sinal de celular?", "answer": "Sim — é justamente o propósito do inReach: comunicação via satélite Iridium, independente de torre de celular."}
    ]}
  ]}
  $j$),
  (v_p_m2, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Mochileiro de longa distância (thru-hiking)", "text": "Valoriza o peso mínimo e a bateria de semanas.", "tags": []},
      {"title": "Caçador/pescador em área sem sinal", "text": "Depende do SOS interativo em caso de emergência.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_m2, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tem touchscreen?", "html": "<p>Não — é controlado só por botão físico, com tela monocromática transflectiva.</p>"},
      {"title": "Dá pra enviar foto ou mensagem de voz?", "html": "<p>Não — esses recursos são exclusivos do inReach Mini 3 Plus.</p>"},
      {"title": "Qual o peso?", "html": "<p>3.5 oz (aproximadamente 100g).</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- INREACH MINI 3 + novidades vs Mini 2
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_m3, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>inReach Mini 3</strong>, lançado em 2 de dezembro de 2025, é a geração mais nova do comunicador satelital compacto da Garmin — primeiro Mini com tela colorida touchscreen.</p><p><strong>Público-alvo:</strong> quem quer o comunicador satelital mais atual da Garmin, com tela touch e mais bateria que o Mini 2, sem pagar pelos recursos de voz/foto do Mini 3 Plus.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Tela touchscreen colorida de 1.9\"", "text": "Primeira geração Mini com touch — o Mini 2 era só botão.", "tags": []},
      {"title": "Texto bidirecional via satélite", "text": "Rede Iridium, cobertura mundial.", "tags": []},
      {"title": "SOS interativo 24/7", "text": "Central de coordenação profissional em tempo real.", "tags": []},
      {"title": "Bateria de até 350h (rastreio 10min)", "text": "Mais que o Mini 2 no mesmo intervalo de rastreio.", "tags": []},
      {"title": "Resistência IP67", "text": "Protegido contra chuva, poeira e imersão acidental.", "tags": []},
      {"title": "App Garmin Explore", "text": "Planejamento de rota, clima e mais recursos via smartphone.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_m3, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Quem quer o comunicador satelital mais atual", "text": "Valoriza touchscreen e mais bateria que o Mini 2.", "tags": [{"label": "Tecnologia", "color": "blue"}]},
      {"title": "Usuário do Mini 2 avaliando upgrade", "text": "Quer saber se vale trocar de geração.", "tags": [{"label": "Upgrade", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer touchscreen colorido e mais autonomia de bateria que o Mini 2</li><li>Cliente não precisa de mensagem de voz nem foto</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer mandar mensagem de voz ou foto → indicar o Mini 3 Plus</li><li>Cliente quer o comunicador mais em conta possível → o Mini 2 continua sendo opção válida</li></ul>"}
  ]}
  $j$),
  (v_p_m3, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tela touchscreen colorida", "html": "<p>1.9\" com tecnologia MIP transflectiva, 306x230 pixels — legível sob sol direto, com navegação por toque.</p>"},
      {"title": "Texto bidirecional via rede Iridium", "html": "<p>Comunicação por satélite com cobertura mundial.</p>"},
      {"title": "SOS interativo 24/7", "html": "<p>Aciona a central de resposta de emergência da Garmin.</p>"},
      {"title": "Bateria de até 350h em modo rastreio de 10min", "html": "<p>Cerca de 170h em modo GPS ou 120h usando todos os sistemas de satélite simultaneamente.</p>"},
      {"title": "Resistência IP67", "html": "<p>Protegido contra poeira, chuva forte e imersão acidental.</p>"}
    ]}
  ]}
  $j$),
  (v_p_m3, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>inReach Mini 2</strong>, o modelo direto que o Mini 3 substitui."},
    {"type": "accordion", "items": [
      {"title": "Touchscreen colorido (recurso totalmente novo)", "html": "<p>O Mini 2 tinha tela monocromática só por botão. O Mini 3 introduz touchscreen colorido pela primeira vez na linha Mini.</p>"},
      {"title": "Mais bateria no mesmo intervalo de rastreio", "html": "<p>Até 350h no Mini 3 contra até 14 dias (336h) no Mini 2 em rastreio de 10min — ganho real, ainda que modesto, de autonomia.</p>"},
      {"title": "Resistência atualizada pra IP67", "html": "<p>O Mini 2 era certificado IPX7 (só água) — o Mini 3 é IP67 (poeira + água).</p>"},
      {"title": "O que NÃO mudou (continua igual ao Mini 2)", "html": "<p>Texto bidirecional via Iridium, SOS interativo 24/7 e compatibilidade com o app Garmin Explore já vinham do Mini 2.</p>"}
    ]}
  ]}
  $j$),
  (v_p_m3, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo touchscreen", "dialog": "O inReach Mini 3 é o primeiro da linha Mini com tela colorida touchscreen — muito mais fácil de navegar pelos menus e escrever mensagens que o modelo anterior, só por botão.", "tip": "Ótimo argumento pra quem já reclamou da navegação por botão do Mini 2."},
      {"title": "Puxando a bateria e a resistência", "dialog": "Ele também ganhou mais bateria no mesmo intervalo de rastreio e resistência IP67, agora protegido contra poeira além de água.", "tip": "Bom argumento pra ambiente de deserto ou muita poeira."},
      {"title": "Fechamento", "dialog": "Com o inReach Mini 3 você sai com touchscreen colorido, mais bateria e a mesma confiabilidade de comunicação satelital da linha Mini.", "tip": "Se o cliente quiser mandar foto ou mensagem de voz, pergunte se prefere o Mini 3 Plus."}
    ]}
  ]}
  $j$),
  (v_p_m3, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Vale a pena trocar o Mini 2 pelo Mini 3?", "answer": "Vale principalmente pelo touchscreen colorido e ganho de bateria. Se o cliente está satisfeito com botão físico e não se importa com a tela monocromática, o Mini 2 continua funcional."},
      {"question": "Qual a diferença pro Mini 3 Plus?", "answer": "O Mini 3 Plus adiciona mensagem de voz, foto e recursos de grupo no texto — o Mini 3 comum não tem esses três recursos, mas custa menos."}
    ]}
  ]}
  $j$),
  (v_p_m3, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Cliente migrando do Mini 2", "text": "Quer touchscreen e mais bateria, sem pagar pelos recursos de voz/foto.", "tags": []},
      {"title": "Trilheiro em ambiente com muita poeira", "text": "Se beneficia da resistência IP67 atualizada.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_m3, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Tem mensagem de voz?", "html": "<p>Não — voz e foto são exclusivos do inReach Mini 3 Plus.</p>"},
      {"title": "Qual a diferença real pro Mini 2?", "html": "<p>Touchscreen colorido, mais bateria e resistência IP67. Veja a aba \"O que há de novo?\" pra comparação completa.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- INREACH MINI 3 PLUS (sem novidades formal — tier irmão do Mini 3)
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_m3p, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>inReach Mini 3 Plus</strong>, lançado em 2 de dezembro de 2025 junto com o Mini 3, é o topo de linha dos comunicadores satelitais compactos da Garmin — o primeiro Mini a enviar mensagem de voz e foto via satélite.</p><p><strong>Público-alvo:</strong> quem quer o comunicador satelital mais completo da Garmin, com voz, foto e texto em grupo, não só SOS e texto simples.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Mensagem de voz de 30s + transcrição", "text": "Grava e envia áudio via satélite, com transcrição de texto no aparelho.", "tags": []},
      {"title": "Compartilhamento de foto", "text": "Envia fotos da aventura via app Garmin Messenger.", "tags": []},
      {"title": "Texto com emoji, reações e grupo", "text": "Até 1.600 caracteres por mensagem.", "tags": []},
      {"title": "LiveTrack", "text": "Contatos acompanham distância, tempo e elevação em tempo real.", "tags": []},
      {"title": "SOS interativo com foto/voz", "text": "Compartilha foto e voz também durante uma emergência.", "tags": []},
      {"title": "Bateria de até 330h (rastreio 10min)", "text": "Um pouco menos que o Mini 3, por causa do alto-falante/microfone embutidos.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_m3p, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Quem quer manter contato rico com a família", "text": "Usa mensagem de voz e foto pra compartilhar a aventura em tempo real.", "tags": [{"label": "Conexão", "color": "blue"}]},
      {"title": "Grupo de trilha/expedição", "text": "Usa o texto em grupo pra coordenar entre vários membros.", "tags": [{"label": "Grupo", "color": "gold"}]},
      {"title": "Quem quer o inReach mais completo", "text": "Não abre mão de nenhum recurso disponível na linha Mini.", "tags": [{"label": "Topo de linha", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer mandar mensagem de voz ou foto via satélite durante a aventura</li><li>Cliente coordena com um grupo e quer texto compartilhado</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente só precisa de texto simples e SOS → o Mini 3 (ou até o Mini 2) já resolve por menos</li><li>Cliente prioriza o máximo de bateria possível → o Mini 3 comum dura um pouco mais (350h contra 330h)</li></ul>"}
  ]}
  $j$),
  (v_p_m3p, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Mensagem de voz com transcrição", "html": "<p>Grava até 30 segundos de áudio, envia via satélite, e o destinatário recebe tanto o áudio quanto uma transcrição em texto — funciona nos dois sentidos.</p>"},
      {"title": "Compartilhamento de foto", "html": "<p>Envia fotos da aventura via app Garmin Messenger, e também recebe fotos de quem está em casa.</p>"},
      {"title": "Texto avançado: emoji, reações e grupo", "html": "<p>Mensagens de até 1.600 caracteres, com suporte a emoji, reações e conversas em grupo.</p>"},
      {"title": "SOS com foto e voz", "html": "<p>Durante uma emergência, dá pra compartilhar foto e mensagem de voz com a central de resposta, além do texto padrão.</p>"},
      {"title": "Alto-falante e microfone embutidos", "html": "<p>Hardware de áudio integrado ao corpo do aparelho, viabilizando a mensagem de voz.</p>"},
      {"title": "Resistência IP67", "html": "<p>Protegido contra poeira, chuva forte e imersão acidental.</p>"}
    ]}
  ]}
  $j$),
  (v_p_m3p, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pela mensagem de voz", "dialog": "O inReach Mini 3 Plus é o primeiro Mini que manda mensagem de voz de verdade via satélite — 30 segundos de áudio, com transcrição em texto pro destinatário. Isso muda completamente a experiência de ficar em contato numa trilha longa.", "tip": "Ótimo argumento emocional pra quem viaja com família esperando notícias."},
      {"title": "Puxando o compartilhamento de foto", "dialog": "Ele também manda foto da aventura via satélite pelo app Garmin Messenger — dá pra compartilhar o momento em tempo real, mesmo sem sinal de celular.", "tip": "Bom argumento pra quem gosta de documentar a viagem."},
      {"title": "Sendo transparente sobre a bateria", "dialog": "Uma coisa pra mencionar: com o alto-falante e microfone embutidos, a bateria é um pouco menor que a do Mini 3 comum (330h contra 350h) — mas ainda é uma autonomia excelente.", "tip": "Melhor mencionar isso proativamente se o cliente comparar direto com o Mini 3."},
      {"title": "Fechamento", "dialog": "Com o inReach Mini 3 Plus você sai com o comunicador satelital mais completo da Garmin — voz, foto, texto em grupo e SOS interativo tudo num único aparelho compacto.", "tip": "Confirme se o cliente realmente vai usar voz/foto — se não, o Mini 3 comum é mais em conta."}
    ]}
  ]}
  $j$),
  (v_p_m3p, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Vale a diferença de preço pro Mini 3 comum?", "answer": "Vale se o cliente realmente vai usar mensagem de voz, foto ou texto em grupo. Se o uso for só texto simples e SOS, o Mini 3 comum entrega a mesma base de comunicação por menos."},
      {"question": "Por que a bateria é menor que a do Mini 3?", "answer": "É o trade-off direto de ter alto-falante e microfone embutidos consumindo energia extra — ainda assim, 330h é uma autonomia muito boa pra uma expedição de semanas."},
      {"question": "A mensagem de voz funciona em qualquer lugar?", "answer": "Sim, em qualquer lugar com visada de satélite Iridium — a mesma cobertura mundial dos outros recursos inReach."}
    ]}
  ]}
  $j$),
  (v_p_m3p, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Expedicionário mantendo contato com família", "text": "Usa mensagem de voz e foto pra compartilhar a jornada.", "tags": []},
      {"title": "Grupo de trilha coordenando entre membros", "text": "Usa o texto em grupo com reações e emoji.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_m3p, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "É sucessor do Mini 3?", "html": "<p>Não — foram lançados no mesmo dia, como tiers diferentes da mesma geração. O Mini 3 Plus é a versão mais completa, com voz e foto; o Mini 3 comum é a versão mais enxuta.</p>"},
      {"title": "Precisa de plano de assinatura diferente pra usar voz/foto?", "html": "<p>O material oficial não detalha planos específicos por recurso — vale confirmar com o time de assinaturas Garmin qual plano habilita cada funcionalidade.</p>"},
      {"title": "Quanto pesa?", "html": "<p>O material oficial consultado não especifica o peso exato do Mini 3 Plus.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- Quiz Especialista — 3 produtos
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-inreach-mini-2', 'Quiz Especialista: inReach Mini 2', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O inReach Mini 2 tem touchscreen?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — só botão físico', true, 1), (v_q, 'Sim, touchscreen colorido', false, 2), (v_q, 'Só em modo SOS', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual a bateria máxima do Mini 2 (rastreio 30min)?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 30 dias', true, 1), (v_q, 'Até 3 dias', false, 2), (v_q, 'Até 1 ano', false, 3), (v_q, 'Até 100 dias', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Mini 2 funciona sem sinal de celular?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Sim — usa rede de satélite Iridium', true, 1), (v_q, 'Não, precisa de celular', false, 2), (v_q, 'Só com WiFi', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-inreach-mini-3', 'Quiz Especialista: inReach Mini 3', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que é novo no Mini 3 em relação ao Mini 2?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Touchscreen colorido', true, 1), (v_q, 'Mensagem de voz', false, 2), (v_q, 'Compartilhamento de foto', false, 3), (v_q, 'GPS', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Mini 3 comum tem mensagem de voz?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — exclusivo do Mini 3 Plus', true, 1), (v_q, 'Sim, tem', false, 2), (v_q, 'Só em modo SOS', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-inreach-mini-3-plus', 'Quiz Especialista: inReach Mini 3 Plus', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Mini 3 Plus é sucessor direto do Mini 3?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — lançados juntos, tiers diferentes da mesma geração', true, 1), (v_q, 'Sim, sucessor direto', false, 2), (v_q, 'O Mini 3 sucede o Plus', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Quantos segundos dura a mensagem de voz do Mini 3 Plus?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, '30 segundos', true, 1), (v_q, '5 minutos', false, 2), (v_q, '10 segundos', false, 3), (v_q, 'Ilimitado', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Por que a bateria do Mini 3 Plus é menor que a do Mini 3?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Alto-falante e microfone embutidos consomem mais energia', true, 1), (v_q, 'Tem uma bateria física menor', false, 2), (v_q, 'É um defeito de fabricação', false, 3), (v_q, 'Não é menor', false, 4);

  insert into product_quizzes (product_id, quiz_id)
  select id, (select id from quizzes where slug = 'quiz-especialista-inreach-mini-2') from products where slug = 'inreach-mini-2'
  union all select id, (select id from quizzes where slug = 'quiz-especialista-inreach-mini-3') from products where slug = 'inreach-mini-3'
  union all select id, (select id from quizzes where slug = 'quiz-especialista-inreach-mini-3-plus') from products where slug = 'inreach-mini-3-plus';

  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-inreach-mini-2-garmin', 'Especialista inReach Mini 2', 'Concedido ao passar no Quiz Especialista do inReach Mini 2.', '{"tipo": "quiz_especialista_produto", "produto": "inreach-mini-2"}'),
  (v_brand_id, 'especialista-inreach-mini-3-garmin', 'Especialista inReach Mini 3', 'Concedido ao passar no Quiz Especialista do inReach Mini 3.', '{"tipo": "quiz_especialista_produto", "produto": "inreach-mini-3"}'),
  (v_brand_id, 'especialista-inreach-mini-3-plus-garmin', 'Especialista inReach Mini 3 Plus', 'Concedido ao passar no Quiz Especialista do inReach Mini 3 Plus.', '{"tipo": "quiz_especialista_produto", "produto": "inreach-mini-3-plus"}');

  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index) values
  (v_p_m2, v_p_m3, null, 'upgrade', 1),
  (v_p_m3, v_p_m2, null, 'entrada', 1),
  (v_p_m3, v_p_m3p, null, 'variante_topo', 2),
  (v_p_m3p, v_p_m3, null, 'variante_entrada', 1);
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 084
-- ============================================================================
