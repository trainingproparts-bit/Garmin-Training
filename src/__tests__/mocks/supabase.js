// src/__tests__/mocks/supabase.js
// Mock do cliente Supabase para testes isolados

export const createMockSupabaseClient = () => {
  const mockData = {};
  const mockError = null;

  return {
    auth: {
      getUser: jest.fn().mockResolvedValue({
        data: { user: { id: 'mock-user-id' } },
        error: null,
      }),
      signOut: jest.fn().mockResolvedValue({ error: null }),
      signInWithPassword: jest.fn().mockResolvedValue({
        data: { user: { id: 'mock-user-id' } },
        error: null,
      }),
    },
    from: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    single: jest.fn().mockResolvedValue({
      data: {
        id: 'mock-user-id',
        full_name: 'Mock User',
        roles: { code: 'collaborator', label: 'Colaborador' },
      },
      error: null,
    }),
    rpc: jest.fn().mockResolvedValue({ data: null, error: null }),
  };
};

export const mockSupabase = createMockSupabaseClient();
