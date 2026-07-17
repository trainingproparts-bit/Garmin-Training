-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 037: Álbum da Equipe
-- ============================================================================
-- Porta o "Álbum dos Campeões" de index_redesign_v5.html (figurinhas por
-- colaborador — classe, atributos, especialidade, equipamento, frase) pro
-- app novo. Decidido com o usuário (2026-07-12) como tratar os atributos
-- que, no protótipo original, nunca tiveram fonte de dado real — o próprio
-- código do protótipo admitia isso em comentário ("Ritmo... vem da planilha
-- de vendedores, não tem esse dado no site"; "Reputação... marque
-- manualmente"): mantém tudo, exceto "Selo" (a faixa de raridade
-- ⭐⭐⭐⭐⭐/"figurinha rara", puramente editorial, sem nenhum significado
-- de progresso — removida a pedido do usuário).
--
-- Mapeamento pra dado real (sem inventar número):
--   Produto    → % de lições publicadas concluídas (lesson_progress)
--   Precisão   → média de score_pct dos quizzes finalizados (quiz_attempts)
--   Jogo       → média de accuracy_pct dos games finalizados (game_scores)
--   Ritmo      → aproximação a partir do ranking de performance_score
--                (não é posição de vendas real — não existe essa fonte
--                 hoje; documentado como aproximação na UI)
--   Classe     → título da certificação mais alta emitida e não revogada
--                (Explorador/Corredor/Maratonista/Triatleta — os 4 reais;
--                 "Ultramaratonista" do protótipo não existe como
--                 certificação de verdade, não portado)
--   Loja       → stores.name
--   Emoji/Frase/Avatar → profiles.emoji/phrase/avatar_url (já existiam,
--                nunca tinham UI de edição — ganham uma agora)
--   Especialidade/Relógio/Esporte → colunas novas, autoeditáveis (mesmo
--                grupo de campos "identidade pessoal" que emoji/phrase já
--                eram, por fn_guard_profile_self_update, sql/008)
--   Reputação/Ponta do Mês → colunas novas, só admin edita (dado
--                curado externamente — no protótipo original também eram
--                preenchidos manualmente por quem mantinha o arquivo)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Novas colunas em profiles
-- ----------------------------------------------------------------------------
alter table public.profiles
  add column if not exists specialty        text,
  add column if not exists favorite_watch   text,
  add column if not exists sport            text,
  add column if not exists reputation_score integer,
  add column if not exists is_top_seller    boolean not null default false;

alter table public.profiles
  drop constraint if exists chk_profiles_reputation_score;
alter table public.profiles
  add constraint chk_profiles_reputation_score
  check (reputation_score is null or (reputation_score between 0 and 100));

comment on column public.profiles.specialty is 'Álbum da Equipe — especialidade/ponto forte pessoal, texto livre curto. Autoeditável (fn_guard_profile_self_update não bloqueia).';
comment on column public.profiles.favorite_watch is 'Álbum da Equipe — modelo de relógio favorito, texto livre curto. Autoeditável.';
comment on column public.profiles.sport is 'Álbum da Equipe — modalidade esportiva praticada, texto livre curto. Autoeditável.';
comment on column public.profiles.reputation_score is 'Álbum da Equipe — 0 a 100, dado curado externamente (não vem de nenhum sistema, RN não define fonte). Só admin edita (fn_guard_profile_self_update bloqueia autoedição).';
comment on column public.profiles.is_top_seller is 'Álbum da Equipe — faixa "Ponta do Mês" na figurinha. Curado manualmente (mesma natureza do dado no protótipo original, que já vinha de planilha externa). Só admin edita.';

-- ----------------------------------------------------------------------------
-- 2. Estende o guard de autoedição (sql/008) — reputation_score e
--    is_top_seller são dado curado, não identidade pessoal como
--    especialidade/relógio/esporte/emoji/frase (esses continuam livres).
-- ----------------------------------------------------------------------------
create or replace function public.fn_guard_profile_self_update()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if fn_is_admin() then
    return new;
  end if;

  if new.role_id             is distinct from old.role_id
     or new.store_id         is distinct from old.store_id
     or new.brand_id         is distinct from old.brand_id
     or new.status           is distinct from old.status
     or new.deleted_at       is distinct from old.deleted_at
     or new.username         is distinct from old.username
     or new.reputation_score is distinct from old.reputation_score
     or new.is_top_seller    is distinct from old.is_top_seller
  then
    raise exception 'apenas administradores podem alterar cargo, loja, marca, status, usuário, reputação ou destaque de vendas de um perfil';
  end if;

  return new;
end;
$$;

comment on function public.fn_guard_profile_self_update() is
  'Bloqueia auto-promoção/auto-transferência e auto-curadoria: só fn_is_admin() pode mudar role_id/store_id/brand_id/status/deleted_at/username/reputation_score/is_top_seller via UPDATE em profiles. Demais campos (full_name/avatar_url/emoji/phrase/specialty/favorite_watch/sport) continuam livres — identidade pessoal, não dado de autorização/curadoria (sql/008, estendido em sql/037).';

-- ----------------------------------------------------------------------------
-- 3. v_team_album — view pública estreita (mesmo padrão de v_ranking_public,
--    sql/026): qualquer colaborador vê a equipe inteira da própria marca,
--    admin vê tudo. Calcula Produto/Precisão/Jogo/Classe a partir de dado
--    real; nunca expõe e-mail/role/status/job_title.
-- ----------------------------------------------------------------------------
create or replace view public.v_team_album as
select
  p.id as user_id,
  p.full_name,
  p.brand_id,
  p.store_id,
  s.name as store_name,
  p.emoji,
  p.phrase,
  p.avatar_url,
  p.specialty,
  p.favorite_watch,
  p.sport,
  p.reputation_score,
  p.is_top_seller,
  p.performance_score,
  coalesce(lp.produto_pct, 0) as produto_pct,
  coalesce(qz.precisao_pct, 0) as precisao_pct,
  coalesce(gm.jogo_pct, 0) as jogo_pct,
  coalesce(cert.classe, 'Explorador') as classe
from public.profiles p
left join public.stores s on s.id = p.store_id
left join lateral (
  select round(
    100.0 * count(*) filter (where l2.completed_at is not null) / nullif(count(*), 0)
  )::int as produto_pct
  from public.lessons les
  join public.lesson_progress l2 on l2.lesson_id = les.id and l2.user_id = p.id
  where les.is_published = true
) lp on true
left join lateral (
  select round(avg(qa.score_pct))::int as precisao_pct
  from public.quiz_attempts qa
  where qa.user_id = p.id and qa.finished_at is not null
) qz on true
left join lateral (
  select round(avg(gsc.accuracy_pct))::int as jogo_pct
  from public.game_sessions gs
  join public.game_scores gsc on gsc.session_id = gs.id
  where gs.user_id = p.id and gs.finished_at is not null
) gm on true
left join lateral (
  select c.title as classe
  from public.user_certifications uc
  join public.certifications c on c.id = uc.certification_id
  where uc.user_id = p.id and uc.revoked_at is null
  order by case c.slug
    when 'triatleta'    then 4
    when 'maratonista'  then 3
    when 'corredor'     then 2
    when 'explorador'   then 1
    else 0
  end desc
  limit 1
) cert on true
where p.status = 'active'
  and (
    fn_is_admin()
    or p.brand_id = (select brand_id from public.profiles where id = auth.uid())
  );

comment on view public.v_team_album is
  'Álbum da Equipe (2026-07-12) — view pública estreita sobre profiles, mesmo padrão de v_ranking_public (sql/026): qualquer autenticado vê a equipe inteira da própria marca, admin vê tudo. Produto/Precisão/Jogo calculados de dado real (lesson_progress/quiz_attempts/game_scores); Classe é a certificação mais alta emitida e não revogada, default "Explorador" pra quem ainda não tem nenhuma.';

grant select on public.v_team_album to authenticated;

-- ----------------------------------------------------------------------------
-- 4. Ranking de performance_score (Ritmo) — reaproveita v_ranking_public
--    (sql/026) no cliente pra derivar a posição relativa; nenhuma view/
--    função nova necessária aqui (Ritmo = percentil calculado em JS a
--    partir do mesmo dado que a tela de Ranking já usa).
-- ============================================================================
-- FIM DA MIGRAÇÃO 037
-- ============================================================================
