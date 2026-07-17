# Regras de Negócio — Garmin Training Hub
### Especificação funcional definitiva (Product Owner + Software Architect)

> Este documento define **como o sistema deve se comportar**, não como será construído. Onde existe mais de uma forma legítima de implementar uma regra, apresento alternativas com vantagens/desvantagens e uma recomendação — mas a decisão final é do negócio.

---

## 1. USUÁRIOS

### 1.1 Cadastro
- Cadastro é sempre feito pelo **Administrador** (não há autocadastro público) — plataforma corporativa fechada.
- Campos obrigatórios no cadastro: nome completo, `username`, loja, cargo, papel (colaborador/líder/admin), marca (se multi-marca).
- Senha inicial é **gerada pelo sistema** (aleatória) ou definida pelo admin — nunca enviada em texto puro por canal não seguro; recomenda-se exibição única na tela do admin no momento da criação, para ele repassar pessoalmente ou por canal interno.
- Todo novo usuário nasce com `must_change_password = true`.

**Alternativa em disputa — quem pode cadastrar líder/admin:**
| Opção | Vantagem | Desvantagem |
|---|---|---|
| Só Admin cadastra qualquer papel | Controle centralizado, menor risco de erro de permissão | Depende de disponibilidade do admin para todo onboarding |
| Líder pode cadastrar Colaborador da própria loja | Onboarding mais rápido, descentraliza operação | Risco de inconsistência de dados de loja/cargo se não houver validação forte |

**Recomendação:** Admin cadastra Líderes e Admins; Líder pode cadastrar Colaboradores **apenas da(s) própria(s) loja(s)**, com o registro sempre auditado.

### 1.2 Login
- Login por `username` + senha (convertido internamente para e-mail técnico, como já ocorre hoje).
- Sessão persistente via Supabase Auth (JWT), expiração configurável (recomendado 7 dias com refresh automático em uso ativo).
- Todo login bem-sucedido ou falho gera evento de auditoria (necessário para bloqueio por tentativas, ver 1.5).
- **Modo convidado**: mantido apenas para demonstração/eventos pontuais — **não gera progresso, XP nem certificação**, e deve ficar visualmente marcado como sessão temporária.

### 1.3 Troca de senha
- Usuário pode trocar a própria senha a qualquer momento, autenticado, informando a senha atual.
- Requisito mínimo: 8+ caracteres (recomendado subir dos 6 atuais), sem exigir composição complexa que gere fricção desnecessária num público não-técnico.
- Troca de senha **não** encerra outras sessões ativas por padrão — a menos que motivada por suspeita de comprometimento, caso em que todas as sessões devem ser invalidadas.

### 1.4 Recuperação de senha

**Decisão confirmada (2026-07-09):** e-mail real passa a ser cadastrado por colaborador (substituindo o padrão fake `@proparts.internal`), mas **nenhum fluxo de e-mail automático do Supabase Auth é utilizado** — nem confirmação de cadastro, nem recuperação de senha por link. Controle de acesso e reset continuam **100% nas mãos do Admin/Líder**, mesmo com e-mail real disponível.

Motivo da escolha (rejeitando a alternativa de autoatendimento por e-mail que estava em disputa): plataforma corporativa fechada, sem autocadastro (regra 1.1) — não há benefício de escala que justifique abrir mão do controle, e evita depender de caixa de entrada de terceiro (spam, e-mail corporativo que o vendedor não checa, etc.).

**Como isso é garantido tecnicamente** (relevante para a modelagem/implementação):
- Toda troca de e-mail é feita via **Supabase Admin API** (`updateUserById` com `email_confirm: true`), nunca via método client-side de auto-atualização — isso evita o e-mail de confirmação de double opt-in.
- Todo reset de senha é feito via **Supabase Admin API** (`updateUserById` com nova senha temporária), nunca via `resetPasswordForEmail()` — a senha temporária é exibida uma única vez na tela do Admin/Líder para repasse manual (já era a regra existente).
- Recomenda-se desligar **"Enable email confirmations"** nas configurações de Auth do projeto, como camada extra de segurança contra disparo acidental.
- Admin API exige `service_role key`, que **nunca pode rodar no navegador** — por isso troca de e-mail e reset de senha entram na mesma Edge Function já prevista no roadmap para cadastro de usuário (ver `PROJECT_CHECKLIST.md`, seção "Usuários & Papéis").
- Toda troca de e-mail/reset de senha feita pelo admin gera registro em `activity_log` (`event_type = 'admin_edit'`), com autor e motivo — mesma trilha de auditoria já usada para bloqueio/desbloqueio (regra 1.5).

### 1.5 Bloqueio
- Automático após **N tentativas de login falhas consecutivas** (recomendado: 5 em 15 minutos), com desbloqueio automático por tempo (ex.: 30 min) ou manual pelo admin.
- Manual pelo Admin/Líder a qualquer momento (afastamento, suspeita de uso indevido), independente de tentativas falhas.
- Usuário bloqueado **não perde histórico, progresso, XP ou badges** — apenas fica impedido de autenticar.
- Todo bloqueio/desbloqueio é registrado com autor e motivo.

### 1.6 Primeiro acesso
- Todo primeiro acesso força troca de senha obrigatória (comportamento já existente, mantido).
- Recomenda-se um onboarding curto no primeiro acesso (explicação da trilha e do sistema de XP/badges) — reduz abandono inicial.
- Primeiro acesso não concede XP por padrão; um **badge simbólico de boas-vindas** é uma opção de baixo custo e alto valor motivacional — **recomendado**.

### 1.7 Alteração de loja
- Ação exclusiva de Admin (evita disputas entre líderes de origem/destino).
- Colaborador **mantém 100% do histórico, XP, badges e certificações** — loja é atributo organizacional, não de mérito.
- Rankings "por loja" recalculam a partir da mudança; snapshots de ranking já fechados **não são reescritos retroativamente**.

### 1.8 Alteração de cargo
- Ação de Admin (cargo pode afetar trilha obrigatória).
- Se o novo cargo tiver trilha obrigatória diferente, o sistema deve automaticamente manter concluído o que for compatível e desbloquear os novos checkpoints exigidos, **sem exigir refazer** conteúdo já certificado (a menos que a trilha antiga tenha sido descontinuada).

### 1.9 Desligamento
- Soft delete (`status = 'inactive'`, `deleted_at` preenchido) — **nunca exclusão física**, para preservar integridade de histórico e certificações emitidas (compliance).
- Some de rankings ativos e do dashboard do líder; histórico permanece consultável pelo Admin.
- Login permanentemente bloqueado (diferente de bloqueio temporário).

### 1.10 Reativação
- Ação de Admin: status volta a `active`, `deleted_at` é limpo.

**Alternativa em disputa:**
| Opção | Vantagem | Desvantagem |
|---|---|---|
| Mantém histórico e XP intactos | Justo com esforço já feito, simples | Pode não refletir se o conteúdo mudou muito no período afastado |
| Zera progresso e exige recomeçar | Garante revisão do conteúdo atual | Desmotivador, ignora conquistas legítimas |

**Recomendação:** manter histórico e XP; **reavaliar automaticamente pré-requisitos de módulos republicados/alterados** durante o afastamento.

---

## 2. TRILHAS

### 2.1 Criação
Trilha é criada pelo Admin, sempre em estado inicial de rascunho (`is_published = false`), sempre vinculada a uma marca e opcionalmente a um ou mais cargos.

### 2.2 Publicação
Só é permitida quando a trilha tem ao menos uma zona com ao menos um checkpoint válido. Publicar torna a trilha imediatamente visível a todos os elegíveis — a menos que se use agendamento de liberação (Seção 9), recomendado para lançamentos coordenados.

### 2.3 Edição
Trilha publicada pode ser editada (nova zona, reordenação), mas a edição de módulos/quizzes já existentes segue as regras próprias de versionamento (Seções 3 e 4). Reordenar zonas não afeta retroativamente quem já passou por elas.

### 2.4 Quando pode ser alterada
- Mudanças estruturais: permitidas a qualquer momento, efeito só para progresso futuro.
- Descontinuar uma trilha inteira: marcar `is_published = false`, **nunca apagar**, preservando certificações já emitidas com base nela.

### 2.5 Quando uma alteração exige recertificação
Nem toda edição deve invalidar um certificado já emitido:

| Tipo de alteração | Exige recertificação? |
|---|---|
| Correção ortográfica/cosmética | Não |
| Adição de novo módulo/zona à trilha existente | Não retroativo — quem já se certificou mantém o certificado |
| Mudança de critério técnico relevante (ex.: produto substituído, informação desatualizada) | **Sim**, se sinalizada como crítica pelo admin |
| Mudança na nota de corte do quiz | Não retroativo — vale só para tentativas futuras |

**Recomendação:** toda edição de módulo/quiz vinculado a certificação passa por confirmação explícita do admin — *"esta alteração invalida certificados já emitidos?"* — decisão humana, nunca automática.

---

## 3. MÓDULOS

### 3.1 Ordem
`order_index` dentro da zona; zonas `free_order = true` liberam todos os checkpoints simultaneamente (mantém o "Circuito de Desafios" atual).

### 3.2 Obrigatoriedade
Cada checkpoint tem `is_required`; obrigatórios bloqueiam conclusão da zona, opcionais não impedem avanço. **Pode variar por cargo/trilha** — o mesmo módulo associado a checkpoints diferentes em trilhas diferentes, sem duplicar conteúdo.

### 3.3 Desbloqueio
Sequencial por padrão (módulo N exige N-1 obrigatório concluído); zonas `free_order` liberam tudo de uma vez.

### 3.4 Pré-requisitos

**Alternativa em disputa:**
| Opção | Vantagem | Desvantagem |
|---|---|---|
| Só ordem sequencial dentro da trilha | Simples, fácil de editar | Não cobre dependências entre trilhas diferentes |
| Grafo de pré-requisitos explícito | Flexível, cobre qualquer cenário | Mais complexo, risco de dependência circular |

**Recomendação:** começar com ordem sequencial (cobre 100% do conteúdo atual); introduzir grafo só se surgir caso real de dependência entre trilhas.

### 3.5 Atualização de conteúdo
Pode ser atualizado a qualquer momento; **não afeta** progresso já registrado — só muda o que será exibido dali para frente.

### 3.6 Histórico de versões
Toda edição relevante gera uma versão (autor, data, snapshot/diff do conteúdo) — necessário tanto para auditoria quanto para sustentar a regra de recertificação (2.5).

---

## 4. QUIZZES

### 4.1 Número de tentativas

**Alternativa em disputa:**
| Opção | Vantagem | Desvantagem |
|---|---|---|
| Ilimitado | Reduz frustração, aprendizado por repetição | Pode incentivar tentativa-e-erro sem estudo real |
| Limitado (ex.: 3), depois exige liberação do líder | Reforça estudo antes de tentar | Pode bloquear indevidamente quem só se distraiu |

**Recomendação:** ilimitado para quizzes de **módulo/conteúdo**; **limitado (3 tentativas) para quizzes de certificação final**, com a 4ª exigindo liberação manual do líder.

### 4.2 Critério de aprovação
Nota de corte configurável por quiz (`passing_score_pct`), padrão 70%, ajustável por certificações mais avançadas (80–90%).

### 4.3 Maior nota ou última nota

**Alternativa em disputa:**
| Opção | Vantagem | Desvantagem |
|---|---|---|
| Maior nota entre tentativas | Reconhece o melhor desempenho, motivador | Pode mascarar regressão de conhecimento |
| Última tentativa | Reflete conhecimento mais atual | Penaliza quem acertou de primeira e "piorou" numa revisão despretensiosa |

**Recomendação:** **maior nota** para aprovação/certificação; **última tentativa** exibida como referência de evolução no histórico pessoal — ambas ficam disponíveis, já que todas as tentativas são guardadas.

### 4.4 Tempo limite
Campo opcional por quiz. Quizzes de conteúdo: recomendado **sem limite** (objetivo é fixação, não pressão). Quizzes de certificação: tempo limite pode ser aplicado se o negócio quiser simular pressão real de atendimento.

### 4.5 Embaralhamento
Ordem de perguntas e alternativas embaralhada a cada tentativa (estender o comportamento já existente nos games para todos os quizzes) — reduz decoreba de posição e cola entre colegas.

### 4.6 Revisão das respostas

**Alternativa em disputa:**
| Opção | Vantagem | Desvantagem |
|---|---|---|
| Gabarito completo (certo/errado + explicação) logo após a tentativa | Reforça aprendizado imediato | Facilita vazamento de gabarito entre colegas |
| Só certo/errado, gabarito liberado após aprovação/esgotamento de tentativas | Protege integridade do quiz | Frustra quem quer entender o erro na hora |

**Recomendação:** manter explicação imediata em quizzes de **conteúdo/aprendizado**; restringir revisão detalhada em quizzes de **certificação formal**, liberando só após aprovação final.

### 4.7 Atualização de perguntas
Editáveis a qualquer momento pelo Admin. Edição **não altera retroativamente** respostas já registradas — a resposta do usuário reflete a versão vigente no momento em que foi dada (o texto da alternativa escolhida deve ficar congelado no registro da resposta).

### 4.8 Comportamento quando uma pergunta muda
- Cosmética: nenhuma ação adicional.
- Conteúdo/gabarito relevante: tentativas antigas continuam válidas para certificações já emitidas (sem recálculo automático); admin pode, manualmente, invalidar tentativas anteriores a uma data se o erro for crítico — ação explícita, nunca automática.

---

## 5. CERTIFICAÇÕES

### 5.1 Critérios para conquistar
Concedida automaticamente quando **todos os checkpoints obrigatórios da trilha** estiverem concluídos — critério objetivo e automático; emissão manual excepcional permitida, sempre com justificativa registrada.

### 5.2 Critérios para perder (revogação)
Pode ser revogada (nunca deletada) em casos como fraude identificada ou decisão administrativa justificada. **Sempre manual e auditada** — nunca automática, dado o peso formal de um certificado.

### 5.3 Validade

**Alternativa em disputa:**
| Opção | Vantagem | Desvantagem |
|---|---|---|
| Permanente | Simples, reconhece o esforço de forma definitiva | Não garante conhecimento atualizado (produtos mudam) |
| Com validade (ex.: 12 meses), exigindo renovação | Garante atualização periódica | Gera atrito se o processo de renovação for pesado |

**Recomendação:** **12 meses** para certificações de produto (portfólio muda com frequência); **permanente** para certificações comportamentais/processo — critério definido por certificação, não regra única.

### 5.4 Renovação
Via quiz de recertificação (mesmo quiz final ou versão reduzida) — não exige refazer toda a trilha. Notificação automática ao colaborador e ao líder **30 dias antes do vencimento**.

### 5.5 Recertificação (por mudança de conteúdo crítico)
Só ocorre quando o admin sinaliza explicitamente a alteração como crítica (Seção 2.5). Usuários afetados são notificados e o certificado entra em estado "pendente de renovação" — não é revogado instantaneamente.

---

## 6. GAMIFICAÇÃO

### 6.1 XP
Soma de todos os lançamentos no livro-razão de pontos — nunca um campo fixo editado manualmente. Fontes: aprovação em quiz, conclusão de módulo, participação em game, badge/achievement, streak mantido, certificação emitida.

**Alternativa em disputa:**
| Opção | Vantagem | Desvantagem |
|---|---|---|
| XP fixo por ação | Simples de entender e balancear | Não diferencia dificuldade/importância do conteúdo |
| XP ponderado por dificuldade/relevância (configurável por item) | Reflete melhor o esforço/valor de cada conteúdo | Exige curadoria do admin |

**Recomendação:** XP ponderado com valor padrão pré-preenchido (ex.: 100 quiz de conteúdo, 200 quiz de certificação, 50 game), editável pelo admin. Tentativas repetidas do mesmo quiz **não geram XP repetido** — só na primeira aprovação.

### 6.2 Badges
Concedidos automaticamente por regra (ex.: "aprovar 3 quizzes de produto"). Uma vez conquistado, **permanente** — não é perdido por desligamento/reativação ou mudança de cargo.

### 6.3 Conquistas (achievements)
Mais narrativas/amplas que badges (ex.: "completou toda a Zona Corredor", "30 dias de streak"). Mesma regra de concessão automática e permanência.

### 6.4 Ranking
Sempre derivado do livro-razão de pontos (nunca editado manualmente). Escopos: geral, por loja, por cargo, por certificações, por engajamento, por velocidade de conclusão — recalculados periodicamente.

**Alternativa em disputa:**
| Opção | Vantagem | Desvantagem |
|---|---|---|
| Cumulativo desde o início | Recompensa histórico de esforço | Colaborador novo nunca alcança quem está há anos |
| Reiniciado por temporada | Todos competem "do zero" periodicamente, mais justo para novatos | Perde-se a noção de evolução contínua se não houver histórico paralelo |

**Recomendação:** **XP total acumulado** sempre visível como progressão pessoal (nunca reiniciado); **ranking competitivo por temporada** (ex.: trimestral), com snapshot de cada temporada preservado no histórico.

### 6.5 Streak
Dias consecutivos com atividade relevante de estudo (não apenas login). Quebra: perde o contador atual, mas o recorde histórico é preservado.

**Alternativa em disputa:**
| Opção | Vantagem | Desvantagem |
|---|---|---|
| Quebra imediata ao faltar um dia | Mais rigoroso, streak tem mais valor | Penaliza folgas/fins de semana/férias legítimas |
| Congelamento automático em fins de semana/feriados | Mais humano, reduz frustração | Mais complexo de comunicar/calcular |

**Recomendação:** pausar contagem em fins de semana/feriados — streak só quebra em dia útil sem atividade.

### 6.6 Medalhas
Marcam posição em ranking de temporada (1º/2º/3º lugar do período) — diferente de badge (mérito individual contínuo). Concedidas automaticamente ao fechar cada temporada.

### 6.7 Temporadas
Período fixo (recomendado trimestral) que reinicia o ranking competitivo e distribui medalhas de posição, sem afetar XP total, badges, conquistas ou certificações.

### 6.8 Níveis
Função direta do XP total (faixas configuráveis), sempre **calculada**, nunca armazenada como estado próprio, para nunca dessincronizar. Subida de nível é evento automático (pode disparar celebração visual).

### 6.9 Classes
Recomendação: **desacoplar Classe de progresso de conteúdo** e vincular à **certificação da zona correspondente** — a classe sobe quando o colaborador certifica a zona, não apenas quando consome o conteúdo sem validação. Dá peso real de competência comprovada à classe.

### 6.10 Mural de Atividades (Feed de Conquistas)
**Decisão confirmada:** o mural é **global** — aberto a todas as lojas da marca, não isolado por filial. É a exceção deliberada à regra de isolamento por loja (Seção 1): o objetivo aqui é criar senso de comunidade e emulação saudável entre lojas diferentes, não segmentar informação sensível.

- **Comportamento de exibição:** tipo notificação/timeline ao vivo — novas conquistas aparecem no topo do mural em tempo real, sem o usuário precisar atualizar a página (via Supabase Realtime).
- **Gatilhos automáticos** (sistema gera a mensagem sozinho, sem ação humana):
  - Conquista de badge (qualquer um: Explorer, Runner, Triathlete, Gabarito Garmin, Ritmo Constante).
  - Emissão de certificação.
  - Nota 100% na primeira tentativa de uma avaliação.
  - Marco de streak atingido (ex.: 5 dias seguidos).
- **Gatilho manual (Líder):** o líder seleciona um colaborador da própria equipe e uma mensagem semi-pronta de um pequeno conjunto de templates (ex.: "Vendas premium", "Metas batidas", "Destaques de atendimento", "Mestre da Objeção"). O líder **não digita texto livre** — reduz risco de mensagem inadequada e mantém o padrão visual/tom do mural. Líder só pode postar sobre colaboradores da(s) loja(s) sob sua gestão (mesma regra de escopo do dashboard, Seção 8).
- **Conteúdo:** texto puro com emoji, sem upload de mídia — mantém custo de armazenamento próximo de zero, decisão já validada no plano de expansão original.
- **Retenção:** mural não tem expiração automática por padrão; se o volume crescer muito, paginação/scroll infinito resolve no front sem precisar apagar histórico (mensagens antigas continuam sendo prova social válida).
- **Não gera XP:** o mural é reconhecimento social, não uma fonte adicional de pontuação — o XP já foi concedido pelo evento original (badge, certificação, etc.); postar no mural não duplica pontos.

---

## 7. DASHBOARD DO COLABORADOR

| Indicador | Cálculo | Frequência de atualização |
|---|---|---|
| Progresso da trilha atual | checkpoints concluídos / obrigatórios da zona/trilha em andamento | Tempo real |
| Continuar de onde parou | última lição tocada por data | Tempo real |
| XP total e nível | soma do livro-razão + faixa de nível | Tempo real |
| Streak atual | contador de dias consecutivos | Diário + tempo real ao concluir atividade do dia |
| Badges/conquistas | registros de concessão | Tempo real (no momento da concessão) |
| Certificados e validade | registros de certificação emitida | Tempo real na emissão; alerta 30 dias antes do vencimento |
| Histórico de quizzes | todas as tentativas | Tempo real |
| Histórico de games | todas as sessões | Tempo real |
| Posição no ranking | snapshot periódico | Recalculado periodicamente (ex.: a cada hora) — exibir "atualizado às Xh", não fingir tempo real |
| Comparação com a equipe | média da loja vs. individual | Mesma cadência do ranking |
| Evolução mensal | XP e módulos concluídos por mês | Diário |

---

## 8. DASHBOARD DO LÍDER

### Indicadores
Todos os do colaborador, agregados por loja/equipe, mais: taxa de conclusão de trilha por colaborador e média da equipe; taxa de aprovação em quizzes; perguntas com maior índice de erro por módulo; tempo médio de estudo; ranking interno da loja; colaboradores inativos (7+ dias); certificações vencendo nos próximos 30 dias.

### Filtros
Por loja (se o líder responde por mais de uma), por período, por trilha/módulo, por cargo, por status.

### Alertas automáticos
Inatividade prolongada (7+ dias); reprovação recorrente no mesmo quiz (2+ seguidas); certificação prestes a vencer; queda de engajamento da equipe mês a mês.

### Insights
Ex.: "Módulo X tem taxa de erro 40% acima da média — considere reforço presencial"; "Colaborador Y não acessa há 12 dias"; "Sua loja está no top 3 em engajamento este mês".

### Comparação entre equipes
Visível para líderes com múltiplas lojas ou para admin: ranking comparativo por loja (XP médio, taxa de aprovação, engajamento), sem expor dados individuais de colaboradores fora da gestão daquele líder.

### Mapa de Gaps de Conhecimento (BI)
Painel que consolida, por pergunta, a taxa de erro da Avaliação Trimestral **daquela loja especificamente** — funciona como um "farol": aponta ao líder exatamente onde a equipe está mais fraca em conhecimento, sem precisar revisar tentativa por tentativa manualmente. Requer rastreamento por pergunta (não só a nota final da avaliação) — ver Seção 5 (Certificações) e modelagem de `evaluation_answers`. Visível só para o líder da(s) loja(s) correspondente(s) e para o admin (visão consolidada de todas as lojas).

---

## 9. GESTÃO DE TREINAMENTOS (painel administrativo, sem código)

A gestora deve conseguir, 100% via painel:
- **Criar módulos/lições**: formulário estruturado (título, conteúdo, mídia via upload, ordem, obrigatoriedade, vínculo com zona/trilha).
- **Criar quizzes**: formulário de perguntas/alternativas com marcação de correta, explicação, nota de corte, tempo limite, embaralhamento on/off.
- **Publicar conteúdo**: alternância rascunho → publicado, com validação (não publica quiz sem pergunta, não publica trilha sem zona).
- **Agendar liberações**: data/hora futura de publicação automática — coordena lançamento com comunicação interna sem depender de ação manual na hora certa.
- **Acompanhar resultados**: analytics com os indicadores das Seções 7 e 8, exportável para relatórios.
- **Emitir certificados**: automático por regra, com opção de emissão manual excepcional sempre justificada.
- **Visualizar analytics**: visão executiva multi-loja/multi-trilha para decisões de currículo (ex.: quais módulos precisam de revisão de conteúdo).

---

## 10. EVENTOS AUTOMÁTICOS DA PLATAFORMA

1. Conclusão de lição
2. Conclusão de módulo (lições obrigatórias concluídas ou quiz do módulo aprovado)
3. Aprovação em quiz → concede XP, verifica badges/achievements
4. Reprovação em quiz → registra tentativa, alerta o líder se recorrente
5. Conclusão de zona → desbloqueia próxima zona ou libera zona de ordem livre
6. Conclusão de trilha completa → emite certificação automaticamente
7. Emissão de badge
8. Emissão de conquista (achievement)
9. Emissão de certificado → gera PDF, notifica colaborador e líder
10. Subida de nível → recalculada a partir do XP total
11. Desbloqueio de nova trilha/zona
12. Atualização de ranking/leaderboard (job periódico)
13. Fechamento de temporada → snapshot do ranking, distribuição de medalhas, reinício do placar
14. Quebra ou manutenção de streak (job diário, com pausa em fins de semana/feriados)
15. Envio de notificação de inatividade (7+ dias sem acesso)
16. Envio de alerta de vencimento de certificação (30 dias antes)
17. Publicação agendada de conteúdo
18. Bloqueio automático por tentativas de login falhas
19. Desbloqueio automático de conta bloqueada por tempo
20. Reavaliação de pré-requisitos após reativação de conta
21. Postagem automática no Mural de Atividades (badge, certificação, streak, nota 100%) — texto gerado pelo sistema, sem intervenção humana
22. Postagem manual no Mural de Atividades pelo líder (a partir de template pré-definido, nunca texto livre)

---

## Resumo das decisões que exigem validação do negócio antes da próxima etapa (Wireframes)

1. Quem pode cadastrar colaboradores: só Admin, ou Líder também? (recomendado: Líder cadastra só da própria loja)
2. ~~Recuperação de senha: migrar para e-mail real do colaborador?~~ — **decidido, ver item confirmado abaixo**
3. Tentativas de quiz: ilimitado geral + limitado (3) só para certificação final? (recomendado: sim)
4. Maior nota vs. última nota: maior nota para aprovação, última como referência de evolução? (recomendado: sim)
5. Validade de certificação: 12 meses para conteúdo de produto, permanente para comportamental? (recomendado: sim, configurável por certificação)
6. Ranking: XP total acumulado sempre visível + ranking competitivo por temporada trimestral? (recomendado: sim)
7. Streak: pausar em fins de semana/feriados? (recomendado: sim)
8. Classe: desacoplar de progresso de conteúdo e vincular à certificação da zona? (recomendado: sim)

**Decisões já confirmadas (plano de expansão, 2026-07-09):**
- E-mail real substitui o padrão fake `@proparts.internal`, **mas sem nenhum fluxo automático de e-mail do Supabase Auth** — troca de e-mail e recuperação de senha continuam 100% controladas por Admin/Líder via Admin API (ver Seção 1.4).
- Mural de Atividades é **global** entre todas as lojas da marca (não isolado por filial) — decisão de produto, aceita.
- Mural combina gatilhos automáticos (sistema) e manuais (líder, só por template pré-definido, nunca texto livre).
- Assistente de Vendas com IA (RAG/Gemini) fica **fora de escopo por enquanto** — não entra na modelagem até haver desenho técnico próprio e validação separada.

Com essas decisões confirmadas, o projeto está pronto para a próxima etapa — **Wireframes**.