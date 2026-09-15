-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 154: CIRQA — Comparativo CIRQA × Whoop
-- ============================================================================
-- Pedido do usuário (2026-09-15): comparativo editorial com o Whoop — marca
-- fora do catálogo (sem linha possível em product_comparisons, que exige os
-- dois produtos cadastrados aqui). Usa product_sections com section_type
-- 'comparativos' (liberado pra blocos ricos na sql/148) — a lista nativa de
-- comparativos entre produtos do catálogo (se houver) continua aparecendo
-- normalmente logo abaixo destes blocos (ver renderSectionPanelInner).
-- Tabela resumida + accordion por critério (clique pra ver o porquê).
-- ============================================================================

insert into product_sections (product_id, section_type, payload)
values ('c803a82e-a40a-4f95-8564-34dbd480f9d9', 'comparativos', $j$
{
  "blocks": [
    {"type": "texto_rico", "html": "<h4>CIRQA × Whoop</h4><p>Um dos concorrentes mais citados quando o assunto é monitoramento contínuo sem tela.</p>"},
    {
      "type": "tabela",
      "headers": ["Critério", "CIRQA", "Whoop"],
      "rows": [
        ["Modelo de pagamento", "Compra do dispositivo", "Assinatura"],
        ["Tela", "Sem tela", "Sem tela"],
        ["Autonomia", "Até 10 dias", "Conforme o modelo"],
        ["Ecossistema", "Garmin Connect", "Ecossistema Whoop"],
        ["Interação", "Botão físico + app", "App"]
      ]
    },
    {
      "type": "accordion",
      "items": [
        {"title": "Preço e modelo de pagamento", "html": "<p>O Cirqa é comprado uma vez, sem mensalidade para os recursos principais. O Whoop segue o modelo de assinatura contínua para acessar os dados.</p>"},
        {"title": "Dados e ecossistema", "html": "<p>O Cirqa calcula Prontidão de Treino (atualizada ao longo do dia) dentro do Garmin Connect. O Whoop tem sua própria métrica de Strain/Recovery, avaliada principalmente pela manhã.</p>"},
        {"title": "Bateria", "html": "<p>O Cirqa chega a até 10 dias de bateria. A autonomia do Whoop varia conforme o modelo do concorrente.</p>"},
        {"title": "Uso", "html": "<p>Ambos são sem tela. O Cirqa tem um botão físico para ações rápidas (iniciar atividade, soneca, transmitir frequência cardíaca); o Whoop depende do aplicativo.</p>"}
      ]
    }
  ]
}
$j$::jsonb)
on conflict (product_id, section_type) do update set payload = excluded.payload;

-- ============================================================================
-- FIM DA MIGRAÇÃO 154
-- ============================================================================
