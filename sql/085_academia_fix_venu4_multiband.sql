-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 085: Correção de erro factual no Venu 4
-- (GPS multibanda + métricas avançadas de corrida)
-- ============================================================================
-- Pedido do usuário (2026-07-22): "e o venu 4 precisa ajustar, ele é casual
-- mas é um modelo com métricas avançadas de corrida, esse é um diferencial.
-- tem a questão do botão que tem menos, mas tem multibanda e metricas
-- parecidas com a do forerunner 570!"
--
-- ERRO CORRIGIDO: sql/074 (já aplicado ao Supabase numa sessão anterior)
-- afirmava em 3 lugares que o Venu 4 NÃO tem GPS multibanda e que métricas
-- de performance/corrida eram exclusividade da linha Forerunner. Isso está
-- ERRADO — confirmado via fontes oficiais:
--   - Manual oficial (www8.garmin.com/manuals, página "Satellite Settings"
--     do Venu 4): confirma modo "All + Multi-Band" e tecnologia SatIQ
--     ("dynamically select the best multi-band GNSS system").
--   - Página oficial ph.garmin.com/products/wearables/venu-4: confirma
--     Training Readiness, Training Status (improved), Training Load,
--     Training Load Focus, Training Effect (+ anaeróbico), Running
--     Dynamics (cadência, comprimento de passada, tempo de contato com o
--     solo), Running Power via pulso, VO2 Max (corrida + trilha), Race
--     Predictor (específico por percurso/clima), HRV Status, Recovery
--     Time e Lactate Threshold — suite de métricas de corrida MUITO
--     próxima da que o Forerunner 570 oferece.
--   - Confirmado também (múltiplas fontes consistentes, incluindo review
--     hands-on): o Venu 4 tem 2 botões físicos (Ação, no topo; Voltar/
--     Lanterna, embaixo) — um a MENOS que os 3 botões do Venu 3. É uma
--     característica real (interface mais touch-first), não um defeito —
--     documentada aqui com o mesmo cuidado do resto do corpo de conteúdo.
--
-- Esta migração faz UPDATE nas 4 seções que continham a informação errada
-- ou que precisavam do novo diferencial (personas, diferenciais, objeções,
-- FAQ) — via product_sections.payload, mesmo mecanismo que o editor admin
-- usa (upsert por product_id + section_type). Não mexe nas demais seções
-- do Venu 4, que já estavam corretas.
-- ============================================================================

update product_sections
set payload = $j$
{"blocks": [
  {"type": "card_grid", "columns": 3, "items": [
    {"title": "Quem quer entender os próprios hábitos", "text": "Quer saber como cafeína, álcool ou rotina afetam sono e estresse — Lifestyle Logging resolve isso.", "tags": [{"label": "Hábitos", "color": "blue"}]},
    {"title": "Quem corre e quer métricas avançadas sem sair do estilo casual", "text": "Training Readiness, Training Status, VO2 Max, Race Predictor e Running Dynamics — suite parecida com a do Forerunner 570, num relógio de perfil lifestyle.", "tags": [{"label": "Corrida", "color": "gold"}]},
    {"title": "Quem precisa de acessibilidade", "text": "Baixa visão ou daltonismo — tela falada e filtros de cor são recursos reais, não genéricos.", "tags": [{"label": "Acessibilidade", "color": "green"}]}
  ]},
  {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer entender o próprio dia a dia (hábitos, sono, energia)</li><li>Cliente corre e quer métricas de performance de verdade (Training Readiness, VO2 Max, Race Predictor, Running Dynamics), mas prefere o design e o touchscreen do Venu ao estilo mais \"esportivo\" do Forerunner</li><li>Cliente precisa de recursos de acessibilidade (baixa visão, daltonismo)</li><li>Cliente quer o Venu mais completo, incluindo ECG e lanterna</li></ul>"},
  {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente prefere navegação por botão físico em vez de touchscreen (o Venu 4 tem só 2 botões, contra 3 do Venu 3) → considerar Forerunner ou Fenix</li><li>Cliente valoriza bateria acima de tudo → o Venu 3 dura mais (14 dias contra 12 do 4)</li></ul>"}
]}
$j$
where product_id = (select id from products where slug = 'venu-4')
  and section_type = 'personas';

update product_sections
set payload = $j$
{"blocks": [
  {"type": "accordion", "items": [
    {"title": "GPS multibanda com SatIQ", "html": "<p>O Venu 4 tem GNSS multibanda de verdade — capta L1+L5, com a tecnologia SatIQ escolhendo dinamicamente o melhor modo de satélite conforme o ambiente (economia de bateria em campo aberto, precisão máxima em área urbana densa ou mata fechada). Não é exclusividade da linha Forerunner.</p>"},
    {"title": "Métricas avançadas de corrida (nível Forerunner 570)", "html": "<p>Training Readiness, Training Status, Training Load, Training Load Focus, Training Effect (aeróbico e anaeróbico), Running Dynamics (cadência, comprimento de passada, tempo de contato com o solo), potência de corrida via pulso, VO2 Max (corrida e trilha), Race Predictor específico por percurso/clima, HRV Status, Recovery Time e Lactate Threshold — uma suite de métricas de performance muito próxima da que o Forerunner 570 oferece, dentro de um relógio de perfil lifestyle/casual.</p>"},
    {"title": "Lanterna LED integrada", "html": "<p>Luz embutida no relógio, útil em ambientes escuros — recurso que o Venu 3 não tem.</p>"},
    {"title": "Health Status (beta)", "html": "<p>Monitora tendências de frequência cardíaca, HRV, respiração, temperatura de pele e Pulse Ox durante o sono, e avisa quando alguma métrica foge do padrão normal.</p>"},
    {"title": "Lifestyle Logging", "html": "<p>Registro personalizado ou pré-definido de hábitos (cafeína, consumo de álcool) — o app Garmin Connect mostra o impacto no sono, estresse e HRV.</p>"},
    {"title": "Sleep Alignment + Sleep Consistency", "html": "<p>Sleep Alignment acompanha o alinhamento do ritmo circadiano; Sleep Consistency monitora o horário médio de dormir ao longo de 7 dias.</p>"},
    {"title": "Garmin Fitness Coach", "html": "<p>Treinos personalizados pra mais de 25 atividades (caminhada, ciclismo, remo, HIIT), com ajuste por frequência cardíaca/duração e adaptação diária conforme histórico, sono e recuperação.</p>"},
    {"title": "Treinos Sugeridos do Dia (sem plano formal)", "html": "<p>Sugestão diária de treino mesmo sem configurar um plano — reduz a barreira de entrada pra quem não quer montar rotina.</p>"},
    {"title": "Perfil de Sessão Mista", "html": "<p>Rastreia múltiplas atividades dentro de uma única sessão.</p>"},
    {"title": "Acessibilidade: Tela Falada + Filtros de Cor", "html": "<p>Tela Falada anuncia hora, dados de saúde e alertas horários. Filtros de cor (escala de cinza, vermelho/verde, verde/vermelho, azul/amarelo) ajudam usuários com daltonismo.</p>"},
    {"title": "App de ECG", "html": "<p>Detecção de fibrilação atrial e ritmo sinusal normal.</p>"},
    {"title": "Alto-falante + microfone + comandos de voz sem celular", "html": "<p>Ligações e mensagens com o celular pareado, mais comandos de voz que funcionam mesmo sem o celular por perto.</p>"},
    {"title": "Design mais touch-first: 2 botões físicos (menos que o Venu 3)", "html": "<p>O Venu 4 tem só 2 botões físicos — Ação (topo) e Voltar/Lanterna (embaixo) — contra 3 botões do Venu 3. A navegação é majoritariamente por toque na tela AMOLED. Vale mencionar isso pra quem prefere controle 100% por botão (nesse caso, Forerunner ou Fenix são mais indicados).</p>"},
    {"title": "Bateria de até 12 dias", "html": "<p>Modo smartwatch: até 12 dias — menor que o Venu 3 (até 14 dias), efeito colateral dos novos sensores e recursos.</p>"},
    {"title": "Resistência à água 5 ATM", "html": "<p>Classificação para natação, equivalente à pressão de uma profundidade de 50 metros.</p>"}
  ]}
]}
$j$
where product_id = (select id from products where slug = 'venu-4')
  and section_type = 'diferenciais';

update product_sections
set payload = $j$
{"blocks": [
  {"type": "objecao", "items": [
    {"question": "O Venu 4 vale mais que o Venu 3?", "answer": "Vale se o cliente quer lanterna, ECG, Health Status, Lifestyle Logging, a suite de métricas de corrida (Training Readiness, Running Dynamics, VO2 Max) ou os recursos de acessibilidade — se nenhum desses interessa e bateria é prioridade, o Venu 3 ainda é uma opção válida (dura mais)."},
    {"question": "Por que a bateria é menor que a do modelo anterior?", "answer": "Mais sensores e recursos novos (lanterna, ECG, Health Status, GPS multibanda) consomem mais energia — é uma troca real, não um defeito. Vale ser transparente sobre isso."},
    {"question": "Esse aqui serve pra quem treina sério?", "answer": "Sim — apesar do perfil casual/lifestyle, o Venu 4 tem GPS multibanda e uma suite completa de métricas de performance (Training Readiness, Training Status, Training Load, Running Dynamics, VO2 Max, Race Predictor, Recovery Time, Lactate Threshold), muito próxima da que o Forerunner 570 oferece. A diferença real pro Forerunner não é a qualidade dos dados de treino — é o design (touchscreen em vez de foco em botão) e o pacote de recursos de saúde/lifestyle que o Venu adiciona por cima."},
    {"question": "Por que o Venu 4 tem menos botões que o Venu 3?", "answer": "É uma escolha de design — o Venu 4 é mais touch-first, com 2 botões físicos (Ação e Voltar/Lanterna) contra os 3 do Venu 3. Pra quem prefere controle 100% por botão físico (ex: uso com luva, chuva forte), vale considerar um Forerunner ou Fenix."}
  ]}
]}
$j$
where product_id = (select id from products where slug = 'venu-4')
  and section_type = 'objecoes';

update product_sections
set payload = $j$
{"blocks": [
  {"type": "accordion", "items": [
    {"title": "O Venu 4 tem GPS multibanda?", "html": "<p>Sim — tem GNSS multibanda (L1+L5) com tecnologia SatIQ, que escolhe dinamicamente o melhor modo de satélite conforme o ambiente. Não é exclusividade da linha Forerunner.</p>"},
    {"title": "O Venu 4 tem métricas avançadas de corrida?", "html": "<p>Sim — Training Readiness, Training Status, Training Load, Running Dynamics, potência de corrida via pulso, VO2 Max (corrida e trilha), Race Predictor e Recovery Time, entre outras. É uma suite muito parecida com a do Forerunner 570, dentro de um relógio de perfil mais casual/lifestyle.</p>"},
    {"title": "Qual a autonomia de bateria?", "html": "<p>Até 12 dias em modo smartwatch — um pouco menos que o Venu 3 (até 14 dias).</p>"},
    {"title": "O Health Status é confiável?", "html": "<p>É um recurso em fase beta — vale posicionar como uma ferramenta de acompanhamento de tendências, não como diagnóstico médico.</p>"},
    {"title": "Tem resistência à água pra nadar?", "html": "<p>Sim, classificação 5 ATM.</p>"},
    {"title": "Quantos botões físicos tem?", "html": "<p>2 — Ação (topo) e Voltar/Lanterna (embaixo) — um a menos que os 3 do Venu 3. A navegação é majoritariamente por toque.</p>"},
    {"title": "Quais tamanhos e cores estão disponíveis?", "html": "<p>41mm e 45mm, nas cores lunar gold, light sand, silver e citron, com pulseiras de couro ou silicone trocáveis.</p>"},
    {"title": "Qual a diferença real pro Venu 3?", "html": "<p>O Venu 4 adiciona lanterna LED, ECG, Health Status, Lifestyle Logging, GPS multibanda, a suite completa de métricas de corrida e acessibilidade (tela falada, filtros de cor) — mas tem 2 dias a menos de bateria e um botão físico a menos. Veja a aba \"O que há de novo?\" pra comparação completa.</p>"}
  ]}
]}
$j$
where product_id = (select id from products where slug = 'venu-4')
  and section_type = 'faq';

-- ============================================================================
-- Reforça a correção no Quiz Especialista: nova pergunta sobre multibanda
-- (nenhuma das 5 perguntas originais de sql/074 afirmava o erro, mas também
-- nenhuma reforçava o fato correto — adicionando uma pergunta dedicada).
-- ============================================================================

do $$
declare
  v_quiz4 uuid;
  v_q     uuid;
begin
  select id into v_quiz4 from quizzes where slug = 'quiz-especialista-venu-4';

  insert into questions (quiz_id, body, order_index) values (v_quiz4, 'O Venu 4 tem GPS multibanda?', 6) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Sim — GNSS multibanda com SatIQ, não é exclusividade da linha Forerunner', true, 1),
    (v_q, 'Não, GPS multibanda é só na linha Forerunner', false, 2),
    (v_q, 'Só na versão internacional', false, 3),
    (v_q, 'Não sei', false, 4);
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 085
-- ============================================================================
