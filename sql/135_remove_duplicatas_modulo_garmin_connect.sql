-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 135: Remove lições duplicadas do módulo
-- "Garmin Connect", criadas por sql/134 ter sido executada duas vezes
-- ============================================================================
-- A migração 134 reaproveitava 4 lições existentes (update, idempotente) e
-- inseria 11 lições novas (insert, NÃO idempotente). Como o arquivo foi
-- rodado duas vezes no SQL Editor do Supabase, as 11 lições novas foram
-- inseridas duas vezes cada (22 linhas, mesmo order_index duplicado em cada
-- par), totalizando 26 lições no módulo em vez de 15.
--
-- Confirmado antes de remover: nenhuma das 11 linhas duplicadas abaixo tem
-- registro em lesson_progress (verificado ao vivo via Supabase client), e a
-- tabela checkpoints não referencia lesson_id — seguro remover diretamente,
-- sem risco de violar FK ou apagar progresso de usuário.
--
-- Mantém 1 linha de cada par (a primeira inserida) e remove a outra, pelo id
-- exato — nunca por título/order_index (evita remover a linha errada caso a
-- ordem no banco não bata com a ordem de retorno da query usada para
-- diagnosticar).
-- ============================================================================

do $$
declare
  v_deleted int;
begin
  delete from lessons where id in (
    '757531ab-6731-4374-8e70-f8b60b0cedb4', -- Do relógio para o Garmin Connect (duplicata)
    'ca09277e-6725-4af0-ba5f-cd34ae37e32e', -- O que o cliente encontra no Connect (duplicata)
    '6407ba86-a915-4ffd-96b5-7cb8248e6fa3', -- Conheça as principais métricas (duplicata)
    '48a3ac4a-5ebf-44f9-a4cd-b2a920d719b1', -- Uma métrica raramente conta toda a história (duplicata)
    '773999b3-3db4-44a2-aab1-3d7006dd416a', -- Como explicar uma métrica (duplicata)
    '04ba9fa4-9b89-4fe9-830c-d3e7de2e0342', -- Associe a necessidade à métrica (duplicata)
    '2fc0b903-bf7d-4e3f-9342-82af1f8f0043', -- Métrica + perfil de cliente (duplicata)
    '47f2a3f8-3ebd-4211-a4c0-afd94f315904', -- Como apresentar o Garmin Connect na loja (duplicata)
    '37b22fec-e623-4561-9b71-674c3a060a34', -- Erros comuns na demonstração (duplicata)
    '721ccc52-ab28-49f1-af2f-9fcef40821ac', -- Checklist de integração (duplicata)
    '2f85741c-216a-4100-931d-e7027b157fe4'  -- Encerramento (duplicata)
  );

  get diagnostics v_deleted = row_count;

  if v_deleted <> 11 then
    raise exception 'Esperava remover exatamente 11 lições duplicadas, removeu %. Revise antes de continuar.', v_deleted;
  end if;
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 135
-- ============================================================================
