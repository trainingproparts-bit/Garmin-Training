-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 073: aba "O que há de novo?" (570 vs 265,
-- 970 vs 965)
-- ============================================================================
-- Pedido do usuário (2026-07-21): nova aba nos produtos Forerunner 570 e 970
-- comparando com a linha anterior direta (Forerunner 265 e Forerunner 965,
-- respectivamente — não confundir com 165/170, que são a linha de entrada).
--
-- FONTES — só oficiais:
--   - Press release Forerunner 265/965 (lançamento, 02/03/2023):
--     garmin.com/en-US/newsroom/press-release/sports-fitness/
--     garmin-adds-amoled-displays-to-its-next-gen-forerunner-265-and-...
--   - Manual do 265/265S (specs/bateria/armazenamento):
--     www8.garmin.com/manuals/webhelp/GUID-F41EAFB3-.../GUID-4DC43516-...
--   - Blog oficial Garmin — "The difference between Garmin Forerunner 965
--     and 970": garmin.com/en-US/blog/fitness/the-difference-between-
--     garmin-forerunner-965-and-970/ (comparação pronta, direto da Garmin)
--   - Press release oficial Forerunner 570/970/HRM 200/600 (04/06/2025):
--     garmin.com.sg/news/press-release/news-2025-jun-forerunner-570-970-
--     hrm-200-600/ (subdomínio oficial da Garmin — Singapura)
--   - Manual do 570 (recursos de novidade Smart Wake/Evening Report), já
--     usado em sql/069.
--
-- Cuidado que vale registrar: o bisel de titânio do 970 NÃO é novidade —
-- o Forerunner 965 já tinha bisel de titânio (confirmado no blog oficial).
-- A novidade real do 970 é a LENTE de safira (o 965 usava Gorilla Glass 3
-- DX). Da mesma forma, GPS multibanda SatIQ, PacePro e o armazenamento de
-- música (8 GB) já existiam no Forerunner 265 — não entram como novidade
-- do 570 pra não repetir um erro de comparação que apareceria fácil se eu
-- só olhasse a lista de recursos do 570 sem checar se o 265 já tinha.
-- ============================================================================

alter table public.product_sections drop constraint product_sections_section_type_check;
alter table public.product_sections add constraint product_sections_section_type_check
  check (section_type in (
    'visao_geral', 'personas', 'diferenciais', 'novidades', 'scripts_venda', 'objecoes', 'casos_uso', 'faq'
  ));

insert into product_sections (product_id, section_type, payload) values
((select id from products where slug = 'forerunner-570'), 'novidades', $j$
{"blocks": [
  {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Forerunner 265</strong> (2023), o modelo direto que o 570 substitui na faixa intermediária — não confundir com o 170/165, que são a linha de entrada."},
  {"type": "accordion", "items": [
    {"title": "Alto-falante + microfone (ligações e assistente de voz)", "html": "<p>Primeira vez que a linha Forerunner ganha ligação telefônica direto do pulso (com o celular pareado) e acesso ao assistente de voz do smartphone (Siri/Google Assistant). O 265 não tinha microfone nem alto-falante.</p>"},
    {"title": "Relatório da Noite (Evening Report)", "html": "<p>Recurso novo — o 265 só tinha o Relatório Matinal. O 570 mostra Body Battery do momento, previsão do treino e do tempo de amanhã, e recomendação do Sleep Coach antes de dormir.</p>"},
    {"title": "Alarme Inteligente (Smart Wake)", "html": "<p>Desperta suavemente numa janela de até 30 minutos antes do alarme, no momento mais oportuno do ciclo de sono — recurso que o 265 não tinha.</p>"},
    {"title": "Temperatura de pele", "html": "<p>Sensor novo nesta geração — o 265 não media temperatura de pele.</p>"},
    {"title": "Monitoramento de variações respiratórias", "html": "<p>Métrica nova de recuperação, alimentando o Training Readiness junto com HRV e temperatura de pele.</p>"},
    {"title": "Garmin Triathlon Coach", "html": "<p>O 265 tinha só Run Coach e Cycling Coach separados. O 570 chega com Triathlon Coach dedicado, com perfis de atividade multisport.</p>"},
    {"title": "O que NÃO mudou (continua igual ao 265)", "html": "<p>Tela AMOLED touchscreen + 5 botões, GPS multibanda SatIQ™, PacePro, armazenamento de música (até 8 GB), Body Battery, monitoramento de sono, Pulse Ox, resistência à água 5 ATM — tudo isso já vinha do 265, não é novidade do 570.</p>"}
  ]}
]}
$j$),
((select id from products where slug = 'forerunner-970'), 'novidades', $j$
{"blocks": [
  {"type": "banner", "tone": "info", "text": "Comparado ao <strong>Forerunner 965</strong> (2023), o modelo direto que o 970 substitui no topo de linha."},
  {"type": "accordion", "items": [
    {"title": "Lente de cristal de safira", "html": "<p>O 965 usava lente Corning Gorilla Glass 3 DX. O 970 sobe pra safira, mais resistente a risco — o bisel de titânio, aliás, já vinha do 965 (não é novidade).</p>"},
    {"title": "App de ECG", "html": "<p>Detecção de fibrilação atrial e ritmo sinusal normal — recurso novo, sendo introduzido na linha Forerunner pela primeira vez com o 970.</p>"},
    {"title": "Lanterna LED integrada", "html": "<p>Luz branca e vermelha com controle de brilho e modo estroboscópio — o 965 não tinha lanterna.</p>"},
    {"title": "Alto-falante + microfone (ligações e assistente de voz)", "html": "<p>Mesma novidade do 570 — primeira vez na linha Forerunner. O 965 não tinha.</p>"},
    {"title": "Temperatura de pele", "html": "<p>Sensor novo nesta geração — o 965 não tinha.</p>"},
    {"title": "Relatório da Noite (Evening Report)", "html": "<p>O 965 só tinha o Relatório Matinal.</p>"},
    {"title": "Garmin Triathlon Coach + novas atividades", "html": "<p>O 965 tinha só Run Coach e Cycling Coach. O 970 chega com Triathlon Coach e novos perfis: duathlon, brick e triathlon em piscina.</p>"},
    {"title": "Tolerância de Corrida, Economia de Corrida e Perda de Velocidade do Passo", "html": "<p>Três métricas de corrida totalmente novas do 970 — Economia de Corrida e Perda de Velocidade do Passo exigem a cinta HRM 600 (também lançada junto).</p>"},
    {"title": "Auto lap por timing gates + previsão de tempo de prova", "html": "<p>Detecção automática de linha de chegada por cancela de cronometragem e previsão de tempo de prova com base no treino recente — recursos novos do 970 (confirmado pela Garmin ao comparar diretamente com o 965).</p>"},
    {"title": "Bateria maior, apesar de mais recursos", "html": "<p>Todos os sistemas + multibanda: até 21h no 970 contra até 19h no 965. Com música: até 12h no 970 contra até 8,5h no 965 — mesmo com lanterna, ECG e mais sensores, a bateria melhorou.</p>"},
    {"title": "O que NÃO mudou (continua igual ao 965)", "html": "<p>Bisel de titânio, mapeamento colorido com navegação turn-by-turn, GPS multibanda, PacePro, Garmin Coach (Run/Cycling), armazenamento de música — tudo isso já vinha do 965, não é novidade do 970.</p>"}
  ]}
]}
$j$);

-- ============================================================================
-- FIM DA MIGRAÇÃO 073
-- ============================================================================
