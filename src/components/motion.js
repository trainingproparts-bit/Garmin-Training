// src/components/motion.js
// Orquestração das animações de entrada e microinterações (ver
// src/styles/motion.css). JS puro, sem dependência nova.
//
// Por que um módulo separado: Dashboard e Trilha Completa montam conteúdo em
// etapas (o esqueleto entra primeiro, os cards de Destaques/Atividades/
// Novidades chegam depois, cada um no seu await). Um observador central que
// aceita ser chamado várias vezes evita que cada página reinvente o controle
// de "o que já foi revelado".

/** Marca que o JS está vivo — só então o CSS esconde o que vai ser revelado. */
document.documentElement.classList.add('js-motion');

const prefersReducedMotion = () =>
  window.matchMedia('(prefers-reduced-motion: reduce)').matches;

let observer = null;

function getObserver() {
  if (observer) return observer;

  observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      reveal(entry.target);
      observer.unobserve(entry.target);
    });
  }, {
    // Revela um pouco antes de entrar de fato na tela, pra animação não
    // começar só depois que o elemento já está visível.
    rootMargin: '0px 0px -8% 0px',
    threshold: 0.01,
  });

  return observer;
}

function reveal(el) {
  el.classList.add('is-revealed');
  // Libera o will-change quando a transição termina (ver motion.css).
  el.addEventListener('transitionend', () => el.classList.add('reveal-done'), { once: true });
}

/**
 * Prepara os elementos marcados com [data-reveal] dentro de `root`, dando a
 * cada um um atraso progressivo, e passa a observá-los.
 *
 * Chamar de novo depois de inserir conteúdo novo é seguro: quem já foi
 * preparado carrega `data-reveal-ready` e é ignorado.
 *
 * @param {ParentNode} root
 * @param {{stagger?: number, base?: number}} [options] atraso por item e
 *   atraso inicial do grupo, ambos em segundos.
 */
export function setupReveal(root = document, options = {}) {
  if (!root) return;
  revealElements(Array.from(root.querySelectorAll('[data-reveal]')), options);
}

/**
 * Mesma coisa que setupReveal, mas recebendo a lista pronta. Útil quando a
 * cascata precisa ser calculada por grupo em vez de na ordem global do DOM
 * (ex.: cada zona da Trilha escalona os próprios cards, senão o último card
 * da página herdaria um atraso de mais de um segundo).
 *
 * @param {Element[]} elements
 * @param {{stagger?: number, base?: number}} [options]
 */
export function revealElements(elements, { stagger = 0.04, base = 0 } = {}) {
  const targets = (elements || []).filter((el) => el && !el.dataset.revealReady);
  if (!targets.length) return;

  targets.forEach((el, i) => {
    el.dataset.revealReady = '1';

    if (prefersReducedMotion()) {
      el.classList.add('is-revealed', 'reveal-done');
      return;
    }

    el.style.setProperty('--reveal-delay', `${(base + i * stagger).toFixed(3)}s`);
    getObserver().observe(el);
  });
}

/**
 * Anima as barras de progresso de 0% até a largura já escrita no style
 * inline pelo render (transição definida em motion.css).
 *
 * @param {ParentNode} root
 */
export function animateProgressFills(root = document) {
  if (!root) return;

  root.querySelectorAll('[data-animate-progress]').forEach((el) => {
    if (el.dataset.progressAnimated) return;
    el.dataset.progressAnimated = '1';

    const target = el.style.width;
    if (!target || prefersReducedMotion()) return;

    el.style.transition = 'none';
    el.style.width = '0%';
    void el.offsetWidth; // força o navegador a assumir o 0% antes de animar
    el.style.transition = '';

    requestAnimationFrame(() => { el.style.width = target; });
  });
}

/**
 * Embrulha a seta final do texto de um botão num <span class="btn-arrow">,
 * pra o CSS ter o que deslocar no hover. Sem isso a seta é só um caractere
 * no meio do texto, sem elemento próprio.
 *
 * @param {ParentNode} root
 */
export function wrapButtonArrows(root = document) {
  if (!root) return;

  const ARROW = /([➔→←])\s*$/;

  root.querySelectorAll('.dash-btn-continue, .dash-revisao-btn, .dash-trail-toggle-full, .special-line-card-cta')
    .forEach((el) => {
      if (el.querySelector('.btn-arrow')) return;

      const last = el.lastChild;
      if (!last || last.nodeType !== Node.TEXT_NODE) return;

      const match = last.textContent.match(ARROW);
      if (!match) return;

      last.textContent = last.textContent.replace(ARROW, '');
      const span = document.createElement('span');
      span.className = 'btn-arrow';
      span.textContent = match[1];
      el.appendChild(span);
    });
}

/**
 * Chacoalha o card de etapa bloqueada ao passar o mouse ou clicar, como
 * aviso de que ele ainda não é o passo atual. O card continua clicável de
 * propósito (navegação livre é decisão antiga do projeto) — ver comentário
 * em motion.css.
 *
 * @param {ParentNode} root
 */
export function wireLockedCardShake(root = document) {
  if (!root) return;

  root.querySelectorAll('.phase-card.locked').forEach((card) => {
    if (card.dataset.shakeWired) return;
    card.dataset.shakeWired = '1';

    const shake = () => {
      if (prefersReducedMotion() || card.classList.contains('shake')) return;
      card.classList.add('shake');
      card.addEventListener('animationend', () => card.classList.remove('shake'), { once: true });
    };

    card.addEventListener('mouseenter', shake);
    card.addEventListener('click', shake);
  });
}

/**
 * Esmaece o painel atual antes de trocar de tela. Devolve uma Promise que
 * resolve quando o fade termina, pra quem chamou navegar em seguida.
 *
 * @param {HTMLElement} panel
 * @returns {Promise<void>}
 */
export function fadeOutPanel(panel) {
  if (!panel || prefersReducedMotion()) return Promise.resolve();

  panel.classList.add('is-leaving');

  return new Promise((resolve) => {
    let done = false;
    const finish = () => {
      if (done) return;
      done = true;
      panel.classList.remove('is-leaving');
      resolve();
    };

    panel.addEventListener('transitionend', finish, { once: true });
    // Rede de segurança: se a transição não disparar (painel já oculto, por
    // exemplo), não trava a navegação.
    setTimeout(finish, 220);
  });
}
