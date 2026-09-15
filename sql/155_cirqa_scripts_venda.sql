-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 155: CIRQA — Scripts de Venda (posicionamento)
-- ============================================================================
-- Pedido do usuário (2026-09-15): 4 situações de cliente clicáveis (accordion)
-- com sugestão curta de abordagem — mantém o roteiro abertura/fechamento já
-- existente sem alteração.
-- ============================================================================

insert into product_sections (product_id, section_type, payload)
values ('c803a82e-a40a-4f95-8564-34dbd480f9d9', 'scripts_venda', $j$
{
  "blocks": [
    {
      "type": "roteiro",
      "steps": [
        {"title": "Abertura pra quem já considera uma banda sem tela", "dialog": "Se você já está olhando uma pulseira de bem-estar sem tela, o Cirqa entrega os mesmos dados de recuperação e treino, mas sem te prender numa assinatura mensal obrigatória pra usar o básico.", "tip": "Bom gancho pra quem já mencionou marcas concorrentes desse segmento."},
        {"title": "Fechamento", "dialog": "Com o Cirqa você sai com até 10 dias de bateria, mais de 80 atividades reconhecidas, e todos os principais dados de recuperação do ecossistema Garmin, sem mensalidade obrigatória.", "tip": "Se o cliente quer ver dado na tela durante o treino, redirecione pra um Forerunner básico."}
      ]
    },
    {"type": "texto_rico", "html": "<hr class=\"cb-topic-divider\"><h3>Quando o CIRQA faz sentido?</h3><p>Toque em cada situação pra ver uma sugestão curta de abordagem.</p>"},
    {
      "type": "accordion",
      "items": [
        {"title": "\"Não quero mais um relógio com tela.\"", "html": "<p>O Cirqa pode ser uma alternativa: mesma qualidade de dado de saúde e recuperação do ecossistema Garmin, sem tela no pulso.</p>"},
        {"title": "\"Quero acompanhar meu sono e recuperação.\"", "html": "<p>Explore o monitoramento contínuo (frequência cardíaca 24h, sono, HRV, estresse) e a integração com o Garmin Connect.</p>"},
        {"title": "\"Não quero pagar mensalidade.\"", "html": "<p>Explique o modelo Garmin: os recursos principais do Garmin Connect vêm inclusos na compra do Cirqa, sem assinatura obrigatória.</p>"},
        {"title": "\"Já tenho outro Garmin.\"", "html": "<p>Explore o Cirqa como complemento ao ecossistema — por exemplo, pra quem quer monitorar saúde sem usar o relógio principal o dia todo.</p>"}
      ]
    }
  ]
}
$j$::jsonb)
on conflict (product_id, section_type) do update set payload = excluded.payload;

-- ============================================================================
-- FIM DA MIGRAÇÃO 155
-- ============================================================================
