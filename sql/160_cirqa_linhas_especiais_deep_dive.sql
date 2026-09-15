-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 160: CIRQA em "Linhas Especiais e Novidades"
-- ============================================================================
-- Pedido do usuário (2026-09-15): "eu queria o cirqa aqui.... não lá na
-- academia de produtos" + "lá na academia ja tava tudo certo" — a Academia
-- de Produtos já tem a página completa do Cirqa (sql/149-157) e não é pra
-- mexer nela. Isso aqui é aditivo: um artigo curto em content_library
-- (category='deep_dive'), no mesmo padrão das outras "Linhas Especiais"
-- (ex.: blaze-equine-wellness), pra aparecer como card na Dashboard.
--
-- "lá é pra ser mais enxuto mesmo" — versão mais curta que a Academia:
-- intro + hardware/bateria + pra quem indicar/como apresentar + fechamento,
-- sem repetir todo o conteúdo de vendas já detalhado na Academia.
--
-- Fatos reutilizados da pesquisa já validada nesta sessão (sql/149-157):
-- sensor Elevate Gen 4, 20g, 5 ATM, até 10 dias de bateria, Bluetooth +
-- ANT+, USB-C, sem assinatura obrigatória pros recursos principais,
-- pulseiras de pulso ou bíceps, sem tela (botão físico inicia/pausa e
-- transmite FC segurando 2s).
-- ============================================================================

insert into content_library (brand_id, category, slug, title, summary, order_index, payload)
values (
  '2f7d8451-b279-4d69-8192-6ac9953d7da1',
  'deep_dive',
  'cirqa-monitoramento-sem-tela',
  'Cirqa: monitoramento contínuo sem tela',
  'A aposta da Garmin em bem-estar contínuo sem tela no pulso: hardware, bateria e como apresentar o Cirqa ao cliente certo.',
  8,
  $j$
{
  "blocks": [
    {
      "type": "texto_rico",
      "html": "<p>O <strong>Cirqa</strong> é a aposta da Garmin em monitoramento contínuo de saúde sem tela no pulso — uma banda pensada pra quem quer os dados de recuperação e treino do ecossistema Garmin sem o compromisso visual de um smartwatch completo.</p><p>Sem tela e sem assinatura obrigatória: os principais recursos do Garmin Connect (sono, estresse, Body Battery, frequência cardíaca 24h) vêm inclusos na compra.</p>"
    },
    {
      "type": "card_grid",
      "columns": 2,
      "items": [
        {"title": "📦 Hardware", "text": "Sensor óptico Elevate Gen 4, 20g, resistência de até 5 ATM. Duas opções de pulseira: padrão pro pulso ou específica pro bíceps (material mais elástico, indicada pra treinos de alta intensidade).", "tags": []},
        {"title": "🔋 Bateria & Conectividade", "text": "Até 10 dias de bateria, carregamento via USB-C, conexão Bluetooth e ANT+. Sem tela: um botão físico inicia/pausa atividades e transmite a frequência cardíaca pra outro dispositivo segurando por 2 segundos.", "tags": []}
      ]
    },
    {
      "type": "card_grid",
      "columns": 2,
      "items": [
        {"title": "🎯 Para quem indicar", "text": "Cliente que quer monitorar sono e recuperação sem querer mais uma tela no pulso; quem já tem um Garmin e busca um complemento discreto; quem quer transmitir frequência cardíaca durante o treino.", "tags": []},
        {"title": "💬 Como apresentar", "text": "Nunca apresente como \"um relógio sem tela\" — é uma ferramenta de bem-estar contínuo. Reforce: sem mensalidade obrigatória pros recursos principais, até 10 dias de bateria, 20g.", "tags": []}
      ]
    },
    {
      "type": "banner",
      "tone": "info",
      "text": "Os dados do Cirqa sincronizam com o Garmin Connect e aparecem em qualquer relógio Garmin compatível — reforce que ele soma ao ecossistema, não compete com o relógio principal do cliente."
    }
  ]
}
$j$::jsonb
);

-- ============================================================================
-- FIM DA MIGRAÇÃO 160
-- ============================================================================
