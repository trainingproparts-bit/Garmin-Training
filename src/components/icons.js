// src/components/icons.js
// Ícones outline finos (estilo Feather/Lucide, desenhados à mão — sem
// dependência nova) para a sidebar/topbar do redesign premium. O Mural de
// Atividades continua usando emoji nativo (badges/feed) — isso é conteúdo
// dele, não navegação, e fica fora deste conjunto por decisão explícita.
// Todo ícone é um <svg> completo, sem width/height fixo — controlado via
// CSS (.nav-icon, .topbar-icon etc.) para herdar cor (stroke="currentColor").

const wrap = (paths) => `
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
    ${paths}
  </svg>`;

export const ICONS = {
  home: wrap(`<path d="M3 10.5 12 3l9 7.5"/><path d="M5 9.5V20a1 1 0 0 0 1 1h4v-6h4v6h4a1 1 0 0 0 1-1V9.5"/>`),

  trilha: wrap(`<circle cx="12" cy="12" r="9"/><path d="M15.5 8.5 13.2 13.2 8.5 15.5l2.3-4.7z"/>`),

  quizzes: wrap(`<rect x="6" y="4" width="12" height="17" rx="2"/><path d="M9 3.5h6a1 1 0 0 1 1 1V6H8V4.5a1 1 0 0 1 1-1z"/><path d="M9 11.5l1.6 1.6L14.5 9.5"/><path d="M8.5 16.5h7"/>`),

  games: wrap(`<rect x="2.5" y="7.5" width="19" height="10" rx="4"/><path d="M7 10.5v4M5 12.5h4"/><circle cx="16" cy="10.8" r="0.9" fill="currentColor" stroke="none"/><circle cx="18.2" cy="13" r="0.9" fill="currentColor" stroke="none"/>`),

  arena: wrap(`<path d="M4 4l7.5 7.5M20 4l-7.5 7.5"/><path d="M4 20l7.5-7.5M20 20l-7.5-7.5"/><circle cx="12" cy="12" r="2.4" fill="currentColor" stroke="none"/>`),

  certificacao: wrap(`<circle cx="12" cy="9" r="6"/><path d="M8.5 14 7 21l5-2.5L17 21l-1.5-7"/>`),

  biblioteca: wrap(`<path d="M4 5.5c2-1 5-1 7 0v13c-2-1-5-1-7 0z"/><path d="M20 5.5c-2-1-5-1-7 0v13c2-1 5-1 7 0z"/>`),

  ranking: wrap(`<path d="M8 4h8v5a4 4 0 0 1-8 0z"/><path d="M8 5H5.5A1.5 1.5 0 0 0 4 6.5c0 2 1.5 3.5 3.5 3.7M16 5h2.5A1.5 1.5 0 0 1 20 6.5c0 2-1.5 3.5-3.5 3.7"/><path d="M12 13v4M9 20.5h6M10 20.5v-3.3h4v3.3"/>`),

  album: wrap(`<rect x="3" y="6" width="13" height="15" rx="1.5" transform="rotate(-6 9.5 13.5)"/><rect x="7" y="3.5" width="14" height="17" rx="1.5"/><circle cx="14" cy="9.5" r="2"/><path d="M9.5 17.5l2.8-3 2.7 2 2-2.5 2 2.5" stroke-linejoin="round"/>`),

  blog: wrap(`<rect x="3.5" y="5" width="17" height="14" rx="1.5"/><path d="M7 9h6M7 12.2h6M7 15.4h4"/><path d="M16.5 9h1"/>`),

  lider: wrap(`<circle cx="9" cy="8.5" r="3"/><path d="M3.5 19c0-3 2.5-5 5.5-5s5.5 2 5.5 5"/><circle cx="17" cy="9" r="2.3"/><path d="M15.8 13.3c2.4 0.3 4.2 2 4.2 4.2"/>`),

  relatorios: wrap(`<path d="M4 20V9.5M10 20V4.5M16 20v-7M20 20H4"/>`),

  admin: wrap(`<circle cx="12" cy="12" r="3"/><path d="M19.4 13.5a7.4 7.4 0 0 0 .1-1.5 7.4 7.4 0 0 0-.1-1.5l2-1.6-2-3.5-2.4 1a7.6 7.6 0 0 0-2.6-1.5L14 2h-4l-.4 2.4a7.6 7.6 0 0 0-2.6 1.5l-2.4-1-2 3.5 2 1.6a7.4 7.4 0 0 0 0 3l-2 1.6 2 3.5 2.4-1a7.6 7.6 0 0 0 2.6 1.5L10 22h4l.4-2.4a7.6 7.6 0 0 0 2.6-1.5l2.4 1 2-3.5z"/>`),

  gestora: wrap(`<rect x="5" y="3.5" width="14" height="18" rx="2"/><path d="M9 3.5V6h6V3.5"/><path d="M8.5 11.5h4M8.5 14.5h7M8.5 17.5h7"/><path d="M15.5 8.8l1.4 1.4 2.6-2.6"/>`),

  bell: wrap(`<path d="M6 10a6 6 0 0 1 12 0c0 4 1.5 5.5 1.5 5.5H4.5S6 14 6 10z"/><path d="M10 19a2 2 0 0 0 4 0"/>`),

  menu: wrap(`<path d="M4 7h16M4 12h16M4 17h16"/>`),

  panelCollapse: wrap(`<rect x="3.5" y="4.5" width="17" height="15" rx="2"/><path d="M9.5 4.5v15"/><path d="M13.5 10l2 2-2 2"/>`),

  panelExpand: wrap(`<rect x="3.5" y="4.5" width="17" height="15" rx="2"/><path d="M9.5 4.5v15"/><path d="M16 10l-2 2 2 2"/>`),

  logout: wrap(`<path d="M9 4H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h3"/><path d="M15 16l4-4-4-4"/><path d="M19 12H9"/>`),

  moon: wrap(`<path d="M20 14.5A8.5 8.5 0 1 1 9.5 4a7 7 0 0 0 10.5 10.5z"/>`),

  lock: wrap(`<rect x="5" y="11" width="14" height="9" rx="1.8"/><path d="M8 11V7.5a4 4 0 0 1 8 0V11"/>`),

  chevronDown: wrap(`<path d="M6 9l6 6 6-6"/>`),

  switchBrand: wrap(`<path d="M20 12H4"/><path d="M9 6l-5 6 5 6"/>`),

  academia: wrap(`<path d="M2 8.5 12 4l10 4.5-10 4.5-10-4.5z"/><path d="M6 10.7v5c0 1.4 2.7 2.8 6 2.8s6-1.4 6-2.8v-5"/><path d="M20 9v6.5"/>`),

  revisao: wrap(`<path d="M4 12a8 8 0 0 1 14-5.2M4 12a8 8 0 0 0 14 5.2"/><path d="M18 3v4h-4"/><path d="M6 21v-4h4"/>`),

  forum: wrap(`<path d="M4 5.5h13a2 2 0 0 1 2 2v6a2 2 0 0 1-2 2H10l-4.5 4v-4H4a2 2 0 0 1-2-2v-6a2 2 0 0 1 2-2z" transform="translate(1 0) scale(0.9)"/><circle cx="8" cy="10.5" r="0.9" fill="currentColor" stroke="none"/><circle cx="12" cy="10.5" r="0.9" fill="currentColor" stroke="none"/><circle cx="16" cy="10.5" r="0.9" fill="currentColor" stroke="none"/>`),

  executivo: wrap(`<path d="M4 20V9.5"/><path d="M10.5 20V4"/><path d="M17 20v-7"/><path d="M3.5 20h17"/><path d="M14.5 8.5l2.5-2.5 2 2 3-3"/>`),

  // Ícones da Academia de Produtos (redesign 2026-09-15 — nav de seção do
  // produto, materiais de download, cards de destaque) — mesmo estilo
  // hand-drawn acima, sem dependência nova.
  fileText: wrap(`<path d="M6 3.5h8l4 4V19a1.5 1.5 0 0 1-1.5 1.5h-11A1.5 1.5 0 0 1 4.5 19V5A1.5 1.5 0 0 1 6 3.5z"/><path d="M14 3.5V8h4"/><path d="M8 12.5h8M8 15.5h8M8 9.5h3"/>`),

  users: wrap(`<circle cx="9" cy="8" r="3.2"/><path d="M3.5 19.5c0-3 2.5-5.3 5.5-5.3s5.5 2.3 5.5 5.3"/><circle cx="17" cy="9" r="2.4"/><path d="M15.8 14.3c2.3 0.4 4 2.5 4 5.2"/>`),

  star: wrap(`<path d="M12 3.5l2.6 5.6 6 0.7-4.5 4.1 1.2 6-5.3-3-5.3 3 1.2-6-4.5-4.1 6-0.7z"/>`),

  zap: wrap(`<path d="M13 2 4 13h6l-1 9 9-11h-6z"/>`),

  scale: wrap(`<path d="M12 3v18M9 3h6"/><path d="M5 7h14"/><path d="M3 15a4 4 0 0 0 8 0L7 7z"/><path d="M13 15a4 4 0 0 0 8 0l-4-8z"/>`),

  message: wrap(`<path d="M12 3.5c-4.7 0-8.5 3.1-8.5 7 0 2.4 1.5 4.5 3.8 5.8L6 20l4-2c0.6 0.1 1.3 0.2 2 0.2 4.7 0 8.5-3.1 8.5-7s-3.8-7-8.5-7z"/>`),

  shield: wrap(`<path d="M12 3l7 3v5.5c0 5-3 8.5-7 9.5-4-1-7-4.5-7-9.5V6z"/><path d="M9 12l2 2 4-4.5"/>`),

  briefcase: wrap(`<rect x="3" y="7.5" width="18" height="12" rx="1.8"/><path d="M8.5 7.5V6a2 2 0 0 1 2-2h3a2 2 0 0 1 2 2v1.5"/><path d="M3 12.5h18"/><path d="M10.5 12.5v1.6h3v-1.6"/>`),

  helpCircle: wrap(`<circle cx="12" cy="12" r="8.5"/><path d="M9.3 9.6a2.8 2.8 0 0 1 5.4.9c0 1.7-2.2 2.2-2.6 3.7"/><path d="M12 17.2h.01" stroke-width="2.6"/>`),

  download: wrap(`<path d="M12 4v10.5M8 11l4 4 4-4"/><path d="M5 17.5v1.8A1.7 1.7 0 0 0 6.7 21h10.6a1.7 1.7 0 0 0 1.7-1.7v-1.8"/>`),

  award: wrap(`<circle cx="12" cy="9" r="5.5"/><path d="M9 13.5 7.5 20.5 12 18l4.5 2.5L15 13.5"/>`),

  link2: wrap(`<path d="M9.5 17H7.3a4.8 4.8 0 0 1 0-9.6H9.5"/><path d="M14.5 7.4h2.2a4.8 4.8 0 0 1 0 9.6h-2.2"/><path d="M8.5 12.2h7"/>`),

  image: wrap(`<rect x="3.5" y="4.5" width="17" height="15" rx="1.8"/><circle cx="8.5" cy="9.5" r="1.6"/><path d="M4 17l5-5 3.5 3.5L16 12l4.5 5.5"/>`),

  folder: wrap(`<path d="M3.5 7.5A1.8 1.8 0 0 1 5.3 5.7H9l2 2.3h7.7a1.8 1.8 0 0 1 1.8 1.8v8A1.8 1.8 0 0 1 18.7 19.6H5.3a1.8 1.8 0 0 1-1.8-1.8z"/>`),

  film: wrap(`<rect x="3" y="5.5" width="18" height="13" rx="1.8"/><path d="M10 9.3v5.4l4.6-2.7z" fill="currentColor" stroke="none"/>`),

  watch: wrap(`<circle cx="12" cy="12" r="6.5"/><path d="M12 9v3.3l2.2 1.3"/><path d="M9.3 5.3l.6-2.3h4.2l.6 2.3M9.3 18.7l.6 2.3h4.2l.6-2.3"/>`),

  search: wrap(`<circle cx="10.5" cy="10.5" r="6.5"/><path d="M19.5 19.5l-4.3-4.3"/>`),

  checkCircle: wrap(`<circle cx="12" cy="12" r="8.5"/><path d="M8 12.3l2.6 2.6 5.4-6"/>`),

  pencil: wrap(`<path d="M4 20l0.6-3.4L15.2 6a1.8 1.8 0 0 1 2.6 0l0.2 0.2a1.8 1.8 0 0 1 0 2.6L7.4 19.4z"/><path d="M13.5 7.7l2.8 2.8"/>`),

  // Ícones de blocos de conteúdo (2026-09-15) — troca os emoji fixos do
  // renderer de banner/roteiro/objeção (ContentBlocks.js) por ícones
  // monocromáticos, mesmo estilo dos demais.
  infoCircle: wrap(`<circle cx="12" cy="12" r="8.5"/><path d="M12 11v5.5" stroke-width="1.8"/><path d="M12 8h.01" stroke-width="2.6"/>`),

  alertTriangle: wrap(`<path d="M12 3.5 21.5 20h-19z"/><path d="M12 9.5v4.5" stroke-width="1.8"/><path d="M12 17h.01" stroke-width="2.6"/>`),

  lightbulb: wrap(`<path d="M9 18h6"/><path d="M10 21h4"/><path d="M12 3a6 6 0 0 0-3.5 10.9c0.6 0.45 1 1.15 1 1.9V16h5v-0.2c0-0.75 0.4-1.45 1-1.9A6 6 0 0 0 12 3z"/>`),

  clipboard: wrap(`<rect x="6" y="4.5" width="12" height="16" rx="1.8"/><rect x="9" y="2.5" width="6" height="3.5" rx="1"/><path d="M9 11h6M9 14.5h6" stroke-width="1.6"/>`),
  target: wrap(`<circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="4.7"/><circle cx="12" cy="12" r="1.3" fill="currentColor" stroke="none"/>`),
  dice: wrap(`<rect x="4" y="4" width="16" height="16" rx="3"/><circle cx="8.5" cy="8.5" r="1" fill="currentColor" stroke="none"/><circle cx="15.5" cy="8.5" r="1" fill="currentColor" stroke="none"/><circle cx="12" cy="12" r="1" fill="currentColor" stroke="none"/><circle cx="8.5" cy="15.5" r="1" fill="currentColor" stroke="none"/><circle cx="15.5" cy="15.5" r="1" fill="currentColor" stroke="none"/>`),
};

export function icon(name) {
  return ICONS[name] || '';
}
