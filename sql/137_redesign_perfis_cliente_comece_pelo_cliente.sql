-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 137: Refino visual da lição "Comece pelo
-- cliente" (módulo Perfis de Cliente, Zona Explorador)
-- ============================================================================
-- Pedido do usuário (2026-09-15): melhorar a hierarquia visual desta lição
-- sem inventar bloco novo — só reorganizando o `body.blocks` já existente
-- pra usar os componentes que o editor (ContentBlocks.js) já suporta:
--
--   - A lista de perguntas de qualificação ("Ele está começando ou já treina
--     há anos?"...) estava dentro do HTML de um bloco texto_rico como <ul>
--     simples. Vira um bloco `checklist` de verdade (interativo, com a frase
--     final "Essas respostas mudam..." como reflexão revelada ao marcar
--     tudo) — mesmo texto, só reestruturado.
--   - "Mas atenção: o vocabulário é um sinal, não uma conclusão..." estava
--     como <strong> dentro de um parágrafo comum. Vira um bloco `banner`
--     tone=warning (borda esquerda vermelha + ícone, já existente) pra dar
--     o peso visual de alerta que o texto já tinha na intenção.
--   - O bloco `timeline` da "lógica do atendimento" e os cards do bloco
--     `card_grid` ganham `icon`/emoji por item (campo novo, aditivo — ver
--     renderTimelineBlock/renderCardGridBlock em ContentBlocks.js), pra sair
--     do "bolinha cinza"/"ícone genérico igual em todos" e cada card ganhar
--     identidade própria.
--
-- Nenhum texto foi reescrito — só reagrupado nos blocos certos. Estrutura de
-- `lessons`/`modules`/progresso não muda.
-- ============================================================================

update lessons
set body = $jsonb$
{
  "blocks": [
    {
      "type": "texto_rico",
      "html": "<p>Na Garmin, clientes diferentes procuram soluções diferentes.</p><p>Um corredor pode estar começando agora. Outro pode estar treinando para uma prova. Uma pessoa pode buscar tecnologia para acompanhar sua saúde e rotina. Outra pode procurar um equipamento para uma expedição.</p><p>Por isso, o primeiro passo do atendimento não é apresentar um relógio.</p><p>É entender o cliente.</p>"
    },
    {
      "type": "texto_rico",
      "html": "<hr class=\"cb-topic-divider\"><h3>Comece pelo perfil, não pelo produto</h3><p>Um cliente nem sempre chega dizendo exatamente o que precisa.</p><p>Ele pode dizer: \"Quero um Garmin para correr.\"</p><p>Isso ainda não é suficiente para indicar um produto.</p><p>Você precisa descobrir:</p>"
    },
    {
      "type": "checklist",
      "items": [
        "Ele está começando ou já treina há anos?",
        "Corre por saúde ou performance?",
        "Participa de provas?",
        "Já usa um relógio GPS?",
        "O que ele sente falta no equipamento atual?"
      ],
      "reflection": "Essas respostas mudam completamente a recomendação."
    },
    {
      "type": "texto_rico",
      "html": "<h4 class=\"cb-model-heading\">A lógica do atendimento</h4>"
    },
    {
      "type": "timeline",
      "reveal": false,
      "items": [
        { "label": "Pessoa", "text": "Quem está na sua frente?", "icon": "users" },
        { "label": "Atividade", "text": "O que ela pratica?", "icon": "zap" },
        { "label": "Objetivo", "text": "O que ela quer alcançar?", "icon": "target" },
        { "label": "Necessidade", "text": "O que realmente precisa acompanhar ou melhorar?", "icon": "search" },
        { "label": "Produto", "text": "Qual solução faz sentido para esse contexto?", "icon": "watch" }
      ]
    },
    {
      "type": "texto_rico",
      "html": "<hr class=\"cb-topic-divider\"><h3>Antes de apresentar, observe</h3><p>Preste atenção ao vocabulário, ao contexto e ao comportamento do cliente. A linguagem que ele usa fornece pistas.</p>"
    },
    {
      "type": "banner",
      "tone": "warning",
      "text": "Mas atenção: o vocabulário é um sinal, não uma conclusão. Sempre confirme através de perguntas."
    },
    {
      "type": "card_grid",
      "columns": 3,
      "items": [
        { "title": "Começando a correr", "text": "Primeiro contato com corrida ou GPS. Prioriza simplicidade.", "tags": [], "imageUrl": "", "icon": "🏃" },
        { "title": "Performance", "text": "Já corre com regularidade e busca evolução e métricas.", "tags": [], "imageUrl": "", "icon": "⚡" },
        { "title": "Triathlon", "text": "Treina mais de uma modalidade, alto volume, participa de provas.", "tags": [], "imageUrl": "", "icon": "🏅" },
        { "title": "Outdoor", "text": "Trilha, montanha, expedição. Valoriza resistência e navegação.", "tags": [], "imageUrl": "", "icon": "⛰️" },
        { "title": "Lifestyle e saúde", "text": "Quer acompanhar sono, rotina e bem-estar no dia a dia.", "tags": [], "imageUrl": "", "icon": "❤️" },
        { "title": "Ciclismo", "text": "Pedala com frequência, quer GPS e dados no guidão.", "tags": [], "imageUrl": "", "icon": "🚴" },
        { "title": "Natação", "text": "Pratica natação ou triathlon, quer métricas na água.", "tags": [], "imageUrl": "", "icon": "🏊" },
        { "title": "Mergulho", "text": "Precisa de um computador de mergulho.", "tags": [], "imageUrl": "", "icon": "🤿" },
        { "title": "Golfe", "text": "Quer distâncias e recursos de jogo direto no pulso.", "tags": [], "imageUrl": "", "icon": "⛳" },
        { "title": "Motociclismo", "text": "Viaja de moto e quer navegação específica.", "tags": [], "imageUrl": "", "icon": "🏍️" },
        { "title": "Náutico e pesca", "text": "Precisa de sonar ou chartplotter para embarcação.", "tags": [], "imageUrl": "", "icon": "🎣" }
      ]
    }
  ]
}
$jsonb$::jsonb
where id = '94bb47ef-1fd6-4d07-97ff-e5c6b226e47f';

-- ============================================================================
-- FIM DA MIGRAÇÃO 137
-- ============================================================================
