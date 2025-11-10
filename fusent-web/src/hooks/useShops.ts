import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import api from '@/lib/api'
import { Shop, CreateShopRequest, PageResponse, PageRequest } from '@/types'

// Get all shops with pagination
export const useShops = (params?: PageRequest) => {
  return useQuery({
    queryKey: ['shops', params],
    queryFn: async (): Promise<PageResponse<Shop>> => {
      const response = await api.get<PageResponse<Shop>>('/shops', { params })
      return response.data
    },
  })
}

// Get single shop
export const useShop = (shopId: string) => {
  return useQuery({
    queryKey: ['shop', shopId],
    queryFn: async (): Promise<Shop> => {
      const response = await api.get<Shop>(`/shops/${shopId}`)
      return response.data
    },
    enabled: !!shopId,
  })
}

// Get shops by seller
export const useSellerShops = (sellerId: string) => {
  return useQuery({
    queryKey: ['shops', 'seller', sellerId],
    queryFn: async (): Promise<Shop[]> => {
      const response = await api.get<Shop[]>(`/shops/seller/${sellerId}`)
      return response.data
    },
    enabled: !!sellerId,
  })
}

// Create shop mutation
export const useCreateShop = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (data: CreateShopRequest): Promise<Shop> => {
      const response = await api.post<Shop>('/shops', data)
      return response.data
    },
    onSuccess: () => {
      // Invalidate all shops queries to refetch
      queryClient.invalidateQueries({ queryKey: ['shops'] })
      toast.success('Магазин создан успешно!')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка создания магазина'
      toast.error(message)
    },
  })
}

// Update shop mutation
export const useUpdateShop = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({
      id,
      data,
    }: {
      id: string
      data: Partial<CreateShopRequest>
    }): Promise<Shop> => {
      const response = await api.put<Shop>(`/shops/${id}`, data)
      return response.data
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['shop', data.id] })
      queryClient.invalidateQueries({ queryKey: ['shops'] })
      toast.success('Магазин обновлен!')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка обновления магазина'
      toast.error(message)
    },
  })
}

// Delete shop mutation
export const useDeleteShop = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (shopId: string): Promise<void> => {
      await api.delete(`/shops/${shopId}`)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['shops'] })
      toast.success('Магазин удален')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка удаления магазина'
      toast.error(message)
    },
  })
}
