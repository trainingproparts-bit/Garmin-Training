// src/components/ImageUploadField.js
// Widget reutilizável de upload de imagem — substitui, em todos os pontos da
// plataforma onde hoje se cola uma URL externa, um fluxo de: preview →
// enviar arquivo → substituir/remover, com opção de colar URL manualmente
// (mantém o caminho antigo disponível, de graça, já que o campo final
// continua sendo só uma string de URL).
//
// Termina sempre num <input type="hidden"> com `name` E `data-field` iguais
// a `fieldName` — cobre os dois padrões de leitura já usados no projeto:
// `new FormData(form).get(name)` (formulários com <form>, ex.: blog.js) e
// `container.querySelector('[data-field="x"]').value` (editores inline sem
// <form>, ex.: produtoDetail.js). Handlers de submit existentes não mudam.
//
// Uso:
//   container.innerHTML = imageUploadFieldHtml({ fieldName: 'banner_url', currentUrl: post.banner_url, folder: 'covers/blog' });
//   wireImageUploadField(container.querySelector('[data-role="iuf-root"]'));

import { uploadContentImage } from '../services/storageService.js';

let instanceCounter = 0;

/**
 * @param {{ fieldName: string, currentUrl?: string, folder: string, label?: string }} opts
 * @returns {string}
 */
export function imageUploadFieldHtml({ fieldName, currentUrl = '', folder, label = '' }) {
  const id = `iuf-${++instanceCounter}`;
  const hasImage = !!currentUrl;
  return `
    <div class="iuf" data-role="iuf-root" data-folder="${folder}">
      ${label ? `<span class="iuf-label">${label}</span>` : ''}
      <div class="iuf-preview-wrap" data-role="iuf-preview-wrap">
        ${hasImage
          ? `<img src="${currentUrl}" alt="" class="iuf-preview-img">`
          : `<div class="iuf-preview-empty">Nenhuma imagem</div>`}
      </div>
      <div class="iuf-actions">
        <button type="button" class="iuf-btn" data-role="iuf-upload-btn">${hasImage ? 'Substituir' : 'Enviar imagem'}</button>
        <button type="button" class="iuf-btn iuf-btn-danger" data-role="iuf-remove-btn" ${hasImage ? '' : 'hidden'}>Remover</button>
        <button type="button" class="iuf-link-btn" data-role="iuf-url-toggle-btn">ou colar uma URL</button>
      </div>
      <input type="file" accept="image/jpeg,image/png,image/webp,image/gif" data-role="iuf-file-input" hidden id="${id}">
      <div class="iuf-url-row" data-role="iuf-url-row" hidden>
        <input type="text" class="iuf-url-input" data-role="iuf-url-input" placeholder="https://..." value="${hasImage ? currentUrl : ''}">
        <button type="button" class="iuf-btn" data-role="iuf-url-apply-btn">Usar esta URL</button>
      </div>
      <p class="iuf-status" data-role="iuf-status"></p>
      <input type="hidden" name="${fieldName}" data-field="${fieldName}" data-role="iuf-hidden-value" value="${currentUrl}">
    </div>`;
}

/**
 * Liga o comportamento do widget já inserido no DOM.
 * @param {HTMLElement} root - o próprio elemento [data-role="iuf-root"], ou um ancestral que o contenha
 * @param {{ onChange?: (url: string) => void }} [opts]
 */
export function wireImageUploadField(root, { onChange } = {}) {
  const widget = root?.matches?.('[data-role="iuf-root"]') ? root : root?.querySelector('[data-role="iuf-root"]');
  if (!widget) return;

  const folder = widget.dataset.folder;
  const previewWrap = widget.querySelector('[data-role="iuf-preview-wrap"]');
  const fileInput = widget.querySelector('[data-role="iuf-file-input"]');
  const hiddenInput = widget.querySelector('[data-role="iuf-hidden-value"]');
  const uploadBtn = widget.querySelector('[data-role="iuf-upload-btn"]');
  const removeBtn = widget.querySelector('[data-role="iuf-remove-btn"]');
  const statusEl = widget.querySelector('[data-role="iuf-status"]');
  const urlToggleBtn = widget.querySelector('[data-role="iuf-url-toggle-btn"]');
  const urlRow = widget.querySelector('[data-role="iuf-url-row"]');
  const urlInput = widget.querySelector('[data-role="iuf-url-input"]');
  const urlApplyBtn = widget.querySelector('[data-role="iuf-url-apply-btn"]');

  function setValue(url) {
    hiddenInput.value = url || '';
    previewWrap.innerHTML = url
      ? `<img src="${url}" alt="" class="iuf-preview-img">`
      : `<div class="iuf-preview-empty">Nenhuma imagem</div>`;
    removeBtn.hidden = !url;
    uploadBtn.textContent = url ? 'Substituir' : 'Enviar imagem';
    if (onChange) onChange(url || '');
  }

  uploadBtn.addEventListener('click', () => fileInput.click());

  fileInput.addEventListener('change', async () => {
    const file = fileInput.files?.[0];
    fileInput.value = ''; // permite selecionar o mesmo arquivo de novo depois, se precisar
    if (!file) return;

    statusEl.textContent = 'Enviando…';
    statusEl.classList.remove('iuf-status-error');
    uploadBtn.disabled = true;

    try {
      const url = await uploadContentImage(file, folder);
      setValue(url);
      statusEl.textContent = 'Imagem enviada.';
      setTimeout(() => { statusEl.textContent = ''; }, 2500);
    } catch (err) {
      console.error('[ImageUploadField] erro ao enviar imagem:', err);
      statusEl.textContent = err.message || 'Não foi possível enviar a imagem agora.';
      statusEl.classList.add('iuf-status-error');
    } finally {
      uploadBtn.disabled = false;
    }
  });

  removeBtn.addEventListener('click', () => {
    setValue('');
    urlInput.value = '';
  });

  urlToggleBtn.addEventListener('click', () => {
    urlRow.hidden = !urlRow.hidden;
  });

  urlApplyBtn.addEventListener('click', () => {
    setValue(urlInput.value.trim());
    urlRow.hidden = true;
    statusEl.textContent = '';
    statusEl.classList.remove('iuf-status-error');
  });
}
