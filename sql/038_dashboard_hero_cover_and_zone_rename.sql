-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 038: capa do Hero Card + renomear Zona Corredor
-- ============================================================================
-- Pedido direto do usuário (simplificação da tela "Minha Trilha"): o card
-- "GPS da Carreira" (Hero Card) ganha suporte a imagem de capa em tela cheia,
-- mesmo padrão de modules/quizzes (sql/027) — coluna nullable, aditiva, admin
-- edita via prompt na UI. E a zona hoje chamada "Zona Corredor" passa a se
-- chamar "Zona Atleta" (só o nome da zona — certificação "Corredor" e os
-- slugs de módulo corredor-connect/corredor-coach não mudam, fora de escopo
-- deste pedido).
-- ============================================================================

alter table public.trails add column if not exists cover_url text;

comment on column public.trails.cover_url is
  'URL de capa opcional em tela cheia pro Hero Card ("GPS da Carreira") na tela Minha Trilha. Null = mantém o gradiente escuro padrão. Só admin edita (trails_admin_all).';

update public.zones
set
  name = 'Zona Atleta',
  banner_message = 'Zona Atleta concluída! Você está pronto para a Zona Maratonista.'
where name = 'Zona Corredor';

update public.zones
set banner_message = 'Zona Explorador concluída! Você abriu a Zona Atleta.'
where name = 'Zona Explorador' and banner_message = 'Zona Explorador concluída! Você abriu a Zona Corredor.';

-- ============================================================================
-- FIM DA MIGRAÇÃO 038
-- ============================================================================
