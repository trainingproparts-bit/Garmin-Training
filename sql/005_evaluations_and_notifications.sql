-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 005: Motor de Avaliações Trimestrais + Sininho
-- ============================================================================
-- Pedido: banco de questões para avaliações trimestrais (Explorer/Runner/
-- Triathlete), sistema de notificações (sininho) e automação que avisa o
-- usuário quando ele termina a última lição de uma trilha.
--
-- DUAS ADIÇÕES ALÉM DO PEDIDO LITERAL, feitas por necessidade estrutural
-- (documentadas aqui, não silenciosas):
--   1. evaluations.passing_score_pct — o pedido original listava só
--      (id, title, type). Sem nota de corte não dá pra calcular "passou/
--      reprovou", e a trava de 24h só faz sentido a partir de uma reprovação.
--      Default 70.00, mesmo padrão de quizzes.passing_score_pct.
--   2. Tabela evaluation_attempts (não estava na lista de tabelas pedida).
--      A trava "24h após reprovar, sem limite de tentativas, com liberação
--      manual do líder" PRECISA de um lugar para registrar quando o usuário
--      reprovou e se um líder liberou antes do prazo — não existe outra
--      tabela no schema que sirva pra isso.
--
-- FORA DE ESCOPO NESTA MIGRAÇÃO (vai ficar pra quando a tela de avaliação
-- for pedida): não existe ainda uma evaluation_answers nem uma RPC de
-- submissão de resposta com correção no servidor (o padrão que já existe
-- para quiz_answers/fn_submit_quiz_answer). Por isso, para não deixar a
-- tabela evaluation_attempts aberta a fraude (aluno inserindo o próprio
-- "passei"), o INSERT direto do client é revogado — só uma função
-- SECURITY DEFINER futura (quando o motor de correção for construído)
-- vai poder gravar tentativas de verdade. A trava e a liberação do líder já
-- ficam prontas e testáveis via fn_check_evaluation_lock/fn_unlock_evaluation_attempt.
--
-- Pré-requisito: garmin_training_hub_migrations.sql (schema base) já rodado.
-- ============================================================================


-- ============================================================================
-- 1) BANCO DE QUESTÕES
-- ============================================================================

create table if not exists evaluations (
  id                  uuid primary key default gen_random_uuid(),
  title               text not null,
  type                text not null,
  passing_score_pct   numeric(5,2) not null default 70.00,
  is_published        boolean not null default true,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  constraint chk_evaluations_score check (passing_score_pct between 0 and 100)
);
comment on table evaluations is 'Avaliação trimestral por tier (type: explorer/runner/triathlete...) — distinta dos quizzes de módulo, é o instrumento de recertificação periódica.';

drop trigger if exists trg_evaluations_updated_at on evaluations;
create trigger trg_evaluations_updated_at
before update on evaluations
for each row execute function fn_set_updated_at();

create table if not exists evaluation_questions (
  id              uuid primary key default gen_random_uuid(),
  evaluation_id   uuid not null references evaluations(id) on delete cascade,
  question_text   text not null,
  options_json    jsonb not null,
  correct_option  integer not null,
  order_index     integer not null default 0,
  constraint chk_evaluation_questions_correct_option check (correct_option >= 0)
);
create index if not exists idx_evaluation_questions_eval_order on evaluation_questions(evaluation_id, order_index);
comment on column evaluation_questions.options_json is 'Array JSON de strings, ex.: ["Opção A","Opção B","Opção C","Opção D"].';
comment on column evaluation_questions.correct_option is 'Índice 0-based em options_json — nunca exposto ao colaborador antes de responder, ver v_evaluation_questions_public.';

-- View segura: mesma técnica já usada em v_alternatives_public (seção 13.1
-- do schema base). Roda com o privilégio do dono da view, não do
-- consumidor — por isso consegue expor um subconjunto de uma tabela cuja
-- RLS de base restringe SELECT a líder/admin.
create or replace view v_evaluation_questions_public as
select id, evaluation_id, question_text, options_json, order_index
from evaluation_questions;


-- ============================================================================
-- 2) TENTATIVAS + TRAVA DE 24H (necessária para a trava pedida)
-- ============================================================================

create table if not exists evaluation_attempts (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null references profiles(id),
  evaluation_id      uuid not null references evaluations(id),
  started_at         timestamptz not null default now(),
  finished_at        timestamptz,
  score_pct          numeric(5,2),
  passed             boolean,
  unlocked_early_by  uuid references profiles(id),
  unlocked_early_at  timestamptz
);
create index if not exists idx_evaluation_attempts_user_eval on evaluation_attempts(user_id, evaluation_id, finished_at desc);
comment on table evaluation_attempts is 'Histórico de tentativas de avaliação trimestral. score_pct/passed nunca são gravados pelo cliente diretamente — ver nota de escopo no topo do arquivo.';
comment on column evaluation_attempts.unlocked_early_by is 'Líder/admin que liberou a tentativa antes do prazo de 24h — nulo enquanto ninguém liberou manualmente.';


-- ============================================================================
-- 3) SININHO — NOTIFICAÇÕES
-- ============================================================================

create table if not exists notifications (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references profiles(id),
  title        text not null,
  message      text not null,
  type         text not null default 'system',
  is_read      boolean not null default false,
  created_at   timestamptz not null default now(),
  action_url   text
);
create index if not exists idx_notifications_user_created on notifications(user_id, created_at desc);
create index if not exists idx_notifications_user_unread   on notifications(user_id, is_read);
comment on table notifications is 'Sininho do dashboard. type é texto livre (evaluation_available, certification_issued, system...) para não travar em um CHECK fechado enquanto o catálogo de notificações ainda está em definição.';


-- ============================================================================
-- 4) FUNÇÕES — trava de tentativa, liberação do líder
-- ============================================================================

-- Checa se o usuário está bloqueado para iniciar uma nova tentativa desta
-- avaliação. Regra: bloqueado por 24h a partir da última tentativa
-- REPROVADA, a menos que um líder/admin já tenha liberado manualmente essa
-- mesma tentativa (unlocked_early_by preenchido). Sem limite de tentativas —
-- só o cooldown de 24h importa.
create or replace function fn_check_evaluation_lock(p_evaluation_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_last    evaluation_attempts;
  v_locked_until timestamptz;
begin
  if v_user_id is null then
    raise exception 'fn_check_evaluation_lock exige usuário autenticado';
  end if;

  select *
    into v_last
    from evaluation_attempts
   where user_id = v_user_id
     and evaluation_id = p_evaluation_id
     and finished_at is not null
     and passed is false
   order by finished_at desc
   limit 1;

  if not found then
    return jsonb_build_object('locked', false, 'locked_until', null, 'reason', null);
  end if;

  if v_last.unlocked_early_by is not null then
    return jsonb_build_object('locked', false, 'locked_until', null, 'reason', 'unlocked_by_leader');
  end if;

  v_locked_until := v_last.finished_at + interval '24 hours';

  if now() >= v_locked_until then
    return jsonb_build_object('locked', false, 'locked_until', null, 'reason', null);
  end if;

  return jsonb_build_object('locked', true, 'locked_until', v_locked_until, 'reason', 'cooldown_24h');
end;
$$;

comment on function fn_check_evaluation_lock(uuid) is
  'Retorna {locked, locked_until, reason} — usado pela UI para habilitar/desabilitar o botão de iniciar avaliação.';

grant execute on function fn_check_evaluation_lock(uuid) to authenticated;

-- Liberação manual do líder/admin — desbloqueia a última tentativa
-- reprovada antes das 24h renderem. Só quem responde por fn_is_leader()
-- (líder da loja do colaborador) ou fn_is_admin() pode chamar.
create or replace function fn_unlock_evaluation_attempt(p_attempt_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_attempt_owner uuid;
  v_owner_store   uuid;
begin
  if not (fn_is_leader() or fn_is_admin()) then
    raise exception 'apenas líder ou admin pode liberar uma tentativa antes do prazo';
  end if;

  select ea.user_id, p.store_id
    into v_attempt_owner, v_owner_store
    from evaluation_attempts ea
    join profiles p on p.id = ea.user_id
   where ea.id = p_attempt_id;

  if v_attempt_owner is null then
    raise exception 'tentativa % não encontrada', p_attempt_id;
  end if;

  if fn_is_leader() and not fn_is_admin() and v_owner_store not in (select fn_leader_store_ids()) then
    raise exception 'líder só pode liberar colaboradores da própria loja';
  end if;

  update evaluation_attempts
     set unlocked_early_by = auth.uid(),
         unlocked_early_at = now()
   where id = p_attempt_id;
end;
$$;

comment on function fn_unlock_evaluation_attempt(uuid) is
  'Líder/admin libera uma tentativa reprovada antes do cooldown de 24h vencer.';

grant execute on function fn_unlock_evaluation_attempt(uuid) to authenticated;


-- ============================================================================
-- 5) AUTOMAÇÃO DO DASHBOARD — notifica quando a trilha inteira é concluída
-- ============================================================================
-- Dispara quando lesson_progress.completed_at é preenchido. Resolve a
-- trilha da lição (lesson -> module -> zone -> trail) e verifica se TODAS
-- as lições publicadas dessa trilha já estão concluídas pelo usuário. Se
-- sim, insere uma notificação — só uma vez (checa se já existe antes de
-- inserir de novo).
create or replace function fn_notify_trail_completed()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_trail_id       uuid;
  v_trail_name     text;
  v_total_lessons  integer;
  v_done_lessons   integer;
  v_already_notified boolean;
begin
  if new.completed_at is null then
    return new;
  end if;

  select z.trail_id, t.name
    into v_trail_id, v_trail_name
    from lessons  l
    join modules  m on m.id = l.module_id
    join zones    z on z.id = m.zone_id
    join trails   t on t.id = z.trail_id
   where l.id = new.lesson_id;

  if v_trail_id is null then
    return new;
  end if;

  select count(*)
    into v_total_lessons
    from lessons  l
    join modules  m on m.id = l.module_id
    join zones    z on z.id = m.zone_id
   where z.trail_id = v_trail_id
     and l.is_published = true;

  if v_total_lessons = 0 then
    return new;
  end if;

  select count(*)
    into v_done_lessons
    from lesson_progress lp
    join lessons  l on l.id = lp.lesson_id
    join modules  m on m.id = l.module_id
    join zones    z on z.id = m.zone_id
   where z.trail_id = v_trail_id
     and l.is_published = true
     and lp.user_id = new.user_id
     and lp.completed_at is not null;

  if v_done_lessons < v_total_lessons then
    return new;
  end if;

  select exists (
    select 1 from notifications
     where user_id = new.user_id
       and type = 'evaluation_available'
       and action_url = '#avaliacoes-trimestrais?trail=' || v_trail_id::text
  ) into v_already_notified;

  if not v_already_notified then
    insert into notifications (user_id, title, message, type, action_url)
    values (
      new.user_id,
      'Sua trilha está completa!',
      format('Você concluiu todas as lições da trilha %s. Sua avaliação trimestral já está disponível.', coalesce(v_trail_name, 'atual')),
      'evaluation_available',
      '#avaliacoes-trimestrais?trail=' || v_trail_id::text
    );
  end if;

  return new;
end;
$$;

comment on function fn_notify_trail_completed() is
  'Ao concluir a última lição publicada de uma trilha, insere notificação de avaliação disponível. action_url usa um placeholder de rota (#avaliacoes-trimestrais) — atualizar quando a tela de avaliação existir.';

drop trigger if exists trg_notify_trail_completed on lesson_progress;
create trigger trg_notify_trail_completed
after insert or update on lesson_progress
for each row execute function fn_notify_trail_completed();


-- ============================================================================
-- 6) RLS
-- ============================================================================

alter table evaluations           enable row level security;
alter table evaluation_questions  enable row level security;
alter table evaluation_attempts   enable row level security;
alter table notifications         enable row level security;

-- evaluations: leitura igual quizzes (publicado ou admin)
create policy evaluations_select_published on evaluations
  for select using (is_published = true or fn_is_admin());
create policy evaluations_admin_all on evaluations
  for all using (fn_is_admin()) with check (fn_is_admin());

-- evaluation_questions: mesma restrição de alternatives — só líder/admin
-- veem a tabela base (com correct_option). Colaborador usa a view pública.
create policy evaluation_questions_select_leader_admin on evaluation_questions
  for select using (fn_is_leader() or fn_is_admin());
create policy evaluation_questions_admin_all on evaluation_questions
  for all using (fn_is_admin()) with check (fn_is_admin());

grant select on v_evaluation_questions_public to authenticated;

-- evaluation_attempts: leitura própria + líder da loja + admin. Sem policy
-- de INSERT/UPDATE para authenticated — grava só via função SECURITY
-- DEFINER (ainda não construída, ver nota de escopo no topo) ou admin.
create policy evaluation_attempts_select_own on evaluation_attempts
  for select using (user_id = auth.uid());
create policy evaluation_attempts_select_leader on evaluation_attempts
  for select using (
    fn_is_leader() and exists (
      select 1 from profiles p where p.id = evaluation_attempts.user_id and p.store_id in (select fn_leader_store_ids())
    )
  );
create policy evaluation_attempts_admin_all on evaluation_attempts
  for all using (fn_is_admin()) with check (fn_is_admin());

revoke insert, update on evaluation_attempts from authenticated;

-- notifications: usuário só vê e só marca como lida as suas próprias.
-- INSERT não é liberado pro client — só a trigger (SECURITY DEFINER) ou admin.
create policy notifications_select_own on notifications
  for select using (user_id = auth.uid());
create policy notifications_update_own on notifications
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy notifications_admin_all on notifications
  for all using (fn_is_admin()) with check (fn_is_admin());

revoke insert on notifications from authenticated;


-- ============================================================================
-- FIM DA MIGRAÇÃO 005
-- ============================================================================
