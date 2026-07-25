-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 102 (documentação retroativa): auditoria
-- completa da Academia de Produtos (38 produtos / ~140 perguntas)
-- ============================================================================
-- Auditoria "pente-fino" pedida pelo usuário, executada por agente em
-- background e já aplicada diretamente ao banco via execute_sql (esta
-- migração documenta o que já está em produção, para manter o histórico
-- consistente com o resto das migrações desta sessão).
--
-- Todos os 38 produtos / ~140 perguntas foram revisados um a um contra
-- fontes oficiais atuais (garmin.com, support.garmin.com, DC Rainmaker).
-- 3 erros reais de superclaim/exclusividade foram encontrados e corrigidos
-- (abaixo, já aplicados, statements incluídos só pra documentação e pra
-- reaplicação segura em caso de rebuild do banco):
--
--   1. Edge 1040 — dizia que Garmin Pay era exclusivo do Edge 1050; na
--      verdade o Edge 850 também tem.
--   2. Forerunner 55 — dizia que armazenamento de música era exclusivo do
--      Forerunner 70; na verdade nem o 55 nem o 70 base têm, só o
--      Forerunner 170 Music.
--   3. Venu 3 — dizia que GPS multibanda era exclusividade da linha
--      Forerunner; falso (Fenix, Epix, Instinct 3, Enduro e até o Venu 4
--      também têm). Reformulado sem a alegação de exclusividade.
--
-- Restante do catálogo (34 de 38 produtos, ~130 perguntas): revisado e
-- confirmado correto, sem alterações.
--
-- Flags pra checagem manual (não é erro confirmado, achado da pesquisa):
--   - inReach Mini 3 Plus: pergunta sobre bateria menor que o Mini 3 tem
--     fontes conflitantes (manual oficial vs. varejo) sobre o modo exato
--     de comparação. Não alterado até confirmação adicional.
--   - GPSMAP 66sr: aparece como "descontinuado" em alguns varejistas do
--     Reino Unido, mas segue ativo no site oficial americano da Garmin e
--     na Amazon. Conteúdo da pergunta em si está correto (bateria de
--     expedição 450h, definição de sensor ABC); vale checagem comercial
--     à parte sobre manter no catálogo ativo, não é uma correção de
--     conteúdo.
-- ============================================================================

begin;

update questions set explanation = null where id = 'bf9a5984-18ee-4a3e-b5b6-2f7d59aef8fd';
update alternatives set body = 'Não, esse recurso só chegou depois, com o Edge 1050 (e também está no Edge 850)', is_correct = true where id = 'e8d92cc8-31c8-483d-9d8d-34683a93a2a3';
update alternatives set body = 'Sim, tem Garmin Pay', is_correct = false where id = 'ae426535-ffab-4aa5-83c8-0b08a4ac0bc8';

update questions set explanation = null where id = '4c378c9d-2414-4cb4-a84f-91d4dbee2de7';
update alternatives set body = 'Não, nem o 55 nem o 70 têm: armazenamento de música só chegou com o Forerunner 170 Music', is_correct = true where id = '912229da-a09c-48af-831a-e74974b8b492';

update questions set explanation = null where id = '9e897be2-db41-4a58-9811-0b04d1fce92e';
update alternatives set body = 'Não, o Venu 3 usa GNSS multi-constelação, mas sem multibanda', is_correct = true where id = '9cdab563-685a-42d2-b3aa-372928cd616a';

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 102
-- ============================================================================
