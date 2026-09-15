-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 117: Fecha lacuna de autorização em
-- fn_soft_delete_profile antes do primeiro uso real pelo cliente
-- ============================================================================
-- Achado ao implementar o botão "Remover usuário" no Painel Admin:
-- fn_soft_delete_profile(p_profile_id, p_actor_id) já existia no schema base
-- (garmin_training_hub_migrations.sql, item 11.8) mas nunca tinha sido
-- chamada por nenhum código do cliente — e por isso nunca tinha passado pelo
-- mesmo escrutínio de segurança que achou o mesmo tipo de bug em sql/034/036
-- (fn_grant_badge*/fn_touch_streak*): SECURITY DEFINER, recebe o id de
-- QUALQUER perfil como parâmetro, sem nenhuma checagem interna de quem está
-- chamando — e toda função nova recebe EXECUTE de PUBLIC por padrão
-- (confirmado em sql/036), que authenticated herda implicitamente. Sem esta
-- correção, qualquer usuário autenticado (colaborador comum) poderia chamar
-- a RPC direto via PostgREST com o id de qualquer colega (ou de um admin) e
-- desativar a conta dele.
--
-- Diferença em relação a sql/034 (que apenas revogou EXECUTE porque aquelas
-- funções só deveriam rodar via trigger): fn_soft_delete_profile PRECISA ser
-- chamável pelo cliente autenticado (é a ação do botão "Remover" do admin),
-- então a correção aqui é adicionar a checagem de admin dentro da própria
-- função — mesmo padrão de defesa em profundidade já usado nas policies RLS
-- (`fn_is_admin()`), só que agora também dentro do corpo SECURITY DEFINER,
-- que ignora RLS por definição.
--
-- Também removido o parâmetro p_actor_id: o cliente podia mandar qualquer
-- uuid ali e o log de auditoria (activity_log) registraria autoria falsa.
-- A função agora usa auth.uid() internamente, e adiciona uma trava para
-- impedir que um admin remova a própria conta por engano (ficaria sem
-- acesso ao próprio painel para reverter).
-- ============================================================================

drop function if exists fn_soft_delete_profile(uuid, uuid);

create or replace function fn_soft_delete_profile(p_profile_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not fn_is_admin() then
    raise exception 'Apenas administradores podem remover usuários.';
  end if;

  if p_profile_id = auth.uid() then
    raise exception 'Você não pode remover a própria conta.';
  end if;

  update profiles
     set status = 'inactive',
         deleted_at = now(),
         updated_at = now()
   where id = p_profile_id
     and deleted_at is null;

  insert into activity_log (actor_id, subject_id, event_type, payload)
  values (auth.uid(), p_profile_id, 'profile_soft_deleted', jsonb_build_object('at', now()));
end;
$$;

revoke execute on function fn_soft_delete_profile(uuid) from public, anon;
grant execute on function fn_soft_delete_profile(uuid) to authenticated;

comment on function fn_soft_delete_profile(uuid) is
  'Desligamento de colaborador: soft delete, nunca DELETE físico. Preserva histórico e certificações. Só executável por admin (checagem interna, sql/117) — auth.uid() usado como ator do log, nunca um valor mandado pelo cliente; bloqueia autoremoção.';

-- ============================================================================
-- FIM DA MIGRAÇÃO 117
-- ============================================================================
