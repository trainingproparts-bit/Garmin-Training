-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 010: backfill de profiles/stores/store_leaders
-- ============================================================================
-- Contexto (2026-07-09): o trigger trg_handle_new_user (009) só cobre signups
-- NOVOS. Os 14 usuários que já existiam em auth.users antes do trigger nunca
-- ganharam profile. Este backfill é pontual, feito à mão com dados confirmados
-- pelo usuário (nomes/papéis/lojas reais; os e-mails de auth.users são
-- placeholders internos, não os e-mails reais das pessoas).
--
-- Decisões confirmadas na conversa:
-- - Multi-marca: stores.brand_id é obrigatório e UNIQUE(brand_id, code); não
--   existe (nem foi criada aqui) a tabela profile_brands que a modelagem
--   original cogitou. Solução pragmática: cada local físico (Morumbi, Moema)
--   virou 2 linhas de loja, uma por marca (Garmin/Shokz), já que as duas
--   marcas convivem na mesma loja física mas o schema atual não representa
--   isso numa linha só. Revisitar com profile_brands se Shokz virar
--   treinamento real.
-- - Os 3 admins (Samara, Mariana, Salomão) enxergam as duas marcas:
--   brand_id/store_id ficam NULL para eles.
-- - Os 11 não-admin ficam todos na loja-Garmin do seu local por padrão.
-- - Morumbi-Garmin fica com 2 líderes (Ailma Almeida e Mayara Freire) —
--   confirmado como intencional, store_leaders é N:N.
-- - username segue o mesmo padrão do fn_handle_new_user (local-part do
--   e-mail real de auth.users).
--
-- IMPORTANTE — rodar em DUAS transações, nesta ordem. Testado ao vivo: uma
-- única instrução WITH com todos os INSERTs falha, porque
-- fn_check_store_leader_role() (trigger de store_leaders) valida o role_id
-- do profile lendo public.profiles, e um data-modifying CTE não vê o que
-- outro data-modifying CTE gravou dentro do mesmo comando (regra do
-- Postgres para WITH, não é bug daqui). Erro visto:
--   "O usuário ... não possui papel de Líder e não pode ser vinculado a uma
--   loja como líder" — mesmo o profile tendo role_id=2, porque a leitura do
--   trigger usava o snapshot de antes do insert de new_profiles.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Passo 1/2 — cria as 4 linhas de loja e os 14 profiles (uma transação só)
-- ---------------------------------------------------------------------------
with garmin as (
  select id from public.brands where slug = 'garmin'
), shokz as (
  select id from public.brands where slug = 'shokz'
), new_stores as (
  insert into public.stores (brand_id, name, code)
  select id, 'Morumbi', 'MORUMBI' from garmin
  union all
  select id, 'Morumbi', 'MORUMBI' from shokz
  union all
  select id, 'Moema', 'MOEMA' from garmin
  union all
  select id, 'Moema', 'MOEMA' from shokz
  returning id, brand_id, name
), morumbi_garmin as (
  select ns.id from new_stores ns, garmin g where ns.name = 'Morumbi' and ns.brand_id = g.id
), moema_garmin as (
  select ns.id from new_stores ns, garmin g where ns.name = 'Moema' and ns.brand_id = g.id
)
insert into public.profiles (id, brand_id, store_id, role_id, full_name, username)
values
  ('832a81e4-799b-4f39-ac52-547ce8213ed6', null, null, 3, 'Samara Pereira', 'samarapereira'),
  ('6ae99023-4f5e-4d30-9076-f801e2194a3a', null, null, 3, 'Mariana Muzzio', 'marianamuzzio'),
  ('b66e7a9c-b551-4263-a601-2195b1a9ed7c', (select id from garmin), (select id from morumbi_garmin), 2, 'Ailma Almeida', 'ailma.almeida'),
  ('4c2a3fd8-cff0-441c-af4f-19ae5c003a8b', (select id from garmin), (select id from morumbi_garmin), 1, 'Daniel Lucena', 'daniel'),
  ('cd736e18-06ab-4ac2-8cb6-f4704d09c1da', (select id from garmin), (select id from morumbi_garmin), 1, 'Fabio Borges', 'fabioborges'),
  ('e60cc6bc-5bb3-4561-8fb5-0be2f3dd3202', (select id from garmin), (select id from morumbi_garmin), 1, 'Gustavo Morais', 'gustavomorais'),
  ('9d77da37-2b6c-4b0f-a2b5-2c11129d68dd', (select id from garmin), (select id from morumbi_garmin), 2, 'Mayara Freire', 'mayara.freire'),
  ('8262d1ec-7383-4380-8dbf-ed3dc44becbb', (select id from garmin), (select id from morumbi_garmin), 1, 'Renato Dias', 'renatodias'),
  ('9244ad95-870f-4502-a216-17ff1dd7514b', (select id from garmin), (select id from moema_garmin), 1, 'Beatriz', 'beatriz'),
  ('236d1e5a-abf5-47d1-9163-18b171ab191b', (select id from garmin), (select id from moema_garmin), 1, 'Dayane Sousa', 'dayane'),
  ('3bcff82d-ad19-4152-9c03-fb21a28a2afd', (select id from garmin), (select id from moema_garmin), 1, 'William', 'william'),
  ('94d2dbc5-d942-4e39-9a13-8b958ff5dbdd', null, null, 3, 'Salomão Setton', 'salomaosetton'),
  ('f5649522-ee8b-4b9b-8347-568cf9d521d3', (select id from garmin), (select id from moema_garmin), 2, 'Ribli Silva', 'ribs'),
  ('390a153c-1253-441a-841c-3aaff7bdb3d5', (select id from garmin), (select id from morumbi_garmin), 1, 'Joyce Souza', 'joycesouza');

-- ---------------------------------------------------------------------------
-- Passo 2/2 — vincula os líderes às lojas (transação separada, depois que os
-- profiles do passo 1 já estão commitados e visíveis para o trigger de
-- validação de papel).
-- ---------------------------------------------------------------------------
with morumbi_garmin as (
  select s.id from public.stores s
  join public.brands b on b.id = s.brand_id
  where s.name = 'Morumbi' and b.slug = 'garmin'
), moema_garmin as (
  select s.id from public.stores s
  join public.brands b on b.id = s.brand_id
  where s.name = 'Moema' and b.slug = 'garmin'
)
insert into public.store_leaders (leader_id, store_id)
select 'b66e7a9c-b551-4263-a601-2195b1a9ed7c'::uuid, id from morumbi_garmin
union all
select '9d77da37-2b6c-4b0f-a2b5-2c11129d68dd'::uuid, id from morumbi_garmin
union all
select 'f5649522-ee8b-4b9b-8347-568cf9d521d3'::uuid, id from moema_garmin;

-- ============================================================================
-- FIM DA MIGRAÇÃO 010 — aplicado em produção (project_id gnxglqjrvnetkbmzetfc)
-- em 2026-07-09. Resultado verificado: auth.users=14, profiles=14, stores=4,
-- store_leaders=3.
-- ============================================================================
