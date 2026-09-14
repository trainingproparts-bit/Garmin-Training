-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 114: pontuação (XP) do fórum
-- ============================================================================
-- Pedido do usuário: 100 pts por publicar um tópico, 150 pts por responder,
-- +20 pts de bônus pro autor da resposta marcada como solução oficial (total
-- 170 pra quem responde e vira solução). Estorna os 20 se a solução for
-- desmarcada ou trocada pra outra resposta.
--
-- Mesmo padrão dos outros gatilhos de XP já existentes (quiz:
-- fn_award_points_on_pass; lição: fn_complete_lesson, sql/004; avaliação
-- Google: fn_award_points_on_avaliacao_google, sql/062) — insere em
-- points_ledger, que profiles.performance_score (trg_sync_performance_score,
-- sql/004) já soma automaticamente.
--
-- fn_award_points_on_forum_solution usa SALDO LÍQUIDO (soma de points_ledger
-- por source_id) em vez de um simples "já existe/não existe" — isso suporta
-- marcar → desmarcar → remarcar a MESMA resposta sem duplicar o crédito nem
-- travar o próximo. Testado manualmente em produção antes de fechar.
-- ============================================================================

alter table public.points_ledger
  drop constraint if exists chk_points_ledger_source;
alter table public.points_ledger
  add constraint chk_points_ledger_source
  check (source_type in ('quiz','module','lesson','game','badge','certification','streak','avaliacao_google','manual_adjustment','review_session','forum_thread','forum_reply','forum_solution'));

-- 100 pts ao publicar um tópico
create or replace function public.fn_award_points_on_forum_thread()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.points_ledger (user_id, source_type, source_id, points, reason)
  values (new.author_id, 'forum_thread', new.id, 100, 'Publicou um tópico no fórum');
  return new;
end;
$$;

comment on function public.fn_award_points_on_forum_thread() is 'Concede 100 pts ao autor de um novo tópico do fórum (forum_threads).';

drop trigger if exists trg_award_points_on_forum_thread on public.forum_threads;
create trigger trg_award_points_on_forum_thread
after insert on public.forum_threads
for each row execute function public.fn_award_points_on_forum_thread();

-- 150 pts ao responder
create or replace function public.fn_award_points_on_forum_reply()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.points_ledger (user_id, source_type, source_id, points, reason)
  values (new.author_id, 'forum_reply', new.id, 150, 'Respondeu um tópico no fórum');
  return new;
end;
$$;

comment on function public.fn_award_points_on_forum_reply() is 'Concede 150 pts ao autor de uma nova resposta do fórum (forum_replies).';

drop trigger if exists trg_award_points_on_forum_reply on public.forum_replies;
create trigger trg_award_points_on_forum_reply
after insert on public.forum_replies
for each row execute function public.fn_award_points_on_forum_reply();

-- +20 pts de bônus quando uma resposta vira solução oficial (forum_threads.solution_reply_id)
create or replace function public.fn_award_points_on_forum_solution()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_net_old int;
  v_net_new int;
  v_author uuid;
begin
  if new.solution_reply_id is not distinct from old.solution_reply_id then
    return new;
  end if;

  -- estorna o bônus da resposta que deixou de ser a solução (se ela tinha saldo positivo)
  if old.solution_reply_id is not null then
    select coalesce(sum(points), 0) into v_net_old
      from public.points_ledger
     where source_type = 'forum_solution' and source_id = old.solution_reply_id;

    if v_net_old > 0 then
      select author_id into v_author from public.forum_replies where id = old.solution_reply_id;
      if v_author is not null then
        insert into public.points_ledger (user_id, source_type, source_id, points, reason)
        values (v_author, 'forum_solution', old.solution_reply_id, -v_net_old, 'Solução do fórum desmarcada');
      end if;
    end if;
  end if;

  -- credita o bônus da nova solução (se ela não tiver saldo positivo pendente)
  if new.solution_reply_id is not null then
    select coalesce(sum(points), 0) into v_net_new
      from public.points_ledger
     where source_type = 'forum_solution' and source_id = new.solution_reply_id;

    if v_net_new <= 0 then
      select author_id into v_author from public.forum_replies where id = new.solution_reply_id;
      if v_author is not null then
        insert into public.points_ledger (user_id, source_type, source_id, points, reason)
        values (v_author, 'forum_solution', new.solution_reply_id, 20, 'Resposta marcada como solução oficial');
      end if;
    end if;
  end if;

  return new;
end;
$$;

comment on function public.fn_award_points_on_forum_solution() is 'Concede +20 pts ao autor da resposta marcada como solução oficial (forum_threads.solution_reply_id); estorna se desmarcada ou trocada. Usa saldo líquido do ledger pra suportar marcar/desmarcar/remarcar a mesma resposta sem duplicar nem travar.';

drop trigger if exists trg_award_points_on_forum_solution on public.forum_threads;
create trigger trg_award_points_on_forum_solution
after update of solution_reply_id on public.forum_threads
for each row execute function public.fn_award_points_on_forum_solution();

revoke execute on function public.fn_award_points_on_forum_thread() from anon, authenticated;
revoke execute on function public.fn_award_points_on_forum_reply() from anon, authenticated;
revoke execute on function public.fn_award_points_on_forum_solution() from anon, authenticated;

-- Backfill: tópicos/respostas/soluções que já existiam antes deste trigger.
insert into public.points_ledger (user_id, source_type, source_id, points, reason)
select t.author_id, 'forum_thread', t.id, 100, 'Publicou um tópico no fórum'
  from public.forum_threads t
 where not exists (
   select 1 from public.points_ledger pl where pl.source_type = 'forum_thread' and pl.source_id = t.id
 );

insert into public.points_ledger (user_id, source_type, source_id, points, reason)
select r.author_id, 'forum_reply', r.id, 150, 'Respondeu um tópico no fórum'
  from public.forum_replies r
 where not exists (
   select 1 from public.points_ledger pl where pl.source_type = 'forum_reply' and pl.source_id = r.id
 );

insert into public.points_ledger (user_id, source_type, source_id, points, reason)
select r.author_id, 'forum_solution', r.id, 20, 'Resposta marcada como solução oficial'
  from public.forum_threads t
  join public.forum_replies r on r.id = t.solution_reply_id
 where t.solution_reply_id is not null
   and not exists (
     select 1 from public.points_ledger pl where pl.source_type = 'forum_solution' and pl.source_id = r.id
   );

-- ============================================================================
-- FIM DA MIGRAÇÃO 114
-- ============================================================================
