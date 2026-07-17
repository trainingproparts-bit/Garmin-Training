-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 009: cria profile automaticamente no signup
-- ============================================================================
-- Causa raiz confirmada em sessão de diagnóstico anterior (2026-07-09):
-- nunca existiu trigger AFTER INSERT ON auth.users, nem função equivalente,
-- nem policy de INSERT em profiles. Os 14 usuários hoje em auth.users foram
-- criados sem contrapartida em public.profiles — não é regressão, é peça que
-- faltou desde a modelagem original (garmin_training_hub_migrations.sql
-- seção 2.1 já dizia "Nó central do grafo", mas nada preenchia essa tabela).
--
-- DECISÃO PENDENTE DE CONFIRMAÇÃO (ver conversa): profiles.role_id é
-- `not null` no schema (garmin_training_hub_migrations.sql:105) e só existe
-- catálogo fechado para 3 papéis (collaborator/leader/admin — sem opção
-- "pendente/sem papel"). Isso conflita com o pedido de deixar role_id nulo
-- para usuário novo. Esta versão usa role_id = 1 (collaborator, menor
-- privilégio) como default no signup — consistente com a regra já aplicada
-- em 008 de que só admin promove alguém — e o admin ajusta depois pelo
-- Painel Admin. Ajustar aqui se a decisão for outra.
-- ============================================================================

create or replace function fn_handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_username  text;
  v_full_name text;
begin
  v_username := coalesce(
    nullif(trim(new.raw_user_meta_data->>'username'), ''),
    split_part(new.email, '@', 1)
  );
  v_full_name := coalesce(
    nullif(trim(new.raw_user_meta_data->>'full_name'), ''),
    v_username
  );

  insert into public.profiles (id, full_name, username, role_id)
  values (new.id, v_full_name, v_username, 1)
  on conflict (id) do nothing;

  return new;
end;
$$;

comment on function fn_handle_new_user() is
  'Cria a linha correspondente em public.profiles no momento do signup em auth.users. Sem isso, profiles fica órfão (achado do diagnóstico de 2026-07-09).';

drop trigger if exists trg_handle_new_user on auth.users;
create trigger trg_handle_new_user
after insert on auth.users
for each row execute function fn_handle_new_user();

-- ============================================================================
-- Nenhuma policy profiles_insert_own foi adicionada de propósito: a trigger
-- roda SECURITY DEFINER e já cobre o caminho legítimo. Abrir INSERT direto
-- pelo cliente reabriria a mesma classe de risco fechada em 008 (a trigger
-- de guarda ali só cobre UPDATE, não INSERT) e contraria o princípio já
-- estabelecido no projeto de que gravação sensível a papel/loja nunca é
-- client-side. Se o time decidir que precisa mesmo assim, avaliar com uma
-- policy que force role_id = 1 via CHECK, não uma policy aberta.
-- ============================================================================

-- ============================================================================
-- FIM DA MIGRAÇÃO 009
-- ============================================================================
