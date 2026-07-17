-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 040: corrige as opções de resposta do Duelo
-- ============================================================================
-- Bug real reportado pelo usuário: a tela de "Duelo de Especificações" só
-- mostrava 2 das 4 opções de resposta. Causa raiz: `GameRunner.js` montava os
-- botões a partir de `Object.keys(round.reveal)` (só os 2-3 concorrentes
-- comparados), ignorando `games.config.meta.opcoes_resposta` — que já define
-- o conjunto REAL de respostas válidas por jogo:
--   - "Duelo de Especificações" (1v1): instinct3, instincte, ambos, nenhum
--   - "Duelo MARQ Carbon" (3vias): golfer, athlete, commander, todos
-- Ou seja, os botões "Ambos"/"Nenhum"/"Todos" nunca existiam — mesmo a rodada
-- 9 do duelo 1v1 tendo `gabarito: "ambos"` (impossível de acertar de propósito
-- hoje, só por acidente, já que qualquer clique era aceito como certo nesse
-- caso, ver bug 2 abaixo).
--
-- Bug 2, no servidor: `fn_submit_game_round` também não sabia lidar com um
-- "nenhum"/"todos" de verdade — `v_is_correct := (v_gabarito = 'ambos') or
-- (p_chosen_key = v_winner_key)` tratava QUALQUER escolha como certa sempre
-- que o gabarito da rodada fosse "ambos", em vez de exigir que o usuário
-- realmente tivesse clicado em "Ambos". Corrigido pra comparação direta:
-- agora que o cliente manda o `chosen_key` no MESMO vocabulário de
-- `gabarito` (instinct3/instincte/ambos/nenhum, ou golfer/athlete/
-- commander/todos — não mais nas chaves abreviadas de `reveal`, i3/ie), a
-- checagem vira uma igualdade simples, sem mapa de tradução.
-- ============================================================================

create or replace function public.fn_submit_game_round(p_session_id uuid, p_round_index integer, p_chosen_key text)
returns boolean
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_owner_ok   boolean;
  v_gabarito   text;
  v_is_correct boolean;
begin
  select exists (
    select 1 from game_sessions
     where id = p_session_id
       and user_id = auth.uid()
       and finished_at is null
  ) into v_owner_ok;

  if not v_owner_ok then
    raise exception 'sessão % não pertence ao usuário autenticado ou já foi finalizada', p_session_id;
  end if;

  select g.config->'rounds'->p_round_index->>'gabarito'
    into v_gabarito
    from game_sessions gs
    join games g on g.id = gs.game_id
   where gs.id = p_session_id;

  if v_gabarito is null then
    raise exception 'rodada % não existe neste jogo', p_round_index;
  end if;

  v_is_correct := (p_chosen_key = v_gabarito);

  insert into game_round_answers (session_id, round_index, chosen_key, is_correct)
  values (p_session_id, p_round_index, p_chosen_key, v_is_correct)
  on conflict (session_id, round_index)
  do update set chosen_key  = excluded.chosen_key,
                is_correct  = excluded.is_correct,
                answered_at = now();

  return v_is_correct;
end;
$function$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 040
-- ============================================================================
