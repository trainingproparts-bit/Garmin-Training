# UX da Plataforma — Garmin Training Hub
### Fase 4: Experiência do usuário (sem código, sem visual, sem cores/tipografia)

> Este documento assume como dados de entrada o que já foi aprovado nas Fases 2 e 3 (Regras de Negócio e Modelagem de Dados). Toda decisão de UX aqui é rastreável a uma regra de negócio específica — quando relevante, cito a seção correspondente entre colchetes, ex. `[RN 4.1]`.

---

## 0. Princípios que guiam toda decisão de tela

Antes de desenhar qualquer wireframe, fixo os critérios que vou usar para justificar cada escolha daqui pra frente — assim a justificativa de UX de cada tela não é opinião solta, é aplicação de um destes princípios:

1. **Regra dos 2 cliques para continuar estudando.** Da tela em que o colaborador estiver, "continuar de onde parei" deve estar acessível em no máximo 2 toques. É a ação mais frequente do sistema e a que mais afeta taxa de conclusão.
2. **Estado > navegação.** Sempre que possível, a tela já chega mostrando o próximo passo certo (não obriga o usuário a decidir "o que eu faço agora"). Reduz carga cognitiva, especialmente para o público de loja, que acessa entre atendimentos, com pouco tempo.
3. **Gamificação é consequência visível, não uma seção separada.** XP, badges e progresso aparecem embutidos no fluxo principal (dashboard, resultado de quiz, conclusão de módulo) — não como uma tela que o usuário precisa lembrar de visitar.
4. **Líder e Gestora nunca ficam "no escuro".** Toda ação de risco (colaborador travado, quiz reprovado 2x, certificação vencendo) gera alerta proativo — o sistema empurra a informação, o usuário não precisa caçar.
5. **Zero código para a Gestora, sempre.** Qualquer tela do painel administrativo que pareça exigir raciocínio técnico (JSON, IDs, regras condicionais) foi malsucedida nesta fase e deve voltar para revisão.
6. **Reversibilidade visível antes de ações destrutivas.** Bloquear usuário, revogar certificado, invalidar tentativa — toda ação com peso administrativo mostra a consequência antes de confirmar (`[RN 1.5, 5.2]`).
7. **Mobile-first para Colaborador e Líder; desktop-first para Gestora.** Colaborador acessa no chão de loja, entre atendimentos, provavelmente no celular ou num tablet compartilhado. Gestora trabalha em ciclos de criação de conteúdo, que pede tela grande. (Isso não é decisão visual — é decisão de **densidade de informação e profundidade de navegação** por tela.)

---

## 1. Perfis — objetivo, contexto e o que cada um teme mais

| Perfil | Objetivo central | Contexto de uso | Frequência | O que mais atrapalha esse perfil hoje |
|---|---|---|---|---|
| **Colaborador** | Progredir na trilha, ser aprovado, ser reconhecido | Loja, entre atendimentos, tempo curto e interrompido, possível PC compartilhado | Diário/quase-diário | Não lembrar onde parou; não saber se está indo bem; sentir que "estudar" é obrigação sem retorno visível |
| **Líder** | Saber se a equipe está evoluindo, sem precisar perguntar pessoa por pessoa | Loja ou celular, momentos de gestão (reunião semanal, 1:1) | Semanal, com picos reativos (alerta) | Descobrir tarde demais que alguém travou ou reprovou; não ter comparação objetiva entre colaboradores/lojas |
| **Gestora de Treinamentos** | Publicar e manter conteúdo relevante, com dado para decidir o que precisa de reforço | Escritório/home office, sessões longas e concentradas | Contínuo (criação) + periódico (analytics) | Depender de programador para qualquer mudança; não enxergar o impacto real do conteúdo (que módulo "não pega") |
| **Administrador Técnico** | Manter a plataforma no ar e configurada corretamente | Esporádico, reativo a incidente ou setup inicial | Raro | Ser interrompido para tarefas que são, na verdade, operação de conteúdo (não deveriam chegar até ele) |

**Decisão de UX que decorre disso:** a separação entre Gestora e Administrador Técnico precisa ser **radical** — se qualquer tarefa do dia a dia (criar módulo, publicar quiz, resetar senha de colaborador) cair no colo do Administrador Técnico, a divisão de papéis falhou. Por isso, praticamente toda a "Gestão de Usuários" (exceto configurações de infraestrutura) vive no painel da Gestora, não no do Administrador Técnico.

---

## 2. Mapa geral de telas

```
AUTENTICAÇÃO
 └─ Login → Primeiro Acesso (condicional) → Recuperação de Senha (alternativo)

COLABORADOR (mobile-first)
 └─ Dashboard (home) ─┬─ Minha Trilha ─┬─ Página do Módulo ─┬─ Página da Aula ─┬─ Quiz ─ Resultado do Quiz
                       │                │                    │                 └─ Avaliação Final ─ Resultado da Avaliação ─ Certificados
                       ├─ Ranking
                       ├─ Álbum
                       ├─ Games
                       ├─ Histórico de Aprendizado
                       ├─ Notificações
                       └─ Perfil

LÍDER (mobile + desktop)
 └─ Dashboard ─┬─ Minha Equipe ─ Perfil do Colaborador
               ├─ Comparativos
               ├─ Relatórios
               ├─ Analytics
               └─ Alertas

GESTORA (desktop-first)
 └─ Dashboard ─┬─ Biblioteca de Conteúdo ─┬─ Cadastro de Trilhas ─ Cadastro de Módulos ─ Editor de Conteúdo
               │                          ├─ Biblioteca de Componentes
               │                          └─ Biblioteca de Mídia
               ├─ Banco de Questões ─┬─ Cadastro de Quizzes
               │                     └─ Cadastro de Avaliações
               ├─ Gestão de Certificados
               ├─ Gestão de Badges
               ├─ Gestão de Games
               ├─ Gestão de Usuários
               ├─ Analytics ─ Insights
               └─ Configurações
```

---

## 3. AUTENTICAÇÃO

### 3.1 Login

| Atributo | Definição |
|---|---|
| **Objetivo** | Autenticar o mais rápido possível, sem fricção, mesmo em PC compartilhado de loja |
| **Usuário** | Todos os perfis |
| **Informações exibidas** | Campo usuário, campo senha, seletor de marca (se PC compartilhado atender Garmin e Shokz), link "esqueci minha senha", opção "acessar como convidado" |
| **Hierarquia visual** | 1) Campo usuário → 2) Campo senha → 3) Entrar (ação primária) → 4) Esqueci senha / Convidado (ações secundárias, discretas) |
| **Componentes** | Formulário de 2 campos, botão primário, 2 links secundários, seletor de marca (só aparece se multi-marca detectada no dispositivo) |
| **Ações principais** | Entrar; recuperar senha; entrar como convidado |
| **Fluxo de navegação** | Sucesso + `must_change_password=true` → **Primeiro Acesso**. Sucesso normal → **Dashboard**. Falha → mensagem de erro inline, sem reload de página. 5 falhas → mensagem de bloqueio temporário `[RN 1.5]` |
| **Justificativa de UX** | Um PC de loja é usado por várias pessoas ao longo do dia — o seletor de marca evita que o colaborador entre no ambiente errado antes mesmo de digitar a senha. A rota "convidado" fica visível mas secundária, pois é caso de uso pontual (representante Garmin em visita), não o caminho principal `[RN 1.2]`. |

### 3.2 Primeiro Acesso

| Atributo | Definição |
|---|---|
| **Objetivo** | Forçar troca de senha e reduzir abandono logo na entrada, com um onboarding curto |
| **Usuário** | Qualquer papel no primeiro login |
| **Informações exibidas** | Aviso de troca obrigatória; campos nova senha + confirmação; 2–3 telas de onboarding (o que é a trilha, o que é XP/badge) |
| **Hierarquia visual** | 1) Troca de senha (bloqueante) → 2) Onboarding (avançável, mas não pulável na primeira vez) → 3) Badge de boas-vindas (celebração) → 4) Dashboard |
| **Componentes** | Formulário de senha com validação em tempo real (8+ caracteres), carrossel de 2–3 cards de onboarding, tela de celebração de badge |
| **Ações principais** | Definir nova senha; avançar onboarding; seguir para o dashboard |
| **Fluxo de navegação** | Único ponto de entrada obrigatório antes do Dashboard na primeira vez. Não é acessível depois do primeiro login. |
| **Justificativa de UX** | `[RN 1.6]` recomenda onboarding curto e badge simbólico — trato isso como um funil de 3 passos e não como 3 telas soltas, porque cada passo a mais é oportunidade de abandono. O badge de boas-vindas fecha o onboarding com reforço positivo imediato, antes mesmo do colaborador ver qualquer conteúdo de treinamento. |

### 3.3 Recuperação de Senha

| Atributo | Definição |
|---|---|
| **Objetivo** | Devolver acesso sem depender só do admin, quando possível |
| **Usuário** | Todos |
| **Informações exibidas** | Campo de identificação (usuário ou e-mail real, se migrado — `[RN 1.4]`); mensagem de confirmação de envio; fallback "não recebeu? fale com seu líder/admin" |
| **Hierarquia visual** | 1) Identificação → 2) Confirmação de envio → 3) Fallback humano sempre visível, nunca escondido |
| **Componentes** | Campo único, botão de envio, bloco de fallback |
| **Ações principais** | Solicitar recuperação; contatar líder/admin |
| **Fluxo de navegação** | A partir do Login → retorna ao Login após conclusão |
| **Justificativa de UX** | Como a recomendação da RN é híbrida (autoatendimento por e-mail real, com fallback manual), a tela precisa deixar o fallback tão visível quanto o fluxo automático — nunca escondido num rodapé, porque parte da base ainda não terá e-mail real migrado. |

---

## 4. COLABORADOR

### 4.1 Dashboard (Home)

| Atributo | Definição |
|---|---|
| **Objetivo** | Responder em até 3 segundos: "onde eu parei" e "como estou indo", e me colocar de volta em ação com 1 toque |
| **Usuário** | Colaborador |
| **Informações exibidas** | Nome + avatar; card "Continuar de onde parei" (destaque máximo); progresso da trilha atual (%); XP total + nível; streak atual; posição no ranking (com "atualizado às Xh" — `[RN 7]`); badges recentes; alertas de certificação vencendo em 30 dias |
| **Hierarquia visual** | 1) Continuar de onde parei (maior destaque, topo) → 2) Progresso da trilha → 3) XP/nível/streak (faixa de status) → 4) Ranking resumido → 5) Badges recentes → 6) Alertas (se houver) |
| **Componentes** | Card de ação primária, barra de progresso, faixa de indicadores (XP/nível/streak), mini-ranking (top 3 + posição do usuário), carrossel de badges, banner de alerta |
| **Ações principais** | Continuar estudando (1 toque → Página da Aula certa); ver trilha completa; ver ranking completo; ver álbum |
| **Fluxo de navegação** | Ponto central pós-login. De qualquer outra tela do Colaborador, "Home" está sempre a 1 toque (ícone fixo na navegação). |
| **Justificativa de UX** | Aplica o Princípio 1 (2 cliques para continuar) da forma mais literal possível: 1 clique a partir do próprio login. O card de continuar não é "mais um item" — é a ação dominante da tela, porque é a que mais reduz abandono `[RN 7]`. |

### 4.2 Minha Trilha

| Atributo | Definição |
|---|---|
| **Objetivo** | Dar visão espacial do progresso (onde estou, o que falta, o que já venci) |
| **Usuário** | Colaborador |
| **Informações exibidas** | Zonas (Explorador → Corredor → Maratonista → Triatleta) com estado (concluída/atual/bloqueada); checkpoints dentro da zona atual com status individual; indicação clara de checkpoints obrigatórios vs. opcionais `[RN 3.2]`; zona de ordem livre ("Circuito de Desafios") sinalizada como não-sequencial `[RN 3.1]` |
| **Hierarquia visual** | 1) Zona atual expandida por padrão → 2) Checkpoint "próximo a fazer" com destaque → 3) Zonas futuras visíveis mas recolhidas (preview, não bloqueio visual escuro) → 4) Zonas concluídas colapsadas com selo |
| **Componentes** | Trilha vertical com nós, badge de obrigatório/opcional por nó, indicador de zona de ordem livre, barra de progresso por zona |
| **Ações principais** | Abrir módulo/checkpoint; ver o que falta para concluir a zona; ver o que falta para certificação da trilha inteira |
| **Fluxo de navegação** | Acessível pela navegação principal e pelo card "Continuar" do Dashboard. Abre **Página do Módulo** ao tocar num checkpoint. |
| **Justificativa de UX** | Mostrar zonas futuras como preview (não como "cadeado escuro" total) mantém motivação — a pessoa vê o caminho inteiro, o que reforça senso de progresso de longo prazo, alinhado ao princípio de "XP total sempre visível como progressão pessoal" `[RN 6.4]`. |

### 4.3 Página do Módulo

| Atributo | Definição |
|---|---|
| **Objetivo** | Mostrar o que compõe o módulo e guiar para a próxima lição/quiz pendente |
| **Usuário** | Colaborador |
| **Informações exibidas** | Título e descrição do módulo; lista de lições com status (concluída/atual/pendente); quiz do módulo (se houver) com status e nota de corte; obrigatoriedade de cada item `[RN 3.2]` |
| **Hierarquia visual** | 1) Próxima lição pendente destacada → 2) Lista completa de lições → 3) Quiz do módulo ao final da lista, com estado bloqueado até lições obrigatórias concluídas |
| **Componentes** | Lista/checklist de lições, indicador de progresso do módulo, card de quiz |
| **Ações principais** | Abrir próxima lição; abrir quiz (quando liberado); voltar para a trilha |
| **Fluxo de navegação** | Chega vindo de Minha Trilha ou Dashboard → leva a Página da Aula ou Quiz |
| **Justificativa de UX** | Nunca deixo a pessoa escolher "qual lição abrir" quando existe uma resposta óbvia (a próxima pendente) — reduz decisão, aplica Princípio 2. |

### 4.4 Página da Aula

| Atributo | Definição |
|---|---|
| **Objetivo** | Entregar o conteúdo com fricção mínima e registrar conclusão automaticamente |
| **Usuário** | Colaborador |
| **Informações exibidas** | Conteúdo da lição (montado pelos componentes reutilizáveis — Seção 7); posição na sequência ("Lição 2 de 4"); botão de avançar |
| **Hierarquia visual** | 1) Conteúdo → 2) Indicador de progresso da sequência → 3) Ação de avançar |
| **Componentes** | Área de conteúdo (renderiza os componentes do editor — banner, texto rico, vídeo, etc.), indicador de sequência, botão "Concluir e avançar" |
| **Ações principais** | Marcar como concluída / avançar; voltar |
| **Fluxo de navegação** | Ao concluir a última lição obrigatória, retorna à Página do Módulo já com o Quiz liberado — nunca deixa a pessoa "perdida" sem saber o próximo passo |
| **Justificativa de UX** | Conclusão automática ao chegar ao fim do conteúdo (sem exigir um clique extra de "marcar como lido" sempre que possível) reduz atrito — cada clique evitável aqui é 1 a menos multiplicado por 14 colaboradores × dezenas de lições. |

### 4.5 Quiz

| Atributo | Definição |
|---|---|
| **Objetivo** | Avaliar aprendizado com o mínimo de ansiedade desnecessária |
| **Usuário** | Colaborador |
| **Informações exibidas** | Pergunta atual + alternativas (ordem embaralhada `[RN 4.5]`); indicador "pergunta X de Y"; tempo limite (se aplicável, só em quiz de certificação `[RN 4.4]`); tentativas restantes (se for quiz de certificação, `[RN 4.1]`) |
| **Hierarquia visual** | 1) Pergunta → 2) Alternativas → 3) Indicador de progresso do quiz → 4) Timer (só quando existir) |
| **Componentes** | Card de pergunta, lista de alternativas selecionáveis, barra de progresso do quiz, timer condicional, contador de tentativas condicional |
| **Ações principais** | Selecionar resposta; avançar; finalizar quiz |
| **Fluxo de navegação** | Vem da Página do Módulo ou da Trilha → leva ao Resultado do Quiz |
| **Justificativa de UX** | Informações que geram pressão desnecessária (timer, tentativas restantes) só aparecem quando a regra de negócio realmente as ativa — quiz de conteúdo fica visualmente "mais leve" que quiz de certificação, reforçando a diferença de propósito entre os dois sem precisar de texto explicativo. |

### 4.6 Resultado do Quiz

| Atributo | Definição |
|---|---|
| **Objetivo** | Comunicar aprovação/reprovação com clareza e, se aprovado, celebrar o ganho (XP, badge, avanço) |
| **Usuário** | Colaborador |
| **Informações exibidas** | Nota obtida vs. nota de corte; aprovado/reprovado; XP ganho (só na primeira aprovação, `[RN 6.1]`); revisão de respostas — completa em quiz de conteúdo, restrita em quiz de certificação até aprovação final `[RN 4.6]`; próximo passo sugerido |
| **Hierarquia visual** | 1) Resultado (aprovado/reprovado) → 2) XP/celebração (se aplicável) → 3) Revisão de respostas → 4) Próximo passo |
| **Componentes** | Card de resultado, indicador de XP com animação de ganho, lista de revisão de respostas (condicional), botão de próximo passo |
| **Ações principais** | Ver revisão; tentar novamente (se reprovado e dentro do limite); avançar para o próximo módulo/checkpoint |
| **Fluxo de navegação** | Aprovado → volta à Página do Módulo (checkpoint desbloqueado) ou, se era o último obrigatório da zona, segue direto para a tela de conclusão de zona. Reprovado, dentro do limite → botão de nova tentativa. Reprovado, no limite (certificação) → mensagem "aguardando liberação do seu líder" `[RN 4.1]`. |
| **Justificativa de UX** | A celebração de XP só acontece na primeira aprovação, exatamente como a regra de negócio define — isso evita a incoerência de "ganhar troféu de novo" ao refazer o mesmo quiz, o que erodiria a credibilidade da gamificação. |

### 4.7 Avaliação Final

| Atributo | Definição |
|---|---|
| **Objetivo** | Sinalizar claramente que este é o momento de maior peso formal da trilha |
| **Usuário** | Colaborador |
| **Informações exibidas** | Aviso de que é avaliação de certificação (não apenas de conteúdo); tentativas restantes; nota de corte exigida; tempo limite (se configurado) |
| **Hierarquia visual** | 1) Aviso de contexto ("esta avaliação certifica você em X") → 2) Pergunta/alternativas → 3) Tentativas e tempo |
| **Componentes** | Banner de contexto, os mesmos componentes do Quiz, com estado visual "formal" |
| **Ações principais** | Iniciar; responder; finalizar |
| **Fluxo de navegação** | Chega ao concluir todos os checkpoints de conteúdo da trilha → leva ao Resultado da Avaliação |
| **Justificativa de UX** | Diferenciar visualmente da tela de Quiz comum evita o erro de o colaborador "não perceber" que está numa tentativa que conta pontos e limite — transparência sobre o peso da ação evita frustração por surpresa. |

### 4.8 Resultado da Avaliação

| Atributo | Definição |
|---|---|
| **Objetivo** | Comunicar o resultado mais importante da jornada — aprovação gera certificação `[RN 5.1]` |
| **Usuário** | Colaborador |
| **Informações exibidas** | Aprovado/reprovado; se aprovado: emissão automática de certificado, XP de certificação, possível subida de Classe `[RN 6.9]`; se reprovado: tentativas restantes ou aviso de liberação pelo líder |
| **Hierarquia visual** | 1) Resultado → 2) Certificado emitido (se aplicável, com celebração de maior destaque que quiz comum) → 3) Subida de nível/classe (se aplicável) → 4) Próximo passo |
| **Componentes** | Card de resultado "formal", card de certificado com CTA de visualizar/baixar, animação de subida de nível/classe |
| **Ações principais** | Ver/baixar certificado; continuar para a próxima zona; tentar novamente (se aplicável) |
| **Fluxo de navegação** | Aprovado → Certificados (ou próxima zona, se houver). Reprovado no limite → aviso de solicitação ao líder. |
| **Justificativa de UX** | Este é o pico emocional da jornada — a celebração aqui precisa ser proporcional ao peso real do evento (certificação formal), maior que a de um quiz de módulo comum, para que o sistema de reforço não fique "achatado" (tudo parecendo igualmente importante). |

### 4.9 Certificados

| Atributo | Definição |
|---|---|
| **Objetivo** | Reunir tudo que já foi conquistado formalmente e alertar sobre renovações |
| **Usuário** | Colaborador |
| **Informações exibidas** | Lista de certificados emitidos, com data, validade (12 meses ou permanente `[RN 5.3]`), status (válido / vencendo em 30 dias / vencido) |
| **Hierarquia visual** | 1) Certificados vencendo em breve (topo, com aviso) → 2) Certificados válidos → 3) Certificados permanentes/comportamentais |
| **Componentes** | Lista de cards de certificado, badge de status de validade, botão de download/visualização por item |
| **Ações principais** | Baixar/visualizar PDF; iniciar renovação (quando vencendo) |
| **Fluxo de navegação** | Acessível pela navegação principal e pelo Resultado da Avaliação. "Iniciar renovação" leva à Avaliação Final (versão de recertificação) `[RN 5.4]`. |
| **Justificativa de UX** | Ordenar por urgência de validade (não por data de emissão) transforma a tela de um "museu de conquistas passadas" em uma ferramenta de ação — quem tem certificado vencendo sabe exatamente o que fazer ao abrir a tela. |

### 4.10 Perfil

| Atributo | Definição |
|---|---|
| **Objetivo** | Gerenciar identidade pessoal e configurações da própria conta |
| **Usuário** | Colaborador |
| **Informações exibidas** | Nome, cargo, loja, avatar/emoji, frase pessoal; opção de troca de senha; resumo de XP/nível/classe |
| **Hierarquia visual** | 1) Identidade (avatar, nome, cargo, loja) → 2) Resumo de progresso → 3) Configurações de conta |
| **Componentes** | Card de identidade editável (avatar/emoji/frase), resumo de gamificação, formulário de troca de senha |
| **Ações principais** | Editar avatar/emoji/frase; trocar senha |
| **Fluxo de navegação** | Acessível pela navegação principal (geralmente ícone fixo, canto da tela) |
| **Justificativa de UX** | Unifico "perfil pessoal" e "conta" na mesma tela porque, para este público, são a mesma necessidade mental ("minhas coisas") — separar em duas telas obrigaria a pessoa a adivinhar onde está a troca de senha. |

### 4.11 Ranking

| Atributo | Definição |
|---|---|
| **Objetivo** | Mostrar posição competitiva de forma motivadora, sem desmotivar quem está no meio/fim da lista |
| **Usuário** | Colaborador |
| **Informações exibidas** | Ranking da temporada atual (competitivo, reinicia trimestralmente `[RN 6.7]`); XP total acumulado sempre visível à parte (nunca reinicia `[RN 6.4]`); filtros por escopo (geral, loja, cargo); horário da última atualização `[RN 7]` |
| **Hierarquia visual** | 1) Minha posição atual (sempre visível, mesmo se não estiver no topo, "fixada" na tela) → 2) Top 10 da temporada → 3) Filtros de escopo → 4) XP total histórico, separado visualmente do ranking de temporada |
| **Componentes** | Card fixo de posição própria, lista/tabela de ranking, seletor de filtro (chips), separação clara entre "temporada" e "histórico total" |
| **Ações principais** | Trocar escopo do ranking; ver histórico de temporadas passadas (medalhas) |
| **Fluxo de navegação** | Acessível pela navegação principal e por atalho no Dashboard |
| **Justificativa de UX** | Separar visualmente "ranking de temporada" (zera) de "XP total" (nunca zera) evita a confusão de "por que meu XP sumiu" ao fechar uma temporada — e fixar a posição própria evita que alguém no 40º lugar precise rolar a lista inteira para se encontrar `[RN 6.4]`. |

### 4.12 Álbum

| Atributo | Definição |
|---|---|
| **Objetivo** | Reforçar senso de equipe e identidade através da coleção de figurinhas dos colegas |
| **Usuário** | Colaborador |
| **Informações exibidas** | Cards dos colegas com classe RPG, atributos, loja; filtros por loja/classe |
| **Hierarquia visual** | 1) Filtros → 2) Grid de cards → 3) Modal detalhado ao selecionar um colega |
| **Componentes** | Filtros (chips), grid de cards, modal de detalhe |
| **Ações principais** | Filtrar; abrir card de um colega |
| **Fluxo de navegação** | Acessível pela navegação principal |
| **Justificativa de UX** | Mantém a mecânica social já validada no produto atual — o Álbum é o único espaço da plataforma cujo objetivo é vínculo social, não progresso individual, e por isso não compete por atenção com o dashboard de estudo. |

### 4.13 Games

| Atributo | Definição |
|---|---|
| **Objetivo** | Oferecer prática leve e opcional, sem a seriedade formal do quiz |
| **Usuário** | Colaborador |
| **Informações exibidas** | Grid de games disponíveis; melhor pontuação pessoal por game |
| **Hierarquia visual** | 1) Grid de games → 2) Pontuação pessoal por card |
| **Componentes** | Grid de cards de game, indicador de high score |
| **Ações principais** | Jogar; ver pontuação |
| **Fluxo de navegação** | Acessível pela navegação principal e pela zona "Circuito de Desafios" na Trilha |
| **Justificativa de UX** | Games vivem tanto na navegação principal quanto dentro da trilha (zona de ordem livre) porque servem dois momentos diferentes: "quero praticar agora, sem compromisso" e "estou navegando pela trilha e encontro um desafio no caminho". |

### 4.14 Histórico de Aprendizado

| Atributo | Definição |
|---|---|
| **Objetivo** | Dar transparência total sobre tudo que já foi feito (todas as tentativas, não só a última) `[RN 4.3, modelagem 16]` |
| **Usuário** | Colaborador |
| **Informações exibidas** | Linha do tempo de lições concluídas, tentativas de quiz (com nota de cada uma), sessões de game, evolução mensal de XP |
| **Hierarquia visual** | 1) Filtro de período → 2) Linha do tempo cronológica → 3) Gráfico simples de evolução mensal |
| **Componentes** | Filtro de período, lista cronológica agrupada por mês, gráfico de evolução |
| **Ações principais** | Filtrar por período/tipo de atividade; abrir detalhe de uma tentativa específica |
| **Fluxo de navegação** | Acessível pela navegação principal e pelo Perfil |
| **Justificativa de UX** | Como a regra de negócio guarda todas as tentativas (não sobrescreve), a tela precisa expor isso — não só para transparência, mas porque "ver minha evolução" é, junto ao streak, um dos gatilhos motivacionais mais fortes de LMS corporativo. |

### 4.15 Notificações

| Atributo | Definição |
|---|---|
| **Objetivo** | Centralizar avisos que hoje "se perdem" (certificação vencendo, badge conquistado, novo conteúdo liberado) |
| **Usuário** | Colaborador |
| **Informações exibidas** | Lista cronológica de eventos relevantes: badges/achievements conquistados, certificação vencendo em 30 dias `[RN 5.4]`, novo módulo/trilha liberado, fechamento de temporada e medalhas `[RN 6.7]` |
| **Hierarquia visual** | 1) Não lidas no topo → 2) Lidas, ordem cronológica reversa |
| **Componentes** | Lista de notificações com ícone por tipo de evento, indicador de não-lida, badge de contagem no ícone da navegação |
| **Ações principais** | Marcar como lida; tocar para ir direto à tela relevante (ex.: notificação de certificado vencendo → Certificados) |
| **Fluxo de navegação** | Acessível por ícone fixo na navegação (com contador); cada notificação leva à tela correspondente ao evento |
| **Justificativa de UX** | Cada tipo de notificação já tem uma tela "dona" no sistema — a Central de Notificações não deve duplicar informação, só **apontar** para ela. Isso evita criar uma segunda fonte de verdade para os mesmos dados. |

---

## 5. LÍDER

### 5.1 Dashboard

| Atributo | Definição |
|---|---|
| **Objetivo** | Responder em segundos: "minha equipe está bem ou preciso agir em algo agora" |
| **Usuário** | Líder |
| **Informações exibidas** | Alertas ativos (topo, sempre); indicadores agregados da(s) loja(s) sob gestão — taxa de conclusão, taxa de aprovação, tempo médio de estudo, ranking interno; seletor de loja (se responde por mais de uma, `[modelagem 1.5]`) |
| **Hierarquia visual** | 1) Alertas acionáveis (inatividade, reprovação recorrente, certificação vencendo) → 2) Indicadores agregados → 3) Ranking interno da loja → 4) Atalho para Minha Equipe |
| **Componentes** | Banner/lista de alertas priorizados, cards de indicador agregado, mini-ranking da loja, seletor de loja |
| **Ações principais** | Resolver/ver detalhe de um alerta; trocar loja em foco; ir para Minha Equipe |
| **Fluxo de navegação** | Ponto central pós-login do Líder. Alertas levam direto ao Perfil do Colaborador correspondente. |
| **Justificativa de UX** | Aplica o Princípio 4 (líder nunca no escuro): alertas ficam **acima** dos indicadores de rotina, porque a pergunta "o que eu preciso fazer hoje" é mais urgente que "como estamos indo em geral" `[RN 8 - Alertas automáticos]`. |

### 5.2 Minha Equipe

| Atributo | Definição |
|---|---|
| **Objetivo** | Visão em lista de todos os colaboradores sob gestão, com estado individual escaneável rapidamente |
| **Usuário** | Líder |
| **Informações exibidas** | Lista de colaboradores com: progresso da trilha, XP, streak, status de atividade (ativo/inativo há N dias), alerta pendente (se houver) |
| **Hierarquia visual** | 1) Colaboradores com alerta pendente (topo, sinalizados) → 2) Demais colaboradores, ordenáveis por progresso/XP/atividade |
| **Componentes** | Lista/tabela com filtros e ordenação, indicador visual de alerta por linha |
| **Ações principais** | Filtrar/ordenar; abrir Perfil do Colaborador |
| **Fluxo de navegação** | A partir do Dashboard → leva ao Perfil do Colaborador |
| **Justificativa de UX** | A lista funciona como "painel de triagem" — o líder deve conseguir escanear 14 pessoas em poucos segundos e saber exatamente quem precisa de atenção, sem abrir perfil por perfil. |

### 5.3 Perfil do Colaborador (visão do Líder)

| Atributo | Definição |
|---|---|
| **Objetivo** | Dar ao líder o mesmo nível de detalhe que o colaborador tem sobre si mesmo, mais contexto de gestão |
| **Usuário** | Líder |
| **Informações exibidas** | Progresso na trilha, histórico de quizzes/games, badges/certificações, tempo de estudo, comparação com a média da equipe |
| **Hierarquia visual** | 1) Identidade + status geral → 2) Progresso e histórico → 3) Comparação com a equipe |
| **Componentes** | Card de identidade, linha do tempo de atividade (reaproveita padrão do Histórico de Aprendizado do colaborador), gráfico comparativo simples |
| **Ações principais** | Ver histórico completo; (se necessário) liberar 4ª tentativa de quiz de certificação `[RN 4.1]` |
| **Fluxo de navegação** | A partir de Minha Equipe ou de um alerta no Dashboard |
| **Justificativa de UX** | Reaproveitar o mesmo padrão de exibição do Histórico de Aprendizado do próprio colaborador (mesma estrutura, dados diferentes) reduz custo de aprendizado do Líder, que também é, em geral, ex-colaborador do sistema. |

### 5.4 Comparativos

| Atributo | Definição |
|---|---|
| **Objetivo** | Comparar desempenho entre colaboradores ou entre lojas (para líder multi-loja), sem expor dados fora do escopo de gestão `[modelagem 11]` |
| **Usuário** | Líder |
| **Informações exibidas** | Gráfico comparativo por indicador (conclusão, aprovação, engajamento) entre colaboradores da própria equipe, ou entre lojas sob gestão |
| **Hierarquia visual** | 1) Seletor de indicador e escopo → 2) Gráfico comparativo → 3) Lista ordenada de suporte ao gráfico |
| **Componentes** | Seletor de indicador (chips), gráfico de barras/ranking, tabela de apoio |
| **Ações principais** | Trocar indicador; trocar escopo (colaborador x colaborador, loja x loja) |
| **Fluxo de navegação** | Acessível pela navegação principal do Líder |
| **Justificativa de UX** | Separar "Comparativos" de "Minha Equipe" evita sobrecarregar a lista de equipe com múltiplos gráficos — a lista serve para triagem rápida, o comparativo serve para uma decisão específica (ex.: preparar reunião mensal). |

### 5.5 Relatórios

| Atributo | Definição |
|---|---|
| **Objetivo** | Gerar documentos exportáveis para prestação de contas (ex.: reunião com Gestora ou Admin) `[RN 9]` |
| **Usuário** | Líder |
| **Informações exibidas** | Seleção de período, escopo (equipe/loja) e indicadores a incluir |
| **Hierarquia visual** | 1) Configuração do relatório → 2) Pré-visualização → 3) Exportar |
| **Componentes** | Formulário de configuração, área de pré-visualização, botão de exportação |
| **Ações principais** | Configurar; pré-visualizar; exportar |
| **Fluxo de navegação** | Acessível pela navegação principal do Líder |
| **Justificativa de UX** | Separar "gerar relatório" de "Analytics" (próxima tela) reconhece que são dois momentos de uso diferentes: Analytics é para explorar dados; Relatórios é para produzir um artefato final e formal a compartilhar. |

### 5.6 Analytics

| Atributo | Definição |
|---|---|
| **Objetivo** | Explorar livremente indicadores agregados da equipe, incluindo módulos com maior taxa de erro `[RN 8]` |
| **Usuário** | Líder |
| **Informações exibidas** | Taxa de conclusão/aprovação por módulo; perguntas com maior índice de erro; tempo médio de estudo; ranking interno; colaboradores inativos |
| **Hierarquia visual** | 1) Indicadores de maior risco (módulo com mais erro, colaboradores inativos) → 2) Indicadores gerais de saúde da equipe |
| **Componentes** | Cards de indicador, gráficos simples, listas ordenáveis |
| **Ações principais** | Explorar por filtro (loja/período/trilha/módulo/cargo/status) |
| **Fluxo de navegação** | Acessível pela navegação principal do Líder |
| **Justificativa de UX** | Priorizar visualmente os indicadores de risco sobre os de "tudo bem" segue o mesmo princípio do Dashboard — dado que não gera ação não deveria competir por atenção com o que gera. |

### 5.7 Alertas

| Atributo | Definição |
|---|---|
| **Objetivo** | Central única de tudo que exige atenção/ação do líder `[RN 8, RN 10]` |
| **Usuário** | Líder |
| **Informações exibidas** | Inatividade prolongada (7+ dias); reprovação recorrente (2+ seguidas); certificação vencendo em 30 dias; queda de engajamento mês a mês |
| **Hierarquia visual** | 1) Alertas mais urgentes (inatividade, reprovação recorrente) → 2) Alertas informativos (vencimento, tendência) |
| **Componentes** | Lista de alertas com ícone por tipo, ação sugerida por item |
| **Ações principais** | Resolver (ex.: liberar 4ª tentativa); ir ao perfil do colaborador; arquivar alerta |
| **Fluxo de navegação** | Acessível pela navegação principal e reflete os mesmos alertas que aparecem resumidos no Dashboard |
| **Justificativa de UX** | O Dashboard mostra um resumo dos alertas mais urgentes; esta tela é o "arquivo completo" — a duplicação parcial é intencional (resumo vs. lista completa), não redundância de informação. |

---

## 6. GESTORA DE TREINAMENTOS

### 6.1 Dashboard

| Atributo | Definição |
|---|---|
| **Objetivo** | Visão executiva multi-loja/multi-trilha para decidir onde focar esforço de conteúdo `[RN 9]` |
| **Usuário** | Gestora |
| **Informações exibidas** | Indicadores gerais (conclusão, aprovação, engajamento) agregados por marca/trilha; conteúdo com pior desempenho (maior taxa de erro); certificações emitidas no período; publicações agendadas pendentes |
| **Hierarquia visual** | 1) Conteúdo que precisa de revisão (maior taxa de erro) → 2) Indicadores gerais → 3) Agenda de publicações |
| **Componentes** | Cards de indicador executivo, lista de "conteúdo em risco", calendário/lista de publicações agendadas |
| **Ações principais** | Ir direto ao módulo/quiz problemático (Editor de Conteúdo); ver Analytics completo |
| **Fluxo de navegação** | Ponto central pós-login da Gestora |
| **Justificativa de UX** | O dashboard da Gestora é orientado a decisão de currículo, não a operação do dia a dia — por isso prioriza "o que está performando mal" antes de qualquer número de vaidade (total de usuários, total de módulos). |

### 6.2 Biblioteca de Conteúdo

| Atributo | Definição |
|---|---|
| **Objetivo** | Ponto único de busca/gestão de tudo que já existe (trilhas, zonas, módulos, lições) |
| **Usuário** | Gestora |
| **Informações exibidas** | Lista/grid de trilhas com status (rascunho/publicado), contagem de zonas/módulos, marca, data de última edição |
| **Hierarquia visual** | 1) Filtro por marca/status → 2) Grid de trilhas → 3) Drill-down em zonas → módulos → lições |
| **Componentes** | Filtros (chips), grid de cards de trilha, navegação em árvore (breadcrumb) para drill-down |
| **Ações principais** | Criar nova trilha; abrir trilha existente; publicar/despublicar |
| **Fluxo de navegação** | Leva a Cadastro de Trilhas (nova) ou ao Editor de Conteúdo (edição de módulo/lição existente) |
| **Justificativa de UX** | Uso de breadcrumb para navegar trilha → zona → módulo → lição em vez de telas isoladas evita que a Gestora "se perca" na profundidade da hierarquia de conteúdo — sempre sabe onde está e pode voltar em 1 clique. |

### 6.3 Cadastro de Trilhas

| Atributo | Definição |
|---|---|
| **Objetivo** | Criar/editar metadados da trilha (nome, marca, cargo vinculado, zonas) sem código `[RN 2.1]` |
| **Usuário** | Gestora |
| **Informações exibidas** | Nome, marca, cargo(s) vinculado(s), lista de zonas (com opção de marcar `free_order`), status rascunho/publicado |
| **Hierarquia visual** | 1) Metadados básicos → 2) Lista de zonas (reordenável) → 3) Ação de publicar (bloqueada até validação mínima, `[RN 2.2]`) |
| **Componentes** | Formulário estruturado, lista reordenável de zonas (drag-and-drop), toggle de publicação com validação inline |
| **Ações principais** | Salvar rascunho; adicionar/reordenar zona; publicar (com checagem automática de "toda trilha publicada precisa de ao menos 1 zona com 1 checkpoint válido") |
| **Fluxo de navegação** | A partir da Biblioteca de Conteúdo → leva ao Cadastro de Módulos dentro de uma zona |
| **Justificativa de UX** | O botão de publicar precisa ficar desabilitado com explicação clara do motivo (não só cinza sem contexto) — é a aplicação direta do Princípio 5 (zero código, mas também zero mistério sobre por que uma ação não está disponível). |

### 6.4 Cadastro de Módulos

| Atributo | Definição |
|---|---|
| **Objetivo** | Criar/editar módulo, associá-lo a um checkpoint de uma ou mais trilhas, sem duplicar conteúdo `[RN 3.2]` |
| **Usuário** | Gestora |
| **Informações exibidas** | Título, descrição, ordem dentro da zona, obrigatoriedade (por trilha/cargo — pode variar), lições vinculadas, quiz vinculado |
| **Hierarquia visual** | 1) Metadados do módulo → 2) Lista de lições (ordenável) → 3) Vínculo com trilhas/checkpoints (com obrigatoriedade configurável por vínculo) |
| **Componentes** | Formulário estruturado, lista ordenável de lições, tabela de vínculos "este módulo aparece em: Trilha X (obrigatório), Trilha Y (opcional)" |
| **Ações principais** | Adicionar lição (leva ao Editor de Conteúdo); vincular a outra trilha/checkpoint; salvar/publicar |
| **Fluxo de navegação** | A partir do Cadastro de Trilhas → leva ao Editor de Conteúdo (para montar cada lição) |
| **Justificativa de UX** | Expor explicitamente a tabela de vínculos ("este módulo está em quais trilhas, com qual obrigatoriedade") é essencial para que a Gestora não duplique módulo por engano — reaproveitamento de conteúdo só funciona se for visível, não implícito. |

### 6.5 Editor de Conteúdo

*(Detalhado com profundidade própria na Seção 7, por ser o núcleo operacional da Gestora.)*

### 6.6 Biblioteca de Componentes

| Atributo | Definição |
|---|---|
| **Objetivo** | Catálogo de componentes reutilizáveis disponíveis para montar lições, com pré-visualização |
| **Usuário** | Gestora |
| **Informações exibidas** | Grid de componentes disponíveis (Banner, Texto Rico, Destaque, Accordion, Card, Flip Card, Grid, Timeline, Comparativo, Vídeo, Galeria, Tabela, Quiz, Avaliação, Flashcards, Cenários, Slider, Calculadora, Checklist, Downloads); descrição curta de uso de cada um |
| **Hierarquia visual** | 1) Categorias de componente (conteúdo estático, interativo, avaliativo, mídia) → 2) Grid dentro de cada categoria |
| **Componentes** | Grid de cards com pré-visualização em miniatura, categorização por chip |
| **Ações principais** | Ver exemplo de uso; inserir componente diretamente no Editor de Conteúdo (se acessado a partir de lá) |
| **Fluxo de navegação** | Acessível de forma independente (referência) e embutida como painel lateral dentro do Editor de Conteúdo |
| **Justificativa de UX** | Categorizar os 20 componentes evita a "parede de ícones" que obriga a Gestora a ler nome por nome — agrupar por função (estático/interativo/avaliativo/mídia) espelha como ela pensa ao montar uma lição ("preciso de algo interativo aqui"). |

### 6.7 Biblioteca de Mídia

| Atributo | Definição |
|---|---|
| **Objetivo** | Gerenciar todos os arquivos (imagens, vídeos, PDFs) usados no conteúdo, num só lugar `[modelagem 13]` |
| **Usuário** | Gestora |
| **Informações exibidas** | Grid de arquivos com miniatura, tipo, tamanho, onde está sendo usado (lição/módulo) |
| **Hierarquia visual** | 1) Filtro por tipo/uso → 2) Grid de arquivos → 3) Detalhe de uso ao selecionar um item |
| **Componentes** | Área de upload (drag-and-drop), grid com miniatura, indicador "usado em: Módulo X" |
| **Ações principais** | Upload; substituir; remover (com aviso se estiver em uso ativo) |
| **Fluxo de navegação** | Acessível de forma independente e como seletor embutido no Editor de Conteúdo |
| **Justificativa de UX** | Mostrar "onde está sendo usado" antes de permitir exclusão evita quebra silenciosa de conteúdo publicado — é aplicação direta do Princípio 6 (reversibilidade/consequência visível antes de ação destrutiva). |

### 6.8 Banco de Questões

| Atributo | Definição |
|---|---|
| **Objetivo** | Repositório central de perguntas reutilizáveis entre quizzes |
| **Usuário** | Gestora |
| **Informações exibidas** | Lista de perguntas com tema/tag, quizzes onde é usada, taxa de erro histórica (se já usada) |
| **Hierarquia visual** | 1) Filtro por tema/tag → 2) Lista de perguntas → 3) Detalhe/edição de uma pergunta |
| **Componentes** | Filtros, lista/tabela, indicador de taxa de erro por pergunta (sinal visual de "pergunta problemática") |
| **Ações principais** | Criar pergunta; editar; ver em quais quizzes está; ver taxa de erro |
| **Fluxo de navegação** | Alimenta o Cadastro de Quizzes e o Cadastro de Avaliações |
| **Justificativa de UX** | Expor a taxa de erro **na própria pergunta** (não só em Analytics) coloca o dado de qualidade de conteúdo no exato lugar onde a ação de melhoria acontece — a Gestora não precisa ir a outra tela para saber que aquela pergunta está confusa. |

### 6.9 Cadastro de Quizzes

| Atributo | Definição |
|---|---|
| **Objetivo** | Montar quiz de conteúdo/módulo com as regras corretas de tentativas, nota de corte, tempo `[RN 4]` |
| **Usuário** | Gestora |
| **Informações exibidas** | Perguntas selecionadas (do Banco de Questões ou novas); nota de corte (padrão 70%); embaralhamento (sempre ativo, `[RN 4.5]`); tempo limite (opcional, recomendado desligado para quiz de conteúdo `[RN 4.4]`) |
| **Hierarquia visual** | 1) Metadados do quiz → 2) Lista de perguntas selecionadas (reordenável, mas embaralhado em runtime) → 3) Regras de aprovação |
| **Componentes** | Formulário estruturado, seletor de perguntas do banco, lista reordenável, campos de regra com valor padrão pré-preenchido |
| **Ações principais** | Adicionar pergunta do banco; criar pergunta nova; publicar |
| **Fluxo de navegação** | A partir do Cadastro de Módulos ou da Biblioteca de Conteúdo |
| **Justificativa de UX** | Valores padrão pré-preenchidos (70% de corte, embaralhamento ligado) seguem a recomendação de negócio e reduzem decisões repetitivas — a Gestora só precisa alterar quando o caso for excepcional, não configurar do zero toda vez. |

### 6.10 Cadastro de Avaliações

| Atributo | Definição |
|---|---|
| **Objetivo** | Montar avaliação final de certificação, com regras mais rígidas que o quiz comum `[RN 4.1, 4.4, 4.6]` |
| **Usuário** | Gestora |
| **Informações exibidas** | Mesmos campos do Cadastro de Quizzes, mais: limite de tentativas (padrão 3), liberação manual da 4ª tentativa, revisão restrita até aprovação final, vínculo direto com emissão de certificação |
| **Hierarquia visual** | 1) Metadados → 2) Perguntas → 3) Regras de certificação (destacadas visualmente como "de maior peso" que as regras de quiz comum) |
| **Componentes** | Mesmos do Cadastro de Quizzes, mais campos específicos de certificação, selo visual "Avaliação de Certificação" |
| **Ações principais** | Configurar regras de certificação; vincular à trilha/certificação correspondente; publicar |
| **Fluxo de navegação** | A partir do Cadastro de Trilhas (associada à trilha) |
| **Justificativa de UX** | Separar esta tela do Cadastro de Quizzes (em vez de um único formulário com "modo avançado") deixa claro, pela própria existência de uma tela dedicada, que este é um tipo de conteúdo com peso formal diferente — reduz risco de a Gestora configurar por engano uma certificação com regras de quiz casual. |

### 6.11 Gestão de Certificados

| Atributo | Definição |
|---|---|
| **Objetivo** | Acompanhar, emitir manualmente (exceção) e revogar certificados, sempre com justificativa `[RN 5.1, 5.2]` |
| **Usuário** | Gestora |
| **Informações exibidas** | Lista de certificados emitidos, por colaborador/trilha, com validade e status; pendentes de renovação (mudança crítica sinalizada, `[RN 5.5]`) |
| **Hierarquia visual** | 1) Pendentes de ação (renovação sinalizada, vencidos) → 2) Lista geral de certificados |
| **Componentes** | Lista/tabela filtrável, modal de emissão manual (com campo de justificativa obrigatório), modal de revogação (com campo de justificativa obrigatório e confirmação) |
| **Ações principais** | Emitir manualmente; revogar; marcar alteração de conteúdo como crítica (dispara renovação pendente, nunca revogação automática, `[RN 2.5]`) |
| **Fluxo de navegação** | Acessível pela navegação principal |
| **Justificativa de UX** | Todo campo de justificativa é obrigatório e não pode ser pulado — reforça na interface o que a regra de negócio já exige na lógica: emissão/revogação manual é exceção auditada, nunca ação trivial de um clique só. |

### 6.12 Gestão de Badges

| Atributo | Definição |
|---|---|
| **Objetivo** | Criar/editar regras de concessão automática de badges e achievements `[RN 6.2, 6.3]` |
| **Usuário** | Gestora |
| **Informações exibidas** | Lista de badges/achievements existentes, regra de concessão em linguagem estruturada (não código), quantidade de colaboradores que já conquistaram cada um |
| **Hierarquia visual** | 1) Lista de badges → 2) Editor de regra (formulário guiado, tipo "quando o colaborador [aprovar] [3] [quizzes de produto]") |
| **Componentes** | Lista de cards, formulário de regra com campos estruturados (ação, quantidade, escopo) em vez de campo de texto livre |
| **Ações principais** | Criar badge/achievement; editar regra; ver quantos já conquistaram |
| **Fluxo de navegação** | Acessível pela navegação principal |
| **Justificativa de UX** | Um formulário guiado por campos estruturados (ação + quantidade + escopo) em vez de um campo de "regra em texto livre" é o que garante, na prática, o "zero código" prometido pelo Princípio 5 — sem isso, a tela viraria um editor de regras técnico disfarçado. |

### 6.13 Gestão de Games

| Atributo | Definição |
|---|---|
| **Objetivo** | Cadastrar/editar games disponíveis e seus parâmetros de pontuação |
| **Usuário** | Gestora |
| **Informações exibidas** | Lista de games, marca vinculada, regras de pontuação, estatísticas de uso |
| **Hierarquia visual** | 1) Lista de games → 2) Configuração de cada um |
| **Componentes** | Lista de cards, formulário de configuração |
| **Ações principais** | Criar/editar game; publicar/despublicar |
| **Fluxo de navegação** | Acessível pela navegação principal |
| **Justificativa de UX** | Mantida como tela simples e de baixa frequência de uso — games têm ciclo de criação mais raro que módulos/quizzes, então não competem por destaque na navegação principal da Gestora. |

### 6.14 Gestão de Usuários

| Atributo | Definição |
|---|---|
| **Objetivo** | Cadastrar, bloquear, transferir de loja/cargo, desligar e reativar colaboradores/líderes `[RN 1]` |
| **Usuário** | Gestora (e, por delegação de negócio, Líder para cadastro de colaborador da própria loja — `[RN 1.1]`, decisão pendente de confirmação do negócio) |
| **Informações exibidas** | Lista de usuários com status (ativo/inativo/bloqueado), loja, cargo, papel; histórico de auditoria de bloqueios/mudanças `[RN 1.5, 1.7, 1.8]` |
| **Hierarquia visual** | 1) Filtro por status/loja/papel → 2) Lista de usuários → 3) Ficha individual com ações e histórico de auditoria |
| **Componentes** | Lista/tabela filtrável, formulário de cadastro, modal de ação (bloquear/desbloquear/transferir/desligar/reativar) sempre com confirmação e, quando aplicável, motivo obrigatório |
| **Ações principais** | Cadastrar; bloquear/desbloquear; transferir loja/cargo; desligar (soft delete); reativar |
| **Fluxo de navegação** | Acessível pela navegação principal |
| **Justificativa de UX** | Toda ação de mudança de estado do usuário (bloquear, desligar) exige confirmação com resumo da consequência ("colaborador mantém XP e histórico, mas perde acesso") — aplica o Princípio 6 rigorosamente, já que são as ações de maior risco de toda a plataforma. |

### 6.15 Analytics (Gestora)

| Atributo | Definição |
|---|---|
| **Objetivo** | Visão executiva multi-loja/multi-trilha para decisão de currículo `[RN 9]` |
| **Usuário** | Gestora |
| **Informações exibidas** | Todos os indicadores do Líder, agregados globalmente; comparação entre lojas/marcas; taxa de erro por módulo/pergunta em toda a base |
| **Hierarquia visual** | 1) Indicadores de risco de conteúdo → 2) Comparação entre lojas/marcas → 3) Indicadores gerais |
| **Componentes** | Cards executivos, gráficos comparativos, tabelas exportáveis |
| **Ações principais** | Filtrar; exportar; ir direto ao Editor de Conteúdo a partir de um item problemático |
| **Fluxo de navegação** | Acessível pela navegação principal; leva a Insights e ao Editor de Conteúdo |
| **Justificativa de UX** | O link direto "ver módulo problemático → editar" fecha o ciclo entre dado e ação — sem isso, Analytics vira um relatório que ninguém usa para agir, só para observar. |

### 6.16 Insights

| Atributo | Definição |
|---|---|
| **Objetivo** | Traduzir dado bruto em recomendação de ação em linguagem natural `[RN 8 - Insights]` |
| **Usuário** | Gestora (e Líder, versão com escopo da própria equipe) |
| **Informações exibidas** | Frases geradas a partir dos dados: "Módulo X tem taxa de erro 40% acima da média"; "Loja Y está no top 3 em engajamento este mês" |
| **Hierarquia visual** | 1) Insights de risco/urgência → 2) Insights positivos/reconhecimento |
| **Componentes** | Lista de cards de insight, cada um com link direto para a tela de ação correspondente |
| **Ações principais** | Ir à ação sugerida (editar módulo, parabenizar loja, revisar pergunta) |
| **Fluxo de navegação** | Acessível pela navegação principal e como bloco embutido no Dashboard |
| **Justificativa de UX** | Insights só têm valor se cada um tiver uma ação de 1 clique associada — um insight sem link de ação é apenas mais um texto que a Gestora precisa interpretar sozinha, o que contraria o propósito da tela. |

### 6.17 Configurações

| Atributo | Definição |
|---|---|
| **Objetivo** | Ajustes operacionais que a Gestora controla sem depender do Administrador Técnico (ex.: nota de corte padrão, duração padrão de validade de certificação, regras de streak) |
| **Usuário** | Gestora |
| **Informações exibidas** | Parâmetros globais configuráveis por marca (nota de corte padrão, validade padrão por tipo de certificação, XP padrão por tipo de ação `[RN 6.1]`, duração de temporada `[RN 6.7]`) |
| **Hierarquia visual** | 1) Parâmetros mais usados (nota de corte, XP padrão) → 2) Parâmetros de gamificação (temporada, streak) |
| **Componentes** | Formulário estruturado por seção, com valor padrão sugerido e explicação curta do efeito de cada campo |
| **Ações principais** | Ajustar parâmetro; salvar |
| **Fluxo de navegação** | Acessível pela navegação principal |
| **Justificativa de UX** | Esta tela é a linha que separa "Gestora" de "Administrador Técnico": tudo aqui é regra de negócio parametrizável (nunca infraestrutura/segurança), reforçando o Princípio 5 mesmo nas configurações mais "avançadas" que a Gestora toca. |

---

## 7. Editor de Conteúdo — a experiência de montar um módulo sem código

Esta é a tela mais crítica da Gestora — se ela não for intuitiva, toda a promessa de "operar sem programador" desmorona. Por isso trato como um fluxo próprio, não como "mais uma tela".

### 7.1 Objetivo
Permitir que a Gestora monte uma lição inteira (banner, texto, vídeo, quiz embutido, etc.) arrastando/inserindo componentes prontos, na ordem que quiser, sem nunca ver ou editar código.

### 7.2 Modelo mental proposto: "linha de montagem vertical"
A lição é representada como uma sequência vertical de blocos empilhados — cada bloco é um componente da Biblioteca de Componentes (Seção 6.6). A Gestora:
1. Escolhe um componente na barra lateral (categorizada: estático / interativo / avaliativo / mídia).
2. Insere no ponto desejado da sequência (entre blocos existentes ou no fim).
3. Preenche os campos daquele componente num painel de propriedades (ex.: para um Flip Card: "frente", "verso"; para uma Timeline: lista de eventos com data e descrição).
4. Reordena blocos livremente (arrastar para cima/baixo).
5. Pré-visualiza a lição exatamente como o colaborador vai vê-la, a qualquer momento, sem sair da tela de edição.

### 7.3 Estrutura da tela

| Atributo | Definição |
|---|---|
| **Objetivo** | Montagem visual de lições/módulos com componentes reutilizáveis, sem código |
| **Usuário** | Gestora |
| **Informações exibidas** | Sequência de blocos já inseridos (miniatura de cada um); painel de propriedades do bloco selecionado; barra lateral de componentes disponíveis; estado de publicação (rascunho/publicado) |
| **Hierarquia visual** | 1) Sequência central de blocos (foco principal) → 2) Painel de propriedades do bloco ativo (lateral, contextual) → 3) Barra de componentes disponíveis (lateral, para inserir novo bloco) → 4) Pré-visualização (acesso a 1 clique, tela cheia) |
| **Componentes** | Lista vertical reordenável de blocos, painel de propriedades dinâmico (muda conforme o tipo de bloco selecionado), barra de inserção categorizada, botão de pré-visualização, botão de salvar/publicar |
| **Ações principais** | Inserir bloco; editar propriedades do bloco; reordenar; excluir bloco; pré-visualizar; salvar rascunho; publicar |
| **Fluxo de navegação** | Chega a partir do Cadastro de Módulos (nova lição) ou da Biblioteca de Conteúdo (edição de lição existente) → publicar retorna ao Cadastro de Módulos com a lição marcada como concluída |
| **Justificativa de UX** | O painel de propriedades ser **contextual** (muda conforme o bloco selecionado, em vez de um formulário gigante único) é o que torna 20 tipos de componente gerenciáveis sem sobrecarga — a Gestora nunca vê campos de "Calculadora" quando está editando um "Banner". A pré-visualização a 1 clique fecha o loop de confiança: ela precisa **ver** o resultado antes de publicar para uma equipe inteira, sem depender de "confiar que ficou certo". |

### 7.4 Regras de UX específicas do editor
- **Nunca perder trabalho:** salvamento automático de rascunho a cada alteração relevante (a Gestora não deve temer perder 40 minutos de montagem por falha de conexão).
- **Validação de publicação:** publicar só é permitido com aviso claro do que falta (ex.: "Quiz sem pergunta cadastrada", já previsto na regra de negócio `[RN 9]`) — nunca um erro genérico.
- **Reuso visível:** ao inserir mídia, o seletor já mostra arquivos existentes na Biblioteca de Mídia antes de oferecer novo upload — evita duplicação de arquivos.
- **Edição não quebra histórico:** ao editar um componente do tipo Quiz/Avaliação dentro do editor, o sistema pergunta explicitamente "esta alteração invalida certificados já emitidos?" — replicando na interface a decisão humana exigida pela regra de negócio `[RN 2.5]`, nunca decidindo isso sozinho.

---

## 8. Fluxos completos

### 8.1 Fluxo completo do Colaborador

```
Login
  │
  ├─(1º acesso)→ Primeiro Acesso → Badge de boas-vindas ─┐
  │                                                        │
  └─(acesso normal)──────────────────────────────────────→ Dashboard
                                                              │
                          ┌───────────────────────────────────┼───────────────────────────────┐
                          │                                   │                                │
                    "Continuar"                          Navegação                        Notificação
                          │                                   │                                │
                          ▼                                   ▼                                ▼
                  Página do Módulo/Aula              Minha Trilha / Ranking /           Tela correspondente
                          │                          Álbum / Games / Histórico /        ao evento (ex.:
                          ▼                          Certificados / Perfil              Certificados)
                       Quiz
                          │
                          ▼
                 Resultado do Quiz
                    │           │
               (aprovado)   (reprovado)
                    │           │
                    ▼           └──→ nova tentativa (se dentro do limite) → Quiz
        próximo checkpoint /
        zona concluída
                    │
        (se era o último checkpoint da trilha)
                    ▼
             Avaliação Final
                    │
          Resultado da Avaliação
                    │
              (aprovado) ──→ Certificado emitido → Certificados
                    │
             (reprovado, no limite) ──→ aviso "aguardando liberação do líder"
```

### 8.2 Fluxo completo do Líder

```
Login → Dashboard (alertas + indicadores agregados)
              │
   ┌──────────┼───────────────┬──────────────┬──────────────┐
   │          │               │              │              │
Alerta    Minha Equipe   Comparativos    Relatórios      Analytics
   │          │
   ▼          ▼
Perfil do Colaborador (histórico completo, comparação com a equipe)
   │
   └──(se aplicável)→ liberar 4ª tentativa de avaliação → volta ao Perfil do Colaborador
```

### 8.3 Fluxo completo da Gestora

```
Login → Dashboard (conteúdo em risco + indicadores + publicações agendadas)
              │
   ┌──────────┼───────────────────┬─────────────────┬───────────────┬──────────────┐
   │          │                   │                 │               │              │
Biblioteca  Banco de          Gestão de         Gestão de      Gestão de      Analytics/
de Conteúdo Questões          Certificados      Usuários       Badges/Games   Insights
   │          │
   ▼          ▼
Cadastro de   Cadastro de Quizzes /
Trilhas       Cadastro de Avaliações
   │
   ▼
Cadastro de Módulos
   │
   ▼
Editor de Conteúdo (monta lições com componentes reutilizáveis)
   │
   ▼
Pré-visualização → Publicar (com validação) → volta à Biblioteca de Conteúdo
```

---

## 9. Revisão final

**Existe alguma tela importante faltando?**
Sim, três lacunas que identifiquei ao desenhar os fluxos:
- **Tela de "Central de Ajuda/Como funciona"** para o Colaborador — hoje o conhecimento sobre XP/badges/streak vive só no onboarding do Primeiro Acesso; sem um lugar de consulta permanente, quem esquece a regra (ex.: "por que meu streak zerou?") não tem onde checar sem perguntar ao líder. **Adicionada** como tela leve, acessível pelo Perfil.
- **Tela de "Gestão de Trilhas por Cargo"** para o Admin/Gestora — a regra de negócio prevê que mudança de cargo pode mudar a trilha obrigatória `[RN 1.8]`, mas não havia tela explícita para configurar qual cargo exige qual trilha. **Adicionada** como sub-tela dentro de Cadastro de Trilhas (vínculo de cargo já estava nos campos, mas faltava a visão "por cargo, quais trilhas são obrigatórias").
- **Tela de "Auditoria/Log de Ações"** para o Admin Técnico (não Gestora) — bloqueios, desligamentos, revogações de certificado e emissões manuais precisam de um registro consultável `[RN 1.5, 5.2]`. Como é uma tela técnica de conformidade, mantenho fora do escopo operacional da Gestora e a atribuo ao Administrador Técnico.

**Existe algum fluxo confuso?**
Um ponto de atenção: o fluxo de **recertificação por mudança crítica de conteúdo** `[RN 5.5]` cruza três perfis (Gestora sinaliza → sistema notifica → Colaborador vê certificado "pendente de renovação" → Líder é alertado). Resolvi isso garantindo que cada perfil veja o mesmo evento com o vocabulário certo para seu contexto: a Gestora vê "alteração crítica confirmada"; o Colaborador vê "certificado pendente de renovação" na tela de Certificados; o Líder vê o mesmo evento como um item em Alertas. Não é uma tela nova — é consistência de rótulo entre telas já desenhadas.

**Existe alguma tela desnecessária?**
Considerei mesclar "Relatórios" e "Analytics" do Líder em uma única tela, já que compartilham dados. Optei por manter separadas porque servem intenções diferentes (explorar vs. exportar/formalizar) — mas é o ponto do desenho onde há maior risco de redundância percebida, e recomendo validar com o Líder real se, na prática, ele sente necessidade de uma tela de "exportar" separada ou se um botão de exportar dentro de Analytics já resolveria.

**Existe alguma oportunidade de reduzir cliques?**
Sim, incorporadas ao desenho: (1) o Dashboard do Colaborador leva a "continuar de onde parou" em 1 clique a partir do login; (2) o seletor de mídia no Editor de Conteúdo mostra arquivos já existentes antes de pedir upload; (3) cada Insight já carrega um link de ação direta, em vez de só descrever o problema; (4) notificações levam direto à tela relevante, nunca a uma central genérica que exige nova navegação.

**Existe alguma funcionalidade típica de LMS corporativo que deveria ser adicionada?**
Três que vi em Docebo/360Learning/Coursera Business e que valem avaliação do negócio antes da próxima fase:
- **Trilhas de aprendizado social/peer learning** (colega recomenda um módulo a outro) — se encaixaria bem no espírito do Álbum, mas é funcionalidade nova, não estava nas regras de negócio aprovadas.
- **Calendário de treinamentos presenciais integrado** — a Gestora já faz visitas presenciais estruturadas; integrar isso à plataforma (em vez de ficar só na rotina externa) fecharia o ciclo online + presencial.
- **Modo offline/sincronização posterior** — comum em LMS de rede de varejo com conectividade instável em loja; vale avaliar se é dor real das duas lojas atuais antes de priorizar.

Nenhuma das três foi incorporada aos wireframes acima por não constar nas regras de negócio aprovadas — fica registrado aqui como sugestão para validação do negócio, não como decisão já tomada.

---

Com isso, a experiência está desenhada tela a tela, perfil a perfil, com wireframe estrutural e justificativa de UX rastreável às regras de negócio e à modelagem de dados já aprovadas. Pronta para a próxima etapa — **decisões visuais (Fase 5): hierarquia de cores, tipografia e componentes de interface**, quando então entramos em HTML/CSS.
