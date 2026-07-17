-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 060: backfill histórico de avaliacoes_google
-- (loja Moema — Beatriz, Dayane Sousa, William, Ribli Silva)
-- ============================================================================
-- Mesmo padrão de sql/059 (Morumbi): planilha só com CONTAGEM mensal, sem
-- nota individual -> nota=5 em todas (mesma decisão já aprovada pelo
-- usuário). Aqui o período cobre até "Há 1 Ano (~2025)", que mapeei como
-- 12 meses atrás de julho/26 = julho/25 (a planilha pula meses com contagem
-- zero pra todo mundo — mar/abr/26 e out/25 não aparecem porque ninguém
-- teve avaliação nesses meses, não por engano).
-- Julho/26 é o mês corrente (hoje é 2026-07-16) — espalha só até dia 15.
-- ============================================================================

do $$
declare
  r record;
  i int;
  days_in_month int;
  max_day int;
  d date;
  is_current_month boolean;
begin
  for r in
    select * from (values
      -- Beatriz
      ('9244ad95-870f-4502-a216-17ff1dd7514b'::uuid, 2026, 7, 3),
      ('9244ad95-870f-4502-a216-17ff1dd7514b'::uuid, 2026, 6, 1),
      ('9244ad95-870f-4502-a216-17ff1dd7514b'::uuid, 2026, 2, 2),
      ('9244ad95-870f-4502-a216-17ff1dd7514b'::uuid, 2026, 1, 1),
      ('9244ad95-870f-4502-a216-17ff1dd7514b'::uuid, 2025, 12, 2),
      ('9244ad95-870f-4502-a216-17ff1dd7514b'::uuid, 2025, 11, 1),
      ('9244ad95-870f-4502-a216-17ff1dd7514b'::uuid, 2025, 9, 3),
      ('9244ad95-870f-4502-a216-17ff1dd7514b'::uuid, 2025, 8, 4),
      ('9244ad95-870f-4502-a216-17ff1dd7514b'::uuid, 2025, 7, 5),
      -- Dayane Sousa
      ('236d1e5a-abf5-47d1-9163-18b171ab191b'::uuid, 2026, 7, 3),
      ('236d1e5a-abf5-47d1-9163-18b171ab191b'::uuid, 2026, 6, 1),
      ('236d1e5a-abf5-47d1-9163-18b171ab191b'::uuid, 2026, 5, 1),
      -- William
      ('3bcff82d-ad19-4152-9c03-fb21a28a2afd'::uuid, 2026, 7, 1),
      -- Ribli Silva
      ('f5649522-ee8b-4b9b-8347-568cf9d521d3'::uuid, 2026, 7, 1)
    ) as t(profile_id, yr, month_num, cnt)
  loop
    days_in_month := extract(day from (date_trunc('month', make_date(r.yr, r.month_num, 1)) + interval '1 month - 1 day'));
    is_current_month := (r.yr = 2026 and r.month_num = 7);
    max_day := case when is_current_month then least(days_in_month, 15) else days_in_month end;

    for i in 1..r.cnt loop
      d := make_date(r.yr, r.month_num, greatest(1, round(i::numeric * max_day / (r.cnt + 1))::int));
      insert into public.avaliacoes_google (profile_id, nota, data_avaliacao)
      values (r.profile_id, 5, d);
    end loop;
  end loop;
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 060
-- ============================================================================
