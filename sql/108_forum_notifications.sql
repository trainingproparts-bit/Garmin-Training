-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 108: notificações de fórum (novo tópico,
-- nova resposta) via broadcast na tabela notifications existente
-- ============================================================================
-- INSERT em notifications é revogado de authenticated (sql/005), só trigger
-- SECURITY DEFINER pode criar notificação — mesmo padrão de
-- fn_notify_trail_completed. Broadcast pra equipe inteira (pedido explícito
-- do usuário: "chegue uma notificação pra todo mundo"), um insert...select
-- em massa por evento, sem loop PL/pgSQL. O autor do tópico já recebe
-- notificação de resposta de graça (está no broadcast geral, só é excluído
-- quando é ele mesmo o autor da ação) — não precisa de um segundo gatilho.
-- ============================================================================

begin;

create or replace function fn_notify_forum_new_thread()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into notifications (user_id, title, message, type, action_url)
  select
    p.id,
    'Novo tópico no fórum',
    new.title,
    'forum_new_thread',
    '#forum-topico?thread=' || new.id
  from profiles p
  where p.status = 'active' and p.deleted_at is null and p.id <> new.author_id;

  return new;
end;
$$;

comment on function fn_notify_forum_new_thread() is 'Notifica toda a equipe ativa (exceto o autor) quando um tópico novo é criado no fórum.';

create trigger trg_notify_forum_new_thread
after insert on forum_threads
for each row execute function fn_notify_forum_new_thread();

create or replace function fn_notify_forum_new_reply()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_thread_title text;
begin
  select title into v_thread_title from forum_threads where id = new.thread_id;

  insert into notifications (user_id, title, message, type, action_url)
  select
    p.id,
    'Nova resposta no fórum',
    coalesce(v_thread_title, 'Um tópico que você segue'),
    'forum_new_reply',
    '#forum-topico?thread=' || new.thread_id
  from profiles p
  where p.status = 'active' and p.deleted_at is null and p.id <> new.author_id;

  return new;
end;
$$;

comment on function fn_notify_forum_new_reply() is 'Notifica toda a equipe ativa (exceto quem respondeu) quando uma resposta nova é postada — inclui o autor do tópico automaticamente, sem gatilho separado.';

create trigger trg_notify_forum_new_reply
after insert on forum_replies
for each row execute function fn_notify_forum_new_reply();

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 108
-- ============================================================================
