-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 037: Atualização de Produtos Obsoletos
-- ============================================================================
-- Remove referências a modelos descontinuados (Epix, Forerunner 55) e
-- substitui por modelos atuais nos templates do Mural de Atividades.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Atualizar templates de mensagem no Mural de Atividades
-- ----------------------------------------------------------------------------
-- Substituir referências de alta performance/outdoor (antigo Epix) por Fēnix 8
-- Substituir referências de corrida de entrada (antigo Forerunner 55) por Forerunner 165

create or replace function public.fn_leader_post_activity(
  p_template_key  text,
  p_subject_id    uuid default null,
  p_product_model text default null,
  p_store_id      uuid default null
)
returns public.activity_feed
language plpgsql
security definer
set search_path = public
as $$
declare
  v_subject    record;
  v_store      record;
  v_message    text;
  v_row        public.activity_feed;
  v_is_team_template boolean := p_template_key in ('meta_dia', 'meta_mes');
  v_brand_id   uuid;
  v_author     record;
begin
  if not (fn_is_leader() or fn_is_admin()) then
    raise exception 'apenas líderes ou administradores podem postar no mural';
  end if;

  -- Derivar brand_id do autor (líder/admin) como fallback
  select id, brand_id into v_author from profiles where id = auth.uid();
  v_brand_id := v_author.brand_id;

  if v_is_team_template then
    if p_store_id is null then
      raise exception 'loja é obrigatória para este tipo de destaque';
    end if;

    select id, name, brand_id into v_store from stores where id = p_store_id;
    if v_store.id is null then
      raise exception 'loja % não encontrada', p_store_id;
    end if;

    -- Usar brand_id da loja se disponível, senão do autor
    if v_store.brand_id is not null then
      v_brand_id := v_store.brand_id;
    end if;

    if fn_is_leader() and not fn_is_admin() and p_store_id not in (select fn_leader_store_ids()) then
      raise exception 'loja % não está sob sua gestão', p_store_id;
    end if;

    v_message := case p_template_key
      when 'meta_dia' then format('🔥 Meta Batida! A equipe da loja %s cravou o objetivo do dia! O painel tá verde! 🍾', v_store.name)
      when 'meta_mes' then format('🏆 GIGANTES DO MÊS! A equipe da loja %s jogou em nível de elite e acaba de BATER A META MENSAL! Parabéns pelo foco inabalável! 🥂🔥🥇', v_store.name)
    end;

    insert into activity_feed (brand_id, subject_id, store_id, author_id, trigger_type, source_event, message)
    values (v_brand_id, null, v_store.id, auth.uid(), 'manual', 'leader_manual', v_message)
    returning * into v_row;

    return v_row;
  end if;

  -- templates individuais: exigem vendedor
  if p_subject_id is null then
    raise exception 'vendedor é obrigatório para este tipo de destaque';
  end if;

  select id, full_name, brand_id, store_id into v_subject from profiles where id = p_subject_id;
  if v_subject.id is null then
    raise exception 'colaborador % não encontrado', p_subject_id;
  end if;

  -- Usar brand_id do subject se disponível, senão do autor
  if v_subject.brand_id is not null then
    v_brand_id := v_subject.brand_id;
  end if;

  if fn_is_leader() and not fn_is_admin() then
    if v_subject.store_id is null or v_subject.store_id not in (select fn_leader_store_ids()) then
      raise exception 'colaborador % não está em loja sob sua gestão', p_subject_id;
    end if;
  end if;

  -- Modelos atualizados: Fēnix 8 (substitui Epix), Forerunner 165 (substitui FR55)
  v_message := case p_template_key
    when 'relogio_corrida'   then format('%s mandou bem demais e garantiu um Forerunner %s no pulso de mais um corredor! 🏃‍♂️🚀', v_subject.full_name, coalesce(p_product_model, '165'))
    when 'relogio_outdoor'   then format('%s acaba de fechar a venda de um Fēnix %s! O cliente levou o ápice da resistência e navegação técnica. ⛰️🏆', v_subject.full_name, coalesce(p_product_model, '8'))
    when 'relogio_lifestyle' then format('Tem novo cliente monitorando tudo com o Venu vendido por %s. Venda certeira e elegante! ✨⌚', v_subject.full_name)
    when 'combo_acessorios'  then format('%s garantiu a experiência completa com relógio + acessórios extras para o cliente! ➕🎯', v_subject.full_name)
    else null
  end;

  if v_message is null then
    raise exception 'template % desconhecido', p_template_key;
  end if;

  insert into activity_feed (brand_id, subject_id, store_id, author_id, trigger_type, source_event, message)
  values (v_brand_id, v_subject.id, v_subject.store_id, auth.uid(), 'manual', 'leader_manual', v_message)
  returning * into v_row;

  return v_row;
end;
$$;

comment on function public.fn_leader_post_activity(text, uuid, text, uuid) is
  'Único caminho pro líder/admin postar no Mural — sempre por template fixo (nunca texto livre), validando escopo de loja do líder. Templates atualizados com modelos atuais: Forerunner 165 (substitui FR55), Fēnix 8 (substitui Epix).';

-- ============================================================================
-- FIM DA MIGRAÇÃO 037
-- ============================================================================
