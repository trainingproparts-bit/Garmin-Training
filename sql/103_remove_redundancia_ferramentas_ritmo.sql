-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 103: remove redundância do módulo
-- "Ferramentas de Ritmo e Planejamento de Prova" (Garmin Coach já é
-- coberto a fundo no módulo dedicado "Garmin Coach", Zona Atleta)
-- ============================================================================
-- Pedido do usuário: "o módulo ferramentas de ritmo e planejamento de prova
-- tá redundante também, ja falamos de garmin coach em outro módulo.
-- podemos falar de treinos que podem ser criados pelo garmin connect, qual
-- o caminho, como criar com passo a passo para fazer em tempo real
-- enquanto lê o módulo e também como baixar trajetos direto no relógio e
-- no edge".
--
-- A lição "Garmin Coach: planos guiados por treinador" duplicava (numa
-- versão bem mais rasa) o que o módulo "Garmin Coach" já ensina em
-- profundidade. Trocada por um passo a passo real de treino estruturado
-- (diferente do Coach: aqui é UMA sessão montada na hora, não um plano de
-- semanas). Adicionada uma lição nova sobre criar e baixar trajetos
-- (rotas) pro relógio e pro Edge, tema que não existia em nenhum módulo.
--
-- Passos confirmados nos manuais oficiais Garmin (support.garmin.com,
-- manuais Forerunner 265/955/965, Edge 1040): caminho de criação de treino
-- (Treinamento e Planejamento > Treinos > Criar um Treino), envio pro
-- relógio (Treinos > selecionar > ícone de enviar > escolher relógio),
-- criação de trajeto (Treinamento e Planejamento > Trajetos > Criar
-- Trajeto, manual/desenho no mapa ou automático por distância), e envio de
-- trajeto tanto pro relógio quanto pro Edge (Trajetos > selecionar >
-- escolher dispositivo > sincronizar).
-- ============================================================================

begin;

-- Lição 3 (era "Garmin Coach: planos guiados por treinador") → treino estruturado
update lessons set
  title = 'Criando um treino estruturado no Garmin Connect, passo a passo',
  body = $j${
    "blocks": [
      {"type": "banner", "tone": "info", "text": "Isso é diferente do Garmin Coach (módulo Garmin Coach, Zona Atleta): lá o cliente segue um plano de várias semanas guiado por um treinador. Aqui, você monta UM treino específico do zero, em poucos minutos, ótimo pra demonstrar o recurso na loja."},
      {"type": "roteiro", "steps": [
        {"title": "Abra o Garmin Connect e comece um treino novo", "dialog": "Toque no menu (☰) do app, depois em Treinamento e Planejamento, Treinos, Criar um Treino.", "tip": "Faça isso agora no seu celular pra acompanhar o passo a passo enquanto lê."},
        {"title": "Escolha a atividade e monte as etapas", "dialog": "Selecione a modalidade (ex.: Corrida) e monte o treino: aquecimento configurado por tempo, distância ou frequência cardíaca, um ou mais blocos de treino com meta de ritmo, FC ou potência, e o resfriamento no final.", "tip": "Um intervalado simples, tipo 5x 1km forte + 400m leve de recuperação, é o exemplo mais fácil de demonstrar pro cliente."},
        {"title": "Salve e nomeie o treino", "dialog": "Toque em Salvar, dê um nome pro treino, e toque em Salvar de novo. Ele aparece na lista de treinos.", "tip": null},
        {"title": "Envie pro relógio", "dialog": "Volte em Treinamento e Planejamento, Treinos, selecione o treino criado, toque no ícone de enviar, escolha o relógio na lista de dispositivos, e siga as instruções na tela pra sincronizar.", "tip": "Assim que sincronizar, o treino aparece pronto no relógio, guiando cada etapa em tempo real durante o treino."}
      ]}
    ]
  }$j$
where id = (select id from lessons where module_id='a25bd64b-60fd-41b3-a132-651285a16d50' and order_index=3);

-- Lição nova (order_index 4) — trajetos/rotas pro relógio e pro Edge
insert into lessons (module_id, title, content_type, order_index, is_published, body) values
('a25bd64b-60fd-41b3-a132-651285a16d50', 'Baixando trajetos: criando um percurso e enviando pro relógio e pro Edge', 'text', 4, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Um <strong>trajeto</strong> (curso/rota) é um percurso salvo com navegação passo a passo: útil pra guiar o atleta por uma rota nova, pelo percurso oficial de uma prova, ou por uma trilha de MTB. Diferente do treino estruturado, que guia o RITMO, o trajeto guia o CAMINHO.</p>"},
    {"type": "roteiro", "steps": [
      {"title": "Crie o trajeto", "dialog": "No app Garmin Connect, toque em Treinamento e Planejamento, Trajetos, Criar Trajeto (ícone +). Escolha o tipo de atividade (corrida, ciclismo, trilha) e o método: desenho no mapa, tocando no ponto de partida e depois no de chegada, ou automático, onde o app sugere um percurso a partir da distância e direção escolhidas.", "tip": "O modo automático é o mais rápido pra demonstrar em loja: escolha uma distância e o app já sugere um trajeto perto da localização atual."},
      {"title": "Revise e salve", "dialog": "Confira a distância e o ganho de elevação calculados pelo app, dê um nome ao trajeto, escolha se fica público ou privado, e salve.", "tip": null},
      {"title": "Envie pro relógio", "dialog": "Volte em Treinamento e Planejamento, Trajetos, selecione o trajeto criado e escolha o relógio na lista de dispositivos. No relógio, o trajeto aparece em Navegação, Trajetos, basta selecionar e escolher Fazer Trajeto.", "tip": null},
      {"title": "Envie pro Edge", "dialog": "O caminho é o mesmo: em Treinamento e Planejamento, Trajetos, selecione o trajeto e escolha o Edge do cliente na lista. No Edge, o trajeto aparece na tela inicial depois de sincronizar pelo app ou pelo Garmin Express, toque nele e selecione Pedalar.", "tip": "Se não aparecer sozinho, mostre o caminho manual pro cliente: Navegação, Trajetos, direto no próprio Edge."}
    ]},
    {"type": "banner", "tone": "info", "text": "Praticamente toda a linha atual suporta trajetos baixados: Forerunner, Fenix, Epix, Instinct, MARQ e todos os Edge."}
  ]
}$j$);

-- Quiz: Q6 e Q7 (eram sobre Garmin Coach) trocadas; 2 perguntas novas via INSERT
update questions set
  body = 'Onde fica, no Garmin Connect, o caminho pra criar um treino estruturado do zero?',
  explanation = 'O caminho é Treinamento e Planejamento > Treinos > Criar um Treino.'
where id = '078a0a4d-6188-4d42-ac7f-7eab04b119aa';
update alternatives set body = 'Treinamento e Planejamento > Treinos > Criar um Treino', is_correct = true where id = '673db8f4-75ac-4467-9841-be96e3a8bdab';
update alternatives set body = 'Configurações > Perfil de Atividade > Novo', is_correct = false where id = '518ceb66-f014-463a-83ef-362c69bfa5fc';
update alternatives set body = 'Meu Dia > Adicionar Treino Rápido', is_correct = false where id = '5174738f-d4b8-46a7-9647-c09d693768a6';
update alternatives set body = 'Garmin Coach > Personalizar Plano', is_correct = false where id = '62e32031-6816-4ee4-8aa8-dca339d58d0d';

update questions set
  body = 'Qual a diferença prática entre um treino estruturado criado na hora e um plano do Garmin Coach?',
  explanation = 'O treino estruturado é uma sessão única montada manualmente pelo vendedor ou cliente; o Garmin Coach é um plano de várias semanas guiado por um treinador, ajustado automaticamente.'
where id = 'fe6cbe6a-25d5-4c04-889f-f2d7b1d2f387';
update alternatives set body = 'Treino estruturado é uma sessão única montada na hora; Garmin Coach é um plano de semanas guiado por treinador', is_correct = true where id = '05b13e6b-3999-431f-8e8f-de5dcf02e943';
update alternatives set body = 'Treino estruturado dura semanas; Garmin Coach é só uma sessão única', is_correct = false where id = '1a2ddc56-fbd5-4a71-bf99-b67aaa2101dc';
update alternatives set body = 'Não existe diferença prática entre os dois', is_correct = false where id = '7ebfdb55-4081-41d4-bb91-4e756bcc28b7';
update alternatives set body = 'Treino estruturado só funciona no Edge; Garmin Coach só no relógio', is_correct = false where id = '80aa6d89-737a-4639-a6eb-0116299b758c';

do $$
declare
  v_quiz uuid := '61a01093-b310-48f3-b5d8-0b0b2e2818fe';
  v_q uuid;
begin

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'Qual a diferença entre um treino estruturado e um trajeto (curso) no Garmin Connect?', 'O treino estruturado guia o ritmo/esforço da sessão; o trajeto guia o caminho/rota a seguir.', 8) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Treino guia o ritmo/esforço; trajeto guia o caminho a seguir', true, 0),
(v_q, 'Os dois fazem exatamente a mesma coisa', false, 1),
(v_q, 'Trajeto só existe pra ciclismo, treino só pra corrida', false, 2),
(v_q, 'Treino estruturado não pode ser enviado pro relógio', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'Depois de criar um trajeto no Garmin Connect, como ele chega no relógio ou no Edge do cliente?', 'É preciso selecionar o trajeto em Treinamento e Planejamento > Trajetos, escolher o dispositivo na lista, e sincronizar (app ou Garmin Express).', 9) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Selecionando o trajeto e escolhendo o dispositivo, depois sincronizando', true, 0),
(v_q, 'Automaticamente, sem nenhuma ação do usuário', false, 1),
(v_q, 'Só é possível enviar pro relógio, nunca pro Edge', false, 2),
(v_q, 'É preciso digitar as coordenadas manualmente no dispositivo', false, 3);

end $$;

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 103
-- ============================================================================
