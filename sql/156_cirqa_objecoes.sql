-- ============================================================================
-- GARMIN TRAINING HUB — MIGRAÇÃO 156: CIRQA — Objeções (expande pra 5)
-- ============================================================================
-- Pedido do usuário (2026-09-15): 5 objeções (framing do briefing) — as 3
-- já existentes reformuladas como pergunta direta + 2 novas ("já tenho um
-- Garmin", "pulso e braço"), respostas ancoradas em fatos já verificados.
-- ============================================================================

insert into product_sections (product_id, section_type, payload)
values ('c803a82e-a40a-4f95-8564-34dbd480f9d9', 'objecoes', $j$
{
  "blocks": [
    {
      "type": "objecao",
      "items": [
        {"question": "Mas ele não tem tela?", "answer": "Isso mesmo — o Cirqa foi pensado pra funcionar sem tela. Todos os dados ficam disponíveis no app Garmin Connect no celular; o botão físico serve pra iniciar/pausar atividades e navegar por opções simples direto na pulseira."},
        {"question": "Preciso pagar assinatura?", "answer": "Não pra usar os recursos principais. Prontidão de Treino, VO2 Max, sono, estresse e mais vêm inclusos sem mensalidade. Só o Connect+ opcional adiciona treinos guiados e coaching."},
        {"question": "Por que eu usaria isso se já tenho um Garmin?", "answer": "O Cirqa pode ser um complemento — por exemplo, pra monitorar saúde e recuperação sem depender do relógio principal o dia todo, ou como uma opção mais discreta em determinados contextos."},
        {"question": "Posso usar durante o treino?", "answer": "Sim — o botão físico inicia/pausa atividades manualmente, e dá pra transmitir a frequência cardíaca pra outro dispositivo (relógio, app) segurando o botão por 2 segundos."},
        {"question": "Posso usar no pulso e no braço?", "answer": "Sim, o Cirqa tem duas opções de pulseira: uma padrão pro pulso e uma específica pra bíceps, com material mais elástico, indicada pra treinos de alta intensidade."}
      ]
    }
  ]
}
$j$::jsonb)
on conflict (product_id, section_type) do update set payload = excluded.payload;

-- ============================================================================
-- FIM DA MIGRAÇÃO 156
-- ============================================================================
