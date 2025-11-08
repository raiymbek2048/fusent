import { useQuery } from '@tanstack/react-query'
import api from '@/lib/api'
import { Product, PageResponse, PageRequest } from '@/types'

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
