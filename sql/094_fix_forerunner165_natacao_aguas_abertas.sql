-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 094: corrige erro factual do Forerunner 165
-- ============================================================================
-- Pedido do usuário (2026-07-24): o Forerunner 165 POSSUI suporte a natação
-- em águas abertas. Confirmado no manual oficial da Garmin (seção "Swimming
-- in Open Water" do Forerunner 165 Series Owner's Manual) — é um recurso
-- padrão da série, sem distinção entre a versão normal e a Music.
--
-- O catálogo tinha essa informação errada em 5 lugares: listava natação em
-- águas abertas como recurso exclusivo do Forerunner 170, quando na
-- verdade os dois modelos suportam. Corrige o conteúdo do produto e a
-- tabela comparativa Forerunner 170 vs Forerunner 165 (linha vira "Sim"
-- pros dois, com winner=tie, mesmo padrão já usado nas outras linhas
-- empatadas dessa mesma tabela).
-- ============================================================================

begin;

-- diferenciais: "25+ perfis de atividade" cita natação só de piscina
update product_sections
set payload = replace(
  payload::text,
  'Incluindo corrida em trilha e natação em piscina.',
  'Incluindo corrida em trilha e natação, tanto em piscina quanto em águas abertas.'
)::jsonb
where id = 'fffe6605-f6b0-4d3d-98ca-dbda6782955c';

-- faq: "Qual a diferença real pro Forerunner 170?" listava natação em águas
-- abertas como exclusiva do 170
update product_sections
set payload = replace(
  payload::text,
  'O 170 adiciona Training Readiness, Training Status, potência de corrida completa, altímetro barométrico, bússola, giroscópio, termômetro, suporte a medidor de potência de ciclismo e natação em águas abertas.',
  'O 170 adiciona Training Readiness, Training Status, potência de corrida completa, altímetro barométrico, bússola, giroscópio, termômetro e suporte a medidor de potência de ciclismo. Natação em águas abertas os dois têm.'
)::jsonb
where id = '11ffd616-199d-44a8-a0c4-a8fc79b06df1';

-- personas: banner "Quando não indicar" citava águas abertas junto do
-- ciclismo como exclusividade do 170
update product_sections
set payload = replace(
  payload::text,
  'Cliente pedala com medidor de potência ou nada em águas abertas → só o 170 tem sensores pra isso',
  'Cliente pedala com medidor de potência de ciclismo → só o 170 tem suporte pra isso'
)::jsonb
where id = '46c8ab81-15df-44d4-9982-bfaf62cb37d4';

-- scripts_venda: roteiro de fechamento comparando com o 170
update product_sections
set payload = replace(
  payload::text,
  'A diferença pro 170 é Training Readiness, Training Status, potência de corrida completa e sensores pra ciclismo/natação em águas abertas; se nenhum desses te interessa, o 165 já entrega bastante.',
  'A diferença pro 170 é Training Readiness, Training Status, potência de corrida completa e suporte a medidor de potência de ciclismo; se nenhum desses te interessa, o 165 já entrega bastante, incluindo natação em águas abertas.'
)::jsonb
where id = 'c38cbb7e-3974-4eec-aa68-b0e034391b65';

-- Tabela comparativa Forerunner 170 vs Forerunner 165
update comparison_items
set value_b = 'Sim', winner = 'tie'
where id = '8567a7fc-273a-462f-bfe9-ce714ae88801';

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 094
-- ============================================================================
