-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 140: Perfis "além da corrida" viram flip
-- cards com espaço para imagem (módulo Perfis de Cliente, lição "Além da
-- corrida e as perguntas certas")
-- ============================================================================
-- Pedido do usuário (2026-09-15): os 8 perfis (Aventureiro/Trilheiro,
-- Lifestyle e Saúde, Ciclista, Nadador/Triatleta, Mergulhador, Golfista,
-- Motociclista, Náutico/Pescador) eram um `card_grid` simples (texto na
-- frente, sem imagem). Usuário quer virar `flip_card` (já existe, mesmo
-- componente usado em Portfólio/Estudo de Caso — ver ContentBlocks.js):
-- frente = imagem (coverUrl, ela mesma vai enviar depois pelo editor —
-- ImageEditModal/upload de capa, mesmo campo já usado por Portfólio),
-- verso = o mesmo conteúdo estruturado (Quem é / Sinais / Pergunta inicial /
-- Linhas relacionadas) que já existia, só movido de `text` (card_grid) pra
-- `backText` (flip_card) — mesmo HTML com as classes .cb-field já
-- existentes, nenhum texto reescrito.
--
-- coverUrl fica vazio nesta migração de propósito — a gestora sobe as
-- imagens pelo editor depois. Sem coverUrl, a frente do flip card mostra só
-- o título (sem overlay escuro), até a imagem ser enviada.
-- ============================================================================

update lessons
set body = jsonb_set(
  body,
  '{blocks,1}',
  $block$
{
  "type": "flip_card",
  "columns": 2,
  "tall": false,
  "compact": false,
  "cards": [
    {
      "emoji": "",
      "title": "Aventureiro / Trilheiro",
      "subtitle": "",
      "frontText": "",
      "backLabel": "",
      "backText": "<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Ama trilhas, camping e expedições, quer resistência e bateria longa.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Fala de trilha, serra, montanha, expedição.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"As trilhas que você faz têm sinal de celular?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Instinct 3, fēnix 8, Enduro 3.</span></span>",
      "coverUrl": ""
    },
    {
      "emoji": "",
      "title": "Lifestyle e Saúde",
      "subtitle": "",
      "frontText": "",
      "backLabel": "",
      "backText": "<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Quer design elegante com funções inteligentes e acompanhamento de saúde no dia a dia.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Pede um relógio menor ou mais bonito, compara com Apple Watch, quer acompanhar sono ou ciclo menstrual.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"É mais pra acompanhar sono, estresse e rotina do dia a dia?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Lily 2, Lily 2 Active, Venu 4.</span></span>",
      "coverUrl": ""
    },
    {
      "emoji": "",
      "title": "Ciclista",
      "subtitle": "",
      "frontText": "",
      "backLabel": "",
      "backText": "<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Pedala com frequência, seja estrada, mountain bike ou uso casual.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Menciona bike, MTB, estrada, gravel, cadência ou potência.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"Pedala mais na rua, na estrada ou também mountain bike?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Edge 850, Edge 550, Edge 1050, Varia RTL515, Rally RK 200.</span></span>",
      "coverUrl": ""
    },
    {
      "emoji": "",
      "title": "Nadador / Triatleta",
      "subtitle": "",
      "frontText": "",
      "backLabel": "",
      "backText": "<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Nada com frequência ou compete em triathlon.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Fala de piscina, mar, braçadas, SWOLF, triathlon ou duathlon.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"Já compete em provas de triathlon ou é só treino mesmo?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Forerunner 955, Forerunner 965, fēnix 8, HRM 600.</span></span>",
      "coverUrl": ""
    },
    {
      "emoji": "",
      "title": "Mergulhador",
      "subtitle": "",
      "frontText": "",
      "backLabel": "",
      "backText": "<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Precisa de um computador de mergulho.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Menciona profundidade, NDL, nitrox, mergulho técnico.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"Pergunta sobre computador de mergulho?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Descent G2, Descent Mk3i, Descent X30.</span></span>",
      "coverUrl": ""
    },
    {
      "emoji": "",
      "title": "Golfista",
      "subtitle": "",
      "frontText": "",
      "backLabel": "",
      "backText": "<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Quer distâncias e recursos de jogo direto no pulso.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Fala de green, par, bunker, handicap.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"Pergunta por GPS de golfe?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Approach S50, Approach S44.</span></span>",
      "coverUrl": ""
    },
    {
      "emoji": "",
      "title": "Motociclista",
      "subtitle": "",
      "frontText": "",
      "backLabel": "",
      "backText": "<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Viaja de moto e quer navegação específica.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Fala de viagem de moto, rota, estrada.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"Pergunta por GPS para moto?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Zūmo XT2.</span></span>",
      "coverUrl": ""
    },
    {
      "emoji": "",
      "title": "Náutico / Pescador",
      "subtitle": "",
      "frontText": "",
      "backLabel": "",
      "backText": "<span class=\"cb-field\"><span class=\"cb-field-label\">Quem é</span><span class=\"cb-field-value\">Precisa de sonar ou chartplotter para embarcação.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Sinais</span><span class=\"cb-field-value\">Menciona pesca em represa, rio ou mar, barco, canoa, lancha.</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Pergunta inicial</span><span class=\"cb-field-value\">\"Fala de barco, canoa, lancha?\"</span></span><span class=\"cb-field\"><span class=\"cb-field-label\">Linhas relacionadas</span><span class=\"cb-field-value\">Striker Vivid 5cv, Striker 4, ECHOMAP UHD2 52cv.</span></span>",
      "coverUrl": ""
    }
  ]
}
$block$::jsonb
)
where id = '4e259942-be34-46f3-b264-42c681a29e8c'
  and body->'blocks'->1->>'type' = 'card_grid';

-- ============================================================================
-- FIM DA MIGRAÇÃO 140
-- ============================================================================
