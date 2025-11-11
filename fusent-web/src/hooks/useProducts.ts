import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import api from '@/lib/api'
import { Product, PageResponse, PageRequest, CreateProductRequest } from '@/types'

// Get all products with pagination
export const useProducts = (params?: PageRequest & { categoryId?: string; shopId?: string }) => {
  return useQuery({
    queryKey: ['products', params],
    queryFn: async (): Promise<PageResponse<Product>> => {
      const response = await api.get<PageResponse<Product>>('/public/catalog/products', { params })
      return response.data
    },
  })
}

// Get single product
export const useProduct = (productId: string) => {
  return useQuery({
    queryKey: ['product', productId],
    queryFn: async (): Promise<Product> => {
      const response = await api.get<Product>(`/public/catalog/products/${productId}`)
      return response.data
    },
    enabled: !!productId,
  })
}

// Get products by shop
export const useShopProducts = (shopId: string, params?: PageRequest) => {
  return useQuery({
    queryKey: ['products', 'shop', shopId, params],
    queryFn: async (): Promise<PageResponse<Product>> => {
      const response = await api.get<PageResponse<Product>>(`/public/catalog/products`, {
        params: { ...params, shopId },
      })
      return response.data
    },
    enabled: !!shopId,
  })
}

// Search products
export const useSearchProducts = (query: string, params?: PageRequest) => {
  return useQuery({
    queryKey: ['products', 'search', query, params],
    queryFn: async (): Promise<PageResponse<Product>> => {
      const response = await api.get<PageResponse<Product>>('/public/catalog/products/search', {
        params: { ...params, query },
      })
      return response.data
    },
    enabled: !!query && query.length > 0,
  })
}

// Create product
export const useCreateProduct = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (data: CreateProductRequest): Promise<Product> => {
      const response = await api.post<Product>('/catalog/products', data)
      return response.data
    },
    onSuccess: (product) => {
      queryClient.invalidateQueries({ queryKey: ['products'] })
      queryClient.invalidateQueries({ queryKey: ['products', 'shop', product.shopId] })
      toast.success('Товар создан!')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка создания товара'
      toast.error(message)
    },
  })
}

// Update product
export const useUpdateProduct = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({ id, data }: { id: string; data: Partial<CreateProductRequest> }): Promise<Product> => {
      const response = await api.put<Product>(`/catalog/products/${id}`, data)
      return response.data
    },
    onSuccess: (product) => {
      queryClient.invalidateQueries({ queryKey: ['product', product.id] })
      queryClient.invalidateQueries({ queryKey: ['products'] })
      queryClient.invalidateQueries({ queryKey: ['products', 'shop', product.shopId] })
      toast.success('Товар обновлен!')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка обновления товара'
      toast.error(message)
    },
  })
}

// Delete product
export const useDeleteProduct = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (productId: string): Promise<void> => {
      await api.delete(`/catalog/products/${productId}`)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] })
      toast.success('Товар удален!')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка удаления товара'
      toast.error(message)
    },
  })
}
