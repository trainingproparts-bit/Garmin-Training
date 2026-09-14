// src/components/chartsSvg.js
// Primitivas de gráfico em SVG puro, sem biblioteca nova (mesmo espírito de
// icons.js) — desenhadas para o Dashboard Executivo, onde a paleta é
// estritamente preto/branco/vermelho. Nenhuma cor fica hardcoded em hex
// aqui: tudo herda de classes CSS (--ed-* em dashboardExecutivo.css), então
// o mesmo gráfico funciona em modo claro/escuro sem lógica JS extra.
//
// Deliberadamente sem pizza/donut/gauge/3D (pedido explícito do usuário).
// Cada função devolve uma string SVG pronta pra template literal — o
// chamador decide se renderiza ou mostra um estado vazio (essas funções não
// sabem o que é "dado insuficiente", isso é decisão de produto da página).

function escapeAttr(str) {
  return String(str).replace(/"/g, '&quot;');
}

/** Sparkline minimalista — sem eixo, sem rótulo, só a forma da tendência. */
export function sparklineSvg(values, { width = 96, height = 28, className = 'ed-spark' } = {}) {
  if (!values?.length) return '';
  const min = Math.min(...values);
  const max = Math.max(...values);
  const range = max - min || 1;
  const stepX = values.length > 1 ? width / (values.length - 1) : 0;

  const points = values.map((v, i) => {
    const x = i * stepX;
    const y = height - ((v - min) / range) * height;
    return `${x.toFixed(1)},${y.toFixed(1)}`;
  });

  return `
    <svg class="${className}" viewBox="0 0 ${width} ${height}" width="${width}" height="${height}" preserveAspectRatio="none" aria-hidden="true">
      <polyline points="${points.join(' ')}" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" />
    </svg>`;
}

/**
 * Gráfico de linha com eixo de rótulos (meses) e 1+ séries.
 * @param {Array<{label: string, data: number[], className?: string}>} series
 * @param {{labels: string[], width?: number, height?: number, valueFormatter?: (n:number)=>string}} opts
 */
export function lineChartSvg(series, { labels, width = 640, height = 240, valueFormatter = (n) => String(n) } = {}) {
  if (!series?.length || !labels?.length) return '';

  const padding = { top: 16, right: 16, bottom: 28, left: 8 };
  const plotW = width - padding.left - padding.right;
  const plotH = height - padding.top - padding.bottom;

  const allValues = series.flatMap((s) => s.data);
  const max = Math.max(...allValues, 0);
  const min = Math.min(...allValues, 0);
  const range = max - min || 1;
  const stepX = labels.length > 1 ? plotW / (labels.length - 1) : 0;

  const yFor = (v) => padding.top + plotH - ((v - min) / range) * plotH;
  const xFor = (i) => padding.left + i * stepX;

  const zeroY = yFor(0);

  const seriesHtml = series.map((s, si) => {
    const pts = s.data.map((v, i) => `${xFor(i).toFixed(1)},${yFor(v).toFixed(1)}`).join(' ');
    const lastX = xFor(s.data.length - 1);
    const lastY = yFor(s.data[s.data.length - 1]);
    const cls = s.className || (si === 0 ? 'ed-line-primary' : 'ed-line-secondary');
    return `
      <polyline points="${pts}" fill="none" class="${cls}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
      <circle cx="${lastX.toFixed(1)}" cy="${lastY.toFixed(1)}" r="3" class="${cls}-dot" />
    `;
  }).join('');

  const labelsHtml = labels.map((l, i) => `
    <text x="${xFor(i).toFixed(1)}" y="${height - 8}" class="ed-axis-label" text-anchor="${i === 0 ? 'start' : i === labels.length - 1 ? 'end' : 'middle'}">${l}</text>
  `).join('');

  return `
    <svg viewBox="0 0 ${width} ${height}" width="100%" height="${height}" class="ed-chart ed-linechart" role="img" aria-label="Gráfico de evolução">
      <line x1="${padding.left}" y1="${zeroY.toFixed(1)}" x2="${width - padding.right}" y2="${zeroY.toFixed(1)}" class="ed-axis-line" />
      ${seriesHtml}
      ${labelsHtml}
    </svg>`;
}

/**
 * Barras — verticais para comparação temporal, horizontais para ranking.
 * @param {Array<{label: string, value: number}>} items
 */
export function barChartSvg(items, { width = 640, height = 240, horizontal = false, valueFormatter = (n) => String(n), className = 'ed-bar' } = {}) {
  if (!items?.length) return '';
  const max = Math.max(...items.map((d) => d.value), 1);

  if (horizontal) {
    const rowH = 28;
    const gap = 10;
    const chartHeight = items.length * (rowH + gap);
    const labelW = 160;
    const barMaxW = width - labelW - 48;

    const rows = items.map((d, i) => {
      const y = i * (rowH + gap);
      const barW = Math.max((d.value / max) * barMaxW, 1);
      return `
        <text x="0" y="${y + rowH / 2 + 4}" class="ed-bar-label">${d.label}</text>
        <rect x="${labelW}" y="${y}" width="${barW.toFixed(1)}" height="${rowH}" class="${className}" rx="2" />
        <text x="${labelW + barW + 8}" y="${y + rowH / 2 + 4}" class="ed-bar-value">${valueFormatter(d.value)}</text>
      `;
    }).join('');

    return `
      <svg viewBox="0 0 ${width} ${chartHeight}" width="100%" height="${chartHeight}" class="ed-chart ed-barchart-h" role="img" aria-label="Gráfico de ranking">
        ${rows}
      </svg>`;
  }

  const padding = { top: 16, right: 8, bottom: 28, left: 8 };
  const plotW = width - padding.left - padding.right;
  const plotH = height - padding.top - padding.bottom;
  const barGap = 8;
  const barW = Math.max((plotW - barGap * (items.length - 1)) / items.length, 4);

  const bars = items.map((d, i) => {
    const x = padding.left + i * (barW + barGap);
    const h = (d.value / max) * plotH;
    const y = padding.top + (plotH - h);
    return `
      <rect x="${x.toFixed(1)}" y="${y.toFixed(1)}" width="${barW.toFixed(1)}" height="${Math.max(h, 1).toFixed(1)}" class="${className}" rx="2" />
      <text x="${(x + barW / 2).toFixed(1)}" y="${height - 8}" class="ed-axis-label" text-anchor="middle">${d.label}</text>
    `;
  }).join('');

  return `
    <svg viewBox="0 0 ${width} ${height}" width="100%" height="${height}" class="ed-chart ed-barchart-v" role="img" aria-label="Gráfico de comparação">
      ${bars}
    </svg>`;
}

/**
 * Funil — barras horizontais decrescentes com % de retenção entre etapas.
 * @param {Array<{label: string, value: number}>} stages - já em ordem (etapa 1 primeiro)
 */
export function funnelChartSvg(stages, { width = 640 } = {}) {
  if (!stages?.length) return '';
  const max = stages[0].value || 1;
  const rowH = 40;
  const gap = 14;
  const chartHeight = stages.length * (rowH + gap);

  const rows = stages.map((s, i) => {
    const y = i * (rowH + gap);
    const barW = Math.max((s.value / max) * width, 2);
    const retencao = i > 0 && stages[i - 1].value > 0 ? Math.round((s.value / stages[i - 1].value) * 100) : null;

    return `
      <g>
        <rect x="0" y="${y}" width="${barW.toFixed(1)}" height="${rowH}" class="ed-funnel-bar" rx="2" />
        <text x="12" y="${y + rowH / 2 + 5}" class="ed-funnel-label">${s.label}</text>
        <text x="${width}" y="${y + rowH / 2 - 4}" class="ed-funnel-value" text-anchor="end">${s.value}</text>
        ${retencao !== null ? `<text x="${width}" y="${y + rowH / 2 + 12}" class="ed-funnel-retention" text-anchor="end">${retencao}% da etapa anterior</text>` : ''}
      </g>`;
  }).join('');

  return `
    <svg viewBox="0 0 ${width} ${chartHeight}" width="100%" height="${chartHeight}" class="ed-chart ed-funnelchart" role="img" aria-label="Funil de aprendizagem">
      ${rows}
    </svg>`;
}

export { escapeAttr };
