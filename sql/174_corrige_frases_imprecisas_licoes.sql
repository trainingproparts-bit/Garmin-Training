-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 174: corrige frases imprecisas em lições
-- ============================================================================
-- Pedido do usuário (2026-10-08): ao refazer os quizzes (sql/172 e 173),
-- alguns trechos de lição ficaram de fora das perguntas por serem
-- imprecisos ou contraditórios com o resto da plataforma. Esta migração
-- corrige só esses trechos, sem reescrever as lições:
--
--   1. Métricas de Corrida: Tempo de Recuperação "ajuda a prevenir
--      overtraining e lesões" contradiz a regra dos outros módulos (nenhuma
--      métrica é apresentada como prevenção de lesão).
--   2. Universo Multiesporte: perfil multiesporte "só nos relógios AMOLED"
--      é impreciso; corrige também uma tag <strong> sem abertura; e preenche
--      a lição "Quais relógios suportam o perfil Multiesporte", que estava
--      vazia, com a orientação de confirmar por modelo (sem lista fixa).
--   3. Linha Edge: a tabela juntava as baterias de 540/550 e 840/850 numa
--      célula só, sem dizer qual número é de qual modelo.
--   4. Universo Garmin: Forerunner 235 deixa de ser "o primeiro" relógio
--      com sensor óptico e GPS; multibanda "a partir do 265" passa a dizer
--      que vale para a linha Forerunner atual.
--   5. Portfólio de Produtos e Perfis de Cliente: "Rally RK 200" vira a
--      linha atual Rally 110/210 (a mesma do módulo de Potência), e o texto
--      do Edge passa a citar os pares 540/550, 840/850 e 1040/1050.
--
-- Cada update só age se o trecho antigo ainda existir (rodar de novo não
-- faz nada).
-- ============================================================================

-- 1. Métricas de Corrida: Tempo de Recuperação
update lessons
   set body = replace(body::text,
         'Ajuda a prevenir quadros de overtraining e lesões por sobrecarga.',
         'Ajuda a planejar a semana de treinos, respeitando o tempo estimado antes do próximo esforço intenso.')::jsonb
 where id = '342f0472-cd16-409c-aa13-80777d400f2f'
   and body::text like '%prevenir quadros de overtraining%';

-- 2a. Universo Multiesporte: compatibilidade e tag <strong>
update lessons
   set body = replace(replace(body::text,
         'é um modo de atividade disponível nos relógios com tela AMOLED da linha atual (Forerunner 970/965, Fenix 8, Epix Pro).',
         'é um modo de atividade disponível em relógios compatíveis da linha atual, como Forerunner 970/965 e Fenix 8. A disponibilidade varia por modelo, então confirme sempre no modelo específico.'),
         'A grande sacada técnica é a transição automática</strong>',
         'A grande sacada técnica é a <strong>transição automática</strong>')::jsonb
 where id = '2e44a6b9-3bc5-497f-8197-47c42366973b'
   and body::text like '%relógios com tela AMOLED da linha atual%';

-- 2b. Universo Multiesporte: lição "Quais relógios suportam" estava vazia
update lessons
   set body = $j$
{"blocks": [
  {"type": "texto_rico", "html": "<p>O perfil Multiesporte e recursos como a transição automática não são iguais em toda a linha Garmin. A disponibilidade muda conforme o modelo e a geração do relógio.</p>"},
  {"type": "banner", "tone": "warning", "text": "<strong>Antes de afirmar:</strong> confirme o recurso na ficha do modelo na Academia de Produtos ou no manual do relógio. Prefira dizer “esse modelo oferece o perfil Multiesporte” a “todo Garmin tem”."}
]}
$j$::jsonb
 where id = '1be7e667-8fcd-4ce0-bbb4-77a50e7cd33f'
   and coalesce(jsonb_array_length(body->'blocks'), 0) = 0;

-- 3. Linha Edge: bateria por modelo na tabela de degraus
update lessons
   set body = jsonb_set(jsonb_set(body,
         '{blocks,1,rows,0,3}', '"540: 26h / 32h · 550: 12h / 36h"'::jsonb),
         '{blocks,1,rows,1,3}', '"840: 26h / 32h · 850: 12h / 36h"'::jsonb)
 where id = '99ce4530-f2af-4f99-acf5-f9521c791d1f'
   and body->'blocks'->1->>'type' = 'tabela'
   and body->'blocks'->1->'rows'->0->>0 = '540 / 550'
   and body->'blocks'->1->'rows'->1->>0 = '840 / 850';

-- 4a. Universo Garmin: Forerunner 235
update lessons
   set body = replace(body::text,
         'Lançamento do Forerunner 235, o primeiro relógio Garmin a combinar sensor óptico de frequência cardíaca no pulso com GPS integrado.',
         'Lançamento do Forerunner 235, com sensor óptico de frequência cardíaca no pulso e GPS integrado.')::jsonb
 where id = 'd36bd707-2b10-4567-9b43-62f8451a24cf'
   and body::text like '%o primeiro relógio Garmin a combinar sensor óptico%';

-- 4b. Universo Garmin: GPS multibanda
update lessons
   set body = replace(body::text,
         'Está disponível a partir do Forerunner 265.',
         'Na linha Forerunner atual, está disponível a partir do Forerunner 265.')::jsonb
 where id = '6bb615c1-d4f1-41e3-a3c3-e8c2929a8a94'
   and body::text like '%Está disponível a partir do Forerunner 265.%';

-- 5a. Portfólio de Produtos: modelos de Edge e linha Rally atual
update lessons
   set body = replace(replace(replace(body::text,
         'A linha vai do Edge 540 (entrada) até o 1050 (topo), passando pelo 840 e 1040',
         'A linha vai dos Edge 540 e 550 (entrada) até os Edge 1040 e 1050 (topo), passando pelos Edge 840 e 850'),
         'se o cliente já pedala com um Edge de entrada (540)',
         'se o cliente já pedala com um Edge de entrada (540 ou 550)'),
         'Os pedais Rally (RK 200) medem',
         'Os pedais Rally (linha atual: Rally 110 e 210) medem')::jsonb
 where id = '7d5e81d0-21a1-426a-9938-7bb667723d3c'
   and body::text like '%Edge 540 (entrada)%';

-- 5b. Perfis de Cliente e Portfólio: restante das menções ao Rally RK 200
update lessons
   set body = replace(body::text, 'Rally RK 200', 'Rally 110/210')::jsonb
 where module_id in ('abfc3f1d-930c-4e86-995a-2a6738c7242b', 'a5f90a90-2af0-44b6-b777-a08a7ef990c6')
   and body::text like '%Rally RK 200%';

-- ============================================================================
-- FIM DA MIGRAÇÃO 174
-- ============================================================================
