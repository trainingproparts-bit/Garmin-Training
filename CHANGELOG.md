# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). Datas e hashes conferidos em `git log`.

## [0.5.0] - 2026-07-08 (Usuários & Papéis — Dashboard do Líder + Painel Admin)

Papéis (colaborador/líder/admin) já existiam no schema base (`profiles.role_id`, `fn_is_admin()`, `fn_is_leader()`, `fn_leader_store_ids()`, e um conjunto extenso de policies `*_select_leader`), mas nada no app diferenciava a experiência por papel. Esta versão constrói as duas telas em cima da RLS que já existia, sem criar nenhuma tabela nova.

### Added
- `src/config/supabase.js`: `getCurrentProfile()` agora resolve `roles(code, label)` via join; novos helpers `isLeaderProfile`/`isAdminProfile`.
- `src/components/appShell.js`: dois itens de nav novos ("Dashboard do Líder", "Painel Admin"), escondidos por padrão e revelados conforme o papel resolvido — a autorização real continua sendo a RLS, isto só controla o que aparece no menu.
- `src/services/teamService.js` + `src/pages/liderDashboard.js`: roster da equipe, score médio, certificações emitidas, taxa de aprovação em quizzes e feed de tentativas recentes. Tudo via RLS já existente (`profiles_select_leader`, `quiz_attempts_select_leader`, `user_certifications_select_leader`) — nenhuma query filtra loja manualmente.
- `src/services/adminService.js` + `src/pages/adminPanel.js`: lista de todos os perfis (`profiles_admin_all`), edição de cargo/loja e bloqueio/desbloqueio manual (RN 1.5).

### Fixed — bug de segurança real e pré-existente
- `sql/008_profiles_privilege_escalation_fix.sql`: `profiles_update_own` (schema base) só restringia qual linha um usuário podia tocar, nunca quais colunas. Um colaborador comum podia chamar `PATCH /profiles?id=eq.<próprio-id>` com `{"role_id": 3}` e se autopromover a admin. Adicionada trigger `fn_guard_profile_self_update` que bloqueia mudança de `role_id`/`store_id`/`brand_id`/`status`/`deleted_at`/`username` por quem não é admin — `performance_score` fica de fora de propósito, porque é atualizado pela trigger de sincronização do Score de Performance (Sprint 3), não pelo dono do perfil.

### Known gap
- `sql/008` ainda não foi aplicado/confirmado no Supabase real.
- A tabela `stores` está vazia (confirmado ao vivo: 0 linhas, sem erro) — Painel Admin e Dashboard do Líder não têm loja real pra atribuir/escopar ainda.
- Nenhuma das duas telas novas foi vista com dado real — falta credencial de login de líder/admin neste ambiente. O que foi verificado ao vivo: nav corretamente escondida para visitante, guard de página bloqueia navegação direta driblando a nav, e todas as queries (incluindo os joins `roles(...)`, `stores(...)`, `profiles(...)`) executam sem erro de sintaxe/relacionamento contra o schema real.
- Cadastro de novo usuário pelo admin não foi construído — exige Supabase Admin API com service role key, só possível via Edge Function.

## [0.4.2] - 2026-07-08 (Verificação ao vivo do Motor de Avaliações Trimestrais)

Depois de você aplicar `006` e `007` no Supabase real, testei tudo de novo.

### Verified
- As 5 funções do motor de avaliação (`fn_check_evaluation_lock`, `fn_start_evaluation_attempt`, `fn_submit_evaluation_answer`, `fn_finish_evaluation_attempt`, `fn_unlock_evaluation_attempt`) existem no banco real e rejeitam corretamente chamada sem sessão autenticada.
- `fetchEvaluationQuestions` retorna as 15 perguntas reais (5 por tier), gabarito protegido pela view pública.
- Tela de Certificações renderizada ao vivo com as 3 avaliações e status de trava; guarda de "faça login" testada como visitante.

### Correção de diagnóstico (registro honesto)
A hipótese em 0.4.1 ("dados duplicados", causa do `PGRST116`) **estava errada**. Rodamos 3 queries de diagnóstico juntos e a causa real era outra: a tabela `evaluations` estava **vazia** (0 linhas) — o que gera exatamente o mesmo erro do PostgREST (`.single()` também falha com zero resultados, não só com mais de um). As constraints de `007` estavam corretas desde o início; só faltava repopular com `seeds/070`, o que resolveu. Não cheguei a confirmar como a tabela ficou vazia (best guess: alguma tentativa de correção anterior, possivelmente do Cursor, rodou um DELETE sem filtro) — não é algo que valha a pena investigar mais a fundo agora que os dados estão corretos e as constraints impedem o problema original de se repetir.

## [0.4.1] - 2026-07-08 (Motor de correção da Avaliação Trimestral)

Fecha o ciclo que a 0.4.0 deixou pendente de propósito: a trava de 24h agora tem como ser exercitada de verdade. Também corrige um bug real de dados duplicados encontrado ao testar contra o Supabase de produção.

### Added
- `sql/006_evaluation_submission_engine.sql`: tabela `evaluation_answers` e as RPCs `fn_start_evaluation_attempt` (cria/retoma tentativa respeitando a trava), `fn_submit_evaluation_answer` (corrige no servidor) e `fn_finish_evaluation_attempt` (calcula `score_pct`/`passed`) — mesmo padrão de `fn_submit_quiz_answer`/`fn_finalize_quiz_attempt`.
- `src/components/EvaluationRunner.js` — espelha `QuizRunner.js`; diferença: opções vêm de `options_json` (array de strings) em vez de linhas de `alternatives`.
- `src/pages/evaluationRunner.js` e painel `evaluation-runner` no AppShell.
- `src/pages/certificacao.js`: nova seção "Avaliações Trimestrais" listando as 3 avaliações com status de trava (bloqueada até tal horário, ou botão de iniciar).
- `evaluationService.js`: `startEvaluationAttempt`, `submitEvaluationAnswer`, `finishEvaluationAttempt`.

### Fixed
- **Bug real de dados duplicados**: `evaluations` nunca teve constraint única, e `seeds/070_evaluations_mock.sql` usava `on conflict do nothing` sem apontar pra nenhuma — cada re-execução do seed criava linhas novas em vez de ser ignorada. Encontrado ao testar `fetchEvaluationQuestions('explorer')` contra o Supabase real (`PGRST116` — "Cannot coerce the result to a single JSON object", sinal de mais de uma linha por `type`). `sql/007_evaluations_dedupe_and_unique.sql` remove as duplicatas (mantendo a mais antiga por tier) e adiciona `UNIQUE(type)`/`UNIQUE(evaluation_id, order_index)`; `seeds/070` atualizado para apontar pra elas.

### Known gap
- `006` e `007` ainda não foram aplicados ao Supabase real (confirmado ao vivo: `fn_start_evaluation_attempt` retorna `PGRST202`, função não encontrada). O ciclo completo só é validável de ponta a ponta depois disso — `PROJECT_CHECKLIST.md` mantém o item como "Em progresso" até lá.

## [0.4.0] - 2026-07-08 (Sprint 4 — Motor de Avaliações Trimestrais + Sininho)

Banco de questões para avaliação trimestral por tier (Explorer/Runner/Triathlete), sistema de notificações do dashboard e a automação que avisa o usuário ao concluir uma trilha inteira.

### Added
- `sql/005_evaluations_and_notifications.sql`:
  - `evaluations` (id, title, type, `passing_score_pct`, is_published) e `evaluation_questions` (id, evaluation_id, question_text, options_json, correct_option, order_index) — banco de questões da avaliação trimestral.
  - `v_evaluation_questions_public` — view sem `correct_option`, mesmo padrão de `v_alternatives_public`; RLS da tabela base restringe SELECT a líder/admin.
  - `evaluation_attempts` (user_id, evaluation_id, started_at, finished_at, score_pct, passed, unlocked_early_by, unlocked_early_at) — necessária para a trava funcionar, não estava na lista de tabelas pedida originalmente.
  - `fn_check_evaluation_lock(p_evaluation_id)` — retorna `{locked, locked_until, reason}`; regra: 24h de cooldown após reprovar, sem limite de tentativas, liberável por `fn_unlock_evaluation_attempt` (líder da loja ou admin).
  - `notifications` (id, user_id, title, message, type, is_read, created_at, action_url) — sininho do dashboard.
  - `fn_notify_trail_completed` (trigger em `lesson_progress`) — ao concluir a última lição publicada de uma trilha, insere notificação de avaliação disponível (com checagem de duplicidade).
- `sql/seeds/070_evaluations_mock.sql` — 15 perguntas reais (5 por tier), grounded no domínio Garmin já usado nos quizzes de módulo.
- `src/services/evaluationService.js` — `fetchEvaluationQuestions`, `checkEvaluationLock`, `unlockEvaluationAttempt`.
- `src/services/notificationService.js` — `fetchUserNotifications`, `countUnreadNotifications`, `markAsRead`.

### Changed
- `evaluations.passing_score_pct` e `evaluation_attempts` foram adicionados além do pedido literal (que listava só `evaluations (id, title, type)` e não mencionava tabela de tentativas) — sem eles não há como calcular aprovação nem persistir a trava de 24h. Documentado no cabeçalho do próprio arquivo de migração.

### Known gap (não é bug, é escopo intencionalmente deixado para depois)
- Não existe `evaluation_answers` nem uma RPC de submissão com correção no servidor (o equivalente de `fn_submit_quiz_answer`) para a Avaliação Trimestral. `evaluation_attempts` tem INSERT/UPDATE revogados do client de propósito — sem o motor de correção, nenhuma tentativa real pode ser gravada, e a trava de 24h nunca é exercida na prática ainda. `PROJECT_CHECKLIST.md` reflete isso como "Em progresso", não como concluído.
- O componente visual do sino não foi construído nesta sprint — por escopo, a Fase 2 pediu só a camada lógica para "alimentar o futuro componente".

## [0.3.0] - 2026-07-08 (Sprint 3 — Ciclo fechado de progresso)

Amarrar o loop de progresso do usuário: concluir uma lição agora grava progresso, concede pontos e devolve o novo total do Score de Performance para atualizar a UI, tudo numa transação atômica.

### Added
- **Nomenclatura "Score de Performance"** substitui "XP" nos textos e no cache do total. A conta continua sendo `SUM(points_ledger.points)` — o que mudou é o rótulo exposto (público de esporte/performance) e a existência de um campo materializado para leitura barata.
- `sql/004_performance_score.sql`:
  - `profiles.performance_score` (integer, default 0) — cache do total, alimentado por trigger.
  - `fn_sync_performance_score()` + `trg_sync_performance_score` — recalculam o total sempre que `points_ledger` muda, valendo para lançamentos de quiz aprovado, certificação, lição e ajuste manual.
  - Extensão do `chk_points_ledger_source` para incluir `'lesson'` (antes só tinha módulo/quiz/game/badge/certificação/manual).
  - `fn_complete_lesson(p_lesson_id, p_amount)` `SECURITY DEFINER` — a policy de `points_ledger` impede INSERT direto do cliente, então a RPC é o único caminho legítimo. Idempotente: se a lição já foi concluída antes, atualiza o timestamp mas **não** duplica pontos (RN 6.1).
- `src/services/moduleService.js`:
  - `completeLesson(lessonId, amount = 25)` — RPC atômica, devolve `{ performance_score, points_awarded, already_completed }`.
  - `fetchModuleProgress(userId, moduleId)` — calcula quantas lições publicadas do módulo já foram concluídas + `completedIds` como `Set`.
- UI da conclusão em `src/pages/moduloConteudo.js`:
  - Barra de progresso do módulo no topo, atualiza sem refetch.
  - Lições já concluídas marcadas visualmente ao carregar (antes sempre renderizavam como pendentes).
  - Feedback "+N pts" no botão, evento `profile:score-updated` para o sidebar reagir.
- `src/components/appShell.js`: sidebar consome `profiles.performance_score` diretamente e escuta o evento `profile:score-updated` para atualizar o rótulo sem refetch de profile inteiro.
- CSS em `src/styles/modulo-content.css`: `.module-progress*`, estado `.content-article.is-completed` e `.content-complete-btn:disabled`.

### Changed
- `moduleService.markLessonComplete` marcada como `@deprecated` (mantida como fallback).
- Sidebar deixou de exibir `profile.level || 'Nível 1'` — o campo `level` nunca existiu no schema real, sempre caía no fallback e passava a falsa impressão de nível fixo. Agora mostra `Score {n} pts`.

## [0.2.1] - 2026-07-08

Correção pontual pedida logo após a Sprint 2: quiz deixa de ser acessado por uma lista solta e passa a respeitar o bloqueio sequencial da trilha.

### Changed
- `src/pages/quizzes.js` virou "Quizzes Extras": em vez de listar todo quiz publicado da marca, busca a trilha publicada e mostra só os checkpoints tipo `quiz` de zonas `free_order = true` (o "Circuito de Desafios", que já é livre/sem bloqueio hoje).
- `src/services/quizService.js`: `fetchPublishedQuizzes` (listava tudo) substituído por `fetchQuizzesByIds` (metadados sob demanda dos checkpoints já filtrados).
- Botão de voltar do painel `quiz-runner` agora leva para a trilha em vez de para a lista de quizzes — o caminho principal para abrir um quiz passou a ser o checkpoint na trilha.
- Label da navegação e do painel: "Quizzes" → "Quizzes Extras".

### Fixed
- Botões de acesso rápido do dashboard (Quizzes/Games/Certificações/Biblioteca técnica) renderizavam mas não tinham nenhum clique ligado — `data-panel-link` nunca era lido por ninguém.

## [0.2.0] - 2026-07-08 (Sprint 2 — Conteúdo)

Migração do texto real das lições e dos guias técnicos que a Sprint 1 tinha deixado como estrutura vazia.

### Added
- 22 lições reais distribuídas nos 6 módulos da trilha (Universo Garmin, Perfis de Cliente, Produtos, Concorrentes, Corredor · Garmin Connect, Corredor · Garmin Coach) — `sql/seeds/050_licoes_modulo1_2.sql`, `051_licoes_modulo3_4.sql`, `052_licoes_corredor.sql`.
- 8 guias técnicos de leitura longa na Biblioteca Técnica: inReach, GPS de mão (GPSMAP/eTrex), linha náutica, Edge ciclismo, apps/integrações, novidades 2026 (Forerunner 70/170), Blaze Equine, MARQ Gen 2 — `sql/seeds/060_biblioteca_deep_dives_a.sql`, `061_biblioteca_deep_dives_b.sql`.
- Nova aba "Guias Técnicos" na Biblioteca Técnica (`src/pages/biblioteca.js`, `src/components/LibraryContent.js`), mesmo padrão de accordion do FAQ.
- `sql/README.md` com a ordem de execução consolidada de todos os arquivos SQL do projeto (schema base + Sprint 1 + Sprint 2).

### Changed
- Todo o texto migrado foi reescrito a partir do HTML original de `index_redesign_v5.html` para soar natural: sem travessão como pontuação, sem a construção comparativa "não é só X, é Y". Nenhum dado factual (specs, preços, nomes de modelo) foi alterado ou inventado — só a forma da prosa.

### Fixed
- `.content-lesson-title` e `.content-lesson-list` nunca tinham CSS próprio — o título de cada lição ficava quase invisível sobre o fundo escuro do card, só percebido ao testar com múltiplas lições reais por módulo.

## [0.1.0] - 2026-07-07 (Sprint 1 — Consolidação e Implementação)

Desmembramento do monólito `index_redesign_v5.html`, integração real com Supabase e unificação de login/navegação/AppShell.

### Added
- `src/router.js`: navegação central por painel, antes vivia dentro de `appShell.js` misturada com layout.
- Novos services por domínio: `moduleService`, `quizService`, `certificationService`, `gameService`, `contentLibraryService`.
- Novos componentes reutilizáveis: `GpsTrail.js`, `DashboardHome.js`, `QuizRunner.js`, `GameRunner.js`, `LibraryContent.js`.
- Novas páginas: `trilha.js`, `quizzes.js`, `quizRunner.js`, `games.js`, `gameRunner.js`, `certificacao.js`, `biblioteca.js`.
- Novo schema SQL: tabela `content_library` (biblioteca técnica — domínio que não existia na modelagem original) e hardening de submissão de quiz via RPC `fn_submit_quiz_answer` (gabarito nunca trafega para o cliente).
- Seeds reais extraídos de `index_redesign_v5.html`: estrutura da trilha "GPS da Carreira" com zonas/checkpoints/certificações, 11 quizzes (121 perguntas, 481 alternativas), 2 minigames "Duelo de Especificações", 95 itens estruturados da biblioteca técnica (perfis, produtos, FAQ, concorrentes, especialidades).
- `vite.config.js` (porta configurável via `PORT`) e `.claude/launch.json` para rodar o dev server em preview.

### Changed
- Sidebar/AppShell agora gerado a partir de `NAV_ITEMS` (config única), sem os 5 links mortos que existiam antes (Games, Quizzes, Formação, Certificações, Ferramentas sem `data-panel`).
- `src/pages/home.js` simplificado — só seleção de marca, sem mais o dashboard hardcoded que competia com `appShell.js`.
- `src/pages/moduloConteudo.js` reescrito para consultar `modules`/`lessons` reais em vez da tabela `courses`, que nunca existiu no schema definitivo.
- CSS consolidado: `dashboard.css`, `learning.css` e `library.css` substituem a antiga triplicação de implementações concorrentes do mesmo conceito visual.
- Header preto fixo no topo removido por completo (pedido de acompanhamento após a primeira correção, que só tinha tirado a logo duplicada do sidebar).

### Deprecated
- `login.html`, `cursos.html`, `js/auth.js` marcados como deprecated (comentário de cabeçalho) — mantidos até a nova implementação ser validada por completo, não apagados.

### Removed
- `src/pages/formacao.js`, `src/pages/cursos.js`, `src/services/cursoService.js` — consultavam a tabela `courses`, inexistente no schema definitivo, já substituídos e testados.
- `src/counter.js`, `src/assets/vite.svg`, `src/assets/javascript.svg`, `src/assets/hero.png` — boilerplate do Vite nunca usado.
- `logo-branco.png` duplicado na raiz do projeto (mantido em `public/`).
- `src/styles/formacao-dashboard.css` — CSS morto, substituído por `dashboard.css`.

### Fixed
Cinco bugs reais encontrados testando o app pela primeira vez no navegador (não só compilando):
1. Logout nunca voltava para a tela de login — `signOut()` não retornava `{error}`, `authService.js` quebrava ao desestruturar `undefined` (TypeError silencioso, capturado pelo try/catch).
2. A trilha sempre carregava a marca "Garmin" fixa, ignorando a marca realmente selecionada pelo usuário.
3. Sidebar aparecia antes de entrar no dashboard (`.app-sidebar{display:flex}` vencia o atributo `[hidden]` sozinho — origem "author" sempre bate estilo de UA, precisou de `.app-sidebar[hidden]` com especificidade maior).
4. Tela Início sem estilo nenhum — `home.css` tinha CSS órfão que nunca estilizava as classes reais da tela (`.brand-card`, `.home-brands-grid`...).
5. Console poluído a cada navegação no modo visitante — "Auth session missing" (estado normal do modo convidado) era logado como `console.error`.

Também corrigido, no mesmo dia: logo duplicada entre header e sidebar, e badge do header fixo em "Garmin · Uso interno" independente da marca selecionada (ambos superados pela remoção completa do header logo em seguida).
