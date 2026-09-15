-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 118: Pergunta-chave nos Perfis de Cliente
-- ============================================================================
-- Pedido do usuário (2026-09-15): reformular a tela "Perfis de Cliente" (Biblioteca
-- Técnica) de bloco de texto para ficha de consulta rápida, com uma pergunta que
-- o vendedor pode fazer na loja para confirmar o perfil do cliente.
--
-- Esse campo NÃO existia em nenhum dos 11 perfis (payload tinha apenas emoji,
-- name, tag, tags, sinais, comunicacao, produtos, primario, objections — ver
-- sql/seeds/040_biblioteca_tecnica.sql). Em vez de inventar informação nova
-- sobre produto, cada pergunta abaixo foi escrita reaproveitando o que já
-- estava em `sinais` daquele mesmo perfil (o "sinal" de identificação virou
-- pergunta direta) — é reorganização do conteúdo já cadastrado, não um dado
-- novo sobre o cliente ou o produto. Vale revisão de quem já mexeu nesse
-- conteúdo antes.
--
-- jsonb_set com `create_missing => true` só adiciona a chave 'pergunta_chave' —
-- não toca em nenhuma chave existente, então nada do que já estava cadastrado
-- (comunicacao, objections, tags etc.) é alterado ou perdido.
-- ============================================================================

update content_library set payload = jsonb_set(payload, '{pergunta_chave}', '"Você já usa algum relógio para treinar, ou seria o primeiro?"', true), updated_at = now()
  where category = 'perfil_cliente' and slug = 'corredor-iniciante';

update content_library set payload = jsonb_set(payload, '{pergunta_chave}', '"Com que frequência você corre, e já usa relógio com GPS hoje?"', true), updated_at = now()
  where category = 'perfil_cliente' and slug = 'corredor-dedicado';

update content_library set payload = jsonb_set(payload, '{pergunta_chave}', '"Você compete ou treina pensando em provas como triathlon ou ultramaratona?"', true), updated_at = now()
  where category = 'perfil_cliente' and slug = 'atleta-de-elite-triatleta';

update content_library set payload = jsonb_set(payload, '{pergunta_chave}', '"Você costuma fazer trilha, montanha ou expedição em lugares sem sinal?"', true), updated_at = now()
  where category = 'perfil_cliente' and slug = 'aventureiro-trilheiro';

update content_library set payload = jsonb_set(payload, '{pergunta_chave}', '"Você procura algo mais discreto para o dia a dia, ou é para presentear?"', true), updated_at = now()
  where category = 'perfil_cliente' and slug = 'mulher-lifestyle';

update content_library set payload = jsonb_set(payload, '{pergunta_chave}', '"Você pedala com frequência — na estrada, no MTB ou nos dois?"', true), updated_at = now()
  where category = 'perfil_cliente' and slug = 'ciclista';

update content_library set payload = jsonb_set(payload, '{pergunta_chave}', '"Você nada com regularidade, ou está se preparando para um triathlon?"', true), updated_at = now()
  where category = 'perfil_cliente' and slug = 'nadador-triatleta';

update content_library set payload = jsonb_set(payload, '{pergunta_chave}', '"Você já mergulha? Usa ou já usou computador de mergulho?"', true), updated_at = now()
  where category = 'perfil_cliente' and slug = 'mergulhador';

update content_library set payload = jsonb_set(payload, '{pergunta_chave}', '"Você joga golfe com que frequência?"', true), updated_at = now()
  where category = 'perfil_cliente' and slug = 'golfista';

update content_library set payload = jsonb_set(payload, '{pergunta_chave}', '"Você costuma viajar de moto? Já usa algum GPS na estrada?"', true), updated_at = now()
  where category = 'perfil_cliente' and slug = 'motociclista';

update content_library set payload = jsonb_set(payload, '{pergunta_chave}', '"Você pesca em rio, represa ou mar — e anda de barco?"', true), updated_at = now()
  where category = 'perfil_cliente' and slug = 'pescador-nautico';

-- ============================================================================
-- FIM DA MIGRAÇÃO 118
-- ============================================================================
