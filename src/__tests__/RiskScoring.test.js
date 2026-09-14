// src/__tests__/RiskScoring.test.js
// Testes da fórmula de Score de Risco do Dashboard Executivo (riskScoring.js).
// Fórmula documentada em detalhe no próprio arquivo — aqui só valida que os
// limiares/pesos descritos lá realmente produzem a faixa esperada.

import { describe, it, expect } from 'vitest';
import { computeRiskScore, computeMediaProgresso, RISK_BAND } from '../services/riskScoring.js';

describe('riskScoring - computeRiskScore', () => {
  it('colaborador ativo, aprovado, sem histórico de reprovação → Evolução positiva', () => {
    const colaborador = {
      dias_inatividade: 1,
      progresso_pct: 90,
      quiz_taxa_aprovacao_pct: 100,
      tem_reprovacao_recorrente: false,
    };
    const result = computeRiskScore(colaborador, { mediaProgressoPct: 60 });
    expect(result.band).toBe(RISK_BAND.EVOLUCAO_POSITIVA);
    expect(result.score).toBe(0);
  });

  it('sem nenhuma atividade registrada (dias_inatividade null) não vira automaticamente Alta atenção', () => {
    const colaborador = {
      dias_inatividade: null,
      progresso_pct: null,
      quiz_taxa_aprovacao_pct: null,
      tem_reprovacao_recorrente: false,
    };
    const result = computeRiskScore(colaborador, { mediaProgressoPct: 60 });
    expect(result.breakdown.inatividade).toBe(30);
    expect(result.score).toBe(30);
    expect(result.band).toBe(RISK_BAND.NORMAL);
  });

  it('30+ dias inativo, progresso muito abaixo da média, quiz reprovado, reprovação recorrente → Alta atenção', () => {
    const colaborador = {
      dias_inatividade: 45,
      progresso_pct: 10,
      quiz_taxa_aprovacao_pct: 20,
      tem_reprovacao_recorrente: true,
    };
    const result = computeRiskScore(colaborador, { mediaProgressoPct: 60 });
    expect(result.breakdown).toEqual({
      inatividade: 45,
      progressoRelativo: 25,
      aprovacaoQuiz: 20,
      reprovacaoRecorrente: 10,
    });
    expect(result.score).toBe(100);
    expect(result.band).toBe(RISK_BAND.ALTA_ATENCAO);
  });

  it('inatividade de 10 dias cai na faixa 7-14 (15 pts), não na faixa <7 nem na 15-29', () => {
    const result = computeRiskScore({ dias_inatividade: 10 }, {});
    expect(result.breakdown.inatividade).toBe(15);
  });

  it('sem grupo de comparação (mediaProgressoPct ausente), progresso não pontua', () => {
    const result = computeRiskScore({ dias_inatividade: 1, progresso_pct: 5 }, {});
    expect(result.breakdown.progressoRelativo).toBe(0);
  });

  it('taxa de aprovação null (sem tentativas finalizadas) não pontua como risco', () => {
    const result = computeRiskScore({ dias_inatividade: 1, quiz_taxa_aprovacao_pct: null }, {});
    expect(result.breakdown.aprovacaoQuiz).toBe(0);
  });

  it('score nunca passa de 100', () => {
    const result = computeRiskScore(
      { dias_inatividade: 999, progresso_pct: 0, quiz_taxa_aprovacao_pct: 0, tem_reprovacao_recorrente: true },
      { mediaProgressoPct: 100 },
    );
    expect(result.score).toBeLessThanOrEqual(100);
  });
});

describe('riskScoring - computeMediaProgresso', () => {
  it('ignora colaboradores sem progresso mensurável (null)', () => {
    const media = computeMediaProgresso([
      { progresso_pct: 50 },
      { progresso_pct: null },
      { progresso_pct: 100 },
    ]);
    expect(media).toBe(75);
  });

  it('retorna null quando nenhum colaborador tem progresso mensurável', () => {
    expect(computeMediaProgresso([{ progresso_pct: null }])).toBeNull();
    expect(computeMediaProgresso([])).toBeNull();
  });
});
