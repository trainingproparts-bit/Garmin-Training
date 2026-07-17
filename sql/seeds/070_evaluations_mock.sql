-- ============================================================================
-- SEED 070: mock de Avaliações Trimestrais (Explorer / Runner / Triathlete)
-- ============================================================================
-- 15 perguntas reais sobre o portfólio Garmin (5 por tier), não são
-- perguntas genéricas de preenchimento — reaproveitam o mesmo domínio de
-- conhecimento já usado nos quizzes de módulo (sql/seeds/020_quizzes.sql).
--
-- Pré-requisito: sql/005_evaluations_and_notifications.sql E
-- sql/007_evaluations_dedupe_and_unique.sql já rodados (é de lá que vêm as
-- constraints uq_evaluations_type / uq_evaluation_questions_eval_order que
-- os "on conflict" abaixo apontam — sem elas, cada re-execução deste seed
-- cria linhas duplicadas em vez de ser ignorada).
-- ============================================================================

insert into evaluations (title, type, passing_score_pct, is_published)
values
  ('Avaliação Trimestral — Explorer',   'explorer',   70.00, true),
  ('Avaliação Trimestral — Runner',     'runner',     70.00, true),
  ('Avaliação Trimestral — Triathlete', 'triathlete', 75.00, true)
on conflict (type) do nothing;

-- ── Explorer ────────────────────────────────────────────────────────────
do $$
declare
  v_eval_id uuid;
begin
  select id into v_eval_id from evaluations where type = 'explorer' limit 1;

  insert into evaluation_questions (evaluation_id, question_text, options_json, correct_option, order_index) values
  (v_eval_id, 'Em que ano a Garmin foi fundada?',
   '["1985","1989","1993","1999"]'::jsonb, 1, 0),
  (v_eval_id, 'Em quantos segmentos oficiais de negócio a Garmin atua?',
   '["3","4","5","6"]'::jsonb, 2, 1),
  (v_eval_id, 'O que é o GPS multibanda?',
   '["Um GPS que funciona em dois países ao mesmo tempo","GPS que usa duas frequências de satélite simultaneamente, resultando em mais precisão em cidades e florestas","Um GPS exclusivo para uso náutico","Uma tecnologia de carregamento sem fio"]'::jsonb, 1, 2),
  (v_eval_id, 'O que o Body Battery mede?',
   '["A carga da bateria do relógio","A energia do corpo, de 0 a 100, baseada em sono, estresse e atividade","A frequência cardíaca máxima do usuário","A distância percorrida no dia"]'::jsonb, 1, 3),
  (v_eval_id, 'Qual a garantia oferecida pela Proparts para dispositivos Garmin?',
   '["1 ano","2 anos","6 meses","3 anos"]'::jsonb, 1, 4)
  on conflict (evaluation_id, order_index) do nothing;
end $$;

-- ── Runner ──────────────────────────────────────────────────────────────
do $$
declare
  v_eval_id uuid;
begin
  select id into v_eval_id from evaluations where type = 'runner' limit 1;

  insert into evaluation_questions (evaluation_id, question_text, options_json, correct_option, order_index) values
  (v_eval_id, 'Qual linha Garmin é a referência para corredores de elite e triatletas?',
   '["Vivoactive","Forerunner 955/965/970","Lily 2","Approach"]'::jsonb, 1, 0),
  (v_eval_id, 'O que é o PacePro?',
   '["Um sensor de potência para corrida","Um plano de ritmo personalizado que considera a elevação do percurso","Um app de música offline","Um tipo de tela AMOLED"]'::jsonb, 1, 1),
  (v_eval_id, 'Qual métrica indica a recuperação do sistema nervoso durante o sono?',
   '["VO2 Max","Status de Treinamento","HRV Status","Carga Aguda"]'::jsonb, 2, 2),
  (v_eval_id, 'O Garmin Coach é:',
   '["Um curso pago no Connect IQ Store","Um serviço gratuito de planos de treino adaptativos dentro do Garmin Connect","Um acessório físico vendido separadamente","Um modo de bateria estendida"]'::jsonb, 1, 3),
  (v_eval_id, 'Quantas horas de bateria em GPS contínuo o Enduro 3 oferece?',
   '["16h","30h","70h ou mais","100h ou mais"]'::jsonb, 2, 4)
  on conflict (evaluation_id, order_index) do nothing;
end $$;

-- ── Triathlete ──────────────────────────────────────────────────────────
do $$
declare
  v_eval_id uuid;
begin
  select id into v_eval_id from evaluations where type = 'triathlete' limit 1;

  insert into evaluation_questions (evaluation_id, question_text, options_json, correct_option, order_index) values
  (v_eval_id, 'Qual certificação garante resistência a impacto, temperatura extrema, umidade e vibração?',
   '["IPX7","MIL-STD-810","EN 13319","ISO 22810"]'::jsonb, 1, 0),
  (v_eval_id, 'O Descent Mk3i é indicado principalmente para qual atividade?',
   '["Golfe","Mergulho técnico","Ciclismo urbano","Corrida de rua"]'::jsonb, 1, 1),
  (v_eval_id, 'Qual a principal diferença entre o Edge 1050 e o Edge 540?',
   '["O 540 tem tela maior","O 1050 tem tela de 3,5 polegadas com Garmin Pay e buzina, o 540 é mais compacto e básico","O 1050 não tem GPS multibanda","Não há diferença relevante entre os dois"]'::jsonb, 1, 2),
  (v_eval_id, 'O que o algoritmo FirstBeat estima a partir da relação entre frequência cardíaca e velocidade?',
   '["Body Battery","VO2 Max estimado","SWOLF","Nível de estresse"]'::jsonb, 1, 3),
  (v_eval_id, 'Qual rede de satélites o inReach utiliza para comunicação?',
   '["Starlink","GPS americano (NAVSTAR)","Iridium","Galileo"]'::jsonb, 2, 4)
  on conflict (evaluation_id, order_index) do nothing;
end $$;

-- ============================================================================
-- FIM DO SEED 070
-- ============================================================================
