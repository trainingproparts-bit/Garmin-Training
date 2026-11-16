import { describe, expect, it, vi } from 'vitest';
vi.mock('../config/supabase.js', () => ({ supabase: {} }));
import { csvCell, trainingReportCsv } from '../services/partnerTrainingService.js';

describe('Partner training report for Excel', () => {
  it('preserves accents, delimiters, quotes and multiline answers', () => {
    expect(csvCell('João; "Olá"\nTudo bem?')).toBe('"João; ""Olá""\nTudo bem?"');
  });
  it('neutralizes formulas supplied as participant names or answers', () => {
    for (const value of ['=1+1',' +SUM(A1)','-2+3','@SUM(A1)','\t=1']) {
      expect(csvCell(value).startsWith('"\'')).toBe(true);
    }
  });
  it('ranks by score with tied positions and retains every question and identity', () => {
    const base = { email:'pessoa@example.com',company_name:'Duty Free',title:'Treinamento',training_date:'2026-11-17',submitted_at:'2026-11-17T12:00:00Z',correct_count:1,total_questions:2,answers:[{question_text:'Qual produto?',selected_text:'A',correct_text:'B',is_correct:false},{question_text:'Outro?',selected_text:'B',correct_text:'B',is_correct:true}] };
    const csv = trainingReportCsv([{...base,full_name:'Menor',score_pct:50},{...base,full_name:'Maior',score_pct:100},{...base,full_name:'Empate',score_pct:100}]);
    expect(csv.charCodeAt(0)).toBe(0xfeff);
    expect(csv.indexOf('Maior')).toBeLessThan(csv.indexOf('Menor'));
    expect(csv).toContain('"1";"Empate"');
    expect(csv).toContain('"3";"Menor"');
    expect(csv.split('\r\n')).toHaveLength(7);
    expect(csv).toContain('"Duty Free"');
    expect(csv).toContain('"Qual produto?";"A";"B";"Não"');
  });
});
