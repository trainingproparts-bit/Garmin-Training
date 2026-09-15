-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 150: CIRQA — Personas (redesign)
-- ============================================================================
-- Pedido do usuário (2026-09-15): 3 perfis simplificados (Minimalista/
-- Atleta/Usuário Garmin) em vez dos rótulos anteriores (Minimalista/
-- Custo-benefício/Entrada) — mesma substância, framing pedido no briefing.
-- Banners "quando indicar"/"quando não indicar" preservados sem alteração.
-- ============================================================================

insert into product_sections (product_id, section_type, payload)
values ('c803a82e-a40a-4f95-8564-34dbd480f9d9', 'personas', $j$
{
  "blocks": [
    {
      "type": "card_grid",
      "columns": 3,
      "items": [
        {"title": "Quer monitoramento sem uma tela no pulso", "text": "Já usa um relógio comum ou não quer tela, só quer os dados de bem-estar.", "tags": [{"color": "blue", "label": "Minimalista"}]},
        {"title": "Busca acompanhar recuperação e evolução", "text": "Usa Prontidão de Treino, VO2 Max e HRV pra entender sua evolução ao longo do tempo.", "tags": [{"color": "gold", "label": "Atleta"}]},
        {"title": "Quer integrar os dados ao Garmin Connect", "text": "Não precisa do relógio completo pra começar a acompanhar treino e sono.", "tags": [{"color": "green", "label": "Usuário Garmin"}]}
      ]
    },
    {
      "type": "banner",
      "tone": "success",
      "text": "<strong>Quando indicar:</strong><ul><li>Cliente já usa ou está comparando com bandas sem tela de bem-estar (tipo Whoop) e valoriza não pagar assinatura obrigatória</li><li>Cliente quer entrar no ecossistema Garmin sem o investimento de um relógio completo</li></ul>"
    },
    {
      "type": "banner",
      "tone": "warning",
      "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer ver dados na tela durante o treino, sem depender do celular → um Forerunner básico atende melhor</li><li>Cliente quer ECG ou o sensor Elevate Gen 5 mais recente → o Cirqa usa Gen 4, sem ECG</li></ul>"
    }
  ]
}
$j$::jsonb)
on conflict (product_id, section_type) do update set payload = excluded.payload;

-- ============================================================================
-- FIM DA MIGRAÇÃO 150
-- ============================================================================
