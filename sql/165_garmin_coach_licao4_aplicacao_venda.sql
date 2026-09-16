-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 165: Garmin Coach, lição 4 reestruturada
-- ============================================================================
-- Fecha a série sql/162 a 165. É a parte de aplicação comercial: onde o
-- Coach abre venda cruzada, como indicar o plano, um cenário de venda
-- interativo, o fechamento em 30 segundos, o checklist do vendedor e a
-- avaliação final.
--
-- A tabela gigante "situação do cliente x plano indicado" que existia aqui
-- virou accordion (uma situação por vez), como pede o briefing.
--
-- A avaliação final referencia o quiz que JÁ existe do módulo
-- ("corredor-coaches", 14 perguntas, id 0048a818), via bloco quiz_embutido.
-- O quiz não foi alterado: ele continua sendo o checkpoint da trilha, e o
-- bloco só dá acesso a ele de dentro da lição.
-- ============================================================================

update lessons set body = $j$
{
  "blocks": [
    {
      "type": "texto_rico",
      "html": "<h3>Onde o Coach abre oportunidade de venda?</h3><p>Pense no que realmente melhora a experiência de treinamento de cada perfil.</p>"
    },
    {
      "type": "card_grid",
      "columns": 3,
      "items": [
        {"title": "Corredor", "text": "<p>Relógio</p><p>↓</p><p>Garmin Coach</p><p>↓</p><p>Sensor de frequência cardíaca</p><p>↓</p><p>Métricas avançadas</p>"},
        {"title": "Ciclista", "text": "<p>Relógio ou Edge</p><p>↓</p><p>Cycling Coach</p><p>↓</p><p>Frequência cardíaca</p><p>↓</p><p>Potência</p><p>↓</p><p>Tacx</p>"},
        {"title": "Triatleta", "text": "<p>Relógio multiesporte</p><p>↓</p><p>Plano de triatlo</p><p>↓</p><p>Sensores</p><p>↓</p><p>Ecossistema Garmin</p>"}
      ]
    },
    {
      "type": "banner",
      "tone": "info",
      "text": "O objetivo não é adicionar produtos sem necessidade. É identificar o que melhora a experiência de treinamento daquele cliente."
    },
    {
      "type": "texto_rico",
      "html": "<h3>Qual plano faz sentido para esse cliente?</h3><p>Comece sempre pelo objetivo. Toque em cada situação para ver a indicação.</p>"
    },
    {
      "type": "accordion",
      "items": [
        {"title": "Nunca correu ou está voltando", "html": "<p>Planos de corrida para iniciantes e retomada, com Jeff Galloway (Run Walk Run) como possibilidade.</p>"},
        {"title": "Preocupado com dores ou lesões", "html": "<p>Amy Parkerson-Mitchell, com foco na mecânica da corrida.</p>"},
        {"title": "Quer melhorar tempo ou performance", "html": "<p>Greg McMillan, com ritmo, zonas de treino e fisiologia aplicada.</p>"},
        {"title": "Quer preparar prova de ciclismo", "html": "<p>Garmin Cycling Coach, escolhendo o plano por distância ou tipo de prova. Requer monitor de frequência cardíaca ou medidor de potência.</p>"},
        {"title": "Treina indoor", "html": "<p>Cycling Coach com o ecossistema Tacx, quando compatível.</p>"},
        {"title": "Quer ganhar força", "html": "<p>Plano de força, configurável por objetivo, equipamento e foco muscular.</p>"},
        {"title": "Vai fazer triatlo", "html": "<p>Plano de triatlo, com dias de piscina e sessões two-a-day.</p>"}
      ]
    },
    {
      "type": "texto_rico",
      "html": "<h3>Situação de venda</h3>"
    },
    {
      "type": "cenario_escolha",
      "context": "Cliente: “Eu quero começar a treinar, mas não sei como montar meus treinos.”",
      "prompt": "O que você faria?",
      "options": [
        {
          "text": "Mostrar apenas as métricas do relógio.",
          "correct": false,
          "feedback": "As métricas sozinhas não respondem ao que o cliente acabou de dizer, que é não saber como organizar os treinos."
        },
        {
          "text": "Perguntar qual é o objetivo e apresentar o Garmin Coach.",
          "correct": true,
          "feedback": "Descobrir o objetivo primeiro permite indicar o plano certo e conecta a necessidade do cliente ao produto."
        },
        {
          "text": "Mostrar todos os recursos do Garmin Connect.",
          "correct": false,
          "feedback": "Apresentar tudo de uma vez confunde. Descubra a necessidade antes de mostrar funcionalidades."
        }
      ]
    },
    {
      "type": "texto_rico",
      "html": "<h3>Garmin Coach em 30 segundos</h3>"
    },
    {
      "type": "timeline",
      "reveal": false,
      "items": [
        {"label": "Objetivo", "text": "O cliente define o que quer alcançar."},
        {"label": "Treinamento", "text": "O plano organiza as sessões."},
        {"label": "Relógio", "text": "O treino acompanha o cliente durante a atividade."},
        {"label": "Evolução", "text": "O atleta acompanha seu progresso."}
      ]
    },
    {
      "type": "banner",
      "tone": "success",
      "text": "<strong>Frase para usar na venda:</strong> “Você define seu objetivo, escolhe um plano e recebe os treinos no relógio, tudo integrado ao Garmin Connect.”"
    },
    {
      "type": "texto_rico",
      "html": "<h3>Checklist do vendedor</h3>"
    },
    {
      "type": "checklist",
      "items": [
        "Perguntei qual é o objetivo do cliente?",
        "Identifiquei a modalidade?",
        "Mostrei o Garmin Coach?",
        "Expliquei como o plano funciona?",
        "Verifiquei a compatibilidade?",
        "Identifiquei algum acessório que realmente agregue ao treinamento?",
        "Mostrei onde encontrar o Coach no Garmin Connect?"
      ],
      "reflection": "Marcou todos? Então você conduziu a conversa pela necessidade do cliente, e não pela lista de recursos."
    },
    {
      "type": "texto_rico",
      "html": "<h3>Avaliação final</h3><p>Teste seu entendimento e a aplicação comercial do Garmin Coach.</p>"
    },
    {
      "type": "quiz_embutido",
      "quizId": "0048a818-d7f3-4766-8196-8e9e948f734a",
      "label": "Fazer a avaliação do Garmin Coach"
    }
  ]
}
$j$::jsonb
where id = '551cd08f-7c54-4c8c-8482-a6607fd7b6c5';

-- ============================================================================
-- FIM DA MIGRAÇÃO 165
-- ============================================================================
