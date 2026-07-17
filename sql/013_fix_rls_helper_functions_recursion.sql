-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 013: corrige recursão de RLS em fn_is_admin/
-- fn_is_leader/fn_leader_store_ids
-- ============================================================================
-- Achado ao testar o Painel Admin com login real de admin pela primeira vez
-- (2026-07-09) — nunca tinha sido exercitado de ponta a ponta antes:
--
--   ERROR: 54001 stack depth limit exceeded
--   HINT: Increase the configuration parameter "max_stack_depth"...
--
-- Causa: fn_is_admin()/fn_is_leader() fazem SELECT em `profiles`. As
-- policies de `profiles` (profiles_admin_all, profiles_select_leader) usam
-- essas mesmas funções na cláusula USING. Sem SECURITY DEFINER, o SELECT
-- interno da função roda com o mesmo papel/RLS de quem chamou — ou seja,
-- reabre a RLS de `profiles`, que chama a função de novo, que reabre a RLS
-- de novo... recursão real, não só "profunda". fn_leader_store_ids() sofre
-- o mesmo problema via `store_leaders` (cuja RLS também chama fn_is_admin()).
--
-- Isso bloqueava tanto o Painel Admin (lista de usuários) quanto o
-- Dashboard do Líder (fetchTeamMembers) — não é um bug introduzido por
-- nenhuma sprint recente, é estrutural desde a modelagem original
-- (garmin_training_hub_migrations.sql), só nunca tinha sido percorrido com
-- login de verdade.
--
-- Fix: padrão recomendado pelo próprio Supabase para esse exato caso —
-- marcar as funções auxiliares de RLS como SECURITY DEFINER (+ search_path
-- fixo). O corpo/retorno de cada função não muda; só passa a rodar com o
-- dono da função (que já tem bypass de RLS), quebrando o loop.
-- ============================================================================

create or replace function public.fn_is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from profiles p
    join roles r on r.id = p.role_id
    where p.id = auth.uid() and r.code = 'admin'
  );
$$;

create or replace function public.fn_is_leader()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from profiles p
    join roles r on r.id = p.role_id
    where p.id = auth.uid() and r.code = 'leader'
  );
$$;

create or replace function public.fn_leader_store_ids()
returns setof uuid
language sql
stable
security definer
set search_path = public
as $$
  select store_id from store_leaders where leader_id = auth.uid();
$$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 013 — aplicado e confirmado ao vivo em 2026-07-09.
-- ============================================================================
