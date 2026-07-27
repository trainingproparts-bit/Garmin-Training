-- 110_refaz_ecossistema_acessorios.sql
-- Reescreve do zero o modulo "Ecossistema de Acessorios: Sensores, Carregadores
-- e Pulseiras" (Zona Triatleta), corrigindo erros tecnicos, removendo conteudo
-- que a loja nao vende e aprofundando o conteudo pedagogico, conforme spec do
-- usuario:
--   1. Remove todas as mencoes ao sensor Tempe e a licao "Running Power".
--   2. Consolida TODO o conteudo de HRM (200 e 600) em uma unica licao central,
--      com o diferencial de armazenamento offline debaixo d'agua bem explicado.
--   3. Corrige o Forerunner 970: ele NAO vem com QuickFit nativo, vem de
--      fabrica com sistema Watchband (pulseira presa por pino). Ensina o
--      procedimento real de adaptacao pra usar pulseira QuickFit de 22mm.
--   4. Aprofunda o sistema de pulseiras (QuickFit x Quick Release x Watchband)
--      e o guia de materiais (Silicone, Nylon/UltraFit, Couro, Metal).
--   5. Carregadores: mantem USB-A x USB-C e acrescenta cuidados de conservacao
--      dos contatos eletricos traseiros contra suor e oxidacao.
--
-- Estrutura final: exatamente 5 licoes (de 7), reaproveitando os IDs das 5
-- licoes mantidas (UPDATE in place, preserva historico) e removendo as 2
-- licoes que saem do modulo (Running Power e a antiga licao de "escolha de
-- pulseira", cujo conteudo foi fundido na nova licao 3).

-- ============================================================
-- 1. Licao 1 (order_index 0) — Sensores Cardiacos: HRM 200 e HRM 600
--    consolidados numa unica licao central sobre cintas e dinamica de corrida.
-- ============================================================
update lessons
set
  title = 'Sensores Cardíacos: HRM 200 e HRM 600 na Dinâmica de Corrida',
  order_index = 0,
  body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<p>A loja trabalha com exatamente duas cintas cardíacas: <strong>HRM 200</strong> (entrada) e <strong>HRM 600</strong> (topo de linha). Esta lição junta tudo sobre as duas num só lugar, porque na prática a decisão de venda é sempre a mesma pergunta: o cliente só quer frequência cardíaca precisa no peito, ou quer dados avançados de corrida e resistência real à natação?</p>"},
  {"type":"tabela","headers":["Recurso","HRM 200","HRM 600"],"rows":[
    ["Frequência cardíaca + HRV","Sim","Sim"],
    ["Dinâmica de Corrida completa","Não","Sim"],
    ["Alimenta a Potência de Corrida no pulso","Não","Sim"],
    ["Armazenamento offline debaixo d'água","Não","Sim"],
    ["Gravação autônoma sem relógio/celular por perto","Não","Até 24h, em mais de 18 modalidades"],
    ["Transmissão","ANT+ e Bluetooth","ANT+ e Bluetooth ao mesmo tempo"],
    ["Perfil de cliente","Quer só FC precisa, custo menor","Corredor sério que quer dados avançados e resistência real à natação"]
  ]},
  {"type":"texto_rico","html":"<p>O HRM 600 calcula a <strong>Dinâmica de Corrida</strong> completa: cadência, comprimento de passada, oscilação vertical, proporção vertical, tempo de contato com o solo e equilíbrio do tempo de contato, além da métrica exclusiva <strong>Step Speed Loss</strong> (perda de velocidade por passada). Ele também alimenta a <strong>Potência de Corrida</strong> exibida no pulso — a Garmin não vende um footpod dedicado só pra isso, a potência é calculada combinando o acelerômetro do relógio com os dados do HRM 600.</p>"},
  {"type":"banner","tone":"info","text":"O diferencial real do HRM 600 é o armazenamento offline debaixo d'água: como o sinal ANT+/Bluetooth não atravessa a água, a cinta guarda os dados internamente durante a natação e só sincroniza com o relógio depois que o nado termina. Some a isso a gravação autônoma de até 24h sem relógio nem celular por perto, em mais de 18 modalidades — nenhuma cinta de entrada como a HRM 200 faz isso."}
]}
$j$::jsonb
where id = '8ef170f6-2ccc-475b-9fc4-f236cedfc023';

-- ============================================================
-- 2. Licao 2 (order_index 1) — Cadencia, Velocidade e Varia RTL515.
--    Remove o sensor Tempe do metric_card_grid.
-- ============================================================
update lessons
set
  order_index = 1,
  body = $j$
{"blocks":[
  {"type":"metric_card_grid","columns":2,"items":[
    {"icon":"🚴","name":"Speed Sensor 2 / Cadence Sensor 2","definition":"Instalados no cubo da roda e no pedivela. Transmitem por ANT+ e Bluetooth ao mesmo tempo, com bateria de cerca de 1 ano. O Speed Sensor 2 ainda guarda até 300 horas de dado sozinho, sem precisar do relógio ou Edge por perto."}
  ]},
  {"type":"texto_rico","html":"<p>O <strong>Varia RTL515</strong> combina radar traseiro e luz: detecta veículos se aproximando por trás a até 140 metros e avisa o ciclista com alerta visual (barra de LED na tela do Edge ou relógio) e sonoro. A luz tem 5 modos (Solid, Peloton, Night Flash, Day Flash e Standby), chegando a 65 lúmens no Day Flash, visível a até 1,6km. A versão com câmera (RCT715) ainda grava o trajeto em vídeo, além do radar e da luz.</p>"},
  {"type":"banner","tone":"info","text":"Todos esses sensores conectam via ANT+ e/ou Bluetooth ao Edge ou ao relógio, ampliando o que o aparelho sozinho não capta."}
]}
$j$::jsonb
where id = 'b5bfa1c1-0e98-4cf9-9b0f-2fc1968343d8';

-- ============================================================
-- 3. Licao 3 (order_index 2) — Guia Definitivo de Pulseiras.
--    Funde a antiga licao de tamanhos com a antiga licao de escolha, corrige
--    o Forerunner 970 (Watchband de fabrica, nao QuickFit nativo) e ensina o
--    procedimento real de adaptacao, alem do guia de materiais.
-- ============================================================
update lessons
set
  title = 'Guia Definitivo de Pulseiras: QuickFit, Quick Release e Watchband',
  order_index = 2,
  body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<p>O portfólio Garmin usa <strong>três sistemas de fixação de pulseira diferentes</strong>, e confundir um com o outro é o erro mais comum na hora de vender uma pulseira certa pro cliente errado.</p>"},
  {"type":"card_grid","columns":3,"items":[
    {"title":"QuickFit","tags":[{"label":"Sem ferramenta","color":"green"}],"text":"Sistema Garmin de troca por alavanca: encaixa e destrava em segundos, sem ferramenta nenhuma. Usado na linha Fenix, Instinct e outros relógios de aventura, em 3 larguras: 20mm, 22mm e 26mm."},
    {"title":"Quick Release","tags":[{"label":"Sem ferramenta","color":"blue"}],"text":"Pino de mola padrão da indústria (spring bar), também sem ferramenta obrigatória — sai com a unha ou uma ferramenta pequena. Usado nos Forerunner 55, 165, 170 e 570. É um sistema diferente do QuickFit, mesmo quando a largura coincide (20 ou 22mm)."},
    {"title":"Watchband","tags":[{"label":"Precisa de ferramenta","color":"gold"}],"text":"Pulseira presa por um pino fixo, que exige uma ferramenta (pino/pushpin) pra remover. É o sistema de fábrica do Forerunner 970."}
  ]},
  {"type":"banner","tone":"warning","text":"Correção importante: o Forerunner 970 NÃO vem com QuickFit nativo de fábrica. Ele vem com o sistema Watchband (pulseira presa por pino, precisa de ferramenta pra soltar). É possível adaptar o relógio pra aceitar uma pulseira QuickFit de 22mm, mas isso exige um procedimento manual — não é plug-and-play como no Fenix ou no Instinct."},
  {"type":"roteiro","steps":[
    {"title":"Passo 1 — Remover a pulseira Watchband original","dialog":"Solte e remova a pulseira Watchband que veio de fábrica no Forerunner 970, usando a ferramenta apropriada pra soltar o pino que a prende.","tip":"Não force o pino sem a ferramenta certa — o sistema Watchband foi projetado pra ser removido só com ela."},
    {"title":"Passo 2 — Soltar o pino da pulseira removida","dialog":"Extraia o pino que prendia a pulseira Watchband. Esse mesmo pino é reaproveitado no próximo passo, não é descartado.","tip":"Guarde o pino, ele é pequeno e fácil de perder."},
    {"title":"Passo 3 — Reposicionar o pino direto nos encaixes da caixa","dialog":"Coloque esse pino diretamente nos encaixes (lugs) da caixa do relógio, sem nenhuma pulseira presa a ele dessa vez.","tip":"É esse passo que faz a diferença: o pino passa a funcionar como o eixo que a pulseira QuickFit vai travar."},
    {"title":"Passo 4 — Encaixar a pulseira QuickFit de 22mm","dialog":"Com o pino já posicionado nos encaixes da caixa, encaixe a pulseira QuickFit de 22mm nele. Ela trava sozinha, sem ferramenta, exatamente como travaria num Fenix ou Instinct.","tip":"Depois desse procedimento, a troca entre pulseiras QuickFit no Forerunner 970 passa a ser tão rápida quanto em qualquer outro modelo QuickFit."}
  ]},
  {"type":"tabela","headers":["Modelo","Tamanho da caixa","Sistema de fábrica","QuickFit compatível"],"rows":[
    ["Fenix 8","42/43mm","QuickFit nativo","20mm"],
    ["Fenix 8","47mm","QuickFit nativo","22mm"],
    ["Fenix 8","51mm","QuickFit nativo","26mm"],
    ["Instinct 3","45mm","QuickFit nativo","22mm"],
    ["Instinct 3","50mm","QuickFit nativo","26mm"],
    ["Forerunner 970","47mm","Watchband (pino)","22mm, só após adaptação manual"],
    ["Forerunner 55 / 165 / 170 / 570","Variados","Quick Release (pino de mola padrão)","Não aplicável — sistema diferente"]
  ]},
  {"type":"texto_rico","html":"<p><strong>Guia de materiais</strong> — a mesma largura (20/22/26mm) existe em materiais diferentes, e cada um resolve uma necessidade distinta do cliente:</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"Silicone","tags":[{"label":"Performance","color":"green"}],"text":"Material padrão QuickFit. Impermeável, resiste bem ao suor e à água, fácil de limpar. Custo menor, mas o visual é mais esportivo do que elegante."},
    {"title":"Nylon / UltraFit","tags":[{"label":"Esportiva","color":"blue"}],"text":"Trançado, respirável, ótimo pra quem treina muito e sua bastante — seca mais rápido que o silicone e não gruda na pele. Mesmas 3 larguras QuickFit (20/22/26mm)."},
    {"title":"Couro","tags":[{"label":"Estilo","color":"gold"}],"text":"Visual premium e discreto, ideal pra usar no trabalho ou em ocasião social. Não é recomendado pra treino intenso, suor constante ou natação — o couro não foi feito pra isso."},
    {"title":"Metal","tags":[{"label":"Lifestyle","color":"gold"}],"text":"Visual mais sofisticado e durável, mas mais pesado que silicone ou nylon. Melhor indicado pro dia a dia e uso casual do que pra treino de alta intensidade."}
  ]},
  {"type":"texto_rico","html":"<p>O jeito mais rápido de confirmar o tamanho de uma pulseira QuickFit é olhar a própria peça: o tamanho vem gravado na parte de baixo, a que fica encostada no pulso (ex.: \"QuickFit 22\"). Sem a pulseira em mãos, o tamanho é definido pelo modelo e pela caixa do relógio, conforme a tabela acima.</p>"},
  {"type":"objecao","items":[
    {"question":"O cliente não sabe o tamanho do relógio dele, e não trouxe a pulseira","answer":"Pergunte o modelo e o tamanho da caixa (em mm, geralmente no nome do produto ou na caixa de venda). Com isso dá pra cruzar direto com a tabela de QuickFit por modelo."}
  ]},
  {"type":"card_grid","columns":3,"items":[
    {"title":"Treina muito e sua bastante","tags":[{"label":"Performance","color":"green"}],"text":"Silicone ou Nylon/UltraFit, secam rápido e resistem ao suor."},
    {"title":"Quer usar no trabalho ou em ocasião social","tags":[{"label":"Estilo","color":"gold"}],"text":"Couro ou metal, visual mais discreto e sofisticado."},
    {"title":"Quer trocar o visual sem trocar de relógio","tags":[{"label":"Venda casada","color":"blue"}],"text":"O próprio sistema QuickFit já é o argumento: troca em segundos, sem ferramenta, vale ter mais de uma pulseira."}
  ]}
]}
$j$::jsonb
where id = '254c2894-176b-43e5-9f56-6bdd4691db06';

-- ============================================================
-- 4. Licao 4 (order_index 3) — Carregadores e Conservacao dos Contatos.
--    Reaproveita o antigo slot "HRM 200 e carregadores" (o HRM 200 ja saiu
--    daqui, foi consolidado na licao 1), virando uma licao só de carregador.
-- ============================================================
update lessons
set
  title = 'Carregadores e Conservação dos Contatos Elétricos',
  order_index = 3,
  body = $j$
{"blocks":[
  {"type":"texto_rico","html":"<p>Pra carregar qualquer relógio ou cinta recarregável, o clipe magnético que encaixa no aparelho é sempre igual — muda só a ponta que liga na tomada ou no computador: relógios 2022 em diante (praticamente toda a linha atual) usam cabo com ponta <strong>USB-C</strong>; aparelhos mais antigos usam ponta <strong>USB-A</strong> tradicional.</p>"},
  {"type":"banner","tone":"info","text":"Bom item de venda casada: cliente que carrega o carro ou já tem carregador USB-C em casa aproveita o mesmo cabo pro relógio."},
  {"type":"texto_rico","html":"<p><strong>Conservação dos contatos traseiros</strong> — os pinos metálicos na parte de trás do relógio (e da cinta cardíaca) são o ponto mais sensível do carregamento. Suor, água salgada e sujeira acumulada ali causam oxidação e, com o tempo, falha no carregamento.</p>"},
  {"type":"card_grid","columns":2,"items":[
    {"title":"Limpe os contatos regularmente","tags":[{"label":"Rotina","color":"blue"}],"text":"Passe um pano seco ou levemente úmido nos pinos traseiros antes de carregar, principalmente depois de treinos com muito suor."},
    {"title":"Seque completamente após suor ou água salgada","tags":[{"label":"Antes de carregar","color":"green"}],"text":"Nunca carregue o relógio ainda molhado ou com suor fresco nos contatos — deixe secar por completo primeiro."},
    {"title":"Enxágue após natação em água salgada","tags":[{"label":"Pós-treino","color":"blue"}],"text":"Água do mar acelera a oxidação dos contatos. Enxágue com água doce e seque bem antes de guardar ou carregar."},
    {"title":"Fique de olho em oxidação visível","tags":[{"label":"Manutenção","color":"gold"}],"text":"Se aparecer uma camada esverdeada ou esbranquiçada nos pinos, limpe com cuidado antes de tentar carregar — isso é o que normalmente causa \"carregador não pega\"."}
  ]}
]}
$j$::jsonb
where id = 'ef644ba5-7905-4fa3-8a79-e90f256bdd62';

-- ============================================================
-- 5. Licao 5 (order_index 4) — Montagem do ecossistema completo (pitch de
--    venda). Remove a mencao ao sensor Tempe do roteiro.
-- ============================================================
update lessons
set
  order_index = 4,
  body = $j$
{"blocks":[
  {"type":"roteiro","steps":[
    {"title":"Apresentando o ecossistema como um todo","dialog":"O relógio sozinho já entrega muita coisa, mas o ecossistema completo é o que separa o atleta casual do sério: HRM 600 ou HRM 200 pra frequência cardíaca, sensores de cadência e velocidade pro ciclismo, o radar Varia pra segurança e contexto no trânsito, e ainda dá pra personalizar com pulseiras QuickFit diferentes pra cada ocasião.","tip":"Apresente o ecossistema em camadas, não tudo de uma vez: comece pelo que resolve a dor imediata do cliente."}
  ]}
]}
$j$::jsonb
where id = 'f5221f03-52cb-47d2-a010-eb50f3b11f0f';

-- ============================================================
-- 6. Remove as 2 licoes que saem do modulo: "Running Power" (conteudo
--    redundante/errado) e a antiga licao de "escolha de pulseira certa"
--    (fundida na nova licao 3). Limpa dependentes antes (review_catalog e
--    seus proprios dependentes), seguindo o mesmo padrao de cascade usado em
--    contentAdminService.js pra nao deixar linha orfa.
-- ============================================================
delete from review_session_items
where catalog_item_id in (
  select id from review_catalog
  where source_table = 'lessons'
    and source_id in ('e7b4b6a9-b6a0-4c35-b1d7-00a8944d9204', 'acaf9bcb-d86d-47b5-afb6-2fe8da478468')
);

delete from review_catalog
where source_table = 'lessons'
  and source_id in ('e7b4b6a9-b6a0-4c35-b1d7-00a8944d9204', 'acaf9bcb-d86d-47b5-afb6-2fe8da478468');

delete from lesson_progress
where lesson_id in ('e7b4b6a9-b6a0-4c35-b1d7-00a8944d9204', 'acaf9bcb-d86d-47b5-afb6-2fe8da478468');

delete from lessons
where id in ('e7b4b6a9-b6a0-4c35-b1d7-00a8944d9204', 'acaf9bcb-d86d-47b5-afb6-2fe8da478468');

-- ============================================================
-- 7. Quiz "Ecossistema de Sensores de Elite" — remove as perguntas sobre
--    Running Power (footpod) e sensor Tempe, corrige a pergunta que dizia o
--    Forerunner 970 "realmente usa" QuickFit (agora reflete a adaptação real
--    via Watchband), e adiciona perguntas novas cobrindo o aprofundamento
--    desta rodada (Watchband x QuickFit, procedimento de adaptação, guia de
--    materiais, conservação dos contatos).
-- ============================================================
delete from review_session_items
where catalog_item_id in (
  select id from review_catalog
  where source_table = 'questions'
    and source_id in ('04ad4289-9ed5-4c3d-bdc5-4e0836863122', 'd659887e-7ea1-4740-931d-2cdb4fffef88')
);

delete from review_catalog
where source_table = 'questions'
  and source_id in ('04ad4289-9ed5-4c3d-bdc5-4e0836863122', 'd659887e-7ea1-4740-931d-2cdb4fffef88');

delete from questions
where id in ('04ad4289-9ed5-4c3d-bdc5-4e0836863122', 'd659887e-7ea1-4740-931d-2cdb4fffef88');

-- corrige a pergunta sobre o Forerunner 970
update questions
set body = 'Qual Forerunner do portfólio pode ser adaptado pra usar pulseira QuickFit de 22mm?'
where id = '2eccad98-d7ae-46a8-a354-e1a365b38b50';

update alternatives set body = 'Só o Forerunner 970, movendo o pino da Watchband pros encaixes da caixa' where id = '9ce696a2-fc42-45b8-928a-fd2cecfac5e3';
update alternatives set body = 'Todos os Forerunner do portfólio, de fábrica' where id = '3773db4a-8227-4969-b7f2-16e62cae2594';
update alternatives set body = 'Nenhum Forerunner aceita pulseira QuickFit, nem adaptado' where id = 'b802e2f7-012f-4a6e-ada0-1341980f0fd3';
update alternatives set body = 'Só o Forerunner 55, sem precisar de adaptação' where id = 'e3387998-0a64-48c4-99a6-3aec2fc51475';

update questions
set explanation = 'O Forerunner 970 vem de fábrica com o sistema Watchband (pulseira presa por pino, precisa de ferramenta pra soltar), não com QuickFit nativo. Pra usar uma pulseira QuickFit de 22mm, é preciso remover a Watchband original, soltar o pino, reposicioná-lo direto nos encaixes da caixa e então encaixar a QuickFit nele.'
where id = '2eccad98-d7ae-46a8-a354-e1a365b38b50';

-- renumera as perguntas restantes em sequencia (0..N) antes de inserir as novas
with ranked as (
  select id, row_number() over (order by order_index) - 1 as new_order
  from questions
  where quiz_id = '0b42b2d9-46be-4336-96a3-523b5edbd708'
)
update questions q
set order_index = ranked.new_order
from ranked
where q.id = ranked.id;

-- 4 perguntas novas cobrindo o aprofundamento desta rodada (IDs fixos pra
-- poder inserir as alternativas na sequência, na mesma migração atômica)
insert into questions (id, quiz_id, body, explanation, order_index, is_active)
values
  ('a1b2c3d4-0001-4a1a-9a1a-110000000001', '0b42b2d9-46be-4336-96a3-523b5edbd708', 'Qual a diferença entre o sistema Watchband do Forerunner 970 e o QuickFit?', 'Watchband é preso por um pino e exige ferramenta pra remover. QuickFit é um sistema de alavanca, sem ferramenta nenhuma, usado nativamente no Fenix e no Instinct.', 13, true),
  ('a1b2c3d4-0002-4a1a-9a1a-110000000002', '0b42b2d9-46be-4336-96a3-523b5edbd708', 'Qual material de pulseira é mais indicado pra um cliente que treina muito e sua bastante?', 'Silicone ou Nylon/UltraFit — impermeáveis, resistem ao suor e secam rápido. Couro e metal não são recomendados pra treino intenso.', 14, true),
  ('a1b2c3d4-0003-4a1a-9a1a-110000000003', '0b42b2d9-46be-4336-96a3-523b5edbd708', 'O que ajuda a evitar oxidação nos contatos traseiros de carregamento?', 'Secar completamente o relógio após suor ou água salgada antes de carregar, e limpar os pinos regularmente com um pano seco ou levemente úmido.', 15, true),
  ('a1b2c3d4-0004-4a1a-9a1a-110000000004', '0b42b2d9-46be-4336-96a3-523b5edbd708', 'O Forerunner 55, 165, 170 e 570 usam o sistema QuickFit?', 'Não — usam Quick Release, o pino de mola padrão da indústria. É um sistema diferente do QuickFit, mesmo quando a largura coincide.', 16, true);

insert into alternatives (question_id, body, is_correct, order_index)
values
  ('a1b2c3d4-0001-4a1a-9a1a-110000000001', 'Watchband precisa de ferramenta pra soltar o pino; QuickFit é uma alavanca sem ferramenta', true, 0),
  ('a1b2c3d4-0001-4a1a-9a1a-110000000001', 'São exatamente o mesmo sistema, só com nomes diferentes', false, 1),
  ('a1b2c3d4-0001-4a1a-9a1a-110000000001', 'Watchband é mais rápido de trocar que o QuickFit', false, 2),
  ('a1b2c3d4-0001-4a1a-9a1a-110000000001', 'QuickFit precisa de ferramenta e Watchband não', false, 3),

  ('a1b2c3d4-0002-4a1a-9a1a-110000000002', 'Silicone ou Nylon/UltraFit', true, 0),
  ('a1b2c3d4-0002-4a1a-9a1a-110000000002', 'Couro', false, 1),
  ('a1b2c3d4-0002-4a1a-9a1a-110000000002', 'Metal', false, 2),
  ('a1b2c3d4-0002-4a1a-9a1a-110000000002', 'Qualquer material serve igual pra treino intenso', false, 3),

  ('a1b2c3d4-0003-4a1a-9a1a-110000000003', 'Secar bem o relógio após suor ou água salgada antes de carregar', true, 0),
  ('a1b2c3d4-0003-4a1a-9a1a-110000000003', 'Carregar o relógio ainda molhado pra economizar tempo', false, 1),
  ('a1b2c3d4-0003-4a1a-9a1a-110000000003', 'Nunca limpar os contatos, pra não arranhar', false, 2),
  ('a1b2c3d4-0003-4a1a-9a1a-110000000003', 'Deixar a oxidação acumular, ela não afeta o carregamento', false, 3),

  ('a1b2c3d4-0004-4a1a-9a1a-110000000004', 'Não, usam Quick Release (pino de mola padrão)', true, 0),
  ('a1b2c3d4-0004-4a1a-9a1a-110000000004', 'Sim, todos usam QuickFit nativo', false, 1),
  ('a1b2c3d4-0004-4a1a-9a1a-110000000004', 'Só o Forerunner 570 usa QuickFit', false, 2),
  ('a1b2c3d4-0004-4a1a-9a1a-110000000004', 'Nenhum desses modelos aceita troca de pulseira sem ferramenta', false, 3);
