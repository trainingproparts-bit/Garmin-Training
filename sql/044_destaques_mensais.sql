-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 044: destaques_mensais (Destaques do Mês)
-- ============================================================================
-- Pedido do usuário: seção "Destaques do Mês" no topo do Dashboard do Líder
-- com 3 cards preenchidos manualmente (não calculados automaticamente por
-- nenhuma métrica real hoje — não existe campo de "avaliação Google" nem
-- ranking de vendas por valor no schema, só o que o líder digitar):
--   1. Melhor Vendedor Moema
--   2. Melhor Vendedor Morumbi
--   3. Mais Avaliado no Google do Mês (+ contagem opcional de avaliações)
--
-- Um registro por mês de referência (mes_referencia, formato 'YYYY-MM').
-- Cada destaque guarda tanto o id do colaborador (FK profiles, nullable)
-- quanto um nome-texto (fallback): quando o líder escolhe alguém do
-- dropdown, o client grava os dois (id + nome espelhado, ver
-- liderDashboard.js) — assim o card mostra sempre um nome, mesmo que o
-- colaborador seja desativado depois, e também aceita texto 100% livre
-- (ex.: "Cliente do balcão", pessoa que não tem perfil no sistema).
-- ============================================================================

create table if not exists public.destaques_mensais (
  id                        uuid primary key default gen_random_uuid(),
  mes_referencia            text not null unique,
  vendedor_moema_id         uuid references public.profiles(id) on delete set null,
  vendedor_moema_nome       text,
  vendedor_morumbi_id       uuid references public.profiles(id) on delete set null,
  vendedor_morumbi_nome     text,
  google_destaque_id        uuid references public.profiles(id) on delete set null,
  google_destaque_nome      text,
  total_avaliacoes_google   integer,
  updated_at                timestamptz not null default now(),
  constraint chk_destaques_mensais_mes_formato check (mes_referencia ~ '^\d{4}-\d{2}$')
);

comment on table public.destaques_mensais is
  'Destaques do Mês do Dashboard do Líder — preenchimento 100% manual (líder/admin), um registro por mes_referencia (YYYY-MM). Cada destaque tem id (FK profiles, opcional) + nome-texto (sempre preenchido, espelhado do perfil escolhido ou digitado livremente).';

-- Segurança: mesma visibilidade de qualquer dado do Dashboard do Líder —
-- líder ou admin, sem escopo de loja (o board mostra Moema E Morumbi juntos
-- de propósito, é um mural de reconhecimento cross-loja, não um relatório
-- por loja). RLS de verdade (ao contrário das views vw_*/v_* deste projeto,
-- que não suportam policy) — aqui dá pra usar policy normal por ser tabela.
alter table public.destaques_mensais enable row level security;

drop policy if exists destaques_mensais_select on public.destaques_mensais;
create policy destaques_mensais_select on public.destaques_mensais
  for select using (fn_is_admin() or fn_is_leader());

drop policy if exists destaques_mensais_upsert on public.destaques_mensais;
create policy destaques_mensais_upsert on public.destaques_mensais
  for all using (fn_is_admin() or fn_is_leader())
  with check (fn_is_admin() or fn_is_leader());

grant select, insert, update on public.destaques_mensais to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 044
-- ============================================================================
