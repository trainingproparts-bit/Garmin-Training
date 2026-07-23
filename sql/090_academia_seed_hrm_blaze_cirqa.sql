-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 090: HRM 200/600, Blaze e Cirqa
-- ============================================================================
-- Pedido do usuário (2026-07-22): adicionar HRM 200 e HRM 600 na Academia de
-- Produtos (comparando com HRM-Dual e HRM-Pro Plus, que ainda não são
-- produtos próprios no catálogo — citados como related_label, conforme o
-- padrão já documentado no schema pra conceitos sem página própria), o Blaze
-- (sistema de bem-estar equino, mercado novo pra Garmin) e o Cirqa (pulseira
-- sem tela lançada oficialmente em 21/07/2026, disponível a partir de
-- 24/07/2026 — pesquisado direto no anúncio oficial da Garmin).
--
-- Duas categorias novas: "Acessórios & Sensores" (HRM 200/600 não são
-- relógios nem se encaixam em nenhuma categoria esportiva específica — são
-- cross-sport) e "Linha Equina" (Blaze abre um mercado literalmente novo pra
-- Garmin, sem categoria existente que sirva).
-- ============================================================================

do $$
declare
  v_brand_id      uuid := '2f7d8451-b279-4d69-8192-6ac9953d7da1'; -- garmin
  v_cat_acessorios uuid;
  v_cat_equina     uuid;
  v_cat_lifestyle  uuid;
  v_p_hrm200 uuid;
  v_p_hrm600 uuid;
  v_p_blaze  uuid;
  v_p_cirqa  uuid;
  v_quiz uuid;
  v_q uuid;
begin
  insert into product_categories (brand_id, slug, name, icon, order_index) values
  (v_brand_id, 'acessorios-sensores', 'Acessórios & Sensores', '🔧', 9),
  (v_brand_id, 'linha-equina', 'Linha Equina', '🐴', 10);
  select id into v_cat_acessorios from product_categories where slug = 'acessorios-sensores' and brand_id = v_brand_id;
  select id into v_cat_equina from product_categories where slug = 'linha-equina' and brand_id = v_brand_id;
  select id into v_cat_lifestyle from product_categories where slug = 'lifestyle-bem-estar' and brand_id = v_brand_id;

  insert into products (brand_id, category_id, slug, name, model_code, tagline, price_usd, is_published, order_index) values
  (v_brand_id, v_cat_acessorios, 'hrm-200', 'HRM 200', '010-13755', 'Cinta cardíaca de entrada, bateria de moeda substituível e Bluetooth seguro', 79.99, true, 1),
  (v_brand_id, v_cat_acessorios, 'hrm-600', 'HRM 600', '010-13756', 'Cinta cardíaca com gravação autônoma, bateria recarregável e Step Speed Loss', 169.99, true, 2),
  (v_brand_id, v_cat_equina, 'blaze', 'Blaze', '010-02891', 'Sistema de bem-estar equino: frequência cardíaca, temperatura de pele e passadas do cavalo', 599.99, true, 1),
  (v_brand_id, v_cat_lifestyle, 'cirqa', 'Cirqa', '010-02949', 'Pulseira de bem-estar sem tela, sem assinatura obrigatória, até 10 dias de bateria', 199.99, true, 5);
  select id into v_p_hrm200 from products where slug = 'hrm-200';
  select id into v_p_hrm600 from products where slug = 'hrm-600';
  select id into v_p_blaze from products where slug = 'blaze';
  select id into v_p_cirqa from products where slug = 'cirqa';

  -- ==========================================================================
  -- HRM 200
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_hrm200, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>HRM 200</strong> é a cinta cardíaca de entrada da Garmin: mede frequência cardíaca e HRV em tempo real, transmitindo por ANT+ (conexões ilimitadas) e Bluetooth Low Energy (até 3 dispositivos simultâneos). Usa bateria de moeda CR2032 substituível, com duração de cerca de 1 ano.</p><p><strong>Público-alvo:</strong> quem quer uma leitura de frequência cardíaca mais estável que o sensor óptico de pulso, sem precisar dos recursos avançados (Dinâmica de Corrida, gravação autônoma) das cintas superiores.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Bluetooth seguro", "text": "Evita que a cinta conecte acidentalmente no aparelho errado numa academia cheia de sinais.", "tags": []},
      {"title": "Módulo destacável e lavável", "text": "O sensor sai da cinta de tecido pra lavar na máquina sem estragar o eletrônico.", "tags": []},
      {"title": "Bateria de moeda, cerca de 1 ano", "text": "CR2032 substituível, sem precisar recarregar.", "tags": []},
      {"title": "Duas cintas de tamanho", "text": "XS-S e M-XL, incluídas na caixa.", "tags": []},
      {"title": "3 ATM", "text": "Resiste a suor e chuva, mas não é indicada pra natação.", "tags": []},
      {"title": "ANT+ e Bluetooth simultâneos", "text": "Conecta em relógio, Edge e app de celular ao mesmo tempo.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_hrm200, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Ciclista de indoor (Zwift, apps de treino)", "text": "Quer FC estável no treino indoor sem gastar no topo de linha.", "tags": [{"label": "Indoor", "color": "blue"}]},
      {"title": "Cliente com orçamento mais ajustado", "text": "Primeira cinta cardíaca, sem precisar de Dinâmica de Corrida.", "tags": [{"label": "Custo-benefício", "color": "gold"}]},
      {"title": "Praticante de atividade geral", "text": "Já tem relógio com GPS, só quer FC mais precisa que a leitura óptica.", "tags": [{"label": "Fitness geral", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente só precisa de frequência cardíaca e HRV estáveis, sem métricas de corrida avançadas</li><li>Cliente não vai nadar com a cinta</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer Dinâmica de Corrida, Potência de Corrida ou gravar treino sem relógio → indicar HRM-Pro Plus ou HRM 600</li><li>Cliente pratica natação → o HRM 200 não é resistente a nado (3 ATM só cobre suor/chuva)</li></ul>"}
  ]}
  $j$),
  (v_p_hrm200, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Bluetooth seguro", "html": "<p>Evita que a cinta se conecte acidentalmente a outro aparelho por perto, comum em academias com muita gente treinando ao mesmo tempo.</p>"},
      {"title": "Módulo destacável e lavável", "html": "<p>O sensor eletrônico sai da cinta de tecido, que pode ser lavada na máquina separadamente.</p>"},
      {"title": "Comparado ao HRM-Dual", "html": "<p>O HRM-Dual (cinta simples já existente na linha Garmin) e o HRM 200 têm proposta parecida: FC e HRV via ANT+/Bluetooth, sem Dinâmica de Corrida. O HRM 200 é a atualização mais recente dessa categoria de entrada.</p>"},
      {"title": "Comparado ao HRM-Pro Plus", "html": "<p>O HRM-Pro Plus soma Dinâmica de Corrida (tempo de contato, cadência, oscilação vertical), Potência de Corrida e resistência a natação (5 ATM, com armazenamento offline debaixo d'água) — recursos que o HRM 200 não tem.</p>"},
      {"title": "Não é resistente a natação", "html": "<p>3 ATM cobre suor e chuva, mas não é indicada pra nadar. Pra isso, o cliente precisa do HRM-Pro Plus ou HRM 600 (ambos 5 ATM).</p>"}
    ]}
  ]}
  $j$),
  (v_p_hrm200, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pra quem só quer FC mais precisa", "dialog": "Se o seu relógio já tem tudo que você precisa e só falta uma frequência cardíaca mais estável que o sensor óptico do pulso, o HRM 200 resolve isso com o menor investimento da linha.", "tip": "Bom argumento pra quem não precisa de Dinâmica de Corrida nem gravação autônoma."},
      {"title": "Fechamento", "dialog": "Com o HRM 200 você sai com FC e HRV estáveis, bateria que dura cerca de um ano e Bluetooth seguro pra treinar em academia cheia sem interferência.", "tip": "Se o cliente mencionar natação ou métricas avançadas de corrida, apresente o HRM-Pro Plus ou HRM 600."}
    ]}
  ]}
  $j$),
  (v_p_hrm200, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Meu relógio já mede FC no pulso, pra que uma cinta?", "answer": "A leitura óptica de pulso varia mais em esforço intenso; a cinta pega o sinal elétrico direto do músculo cardíaco, mais estável exatamente quando a intensidade sobe."},
      {"question": "Qual a diferença pro HRM-Pro Plus?", "answer": "O Pro Plus soma Dinâmica de Corrida, Potência de Corrida e resiste à natação. O HRM 200 é só FC e HRV, num preço bem menor."},
      {"question": "Posso nadar com o HRM 200?", "answer": "Não é recomendado — ele é 3 ATM, cobre suor e chuva, mas não é indicado pra nado. Pra isso, o HRM-Pro Plus ou HRM 600 (5 ATM) são as opções certas."}
    ]}
  ]}
  $j$),
  (v_p_hrm200, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Cliente que treina em Zwift ou app indoor", "text": "Quer FC confiável sem pagar pelo topo de linha.", "tags": []},
      {"title": "Primeira cinta cardíaca do cliente", "text": "Entrada acessível pra quem nunca usou cinta antes.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_hrm200, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Qual bateria o HRM 200 usa?", "html": "<p>CR2032, substituível, com duração aproximada de 1 ano.</p>"},
      {"title": "Quantos dispositivos conectam ao mesmo tempo?", "html": "<p>ANT+ aceita conexões ilimitadas; Bluetooth Low Energy aceita até 3 dispositivos simultâneos.</p>"},
      {"title": "O módulo sai da cinta pra lavar?", "html": "<p>Sim, o sensor é destacável e a cinta de tecido pode ser lavada na máquina separadamente.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- HRM 600
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_hrm600, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>HRM 600</strong> é a cinta cardíaca mais avançada da Garmin em um ponto específico: grava atividade de forma <strong>autônoma</strong>, sem precisar de relógio nem celular por perto, guardando até 24 horas de uma sessão em mais de 18 modalidades esportivas. Usa bateria recarregável (cerca de 2 meses de uso a 1h por dia) em vez de bateria de moeda.</p><p><strong>Público-alvo:</strong> atleta de esporte coletivo que treina sem levar o relógio no pulso, ou quem simplesmente quer registrar o treino direto pela cinta.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Gravação autônoma", "text": "Registra o treino sozinha, sem depender de relógio ou celular por perto.", "tags": []},
      {"title": "Step Speed Loss", "text": "Métrica exclusiva de eficiência de corrida, mostrando perda de velocidade por passada.", "tags": []},
      {"title": "Bateria recarregável", "text": "Cerca de 2 meses de uso a 1h por dia, sem trocar bateria de moeda.", "tags": []},
      {"title": "5 ATM", "text": "Resistente à natação, com módulo destacável e lavável.", "tags": []},
      {"title": "Atualização de firmware sem fio", "text": "Recebe melhorias direto, sem precisar de cabo.", "tags": []},
      {"title": "Bluetooth seguro", "text": "Evita conexão acidental com aparelho errado.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_hrm600, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Atleta de esporte coletivo", "text": "Treina sem relógio no pulso e quer registrar a sessão mesmo assim.", "tags": [{"label": "Esporte coletivo", "color": "blue"}]},
      {"title": "Quem quer treinar sem depender do celular por perto", "text": "A gravação autônoma libera o atleta de levar mais aparelho.", "tags": [{"label": "Autonomia", "color": "green"}]},
      {"title": "Corredor técnico buscando eficiência", "text": "Usa o Step Speed Loss pra refinar a técnica de passada.", "tags": [{"label": "Performance", "color": "gold"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente quer gravar treino sem levar relógio ou celular</li><li>Cliente pratica esporte coletivo (futebol, basquete) sem relógio de pulso durante o jogo</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente sempre usa o relógio no pulso durante o treino e não precisa de gravação autônoma → HRM-Pro Plus já cobre bem, com Dinâmica de Corrida completa e preço menor</li></ul>"}
  ]}
  $j$),
  (v_p_hrm600, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Gravação autônoma (até 24h, 18+ modalidades)", "html": "<p>A cinta grava o treino sozinha, sem precisar de relógio nem celular por perto durante a atividade — depois sincroniza com o Garmin Connect.</p>"},
      {"title": "Step Speed Loss", "html": "<p>Métrica exclusiva do HRM 600 que mostra a perda de velocidade por passada, um indicador de eficiência de corrida que nenhuma outra cinta Garmin calcula.</p>"},
      {"title": "Bateria recarregável", "html": "<p>Cerca de 2 meses de uso a 1h por dia — diferente do HRM 200 e HRM-Pro Plus, que usam bateria de moeda substituível.</p>"},
      {"title": "5 ATM, resistente à natação", "html": "<p>Módulo destacável e lavável, resistente o suficiente pra nadar.</p>"},
      {"title": "Comparado ao HRM-Pro Plus", "html": "<p>O Pro Plus soma Dinâmica de Corrida completa (tempo de contato, cadência, oscilação vertical) e Potência de Corrida, mas não grava atividade sozinho. O HRM 600 é o único com gravação autônoma e Step Speed Loss, mas sem o pacote completo de Dinâmica de Corrida do Pro Plus.</p>"}
    ]}
  ]}
  $j$),
  (v_p_hrm600, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pra atleta de esporte coletivo", "dialog": "Se você joga futebol ou outro esporte coletivo sem levar relógio no pulso durante o jogo, o HRM 600 grava o treino inteiro sozinho, e você sincroniza tudo depois.", "tip": "Bom gancho pra quem já reclamou de não conseguir registrar o jogo por não usar relógio em campo."},
      {"title": "Puxando o Step Speed Loss pro corredor técnico", "dialog": "Pra quem já treina forma de corrida, o HRM 600 tem uma métrica exclusiva, Step Speed Loss, que mostra exatamente onde você perde velocidade em cada passada.", "tip": "Bom argumento pra corredor mais técnico, não tanto pra iniciante."},
      {"title": "Fechamento", "dialog": "Com o HRM 600 você sai com gravação autônoma, bateria recarregável e uma métrica de eficiência que nenhuma outra cinta Garmin tem.", "tip": "Se o cliente sempre usa relógio no pulso e não precisa gravar sozinho, o HRM-Pro Plus é mais barato e já cobre bem."}
    ]}
  ]}
  $j$),
  (v_p_hrm600, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Por que pagar mais no HRM 600 se já tenho relógio?", "answer": "Se você sempre usa o relógio no pulso, o HRM-Pro Plus já entrega Dinâmica de Corrida completa por menos. O HRM 600 vale a diferença pra quem quer gravar sem relógio, como em esporte coletivo, ou quer o Step Speed Loss."},
      {"question": "A bateria recarregável não é pior que a de moeda?", "answer": "É uma troca: dura menos tempo entre cargas (cerca de 2 meses contra ~1 ano da bateria de moeda), mas nunca precisa comprar bateria nova, e carrega rápido."},
      {"question": "O que é Step Speed Loss?", "answer": "É uma métrica exclusiva do HRM 600 que mostra a perda de velocidade em cada passada, ajudando o corredor a identificar onde a técnica está perdendo eficiência."}
    ]}
  ]}
  $j$),
  (v_p_hrm600, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Jogador de futebol amador", "text": "Quer registrar o jogo sem usar relógio em campo.", "tags": []},
      {"title": "Corredor técnico buscando eficiência", "text": "Usa Step Speed Loss pra refinar a passada.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_hrm600, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Quanto dura a bateria do HRM 600?", "html": "<p>Cerca de 2 meses de uso a 1 hora por dia, recarregável.</p>"},
      {"title": "Quanto tempo de treino ele grava sozinho?", "html": "<p>Até 24 horas por sessão, em mais de 18 modalidades esportivas.</p>"},
      {"title": "Dá pra nadar com o HRM 600?", "html": "<p>Sim, é 5 ATM, resistente à natação.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- BLAZE (bem-estar equino)
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_blaze, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Blaze</strong> é a entrada da Garmin num mercado totalmente novo: bem-estar equino. É um sensor removível encaixado numa manga de neoprene, presa na base da parte de baixo do rabo do cavalo, sem precisar de nenhum preparo especial na pele do animal.</p><p><strong>Frase oficial da Garmin</strong> (Susan Lyman, VP de Vendas e Marketing ao Consumidor): \"a Garmin é líder mundial em saúde e fitness, e estamos animados em trazer nossos dados avançados de sensor e tecnologia pro mercado equino com a introdução do Blaze\".</p><p><strong>Público-alvo:</strong> cavaleiros, treinadores e proprietários que já usam tecnologia de treino em si mesmos e agora querem monitorar a saúde do cavalo com o mesmo padrão.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Frequência cardíaca do cavalo", "text": "Monitorada em tempo real durante treino e transporte.", "tags": []},
      {"title": "Passadas e análise de marcha", "text": "Acompanha o movimento do animal ao longo da atividade.", "tags": []},
      {"title": "Temperatura de pele", "text": "Acompanha variações médias de temperatura.", "tags": []},
      {"title": "Heat Score", "text": "Orientação de segurança pra decidir se é seguro montar, com base em temperatura e umidade do ar.", "tags": []},
      {"title": "Até 25h de bateria", "text": "Sensor recarregável, removível pra limpeza e recarga.", "tags": []},
      {"title": "Perfis por cavalo", "text": "Cadastra vários cavalos separadamente no mesmo app.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_blaze, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Proprietário de cavalo de esporte", "text": "Já monitora o próprio treino e quer o mesmo padrão pro animal.", "tags": [{"label": "Esporte equestre", "color": "gold"}]},
      {"title": "Treinador com múltiplos cavalos", "text": "Usa perfis individuais pra acompanhar vários animais.", "tags": [{"label": "Profissional", "color": "blue"}]},
      {"title": "Cavaleiro preocupado com segurança em dias quentes", "text": "Usa o Heat Score antes de decidir montar.", "tags": [{"label": "Segurança", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente já é cavaleiro/proprietário e demonstra preocupação com saúde e recuperação do animal</li><li>Cliente treina ou compete em clima quente e valoriza uma orientação objetiva de segurança</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente não tem cavalo próprio nem acesso regular a um animal pra monitorar</li></ul>"}
  ]}
  $j$),
  (v_p_blaze, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Heat Score", "html": "<p>Orientação de segurança que combina temperatura do ar e umidade, ajudando a decidir se é seguro montar naquele momento.</p>"},
      {"title": "Perfis individuais por cavalo", "html": "<p>O mesmo conjunto de wrap e sensor pode ser usado em cavalos diferentes, cada um com seu próprio perfil salvo no app.</p>"},
      {"title": "Blaze Connect IQ", "html": "<p>App específico que roda em relógios Garmin compatíveis, mostrando os dados do cavalo direto no pulso do cavaleiro, além do app de celular.</p>"},
      {"title": "Sensor removível e recarregável", "html": "<p>Até 25 horas de bateria, sai da manga de neoprene facilmente pra limpar e recarregar.</p>"},
      {"title": "Sem preparo especial na pele do animal", "html": "<p>A manga simplesmente enrola na base do rabo, encaixando o sensor contra a parte de baixo, sem precisar tosquiar pelo ou aplicar gel.</p>"}
    ]}
  ]}
  $j$),
  (v_p_blaze, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pra quem já monitora o próprio treino", "dialog": "Você já usa tecnologia pra acompanhar o seu treino, né? O Blaze traz esse mesmo padrão de dado pro seu cavalo: frequência cardíaca, temperatura de pele e até uma pontuação de segurança pra dias quentes.", "tip": "Bom gancho pra cliente que já é usuário Garmin em outro produto."},
      {"title": "Puxando o Heat Score em clima quente", "dialog": "Uma coisa que chama atenção é o Heat Score: ele calcula, com base na temperatura e umidade do dia, se é seguro montar naquele momento, tirando a decisão do feeling.", "tip": "Ótimo argumento em regiões ou épocas de calor intenso."},
      {"title": "Fechamento", "dialog": "O Blaze sai da manga fácil pra recarregar e limpar, aguenta até 25 horas de uso, e você pode cadastrar mais de um cavalo no mesmo app se precisar.", "tip": "Reforce que não precisa de preparo especial no animal pra instalar."}
    ]}
  ]}
  $j$),
  (v_p_blaze, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "R$ 599,99 não é caro pra um acessório de cavalo?", "answer": "Compare com o que ele substitui: monitoramento manual de frequência cardíaca, avaliação visual de calor e cansaço, tudo isso automatizado e registrado historicamente num app. Pra quem treina ou compete com regularidade, é um investimento em segurança e desempenho do animal."},
      {"question": "Machuca ou incomoda o cavalo?", "answer": "Não é necessário nenhum preparo especial na pele; a manga de neoprene simplesmente enrola na base do rabo, sem precisar tosquiar pelo ou usar gel."},
      {"question": "Funciona sem relógio Garmin?", "answer": "Sim, funciona pelo app Blaze no celular. O app Blaze Connect IQ no relógio é um recurso a mais, não um requisito."}
    ]}
  ]}
  $j$),
  (v_p_blaze, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Treinador com vários cavalos em preparação", "text": "Usa perfis individuais pra acompanhar cada animal separadamente.", "tags": []},
      {"title": "Cavaleiro competindo em clima quente", "text": "Usa o Heat Score pra decidir com segurança se é hora de montar.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_blaze, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Quanto dura a bateria do sensor?", "html": "<p>Até 25 horas, e o sensor é removível pra recarregar e limpar.</p>"},
      {"title": "Serve pra qualquer tamanho de cavalo?", "html": "<p>A manga do Blaze é feita pra rabos com circunferência de 7,5 a 11 polegadas na base — confirme essa medida antes de vender.</p>"},
      {"title": "Precisa de assinatura?", "html": "<p>Não, o app Blaze acompanha o produto sem custo de assinatura pra funções básicas.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- CIRQA (pulseira sem tela)
  -- ==========================================================================
  insert into product_sections (product_id, section_type, payload) values
  (v_p_cirqa, 'visao_geral', $j$
  {"blocks": [
    {"type": "texto_rico", "html": "<p>O <strong>Cirqa</strong> é a pulseira de bem-estar sem tela da Garmin, anunciada oficialmente em 21 de julho de 2026 e disponível pra compra a partir de 24 de julho de 2026. Usa sensor óptico Elevate Gen 4 e Pulse Ox, num corpo de 27x47x9mm e cerca de 21g, com resistência 5 ATM (dá pra nadar).</p><p><strong>Diferencial de posicionamento:</strong> ao contrário de concorrentes do mesmo segmento sem tela, o Cirqa não exige assinatura pra usar os recursos principais do Garmin Connect — só o Connect+ (opcional) adiciona treinos guiados e coaching.</p>"},
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Sem tela, um botão físico", "text": "Design minimalista, com pulseira de tecido ComfortFit.", "tags": []},
      {"title": "Sem assinatura obrigatória", "text": "Recursos principais do Garmin Connect vêm inclusos, sem mensalidade.", "tags": []},
      {"title": "Até 10 dias de bateria", "text": "Carregador proprietário da Garmin.", "tags": []},
      {"title": "80+ atividades", "text": "Corrida, ciclismo, yoga e mais, controladas pelo botão ou pelo app.", "tags": []},
      {"title": "Usa no pulso ou no braço", "text": "Design versátil, com alça de tecido.", "tags": []},
      {"title": "5 ATM", "text": "Resistente o suficiente pra nadar.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_cirqa, 'personas', $j$
  {"blocks": [
    {"type": "card_grid", "columns": 3, "items": [
      {"title": "Quem quer monitorar saúde sem outro relógio no pulso", "text": "Já usa um relógio comum ou não quer tela, só quer os dados de bem-estar.", "tags": [{"label": "Minimalista", "color": "blue"}]},
      {"title": "Cliente comparando com bandas sem tela da concorrência", "text": "Quer o mesmo conceito, mas sem assinatura mensal obrigatória.", "tags": [{"label": "Custo-benefício", "color": "gold"}]},
      {"title": "Quem quer entrar no ecossistema Garmin por um preço menor", "text": "Não precisa do relógio completo pra começar a acompanhar treino e sono.", "tags": [{"label": "Entrada", "color": "green"}]}
    ]},
    {"type": "banner", "tone": "success", "text": "<strong>Quando indicar:</strong><ul><li>Cliente já usa ou está comparando com bandas sem tela de bem-estar (tipo Whoop) e valoriza não pagar assinatura obrigatória</li><li>Cliente quer entrar no ecossistema Garmin sem o investimento de um relógio completo</li></ul>"},
    {"type": "banner", "tone": "warning", "text": "<strong>Quando não indicar:</strong><ul><li>Cliente quer ver dados na tela durante o treino, sem depender do celular → um Forerunner básico atende melhor</li><li>Cliente quer ECG ou o sensor Elevate Gen 5 mais recente → o Cirqa usa Gen 4, sem ECG</li></ul>"}
  ]}
  $j$),
  (v_p_cirqa, 'diferenciais', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Sem assinatura obrigatória", "html": "<p>Diferente de concorrentes do mesmo conceito (banda sem tela), os recursos principais do Garmin Connect vêm inclusos sem mensalidade. O Connect+ é opcional, pra quem quer treinos guiados e coaching extra.</p>"},
      {"title": "Métricas de bem-estar completas", "html": "<p>Mesmo sem tela, calcula Training Readiness, VO2 Max, HRV Status, Body Battery, estresse o dia todo, respiração, Fitness Age, FC de repouso e sono com Sleep Coach.</p>"},
      {"title": "Modo cadeira de rodas", "html": "<p>Detecção de impulso pra quem usa cadeira de rodas, adaptando o cálculo de atividade.</p>"},
      {"title": "GPS conectado via celular", "html": "<p>Não tem GPS próprio; usa o GPS do celular pareado durante atividades ao ar livre.</p>"},
      {"title": "Sensor Elevate Gen 4, sem ECG", "html": "<p>Usa a geração anterior do sensor óptico (não o Gen 5 mais recente) e não tem ECG — diferença importante se o cliente comparar com o Venu ou Fenix.</p>"}
    ]}
  ]}
  $j$),
  (v_p_cirqa, 'scripts_venda', $j$
  {"blocks": [
    {"type": "roteiro", "steps": [
      {"title": "Abertura pra quem já considera uma banda sem tela", "dialog": "Se você já está olhando uma pulseira de bem-estar sem tela, o Cirqa entrega os mesmos dados de recuperação e treino, mas sem te prender numa assinatura mensal obrigatória pra usar o básico.", "tip": "Bom gancho pra quem já mencionou marcas concorrentes desse segmento."},
      {"title": "Fechamento", "dialog": "Com o Cirqa você sai com até 10 dias de bateria, mais de 80 atividades reconhecidas, e todos os principais dados de recuperação do ecossistema Garmin, sem mensalidade obrigatória.", "tip": "Se o cliente quer ver dado na tela durante o treino, redirecione pra um Forerunner básico."}
    ]}
  ]}
  $j$),
  (v_p_cirqa, 'objecoes', $j$
  {"blocks": [
    {"type": "objecao", "items": [
      {"question": "Como eu vejo meus dados sem tela?", "answer": "Todos os dados ficam disponíveis no app Garmin Connect no celular; o botão físico serve pra iniciar/pausar atividades e navegar por opções simples direto na pulseira."},
      {"question": "É verdade que não precisa de assinatura?", "answer": "Sim, os recursos principais do Garmin Connect (Training Readiness, VO2 Max, sono, estresse e mais) vêm inclusos sem mensalidade. Só o Connect+ opcional adiciona treinos guiados e coaching."},
      {"question": "Qual a diferença pra um relógio Garmin comum?", "answer": "O Cirqa não tem tela nem GPS próprio (usa o do celular pareado), e o sensor óptico é uma geração anterior (Elevate Gen 4, sem ECG). Em troca, é mais discreto e mais barato que um relógio completo."}
    ]}
  ]}
  $j$),
  (v_p_cirqa, 'casos_uso', $j$
  {"blocks": [
    {"type": "banner", "tone": "info", "text": "Cenários típicos de atendimento (ilustrativos, pra treinar a abordagem — não são depoimentos reais de clientes)."},
    {"type": "card_grid", "columns": 2, "items": [
      {"title": "Cliente comparando com banda sem tela da concorrência", "text": "Valoriza não pagar assinatura obrigatória pra ver os dados básicos.", "tags": []},
      {"title": "Cliente que quer só monitorar sono e recuperação", "text": "Não precisa de GPS na tela nem de treino estruturado, só dados de bem-estar.", "tags": []}
    ]}
  ]}
  $j$),
  (v_p_cirqa, 'faq', $j$
  {"blocks": [
    {"type": "accordion", "items": [
      {"title": "Quanto dura a bateria do Cirqa?", "html": "<p>Até 10 dias, com carregador proprietário da Garmin.</p>"},
      {"title": "Dá pra nadar com o Cirqa?", "html": "<p>Sim, é 5 ATM.</p>"},
      {"title": "Quais as cores e tamanhos disponíveis?", "html": "<p>Preto, French Gray, berry e navy, em tamanhos S/M e L/XL. A pulseira de reposição custa US$ 49,99.</p>"}
    ]}
  ]}
  $j$);

  -- ==========================================================================
  -- Quizzes Especialistas
  -- ==========================================================================
  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-hrm-200', 'Quiz Especialista: HRM 200', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Que tipo de bateria o HRM 200 usa?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Bateria de moeda CR2032, substituível', true, 1), (v_q, 'Bateria recarregável', false, 2), (v_q, 'Não usa bateria', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O HRM 200 é indicado pra natação?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não, é 3 ATM, só cobre suor e chuva', true, 1), (v_q, 'Sim, é 5 ATM', false, 2), (v_q, 'Sim, mas só em piscina', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que o HRM-Pro Plus tem que o HRM 200 não tem?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Dinâmica de Corrida e Potência de Corrida', true, 1), (v_q, 'Bateria de moeda', false, 2), (v_q, 'Bluetooth seguro', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-hrm-600', 'Quiz Especialista: HRM 600', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que torna o HRM 600 único entre as cintas Garmin?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Gravação autônoma de atividade, sem precisar de relógio ou celular', true, 1), (v_q, 'Ser a cinta mais barata da linha', false, 2), (v_q, 'Não precisar de bateria', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que é Step Speed Loss?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Métrica exclusiva que mostra a perda de velocidade por passada', true, 1), (v_q, 'O tempo de vida da bateria', false, 2), (v_q, 'A distância total da corrida', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Quanto tempo dura a bateria recarregável do HRM 600?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Cerca de 2 meses, a 1h de uso por dia', true, 1), (v_q, 'Cerca de 1 ano', false, 2), (v_q, 'Cerca de 1 semana', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-blaze', 'Quiz Especialista: Blaze', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Onde o sensor do Blaze é posicionado no cavalo?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Numa manga de neoprene na base do rabo', true, 1), (v_q, 'No pescoço', false, 2), (v_q, 'Na sela', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O que é o Heat Score do Blaze?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Orientação de segurança pra montar, baseada em temperatura e umidade', true, 1), (v_q, 'A temperatura corporal do cavaleiro', false, 2), (v_q, 'Um alerta de bateria fraca', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Quanto dura a bateria do sensor Blaze?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Até 25 horas', true, 1), (v_q, 'Até 90 horas', false, 2), (v_q, 'Até 5 horas', false, 3), (v_q, 'Não sei', false, 4);

  insert into quizzes (brand_id, slug, title, passing_score_pct, is_published)
  values (v_brand_id, 'quiz-especialista-cirqa', 'Quiz Especialista: Cirqa', 70, true) returning id into v_quiz;
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Cirqa exige assinatura pra usar os recursos principais?', 1) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não, só o Connect+ opcional adiciona treinos guiados extras', true, 1), (v_q, 'Sim, assinatura obrigatória', false, 2), (v_q, 'Só depois de 30 dias', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'O Cirqa tem GPS próprio?', 2) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Não, usa o GPS do celular pareado', true, 1), (v_q, 'Sim, GPS multibanda embutido', false, 2), (v_q, 'Sim, mas só em modo economia', false, 3), (v_q, 'Não sei', false, 4);
  insert into questions (quiz_id, body, order_index) values (v_quiz, 'Qual sensor óptico o Cirqa usa?', 3) returning id into v_q;
  insert into alternatives (question_id, body, is_correct, order_index) values
    (v_q, 'Elevate Gen 4, sem ECG', true, 1), (v_q, 'Elevate Gen 5, com ECG', false, 2), (v_q, 'Não tem sensor óptico', false, 3), (v_q, 'Não sei', false, 4);

  insert into product_quizzes (product_id, quiz_id)
  select id, (select id from quizzes where slug = 'quiz-especialista-hrm-200') from products where slug = 'hrm-200'
  union all
  select id, (select id from quizzes where slug = 'quiz-especialista-hrm-600') from products where slug = 'hrm-600'
  union all
  select id, (select id from quizzes where slug = 'quiz-especialista-blaze') from products where slug = 'blaze'
  union all
  select id, (select id from quizzes where slug = 'quiz-especialista-cirqa') from products where slug = 'cirqa';

  insert into badges (brand_id, slug, title, description, rule) values
  (v_brand_id, 'especialista-hrm-200-garmin', 'Especialista HRM 200', 'Concedido ao passar no Quiz Especialista do HRM 200.', '{"tipo": "quiz_especialista_produto", "produto": "hrm-200"}'),
  (v_brand_id, 'especialista-hrm-600-garmin', 'Especialista HRM 600', 'Concedido ao passar no Quiz Especialista do HRM 600.', '{"tipo": "quiz_especialista_produto", "produto": "hrm-600"}'),
  (v_brand_id, 'especialista-blaze-garmin', 'Especialista Blaze', 'Concedido ao passar no Quiz Especialista do Blaze.', '{"tipo": "quiz_especialista_produto", "produto": "blaze"}'),
  (v_brand_id, 'especialista-cirqa-garmin', 'Especialista Cirqa', 'Concedido ao passar no Quiz Especialista do Cirqa.', '{"tipo": "quiz_especialista_produto", "produto": "cirqa"}');

  -- ==========================================================================
  -- Grafo de conhecimento — relacionados (Dual e Pro Plus ainda não são
  -- produtos próprios, entram como related_label informativo)
  -- ==========================================================================
  insert into product_relationships (product_id, related_product_id, related_label, relationship_type, order_index) values
  (v_p_hrm200, v_p_hrm600, null, 'upgrade', 1),
  (v_p_hrm200, null, 'HRM-Dual', 'equivalente', 2),
  (v_p_hrm200, null, 'HRM-Pro Plus', 'upgrade', 3),
  (v_p_hrm600, v_p_hrm200, null, 'entrada', 1),
  (v_p_hrm600, null, 'HRM-Pro Plus', 'alternativo', 2);
end $$;

-- ============================================================================
-- FIM DA MIGRAÇÃO 090
-- ============================================================================
