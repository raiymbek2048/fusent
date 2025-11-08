import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import api from '@/lib/api'

export interface Notification {
  id: string
  userId: string
  type: 'order' | 'message' | 'social' | 'system'
  title: string
  message: string
  read: boolean
  data?: Record<string, any>
  createdAt: string
}

// Get user notifications
export const useNotifications = (userId?: string) => {
  return useQuery({
    queryKey: ['notifications', userId],
    queryFn: async (): Promise<Notification[]> => {
      if (!userId) throw new Error('User ID required')
      const response = await api.get<Notification[]>(`/notifications/${userId}`)
      return response.data
    },
    enabled: !!userId,
    refetchInterval: 30000, // Refetch every 30 seconds
  })
}

// Get unread count
export const useUnreadNotificationsCount = (userId?: string) => {
  return useQuery({
    queryKey: ['notifications', 'unread', userId],
    queryFn: async (): Promise<number> => {
      if (!userId) throw new Error('User ID required')
      const response = await api.get<{ count: number }>(`/notifications/${userId}/unread/count`)
      return response.data.count
    },
    enabled: !!userId,
    refetchInterval: 30000,
  })
}

// Mark notification as read
export const useMarkNotificationRead = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (notificationId: string): Promise<void> => {
      await api.put(`/notifications/${notificationId}/read`)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] })
    },
  })
}

// Mark all notifications as read
export const useMarkAllNotificationsRead = (userId?: string) => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (): Promise<void> => {
      if (!userId) throw new Error('User ID required')
      await api.put(`/notifications/${userId}/read-all`)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] })
      toast.success('Все уведомления прочитаны')
    },
  })
}

// Delete notification
export const useDeleteNotification = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (notificationId: string): Promise<void> => {
      await api.delete(`/notifications/${notificationId}`)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] })
    },
  })
}
