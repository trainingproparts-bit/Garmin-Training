-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 051: cover_url em games
-- ============================================================================
-- Redesign "Arena de Desafios" (unificação de Quizzes Extras + Games num só
-- painel): o card de Duelo ganhou o mesmo tratamento de capa opcional que
-- modules/quizzes já tinham (sql/027) — hoje games não tinha a coluna porque
-- games.js nunca teve nenhum tratamento visual de capa. Nullable e aditiva,
-- zero risco pros dados existentes. RLS já cobre UPDATE via games_admin_all
-- (ALL, sql base) — não precisa de policy nova.
-- ============================================================================

alter table public.games add column if not exists cover_url text;

comment on column public.games.cover_url is
  'URL de capa opcional pro card 16:9 do Duelo na Arena de Desafios. Null = mostra gradiente split "VS" placeholder. Só admin edita (games_admin_all).';

-- ============================================================================
-- FIM DA MIGRAÇÃO 051
-- ============================================================================
