-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 021: submissão de game (hardening)
-- ============================================================================
-- Achado ao testar ao vivo (login real, Daniel Lucena, 2026-07-10) o item
-- do ROADMAP "hardening de Games": o recurso está **quebrado hoje**, não só
-- "sem proteção" como o checklist registrava. `game_sessions` tem policy de
-- INSERT/SELECT própria mas **nenhuma de UPDATE** — o `PATCH` que
-- `finishGameSession()` faz pra marcar `finished_at`/`rounds_played`
-- retorna 204 (sucesso), mas RLS sem policy de UPDATE correspondente
-- silenciosamente afeta 0 linhas: a sessão nunca fecha de verdade.
-- `game_scores` não tem policy de INSERT nenhuma — o upsert de score falha
-- com 403 explícito. Confirmado ao vivo: jogar o "Duelo de Especificações"
-- inteiro não grava nada (`finished_at`/`rounds_played`/`result_summary`
-- continuam null, `game_scores` nunca ganha linha).
--
-- Fix: mesmo padrão de `sql/003_quiz_submission_hardening.sql` — nunca
-- confiar em score calculado no cliente. Nova tabela `game_round_answers`
-- (equivalente a `quiz_answers`) grava a escolha de cada rodada com
-- `is_correct` calculado no servidor a partir de `games.config` (o cliente
-- nunca escreve `is_correct`). `fn_finalize_game_session` fecha a sessão e
-- grava `game_scores` somando as respostas reais da própria sessão — nunca
-- o valor que o cliente mandar.
--
-- Ressalva que continua real mesmo depois deste fix (fora de escopo aqui):
-- `games.config` chega inteiro ao cliente antes de jogar, incluindo
-- `gabarito` de todas as rodadas — ao contrário de quizzes
-- (`alternatives.is_correct` só é exposto depois de responder via
-- `v_alternatives_public`), então um usuário tecnicamente sofisticado pode
-- inspecionar a network/JS e ver a resposta certa antes de escolher. Esse
-- fix fecha "o cliente inventa o próprio placar" (o problema descrito no
-- checklist), não "o cliente pode ver o gabarito antes de jogar" (mudança
-- maior, exigiria servir rodada por rodada — fora do pedido desta rodada,
-- e consistente com games serem "prática informal, sem peso de
-- certificação").
-- ============================================================================

create table if not exists public.game_round_answers (
  id           uuid primary key default gen_random_uuid(),
  session_id   uuid not null references public.game_sessions(id) on delete cascade,
  round_index  integer not null,
  chosen_key   text not null,
  is_correct   boolean not null,
  answered_at  timestamptz not null default now(),
  constraint uq_game_round_answers_session_round unique (session_id, round_index)
);
create index if not exists idx_game_round_answers_session on public.game_round_answers(session_id);

alter table public.game_round_answers enable row level security;

drop policy if exists game_round_answers_select_own on public.game_round_answers;
create policy game_round_answers_select_own on public.game_round_answers
  for select using (
    exists (select 1 from public.game_sessions gs where gs.id = game_round_answers.session_id and gs.user_id = auth.uid())
  );

drop policy if exists game_round_answers_admin_all on public.game_round_answers;
create policy game_round_answers_admin_all on public.game_round_answers
  for all using (fn_is_admin()) with check (fn_is_admin());

-- Nenhuma policy de INSERT/UPDATE pro authenticated de propósito — só a
-- função SECURITY DEFINER abaixo grava, depois de calcular is_correct ela
-- mesma (mesmo princípio de quiz_answers/fn_submit_quiz_answer).

create or replace function public.fn_submit_game_round(
  p_session_id  uuid,
  p_round_index integer,
  p_chosen_key  text
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_owner_ok   boolean;
  v_gabarito   text;
  v_winner_key text;
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

  -- Mesmo mapa gabarito→chave de reveal do GameRunner.js (GABARITO_TO_REVEAL_KEY)
  -- — os dois jogos seedados hoje usam abreviações diferentes pro vencedor.
  v_winner_key := case v_gabarito
    when 'instinct3' then 'i3'
    when 'instincte' then 'ie'
    else v_gabarito
  end;

  v_is_correct := (v_gabarito = 'ambos') or (p_chosen_key = v_winner_key);

  insert into game_round_answers (session_id, round_index, chosen_key, is_correct)
  values (p_session_id, p_round_index, p_chosen_key, v_is_correct)
  on conflict (session_id, round_index)
  do update set chosen_key  = excluded.chosen_key,
                is_correct  = excluded.is_correct,
                answered_at = now();

  return v_is_correct;
end;
$$;

comment on function public.fn_submit_game_round(uuid, integer, text) is
  'Único caminho permitido para registrar a escolha de uma rodada do Duelo de Especificações — calcula acerto/erro no servidor a partir de games.config, nunca confia no cliente.';

grant execute on function public.fn_submit_game_round(uuid, integer, text) to authenticated;

create or replace function public.fn_finalize_game_session(p_session_id uuid)
returns table (score integer, accuracy_pct numeric, rounds_played integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_owner_ok      boolean;
  v_correct_count integer;
  v_total_answers integer;
  v_accuracy      numeric(5,2);
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

  select count(*), count(*) filter (where is_correct)
    into v_total_answers, v_correct_count
    from game_round_answers
   where session_id = p_session_id;

  v_accuracy := case when v_total_answers = 0 then 0
                     else round((v_correct_count::numeric / v_total_answers::numeric) * 100, 2)
                end;

  update game_sessions
     set finished_at    = now(),
         rounds_played  = v_total_answers,
         result_summary = jsonb_build_object('correctCount', v_correct_count, 'totalRounds', v_total_answers)
   where id = p_session_id;

  insert into game_scores (session_id, score, accuracy_pct)
  values (p_session_id, v_correct_count, v_accuracy)
  on conflict (session_id) do update set score = excluded.score, accuracy_pct = excluded.accuracy_pct;

  return query select v_correct_count, v_accuracy, v_total_answers;
end;
$$;

comment on function public.fn_finalize_game_session(uuid) is
  'Fecha a sessão de game e grava game_sessions/game_scores calculados no servidor a partir de game_round_answers — nunca confia em placar enviado pelo cliente. Sem isso, game_sessions.finished_at nunca era setado de verdade (faltava policy de UPDATE) e game_scores rejeitava o INSERT (403, faltava policy).';

grant execute on function public.fn_finalize_game_session(uuid) to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 021
-- ============================================================================
