-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 034: Revoga EXECUTE de RPCs internas
-- ============================================================================
-- Achado ao rodar o advisor de segurança do Supabase depois de aplicar
-- sql/033 (Engine de Streak): funções SECURITY DEFINER que só deveriam ser
-- chamadas por trigger/por outra função SECURITY DEFINER continuavam com
-- EXECUTE concedido a `anon`/`authenticated` (grant padrão do Postgres pra
-- toda função nova, a menos que seja revogado explicitamente — mesmo
-- problema que sql/016 já tinha fechado pra fn_admin_finalize_new_profile).
--
-- Sem essa revogação, qualquer usuário autenticado (ou até anônimo) podia
-- chamar essas funções direto via PostgREST (`/rest/v1/rpc/<nome>`) com um
-- `p_user_id` arbitrário e, por exemplo, conceder a si mesmo (ou a
-- qualquer outro usuário) o badge que quisesse, sem nenhuma checagem —
-- `fn_grant_badge`/`fn_grant_badge_on_certification`/
-- `fn_grant_badge_on_quiz_100` (sql/023, PRÉ-EXISTENTE, não introduzido
-- nesta migração) tinham exatamente essa lacuna. As `fn_touch_streak*`
-- (sql/033, introduzidas nesta sessão) nasceram com o mesmo problema —
-- corrigido aqui antes de ganhar uso real.
--
-- Revogar EXECUTE de anon/authenticated não quebra nada: trigger e chamada
-- função-a-função (`perform fn_x(...)` de dentro de outra SECURITY DEFINER)
-- rodam com o privilégio de quem é DONO da função (postgres), não do papel
-- que originou o evento — mesmo raciocínio já documentado em sql/016 pra
-- fn_admin_finalize_new_profile.
-- ============================================================================

revoke execute on function public.fn_grant_badge(uuid, text) from anon, authenticated;
revoke execute on function public.fn_grant_badge_on_certification() from anon, authenticated;
revoke execute on function public.fn_grant_badge_on_quiz_100() from anon, authenticated;

revoke execute on function public.fn_touch_streak(uuid) from anon, authenticated;
revoke execute on function public.fn_touch_streak_on_lesson() from anon, authenticated;
revoke execute on function public.fn_touch_streak_on_quiz() from anon, authenticated;
revoke execute on function public.fn_touch_streak_on_game() from anon, authenticated;
revoke execute on function public.fn_touch_streak_on_evaluation() from anon, authenticated;

comment on function public.fn_grant_badge(uuid, text) is
  'Concede um badge pelo tipo (ex.: ''explorer'') resolvendo a marca do próprio perfil — badges.slug leva sufixo de marca (sql/022). Idempotente (uq_user_badges); grava em user_badges, que já dispara o post automático no Mural (trg_post_activity_badge_earned, sql/022). EXECUTE revogado de anon/authenticated (sql/034) — só chamada por trigger/outra função SECURITY DEFINER, nunca direto pelo cliente.';

comment on function public.fn_touch_streak(uuid) is
  'Recalcula streaks de forma reativa (sem job diário): incrementa se a última atividade foi ontem (ou sexta, se hoje é segunda/sábado/domingo — pausa de fim de semana, RN §6.5), senão reseta pra 1. A cada múltiplo de 5 dias posta marco no Mural e, no 5º dia, concede o badge Ritmo Constante (fn_grant_badge, sql/023). EXECUTE revogado de anon/authenticated (sql/034) — só chamada pelas 4 triggers de atividade (lição/quiz/game/avaliação), nunca direto pelo cliente com um p_user_id arbitrário.';

-- ============================================================================
-- FIM DA MIGRAÇÃO 034
-- ============================================================================
