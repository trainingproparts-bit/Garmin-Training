-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 151: CIRQA — Diferenciais + Garmin Connect
-- vs Connect+ (redesign)
-- ============================================================================
-- Pedido do usuário (2026-09-15): 5 diferenciais centrais (framing do
-- briefing) + tabs Garmin Connect (grátis) vs Connect+ (pago), reaproveitando
-- fatos já existentes (não inventa recursos). "Modo cadeira de rodas" e
-- "GPS via celular"/"sem ECG" (que estavam nos diferenciais antigos)
-- migraram pra "Uso" e "Hardware" respectivamente — nada foi removido, só
-- reorganizado num lugar mais específico.
-- ============================================================================

insert into product_sections (product_id, section_type, payload)
values ('c803a82e-a40a-4f95-8564-34dbd480f9d9', 'diferenciais', $j$
{
  "blocks": [
    {
      "type": "accordion",
      "items": [
        {"title": "Distração zero", "html": "<p>Sem tela para acompanhar notificações durante o dia — o foco fica nos dados de saúde e recuperação, não em interações constantes no pulso.</p>"},
        {"title": "Monitoramento contínuo", "html": "<p>Pensado para acompanhar dados ao longo do dia e durante o sono: frequência cardíaca 24h, SpO2 e temperatura de pele à noite, respiração e HRV.</p>"},
        {"title": "Até 10 dias", "html": "<p>Autonomia que reduz a necessidade de carregamento, com bateria recarregável embutida e carregador proprietário USB-C.</p>"},
        {"title": "Garmin Connect", "html": "<p>Integração completa com o ecossistema Garmin — treino, sono, recuperação e mais de 80 atividades manuais, tudo no mesmo app.</p>"},
        {"title": "Sem assinatura obrigatória", "html": "<p>Diferente de concorrentes do mesmo conceito (banda sem tela), os recursos principais do Garmin Connect vêm inclusos sem mensalidade. O Connect+ é opcional, pra quem quer treinos guiados e coaching extra.</p>"}
      ]
    },
    {
      "type": "tabs",
      "items": [
        {
          "label": "Garmin Connect",
          "title": "O que o cliente recebe sem assinatura",
          "text": "<ul><li>Todo o acompanhamento de saúde e fitness: passos, FC, sono, HRV, SpO2, temperatura de pele, estresse e ciclo menstrual</li><li>Detecção automática de atividade e registro manual</li><li>Carga de Treino (Carga Aguda, Relação de Carga, Foco de Carga)</li><li>Status e Prontidão de Treino</li><li>Tempo de Recuperação e Efeito de Treino</li><li>Mais de 80 tipos de atividade manual</li><li>Transmissão de frequência cardíaca (ANT+ e Bluetooth)</li><li>Diário de saúde e painel de Status de Saúde</li></ul>"
        },
        {
          "label": "Garmin Connect+",
          "title": "O que é adicional",
          "text": "<ul><li>Treinos guiados do Garmin Coach (Força e Fitness) direto no app</li><li>Treinos estruturados (Cardio, Yoga, HIIT, Força, Pilates, Cadeira de Rodas)</li><li>Acompanhamento nutricional</li><li>Criação manual de voltas durante a atividade</li><li>Gráfico de frequência cardíaca ao vivo durante a atividade</li><li>Insights de IA (Active Intelligence)</li><li>Painel de performance (versão web)</li><li>LiveTrack aprimorado e mapas 3D no app</li><li>Descontos em acessórios</li></ul>",
          "note": "Recursos opcionais — nenhum deles é necessário pros dados principais de saúde e treino do Cirqa."
        }
      ]
    }
  ]
}
$j$::jsonb)
on conflict (product_id, section_type) do update set payload = excluded.payload;

-- ============================================================================
-- FIM DA MIGRAÇÃO 151
-- ============================================================================
