-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 152: CIRQA — Hardware (seção nova)
-- ============================================================================
-- Pedido do usuário (2026-09-15): specs compactas sempre visíveis + tabela
-- técnica completa dentro de um accordion ("Ver especificações completas").
-- Peso corrigido pra 20g real (fonte: DC Rainmaker) — briefing do usuário
-- tinha 14,8g. Dimensões/temperatura/frequência sem fio vêm do manual
-- oficial da Garmin (nunca estiveram cadastradas antes).
-- ============================================================================

insert into product_sections (product_id, section_type, payload)
values ('c803a82e-a40a-4f95-8564-34dbd480f9d9', 'hardware', $j$
{
  "blocks": [
    {"type": "texto_rico", "html": "<h4>Por dentro do CIRQA</h4>"},
    {
      "type": "card_grid",
      "columns": 3,
      "items": [
        {"title": "20 g", "text": "Peso do dispositivo.", "tags": []},
        {"title": "Elevate Gen 4", "text": "Sensor óptico + Pulse Ox.", "tags": []},
        {"title": "5 ATM", "text": "Resistência à água — dá pra nadar.", "tags": []},
        {"title": "Até 10 dias", "text": "Autonomia de bateria.", "tags": []},
        {"title": "Bluetooth + ANT+, USB-C", "text": "Conectividade e carregamento.", "tags": []}
      ]
    },
    {
      "type": "accordion",
      "items": [
        {
          "title": "Ver especificações completas",
          "html": "<p><strong>Dimensões (pulseira S/M):</strong> 24,5 x 2,4 x 0,2 cm.</p><p><strong>Dimensões (pulseira L/XL):</strong> 28,5 x 2,4 x 0,2 cm.</p><p><strong>Dimensões (braçadeira S/M):</strong> 36,0 x 2,4 x 0,2 cm.</p><p><strong>Dimensões (braçadeira L/XL):</strong> 50,0 x 2,4 x 0,2 cm.</p><p><strong>Bateria:</strong> íon-lítio recarregável embutida, até 10 dias.</p><p><strong>Temperatura de operação:</strong> -20°C a 60°C.</p><p><strong>Temperatura de carregamento:</strong> 0°C a 45°C.</p><p><strong>Frequência sem fio:</strong> 2400–2483,5 MHz.</p><p><strong>Resistência à água:</strong> 5 ATM.</p>"
        }
      ]
    }
  ]
}
$j$::jsonb)
on conflict (product_id, section_type) do update set payload = excluded.payload;

-- ============================================================================
-- FIM DA MIGRAÇÃO 152
-- ============================================================================
