// src/components/LibraryContent.js
// Renderiza cada categoria da Biblioteca Técnica (content_library.payload).
// Os nomes de campo dentro de payload são os mesmos das arrays originais de
// index_redesign_v5.html (profiles/prods/faqs/comps/sports) — preservados
// tal qual na migração (sql/seeds/040_biblioteca_tecnica.sql) para não
// perder fidelidade ao conteúdo real.

import { updateContentItem } from '../services/contentLibraryService.js';
import { navigateToPanel } from '../router.js';
import { getCurrentProfile, isAdminProfile, isLeaderProfile } from '../config/supabase.js';
import { openImageEditModal } from './ImageEditModal.js';

export function renderLibrarySection(container, category, items, extra) {
  if (!items.length) {
    container.innerHTML = '<p class="learning-empty">Nenhum conteúdo cadastrado nesta categoria ainda.</p>';
    return;
  }

  const renderers = {
    perfil_cliente: (list) => renderPerfis(list, extra),
    produto: renderProdutos,
    faq: renderFaq,
    concorrente: renderConcorrentes,
    especialidade: renderEspecialidades,
    deep_dive: renderDeepDives,
  };

  const renderer = renderers[category];
  container.innerHTML = renderer ? renderer(items) : '<p class="learning-error">Categoria desconhecida.</p>';

  if (category === 'faq') wireAccordion(container);
  if (category === 'deep_dive') wireDeepDiveLinks(container);
  if (category === 'produto') wireProductDetails(container, items);
  if (category === 'perfil_cliente') {
    wireFlipCards(container);
    wirePersonaEdit(container, items, extra);
  }
}

/** Clique em qualquer lugar do card vira ele — mesmo mecanismo do bloco de conteúdo "Card Giratório" (ContentBlocks.js/cb-flip-card), sem depender de admin/líder. */
function wireFlipCards(container) {
  container.querySelectorAll('[data-flip-card]').forEach((card) => {
    card.addEventListener('click', () => card.classList.toggle('flipped'));
  });
}

/**
 * Ficha de consulta rápida do vendedor (pedido do usuário, 2026-09-15 —
 * antes disso essa tela era um bloco de texto com pouca hierarquia). Ordem
 * fixa PERFIL → IDENTIFICAÇÃO → PERGUNTA → RECOMENDAÇÃO → ARGUMENTO, igual
 * para os 11 perfis (mesmo componente, sem solução específica por persona).
 *
 * "Como apresentar" reaproveita o `dest` já cadastrado de cada produto no
 * catálogo (categoria `produto`, ver `extra.produtoByName` montado em
 * biblioteca.js) em vez de inventar uma descrição nova — se um produto citado
 * no perfil não existir no catálogo, o nome ainda aparece, só sem a linha de
 * destaque. Nada do payload original foi removido, só reorganizado
 * (objections/tags continuam intactos, só não têm um bloco dedicado aqui).
 *
 * A recomendação principal é um flip-card (pedido do usuário, 2026-09-15 —
 * a versão anterior usava fundo rosa/vermelho, que "parece erro"; e não
 * tinha onde colocar uma foto do produto). Frente: produto + espaço para
 * imagem (editável por admin/líder, reaproveitando o mesmo modal usado em
 * capas de trilha/quiz — ver ImageEditModal.js); verso: `comunicacao`
 * (gancho comercial), que antes vivia num bloco separado no rodapé. Mesmo
 * mecanismo de virar do "Card Giratório" de ContentBlocks.js.
 */
const PERSONA_STEPS = [
  'Identifique o esporte ou objetivo',
  'Faça a pergunta-chave',
  'Entenda o nível de experiência',
  'Apresente o produto principal',
  'Mostre uma alternativa quando fizer sentido',
];

function renderPersonaIntro() {
  return `
    <div class="lib-persona-intro">
      <h4 class="lib-persona-intro-title">Como usar os perfis</h4>
      <p class="lib-persona-intro-text">O perfil ajuda você a entender rapidamente o que o cliente pratica, o que procura e qual produto pode fazer mais sentido.</p>
      <ol class="lib-persona-intro-steps">${PERSONA_STEPS.map((s) => `<li>${s}</li>`).join('')}</ol>
    </div>`;
}

function renderPerfis(items, extra) {
  const produtoByName = extra?.produtoByName || new Map();

  return `${renderPersonaIntro()}
  <div class="lib-persona-grid">${items.map((item, index) => {
    const p = item.payload;
    const alternativas = (p.produtos || []).filter((nome) => nome !== p.primario);
    const acharProduto = (nome) => produtoByName.get((nome || '').toLowerCase());
    const primarioProduto = p.primario ? acharProduto(p.primario) : null;
    const coverUrl = primarioProduto?.payload?.cover_url || '';

    return `
      <article class="lib-persona-card" data-persona-index="${index}">
        <header class="lib-persona-head">
          <span class="lib-persona-emoji" aria-hidden="true">${p.emoji || ''}</span>
          <div class="lib-persona-head-text">
            <h3 class="lib-persona-name">${p.name || item.title}</h3>
            ${(p.tags || []).length ? `<div class="lib-persona-tags">${p.tags.map((t) => `<span class="lib-persona-tag-pill">${t}</span>`).join('')}</div>` : ''}
          </div>
          <button type="button" class="lib-edit-btn" data-persona-index="${index}" hidden>Editar</button>
        </header>

        <p class="lib-persona-desc">${p.tag || item.summary || ''}</p>

        <div class="lib-persona-section">
          <h4 class="lib-persona-label">Como identificar</h4>
          <ul class="lib-persona-signals">${(p.sinais || []).map((s) => `<li>${s}</li>`).join('')}</ul>
        </div>

        ${p.pergunta_chave ? `
          <div class="lib-persona-question">
            <span class="lib-persona-label">Pergunta-chave</span>
            <p>“${p.pergunta_chave}”</p>
          </div>
        ` : ''}

        <div class="lib-persona-section">
          <h4 class="lib-persona-label">Como apresentar</h4>

          ${p.primario ? `
            <div class="lib-persona-flip" data-flip-card data-product-id="${primarioProduto?.id || ''}">
              <div class="lib-persona-flip-inner">
                <div class="lib-persona-flip-face lib-persona-flip-front ${coverUrl ? 'has-cover' : ''}" ${coverUrl ? `style="background-image:url('${coverUrl}')"` : ''}>
                  <button type="button" class="lib-cover-edit-btn" data-edit-product-cover hidden>🖼️ Imagem</button>
                  <span class="lib-persona-product-kicker">Recomendação principal</span>
                  <span class="lib-persona-product-name">${p.primario}</span>
                  ${primarioProduto?.payload?.dest ? `<p class="lib-persona-product-blurb">${primarioProduto.payload.dest}</p>` : ''}
                  <span class="lib-persona-flip-hint">Toque para ver o argumento de venda →</span>
                </div>
                <div class="lib-persona-flip-face lib-persona-flip-back">
                  <span class="lib-persona-product-kicker">Gancho comercial</span>
                  ${(p.comunicacao || []).length
                    ? `<ul>${p.comunicacao.map((c) => `<li>${c}</li>`).join('')}</ul>`
                    : '<p class="lib-persona-product-blurb">Nenhum argumento cadastrado ainda.</p>'}
                  <span class="lib-persona-flip-hint">Toque para voltar</span>
                </div>
              </div>
            </div>
          ` : ''}

          ${alternativas.length ? `
            <div class="lib-persona-alts">
              <span class="lib-persona-alts-kicker">Alternativas</span>
              ${alternativas.map((nome) => `
                <div class="lib-persona-product lib-persona-product--alt">
                  <span class="lib-persona-product-name">${nome}</span>
                  ${acharProduto(nome)?.payload?.dest ? `<p class="lib-persona-product-blurb">${acharProduto(nome).payload.dest}</p>` : ''}
                </div>
              `).join('')}
            </div>
          ` : ''}
        </div>
      </article>`;
  }).join('')}</div>
  <div id="lib-persona-edit" class="lib-persona-edit" hidden></div>`;
}

function renderProdutos(items) {
  const rows = items.map((item, index) => {
    const p = item.payload;
    const dots = Array.from({ length: 5 }, (_, i) => `<div class="lib-dot ${i < (p.lvl || 0) ? 'on' : ''}"></div>`).join('');
    return `
      <tr class="lib-prod-row" data-prod-index="${index}" style="cursor: pointer;">
        <td><div class="lib-prod-name">${p.name || item.title}</div><span class="lib-prod-series">${p.s || ''}</span></td>
        <td><div class="lib-level-dots">${dots}</div></td>
        <td class="lib-prod-para">${p.para || ''}</td>
        <td class="lib-prod-dest">${p.dest || item.summary || ''}</td>
      </tr>`;
  }).join('');

  return `
    <div class="lib-table-wrap">
      <table class="lib-table">
        <thead><tr><th>Produto</th><th>Nível</th><th>Indicado para</th><th>Destaques</th></tr></thead>
        <tbody>${rows}</tbody>
      </table>
    </div>
    <div id="lib-prod-details" class="lib-prod-details" hidden></div>`;
}

function renderFaq(items) {
  return `<div class="lib-accordion">${items.map((item, i) => {
    const p = item.payload;
    return `
      <div class="lib-acc-item">
        <button type="button" class="lib-acc-btn" data-acc-target="faq-${i}">
          <span>❓ ${p.q || item.title}</span><span class="lib-acc-chevron">▼</span>
        </button>
        <div class="lib-acc-body" id="faq-${i}" hidden>${p.a || ''}</div>
      </div>`;
  }).join('')}</div>`;
}

function renderConcorrentes(items) {
  return `<div class="lib-comp-grid">${items.map((item) => {
    const c = item.payload;
    const rows = (c.rows || []).map((r) => `
      <tr><td class="lib-comp-aspect">${r.a}</td><td class="lib-comp-ours">${r.g}</td><td class="lib-comp-theirs">${r.t}</td></tr>
    `).join('');
    return `
      <div class="lib-comp-card">
        <div class="lib-comp-header"><span class="lib-comp-name">${c.name || item.title}</span><span class="lib-tag">${c.badge || ''}</span></div>
        <p class="lib-comp-desc">${c.desc || item.summary || ''}</p>
        <table class="lib-comp-table">
          <tr><th>Aspecto</th><th>✅ Garmin</th><th>○ ${c.name || ''}</th></tr>
          ${rows}
        </table>
      </div>`;
  }).join('')}</div>`;
}

function renderEspecialidades(items) {
  return `<div class="lib-sport-grid">${items.map((item) => {
    const s = item.payload;
    return `
      <div class="lib-sport-card">
        <div class="lib-sport-header"><span class="lib-sport-emoji">${s.emoji || ''}</span><span class="lib-sport-name">${s.name || item.title}</span></div>
        <div class="lib-metrics-wrap">${(s.metrics || []).map((m) => `<span class="lib-tag">${m}</span>`).join('')}</div>
      </div>`;
  }).join('')}</div>`;
}

function renderDeepDives(items) {
  return `<div class="lib-deepdive-list">${items.map((item) => `
    <button type="button" class="lib-deepdive-link" data-deepdive-slug="${item.slug}">
      <span>
        <span class="lib-deepdive-link-title">📘 ${item.title}</span>
        ${item.summary ? `<span class="lib-deepdive-link-summary">${item.summary}</span>` : ''}
      </span>
      <span class="lib-deepdive-link-arrow">→</span>
    </button>`).join('')}</div>`;
}

function wireDeepDiveLinks(container) {
  container.querySelectorAll('[data-deepdive-slug]').forEach((btn) => {
    btn.addEventListener('click', () => {
      window.selectedDeepDiveSlug = btn.dataset.deepdiveSlug;
      window.deepDiveReturnPanel = 'biblioteca';
      navigateToPanel('deep-dive-detail');
    });
  });
}

function wireAccordion(container) {
  container.querySelectorAll('[data-acc-target]').forEach((btn) => {
    btn.addEventListener('click', () => {
      const body = container.querySelector(`#${CSS.escape(btn.dataset.accTarget)}`);
      if (!body) return;
      body.hidden = !body.hidden;
      btn.classList.toggle('open', !body.hidden);
    });
  });
}

function wireProductDetails(container, items) {
  const detailsEl = container.querySelector('#lib-prod-details');
  if (!detailsEl) return;

  container.querySelectorAll('.lib-prod-row').forEach((row) => {
    row.addEventListener('click', () => {
      const index = parseInt(row.dataset.prodIndex, 10);
      const item = items[index];
      if (!item) return;

      const p = item.payload;
      detailsEl.innerHTML = `
        <div style="background: var(--white); border: 1px solid var(--border); border-radius: var(--r3); padding: 20px; margin-top: 16px;">
          <h3 style="margin: 0 0 12px; font-size: 18px; color: var(--text);">${p.name || item.title}</h3>
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; margin-bottom: 16px;">
            <div><strong>Série:</strong> ${p.s || '-'}</div>
            <div><strong>Categoria:</strong> ${p.cat || '-'}</div>
            <div><strong>Nível:</strong> ${p.lvl || '-'}</div>
            <div><strong>Indicado para:</strong> ${p.para || '-'}</div>
          </div>
          <div style="margin-bottom: 16px;">
            <strong>Destaques:</strong>
            <p style="margin: 4px 0 0; color: var(--text2);">${p.dest || item.summary || '-'}</p>
          </div>
          <div style="font-size: 12px; color: var(--text3);">
            <strong>Dados brutos do payload:</strong>
            <pre style="background: var(--off); padding: 8px; border-radius: var(--r2); margin: 8px 0 0; overflow-x: auto;">${JSON.stringify(p, null, 2)}</pre>
          </div>
          <button type="button" style="margin-top: 12px; padding: 8px 16px; background: var(--off); border: 1px solid var(--border); border-radius: var(--r2); cursor: pointer;" onclick="document.getElementById('lib-prod-details').hidden = true;">Fechar</button>
        </div>
      `;
      detailsEl.hidden = false;
    });
  });
}

/**
 * "Editar" na Biblioteca Técnica é admin/líder, não Colaborador — o botão
 * vem `hidden` desde a renderização (renderPerfis) e só reaparece aqui,
 * depois de confirmar o papel. Bug real corrigido (2026-07-24): antes disso
 * o botão aparecia pra qualquer um sem checagem nenhuma, e um colaborador
 * comum (RN: "William") conseguiu abrir e submeter o formulário de edição.
 */
async function wirePersonaEdit(container, items, extra) {
  const editEl = container.querySelector('#lib-persona-edit');
  if (!editEl) return;

  const profile = await getCurrentProfile();
  const canEdit = profile && (isAdminProfile(profile) || isLeaderProfile(profile));
  if (!canEdit) return;

  container.querySelectorAll('.lib-edit-btn').forEach((btn) => {
    btn.hidden = false;
  });

  container.querySelectorAll('[data-edit-product-cover]').forEach((btn) => {
    btn.hidden = false;
    btn.addEventListener('click', (e) => {
      e.stopPropagation(); // não pode virar o flip-card ao clicar no botão
      const flipCard = btn.closest('[data-flip-card]');
      const productId = flipCard?.dataset.productId;
      if (!productId) return;
      const produto = (extra?.produtoByName ? [...extra.produtoByName.values()] : []).find((it) => it.id === productId);
      if (!produto) return;

      openImageEditModal({
        title: `Imagem — ${produto.payload.name || produto.title}`,
        currentUrl: produto.payload.cover_url || '',
        folder: 'covers/produtos',
        onSave: async (url) => {
          const updatedPayload = { ...produto.payload, cover_url: url || '' };
          await updateContentItem(produto.id, { payload: updatedPayload });
          produto.payload = updatedPayload;
          renderLibrarySection(container, 'perfil_cliente', items, extra);
        },
      });
    });
  });

  container.querySelectorAll('.lib-edit-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
      const index = parseInt(btn.dataset.personaIndex, 10);
      const item = items[index];
      if (!item) return;

      const p = item.payload;
      editEl.innerHTML = `
        <div style="background: var(--white); border: 1px solid var(--border); border-radius: var(--r3); padding: 20px; margin-top: 16px;">
          <h3 style="margin: 0 0 16px; font-size: 18px; color: var(--text);">Editar Persona: ${p.name || item.title}</h3>
          <form id="persona-edit-form">
            <div style="margin-bottom: 12px;">
              <label style="display: block; margin-bottom: 4px; font-size: 13px; font-weight: 600; color: var(--text);">Nome:</label>
              <input type="text" name="name" value="${p.name || ''}" style="width: 100%; padding: 8px; border: 1px solid var(--border); border-radius: var(--r2); font-size: 14px;">
            </div>
            <div style="margin-bottom: 12px;">
              <label style="display: block; margin-bottom: 4px; font-size: 13px; font-weight: 600; color: var(--text);">Tag:</label>
              <input type="text" name="tag" value="${p.tag || ''}" style="width: 100%; padding: 8px; border: 1px solid var(--border); border-radius: var(--r2); font-size: 14px;">
            </div>
            <div style="margin-bottom: 12px;">
              <label style="display: block; margin-bottom: 4px; font-size: 13px; font-weight: 600; color: var(--text);">Emoji:</label>
              <input type="text" name="emoji" value="${p.emoji || ''}" style="width: 100%; padding: 8px; border: 1px solid var(--border); border-radius: var(--r2); font-size: 14px;">
            </div>
            <div style="margin-bottom: 12px;">
              <label style="display: block; margin-bottom: 4px; font-size: 13px; font-weight: 600; color: var(--text);">Pergunta-chave (o que perguntar para confirmar o perfil):</label>
              <input type="text" name="pergunta_chave" value="${p.pergunta_chave || ''}" style="width: 100%; padding: 8px; border: 1px solid var(--border); border-radius: var(--r2); font-size: 14px;">
            </div>
            <div style="margin-bottom: 12px;">
              <label style="display: block; margin-bottom: 4px; font-size: 13px; font-weight: 600; color: var(--text);">Produto Primário:</label>
              <input type="text" name="primario" value="${p.primario || ''}" style="width: 100%; padding: 8px; border: 1px solid var(--border); border-radius: var(--r2); font-size: 14px;">
            </div>
            <div style="margin-bottom: 12px;">
              <label style="display: block; margin-bottom: 4px; font-size: 13px; font-weight: 600; color: var(--text);">Produtos (separados por vírgula):</label>
              <input type="text" name="produtos" value="${(p.produtos || []).join(', ')}" style="width: 100%; padding: 8px; border: 1px solid var(--border); border-radius: var(--r2); font-size: 14px;">
            </div>
            <div style="margin-bottom: 16px;">
              <label style="display: block; margin-bottom: 4px; font-size: 13px; font-weight: 600; color: var(--text);">Sinais de identificação (um por linha):</label>
              <textarea name="sinais" rows="4" style="width: 100%; padding: 8px; border: 1px solid var(--border); border-radius: var(--r2); font-size: 14px;">${(p.sinais || []).join('\n')}</textarea>
            </div>
            <div style="display: flex; gap: 8px;">
              <button type="submit" style="padding: 8px 16px; background: var(--g); color: #fff; border: none; border-radius: var(--r2); cursor: pointer; font-size: 13px;">Salvar</button>
              <button type="button" id="cancel-edit" style="padding: 8px 16px; background: var(--off); border: 1px solid var(--border); border-radius: var(--r2); cursor: pointer; font-size: 13px;">Cancelar</button>
            </div>
            <div id="edit-message" style="margin-top: 12px; font-size: 13px;"></div>
          </form>
        </div>
      `;
      editEl.hidden = false;

      const form = editEl.querySelector('#persona-edit-form');
      const cancelBtn = editEl.querySelector('#cancel-edit');
      const messageEl = editEl.querySelector('#edit-message');

      cancelBtn.addEventListener('click', () => {
        editEl.hidden = true;
      });

      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        messageEl.textContent = 'Salvando...';
        messageEl.style.color = 'var(--text3)';

        try {
          const formData = new FormData(form);
          const updatedPayload = { ...p };
          updatedPayload.name = formData.get('name');
          updatedPayload.tag = formData.get('tag');
          updatedPayload.emoji = formData.get('emoji');
          updatedPayload.pergunta_chave = formData.get('pergunta_chave');
          updatedPayload.primario = formData.get('primario');
          updatedPayload.produtos = formData.get('produtos').split(',').map(s => s.trim()).filter(s => s);
          updatedPayload.sinais = formData.get('sinais').split('\n').map(s => s.trim()).filter(s => s);

          await updateContentItem(item.id, { payload: updatedPayload });
          
          messageEl.textContent = 'Persona atualizada com sucesso!';
          messageEl.style.color = 'var(--acc)';
          
          items[index].payload = updatedPayload;
          
          setTimeout(() => {
            editEl.hidden = true;
            renderLibrarySection(container, 'perfil_cliente', items);
            wirePersonaEdit(container, items);
          }, 1000);
        } catch (err) {
          console.error('[Persona Edit] erro ao salvar:', err);
          messageEl.textContent = 'Erro ao salvar: ' + err.message;
          messageEl.style.color = 'var(--g)';
        }
      });
    });
  });
}
