import { useQuery } from '@tanstack/react-query'
import api from '@/lib/api'

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
