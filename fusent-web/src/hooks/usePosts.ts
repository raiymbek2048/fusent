import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import api from '@/lib/api'
import { Post, Comment, CreatePostRequest, CreateCommentRequest, PageResponse, PageRequest } from '@/types'

// Get feed posts
export const useFeedPosts = (params?: PageRequest) => {
  return useQuery({
    queryKey: ['posts', 'feed', params],
    queryFn: async (): Promise<PageResponse<Post>> => {
      const response = await api.get<PageResponse<Post>>('/social/feed', { params })
      return response.data
    },
  })
}

// Get shop posts
export const useShopPosts = (shopId: string, params?: PageRequest) => {
  return useQuery({
    queryKey: ['posts', 'shop', shopId, params],
    queryFn: async (): Promise<PageResponse<Post>> => {
      const response = await api.get<PageResponse<Post>>(`/social/shops/${shopId}/posts`, { params })
      return response.data
    },
    enabled: !!shopId,
  })
}

// Get post comments
export const usePostComments = (postId: string, params?: PageRequest) => {
  return useQuery({
    queryKey: ['comments', postId, params],
    queryFn: async (): Promise<PageResponse<Comment>> => {
      const response = await api.get<PageResponse<Comment>>(`/social/posts/${postId}/comments`, { params })
      return response.data
    },
    enabled: !!postId,
  })
}

// Create post mutation
export const useCreatePost = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (data: CreatePostRequest): Promise<Post> => {
      const response = await api.post<Post>('/social/posts', data)
      return response.data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['posts'] })
      toast.success('Пост опубликован!')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка публикации поста'
      toast.error(message)
    },
  })
}

// Like post mutation
export const useLikePost = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (postId: string): Promise<void> => {
      await api.post(`/social/posts/${postId}/like`)
    },
    onSuccess: (_, postId) => {
      queryClient.invalidateQueries({ queryKey: ['posts'] })
    },
  })
}

// Unlike post mutation
export const useUnlikePost = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (postId: string): Promise<void> => {
      await api.delete(`/social/posts/${postId}/like`)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['posts'] })
    },
  })
}

// Create comment mutation
export const useCreateComment = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (data: CreateCommentRequest): Promise<Comment> => {
      const response = await api.post<Comment>('/social/comments', data)
      return response.data
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['comments', data.postId] })
      queryClient.invalidateQueries({ queryKey: ['posts'] })
      toast.success('Комментарий добавлен!')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка добавления комментария'
      toast.error(message)
    },
  })
}
