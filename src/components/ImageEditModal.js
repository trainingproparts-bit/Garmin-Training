// src/components/ImageEditModal.js
// Modal genérico pra editar uma imagem única fora de um <form> (capa de
// trilha/quiz/duelo/biblioteca) — substitui os window.prompt('URL da imagem
// de capa...') espalhados por DashboardHome.js/GpsTrail.js/arenaDesafios.js.
// Mesmo padrão visual/estrutural de openPasswordModal (appShell.js): monta
// num root anexado a document.body, fecha via backdrop-click/Cancelar.

import { imageUploadFieldHtml, wireImageUploadField } from './ImageUploadField.js';

/**
 * @param {{ title: string, currentUrl?: string, folder: string, onSave: (url: string|null) => Promise<void> }} opts
 */
export function openImageEditModal({ title, currentUrl = '', folder, onSave }) {
  const root = document.createElement('div');
  root.innerHTML = `
    <div class="iuf-modal-backdrop" data-role="iuf-modal-backdrop">
      <div class="iuf-modal">
        <h3 class="iuf-modal-title">${title}</h3>
        <div data-role="iuf-modal-field"></div>
        <p class="iuf-status" data-role="iuf-modal-msg"></p>
        <div class="iuf-modal-actions">
          <button type="button" class="login-btn" data-role="iuf-modal-save" style="width:auto;">Salvar</button>
          <button type="button" class="cb-editor-btn" data-role="iuf-modal-cancel">Cancelar</button>
        </div>
      </div>
    </div>`;
  document.body.appendChild(root);

  const fieldWrap = root.querySelector('[data-role="iuf-modal-field"]');
  fieldWrap.innerHTML = imageUploadFieldHtml({ fieldName: 'image_url', currentUrl, folder });
  wireImageUploadField(fieldWrap);

  const close = () => root.remove();

  root.querySelector('[data-role="iuf-modal-backdrop"]').addEventListener('click', (e) => {
    if (e.target === e.currentTarget) close();
  });
  root.querySelector('[data-role="iuf-modal-cancel"]').addEventListener('click', close);

  root.querySelector('[data-role="iuf-modal-save"]').addEventListener('click', async () => {
    const url = fieldWrap.querySelector('[data-role="iuf-hidden-value"]').value.trim();
    const saveBtn = root.querySelector('[data-role="iuf-modal-save"]');
    const msgEl = root.querySelector('[data-role="iuf-modal-msg"]');
    saveBtn.disabled = true;
    msgEl.textContent = 'Salvando…';
    msgEl.classList.remove('iuf-status-error');
    try {
      await onSave(url || null);
      close();
    } catch (err) {
      console.error('[ImageEditModal] erro ao salvar:', err);
      msgEl.textContent = 'Não foi possível salvar agora.';
      msgEl.classList.add('iuf-status-error');
      saveBtn.disabled = false;
    }
  });
}
