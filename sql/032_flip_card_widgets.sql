-- ============================================================================
-- GARMIN TRAINING HUB — 032: CARDS GIRATÓRIOS (FLIP) NOS 3 PONTOS ORIGINAIS
-- ============================================================================
-- 028/029/030 tinham achatado os flip-cards do protótipo original (clique
-- para virar e ver o verso) em card_grid/roteiro estáticos — perdendo a
-- interação. Este arquivo introduz o novo tipo de bloco `flip_card`
-- (ContentBlocks.js) e reconstrói os 3 pontos que usavam flip-cards no
-- protótipo, com o MESMO texto já usado nas migrações anteriores:
--
--   1. content_library / novidades-2026-forerunner-70-170 — Forerunner 70
--      e 170 (.cfi original, dentro de payload.blocks — este artigo não usa
--      abas, ao contrário de inReach/Edge/Apps em 029).
--   2. lessons / Garmin Connect / "Estudo de caso: aplicando os recursos
--      com 4 perfis de cliente" — Ana/Rafael/Cláudia/Bruno (.cfi original).
--   3. lessons / Garmin Coach / "Modalidades e especialistas..." — os 3
--      treinadores de corrida Galloway/Amy/McMillan (.trainer-card original).
-- ============================================================================

-- ============================================================================
-- 1. NOVIDADES 2026 — content_library
-- ============================================================================
update content_library
set payload = jsonb_set(payload, '{blocks}', $b1$
[
  {"type":"texto_rico","html":"<p>Os dois lançamentos de 2026 na linha Forerunner. Toque no card para ver a comparação com o modelo anterior.</p>"},
  {"type":"flip_card","columns":2,"cards":[
    {"emoji":"⌚","title":"Forerunner 70","subtitle":"Entrada Compacta · GPS Running · Novo 2026","frontText":"<ul><li>GPS com suporte multissistema (GNSS)</li><li>Sensor cardíaco óptico integrado</li><li>Até 11 dias de bateria (smartwatch)</li><li>Garmin Pay — pagamento pelo relógio</li><li>Body Battery + monitoramento de sono</li><li>Design leve e compacto no pulso</li><li>Indicado: iniciante, presente, casual</li></ul>","backLabel":"FR70 vs Forerunner 55","backText":"<ul><li><strong>Garmin Pay:</strong> FR55 não tinha → FR70 tem incluído</li><li><strong>Bateria:</strong> FR55 ~10 dias → FR70 até 11 dias</li><li><strong>Design:</strong> FR55 padrão → FR70 mais leve e compacto</li><li><strong>Sensor cardíaco:</strong> FR55 Gen 3 → FR70 atualizado</li></ul><p><em>\"O FR70 é o companheiro perfeito pra quem está começando — GPS, frequência cardíaca, até 11 dias de bateria e ainda tem Garmin Pay. Tudo que precisa, no tamanho certo.\"</em></p>"},
    {"emoji":"⌚","title":"Forerunner 170","subtitle":"AMOLED · Compacto · Novo 2026","frontText":"<ul><li>Tela AMOLED + design menor que o FR165</li><li>Sensor Elevate Gen 4</li><li>Relatório noturno + despertador inteligente</li><li>Registro de estilo de vida no relógio</li><li>App de calculadora nativa integrada</li><li>Mais perfis de atividade que o FR165</li><li>⚠️ Sem GPS multibanda · Sem triathlon</li></ul>","backLabel":"FR170 vs Forerunner 165","backText":"<ul><li><strong>Sensor cardíaco:</strong> mesmo Elevate Gen 4</li><li><strong>Tamanho:</strong> FR165 maior → FR170 mais compacto</li><li><strong>Relatório noturno:</strong> FR165 não tinha → FR170 tem</li><li><strong>Despertador inteligente:</strong> FR165 não tinha → FR170 tem</li><li><strong>Perfis de atividade:</strong> FR165 menos → FR170 mais perfis incluídos</li></ul><p><em>\"O FR170 é menor, tem sensor de FC melhorado e recursos de software mais novos como relatório noturno e despertador inteligente. Se quer multiesporte ou GPS multibanda, o 265 é o próximo passo.\"</em></p>"}
  ]},
  {"type":"banner","tone":"info","text":"<strong>Quando indicar o FR70?</strong> Iniciante, presente, cliente que nunca usou GPS e quer começar simples. <strong>Quando indicar o FR170?</strong> Corredor que quer algo mais compacto que o FR165, com recursos de software mais recentes (relatório noturno, despertador inteligente) e mais perfis de atividade — mas que não precisa de GPS multibanda nem multiesporte. Para multiesporte ou GPS multibanda, o FR265 em diante."}
]
$b1$::jsonb)
where slug = 'novidades-2026-forerunner-70-170';

-- ============================================================================
-- 2. GARMIN CONNECT — "Estudo de caso: aplicando os recursos com 4 perfis de cliente"
-- ============================================================================
update lessons set body = jsonb_build_object('blocks', $b2$
[
  {"type":"texto_rico","html":"<h3>Como usar este estudo de caso</h3><p>A ideia aqui é sair sabendo ligar recurso a benefício real para o cliente, entendendo por que aquela função faz diferença naquele caso específico. Toque em cada card para ver o roteiro de apresentação sugerido no Garmin Connect. Se possível, pratique em dupla: um lê os passos, o outro navega no app de verdade.</p>"},
  {"type":"flip_card","columns":2,"cards":[
    {"emoji":"👩","title":"Ana, 34 anos","subtitle":"Home office, São Paulo","frontText":"<p>Mãe de dois filhos, trabalha em casa o dia todo. Percebeu que fica sentada demais e quer começar a se mover, sem pressão e sem metas absurdas. Nunca praticou esporte com regularidade.</p><p><strong>Métricas mais relevantes:</strong> Body Battery, Passos, Estresse e Sono.</p>","backLabel":"Roteiro sugerido","backText":"<ol><li>Abra o app e mostre o Body Battery, explicando que o número representa a energia disponível naquele momento.</li><li>Abra o gráfico de estresse do dia, identifique um pico e ligue isso ao ritmo de trabalho dela (reuniões, prazos, e-mails).</li><li>Configure a meta de passos em 6.000, um valor realista para começar, e mostre o alerta de sedentarismo do relógio.</li><li>Abra o Sleep Score e mostre que dormir mal resulta em Body Battery baixo no dia seguinte.</li><li>Para fechar, acesse o Monitoramento de Hábitos e mostre o calendário visual de consistência do mês.</li></ol>"},
    {"emoji":"🏃","title":"Rafael, 28 anos","subtitle":"Academia 4x/semana, São Paulo","frontText":"<p>Malha com frequência e quer evoluir para a corrida de rua. Entende de treino, mas nunca usou dados avançados. Quer treinar melhor, não só treinar mais.</p><p><strong>Métricas mais relevantes:</strong> Minutos de Intensidade, HRV Status e Status de Treinamento.</p>","backLabel":"Roteiro sugerido","backText":"<ol><li>Abra uma atividade já registrada e mostre o gráfico de frequência cardíaca por zona ao longo do treino.</li><li>Acesse Minutos de Intensidade e compare com a meta semanal da OMS, de 150 minutos.</li><li>Vá ao Status de Treinamento e explique cada classificação (produtivo, descansado, sobrecarregado).</li><li>Acesse o HRV Status semanal e explique que variabilidade alta indica boa recuperação, enquanto variabilidade baixa indica que o corpo está pedindo uma pausa.</li><li>Para fechar, mostre o gasto calórico e sugira a integração com o MyFitnessPal para fechar o ciclo de nutrição.</li></ol>"},
    {"emoji":"💼","title":"Cláudia, 42 anos","subtitle":"Executiva, viaja com frequência","frontText":"<p>Agenda lotada, viagens frequentes, pouco tempo para descansar. Quer saber se está se recuperando entre os compromissos. Aprecia praticidade: quer pagar o café pós-treino sem carteira e correr no hotel sem celular.</p><p><strong>Métricas mais relevantes:</strong> Body Battery, Garmin Pay e Música.</p>","backLabel":"Roteiro sugerido","backText":"<ol><li>Abra o Sleep Score de uma noite de viagem e compare com uma noite em casa, mostrando o impacto no Body Battery.</li><li>Compare o Body Battery de um dia tranquilo com um dia cheio de reuniões, mostrando em que momento a energia cai.</li><li>Abra o gráfico de estresse e identifique o horário de pico, ligando isso ao momento de mais compromissos.</li><li>Acesse o Garmin Pay no app, mostre o cadastro do cartão e o PIN, e simule um pagamento de café pós-treino só com o relógio.</li><li>Para fechar, mostre como sincronizar uma playlist do Spotify para ela correr no hotel sem celular e sem internet.</li></ol>"},
    {"emoji":"👴","title":"Bruno, 55 anos","subtitle":"Aposentado, São Paulo","frontText":"<p>Aposentou há 6 meses. O médico pediu atividade física leve para controlar a pressão. Nunca praticou esporte, tem resistência à tecnologia, mas foi convencido pelo filho a experimentar.</p><p><strong>Métricas mais relevantes:</strong> Batimento Cardíaco, SpO2, Passos e Sono.</p>","backLabel":"Roteiro sugerido","backText":"<ol><li>Mostre o batimento cardíaco em repouso, explicando o que é um valor saudável e por que acompanhar a tendência semanal importa.</li><li>Acesse o Sleep Score junto com o SpO2 e explique de forma simples que, se essa linha cair muito, vale conversar com o médico.</li><li>Configure a meta de passos em 5.000, reforçando que o objetivo é consistência, não velocidade.</li><li>Ative os lembretes de hidratação e mostre como registrar o consumo de água em dois toques no relógio.</li><li>Para fechar, mostre o histórico semanal de passos e sono em gráfico, explicando que o médico consegue acompanhar essa evolução junto com ele.</li></ol>"}
  ]}
]
$b2$::jsonb)
where id = '8a6d87d8-7d9b-4afa-9643-7ffebb12cde5';

-- ============================================================================
-- 3. GARMIN COACH — "Modalidades e especialistas: corrida, ciclismo, força e triatlo"
-- ============================================================================
update lessons set body = jsonb_build_object('blocks', $b3$
[
  {"type":"texto_rico","html":"<h3>Corrida</h3><p>Dentro da modalidade de corrida existem dois caminhos. O Run Coach oferece treinos totalmente personalizados que mudam diariamente conforme o desempenho do atleta. Já os Planos Expert permitem que o cliente escolha um treinador pela filosofia de treino dele. Toque em cada card para ver quando indicar.</p>"},
  {"type":"flip_card","columns":3,"cards":[
    {"emoji":"🚶‍♂️","title":"Jeff Galloway","subtitle":"Método Run Walk Run","frontText":"<p>Indicado para quem é iniciante ou está voltando de uma lesão.</p>","backLabel":"Indique quando o cliente...","backText":"<p>É iniciante ou está voltando de uma lesão.</p><p><strong>Método:</strong> Run Walk Run — alterna corrida e caminhada para reduzir impacto e dar confiança.</p><p><strong>Frase de venda:</strong> <em>\"Esse plano foi feito pra quem quer voltar a correr sem se machucar de novo.\"</em></p>"},
    {"emoji":"🩺","title":"Amy Parkerson-Mitchell","subtitle":"Fisioterapeuta","frontText":"<p>Indicada para quem já sofreu lesões recorrentes ou se preocupa com a mecânica da corrida.</p>","backLabel":"Indique quando o cliente...","backText":"<p>Já corre, mas se preocupa com dores e lesões.</p><p><strong>Método:</strong> Foco na mecânica corporal e prevenção de lesões, priorizando uma corrida mais segura, não necessariamente mais rápida.</p><p><strong>Frase de venda:</strong> <em>\"Ela é fisioterapeuta — o plano dela cuida do seu corpo antes de cuidar do seu tempo.\"</em></p>"},
    {"emoji":"📊","title":"Greg McMillan","subtitle":"Fisiologia e Ritmo","frontText":"<p>Indicado para quem já corre e quer evoluir tempo e performance com método.</p>","backLabel":"Indique quando o cliente...","backText":"<p>Já corre bem e quer evoluir o tempo com método.</p><p><strong>Método:</strong> Fisiologia aplicada — entender a dinâmica do ritmo, as zonas de treino e o porquê de cada sessão.</p><p><strong>Frase de venda:</strong> <em>\"Se você já corre e quer entender o porquê de cada treino, esse é o seu treinador.\"</em></p>"}
  ]},
  {"type":"banner","tone":"info","text":"Distâncias disponíveis: 5K, 10K e Meia Maratona, com suporte a ritmos entre 4:24 e 7:30 min/km."},
  {"type":"texto_rico","html":"<h3>Ciclismo</h3><p>O Garmin Cycling Coach oferece planos autoguiados nos tipos Century (160 km), Gran Fondo, Metric Century (100 km), MTB, Race e Time Trial. Para treino indoor, o ecossistema é compatível com Smart Trainers Tacx através do app Tacx Training, integrando o treino indoor ao plano do relógio. O requisito obrigatório é ter um monitor de frequência cardíaca ou um medidor de potência, e usar os dois juntos é recomendado para máxima precisão.</p><h3>Força</h3><p>O treinamento de força tem planos configuráveis com base em três variáveis que o próprio cliente escolhe no app: o objetivo (hipertrofia, força ou condicionamento), o equipamento disponível (dumbbells, barras ou peso corporal) e o foco muscular em grupos específicos.</p><h3>Triatlo</h3><p>O plano de triatlo cobre as três disciplinas e permite agendar dias específicos de piscina, além de sessões Two-a-day, com dois treinos no mesmo dia. O Garmin Connect+ é um upgrade de experiência que inclui vídeos exclusivos e conteúdo educacional de especialistas sobre técnica de transição e natação.</p>"}
]
$b3$::jsonb)
where id = '1435a4aa-8d7f-4d08-b745-cf500e2f75eb';

-- ============================================================================
-- FIM DA MIGRAÇÃO 032
-- ============================================================================
