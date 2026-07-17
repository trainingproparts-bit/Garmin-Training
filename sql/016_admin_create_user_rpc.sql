-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 016: RPC de apoio ao cadastro de usuário
-- ============================================================================
-- Cadastro de usuário pelo admin (RN 1.1) precisa da Supabase Admin API
-- (auth.admin.createUser), que só roda com service role key — nunca no
-- navegador. Isso vira uma Edge Function (supabase/functions/
-- admin-create-user). O trigger trg_handle_new_user (009) já cria o profile
-- automaticamente no INSERT em auth.users, com full_name/username vindos de
-- raw_user_meta_data (a Edge Function passa isso na criação) e role_id=1
-- (collaborator) fixo — mas quem está criando pode escolher outro papel/
-- loja/marca, e trg_guard_profile_self_update (008) bloqueia justamente
-- essa troca (role_id/store_id/brand_id) pra quem não é admin.
--
-- Problema: a Edge Function chama a API via service role, que não carrega
-- JWT nenhum — auth.uid() fica null nessa conexão, então fn_is_admin()
-- (usada pelo trigger 008) sempre retornaria false, bloqueando até um
-- admin de verdade de finalizar o cadastro.
--
-- Solução: esta função recebe o id de quem está pedindo a ação
-- (p_actor_id, já validado pela própria Edge Function via JWT do chamador
-- antes de chegar aqui) e simula a identidade dele só para esta transação
-- (set_config('request.jwt.claims', ..., true) — "true" = escopo local à
-- transação, desfeito sozinho no commit). fn_is_admin() então faz a checagem
-- de verdade contra profiles/roles, revalidando no servidor que p_actor_id
-- É mesmo admin — não é um bypass cego. EXECUTE é revogado de anon/
-- authenticated de propósito: só service_role (a Edge Function) pode chamar
-- isto; um colaborador não pode invocar via /rest/v1/rpc passando o id de
-- outra pessoa para se passar por admin.
-- ============================================================================

create or replace function public.fn_admin_finalize_new_profile(
  p_actor_id  uuid,
  p_new_user_id uuid,
  p_role_id   smallint,
  p_store_id  uuid,
  p_brand_id  uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  perform set_config('request.jwt.claims', json_build_object('sub', p_actor_id)::text, true);

  if not fn_is_admin() then
    raise exception 'apenas administradores podem cadastrar usuários';
  end if;

  update public.profiles
  set role_id  = p_role_id,
      store_id = p_store_id,
      brand_id = p_brand_id
  where id = p_new_user_id;
end;
$$;

comment on function public.fn_admin_finalize_new_profile(uuid, uuid, smallint, uuid, uuid) is
  'Chamada só pela Edge Function admin-create-user (service role) logo após auth.admin.createUser. Ajusta role_id/store_id/brand_id do profile recém-criado pelo trigger 009, revalidando no servidor que p_actor_id é admin de verdade.';

revoke all on function public.fn_admin_finalize_new_profile(uuid, uuid, smallint, uuid, uuid) from public, anon, authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 016
-- ============================================================================
