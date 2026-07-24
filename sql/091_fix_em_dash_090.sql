-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 091: remove travessões introduzidos na 090
-- ============================================================================
-- A migração 090 (HRM 200/600, Blaze, Cirqa) acabou usando travessão em 11
-- trechos de texto, contrariando a regra do usuário de não usar travessão em
-- nenhum texto (só em títulos). Corrige aqui, reescrevendo cada trecho sem
-- quebrar o sentido.
-- ============================================================================

begin;

-- HRM 200 — diferenciais: "Comparado ao HRM-Pro Plus"
update product_sections
set payload = replace(
  payload::text,
  'O HRM-Pro Plus soma Dinâmica de Corrida (tempo de contato, cadência, oscilação vertical), Potência de Corrida e resistência a natação (5 ATM, com armazenamento offline debaixo d''água) — recursos que o HRM 200 não tem.',
  'O HRM-Pro Plus soma Dinâmica de Corrida (tempo de contato, cadência, oscilação vertical), Potência de Corrida e resistência a natação (5 ATM, com armazenamento offline debaixo d''água), recursos que o HRM 200 não tem.'
)::jsonb
where product_id = (select id from products where slug = 'hrm-200') and section_type = 'diferenciais';

-- HRM 200 — objecoes: "Posso nadar com o HRM 200?"
update product_sections
set payload = replace(
  payload::text,
  'Não é recomendado — ele é 3 ATM, cobre suor e chuva, mas não é indicado pra nado.',
  'Não é recomendado: ele é 3 ATM, cobre suor e chuva, mas não é indicado pra nado.'
)::jsonb
where product_id = (select id from products where slug = 'hrm-200') and section_type = 'objecoes';

-- HRM 600 — diferenciais: gravação autônoma e bateria recarregável
update product_sections
set payload = replace(
  replace(
    payload::text,
    'A cinta grava o treino sozinha, sem precisar de relógio nem celular por perto durante a atividade — depois sincroniza com o Garmin Connect.',
    'A cinta grava o treino sozinha, sem precisar de relógio nem celular por perto durante a atividade, e depois sincroniza com o Garmin Connect.'
  ),
  'Cerca de 2 meses de uso a 1h por dia — diferente do HRM 200 e HRM-Pro Plus, que usam bateria de moeda substituível.',
  'Cerca de 2 meses de uso a 1h por dia, diferente do HRM 200 e HRM-Pro Plus, que usam bateria de moeda substituível.'
)::jsonb
where product_id = (select id from products where slug = 'hrm-600') and section_type = 'diferenciais';

-- Blaze — faq: tamanho de cavalo
update product_sections
set payload = replace(
  payload::text,
  'A manga do Blaze é feita pra rabos com circunferência de 7,5 a 11 polegadas na base — confirme essa medida antes de vender.',
  'A manga do Blaze é feita pra rabos com circunferência de 7,5 a 11 polegadas na base; confirme essa medida antes de vender.'
)::jsonb
where product_id = (select id from products where slug = 'blaze') and section_type = 'faq';

-- Cirqa — visao_geral e diferenciais
update product_sections
set payload = replace(
  payload::text,
  'ao contrário de concorrentes do mesmo segmento sem tela, o Cirqa não exige assinatura pra usar os recursos principais do Garmin Connect — só o Connect+ (opcional) adiciona treinos guiados e coaching.',
  'ao contrário de concorrentes do mesmo segmento sem tela, o Cirqa não exige assinatura pra usar os recursos principais do Garmin Connect; só o Connect+ (opcional) adiciona treinos guiados e coaching.'
)::jsonb
where product_id = (select id from products where slug = 'cirqa') and section_type = 'visao_geral';

update product_sections
set payload = replace(
  payload::text,
  'Usa a geração anterior do sensor óptico (não o Gen 5 mais recente) e não tem ECG — diferença importante se o cliente comparar com o Venu ou Fenix.',
  'Usa a geração anterior do sensor óptico (não o Gen 5 mais recente) e não tem ECG, diferença importante se o cliente comparar com o Venu ou Fenix.'
)::jsonb
where product_id = (select id from products where slug = 'cirqa') and section_type = 'diferenciais';

-- Banner repetido de "Cenários típicos" nos 4 produtos novos (casos_uso)
update product_sections
set payload = replace(
  payload::text,
  'Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes).',
  'Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem, não são depoimentos reais de clientes).'
)::jsonb
where product_id in (
  select id from products where slug in ('hrm-200', 'hrm-600', 'blaze', 'cirqa')
) and section_type = 'casos_uso';

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 091
-- ============================================================================
