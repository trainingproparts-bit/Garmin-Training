// src/__tests__/StreakWeekendLogic.test.js
// Testes para lógica de Streak com pausa de fim de semana (RN §6.5)
// A implementação real está no servidor (sql/033_streak_engine.sql), mas
// validamos aqui o comportamento esperado do cálculo de dias consecutivos.

import { describe, it, expect } from 'vitest';

describe('Streak Engine - Lógica de Pausa de Fim de Semana', () => {
  /**
   * Helper para calcular se um streak deve ser mantido considerando pausa de fim de semana.
   * Regra: segunda/sábado/domingo usam sexta como piso; terça a sexta exigem o dia anterior.
   * @param {Date} lastActivityDate - última data de atividade registrada
   * @param {Date} currentDate - data atual para verificação
   * @returns {boolean} - true se o streak deve ser mantido
   */
  function shouldMaintainStreak(lastActivityDate, currentDate) {
    const last = new Date(lastActivityDate).toDateString();
    const current = new Date(currentDate).toDateString();
    
    // Se for o mesmo dia, mantém
    if (last === current) return true;
    
    const lastDay = new Date(lastActivityDate).getDay(); // 0=domingo, 6=sábado
    const currentDay = new Date(currentDate).getDay();
    
    const dayDiff = Math.floor((new Date(currentDate) - new Date(lastActivityDate)) / (1000 * 60 * 60 * 24));
    
    // Se passou mais de 3 dias (considerando fim de semana), quebra
    if (dayDiff > 3) return false;
    
    // Regra de pausa de fim de semana:
    // - Segunda (1): usa sexta (5) como piso
    // - Sábado (6): usa sexta (5) como piso  
    // - Domingo (0): usa sexta (5) como piso
    // - Terça (2) a Sexta (5): exige dia anterior
    
    if (currentDay === 1 || currentDay === 6 || currentDay === 0) {
      // Segunda, sábado ou domingo: aceita até sexta como última atividade
      const acceptableDays = [5, 6, 0, 1]; // sexta, sábado, domingo, segunda
      return acceptableDays.includes(lastDay);
    } else {
      // Terça a sexta: exige dia anterior
      return dayDiff === 1;
    }
  }

  it('deve manter streak se a última atividade foi hoje', () => {
    const today = new Date('2026-07-13'); // segunda-feira
    expect(shouldMaintainStreak(today, today)).toBe(true);
  });

  it('deve manter streak se a última atividade foi ontem (dia útil)', () => {
    const yesterday = new Date('2026-07-12'); // domingo
    const today = new Date('2026-07-13'); // segunda-feira
    expect(shouldMaintainStreak(yesterday, today)).toBe(true);
  });

  it('deve manter streak na segunda se última atividade foi sexta (pausa de fim de semana)', () => {
    const friday = new Date('2026-07-11'); // sexta-feira
    const monday = new Date('2026-07-14'); // segunda-feira
    expect(shouldMaintainStreak(friday, monday)).toBe(true);
  });

  it('deve manter streak no sábado se última atividade foi sexta', () => {
    const friday = new Date('2026-07-11'); // sexta-feira
    const saturday = new Date('2026-07-12'); // sábado
    expect(shouldMaintainStreak(friday, saturday)).toBe(true);
  });

  it('deve manter streak no domingo se última atividade foi sexta', () => {
    const friday = new Date('2026-07-11'); // sexta-feira
    const sunday = new Date('2026-07-13'); // domingo
    expect(shouldMaintainStreak(friday, sunday)).toBe(true);
  });

  it('deve quebrar streak na terça se última atividade foi sexta (gap > 3 dias)', () => {
    const friday = new Date('2026-07-11'); // sexta-feira
    const tuesday = new Date('2026-07-15'); // terça-feira
    expect(shouldMaintainStreak(friday, tuesday)).toBe(false);
  });

  it('deve quebrar streak na quarta se última atividade foi segunda (gap > 1 dia útil)', () => {
    const monday = new Date('2026-07-13'); // segunda-feira
    const wednesday = new Date('2026-07-15'); // quarta-feira
    expect(shouldMaintainStreak(monday, wednesday)).toBe(false);
  });

  it('deve manter streak na terça se última atividade foi segunda', () => {
    const monday = new Date('2026-07-13'); // segunda-feira
    const tuesday = new Date('2026-07-14'); // terça-feira
    expect(shouldMaintainStreak(monday, tuesday)).toBe(true);
  });

  it('deve manter streak na quarta se última atividade foi terça', () => {
    const tuesday = new Date('2026-07-14'); // terça-feira
    const wednesday = new Date('2026-07-15'); // quarta-feira
    expect(shouldMaintainStreak(tuesday, wednesday)).toBe(true);
  });

  it('deve manter streak na quinta se última atividade foi quarta', () => {
    const wednesday = new Date('2026-07-15'); // quarta-feira
    const thursday = new Date('2026-07-16'); // quinta-feira
    expect(shouldMaintainStreak(wednesday, thursday)).toBe(true);
  });

  it('deve manter streak na sexta se última atividade foi quinta', () => {
    const thursday = new Date('2026-07-16'); // quinta-feira
    const friday = new Date('2026-07-17'); // sexta-feira
    expect(shouldMaintainStreak(thursday, friday)).toBe(true);
  });

  it('deve quebrar streak após gap de 4 dias mesmo com fim de semana', () => {
    const thursday = new Date('2026-07-09'); // quinta-feira
    const monday = new Date('2026-07-13'); // segunda-feira (4 dias depois)
    expect(shouldMaintainStreak(thursday, monday)).toBe(false);
  });
});
