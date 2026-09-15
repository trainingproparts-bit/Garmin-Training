-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 142: Index S2 na Academia de Produtos
-- ============================================================================
-- Pedido do usuário (2026-09-15): incluir o Index S2 (balança inteligente)
-- na Academia de Produtos — antes só existia uma menção resumida dele na
-- lição de Portfólio (sql/122). Categoria "Acessórios & Sensores" (mesma
-- das cintas HRM — não é relógio nem se encaixa em categoria esportiva).
--
-- Fatos técnicos reaproveitados de sql/122 (já verificados no manual oficial
-- garmin.com/support na época): mede peso, IMC, % de gordura corporal, % de
-- água corporal, massa muscular esquelética e massa óssea por bioimpedância;
-- carga máxima 181,4 kg; sincroniza direto com o Garmin Connect por Wi-Fi,
-- sem precisar do celular por perto; reconhece automaticamente até 16
-- perfis de usuário na mesma balança; tela colorida embutida.
--
-- Model code (010-02294-02, versão preta) e confirmação do preço de
-- lançamento americano (US$ 149,99) pesquisados agora no site oficial da
-- Garmin/varejo autorizado — price_usd fica NULL mesmo assim: o projeto já
-- decidiu (sql/072, "tira os valores em US") não exibir preço americano na
-- Academia de Produtos, e não existe preço oficial em BRL pra usar no lugar.
-- ============================================================================

do $$
declare
  v_brand_id uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_acessorios uuid;
  v_p_index_s2 uuid;
  v_quiz uuid;
  v_q uuid;
begin
  select id into v_cat_acessorios from product_categories where slug = 'acessorios-sensores' and brand_id = v_brand_id;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, price_usd, is_published, order_index) values
  (v_brand_id, v_cat_acessorios, 'index-s2', 'Index S2', '010-02294-02', 'Balança inteligente com bioimpedância completa, sincronização automática por Wi-Fi e reconhecimento de até 16 perfis', null, true, 3);
  select id into v_p_index_s2 from products where slug = 'index-s2';

  -- ==========================================================================
  -- INDEX S2
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_index_s2, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Index S2</strong> é a balança inteligente da Garmin: mede peso, IMC, percentual de gordura corporal, percentual de água corporal, massa muscular esquelética e massa óssea por bioimpedância, numa tela colorida embutida. Sincroniza direto com o Garmin Connect por Wi-Fi, sem precisar do celular por perto, e reconhece automaticamente até 16 perfis de usuário na mesma balança — cada pessoa da casa vê só os próprios dados.</p><p><strong>Público-alvo:</strong> quem já usa o ecossistema Garmin Connect (relógio ou não) e quer complementar os dados de treino com composição corporal, sem precisar digitar nada manualmente.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Bioimpedância completa", "text": "Peso, IMC, % de gordura, % de água, massa muscular e massa óssea.", "tags": []},
      {"title": "Sincronização Wi-Fi automática", "text": "Envia os dados pro Garmin Connect sem precisar do celular por perto.", "tags": []},
      {"title": "Até 16 perfis automáticos", "text": "Reconhece quem subiu na balança e separa o histórico de cada pessoa.", "tags": []},
      {"title": "Carga máxima 181,4 kg", "text": "Suporta praticamente qualquer usuário da casa.", "tags": []},
      {"title": "Tela colorida embutida", "text": "Mostra o resultado na hora, sem precisar abrir o app.", "tags": []},
      {"title": "Integra com o histórico de treino", "text": "Peso e composição corporal aparecem junto dos outros dados no Garmin Connect.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_index_s2, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Já usa relógio Garmin e Garmin Connect", "text": "Quer ver peso e composição corporal junto do resto dos dados de treino e recuperação.", "tags": [{"label": "Ecossistema", "color": "gold"}]},
      {"title": "Casa com mais de uma pessoa", "text": "Cada morador tem o próprio histórico, sem precisar selecionar perfil manualmente.", "tags": [{"label": "Família", "color": "blue"}]},
      {"title": "Quer acompanhar tendência, não só o número do dia", "text": "Valoriza gráfico de evolução ao longo do tempo em vez de uma leitura isolada.", "tags": [{"label": "Acompanhamento", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente já usa Garmin Connect e quer complementar com dados de composição corporal</li><li>Mais de uma pessoa na casa vai usar a balança e querem histórico separado</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente busca uma medição clínica validada — bioimpedância doméstica é uma estimativa de acompanhamento, não um exame diagnóstico</li><li>Cliente não usa nem pretende usar o Garmin Connect — sem o app, a balança perde a maior parte da utilidade</li></ul>"}
  ]}
  $j$),
  (v_p_index_s2, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Bioimpedância completa", "html": "<p>Além do peso, calcula IMC, percentual de gordura corporal, percentual de água corporal, massa muscular esquelética e massa óssea — tudo na mesma pesada.</p>"},
      {"title": "Sincronização Wi-Fi automática", "html": "<p>A balança se conecta direto à internet por Wi-Fi e envia os dados pro Garmin Connect sozinha, sem precisar levar o celular junto até o banheiro.</p>"},
      {"title": "Reconhecimento automático de até 16 perfis", "html": "<p>A balança identifica quem subiu nela (por peso e padrão de bioimpedância) e registra no histórico da pessoa certa, sem precisar selecionar usuário manualmente antes de pesar.</p>"},
      {"title": "Carga máxima 181,4 kg", "html": "<p>Suporta a maioria dos usuários domésticos sem restrição.</p>"},
      {"title": "Tela colorida embutida", "html": "<p>Mostra peso e tendência na hora, direto no visor da balança, sem precisar abrir o app pra ver o resultado.</p>"}
    ]}
  ]}
  $j$),
  (v_p_index_s2, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pra quem já usa Garmin Connect", "dialog": "Já que você já acompanha seus treinos pelo Garmin Connect, o Index S2 completa esse quadro com peso e composição corporal, sincronizando sozinho por Wi-Fi sem precisar digitar nada.", "tip": "Bom gancho pra cliente que já tem relógio Garmin ou já usa o app."},
      {"title": "Puxando o reconhecimento automático de perfil", "dialog": "Se mais de uma pessoa em casa for usar a balança, ela reconhece automaticamente quem subiu e separa o histórico de cada um, sem precisar selecionar nada na tela.", "tip": "Ótimo argumento pra venda em família ou casal."},
      {"title": "Fechamento", "dialog": "Com o Index S2 você sai com peso, IMC, gordura, água, massa muscular e óssea, tudo sincronizado sozinho no Garmin Connect.", "tip": "Se o cliente perguntar sobre precisão clínica, deixe claro que é uma estimativa de acompanhamento de tendência, não um exame médico."}
    ]}
  ]}
  $j$),
  (v_p_index_s2, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Essa medição de bioimpedância é precisa?", "answer": "É uma estimativa doméstica útil pra acompanhar a tendência ao longo do tempo — não substitui um exame clínico, mas mostra bem se a composição corporal está melhorando ou piorando entre uma pesagem e outra."},
      {"question": "Preciso levar o celular toda vez que for pesar?", "answer": "Não — o Index S2 sincroniza sozinho com o Garmin Connect por Wi-Fi, sem precisar do celular por perto."},
      {"question": "Serve pra mais de uma pessoa na mesma casa?", "answer": "Sim, reconhece automaticamente até 16 perfis de usuário e separa o histórico de cada pessoa sem precisar selecionar nada manualmente."}
    ]}
  ]}
  $j$),
  (v_p_index_s2, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Cliente com relógio Garmin querendo completar o ecossistema", "text": "Já acompanha treino e sono, quer somar composição corporal no mesmo app.", "tags": []},
      {"title": "Casal ou família comprando pra casa toda", "text": "Valoriza o reconhecimento automático de perfil pra não misturar histórico.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_index_s2, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Qual a carga máxima do Index S2?", "html": "<p>181,4 kg.</p>"},
      {"title": "Precisa do celular por perto pra sincronizar?", "html": "<p>Não — a balança conecta direto por Wi-Fi e sincroniza sozinha com o Garmin Connect.</p>"},
      {"title": "Quantos perfis de usuário ela reconhece automaticamente?", "html": "<p>Até 16 perfis na mesma balança.</p>"},
      {"title": "O que ela mede além do peso?", "html": "<p>IMC, percentual de gordura corporal, percentual de água corporal, massa muscular esquelética e massa óssea, por bioimpedância.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- Quiz Especialista
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-index-s2', 'Quiz Especialista: Index S2', 70, true) returning id into v_quiz;

  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Como o Index S2 sincroniza os dados com o Garmin Connect?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Direto por Wi-Fi, sem precisar do celular por perto', true, 1), (v_q, 'Só por Bluetooth com o celular por perto', false, 2), (v_q, 'Precisa conectar um cabo USB', false, 3), (v_q, 'Não sei', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Quantos perfis de usuário o Index S2 reconhece automaticamente?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 16 perfis', true, 1), (v_q, 'Até 4 perfis', false, 2), (v_q, 'Só 1 perfil por balança', false, 3), (v_q, 'Não sei', false, 4);

  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Além do peso, o que o Index S2 mede por bioimpedância?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'IMC, % de gordura, % de água, massa muscular e óssea', true, 1), (v_q, 'Só a frequência cardíaca', false, 2), (v_q, 'Só a altura', false, 3), (v_q, 'Não sei', false, 4);

  insert into product_quizzes (product_id, quiz_id)
  select id, (select id from quizzes where slug = 'quiz-especialista-index-s2') from products where slug = 'index-s2';

  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-index-s2-garmin', 'Especialista Index S2', 'Concedido ao passar no Quiz Especialista do Index S2.', '{"tipo": "quiz_especialista_produto", "produto": "index-s2"}');
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 142
-- ============================================================================
