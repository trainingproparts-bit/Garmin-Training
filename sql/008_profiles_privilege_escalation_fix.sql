-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 008: fecha escalonamento de privilégio em profiles
-- ============================================================================
-- Problema estrutural encontrado ao construir o Painel Admin/Dashboard do
-- Líder (não introduzido por esta sprint, já existia desde
-- garmin_training_hub_migrations.sql seção 12.4):
--
--   create policy profiles_update_own on profiles
--     for update using (id = auth.uid());
--
-- Essa policy só restringe QUAL linha pode ser tocada (a própria), nunca
-- QUAIS COLUNAS. RLS do Postgres não tem granularidade de coluna nativa —
-- então, sem essa migração, qualquer colaborador autenticado pode chamar
-- diretamente `PATCH /profiles?id=eq.<próprio-id>` com `{"role_id": 3}` e
-- se autopromover a admin. RN 1.1/1.7/1.8 são explícitas: só o Admin altera
-- cargo, loja e marca.
--
-- Fix: trigger BEFORE UPDATE que bloqueia mudança nos campos de
-- autorização/identidade quando quem está editando não é admin. Colaborador
-- continua podendo editar os próprios full_name/avatar_url/emoji/phrase
-- livremente (profiles_update_own continua valendo pra isso).
--
-- performance_score fica de fora da lista de campos protegidos de propósito:
-- ele é atualizado por fn_sync_performance_score (trigger disparada por
-- points_ledger, sql/004_performance_score.sql) rodando no contexto de
-- fn_complete_lesson/fn_award_points_on_pass — não é o dono do perfil
-- editando a si mesmo diretamente, e bloquear essa coluna quebraria o
-- ciclo fechado de conclusão de lição.
-- ============================================================================

create or replace function fn_guard_profile_self_update()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if fn_is_admin() then
    return new;
  end if;

  if new.role_id       is distinct from old.role_id
     or new.store_id    is distinct from old.store_id
     or new.brand_id    is distinct from old.brand_id
     or new.status      is distinct from old.status
     or new.deleted_at  is distinct from old.deleted_at
     or new.username    is distinct from old.username
  then
    raise exception 'apenas administradores podem alterar cargo, loja, marca, status ou usuário de um perfil';
  end if;

  return new;
end;
$$;

comment on function fn_guard_profile_self_update() is
  'Bloqueia auto-promoção/auto-transferência: só fn_is_admin() pode mudar role_id/store_id/brand_id/status/deleted_at/username via UPDATE em profiles.';

drop trigger if exists trg_guard_profile_self_update on profiles;
create trigger trg_guard_profile_self_update
before update on profiles
for each row execute function fn_guard_profile_self_update();

-- ============================================================================
-- FIM DA MIGRAÇÃO 008
-- ============================================================================
