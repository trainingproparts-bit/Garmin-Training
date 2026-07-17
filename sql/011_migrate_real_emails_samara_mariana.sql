-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 011: e-mail real de Samara e Mariana
-- ============================================================================
-- Mesmo tipo de troca já feita (fora de arquivo versionado, via SQL Editor)
-- para Ailma Almeida e Mayara Freire, registrada em PROJECT_CHECKLIST.md
-- ("Usuários & Papéis"). Editar e-mail de usuário JÁ EXISTENTE não exige a
-- Supabase Admin API/Edge Function — só criar usuário novo exige (precisa
-- gerar hash de senha corretamente). UPDATE direto não passa pelo mailer do
-- GoTrue, então nenhum e-mail de confirmação é disparado.
--
-- Confirmado com o usuário em 2026-07-09: samara.pereira@proparts.net.br e
-- mariana.muzzio@proparts.esp.br são e-mails reais de fato (não placeholder).
-- Os outros 10 usuários ainda sem e-mail real confirmado permanecem no
-- domínio placeholder @proparts.internal.
-- ============================================================================

update auth.users
set email = 'samara.pereira@proparts.net.br'
where id = '832a81e4-799b-4f39-ac52-547ce8213ed6';

update auth.users
set email = 'mariana.muzzio@proparts.esp.br'
where id = '6ae99023-4f5e-4d30-9076-f801e2194a3a';

update auth.identities
set identity_data = jsonb_set(identity_data, '{email}', to_jsonb('samara.pereira@proparts.net.br'::text))
where user_id = '832a81e4-799b-4f39-ac52-547ce8213ed6';

update auth.identities
set identity_data = jsonb_set(identity_data, '{email}', to_jsonb('mariana.muzzio@proparts.esp.br'::text))
where user_id = '6ae99023-4f5e-4d30-9076-f801e2194a3a';

-- ============================================================================
-- FIM DA MIGRAÇÃO 011 — aplicado e confirmado ao vivo em 2026-07-09.
-- ============================================================================
