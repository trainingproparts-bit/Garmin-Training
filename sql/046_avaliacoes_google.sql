-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 046: avaliacoes_google
-- ============================================================================
-- "Melhor reputação" no card Destaques do Mês (Dashboard Principal) usava
-- profiles.reputation_score — um único número estático (sql/037), sem data
-- nenhuma por trás. Isso fazia o card sempre mostrar "a reputação atual de
-- alguém", nunca "quem se destacou ESTE MÊS" — inconsistente com os outros
-- 2 destaques ("Ponta do Mês"), que ao menos são recurados manualmente todo
-- mês. Pedido do usuário: virar um recorte mensal de verdade.
--
-- Uma linha por avaliação Google individual (data real), preenchida
-- manualmente pelo admin (não existe integração com a API do Google — RN
-- confirmada 2 rodadas atrás: "quem gerencia é o ADMIN"). "Melhor reputação
-- do mês" passa a ser contagem de avaliações com data_avaliacao dentro do
-- mês corrente, por vendedor — client-side em DashboardHome.js, reaproveita
-- o mesmo array já buscado de v_team_album (já escopado por marca) em vez
-- de duplicar filtro de marca aqui.
--
-- profiles.reputation_score (Álbum da Equipe) continua existindo e editável
-- do jeito que já era — não é a mesma coisa, e este card não mexe nela.
-- ============================================================================

create table if not exists public.avaliacoes_google (
  id              uuid primary key default gen_random_uuid(),
  profile_id      uuid not null references public.profiles(id) on delete cascade,
  nota            integer check (nota between 1 and 5),
  data_avaliacao  date not null default current_date,
  observacao      text,
  created_at      timestamptz not null default now(),
  created_by      uuid references public.profiles(id) on delete set null
);

create index if not exists idx_avaliacoes_google_profile_data on public.avaliacoes_google(profile_id, data_avaliacao);

comment on table public.avaliacoes_google is
  'Avaliações Google registradas manualmente pelo admin (Vendedor + Data + Nota + observação/link) — sem integração real com a API do Google. Fonte de "Melhor reputação do mês" no Dashboard Principal (contagem de avaliações no mês corrente por vendedor).';

alter table public.avaliacoes_google enable row level security;

-- Leitura: mesmo padrão de escopo por marca já usado em v_team_album/
-- v_ranking_public (qualquer autenticado vê a própria marca; admin vê
-- tudo) — aqui é tabela de verdade (não view), então dá pra usar policy.
drop policy if exists avaliacoes_google_select on public.avaliacoes_google;
create policy avaliacoes_google_select on public.avaliacoes_google
  for select using (
    fn_is_admin()
    or exists (
      select 1
      from public.profiles avaliado
      where avaliado.id = avaliacoes_google.profile_id
        and avaliado.brand_id = (select brand_id from public.profiles where id = auth.uid())
    )
  );

-- Escrita: só admin (RN explícita do usuário — líder não gerencia isso).
drop policy if exists avaliacoes_google_admin_write on public.avaliacoes_google;
create policy avaliacoes_google_admin_write on public.avaliacoes_google
  for all using (fn_is_admin()) with check (fn_is_admin());

grant select, insert, update, delete on public.avaliacoes_google to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 046
-- ============================================================================
