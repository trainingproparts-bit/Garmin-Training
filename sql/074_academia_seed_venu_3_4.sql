-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 074: Academia de Produtos — Venu 3 e Venu 4
-- ============================================================================
-- Pedido do usuário (2026-07-21): "faz do venu 3 e do venu 4, mesmo estilo"
-- — mesma profundidade dos Forerunners (7 seções + quiz especialista +
-- comparativo) e a aba "O que há de novo?" (sql/073) em cada um comparando
-- com o predecessor direto: Venu 3 vs Venu 2, Venu 4 vs Venu 3. Categoria
-- nova (Venu é linha lifestyle/bem-estar, não corrida) — Venu 2 não vira
-- produto próprio, só referência de pesquisa pra sustentar a aba do Venu 3
-- (mesmo tratamento que Forerunner 265/965 receberam em sql/073).
--
-- Sem preços em US$ em lugar nenhum (pedido do usuário nesta mesma sessão,
-- sql/072) — price_usd fica null, nenhuma menção textual a valor.
--
-- FONTES — só oficiais (garmin.com/newsroom, subdomínios oficiais regionais,
-- manuais do proprietário):
--   - Press release Venu 4 (17/09/2025): garmin.com/en-US/newsroom/
--     press-release/sports-fitness/take-steps-towards-a-healthier-
--     lifestyle-with-the-venu-4-from-garmin/
--   - Press release Venu 3 (30/08/2023): garmin.com/en-US/newsroom/
--     press-release/sports-fitness/reach-your-health-and-fitness-goals-
--     with-new-venu-3-gps-smartwatches-from-garmin/
--   - Press release Venu 2 (22/04/2021): garmin.com/en-US/newsroom/
--     press-release/featured/garmin-announces-venu-2-series-fitness-
--     smartwatch/ (só usado como referência pra aba de novidades do Venu 3,
--     Venu 2 não vira produto)
--   - Manuais do proprietário (specs/água): www8.garmin.com/manuals/webhelp/
--     GUID-2CF5620C-... (Venu 4) e GUID-9CC4A873-... (Venu 3) — confirmam
--     5 ATM nos dois.
--
-- Achado que vale registrar: o Venu 4 tem MENOS bateria que o Venu 3 (até
-- 12 dias contra até 14) — mais recursos (lanterna, ECG, Health Status)
-- custaram autonomia, ao contrário do 970 (que ganhou bateria sobre o 965).
-- Isso é mostrado com transparência na aba de novidades, não escondido.
-- O alto-falante/microfone do Venu 3 também não é 100% inédito — já
-- existia no "Venu 2 Plus" (variante separada); o que é novo no Venu 3 é
-- esse recurso virar padrão, sem precisar de uma variante "Plus" à parte.
-- ============================================================================

do $$
declare
  v_brand_id   uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_id     uuid;
  v_p3         uuid;
  v_p4         uuid;
  v_quiz3      uuid;
  v_quiz4      uuid;
  v_q          uuid;
  v_comp       uuid;
begin
  insert into product_categories (brand_id, slug, name, icon, order_index)
  values (v_brand_id, 'lifestyle-bem-estar', 'Lifestyle & Bem-Estar', '💛', 2)
  returning id into v_cat_id;

  -- ==========================================================================
  -- 1. Produtos
  -- ==========================================================================
  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index)
  values (v_brand_id, v_cat_id, 'venu-3', 'Venu 3', '010-02784', 'Smartwatch de saúde e bem-estar com AMOLED e coach de sono', true, 1)
  returning id into v_p3;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, is_published, order_index)
  values (v_brand_id, v_cat_id, 'venu-4', 'Venu 4', '010-02962', 'Smartwatch de saúde e bem-estar com lanterna, ECG e coach pessoal de fitness', true, 2)
  returning id into v_p4;

  -- ==========================================================================
  -- 2. VENU 3 — seções completas
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p3, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Venu 3</strong> é o smartwatch de saúde e bem-estar da Garmin, lançado em 30 de agosto de 2023 (Venu 3 e Venu 3S). Diferente da linha Forerunner, o foco aqui não é performance esportiva — é saúde, sono e hábitos no dia a dia, com AMOLED e bateria de longa duração.</p><p><strong>Posicionamento oficial da Garmin</strong> (Dan Bartel, VP de Vendas ao Consumidor Global): \"Não importa como seja sua jornada de saúde e fitness, o Venu 3 está pronto pra te apoiar em cada passo.\"</p><p><strong>Público-alvo:</strong> quem quer monitorar saúde, sono e bem-estar no dia a dia, sem precisar dos recursos avançados de treino esportivo da linha Forerunner.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Sleep Coach + detecção de soneca", "text": "Recomendações personalizadas de sono e detecção automática de sonecas — novidade desta geração.", "tags": []},
      {"title": "Alto-falante + microfone", "text": "Ligações e resposta de mensagens direto do pulso, pareado ao celular.", "tags": []},
      {"title": "Modo Cadeira de Rodas", "text": "Rastreamento de impulsos, alertas de mudança de peso e treinos específicos pra usuários de cadeira de rodas.", "tags": []},
      {"title": "Bateria de até 14 dias", "text": "Modo smartwatch: até 14 dias (Venu 3) ou 10 dias (Venu 3S).", "tags": []},
      {"title": "30+ apps esportivos", "text": "Incluindo treinos animados pré-carregados (força, HIIT, Pilates, yoga).", "tags": []},
      {"title": "Bisel de aço inoxidável", "text": "Leve, com pulseira de silicone de troca rápida.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p3, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Quem foca em bem-estar, não em performance", "text": "Não treina pra competir — quer entender sono, estresse e energia no dia a dia.", "tags": [{"label": "Bem-estar", "color": "blue"}]},
      {"title": "Quem usa cadeira de rodas", "text": "Precisa de rastreamento de atividade adaptado (impulsos, treinos específicos), não do Forerunner.", "tags": [{"label": "Acessibilidade", "color": "green"}]},
      {"title": "Quem quer AMOLED sem o preço da linha esportiva", "text": "Gosta da tela bonita e dos recursos de saúde, sem precisar de métricas avançadas de corrida.", "tags": [{"label": "Estilo de vida", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer monitorar sono, estresse e energia — não métricas de treino avançadas</li><li>Cliente usa cadeira de rodas e precisa de rastreamento adaptado</li><li>Cliente quer ligar e responder mensagem direto do relógio</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer Training Readiness, potência de corrida ou GPS multibanda → indicar a linha Forerunner</li><li>Cliente quer mapeamento colorido ou navegação avançada → nenhum Venu tem isso</li></ul>"}
  ]}
  $j$),
  (v_p3, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Sleep Coach + Nap Detection + Morning Report", "html": "<p>Recomendações personalizadas de sono, detecção automática de sonecas e um resumo matinal com sono, recuperação e HRV.</p>"},
      {"title": "Modo Cadeira de Rodas", "html": "<p>Rastreamento de impulsos, alertas de mudança de peso e apps esportivos/treinos específicos pra usuários de cadeira de rodas.</p>"},
      {"title": "Alto-falante + microfone", "html": "<p>Ligações e resposta de texto direto do pulso, pareado ao celular. Envio de fotos por mensagem (Android) e teclado no relógio (Android).</p>"},
      {"title": "30+ apps esportivos + treinos animados", "html": "<p>Treinos pré-carregados de força, HIIT, Pilates e yoga com animação na tela, mais acesso a 1.600+ exercícios pelo app Garmin Connect.</p>"},
      {"title": "Monitoramento de saúde 24/7", "html": "<p>Frequência cardíaca, respiração, Pulse Ox, estresse, Body Battery e variabilidade da frequência cardíaca (HRV).</p>"},
      {"title": "Esforço percebido (RPE) + criação de intervalos", "html": "<p>Registro de esforço percebido e criação de treinos intervalados pra corrida e ciclismo.</p>"},
      {"title": "Música offline", "html": "<p>Download de playlists via Spotify, Amazon Music ou Deezer (assinatura separada necessária).</p>"},
      {"title": "Segurança", "html": "<p>Detecção de incidente e compartilhamento de localização ao vivo com contatos de emergência.</p>"},
      {"title": "Resistência à água 5 ATM", "html": "<p>Classificação para natação, equivalente à pressão de uma profundidade de 50 metros.</p>"}
    ]}
  ]}
  $j$),
  (v_p3, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Venu 2</strong> (2021), o modelo direto que o Venu 3 substitui."},
    {"type": "accordion", "items": [
      {"title": "Alto-falante + microfone vira padrão", "html": "<p>No Venu 2, ligação pelo relógio só existia numa variante separada (\"Venu 2 Plus\"). No Venu 3, esse recurso já vem de fábrica, sem precisar de uma versão à parte.</p>"},
      {"title": "Sleep Coach", "html": "<p>Recomendações personalizadas de sono — o Venu 2 só tinha sono com estágios e pontuação, sem coach.</p>"},
      {"title": "Detecção de soneca (Nap Detection)", "html": "<p>Recurso novo — o Venu 2 não detectava sonecas automaticamente.</p>"},
      {"title": "Relatório Matinal (Morning Report)", "html": "<p>Resumo de sono, recuperação e HRV ao acordar — não existia no Venu 2.</p>"},
      {"title": "Modo Cadeira de Rodas", "html": "<p>Rastreamento de impulsos, alertas de mudança de peso e apps esportivos específicos — recurso de acessibilidade novo, não existia no Venu 2.</p>"},
      {"title": "Esforço percebido (RPE)", "html": "<p>Registro de esforço percebido durante o treino — não existia no Venu 2.</p>"},
      {"title": "Bateria maior", "html": "<p>Até 14 dias (Venu 3) contra até 11 dias (Venu 2) em modo smartwatch.</p>"},
      {"title": "O que NÃO mudou (continua igual ao Venu 2)", "html": "<p>Tela AMOLED com Gorilla Glass, bisel de aço inoxidável, Body Battery, Pulse Ox, estresse 24h, Garmin Pay, música offline, resistência à água 5 ATM — tudo isso já vinha do Venu 2.</p>"}
    ]}
  ]}
  $j$),
  (v_p3, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo foco em bem-estar", "dialog": "Antes de falar de recursos, me conta: você tá buscando entender melhor seu sono e sua energia no dia a dia, ou quer métricas avançadas de treino esportivo?", "tip": "Se a resposta for treino avançado, o Venu não é o produto certo — puxe pra linha Forerunner."},
      {"title": "Puxando o Sleep Coach", "dialog": "O Venu 3 tem um Sleep Coach que te dá recomendações personalizadas de sono, além de detectar sonecas automaticamente e te dar um resumo completo assim que você acorda.", "tip": "Bom gancho pra quem já mencionou que dorme mal ou quer entender melhor o próprio sono."},
      {"title": "Se o cliente usa cadeira de rodas", "dialog": "O Venu 3 tem um Modo Cadeira de Rodas dedicado — rastreia impulsos, avisa mudança de peso e tem treinos específicos pensados pra esse uso.", "tip": "Recurso de acessibilidade real, não é só marketing — vale mencionar pra qualquer cliente que mencione usar cadeira de rodas."},
      {"title": "Fechamento", "dialog": "Com o Venu 3 você sai com ligação direto do pulso, mais de 30 apps esportivos e até 14 dias de bateria.", "tip": "Cor e tamanho (Venu 3 ou 3S) costumam ser a última decisão — vale mostrar as opções."}
    ]}
  ]}
  $j$),
  (v_p3, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que não levar um Forerunner?", "answer": "Se o cliente não treina pra competir e quer focar em saúde/sono/bem-estar, o Venu 3 entrega isso melhor — sem pagar por métricas de treino avançado que ele não vai usar."},
      {"question": "Esse aqui serve pra corrida também?", "answer": "Serve pra corridas casuais (tem GPS e VO2 max), mas não tem Training Readiness, potência de corrida no pulso nem GPS multibanda — pra quem treina sério, a linha Forerunner é mais indicada."},
      {"question": "Vale a pena pra quem usa cadeira de rodas?", "answer": "Sim — o Modo Cadeira de Rodas é um recurso real de acessibilidade, com rastreamento de impulsos e treinos específicos, não só uma adaptação genérica."}
    ]}
  ]}
  $j$),
  (v_p3, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Cliente que dorme mal", "text": "Quer entender por que acorda cansado. O Sleep Coach e o Relatório Matinal dão o diagnóstico e a recomendação.", "tags": []},
      {"title": "Cliente que usa cadeira de rodas", "text": "Quer rastrear atividade física de forma adaptada — o Modo Cadeira de Rodas resolve isso.", "tags": []},
      {"title": "Cliente vindo de um relógio básico", "text": "Quer o salto pra AMOLED e recursos de saúde completos, sem precisar da linha esportiva mais cara.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p3, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "O Venu 3 tem GPS multibanda?", "html": "<p>Não — GPS multibanda (SatIQ) é exclusivo da linha Forerunner nesta comparação.</p>"},
      {"title": "Tem Training Readiness?", "html": "<p>Não — esse recurso é específico da linha Forerunner. O Venu foca em saúde e bem-estar geral, não em métricas avançadas de treino.</p>"},
      {"title": "Qual a diferença entre Venu 3 e Venu 3S?", "html": "<p>Tamanho de caixa (45mm vs menor) e cores — o 3S tem bateria um pouco menor (até 10 dias smartwatch contra 14 do 3).</p>"},
      {"title": "Tem resistência à água pra nadar?", "html": "<p>Sim, classificação 5 ATM.</p>"},
      {"title": "Qual a diferença real pro Venu 4?", "html": "<p>O Venu 4 adiciona lanterna LED, app de ECG, Health Status, Lifestyle Logging e recursos de acessibilidade (tela falada, filtros de cor) — mas tem bateria um pouco menor. Veja a aba \"O que há de novo?\" do Venu 4 pra comparação completa.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 3. VENU 4 — seções completas
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p4, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Venu 4</strong> é o smartwatch de saúde e bem-estar mais completo da Garmin, lançado em 17 de setembro de 2025.</p><p><strong>Posicionamento oficial da Garmin</strong> (Susan Lyman, VP de Vendas e Marketing ao Consumidor): \"Projetamos o Venu 4 pra ser um coach pessoal de fitness e bem-estar no pulso.\"</p><p><strong>Público-alvo:</strong> quem quer entender hábitos e saúde no dia a dia (não só treino), incluindo recursos de acessibilidade — tela falada e filtros de cor pra daltonismo.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Lanterna LED integrada", "text": "Luz embutida no relógio pra mais visibilidade no escuro.", "tags": []},
      {"title": "Health Status (beta)", "text": "Monitora tendências de FC, HRV, respiração, temperatura de pele e Pulse Ox durante o sono, e avisa quando algo foge do padrão.", "tags": []},
      {"title": "Lifestyle Logging", "text": "Registra hábitos (cafeína, álcool, hábitos personalizados) e mostra o impacto no sono, estresse e HRV.", "tags": []},
      {"title": "Acessibilidade", "text": "Tela falada (anuncia hora e dados de saúde) e filtros de cor pra daltonismo.", "tags": []},
      {"title": "App de ECG", "text": "Detecção de fibrilação atrial e ritmo sinusal normal.", "tags": []},
      {"title": "Alto-falante + microfone", "text": "Ligações, mensagens e comandos de voz — inclusive sem o celular por perto.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p4, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Quem quer entender os próprios hábitos", "text": "Quer saber como cafeína, álcool ou rotina afetam sono e estresse — Lifestyle Logging resolve isso.", "tags": [{"label": "Hábitos", "color": "blue"}]},
      {"title": "Quem precisa de acessibilidade", "text": "Baixa visão ou daltonismo — tela falada e filtros de cor são recursos reais, não genéricos.", "tags": [{"label": "Acessibilidade", "color": "green"}]},
      {"title": "Quem já tem um Venu antigo", "text": "Quer o pacote mais completo da linha, com lanterna, ECG e Health Status.", "tags": [{"label": "Upgrade", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer entender o próprio dia a dia (hábitos, sono, energia), não métricas de treino avançado</li><li>Cliente precisa de recursos de acessibilidade (baixa visão, daltonismo)</li><li>Cliente quer o Venu mais completo, incluindo ECG e lanterna</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer Training Readiness, potência de corrida ou GPS multibanda → linha Forerunner</li><li>Cliente valoriza bateria acima de tudo → o Venu 3 dura mais (14 dias contra 12 do 4)</li></ul>"}
  ]}
  $j$),
  (v_p4, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Lanterna LED integrada", "html": "<p>Luz embutida no relógio, útil em ambientes escuros — recurso que o Venu 3 não tem.</p>"},
      {"title": "Health Status (beta)", "html": "<p>Monitora tendências de frequência cardíaca, HRV, respiração, temperatura de pele e Pulse Ox durante o sono, e avisa quando alguma métrica foge do padrão normal.</p>"},
      {"title": "Lifestyle Logging", "html": "<p>Registro personalizado ou pré-definido de hábitos (cafeína, consumo de álcool) — o app Garmin Connect mostra o impacto no sono, estresse e HRV.</p>"},
      {"title": "Sleep Alignment + Sleep Consistency", "html": "<p>Sleep Alignment acompanha o alinhamento do ritmo circadiano; Sleep Consistency monitora o horário médio de dormir ao longo de 7 dias.</p>"},
      {"title": "Garmin Fitness Coach", "html": "<p>Treinos personalizados pra mais de 25 atividades (caminhada, ciclismo, remo, HIIT), com ajuste por frequência cardíaca/duração e adaptação diária conforme histórico, sono e recuperação.</p>"},
      {"title": "Treinos Sugeridos do Dia (sem plano formal)", "html": "<p>Sugestão diária de treino mesmo sem configurar um plano — reduz a barreira de entrada pra quem não quer montar rotina.</p>"},
      {"title": "Perfil de Sessão Mista", "html": "<p>Rastreia múltiplas atividades dentro de uma única sessão.</p>"},
      {"title": "Acessibilidade: Tela Falada + Filtros de Cor", "html": "<p>Tela Falada anuncia hora, dados de saúde e alertas horários. Filtros de cor (escala de cinza, vermelho/verde, verde/vermelho, azul/amarelo) ajudam usuários com daltonismo.</p>"},
      {"title": "App de ECG", "html": "<p>Detecção de fibrilação atrial e ritmo sinusal normal.</p>"},
      {"title": "Alto-falante + microfone + comandos de voz sem celular", "html": "<p>Ligações e mensagens com o celular pareado, mais comandos de voz que funcionam mesmo sem o celular por perto.</p>"},
      {"title": "Bateria de até 12 dias", "html": "<p>Modo smartwatch: até 12 dias — menor que o Venu 3 (até 14 dias), efeito colateral dos novos sensores e recursos.</p>"},
      {"title": "Resistência à água 5 ATM", "html": "<p>Classificação para natação, equivalente à pressão de uma profundidade de 50 metros.</p>"}
    ]}
  ]}
  $j$),
  (v_p4, 'novidades', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Venu 3</strong> (2023), o modelo direto que o Venu 4 substitui."},
    {"type": "accordion", "items": [
      {"title": "Health Status (beta)", "html": "<p>Monitoramento de tendências e alertas de desvio (FC, HRV, respiração, temperatura de pele, Pulse Ox no sono) — recurso novo, o Venu 3 não tinha.</p>"},
      {"title": "Lifestyle Logging", "html": "<p>Registro de hábitos (cafeína, álcool) com relatório de impacto no sono/estresse/HRV — não existia no Venu 3.</p>"},
      {"title": "Sleep Alignment + Sleep Consistency", "html": "<p>Duas métricas novas de sono — ritmo circadiano e consistência do horário de dormir. O Venu 3 tinha Sleep Coach, mas não essas duas métricas específicas.</p>"},
      {"title": "Garmin Fitness Coach (25+ atividades)", "html": "<p>Expande o Garmin Coach do Venu 3 — que era mais focado em planos de corrida/ciclismo — pra mais de 25 atividades com adaptação diária.</p>"},
      {"title": "Acessibilidade: Tela Falada + Filtros de Cor", "html": "<p>Recursos novos de acessibilidade — o Venu 3 não tinha tela falada nem filtros de cor pra daltonismo (só as 2 opções de tamanho de fonte).</p>"},
      {"title": "Lanterna LED", "html": "<p>O Venu 3 não tinha lanterna integrada.</p>"},
      {"title": "App de ECG", "html": "<p>Recurso novo — o Venu 3 não tinha detecção de fibrilação atrial.</p>"},
      {"title": "Comandos de voz sem celular", "html": "<p>O Venu 3 já tinha alto-falante/microfone, mas dependia do celular pareado pra ligações. O Venu 4 adiciona comandos de voz que funcionam mesmo sem o celular por perto.</p>"},
      {"title": "Bateria menor (atenção ao vender)", "html": "<p>Até 12 dias no Venu 4 contra até 14 dias no Venu 3 — mais sensores e recursos custaram autonomia. Vale avisar o cliente que prioriza bateria acima de tudo.</p>"},
      {"title": "O que NÃO mudou (continua igual ao Venu 3)", "html": "<p>Tela AMOLED touchscreen, alto-falante + microfone (já vinha do Venu 3), Sleep Coach, Body Battery, Garmin Pay, resistência à água 5 ATM — tudo isso já vinha do Venu 3, não é novidade do Venu 4.</p>"}
    ]}
  ]}
  $j$),
  (v_p4, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pelo hábito, não pelo recurso", "dialog": "Tem algum hábito que você gostaria de entender melhor o impacto — tipo cafeína, álcool, ou até a rotina de sono? O Venu 4 registra isso e te mostra o efeito real no seu sono e estresse.", "tip": "Lifestyle Logging vende melhor quando ancorado num hábito real que o cliente já mencionou, não como recurso genérico."},
      {"title": "Puxando o Health Status pra quem se preocupa com saúde", "dialog": "O Venu 4 acompanha suas tendências de frequência cardíaca, HRV e outros sinais durante o sono, e te avisa se algo sair do padrão — é como ter um alerta preventivo no pulso.", "tip": "Recurso ainda em beta — seja transparente sobre isso se o cliente perguntar."},
      {"title": "Acessibilidade como diferencial real", "dialog": "Se baixa visão ou daltonismo é uma necessidade sua, o Venu 4 tem tela falada, que anuncia a hora e os dados de saúde, e filtros de cor pensados pra diferentes tipos de daltonismo.", "tip": "Não é um recurso pra empurrar em toda venda — só quando o cliente sinalizar essa necessidade."},
      {"title": "Sendo transparente sobre a bateria", "dialog": "Uma coisa importante: o Venu 4 dura até 12 dias, um pouco menos que o Venu 3 (até 14) — são mais sensores e recursos novos consumindo energia.", "tip": "Melhor mencionar isso proativamente do que deixar o cliente descobrir depois — gera confiança."}
    ]}
  ]}
  $j$),
  (v_p4, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "O Venu 4 vale mais que o Venu 3?", "answer": "Vale se o cliente quer lanterna, ECG, Health Status, Lifestyle Logging ou os recursos de acessibilidade — se nenhum desses interessa e bateria é prioridade, o Venu 3 ainda é uma opção válida (dura mais)."},
      {"question": "Por que a bateria é menor que a do modelo anterior?", "answer": "Mais sensores e recursos novos (lanterna, ECG, Health Status) consomem mais energia — é uma troca real, não um defeito. Vale ser transparente sobre isso."},
      {"question": "Esse aqui serve pra quem treina sério?", "answer": "Serve pra atividade física em geral, mas não tem Training Readiness nem GPS multibanda — pra treino de performance, a linha Forerunner é mais indicada."}
    ]}
  ]}
  $j$),
  (v_p4, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Cliente querendo entender hábitos", "text": "Quer saber se o café da tarde afeta o sono — Lifestyle Logging dá a resposta com dados reais.", "tags": []},
      {"title": "Cliente com baixa visão", "text": "Precisa de tela falada pra usar o relógio com autonomia — recurso de acessibilidade real.", "tags": []},
      {"title": "Cliente vindo do Venu 3", "text": "Satisfeito com o Venu 3, quer saber se vale trocar — lanterna, ECG e Health Status costumam ser os argumentos decisivos, com a ressalva da bateria menor.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p4, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "O Venu 4 tem GPS multibanda?", "html": "<p>Não — GPS multibanda é exclusivo da linha Forerunner.</p>"},
      {"title": "Qual a autonomia de bateria?", "html": "<p>Até 12 dias em modo smartwatch — um pouco menos que o Venu 3 (até 14 dias).</p>"},
      {"title": "O Health Status é confiável?", "html": "<p>É um recurso em fase beta — vale posicionar como uma ferramenta de acompanhamento de tendências, não como diagnóstico médico.</p>"},
      {"title": "Tem resistência à água pra nadar?", "html": "<p>Sim, classificação 5 ATM.</p>"},
      {"title": "Quais tamanhos e cores estão disponíveis?", "html": "<p>41mm e 45mm, nas cores lunar gold, light sand, silver e citron, com pulseiras de couro ou silicone trocáveis.</p>"},
      {"title": "Qual a diferença real pro Venu 3?", "html": "<p>O Venu 4 adiciona lanterna LED, ECG, Health Status, Lifestyle Logging e acessibilidade (tela falada, filtros de cor) — mas tem 2 dias a menos de bateria. Veja a aba \"O que há de novo?\" pra comparação completa.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- 4. Quiz Especialista — Venu 3
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-venu-3', 'Quiz Especialista: Venu 3', 70, true)
  returning id into v_quiz3;

  insert into questions (quiz_id, body, order_index) values (v_quiz3, 'O que o Sleep Coach do Venu 3 oferece?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Recomendações personalizadas de sono', true, 1), (v_q, 'Training Readiness', false, 2), (v_q, 'GPS multibanda', false, 3), (v_q, 'Mapeamento colorido', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz3, 'O Modo Cadeira de Rodas do Venu 3 rastreia o quê?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Impulsos e mudança de peso', true, 1), (v_q, 'Potência de corrida', false, 2), (v_q, 'Cadência de pedalada', false, 3), (v_q, 'Nenhuma das opções', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz3, 'O Venu 3 tem GPS multibanda (SatIQ)?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não — é exclusivo da linha Forerunner', true, 1), (v_q, 'Sim, igual ao Forerunner 570', false, 2), (v_q, 'Só na versão 3S', false, 3), (v_q, 'Sim, mas sem SatIQ', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz3, 'Qual a autonomia máxima em modo smartwatch do Venu 3?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 14 dias', true, 1), (v_q, 'Até 10 dias', false, 2), (v_q, 'Até 20 dias', false, 3), (v_q, 'Até 7 dias', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz3, 'O que virou padrão no Venu 3 e antes só existia numa variante separada (Venu 2 Plus)?', 5) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Alto-falante e microfone (ligações)', true, 1), (v_q, 'Lanterna LED', false, 2), (v_q, 'App de ECG', false, 3), (v_q, 'GPS multibanda', false, 4);

  -- ==========================================================================
  -- 5. Quiz Especialista — Venu 4
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-venu-4', 'Quiz Especialista: Venu 4', 70, true)
  returning id into v_quiz4;

  insert into questions (quiz_id, body, order_index) values (v_quiz4, 'O que o Lifestyle Logging do Venu 4 registra?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Hábitos como cafeína e álcool, mostrando impacto no sono/estresse', true, 1), (v_q, 'Só passos e calorias', false, 2), (v_q, 'Potência de corrida', false, 3), (v_q, 'Rotas de ciclismo', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz4, 'A bateria do Venu 4 é maior ou menor que a do Venu 3?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Menor — até 12 dias contra até 14 do Venu 3', true, 1), (v_q, 'Maior — até 18 dias', false, 2), (v_q, 'A mesma autonomia', false, 3), (v_q, 'O Venu 4 não tem modo smartwatch', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz4, 'Quais recursos de acessibilidade o Venu 4 tem que o Venu 3 não tinha?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Tela Falada e Filtros de Cor', true, 1), (v_q, 'Apenas fonte grande', false, 2), (v_q, 'Nenhum, são iguais', false, 3), (v_q, 'Modo Cadeira de Rodas (esse já era do Venu 3)', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz4, 'O Venu 4 tem app de ECG?', 4) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Sim — recurso novo, o Venu 3 não tinha', true, 1), (v_q, 'Não, nenhum Venu tem', false, 2), (v_q, 'Sim, mas o Venu 3 também já tinha', false, 3), (v_q, 'Só na versão Plus', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz4, 'O Venu 4 tem lanterna LED integrada?', 5) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Sim — o Venu 3 não tinha', true, 1), (v_q, 'Não, nenhum Venu tem', false, 2), (v_q, 'Sim, mas já vinha do Venu 3', false, 3), (v_q, 'Só nos tamanhos 45mm', false, 4);

  -- ==========================================================================
  -- 6. Ligação produto → quiz
  -- ==========================================================================
  insert into product_quizzes (product_id, quiz_id) values (v_p3, v_quiz3), (v_p4, v_quiz4);

  -- ==========================================================================
  -- 7. Badges "Especialista em <produto>"
  -- ==========================================================================
  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-venu-3-garmin', 'Especialista Venu 3', 'Concedido ao passar no Quiz Especialista do Venu 3.', '{"tipo": "quiz_especialista_produto", "produto": "venu-3"}'),
  (v_brand_id, 'especialista-venu-4-garmin', 'Especialista Venu 4', 'Concedido ao passar no Quiz Especialista do Venu 4.', '{"tipo": "quiz_especialista_produto", "produto": "venu-4"}');

  -- ==========================================================================
  -- 8. Comparativo Venu 4 x Venu 3
  -- ==========================================================================
  insert into product_comparisons (brand_id, product_a_id, product_b_id, slug, title, resumo_executivo, blocks, is_published)
  values (
    v_brand_id, v_p4, v_p3, 'venu-4-vs-venu-3',
    'Venu 4 vs Venu 3',
    'O Venu 4 (2025) adiciona lanterna LED, app de ECG, Health Status (beta), Lifestyle Logging e recursos de acessibilidade (Tela Falada, Filtros de Cor) sobre o Venu 3 (2023) — mas tem 2 dias a menos de bateria (até 12 contra até 14). Os dois compartilham tela AMOLED, alto-falante/microfone, Sleep Coach, Body Battery e resistência à água 5 ATM.',
    $j$
    [
      {"type": "card_grid", "columns": 2, "items": [
        {"title": "Vantagens do Venu 4", "text": "Lanterna LED · App de ECG · Health Status (beta) · Lifestyle Logging · Acessibilidade (Tela Falada + Filtros de Cor) · Garmin Fitness Coach com mais atividades · Comandos de voz sem celular", "tags": [{"label": "4", "color": "blue"}]},
        {"title": "Vantagens do Venu 3", "text": "Bateria maior (até 14 dias contra até 12 do Venu 4)", "tags": [{"label": "3", "color": "gold"}]}
      ]},
      {"type": "objecao", "items": [
        {"question": "Vale a pena trocar o Venu 3 pelo Venu 4?", "answer": "Vale se o cliente quer lanterna, ECG, Health Status, Lifestyle Logging ou os recursos de acessibilidade. Se bateria é a prioridade número um e nenhum desses recursos interessa, o Venu 3 continua sendo uma opção sólida."},
        {"question": "Por que o Venu 4 tem menos bateria que o Venu 3?", "answer": "Os novos sensores e recursos (lanterna, ECG, Health Status) consomem mais energia — é uma troca real entre recursos e autonomia, vale ser transparente sobre isso na venda."}
      ]}
    ]
    $j$,
    true
  ) returning id into v_comp;

  insert into comparison_items (comparison_id, spec_label, value_a, value_b, winner, order_index) values
  (v_comp, 'Bateria — modo smartwatch', 'Até 12 dias', 'Até 14 dias', 'b', 1),
  (v_comp, 'Lanterna LED integrada', 'Sim', 'Não', 'a', 2),
  (v_comp, 'App de ECG', 'Sim', 'Não', 'a', 3),
  (v_comp, 'Health Status (beta)', 'Sim', 'Não', 'a', 4),
  (v_comp, 'Lifestyle Logging', 'Sim', 'Não', 'a', 5),
  (v_comp, 'Acessibilidade (Tela Falada + Filtros de Cor)', 'Sim', 'Não', 'a', 6),
  (v_comp, 'Garmin Fitness Coach (25+ atividades)', 'Sim', 'Coach mais limitado (corrida/ciclismo)', 'a', 7),
  (v_comp, 'Alto-falante + microfone', 'Sim', 'Sim', 'tie', 8),
  (v_comp, 'Sleep Coach', 'Sim', 'Sim', 'tie', 9),
  (v_comp, 'Resistência à água', '5 ATM', '5 ATM', 'tie', 10);

  -- ==========================================================================
  -- 9. Grafo de conhecimento — relacionados
  -- ==========================================================================
  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index) values
  (v_p4, v_p3, null, 'antecessor', 1),
  (v_p4, null, 'Health Status', 'funcionalidade', 2),
  (v_p4, null, 'Lifestyle Logging', 'funcionalidade', 3),
  (v_p3, v_p4, null, 'upgrade', 1),
  (v_p3, null, 'Sleep Coach', 'funcionalidade', 2);
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 074
-- ============================================================================
