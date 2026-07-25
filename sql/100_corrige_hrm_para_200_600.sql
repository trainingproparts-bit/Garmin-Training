-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 100: restringe conteúdo de cintas cardíacas
-- (HRM) aos modelos realmente vendidos pela loja: HRM 200 e HRM 600
-- ============================================================================
-- Pedido do usuário: "estamos trabalhando só com hrm 200 e 600. faça a
-- pesquisa minusciosa e altere". Pesquisa feita nos manuais oficiais da
-- Garmin (static.garmin.com/pumac, www8.garmin.com/manuals) e em coberturas
-- técnicas (the5krunner, heartratemonitorsusa):
--   HRM 200: 3 ATM, bateria de moeda CR2032 substituível (~1 ano a 1h/dia),
--     ANT+ (conexões ilimitadas) + Bluetooth Low Energy (até 3 simultâneas),
--     sem Dinâmica de Corrida, não indicado pra natação.
--   HRM 600: 5 ATM (resistente à natação, armazena offline debaixo d'água),
--     bateria recarregável (~2 meses a 1h/dia), ANT+ + Bluetooth simultâneos,
--     Dinâmica de Corrida completa (cadência, comprimento de passada,
--     oscilação vertical, proporção vertical, tempo de contato com o solo,
--     equilíbrio do tempo de contato) + Step Speed Loss (métrica exclusiva),
--     grava até 24h de atividade sozinho sem relógio (18+ modalidades).
--
-- Achado importante: o conteúdo antigo dizia que o HRM 600 tinha um "pacote
-- incompleto" de Dinâmica de Corrida comparado ao HRM-Pro Plus. Isso estava
-- errado: o HRM 600 tem o conjunto COMPLETO de Dinâmica de Corrida (o mesmo
-- do Pro Plus) MAIS a métrica exclusiva Step Speed Loss, um superconjunto,
-- não um pacote reduzido.
--
-- Removidas todas as referências a HRM-Dual, HRM-Pro Plus e HRM-Fit (cintas
-- reais da Garmin, mas que esta loja não vende) em: conteúdo dos produtos
-- HRM 200/600 na Academia de Produtos, o quiz "Cintas Cardíacas (HRM)", o
-- módulo "Ecossistema de Sensores de Elite" (lição inteira reescrita de
-- "HRM-Pro Plus" pra "HRM 600"), o módulo "Fechamento de Vendas Premium" e
-- o módulo "Linha Edge de Entrada e Sensores".
-- ============================================================================

begin;

-- ============================================================================
-- PARTE 1: Academia de Produtos — HRM 200
-- ============================================================================

update product_sections set payload = $j${
  "blocks": [{
    "type": "accordion",
    "items": [
      {"title": "Bluetooth seguro", "html": "<p>Evita que a cinta se conecte acidentalmente a outro aparelho por perto, comum em academias com muita gente treinando ao mesmo tempo.</p>"},
      {"title": "Módulo destacável e lavável", "html": "<p>O sensor eletrônico sai da cinta de tecido, que pode ser lavada na máquina separadamente.</p>"},
      {"title": "Bateria de moeda, sem recarregar", "html": "<p>CR2032 substituível, dura cerca de 1 ano a 1h de uso por dia. Diferente do HRM 600, que é recarregável e dura cerca de 2 meses por carga.</p>"},
      {"title": "Comparado ao HRM 600", "html": "<p>O HRM 600 soma Dinâmica de Corrida completa (incluindo a métrica exclusiva Step Speed Loss), grava até 24h de atividade sozinho sem relógio e é resistente à natação (5 ATM). O HRM 200 é só frequência cardíaca e HRV, num preço bem menor.</p>"},
      {"title": "Não é resistente a natação", "html": "<p>3 ATM cobre suor e chuva, mas não é indicada pra nadar. Pra isso, o cliente precisa do HRM 600 (5 ATM).</p>"}
    ]
  }]
}$j$
where id = '1fba6e47-ec5e-47b0-b13e-a1c1a5cba083';

update product_sections set payload = $j${
  "blocks": [{
    "type": "objecao",
    "items": [
      {"question": "Meu relógio já mede FC no pulso, pra que uma cinta?", "answer": "A leitura óptica de pulso varia mais em esforço intenso; a cinta pega o sinal elétrico direto do músculo cardíaco, mais estável exatamente quando a intensidade sobe."},
      {"question": "Qual a diferença pro HRM 600?", "answer": "O HRM 600 soma Dinâmica de Corrida completa (com a métrica exclusiva Step Speed Loss), grava até 24h de treino sozinho, sem relógio, e é resistente à natação (5 ATM). O HRM 200 é só FC e HRV, com bateria de moeda que dura cerca de 1 ano, num preço bem menor."},
      {"question": "Posso nadar com o HRM 200?", "answer": "Não é recomendado: ele é 3 ATM, cobre suor e chuva, mas não é indicado pra nado. Pra isso, o HRM 600 (5 ATM) é a opção certa."}
    ]
  }]
}$j$
where id = '1dc7b6a1-8006-4366-b6e4-2fa5ba20e9df';

update product_sections set payload = $j${
  "blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista de indoor (Zwift, apps de treino)", "text": "Quer FC estável no treino indoor sem gastar no topo de linha.", "tags": [{"label": "Indoor", "color": "blue"}]},
      {"title": "Cliente com orçamento mais ajustado", "text": "Primeira cinta cardíaca, sem precisar de Dinâmica de Corrida.", "tags": [{"label": "Custo-benefício", "color": "gold"}]},
      {"title": "Praticante de atividade geral", "text": "Já tem relógio com GPS, só quer FC mais precisa que a leitura óptica.", "tags": [{"label": "Fitness geral", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente só precisa de frequência cardíaca e HRV estáveis, sem métricas de corrida avançadas</li><li>Cliente não vai nadar com a cinta</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer Dinâmica de Corrida ou gravar treino sem relógio → indicar o HRM 600</li><li>Cliente pratica natação → o HRM 200 não é resistente a nado (3 ATM só cobre suor/chuva)</li></ul>"}
  ]
}$j$
where id = 'a3dc31da-b70f-43ba-b8f9-efb91d4221ef';

update product_sections set payload = $j${
  "blocks": [{
    "type": "roteiro",
    "steps": [
      {"title": "Abertura pra quem só quer FC mais precisa", "dialog": "Se o seu relógio já tem tudo que você precisa e só falta uma frequência cardíaca mais estável que o sensor óptico do pulso, o HRM 200 resolve isso com o menor investimento da linha.", "tip": "Bom argumento pra quem não precisa de Dinâmica de Corrida nem gravação autônoma."},
      {"title": "Fechamento", "dialog": "Com o HRM 200 você sai com FC e HRV estáveis, bateria que dura cerca de um ano e Bluetooth seguro pra treinar em academia cheia sem interferência.", "tip": "Se o cliente mencionar natação ou métricas avançadas de corrida, apresente o HRM 600."}
    ]
  }]
}$j$
where id = 'b5add041-35b6-4be0-9b64-53f8489079a3';

-- ============================================================================
-- PARTE 2: Academia de Produtos — HRM 600
-- ============================================================================

update product_sections set payload = $j${
  "blocks": [{
    "type": "accordion",
    "items": [
      {"title": "Gravação autônoma (até 24h, 18+ modalidades)", "html": "<p>A cinta grava o treino sozinha, sem precisar de relógio nem celular por perto durante a atividade, e depois sincroniza com o Garmin Connect.</p>"},
      {"title": "Dinâmica de Corrida completa", "html": "<p>Cadência, comprimento de passada, oscilação vertical, proporção vertical, tempo de contato com o solo e equilíbrio do tempo de contato, o conjunto completo, direto do acelerômetro no peito.</p>"},
      {"title": "Step Speed Loss (métrica exclusiva)", "html": "<p>Mostra a perda de velocidade por passada, um indicador de eficiência de corrida que nenhuma outra cinta Garmin calcula.</p>"},
      {"title": "Bateria recarregável", "html": "<p>Cerca de 2 meses de uso a 1h por dia, diferente do HRM 200, que usa bateria de moeda substituível.</p>"},
      {"title": "5 ATM, resistente à natação", "html": "<p>Módulo destacável e lavável, resistente o suficiente pra nadar: guarda o dado offline debaixo d'água e sincroniza depois.</p>"}
    ]
  }]
}$j$
where id = '4ef42fd5-f047-47ac-875b-f37e73a346a3';

update product_sections set payload = $j${
  "blocks": [{
    "type": "objecao",
    "items": [
      {"question": "Por que pagar mais no HRM 600 se já tenho relógio?", "answer": "Vale a diferença se você quer gravar sem relógio (esporte coletivo) ou quer a métrica exclusiva Step Speed Loss de eficiência de passada. Se você sempre usa o relógio no pulso e não precisa desses dois recursos, o HRM 200 já cobre bem frequência cardíaca e HRV, por um preço bem menor."},
      {"question": "A bateria recarregável não é pior que a de moeda?", "answer": "É uma troca: dura menos tempo entre cargas (cerca de 2 meses contra ~1 ano da bateria de moeda do HRM 200), mas nunca precisa comprar bateria nova, e carrega rápido."},
      {"question": "O que é Step Speed Loss?", "answer": "É uma métrica exclusiva do HRM 600 que mostra a perda de velocidade em cada passada, ajudando o corredor a identificar onde a técnica está perdendo eficiência."}
    ]
  }]
}$j$
where id = '30172292-b566-44ba-bc60-047df9f1ec1e';

update product_sections set payload = $j${
  "blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Atleta de esporte coletivo", "text": "Treina sem relógio no pulso e quer registrar a sessão mesmo assim.", "tags": [{"label": "Esporte coletivo", "color": "blue"}]},
      {"title": "Quem quer treinar sem depender do celular por perto", "text": "A gravação autônoma libera o atleta de levar mais aparelho.", "tags": [{"label": "Autonomia", "color": "green"}]},
      {"title": "Corredor técnico buscando eficiência", "text": "Usa o Step Speed Loss pra refinar a técnica de passada.", "tags": [{"label": "Performance", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer gravar treino sem levar relógio ou celular</li><li>Cliente pratica esporte coletivo (futebol, basquete) sem relógio de pulso durante o jogo</li><li>Cliente quer Dinâmica de Corrida completa ou a métrica exclusiva Step Speed Loss</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente só precisa de frequência cardíaca e HRV, sem Dinâmica de Corrida nem gravação autônoma → o HRM 200 já cobre bem, por um preço bem menor</li></ul>"}
  ]
}$j$
where id = '739c1f9c-bd7a-4cfa-9317-920bded5d14f';

update product_sections set payload = $j${
  "blocks": [{
    "type": "roteiro",
    "steps": [
      {"title": "Abertura pra atleta de esporte coletivo", "dialog": "Se você joga futebol ou outro esporte coletivo sem levar relógio no pulso durante o jogo, o HRM 600 grava o treino inteiro sozinho, e você sincroniza tudo depois.", "tip": "Bom gancho pra quem já reclamou de não conseguir registrar o jogo por não usar relógio em campo."},
      {"title": "Puxando o Step Speed Loss pro corredor técnico", "dialog": "Pra quem já treina forma de corrida, o HRM 600 tem uma métrica exclusiva, Step Speed Loss, que mostra exatamente onde você perde velocidade em cada passada.", "tip": "Bom argumento pra corredor mais técnico, não tanto pra iniciante."},
      {"title": "Fechamento", "dialog": "Com o HRM 600 você sai com gravação autônoma, Dinâmica de Corrida completa, bateria recarregável e uma métrica de eficiência que nenhuma outra cinta Garmin tem.", "tip": "Se o cliente só precisa de FC e HRV, sem os recursos avançados, o HRM 200 é mais barato e já resolve."}
    ]
  }]
}$j$
where id = 'fbaaa31b-aa73-4724-b58f-3181082db9ff';

-- ============================================================================
-- PARTE 3: Quiz "Cintas Cardíacas (HRM)" — 4 perguntas sobre HRM-Fit/HRM-Pro
-- Plus (não vendidos) trocadas por perguntas sobre HRM 200/HRM 600
-- ============================================================================

-- Q0 (era: HRM-Fit vs HRM-Pro Plus, água) → HRM 200 vs HRM 600, resistência à água
update questions set
  body = 'Qual a diferença de resistência à água entre o HRM 200 e o HRM 600?',
  explanation = 'O HRM 200 é 3 ATM (suor e chuva, não indicado pra nado). O HRM 600 é 5 ATM, resistente à natação, com armazenamento offline debaixo d''água.'
where id = '22724900-460a-4dea-8809-5e9237a6e087';
update alternatives set body = 'HRM 200 é 3 ATM (não indicado pra nado); HRM 600 é 5 ATM (resistente à natação)', is_correct = true where id = 'f5a75ec9-3ad9-43e9-a6c6-745af604c35e';
update alternatives set body = 'Os dois são 5 ATM e resistentes à natação', is_correct = false where id = '806407e2-8cb0-42d2-ac44-23eb20c221a4';
update alternatives set body = 'Os dois são 3 ATM, nenhum é indicado pra nado', is_correct = false where id = 'd052a791-bf3a-4877-b970-07007791c904';
update alternatives set body = 'HRM 200 é 5 ATM; HRM 600 é só 3 ATM', is_correct = false where id = '105d1e20-098f-48dc-bf86-6e4640e4af09';

-- Q4 (era: 6 métricas de Dinâmica de Corrida do HRM-Pro Plus) → 7 métricas do HRM 600
update questions set
  body = 'O HRM 600 calcula Dinâmica de Corrida completa. Quais são as métricas desse conjunto?',
  explanation = 'O HRM 600 calcula cadência, comprimento de passada, oscilação vertical, proporção vertical, tempo de contato com o solo e equilíbrio do tempo de contato, o conjunto completo de Dinâmica de Corrida, mais a métrica exclusiva Step Speed Loss.'
where id = 'af0d8852-2ae1-4ed3-943b-3209169b5220';
update alternatives set body = 'Cadência, Velocidade, Potência, VO2 Máximo, Altitude e Frequência Máxima', is_correct = false where id = 'f6355679-178b-4cc2-8182-a6f76c2473b7';
update alternatives set body = 'Cadência, Oscilação Vertical, Tempo de Contato com o Solo, Equilíbrio, Comprimento de Passada e Proporção Vertical', is_correct = true where id = 'cf548c3c-faf7-447f-8496-b47cc4192281';
update alternatives set body = 'Passos por Minuto, Calorias, TrueUp, GPS Interno, Ritmo e Distância', is_correct = false where id = '5b98a083-8dfb-4b1c-af0d-8645cf13e4d2';
update alternatives set body = 'Frequência Cardíaca, Step Speed Loss, Potência, VO2, Altitude e Ritmo', is_correct = false where id = '4dd0fe52-f1c6-46b1-987d-0a7bed8646f6';

-- Q5 (era: HRM-Pro Plus transmissão na natação) → trade-off de bateria HRM 200 x HRM 600
update questions set
  body = 'Qual é o principal trade-off de bateria entre o HRM 200 e o HRM 600?',
  explanation = 'O HRM 200 usa bateria de moeda CR2032 substituível, dura cerca de 1 ano sem precisar recarregar. O HRM 600 usa bateria recarregável, dura cerca de 2 meses por carga, mas nunca precisa comprar bateria nova.'
where id = '248724af-900e-44cd-ad33-9f207b8c86dd';
update alternatives set body = 'HRM 200 dura cerca de 1 ano com bateria de moeda; HRM 600 dura cerca de 2 meses por carga recarregável', is_correct = true where id = '6922081b-d901-42c1-aef7-07ccb11c32c4';
update alternatives set body = 'Os dois usam a mesma bateria de moeda CR2032', is_correct = false where id = 'dde130a4-43ff-4562-aea3-225cea576cd5';
update alternatives set body = 'HRM 200 é recarregável; HRM 600 usa bateria de moeda', is_correct = false where id = 'cf09d7f0-7c6b-498c-a127-54c543d900d5';
update alternatives set body = 'Nenhum dos dois precisa de bateria, funcionam por indução', is_correct = false where id = '48359ffa-ecc1-4e69-868b-4de9cea5e3fb';

-- Q6 (era: TrueUp do HRM-Pro Plus) → conectividade do HRM 200
update questions set
  body = 'No HRM 200, quantos dispositivos podem se conectar ao mesmo tempo por Bluetooth Low Energy?',
  explanation = 'O HRM 200 transmite por ANT+ (conexões ilimitadas) e Bluetooth Low Energy (até 3 dispositivos simultâneos).'
where id = '39eff501-2ab5-43d7-8cb8-6548eb482974';
update alternatives set body = 'Até 3 dispositivos por Bluetooth, e ilimitados por ANT+', is_correct = true where id = 'f2612880-bbaf-4ab3-8d7f-abd35efb6566';
update alternatives set body = 'Só 1 dispositivo por vez, em qualquer protocolo', is_correct = false where id = '088c7b28-711d-48d4-a3c9-aae9b27d2be0';
update alternatives set body = 'Até 10 dispositivos simultâneos', is_correct = false where id = '13e4f541-92ee-40d5-aadc-e4340ff83ba0';
update alternatives set body = 'O HRM 200 não transmite por Bluetooth, só ANT+', is_correct = false where id = '80113cf2-3d61-47ec-8e90-3e62eb44052b';

-- ============================================================================
-- PARTE 4: Módulo "Ecossistema de Sensores de Elite" — lição inteira sobre
-- HRM-Pro Plus reescrita pra HRM 600
-- ============================================================================

update lessons set
  title = 'HRM 600: a cinta que vai além da frequência cardíaca',
  body = $j${
    "blocks": [
      {"type": "texto_rico", "html": "<p>O <strong>HRM 600</strong> é a cinta cardíaca mais completa da Garmin: além da frequência cardíaca, calcula Dinâmica de Corrida completa (cadência, comprimento de passada, oscilação vertical, proporção vertical, tempo de contato com o solo e equilíbrio do tempo de contato) e soma a métrica exclusiva Step Speed Loss, que mostra a perda de velocidade por passada. Também alimenta a Potência de Corrida no pulso. Transmite por ANT+ e Bluetooth ao mesmo tempo, e é resistente à natação: guarda o dado internamente debaixo d'água (o sinal não atravessa a água) e sincroniza com o relógio só depois que o nado termina. Grava até 24h de atividade sozinho, sem relógio nem celular por perto, em mais de 18 modalidades.</p>"},
      {"type": "banner", "tone": "info", "text": "Esse armazenamento offline embaixo d'água, somado à gravação autônoma sem relógio, é o que diferencia o HRM 600 de uma cinta comum como o HRM 200: nenhuma cinta de entrada guarda dado sozinha durante o nado ou grava o treino inteiro sem depender de outro aparelho."}
    ]
  }$j$
where id = '8ef170f6-2ccc-475b-9fc4-f236cedfc023';

update lessons set
  body = $j${
    "blocks": [
      {"type": "roteiro", "steps": [
        {"title": "Apresentando o ecossistema como um todo", "dialog": "O relógio sozinho já entrega muita coisa, mas o ecossistema completo é o que separa o atleta casual do sério: HRM 600 pra dinâmica de corrida completa e dado seguro na água, tempe pra contexto de calor no treino, e Varia se o ciclismo é feito em rua aberta com tráfego.", "tip": "Apresente o ecossistema em camadas, não tudo de uma vez: comece pelo que resolve a dor imediata do cliente."}
      ]}
    ]
  }$j$
where id = 'f5221f03-52cb-47d2-a010-eb50f3b11f0f';

update questions set
  body = 'O que o HRM 600 calcula além da frequência cardíaca?',
  explanation = 'Calcula Dinâmica de Corrida completa (cadência, comprimento de passada, oscilação vertical, tempo de contato com o solo) e alimenta a Potência de Corrida.'
where id = '10f0b99d-2b72-45ac-bb72-2d71cc03f3db';

update questions set
  body = 'Como o HRM 600 lida com dados durante a natação?',
  explanation = 'Guarda o dado internamente debaixo d''água (o sinal não atravessa a água) e sincroniza com o relógio depois do nado.'
where id = '23413dac-18f2-4519-979b-c4542aa8c564';

update questions set
  body = 'Como o HRM 600 transmite dados?',
  explanation = 'Transmite por ANT+ (conexões ilimitadas) e Bluetooth Low Energy (até 3 dispositivos) ao mesmo tempo.'
where id = '678191f9-b858-4da4-8aab-7a0b60886cbb';

-- ============================================================================
-- PARTE 5: Módulo "Fechamento de Vendas Premium" — bundle de exemplo trocado
-- de HRM-Pro Plus pra HRM 600
-- ============================================================================

update lessons set
  body = $j${
    "blocks": [
      {"type": "roteiro", "steps": [
        {"title": "Fechamento assumptivo com dois modelos premium", "dialog": "Pelo que você me contou do treino, os dois que fazem mais sentido são o Fenix 8 e o Forerunner 970. Qual dos dois combina mais com o que você busca: mais recursos multiesporte ou um corpo mais leve focado em corrida?", "tip": "Técnica \"qual, não se\": nunca pergunte se ele quer comprar, pergunte qual dos dois."},
        {"title": "Fechando com bundle relevante", "dialog": "Pra fechar junto, já recomendo uma cinta HRM 600: com o volume de treino que você descreveu, o dado de recuperação fica muito mais preciso que só com o sensor óptico do pulso.", "tip": "Só ofereça o bundle depois de já validar a dor real do cliente (nesse caso, precisão de recuperação)."}
      ]}
    ]
  }$j$
where id = 'a847ad88-607f-423f-a091-e4d68db24c2e';

update questions set
  body = 'No roteiro de fechamento pro triatleta premium, quando o bundle (ex.: HRM 600) deve ser oferecido?'
where id = '3b39036f-ad5b-4565-b342-4aaec3cca926';

-- ============================================================================
-- PARTE 6: Módulo "Linha Edge de Entrada e Sensores" — HRM-Dual/HRM-Pro Plus
-- trocados por HRM 200/HRM 600
-- ============================================================================

update lessons set
  body = $j${
    "blocks": [
      {"type": "texto_rico", "html": "<p>Um Edge sozinho já calcula velocidade e distância por GPS, mas sensores dedicados aumentam a precisão e liberam métricas que o GPS não entrega.</p>"},
      {"type": "metric_card_grid", "columns": 2, "items": [
        {"icon": "🚴", "name": "Speed Sensor 2 / Cadence Sensor 2", "definition": "Instalados no cubo da roda e no pedivela. Transmitem por ANT+ e Bluetooth ao mesmo tempo, com bateria de cerca de 1 ano. O Speed Sensor 2 ainda guarda até 300 horas de dado sozinho, sem precisar do computador por perto."},
        {"icon": "❤️", "name": "HRM 200", "definition": "Cinta de frequência cardíaca de entrada, ANT+ e Bluetooth, sem Dinâmica de Corrida. Ideal só pra quem quer FC mais precisa que a leitura óptica do pulso."},
        {"icon": "🏃", "name": "HRM 600", "definition": "Cinta mais completa: além da FC, calcula Dinâmica de Corrida completa e resiste à natação, guardando dado offline debaixo d'água até sincronizar depois."}
      ]},
      {"type": "objecao", "items": [
        {"question": "Meu relógio já mede frequência cardíaca no pulso, pra que uma cinta?", "answer": "A leitura óptica de pulso sofre mais em esforço alto e em dias frios. Uma cinta como a HRM 200 ou HRM 600 lê direto do músculo cardíaco, é mais estável exatamente na hora que a intensidade sobe."}
      ]}
    ]
  }$j$
where id = '93e274cf-aa29-4cb2-8b6c-bb66528604e5';

-- ============================================================================
-- PARTE 7: retoques finais (3 perguntas e 1 alternativa que escaparam da
-- primeira varredura por não conterem "HRM-" — usavam "HRM-Pro Plus" ou
-- "HRM-Dual" em body/explanation sem hífen antes do nome do produto)
-- ============================================================================

update questions set explanation = 'O HRM 200 possui resistência de 3 ATM, suportando apenas exposição ocasional a água e produtos químicos de limpeza. O manual não lista a natação como atividade suportada para o registro de dados, diferente do HRM 600.'
where id = '49d3b441-7485-4f9b-a1f7-2f6e8d2ee822';

update questions set
  body = 'O que o HRM 600 tem que o HRM 200 não tem?',
  explanation = 'O HRM 600 soma Dinâmica de Corrida completa, a métrica exclusiva Step Speed Loss, resistência à natação (5 ATM) e gravação autônoma sem relógio.'
where id = 'f6571658-2b88-4fa2-ac1e-f47e9ab28c6f';
update alternatives set body = 'Dinâmica de Corrida completa, Step Speed Loss e resistência à natação' where id = '2c37ff9d-8647-4ab5-a6f6-b63775a532b7';
update alternatives set body = 'Bateria de moeda substituível' where id = '5b82f99a-e6f8-4993-ad4b-ee1f3c854450';

update questions set
  body = 'Qual a diferença prática entre HRM 200 e HRM 600?',
  explanation = 'O HRM 200 só mede frequência cardíaca e HRV; o HRM 600 soma Dinâmica de Corrida completa e resiste à natação com dado guardado offline.'
where id = '7f808b6f-3bfd-434c-aca7-add2b01dbfb9';
update alternatives set body = 'HRM 600 soma Dinâmica de Corrida e resiste à natação', is_correct = true where id = '9d40f0fa-a4ee-4cb4-b845-03c12b9c9153';
update alternatives set body = 'HRM 200 é mais preciso em frequência cardíaca', is_correct = false where id = 'a25c7525-501d-457e-b549-3e0dcaaed022';
update alternatives set body = 'HRM 600 não transmite por ANT+', is_correct = false where id = 'dc874eab-8cc8-4ad2-bf17-5c0c3b3d004b';

update alternatives set body = 'Um monitor de pulso genérico de terceiros' where id = 'fcc0b0b0-6cce-464f-9dff-43c16abac705';

commit;

-- ============================================================================
-- FIM DA MIGRAÇÃO 100
-- ============================================================================
