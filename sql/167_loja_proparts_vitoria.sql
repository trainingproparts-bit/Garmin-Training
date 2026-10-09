-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 167: unidade Proparts (escritório)
-- ============================================================================
-- Pedido do usuário (2026-09-16): "a vitoria ribeiro ta como moema mas ela
-- deveria estar como proparts, pq tem a galera do escritório".
--
-- Diagnóstico antes de escrever: as lojas não eram duplicadas como parecia.
-- Existe uma Moema e uma Morumbi PARA CADA MARCA (Garmin e Shokz). A Vitória
-- estava amarrada à Moema da SHOKZ, sozinha, enquanto toda a operação vive
-- nas lojas da Garmin — era esse o desencontro, não o nome da loja.
--
-- O resto do escritório (Caiê, Mariana, Salomão, Samara) está com store_id
-- nulo. O usuário escolheu criar a unidade Proparts e mover só a Vitória
-- agora; os demais seguem sem loja até ela decidir.
--
-- Marca: uma única Proparts na Garmin (escolha do usuário), que é onde está
-- toda a operação hoje. `brand_id` é NOT NULL, então não dá pra criar uma
-- unidade "sem marca".
--
-- Efeito colateral esperado e desejado: Proparts NÃO entra no "Ponta do mês"
-- da Dashboard, que lista lojas fixas (DESTAQUE_STORES = ['Moema','Morumbi']
-- em DashboardHome.js). Escritório não é piso de venda, então não concorre
-- no destaque por loja.
-- ============================================================================

insert into stores (brand_id, name, code, is_active)
select '2f7d8451-b279-4d69-8192-6ac9953d7da1', 'Proparts', 'PROPARTS', true
where not exists (select 1 from stores where code = 'PROPARTS');

-- trg_guard_profile_self_update bloqueia mudança de loja pra quem não é
-- admin (fn_is_admin()), e uma migração roda sem sessão de usuário, então
-- nunca passaria nesse teste. O guard existe pra impedir que alguém troque a
-- própria loja pelo app — não pra impedir correção de cadastro via migração.
-- Desabilitar aqui é transacional: se qualquer coisa abaixo falhar, o
-- rollback devolve o trigger junto.
alter table profiles disable trigger trg_guard_profile_self_update;

update profiles
set store_id = (select id from stores where code = 'PROPARTS')
where username = 'vitoria.ribeiro';

alter table profiles enable trigger trg_guard_profile_self_update;

-- ============================================================================
-- FIM DA MIGRAÇÃO 167
-- ============================================================================
