-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 153: CIRQA — Uso (seção nova)
-- ============================================================================
-- Pedido do usuário (2026-09-15): pulso vs bíceps (tabs, uma opção aberta
-- por vez), modo cadeira de rodas e botão físico (accordion, movidos de
-- "Diferenciais"), limitações de precisão (sem escondê-las) e legenda de
-- LEDs compacta + tabela completa num accordion. Conteúdo de LEDs/botão/
-- limitações nunca esteve cadastrado antes — fontes: manual oficial da
-- Garmin ("Module Status LED"), the5krunner ("CIRQA Button and LED Guide")
-- e DC Rainmaker ("Everything You Need to Know").
-- ============================================================================

insert into product_sections (product_id, section_type, payload)
values ('c803a82e-a40a-4f95-8564-34dbd480f9d9', 'uso', $j$
{
  "blocks": [
    {
      "type": "tabs",
      "items": [
        {"label": "Pulso", "title": "Pulso", "text": "<p>Uso recomendado para monitoramento diário e sono — a posição padrão pra acompanhar frequência cardíaca, HRV e temperatura de pele ao longo do dia e da noite.</p>"},
        {"label": "Bíceps", "title": "Bíceps", "text": "<p>Banda específica para bíceps, com material mais elástico, indicada para treinos de alta intensidade. Vendida separadamente.</p>"}
      ]
    },
    {
      "type": "accordion",
      "items": [
        {"title": "Modo cadeira de rodas", "html": "<p>Detecção de impulso pra quem usa cadeira de rodas, adaptando o cálculo de atividade. Disponível como um dos mais de 80 tipos de atividade reconhecidos pelo Cirqa.</p>"},
        {"title": "Botão físico", "html": "<p><strong>Quando você precisa iniciar uma atividade imediatamente, não precisa depender da detecção automática.</strong></p><p>O botão único também permite soneca de alarme (toque curto), ativar a transmissão de frequência cardíaca pra outro dispositivo (pressionar e segurar por 2 segundos) e silenciar a vibração através do recurso Encontrar Minha Pulseira.</p>"}
      ]
    },
    {"type": "texto_rico", "html": "<h4>Para obter os melhores dados</h4>"},
    {
      "type": "card_grid",
      "columns": 3,
      "items": [
        {"title": "Detecção automática", "text": "Pode haver um intervalo de 15 a 20 minutos até uma atividade automática aparecer no app, exigindo confirmação do tipo depois.", "tags": []},
        {"title": "Treinos intensos", "text": "O posicionamento do dispositivo no pulso ou braço pode influenciar a qualidade da leitura óptica.", "tags": []},
        {"title": "Temperaturas baixas", "text": "Como em qualquer sensor óptico, mãos ou braços muito frios podem reduzir a qualidade da leitura de frequência cardíaca.", "tags": []}
      ]
    },
    {
      "type": "accordion",
      "items": [
        {"title": "Ver orientações técnicas", "html": "<p>Essas situações não são falhas do produto, mas limitações conhecidas de qualquer sensor óptico de pulso/braço. Ajude o cliente a configurar corretamente: ajustar o aperto da pulseira, posicionar acima do osso do pulso, e confirmar manualmente atividades quando a detecção automática demorar.</p>"}
      ]
    },
    {"type": "texto_rico", "html": "<hr class=\"cb-topic-divider\"><h4>Entenda os LEDs</h4>"},
    {
      "type": "card_grid",
      "columns": 3,
      "items": [
        {"title": "Roxo", "text": "Emparelhamento.", "tags": []},
        {"title": "Verde", "text": "Atividade (piscando = gravando, sólido = pausado).", "tags": []},
        {"title": "Laranja", "text": "Transmissão de frequência cardíaca (broadcast).", "tags": []},
        {"title": "Branco", "text": "Inicialização ou reinicialização.", "tags": []},
        {"title": "Vermelho", "text": "Parado aguardando ação, ou bateria criticamente baixa.", "tags": []}
      ]
    },
    {
      "type": "accordion",
      "items": [
        {
          "title": "Ver todos os códigos",
          "html": "<p><strong>LED do módulo (atividade/operação):</strong></p><ul><li>Roxo piscando: modo de emparelhamento.</li><li>Verde piscando: gravando atividade.</li><li>Verde sólido: atividade pausada.</li><li>Vermelho piscando: parado, aguardando ação.</li><li>Laranja piscando: transmissão de frequência cardíaca ativa.</li><li>Branco piscando: iniciando ou reiniciando.</li><li>Verde e laranja alternando: atualização de software em andamento.</li><li>Verde, amarelo e vermelho alternando: reset de fábrica em andamento.</li></ul><p><strong>LED de bateria (toque duplo no módulo, com Status de Bateria ativado no Garmin Connect):</strong></p><ul><li>Verde sólido: bateria cheia.</li><li>Verde piscando: carregando.</li><li>Laranja sólido: bateria baixa.</li><li>Vermelho sólido: bateria criticamente baixa.</li></ul>"
        }
      ]
    }
  ]
}
$j$::jsonb)
on conflict (product_id, section_type) do update set payload = excluded.payload;

-- ============================================================================
-- FIM DA MIGRAÇÃO 153
-- ============================================================================
