import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import api from '@/lib/api'
import { Category } from '@/types'

// Get all categories
export const useCategories = () => {
  return useQuery({
    queryKey: ['categories'],
    queryFn: async (): Promise<Category[]> => {
      const response = await api.get<Category[]>('/catalog/categories')
      return response.data
    },
    staleTime: 10 * 60 * 1000, // 10 minutes
  })
}

// Get category by ID
export const useCategory = (categoryId?: string) => {
  return useQuery({
    queryKey: ['category', categoryId],
    queryFn: async (): Promise<Category> => {
      if (!categoryId) throw new Error('Category ID required')
      const response = await api.get<Category>(`/catalog/categories/${categoryId}`)
      return response.data
    },
    enabled: !!categoryId,
  })
}

// Get root categories (no parent)
export const useRootCategories = () => {
  return useQuery({
    queryKey: ['categories', 'root'],
    queryFn: async (): Promise<Category[]> => {
      const response = await api.get<Category[]>('/catalog/categories/root')
      return response.data
    },
    staleTime: 10 * 60 * 1000,
  })
}

// Get subcategories by parent ID
export const useSubcategories = (parentId?: string) => {
  return useQuery({
    queryKey: ['categories', 'sub', parentId],
    queryFn: async (): Promise<Category[]> => {
      if (!parentId) throw new Error('Parent ID required')
      const response = await api.get<Category[]>(`/catalog/categories/${parentId}/subcategories`)
      return response.data
    },
    enabled: !!parentId,
  })
}

// Create category (admin only)
export const useCreateCategory = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (data: Partial<Category>): Promise<Category> => {
      const response = await api.post<Category>('/catalog/categories', data)
      return response.data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['categories'] })
      toast.success('Категория создана!')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка создания категории'
      toast.error(message)
    },
  })
}
