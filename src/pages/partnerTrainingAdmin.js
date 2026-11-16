import * as training from '../services/partnerTrainingService.js';
import { getCurrentProfile, isAdminProfile } from '../config/supabase.js';
import { imageUploadFieldHtml, wireImageUploadField } from '../components/ImageUploadField.js';
import { escapeTraining as esc, trainingDate } from './partnerTraining.js';

let companies = [];
let catalog = [];
let eventRows = [];
let draftQuestions = [];
let draftMaterials = [];
let locked = false;

window.addEventListener('panel:activated', e => { if (e.detail.panelId === 'partner-training-admin') initAdmin(); });

async function initAdmin() {
  const root = document.getElementById('partnerTrainingAdminContainer');
  if (!root) return;
  root.innerHTML = '<p class="learning-loading">Carregando treinamentos de parceiros…</p>';
  try {
    const profile = await getCurrentProfile();
    if (!isAdminProfile(profile)) { root.innerHTML = '<p class="learning-error">Esta área é restrita a administradores.</p>'; return; }
    [companies, catalog, eventRows] = await Promise.all([training.listPartnerCompanies(), training.listMaterialCatalog(), training.listTrainingEvents(null, {admin:true})]);
    renderAdmin(root);
  } catch (err) { root.innerHTML = `<p class="pt-error">${esc(err.message)}</p><button class="pt-button" id="ptAdminRetry" type="button">Tentar novamente</button>`; root.querySelector('#ptAdminRetry').onclick = initAdmin; }
}

function renderAdmin(root) {
  root.innerHTML = `<div class="pt-admin"><div class="pt-section-heading"><div><span class="pt-eyebrow">PARCEIROS · GARMIN</span><h1>Treinamentos por data</h1><p class="pt-muted">Prepare os materiais, escreva as perguntas e acompanhe cada turma.</p></div><button type="button" class="pt-primary" id="ptNewEvent">Novo treinamento +</button></div><details class="pt-company-box"><summary>Cadastrar empresa ou revenda</summary><form class="pt-inline-form" id="ptCompanyForm"><label>Nome da empresa<input name="name" maxlength="120" required placeholder="Nome da empresa ou loja"></label><label>Identificador<input name="slug" required pattern="[a-z0-9]+(-[a-z0-9]+)*" placeholder="nome-da-empresa"></label><button class="pt-button" type="submit">Cadastrar empresa</button><p role="status" id="ptCompanyStatus"></p></form></details><div class="pt-admin-filter"><label>Filtrar por empresa<select id="ptCompanyFilter"><option value="">Todas as empresas</option>${companies.map(c => `<option value="${c.id}">${esc(c.name)}</option>`).join('')}</select></label></div><div id="ptEventList"></div><div id="ptEditor"></div></div>`;
  showEventList(root);
  root.querySelector('#ptNewEvent').onclick = () => openEditor(root, null);
  root.querySelector('#ptCompanyFilter').onchange = () => showEventList(root);
  root.querySelector('#ptCompanyForm').onsubmit = async e => { e.preventDefault(); const form = e.currentTarget; const button = form.querySelector('button'); const status = root.querySelector('#ptCompanyStatus'); button.disabled = true; try { const company = await training.createPartnerCompany(Object.fromEntries(new FormData(form))); companies.push(company); const filter = root.querySelector('#ptCompanyFilter'); filter.add(new Option(company.name, company.id)); status.textContent = 'Empresa cadastrada. Já pode ser selecionada em um novo treinamento.'; form.reset(); } catch (err) { status.textContent = err.message; } finally { button.disabled = false; } };
  const name = root.querySelector('#ptCompanyForm [name="name"]');
  name.oninput = () => { const slug = root.querySelector('#ptCompanyForm [name="slug"]'); if (!slug.dataset.edited) slug.value = name.value.normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,''); };
  root.querySelector('#ptCompanyForm [name="slug"]').oninput = e => e.target.dataset.edited = 'true';
}

function showEventList(root) {
  const company = root.querySelector('#ptCompanyFilter').value;
  const rows = eventRows.filter(e => !company || e.partner_company_id === company);
  root.querySelector('#ptEventList').innerHTML = rows.length ? `<div class="pt-event-list">${rows.map(e => `<article class="pt-event-row"><div class="pt-event-date">${trainingDate(e.training_date)}</div><div class="pt-event-name"><h2>${esc(e.title)}</h2><span>${esc(companies.find(c => c.id === e.partner_company_id)?.name || '')}</span></div><span class="pt-status ${e.is_published ? 'pt-status-live' : ''}">${e.is_published ? 'Publicado' : 'Rascunho'}</span><button type="button" class="pt-button" data-edit-event="${e.id}">Gerenciar →</button></article>`).join('')}</div>` : '<div class="pt-empty pt-empty-small"><h2>Vamos preparar a próxima turma?</h2><p>Crie um treinamento, selecione os materiais e adicione suas perguntas.</p></div>';
  root.querySelectorAll('[data-edit-event]').forEach(b => b.onclick = () => openEditor(root, eventRows.find(e => e.id === b.dataset.editEvent)));
}

async function openEditor(root, event) {
  const editor = root.querySelector('#ptEditor');
  editor.innerHTML = '<p class="learning-loading">Abrindo editor…</p>';
  editor.scrollIntoView({behavior:'smooth',block:'start'});
  try {
    let report = [];
    if (event) [draftQuestions, draftMaterials, report] = await Promise.all([training.getTrainingQuestions(event.id, {admin:true}), training.getTrainingMaterials(event.id), training.listTrainingReport(event.id)]);
    else { draftQuestions = []; draftMaterials = []; }
    locked = report.length > 0;
    renderEditor(root, event, report);
  } catch (err) { editor.innerHTML = `<p class="pt-error">${esc(err.message)}</p>`; }
}

function renderEditor(root, event, report) {
  const editor = root.querySelector('#ptEditor');
  editor.innerHTML = `<section class="pt-editor"><div class="pt-section-heading"><div><span class="pt-eyebrow">EDITOR DO TREINAMENTO</span><h2>${event ? 'Editar treinamento' : 'Novo treinamento'}</h2></div><button type="button" class="pt-back" id="ptCloseEditor">Fechar editor ×</button></div><form id="ptEventForm" class="pt-form"><div class="pt-two-cols"><label>Empresa / loja<select name="partner_company_id" required><option value="">Selecione</option>${companies.map(c => `<option value="${c.id}" ${event?.partner_company_id === c.id ? 'selected' : ''}>${esc(c.name)}</option>`).join('')}</select></label><label>Data do treinamento<input type="date" name="training_date" value="${esc(event?.training_date?.slice(0,10) || '')}" required></label></div><label>Título<input name="title" required maxlength="160" value="${esc(event?.title || '')}" placeholder="Nome do treinamento"></label><label>Apresentação<textarea name="description" rows="3" maxlength="4000" placeholder="Uma breve mensagem para os participantes">${esc(event?.description || '')}</textarea></label><div class="pt-two-cols">${imageUploadFieldHtml({fieldName:'logo_url', currentUrl:event?.logo_url || '', folder:'partner-training/logos', label:'Logo da empresa parceira'})}${imageUploadFieldHtml({fieldName:'cover_url', currentUrl:event?.cover_url || '', folder:'partner-training/covers', label:'Imagem de capa / fundo'})}</div><section class="pt-editor-section"><div class="pt-section-heading"><div><h3>Materiais de apoio</h3><p class="pt-muted">Selecione conteúdos já publicados na plataforma. Os comparativos aparecerão em sua própria aba.</p></div></div><div class="pt-catalog-tools"><label>Buscar material<input type="search" id="ptCatalogSearch" placeholder="Nome do produto, módulo ou guia"></label><label>Categoria<select id="ptCatalogKind"><option value="">Todas</option><option value="library">Biblioteca</option><option value="module">Módulos</option><option value="product">Produtos</option><option value="comparison">Comparativos</option></select></label></div><div id="ptCatalogList" class="pt-catalog-list"></div><h4>Selecionados para este treinamento</h4><div id="ptSelectedMaterials"></div></section><section class="pt-editor-section"><div class="pt-section-heading"><div><h3>Questionário</h3><p class="pt-muted">Crie perguntas simples e selecione a alternativa correta.</p></div><button type="button" class="pt-button" id="ptAddQuestion" ${locked ? 'disabled' : ''}>Adicionar pergunta +</button></div>${locked ? '<p class="pt-callout">Este treinamento já recebeu respostas. As perguntas estão preservadas para manter o relatório. Para outro questionário, crie um novo treinamento.</p>' : ''}<div id="ptQuestionsEditor"></div></section><div class="pt-save-bar"><label class="pt-checkbox"><input type="checkbox" name="is_published" ${event?.is_published ? 'checked' : ''}> Publicar para participantes</label><button class="pt-primary" type="submit">Salvar treinamento</button></div><p class="pt-muted pt-fine">É possível salvar sem perguntas como rascunho. Para publicar, adicione pelo menos uma pergunta com a resposta correta.</p><p class="pt-error" role="alert" id="ptSaveError" hidden></p><p role="status" id="ptSaveStatus"></p></form>${event ? `<div class="pt-share-actions"><a class="pt-button" href="${eventLink(event.id, true)}" target="_blank" rel="noopener">Ver página ↗</a><button type="button" class="pt-button" id="ptCopyLink" ${!event.is_published ? 'disabled' : ''}>Copiar link para participantes</button><span role="status" id="ptCopyStatus"></span>${!event.is_published ? '<p class="pt-muted">O link ficará disponível após publicar o treinamento.</p>' : ''}</div><section class="pt-editor-section"><div class="pt-section-heading"><div><h3>Resultados da turma</h3><p class="pt-muted">${report.length} participante${report.length === 1 ? '' : 's'} com respostas enviadas.</p></div><button type="button" class="pt-button" id="ptExportReport" ${!report.length ? 'disabled' : ''}>Exportar planilha CSV ↓</button></div><div id="ptReport">${renderReport(report)}</div><p role="alert" id="ptReportError" class="pt-error" hidden></p></section>` : ''}</section>`;
  editor.querySelectorAll('[data-role="iuf-root"]').forEach(widget => wireImageUploadField(widget));
  renderCatalog(editor);
  renderSelected(editor);
  renderQuestions(editor);
  editor.querySelector('#ptCatalogSearch').oninput = () => renderCatalog(editor);
  editor.querySelector('#ptCatalogKind').onchange = () => renderCatalog(editor);
  editor.querySelector('#ptAddQuestion').onclick = () => { collectQuestions(editor); draftQuestions.push({question_text:'',options_json:['',''],correct_option:0}); renderQuestions(editor); editor.querySelector('.pt-question-edit:last-child')?.scrollIntoView({behavior:'smooth', block:'center'}); };
  editor.querySelector('#ptCloseEditor').onclick = () => editor.innerHTML = '';
  editor.querySelector('#ptCopyLink')?.addEventListener('click', async () => { const status = editor.querySelector('#ptCopyStatus'); try { await navigator.clipboard.writeText(eventLink(event.id)); status.textContent = 'Link copiado.'; } catch { status.textContent = eventLink(event.id); } });
  editor.querySelector('#ptExportReport')?.addEventListener('click', async e => { const b = e.currentTarget; b.disabled = true; const error = editor.querySelector('#ptReportError'); error.hidden = true; try { await training.downloadTrainingReport(event.id); } catch (err) { error.textContent = err.message; error.hidden = false; } finally { b.disabled = false; } });
  editor.querySelector('#ptEventForm').onsubmit = async e => {
    e.preventDefault(); collectQuestions(editor);
    const form = e.currentTarget; const button = form.querySelector('[type="submit"]'); const error = editor.querySelector('#ptSaveError'); error.hidden = true; button.disabled = true; button.textContent = 'Salvando…';
    try {
      const values = Object.fromEntries(new FormData(form));
      const row = {id:event?.id,partner_company_id:values.partner_company_id,title:values.title.trim(),training_date:values.training_date,description:values.description.trim(),logo_url:values.logo_url,cover_url:values.cover_url,is_published:values.is_published === 'on'};
      if (row.is_published && !draftQuestions.length) throw new Error('Adicione pelo menos uma pergunta antes de publicar.');
      if (draftQuestions.some(q => !q.question_text.trim() || q.options_json.some(o => !o.trim()) || q.correct_option < 0 || q.correct_option >= q.options_json.length)) throw new Error('Preencha o texto, as alternativas e a resposta correta de todas as perguntas.');
      const id = await training.saveTrainingEvent(row, draftQuestions.map((q,i) => ({...q,order_index:i})), draftMaterials.map((m,i) => ({...m,order_index:i})));
      // Keep the saved identity even if refreshing the list fails: retrying a
      // successful first save must update the same training, never duplicate it.
      event = {...row, id};
      eventRows = await training.listTrainingEvents(null, {admin:true});
      showEventList(root);
      await openEditor(root, eventRows.find(r => r.id === id) || {...row,id});
      root.querySelector('#ptSaveStatus').textContent = row.is_published ? 'Treinamento salvo e publicado.' : 'Rascunho salvo.';
    } catch (err) { error.textContent = err.message; error.hidden = false; button.disabled = false; button.textContent = 'Salvar treinamento'; }
  };
}

function renderCatalog(editor) {
  const search = editor.querySelector('#ptCatalogSearch').value.toLocaleLowerCase('pt-BR');
  const kind = editor.querySelector('#ptCatalogKind').value;
  const filtered = catalog.filter(m => (!kind || m.kind === kind) && m.title.toLocaleLowerCase('pt-BR').includes(search));
  editor.querySelector('#ptCatalogList').innerHTML = filtered.length ? filtered.map(m => `<label class="pt-catalog-item"><input type="checkbox" data-catalog-id="${esc(m.source_id)}" data-catalog-kind="${esc(m.kind)}" ${draftMaterials.some(s => s.source_id === m.source_id && s.kind === m.kind) ? 'checked' : ''}><span>${esc(m.title)}<small>${kindLabel(m.kind)}</small></span></label>`).join('') : '<p class="pt-muted">Nenhum material encontrado.</p>';
  editor.querySelectorAll('[data-catalog-id]').forEach(input => input.onchange = () => { const m = catalog.find(c => c.source_id === input.dataset.catalogId && c.kind === input.dataset.catalogKind); if (input.checked) draftMaterials.push({...m}); else draftMaterials = draftMaterials.filter(c => !(c.source_id === m.source_id && c.kind === m.kind)); renderSelected(editor); });
}
function kindLabel(kind) { return ({library:'Biblioteca',module:'Módulo',product:'Produto',comparison:'Comparativo',link:'Link'})[kind] || kind; }
function renderSelected(editor) { editor.querySelector('#ptSelectedMaterials').innerHTML = draftMaterials.length ? draftMaterials.map((m,i) => `<div class="pt-selected-material"><span>${i+1}. ${esc(m.title)} <small>${kindLabel(m.kind)}</small></span><div><button type="button" class="pt-small-button" data-material-up="${i}" aria-label="Mover ${esc(m.title)} para cima" ${i===0 ? 'disabled' : ''}>↑</button><button type="button" class="pt-small-button" data-material-remove="${i}" aria-label="Remover ${esc(m.title)}">×</button></div></div>`).join('') : '<p class="pt-muted">Nenhum material selecionado.</p>'; editor.querySelectorAll('[data-material-remove]').forEach(b => b.onclick = () => { draftMaterials.splice(Number(b.dataset.materialRemove),1); renderSelected(editor); renderCatalog(editor); }); editor.querySelectorAll('[data-material-up]').forEach(b => b.onclick = () => { const i = Number(b.dataset.materialUp); [draftMaterials[i-1],draftMaterials[i]] = [draftMaterials[i],draftMaterials[i-1]]; renderSelected(editor); }); }

function collectQuestions(editor) {
  if (locked) return;
  editor.querySelectorAll('.pt-question-edit').forEach((el,i) => { draftQuestions[i] = {...draftQuestions[i],question_text:el.querySelector('[data-question-text]').value,options_json:[...el.querySelectorAll('[data-option-text]')].map(e => e.value),correct_option:Number(el.querySelector('[data-correct-option]:checked')?.value ?? -1)}; });
}
function renderQuestions(editor) {
  editor.querySelector('#ptQuestionsEditor').innerHTML = draftQuestions.length ? draftQuestions.map((q,i) => `<fieldset class="pt-question-edit" ${locked ? 'disabled' : ''}><legend>Pergunta ${i+1}</legend><div class="pt-question-actions"><button type="button" class="pt-small-button" data-question-up="${i}" ${i===0 ? 'disabled' : ''}>↑ Mover acima</button><button type="button" class="pt-small-button" data-question-remove="${i}">Remover</button></div><label>Pergunta<input data-question-text value="${esc(q.question_text)}" maxlength="2000" required placeholder="Escreva sua pergunta"></label><p class="pt-fine pt-muted">Marque o círculo da alternativa correta.</p>${q.options_json.map((o,n) => `<div class="pt-option-edit"><input type="radio" name="correct-${i}" value="${n}" data-correct-option ${q.correct_option === n ? 'checked' : ''} aria-label="Alternativa ${n+1} é a correta" required><input data-option-text value="${esc(o)}" maxlength="1000" required aria-label="Texto da alternativa ${n+1}" placeholder="Alternativa ${n+1}">${q.options_json.length > 2 ? `<button type="button" class="pt-small-button" data-option-remove="${i}:${n}" aria-label="Remover alternativa ${n+1}">×</button>` : ''}</div>`).join('')}${q.options_json.length < 4 ? `<button type="button" class="pt-back" data-option-add="${i}">+ Adicionar alternativa</button>` : ''}</fieldset>`).join('') : '<div class="pt-question-empty"><p>Seu questionário começa em branco.</p><span>Adicione uma pergunta e escreva as alternativas no seu ritmo.</span></div>';
  editor.querySelectorAll('[data-question-remove]').forEach(b => b.onclick = () => { collectQuestions(editor); draftQuestions.splice(Number(b.dataset.questionRemove),1); renderQuestions(editor); });
  editor.querySelectorAll('[data-question-up]').forEach(b => b.onclick = () => { collectQuestions(editor); const i=Number(b.dataset.questionUp); [draftQuestions[i-1],draftQuestions[i]]=[draftQuestions[i],draftQuestions[i-1]]; renderQuestions(editor); });
  editor.querySelectorAll('[data-option-add]').forEach(b => b.onclick = () => { collectQuestions(editor); draftQuestions[Number(b.dataset.optionAdd)].options_json.push(''); renderQuestions(editor); });
  editor.querySelectorAll('[data-option-remove]').forEach(b => b.onclick = () => { collectQuestions(editor); const [i,n]=b.dataset.optionRemove.split(':').map(Number); const q=draftQuestions[i]; q.options_json.splice(n,1); q.correct_option=q.correct_option===n ? -1 : q.correct_option>n ? q.correct_option-1 : q.correct_option; renderQuestions(editor); });
}

function eventLink(id, preview=false) { const url=new URL(location.href); url.search=''; url.hash=''; url.searchParams.set('treinamento',id); if(preview) url.searchParams.set('preview','1'); return url.href; }
function renderReport(report) { if (!report.length) return '<p class="pt-muted">As respostas aparecerão aqui após o primeiro envio.</p>'; return `<div class="pt-table-scroll"><table class="pt-report-table"><thead><tr><th>Posição</th><th>Participante</th><th>E-mail</th><th>Acertos</th><th>Nota</th></tr></thead><tbody>${[...report].sort((a,b)=>Number(b.score_pct)-Number(a.score_pct)).map((r,i)=>`<tr><td>${i+1}</td><td>${esc(r.full_name)}</td><td>${esc(r.email)}</td><td>${r.correct_count} / ${r.total_questions}</td><td><strong>${Number(r.score_pct).toFixed(0)}%</strong></td></tr>`).join('')}</tbody></table></div>`; }
