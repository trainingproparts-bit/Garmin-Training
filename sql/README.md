# SQL — ordem de execução

Este projeto tem duas gerações de arquivo SQL: o schema original (raiz do
projeto) e as migrações/seeds desta Sprint 1 (pasta `sql/`). Nenhum deles foi
aplicado ainda ao projeto Supabase real usado pelo app — isso foi confirmado
durante o teste local desta sprint (a tabela `quizzes` retornou 404 ao
consultar o banco real). Rode os arquivos abaixo, nesta ordem exata, no SQL
Editor do Supabase:

1. **`../garmin_training_hub_migrations.sql`** (raiz do projeto)
   Schema base completo: `brands`, `trails`, `zones`, `modules`, `lessons`,
   `checkpoints`, `quizzes`, `questions`, `alternatives`, `games`,
   certificações, gamificação, RLS, views, materialized views. Sem isso,
   nada mais funciona.

2. **`002_content_library_schema.sql`**
   Tabela nova `content_library` (biblioteca técnica: perfis de cliente,
   produtos, FAQ, concorrentes, especialidades) — domínio que não existia na
   modelagem original.

3. **`003_quiz_submission_hardening.sql`**
   Cria `fn_submit_quiz_answer` (RPC) e revoga INSERT direto em
   `quiz_answers` do papel `authenticated`. Sem isso, o QuizRunner do app
   novo não consegue gravar respostas com segurança (o gabarito nunca é
   exposto ao cliente).

3.5. **`004_performance_score.sql`** (Sprint 3)
   Adiciona `profiles.performance_score` (cache do total),
   `fn_sync_performance_score` (trigger que sincroniza esse cache com
   `points_ledger`), estende o CHECK de `source_type` para incluir
   `'lesson'` e cria a RPC `fn_complete_lesson` que fecha o ciclo de
   conclusão da lição. Pré-requisito para o botão "Concluir" do módulo
   funcionar.

4. **`seeds/020_quizzes.sql`**
   11 quizzes / 121 perguntas / 481 alternativas, migrados fielmente de
   `index_redesign_v5.html`.

5. **`seeds/030_games.sql`**
   Os 2 minigames "Duelo de Especificações" (Instinct 3 vs Instinct E, e
   MARQ Golfer/Athlete/Commander).

6. **`seeds/010_trilha_e_certificacoes.sql`**
   Trilha "GPS da Carreira", zonas, módulos, checkpoints (inclui os
   checkpoints do tipo `quiz`/`game` — por isso precisa rodar **depois** dos
   itens 4 e 5) e as 4 certificações.

7. **`seeds/040_biblioteca_tecnica.sql`**
   Perfis de cliente, produtos, FAQ, concorrentes e especialidades —
   pode rodar a qualquer momento depois do item 2 (não depende de 4/5/6).

8. **`seeds/050_licoes_modulo1_2.sql`**, **`051_licoes_modulo3_4.sql`**,
   **`052_licoes_corredor.sql`** (Sprint 2)
   Texto real das aulas dos 6 módulos (Universo Garmin, Perfis de Cliente,
   Produtos, Concorrentes, Corredor Connect, Corredor Coach) — 22 lições ao
   todo, em `lessons.body` (`{"html": "..."}`). Precisam rodar depois do
   item 6 (dependem de `modules` já existir).

9. **`seeds/060_biblioteca_deep_dives_a.sql`** e **`061_biblioteca_deep_dives_b.sql`**
   — **já aplicados (2026-07-10)**
   Os 8 guias técnicos de leitura longa (inReach, GPS de mão, náutico, Edge
   ciclismo, Apps/Integrações, novidades 2026, Blaze Equine, MARQ Gen 2) —
   categoria `deep_dive` em `content_library`. Ficaram escritos e prontos
   desde a Sprint 2 mas só foram rodados no banco real agora, como fonte de
   conteúdo da fileira "Linhas Especiais e Novidades" do redesign visual
   (ver item 29 abaixo) — antes disso, `deep_dive` tinha 0 linhas em
   produção.

10. **`005_evaluations_and_notifications.sql`** (Sprint 4) — **já aplicado**
    Motor de Avaliações Trimestrais: `evaluations`, `evaluation_questions`
    (+ view pública sem `correct_option`), `evaluation_attempts` (trava de
    24h após reprovar, liberável por líder/admin) e `notifications`
    (sininho do dashboard), incluindo a trigger que avisa o usuário quando
    ele conclui a última lição publicada de uma trilha. Depende de
    `garmin_training_hub_migrations.sql` (tabelas `lessons`/`modules`/
    `zones`/`trails`/`profiles`) e de `fn_is_admin`/`fn_is_leader`/
    `fn_leader_store_ids` (já criadas no schema base).

11. **`007_evaluations_dedupe_and_unique.sql`** (Sprint 4 — **rodar assim que possível**)
    `evaluations` nunca teve constraint única, e `seeds/070` usava
    `on conflict do nothing` sem apontar pra nenhuma — cada re-execução do
    seed criava linhas novas em vez de ser ignorada. Isso já aconteceu no
    projeto real: `fetchEvaluationQuestions('explorer')` quebrou com
    `PGRST116` ("Cannot coerce the result to a single JSON object"), sinal
    de mais de uma linha por `type`. Este arquivo remove as duplicatas
    (mantendo a mais antiga de cada tier) e adiciona as constraints que
    faltavam. **Rode antes de qualquer nova tentativa de usar a tela de
    Avaliações Trimestrais.**

12. **`seeds/070_evaluations_mock.sql`** (Sprint 4) — **já aplicado, mas
    seguro rodar de novo depois do item 11**
    15 perguntas reais (5 por tier: Explorer, Runner, Triathlete). Agora
    aponta pras constraints do item 11 no `on conflict`, então rodar de
    novo não duplica mais nada.

13. **`006_evaluation_submission_engine.sql`** (Sprint 4) — **já aplicado**
    `evaluation_answers` + `fn_start_evaluation_attempt` /
    `fn_submit_evaluation_answer` / `fn_finish_evaluation_attempt` — fecha
    o ciclo que a 005 deixou pendente (a trava de 24h agora é exercitável
    de ponta a ponta: responder → corrigir no servidor → gravar
    aprovado/reprovado). Mesmo padrão de `003_quiz_submission_hardening.sql`.
    Independente do item 11/12, mas parte da mesma sprint.

14. **`008_profiles_privilege_escalation_fix.sql`** — **rodar assim que possível**
    Bug de segurança real e pré-existente (não introduzido por esta sprint):
    `profiles_update_own` no schema base só restringe qual linha pode ser
    tocada, nunca quais colunas — um colaborador podia se autopromover a
    admin com um `PATCH` direto em `role_id`. Este arquivo adiciona uma
    trigger que bloqueia qualquer edição de `role_id`/`store_id`/`brand_id`/
    `status`/`deleted_at`/`username` por quem não é admin. Não depende de
    nenhum outro arquivo desta lista além do schema base.

15. **`009_handle_new_user_profile.sql`** — **já aplicado**
    Trigger `trg_handle_new_user` (AFTER INSERT em `auth.users`) + função
    `fn_handle_new_user()` (SECURITY DEFINER): cria a linha correspondente em
    `public.profiles` no momento do signup, com `role_id = 1` (collaborator)
    como default — antes disso, `profiles` nunca era populada e ficava órfã
    (achado do diagnóstico de 2026-07-09). Cobre só usuários **novos**; não
    retroage para quem já existia em `auth.users`.

16. **`010_backfill_profiles_stores_leaders.sql`** — **já aplicado**
    Backfill pontual dos 14 usuários que existiam em `auth.users` antes do
    trigger 009 existir: cria as 4 linhas de `stores` (Morumbi/Moema × Garmin/
    Shokz — `stores.brand_id` é obrigatório e a tabela `profile_brands` que a
    modelagem original cogitou para multi-marca por usuário nunca foi
    criada), os 14 `profiles` e os 3 vínculos em `store_leaders`. Precisa
    rodar em **duas transações separadas** (o arquivo já vem dividido assim):
    um `WITH` único falha porque o trigger de validação de `store_leaders`
    não enxerga o que outro CTE de escrita gravou no mesmo comando.

17. **`011_migrate_real_emails_samara_mariana.sql`** — **já aplicado**
    Mesmo tipo de troca de e-mail (via `UPDATE` direto, sem Admin API) já
    feita antes pra Ailma/Mayara, agora pra Samara (`samara.pereira@
    proparts.net.br`) e Mariana (`mariana.muzzio@proparts.esp.br`) —
    confirmado com o usuário que são e-mails reais de fato.

18. **`012_fix_samara_admin_profile_after_recreate.sql`** — **já aplicado**
    Corrige um incidente pontual: o usuário recriou a conta da Samara direto
    no Supabase Dashboard (não conseguia resetar a senha antiga), o que
    apagou o profile admin original via CASCADE e o trigger 009 criou um
    profile de colaborador padrão pro id novo. Este arquivo restaura
    `full_name`/`role_id` de admin pro id novo.

19. **`013_fix_rls_helper_functions_recursion.sql`** — **já aplicado, rodar
    assim que possível se ainda não tiver rodado**
    Bug real e pré-existente (não introduzido por nenhuma sprint), achado ao
    testar o Painel Admin/Dashboard do Líder com login real de admin pela
    primeira vez: `fn_is_admin()`/`fn_is_leader()`/`fn_leader_store_ids()`
    não eram `SECURITY DEFINER`, e como as próprias policies de `profiles`
    chamam essas funções (que por sua vez consultam `profiles`/
    `store_leaders`), a checagem de papel recursionava de verdade até
    `54001 stack depth limit exceeded`. Corrigido marcando as 3 funções
    `SECURITY DEFINER` (padrão recomendado pelo Supabase pra esse caso).
    Sem isso, **nem Painel Admin nem Dashboard do Líder conseguem listar
    a equipe**.

20. **`014_resolve_login_email_by_username.sql`** — **já aplicado**
    Login por username sem o cliente precisar saber/adivinhar domínio de
    e-mail. Função `fn_resolve_login_email(username)` (`SECURITY DEFINER`,
    só devolve o e-mail de um username exato, liberada pra `anon`/
    `authenticated`) chamada por `src/services/authService.js:signIn()`
    antes do `signInWithPassword`. Substitui a lógica anterior que completava
    `${username}@proparts.net.br` no cliente — quebrava pra quem tem e-mail
    real em outro domínio e vazava o domínio interno `@proparts.internal`.

21. **`015_store_knowledge_gaps_view.sql`** — **já aplicado e testado ao
    vivo com dados sintéticos (removidos depois do teste)**
    View `vw_store_knowledge_gaps` para o "Relatório de Gaps da Equipe" do
    Dashboard do Líder: taxa de erro por pergunta nos últimos 30 dias
    (`quiz_answers`/`quiz_attempts`/`questions`/`quizzes`, schema base —
    nenhuma tabela nova), com o filtro de loja/papel embutido na própria
    query (`fn_is_admin()`/`fn_is_leader()`/`fn_leader_store_ids()`, já
    `SECURITY DEFINER` desde o item 19). Consumida por
    `src/services/teamService.js:fetchStoreKnowledgeGaps()` e
    `src/pages/teamGapsReport.js`. O linter de segurança acusa "Security
    Definer View" — mesmo padrão de todas as outras views do schema, não é
    problema novo.

22. **`016_admin_create_user_rpc.sql`** — **já aplicado**
    Função `fn_admin_finalize_new_profile` — apoio à Edge Function
    `supabase/functions/admin-create-user` (cadastro de usuário pelo admin,
    RN 1.1). Ajusta `role_id`/`store_id`/`brand_id` do profile recém-criado
    pelo trigger 009 sem esbarrar em `trg_guard_profile_self_update` (008):
    simula a identidade de quem pediu a ação só dentro da própria transação
    (`set_config('request.jwt.claims', ...)`) e revalida `fn_is_admin()` de
    verdade no servidor. `EXECUTE` revogado de `anon`/`authenticated` — só
    chamável por `service_role` (a Edge Function).

23. **`017_fix_certification_issuance_scope.sql`** — **já aplicado**
    `fn_issue_certification()` contava checkpoints obrigatórios de **toda a
    trilha** somada, não da zona de cada certificação — achado ao testar o
    fluxo completo de colaborador pela primeira vez (login → lição → quiz →
    certificado, item do `ROADMAP.md`). `certifications` ganha `zone_id`
    (populado para Explorador/Corredor; null de propósito para Maratonista/
    Triatleta, que não têm zona real ainda). Trigger reescrita pra contar só
    checkpoints da zona daquela certificação específica.

24. **`018_fix_module_checkpoint_completion.sql`** — **já aplicado**
    `fn_update_user_progress_from_lesson()` marcava o checkpoint do módulo
    como `completed` assim que **uma** lição batia 100%, sem checar as
    outras — um colaborador podia pular lições e destravar o quiz cedo
    demais. Corrigido pra exigir todas as lições publicadas do módulo
    concluídas.

25. **`019_fix_certification_trigger_insert.sql`** — **já aplicado**
    `trg_issue_certification` disparava só `AFTER UPDATE` em `user_progress`
    — mas a conclusão de um checkpoint quase sempre é um `INSERT` (primeira
    vez), nunca um `UPDATE`. Ou seja, certificação nunca era emitida na
    prática, mesmo com `017` corrigido. Trigger agora dispara em
    `INSERT OR UPDATE`.

26. **`020_expose_zone_level_in_gaps_view.sql`** — **já aplicado**
    `vw_store_knowledge_gaps` passa a expor `zone_name`/`certification_title`/
    `certification_level` (via `checkpoints`→`zones`→`certifications.zone_id`,
    item 23), pra o Card de Alerta do Relatório de Gaps classificar o nível
    do módulo (Nível 1–4) sem heurística de texto sobre `quiz_title`. `null`
    quando o quiz não é checkpoint de nenhuma zona com certificação (Circuito
    de Desafios, quizzes extras). Precisou `DROP VIEW` + `CREATE VIEW` (não dá
    pra inserir coluna no meio via `CREATE OR REPLACE VIEW`).

27. **`021_game_submission_hardening.sql`** — **já aplicado, testado ao vivo**
    Achado que Games estava **quebrado**, não só sem hardening: `game_sessions`
    não tinha policy de `UPDATE` (o `PATCH` de fechar sessão retornava 204
    mas afetava 0 linhas) e `game_scores` não tinha policy de `INSERT` (403
    direto). Nova tabela `game_round_answers` (equivalente a `quiz_answers`)
    + `fn_submit_game_round`/`fn_finalize_game_session` (`SECURITY DEFINER`,
    mesmo padrão do item 3) — placar sempre calculado no servidor a partir de
    `games.config`, nunca do valor que o cliente mandar. Consumido por
    `src/services/gameService.js` e `src/components/GameRunner.js`.

28. **`022_activity_feed.sql`** — **já aplicado, testado ao vivo (posts de
    teste removidos depois)**
    Mural de Atividades (RN §6.10 / modelagem §6.8): tabela `activity_feed`
    (texto puro, sem upload de mídia), RLS de leitura global dentro da marca
    do próprio perfil, gatilhos automáticos (`AFTER INSERT`) pra badge
    conquistado (`user_badges`) e certificação emitida (`user_certifications`),
    e `fn_leader_post_activity` — único caminho de postagem manual do
    líder/admin, sempre por template fixo (nunca texto livre), validando
    escopo de loja via `fn_leader_store_ids()`. Seed dos 5 badges nomeados
    (Explorer/Runner/Triathlete/Gabarito Garmin/Ritmo Constante, slug com
    sufixo de marca porque `badges.slug` é único globalmente). Realtime
    habilitado (`supabase_realtime` publication) — front assina `INSERT` e
    injeta o card sem polling. Consumido por
    `src/services/activityFeedService.js`,
    `src/components/DashboardHome.js` (painel "Atividades Recentes") e
    `src/pages/liderDashboard.js` (seção "Destaques do Balcão").

29. **`023_badge_granting_engine.sql`** — **já aplicado, testado ao vivo (dado
    sintético removido depois)**
    Fecha o loop que o item 28 deixou pendente: os 5 badges e o trigger de
    Mural já existiam, mas nada até então inseria em `user_badges`. Regra
    decidida com o usuário (a partir das descrições já escritas em 022):
    Explorer/Runner concedidos na emissão da certificação de zona
    correspondente (`explorador`/`corredor`, mesmo evento de
    `trg_issue_certification`, schema base); Triathlete quando as duas
    estiverem emitidas e não revogadas (hoje é a trilha real inteira —
    Maratonista/Triatleta não têm zona/conteúdo próprio, item 23); Gabarito
    Garmin na 1ª tentativa de qualquer quiz fechando com 100%. Ritmo
    Constante **fora de escopo** — depende de sistema de streak (job diário,
    pausa em fim de semana, RN §6.5) que não existe ainda. Helper
    `fn_grant_badge(user_id, badge_key)` resolve a marca do próprio perfil e
    grava de forma idempotente (`uq_user_badges`); cada concessão já dispara
    o post automático no Mural (item 28) sem código adicional.

30. **`024_lesson_content_blocks_migration.sql`** — **já aplicado, testado ao
    vivo com dado real (bloco de teste removido depois)**
    Converte as 38 lições reais de `lessons.body` de `{"html": "..."}` único
    para `{"blocks": [{"type": "texto_rico", "html": "..."}]}` — schema de
    blocos tipados da Fase 4 (UX §6.6), subconjunto de 8 tipos essenciais
    decidido com o usuário (banner, texto_rico, accordion, card, timeline,
    video, galeria, quiz_embutido) dos 20 documentados. `UPDATE` genérico
    (sem hardcode de ID), sem perda de conteúdo — só empacota o HTML
    existente como primeiro bloco. Ver `src/components/ContentBlocks.js`
    (render + editor) e `src/pages/moduloConteudo.js` (editor administrativo,
    admin-only). `content_library` (categoria `deep_dive`) não tem nenhuma
    linha em produção — `sql/seeds/060`/`061_biblioteca_deep_dives_*.sql`
    foram corrigidos na origem para já nascerem no formato de blocos, sem
    precisar de migração aqui.

31. **`025_ranking_store_highlights.sql`** — **já aplicado, testado ao vivo**
    Tabela `store_sales_highlights` — texto curto de "Destaque de Vendas" por
    loja, atualizado manualmente todo mês por Admin ou pelo Líder daquela
    loja (pedido direto do usuário em 2026-07-10, não documentado na RN). 1
    linha por loja (`uq_store_sales_highlights_store`), sem histórico —
    cada atualização substitui a anterior. RLS: leitura pra qualquer
    autenticado da mesma marca da loja (ou admin, vê tudo); escrita só
    admin (qualquer loja) ou líder (só as suas, via `fn_leader_store_ids()`
    — mesma função de `sql/013`/`sql/022`). Testado ao vivo: líder tentando
    editar loja fora da própria gestão via chamada direta (bypassando a UI)
    foi bloqueado pela RLS, não só pela interface.

32. **`026_ranking_public_view.sql`** — **já aplicado, testado ao vivo**
    Achado ao testar o Ranking de Pontos (item 31/`src/pages/ranking.js`)
    com login real de colaborador comum: `profiles` só tem RLS de `SELECT`
    pra si mesmo (`profiles_select_own`), pro líder ver a própria loja
    (`profiles_select_leader`) ou pro admin ver tudo (`profiles_admin_all`)
    — nenhuma política deixava um colaborador comum ver o placar de outro
    colega, então o ranking aparecia com 1 linha só (a dele mesmo) pra
    qualquer um que não fosse líder/admin. Corrigido com
    `v_ranking_public` — view estreita (mesmo padrão de
    `v_alternatives_public`, `v_evaluation_questions_public`,
    `vw_store_knowledge_gaps`), expõe só id/full_name/performance_score/
    store_id/store_name/brand_id de perfis ativos, nunca e-mail/role/
    status/job_title. Escopo de marca embutido na própria view
    (`fn_is_admin()` vê tudo; qualquer outro autenticado só a própria
    marca — sem isso um admin com `brand_id` nulo veria zero linhas).

33. **`027_cover_url_columns.sql`** — **já aplicado, testado ao vivo**
    Redesign visual "estilo streaming" (2026-07-10): coluna `cover_url`
    (nullable) em `modules` e `quizzes`, pro card 16:9 da trilha/Quizzes
    Extras — `content_library` não precisou de coluna nova (`payload` já é
    jsonb, capa fica em `payload.cover_url`). Nenhuma foto real existe hoje
    (nem banco, nem Storage); enquanto isso, os cards mostram um gradiente +
    ícone, com um controle "Editar capa" (admin-only, `window.prompt` com a
    URL) pra trocar por foto de verdade quando existir. RLS já cobria
    `UPDATE` via `modules_admin_all`/`quizzes_admin_all` (`ALL`, schema
    base) — sem policy nova. Testado ao vivo como admin (Samara): capa
    salva, aparece no card, revertida depois do teste.

34. **`028_deep_dive_rich_blocks.sql`** — **já aplicado, testado ao vivo**
    As seeds 060/061 tinham migrado os 8 artigos de "Linhas Especiais" como
    um único bloco `texto_rico` de prosa corrida, perdendo a estrutura
    visual rica do protótipo original (cards comparativos, tabelas de
    especificação, passos de script de venda com fala literal, blocos de
    objeção). Este arquivo reconstrói os 8 artigos usando 4 tipos de bloco
    novos em `ContentBlocks.js`/`contentBlocks.css` — `roteiro` (passos
    numerados com fala em destaque + botão "Copiar Argumento" + dica),
    `objecao` (pergunta do cliente + resposta), `tabela` (comparativo em
    colunas) e `card_grid` (grade de 2-3 colunas com tags coloridas) —
    lidos linha a linha do protótipo `index_redesign_v5.html` e gravados via
    `jsonb_set(payload, '{blocks}', ...)` (preserva `cover_url` se existir).
    Acompanha também um ajuste de densidade CSS (`shell.css`/
    `modulo-content.css`/`contentBlocks.css`): remove uma camada de padding
    duplicada em `.panel-body` do painel de lição e reduz padding/
    line-height/margens que deixavam a leitura com "zoom" exagerado.

35. **`029_deep_dive_tab_groups.sql`** — **já aplicado, testado ao vivo**
    Complementa a 028: os 3 guias mais densos (inReach, Edge, Apps/
    Integrações/Tecnologias) tinham um seletor de abas (`.itabs`) no
    protótipo original, que a 028 tinha achatado numa lista sequencial
    única — forçando rolagem infinita. Esta migração reagrupa os mesmos
    blocos (sem alterar nenhum texto) em `{ intro, tabs: [{label, blocks}] }`
    — `src/pages/deepDiveDetail.js` (novo painel dedicado por guia, ver
    abaixo) sabe renderizar isso como abas clicáveis. Os outros 5 guias
    continuam com `{ blocks: [...] }` liso (não tinham abas no original).

36. **`030_module_lessons_rich_blocks.sql`** — **já aplicado, testado ao vivo**
    Mesma correção de 028, agora nas 22 lições reais dos 6 módulos de
    treinamento (Universo Garmin, Perfis de Cliente, Portfólio de Produtos,
    Concorrentes & Objeções, Garmin Connect, Garmin Coach) — todas estavam
    achatadas num único bloco `texto_rico`. Reestrutura o mesmo texto usando
    os tipos de bloco já existentes (`timeline`, `card`, `card_grid`,
    `tabela`, `roteiro`, `objecao`, `banner`) lidos linha a linha do
    protótipo `index_redesign_v5.html` e cruzados com o texto já vigente em
    `lessons.body`. A árvore de decisão de diagnóstico do Garmin Coach (7
    desfechos) virou uma `tabela` "situação → plano indicado"; o simulador
    de ritmo com slider não tem equivalente em bloco de conteúdo (é uma
    ferramenta interativa, não texto) e ficou fora desta migração.

37. **`031_dedupe_connect_coach_lessons.sql`** — **já aplicado, testado ao vivo**
    Bug de dados pré-existente (Garmin Connect já documentado no
    ROADMAP.md; Garmin Coach tinha o mesmo bug e não estava documentado):
    cada lição vinha triplicada (3 UUIDs por título, mesmo conteúdo),
    fazendo cada lição aparecer 3× seguidas na tela do módulo. Confirmado
    que 0 linhas de `lesson_progress` referenciavam as duplicatas antes de
    apagar — sem risco de perder progresso de ninguém. 24 linhas → 8.

38. **`032_flip_card_widgets.sql`** — **já aplicado, testado ao vivo**
    028/029/030 tinham achatado os flip-cards do protótipo (clique pra virar
    e ver o verso) em `card_grid`/`roteiro` estáticos. Este arquivo introduz
    o tipo de bloco `flip_card` (`ContentBlocks.js`/`contentBlocks.css` —
    mesma técnica CSS 3D do `.cfi`/`.trainer-card` original: `perspective` +
    `transform-style: preserve-3d` + `backface-visibility: hidden`, clique
    alterna a classe `flipped`) e reconstrói os 3 pontos que usavam
    flip-cards: Forerunner 70/170 (Novidades 2026), os 4 perfis de cliente
    do estudo de caso do Garmin Connect, e os 3 treinadores de corrida do
    Garmin Coach — mesmo texto das migrações anteriores, agora com a
    interação de fato. Acompanha reversão do fundo escuro do card de lição
    (`.content-article` em `modulo-content.css`) para fundo claro/texto
    escuro — pedido explícito do usuário, que achou o tema escuro ruim para
    leitura de texto longo.

39. **`033_streak_engine.sql`** — **já aplicado, testado ao vivo**
    Fecha a lacuna de "Ritmo Constante FORA de escopo" deixada em `023`:
    engine de streak (RN §6.5). A tabela `streaks` e sua RLS **já existiam**
    no schema base, junto com um `fn_update_streak()` que lia de
    `study_sessions` — mas nada nunca populava essa tabela (confirmado por
    comentário pré-existente em `liderDashboard.js`) nem chamava essa função
    (confirmado em `pg_trigger`): código morto desde sempre. Substituído por
    `fn_touch_streak`, chamado reativamente por 4 triggers (`lesson_progress`,
    `quiz_attempts`, `game_sessions`, `evaluation_attempts` — sempre `AFTER
    INSERT OR UPDATE`, mesmo cuidado de `019`/`023` pra não perder o caso de
    "conclusão via INSERT direto"). Sem job diário: `v_streaks_effective`
    recalcula na leitura se o streak gravado ainda está vivo hoje. Pausa de
    fim de semana (RN §6.5): segunda, sábado e domingo usam sexta como piso;
    terça a sexta exigem o dia anterior. A cada 5 dias postam marco no Mural;
    no 5º dia concede o badge Ritmo Constante (`fn_grant_badge`, `023`).
    **Bug achado e corrigido durante o teste ao vivo** (rodei o teste num
    domingo real): a lógica de pausa de fim de semana só tratava segunda-feira
    olhando pra sexta — sábado/domingo caíam no ramo "senão" (ontem), o que
    quebraria o streak de qualquer atividade "bônus" de fim de semana.
    Corrigido pra sábado/domingo também usarem sexta como piso. Testado ao
    vivo com dado sintético (Daniel Lucena, revertido ao final): incremento
    dia-a-dia, marco de 5 dias com post no Mural + badge concedido, quebra de
    streak preservando o recorde histórico, e `v_streaks_effective` zerando
    corretamente um streak "fantasma" (gravado como 5, mas parado há 6 dias).

40. **`034_revoke_internal_only_rpcs.sql`** — **já aplicado, testado ao vivo**
    Achado pelo advisor de segurança do Supabase logo depois de aplicar `033`:
    `fn_touch_streak` (e as 4 funções de trigger) nasceram com `EXECUTE`
    concedido a `anon`/`authenticated` (grant padrão do Postgres, a menos que
    seja revogado) — qualquer usuário autenticado (ou anônimo) podia chamar
    `fn_touch_streak(p_user_id)` via RPC com um UUID arbitrário e manipular o
    streak de qualquer pessoa. Investigando o mesmo padrão, achei que
    `fn_grant_badge`/`fn_grant_badge_on_certification`/
    `fn_grant_badge_on_quiz_100` (`023`, **pré-existente, não introduzido
    agora**) tinham exatamente a mesma lacuna — `fn_grant_badge(p_user_id,
    p_badge_key)` podia ser chamada direto por qualquer um pra conceder
    qualquer badge a qualquer usuário, sem checagem nenhuma. Revogado
    `EXECUTE` de `anon`/`authenticated` nas 8 funções (as 5 novas de streak +
    as 3 de badge). Confirmado ao vivo que revogar não quebra nada: trigger e
    chamada função-a-função (`perform fn_x(...)` de dentro de outra
    `SECURITY DEFINER`) rodam com o privilégio do dono da função, não do
    papel que originou o evento — mesmo raciocínio já usado em `016` pra
    `fn_admin_finalize_new_profile`. **Correção: essa revogação não pegou de
    verdade — ver `036`.**

41. **`035_game_and_streak_xp.sql`** — **já aplicado, testado ao vivo**
    RN §6.1 lista as fontes de XP: "aprovação em quiz, conclusão de módulo,
    participação em game, badge/achievement, streak mantido, certificação
    emitida", com recomendação de valor "50 game". Quiz e lição já lançavam
    em `points_ledger`; game e streak, não. Fecha as 2 lacunas: (1)
    `fn_award_points_on_game_finish`, trigger em `game_sessions`, concede 50
    pts só na 1ª sessão finalizada de cada game por usuário (mesmo princípio
    "sem XP repetido" de quiz/lição — evita farm por replay livre, já que
    games não têm bloqueio sequencial por decisão de design); (2) o marco de
    5 dias de `fn_touch_streak` (`033`) ganhou um 3º efeito: além do post no
    Mural e do badge no 5º dia, agora também lança 20 pts em `points_ledger`
    (`source_type = 'streak'`, novo valor no `CHECK`, que antes só aceitava
    `quiz/module/lesson/game/badge/certification/manual_adjustment`).
    Testado ao vivo com dado sintético (Daniel Lucena, revertido ao final):
    sessão de game concedeu 50 pts, replay do mesmo game não duplicou,
    marco de streak concedeu 20 pts — `performance_score` bateu exatamente
    70 (50+20) antes da limpeza.

42. **`036_fix_public_execute_grant.sql`** — **já aplicado, testado ao vivo**
    Ao testar `035` ao vivo, fui conferir se a revogação de `034` tinha
    "pegado" de verdade antes de dar como resolvido — e não tinha.
    `has_function_privilege('anon', ..., 'EXECUTE')` continuava `true` pras 8
    funções de `034` (e pra `fn_award_points_on_game_finish`, nova em `035`).
    Causa raiz: toda função nova recebe `EXECUTE` concedido a `PUBLIC`
    automaticamente (comportamento padrão do Postgres — a ACL mostra
    `=X/postgres`, onde o `=` antes da barra é a notação de PUBLIC nesse
    formato). `anon`/`authenticated` são papéis comuns e herdam qualquer
    privilégio de PUBLIC implicitamente — revogar deles especificamente não
    tira nada enquanto PUBLIC continuar com o grant; precisa revogar de
    PUBLIC também. Corrigido nas 9 funções (as 8 de `034` + a nova de `035`).
    Confirmado ao vivo, depois da correção: `has_function_privilege` agora
    retorna `false` pra `anon`/`authenticated` nas 9, e o trigger de lição
    (`fn_touch_streak_on_lesson`) continua funcionando normalmente (streak
    criado corretamente ao completar uma lição de teste).

43. **`037_team_album.sql`** — **já aplicado, testado ao vivo**
    Álbum da Equipe, portado de `index_redesign_v5.html` — pedido direto do
    usuário. 5 colunas novas em `profiles` (`specialty`/`favorite_watch`/
    `sport`, autoeditáveis — mesma categoria de `emoji`/`phrase` que
    `fn_guard_profile_self_update`, sql/008, já liberava; `reputation_score`/
    `is_top_seller`, curadoria só-admin — o guard foi **estendido** pra
    bloquear autoedição desses 2 também). View `v_team_album` (mesmo padrão
    de `v_ranking_public`, sql/026): Produto/Precisão/Jogo calculados de
    dado real (`lesson_progress`/`quiz_attempts`/`game_scores`), Classe pela
    certificação mais alta emitida e não revogada. Ritmo não tem fonte real
    (RN não define, protótipo original também dependia de planilha externa)
    — aproximado no cliente como percentil de `performance_score`.
    **Decisão de escopo com o usuário:** manter todos os atributos do card
    original e deixá-los editáveis, exceto "Selo" (faixa de raridade
    editorial, sem significado de progresso) — removido.
    - **1 bug de segurança real encontrado e corrigido em revisão, antes de
      testar:** o fallback de avatar usava `onerror` inline interpolando
      texto livre do usuário (emoji) dentro de uma string de handler JS —
      vetor de XSS mais sério que interpolação simples em innerHTML.
      Corrigido anexando o listener de erro via JS depois de inserir no DOM.
    - **Bloqueio de infraestrutura durante a sessão:** o MCP do Supabase
      caiu no meio do desenvolvimento; o usuário aplicou este arquivo
      manualmente no SQL Editor antes do teste ao vivo poder continuar.
    - **Testado ao vivo com login real (Samara/admin e Daniel/colaborador),
      dado real da Garmin (11 pessoas):** grade renderizou corretamente;
      curadoria de admin (reputação + Ponta do Mês) salvou e refletiu na
      hora — revertida; autoedição de figurinha (Daniel) salvou e refletiu
      no modal de detalhe — revertida; **guard de segurança confirmado
      bypassando a UI** — chamada direta tentando autoeditar reputação como
      Daniel foi bloqueada pelo trigger estendido, mesma mensagem de erro
      do guard original.

44. **`038_dashboard_hero_cover_and_zone_rename.sql`** — **já aplicado, testado ao vivo**
    Pedido direto do usuário (simplificação da tela "Minha Trilha"): coluna
    `cover_url` nova em `trails` (mesmo padrão de `modules`/`quizzes`, sql/027)
    pro Hero Card ("GPS da Carreira") aceitar uma imagem de capa em tela
    cheia, com overlay escuro pra manter o texto legível — admin edita via
    botão "Editar capa" (mesmo padrão de prompt já usado nas Linhas
    Especiais). A zona antes chamada "Zona Corredor" passou a se chamar
    "Zona Atleta" (só o nome da zona e os banner_message que a citavam —
    certificação "Corredor" e slugs de módulo `corredor-connect`/
    `corredor-coach` não mudaram, fora do pedido). `DashboardHome.js`
    também passou a filtrar a fileira da trilha completa pra mostrar só as
    zonas `free_order` (Circuito de Desafios) — Zona Explorador/Atleta somem
    da tela "Minha Trilha", restando quizzes/circuito de desafios e Linhas
    Especiais; o card do Hero encolheu (padding/título menores, anel de
    112px→88px). O progresso/HUD/"Continuar treinamento" continuam usando
    as zonas completas (não filtradas) — só a fileira visual mudou.
    - **Testado ao vivo (Samara/admin):** capa em tela cheia renderizando
      corretamente (dado real já existente na coluna), zonas de módulo
      escondidas da tela, Circuito de Desafios + Linhas Especiais intactos,
      responsivo mobile (375px) sem overflow, zero erro de console.
    - **Refinamento seguinte, mesmo pedido (sem SQL novo):** dentro do
      Circuito de Desafios, quiz e "duelo" (game) agora ficam em fileiras
      separadas (`GpsTrail.js`/`renderZona` calcula o estado sequencial na
      ordem original da zona e só depois separa por `checkpoint_type` pra
      exibição — preserva a regra de liberação mesmo se uma zona não-livre
      um dia misturar tipos), com a fileira de duelo só aparecendo quando a
      zona realmente tem algum (`Circuito · Nível 2`, só quiz, não mostra
      "Duelos" vazio). Também removida a barra "← Escolher Marca / Garmin"
      que duplicava a navegação da sidebar só na tela "Minha Trilha" —
      as outras telas mantêm seus próprios cabeçalhos de volta.
    - **Mais um refinamento, mesmo pedido (sem SQL novo):** o Hero Card
      ganhou um toggle "Ver trilha completa" que revela uma visão compacta
      de TODAS as zonas (inclusive Explorador/Atleta, escondidas da fileira
      grande) — nós pequenos (30px) em vez de cards 16:9, numa grade que
      quebra linha (`flex-wrap`) em vez de scroll horizontal, cabendo com
      pouco scroll dentro do próprio card (`GpsTrail.js`/`renderMiniTrilha`,
      reaproveita a mesma lógica de estado sequencial de `renderZona` via
      um helper compartilhado `statusPorCheckpoint`). Clique num nó
      desbloqueado navega direto pro módulo/quiz/game, igual aos cards
      grandes. **Bug real encontrado e corrigido antes de fechar o
      teste:** o container começou visível mesmo com o atributo `hidden`,
      porque a regra `.mini-trail-wrap { display: flex }` (mesma
      especificidade de `[hidden]`) vinha depois no CSS e vencia — mesma
      classe de bug já documentada no redesign original (`.app-sidebar`).
      Corrigido com `.mini-trail-wrap[hidden] { display: none }`. Testado
      ao vivo (Samara/admin) em desktop e mobile (375px): toggle abre/fecha
      corretamente, os 18 nós renderizam com o status certo (atual/
      bloqueado), clique num nó atual navega pro módulo certo, zero erro
      de console.
    - **Dois pedidos seguintes, sem SQL novo:** (1) linhas da sidebar
      encolhidas (`shell.css` — padding de `.sb-link`/`.sb-brand`/
      `.sb-collapse-btn`/`.sb-quick-access`/`.sb-footer`/`.sb-profile`
      reduzido, ícone 18px→16px) pra caber os ~13 itens sem precisar do
      `overflow-y: auto` do `.app-sidebar` na maioria das telas. (2) ✓/✗
      literais dentro de blocos comparativos (`card_grid`/`tabela` em
      `ContentBlocks.js`) agora ganham cor automaticamente — verde
      (`#007a6a`, mesmo tom já usado em `.lib-comp-ours` no comparativo de
      concorrentes) pro check, vermelho (`var(--g)`) pro x — via um helper
      `colorizeCheckmarks()` que envolve cada símbolo num `<span>`, sem
      precisar editar o conteúdo de cada artigo (`content_library.payload`)
      um por um. Cobre os 4 artigos que já usam esse padrão (inReach,
      GPS de mão, Náutico, Edge — confirmado via query direta no payload).
    - **Background/cards trocados de volta, pedido do usuário:** `--bg-page`
      passou de branco puro (`#ffffff`) pra um cinza bem claro e neutro
      (`#f5f5f5`), e `--card-bg` passou a ser branco (`#ffffff`) — inverte a
      hierarquia que tinha sido decidida sessões atrás (página branca +
      card cinza) de volta pro padrão convencional (página cinza clarinho +
      card branco). `body` passou a usar `var(--bg-page)` em vez de
      `var(--white)` fixo (`base.css`) — como todos os "cards" já usavam
      `var(--card-bg)` desde a passada de tokens anterior, a troca inteira
      foi só nesses 2 valores de token, sem precisar tocar CSS de página
      por página.

39. **`039_quiz_answer_explanation.sql`** — **já aplicado, testado ao vivo**
    Bug real reportado pelo usuário: "antes aparecia um feedback com frase
    de explicação" nos quizzes — `questions.explanation` já existia no
    schema base com conteúdo real cadastrado, mas nunca foi selecionado por
    `quizService.fetchQuizForAttempt` nem renderizado por `QuizRunner.js`
    (não é regressão desta sessão — nunca foi ligado no app Vite). Corrigido
    servindo a explicação a partir do PRÓPRIO `fn_submit_quiz_answer` (que
    já busca a alternativa pra calcular `is_correct`) — a função passou a
    usar parâmetros `OUT` (`is_correct`, `explanation`) em vez de
    `RETURNS boolean`, retornando os dois juntos, sem round-trip extra e
    sem nunca expor a explicação de perguntas futuras antes de respondê-las
    (mesmo princípio que já protege `alternatives.is_correct`). `QuizRunner.js`
    agora mostra a explicação abaixo do "✓/✗ Resposta correta/incorreta".
    - **Testado ao vivo (Samara/admin), Quiz Especial — IPX & Resistência à
      Água:** explicação renderizando certo tanto pra resposta certa quanto
      errada; 30 testes do Vitest atualizados e passando (mock do RPC
      mudou de `data: true/false` pra `data: {is_correct, explanation}`).
      Tentativas de teste (`quiz_attempts`/`quiz_answers`) apagadas depois.

40. **`040_fix_game_round_answer_options.sql`** — **já aplicado, testado ao vivo**
    Bug real reportado pelo usuário: a tela de "Duelo de Especificações" só
    mostrava 2 das 4 opções de resposta. Causa raiz: `GameRunner.js` montava
    os botões a partir de `Object.keys(round.reveal)` (só os concorrentes
    comparados — 2 ou 3), ignorando `games.config.meta.opcoes_resposta`, que
    já define o conjunto real de respostas (ex.: `instinct3`/`instincte`/
    `ambos`/`nenhum` no duelo 1v1; `golfer`/`athlete`/`commander`/`todos` no
    duelo 3 vias) — os botões de empate/nenhum nunca existiam, mesmo a
    rodada 9 do duelo 1v1 tendo `gabarito: "ambos"` (impossível de acertar
    de propósito). Bug 2, no servidor: `fn_submit_game_round` tratava
    QUALQUER escolha como certa sempre que o gabarito fosse "ambos" (em vez
    de exigir clique em "Ambos" de fato) — corrigido pra comparação direta
    `p_chosen_key = v_gabarito`, já que o cliente agora manda a escolha no
    mesmo vocabulário de `gabarito`, não mais nas chaves abreviadas de
    `reveal` (`i3`/`ie`).
    - **Redesign visual do Duelo, mesmo pedido:** cabeçalho dark com o nome
      do confronto (`config.meta.titulo`) + barra de progresso da rodada,
      card do critério (ícone/nome/descrição), grade 2×2 de opções (1
      coluna no mobile) com cor por concorrente (`--g`/`--gold`/`--acc`) e
      cor neutra pros coringas (verde-`#007a6a` pra empate, cinza pra
      "nenhum"), hover com elevação leve e transição de 200ms. CSS novo em
      `learning.css` (`.duel-*`), substituindo `.game-runner-category`
      (não usada em mais nenhum lugar, removida).
    - **Testado ao vivo (Samara/admin):** as 4 opções aparecem em todas as
      rodadas; avancei até a rodada 9 (gabarito "ambos") e confirmei que
      clicar em "Ambos iguais" agora é reconhecido como certo (antes era
      impossível de acertar de propósito); zero erro de console. Sessões de
      teste (`game_sessions`/`game_round_answers`) apagadas depois.

41. **Rodada de polimento visual (sem SQL novo)** — **testado ao vivo**
    Três pedidos do usuário na mesma sessão, todos client-side (JS + CSS):
    - **Bug real corrigido antes de qualquer visual, por pedido explícito:**
      o badge "ATUAL" aparecia em vários cards do Circuito de Desafios ao
      mesmo tempo — `GpsTrail.js`/`statusPorCheckpoint` marcava TODO
      checkpoint pendente de uma zona `free_order` como "current". Agora só
      o primeiro pendente vira `current` (badge "Atual"); os demais viram
      um estado novo `available` (badge "Disponível", visual mais discreto,
      continuam clicáveis normalmente).
    - **Circuito de Desafios modernizado:** ícones outline (SVG à mão,
      sem lib/emoji) por tópico do quiz via heurística de palavra-chave no
      título (gota d'água pra IPX, balão de chat pra atendimento, coração
      pra HRM, relógio pra Instinct, genérico nos demais); gradiente do
      thumbnail varia deterministicamente por card (hash do id do
      checkpoint) pra reduzir a sensação de template repetido; indicador
      "N perguntas" no card (nova função `fetchQuizQuestionCounts` em
      `trilhaService.js` — `time_limit_seconds` é sempre null nos quizzes
      reais, não valia mostrar "N min"); badges "Opcional"/status ganharam
      ícone; cantos mais arredondados (18px) + hover com leve escala;
      setas de navegação reais (antes só existia o scroll nativo) +
      dots de paginação, escondidos automaticamente quando a fileira tem
      só 1 card. **Bug do padrão `[hidden]` perdendo pra `display:flex`
      encontrado de novo** (mesma classe de bug já documentada nesta
      sessão) — corrigido com `.media-row-arrow[hidden]`/`.media-row-dots[hidden] { display: none }`.
    - **Cards de pergunta do quiz modernizados:** header com ícone temático
      (mesma heurística de palavra-chave) + barra de progresso mais grossa
      em gradiente de marca; alternativas viraram cards com padding maior,
      sombra, marcador de letra (A/B/C/D) circular, ícone de check/x que
      só aparece depois de responder; bloco de feedback reformulado (ícone
      grande + título em negrito + explicação abaixo, com gradiente sutil
      e animação de entrada fade+slide-up). Responsivo mobile conferido
      (padding/fonte reduzidos, ícone do header menor).
    - **Duelo de Especificações "gamificado":** fundo dos cards por
      concorrente com tom quente (âmbar, Instinct 3) vs frio (azul,
      Instinct E) — não só a borda; ícone neutro (relógio outline) nos
      dois lados antes de responder, troféu só aparece no vencedor depois
      do resultado, com animação de "pop"; pulso de suspense (450ms) em
      todos os cards ao clicar, antes de revelar; confete leve (divs
      coloridas, sem lib) no card vencedor quando acerta; shake no card
      errado; placar ao vivo por concorrente acima do critério da rodada
      (meta-placar do "duelo de verdade" entre os produtos, não do
      acerto/erro do jogador — coringas ambos/todos/nenhum não somam pra
      ninguém); barra de progresso fica dourada nas 2 últimas rodadas;
      microcopy variado (5 frases aleatórias de acerto, 5 de erro) na
      frente do texto real de explicação, que continua vindo do banco.
      **Bug real encontrado em revisão, antes de qualquer teste:** a cor
      de repouso de "Ambos iguais"/"Todos empatam" usava o mesmo tom de
      verde do estado ".correct" — quando o vencedor real era outro
      concorrente, "Ambos iguais" parecia estar marcado como certo também,
      por coincidência de cor. Trocado pra roxo/lavanda, sem ambiguidade
      com o verde de "acertou".
    - **Testado ao vivo (Samara/admin):** badge duplicado confirmado
      corrigido (só 1 card "Atual" por zona); ícones variando certo por
      tópico; setas/dots funcionando e escondidos na zona de 1 card só;
      quiz com header/progresso/letras/ícones de resultado corretos em
      acerto e erro, mobile conferido; duelo com cores quente/frio,
      troféu só pós-resposta, placar somando certo, cor de "ambos" não
      mais ambígua com "correto". Zero erro de console em toda a sessão.
      Sessões e tentativas de teste apagadas do banco ao final.

42. **Seletor de nível no Circuito de Desafios (sem SQL novo)** — **testado ao vivo**
    Pedido do usuário, com uma correção de escopo feita junto com ele via
    pergunta direta: em vez de inventar uma estrutura de "níveis" fake por
    quiz (o schema não tem isso — cada quiz é uma lista simples de
    perguntas), reaproveita as 2 zonas REAIS que já existiam como fileiras
    separadas ("Circuito de Desafios" e "Circuito de Desafios · Nível 2")
    e as mescla num card só com pills "Nível 1"/"Nível 2". `GpsTrail.js`
    ganhou `groupZonesByChallenge()` (agrupa zonas por nome-base, extraindo
    o "· Nível N" via regex — genérico pra quantos níveis existirem no
    futuro, não hardcoded pra 2), `renderChallengeGroup()` (título + pills
    + conteúdo trocável) e `renderZonaBody()` (fileiras de uma zona sem o
    wrapper de título, reaproveitado tanto pela zona solteira quanto pelo
    conteúdo trocável do grupo). Trocar de nível não recarrega a página —
    só re-renderiza o `[data-role="level-content"]` daquele grupo e
    re-liga os cliques/carrossel só ali. Nível com 100% dos checkpoints
    concluídos ganha um ícone de check no pill. Sem conceito de nível
    "bloqueado" — as 2 zonas reais são `free_order` sem `unlock_rule`
    configurada, não existe dado de bloqueio real entre elas pra respeitar.
    Seleção persistida em `localStorage` (`gth-desafio-nivel-<slug>`,
    mesmo padrão/prefixo já usado por `SIDEBAR_COLLAPSE_KEY`).
    - **Testado ao vivo (Samara/admin):** troca de nível sem reload,
      conteúdo do card atualiza corretamente pros dois lados; recarreguei a
      página inteira e confirmei que o Nível 2 continuou selecionado
      (persistência funcionando); zero erro de console.
    - **Achado e limpo durante o teste, não relacionado a este item:**
      progresso real (3 lições + pontos) tinha ficado gravado na conta da
      Samara de um teste anterior nesta mesma sessão — apagado
      (`lesson_progress`/`user_progress`/`points_ledger`, `performance_score`
      recalculado de volta a 0).

43. **CTA "Responder quiz" ao concluir módulo (sem SQL novo)** — **testado ao vivo**
    Bug real reportado pelo usuário: terminar as lições de um módulo não
    levava pro quiz — a pessoa tinha que voltar pra "Minha Trilha" e achar
    o card recém-desbloqueado manualmente. `moduleService.fetchNextQuizCheckpoint(zoneId, moduleId)`
    busca o checkpoint que vem logo depois do módulo na mesma zona da
    trilha; `moduloConteudo.js` mostra um banner "Módulo concluído! Responda
    o quiz agora..." assim que a barra de progresso chega a 100% (revelado
    na hora, sem reload, com scroll suave até o banner) — clicar leva direto
    pro quiz-runner certo.
    - **Bug real encontrado em revisão, antes de testar:** o fluxo de
      edição de conteúdo (admin, "Editar conteúdo" → salvar) chamava
      `renderModule(...)` de novo sem passar o `nextQuiz` adiante — o CTA
      sumiria silenciosamente depois de qualquer edição de lição no meio de
      um módulo já concluído. Corrigido propagando o parâmetro por toda a
      cadeia (`wireLessonEdit` → `onSave` → `renderModule`).
    - **Testado ao vivo (Samara/admin), módulo "O Universo Garmin":**
      completei as 3 lições — banner apareceu automaticamente na última,
      com scroll até ele; cliquei "Responder quiz →" e caiu certinho em
      "Módulo 1 — Universo Garmin" (confirmado também que a trilha já
      desbloqueava esse quiz como próximo passo, mesmo mecanismo). Dado de
      teste (lesson_progress/user_progress/points_ledger de Samara)
      apagado depois.

44. **`041_lider_zona_atual_view.sql`** — **já aplicado, testado ao vivo**
    Pedido do usuário (Dashboard do Líder): view `v_lider_zona_atual`
    mostrando a posição de cada colaborador no funil de capacitação
    ("Explorador - O Universo Garmin" em vez de só um score agregado),
    construída estritamente sobre a estrutura real de hoje (confirmado por
    query direta antes de escrever, não a estrutura genérica que tinha sido
    proposta inicialmente):
    - Só "Zona Explorador" e "Zona Atleta" entram no funil — Maratonista/
      Triatleta têm `certifications.zone_id = null`, sem módulo cadastrado.
    - `certifications.title` da 2ª certificação real ainda é 'Corredor'
      (slug `corredor`) — a view expõe "Atleta" como rótulo (mesmo
      mapeamento visual do sql/038), sem precisar renomear a certificação.
    - `profiles.hired_at` existe mas está `null` pros 14 usuários reais —
      a regra de onboarding (90+ dias sem concluir Atleta) cai pra
      `created_at` como fallback, marcando isso explicitamente
      (`onboarding_data_estimada = true`) pro dashboard não fingir precisão
      que não existe.
    - Sem `study_sessions`/`login_events` populados (lacuna já documentada
      em `liderDashboard.js`) — "dias de inatividade" usa a última
      atividade REAL em `lesson_progress`/`quiz_attempts`.
    - Segurança embutida no WHERE da própria view (Postgres não tem RLS
      nativa em view) — mesmo padrão de `v_ranking_public`/
      `vw_store_knowledge_gaps`: admin vê tudo, líder só a própria loja
      (`fn_is_admin()`/`fn_is_leader()`/`fn_leader_store_ids()`, já
      existentes, sem mudança).
    - `teamService.fetchLeaderZonaAtual()` + `liderDashboard.js` ganharam a
      seção "Funil de Capacitação": cards de % por etapa, filtro de loja
      (client-side — a view já limita o conjunto por RLS embutida) e
      tabela com badge de inatividade (🔴 15+ dias/🟡 7+ dias/🟢 em dia,
      mesma paleta semáforo de `vw_store_knowledge_gaps`) e alerta de
      onboarding.
    - **Testado ao vivo (Samara/admin):** os 11 colaboradores reais
      aparecem corretamente como "Explorador · O Universo Garmin · Sem
      atividade ainda" (bate com o estado real do banco — ninguém tem
      lição/quiz concluído hoje); filtro por loja funcionando (Morumbi
      isolou os 7 certos). Lógica de onboarding testada à parte com dado
      sintético (`hired_at` de Daniel Lucena setado pra 100 dias atrás):
      `alerta_onboarding` virou `true` e `onboarding_data_estimada` virou
      `false` corretamente — revertido depois. Zero erro de console novo
      (2 erros de `[Ranking]` no console são anteriores a esta sessão de
      teste, de uma navegação avulsa — não relacionados a este item, vale
      investigar à parte).

## O que ainda não está aqui

- Cadastro de novo usuário pelo admin — exige a Supabase Admin API
  (`auth.admin.createUser`), que só roda com a service role key. Não é
  possível fazer isso só com SQL/RLS; precisa de uma Edge Function.
- Tabela `profile_brands` (pivô) para representar um usuário com acesso a
  mais de uma marca — a modelagem original previu isso, mas nunca foi
  criada. Hoje (pós-010) cada pessoa fica presa a UMA marca; só os 3 admins
  enxergam as duas (via `brand_id`/`store_id` nulos, não via pivô).
- ~~Painel administrativo de conteúdo (Gestora)~~ — **feito em 2026-07-12**,
  ver itens 39/40 acima (postar no blog + relatório de quizzes por loja) e o
  CRUD de módulos/lições/quizzes com drag-and-drop (`gestoraContentEditor.js`,
  sem SQL novo — RLS `*_admin_all` já existia). Fora de escopo ainda:
  vincular módulo/quiz à trilha (`checkpoints`) e os 20 tipos de bloco
  completos da Fase 4 (hoje 13 de 20 em `ContentBlocks.js`).
- Gamificação social (ranking/leaderboard) — `points_ledger` e `leaderboard`
  já existem no banco, nenhuma tela consome isso ainda. Badges e o feed de
  atividades (item 28) já têm cobertura; streak automático (`streaks`) segue
  sem trigger equivalente.
- Busca inteligente e blog "Casos Reais" — nunca foram especificados em
  nenhum documento de regras de negócio ou UX.
- Edge Functions documentadas na modelagem original (seção 12) — nenhuma
  implementada; Storage Buckets já foram criados diretamente via SQL.
