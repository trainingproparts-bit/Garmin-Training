\# Modelagem de Dados — Garmin Training Hub

\### Arquitetura definitiva da camada de dados (Supabase / PostgreSQL)



> Escopo deste documento: modelagem lógica e física do banco. Sem SQL, sem frontend, sem telas — apenas o desenho das tabelas, relacionamentos, integridade, RLS, triggers, functions, views e storage.



\---



\## 0. Princípios de design adotados



Antes das tabelas, os critérios que guiam toda decisão abaixo:



1\. \*\*Toda gravação sensível ao negócio acontece no servidor, nunca confiando em valor calculado no cliente.\*\* O sistema atual grava `pct` do quiz calculado no navegador; a nova modelagem grava apenas respostas brutas (`quiz\_answers`) e calcula nota, aprovação, pontos e certificação via `function`/`trigger` no banco.

2\. \*\*Progresso e histórico são eventos, não apenas um "estado atual".\*\* Em vez de sobrescrever um campo `progress`, cada ação gera uma linha (event sourcing parcial): isso é o que permite responder "evolução mensal", "tempo médio de estudo", "quem mais estuda" sem re-arquitetar depois.

3\. \*\*Multi-tenant desde o início.\*\* `brand\_id` está presente em todas as tabelas de conteúdo e configuração, permitindo Garmin, Shokz e futuras marcas sem duplicar schema.

4\. \*\*Separação entre "definição de conteúdo" (trilhas, quizzes, perguntas) e "execução do usuário" (tentativas, progresso, pontos).\*\* Isso permite editar conteúdo sem afetar histórico já registrado (ex.: mudar uma pergunta não deve alterar retroativamente uma tentativa já respondida — por isso `quiz\_answers` guarda uma cópia congelada do texto da alternativa escolhida).

5\. \*\*RLS (Row Level Security) como camada de autorização primária\*\*, não a lógica de frontend. Cada tabela sensível tem política própria por papel.

6\. \*\*UUID como PK padrão\*\* (compatibilidade nativa com `auth.users` do Supabase) e \*\*soft delete\*\* (`deleted\_at`) em tabelas de conteúdo/pessoas, nunca `DELETE` físico onde há histórico dependente.

7\. \*\*`timestamptz` em todos os campos de data/hora\*\*, nunca `timestamp` sem timezone.

8\. \*\*Pontuação/XP nunca é um campo mutável somado diretamente\*\* — é sempre a soma agregada de `points\_ledger`, que é um livro-razão auditável (nunca se edita um total "à mão" como acontece hoje no álbum manual).



\---



\## 1. Domínio: Usuários e Organização



\### 1.1 `brands`

\*\*Finalidade:\*\* suporta multi-tenant (Garmin, Shokz, próximas marcas), cada uma com seu próprio conjunto de trilhas, quizzes e tema visual.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| slug | text | único, ex: `garmin`, `shokz` |

| name | text | |

| logo\_url | text | aponta para Storage |

| theme\_config | jsonb | cores, tokens visuais |

| is\_active | boolean | default true |

| created\_at | timestamptz | default now() |



\- \*\*PK:\*\* `id`

\- \*\*Constraints:\*\* `UNIQUE(slug)`

\- \*\*Índices:\*\* `slug`

\- \*\*Relacionamentos:\*\* 1:N com `stores`, `trails`, `quizzes`, `games`, `profiles` (via `brand\_id` — usuário pode ter acesso primário a uma marca, ou tabela pivô `profile\_brands` se precisar de multi-marca por usuário)



\### 1.2 `roles`

\*\*Finalidade:\*\* catálogo fechado de papéis (Colaborador, Líder, Administrador), evita strings soltas espalhadas pelo código.



| Campo | Tipo | Observação |

|---|---|---|

| id | smallint | PK |

| code | text | `collaborator`, `leader`, `admin` — único |

| label | text | rótulo de exibição |



\- \*\*Constraints:\*\* `UNIQUE(code)`. Tabela pequena e estática — carregada por seed, não por app.

\- \*\*Relacionamentos:\*\* 1:N com `profiles`



\### 1.3 `stores`

\*\*Finalidade:\*\* unidade/loja (Comissão Técnica, Morumbi, Moema) — usada para ranking por loja e escopo de visibilidade do líder.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| brand\_id | uuid | FK → `brands.id` |

| name | text | |

| code | text | único por marca |

| region | text | opcional, agrupamento maior |

| is\_active | boolean | default true |

| created\_at | timestamptz | |



\- \*\*PK:\*\* `id`

\- \*\*FK:\*\* `brand\_id` → `brands.id` (ON DELETE RESTRICT)

\- \*\*Constraints:\*\* `UNIQUE(brand\_id, code)`

\- \*\*Índices:\*\* `brand\_id`

\- \*\*Relacionamentos:\*\* 1:N com `profiles`; N:N com `profiles` (líderes) via `store\_leaders` (ver 1.5), pois um líder pode responder por mais de uma loja



\### 1.4 `profiles`

\*\*Finalidade:\*\* perfil de aplicação do usuário, 1:1 com `auth.users` do Supabase. É o centro do grafo — quase toda tabela de progresso/gamificação referencia `profiles.id`.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK, também FK → `auth.users.id` |

| brand\_id | uuid | FK → `brands.id` |

| store\_id | uuid | FK → `stores.id`, nullable (admin pode não ter loja) |

| role\_id | smallint | FK → `roles.id` |

| full\_name | text | |

| username | text | único, usado no login "usuário/senha" |

| avatar\_url | text | Storage |

| emoji | text | fallback de avatar (herdado do álbum atual) |

| phrase | text | frase pessoal, herdado da figurinha |

| job\_title | text | cargo — usado no "ranking por cargo" |

| hired\_at | date | opcional, para métricas de tempo de casa |

| must\_change\_password | boolean | default true |

| is\_guest | boolean | default false |

| status | text | `active`, `inactive`, `suspended` |

| created\_at | timestamptz | |

| updated\_at | timestamptz | |

| deleted\_at | timestamptz | soft delete |



\- \*\*PK:\*\* `id`

\- \*\*FK:\*\* `id` → `auth.users.id` (ON DELETE CASCADE); `brand\_id` → `brands.id`; `store\_id` → `stores.id`; `role\_id` → `roles.id`

\- \*\*Constraints:\*\* `UNIQUE(username)`; `CHECK(status IN ('active','inactive','suspended'))`

\- \*\*Índices:\*\* `store\_id`, `role\_id`, `brand\_id`, índice composto `(store\_id, role\_id)` para consultas do líder

\- \*\*Relacionamentos:\*\* raiz de quase todo o restante do schema (progresso, pontos, badges, certificações, sessões, tentativas)



\### 1.5 `store\_leaders` (tabela de junção)

\*\*Finalidade:\*\* um líder pode enxergar mais de uma loja; uma loja pode ter mais de um líder.



| Campo | Tipo |

|---|---|

| leader\_id | uuid — FK → `profiles.id` |

| store\_id | uuid — FK → `stores.id` |

| assigned\_at | timestamptz |



\- \*\*PK composta:\*\* `(leader\_id, store\_id)`

\- \*\*Constraint:\*\* `CHECK` via trigger garantindo que `leader\_id` referencia um `profile` com `role.code = 'leader'`



\---



\## 2. Domínio: Conteúdo (Trilhas, Zonas, Módulos, Aulas)



\### 2.1 `trails`

\*\*Finalidade:\*\* trilha de carreira (Explorador → Corredor → Maratonista → Triatleta), equivalente ao `GPS\_ZONES` atual, agora como dado, não array JS.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| brand\_id | uuid | FK → `brands.id` |

| slug | text | único por marca |

| name | text | |

| description | text | |

| cover\_url | text | |

| order\_index | integer | ordem de exibição |

| is\_published | boolean | default false |

| created\_at / updated\_at | timestamptz | |



\- \*\*Constraints:\*\* `UNIQUE(brand\_id, slug)`

\- \*\*Índices:\*\* `brand\_id, order\_index`



\### 2.2 `zones`

\*\*Finalidade:\*\* zona dentro de uma trilha (equivalente a cada item de `GPS\_ZONES`), com suporte a `free\_order` (herdado do "Circuito de Desafios").



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| trail\_id | uuid | FK → `trails.id` |

| name | text | |

| banner\_message | text | mensagem de conclusão de zona |

| free\_order | boolean | default false |

| order\_index | integer | |

| unlock\_rule | jsonb | condição de desbloqueio (ex.: zona anterior 100% concluída) |



\- \*\*FK:\*\* `trail\_id` → `trails.id` (ON DELETE CASCADE)

\- \*\*Constraints:\*\* `UNIQUE(trail\_id, order\_index)`

\- \*\*Índices:\*\* `trail\_id`



\### 2.3 `modules`

\*\*Finalidade:\*\* conteúdo educacional (equivalente aos módulos atuais: Universo Garmin, Perfis de Cliente, etc.). Um módulo é um tipo de \*\*checkpoint\*\*.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| zone\_id | uuid | FK → `zones.id` |

| slug | text | único |

| title | text | |

| summary | text | |

| estimated\_minutes | integer | usado para meta de tempo de estudo |

| order\_index | integer | |

| is\_published | boolean | |

| created\_at / updated\_at | timestamptz | |



\- \*\*FK:\*\* `zone\_id` → `zones.id`

\- \*\*Índices:\*\* `zone\_id, order\_index`



\### 2.4 `lessons`

\*\*Finalidade:\*\* granularidade abaixo do módulo (ex.: dentro de "Corredor · Garmin Connect", as subseções "O que é", "Métricas", "Música", "Garmin Pay", "Estudo de caso"). Permite progresso fino e "continuar de onde parou" no nível certo de detalhe.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| module\_id | uuid | FK → `modules.id` |

| title | text | |

| content\_type | text | `text`, `video`, `interactive`, `case\_study` |

| body | jsonb / text | conteúdo estruturado |

| order\_index | integer | |

| is\_published | boolean | |



\- \*\*FK:\*\* `module\_id` → `modules.id` (ON DELETE CASCADE)

\- \*\*Índices:\*\* `module\_id, order\_index`



\### 2.5 `attachments`

\*\*Finalidade:\*\* arquivos (imagens, PDFs, vídeos) ligados a uma lição/módulo, referenciando Storage Buckets.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| lesson\_id | uuid | FK → `lessons.id`, nullable |

| module\_id | uuid | FK → `modules.id`, nullable |

| bucket | text | nome do bucket |

| storage\_path | text | |

| file\_type | text | `image`, `video`, `pdf`, `doc` |

| uploaded\_by | uuid | FK → `profiles.id` |

| created\_at | timestamptz | |



\- \*\*Constraint:\*\* `CHECK (lesson\_id IS NOT NULL OR module\_id IS NOT NULL)` — precisa pertencer a algo

\- \*\*Índices:\*\* `lesson\_id`, `module\_id`



\### 2.6 `checkpoints`

\*\*Finalidade:\*\* camada de indireção que unifica módulo, quiz e game como "etapas" de uma zona — resolve exatamente o que hoje é o array `checkpoints: \['universo', 'quiz-ipx', 'game-duelo', ...]` misturando tipos diferentes de conteúdo numa lista de strings.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| zone\_id | uuid | FK → `zones.id` |

| checkpoint\_type | text | `module`, `quiz`, `game` |

| reference\_id | uuid | aponta para `modules.id`, `quizzes.id` ou `games.id` (validado via trigger, não FK direta) |

| order\_index | integer | |

| is\_required | boolean | default true — permite checkpoints opcionais |



\- \*\*Índices:\*\* `zone\_id, order\_index`, `(checkpoint\_type, reference\_id)`

\- \*\*Regra de integridade:\*\* trigger `BEFORE INSERT/UPDATE` valida que `reference\_id` existe na tabela correspondente ao `checkpoint\_type` (já que não há FK polimórfica nativa em Postgres)



\---



\## 3. Domínio: Quizzes



\### 3.1 `quizzes`

\*\*Finalidade:\*\* definição do quiz (substitui os 10+ objetos `quizData\*` hardcoded).



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| brand\_id | uuid | FK → `brands.id` |

| slug | text | único |

| title | text | |

| passing\_score\_pct | numeric(5,2) | default 70.00 |

| time\_limit\_seconds | integer | nullable |

| max\_attempts | integer | nullable = ilimitado |

| is\_published | boolean | |

| created\_at / updated\_at | timestamptz | |



\- \*\*Constraints:\*\* `UNIQUE(brand\_id, slug)`; `CHECK (passing\_score\_pct BETWEEN 0 AND 100)`



\### 3.2 `questions`

\*\*Finalidade:\*\* pergunta de um quiz.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| quiz\_id | uuid | FK → `quizzes.id` |

| body | text | |

| explanation | text | texto exibido após responder (`exp` no código atual) |

| order\_index | integer | |

| is\_active | boolean | permite desativar pergunta sem apagar histórico |



\- \*\*FK:\*\* `quiz\_id` → `quizzes.id` (ON DELETE CASCADE)

\- \*\*Índices:\*\* `quiz\_id, order\_index`



\### 3.3 `alternatives`

\*\*Finalidade:\*\* alternativas de resposta.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| question\_id | uuid | FK → `questions.id` |

| body | text | |

| is\_correct | boolean | |

| feedback | text | feedback específico da alternativa (`fb\[i]` no código atual) |

| order\_index | integer | |



\- \*\*FK:\*\* `question\_id` → `questions.id` (ON DELETE CASCADE)

\- \*\*Constraint:\*\* trigger garante \*\*exatamente uma\*\* alternativa `is\_correct = true` por pergunta (ou N para múltipla escolha, se o produto evoluir — hoje é sempre resposta única)

\- \*\*Índices:\*\* `question\_id`



\### 3.4 `quiz\_attempts`

\*\*Finalidade:\*\* cada tentativa de um usuário em um quiz — é a fonte de verdade para nota, aprovação e histórico (substitui o e-mail via EmailJS).



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| user\_id | uuid | FK → `profiles.id` |

| quiz\_id | uuid | FK → `quizzes.id` |

| started\_at | timestamptz | |

| finished\_at | timestamptz | nullable enquanto em andamento |

| score\_pct | numeric(5,2) | calculado por trigger/function ao finalizar, nunca enviado pelo cliente |

| passed | boolean | calculado (`score\_pct >= quiz.passing\_score\_pct`) |

| attempt\_number | integer | calculado (n-ésima tentativa do usuário naquele quiz) |

| duration\_seconds | integer | calculado (`finished\_at - started\_at`) |



\- \*\*Índices:\*\* `(user\_id, quiz\_id)`, `(quiz\_id, passed)` (para taxa de acerto por quiz), `finished\_at` (para relatórios por período)

\- \*\*Regra de integridade:\*\* `score\_pct`, `passed`, `attempt\_number` e `duration\_seconds` \*\*nunca são inseridos pelo cliente\*\* — são preenchidos por trigger `AFTER INSERT` em `quiz\_answers` quando a última resposta do attempt é registrada, ou por function chamada ao "finalizar" o quiz



\### 3.5 `quiz\_answers`

\*\*Finalidade:\*\* cada resposta individual dentro de uma tentativa — permite responder "quais perguntas têm maior índice de erro" e "menor taxa de acerto por colaborador".



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| attempt\_id | uuid | FK → `quiz\_attempts.id` |

| question\_id | uuid | FK → `questions.id` |

| alternative\_id | uuid | FK → `alternatives.id` |

| is\_correct | boolean | congelado no momento da resposta |

| answered\_at | timestamptz | |



\- \*\*Constraints:\*\* `UNIQUE(attempt\_id, question\_id)` — uma resposta por pergunta por tentativa

\- \*\*Índices:\*\* `question\_id` (para agregações de taxa de erro por pergunta), `attempt\_id`



\---



\## 4. Domínio: Games



\### 4.1 `games`

\*\*Finalidade:\*\* catálogo de minigames (Duelo Instinct, Duelo MARQ Carbon, e futuros).



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| brand\_id | uuid | FK → `brands.id` |

| slug | text | único |

| title | text | |

| config | jsonb | regras/rounds/categorias do jogo |

| is\_published | boolean | |



\### 4.2 `game\_sessions`

\*\*Finalidade:\*\* cada partida jogada.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| user\_id | uuid | FK → `profiles.id` |

| game\_id | uuid | FK → `games.id` |

| started\_at | timestamptz | |

| finished\_at | timestamptz | |

| rounds\_played | integer | |

| result\_summary | jsonb | detalhe bruto da partida (para auditoria/replay) |



\- \*\*Índices:\*\* `(user\_id, game\_id)`, `finished\_at`



\### 4.3 `game\_scores`

\*\*Finalidade:\*\* pontuação consolidada por partida — separada de `game\_sessions` para permitir múltiplas métricas de score sem alterar o registro bruto da sessão.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| session\_id | uuid | FK → `game\_sessions.id`, único (1:1) |

| score | integer | |

| accuracy\_pct | numeric(5,2) | |

| rank\_at\_time | integer | posição do jogador no momento (opcional, snapshot) |



\- \*\*Constraint:\*\* `UNIQUE(session\_id)`

\- \*\*Índices:\*\* `score` (para leaderboard de jogos)



\---



\## 5. Domínio: Progresso



> Aqui mora a correção do maior problema do sistema atual: progresso hoje vive em `localStorage`, por navegador, chaveado por nome digitado — sem servidor, sem histórico, sem agregação possível.



\### 5.1 `user\_progress`

\*\*Finalidade:\*\* status de um usuário em cada \*\*checkpoint\*\* (módulo, quiz ou game) — visão consolidada usada para desenhar a trilha (bloqueado/em andamento/concluído).



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| user\_id | uuid | FK → `profiles.id` |

| checkpoint\_id | uuid | FK → `checkpoints.id` |

| status | text | `locked`, `unlocked`, `in\_progress`, `completed` |

| completed\_at | timestamptz | nullable |

| updated\_at | timestamptz | |



\- \*\*Constraints:\*\* `UNIQUE(user\_id, checkpoint\_id)`; `CHECK (status IN ('locked','unlocked','in\_progress','completed'))`

\- \*\*Índices:\*\* `(user\_id, status)`, `checkpoint\_id` (para "qual módulo gera mais dificuldade" via `JOIN` com tempo/tentativas)

\- \*\*Regra de integridade:\*\* atualizado por trigger a partir de `quiz\_attempts.passed = true`, `lesson\_progress` completo a 100%, ou `game\_sessions` concluída — nunca escrito diretamente pelo frontend



\### 5.2 `lesson\_progress`

\*\*Finalidade:\*\* granularidade fina de "continuar de onde parou" dentro de um módulo com várias lições.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| user\_id | uuid | FK → `profiles.id` |

| lesson\_id | uuid | FK → `lessons.id` |

| progress\_pct | numeric(5,2) | default 0 |

| last\_position | jsonb | ex.: timestamp de vídeo, scroll, etc. |

| completed\_at | timestamptz | nullable |

| updated\_at | timestamptz | |



\- \*\*Constraints:\*\* `UNIQUE(user\_id, lesson\_id)`

\- \*\*Índices:\*\* `(user\_id, updated\_at DESC)` — exatamente o índice que sustenta a query "continuar de onde parou" (última lição tocada)



\### 5.3 `checkpoint\_progress` (histórico, distinto de `user\_progress`)

\*\*Finalidade:\*\* enquanto `user\_progress` é o \*\*estado atual\*\*, esta tabela é o \*\*log de eventos\*\* de mudança de status — necessário para "evolução mensal" e "velocidade de conclusão".



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| user\_id | uuid | FK → `profiles.id` |

| checkpoint\_id | uuid | FK → `checkpoints.id` |

| from\_status | text | |

| to\_status | text | |

| changed\_at | timestamptz | default now() |



\- \*\*Índices:\*\* `(user\_id, changed\_at)`, `(checkpoint\_id, changed\_at)`

\- Alimentada por trigger `AFTER UPDATE` em `user\_progress`



\---



\## 6. Domínio: Gamificação



\### 6.1 `points\_ledger`

\*\*Finalidade:\*\* livro-razão de pontos/XP — substitui os atributos manuais do álbum atual (`Produto`, `Ritmo`, etc. editados à mão). Cada linha é um evento de ganho (ou eventualmente estorno) de pontos.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| user\_id | uuid | FK → `profiles.id` |

| source\_type | text | `quiz`, `module`, `game`, `badge`, `certification`, `manual\_adjustment` |

| source\_id | uuid | id da origem (quiz\_attempt, game\_session, etc.) |

| points | integer | pode ser negativo (estorno/ajuste) |

| reason | text | descrição legível, obrigatório quando `source\_type = 'manual\_adjustment'` |

| created\_by | uuid | FK → `profiles.id`, nullable (sistema) — quem gerou o lançamento manual, se houver |

| created\_at | timestamptz | default now() |



\- \*\*Índices:\*\* `(user\_id, created\_at)` — sustenta soma de XP e "evolução mensal" via agregação por período

\- \*\*Regra de integridade:\*\* \*\*XP total do usuário nunca é um campo próprio\*\* — é sempre `SUM(points) WHERE user\_id = ...`, exposto via view (seção 9)



\### 6.2 `badges`

\*\*Finalidade:\*\* catálogo de badges (ex.: "Especialista em Cintas", conquistado hoje só visualmente).



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| brand\_id | uuid | FK → `brands.id` |

| slug | text | único |

| title | text | |

| description | text | |

| icon\_url | text | |

| rule | jsonb | condição de concessão (ex.: quiz X aprovado + módulo Y concluído) |



\### 6.3 `user\_badges`

\*\*Finalidade:\*\* badges conquistados.



| Campo | Tipo |

|---|---|

| id | uuid — PK |

| user\_id | uuid — FK → `profiles.id` |

| badge\_id | uuid — FK → `badges.id` |

| earned\_at | timestamptz |



\- \*\*Constraint:\*\* `UNIQUE(user\_id, badge\_id)` — badge só é concedido uma vez

\- \*\*Índices:\*\* `user\_id`



\### 6.4 `achievements`

\*\*Finalidade:\*\* conquistas mais amplas/narrativas (diferente de badge pontual — ex.: "Completou toda a Zona Corredor", "30 dias de streak"), usadas na Home ("destaques"/"conquistas" do dashboard atual).



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| brand\_id | uuid | FK |

| slug | text | único |

| title | text | |

| description | text | |

| rule | jsonb | |

| tier | text | `bronze`, `silver`, `gold` (opcional) |



\### 6.5 `user\_achievements`



| Campo | Tipo |

|---|---|

| id | uuid — PK |

| user\_id | uuid — FK → `profiles.id` |

| achievement\_id | uuid — FK → `achievements.id` |

| earned\_at | timestamptz |



\- \*\*Constraint:\*\* `UNIQUE(user\_id, achievement\_id)`



\### 6.6 `streaks`

\*\*Finalidade:\*\* sequência de dias consecutivos de estudo — não existe hoje, mas é citado implicitamente pela ideia de engajamento contínuo.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| user\_id | uuid | FK → `profiles.id`, único (1:1) |

| current\_streak\_days | integer | default 0 |

| longest\_streak\_days | integer | default 0 |

| last\_activity\_date | date | |

| updated\_at | timestamptz | |



\- \*\*Constraint:\*\* `UNIQUE(user\_id)`

\- Atualizado por trigger/function diária a partir de `study\_sessions`/`login\_events`



\### 6.7 `leaderboard` (snapshot materializado, não fonte de verdade)

\*\*Finalidade:\*\* tabela de \*\*snapshot periódico\*\* do ranking, para servir o dashboard rapidamente sem recalcular agregações pesadas em tempo real a cada acesso, e para permitir "ranking do mês passado vs. este mês".



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| user\_id | uuid | FK → `profiles.id` |

| scope\_type | text | `global`, `store`, `role`, `brand` |

| scope\_id | uuid | nullable (id da loja/cargo quando aplicável) |

| period | text | `2026-07`, ou `all\_time` |

| total\_points | integer | |

| rank\_position | integer | |

| computed\_at | timestamptz | |



\- \*\*Índices:\*\* `(scope\_type, scope\_id, period, rank\_position)`

\- Gerada por job agendado (Edge Function/cron) que lê `points\_ledger` — nunca escrita manualmente (elimina de vez a atualização manual mensal do álbum)



\### 6.8 `activity\_feed`

\*\*Finalidade:\*\* Mural de Atividades — feed único de conquistas, \*\*global entre todas as lojas\*\* (decisão de produto: reforça senso de comunidade da rede inteira, não só da própria loja). Funciona como uma timeline "tipo notificação": novas linhas aparecem em tempo real via Supabase Realtime, sem o cliente precisar dar refresh/polling. Texto puro, sem peso de mídia — mantém o princípio de custo zero de armazenamento do plano original.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| brand\_id | uuid | FK → `brands.id` — feed é global \*dentro da marca\*, não entre marcas diferentes (Garmin e Shokz não se misturam) |

| subject\_id | uuid | FK → `profiles.id` — o vendedor protagonista da mensagem (nullable só em mensagens institucionais gerais, se existirem no futuro) |

| store\_id | uuid | FK → `stores.id`, nullable — mantido só para exibir "{loja}" na mensagem e permitir filtro opcional por loja na UI; \*\*não é usado para restringir visibilidade\*\* (feed é aberto) |

| author\_id | uuid | FK → `profiles.id`, nullable — quem gerou a postagem manual (líder); `null` quando `trigger\_type = 'automatic'` (o "autor" é o sistema) |

| trigger\_type | text | `automatic` \\| `manual` |

| source\_event | text | `badge\_earned`, `streak\_milestone`, `quiz\_perfect\_score`, `certification\_issued`, `leader\_manual` — usado para escolher ícone/estilo no front sem parsear o texto |

| related\_badge\_id | uuid | FK → `badges.id`, nullable — preenchido quando a origem é conquista de badge |

| message | text | texto final já renderizado (ex.: `"{vendedor} desbravou o território inicial e conquistou o badge Explorer! 🧭"`) — guardado pronto, não como template, para não depender de re-render em cada leitura |

| created\_at | timestamptz | default now() |



\- \*\*PK:\*\* `id`

\- \*\*FK:\*\* `brand\_id` → `brands.id`; `subject\_id` → `profiles.id`; `store\_id` → `stores.id` (ON DELETE SET NULL); `author\_id` → `profiles.id` (ON DELETE SET NULL); `related\_badge\_id` → `badges.id` (ON DELETE SET NULL)

\- \*\*Constraints:\*\* `CHECK (trigger\_type IN ('automatic','manual'))`; `CHECK (trigger\_type = 'manual' OR author\_id IS NULL)` — garante que post automático nunca tenha autor humano

\- \*\*Índices:\*\* `(brand\_id, created\_at DESC)` — é o índice que sustenta a query principal do mural (feed ordenado, mais recente primeiro); `subject\_id` (para "minhas conquistas no mural")

\- \*\*Regra de integridade:\*\* mensagens automáticas são geradas por trigger `AFTER INSERT` nas tabelas de origem (`user\_badges`, `streaks` ao bater marco, `quiz\_attempts` quando `score\_pct = 100` na primeira tentativa, `user\_certifications`) — o cliente nunca insere `trigger\_type = 'automatic'` diretamente. Mensagens manuais só podem ser inseridas por um `profile` com `role.code = 'leader'` ou `'admin'`, e apenas sobre um `subject\_id` que esteja em uma loja sob a gestão daquele líder (`store\_leaders`) — validado via trigger `BEFORE INSERT`.

\- \*\*Realtime:\*\* tabela habilitada para Supabase Realtime (`ALTER PUBLICATION supabase\_realtime ADD TABLE activity\_feed`) — o front assina `INSERT` e injeta a nova linha no topo do mural sem recarregar a lista.



\---



\## 7. Domínio: Certificações



\### 7.1 `certifications`

\*\*Finalidade:\*\* definição de cada nível de certificação (Explorador/Corredor/Maratonista/Triatleta), com critério de emissão.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| brand\_id | uuid | FK |

| trail\_id | uuid | FK → `trails.id`, nullable |

| slug | text | único |

| title | text | |

| criteria | jsonb | ex.: "todas as zonas da trilha concluídas" |

| certificate\_template\_url | text | Storage — modelo do PDF gerado |



\### 7.2 `user\_certifications`

\*\*Finalidade:\*\* certificado emitido para um usuário.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| user\_id | uuid | FK → `profiles.id` |

| certification\_id | uuid | FK → `certifications.id` |

| issued\_at | timestamptz | |

| certificate\_url | text | PDF final gerado, no Storage |

| revoked\_at | timestamptz | nullable — permite revogação sem apagar histórico |



\- \*\*Constraint:\*\* `UNIQUE(user\_id, certification\_id)` (a menos que se queira permitir re-certificação anual — nesse caso remover o unique e adicionar `valid\_until`)

\- \*\*Índices:\*\* `user\_id`, `certification\_id`

\- Emitido por trigger/Edge Function quando `user\_progress` indica trilha 100% concluída



\### 7.3 `evaluations` / `evaluation\_questions` (documentado retroativamente)

\*\*Finalidade:\*\* motor de Avaliações Trimestrais por tier (Explorer/Runner/Triathlete), já implementado em produção (`sql/005\_evaluations\_and\_notifications.sql`, ver `PROJECT\_CHECKLIST.md`) mas ausente deste documento de arquitetura até agora. Estrutura análoga a `quizzes`/`questions`, com gabarito protegido por view pública (`v\_evaluation\_questions\_public`) no mesmo padrão de `alternatives`/`is\_correct`.



| Tabela | Papel |

|---|---|

| `evaluations` | definição da avaliação por tier (equivalente a `quizzes`, mas para certificação trimestral formal) |

| `evaluation\_questions` | pergunta + `correct\_option`, protegido por view pública sem o gabarito |



\### 7.4 `evaluation\_attempts` / `evaluation\_answers`

\*\*Finalidade:\*\* granularidade necessária para o BI de Gaps de Conhecimento (ver §9, `vw\_store\_knowledge\_gaps`) — mesmo papel que `quiz\_attempts`/`quiz\_answers` cumprem para quizzes de conteúdo, mas para a avaliação formal trimestral. Sem essa granularidade por pergunta, não é possível calcular "quais perguntas essa loja mais erra".



| Campo (`evaluation\_attempts`) | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| user\_id | uuid | FK → `profiles.id` |

| evaluation\_id | uuid | FK → `evaluations.id` |

| store\_id | uuid | FK → `stores.id` — congelado no momento da tentativa (mesmo que o usuário mude de loja depois, a tentativa continua contando para a loja onde ela ocorreu) |

| started\_at / finished\_at | timestamptz | |

| score\_pct | numeric(5,2) | calculado por function, nunca pelo cliente |

| passed | boolean | |

| locked\_until | timestamptz | trava de 24h (já existente via `fn\_check\_evaluation\_lock`) |



| Campo (`evaluation\_answers`) | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| attempt\_id | uuid | FK → `evaluation\_attempts.id` |

| question\_id | uuid | FK → `evaluation\_questions.id` |

| is\_correct | boolean | congelado no momento da resposta |

| answered\_at | timestamptz | |



\- \*\*Constraints:\*\* `UNIQUE(attempt\_id, question\_id)`

\- \*\*Índices:\*\* `(question\_id, store\_id)` via `JOIN` com `evaluation\_attempts` — é o índice que sustenta a agregação "pergunta mais errada por loja"



\---



\## 8. Domínio: Analytics e Auditoria



\### 8.1 `login\_events`

\*\*Finalidade:\*\* sustenta diretamente "quem não acessa há mais de 7 dias" e engajamento.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| user\_id | uuid | FK → `profiles.id` |

| logged\_in\_at | timestamptz | |

| device\_info | jsonb | user-agent, opcional |

| ip\_hash | text | hash do IP, não IP puro (privacidade) |



\- \*\*Índices:\*\* `(user\_id, logged\_in\_at DESC)` — essencial para "último acesso"



\### 8.2 `study\_sessions`

\*\*Finalidade:\*\* sustenta "tempo médio de estudo", "quem mais estuda" — sessão de uso contínuo do app.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| user\_id | uuid | FK → `profiles.id` |

| started\_at | timestamptz | |

| ended\_at | timestamptz | nullable, atualizado por heartbeat do cliente |

| duration\_seconds | integer | calculado ao fechar a sessão |



\- \*\*Índices:\*\* `(user\_id, started\_at)`



\### 8.3 `page\_views`

\*\*Finalidade:\*\* granularidade de navegação (qual painel/módulo foi acessado), sustenta "qual módulo gera mais dificuldade" cruzado com tempo gasto e taxa de erro.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| user\_id | uuid | FK → `profiles.id` |

| study\_session\_id | uuid | FK → `study\_sessions.id`, nullable |

| panel\_id | text | equivalente ao `data-panel` atual |

| entity\_type | text | `module`, `quiz`, `game`, `home`, etc. |

| entity\_id | uuid | nullable |

| viewed\_at | timestamptz | |



\- \*\*Índices:\*\* `(user\_id, viewed\_at)`, `(entity\_type, entity\_id)`



\### 8.4 `activity\_log`

\*\*Finalidade:\*\* log geral de eventos de gamificação e administrativos (concessão de badge, emissão de certificado, ajuste manual de pontos, ação de admin) — trilha de auditoria única e centralizada.



| Campo | Tipo | Observação |

|---|---|---|

| id | uuid | PK |

| actor\_id | uuid | FK → `profiles.id`, quem gerou o evento (pode ser o próprio sistema) |

| subject\_id | uuid | FK → `profiles.id`, sobre quem é o evento (pode ser igual ao actor) |

| event\_type | text | `badge\_earned`, `cert\_issued`, `points\_adjusted`, `admin\_edit`, ... |

| payload | jsonb | detalhe do evento |

| created\_at | timestamptz | |



\- \*\*Índices:\*\* `(subject\_id, created\_at)`, `(event\_type, created\_at)`



\---



\## 9. Views e Materialized Views (leitura otimizada para os dashboards)



Não é código SQL ainda — apenas a definição de \*\*o que cada view resolve\*\* e \*\*de quais tabelas ela deriva\*\*, para que a modelagem já preveja essas necessidades.



| View | Resolve | Fonte |

|---|---|---|

| `v\_user\_total\_points` | XP total por usuário (ranking geral, por loja, por cargo) | `SUM(points\_ledger.points) GROUP BY user\_id` |

| `v\_user\_last\_activity` | Último acesso — base do "quem não acessa há 7+ dias" | `MAX(login\_events.logged\_in\_at) GROUP BY user\_id` |

| `v\_quiz\_accuracy\_by\_question` | Taxa de erro por pergunta | `quiz\_answers` agregada por `question\_id` |

| `v\_module\_difficulty` | Qual módulo gera mais dificuldade (combina taxa de erro dos quizzes do módulo + tempo médio em `lesson\_progress`) | `quiz\_answers` + `checkpoints` + `lesson\_progress` |

| `v\_user\_study\_time\_avg` | Tempo médio de estudo por colaborador/período | `study\_sessions.duration\_seconds` agregada por `user\_id`, por mês |

| `mv\_leaderboard\_global` (materialized) | Ranking geral, recalculado periodicamente | `v\_user\_total\_points` + `profiles` |

| `mv\_leaderboard\_by\_store` (materialized) | Ranking por loja | idem + `store\_id` |

| `mv\_leaderboard\_by\_role` (materialized) | Ranking por cargo (`job\_title`) | idem + `profiles.job\_title` |

| `mv\_leaderboard\_by\_certifications` (materialized) | Ranking por quantidade/nível de certificação | `user\_certifications` agregada |

| `mv\_leaderboard\_engagement` (materialized) | Ranking por engajamento (logins + tempo de estudo + streak) | `login\_events` + `study\_sessions` + `streaks`, com peso configurável |

| `mv\_leaderboard\_completion\_speed` (materialized) | Ranking por velocidade de conclusão de trilha | `checkpoint\_progress` — tempo entre primeiro `unlocked` e `completed` |

| `v\_user\_monthly\_evolution` | Evolução mensal (pontos, módulos concluídos, quizzes aprovados) | `points\_ledger` + `checkpoint\_progress` agregados por mês |

| `v\_team\_comparison` | Comparação do colaborador com a média da equipe/loja | `v\_user\_total\_points` cruzada com `stores` |

| `vw\_store\_knowledge\_gaps` | "Farol" de treinamento do líder — ranking das perguntas mais erradas \*\*daquela loja específica\*\* na Avaliação Trimestral, protegida por RLS (líder só vê a própria loja) | `evaluation\_answers` + `evaluation\_attempts.store\_id` agregados por `question\_id`, ordenado por taxa de erro desc |



As \*\*materialized views de ranking são atualizadas por job agendado\*\* (Edge Function com cron do Supabase, ex.: a cada hora ou diariamente), não em tempo real a cada request — evita custo de recálculo constante e ainda assim mantém `leaderboard` (snapshot histórico) alimentada.



\---



\## 10. Triggers e Functions (o que cada uma resolve)



| Trigger/Function | Dispara em | Faz o quê |

|---|---|---|

| `fn\_grade\_quiz\_attempt` | `AFTER INSERT` na última resposta de um `quiz\_attempts` (ou chamada explícita "finalizar") | Calcula `score\_pct`, `passed`, `duration\_seconds` a partir de `quiz\_answers` — nunca confia em valor vindo do cliente |

| `fn\_award\_points\_on\_pass` | `AFTER UPDATE` em `quiz\_attempts` quando `passed` vira `true` | Insere linha em `points\_ledger` |

| `fn\_update\_user\_progress` | `AFTER` em `quiz\_attempts`, `lesson\_progress`, `game\_sessions` | Atualiza `user\_progress.status` do checkpoint correspondente |

| `fn\_log\_checkpoint\_change` | `AFTER UPDATE` em `user\_progress` | Insere em `checkpoint\_progress` (histórico) |

| `fn\_check\_badge\_rules` | `AFTER INSERT` em `points\_ledger`, `user\_progress`, `user\_certifications` | Avalia `badges.rule`/`achievements.rule` e concede se satisfeito |

| `fn\_issue\_certification` | `AFTER UPDATE` em `user\_progress` (trilha 100%) | Gera `user\_certifications`, dispara Edge Function de geração de PDF |

| `fn\_update\_streak` | job diário (Edge Function) | Recalcula `streaks` a partir de `study\_sessions`/`login\_events` do dia |

| `fn\_enforce\_single\_correct\_alternative` | `BEFORE INSERT/UPDATE` em `alternatives` | Garante exatamente uma alternativa correta por pergunta |

| `fn\_validate\_checkpoint\_reference` | `BEFORE INSERT/UPDATE` em `checkpoints` | Garante que `reference\_id` existe na tabela certa conforme `checkpoint\_type` |

| `fn\_refresh\_leaderboards` | cron (Edge Function agendada) | `REFRESH MATERIALIZED VIEW` de todas as `mv\_leaderboard\_\*` |

| `fn\_soft\_delete\_profile` | chamada de admin | Marca `deleted\_at` em vez de `DELETE`, preservando histórico |

| `fn\_post\_to\_activity\_feed` | `AFTER INSERT` em `user\_badges`, `user\_certifications`; `AFTER UPDATE` em `streaks` (marco atingido); `AFTER UPDATE` em `quiz\_attempts` (`score\_pct = 100` na 1ª tentativa) | Monta o texto final (com emoji/template) e insere em `activity\_feed` com `trigger\_type = 'automatic'` |

| `fn\_validate\_manual\_mural\_post` | `BEFORE INSERT` em `activity\_feed` quando `trigger\_type = 'manual'` | Garante que `author\_id` é líder/admin e que `subject\_id` está em loja sob a gestão desse líder (via `store\_leaders`) |

| `fn\_grade\_evaluation\_attempt` | equivalente a `fn\_grade\_quiz\_attempt`, mas em `evaluation\_answers`/`evaluation\_attempts` | Calcula `score\_pct`/`passed` da Avaliação Trimestral no servidor |



\---



\## 11. Políticas de RLS (Row Level Security) — desenho por tabela



Regra geral: \*\*RLS habilitado em 100% das tabelas\*\*, nada fica aberto por omissão.



| Tabela | Colaborador | Líder | Admin |

|---|---|---|---|

| `profiles` | `SELECT/UPDATE` apenas a própria linha (campos não sensíveis) | `SELECT` de perfis cujo `store\_id` esteja em `store\_leaders` do líder | acesso total |

| `quiz\_attempts` / `quiz\_answers` | `SELECT/INSERT` apenas `user\_id = auth.uid()` | `SELECT` das lojas sob sua gestão | total |

| `game\_sessions` / `game\_scores` | igual acima | `SELECT` das lojas sob gestão | total |

| `user\_progress` / `lesson\_progress` / `checkpoint\_progress` | `SELECT` próprio; `INSERT/UPDATE` apenas via function (não direto) | `SELECT` das lojas sob gestão | total |

| `points\_ledger` | `SELECT` próprio, \*\*sem `INSERT/UPDATE` direto\*\* (só via trigger/function com `SECURITY DEFINER`) | `SELECT` das lojas sob gestão | `INSERT` manual permitido (ajustes), com `created\_by` obrigatório |

| `user\_badges` / `user\_achievements` / `user\_certifications` | `SELECT` próprio | `SELECT` das lojas sob gestão | total, `INSERT/UPDATE` manual permitido |

| `leaderboard` / `mv\_leaderboard\_\*` | `SELECT` liberado a todos autenticados (ranking é público internamente) | idem | total |

| `login\_events` / `study\_sessions` / `page\_views` | `INSERT` próprio (telemetria), `SELECT` próprio | `SELECT` das lojas sob gestão | total |

| `activity\_log` | sem acesso direto | `SELECT` filtrado por `subject\_id` nas lojas sob gestão | total |

| Tabelas de conteúdo (`trails`,`zones`,`modules`,`lessons`,`quizzes`,`questions`,`alternatives`,`games`,`badges`,`achievements`,`certifications`) | `SELECT` apenas onde `is\_published = true` | idem colaborador (mais visão de rascunho, se decidido) | `SELECT/INSERT/UPDATE/DELETE` total |

| `activity\_feed` | `SELECT` \*\*liberado a todos os autenticados da marca, de qualquer loja\*\* (mural é global por decisão de produto); `INSERT` só via function (automático) — nunca direto | `SELECT` igual colaborador; `INSERT manual` permitido só sobre `subject\_id` de loja sob sua gestão | total |

| `evaluation\_attempts` / `evaluation\_answers` | `SELECT/INSERT` apenas `user\_id = auth.uid()`, via function (não direto) | `SELECT` das lojas sob gestão | total |

| `brands`, `stores`, `roles` | `SELECT` da própria marca/loja | `SELECT` | total |



\*\*Importante:\*\* `alternatives.is\_correct` \*\*nunca é exposto\*\* ao papel Colaborador antes de a pergunta ser respondida — isso não se resolve só com RLS de linha, e sim com uma \*\*view pública sem a coluna `is\_correct`\*\* para servir o quiz em andamento, liberando a coluna real só em `quiz\_answers` (já respondido) ou via function que julga a resposta no servidor.



\---



\## 12. Edge Functions necessárias



| Edge Function | Responsabilidade |

|---|---|

| `submit-quiz-answer` | Recebe resposta, grava em `quiz\_answers`, dispara avaliação (evita expor gabarito no client) |

| `finalize-quiz-attempt` | Fecha a tentativa, calcula nota final, dispara pontos/badges/progresso |

| `generate-certificate-pdf` | Gera o PDF do certificado a partir do template no Storage, grava `certificate\_url` |

| `refresh-leaderboards` | Cron diário/horário — `REFRESH MATERIALIZED VIEW` de todas as leaderboards |

| `compute-streaks` | Cron diário — recalcula `streaks` |

| `send-engagement-alerts` | Cron — identifica usuários inativos 7+ dias e líderes correspondentes, gera notificação (não mais e-mail solto via EmailJS) |

| `import-sales-ranking` | Se a integração com a planilha de vendas continuar existindo, importa e grava em `points\_ledger`/tabela auxiliar `sales\_metrics`, de forma auditável (não editando o perfil manualmente) |

| `upload-attachment` | Valida tipo/tamanho de arquivo antes de liberar upload direto ao bucket |



\---



\## 13. Storage Buckets e sistema de upload



| Bucket | Conteúdo | Acesso |

|---|---|---|

| `avatars` | fotos de perfil dos colaboradores | leitura pública (URLs assinadas ou pública, conforme política de privacidade), escrita apenas pelo próprio usuário ou admin |

| `brand-assets` | logos, temas, capas de trilha/módulo | leitura pública, escrita só admin |

| `lesson-media` | vídeos/imagens/PDFs de conteúdo educacional | leitura autenticada (apenas usuários logados na marca), escrita só admin |

| `certificates` | PDFs de certificados emitidos | leitura restrita ao próprio usuário + líder da loja + admin (URL assinada com expiração) |

| `attachments-general` | anexos diversos vinculados a `attachments` | leitura conforme `lesson\_id`/`module\_id` publicado |



\*\*Sistema de upload:\*\* todo upload passa por Edge Function (`upload-attachment`) que valida `mime\_type`, tamanho máximo e quota antes de liberar a URL assinada de escrita — nunca upload direto do cliente sem validação de borda, para não repetir o padrão atual de campos de imagem soltos em cards sem qualquer controle.



\---



\## 14. Visão consolidada do relacionamento entre domínios



```

brands ─┬─< stores ─< profiles >─< store\_leaders (líder N:N loja)

&#x20;       ├─< trails ─< zones ─< checkpoints ──> modules ─< lessons ─< attachments

&#x20;       │                              └─────> quizzes ─< questions ─< alternatives

&#x20;       │                              └─────> games

&#x20;       ├─< badges ─< user\_badges >─ profiles

&#x20;       ├─< achievements ─< user\_achievements >─ profiles

&#x20;       ├─< certifications ─< user\_certifications >─ profiles

&#x20;       │                └─< evaluations ─< evaluation\_questions

&#x20;       └─< activity\_feed (global, todas as lojas da marca) ── subject\_id/author\_id ─> profiles



profiles ─< quiz\_attempts ─< quiz\_answers

profiles ─< evaluation\_attempts ─< evaluation\_answers ──(agregado por loja)──> vw\_store\_knowledge\_gaps

profiles ─< game\_sessions ─< game\_scores

profiles ─< user\_progress (por checkpoint) ─< checkpoint\_progress (histórico)

profiles ─< lesson\_progress

profiles ─< points\_ledger ──(agregado)──> v\_user\_total\_points ──> mv\_leaderboard\_\*

profiles ─< login\_events / study\_sessions ─< page\_views

profiles ─< streaks (1:1)

profiles ─< activity\_log (como actor e como subject)

```



Todo o grafo converge em `profiles.id` — é o nó que permite responder, com um `JOIN` simples e sem nova modelagem, cada uma das perguntas listadas para o dashboard do líder (acesso, estudo, taxa de acerto, dificuldade por módulo, evolução, todos os tipos de ranking, gaps de conhecimento por loja) e do colaborador (progresso em tempo real, retomar de onde parou, histórico completo, conquistas, comparação com a equipe, mural de conquistas da rede inteira).



\---



\## 15. Cobertura explícita das perguntas do Dashboard do Líder



| Pergunta | Como é respondida |

|---|---|

| Quem não acessa há mais de 7 dias? | `v\_user\_last\_activity` filtrando `MAX(logged\_in\_at) < now() - interval '7 days'` |

| Quem mais estuda? | `v\_user\_study\_time\_avg` ordenado desc |

| Quem possui menor taxa de acerto? | agregação de `quiz\_answers.is\_correct` por `user\_id` |

| Quais perguntas têm maior índice de erro? | `v\_quiz\_accuracy\_by\_question` |

| Qual módulo gera mais dificuldade? | `v\_module\_difficulty` |

| Tempo médio de estudo por colaborador | `v\_user\_study\_time\_avg` |

| Evolução mensal | `v\_user\_monthly\_evolution` |

| Ranking por loja / geral / cargo / certificações / engajamento / velocidade / XP | as `mv\_leaderboard\_\*` correspondentes |

| Quais perguntas da Avaliação Trimestral a minha loja mais erra? | `vw\_store\_knowledge\_gaps` |



\## 16. Cobertura explícita do Dashboard do Colaborador



| Necessidade | Como é resolvida |

|---|---|

| Progresso em tempo real | `user\_progress` + `lesson\_progress`, lidos diretamente (sem cache) |

| Continuar de onde parou | `lesson\_progress` ordenado por `updated\_at DESC` |

| Histórico de atividades | `activity\_log` + `page\_views` filtrados por `subject\_id`/`user\_id` |

| Histórico de quizzes | `quiz\_attempts` (todas as tentativas, não só a última) |

| Histórico de games | `game\_sessions` + `game\_scores` |

| Conquistas / badges / certificados | `user\_achievements`, `user\_badges`, `user\_certifications` |

| Evolução por mês | `v\_user\_monthly\_evolution` |

| Comparação com a equipe | `v\_team\_comparison` |



\---



Esta modelagem está pronta para virar schema físico (migrations SQL) na próxima etapa. Quer que eu escreva agora as migrations SQL completas (`CREATE TABLE`, `CREATE POLICY`, `CREATE TRIGGER`, `CREATE FUNCTION`, `CREATE MATERIALIZED VIEW`) na ordem correta de dependência, ou prefere primeiro revisar/ajustar algum domínio específico deste desenho?

