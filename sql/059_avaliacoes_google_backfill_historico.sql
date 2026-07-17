-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 059: backfill histórico de avaliacoes_google
-- ============================================================================
-- Pedido do usuário: registrar a contagem mensal de avaliações Google (Jan a
-- Jul/26) de 6 vendedores de uma loja, a partir de uma planilha só com
-- CONTAGEM por mês (sem nota individual 1-5 por avaliação). Confirmado com o
-- usuário via pergunta: (1) só popular o histórico em avaliacoes_google —
-- nenhuma tela nova agora, isso já alimenta corretamente o card "Melhor
-- reputação do mês" existente (que soma avaliações do mês CORRENTE por
-- vendedor); (2) como não há nota real por avaliação, assumir nota=5 em
-- todas (aprovado explicitamente pelo usuário).
--
-- Cada linha da tabela abaixo é (profile_id, mês, contagem) — o loop gera
-- 1 registro em avaliacoes_google por avaliação, com data_avaliacao
-- espalhada ao longo do mês (não empilhada no dia 1), já que a planilha só
-- trazia o total mensal, não o dia exato de cada avaliação. Julho é o mês
-- corrente (hoje é 2026-07-16), então limita o espalhamento até dia 15 pra
-- não gerar avaliação com data futura.
-- ============================================================================

do $$
declare
  r record;
  i int;
  days_in_month int;
  max_day int;
  d date;
begin
  for r in
    select * from (values
      -- Fabio Borges
      ('cd736e18-06ab-4ac2-8cb6-f4704d09c1da'::uuid, 4, 1),
      ('cd736e18-06ab-4ac2-8cb6-f4704d09c1da'::uuid, 6, 3),
      -- Joyce Souza
      ('390a153c-1253-441a-841c-3aaff7bdb3d5'::uuid, 2, 2),
      ('390a153c-1253-441a-841c-3aaff7bdb3d5'::uuid, 4, 1),
      ('390a153c-1253-441a-841c-3aaff7bdb3d5'::uuid, 5, 1),
      ('390a153c-1253-441a-841c-3aaff7bdb3d5'::uuid, 6, 1),
      ('390a153c-1253-441a-841c-3aaff7bdb3d5'::uuid, 7, 1),
      -- Daniel Lucena
      ('4c2a3fd8-cff0-441c-af4f-19ae5c003a8b'::uuid, 1, 3),
      ('4c2a3fd8-cff0-441c-af4f-19ae5c003a8b'::uuid, 2, 6),
      ('4c2a3fd8-cff0-441c-af4f-19ae5c003a8b'::uuid, 3, 2),
      ('4c2a3fd8-cff0-441c-af4f-19ae5c003a8b'::uuid, 4, 2),
      ('4c2a3fd8-cff0-441c-af4f-19ae5c003a8b'::uuid, 7, 1),
      -- Gustavo Morais
      ('e60cc6bc-5bb3-4561-8fb5-0be2f3dd3202'::uuid, 2, 3),
      ('e60cc6bc-5bb3-4561-8fb5-0be2f3dd3202'::uuid, 3, 4),
      ('e60cc6bc-5bb3-4561-8fb5-0be2f3dd3202'::uuid, 4, 5),
      ('e60cc6bc-5bb3-4561-8fb5-0be2f3dd3202'::uuid, 5, 3),
      ('e60cc6bc-5bb3-4561-8fb5-0be2f3dd3202'::uuid, 6, 3),
      ('e60cc6bc-5bb3-4561-8fb5-0be2f3dd3202'::uuid, 7, 4),
      -- Renato Dias
      ('8262d1ec-7383-4380-8dbf-ed3dc44becbb'::uuid, 5, 2),
      ('8262d1ec-7383-4380-8dbf-ed3dc44becbb'::uuid, 6, 2),
      ('8262d1ec-7383-4380-8dbf-ed3dc44becbb'::uuid, 7, 7),
      -- Mayara Freire
      ('9d77da37-2b6c-4b0f-a2b5-2c11129d68dd'::uuid, 2, 3)
    ) as t(profile_id, month_num, cnt)
  loop
    days_in_month := extract(day from (date_trunc('month', make_date(2026, r.month_num, 1)) + interval '1 month - 1 day'));
    max_day := case when r.month_num = 7 then least(days_in_month, 15) else days_in_month end;

    for i in 1..r.cnt loop
      d := make_date(2026, r.month_num, greatest(1, round(i::numeric * max_day / (r.cnt + 1))::int));
      insert into public.avaliacoes_google (profile_id, nota, data_avaliacao)
      values (r.profile_id, 5, d);
    end loop;
  end loop;
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 059
-- ============================================================================
