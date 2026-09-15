-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 146: "Fixação de Conteúdo e Vocabulário de
-- Balcão" vira checagem rápida (1 certa + 1 errada) por termo
-- ============================================================================
-- Pedido do usuário (2026-09-15): trocar o bloco `match_quiz` (clicar num
-- termo, depois na definição correspondente, os 7 pares juntos) por uma
-- checagem rápida com feedback imediato — uma pergunta única por vez,
-- multipla escolha simples (1 opção certa + 1 errada), que "quebra a
-- leitura passiva e confirma se o conceito ficou antes de seguir em
-- frente". Vira 7 blocos `cenario_escolha` em sequência (block já existente,
-- feito pra exatamente isso: prompt + opções com feedback por opção).
--
-- Como o usuário só forneceu as definições CORRETAS (nenhum distrator),
-- confirmado com ele: cada opção errada é a definição verdadeira de OUTRO
-- termo do mesmo glossário (não é conteúdo inventado/falso, só a resposta
-- certa de uma pergunta diferente) — testa se a pessoa não está confundindo
-- métricas parecidas, sem introduzir nenhuma informação incorreta no app.
--
-- Textos das definições atualizados pros mais simples que o usuário pediu.
-- Checklist final (bloco seguinte) não muda.
-- ============================================================================

update lessons
set body = $jsonb$
{
  "blocks": [
    {
      "type": "cenario_escolha",
      "prompt": "O que significa HRM 600?",
      "context": "",
      "options": [
        {"text": "Cinta que amplia as informações de treino e permite acessar métricas avançadas de corrida.", "correct": true, "feedback": "Isso mesmo — o HRM 600 é a cinta que libera métricas avançadas, como Economia de Corrida e SSL."},
        {"text": "Mostra como está a energia disponível durante a corrida.", "correct": false, "feedback": "Essa é a definição de Estamina. O HRM 600 é a cinta que amplia as informações de treino e libera métricas avançadas de corrida."}
      ]
    },
    {
      "type": "cenario_escolha",
      "prompt": "O que significa Estamina?",
      "context": "",
      "options": [
        {"text": "Mostra como está a energia disponível durante a corrida.", "correct": true, "feedback": "Isso mesmo — a Estamina acompanha a energia disponível em tempo real, durante a corrida."},
        {"text": "Mostra o ritmo da corrida em minutos por quilômetro.", "correct": false, "feedback": "Essa é a definição de Pace. A Estamina mostra como está a energia disponível durante a corrida."}
      ]
    },
    {
      "type": "cenario_escolha",
      "prompt": "O que significa Pace?",
      "context": "",
      "options": [
        {"text": "Mostra o ritmo da corrida em minutos por quilômetro.", "correct": true, "feedback": "Isso mesmo — o Pace é o ritmo da corrida, em minutos por quilômetro."},
        {"text": "Quantidade de passos dados por minuto durante a corrida.", "correct": false, "feedback": "Essa é a definição de Cadência. O Pace mostra o ritmo da corrida em minutos por quilômetro."}
      ]
    },
    {
      "type": "cenario_escolha",
      "prompt": "O que significa SSL?",
      "context": "",
      "options": [
        {"text": "Mostra quanto o corredor perde de velocidade a cada passada ao tocar o chão.", "correct": true, "feedback": "Isso mesmo — SSL é a perda de velocidade a cada passada, ao tocar o chão."},
        {"text": "Mostra o consumo de oxigênio necessário para manter o ritmo.", "correct": false, "feedback": "Essa é a definição de Economia de Corrida. O SSL mostra quanto o corredor perde de velocidade a cada passada ao tocar o chão."}
      ]
    },
    {
      "type": "cenario_escolha",
      "prompt": "O que significa VFC?",
      "context": "",
      "options": [
        {"text": "Mostra pequenas variações no tempo entre os batimentos do coração.", "correct": true, "feedback": "Isso mesmo — a VFC mostra as variações no tempo entre os batimentos cardíacos."},
        {"text": "Indica a capacidade do corpo de usar oxigênio durante o exercício.", "correct": false, "feedback": "Essa é a definição de VO2 Máx. A VFC mostra pequenas variações no tempo entre os batimentos do coração."}
      ]
    },
    {
      "type": "cenario_escolha",
      "prompt": "O que significa Cadência (spm)?",
      "context": "",
      "options": [
        {"text": "Quantidade de passos dados por minuto durante a corrida.", "correct": true, "feedback": "Isso mesmo — Cadência é a quantidade de passos dados por minuto."},
        {"text": "Mostra o ritmo da corrida em minutos por quilômetro.", "correct": false, "feedback": "Essa é a definição de Pace. Cadência é a quantidade de passos dados por minuto durante a corrida."}
      ]
    },
    {
      "type": "cenario_escolha",
      "prompt": "O que significa VO2 Máx.?",
      "context": "",
      "options": [
        {"text": "Indica a capacidade do corpo de usar oxigênio durante o exercício.", "correct": true, "feedback": "Isso mesmo — o VO2 Máx indica a capacidade do corpo de usar oxigênio durante o exercício."},
        {"text": "Mostra pequenas variações no tempo entre os batimentos do coração.", "correct": false, "feedback": "Essa é a definição de VFC. O VO2 Máx indica a capacidade do corpo de usar oxigênio durante o exercício."}
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
-- FIM DA MIGRAÇÃO 146
-- ============================================================================
