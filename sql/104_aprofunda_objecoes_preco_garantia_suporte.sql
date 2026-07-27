-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 104: aprofunda "Contornando Objeções de
-- Preço" com o diferencial real da loja (garantia, suporte, parcelamento)
-- ============================================================================
-- Pedido do usuário: "nosso diferencial (apesar da diferença de valores pra
-- quem compra fora) é que conosco a garantia é de 2 anos por sermos
-- importadora oficial, damos pós atendimento, a pessoa pode procurar caso
-- surja qualquer dúvida e temos um time de plantão de suporte técnico. e
-- possibilitamos parcelamento em até 18x com juros".
--
-- Duas mudanças:
-- 1. NOVA lição (order_index 3) sobre o diferencial de garantia/suporte,
--    o argumento mais forte contra "achei mais barato de fora" — não
--    existia em nenhum lugar do módulo antes.
-- 2. CORREÇÃO factual real: o roteiro de fechamento (antes order_index 3,
--    agora 4) dizia "dá pra parcelar SEM JUROS em várias vezes" — política
--    real da loja é até 18x COM juros no cartão. Uma cinta cardíaca de
--    entrada prometendo parcelamento sem juros pro cliente seria uma
--    promessa falsa; corrigido pra não afirmar isso.
-- ============================================================================

begin;

-- Abre espaço: "Roteiro de fechamento com parcelamento" sai do order_index 3 pro 4
update lessons set order_index = 4 where id = '3971dd04-9e16-48f3-84e2-c327aaa07fcf';

-- Corrige a promessa errada de "parcelamento sem juros" pra refletir a política real (até 18x com juros)
update lessons set
  body = $j${
    "blocks": [
      {"type": "roteiro", "steps": [
        {"title": "Oferecendo parcelamento sem parecer desespero de venda", "dialog": "Se o valor à vista pesar agora, dá pra parcelar em até 18 vezes no cartão, o que deixa o valor mensal bem mais leve que o total. Quer que eu já calcule como fica no seu cartão?", "tip": "O parcelamento tem os juros normais do cartão, não é parcelamento sem juros. Nunca prometa \"sem juros\" pro cliente: fale em até 18x e deixe a taxa exata por conta da operadora do cartão dele."},
        {"title": "Fechando com escolha, não com sim ou não", "dialog": "Prefere fechar no modelo que a gente conversou ou prefere já levar com a cinta extra também, pra já sair rodando sem precisar voltar depois?", "tip": "Técnica de fechamento assumindo a venda: a pergunta não é se compra, é qual opção leva."}
      ]}
    ]
  }$j$
where id = '3971dd04-9e16-48f3-84e2-c327aaa07fcf';

-- Nova lição (order_index 3): garantia de 2 anos e suporte, o diferencial real da loja
insert into lessons (module_id, title, content_type, order_index, is_published, body) values
('00ced86e-4e45-4f95-b932-1899ad8e8cbe', 'Garantia de 2 anos e suporte: por que comprar com a gente', 'text', 3, true, $j${
  "blocks": [
    {"type": "texto_rico", "html": "<p>Quando o cliente compara nosso preço com o de fora (marketplace, importado por conta própria, vendedor não autorizado), o preço menor esconde um risco real: garantia, suporte e procedência. Somos importadora oficial Garmin, e isso muda a conversa.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Garantia de 2 anos", "text": "Cobertura completa por sermos importadora oficial Garmin, sem letra miúda.", "tags": [{"label": "Procedência", "color": "green"}]},
      {"title": "Pós-atendimento", "text": "O cliente pode nos procurar depois da compra sempre que tiver qualquer dúvida, sem custo.", "tags": [{"label": "Suporte", "color": "blue"}]},
      {"title": "Suporte técnico de plantão", "text": "Time dedicado disponível pra resolver problema técnico, não é só venda e ponto.", "tags": [{"label": "Pós-venda", "color": "gold"}]}
    ]},
    {"type": "objecao", "items": [
      {"question": "Achei mais barato num site importado ou marketplace, por que comprar com vocês?", "answer": "O preço menor de fora normalmente não inclui garantia de 2 anos, nem suporte pós-venda, nem um time técnico pra te ajudar se o relógio apresentar algum problema. Aqui você paga pela tranquilidade de ter procedência garantida e alguém pra te atender depois, não só no dia da compra."}
    ]},
    {"type": "roteiro", "steps": [
      {"title": "Puxando o diferencial de garantia na conversa", "dialog": "Além do produto, você leva 2 anos de garantia porque somos importadora oficial Garmin, e qualquer dúvida depois da compra é só nos procurar, temos um time de suporte técnico disponível pra te ajudar.", "tip": "Use esse argumento principalmente quando o cliente mencionar preço de fora, é o momento certo de mostrar o que o preço menor não inclui."}
    ]}
  ]
}$j$);

-- Quiz: 3 perguntas novas sobre garantia/suporte/parcelamento correto
do $$
declare
  v_quiz uuid := '76854546-2f5e-45a1-b20e-992f7a946b8b';
  v_q uuid;
begin

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'Por que a garantia é um diferencial forte frente a comprar de fora (importado, marketplace)?', 'A loja é importadora oficial Garmin, com garantia de 2 anos; produto de fora normalmente não tem essa cobertura.', 8) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Somos importadora oficial Garmin, com garantia de 2 anos, cobertura que produto de fora normalmente não tem', true, 0),
(v_q, 'Não há diferença real de garantia entre comprar aqui ou de fora', false, 1),
(v_q, 'A garantia de fora é sempre mais longa', false, 2),
(v_q, 'Garantia só existe pra quem compra à vista', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'Além da garantia de 2 anos, o que mais o cliente ganha comprando com a loja?', 'Pós-atendimento (pode procurar a loja com qualquer dúvida) e um time de suporte técnico de plantão.', 9) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Pós-atendimento e suporte técnico de plantão pra qualquer dúvida depois da compra', true, 0),
(v_q, 'Nada além do produto em si', false, 1),
(v_q, 'Um desconto automático na próxima compra', false, 2),
(v_q, 'Acesso a um treinador pessoal gratuito', false, 3);

insert into questions (quiz_id, body, explanation, order_index) values
(v_quiz, 'Em quantas vezes é possível parcelar a compra, e como isso funciona?', 'Em até 18x no cartão, com os juros normais da operadora, nunca prometa parcelamento sem juros pro cliente.', 10) returning id into v_q;
insert into alternatives (question_id, body, is_correct, order_index) values
(v_q, 'Em até 18x no cartão, com juros', true, 0),
(v_q, 'Em até 18x sem juros', false, 1),
(v_q, 'Só à vista, a loja não parcela', false, 2),
(v_q, 'Em até 12x sem juros', false, 3);

end $$;

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 104
-- ============================================================================
