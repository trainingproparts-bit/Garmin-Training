-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 038: Novos Badges Automáticos Profissionais
-- ============================================================================
-- Adiciona badges automáticos focados em ambiente corporativo/profissional:
-- - Speed Run (quiz completo em <60s com aprovação)
-- - Inabalável (reprova, refaz em <24h com 100%)
-- - Especialista Garmin (100% em todos os quizzes de um módulo de produto)
-- - Foco de Ferro (5 lições teóricas seguidas sem pular para quizzes)
-- - Gente Boa (primeira trilha completa em 7 dias após cadastro)
-- - Destaque do Mês (curadoria do Admin/Líder)
-- - Influenciador da Loja (10 reações em postagem do activity_feed)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Inserir novos badges na tabela badges
-- ----------------------------------------------------------------------------
-- Badges de Performance em Quizzes
insert into public.badges (brand_id, slug, title, description, icon_url, rule)
select b.id, 'speed-run-' || b.slug, 'Speed Run', 'Quiz completo em menos de 60 segundos com nota de aprovação (mínimo 80%).', '⚡', '{"type": "quiz_speed", "max_seconds": 60, "min_score_pct": 80}'::jsonb
from public.brands b
where not exists (
  select 1 from public.badges existing where existing.brand_id = b.id and existing.slug = 'speed-run-' || b.slug
);

insert into public.badges (brand_id, slug, title, description, icon_url, rule)
select b.id, 'inabalavel-' || b.slug, 'Inabalável', 'Reprovou um quiz, refaz em menos de 24 horas e consegue aprovação com nota máxima (100%).', '💪', '{"type": "quiz_recovery", "max_hours": 24, "required_score_pct": 100}'::jsonb
from public.brands b
where not exists (
  select 1 from public.badges existing where existing.brand_id = b.id and existing.slug = 'inabalavel-' || b.slug
);

-- Badges de Excelência e Consistência Profissional
insert into public.badges (brand_id, slug, title, description, icon_url, rule)
select b.id, 'especialista-garmin-' || b.slug, 'Especialista Garmin', 'Nota máxima (100%) em todos os quizzes de um módulo de produto específico.', '🎯', '{"type": "module_perfection", "required_score_pct": 100}'::jsonb
from public.brands b
where not exists (
  select 1 from public.badges existing where existing.brand_id = b.id and existing.slug = 'especialista-garmin-' || b.slug
);

insert into public.badges (brand_id, slug, title, description, icon_url, rule)
select b.id, 'foco-de-ferro-' || b.slug, 'Foco de Ferro', 'Completou 5 lições teóricas seguidas sem pular para os quizzes, demonstrando assimilação do material técnico.', '📚', '{"type": "consecutive_lessons", "required_count": 5}'::jsonb
from public.brands b
where not exists (
  select 1 from public.badges existing where existing.brand_id = b.id and existing.slug = 'foco-de-ferro-' || b.slug
);

insert into public.badges (brand_id, slug, title, description, icon_url, rule)
select b.id, 'gente-boa-' || b.slug, 'Gente Boa', 'Concluiu a primeira trilha de integração completa nos primeiros 7 dias após o cadastro.', '🌟', '{"type": "onboarding_speed", "max_days": 7}'::jsonb
from public.brands b
where not exists (
  select 1 from public.badges existing where existing.brand_id = b.id and existing.slug = 'gente-boa-' || b.slug
);

-- Badges de Comunidade e Liderança
insert into public.badges (brand_id, slug, title, description, icon_url, rule)
select b.id, 'destaque-mes-' || b.slug, 'Destaque do Mês', 'Marcado como "Ponta do Mês" pelo administrador/líder no Álbum da Equipe.', '🏆', '{"type": "manual_leader", "requires_admin": true}'::jsonb
from public.brands b
where not exists (
  select 1 from public.badges existing where existing.brand_id = b.id and existing.slug = 'destaque-mes-' || b.slug
);

insert into public.badges (brand_id, slug, title, description, icon_url, rule)
select b.id, 'influenciador-loja-' || b.slug, 'Influenciador da Loja', 'Postagem de conquista no activity_feed atingiu 10 reações (curtidas/palmas) dos colegas de equipe.', '👏', '{"type": "social_engagement", "required_reactions": 10}'::jsonb
from public.brands b
where not exists (
  select 1 from public.badges existing where existing.brand_id = b.id and existing.slug = 'influenciador-loja-' || b.slug
);

-- ============================================================================
-- FIM DA MIGRAÇÃO 038 - PARTE 1 (INSERÇÃO DE BADGES)
-- ============================================================================
