-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 027: cover_url em modules/quizzes
-- ============================================================================
-- Redesign visual 2026-07-10 (cards 16:9 estilo streaming): nenhuma foto real
-- existe hoje pra módulos/quizzes/linhas especiais (nem no banco, nem em
-- Storage) — os cards mostram um gradiente + ícone até o admin colar uma URL
-- de capa de verdade. `content_library.payload` já é jsonb (capa fica em
-- payload.cover_url, sem migração); `modules`/`quizzes` são tabelas simples,
-- por isso a coluna nova aqui. Nullable e aditiva — zero risco pros dados
-- existentes. RLS já cobre UPDATE via modules_admin_all/quizzes_admin_all
-- (ALL, sql base) — não precisa de policy nova.
-- ============================================================================

alter table public.modules add column if not exists cover_url text;
alter table public.quizzes add column if not exists cover_url text;

comment on column public.modules.cover_url is
  'URL de capa opcional pro card 16:9 do módulo na trilha (redesign 2026-07-10). Null = mostra gradiente+ícone placeholder. Só admin edita (modules_admin_all).';
comment on column public.quizzes.cover_url is
  'URL de capa opcional pro card 16:9 do quiz (redesign 2026-07-10). Null = mostra gradiente+ícone placeholder. Só admin edita (quizzes_admin_all).';

-- ============================================================================
-- FIM DA MIGRAÇÃO 027
-- ============================================================================
