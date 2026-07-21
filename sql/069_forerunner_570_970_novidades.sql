-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 069: Forerunner 570/970 — recursos de novidade
-- ============================================================================
-- Pedido do usuário (2026-07-20): a seção "Diferenciais" do 570 e do 970
-- estava faltando recursos de novidade da geração — Alarme Inteligente
-- (Smart Wake), Relatório Matinal (além do já existente Relatório da Noite)
-- e as 3 métricas de corrida exclusivas do 970 estavam resumidas numa frase
-- só em vez de explicadas cada uma.
--
-- Fontes — só oficiais, mesma regra de sql/065:
--   - Manual do proprietário do 570 (Smart Wake/Editing an Alarm):
--     www8.garmin.com/manuals/webhelp/GUID-25E3235D-.../GUID-3E0E8E1C-...
--   - Manual do proprietário do 570 (Evening Report):
--     www8.garmin.com/manuals/webhelp/GUID-25E3235D-.../GUID-4F0239D5-...
--   - Manual do proprietário do 970 (Running Economy):
--     www8.garmin.com/manuals/webhelp/GUID-025D75CF-.../GUID-6E986507-...
--   - Manual do proprietário do 970 (Running Tolerance):
--     www8.garmin.com/manuals/webhelp/GUID-025D75CF-.../GUID-C83A37F8-...
-- Step Speed Loss (definição oficial de "diferença entre velocidade no
-- primeiro contato com o solo e velocidade mínima na fase de apoio") também
-- confirmada nos manuais oficiais, mesma família de páginas.
--
-- Aplicado diretamente via mcp__supabase__execute_sql nesta sessão — este
-- arquivo documenta a mudança no histórico de migrações (mesmo texto usado).
-- ============================================================================

update product_sections
set payload = $j$
{"blocks": [
  {"type": "accordion", "items": [
    {"title": "Tela AMOLED touchscreen + 5 botões", "html": "<p>A tela AMOLED mais brilhante já lançada pela Garmin até hoje, com touchscreen E controle físico por 5 botões — funciona bem de luva ou suado, sem depender só do toque.</p>"},
    {"title": "GPS multibanda com SatIQ™", "html": "<p>SatIQ ajusta automaticamente entre bandas de satélite pra equilibrar precisão de posicionamento e economia de bateria, sem o usuário precisar escolher manualmente o modo de GPS.</p>"},
    {"title": "Bateria por modo de uso", "html": "<p>Só GPS: até 18h. Todos os sistemas + multibanda: até 13-14h. Modo smartwatch (atividade, notificações, FC de pulso): até 10 dias (42mm) ou 11 dias (47mm).</p>"},
    {"title": "Garmin Triathlon Coach", "html": "<p>Planos de treino guiados pros 3 esportes do triathlon, com perfis de atividade multisport customizáveis.</p>"},
    {"title": "Relatório da Noite (Evening Report)", "html": "<p>Recurso NOVO, lançado junto com o 570/970 — antes só existia o Relatório Matinal. Mostra o Body Battery™ do momento, previsão do treino e do tempo de amanhã, e a recomendação do Sleep Coach, exibido pouco antes do horário de dormir.</p>"},
    {"title": "Relatório Matinal (Morning Report)", "html": "<p>Resumo ao acordar com previsão do tempo, dados do sono da noite anterior e status da variabilidade da frequência cardíaca (HRV) durante a madrugada. Pode ser ativado/desativado e ter a ordem dos dados personalizada.</p>"},
    {"title": "Alarme Inteligente (Smart Wake)", "html": "<p>Desperta suavemente numa janela de até 30 minutos antes do horário do alarme configurado, com base no momento mais oportuno do seu ciclo de sono. O alarme principal sempre toca no horário marcado — o Smart Wake só pode antecipar um aviso mais suave dentro dessa janela (ex.: alarme às 8h pode disparar suavemente entre 7h30 e 8h).</p>"},
    {"title": "Temperatura de pele + Pulse Ox", "html": "<p>Sensor de temperatura de pele e Pulse Ox (variações respiratórias durante o sono), alimentando as métricas de recuperação.</p>"},
    {"title": "Training Readiness + métricas avançadas", "html": "<p>VO2 max, potência de corrida direto no pulso e dinâmica de corrida, combinados no score de Training Readiness.</p>"},
    {"title": "Auto lap + previsão de tempo de prova", "html": "<p>Detecção automática de linha de chegada por timing gate e previsão de tempo de prova com base no treino recente.</p>"},
    {"title": "Garmin Pay + notificações inteligentes", "html": "<p>Pagamento por aproximação e notificações do celular direto no pulso.</p>"},
    {"title": "Música offline (até 8 GB)", "html": "<p>Download de playlists do Spotify, Deezer ou Amazon Music pra ouvir sem o celular — armazenamento de até 8 GB.</p>"},
    {"title": "Detecção de incidente + LiveTrack", "html": "<p>Detecta quedas/acidentes durante o treino e avisa contatos de emergência com localização ao vivo.</p>"},
    {"title": "Resistência à água 5 ATM", "html": "<p>Classificação para natação, equivalente à pressão de uma profundidade de 50 metros.</p>"}
  ]}
]}
$j$::jsonb
where product_id = (select id from products where slug = 'forerunner-570') and section_type = 'diferenciais';

update product_sections
set payload = $j$
{"blocks": [
  {"type": "accordion", "items": [
    {"title": "Bisel de titânio + lente de safira", "html": "<p>Construção mais robusta que o alumínio/vidro do 570 — a safira resiste melhor a riscos no dia a dia.</p>"},
    {"title": "Lanterna LED integrada", "html": "<p>Luz branca e vermelha embutida no próprio relógio — útil em treinos de madrugada ou em trilha, sem precisar de lanterna separada.</p>"},
    {"title": "Mapeamento colorido + navegação turn-by-turn", "html": "<p>Mapas completos e coloridos com instruções de navegação passo a passo direto no pulso — recurso que o 570 não tem.</p>"},
    {"title": "App de ECG", "html": "<p>Detecta fibrilação atrial e ritmo sinusal normal. É um recurso novo sendo introduzido na linha Forerunner pela primeira vez.</p>"},
    {"title": "Tolerância de Corrida (Running Tolerance)", "html": "<p>Ajuda a equilibrar o ganho de quilometragem com o risco de lesão. O mostrador exibe a carga de impacto aguda do dia, uma estimativa de quilometragem da semana de treino atual e um gráfico com o histórico de tolerância e carga de impacto ao longo de várias semanas.</p>"},
    {"title": "Economia de Corrida (Running Economy)", "html": "<p>Estima a eficiência de conversão de energia — como o consumo de combustível de um carro —, em mililitros de oxigênio consumido por kg de peso corporal por km. Exige a cinta cardíaca HRM 600 e combina frequência cardíaca, oscilação vertical, Perda de Velocidade do Passo e outras métricas.</p>"},
    {"title": "Perda de Velocidade do Passo (Step Speed Loss)", "html": "<p>Mede quanto você desacelera no instante em que o pé toca o solo (dinâmica de corrida) — a diferença entre a velocidade no primeiro contato com o solo e a velocidade mínima durante a fase de apoio daquele passo. Medida em cm/s pela cinta cardíaca no peito; quanto menor, melhor.</p>"},
    {"title": "Compatibilidade com HRM 600", "html": "<p>Suporta a cinta cardíaca mais avançada da Garmin (vendida separadamente, necessária pra Economia de Corrida e Perda de Velocidade do Passo), com dados mais precisos de frequência cardíaca e dinâmica de corrida.</p>"},
    {"title": "Armazenamento de música (32 GB)", "html": "<p>4x o espaço do 570 (8 GB) — cabe uma biblioteca bem maior de playlists baixadas.</p>"},
    {"title": "Bateria por modo de uso", "html": "<p>Só GPS: até 26h. Todos os sistemas + multibanda: até 21h. Modo smartwatch: até 15 dias.</p>"},
    {"title": "Recursos compartilhados com o 570", "html": "<p>Tela AMOLED touchscreen + 5 botões, SatIQ GPS multibanda, Triathlon Coach, Relatório Matinal, Relatório da Noite (Evening Report), Alarme Inteligente (Smart Wake), temperatura de pele, Pulse Ox, Training Readiness, Garmin Pay, resistência à água 5 ATM.</p>"}
  ]}
]}
$j$::jsonb
where product_id = (select id from products where slug = 'forerunner-970') and section_type = 'diferenciais';

update comparison_items
set value_b = 'Tolerância de Corrida, Economia de Corrida (requer HRM 600) e Perda de Velocidade do Passo'
where comparison_id = (select id from product_comparisons where slug = 'forerunner-570-vs-forerunner-970')
  and spec_label = 'Métricas exclusivas de corrida';

insert into comparison_items (comparison_id, spec_label, value_a, value_b, winner, order_index)
select id, 'Alarme Inteligente (Smart Wake)', 'Sim', 'Sim', 'tie', 17
from product_comparisons where slug = 'forerunner-570-vs-forerunner-970';

insert into comparison_items (comparison_id, spec_label, value_a, value_b, winner, order_index)
select id, 'Relatório Matinal + Relatório da Noite', 'Sim', 'Sim', 'tie', 18
from product_comparisons where slug = 'forerunner-570-vs-forerunner-970';

-- ============================================================================
-- FIM DA MIGRAÇÃO 069
-- ============================================================================
