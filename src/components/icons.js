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

  chevronDown: wrap(`<path d="M6 9l6 6 6-6"/>`),

  switchBrand: wrap(`<path d="M20 12H4"/><path d="M9 6l-5 6 5 6"/>`),

  academia: wrap(`<path d="M2 8.5 12 4l10 4.5-10 4.5-10-4.5z"/><path d="M6 10.7v5c0 1.4 2.7 2.8 6 2.8s6-1.4 6-2.8v-5"/><path d="M20 9v6.5"/>`),
};

export function icon(name) {
  return ICONS[name] || '';
}
