import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useRouter } from 'next/navigation'
import toast from 'react-hot-toast'
import api, { setTokens, clearTokens } from '@/lib/api'
import { useAuthStore } from '@/store/authStore'
import {
  AuthResponse,
  LoginRequest,
  RegisterRequest,
  ChangePasswordRequest,
  User,
} from '@/types'

// Get current user
export const useCurrentUser = () => {
  return useQuery({
    queryKey: ['currentUser'],
    queryFn: async (): Promise<User> => {
      const response = await api.get<User>('/auth/me')
      return response.data
    },
    retry: 1,  // Retry once to handle temporary network issues
    retryDelay: 1000,  // Wait 1 second before retrying
    staleTime: 5 * 60 * 1000, // 5 minutes
    gcTime: 10 * 60 * 1000, // Keep cached data for 10 minutes
    refetchOnWindowFocus: false,  // Don't refetch when window gains focus
    enabled: typeof window !== 'undefined' && !!localStorage.getItem('accessToken'),  // Only fetch if token exists
  })
}

// Login mutation
export const useLogin = () => {
  const router = useRouter()
  const setUser = useAuthStore((state) => state.setUser)
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (credentials: LoginRequest): Promise<AuthResponse> => {
      const response = await api.post<AuthResponse>('/auth/login', credentials)
      return response.data
    },
    onSuccess: (data) => {
      setTokens(data.accessToken, data.refreshToken)
      setUser(data.user)
      queryClient.setQueryData(['currentUser'], data.user)
      toast.success('Успешный вход!')
      router.push('/')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка входа'
      toast.error(message)
    },
  })
}

// Register mutation
export const useRegister = () => {
  const router = useRouter()
  const setUser = useAuthStore((state) => state.setUser)
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (data: RegisterRequest): Promise<AuthResponse> => {
      const response = await api.post<AuthResponse>('/auth/register', data)
      return response.data
    },
    onSuccess: (data) => {
      setTokens(data.accessToken, data.refreshToken)
      setUser(data.user)
      queryClient.setQueryData(['currentUser'], data.user)
      toast.success('Регистрация успешна!')
      router.push('/')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка регистрации'
      toast.error(message)
    },
  })
}

// Logout mutation
export const useLogout = () => {
  const router = useRouter()
  const logout = useAuthStore((state) => state.logout)
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async () => {
      // Just clear local state, no API call needed for stateless JWT
      clearTokens()
    },
    onSuccess: () => {
      logout()
      queryClient.clear()
      toast.success('Вы вышли из системы')
      router.push('/login')
    },
  })
}

// Change password mutation
export const useChangePassword = () => {
  return useMutation({
    mutationFn: async (data: ChangePasswordRequest): Promise<void> => {
      await api.post('/auth/change-password', data)
    },
    onSuccess: () => {
      toast.success('Пароль успешно изменен')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка смены пароля'
      toast.error(message)
    },
  })
}
