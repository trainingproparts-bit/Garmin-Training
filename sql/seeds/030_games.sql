-- ============================================================================
-- 030_games.sql
-- Seed dos minigames "Duelo de Especificações" (Garmin)
-- ============================================================================
-- Fonte: index_redesign_v5.html
--   - G_PERGUNTAS  (~linha 7373) -> minigame "Instinct 3 vs Instinct E"
--   - MG_PERGUNTAS (~linha 7620) -> minigame "Duelo MARQ Carbon"
-- Painel de apresentação: panel-games (~linha 6983)
--
-- Cada linha de games.config guarda o array de rodadas (rounds) migrado
-- fielmente do protótipo (categoria, texto da pergunta, gabarito, textos de
-- acerto/erro e o reveal comparativo), além de um bloco meta com o título
-- exibido na UI, o modo de jogo, as opções de resposta disponíveis e o
-- tamanho do pool de perguntas de onde as 10 rodadas de cada partida são
-- sorteadas (ver funções gIniciar()/mgIniciar() no protótipo).
-- ============================================================================

-- Minigame 1 — Instinct 3 vs Instinct E (10 perguntas no pool, 10 rodadas por partida)
insert into games (brand_id, slug, title, config, is_published)
values (
  (select id from brands where slug = 'garmin'),
  'duelo-instinct-3-vs-e',
  'Duelo de Especificações: Instinct 3 vs Instinct E',
  '{
  "rounds": [
    {
      "cat": {
        "icone": "🖥️",
        "nome": "Tipo de Tela",
        "descr": "Tecnologia e qualidade de exibição"
      },
      "texto": "Qual relógio possui tela AMOLED colorida com suporte ao modo sempre ligado?",
      "gabarito": "instinct3",
      "acerto": "✅ Correto! O Instinct 3 tem tela AMOLED colorida de 1,2\" com resolução 390×390 px e modo sempre ligado (Always-on Display). Também possui a função Mudança de Cor Vermelha para uso noturno.",
      "erro": "❌ É o Instinct 3. Ele tem tela AMOLED colorida de 1,2\". O Instinct E usa tela monocromática MIP transfletiva, de duas janelas, excelente sob luz solar mas sem cores.",
      "reveal": {
        "i3": "<strong>AMOLED colorida</strong> · 1,2\" · 390×390 px · modo sempre ligado",
        "ie": "<strong>MIP monocromática</strong> · transfletiva · 176×176 px · visível sob sol"
      }
    },
    {
      "cat": {
        "icone": "🔋",
        "nome": "Autonomia — Expedição GPS",
        "descr": "Duração máxima com GPS ativo em expedição"
      },
      "texto": "Em modo de expedição com GPS ativo, qual relógio dura mais dias com uma única carga?",
      "gabarito": "instincte",
      "acerto": "✅ Exato! O Instinct E chega a 20 dias em modo expedição GPS, enquanto o Instinct 3 dura até 16 dias. A tela MIP consome muito menos energia nesse modo.",
      "erro": "❌ Neste critério específico o Instinct E leva vantagem: até 20 dias em expedição GPS, contra 16 dias do Instinct 3. A tela MIP consome menos energia que a AMOLED em uso prolongado.",
      "reveal": {
        "i3": "Expedição GPS: <strong>até 16 dias</strong>",
        "ie": "Expedição GPS: <strong>até 20 dias</strong> ✓ (tela MIP economiza bateria)"
      }
    },
    {
      "cat": {
        "icone": "📡",
        "nome": "Sistema de GPS",
        "descr": "Precisão e tecnologia de posicionamento"
      },
      "texto": "Qual relógio possui GPS de banda dupla com tecnologia SatIQ™, que ajusta automaticamente os satélites para equilibrar precisão e economia de bateria?",
      "gabarito": "instinct3",
      "acerto": "✅ Certo! O Instinct 3 tem GPS multibanda com SatIQ™ — seleciona automaticamente entre satélites para maximizar precisão sem drenar a bateria. Ideal em ambientes difíceis como florestas e cidades.",
      "erro": "❌ É o Instinct 3. Ele tem GPS de banda dupla com SatIQ™. O Instinct E possui suporte multi-GNSS básico, sem a tecnologia de seleção automática de banda.",
      "reveal": {
        "i3": "<strong>GPS multibanda + SatIQ™</strong> · ajuste automático entre satélites",
        "ie": "<strong>Multi-GNSS básico</strong> · sem seleção automática de banda"
      }
    },
    {
      "cat": {
        "icone": "💡",
        "nome": "Lanterna Integrada",
        "descr": "Iluminação embutida no próprio relógio"
      },
      "texto": "Qual relógio possui lanterna LED integrada com múltiplas intensidades e opção de luz vermelha para não prejudicar a visão noturna?",
      "gabarito": "instinct3",
      "acerto": "✅ Correto! Apenas o Instinct 3 tem lanterna LED integrada com intensidades variáveis e luz vermelha. O Instinct E não possui esse recurso.",
      "erro": "❌ A lanterna LED é exclusiva do Instinct 3. O Instinct E não tem esse recurso.",
      "reveal": {
        "i3": "Lanterna LED integrada ✓ · intensidades variáveis · luz vermelha disponível",
        "ie": "Sem lanterna integrada ✗"
      }
    },
    {
      "cat": {
        "icone": "💤",
        "nome": "Métricas Avançadas de Sono",
        "descr": "Análise detalhada do descanso noturno"
      },
      "texto": "Qual relógio oferece Pontuação de Sono com insights detalhados sobre a qualidade do descanso?",
      "gabarito": "instinct3",
      "acerto": "✅ Correto! O Instinct 3 traz Pontuação de Sono com insights detalhados. O Instinct E monitora o sono, mas sem as métricas avançadas de pontuação e análise aprofundada.",
      "erro": "❌ A Pontuação de Sono com insights é exclusiva do Instinct 3. O Instinct E registra o sono, mas sem esse nível de análise.",
      "reveal": {
        "i3": "<strong>Pontuação de Sono + insights</strong> · análise detalhada",
        "ie": "Monitoramento de sono básico · sem pontuação"
      }
    },
    {
      "cat": {
        "icone": "🏃",
        "nome": "Corrida — Potência e Balanço",
        "descr": "Métricas avançadas de performance na corrida"
      },
      "texto": "Qual relógio calcula a potência de corrida diretamente no pulso e inclui o balanço do tempo de contato com o solo?",
      "gabarito": "instinct3",
      "acerto": "✅ Correto! O Instinct 3 fornece Potência de Corrida e balanço do tempo de contato com o solo. O Instinct E oferece algumas dinâmicas de corrida, mas não inclui o balanço.",
      "erro": "❌ É o Instinct 3. Ele inclui Potência de Corrida e o balanço do tempo de contato com o solo. O Instinct E tem dinâmicas básicas, mas não chega nesse nível.",
      "reveal": {
        "i3": "Potência de Corrida ✓ · tempo de contato ✓ · <strong>balanço incluído</strong>",
        "ie": "Dinâmicas de corrida básicas · sem potência · sem balanço"
      }
    },
    {
      "cat": {
        "icone": "⚙️",
        "nome": "Material da Caixa",
        "descr": "Resistência e acabamento físico do relógio"
      },
      "texto": "Qual relógio possui bisel reforçado com metal — combinação de polímero e alumínio?",
      "gabarito": "instinct3",
      "acerto": "✅ Isso mesmo! O Instinct 3 tem bisel de polímero reforçado com alumínio. O Instinct E usa apenas polímero reforçado com fibra, sendo mais leve mas sem o metal.",
      "erro": "❌ O bisel com alumínio é do Instinct 3. O Instinct E usa polímero reforçado com fibra — mais leve, porém sem componente metálico.",
      "reveal": {
        "i3": "Bisel de <strong>polímero + alumínio</strong> · mais robusto",
        "ie": "<strong>Polímero reforçado com fibra</strong> · mais leve (48g vs 53g)"
      }
    },
    {
      "cat": {
        "icone": "💳",
        "nome": "Pagamentos por Aproximação",
        "descr": "Pagamento pelo pulso sem cartão"
      },
      "texto": "Qual dos dois modelos possui suporte a pagamentos por aproximação?",
      "gabarito": "instinct3",
      "acerto": "✅ Correto! O Instinct 3 possui pagamentos por aproximação (equivalente ao Garmin Pay). O Instinct E não traz essa funcionalidade.",
      "erro": "❌ O pagamento por aproximação é exclusivo do Instinct 3. O Instinct E não oferece esse recurso.",
      "reveal": {
        "i3": "Pagamentos por aproximação <strong>disponível</strong> ✓",
        "ie": "Pagamentos por aproximação <strong>não disponível</strong> ✗"
      }
    },
    {
      "cat": {
        "icone": "⛰️",
        "nome": "Sensores Compartilhados",
        "descr": "Sensores presentes nos dois modelos"
      },
      "texto": "Altímetro barométrico, bússola eletrônica e termômetro — esses três sensores estão presentes em qual relógio?",
      "gabarito": "ambos",
      "acerto": "✅ Exato! Altímetro barométrico, bússola e termômetro estão presentes nos dois modelos. A diferença é que apenas o Instinct 3 possui giroscópio.",
      "erro": "❌ Esses três sensores estão presentes nos dois relógios! A diferença é o giroscópio, que é exclusivo do Instinct 3.",
      "reveal": {
        "i3": "Altímetro baro · bússola · termômetro · <strong>giroscópio ✓</strong>",
        "ie": "Altímetro baro · bússola · termômetro · <strong>sem giroscópio</strong>"
      }
    },
    {
      "cat": {
        "icone": "🔋",
        "nome": "Autonomia em Modo Relógio",
        "descr": "Duração no uso cotidiano como smartwatch"
      },
      "texto": "Em modo smartwatch convencional, qual dos dois dura mais dias sem precisar carregar?",
      "gabarito": "instinct3",
      "acerto": "✅ Correto! Em modo relógio o Instinct 3 chega a 18 dias, contra 16 dias do Instinct E. No modo Economia, porém, o Instinct E vence com até 40 dias contra 24 do Instinct 3.",
      "erro": "❌ No modo smartwatch convencional o Instinct 3 surpreende: até 18 dias contra 16 do Instinct E. O Instinct E leva vantagem em modo Economia (40 dias) e em Expedição GPS (20 vs 16 dias).",
      "reveal": {
        "i3": "Smartwatch: <strong>até 18 dias</strong> ✓ · Always-on: até 7 dias · GPS: até 32h",
        "ie": "Smartwatch: <strong>até 16 dias</strong> · Economia: até 40 dias ✓ · Expedição GPS: 20 dias ✓"
      }
    }
  ],
  "meta": {
    "titulo": "Instinct 3 vs Instinct E",
    "modo": "duelo_1v1",
    "opcoes_resposta": [
      "instinct3",
      "instincte",
      "ambos",
      "nenhum"
    ],
    "rodadas_por_partida": 10,
    "total_perguntas_no_pool": 10
  }
}'::jsonb,
  true
)
on conflict (slug) do nothing;

-- Minigame 2 — MARQ Carbon: Golfer vs Athlete vs Commander (15 perguntas no pool, 10 rodadas por partida)
insert into games (brand_id, slug, title, config, is_published)
values (
  (select id from brands where slug = 'garmin'),
  'duelo-marq',
  'Duelo MARQ Carbon — Trio de Luxo (Golfer vs Athlete vs Commander)',
  '{
  "rounds": [
    {
      "cat": {
        "icone": "⛳",
        "nome": "Conteúdo da Caixa — Sensores de Taco",
        "descr": "Acessório incluído no box"
      },
      "texto": "Qual modelo vem com 3 sensores Approach CT10 de rastreamento de tacos incluídos na caixa?",
      "gabarito": "golfer",
      "acerto": "✅ Correto! O MARQ Golfer é o único que inclui 3 sensores Approach CT10 na caixa. Eles rastreiam qual taco foi usado em cada tacada e ajudam a montar estatísticas de distância por taco.",
      "erro": "❌ É o MARQ Golfer. Ele é o único que vem com 3 sensores Approach CT10 na caixa — uma ferramenta exclusiva para análise de jogo no campo.",
      "reveal": {
        "golfer": "<strong>3 sensores CT10 incluídos</strong> ✓ · rastreamento de taco por tacada",
        "athlete": "Sem sensores CT10 · foco em corrida e treino",
        "commander": "Sem sensores CT10 · foco em uso tático"
      }
    },
    {
      "cat": {
        "icone": "❤️",
        "nome": "Conteúdo da Caixa — Cinta Cardíaca",
        "descr": "Acessório incluído no box"
      },
      "texto": "Qual modelo vem com a cinta cardíaca HRM-Pro Plus incluída na caixa?",
      "gabarito": "athlete",
      "acerto": "✅ Correto! O MARQ Athlete é o único que inclui a cinta HRM-Pro Plus na caixa — a mais completa da linha Garmin, com métricas de dinâmica de corrida e dados de esteira.",
      "erro": "❌ É o MARQ Athlete. Ele vem com a cinta HRM-Pro Plus incluída — a mais completa da linha, com dinâmicas avançadas de corrida.",
      "reveal": {
        "golfer": "Sem cinta cardíaca incluída · foco em golfe",
        "athlete": "<strong>HRM-Pro Plus incluída</strong> ✓ · cinta de alta performance",
        "commander": "Sem cinta cardíaca incluída · foco tático"
      }
    },
    {
      "cat": {
        "icone": "⌚",
        "nome": "Bezel Temático",
        "descr": "Marcações gravadas no aro do relógio"
      },
      "texto": "Qual modelo possui marcações dos buracos 1 a 18 gravadas no bezel?",
      "gabarito": "golfer",
      "acerto": "✅ Correto! O bezel do MARQ Golfer traz as marcações dos buracos 1 a 18 — detalhes que reforçam a identidade do modelo com quem vive no campo.",
      "erro": "❌ É o MARQ Golfer. O bezel dele traz a numeração dos buracos 1 a 18, refletindo a identidade do modelo para o golfista.",
      "reveal": {
        "golfer": "<strong>Marcações dos buracos 1–18</strong> · bezel temático de golfe ✓",
        "athlete": "Marcações de VO₂ máx e tempo de recuperação · bezel esportivo",
        "commander": "Marcações UTC · bezel de navegação tática"
      }
    },
    {
      "cat": {
        "icone": "⌚",
        "nome": "Bezel Temático",
        "descr": "Marcações gravadas no aro do relógio"
      },
      "texto": "Qual modelo possui marcações de VO₂ máx e tempo de recuperação gravadas no bezel?",
      "gabarito": "athlete",
      "acerto": "✅ Correto! O MARQ Athlete tem um bezel focado em performance esportiva — com referências de VO₂ máx e tempo de recuperação, ideal para atletas de alto rendimento.",
      "erro": "❌ É o MARQ Athlete. O bezel dele traz indicadores de VO₂ máx e tempo de recuperação, reforçando o caráter esportivo do modelo.",
      "reveal": {
        "golfer": "Marcações dos buracos 1–18 · bezel de golfe",
        "athlete": "<strong>Marcações de VO₂ máx e recuperação</strong> · bezel esportivo ✓",
        "commander": "Marcações UTC · bezel de navegação tática"
      }
    },
    {
      "cat": {
        "icone": "🎖️",
        "nome": "Funcionalidade Tática — Modo Stealth",
        "descr": "Recursos para uso militar e segurança"
      },
      "texto": "Qual modelo possui Modo Stealth (desativa GPS e transmissão de dados), compatibilidade com óculos de visão noturna e Kill Switch?",
      "gabarito": "commander",
      "acerto": "✅ Correto! Essas três funcionalidades são exclusivas do MARQ Commander — pensadas para operações táticas onde a discrição e a segurança de dados são críticas.",
      "erro": "❌ São exclusividades do MARQ Commander: Modo Stealth, compatibilidade com visão noturna e Kill Switch. Recursos desenvolvidos para operações táticas.",
      "reveal": {
        "golfer": "Sem funcionalidades táticas · foco em campo de golfe",
        "athlete": "Sem funcionalidades táticas · foco em performance esportiva",
        "commander": "<strong>Modo Stealth · Kill Switch · visão noturna</strong> ✓ · uso tático"
      }
    },
    {
      "cat": {
        "icone": "🎯",
        "nome": "Calculadora Balística",
        "descr": "Ferramenta para tiro de longa distância"
      },
      "texto": "Qual modelo inclui o Applied Ballistics Ultralite pré-instalado — calculadora balística para tiro de longa distância?",
      "gabarito": "commander",
      "acerto": "✅ Correto! O MARQ Commander inclui o Applied Ballistics Ultralite, uma ferramenta de altíssima precisão para atiradores de longa distância, com correções de vento, altitude e balística.",
      "erro": "❌ É o MARQ Commander. O Applied Ballistics Ultralite é uma ferramenta exclusiva dele — voltada para atiradores de longa distância com cálculos avançados de trajetória.",
      "reveal": {
        "golfer": "Sem calculadora balística · voltado para golfe",
        "athlete": "Sem calculadora balística · voltado para esporte",
        "commander": "<strong>Applied Ballistics Ultralite incluído</strong> ✓ · tiro de longa distância"
      }
    },
    {
      "cat": {
        "icone": "🪂",
        "nome": "Modo Paraquedismo",
        "descr": "Ferramenta para salto de paraquedas"
      },
      "texto": "Qual modelo possui o Modo Jumpmaster, que calcula o ponto ideal de saída para saltos de paraquedas?",
      "gabarito": "commander",
      "acerto": "✅ Correto! O Modo Jumpmaster é exclusivo do MARQ Commander. Ele calcula a posição de saída para saltos de paraquedas com base em vento, altitude e ponto de pouso desejado.",
      "erro": "❌ É o MARQ Commander. O Modo Jumpmaster — cálculo de ponto de saída para saltos — é uma funcionalidade tática exclusiva desse modelo.",
      "reveal": {
        "golfer": "Sem Modo Jumpmaster · uso civil, campo de golfe",
        "athlete": "Sem Modo Jumpmaster · uso esportivo convencional",
        "commander": "<strong>Modo Jumpmaster incluído</strong> ✓ · salto de paraquedas tático"
      }
    },
    {
      "cat": {
        "icone": "🏌️",
        "nome": "Caddie Digital",
        "descr": "Ferramenta de apoio no jogo de golfe"
      },
      "texto": "Qual modelo inclui o Caddie Virtual com gráfico de dispersão de tacadas e sugestão automática de taco?",
      "gabarito": "golfer",
      "acerto": "✅ Correto! O MARQ Golfer tem o Caddie Virtual — que analisa o histórico de tacadas do jogador e sugere qual taco usar em cada situação, exibindo um gráfico de dispersão personalizado.",
      "erro": "❌ É o MARQ Golfer. O Caddie Virtual com gráfico de dispersão e sugestão de taco é uma funcionalidade exclusiva do modelo voltado para o golfe.",
      "reveal": {
        "golfer": "<strong>Caddie Virtual + gráfico de dispersão</strong> ✓ · sugestão de taco por situação",
        "athlete": "Sem Caddie Virtual · foco em análise de treino esportivo",
        "commander": "Sem Caddie Virtual · foco em navegação e uso tático"
      }
    },
    {
      "cat": {
        "icone": "🗺️",
        "nome": "Mapas Pré-carregados",
        "descr": "Tipo de mapa disponível sem baixar nada"
      },
      "texto": "Mapas TopoActive com trilhas de corrida, ciclismo e caminhadas pré-carregados — em quais modelos esse recurso está disponível?",
      "gabarito": "todos",
      "acerto": "✅ Correto! Os três modelos Carbon Edition têm mapas TopoActive pré-carregados. A diferença é que o MARQ Golfer também inclui mapas CourseView de mais de 42.000 campos de golfe.",
      "erro": "❌ Os mapas TopoActive estão nos três modelos. Todos vêm com trilhas de corrida, ciclismo e caminhadas. O MARQ Golfer ainda acrescenta os mapas CourseView de campos de golfe.",
      "reveal": {
        "golfer": "TopoActive ✓ + <strong>CourseView (+42.000 campos de golfe)</strong>",
        "athlete": "<strong>TopoActive incluído</strong> ✓ · trilhas e rotas outdoor",
        "commander": "<strong>TopoActive incluído</strong> ✓ · trilhas e rotas outdoor"
      }
    },
    {
      "cat": {
        "icone": "🧭",
        "nome": "Grade de Coordenadas Dupla",
        "descr": "Sistema de navegação tática avançada"
      },
      "texto": "Qual modelo suporta exibição simultânea de coordenadas em formato UTM e MGRS (grade militar)?",
      "gabarito": "commander",
      "acerto": "✅ Correto! O MARQ Commander suporta o formato duplo UTM/MGRS, padrão de navegação utilizado por forças militares e operadores táticos em todo o mundo.",
      "erro": "❌ É o MARQ Commander. Ele suporta coordenadas em formato duplo UTM/MGRS — o padrão de navegação tática das forças militares.",
      "reveal": {
        "golfer": "Coordenadas padrão GPS · sem MGRS",
        "athlete": "Coordenadas padrão GPS · sem MGRS",
        "commander": "<strong>UTM + MGRS simultâneo</strong> ✓ · navegação tática de precisão"
      }
    },
    {
      "cat": {
        "icone": "💎",
        "nome": "Base de Hardware",
        "descr": "Especificações compartilhadas pelos três"
      },
      "texto": "Tela AMOLED com lente de safira, caixa de 46mm em Fused Carbon Fiber e bateria de até 16 dias — em qual modelo?",
      "gabarito": "todos",
      "acerto": "✅ Correto! Essas especificações são a base de hardware compartilhada pelos três Carbon Edition. O que diferencia cada modelo são as funcionalidades e acessórios incluídos.",
      "erro": "❌ Essas são as especificações base dos três modelos. AMOLED safira, 46mm, Fused Carbon Fiber e até 16 dias de bateria são comuns ao Golfer, Athlete e Commander.",
      "reveal": {
        "golfer": "AMOLED safira · 46mm · Carbon Fiber · <strong>16 dias ✓</strong>",
        "athlete": "AMOLED safira · 46mm · Carbon Fiber · <strong>16 dias ✓</strong>",
        "commander": "AMOLED safira · 46mm · Carbon Fiber · <strong>16 dias ✓</strong>"
      }
    },
    {
      "cat": {
        "icone": "🧶",
        "nome": "Pulseira Original",
        "descr": "Material da pulseira que acompanha o relógio"
      },
      "texto": "Qual modelo vem com pulseira híbrida de couro FKM perfurado com reforço em borracha?",
      "gabarito": "golfer",
      "acerto": "✅ Correto! O MARQ Golfer vem com pulseira híbrida de couro FKM perfurado — elegante para o ambiente do clube, mas resistente o suficiente para o campo.",
      "erro": "❌ É o MARQ Golfer. A pulseira híbrida de couro FKM perfurado é característica desse modelo — pensada para o ambiente do clube de golfe.",
      "reveal": {
        "golfer": "<strong>Couro FKM perfurado + borracha</strong> ✓ · estilo country club",
        "athlete": "Borracha/silicone de alta performance · focada em treino",
        "commander": "Nylon Jacquard-weave · estilo tático"
      }
    },
    {
      "cat": {
        "icone": "🧶",
        "nome": "Pulseira Original",
        "descr": "Material da pulseira que acompanha o relógio"
      },
      "texto": "Qual modelo vem com pulseira de nylon Jacquard-weave como pulseira original?",
      "gabarito": "commander",
      "acerto": "✅ Correto! O MARQ Commander vem com pulseira de nylon Jacquard-weave — resistente, discreta e de visual tático, coerente com o perfil do modelo.",
      "erro": "❌ É o MARQ Commander. A pulseira de nylon Jacquard-weave é característica desse modelo — textura tática, durável e funcional.",
      "reveal": {
        "golfer": "Couro FKM perfurado + borracha · estilo country club",
        "athlete": "Borracha/silicone de alta performance · focada em treino",
        "commander": "<strong>Nylon Jacquard-weave</strong> ✓ · visual e função táticos"
      }
    },
    {
      "cat": {
        "icone": "🏃",
        "nome": "Conteúdo da Caixa — Pulseira Original",
        "descr": "Material da pulseira que acompanha o modelo esportivo"
      },
      "texto": "Qual modelo vem com pulseira de borracha/silicone de alta performance como pulseira original?",
      "gabarito": "athlete",
      "acerto": "✅ Correto! O MARQ Athlete vem com pulseira de borracha/silicone de alta performance — pensada para treinos intensos, suor e uso esportivo diário.",
      "erro": "❌ É o MARQ Athlete. A pulseira de borracha/silicone de alta performance é o strap original desse modelo — voltado para quem treina com frequência.",
      "reveal": {
        "golfer": "Couro FKM perfurado + borracha · estilo country club",
        "athlete": "<strong>Borracha/silicone de alta performance</strong> ✓ · ideal para treinos",
        "commander": "Nylon Jacquard-weave · estilo tático"
      }
    },
    {
      "cat": {
        "icone": "⌚",
        "nome": "Bezel Temático",
        "descr": "Marcações gravadas no aro do relógio"
      },
      "texto": "Qual modelo possui marcações UTC gravadas no bezel para navegação e operações internacionais?",
      "gabarito": "commander",
      "acerto": "✅ Correto! O MARQ Commander tem marcações UTC no bezel — essenciais para coordenação em operações que envolvem múltiplos fusos horários, como missões militares ou expedições internacionais.",
      "erro": "❌ É o MARQ Commander. As marcações UTC no bezel são exclusivas desse modelo — uma referência de tempo universal para quem opera em múltiplos fusos.",
      "reveal": {
        "golfer": "Marcações dos buracos 1–18 · bezel de golfe",
        "athlete": "Marcações de VO₂ máx e tempo de recuperação · bezel esportivo",
        "commander": "<strong>Marcações UTC</strong> ✓ · navegação e operações internacionais"
      }
    }
  ],
  "meta": {
    "titulo": "MARQ Carbon — Trio de Luxo (Golfer vs Athlete vs Commander)",
    "modo": "duelo_3vias",
    "opcoes_resposta": [
      "golfer",
      "athlete",
      "commander",
      "todos"
    ],
    "rodadas_por_partida": 10,
    "total_perguntas_no_pool": 15
  }
}'::jsonb,
  true
)
on conflict (slug) do nothing;

