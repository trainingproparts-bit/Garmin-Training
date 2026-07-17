-- ============================================================================
-- GARMIN TRAINING HUB — EXEMPLO DE DML: Homologação Semanal
-- ============================================================================
-- As tabelas ciclos_semanais / ciclo_conteudos / assinaturas_lideres JÁ
-- EXISTEM em produção — foram criadas e aplicadas em sql/048_homologacao_
-- semanal.sql (nesta mesma sessão), junto com blog_reads e as funções
-- fn_ciclo_itens_progresso / fn_assinar_ciclo. Isso NÃO é uma migração nova
-- — é só um exemplo de DML ilustrativo, usando IDs reais do banco atual,
-- pra mostrar o formato esperado de inserção manual (o fluxo normal é pelo
-- painel "Homologação Semanal" do Admin, não INSERT direto).
--
-- IDs usados abaixo (conferidos no banco no momento em que este arquivo foi
-- escrito — troque pelos ids reais do momento em que for rodar de verdade,
-- eles podem não existir mais ou ter mudado):
--   loja Morumbi (Garmin):      72c04f2c-1659-45d6-8683-54557246ecbc
--   módulo "Garmin Connect":    478e1177-c66a-4f19-adfc-e5e7ed9a605c
--   quiz "Módulo 1 — Universo": 746043c7-4efe-465a-b270-d13b24dc0725
--   game "Duelo Instinct 3":    b178c498-ec5b-4cff-843e-4fcf3ca8c0c6
--   líder da Morumbi:           b66e7a9c-b551-4263-a601-2195b1a9ed7c (Ailma Almeida)
--
-- NÃO rode isto direto em produção sem revisar os IDs — vira um ciclo
-- semanal real e visível pro líder assinar.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Criar o ciclo da semana pra uma loja
-- ----------------------------------------------------------------------------
insert into public.ciclos_semanais (store_id, data_inicio, data_fim, status)
values (
  '72c04f2c-1659-45d6-8683-54557246ecbc', -- Morumbi (Garmin)
  '2026-07-17',                            -- sexta
  '2026-07-24',                            -- sexta seguinte
  'ativo'
)
returning id; -- guarde esse id pra usar no passo 2 e 3

-- ----------------------------------------------------------------------------
-- 2. Marcar os conteúdos avulsos que valem nesta semana
--    (troque :ciclo_id pelo id devolvido no passo 1)
-- ----------------------------------------------------------------------------
insert into public.ciclo_conteudos (ciclo_id, tipo_conteudo, conteudo_id)
values
  (:'ciclo_id', 'modulo', '478e1177-c66a-4f19-adfc-e5e7ed9a605c'), -- Módulo: Garmin Connect
  (:'ciclo_id', 'quiz',   '746043c7-4efe-465a-b270-d13b24dc0725'), -- Quiz: Módulo 1 — Universo Garmin
  (:'ciclo_id', 'game',   'b178c498-ec5b-4cff-843e-4fcf3ca8c0c6'); -- Game: Duelo Instinct 3 vs Instinct E
  -- tipo 'blog' funciona igual, apontando pro id de um blog_posts publicado

-- ----------------------------------------------------------------------------
-- 3. Consultar o progresso por item (mesma função que a UI usa)
-- ----------------------------------------------------------------------------
select * from fn_ciclo_itens_progresso(:'ciclo_id');

-- ----------------------------------------------------------------------------
-- 4. Assinatura do líder — NUNCA por INSERT direto (a tabela não tem policy
--    de INSERT pro authenticated de propósito). Só via RPC, autenticado
--    como o próprio líder, e só funciona de sexta 00:00 a segunda 23:59:
-- ----------------------------------------------------------------------------
-- select fn_assinar_ciclo(:'ciclo_id', null, 'Confirmo que revisei o progresso da equipe.');
