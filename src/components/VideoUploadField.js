// src/components/VideoUploadField.js
// Widget de upload de vídeo — mesmo padrão de ImageUploadField.js (preview →
// enviar arquivo → substituir/remover, com opção de colar URL manualmente).
// A URL manual continua servindo pra embed de YouTube/Vimeo (iframe), que já
// funcionava antes; o upload de arquivo é a via nova, direto pro Storage
// (bucket 'lesson-media', ver sql/136 e storageService.js).
//
// Mesmo contrato de <input type="hidden"> com `name` e `data-field` do
// ImageUploadField — ver leitura em ContentBlocks.js (readBlockFromRow).
//
// Uso:
//   container.innerHTML = videoUploadFieldHtml({ fieldName: 'videoUrl', currentUrl: block.videoUrl, folder: 'blocks/licoes' });
//   wireVideoUploadField(container.querySelector('[data-role="vuf-root"]'));

import { uploadContentVideo } from '../services/storageService.js';

let instanceCounter = 0;

/** Vídeo enviado pro nosso Storage tem extensão de arquivo reconhecível na URL; embed (YouTube/Vimeo) não. */
function isDirectVideoUrl(url) {
  return /\.(mp4|webm|mov|ogv|ogg)(\?|$)/i.test(url || '');
}

/**
 * @param {{ fieldName: string, currentUrl?: string, folder: string, label?: string }} opts
 * @returns {string}
 */
export function videoUploadFieldHtml({ fieldName, currentUrl = '', folder, label = '' }) {
  const id = `vuf-${++instanceCounter}`;
  const hasVideo = !!currentUrl;
  const isDirect = isDirectVideoUrl(currentUrl);
  return `
    <div class="iuf" data-role="vuf-root" data-folder="${folder}">
      ${label ? `<span class="iuf-label">${label}</span>` : ''}
      <div class="iuf-preview-wrap" data-role="vuf-preview-wrap">
        ${hasVideo
          ? (isDirect
            ? `<video src="${currentUrl}" class="iuf-preview-img" controls></video>`
            : `<div class="iuf-preview-empty">Vídeo embed (URL externa)</div>`)
          : `<div class="iuf-preview-empty">Nenhum vídeo</div>`}
      </div>
      <div class="iuf-actions">
        <button type="button" class="iuf-btn" data-role="vuf-upload-btn">${hasVideo ? 'Substituir' : 'Enviar vídeo'}</button>
        <button type="button" class="iuf-btn iuf-btn-danger" data-role="vuf-remove-btn" ${hasVideo ? '' : 'hidden'}>Remover</button>
        <button type="button" class="iuf-link-btn" data-role="vuf-url-toggle-btn">ou colar uma URL de embed (YouTube/Vimeo)</button>
      </div>
      <input type="file" accept="video/mp4,video/webm,video/quicktime,video/ogg" data-role="vuf-file-input" hidden id="${id}">
      <div class="iuf-url-row" data-role="vuf-url-row" hidden>
        <input type="text" class="iuf-url-input" data-role="vuf-url-input" placeholder="https://www.youtube.com/embed/..." value="${!isDirect ? currentUrl : ''}">
        <button type="button" class="iuf-btn" data-role="vuf-url-apply-btn">Usar esta URL</button>
      </div>
      <p class="iuf-status" data-role="vuf-status"></p>
      <input type="hidden" name="${fieldName}" data-field="${fieldName}" data-role="vuf-hidden-value" value="${currentUrl}">
    </div>`;
}

/**
 * Liga o comportamento do widget já inserido no DOM.
 * @param {HTMLElement} root - o próprio elemento [data-role="vuf-root"], ou um ancestral que o contenha
 */
export function wireVideoUploadField(root) {
  const widget = root?.matches?.('[data-role="vuf-root"]') ? root : root?.querySelector('[data-role="vuf-root"]');
  if (!widget) return;

  const folder = widget.dataset.folder;
  const previewWrap = widget.querySelector('[data-role="vuf-preview-wrap"]');
  const fileInput = widget.querySelector('[data-role="vuf-file-input"]');
  const hiddenInput = widget.querySelector('[data-role="vuf-hidden-value"]');
  const uploadBtn = widget.querySelector('[data-role="vuf-upload-btn"]');
  const removeBtn = widget.querySelector('[data-role="vuf-remove-btn"]');
  const statusEl = widget.querySelector('[data-role="vuf-status"]');
  const urlToggleBtn = widget.querySelector('[data-role="vuf-url-toggle-btn"]');
  const urlRow = widget.querySelector('[data-role="vuf-url-row"]');
  const urlInput = widget.querySelector('[data-role="vuf-url-input"]');
  const urlApplyBtn = widget.querySelector('[data-role="vuf-url-apply-btn"]');

  function setValue(url) {
    hiddenInput.value = url || '';
    const isDirect = isDirectVideoUrl(url);
    previewWrap.innerHTML = url
      ? (isDirect
        ? `<video src="${url}" class="iuf-preview-img" controls></video>`
        : `<div class="iuf-preview-empty">Vídeo embed (URL externa)</div>`)
      : `<div class="iuf-preview-empty">Nenhum vídeo</div>`;
    removeBtn.hidden = !url;
    uploadBtn.textContent = url ? 'Substituir' : 'Enviar vídeo';
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
      const url = await uploadContentVideo(file, folder);
      setValue(url);
      statusEl.textContent = 'Vídeo enviado.';
      setTimeout(() => { statusEl.textContent = ''; }, 2500);
    } catch (err) {
      console.error('[VideoUploadField] erro ao enviar vídeo:', err);
      statusEl.textContent = err.message || 'Não foi possível enviar o vídeo agora.';
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
