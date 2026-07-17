// src/services/notificationService.js
// Camada de acesso ao sininho do dashboard (tabela notifications).
// INSERT não é liberado para o client (ver RLS em
// sql/005_evaluations_and_notifications.sql) — notificações nascem só da
// trigger fn_notify_trail_completed ou de ação de admin. Este service só
// lê e marca como lida.

import { supabase } from '../config/supabase.js';

/** Notificações do usuário, mais recente primeiro. */
export async function fetchUserNotifications(userId) {
  const { data, error } = await supabase
    .from('notifications')
    .select('id, title, message, type, is_read, created_at, action_url')
    .eq('user_id', userId)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return data;
}

/** Quantidade de notificações não lidas — para o badge numérico do sininho. */
export async function countUnreadNotifications(userId) {
  const { count, error } = await supabase
    .from('notifications')
    .select('id', { count: 'exact', head: true })
    .eq('user_id', userId)
    .eq('is_read', false);
  if (error) throw error;
  return count || 0;
}

/** Marca uma notificação como lida (RLS permite só a própria). */
export async function markAsRead(notificationId) {
  const { error } = await supabase
    .from('notifications')
    .update({ is_read: true })
    .eq('id', notificationId);
  if (error) throw error;
}
