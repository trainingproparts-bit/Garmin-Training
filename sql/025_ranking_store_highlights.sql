-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 025: Ranking + Destaque de Vendas por Loja
-- ============================================================================
-- Ranking de pontos (RN §6.4) implementado como visão AO VIVO a partir de
-- profiles.performance_score (já é o total acumulado real, sql/004) — sem
-- temporada trimestral, snapshot em `leaderboard` nem medalhas (RN §6.6),
-- que exigiriam uma tabela de temporadas e um job periódico. Fica pra uma
-- rodada futura, decidido com o usuário em 2026-07-10.
--
-- Destaque de Vendas por loja: pedido explícito do usuário — um texto curto
-- por loja, atualizado manualmente todo mês por Admin ou pelo Líder daquela
-- loja (mesmo escopo de gestão do Dashboard do Líder). Não guarda histórico
-- mês a mês de propósito — é sempre o destaque "atual", sobrescrito na
-- próxima atualização (1 linha por loja, uq_store_sales_highlights_store).
-- ============================================================================

create table if not exists public.store_sales_highlights (
  id          uuid primary key default gen_random_uuid(),
  store_id    uuid not null references public.stores(id) on delete cascade,
  message     text not null,
  updated_by  uuid references public.profiles(id) on delete set null,
  updated_at  timestamptz not null default now(),
  constraint uq_store_sales_highlights_store unique (store_id)
);

comment on table public.store_sales_highlights is
  'Destaque de vendas do mês por loja — texto livre, atualizado manualmente por admin/líder (RN não documenta isso; pedido direto do usuário em 2026-07-10). 1 linha por loja, sem histórico — cada atualização substitui a anterior.';

alter table public.store_sales_highlights enable row level security;

-- Leitura: qualquer autenticado da mesma marca da loja (ou admin, vê tudo).
drop policy if exists store_highlights_select_all on public.store_sales_highlights;
create policy store_highlights_select_all on public.store_sales_highlights
  for select using (
    fn_is_admin()
    or exists (
      select 1 from public.stores s
       where s.id = store_sales_highlights.store_id
         and s.brand_id = (select brand_id from public.profiles where id = auth.uid())
    )
  );

drop policy if exists store_highlights_admin_all on public.store_sales_highlights;
create policy store_highlights_admin_all on public.store_sales_highlights
  for all using (fn_is_admin()) with check (fn_is_admin());

-- Líder só edita destaque das lojas sob sua gestão (mesma função já usada
-- pelo Dashboard do Líder e pelo Mural, sql/013/022).
drop policy if exists store_highlights_leader_manage on public.store_sales_highlights;
create policy store_highlights_leader_manage on public.store_sales_highlights
  for all using (fn_is_leader() and store_id in (select fn_leader_store_ids()))
  with check (fn_is_leader() and store_id in (select fn_leader_store_ids()));

grant select, insert, update on public.store_sales_highlights to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 025
-- ============================================================================
