-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 014: login por username sem expor domínio
-- ============================================================================
-- authService.js resolvia o e-mail adivinhando `${username}@proparts.net.br`.
-- Isso já quebrava pra quem tem e-mail real em outro domínio (Mariana/Mayara,
-- @proparts.esp.br) e nunca funcionaria pra quem ainda está no e-mail
-- placeholder interno (@proparts.internal, 10 dos 14 usuários) — e vazava
-- esse domínio interno na primeira tentativa de login que falhasse.
--
-- Esta função resolve username -> email real inteiramente no servidor, sem
-- nenhum domínio hardcoded no cliente. SECURITY DEFINER porque `anon` (antes
-- do login) não tem acesso a auth.users; esta é a única porta estreita que
-- abre — devolve só o e-mail de um username exato, nada mais do schema de
-- auth. Chamada por src/services/authService.js:signIn().
-- ============================================================================

create or replace function public.fn_resolve_login_email(p_username text)
returns text
language sql
stable
security definer
set search_path = public
as $$
  select u.email
  from public.profiles p
  join auth.users u on u.id = p.id
  where p.username = p_username
    and p.deleted_at is null
  limit 1;
$$;

comment on function public.fn_resolve_login_email(text) is
  'Resolve username -> email real para o login por username (usuário nunca digita e-mail). SECURITY DEFINER: único caminho que expõe algo de auth.users para anon, e só o e-mail correspondente a um username exato.';

revoke all on function public.fn_resolve_login_email(text) from public;
grant execute on function public.fn_resolve_login_email(text) to anon, authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 014 — aplicado e confirmado ao vivo em 2026-07-09.
-- ============================================================================
