-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 097: alinha quiz de "Portfólio de
-- Produtos" ao texto real do módulo (Zona Explorador)
-- ============================================================================
-- Maior desalinhamento encontrado até agora: o módulo só tem 3 lições
-- (linha Forerunner, linha Fenix, linha MARQ), mas 6 das 10 perguntas do
-- quiz testavam linhas que essas lições nunca mencionam (Enduro 3,
-- Instinct 3, Edge 540/550/1050, Lily 2, Venu 4, Vivoactive 6) — todo esse
-- catálogo já é coberto com muito mais profundidade na Academia de
-- Produtos, não faz sentido testar aqui sem o texto de apoio.
--
-- As 6 perguntas viram perguntas sobre trechos das 3 lições que ainda não
-- eram testados: Fenix E, Forerunner 55, Forerunner 570, Fenix 8 AMOLED
-- Sapphire, MARQ Commander e MARQ Golfer Carbon.
-- ============================================================================

begin;

-- Q3 (era: Enduro 3 vs Fenix 8) → Fenix E
update questions set
  body = 'Qual é a proposta do Fenix E dentro da linha Fenix?',
  explanation = 'O Fenix E é o modelo de entrada da linha: tela AMOLED, GPS padrão e mapas TopoActive, mas sem alto-falante, microfone nem GPS multibanda.'
where id = '87854e77-1f3a-4e3e-b7e1-7c212ada25b7';
update alternatives set body = 'Porta de entrada com AMOLED e mapas TopoActive, mas sem alto-falante, microfone nem GPS multibanda', is_correct = true where id = '5e6cdac1-4e5e-4f2c-a488-2809e95df0d0';
update alternatives set body = 'O modelo mais caro de toda a linha Fenix', is_correct = false where id = '95541e09-f639-4e2f-a877-bfdd2f7ffa93';
update alternatives set body = 'Exclusivo para mergulho técnico com nitrox', is_correct = false where id = '6dec2354-c338-4bf5-87b0-0ff967e16e8e';
update alternatives set body = 'Só vem com pulseira em couro italiano', is_correct = false where id = 'c52323a6-7867-4055-8879-754ea1221051';

-- Q4 (era: Instinct 3) → Forerunner 55
update questions set
  body = 'Qual Forerunner clássico de entrada tem sensor óptico de frequência cardíaca, planos de treino, Body Battery e monitoramento de sono?',
  explanation = 'O Forerunner 55 é descrito na lição como "o clássico da entrada", com esse conjunto de recursos.'
where id = '49b0900d-0c32-4d71-812a-863a30462155';
update alternatives set body = 'Forerunner 55', is_correct = true where id = '688a0d6b-62b0-44b5-aee0-f85c4a42041b';
update alternatives set body = 'Forerunner 570', is_correct = false where id = '531cfa7b-cd9e-425c-a42f-edeb58845f22';
update alternatives set body = 'Forerunner 265', is_correct = false where id = '589b4eba-46fe-459f-88fe-2648bb729817';
update alternatives set body = 'Forerunner 965', is_correct = false where id = 'cfcf66d3-9dce-4965-bbcb-f40baba8a2d5';

-- Q5 (era: Edge 1050) → Forerunner 570
update questions set
  body = 'Lançado em 2025, com GPS SatIQ e sensor Elevate Gen 5, feito para treino intervalado de alta precisão. Qual modelo é esse?',
  explanation = 'A lição descreve exatamente esse conjunto de recursos como o Forerunner 570.'
where id = '8f4b07c7-ba1a-472a-b880-9aba9e36771c';
update alternatives set body = 'Forerunner 570', is_correct = true where id = '16f96a43-f4d8-4e53-bd2b-299fa3fa2c2f';
update alternatives set body = 'Forerunner 265', is_correct = false where id = 'a07f1c9c-0474-4ddb-a74e-90fa232b0050';
update alternatives set body = 'Forerunner 170', is_correct = false where id = '99943629-e15d-449b-9d06-b972a018f1d7';
update alternatives set body = 'Forerunner 955', is_correct = false where id = 'ae7f47a9-c9a2-490b-9bf4-803203d5aed3';

-- Q6 (era: Lily/Venu) → Fenix 8 AMOLED Sapphire
update questions set
  body = 'O que diferencia o Fenix 8 AMOLED Sapphire da versão padrão do Fenix 8?',
  explanation = 'É a versão top da linha, com cristal de safira para máxima resistência a arranhões e acabamento premium, reunindo todos os recursos do Fenix 8.'
where id = '0e6ecd6d-9bdd-4116-abf8-15e34e6a104d';
update alternatives set body = 'Cristal de safira para máxima resistência a arranhões, com acabamento premium', is_correct = true where id = 'ad8f01da-987e-4933-b906-997b41ff4fc8';
update alternatives set body = 'É mais barato que o Fenix 8 padrão', is_correct = false where id = '67e9508c-e37b-4dbc-ad45-5c1b85697a95';
update alternatives set body = 'Não tem opção solar', is_correct = false where id = '73493c09-814d-4ba8-acd8-b69fc2ea60ab';
update alternatives set body = 'Perde o modo mergulho', is_correct = false where id = '8c2e8c7b-2947-4447-9522-fb82eb951906';

-- Q7 (era: Vivoactive 6) → MARQ Commander
update questions set
  body = 'Qual MARQ tem caixa em titânio, pulseira em couro italiano, estética militar sofisticada e modo tático?',
  explanation = 'A lição descreve o MARQ Commander (Gen 2) com exatamente essas características, indicado pra quem combina alto desempenho com presença no pulso.'
where id = '5da67dcf-e231-430f-9a44-a722bc5a2cbc';
update alternatives set body = 'MARQ Commander (Gen 2)', is_correct = true where id = '3f657b74-9fb8-439f-ad42-5afcc882d24d';
update alternatives set body = 'MARQ Athlete (Gen 2)', is_correct = false where id = 'ebc699a1-e841-4ef4-8669-b03bce0a4c2b';
update alternatives set body = 'MARQ Golfer Carbon (Gen 2)', is_correct = false where id = '470d65e9-d6d8-452c-a79a-2848eb73e2fc';
update alternatives set body = 'Fenix 8 AMOLED Sapphire', is_correct = false where id = 'ec293a1e-6da4-4ddb-b092-90c8291ccda3';

-- Q8 (era: Edge 540 vs 550) → MARQ Golfer Carbon
update questions set
  body = 'O que torna o MARQ Golfer Carbon único no mercado de golfe, segundo o módulo?',
  explanation = 'A lição descreve o MARQ Golfer Carbon como o único relógio de golfe no patamar de luxo real, com caixa em fibra de carbono e mapas de mais de 42.000 campos.'
where id = '9ae7c1c6-136b-4172-9d4f-bfa4b08662ba';
update alternatives set body = 'É o único relógio de golfe no patamar de luxo real, com caixa em fibra de carbono e mapas de mais de 42.000 campos', is_correct = true where id = '6366dd58-e31d-4305-b04a-6d89b1fe38ea';
update alternatives set body = 'É o modelo mais barato da linha MARQ', is_correct = false where id = '752d9b46-e97e-4404-b045-1f5d624279f3';
update alternatives set body = 'Não tem modo caddie digital', is_correct = false where id = 'c03bf180-5327-4c19-8d54-ccdfa84be028';
update alternatives set body = 'É feito de titânio, igual o MARQ Commander', is_correct = false where id = 'c1220ecf-3034-4117-8a61-20faaa3f58a6';

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 097
-- ============================================================================
