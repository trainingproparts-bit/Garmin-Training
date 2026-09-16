-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 162: Garmin Coach, lição 1 reestruturada
-- ============================================================================
-- Pedido do usuário (2026-09-16): reestruturar o módulo Garmin Coach inteiro
-- como aula interativa (briefing de UX/UI sales enablement), na sequência
-- O QUE É > COMO FUNCIONA > OBJETIVOS > COMO INDICAR > PRÁTICA > REQUISITOS
-- > DÚVIDAS > APLICAÇÃO NA VENDA. Os 4 lessons existentes são mantidos como
-- contêineres (preserva progresso, conclusão, ordem e o quiz do módulo);
-- só o `body` de cada um é reescrito. Esta é a lição 1 de 4.
--
-- Regras de escrita pedidas: sem travessão e sem o comparativo
-- "Não é só X, é Y".
--
-- Correções de conteúdo exigidas pelo briefing (o texto anterior violava):
--   - removida a comparação com preço de personal trainer (R$150 a R$300);
--   - removido "gratuita" absoluto e "vitalícia" (existe Garmin Connect+);
--   - removido "evitando lesão" e o "reduz automaticamente a intensidade";
--   - agora diferencia acompanhamento, dado do ecossistema e adaptação, e
--     diz explicitamente que nem todo plano usa os mesmos dados igual.
-- ============================================================================

update lessons set body = $j$
{
  "blocks": [
    {
      "type": "texto_rico",
      "html": "<h3>Garmin Coach</h3><p><strong>Treinamento adaptativo para acompanhar o objetivo do cliente.</strong></p><p>O Garmin Coach cria planos de treinamento dentro do Garmin Connect e leva as sessões diretamente para o relógio.</p>"
    },
    {
      "type": "timeline",
      "reveal": false,
      "items": [
        {"label": "Objetivo", "text": "O cliente define o que quer alcançar."},
        {"label": "Plano", "text": "O treinamento organiza as sessões."},
        {"label": "Adaptação", "text": "A evolução do atleta orienta o acompanhamento do plano."}
      ]
    },
    {
      "type": "texto_rico",
      "html": "<h3>Garmin Coach em 30 segundos</h3>"
    },
    {
      "type": "card_grid",
      "columns": 2,
      "items": [
        {"title": "O que é", "text": "Planos de treinamento dentro do Garmin Connect."},
        {"title": "Para quem", "text": "Clientes que querem treinar com uma meta ou objetivo."},
        {"title": "Onde acontece", "text": "Garmin Connect e relógio compatível."},
        {"title": "Diferencial", "text": "O treinamento acompanha a evolução do atleta."}
      ]
    },
    {
      "type": "banner",
      "tone": "info",
      "text": "<strong>Na venda:</strong> o Garmin Coach transforma o relógio de um dispositivo que registra o treino em uma ferramenta que também orienta o treinamento."
    },
    {
      "type": "texto_rico",
      "html": "<h3>Como funciona</h3>"
    },
    {
      "type": "timeline",
      "reveal": false,
      "items": [
        {"label": "Objetivo", "text": "O cliente escolhe a meta e a modalidade."},
        {"label": "Plano", "text": "O Garmin Coach organiza as sessões dentro do Garmin Connect."},
        {"label": "Treino", "text": "As sessões vão para o relógio e guiam o atleta durante a atividade."},
        {"label": "Resultado", "text": "O desempenho de cada treino fica registrado no Garmin Connect."},
        {"label": "Evolução", "text": "O acompanhamento ao longo do plano orienta os próximos passos."}
      ]
    },
    {
      "type": "card_grid",
      "columns": 2,
      "items": [
        {"title": "Planilha fixa", "text": "<p>Objetivo</p><p>↓</p><p>Sequência fixa de treinos</p><p>↓</p><p>Execução</p>"},
        {"title": "Garmin Coach", "text": "<p>Objetivo</p><p>↓</p><p>Treino</p><p>↓</p><p>Resultado</p><p>↓</p><p>Acompanhamento</p><p>↓</p><p>Próximos passos</p>"}
      ]
    },
    {
      "type": "texto_rico",
      "html": "<h3>O que torna o treinamento adaptativo?</h3><p>O Garmin Coach usa o acompanhamento dos treinos realizados e os dados disponíveis no ecossistema Garmin para ajudar a orientar a evolução do atleta ao longo do plano. Nem todos os planos utilizam os mesmos dados da mesma forma.</p>"
    },
    {
      "type": "metric_card_grid",
      "columns": 2,
      "items": [
        {"name": "Desempenho", "definition": "Como o atleta executou os treinos do plano.", "tip": "É a base do acompanhamento. O resultado de cada sessão fica registrado no Garmin Connect."},
        {"name": "Sono", "definition": "Qualidade e duração do sono medidas pelo relógio.", "tip": "Faz parte dos dados de recuperação acompanhados pelo ecossistema Garmin."},
        {"name": "Estresse", "definition": "Estimativa do nível de estresse ao longo do dia.", "tip": "Ajuda a dar contexto sobre o quanto o corpo está sob carga."},
        {"name": "VFC / HRV", "definition": "Variabilidade da frequência cardíaca.", "tip": "Indicador ligado à recuperação, disponível no ecossistema Garmin."},
        {"name": "Carga", "definition": "Volume e intensidade de treino acumulados.", "tip": "Ajuda a enxergar o equilíbrio entre treinar e descansar."},
        {"name": "Recuperação", "definition": "Tempo sugerido de recuperação depois do esforço.", "tip": "Contribui para orientar quando faz sentido treinar forte ou aliviar."}
      ]
    },
    {
      "type": "banner",
      "tone": "info",
      "text": "<strong>Treinar melhor não significa simplesmente treinar mais.</strong>"
    },
    {
      "type": "accordion",
      "items": [
        {"title": "Entenda o termo: tapering (polimento)", "html": "<p>Redução planejada do volume de treino antes de uma prova, para favorecer a recuperação e a preparação para o evento.</p>"}
      ]
    }
  ]
}
$j$::jsonb
where id = '66df6b3a-4d20-495e-adc9-7502fc230d39';

-- ============================================================================
-- FIM DA MIGRAÇÃO 162
-- ============================================================================
