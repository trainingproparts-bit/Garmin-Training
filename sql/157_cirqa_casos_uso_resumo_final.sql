-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 157: CIRQA — Casos de Uso + resumo final
-- ============================================================================
-- Pedido do usuário (2026-09-15): mantém os 2 cenários já cadastrados e
-- acrescenta o fechamento "CIRQA em 30 segundos" (para quem é / diferencial
-- principal / pontos pra lembrar) + a pergunta de descoberta de necessidade,
-- como ferramenta, não script obrigatório.
-- ============================================================================

insert into product_sections (product_id, section_type, payload)
values ('c803a82e-a40a-4f95-8564-34dbd480f9d9', 'casos_uso', $j$
{
  "blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem, não são depoimentos reais de clientes)."},
    {
      "type": "card_grid",
      "columns": 2,
      "items": [
        {"title": "Cliente comparando com banda sem tela da concorrência", "text": "Valoriza não pagar assinatura obrigatória pra ver os dados básicos.", "tags": []},
        {"title": "Cliente que quer só monitorar sono e recuperação", "text": "Não precisa de GPS na tela nem de treino estruturado, só dados de bem-estar.", "tags": []}
      ]
    },
    {"type": "texto_rico", "html": "<hr class=\"cb-topic-divider\"><h3>CIRQA em 30 segundos</h3>"},
    {
      "type": "banner",
      "tone": "success",
      "text": "<p><strong>Para quem é:</strong> usuários que querem monitoramento contínuo sem uma tela no pulso.</p><p><strong>Principal diferencial:</strong> dados de saúde e recuperação dentro do ecossistema Garmin, sem depender de assinatura pra acessar os principais recursos.</p><p><strong>Pontos para lembrar:</strong> até 10 dias de bateria, 20g, Elevate Gen 4, Garmin Connect, sem tela, 5 ATM.</p>"
    },
    {
      "type": "banner",
      "tone": "info",
      "text": "<p><strong>Pergunta para descobrir a necessidade:</strong> \"O que mais te incomoda em usar um smartwatch hoje?\"</p><p>Use como ferramenta de descoberta, não como script obrigatório.</p>"
    }
  ]
}
$j$::jsonb)
on conflict (product_id, section_type) do update set payload = excluded.payload;

-- ============================================================================
-- FIM DA MIGRAÇÃO 157
-- ============================================================================
