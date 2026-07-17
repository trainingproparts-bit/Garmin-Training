-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 018: corrige conclusão prematura de checkpoint
-- ============================================================================
-- Achado ao testar pela primeira vez o fluxo completo de colaborador
-- (login → lição → conclusão → quiz desbloqueado): fn_update_user_progress_
-- from_lesson() marcava o checkpoint do módulo como 'completed' assim que
-- UMA lição qualquer daquele módulo batia progress_pct=100 — sem checar se
-- as OUTRAS lições do módulo ainda estavam pendentes. Confirmado ao vivo com
-- Daniel Lucena: completou só a 1ª de 3 lições de "O Universo Garmin" e o
-- checkpoint (e por consequência o quiz seguinte) já apareceu liberado no
-- banco (só não refletiu na tela na hora por falta de refetch — outro
-- achado menor, a tela de trilha não recarrega progresso sozinha ao voltar
-- do conteúdo de um módulo).
--
-- Isso quebra o próprio propósito do bloqueio sequencial (RN/checklist:
-- "Componente de trilha/checkpoints dinâmico... bloqueio sequencial") —
-- um colaborador podia pular 2 de 3 lições e already destravar o quiz.
--
-- Fix: só marca o checkpoint 'completed' quando TODAS as lições publicadas
-- do módulo têm lesson_progress concluído (progress_pct=100) para aquele
-- usuário.
-- ============================================================================

create or replace function public.fn_update_user_progress_from_lesson()
returns trigger
language plpgsql
as $$
declare
  v_module_id       uuid;
  v_checkpoint_id   uuid;
  v_total_lessons   integer;
  v_completed_lessons integer;
begin
  if new.progress_pct < 100 then
    return new;
  end if;

  select module_id into v_module_id from lessons where id = new.lesson_id;

  select count(*) into v_total_lessons
    from lessons
   where module_id = v_module_id
     and is_published = true;

  select count(distinct lp.lesson_id) into v_completed_lessons
    from lesson_progress lp
    join lessons l on l.id = lp.lesson_id
   where lp.user_id = new.user_id
     and l.module_id = v_module_id
     and l.is_published = true
     and lp.progress_pct = 100;

  if v_total_lessons = 0 or v_completed_lessons < v_total_lessons then
    return new;
  end if;

  select id into v_checkpoint_id
    from checkpoints
   where checkpoint_type = 'module'
     and reference_id = v_module_id
   limit 1;

  if v_checkpoint_id is not null then
    insert into user_progress (user_id, checkpoint_id, status, completed_at)
    values (new.user_id, v_checkpoint_id, 'completed', now())
    on conflict (user_id, checkpoint_id)
    do update set status = 'completed', completed_at = now(), updated_at = now()
    where user_progress.status is distinct from 'completed';
  end if;

  return new;
end;
$$;

comment on function public.fn_update_user_progress_from_lesson() is
  'Marca o checkpoint do módulo completed só quando TODAS as lições publicadas do módulo estão concluídas pelo usuário — corrigido em 018 (antes marcava completo já na 1ª lição, destravando o quiz cedo demais).';

-- ============================================================================
-- FIM DA MIGRAÇÃO 018
-- ============================================================================
