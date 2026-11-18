import { afterEach, describe, expect, it, vi } from 'vitest';
vi.mock('../config/supabase.js', () => ({ supabase: {} }));
import { csvCell, trainingReportCsv, downloadTrainingReport } from '../services/partnerTrainingService.js';

describe('Partner training report for Excel', () => {
  it('preserves accents, delimiters, quotes and multiline answers', () => {
    expect(csvCell('João; "Olá"\nTudo bem?')).toBe('"João; ""Olá""\nTudo bem?"');
  });
  it('neutralizes formulas supplied as participant names or answers', () => {
    for (const value of ['=1+1',' +SUM(A1)','-2+3','@SUM(A1)','\t=1']) {
      expect(csvCell(value).startsWith('"\'')).toBe(true);
    }
  });
  it('exports one row per participant with tied ranks and wrong-answer details', () => {
    const base = { email:'pessoa@example.com',company_name:'Duty Free',title:'Treinamento',training_date:'2026-11-17',submitted_at:'2026-11-17T12:00:00Z',correct_count:1,total_questions:2,answers:[{question_text:'Qual produto?',selected_text:'A',correct_text:'B',is_correct:false},{question_text:'Outro?',selected_text:'B',correct_text:'B',is_correct:true}] };
    const csv = trainingReportCsv([{...base,full_name:'Menor',score_pct:50},{...base,full_name:'Maior',score_pct:100},{...base,full_name:'Empate',score_pct:100}]);
    expect(csv.charCodeAt(0)).toBe(0xfeff);
    expect(csv.indexOf('Maior')).toBeLessThan(csv.indexOf('Menor'));
    expect(csv).toContain('"1";"Empate"');
    expect(csv).toContain('"3";"Menor"');
    expect(csv.split('\r\n')).toHaveLength(4);
    expect(csv.match(/Maior/g)).toHaveLength(1);
    expect(csv).toContain('Q1');
    expect(csv).toContain('"Duty Free"');
    expect(csv).toContain('Q1: Qual produto?\nMarcada: A\nCorreta: B');
    expect(csv).not.toContain('Outro?');
  });
});

describe('Report completeness',()=>{
 it('keeps participants with no answer details and distinguishes full scores',()=>{
 const base={full_name:'Sem detalhes',total_questions:10,submitted_at:'2026-11-17T12:00:00Z'};
 const csv=trainingReportCsv([{...base,correct_count:8,score_pct:80,answers:[]},{...base,full_name:'Completo',correct_count:10,score_pct:100,answers:[]}]);
 expect(csv.split('\r\n')).toHaveLength(3);
 expect(csv).toContain('Detalhamento indisponível');
 expect(csv).toContain('Nenhuma');
 });
});

describe('Download the displayed class results', () => {
 afterEach(() => { vi.restoreAllMocks(); vi.unstubAllGlobals(); vi.useRealTimers(); });
 it('exports loaded results without querying again', async () => {
  vi.useFakeTimers();
  const createObjectURL=vi.fn(()=> 'blob:report');
  vi.stubGlobal('URL',{createObjectURL,revokeObjectURL:vi.fn()});
  vi.stubGlobal('Blob', class { constructor(parts){this.parts=parts;} });
  const click=vi.spyOn(HTMLAnchorElement.prototype,'click').mockImplementation(()=>{});
  await downloadTrainingReport('class-2',[{event_id:'class-2',full_name:'Participante',correct_count:1,total_questions:1,score_pct:100,submitted_at:'2026-11-18T12:00:00Z',answers:[{is_correct:true}]}]);
  expect(click).toHaveBeenCalledOnce();
  expect(createObjectURL.mock.calls[0][0].parts[0]).toContain('Participante');
  vi.runAllTimers();
 });
 it('rejects results from another class',async()=>{
  await expect(downloadTrainingReport('class-2',[{event_id:'class-1'}])).rejects.toThrow('outra turma');
 });
 it('identifies an empty loaded report without querying another class',async()=>{
  await expect(downloadTrainingReport('class-2',[])).rejects.toThrow('Não há respostas carregadas');
 });
});
