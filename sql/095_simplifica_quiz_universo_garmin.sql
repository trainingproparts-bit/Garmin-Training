-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 095: alinha quiz de "O Universo Garmin" ao
-- texto real do módulo (Zona Explorador)
-- ============================================================================
-- Pedido do usuário (2026-07-24): quiz do Módulo 1 (onboarding) tinha 5 das
-- 10 perguntas testando coisa que o texto do módulo nunca ensina: os 5
-- segmentos oficiais da Garmin, a rede de satélite do inReach (Iridium),
-- a diferença entre Garmin Connect e Connect IQ, e até política de
-- garantia da Proparts — nenhum desses fatos aparece nas 3 lições do
-- módulo (história da marca / por que a Garmin vence / 5 tecnologias:
-- GPS multibanda, FirstBeat+VO2 Max, Body Battery, sono, Garmin Pay).
--
-- Em vez de deletar (evita reabrir o mesmo tipo de problema de FK que
-- fn_review_catalog_sync_blocks já causou — ver migração 092), atualiza as
-- 5 perguntas e suas alternativas em UPDATE, preservando os mesmos
-- question_id/alternative_id (histórico de quiz_answers de quem já
-- respondeu continua íntegro). As 5 novas perguntas cobrem trechos do
-- texto que ainda não eram testados (bateria, durabilidade, sono, Garmin
-- Pay, ecossistema).
-- ============================================================================

begin;

-- Q2 (era: 5 segmentos oficiais) → bateria (lição "Por que a Garmin vence")
update questions set
  body = 'Segundo o módulo, por que a bateria da Garmin é considerada um diferencial frente aos concorrentes?',
  explanation = 'Enquanto concorrentes duram de 1 a 2 dias, um Garmin dura semanas, permitindo monitorar o sono todas as noites sem precisar carregar toda noite.'
where id = '85061fd7-e8f4-4b6a-9a40-e493a2760eee';

update alternatives set body = 'Dura semanas, enquanto concorrentes duram de 1 a 2 dias, permitindo monitorar o sono todas as noites', is_correct = true where id = '38657810-9f45-4999-b524-94d52b609db1';
update alternatives set body = 'Recarrega totalmente em 5 minutos', is_correct = false where id = 'e264fe80-7262-4f07-8065-47999ab80416';
update alternatives set body = 'Não precisa de bateria, funciona só com energia solar', is_correct = false where id = '34e9df1e-d9e4-4539-a0e2-7a0868ef5794';
update alternatives set body = 'Dura o mesmo que os concorrentes, mas custa menos', is_correct = false where id = '4787f8b7-5e06-48f2-96eb-abfc670e50a2';

-- Q3 (era: rede de satélite do inReach) → monitoramento de sono
update questions set
  body = 'O que o monitoramento de sono do Garmin registra, segundo o módulo?',
  explanation = 'O relógio registra cada fase do sono (leve, profunda e REM) e entrega uma pontuação pela manhã.'
where id = '112450f2-23ce-4f77-8c91-77c49b3964bb';

update alternatives set body = 'Cada fase do sono (leve, profunda e REM), com pontuação pela manhã', is_correct = true where id = 'f126ac08-4543-4c2b-aa63-66fffc2f1819';
update alternatives set body = 'Só o horário em que o usuário dormiu e acordou', is_correct = false where id = '4fa0e7e9-eb5e-45c7-95fb-a4aa390adf69';
update alternatives set body = 'A temperatura do quarto durante a noite', is_correct = false where id = '8a79c38b-edfb-4fb9-bb83-2cd61ce15c9e';
update alternatives set body = 'O número de vezes que o usuário se mexeu na cama', is_correct = false where id = '67e7f76e-62e3-4c22-89af-422e49f97479';

-- Q7 (era: Connect vs Connect IQ) → durabilidade
update questions set
  body = 'Com cuidados básicos, quantos anos um relógio Garmin costuma durar, segundo o módulo?',
  explanation = 'Com certificação MIL-STD-810, cristal de safira nas linhas premium e cuidados básicos, um Garmin dura de 5 a 8 anos.'
where id = '658be606-46e0-411d-a0b0-e9119ba4f8ec';

update alternatives set body = 'De 5 a 8 anos', is_correct = true where id = 'f343a8c3-065b-451d-92c4-92c1b414a445';
update alternatives set body = 'De 1 a 2 anos', is_correct = false where id = '358a236e-200a-475f-8d41-cf93123d2dfb';
update alternatives set body = 'Menos de 1 ano', is_correct = false where id = '79d9ae47-a0de-4155-a59e-7d5ab8a8b481';
update alternatives set body = 'Mais de 20 anos', is_correct = false where id = '37fb6a7e-57f0-4bdb-9a8d-f185f4410dfe';

-- Q8 (era: garantia Proparts) → Garmin Pay
update questions set
  body = 'O que o Garmin Pay permite fazer, segundo o módulo?',
  explanation = 'Permite pagar direto pelo relógio, sem precisar tirar o celular do bolso, funcionando nos principais bancos brasileiros.'
where id = '65b34dfa-e233-46a6-86f0-61d96cf20856';

update alternatives set body = 'Pagar direto pelo relógio, sem precisar tirar o celular do bolso', is_correct = true where id = '18f02b9b-d6cf-4277-909c-8b92f9b718ae';
update alternatives set body = 'Financiar a compra de um novo relógio Garmin', is_correct = false where id = 'd37905b1-c345-4f9f-bb56-9691ec9300af';
update alternatives set body = 'Transferir XP entre contas do Garmin Connect', is_correct = false where id = 'f552571f-2741-46fd-8a28-546e12ee6276';
update alternatives set body = 'Pagar a mensalidade de um clube de assinatura Garmin', is_correct = false where id = '0ece2be2-7b2b-4817-8e2b-3290fa926629';

-- Q9 (era: afirmação sobre os 5 segmentos) → ecossistema
update questions set
  body = 'O que forma o "ecossistema inigualável" da Garmin, segundo o módulo?',
  explanation = 'Entre Garmin Connect, Connect IQ e mais de 50 integrações, o atleta que usa Garmin tem todos os dados reunidos num só lugar, ano após ano.'
where id = '4d71afad-1b29-4672-b60d-6dc7c078a3fa';

update alternatives set body = 'Garmin Connect, Connect IQ e mais de 50 integrações reunindo os dados do atleta', is_correct = true where id = '188ed36c-dce7-4d27-b0d3-b5c9401c8a82';
update alternatives set body = 'Só o aplicativo Garmin Connect, sem nenhuma integração externa', is_correct = false where id = '50dc2b51-0708-431c-83f5-9b9768366b62';
update alternatives set body = 'Parcerias exclusivas com academias de ginástica', is_correct = false where id = 'c9125375-4ede-4b4f-a9d5-5123eac280e9';
update alternatives set body = 'Um clube de assinatura mensal obrigatório pra usar o relógio', is_correct = false where id = '2633b3d1-915c-4dcf-98b4-8a2e278cef51';

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 095
-- ============================================================================
