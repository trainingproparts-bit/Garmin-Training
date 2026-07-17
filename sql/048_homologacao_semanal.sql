-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 048: Homologação Semanal de Treinamento
-- ============================================================================
-- Pedido do usuário: ciclo semanal por loja, com conteúdo avulso e de
-- formatos diferentes (módulo, quiz, post de blog, game) marcado pelo admin
-- pra "valer" naquela semana, e o líder da loja assina confirmando o
-- progresso do time nesses itens específicos.
--
-- Duas correções feitas em cima da especificação original do usuário
-- (confirmadas com ele antes de escrever isto):
--   1. 'game' não tem progresso em quiz_attempts — vive em game_sessions/
--      game_scores (tabelas reais e separadas, sql/021). A função de
--      progresso usa a tabela certa por tipo.
--   2. Post de blog não tinha NENHUM registro de leitura por usuário
--      (blog_posts só guarda o conteúdo). Criada blog_reads do zero
--      (decisão do usuário: "criar rastreamento de leitura").
--
-- id_conteudo_origem é polimórfico (aponta pra modules/quizzes/blog_posts/
-- games conforme tipo_conteudo) — sem FK de banco cravada, porque uma FK
-- só aponta pra uma tabela. A integridade é garantida na função de
-- progresso (que já filtra por tipo antes de fazer o join certo).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. blog_reads — rastreamento de leitura (não existia nenhum antes)
-- ----------------------------------------------------------------------------
create table if not exists public.blog_reads (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles(id) on delete cascade,
  post_id    uuid not null references public.blog_posts(id) on delete cascade,
  lido_em    timestamptz not null default now(),
  unique (user_id, post_id)
);

comment on table public.blog_reads is
  'Marca "li este post" por usuário (sql/048) — não existia rastreamento nenhum de leitura de blog antes. Base pro tipo "blog" na Homologação Semanal.';

alter table public.blog_reads enable row level security;

drop policy if exists blog_reads_select_own on public.blog_reads;
create policy blog_reads_select_own on public.blog_reads
  for select using (user_id = auth.uid() or fn_is_admin() or fn_is_leader());

drop policy if exists blog_reads_insert_own on public.blog_reads;
create policy blog_reads_insert_own on public.blog_reads
  for insert with check (user_id = auth.uid());

grant select, insert on public.blog_reads to authenticated;

-- ----------------------------------------------------------------------------
-- 2. ciclos_semanais
-- ----------------------------------------------------------------------------
create table if not exists public.ciclos_semanais (
  id           uuid primary key default gen_random_uuid(),
  store_id     uuid not null references public.stores(id),
  data_inicio  date not null,
  data_fim     date not null,
  status       text not null default 'ativo' check (status in ('ativo', 'encerrado')),
  created_by   uuid references public.profiles(id) on delete set null,
  created_at   timestamptz not null default now(),
  constraint chk_ciclos_semanais_datas check (data_fim >= data_inicio)
);

comment on table public.ciclos_semanais is
  'Homologação Semanal (sql/048) — um ciclo por loja/semana, com conteúdo avulso marcado pelo admin (ver ciclo_conteudos) que o líder da loja confirma/assina (ver assinaturas_lideres).';

alter table public.ciclos_semanais enable row level security;

drop policy if exists ciclos_semanais_select on public.ciclos_semanais;
create policy ciclos_semanais_select on public.ciclos_semanais
  for select using (
    fn_is_admin()
    or (fn_is_leader() and store_id in (select fn_leader_store_ids()))
  );

drop policy if exists ciclos_semanais_admin_write on public.ciclos_semanais;
create policy ciclos_semanais_admin_write on public.ciclos_semanais
  for all using (fn_is_admin()) with check (fn_is_admin());

grant select, insert, update on public.ciclos_semanais to authenticated;

-- ----------------------------------------------------------------------------
-- 3. ciclo_conteudos — junção polimórfica (módulo/quiz/blog/game)
-- ----------------------------------------------------------------------------
create table if not exists public.ciclo_conteudos (
  id               uuid primary key default gen_random_uuid(),
  ciclo_id         uuid not null references public.ciclos_semanais(id) on delete cascade,
  tipo_conteudo    text not null check (tipo_conteudo in ('modulo', 'quiz', 'blog', 'game')),
  conteudo_id      uuid not null,
  created_at       timestamptz not null default now(),
  unique (ciclo_id, tipo_conteudo, conteudo_id)
);

comment on table public.ciclo_conteudos is
  'Itens avulsos cobrados num ciclo semanal (sql/048) — conteudo_id é polimórfico (aponta pra modules/quizzes/blog_posts/games conforme tipo_conteudo), sem FK cravada no banco (uma FK só serve uma tabela). fn_ciclo_itens_progresso resolve o join certo por tipo.';

alter table public.ciclo_conteudos enable row level security;

drop policy if exists ciclo_conteudos_select on public.ciclo_conteudos;
create policy ciclo_conteudos_select on public.ciclo_conteudos
  for select using (
    exists (
      select 1 from public.ciclos_semanais cs
      where cs.id = ciclo_conteudos.ciclo_id
        and (fn_is_admin() or (fn_is_leader() and cs.store_id in (select fn_leader_store_ids())))
    )
  );

drop policy if exists ciclo_conteudos_admin_write on public.ciclo_conteudos;
create policy ciclo_conteudos_admin_write on public.ciclo_conteudos
  for all using (fn_is_admin()) with check (fn_is_admin());

grant select, insert, delete on public.ciclo_conteudos to authenticated;

-- ----------------------------------------------------------------------------
-- 4. assinaturas_lideres — auditoria de confirmação do líder
-- ----------------------------------------------------------------------------
create table if not exists public.assinaturas_lideres (
  id                          uuid primary key default gen_random_uuid(),
  ciclo_id                    uuid not null references public.ciclos_semanais(id) on delete cascade,
  lider_id                    uuid not null references public.profiles(id) on delete set null,
  store_id                    uuid not null references public.stores(id),
  percentual_conclusao_time   numeric,
  assinado_em                 timestamptz,
  status_assinatura           text not null default 'pendente' check (status_assinatura in ('pendente', 'assinado')),
  ip_assinatura               text,
  termo_texto                 text,
  unique (ciclo_id, lider_id)
);

comment on table public.assinaturas_lideres is
  'Confirmação do líder sobre o progresso do time num ciclo semanal (sql/048). ip_assinatura é best-effort (enviado pelo próprio cliente, sem verificação server-side — esta arquitetura não tem camada de servidor que inspecione o IP real da requisição, só Postgres+RLS direto). Escrita só via fn_assinar_ciclo (SECURITY DEFINER), nunca INSERT/UPDATE direto do líder, pra manter o registro de auditoria íntegro.';

alter table public.assinaturas_lideres enable row level security;

drop policy if exists assinaturas_lideres_select on public.assinaturas_lideres;
create policy assinaturas_lideres_select on public.assinaturas_lideres
  for select using (
    fn_is_admin()
    or (fn_is_leader() and store_id in (select fn_leader_store_ids()))
  );

-- Sem policy de INSERT/UPDATE pro authenticated de propósito — só
-- fn_assinar_ciclo (SECURITY DEFINER) grava aqui, validando janela de
-- assinatura e escopo de loja antes.
drop policy if exists assinaturas_lideres_admin_write on public.assinaturas_lideres;
create policy assinaturas_lideres_admin_write on public.assinaturas_lideres
  for all using (fn_is_admin()) with check (fn_is_admin());

grant select on public.assinaturas_lideres to authenticated;

-- ----------------------------------------------------------------------------
-- 5. fn_ciclo_itens_progresso — progresso por item, resolvendo a tabela
--    certa por tipo_conteudo (correção da spec original do usuário: game
--    não é quiz_attempts, é game_sessions)
-- ----------------------------------------------------------------------------
create or replace function public.fn_ciclo_itens_progresso(p_ciclo_id uuid)
returns table(tipo_conteudo text, conteudo_id uuid, titulo text, pct_conclusao numeric)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id uuid;
  v_total_colaboradores int;
begin
  select store_id into v_store_id from ciclos_semanais where id = p_ciclo_id;
  if v_store_id is null then
    raise exception 'ciclo % não encontrado', p_ciclo_id;
  end if;

  if not (fn_is_admin() or (fn_is_leader() and v_store_id in (select fn_leader_store_ids()))) then
    raise exception 'sem permissão para consultar este ciclo';
  end if;

  select count(*) into v_total_colaboradores
  from profiles where store_id = v_store_id and role_id = 1 and deleted_at is null;

  return query
  -- módulo: % de colaboradores que concluíram TODAS as lições publicadas do módulo
  select
    cc.tipo_conteudo,
    cc.conteudo_id,
    m.title,
    case when v_total_colaboradores = 0 then 0::numeric else round(100.0 * (
      select count(*)
      from profiles p
      where p.store_id = v_store_id and p.role_id = 1 and p.deleted_at is null
        and not exists (
          select 1 from lessons les
          where les.module_id = m.id and les.is_published = true
            and not exists (
              select 1 from lesson_progress lp
              where lp.lesson_id = les.id and lp.user_id = p.id and lp.completed_at is not null
            )
        )
    ) / v_total_colaboradores, 1) end
  from ciclo_conteudos cc
  join modules m on m.id = cc.conteudo_id
  where cc.ciclo_id = p_ciclo_id and cc.tipo_conteudo = 'modulo'

  union all

  -- quiz: % de colaboradores com pelo menos 1 tentativa finalizada
  select
    cc.tipo_conteudo, cc.conteudo_id, q.title,
    case when v_total_colaboradores = 0 then 0::numeric else round(100.0 * (
      select count(distinct qa.user_id)
      from quiz_attempts qa
      join profiles p on p.id = qa.user_id
      where qa.quiz_id = q.id and qa.finished_at is not null
        and p.store_id = v_store_id and p.role_id = 1 and p.deleted_at is null
    ) / v_total_colaboradores, 1) end
  from ciclo_conteudos cc
  join quizzes q on q.id = cc.conteudo_id
  where cc.ciclo_id = p_ciclo_id and cc.tipo_conteudo = 'quiz'

  union all

  -- game: % de colaboradores com pelo menos 1 sessão finalizada (game_sessions, NÃO quiz_attempts)
  select
    cc.tipo_conteudo, cc.conteudo_id, g.title,
    case when v_total_colaboradores = 0 then 0::numeric else round(100.0 * (
      select count(distinct gs.user_id)
      from game_sessions gs
      join profiles p on p.id = gs.user_id
      where gs.game_id = g.id and gs.finished_at is not null
        and p.store_id = v_store_id and p.role_id = 1 and p.deleted_at is null
    ) / v_total_colaboradores, 1) end
  from ciclo_conteudos cc
  join games g on g.id = cc.conteudo_id
  where cc.ciclo_id = p_ciclo_id and cc.tipo_conteudo = 'game'

  union all

  -- blog: % de colaboradores que marcaram como lido (blog_reads, sql/048, novo)
  select
    cc.tipo_conteudo, cc.conteudo_id, b.title,
    case when v_total_colaboradores = 0 then 0::numeric else round(100.0 * (
      select count(distinct br.user_id)
      from blog_reads br
      join profiles p on p.id = br.user_id
      where br.post_id = b.id
        and p.store_id = v_store_id and p.role_id = 1 and p.deleted_at is null
    ) / v_total_colaboradores, 1) end
  from ciclo_conteudos cc
  join blog_posts b on b.id = cc.conteudo_id
  where cc.ciclo_id = p_ciclo_id and cc.tipo_conteudo = 'blog';
end;
$$;

comment on function public.fn_ciclo_itens_progresso(uuid) is
  'Progresso por item de um ciclo semanal, resolvendo a tabela certa por tipo_conteudo: modulo→lesson_progress (todas as lições publicadas), quiz→quiz_attempts, game→game_sessions (não quiz_attempts — correção da spec original), blog→blog_reads (sql/048, novo). % sobre colaboradores ativos (role_id=1) da loja do ciclo.';

grant execute on function public.fn_ciclo_itens_progresso(uuid) to authenticated;

-- ----------------------------------------------------------------------------
-- 6. fn_assinar_ciclo — assinatura do líder, com trava de janela (sexta
--    00:00 a segunda 23:59, dia da semana corrente — não das datas do ciclo)
-- ----------------------------------------------------------------------------
create or replace function public.fn_assinar_ciclo(
  p_ciclo_id       uuid,
  p_ip_assinatura  text default null,
  p_termo_texto    text default null
)
returns public.assinaturas_lideres
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id  uuid;
  v_dia_semana int := extract(dow from now()); -- 0=domingo .. 6=sábado
  v_pct       numeric;
  v_row       public.assinaturas_lideres;
begin
  if not (fn_is_leader() or fn_is_admin()) then
    raise exception 'apenas líderes ou administradores podem assinar um ciclo';
  end if;

  select store_id into v_store_id from ciclos_semanais where id = p_ciclo_id;
  if v_store_id is null then
    raise exception 'ciclo % não encontrado', p_ciclo_id;
  end if;

  if fn_is_leader() and not fn_is_admin() and v_store_id not in (select fn_leader_store_ids()) then
    raise exception 'você não lidera esta loja';
  end if;

  -- janela: sexta(5), sábado(6), domingo(0), segunda(1) — dia real corrente, não as datas do ciclo
  if v_dia_semana not in (5, 6, 0, 1) then
    raise exception 'assinatura só é permitida de sexta-feira 00:00 a segunda-feira 23:59';
  end if;

  select round(avg(pct_conclusao), 1) into v_pct from fn_ciclo_itens_progresso(p_ciclo_id);

  insert into assinaturas_lideres (
    ciclo_id, lider_id, store_id, percentual_conclusao_time, assinado_em, status_assinatura, ip_assinatura, termo_texto
  )
  values (
    p_ciclo_id, auth.uid(), v_store_id, coalesce(v_pct, 0), now(), 'assinado', p_ip_assinatura, p_termo_texto
  )
  on conflict (ciclo_id, lider_id) do update set
    percentual_conclusao_time = excluded.percentual_conclusao_time,
    assinado_em = excluded.assinado_em,
    status_assinatura = excluded.status_assinatura,
    ip_assinatura = excluded.ip_assinatura,
    termo_texto = excluded.termo_texto
  returning * into v_row;

  return v_row;
end;
$$;

comment on function public.fn_assinar_ciclo(uuid, text, text) is
  'Único caminho de escrita em assinaturas_lideres — valida líder/loja/janela (sexta 00:00–segunda 23:59, dia real corrente) e snapshotta o % médio de fn_ciclo_itens_progresso no momento da assinatura. ip_assinatura é best-effort, enviado pelo cliente sem verificação server-side (sem camada de servidor nesta arquitetura pra inspecionar IP de requisição de verdade).';

grant execute on function public.fn_assinar_ciclo(uuid, text, text) to authenticated;

-- ============================================================================
-- FIM DA MIGRAÇÃO 048
-- ============================================================================
