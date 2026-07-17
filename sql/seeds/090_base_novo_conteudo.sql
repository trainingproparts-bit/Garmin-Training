-- ============================================================================
-- GARMIN TRAINING HUB — BASE PRA CRIAR CONTEÚDO NOVO DIRETO NO SUPABASE
-- ============================================================================
-- Referência reutilizável — não é uma migração (não precisa "rodar" este
-- arquivo inteiro de uma vez). Copie o bloco do tipo que você precisa,
-- troque os valores marcados com "TROQUE" e rode só aquele trecho no SQL
-- Editor do Supabase.
--
-- IDs reais de hoje pra usar como referência (confira antes de usar — este
-- arquivo não se atualiza sozinho se você criar zonas/marcas novas):
--
--   Marca Garmin  : 2f7d8451-b279-4d69-8192-6ac9953d7da1
--   Marca Shokz   : 8d99747c-09bd-4f56-9c9a-2f0445391c6e  (sem trilha/zonas ainda)
--
--   Zona Explorador                       : 9cfd688f-fcad-4a99-900d-9b6771068661
--   Zona Atleta                           : 7ded46e1-864c-4122-be37-bf99f0385683
--   Circuito de Desafios (Nível 1)        : 919ce86f-456c-4cc3-a2ce-2f4ae370bdbd
--   Circuito de Desafios · Nível 2        : 5436de90-b090-43dc-95b0-15237036d129
--
-- Pra achar o zone_id/brand_id certo na hora, sempre dá pra consultar:
--   select z.id, z.name, t.name as trilha, b.name as marca
--   from zones z join trails t on t.id=z.trail_id join brands b on b.id=t.brand_id;
-- ============================================================================


-- ============================================================================
-- 1. MÓDULO (modules + lessons + checkpoint opcional na trilha)
-- ============================================================================

-- 1a. O módulo em si
insert into public.modules (zone_id, slug, title, summary, estimated_minutes, order_index, is_published, cover_url)
values (
  '9cfd688f-fcad-4a99-900d-9b6771068661',  -- TROQUE: zone_id de destino
  'nome-do-modulo-slug',                    -- TROQUE: slug único, minúsculo, com hífen
  'Título do Módulo',                       -- TROQUE
  'Resumo curto de uma linha do que o módulo ensina.', -- TROQUE (opcional, pode ser null)
  10,                                        -- TROQUE: minutos estimados (opcional, pode ser null)
  (select coalesce(max(order_index), -1) + 1 from modules where zone_id = '9cfd688f-fcad-4a99-900d-9b6771068661'), -- próxima posição na zona
  false,                                     -- is_published: comece false, publique só depois de revisar
  null                                       -- cover_url (opcional, imagem 16:9)
)
returning id; -- guarde esse id pra usar nas lições abaixo

-- 1b. Lições do módulo — body é jsonb no formato { blocks: [...] } (ver
-- src/components/ContentBlocks.js pros ~13 tipos de bloco disponíveis:
-- texto_rico, banner, card, accordion, timeline, video, galeria,
-- quiz_embutido, roteiro, objecao, tabela, card_grid, flip_card).
-- Exemplo simples com texto_rico + card:
insert into public.lessons (module_id, title, content_type, body, order_index, is_published)
values (
  '00000000-0000-0000-0000-000000000000', -- TROQUE: id do módulo (retornado em 1a)
  'Título da Lição 1',                     -- TROQUE
  'text',                                  -- content_type ('text' é o único valor usado hoje)
  '{
    "blocks": [
      { "type": "texto_rico", "html": "<p>Introdução da lição em HTML simples.</p>" },
      { "type": "card", "icon": "💡", "title": "Ponto-chave", "text": "Texto do card." },
      { "type": "banner", "tone": "info", "text": "Dica ou aviso em destaque." }
    ]
  }'::jsonb,
  0,     -- order_index dentro do módulo (0, 1, 2...)
  true   -- is_published
)
returning id;

-- 1c. (Opcional) Vincular o módulo à trilha — só aparece pro colaborador
--     depois deste passo. order_index é a posição dentro da ZONA (não do módulo).
insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
values (
  '9cfd688f-fcad-4a99-900d-9b6771068661', -- TROQUE: mesma zone_id do módulo
  'module',
  '00000000-0000-0000-0000-000000000000', -- TROQUE: id do módulo (1a)
  (select coalesce(max(order_index), -1) + 1 from checkpoints where zone_id = '9cfd688f-fcad-4a99-900d-9b6771068661'),
  true -- is_required: false = aparece como opcional/extra dentro da zona
);


-- ============================================================================
-- 2. QUIZ (quizzes + questions + alternatives + checkpoint opcional)
-- ============================================================================

-- 2a. O quiz
insert into public.quizzes (brand_id, slug, title, passing_score_pct, time_limit_seconds, max_attempts, is_published, cover_url)
values (
  '2f7d8451-b279-4d69-8192-6ac9953d7da1', -- TROQUE: brand_id
  'nome-do-quiz-slug',                     -- TROQUE
  'Título do Quiz',                        -- TROQUE
  70,                                       -- % mínimo pra passar
  null,                                     -- time_limit_seconds (opcional, null = sem limite)
  null,                                     -- max_attempts (opcional, null = ilimitado)
  false,                                    -- comece despublicado
  null
)
returning id; -- guarde pra usar em 2b

-- 2b. Uma pergunta do quiz
insert into public.questions (quiz_id, body, explanation, order_index, is_active)
values (
  '00000000-0000-0000-0000-000000000000', -- TROQUE: id do quiz (2a)
  'Texto da pergunta?',                     -- TROQUE
  'Explicação mostrada depois de responder (nunca antes — RLS já protege isso).', -- TROQUE
  0,
  true
)
returning id; -- guarde pra usar em 2c

-- 2c. Alternativas da pergunta — exatamente 1 com is_correct = true
insert into public.alternatives (question_id, body, is_correct, feedback, order_index)
values
  ('00000000-0000-0000-0000-000000000000', 'Alternativa A (correta)', true,  null, 0), -- TROQUE question_id
  ('00000000-0000-0000-0000-000000000000', 'Alternativa B',           false, null, 1), -- TROQUE question_id
  ('00000000-0000-0000-0000-000000000000', 'Alternativa C',           false, null, 2); -- TROQUE question_id

-- 2d. (Opcional) Vincular à trilha, igual módulo — ou deixar fora dos
--     checkpoints pra aparecer só em "Quizzes Extras" (games.js/quizzes.js
--     já listam por brand_id, sem depender de checkpoint).
insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
values (
  '919ce86f-456c-4cc3-a2ce-2f4ae370bdbd', -- TROQUE: ex. Circuito de Desafios
  'quiz',
  '00000000-0000-0000-0000-000000000000', -- TROQUE: id do quiz (2a)
  (select coalesce(max(order_index), -1) + 1 from checkpoints where zone_id = '919ce86f-456c-4cc3-a2ce-2f4ae370bdbd'),
  false
);


-- ============================================================================
-- 3. GAME / DUELO (games + checkpoint opcional)
-- ============================================================================
-- config é jsonb — formato "duelo_1v1" (o único implementado hoje no
-- GameRunner.js). opcoes_resposta precisa bater com os "gabarito" usados em
-- cada round (mais wildcards se fizer sentido: "ambos"/"nenhum"/"todos").

insert into public.games (brand_id, slug, title, config, is_published)
values (
  '2f7d8451-b279-4d69-8192-6ac9953d7da1', -- TROQUE: brand_id
  'nome-do-duelo-slug',                    -- TROQUE
  'Duelo: Produto A vs Produto B',         -- TROQUE
  '{
    "meta": {
      "modo": "duelo_1v1",
      "titulo": "Produto A vs Produto B",
      "opcoes_resposta": ["produto_a", "produto_b", "ambos", "nenhum"],
      "rodadas_por_partida": 5,
      "total_perguntas_no_pool": 5
    },
    "rounds": [
      {
        "cat": { "nome": "Categoria da Rodada", "descr": "O que está sendo comparado", "icone": "⚙️" },
        "texto": "Qual produto tem a característica X?",
        "acerto": "✅ Correto! Explicação de por que está certo.",
        "erro": "❌ Errado. Explicação de qual é o certo e por quê.",
        "reveal": {
          "produto_a": "<strong>Detalhe técnico</strong> do Produto A nesse critério",
          "produto_b": "<strong>Detalhe técnico</strong> do Produto B nesse critério"
        },
        "gabarito": "produto_a"
      }
    ]
  }'::jsonb,
  false -- comece despublicado até revisar todas as rodadas
)
returning id;

-- (Opcional) Vincular o duelo a uma zona (ver seção "Circuito de Desafios" —
-- é assim que o Duelo MARQ foi corrigido nesta sessão, sql/047):
-- insert into public.checkpoints (zone_id, checkpoint_type, reference_id, order_index, is_required)
-- values ('5436de90-b090-43dc-95b0-15237036d129', 'game', '<id-do-game>', 2, false);


-- ============================================================================
-- 4. POST DO BLOG (blog_posts — não tem brand_id, é global pra organização)
-- ============================================================================
-- category é CHECK constraint fixa: só aceita 'Caso Real', 'Novidade',
-- 'Comunicado' ou 'Dica' (ver blogService.js CATEGORIES).

insert into public.blog_posts (title, content, category, banner_url, author_id, is_published)
values (
  'Título do Post',                         -- TROQUE
  '<p>Conteúdo do post em HTML simples.</p>', -- TROQUE
  'Dica',                                    -- TROQUE: 'Caso Real' | 'Novidade' | 'Comunicado' | 'Dica'
  null,                                       -- banner_url (opcional)
  (select id from profiles where username = 'samara.pereira'), -- TROQUE: autor (deve ser admin pra RLS deixar)
  true
);

-- ============================================================================
-- FIM
-- ============================================================================
