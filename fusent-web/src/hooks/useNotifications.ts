import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '@/lib/api'
import toast from 'react-hot-toast'

export interface NotificationLog {
  id: string
  channel: 'PUSH' | 'SMS' | 'EMAIL' | 'IN_APP'
  recipient: string
  templateKey: string
  payloadJson: Record<string, any>
  status: 'QUEUED' | 'DELIVERED' | 'FAILED'
  provider?: string
  providerRef?: string
  attempts: number
  lastError?: string
  createdAt: string
  deliveredAt?: string
}

// Get notification history for user
export const useNotificationHistory = (recipient?: string) => {
  return useQuery({
    queryKey: ['notifications', 'history', recipient],
    queryFn: async (): Promise<NotificationLog[]> => {
      if (!recipient) throw new Error('Recipient required')
      const response = await api.get<NotificationLog[]>(`/notifications/history/${recipient}`, {
        params: { page: 0, size: 50 }
      })
      return response.data
    },
    enabled: !!recipient,
    refetchInterval: 30000, // Refetch every 30 seconds
  })
}

// Get unread notifications count
export const useUnreadNotificationsCount = (recipient?: string) => {
  return useQuery({
    queryKey: ['notifications', 'unread', recipient],
    queryFn: async (): Promise<number> => {
      if (!recipient) return 0
      const response = await api.get<NotificationLog[]>(`/notifications/history/${recipient}`, {
        params: { page: 0, size: 100 }
      })
      // Filter for IN_APP notifications that are QUEUED (not delivered yet)
      const unread = response.data.filter(
        n => n.channel === 'IN_APP' && n.status === 'QUEUED'
      )
      return unread.length
    },
    enabled: !!recipient,
    refetchInterval: 30000,
  })
}

// Mark all notifications as read
export const useMarkAllAsRead = (recipient?: string) => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async () => {
      await api.patch('/notifications/mark-all-read')
    },
    onSuccess: () => {
      // Invalidate and refetch notifications
      queryClient.invalidateQueries({ queryKey: ['notifications', 'history', recipient] })
      queryClient.invalidateQueries({ queryKey: ['notifications', 'unread', recipient] })
      toast.success('Все уведомления отмечены как прочитанные')
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Ошибка при обновлении уведомлений')
    },
  })
}

// Mark single notification as read
export const useMarkAsRead = (recipient?: string) => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (notificationId: string) => {
      await api.patch(`/notifications/${notificationId}/read`)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications', 'history', recipient] })
      queryClient.invalidateQueries({ queryKey: ['notifications', 'unread', recipient] })
    },
    onError: (error: any) => {
      console.error('Error marking notification as read:', error)
    },
  })
}
