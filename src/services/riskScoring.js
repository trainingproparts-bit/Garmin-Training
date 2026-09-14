// src/services/riskScoring.js
// Score de Risco de Treinamento — Dashboard Executivo.
//
// Pedido explícito do usuário (seção 10 do briefing): "se criar um score,
// documente claramente: quais variáveis entram, peso de cada variável,
// interpretação, limitações". Este arquivo é essa documentação — a fórmula
// vive só aqui, em JS puro (não em SQL), justamente para ficar legível e
// auditável num único lugar, sem abrir o SQL Editor pra entender "por que
// esse colaborador está em Atenção".
//
// ── Variáveis que entram (todas vêm de v_exec_colaborador_resumo, sql/115) ──
//
// 1. Inatividade (dias_inatividade) — peso máximo 45 pts
//    <7 dias: 0 · 7–14: 15 · 15–29: 30 · 30+: 45
//    O limiar de 15 dias == "estagnado" reaproveita o mesmo vocabulário já
//    usado no Painel do Líder (liderDashboard.js, INATIVIDADE_LIMIAR_DIAS).
//    dias_inatividade nulo (nunca registrou nenhuma atividade real) entra
//    como 30 pts, não 45 — LIMITAÇÃO: não dá pra distinguir com certeza
//    "colaborador abandonado" de "colaborador recém-cadastrado que ainda não
//    começou", porque hired_at está null pra boa parte da base real (ver
//    onboarding_data_estimada em v_lider_zona_atual) — tratamos como sinal
//    de atenção moderada, não crítica, até haver mais contexto.
//
// 2. Progresso muito abaixo da média do grupo — peso máximo 25 pts
//    Compara progresso_pct do colaborador contra a média do grupo filtrado
//    (loja/cargo, calculada no chamador). >=70% da média do grupo: 0 pts ·
//    40–69%: 12 pts · <40%: 25 pts. Sem checkpoints obrigatórios atribuíveis
//    (progresso_pct null) não pontua — não há o que comparar.
//
// 3. Taxa de aprovação em quiz abaixo de 50% — peso máximo 20 pts
//    >=70%: 0 · 50–69%: 8 · <50%: 20. Sem nenhuma tentativa finalizada ainda
//    não pontua (amostra insuficiente, não vira "risco" por omissão).
//
// 4. Reprovação recorrente (2 tentativas finalizadas mais recentes do MESMO
//    quiz, ambas reprovadas) — 10 pts fixos, sinal de dificuldade persistente
//    num conteúdo específico, não um erro pontual.
//
// ── Faixas finais (0–100, soma das 4 variáveis) ──
//   0–15  + atividade recente (<7 dias)  → "Evolução positiva"
//   0–40  (sem a condição acima)          → "Normal"
//   41–65                                 → "Atenção"
//   66+                                   → "Alta atenção"
//
// ── Limitações declaradas ──
//   - Não mede "velocidade" de evolução (comparação com o mês anterior do
//     PRÓPRIO colaborador) — só o estado atual. Tendência mês a mês é
//     mostrada separadamente na aba Evolução, não entra nesta nota.
//   - Não usa login/sessão (login_events/study_sessions nunca são gravadas
//     por nenhuma tela do app — confirmado por auditoria de código).
//   - Pesos são fixos nesta versão (não configuráveis por painel admin).

export const RISK_BAND = {
  EVOLUCAO_POSITIVA: 'evolucao_positiva',
  NORMAL: 'normal',
  ATENCAO: 'atencao',
  ALTA_ATENCAO: 'alta_atencao',
};

export const RISK_BAND_LABEL = {
  [RISK_BAND.EVOLUCAO_POSITIVA]: 'Evolução positiva',
  [RISK_BAND.NORMAL]: 'Normal',
  [RISK_BAND.ATENCAO]: 'Atenção',
  [RISK_BAND.ALTA_ATENCAO]: 'Alta atenção',
};

function pontosInatividade(diasInatividade) {
  if (diasInatividade === null || diasInatividade === undefined) return 30;
  if (diasInatividade < 7) return 0;
  if (diasInatividade < 15) return 15;
  if (diasInatividade < 30) return 30;
  return 45;
}

function pontosProgressoRelativo(progressoPct, mediaGrupoPct) {
  if (progressoPct === null || progressoPct === undefined) return 0;
  const media = Number.isFinite(mediaGrupoPct) && mediaGrupoPct > 0 ? mediaGrupoPct : null;
  if (media === null) return 0; // sem base de comparação (grupo vazio/sem progresso)

  const razao = progressoPct / media;
  if (razao >= 0.7) return 0;
  if (razao >= 0.4) return 12;
  return 25;
}

function pontosAprovacaoQuiz(taxaAprovacaoPct) {
  if (taxaAprovacaoPct === null || taxaAprovacaoPct === undefined) return 0;
  if (taxaAprovacaoPct >= 70) return 0;
  if (taxaAprovacaoPct >= 50) return 8;
  return 20;
}

/**
 * @param {object} colaborador - linha de v_exec_colaborador_resumo
 * @param {{ mediaProgressoPct?: number }} contexto - médias do grupo filtrado (loja/cargo), calculadas pelo chamador
 * @returns {{ score: number, band: string, bandLabel: string, breakdown: object }}
 */
export function computeRiskScore(colaborador, contexto = {}) {
  const diasInatividade = colaborador?.dias_inatividade ?? null;
  const progressoPct = colaborador?.progresso_pct ?? null;
  const taxaAprovacaoPct = colaborador?.quiz_taxa_aprovacao_pct ?? null;
  const temReprovacaoRecorrente = !!colaborador?.tem_reprovacao_recorrente;

  const breakdown = {
    inatividade: pontosInatividade(diasInatividade),
    progressoRelativo: pontosProgressoRelativo(progressoPct, contexto.mediaProgressoPct),
    aprovacaoQuiz: pontosAprovacaoQuiz(taxaAprovacaoPct),
    reprovacaoRecorrente: temReprovacaoRecorrente ? 10 : 0,
  };

  const score = Math.min(
    100,
    breakdown.inatividade + breakdown.progressoRelativo + breakdown.aprovacaoQuiz + breakdown.reprovacaoRecorrente,
  );

  const atividadeRecente = diasInatividade !== null && diasInatividade !== undefined && diasInatividade < 7;

  let band;
  if (score <= 15 && atividadeRecente) band = RISK_BAND.EVOLUCAO_POSITIVA;
  else if (score <= 40) band = RISK_BAND.NORMAL;
  else if (score <= 65) band = RISK_BAND.ATENCAO;
  else band = RISK_BAND.ALTA_ATENCAO;

  return { score, band, bandLabel: RISK_BAND_LABEL[band], breakdown };
}

/** Média simples de progresso_pct entre colaboradores com progresso mensurável (progresso_pct != null) — usada como mediaProgressoPct do contexto acima. */
export function computeMediaProgresso(colaboradores) {
  const valores = (colaboradores || [])
    .map((c) => c.progresso_pct)
    .filter((v) => v !== null && v !== undefined);
  if (!valores.length) return null;
  return valores.reduce((sum, v) => sum + v, 0) / valores.length;
}
