import { supabase } from '../config/supabase.js';

function unwrap({ data, error }) { if (error) throw error; return data; }
const SUMMARY = 'id,correct_count,total_questions,score_pct,submitted_at';
export async function listPartnerCompanies() {
  return unwrap(await supabase.from('partner_companies').select('id,name,brand_id,slug').eq('is_active', true).order('order_index'));
}
export async function getParticipant() {
  const { data: { user }, error } = await supabase.auth.getUser();
  if (error?.name === 'AuthSessionMissingError' || !user) return null;
  if (error) throw error;
  return unwrap(await supabase.from('guest_registrations').select('*').eq('user_id', user.id).maybeSingle());
}
export async function registerParticipant({ full_name, email, partner_company_id }) {
  const { data: { session }, error } = await supabase.auth.getSession();
  if (error) throw error;
  if (session && !session.user.is_anonymous) throw new Error('Você está com um login da equipe aberto. Saia da conta para entrar como participante.');
  if (!session) {
    const result = await supabase.auth.signInAnonymously();
    if (result.error?.code === 'anonymous_provider_disabled' || /anonymous sign-ins are disabled/i.test(result.error?.message || '')) {
      throw new Error('O acesso sem senha ainda não está disponível. Avise a pessoa responsável pelo treinamento.');
    }
    unwrap(result);
  }
  return unwrap(await supabase.rpc('fn_register_guest', { p_full_name: full_name, p_email: email, p_partner_company_id: partner_company_id }));
}
export async function leaveParticipant() { unwrap(await supabase.auth.signOut()); }
export async function listTrainingEvents(companyId, { admin = false } = {}) {
  let query = supabase.from('partner_training_events').select('*').order('training_date', { ascending: false }).order('created_at', { ascending: false });
  if (companyId) query = query.eq('partner_company_id', companyId);
  if (!admin) query = query.eq('is_published', true);
  return unwrap(await query);
}
export async function getTrainingEvent(id) { return unwrap(await supabase.from('partner_training_events').select('*').eq('id', id).maybeSingle()); }
export async function getTrainingQuestions(eventId, { admin = false } = {}) {
  return admin
    ? unwrap(await supabase.from('partner_training_questions').select('*').eq('event_id', eventId).order('order_index').order('id'))
    : unwrap(await supabase.rpc('fn_partner_training_questions', { p_event_id: eventId }));
}
export async function getTrainingMaterials(eventId) { return unwrap(await supabase.from('partner_training_materials').select('*').eq('event_id', eventId).order('order_index')); }
export async function getMyTrainingSubmission(eventId) {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return null;
  return unwrap(await supabase.from('partner_training_submissions').select(SUMMARY).eq('event_id', eventId).eq('user_id', user.id).maybeSingle());
}
export async function submitTraining(eventId, answers) { return unwrap(await supabase.rpc('fn_submit_partner_training', { p_event_id: eventId, p_answers: answers })); }
export async function saveTrainingEvent(event, questions, materials) { return unwrap(await supabase.rpc('fn_save_partner_training', { p_event: event, p_questions: questions, p_materials: materials })); }
export async function listTrainingReport(eventId) {
  const rows = [];
  for (let offset = 0; ; offset += 500) {
    const page = unwrap(await supabase.from('partner_training_submissions').select('*').eq('event_id', eventId).order('score_pct', { ascending: false }).order('submitted_at').order('id').range(offset, offset + 499));
    rows.push(...page);
    if (page.length < 500) return rows;
  }
}
export async function createPartnerCompany({ name, slug, brand_id }) {
  if (!brand_id) {
    const brand = unwrap(await supabase.from('brands').select('id').eq('name', 'Garmin').single());
    brand_id = brand.id;
  }
  return unwrap(await supabase.from('partner_companies').insert({ name: name.trim(), slug: slug.trim(), brand_id }).select('id,name,brand_id,slug').single());
}

const escapeHtml = (v) => String(v ?? '').replace(/[&<>"']/g, c => ({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[c]));
/** Load all catalog pages: Supabase caps a single response at 1,000 records. */
async function catalogRows(table, columns = '*', published = false) {
  const rows = [];
  for (let offset = 0; ; offset += 500) {
    let query = supabase.from(table).select(columns).order('id').range(offset, offset + 499);
    if (published) query = query.eq('is_published', true);
    const page = unwrap(await query);
    rows.push(...page);
    if (page.length < 500) return rows;
  }
}
export async function listMaterialCatalog() {
  const [library, modules, lessons, products, sections, materials, comparisons, items] = await Promise.all([
    catalogRows('content_library', '*', true), catalogRows('modules', '*', true), catalogRows('lessons', '*', true),
    catalogRows('products', '*', true), catalogRows('product_sections'), catalogRows('product_materials'),
    catalogRows('product_comparisons', '*', true), catalogRows('comparison_items'),
  ]);
  const ordered = rows => rows.sort((a,b) => (a.order_index ?? 0) - (b.order_index ?? 0));
  return [
    ...library.map(x => ({ source_id:x.id,kind:'library',title:x.title,payload:x.payload,url:'' })),
    ...modules.map(x => ({ source_id:x.id,kind:'module',title:x.title,payload:{ sections:ordered(lessons.filter(l=>l.module_id===x.id)).map(l=>({ title:l.title,payload:l.body })) },url:'' })),
    ...products.map(x => ({ source_id:x.id,kind:'product',title:x.name,payload:{ sections:[
      { title:x.name,payload:{ html:`<p>${escapeHtml(x.tagline)}</p>` } },
      ...sections.filter(s=>s.product_id===x.id).map(s=>({ title:s.section_type.replaceAll('_',' '),payload:s.payload })),
      ...ordered(materials.filter(m=>m.product_id===x.id)).filter(m=>/^https?:\/\//i.test(m.url)).map(m=>({ title:m.title,payload:{ html:`<a href="${escapeHtml(m.url)}" target="_blank" rel="noopener noreferrer">Abrir material</a>` } })),
    ] },url:'' })),
    ...comparisons.map(x=>({ source_id:x.id,kind:'comparison',title:x.title,payload:{ sections:[
      { title:'Resumo',payload:{ html:`<p>${escapeHtml(x.resumo_executivo)}</p>` } },
      { title:'Comparativo',payload:{ html:`<div class="pt-table-wrap"><table><thead><tr><th>Característica</th><th>${escapeHtml(products.find(p=>p.id===x.product_a_id)?.name || 'Produto A')}</th><th>${escapeHtml(products.find(p=>p.id===x.product_b_id)?.name || 'Produto B')}</th></tr></thead><tbody>${ordered(items.filter(i=>i.comparison_id===x.id)).map(i=>`<tr><th>${escapeHtml(i.spec_label)}</th><td>${escapeHtml(i.value_a)}</td><td>${escapeHtml(i.value_b)}</td></tr>`).join('')}</tbody></table></div>` } },
      ...(Array.isArray(x.blocks) && x.blocks.length ? [{ title:'Saiba mais',payload:{blocks:x.blocks} }] : []),
    ] },url:'' })),
  ];
}

export function csvCell(value) {
  let text = String(value ?? '');
  if (/^[\s\uFEFF]*[=+\-@\t\r\n]/.test(text)) text = "'" + text;
  return '"' + text.replaceAll('"', '""') + '"';
}
export function trainingReportCsv(rows) {
  const header = ['Classificação','Nome','E-mail','Empresa','Treinamento','Data do treinamento','Enviado em','Acertos','Perguntas','Nota (%)','Pergunta','Resposta escolhida','Resposta correta','Acertou'];
  const sorted = [...rows].sort((a,b)=>Number(b.score_pct)-Number(a.score_pct) || String(a.submitted_at).localeCompare(String(b.submitted_at)));
  const output = [header];
  let rank = 1;
  sorted.forEach((r,index)=>{
    if (index && Number(r.score_pct)!==Number(sorted[index-1].score_pct)) rank=index+1;
    for (const a of r.answers || []) output.push([rank,r.full_name,r.email,r.company_name,r.title,r.training_date,new Date(r.submitted_at).toLocaleString('pt-BR',{timeZone:'America/Sao_Paulo'}),r.correct_count,r.total_questions,String(r.score_pct).replace('.',','),a.question_text,a.selected_text,a.correct_text,a.is_correct?'Sim':'Não']);
  });
  return '\uFEFF' + output.map(row=>row.map(csvCell).join(';')).join('\r\n');
}
export async function downloadTrainingReport(eventId) {
  const rows = await listTrainingReport(eventId);
  if (!rows.length) throw new Error('Este treinamento ainda não recebeu respostas.');
  const blob = new Blob([trainingReportCsv(rows)], { type:'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a'); a.href=url; a.download=`treinamento-${eventId}.csv`;
  document.body.append(a); a.click(); a.remove(); setTimeout(()=>URL.revokeObjectURL(url),1000);
}
