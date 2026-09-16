-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 164: Garmin Coach, lição 3 reestruturada
-- ============================================================================
-- Continua a sql/163. Cobre o Coach durante o treino, gerenciamento do
-- plano, o caminho no Garmin Connect, requisitos e dúvidas frequentes.
--
-- A lista gigante de modelos compatíveis sai da página e vira interação:
-- quatro famílias visíveis (Forerunner, fēnix/Instinct, Venu/vívoactive,
-- Edge) e a lista detalhada dentro de "Ver compatibilidade completa".
-- Nenhum modelo novo foi inventado: a lista é exatamente a que já existia.
--
-- Ajustes de conteúdo exigidos pelo briefing:
--   - "ajusta a carga para baixo automaticamente" virou "pode sugerir
--     pausar ou ajustar a carga" (não afirmar reajuste automático sempre);
--   - a resposta sobre alertas de ritmo deixou de afirmar que o Coach
--     "substitui os padrões para garantir a precisão";
--   - removido o banner "o relógio pensa por ele", proibido pelo briefing.
-- ============================================================================

update lessons set body = $j$
{
  "blocks": [
    {
      "type": "texto_rico",
      "html": "<h3>O Coach durante o treino</h3>"
    },
    {
      "type": "card_grid",
      "columns": 2,
      "items": [
        {
          "title": "Barra de ritmo",
          "text": "<p>Durante determinados treinos de corrida, o relógio mostra uma orientação de ritmo para ajudar o atleta a permanecer dentro da faixa definida para aquela etapa.</p><p><strong>Não confundir com ritmo instantâneo.</strong> A barra mostra o ritmo médio da etapa ou volta atual.</p>"
        },
        {
          "title": "Confidence Score",
          "text": "<p>Indicador relacionado à meta definida no plano, representado por cores (roxo, verde, laranja e vermelho).</p><p>Com meta de tempo ou ritmo, o indicador fica disponível. Sem meta de tempo ou ritmo, ele não é exibido da mesma forma.</p>"
        }
      ]
    },
    {
      "type": "texto_rico",
      "html": "<h3>Gerenciamento do plano</h3>"
    },
    {
      "type": "card_grid",
      "columns": 3,
      "items": [
        {"title": "Reagendar", "text": "Permite ajustar determinados treinos pelo Garmin Connect. Planos de ciclismo autoguiado exigem o Garmin Connect Web."},
        {"title": "Pausar", "text": "Mantém o progresso do plano."},
        {"title": "Sair", "text": "Remove os treinos futuros do plano. Os treinos já realizados continuam no calendário."}
      ]
    },
    {
      "type": "banner",
      "tone": "warning",
      "text": "<strong>Pausar não é o mesmo que sair do plano.</strong> Depois de sair, para retomar é preciso começar um plano do zero."
    },
    {
      "type": "texto_rico",
      "html": "<h3>Garmin Connect na prática</h3><p>Caminho para encontrar os planos no aplicativo:</p><p><strong>Garmin Connect &gt; Mais &gt; Treinamento e Planejamento &gt; Planos Garmin Coach</strong></p>"
    },
    {
      "type": "banner",
      "tone": "info",
      "text": "Se estiver com o cliente, mostre esse caminho no aplicativo."
    },
    {
      "type": "texto_rico",
      "html": "<h3>Requisitos e compatibilidade</h3><p>Organizados por família de produto. Abra “Ver compatibilidade completa” para a lista detalhada.</p>"
    },
    {
      "type": "card_grid",
      "columns": 2,
      "items": [
        {"title": "Forerunner", "text": "Foco em corrida e triatlo."},
        {"title": "fēnix / Instinct", "text": "Multiesporte e aventura."},
        {"title": "Venu / vívoactive", "text": "Lifestyle, saúde e fitness."},
        {"title": "Edge", "text": "Ciclismo."}
      ]
    },
    {
      "type": "accordion",
      "items": [
        {
          "title": "Ver compatibilidade completa",
          "html": "<p>Linha Forerunner (do 45 ao 970), linha fēnix (do 5 ao fēnix 8/E), Venu (do Sq ao Venu 4/X1), Instinct em todas as gerações incluindo o Instinct 3, vívoactive 5/6 e os ciclocomputadores Edge.</p><p>Para planos de ciclismo é preciso ter monitor de frequência cardíaca ou medidor de potência, como o Rally. Para ciclismo indoor, a linha Tacx de Smart Trainers faz a integração.</p><p>O Garmin Express atualiza o software do relógio pelo computador. Se o Coach não aparecer no dispositivo, atualizar é o primeiro passo.</p>"
        }
      ]
    },
    {
      "type": "texto_rico",
      "html": "<h3>Dúvidas frequentes</h3>"
    },
    {
      "type": "accordion",
      "items": [
        {"title": "Quantos planos o cliente pode ter ativos ao mesmo tempo?", "html": "<p>Apenas um plano Garmin Coach ativo por vez.</p>"},
        {"title": "O que acontece se o atleta pular partes opcionais de um treino?", "html": "<p>Para avançar durante a atividade, basta apertar o botão Lap (volta). Se o atleta pula muitas sessões, o plano pode sugerir pausar ou ajustar a carga.</p>"},
        {"title": "O cliente pode usar os alertas de ritmo habituais do relógio?", "html": "<p>Durante os treinos guiados, os alertas do Coach orientam o ritmo definido para cada etapa do plano.</p>"},
        {"title": "Quais idiomas são suportados?", "html": "<p>Português, inglês, espanhol, francês, alemão, chinês, japonês, coreano, holandês, dinamarquês, norueguês, sueco, italiano, tailandês, vietnamita, indonésio e checo.</p>"}
      ]
    }
  ]
}
$j$::jsonb
where id = '1702bda8-0836-4572-8e9a-87ba091f3aec';

-- ============================================================================
-- FIM DA MIGRAÇÃO 164
-- ============================================================================
