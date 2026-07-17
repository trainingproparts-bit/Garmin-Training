-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 055: "prateleira vazia" das certificações 3/4/5
-- ============================================================================
-- Pedido do usuário: completar a Certificação 2 (Atleta/Corredor, Zona Atleta)
-- com os Módulos 4-7, e criar 3 certificações novas (Maratonista, Triatleta,
-- Aventureiro), cada uma com sua própria zona sequencial e módulos — tudo
-- como "prateleira vazia": título real, zero lições/perguntas, conteúdo
-- "[a preencher]" nos campos de resumo. Módulo 4 da Zona Atleta
-- ("Métricas Essenciais de Corrida") é a ÚNICA exceção — recebe conteúdo
-- completo na migração seguinte (sql/056).
--
-- Decisão confirmada com o usuário: módulos "prateleira vazia" ficam
-- is_published = true (aparecem na trilha na posição certa, com o badge
-- visual normal de bloqueado/disponível conforme a sequência) mas com ZERO
-- lições — abrir um mostra "Conteúdo em preparação" (já existe em
-- moduloConteudo.js, zero código novo necessário). Quizzes-placeholder
-- seguem o mesmo princípio: publicados, zero perguntas (QuizRunner já trata
-- isso com "Este quiz ainda não tem perguntas cadastradas").
--
-- Achado importante (pesquisa prévia): fn_issue_certification é genérica
-- (conta checkpoints obrigatórios de qualquer zona com certifications.zone_id
-- setado) — criar zona+certificação nova já basta pra emissão funcionar.
-- MAS fn_grant_badge_on_certification tem um CASE hardcoded (só sabia
-- 'explorador'→explorer e 'corredor'→runner) — sem atualizar essa função,
-- as 3 certificações novas emitiriam o certificado mas NUNCA concederiam
-- badge. Corrigido nesta migração junto com o seed dos 3 badges novos.
--
-- Reordenação: Circuito de Desafios (order_index 3→6) e Nível 2 (4→7) foram
-- empurrados pra depois das 3 novas zonas sequenciais, mantendo a progressão
-- narrativa Explorador→Atleta→Maratonista→Triatleta→Aventureiro→Desafios
-- Extras. Pura reordenação (order_index), não deleta nem desvincula nada.
--
-- ACHADO CRÍTICO (só apareceu ao tentar rodar a primeira versão desta
-- migração): já existiam certifications com slug 'maratonista' e 'triatleta'
-- na base — dangling, zone_id null, criteria.note dizendo literalmente "zona
-- ainda não existe... UI trata como bloqueada até o conteúdo ser criado".
-- Ou seja, alguém já tinha rascunhado esses 2 níveis antes, com um plano de
-- módulos DIFERENTE do que o usuário pediu agora (ex.: Maratonista antigo
-- era "linhas premium Fenix/Descent/Edge", não "endurance/ritmo/nutrição").
-- certificacao.js também já tem CERT_VISUAL com emoji/cor pra esses 2 slugs
-- (não pra 'aventureiro') — e criteria.objective/level/required_modules SÃO
-- renderizados de verdade nos cards da tela Certificações. Por isso: os 2
-- slugs existentes são ATUALIZADOS (zone_id + criteria novo, refletindo os
-- módulos reais agora criados), nunca inseridos de novo (evita duplicar
-- linha/violar unique constraint). 'aventureiro' é criado do zero (não
-- existia antes) — e ganha uma entrada CERT_VISUAL nova em certificacao.js.
-- ============================================================================

update zones set order_index = 6 where id = '919ce86f-456c-4cc3-a2ce-2f4ae370bdbd'; -- Circuito de Desafios
update zones set order_index = 7 where id = '5436de90-b090-43dc-95b0-15237036d129'; -- Circuito de Desafios · Nível 2

do $$
declare
  v_trail_id   uuid := '0f1d6962-f6f9-4c40-a1e3-0bb4693f3fe5';
  v_brand_id   uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1';
  v_zona_atleta_id uuid := '7ded46e1-864c-4122-be37-bf99f0385683';

  v_zona_marat_id  uuid;
  v_zona_tri_id    uuid;
  v_zona_avent_id  uuid;

  v_mod_id     uuid;
  v_quiz_id    uuid;
  v_cp_order   int;
  v_mod_order  int;
begin
  -- ==========================================================================
  -- 1. Certificação 2 (Atleta) — completar Zona Atleta com Módulos 4-7
  -- ==========================================================================
  v_cp_order := 4;  -- checkpoints 0-3 já existem (Garmin Connect/Coach + quizzes)
  v_mod_order := 2; -- modules 0-1 já existem

  -- Módulo 4: Métricas Essenciais de Corrida (conteúdo completo vem em sql/056)
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_atleta_id, 'metricas-essenciais-corrida', 'Métricas Essenciais de Corrida', '[a preencher]', v_mod_order, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_atleta_id, 'module', v_mod_id, v_cp_order, true);

  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-metricas-essenciais-corrida', 'Quiz — Métricas Essenciais de Corrida', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_atleta_id, 'quiz', v_quiz_id, v_cp_order + 1, true);

  -- Módulo 5: O Próximo Passo na Bike — Linha Edge de Entrada e Sensores
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_atleta_id, 'linha-edge-entrada-sensores', 'O Próximo Passo na Bike — Linha Edge de Entrada e Sensores', '[a preencher]', v_mod_order + 1, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_atleta_id, 'module', v_mod_id, v_cp_order + 2, true);

  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-linha-edge-entrada-sensores', 'Quiz — Linha Edge de Entrada e Sensores', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_atleta_id, 'quiz', v_quiz_id, v_cp_order + 3, true);

  -- Módulo 6: Introdução à Potência e Dinâmica de Pedal
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_atleta_id, 'potencia-dinamica-pedal', 'Introdução à Potência e Dinâmica de Pedal', '[a preencher]', v_mod_order + 2, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_atleta_id, 'module', v_mod_id, v_cp_order + 4, true);

  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-potencia-dinamica-pedal', 'Quiz — Potência e Dinâmica de Pedal', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_atleta_id, 'quiz', v_quiz_id, v_cp_order + 5, true);

  -- Módulo 7: Contornando Objeções de Preço
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_atleta_id, 'contornando-objecoes-de-preco', 'Contornando Objeções de Preço', '[a preencher]', v_mod_order + 3, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_atleta_id, 'module', v_mod_id, v_cp_order + 6, true);

  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-contornando-objecoes-de-preco', 'Quiz — Contornando Objeções de Preço', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_atleta_id, 'quiz', v_quiz_id, v_cp_order + 7, true);

  -- ==========================================================================
  -- 2. Certificação 3: Maratonista (nova zona + 4 módulos)
  -- ==========================================================================
  insert into public.zones (trail_id, name, free_order, order_index)
  values (v_trail_id, 'Zona Maratonista', false, 3)
  returning id into v_zona_marat_id;

  -- 'maratonista' já existia (dangling, zone_id null, criteria de um plano
  -- antigo/diferente) — atualiza em vez de inserir, pra não violar a unique
  -- constraint de slug e pra corrigir o que os cards de Certificações mostram.
  update public.certifications
     set zone_id = v_zona_marat_id,
         criteria = jsonb_build_object(
           'level', 'Nível 3',
           'color', '#9b59b6',
           'objective', 'Preparar o colaborador para atender corredores de longa distância: planejamento de prova, prontidão física e segurança em provas de resistência.',
           'required_modules', jsonb_build_array(
             jsonb_build_object('order', 1, 'title', 'Portfólio de Endurance', 'module_slug', 'portfolio-de-endurance', 'modules_implemented_in_trail', true),
             jsonb_build_object('order', 2, 'title', 'O Triângulo da Prontidão', 'module_slug', 'triangulo-da-prontidao', 'modules_implemented_in_trail', true),
             jsonb_build_object('order', 3, 'title', 'Ferramentas de Ritmo e Planejamento de Prova', 'module_slug', 'ferramentas-ritmo-planejamento-prova', 'modules_implemented_in_trail', true),
             jsonb_build_object('order', 4, 'title', 'Segurança, Aclimatação e Nutrição em Longas Distâncias', 'module_slug', 'seguranca-aclimatacao-nutricao-longas-distancias', 'modules_implemented_in_trail', true)
           )
         )
   where slug = 'maratonista';

  v_cp_order := 0;
  v_mod_order := 0;

  -- Módulo 1: Portfólio de Endurance
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_marat_id, 'portfolio-de-endurance', 'Portfólio de Endurance', '[a preencher]', v_mod_order, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_marat_id, 'module', v_mod_id, v_cp_order, true);
  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-portfolio-de-endurance', 'Quiz — Portfólio de Endurance', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_marat_id, 'quiz', v_quiz_id, v_cp_order + 1, true);

  -- Módulo 2: O Triângulo da Prontidão
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_marat_id, 'triangulo-da-prontidao', 'O Triângulo da Prontidão', '[a preencher]', v_mod_order + 1, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_marat_id, 'module', v_mod_id, v_cp_order + 2, true);
  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-triangulo-da-prontidao', 'Quiz — O Triângulo da Prontidão', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_marat_id, 'quiz', v_quiz_id, v_cp_order + 3, true);

  -- Módulo 3: Ferramentas de Ritmo e Planejamento de Prova
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_marat_id, 'ferramentas-ritmo-planejamento-prova', 'Ferramentas de Ritmo e Planejamento de Prova', '[a preencher]', v_mod_order + 2, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_marat_id, 'module', v_mod_id, v_cp_order + 4, true);
  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-ferramentas-ritmo-planejamento-prova', 'Quiz — Ferramentas de Ritmo e Planejamento de Prova', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_marat_id, 'quiz', v_quiz_id, v_cp_order + 5, true);

  -- Módulo 4: Segurança, Aclimatação e Nutrição em Longas Distâncias
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_marat_id, 'seguranca-aclimatacao-nutricao-longas-distancias', 'Segurança, Aclimatação e Nutrição em Longas Distâncias', '[a preencher]', v_mod_order + 3, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_marat_id, 'module', v_mod_id, v_cp_order + 6, true);
  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-seguranca-aclimatacao-nutricao', 'Quiz — Segurança, Aclimatação e Nutrição', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_marat_id, 'quiz', v_quiz_id, v_cp_order + 7, true);

  -- ==========================================================================
  -- 3. Certificação 4: Triatleta (nova zona + 4 módulos)
  -- ==========================================================================
  insert into public.zones (trail_id, name, free_order, order_index)
  values (v_trail_id, 'Zona Triatleta', false, 4)
  returning id into v_zona_tri_id;

  -- 'triatleta' também já existia dangling — mesmo tratamento (update, não insert).
  update public.certifications
     set zone_id = v_zona_tri_id,
         criteria = jsonb_build_object(
           'level', 'Nível 4',
           'color', '#F0A500',
           'objective', 'Preparar o colaborador para o público multiesporte de alta performance: GPS multibanda, sensores de elite e fechamento de vendas premium.',
           'required_modules', jsonb_build_array(
             jsonb_build_object('order', 1, 'title', 'O Universo Multiesporte', 'module_slug', 'universo-multiesporte', 'modules_implemented_in_trail', true),
             jsonb_build_object('order', 2, 'title', 'GPS Multibanda (SatIQ) e Cartografia Completa', 'module_slug', 'gps-multibanda-satiq-cartografia-completa', 'modules_implemented_in_trail', true),
             jsonb_build_object('order', 3, 'title', 'Ecossistema de Sensores de Elite', 'module_slug', 'ecossistema-sensores-de-elite', 'modules_implemented_in_trail', true),
             jsonb_build_object('order', 4, 'title', 'Fechamento de Vendas Premium', 'module_slug', 'fechamento-de-vendas-premium', 'modules_implemented_in_trail', true)
           )
         )
   where slug = 'triatleta';

  v_cp_order := 0;
  v_mod_order := 0;

  -- Módulo 1: O Universo Multiesporte
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_tri_id, 'universo-multiesporte', 'O Universo Multiesporte', '[a preencher]', v_mod_order, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_tri_id, 'module', v_mod_id, v_cp_order, true);
  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-universo-multiesporte', 'Quiz — O Universo Multiesporte', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_tri_id, 'quiz', v_quiz_id, v_cp_order + 1, true);

  -- Módulo 2: GPS Multibanda (SatIQ) e Cartografia Completa
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_tri_id, 'gps-multibanda-satiq-cartografia-completa', 'GPS Multibanda (SatIQ) e Cartografia Completa', '[a preencher]', v_mod_order + 1, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_tri_id, 'module', v_mod_id, v_cp_order + 2, true);
  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-gps-multibanda-satiq-cartografia', 'Quiz — GPS Multibanda (SatIQ) e Cartografia', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_tri_id, 'quiz', v_quiz_id, v_cp_order + 3, true);

  -- Módulo 3: Ecossistema de Sensores de Elite
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_tri_id, 'ecossistema-sensores-de-elite', 'Ecossistema de Sensores de Elite', '[a preencher]', v_mod_order + 2, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_tri_id, 'module', v_mod_id, v_cp_order + 4, true);
  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-ecossistema-sensores-de-elite', 'Quiz — Ecossistema de Sensores de Elite', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_tri_id, 'quiz', v_quiz_id, v_cp_order + 5, true);

  -- Módulo 4: Fechamento de Vendas Premium
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_tri_id, 'fechamento-de-vendas-premium', 'Fechamento de Vendas Premium', '[a preencher]', v_mod_order + 3, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_tri_id, 'module', v_mod_id, v_cp_order + 6, true);
  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-fechamento-de-vendas-premium', 'Quiz — Fechamento de Vendas Premium', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_tri_id, 'quiz', v_quiz_id, v_cp_order + 7, true);

  -- ==========================================================================
  -- 4. Certificação 5: Aventureiro (nova zona + 5 módulos)
  -- ==========================================================================
  insert into public.zones (trail_id, name, free_order, order_index)
  values (v_trail_id, 'Zona Aventureiro', false, 5)
  returning id into v_zona_avent_id;

  -- 'aventureiro' não existia antes (diferente de maratonista/triatleta) — insert normal.
  insert into public.certifications (brand_id, trail_id, slug, title, criteria, zone_id)
  values (
    v_brand_id, v_trail_id, 'aventureiro', 'Aventureiro',
    jsonb_build_object(
      'level', 'Nível 5',
      'color', '#2E86AB',
      'objective', 'Preparar o colaborador para o público outdoor e náutico: portfólio GPSMAP, cartografia avançada e resistência em ambientes extremos.',
      'required_modules', jsonb_build_array(
        jsonb_build_object('order', 1, 'title', 'Portfólio GPSMAP e Diferencial do GPS Dedicado', 'module_slug', 'portfolio-gpsmap-diferencial-gps-dedicado', 'modules_implemented_in_trail', true),
        jsonb_build_object('order', 2, 'title', 'Cartografia e Navegação Avançada', 'module_slug', 'cartografia-navegacao-avancada', 'modules_implemented_in_trail', true),
        jsonb_build_object('order', 3, 'title', 'Aplicações Náuticas e Marinas', 'module_slug', 'aplicacoes-nauticas-marinas', 'modules_implemented_in_trail', true),
        jsonb_build_object('order', 4, 'title', 'Autonomia, Aclimatação e Resistência em Ambientes Extremos', 'module_slug', 'autonomia-aclimatacao-resistencia-ambientes-extremos', 'modules_implemented_in_trail', true),
        jsonb_build_object('order', 5, 'title', 'Contornando Objeções do Público Outdoor', 'module_slug', 'contornando-objecoes-publico-outdoor', 'modules_implemented_in_trail', true)
      )
    ),
    v_zona_avent_id
  );

  v_cp_order := 0;
  v_mod_order := 0;

  -- Módulo 1: Portfólio GPSMAP e Diferencial do GPS Dedicado
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_avent_id, 'portfolio-gpsmap-diferencial-gps-dedicado', 'Portfólio GPSMAP e Diferencial do GPS Dedicado', '[a preencher]', v_mod_order, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_avent_id, 'module', v_mod_id, v_cp_order, true);
  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-portfolio-gpsmap-gps-dedicado', 'Quiz — Portfólio GPSMAP e GPS Dedicado', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_avent_id, 'quiz', v_quiz_id, v_cp_order + 1, true);

  -- Módulo 2: Cartografia e Navegação Avançada
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_avent_id, 'cartografia-navegacao-avancada', 'Cartografia e Navegação Avançada', '[a preencher]', v_mod_order + 1, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_avent_id, 'module', v_mod_id, v_cp_order + 2, true);
  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-cartografia-navegacao-avancada', 'Quiz — Cartografia e Navegação Avançada', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_avent_id, 'quiz', v_quiz_id, v_cp_order + 3, true);

  -- Módulo 3: Aplicações Náuticas e Marinas
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_avent_id, 'aplicacoes-nauticas-marinas', 'Aplicações Náuticas e Marinas', '[a preencher]', v_mod_order + 2, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_avent_id, 'module', v_mod_id, v_cp_order + 4, true);
  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-aplicacoes-nauticas-marinas', 'Quiz — Aplicações Náuticas e Marinas', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_avent_id, 'quiz', v_quiz_id, v_cp_order + 5, true);

  -- Módulo 4: Autonomia, Aclimatação e Resistência em Ambientes Extremos
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_avent_id, 'autonomia-aclimatacao-resistencia-ambientes-extremos', 'Autonomia, Aclimatação e Resistência em Ambientes Extremos', '[a preencher]', v_mod_order + 3, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_avent_id, 'module', v_mod_id, v_cp_order + 6, true);
  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-autonomia-aclimatacao-resistencia', 'Quiz — Autonomia, Aclimatação e Resistência', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_avent_id, 'quiz', v_quiz_id, v_cp_order + 7, true);

  -- Módulo 5: Contornando Objeções do Público Outdoor
  insert into public.modules (zone_id, slug, title, summary, order_index, is_published)
  values (v_zona_avent_id, 'contornando-objecoes-publico-outdoor', 'Contornando Objeções do Público Outdoor', '[a preencher]', v_mod_order + 4, true)
  returning id into v_mod_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_avent_id, 'module', v_mod_id, v_cp_order + 8, true);
  insert into public.quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-objecoes-publico-outdoor', 'Quiz — Objeções do Público Outdoor', 70, true)
  returning id into v_quiz_id;
  insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
  values (v_zona_avent_id, 'quiz', v_quiz_id, v_cp_order + 9, true);

end $$;

-- ============================================================================
-- 5. Badges novos (Maratonista, Triatleta, Aventureiro) — só marca Garmin,
--    mesmo padrão dos badges reais (Shokz ainda não tem trilha/zonas, sql/090).
-- ============================================================================
insert into public.badges (brand_id, slug, title, rule)
select id, 'maratonista-' || slug, 'Maratonista', '{}'::jsonb from public.brands where slug = 'garmin'
union all
select id, 'triatleta-' || slug, 'Triatleta', '{}'::jsonb from public.brands where slug = 'garmin'
union all
select id, 'aventureiro-' || slug, 'Aventureiro', '{}'::jsonb from public.brands where slug = 'garmin';

-- ============================================================================
-- 6. Atualiza fn_grant_badge_on_certification pra conhecer os 3 slugs novos
--    (sem isso, as certificações emitiriam normalmente mas nunca dariam badge).
-- ============================================================================
create or replace function public.fn_grant_badge_on_certification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cert_slug   text;
  v_badge_key   text;
  v_real_certs  integer;
  v_brand_id    uuid;
begin
  select slug, brand_id into v_cert_slug, v_brand_id from certifications where id = new.certification_id;

  v_badge_key := case v_cert_slug
    when 'explorador'   then 'explorer'
    when 'corredor'     then 'runner'
    when 'maratonista'  then 'maratonista'
    when 'triatleta'    then 'triatleta'
    when 'aventureiro'  then 'aventureiro'
    else null
  end;

  if v_badge_key is not null then
    perform fn_grant_badge(new.user_id, v_badge_key, v_brand_id);
  end if;

  -- Triathlete = trilha real inteira concluída (hoje, Explorador + Corredor —
  -- Maratonista/Triatleta/Aventureiro são certificações à parte, não contam
  -- pro badge histórico Triathlete, que continua no critério original).
  if v_cert_slug in ('explorador', 'corredor') then
    select count(*) into v_real_certs
      from user_certifications uc
      join certifications c on c.id = uc.certification_id
     where uc.user_id = new.user_id
       and c.slug in ('explorador', 'corredor')
       and uc.revoked_at is null;

    if v_real_certs = 2 then
      perform fn_grant_badge(new.user_id, 'triathlete', v_brand_id);
    end if;
  end if;

  return new;
end;
$$;

comment on function public.fn_grant_badge_on_certification() is
  'Concede badge ao emitir certificação de zona. Conhece explorador/corredor/maratonista/triatleta/aventureiro (sql/055) — badge_key = slug da certificação, exceto explorador→explorer e corredor→runner (nomes legados em inglês). Triathlete continua exclusivo de Explorador+Corredor (trilha histórica).';

-- ============================================================================
-- FIM DA MIGRAÇÃO 055
-- ============================================================================
