-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 036: Corrige revogação de EXECUTE incompleta
-- ============================================================================
-- sql/034 revogou EXECUTE de `anon`/`authenticated` em 8 funções internas
-- (fn_grant_badge* e fn_touch_streak*), e sql/035 tentou o mesmo pra
-- fn_award_points_on_game_finish — mas o `has_function_privilege` continuava
-- retornando true pras duas. Causa raiz: toda função nova recebe EXECUTE
-- concedido a PUBLIC automaticamente (comportamento padrão do Postgres,
-- ACL mostra `=X/postgres` — o "=" antes do "/" é a notação de PUBLIC).
-- `anon`/`authenticated` são papéis comuns e herdam qualquer privilégio de
-- PUBLIC implicitamente — revogar deles especificamente não tira nada
-- enquanto PUBLIC continuar com o grant. Precisa revogar de PUBLIC também.
--
-- Achado ao testar sql/035 ao vivo: fui conferir se o revoke anterior tinha
-- "pegado" de verdade antes de dar como resolvido, e não tinha.
-- ============================================================================

revoke execute on function public.fn_grant_badge(uuid, text) from public;
revoke execute on function public.fn_grant_badge_on_certification() from public;
revoke execute on function public.fn_grant_badge_on_quiz_100() from public;

revoke execute on function public.fn_touch_streak(uuid) from public;
revoke execute on function public.fn_touch_streak_on_lesson() from public;
revoke execute on function public.fn_touch_streak_on_quiz() from public;
revoke execute on function public.fn_touch_streak_on_game() from public;
revoke execute on function public.fn_touch_streak_on_evaluation() from public;

revoke execute on function public.fn_award_points_on_game_finish() from public;

-- ============================================================================
-- FIM DA MIGRAÇÃO 036
-- ============================================================================
