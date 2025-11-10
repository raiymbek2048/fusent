import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import api from '@/lib/api'
import { Conversation, Message, SendMessageRequest, PageResponse, PageRequest } from '@/types'

// Get user conversations
export const useConversations = (userId?: string) => {
  return useQuery({
    queryKey: ['conversations', userId],
    queryFn: async (): Promise<Conversation[]> => {
      if (!userId) throw new Error('User ID required')
      const response = await api.get<Conversation[]>('/chat/conversations')
      return response.data
    },
    enabled: !!userId,
  })
}

// Get conversation by ID
export const useConversation = (conversationId?: string) => {
  return useQuery({
    queryKey: ['conversation', conversationId],
    queryFn: async (): Promise<Conversation> => {
      if (!conversationId) throw new Error('Conversation ID required')
      const response = await api.get<Conversation>(`/chat/conversations/${conversationId}`)
      return response.data
    },
    enabled: !!conversationId,
  })
}

// Get messages for conversation
export const useMessages = (conversationId?: string, params?: PageRequest) => {
  return useQuery({
    queryKey: ['messages', conversationId, params],
    queryFn: async (): Promise<PageResponse<Message>> => {
      if (!conversationId) throw new Error('Conversation ID required')
      const response = await api.get<PageResponse<Message>>(
        `/chat/conversations/${conversationId}/messages`,
        { params }
      )
      return response.data
    },
    enabled: !!conversationId,
  })
}

// Create or get conversation
export const useCreateConversation = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (sellerId: string): Promise<Conversation> => {
      const response = await api.post<Conversation>('/chat/conversations', { sellerId })
      return response.data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['conversations'] })
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка создания чата'
      toast.error(message)
    },
  })
}

// Send message
export const useSendMessage = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (request: SendMessageRequest): Promise<Message> => {
      const response = await api.post<Message>('/chat/messages', request)
      return response.data
    },
    onSuccess: (message) => {
      queryClient.invalidateQueries({ queryKey: ['messages', message.conversationId] })
      queryClient.invalidateQueries({ queryKey: ['conversations'] })
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка отправки сообщения'
      toast.error(message)
    },
  })
}

// Mark messages as read
export const useMarkMessagesRead = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (conversationId: string): Promise<void> => {
      await api.post(`/chat/conversations/${conversationId}/read`)
    },
    onSuccess: (_, conversationId) => {
      queryClient.invalidateQueries({ queryKey: ['conversation', conversationId] })
      queryClient.invalidateQueries({ queryKey: ['conversations'] })
    },
  })
}
