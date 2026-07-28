-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 113: corrige RLS de avaliacoes_google —
-- colaborador comum só enxergava as PRÓPRIAS avaliações, nunca as da equipe
-- ============================================================================
-- Bug reportado pelo usuário: "o site aparece que o mais avaliado do mês é a
-- pessoa que tá logada e não de fato o mais avaliado".
--
-- Causa raiz: a policy avaliacoes_google_select (sql/046) checava a marca do
-- AVALIADO assim:
--
--   exists (
--     select 1 from public.profiles avaliado
--     where avaliado.id = avaliacoes_google.profile_id
--       and avaliado.brand_id = (select brand_id from public.profiles where id = auth.uid())
--   )
--
-- Esse SELECT em `profiles avaliado` roda sob a RLS de profiles do PRÓPRIO
-- usuário que está consultando. Um colaborador comum só tem a policy
-- profiles_select_own (id = auth.uid()) — nunca profiles_select_leader nem
-- profiles_admin_all. Ou seja: pra qualquer profile_id que NÃO seja o do
-- próprio usuário logado, a subquery `avaliado.id = ...` nunca encontra a
-- linha (RLS de profiles já filtra ela fora antes mesmo do WHERE), então o
-- EXISTS só é verdadeiro quando profile_id = auth.uid() — o colaborador só
-- enxerga as próprias avaliações. DashboardHome.js.renderDestaquesPreview
-- então sempre calcula o "mais avaliado" a partir de um conjunto de 1 pessoa
-- (o próprio usuário logado), fazendo ele "vencer" por padrão sempre que tem
-- pelo menos 1 avaliação no mês, mesmo quando um colega tem mais.
--
-- Mesmo bug já resolvido antes pra fn_is_admin/fn_is_leader (sql/013, mesma
-- causa: leitura de profiles sem SECURITY DEFINER reabre a RLS de profiles).
-- Aqui o caso é ligeiramente diferente (não é recursão, é falta de
-- visibilidade cross-user), mas a correção é a mesma receita: mover a
-- checagem pra dentro de uma função SECURITY DEFINER, que roda com o dono da
-- função (bypassa RLS de profiles) em vez de com o papel de quem chamou.
--
-- Varredura confirmou que avaliacoes_google é a ÚNICA policy no schema que
-- precisa ler o profile de OUTRO usuário (não o do próprio auth.uid()) pra
-- decidir visibilidade — todas as outras políticas "_select_all"
-- (activity_feed, store_sales_highlights) só comparam contra o brand_id do
-- PRÓPRIO usuário logado (leitura permitida por profiles_select_own), e as
-- "_select_leader" já são gateadas por fn_is_leader(), que por sua vez já é
-- SECURITY DEFINER — não é um padrão repetido em outro lugar.
-- ============================================================================

create or replace function public.fn_same_brand_as_viewer(p_profile_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles viewer
    join public.profiles avaliado on avaliado.brand_id = viewer.brand_id
    where viewer.id = auth.uid() and avaliado.id = p_profile_id
  );
$$;

comment on function public.fn_same_brand_as_viewer(uuid) is
  'SECURITY DEFINER — checa se p_profile_id pertence à mesma marca do usuário autenticado, bypassando a RLS de profiles (que só libera leitura de linha própria pra colaborador comum). Extraído do bug de avaliacoes_google_select (sql/113): sem isso, qualquer policy que precise comparar a marca de OUTRO usuário (não o do auth.uid()) falha silenciosamente pra quem não é líder/admin.';

grant execute on function public.fn_same_brand_as_viewer(uuid) to authenticated;

drop policy if exists avaliacoes_google_select on public.avaliacoes_google;
create policy avaliacoes_google_select on public.avaliacoes_google
  for select using (
    fn_is_admin() or fn_same_brand_as_viewer(profile_id)
  );

-- ============================================================================
-- FIM DA MIGRAÇÃO 113
-- ============================================================================
