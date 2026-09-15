-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 161: Cirqa — capa do card em Linhas Especiais
-- ============================================================================
-- Complementa sql/160: foto oficial de produto (CDN Garmin, SKU 010-04675-00,
-- o Cirqa Smart Band) como cover_url do artigo deep_dive, mesmo padrão dos
-- outros cards da Dashboard que já têm foto (não fica sem capa/com ícone).
-- ============================================================================

update content_library
set payload = jsonb_set(payload, '{cover_url}', '"https://res.garmin.com/transform/image/upload/b_rgb:FFFFFF,c_pad,dpr_1.0,f_auto,h_800,q_auto,w_800/c_pad,h_800,w_800/v1/Product_Images/en/products/010-04675-00/v/cf-xl?pgw=1"'::jsonb)
where slug = 'cirqa-monitoramento-sem-tela';

-- ============================================================================
-- FIM DA MIGRAÇÃO 161
-- ============================================================================
