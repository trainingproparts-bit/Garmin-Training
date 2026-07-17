-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 017: corrige escopo de fn_issue_certification
-- ============================================================================
-- Achado ao testar pela primeira vez o fluxo completo de colaborador
-- (login → lição → quiz → certificado), item pendente do ROADMAP.md nunca
-- percorrido antes: fn_issue_certification() (garmin_training_hub_migrations.sql)
-- contava checkpoints obrigatórios de TODA a trilha (todas as zonas somadas),
-- não da zona correspondente a cada certificação. Efeito prático:
--   - Nenhuma certificação seria emitida até completar Zona Explorador
--     (8 checkpoints) E Zona Corredor (4 checkpoints) juntas — 12/12.
--   - Ao bater 12/12, as 4 certificações (Explorador, Corredor, Maratonista,
--     Triatleta) seriam emitidas de uma vez só — mesmo Maratonista/Triatleta
--     não tendo zona nem conteúdo implementado ainda (confirmado: só existem
--     4 zonas em GPS_ZONES, nenhuma chamada "maratonista"/"triatleta").
-- Isso não é uma decisão de negócio em disputa — é bug de implementação: o
-- próprio `criteria` (jsonb) de cada certificação já lista `required_modules`
-- distintos por tier, a contagem só nunca respeitava esse recorte.
--
-- Fix: certifications ganha zone_id (nullable — Maratonista/Triatleta ficam
-- null de propósito, sem zona real ainda, então continuam corretamente
-- inalcançáveis até existir conteúdo). A trigger passa a contar checkpoints
-- só da zona daquela certificação específica.
-- ============================================================================

alter table public.certifications
  add column if not exists zone_id uuid references public.zones(id);

update public.certifications set zone_id = '9cfd688f-fcad-4a99-900d-9b6771068661' where slug = 'explorador';
update public.certifications set zone_id = '7ded46e1-864c-4122-be37-bf99f0385683' where slug = 'corredor';
-- maratonista/triatleta ficam com zone_id null de propósito (sem zona real ainda).

comment on column public.certifications.zone_id is
  'Zona cujos checkpoints obrigatórios contam para emitir esta certificação (fn_issue_certification). Null = sem zona real implementada ainda (Maratonista/Triatleta) — certificação fica corretamente inalcançável até existir conteúdo.';

create or replace function public.fn_issue_certification()
returns trigger
language plpgsql
as $$
declare
  v_cert record;
  v_total_required     integer;
  v_completed_required integer;
begin
  if new.status <> 'completed' then
    return new;
  end if;

  for v_cert in
    select cert.*
    from certifications cert
    join checkpoints c0 on c0.id = new.checkpoint_id
    join zones z0 on z0.id = c0.zone_id
    where cert.trail_id = z0.trail_id
      and cert.zone_id is not null
  loop
    select count(*) into v_total_required
      from checkpoints c
     where c.zone_id = v_cert.zone_id
       and c.is_required = true;

    select count(*) into v_completed_required
      from checkpoints c
      join user_progress up on up.checkpoint_id = c.id and up.user_id = new.user_id
     where c.zone_id = v_cert.zone_id
       and c.is_required = true
       and up.status = 'completed';

    if v_total_required > 0 and v_completed_required = v_total_required then
      insert into user_certifications (user_id, certification_id)
      values (new.user_id, v_cert.id)
      on conflict (user_id, certification_id) do nothing;

      insert into points_ledger (user_id, source_type, source_id, points, reason)
      values (new.user_id, 'certification', v_cert.id, 300, 'Emissão automática de certificação');
    end if;
  end loop;

  return new;
end;
$$;

comment on function public.fn_issue_certification() is
  'Emite certificação quando todos os checkpoints obrigatórios da ZONA daquela certificação (certifications.zone_id) estão completed para o usuário — corrigido em 017 para não mais somar a trilha inteira.';

-- ============================================================================
-- FIM DA MIGRAÇÃO 017
-- ============================================================================
