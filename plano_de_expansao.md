Relatório de Expansão: Ecossistema Garmin LMS + BI

1\. Segurança e Infraestrutura de Lojas

Isolamento por Filiais: Criação da tabela stores e vínculo obrigatório de cada perfil a um store\_id.



Blindagem de Perfis via RLS (Supabase): Usuários comuns (Vendedores) alteram apenas foto e nome. Cargo, loja e pontuação são totalmente bloqueados para edição própria.



2\. Mural de Atividades Recentes

Banco de Mensagens: Tabela dedicada no Supabase para armazenar os logs de conquistas em formato de texto puro (peso zero no banco).



Gatilhos Híbridos:



Automáticos: Disparados por eventos do sistema (conquista de medalhas).



Manuais (Líderes): Mensagens semi-prontas enviadas pelo painel da liderança (Vendas premium, Metas batidas, Destaques de atendimento).



3\. Business Intelligence (Análise de Gaps de Conhecimento)

Rastreamento Granular: Criação da tabela evaluation\_answers para registrar acertos e erros questão por questão em cada tentativa.



View de Inteligência (vw\_store\_knowledge\_gaps): Uma view SQL protegida por RLS que consolida e calcula automaticamente quais são as perguntas mais erradas daquela loja específica, servindo como um "farol" de treinamento para o Líder.



4\. Assistente de Vendas Inteligente (Gemini API)

Arquitetura RAG: Manuais técnicos, tabelas comparativas e argumentos de objeções armazenados em texto no Supabase. O banco filtra o conteúdo relevante e envia apenas o trecho exato para a IA responder.



Custo Zero de IA: Implementação via API do Gemini 1.5 Flash através do plano gratuito do Google AI Studio (limite de até 1.500 requisições diárias), sem necessidade de plano premium.



Trava de Segurança: Configuração global gerenciada pelo Admin para limitar a quantidade de perguntas diárias por vendedor.



5\. Sistema de Gamificação (Badges baseados em Emojis)

Economia total de espaço (puro texto) usando emojis nativos para representação visual rápida:



🧭 Explorer (Automático): Conclusão do Módulo 1.



Mural: "{vendedor} desbravou o território inicial e conquistou o badge Explorer! 🧭"



🏃‍♂️ Runner (Automático): Conclusão do Módulo 2.



Mural: "{vendedor} aumentou o ritmo e acabou de se tornar um Runner! 🏃‍♂️"



🏊‍♂️ Triathlete (Automático): Conclusão do Módulo 3 (Nível Máximo).



Mural: "{vendedor} superou todos os limites e alcançou o topo: agora é um Triathlete! 🏊‍♂️🚴‍♂️🏃‍♂️"



🎯 Gabarito Garmin (Automático): Nota 100% na primeira tentativa de qualquer avaliação.



Mural: "{vendedor} cravou a nota máxima no teste de produtos e ganhou o badge Gabarito Garmin! 🎯"



🔥 Ritmo Constante (Automático): Acessar e completar lições por 5 dias seguidos.



Mural: "{vendedor} está com foco total! Completou 5 dias seguidos de estudos e garantiu o badge Ritmo Constante! 🔥"



💎 Mestre da Objeção (Manual do Líder): Concedido ao vendedor que der um show contornando uma venda complexa.



Mural: "{vendedor} contornou todas as objeções no balcão e garantiu o badge Mestre da Objeção! 💎"



🏢 Ranking Interlojas: Comparativo de engajamento e média de acertos entre as filiais no painel do Admin/Líder.



6\. UX de Navegação (Menu Dropdown do Avatar)

Interface limpa no canto superior direito da tela que injeta opções dinamicamente com base nas travas de cargo (Roles):



Vendedor: Perfil básico e Sair.



Líder de Loja: Dashboard (Gráficos locais), Relatórios (Foco na View de Gaps/Erros) e Equipe (Gestão dos vendedores locais e Mural).



Super Admin ("Modo Deus"): Visão macro de todas as lojas do país, alteração de cargos de qualquer usuário, gerenciador de conteúdo (aulas e questões), alimentação de manuais da IA e travas de orçamento do sistema.

