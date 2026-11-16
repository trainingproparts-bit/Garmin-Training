import * as training from '../services/partnerTrainingService.js';
import { supabase } from '../config/supabase.js';
import { renderBlocks, wireBlockInteractions } from '../components/ContentBlocks.js';

export const escapeTraining = (value) => String(value ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
export function trainingUrl(value) { try { const u = new URL(value); return ['https:', 'http:'].includes(u.protocol) ? u.href : ''; } catch { return ''; } }
export const trainingDate = (date) => date ? new Intl.DateTimeFormat('pt-BR', {dateStyle:'long'}).format(new Date(`${date.slice(0,10)}T12:00:00`)) : '';
let participant = null;
let events = [];
let activeEvent = null;
let answers = {};
let request = 0;

window.addEventListener('panel:activated', e => { if (e.detail.panelId === 'partner-training') initPartnerTraining(); });

async function initPartnerTraining() {
  const root = document.getElementById('partnerTrainingContainer');
  if (!root) return;
  root.innerHTML = '<p class="learning-loading">Carregando treinamentos…</p>';
  try {
    participant = await training.getParticipant();
    const eventId = new URLSearchParams(location.search).get('treinamento');
    const directEvent = eventId ? await training.getTrainingEvent(eventId) : null;
    if (participant) {
      events = await training.listTrainingEvents(participant.partner_company_id);
      await showEvent(root, events.find(e => e.id === directEvent?.id) || events[0]);
    } else if (directEvent && new URLSearchParams(location.search).get('preview') === '1') {
      const {data: {user}} = await supabase.auth.getUser();
      if (user && !user.is_anonymous) { events = [directEvent]; await showEvent(root, directEvent); return; }
      await showEntry(root, directEvent);
    } else await showEntry(root, directEvent);
  } catch (err) {
    root.innerHTML = `<div class="pt-empty"><h2>Não foi possível abrir o treinamento</h2><p>${escapeTraining(err.message)}</p><button type="button" class="pt-primary" id="ptRetry">Tentar novamente</button><button type="button" class="pt-button" data-back-to="login">Voltar ao login</button></div>`;
    root.querySelector('#ptRetry').onclick = initPartnerTraining;
  }
}

async function showEntry(root, directEvent) {
  const companies = await training.listPartnerCompanies();
  root.innerHTML = `<div class="pt-entry"><button class="pt-back" type="button" data-back-to="login">← Voltar ao login</button><section class="pt-entry-card"><img class="pt-brand" src="/logo-preto.png" alt="Proparts"><span class="pt-eyebrow">GARMIN · TRAINING HUB</span><h1>Seu próximo passo<br>começa aqui.</h1><p class="pt-muted">Acesse os materiais e o questionário do seu treinamento, sem senha.</p>${directEvent ? `<div class="pt-callout"><strong>${escapeTraining(directEvent.title)}</strong><br>${trainingDate(directEvent.training_date)}</div>` : ''}<form id="ptEntryForm" class="pt-form"><label>Empresa ou loja<select name="partner_company_id" required><option value="">Selecione sua empresa</option>${companies.map(c => `<option value="${c.id}" ${c.id === directEvent?.partner_company_id ? 'selected' : ''}>${escapeTraining(c.name)}</option>`).join('')}</select></label><label>Nome completo<input name="full_name" autocomplete="name" minlength="2" maxlength="120" required placeholder="Como podemos chamar você?"></label><label>E-mail<input name="email" type="email" autocomplete="email" maxlength="254" required placeholder="Seu e-mail corporativo, se tiver"></label><p class="pt-fine">Seus dados e respostas serão usados no acompanhamento deste treinamento e no relatório enviado à gestão da sua empresa.</p><p role="alert" class="pt-error" id="ptEntryError" hidden></p><button class="pt-primary" type="submit">Acessar treinamento →</button></form></section></div>`;
  root.querySelector('#ptEntryForm').onsubmit = async e => {
    e.preventDefault();
    const form = e.currentTarget;
    const button = form.querySelector('[type="submit"]');
    const error = root.querySelector('#ptEntryError');
    button.disabled = true; button.textContent = 'Abrindo treinamento…'; error.hidden = true;
    try {
      participant = await training.registerParticipant(Object.fromEntries(new FormData(form)));
      events = await training.listTrainingEvents(participant.partner_company_id);
      await showEvent(root, events.find(ev => ev.id === directEvent?.id) || events[0]);
    } catch (err) { error.textContent = err.message; error.hidden = false; button.disabled = false; button.textContent = 'Acessar treinamento →'; }
  };
}

async function showEvent(root, event) {
  const turn = ++request;
  activeEvent = event || null;
  answers = {};
  if (!event) {
    root.innerHTML = `<div class="pt-empty"><img class="pt-brand" src="/logo-preto.png" alt="Proparts"><h1>Seu treinamento está chegando</h1><p>Ainda não há treinamentos publicados para sua empresa. Volte em breve.</p><button type="button" class="pt-button" id="ptLeave">Trocar participante</button></div>`;
    wireLeave(root); return;
  }
  root.innerHTML = '<p class="learning-loading">Abrindo materiais e questionário…</p>';
  const [questions, materials, submission] = await Promise.all([training.getTrainingQuestions(event.id), training.getTrainingMaterials(event.id), participant ? training.getMyTrainingSubmission(event.id) : null]);
  if (turn !== request) return;
  try { answers = JSON.parse(sessionStorage.getItem(`pt-answers-${event.id}`) || '{}'); } catch { answers = {}; }
  const cover = trainingUrl(event.cover_url);
  const logo = trainingUrl(event.logo_url);
  root.innerHTML = `<div class="pt-landing"><header class="pt-top"><img class="pt-brand" src="/logo-preto.png" alt="Proparts"><div>${participant ? `<span class="pt-greeting">Olá, ${escapeTraining(participant.full_name)}.</span><button type="button" class="pt-back" id="ptLeave">Trocar participante</button>` : '<button type="button" class="pt-back" data-back-to="partner-training-admin">← Voltar à gestão</button>'}</div></header><section class="pt-hero ${cover ? 'pt-hero-image' : ''}">${cover ? `<img class="pt-cover" src="${escapeTraining(cover)}" alt="">` : ''}<div class="pt-hero-copy"><span class="pt-eyebrow">TREINAMENTO GARMIN</span><h1>${escapeTraining(event.title)}</h1><p>${escapeTraining(event.description || 'Conhecimento para transformar cada atendimento.')}</p><span class="pt-date">${trainingDate(event.training_date)}</span></div>${logo ? `<div class="pt-partner-logo"><img src="${escapeTraining(logo)}" alt="Empresa parceira"></div>` : ''}</section><div class="pt-training-picker"><label for="ptEventSelect">Treinamentos da sua empresa</label><select id="ptEventSelect">${events.map(ev => `<option value="${ev.id}" ${ev.id === event.id ? 'selected' : ''}>${trainingDate(ev.training_date)} · ${escapeTraining(ev.title)}</option>`).join('')}</select></div>${!participant ? '<p class="pt-callout">Visualização da página. Para responder como participante, abra o link em uma janela anônima e informe seus dados.</p>' : ''}<nav class="pt-tabs" aria-label="Conteúdo do treinamento"><button type="button" class="pt-tab active" data-pt-tab="materials" aria-pressed="true">Materiais de apoio</button><button type="button" class="pt-tab" data-pt-tab="comparisons" aria-pressed="false">Comparativos</button><button type="button" class="pt-tab" data-pt-tab="quiz" aria-pressed="false">Questionário${submission ? ' · Enviado' : ''}</button></nav><div class="pt-tab-content" id="ptMaterials"></div><div class="pt-tab-content" id="ptComparisons" hidden></div><div class="pt-tab-content" id="ptQuiz" hidden></div><footer class="pt-footer">Proparts Training Hub · Aprender para ir além.</footer></div>`;
  renderMaterials(root.querySelector('#ptMaterials'), materials.filter(m => m.kind !== 'comparison'));
  renderMaterials(root.querySelector('#ptComparisons'), materials.filter(m => m.kind === 'comparison'));
  renderQuiz(root.querySelector('#ptQuiz'), questions, submission);
  root.querySelector('#ptEventSelect').onchange = async e => { try { await showEvent(root, events.find(ev => ev.id === e.target.value)); } catch (err) { root.innerHTML = `<p class="pt-error">${escapeTraining(err.message)}</p><button type="button" class="pt-button" id="ptRetry">Tentar novamente</button>`; root.querySelector('#ptRetry').onclick = initPartnerTraining; } };
  root.querySelectorAll('[data-pt-tab]').forEach(button => { button.onclick = () => { root.querySelectorAll('[data-pt-tab]').forEach(b => { b.classList.toggle('active', b === button); b.setAttribute('aria-pressed', String(b === button)); }); root.querySelector('#ptMaterials').hidden = button.dataset.ptTab !== 'materials'; root.querySelector('#ptComparisons').hidden = button.dataset.ptTab !== 'comparisons'; root.querySelector('#ptQuiz').hidden = button.dataset.ptTab !== 'quiz'; }; });
  wireLeave(root);
}

function wireLeave(root) { const button = root.querySelector('#ptLeave'); if (button) button.onclick = async () => { button.disabled = true; try { await training.leaveParticipant(); participant = null; answers = {}; for (const key of Object.keys(sessionStorage)) if (key.startsWith('pt-answers-')) sessionStorage.removeItem(key); await initPartnerTraining(); } catch (err) { button.disabled = false; button.textContent = err.message; } }; }

export function renderTrainingPayload(payload) {
  if (!payload) return '';
  if (typeof payload === 'string') return `<p>${escapeTraining(payload)}</p>`;
  if (Array.isArray(payload.tabs)) return `${payload.intro || ''}${payload.tabs.map(tab => `<section><h3>${escapeTraining(tab.label || tab.title)}</h3>${renderTrainingPayload(tab)}</section>`).join('')}`;
  if (Array.isArray(payload.blocks)) return renderBlocks(payload.blocks.filter(b => b.type !== 'quiz_embutido'));
  if (payload.html) return payload.html;
  if (Array.isArray(payload.sections)) return payload.sections.map(s => `<section><h3>${escapeTraining(s.title)}</h3>${renderTrainingPayload(s.payload || s.body || s)}</section>`).join('');
  if (Array.isArray(payload.items)) return `<div class="pt-comparison-items">${payload.items.map(item => `<article><h3>${escapeTraining(item.title || item.label || item.spec_name || item.attribute_name || '')}</h3>${item.payload ? renderTrainingPayload(item.payload) : `<p>${escapeTraining(item.description || item.text || item.value || '')}</p>`}</article>`).join('')}</div>`;
  if (payload.summary || payload.description) return `<p>${escapeTraining(payload.summary || payload.description)}</p>`;
  return '';
}

function renderMaterials(root, materials) {
  root.innerHTML = materials.length ? `<div class="pt-material-list">${materials.map((m, i) => `<details class="pt-material" ${i === 0 ? 'open' : ''}><summary><span>${escapeTraining(m.title)}</span><span class="pt-material-sign" aria-hidden="true">+</span></summary><div class="pt-material-body">${renderTrainingPayload(m.payload)}${trainingUrl(m.url) ? `<a class="pt-resource-link" href="${escapeTraining(trainingUrl(m.url))}" target="_blank" rel="noopener noreferrer">Abrir material ↗</a>` : ''}</div></details>`).join('')}</div>` : '<div class="pt-empty pt-empty-small"><h2>Materiais em preparação</h2><p>Os materiais desta aba aparecerão aqui assim que forem adicionados.</p></div>';
  wireBlockInteractions(root);
}

function renderQuiz(root, questions, submission) {
  if (submission) { root.innerHTML = `<div class="pt-result"><span class="pt-eyebrow">QUESTIONÁRIO ENVIADO</span><h2>Obrigado por participar!</h2><strong class="pt-result-score">${submission.correct_count}<span> / ${submission.total_questions}</span></strong><p>${Number(submission.score_pct).toFixed(0)}% de acertos. Suas respostas foram registradas.</p><p class="pt-muted">Você pode continuar consultando os materiais de apoio.</p></div>`; return; }
  if (!questions.length) { root.innerHTML = '<div class="pt-empty pt-empty-small"><h2>Questionário em preparação</h2><p>As perguntas deste treinamento ainda não foram publicadas.</p></div>'; return; }
  root.innerHTML = `<form id="ptQuizForm"><div class="pt-section-heading"><div><span class="pt-eyebrow">COLOQUE EM PRÁTICA</span><h2>O que ficou do treinamento?</h2></div><span>${questions.length} perguntas</span></div><p class="pt-muted">Selecione uma resposta por pergunta. Confira antes de enviar: o envio é único.</p>${questions.map((q, i) => `<fieldset class="pt-question"><legend><span>${String(i + 1).padStart(2, '0')}</span> ${escapeTraining(q.question_text)}</legend>${q.options_json.map((option, n) => `<label class="pt-option"><input type="radio" name="${q.id}" value="${n}" ${Number(answers[q.id]) === n && answers[q.id] !== undefined ? 'checked' : ''} required ${!participant ? 'disabled' : ''}><span>${escapeTraining(option)}</span></label>`).join('')}</fieldset>`).join('')}<p id="ptQuizError" class="pt-error" role="alert" hidden></p><button type="submit" class="pt-primary" ${!participant ? 'disabled' : ''}>Enviar respostas</button></form>`;
  const form = root.querySelector('form');
  form.onchange = () => { answers = Object.fromEntries(new FormData(form)); try { sessionStorage.setItem(`pt-answers-${activeEvent.id}`, JSON.stringify(answers)); } catch {} };
  form.onsubmit = async e => { e.preventDefault(); const eventId = activeEvent.id; const button = form.querySelector('[type="submit"]'); const error = root.querySelector('#ptQuizError'); button.disabled = true; button.textContent = 'Enviando…'; error.hidden = true; try { const result = await training.submitTraining(eventId, questions.map(q => ({question_id:q.id, selected_option:Number(new FormData(form).get(q.id))}))); try { sessionStorage.removeItem(`pt-answers-${eventId}`); } catch {} renderQuiz(root, questions, result); } catch (err) { error.textContent = err.message; error.hidden = false; button.disabled = false; button.textContent = 'Enviar respostas'; } };
}
