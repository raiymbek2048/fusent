import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import api from '@/lib/api'
import { FollowRequest, FollowTargetType } from '@/types'

interface FollowResponse {
  id: string
  followerId: string
  targetType: FollowTargetType
  targetId: string
  targetName?: string
  createdAt: string
}

interface FollowersStatsResponse {
  followersCount: number
  followingCount: number
}

// Check if current user is following
export const useIsFollowing = (targetType: FollowTargetType, targetId: string, options?: { enabled?: boolean }) => {
  return useQuery({
    queryKey: ['isFollowing', targetType, targetId],
    queryFn: async (): Promise<boolean> => {
      const response = await api.get<boolean>(`/social/follows/${targetType}/${targetId}/is-following`)
      return response.data
    },
    ...options,
  })
}

// Get following list
export const useFollowing = (userId: string) => {
  return useQuery({
    queryKey: ['following', userId],
    queryFn: async (): Promise<FollowResponse[]> => {
      const response = await api.get<FollowResponse[]>(`/social/users/${userId}/following`)
      return response.data
    },
    enabled: !!userId,
  })
}

// Get followers list
export const useFollowers = (targetType: FollowTargetType, targetId: string) => {
  return useQuery({
    queryKey: ['followers', targetType, targetId],
    queryFn: async (): Promise<FollowResponse[]> => {
      const response = await api.get<FollowResponse[]>(`/social/follows/${targetType}/${targetId}/followers`)
      return response.data
    },
    enabled: !!targetType && !!targetId,
  })
}

// Get follow stats
export const useFollowStats = (targetType: FollowTargetType, targetId: string) => {
  return useQuery({
    queryKey: ['followStats', targetType, targetId],
    queryFn: async (): Promise<FollowersStatsResponse> => {
      const response = await api.get<FollowersStatsResponse>(`/social/follows/${targetType}/${targetId}/stats`)
      return response.data
    },
    enabled: !!targetType && !!targetId,
  })
}

// Follow mutation
export const useFollow = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (data: FollowRequest): Promise<FollowResponse> => {
      const response = await api.post<FollowResponse>('/social/follows', data)
      return response.data
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['isFollowing'] })
      queryClient.invalidateQueries({ queryKey: ['followers'] })
      queryClient.invalidateQueries({ queryKey: ['following'] })
      queryClient.invalidateQueries({ queryKey: ['followStats'] })
      queryClient.invalidateQueries({ queryKey: ['posts', 'following'] })
      toast.success('Вы подписались!')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка подписки'
      toast.error(message)
    },
  })
}

// Unfollow mutation
export const useUnfollow = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({ targetType, targetId }: { targetType: FollowTargetType; targetId: string }): Promise<void> => {
      await api.delete(`/social/follows/${targetType}/${targetId}`)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['isFollowing'] })
      queryClient.invalidateQueries({ queryKey: ['followers'] })
      queryClient.invalidateQueries({ queryKey: ['following'] })
      queryClient.invalidateQueries({ queryKey: ['followStats'] })
      queryClient.invalidateQueries({ queryKey: ['posts', 'following'] })
      toast.success('Вы отписались')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка отписки'
      toast.error(message)
    },
  })
}
