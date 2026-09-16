-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 163: Garmin Coach, lição 2 reestruturada
-- ============================================================================
-- Continua a sql/162. Esta lição vira a principal interação do módulo:
-- "Qual é o objetivo do cliente?" com 4 abas (corrida, ciclismo, força,
-- triatlo), em vez de texto corrido com todas as modalidades abertas ao
-- mesmo tempo. Os 3 treinadores Expert de corrida continuam em flip cards
-- (frente compacta, detalhe no verso), agora sem emoji, como pedido.
--
-- Dados preservados do conteúdo original, sem inventar nada: distâncias 5K,
-- 10K e Meia Maratona com ritmos entre 4:24 e 7:30 min/km; tipos de plano de
-- ciclismo (Century 160 km, Metric Century 100 km, Gran Fondo, MTB, Race,
-- Time Trial); exigência de frequência cardíaca ou potência; integração
-- Tacx; as três variáveis do plano de força; dias de piscina, two-a-day e
-- Garmin Connect+ no triatlo.
-- ============================================================================

update lessons set body = $j$
{
  "blocks": [
    {
      "type": "texto_rico",
      "html": "<h3>Escolha o objetivo do cliente</h3><p><strong>Qual é o objetivo do cliente?</strong></p><p>Toque na modalidade para ver os planos disponíveis, sem precisar percorrer as outras.</p>"
    },
    {
      "type": "tabs",
      "items": [
        {
          "label": "Corrida",
          "title": "Corrida",
          "text": "<p><strong>Run Coach:</strong> plano de corrida que acompanha o desempenho do atleta ao longo do plano.</p><p><strong>Planos Expert:</strong> o cliente escolhe um treinador pela filosofia de treino. Os três estão logo abaixo.</p><p><strong>Distâncias:</strong> 5K, 10K e Meia Maratona, com suporte a ritmos entre 4:24 e 7:30 min/km.</p>",
          "note": "Indique pela necessidade do cliente: começar, voltar a correr ou melhorar performance."
        },
        {
          "label": "Ciclismo",
          "title": "Garmin Cycling Coach",
          "text": "<p>Planos autoguiados para diferentes objetivos:</p><ul><li>Century (160 km)</li><li>Metric Century (100 km)</li><li>Gran Fondo</li><li>MTB</li><li>Race</li><li>Time Trial</li></ul><p><strong>Ecossistema de treino:</strong> relógio ou Edge, frequência cardíaca, potência e Tacx. Determinados planos exigem monitor de frequência cardíaca ou medidor de potência, e o treino indoor pode se integrar ao ecossistema Tacx.</p>",
          "note": "Usar frequência cardíaca e potência juntos é recomendado para mais precisão."
        },
        {
          "label": "Força",
          "title": "Treinamento de força",
          "text": "<p>O cliente monta o plano a partir de três escolhas dentro do aplicativo:</p><ul><li><strong>Objetivo:</strong> hipertrofia, força ou condicionamento</li><li><strong>Equipamento:</strong> halteres, barras ou peso corporal</li><li><strong>Foco:</strong> grupos musculares</li></ul>",
          "note": "Mostre que o Garmin também acompanha uma rotina de força e condicionamento."
        },
        {
          "label": "Triatlo",
          "title": "Triatlo",
          "text": "<p>O plano cobre as três disciplinas: <strong>natação, ciclismo e corrida.</strong></p><ul><li><strong>Dias de piscina:</strong> sessões específicas de natação.</li><li><strong>Two-a-day:</strong> dois treinos estruturados no mesmo dia.</li><li><strong>Garmin Connect+:</strong> conteúdos adicionais e vídeos educacionais, quando disponíveis.</li></ul>",
          "note": "Plano indicado para quem vai combinar as três modalidades."
        }
      ]
    },
    {
      "type": "texto_rico",
      "html": "<h3>Corrida: escolha do treinador Expert</h3><p>Toque em cada card para ver quando indicar e qual é o método do treinador.</p>"
    },
    {
      "type": "flip_card",
      "columns": 3,
      "tall": true,
      "compact": false,
      "square": false,
      "cards": [
        {
          "title": "Jeff Galloway",
          "subtitle": "Run Walk Run",
          "frontText": "<p>Para o cliente iniciante ou que está voltando a correr.</p>",
          "backLabel": "Quando indicar e método",
          "backText": "<p><strong>Indique quando:</strong> cliente iniciante ou voltando a correr.</p><p><strong>Método:</strong> alternância entre corrida e caminhada.</p><p><strong>Na venda:</strong> “É uma opção interessante para quem quer começar ou voltar a correr de forma gradual.”</p>"
        },
        {
          "title": "Amy Parkerson-Mitchell",
          "subtitle": "Fisioterapia e mecânica da corrida",
          "frontText": "<p>Para o cliente preocupado com dores, lesões ou mecânica.</p>",
          "backLabel": "Quando indicar e método",
          "backText": "<p><strong>Indique quando:</strong> cliente preocupado com dores, lesões ou mecânica.</p><p><strong>Método:</strong> foco na mecânica corporal e prevenção de lesões.</p><p><strong>Na venda:</strong> “É uma opção para quem quer evoluir a corrida dando atenção também à forma como o corpo se movimenta.”</p>"
        },
        {
          "title": "Greg McMillan",
          "subtitle": "Fisiologia e ritmo",
          "frontText": "<p>Para o cliente que já corre e quer melhorar o desempenho.</p>",
          "backLabel": "Quando indicar e método",
          "backText": "<p><strong>Indique quando:</strong> cliente que já corre e quer melhorar o desempenho.</p><p><strong>Método:</strong> ritmo, zonas de treino e fisiologia aplicada.</p><p><strong>Na venda:</strong> “É uma opção para quem já corre e quer entender melhor como estruturar o treino para evoluir.”</p>"
        }
      ]
    }
  ]
}
$j$::jsonb
where id = '1435a4aa-8d7f-4d08-b745-cf500e2f75eb';

-- ============================================================================
-- FIM DA MIGRAÇÃO 163
-- ============================================================================
