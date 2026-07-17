// src/__tests__/QuizGameHardening.test.js
// Testes para hardening de Quizzes e Games (RPC calls)

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { submitAnswer, finalizeQuizAttempt } from '../services/quizService.js';
import { submitGameRound, finalizeGameSession } from '../services/gameService.js';

// Mock do Supabase - usando vi.hoisted para evitar problema de hoisting
const { mockSupabase } = vi.hoisted(() => {
  return {
    mockSupabase: {
      rpc: vi.fn(),
    },
  };
});

vi.mock('../config/supabase.js', () => ({
  supabase: mockSupabase,
}));

describe('Quiz Service - Hardening via RPC', () => {
  beforeEach(() => {
    mockSupabase.rpc.mockClear();
  });

  it('deve chamar RPC fn_submit_quiz_answer com parâmetros corretos', async () => {
    mockSupabase.rpc.mockResolvedValue({
      data: { is_correct: true, explanation: 'Porque sim.' }, // resposta correta (sql/039 — RPC agora retorna is_correct + explanation)
      error: null,
    });

    const attemptId = 'attempt-123';
    const questionId = 'question-456';
    const alternativeId = 'alternative-789';

    const result = await submitAnswer(attemptId, questionId, alternativeId);

    expect(mockSupabase.rpc).toHaveBeenCalledWith('fn_submit_quiz_answer', {
      p_attempt_id: attemptId,
      p_question_id: questionId,
      p_alternative_id: alternativeId,
    });
    expect(result).toEqual({ isCorrect: true, explanation: 'Porque sim.' });
  });

  it('deve chamar RPC fn_submit_quiz_answer e retornar isCorrect false para resposta incorreta', async () => {
    mockSupabase.rpc.mockResolvedValue({
      data: { is_correct: false, explanation: null }, // resposta incorreta, sem explicação cadastrada
      error: null,
    });

    const result = await submitAnswer('attempt-123', 'question-456', 'alternative-789');

    expect(result).toEqual({ isCorrect: false, explanation: null });
  });

  it('deve lançar erro quando RPC fn_submit_quiz_answer falha', async () => {
    mockSupabase.rpc.mockResolvedValue({
      data: null,
      error: { message: 'RPC error' },
    });

    await expect(
      submitAnswer('attempt-123', 'question-456', 'alternative-789')
    ).rejects.toThrow('RPC error');
  });

  it('deve chamar RPC fn_finalize_quiz_attempt e retornar dados atualizados', async () => {
    const mockAttemptData = {
      id: 'attempt-123',
      score_pct: 85.5,
      passed: true,
      attempt_number: 1,
    };

    mockSupabase.rpc.mockResolvedValue({
      data: mockAttemptData,
      error: null,
    });

    const result = await finalizeQuizAttempt('attempt-123');

    expect(mockSupabase.rpc).toHaveBeenCalledWith('fn_finalize_quiz_attempt', {
      p_attempt_id: 'attempt-123',
    });
    expect(result).toEqual(mockAttemptData);
  });

  it('deve lançar erro quando RPC fn_finalize_quiz_attempt falha', async () => {
    mockSupabase.rpc.mockResolvedValue({
      data: null,
      error: { message: 'Finalization error' },
    });

    await expect(finalizeQuizAttempt('attempt-123')).rejects.toThrow('Finalization error');
  });
});

describe('Game Service - Hardening via RPC', () => {
  beforeEach(() => {
    mockSupabase.rpc.mockClear();
  });

  it('deve chamar RPC fn_submit_game_round com parâmetros corretos', async () => {
    mockSupabase.rpc.mockResolvedValue({
      data: true, // resposta correta
      error: null,
    });

    const sessionId = 'session-123';
    const roundIndex = 0;
    const chosenKey = 'option-a';

    const result = await submitGameRound(sessionId, roundIndex, chosenKey);

    expect(mockSupabase.rpc).toHaveBeenCalledWith('fn_submit_game_round', {
      p_session_id: sessionId,
      p_round_index: roundIndex,
      p_chosen_key: chosenKey,
    });
    expect(result).toBe(true);
  });

  it('deve chamar RPC fn_submit_game_round e retornar false para resposta incorreta', async () => {
    mockSupabase.rpc.mockResolvedValue({
      data: false, // resposta incorreta
      error: null,
    });

    const result = await submitGameRound('session-123', 0, 'option-a');

    expect(result).toBe(false);
  });

  it('deve lançar erro quando RPC fn_submit_game_round falha', async () => {
    mockSupabase.rpc.mockResolvedValue({
      data: null,
      error: { message: 'Game RPC error' },
    });

    await expect(
      submitGameRound('session-123', 0, 'option-a')
    ).rejects.toThrow('Game RPC error');
  });

  it('deve chamar RPC fn_finalize_game_session e retornar placar calculado', async () => {
    const mockSessionData = {
      id: 'session-123',
      game_scores: {
        score: 90,
        accuracy_pct: 85.5,
      },
    };

    mockSupabase.rpc.mockResolvedValue({
      data: [mockSessionData],
      error: null,
    });

    const result = await finalizeGameSession('session-123');

    expect(mockSupabase.rpc).toHaveBeenCalledWith('fn_finalize_game_session', {
      p_session_id: 'session-123',
    });
    expect(result).toEqual(mockSessionData);
  });

  it('deve lançar erro quando RPC fn_finalize_game_session falha', async () => {
    mockSupabase.rpc.mockResolvedValue({
      data: null,
      error: { message: 'Game finalization error' },
    });

    await expect(finalizeGameSession('session-123')).rejects.toThrow('Game finalization error');
  });
});
