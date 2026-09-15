-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 143: Reformula o módulo "Métricas
-- Essenciais e Avançadas de Corrida" (Zona Atleta)
-- ============================================================================
-- Pedido do usuário (2026-09-15): reescreveu as 4 lições do módulo do zero,
-- com brief completo por elemento (texto rico, accordion, cards de métrica,
-- abas comparativas, card, quiz de associação, checklist). Substitui o body
-- inteiro de cada lição pelo conteúdo do brief, mapeado pros tipos de bloco
-- já existentes em ContentBlocks.js — nenhum bloco novo no schema.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Lição 1: Métricas Fundamentais (A Base da Experiência do Atleta)
-- ----------------------------------------------------------------------------
update lessons
set title = 'Métricas Fundamentais (A Base da Experiência do Atleta)',
    body = $jsonb$
{
  "blocks": [
    {
      "type": "texto_rico",
      "html": "<p>As métricas fundamentais são o ponto de partida para qualquer corredor. Compreender a diferença técnica entre o monitoramento via smartwatch e via smartphone é o principal argumento para demonstrar o valor do GPS dedicado no pulso.</p>"
    },
    {
      "type": "accordion",
      "items": [
        {
          "title": "Ritmo de Corrida (Pace)",
          "html": "<ul><li><strong>Conceito:</strong> Indica a velocidade da corrida em minutos por quilômetro (min/km).</li><li><strong>Ritmo Instantâneo:</strong> Atualização em tempo real (sensível a variações da passada).</li><li><strong>Ritmo Médio:</strong> Média acumulada desde o início da atividade (ideal para verificar o cumprimento da meta global do treino).</li><li><strong>Ritmo da Volta (Lap):</strong> Média calculada apenas para o bloco atual (essencial para treinos intervalados/tiros).</li></ul>"
        },
        {
          "title": "Cadência de Passadas (spm)",
          "html": "<ul><li><strong>Conceito:</strong> Número de passadas efetuadas por minuto.</li><li><strong>Impacto na Técnica:</strong> Uma cadência baixa sinaliza a ocorrência de overstride (passada excessivamente larga), onde o pé toca o solo à frente do centro de gravidade do corpo.</li><li><strong>Benefício ao Atleta:</strong> A elevação da cadência reduz o efeito de frenagem e diminui a sobrecarga estrutural sobre as articulações dos joelhos.</li></ul>"
        },
        {
          "title": "Precisão de GPS e Altimetria",
          "html": "<ul><li><strong>Conceito:</strong> Medição exata da distância percorrida e do ganho de elevação acumulado.</li><li><strong>Vantagem Competitiva:</strong> O receptor GPS dedicado no pulso evita a atenuação de sinal (efeito multi-caminho) provocada por edifícios altos e cobertura vegetal, superando a precisão do smartphone transportado no bolso ou braçadeira.</li></ul>"
        }
      ]
    }
  ]
}
$jsonb$::jsonb
where id = '1072a42a-bc8e-4e21-91f7-1f23f3855a86';

-- ----------------------------------------------------------------------------
-- Lição 2: Métricas Fisiológicas e Gestão de Esforço
-- ----------------------------------------------------------------------------
update lessons
set body = $jsonb$
{
  "blocks": [
    {
      "type": "metric_card_grid",
      "columns": 2,
      "items": [
        {
          "icon": "",
          "name": "Capacidade Cardiorrespiratória (VO2 Máx)",
          "definition": "Volume máximo de oxigênio (ml/kg/min) consumido em esforço máximo.",
          "tip": "Processado via algoritmos da Firstbeat Analytics. No balcão, é a prova da evolução física contínua do cliente ao longo do tempo.",
          "badge": ""
        },
        {
          "icon": "",
          "name": "Variabilidade da Frequência Cardíaca (VFC / HRV)",
          "definition": "Análise dos microintervalos de tempo entre batimentos cardíacos sucessivos.",
          "tip": "Variações maiores indicam bom estado de recuperação e baixo estresse fisiológico; variações reduzidas apontam fadiga acumulada. Monitorado predominantemente durante o repouso e o sono.",
          "badge": ""
        },
        {
          "icon": "",
          "name": "Tempo de Recuperação Recomendado",
          "definition": "Intervalo estimado (em horas) necessário antes da execução da próxima sessão de alta intensidade.",
          "tip": "Ajuda a prevenir quadros de overtraining e lesões por sobrecarga.",
          "badge": ""
        }
      ]
    },
    {
      "type": "tabs",
      "items": [
        {
          "label": "Estamina",
          "title": "Reserva de Energia em Tempo Real (Estamina)",
          "text": "<strong>Aplicação:</strong> medição feita durante a execução da atividade físico-esportiva.<br><strong>Mecanismo:</strong> atua analogamente a um tanque de combustível (0 a 100%).<br><strong>Reserva Atual:</strong> nível de energia disponível no momento exato.<br><strong>Reserva Potencial:</strong> limite máximo sustentável sob ritmo dosado.",
          "note": "Finalidade: gestão de ritmo em provas longas para evitar exaustão precoce."
        },
        {
          "label": "Tempo de Recuperação",
          "title": "Tempo de Recuperação",
          "text": "<strong>Aplicação:</strong> estimativa calculada para o período pós-treino.<br><strong>Mecanismo:</strong> contagem regressiva em horas para a regeneração muscular.",
          "note": "Finalidade: programação segura do calendário semanal de treinos."
        }
      ]
    }
  ]
}
$jsonb$::jsonb
where id = '342f0472-cd16-409c-aa13-80777d400f2f';

-- ----------------------------------------------------------------------------
-- Lição 3: Biomecânica e Recursos Avançados (Venda Casada)
-- ----------------------------------------------------------------------------
update lessons
set title = 'Biomecânica e Recursos Avançados (Venda Casada)',
    body = $jsonb$
{
  "blocks": [
    {
      "type": "card",
      "icon": "🎯",
      "title": "Oportunidade de Upsell: Combo Forerunner 970 + Cinta HRM 600",
      "text": "Para clientes focados em alta performance biomecânica, a venda isolada do smartwatch restringe o acesso aos dados mais avançados. Apresente os recursos abaixo como justificativa técnica para aquisição do combo."
    },
    {
      "type": "accordion",
      "items": [
        {
          "title": "Economia de Corrida (Requer HRM 600)",
          "html": "<p>Mede o consumo de oxigênio necessário para manter uma determinada velocidade. Quanto menor o consumo de energia para manter o ritmo, mais eficiente é a técnica do atleta.</p>"
        },
        {
          "title": "Perda de Velocidade na Passada / Frenagem (SSL) (Requer HRM 600)",
          "html": "<p>Quantifica (em cm/s ou porcentagem) o desacoplamento de velocidade sofrido a cada contato do pé com o solo. Reduzir esse \"freio natural\" permite correr mais rápido sem aumentar o esforço cardiorrespiratório.</p>"
        }
      ]
    }
  ]
}
$jsonb$::jsonb
where id = 'e0863e72-e7ae-46c0-b199-fa0331c57852';

-- ----------------------------------------------------------------------------
-- Lição 4: Fixação de Conteúdo e Vocabulário de Balcão
-- ----------------------------------------------------------------------------
update lessons
set title = 'Fixação de Conteúdo e Vocabulário de Balcão',
    body = $jsonb$
{
  "blocks": [
    {
      "type": "match_quiz",
      "pairs": [
        {"term": "Pace", "definition": "Velocidade expressa em minutos por quilômetro."},
        {"term": "Cadência (spm)", "definition": "Total de passadas computadas por minuto."},
        {"term": "VO2 Máx", "definition": "Volume máximo de oxigênio consumido por quilograma de peso corporal."},
        {"term": "VFC / HRV", "definition": "Variação dos microintervalos entre batimentos cardíacos."},
        {"term": "Estamina", "definition": "Nível de reserva de energia disponível em tempo real durante a corrida."},
        {"term": "SSL", "definition": "Métrica de frenagem a cada impacto da passada no solo."},
        {"term": "HRM 600", "definition": "Cinta peitoral avançada requerida para coleta de métricas de Economia de Corrida e SSL."}
      ]
    },
    {
      "type": "checklist",
      "items": [
        "Sei explicar a diferença entre Pace Instantâneo, Médio e Lap.",
        "Consigo argumentar por que o GPS de pulso supera o GPS de celular.",
        "Sei demonstrar a diferença prática entre Estamina (durante) e Tempo de Recuperação (após).",
        "Consigo oferecer o combo Relógio + Cinta HRM 600 justificando as métricas de SSL e Economia de Corrida."
      ],
      "reflection": ""
    }
  ]
}
$jsonb$::jsonb
where id = '415c3b5f-3b5f-4ad4-afa4-0399c6dc6c96';

-- ============================================================================
-- FIM DA MIGRAÇÃO 143
-- ============================================================================
