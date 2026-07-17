// src/__tests__/GpsTrail.test.js
// Testes para regras de bloqueio da Trilha GPS (GpsTrail.js)

import { describe, it, expect, vi } from 'vitest';
import { renderGpsTrail, calcularProgresso, proximoCheckpoint } from '../components/GpsTrail.js';

describe('GpsTrail - Regras de Bloqueio Sequencial', () => {
  it('deve bloquear checkpoint quando módulo anterior não está concluído', () => {
    const container = document.createElement('div');
    const zones = [
      {
        id: 'zone-1',
        name: 'Zona Explorador',
        free_order: false,
        checkpoints: [
          { id: 'cp-1', checkpoint_type: 'module', reference_id: 'mod-1', title: 'Módulo 1', is_required: true },
          { id: 'cp-2', checkpoint_type: 'quiz', reference_id: 'quiz-1', title: 'Quiz 1', is_required: true },
          { id: 'cp-3', checkpoint_type: 'module', reference_id: 'mod-2', title: 'Módulo 2', is_required: true },
        ],
      },
    ];
    
    // Apenas o primeiro checkpoint está concluído
    const doneCheckpointIds = new Set(['cp-1']);
    const onCheckpointClick = vi.fn();
    
    renderGpsTrail(container, zones, doneCheckpointIds, onCheckpointClick);
    
    // Verifica estados
    const cards = container.querySelectorAll('.media-card');
    expect(cards.length).toBe(3);
    
    // cp-1 deve estar concluído (done)
    expect(cards[0].classList.contains('done')).toBe(true);
    expect(cards[0].dataset.clickable).toBe('true');
    
    // cp-2 deve ser atual (current) - primeiro pendente
    expect(cards[1].classList.contains('current')).toBe(true);
    expect(cards[1].dataset.clickable).toBe('true');
    
    // cp-3 deve estar bloqueado (locked) - módulo anterior não concluído
    expect(cards[2].classList.contains('locked')).toBe(true);
    expect(cards[2].dataset.clickable).toBe('false');
  });

  it('deve liberar todos os checkpoints em zona com free_order=true', () => {
    const container = document.createElement('div');
    const zones = [
      {
        id: 'zone-1',
        name: 'Circuito de Desafios',
        free_order: true,
        checkpoints: [
          { id: 'cp-1', checkpoint_type: 'module', reference_id: 'mod-1', title: 'Módulo 1', is_required: true },
          { id: 'cp-2', checkpoint_type: 'quiz', reference_id: 'quiz-1', title: 'Quiz 1', is_required: true },
          { id: 'cp-3', checkpoint_type: 'game', reference_id: 'game-1', title: 'Jogo 1', is_required: true },
        ],
      },
    ];
    
    // Nenhum checkpoint concluído
    const doneCheckpointIds = new Set();
    const onCheckpointClick = vi.fn();
    
    renderGpsTrail(container, zones, doneCheckpointIds, onCheckpointClick);
    
    const cards = container.querySelectorAll('.media-card');
    expect(cards.length).toBe(3);
    
    // Todos devem ser "current" (não locked) em zona free_order
    cards.forEach((card) => {
      expect(card.classList.contains('locked')).toBe(false);
      expect(card.dataset.clickable).toBe('true');
    });
  });

  it('deve calcular progresso corretamente', () => {
    const zones = [
      {
        id: 'zone-1',
        name: 'Zona 1',
        free_order: false,
        checkpoints: [
          { id: 'cp-1', checkpoint_type: 'module', reference_id: 'mod-1', title: 'M1', is_required: true },
          { id: 'cp-2', checkpoint_type: 'quiz', reference_id: 'quiz-1', title: 'Q1', is_required: true },
        ],
      },
      {
        id: 'zone-2',
        name: 'Zona 2',
        free_order: false,
        checkpoints: [
          { id: 'cp-3', checkpoint_type: 'module', reference_id: 'mod-2', title: 'M2', is_required: true },
        ],
      },
    ];
    
    // 2 de 3 concluídos
    const doneCheckpointIds = new Set(['cp-1', 'cp-3']);
    
    const progresso = calcularProgresso(zones, doneCheckpointIds);
    
    expect(progresso.total).toBe(3);
    expect(progresso.done).toBe(2);
    expect(progresso.pct).toBe(67); // Math.round(2/3 * 100)
  });

  it('deve identificar próximo checkpoint pendente', () => {
    const zones = [
      {
        id: 'zone-1',
        name: 'Zona 1',
        free_order: false,
        checkpoints: [
          { id: 'cp-1', checkpoint_type: 'module', reference_id: 'mod-1', title: 'M1', is_required: true },
          { id: 'cp-2', checkpoint_type: 'quiz', reference_id: 'quiz-1', title: 'Q1', is_required: true },
        ],
      },
    ];
    
    const doneCheckpointIds = new Set(['cp-1']);
    
    const proximo = proximoCheckpoint(zones, doneCheckpointIds);
    
    expect(proximo).not.toBeNull();
    expect(proximo.checkpoint.id).toBe('cp-2');
    expect(proximo.zone.id).toBe('zone-1');
  });

  it('deve retornar null quando todos os checkpoints estão concluídos', () => {
    const zones = [
      {
        id: 'zone-1',
        name: 'Zona 1',
        free_order: false,
        checkpoints: [
          { id: 'cp-1', checkpoint_type: 'module', reference_id: 'mod-1', title: 'M1', is_required: true },
          { id: 'cp-2', checkpoint_type: 'quiz', reference_id: 'quiz-1', title: 'Q1', is_required: true },
        ],
      },
    ];
    
    const doneCheckpointIds = new Set(['cp-1', 'cp-2']);
    
    const proximo = proximoCheckpoint(zones, doneCheckpointIds);
    
    expect(proximo).toBeNull();
  });
});
