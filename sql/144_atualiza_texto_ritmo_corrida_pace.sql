-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 144: Texto mais completo pro item "Ritmo de
-- Corrida (Pace)" (módulo Métricas Essenciais e Avançadas de Corrida)
-- ============================================================================
-- Pedido do usuário (2026-09-15): substituir o html do item "Ritmo de
-- Corrida (Pace)" (accordion, lição "Métricas Fundamentais...") por um texto
-- próprio, mais completo pra treinamento — inclui exemplo numérico, as três
-- variações de pace (instantâneo/médio/lap) e uma seção "Na conversa com o
-- cliente" com pergunta-gancho e o argumento de venda.
-- ============================================================================

update lessons
set body = jsonb_set(
  body,
  '{blocks,1,items,0,html}',
  $html$"<p>O Pace indica <strong>quanto tempo o atleta leva, em média, para percorrer 1 km</strong>. Quanto menor o número, mais rápido é o ritmo.</p><p><strong>Exemplo:</strong> 5:00 min/km significa que o atleta está correndo a uma velocidade equivalente a <strong>5 minutos para cada quilômetro</strong>.</p><p>Na Garmin, o corredor pode acompanhar diferentes referências de ritmo:</p><ul><li><strong>Pace Instantâneo:</strong> mostra o ritmo aproximado naquele momento da corrida. É útil para ajustar o esforço durante o percurso.</li><li><strong>Pace Médio:</strong> calcula o ritmo médio da atividade até aquele momento.</li><li><strong>Pace da Volta (Lap):</strong> mostra o ritmo de um trecho específico, sendo especialmente útil em treinos intervalados.</li></ul><h4>Na conversa com o cliente</h4><p>O Pace é uma ótima porta de entrada para entender o nível de experiência do corredor:</p><p><em>\"Você costuma controlar seu ritmo durante a corrida ou olha só o resultado depois?\"</em></p><p>A partir da resposta, o vendedor pode demonstrar como o relógio permite <strong>acompanhar o ritmo no pulso e tomar decisões durante o treino</strong>, sem precisar ficar consultando o celular.</p><p><strong>Ponto de venda:</strong> não é apenas saber \"quanto correu\". É conseguir <strong>controlar como está correndo</strong>.</p>"$html$::jsonb
)
where id = '1072a42a-bc8e-4e21-91f7-1f23f3855a86'
  and body->'blocks'->1->'items'->0->>'title' = 'Ritmo de Corrida (Pace)';

-- ============================================================================
-- FIM DA MIGRAÇÃO 144
-- ============================================================================
