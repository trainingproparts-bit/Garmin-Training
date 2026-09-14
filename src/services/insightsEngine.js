// src/services/insightsEngine.js
// Insights automáticos do Dashboard Executivo — regras determinísticas sobre
// dados já carregados (não é IA/heurística estatística sofisticada, é um
// conjunto pequeno de regras claras, cada uma com um critério mínimo de
// amostra pra não gerar frase genérica sem número real por trás, conforme
// pedido explícito do usuário: "priorize insights que indiquem ação").
//
// Cada regra só entra na lista se os dados sustentarem — nenhuma regra
// preenche com "0" ou frase vazia quando falta amostra.

const AMOSTRA_MINIMA_GAP = 3; // menos que isso, uma taxa de erro de pergunta é ruído estatístico, não sinal
const AMOSTRA_MINIMA_QUIZ_MES = 5; // tentativas de quiz no mês, pra taxa de aprovação mensal não virar ruído
const INATIVIDADE_LIMIAR_DIAS = 15; // mesmo limiar "estagnado" do Painel do Líder (liderDashboard.js)

function ultimosDoisMeses(evolucaoPorMes) {
  const meses = [...new Set((evolucaoPorMes || []).map((r) => r.mes))].sort();
  if (meses.length < 2) return null;
  return { anterior: meses[meses.length - 2], atual: meses[meses.length - 1] };
}

function somaPorMes(evolucaoMensal, mes, campo) {
  return (evolucaoMensal || [])
    .filter((r) => r.mes === mes)
    .reduce((sum, r) => sum + (Number(r[campo]) || 0), 0);
}

/**
 * @param {object} data
 * @param {Array} data.colaboradores - v_exec_colaborador_resumo (já filtrado pelo escopo ativo no dashboard)
 * @param {Array} data.evolucaoMensal - v_exec_evolucao_mensal (mesmo escopo)
 * @param {Array} data.gaps - vw_store_knowledge_gaps (mesmo escopo)
 * @returns {Array<{id: string, tone: 'critical'|'warning'|'positive'|'info', text: string}>}
 */
export function computeInsights({ colaboradores = [], evolucaoMensal = [], gaps = [] } = {}) {
  const insights = [];

  // 1) Inatividade prolongada
  const inativos = colaboradores.filter((c) => (c.dias_inatividade ?? 0) >= INATIVIDADE_LIMIAR_DIAS);
  if (inativos.length > 0) {
    const nomes = inativos.slice(0, 3).map((c) => c.full_name).join(', ');
    const resto = inativos.length > 3 ? ` e mais ${inativos.length - 3}` : '';
    insights.push({
      id: 'inatividade',
      tone: 'critical',
      text: `${inativos.length} colaborador${inativos.length > 1 ? 'es' : ''} sem atividade há ${INATIVIDADE_LIMIAR_DIAS}+ dias: ${nomes}${resto}.`,
    });
  }

  // 2) Pergunta/quiz com maior taxa de erro (amostra mínima pra não ser ruído)
  const gapsRelevantes = gaps.filter((g) => (g.total_answers ?? 0) >= AMOSTRA_MINIMA_GAP && (g.error_rate_pct ?? 0) > 0);
  if (gapsRelevantes.length > 0) {
    const pior = gapsRelevantes.reduce((a, b) => ((b.error_rate_pct ?? 0) > (a.error_rate_pct ?? 0) ? b : a));
    insights.push({
      id: 'maior-erro',
      tone: pior.error_rate_pct > 50 ? 'critical' : 'warning',
      text: `"${pior.question_text}" (${pior.quiz_title}) tem ${pior.error_rate_pct}% de taxa de erro nos últimos 30 dias, ${pior.wrong_answers} de ${pior.total_answers} tentativas.`,
    });
  }

  // 3) Variação de XP total mês a mês (só com 2 meses reais de dado)
  const janela = ultimosDoisMeses(evolucaoMensal);
  if (janela) {
    const xpAnterior = somaPorMes(evolucaoMensal, janela.anterior, 'xp_ganho');
    const xpAtual = somaPorMes(evolucaoMensal, janela.atual, 'xp_ganho');
    if (xpAnterior > 0) {
      const variacaoPct = Math.round(((xpAtual - xpAnterior) / xpAnterior) * 100);
      if (Math.abs(variacaoPct) >= 10) {
        insights.push({
          id: 'variacao-xp',
          tone: variacaoPct > 0 ? 'positive' : 'warning',
          text: `O Score de Performance total da equipe ${variacaoPct > 0 ? 'cresceu' : 'caiu'} ${Math.abs(variacaoPct)}% em relação ao mês anterior.`,
        });
      }
    }

    // 4) Variação de taxa de aprovação em quiz (amostra mínima em cada mês)
    const tentativasAnterior = somaPorMes(evolucaoMensal, janela.anterior, 'quiz_tentativas');
    const tentativasAtual = somaPorMes(evolucaoMensal, janela.atual, 'quiz_tentativas');
    if (tentativasAnterior >= AMOSTRA_MINIMA_QUIZ_MES && tentativasAtual >= AMOSTRA_MINIMA_QUIZ_MES) {
      const aprovAnterior = somaPorMes(evolucaoMensal, janela.anterior, 'quiz_aprovados');
      const aprovAtual = somaPorMes(evolucaoMensal, janela.atual, 'quiz_aprovados');
      const taxaAnterior = (aprovAnterior / tentativasAnterior) * 100;
      const taxaAtual = (aprovAtual / tentativasAtual) * 100;
      const deltaPontos = Math.round(taxaAtual - taxaAnterior);
      if (Math.abs(deltaPontos) >= 5) {
        insights.push({
          id: 'variacao-aprovacao',
          tone: deltaPontos > 0 ? 'positive' : 'warning',
          text: `A taxa de aprovação em quizzes ${deltaPontos > 0 ? 'subiu' : 'caiu'} ${Math.abs(deltaPontos)} pontos percentuais em relação ao mês anterior (${Math.round(taxaAnterior)}% → ${Math.round(taxaAtual)}%).`,
        });
      }
    }

    // 5) Maior crescimento individual de XP no período (só entre quem já tinha histórico no mês anterior)
    const idsComHistorico = new Set(
      evolucaoMensal.filter((r) => r.mes === janela.anterior && r.xp_ganho > 0).map((r) => r.colaborador_id),
    );
    let maiorCrescimento = null;
    idsComHistorico.forEach((id) => {
      const anterior = evolucaoMensal.find((r) => r.mes === janela.anterior && r.colaborador_id === id)?.xp_ganho || 0;
      const atual = evolucaoMensal.find((r) => r.mes === janela.atual && r.colaborador_id === id)?.xp_ganho || 0;
      const delta = atual - anterior;
      if (delta > 0 && (!maiorCrescimento || delta > maiorCrescimento.delta)) {
        maiorCrescimento = { id, delta };
      }
    });
    if (maiorCrescimento) {
      const colaborador = colaboradores.find((c) => c.colaborador_id === maiorCrescimento.id);
      if (colaborador) {
        insights.push({
          id: 'maior-crescimento',
          tone: 'positive',
          text: `${colaborador.full_name} está entre os maiores crescimentos do período, +${maiorCrescimento.delta} pts de Score de Performance em relação ao mês anterior.`,
        });
      }
    }
  }

  // 6) Qualidade de dado — perfis sem marca atribuída não têm como calcular
  // progresso (checkpoints obrigatórios são por marca/trilha), então
  // progresso_pct vem null pra eles em vez de um 0% inventado. Isso é
  // correto do ponto de vista de cálculo, mas precisa aparecer pra gestora
  // não interpretar "—" como "não fez nada" — RN pediu explicitamente pra
  // nunca esconder dado incompleto (seção 19 do briefing).
  const semMarca = colaboradores.filter((c) => !c.brand_id);
  if (semMarca.length > 0) {
    const nomes = semMarca.slice(0, 3).map((c) => c.full_name).join(', ');
    const resto = semMarca.length > 3 ? ` e mais ${semMarca.length - 3}` : '';
    insights.push({
      id: 'perfil-sem-marca',
      tone: 'warning',
      text: `${semMarca.length} colaborador${semMarca.length > 1 ? 'es têm' : ' tem'} perfil sem marca atribuída (cadastro do admin não foi finalizado) — progresso não pode ser calculado até isso ser corrigido: ${nomes}${resto}.`,
    });
  }

  // 7) Distribuição de risco — só quando há gente em atenção alta
  const altaAtencao = colaboradores.filter((c) => c._risco?.band === 'alta_atencao');
  if (altaAtencao.length > 0) {
    insights.push({
      id: 'risco-alto',
      tone: 'critical',
      text: `${altaAtencao.length} colaborador${altaAtencao.length > 1 ? 'es estão' : ' está'} em Alta Atenção agora — recomenda-se intervenção da gestão.`,
    });
  }

  return insights;
}
