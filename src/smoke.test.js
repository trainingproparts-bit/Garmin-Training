import { describe, it, expect } from 'vitest';

describe('Smoke test', () => {
  it('should pass a basic assertion', () => {
    expect(1 + 1).toBe(2);
  });

  it('should handle string operations', () => {
    const str = 'Garmin Training Hub';
    expect(str).toContain('Garmin');
  });
});
