-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 149: CIRQA — Visão Geral (redesign)
-- ============================================================================
-- Pedido do usuário (2026-09-15): redesign da página do CIRQA como
-- "experiência de descoberta do produto" — resumo de 30 segundos (4 pontos)
-- + detalhe existente preservado + comparativo curto CIRQA vs smartwatch
-- tradicional (não é sobre qual é melhor, é sobre pra qual necessidade cada
-- um foi feito). Peso corrigido pra 20g (real, fonte: DC Rainmaker "Garmin
-- Cirqa Hands-On" — o texto já cadastrado antes dizia "cerca de 21g").
-- ============================================================================

insert into product_sections (product_id, section_type, payload)
values ('c803a82e-a40a-4f95-8564-34dbd480f9d9', 'visao_geral', $j$
{
  "blocks": [
    {
      "type": "texto_rico",
      "html": "<p><strong>Performance e saúde sem distração.</strong></p><p>Monitoramento contínuo de saúde e recuperação em um dispositivo discreto, sem tela e sem a necessidade de uma assinatura para acessar os principais dados.</p>"
    },
    {
      "type": "card_grid",
      "columns": 2,
      "items": [
        {"title": "Sem tela", "text": "Foco em dados, sem notificações ou distrações no dia a dia.", "tags": []},
        {"title": "Até 10 dias", "text": "Autonomia de bateria para monitoramento contínuo.", "tags": []},
        {"title": "Elevate Gen 4", "text": "Sensor óptico para frequência cardíaca e outros dados de saúde.", "tags": []},
        {"title": "Garmin Connect", "text": "Os dados ficam integrados ao ecossistema Garmin.", "tags": []}
      ]
    },
    {
      "type": "texto_rico",
      "html": "<h4>Em mais detalhe</h4><p>O <strong>Cirqa</strong> é a pulseira de bem-estar sem tela da Garmin, anunciada oficialmente em 21 de julho de 2026 e disponível pra compra a partir de 24 de julho de 2026. Usa sensor óptico Elevate Gen 4 e Pulse Ox, num corpo de 27x47x9mm e 20g, com resistência 5 ATM (dá pra nadar).</p><p><strong>Diferencial de posicionamento:</strong> ao contrário de concorrentes do mesmo segmento sem tela, o Cirqa não exige assinatura pra usar os recursos principais do Garmin Connect; só o Connect+ (opcional) adiciona treinos guiados e coaching.</p>"
    },
    {
      "type": "card_grid",
      "columns": 3,
      "items": [
        {"title": "Sem tela, um botão físico", "text": "Design minimalista, com pulseira de tecido ComfortFit.", "tags": []},
        {"title": "Sem assinatura obrigatória", "text": "Recursos principais do Garmin Connect vêm inclusos, sem mensalidade.", "tags": []},
        {"title": "Até 10 dias de bateria", "text": "Carregador proprietário da Garmin.", "tags": []},
        {"title": "80+ atividades", "text": "Corrida, ciclismo, yoga e mais, controladas pelo botão ou pelo app.", "tags": []},
        {"title": "Usa no pulso ou no braço", "text": "Design versátil, com alça de tecido.", "tags": []},
        {"title": "5 ATM", "text": "Resistente o suficiente pra nadar.", "tags": []}
      ]
    },
    {
      "type": "tabela",
      "headers": ["", "CIRQA", "Smartwatch tradicional"],
      "rows": [
        ["Tela", "Sem tela", "Tela e notificações"],
        ["Mensalidade para dados principais", "Não exige", "Varia por marca"],
        ["Bateria", "Até 10 dias", "Geralmente alguns dias"],
        ["Ecossistema", "Garmin Connect", "Depende da marca"]
      ]
    },
    {
      "type": "texto_rico",
      "html": "<p>Não se trata de um produto ser melhor que o outro — é sobre para qual necessidade o Cirqa foi criado.</p>"
    }
  ]
}
$j$::jsonb)
on conflict (product_id, section_type) do update set payload = excluded.payload;

-- ============================================================================
-- FIM DA MIGRAÇÃO 149
-- ============================================================================
