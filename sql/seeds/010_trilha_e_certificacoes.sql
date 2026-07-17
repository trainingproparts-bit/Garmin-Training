-- ============================================================================
-- SEED 010: TRILHA "GPS DA CARREIRA" + CERTIFICAÇÕES (marca: garmin)
-- ============================================================================
-- Migra para SQL a trilha de formação real hoje hardcoded em
-- index_redesign_v5.html, a partir de três estruturas de dados existentes
-- no protótipo (nada aqui é inventado, apenas normalizado):
--   • const GPS_ZONES        (~linha 8358) — zonas reais da trilha e a ordem
--                                            real dos checkpoints de cada uma.
--   • const CHECKPOINT_META  (~linha 8458) — ícone/título/painel de cada
--                                            checkpoint referenciado em GPS_ZONES.
--   • const certs            (~linha 4314) — os 4 níveis de certificação
--                                            (Explorador/Corredor/Maratonista/
--                                            Triatleta) e seus "mods" (currículo).
-- Título/resumo de cada módulo foi conferido contra o conteúdo real dos
-- respectivos <div class="panel" id="panel-...">: panel-universo (~3116),
-- panel-perfis-modulo (~3159), panel-produtos-modulo (~6115),
-- panel-concorrentes-modulo (~6369), panel-corredor-connect (~2494) e
-- panel-corredor-coach (~2798).
--
-- ORDEM DE EXECUÇÃO ESPERADA:
--   1. garmin_training_hub_migrations.sql   (schema base: brands, trails,
--      zones, modules, checkpoints, certifications, triggers de validação)
--   2. sql/002_content_library_schema.sql   (não é pré-requisito direto deste
--      arquivo, mas faz parte da mesma sprint de consolidação)
--   3. sql/seeds/020_quizzes.sql e sql/seeds/030_games.sql — PRECISAM rodar
--      antes deste arquivo: a SEÇÃO 5 abaixo cria checkpoints do tipo
--      'quiz'/'game' cujas subqueries exigem que esses registros já existam
--      (reference_id é NOT NULL e validado por trigger).
--   4. este arquivo (sql/seeds/010_trilha_e_certificacoes.sql)
--
-- IMPORTANTE — idempotência parcial:
--   • trails, modules e certifications têm unique constraint (slug) e por
--     isso usam `on conflict (...) do nothing` — seguro rodar mais de uma vez.
--   • zones e checkpoints NÃO têm unique constraint prático para dado de
--     seed (zones tem unique(trail_id, order_index), mas checkpoints não tem
--     nenhuma). Este script assume SCHEMA LIMPO / PRIMEIRA CARGA para essas
--     duas tabelas — rodar duas vezes duplica zones/checkpoints.
--
-- AMBIGUIDADE DE JULGAMENTO (documentada, não escondida):
--   O array `certs` (currículo/marketing das certificações) e o array real
--   `GPS_ZONES` (checkpoints de fato implementados no app) NÃO batem 1:1:
--     • Nível 1 (Explorador): `certs[0].mods` lista 5 itens, incluindo
--       "Script de Atendimento" e "Objeções Comuns" como módulos distintos.
--       Só existem, de fato, 4 checkpoints implementados na zona
--       'explorador' (universo, perfis-modulo, produtos-modulo,
--       concorrentes-modulo) — "Objeções Comuns" está coberto pelo módulo
--       concorrentes-modulo; "Script de Atendimento" não tem checkpoint
--       próprio hoje.
--     • Níveis 2 a 4 (Corredor/Maratonista/Triatleta): a zona real
--       'corredor' só tem 2 checkpoints (corredor-connect, corredor-coach),
--       enquanto `certs[1].mods` descreve 4 módulos ("Linha Forerunner
--       Completa", "Métricas de Corrida", etc.) que não têm checkpoint
--       implementado. As zonas 'maratonista' e 'triatleta' referenciadas em
--       `heroLevels` (por id) SEQUER EXISTEM em GPS_ZONES — o próprio
--       código-fonte trata isso como conteúdo futuro (`if (!zone) state =
--       'locked'`).
--   Decisão adotada: `modules`/`checkpoints` migram exclusivamente o que
--   está REAL e IMPLEMENTADO em GPS_ZONES/CHECKPOINT_META. `certifications`
--   migram os 4 níveis do array `certs` por completo (conforme pedido),
--   guardando o currículo aspiracional em `criteria` (jsonb) — inclusive
--   para os módulos que ainda não têm checkpoint real — e sinalizando esse
--   gap com o campo "modules_implemented_in_trail" em cada criteria.
--   Os checkpoints do "Circuito de Desafios" (zonas free_order 'desafios' e
--   'desafios2') foram marcados como is_required = false: o próprio rótulo
--   da zona ("quizzes e games extras") indica conteúdo bônus, não uma
--   trava de certificação.
-- ============================================================================


-- ============================================================================
-- 1) TRAILS — a trilha "GPS da Carreira"
-- ============================================================================
-- Nome e legenda vêm literalmente da UI (gps-hud-brand e gps-hud-caption em
-- index_redesign_v5.html, ~linha 2204 e 2228). Nenhum texto de marketing foi
-- inventado.
insert into trails (brand_id, slug, name, description, order_index, is_published)
values (
  (select id from brands where slug = 'garmin'),
  'gps-carreira',
  'GPS da Carreira',
  'Trilha de formação por zonas: conclua os módulos em ordem, acerte o quiz com a nota mínima exigida e avance no percurso até a certificação.',
  1,
  true
)
on conflict (brand_id, slug) do nothing;


-- ============================================================================
-- 2) ZONES — as 4 zonas reais de GPS_ZONES, na ordem do array
-- ============================================================================
-- free_order = true apenas nas zonas "Circuito de Desafios" (id 'desafios' e
-- 'desafios2'), exatamente como no protótipo (`freeOrder: true`), onde os
-- checkpoints ficam liberados de uma vez, sem bloqueio sequencial.
-- Assume schema limpo / primeira carga (sem on conflict — ver nota no topo).
insert into zones (trail_id, name, banner_message, free_order, order_index, unlock_rule)
values
  (
    (select id from trails where slug = 'gps-carreira'),
    'Zona Explorador',
    'Zona Explorador concluída! Você abriu a Zona Atleta.',
    false,
    1,
    '{}'::jsonb
  ),
  (
    (select id from trails where slug = 'gps-carreira'),
    'Zona Atleta',
    'Zona Atleta concluída! Você está pronto para a Zona Maratonista.',
    false,
    2,
    '{}'::jsonb
  ),
  (
    (select id from trails where slug = 'gps-carreira'),
    'Circuito de Desafios',
    'Circuito de Desafios completo! Você dominou todos os quizzes e games extras.',
    true,
    3,
    '{}'::jsonb
  ),
  (
    (select id from trails where slug = 'gps-carreira'),
    'Circuito de Desafios · Nível 2',
    'Circuito Nível 2 completo! Você dominou as cintas de frequência cardíaca.',
    true,
    4,
    '{}'::jsonb
  );


-- ============================================================================
-- 3) MODULES — um módulo por checkpoint do tipo 'module' em GPS_ZONES
-- ============================================================================
-- slug = mesmo id usado como data-checkpoint no HTML (universo, perfis-modulo,
-- produtos-modulo, concorrentes-modulo, corredor-connect, corredor-coach) —
-- preserva rastreabilidade 1:1 com o protótipo. title/summary conferidos
-- contra CHECKPOINT_META e o conteúdo real de cada panel (ver cabeçalho).
-- estimated_minutes não existe em nenhuma fonte real — deixado NULL
-- (não inventado).
insert into modules (zone_id, slug, title, summary, estimated_minutes, order_index, is_published)
values
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 1),
    'universo',
    'O Universo Garmin',
    'História, posicionamento e DNA da marca.',
    null,
    1,
    true
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 1),
    'perfis-modulo',
    'Perfis de Cliente',
    'Os 12 perfis: como identificar e comunicar.',
    null,
    2,
    true
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 1),
    'produtos-modulo',
    'Portfólio de Produtos',
    'Conheça cada linha, seus modelos e para quem cada um serve.',
    null,
    3,
    true
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 1),
    'concorrentes-modulo',
    'Concorrentes & Objeções',
    'Cada concorrente tem um público real. Saber onde o Garmin vence é o que separa um atendimento mediano de um que fecha.',
    null,
    4,
    true
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 2),
    'corredor-connect',
    'Garmin Connect',
    'O app que dá vida ao relógio. Entenda o que ele monitora e como cada dado vira argumento de venda.',
    null,
    1,
    true
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 2),
    'corredor-coach',
    'Garmin Coach',
    'Um personal trainer vitalício e gratuito dentro do relógio.',
    null,
    2,
    true
  )
on conflict (slug) do nothing;


-- ============================================================================
-- 4) CHECKPOINTS — tipo 'module', um por entrada de GPS_ZONES já migrada
-- ============================================================================
-- Assume schema limpo / primeira carga (sem on conflict — ver nota no topo).
-- is_required = true: são os módulos "de conteúdo" das zonas sequenciais
-- (explorador/corredor), que de fato gated o avanço no percurso no protótipo.
insert into checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
values
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 1),
    'module',
    (select id from modules where slug = 'universo'),
    1,
    true
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 1),
    'module',
    (select id from modules where slug = 'perfis-modulo'),
    2,
    true
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 1),
    'module',
    (select id from modules where slug = 'produtos-modulo'),
    3,
    true
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 1),
    'module',
    (select id from modules where slug = 'concorrentes-modulo'),
    4,
    true
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 2),
    'module',
    (select id from modules where slug = 'corredor-connect'),
    1,
    true
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 2),
    'module',
    (select id from modules where slug = 'corredor-coach'),
    2,
    true
  );


-- ============================================================================
-- 5) CHECKPOINTS — tipo 'quiz'/'game' (Circuito de Desafios)
-- ============================================================================
-- Antes pendente (a trigger trg_validate_checkpoint_reference exige que
-- reference_id já exista em `quizzes`/`games`, coluna NOT NULL). Agora que
-- sql/seeds/020_quizzes.sql e sql/seeds/030_games.sql existem, este bloco
-- passa a ser executável — DESDE QUE RODADO DEPOIS DELES (ordem: 010 seções
-- 1-4 → 020 → 030 → 010 seção 5. Na prática, mais simples rodar este arquivo
-- por último, depois de 020 e 030, já que as seções 1-4 não dependem deles).
--
-- Os slugs abaixo são os reais definidos em 020_quizzes.sql/030_games.sql
-- (não os nomes de painel do protótipo, ex. "quiz-ipx" virou o slug
-- 'ipx-resistencia-agua' — ver cabeçalho de cada arquivo de seed).
--
-- is_required = false em todos: a própria zona é rotulada "Circuito de
-- Desafios" — não é um gate de certificação.
insert into checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
values
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 3),
    'quiz',
    (select id from quizzes where slug = 'ipx-resistencia-agua'),
    1,
    false
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 3),
    'quiz',
    (select id from quizzes where slug = 'atendimento-cenarios'),
    2,
    false
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 3),
    'quiz',
    (select id from quizzes where slug = 'instinct-3'),
    3,
    false
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 3),
    'quiz',
    (select id from quizzes where slug = 'metricas-tecnicas'),
    4,
    false
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 3),
    'game',
    (select id from games where slug = 'duelo-instinct-3-vs-e'),
    5,
    false
  ),
  (
    (select id from zones where trail_id = (select id from trails where slug = 'gps-carreira') and order_index = 4),
    'quiz',
    (select id from quizzes where slug = 'cintas-hrm'),
    1,
    false
  );


-- ============================================================================
-- 6) CERTIFICATIONS — os 4 níveis do array `certs`
-- ============================================================================
-- criteria (jsonb) guarda o currículo tal como descrito em `certs[i].mods` e
-- `certs[i].skills`, com o objetivo (`obj`) e o quiz de conclusão de cada
-- nível. O campo "modules_implemented_in_trail" documenta, por módulo,
-- se já existe um checkpoint real na trilha (true) ou se é currículo
-- aspiracional ainda sem conteúdo implementado (false) — ver ambiguidade
-- descrita no cabeçalho do arquivo.

-- 6.1 Nível 1 — Explorador
insert into certifications (brand_id, trail_id, slug, title, criteria, certificate_template_url)
values (
  (select id from brands where slug = 'garmin'),
  (select id from trails where slug = 'gps-carreira'),
  'explorador',
  'Explorador',
  '{
    "level": "Nível 1",
    "color": "#E31020",
    "objective": "Dominar o portfólio básico Garmin, entender os perfis de cliente mais comuns e realizar um atendimento estruturado do início ao fim.",
    "skills": [
      "Identificar os perfis de cliente mais frequentes",
      "Apresentar o produto certo baseado na sondagem",
      "Usar o script de atendimento com confiança",
      "Explicar o Garmin Connect e a sincronização",
      "Contornar as 3 objeções mais comuns"
    ],
    "required_modules": [
      {"order": 1, "title": "O Universo Garmin", "summary": "História, posicionamento e DNA da marca.", "modules_implemented_in_trail": true, "module_slug": "universo"},
      {"order": 2, "title": "Perfis de Cliente", "summary": "Os 12 perfis: como identificar e comunicar.", "modules_implemented_in_trail": true, "module_slug": "perfis-modulo"},
      {"order": 3, "title": "Script de Atendimento", "summary": "Os 5 passos do atendimento presencial.", "modules_implemented_in_trail": false, "module_slug": null},
      {"order": 4, "title": "Objeções Comuns", "summary": "As principais objeções e como respondê-las.", "modules_implemented_in_trail": false, "module_slug": null}
    ],
    "quiz": {"title": "Quiz Explorador", "questions": 10, "min_score_pct": 70, "points": 100}
  }'::jsonb,
  null
)
on conflict (slug) do nothing;

-- 6.2 Nível 2 — Corredor
insert into certifications (brand_id, trail_id, slug, title, criteria, certificate_template_url)
values (
  (select id from brands where slug = 'garmin'),
  (select id from trails where slug = 'gps-carreira'),
  'corredor',
  'Corredor',
  '{
    "level": "Nível 2",
    "color": "#00C2A8",
    "objective": "Dominar tecnicamente toda a linha Forerunner e vender para corredores de todos os níveis com autoridade.",
    "skills": [
      "Diferenciar cada modelo Forerunner",
      "Explicar GPS multibanda e FirstBeat",
      "Apresentar PacePRO, Training Readiness e Body Battery",
      "Integrar Garmin com Strava e TrainingPeaks"
    ],
    "required_modules": [
      {"order": 1, "title": "Linha Forerunner Completa", "summary": "FR55 ao FR970: diferenças técnicas.", "modules_implemented_in_trail": false, "module_slug": null},
      {"order": 2, "title": "Métricas de Corrida", "summary": "PacePRO, potência, VO2 Max, Training Effect.", "modules_implemented_in_trail": false, "module_slug": null},
      {"order": 3, "title": "Ecossistema do Corredor", "summary": "Strava, TrainingPeaks, Stryd, planos adaptativos.", "modules_implemented_in_trail": false, "module_slug": null}
    ],
    "quiz": {"title": "Quiz Corredor", "questions": 25, "min_score_pct": 70, "points": 100},
    "note": "A zona real ''corredor'' da trilha hoje contém apenas os checkpoints corredor-connect e corredor-coach (Garmin Connect / Garmin Coach) — o currículo Forerunner/métricas/ecossistema acima é aspiracional e ainda não tem módulo implementado."
  }'::jsonb,
  null
)
on conflict (slug) do nothing;

-- 6.3 Nível 3 — Maratonista
insert into certifications (brand_id, trail_id, slug, title, criteria, certificate_template_url)
values (
  (select id from brands where slug = 'garmin'),
  (select id from trails where slug = 'gps-carreira'),
  'maratonista',
  'Maratonista',
  '{
    "level": "Nível 3",
    "color": "#F0A500",
    "objective": "Dominar linhas premium (Fenix, Instinct, Descent, Edge) e vender para atletas de alta performance.",
    "skills": [
      "Apresentar Fenix 8 e Descent com autoridade",
      "Dominar linha Edge de ciclocomputadores",
      "Conduzir comparação Garmin vs concorrentes"
    ],
    "required_modules": [
      {"order": 1, "title": "Linha Premium: Fenix, Enduro, Instinct", "summary": "Diferenciais técnicos e argumentação.", "modules_implemented_in_trail": false, "module_slug": null},
      {"order": 2, "title": "Mergulho: Série Descent", "summary": "Bühlmann, nitrox e modos técnicos.", "modules_implemented_in_trail": false, "module_slug": null},
      {"order": 3, "title": "Ciclismo: Edge + Rally + Varia", "summary": "Edge 540/840/1050 + pedais de potência + radar.", "modules_implemented_in_trail": false, "module_slug": null},
      {"order": 4, "title": "Concorrentes em Profundidade", "summary": "Apple Watch, Polar, Coros — argumentação.", "modules_implemented_in_trail": false, "module_slug": null}
    ],
    "quiz": {"title": "Quiz Maratonista", "questions": 30, "min_score_pct": 75, "points": 100},
    "note": "Nível ainda sem zona própria em GPS_ZONES (a UI trata a zona ''maratonista'' como bloqueada/inexistente até que o conteúdo seja criado)."
  }'::jsonb,
  null
)
on conflict (slug) do nothing;

-- 6.4 Nível 4 — Triatleta
insert into certifications (brand_id, trail_id, slug, title, criteria, certificate_template_url)
values (
  (select id from brands where slug = 'garmin'),
  (select id from trails where slug = 'gps-carreira'),
  'triatleta',
  'Triatleta',
  '{
    "level": "Nível 4",
    "color": "#FF6B35",
    "objective": "Tornar-se referência técnica da equipe e ter capacidade de treinar novos colaboradores.",
    "skills": [
      "Dominar 100% do portfólio incluindo náutico e GPS portátil",
      "Conduzir treinamentos para novos colaboradores",
      "Configurar qualquer produto Garmin ao vivo"
    ],
    "required_modules": [
      {"order": 1, "title": "Portfólio Completo: Náutico, inReach, GPS", "summary": "ECHOMAP, Striker, GPSMAP, inReach, Zumo.", "modules_implemented_in_trail": false, "module_slug": null},
      {"order": 2, "title": "Configuração Avançada", "summary": "Configurar qualquer modelo, Connect IQ, planos.", "modules_implemented_in_trail": false, "module_slug": null},
      {"order": 3, "title": "Mentoria e Liderança", "summary": "Como transmitir o conhecimento para novos.", "modules_implemented_in_trail": false, "module_slug": null}
    ],
    "quiz": {"title": "Quiz Final Triatleta", "questions": 40, "min_score_pct": 80, "points": 100},
    "note": "Nível ainda sem zona própria em GPS_ZONES (a UI trata a zona ''triatleta'' como bloqueada/inexistente até que o conteúdo seja criado)."
  }'::jsonb,
  null
)
on conflict (slug) do nothing;


-- ============================================================================
-- FIM DA SEED 010
-- ============================================================================
