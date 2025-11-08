import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import api from '@/lib/api'
import { useCartStore } from '@/store/cartStore'
import {
  Cart,
  CartItem,
  CartSummary,
  AddToCartRequest,
  UpdateCartItemRequest,
} from '@/types'

// Get cart for user
export const useCart = (userId?: string) => {
  const setCart = useCartStore((state) => state.setCart)
  const setLoading = useCartStore((state) => state.setLoading)

  return useQuery({
    queryKey: ['cart', userId],
    queryFn: async (): Promise<Cart> => {
      if (!userId) throw new Error('User ID required')
      const response = await api.get<Cart>(`/cart/${userId}`)
      return response.data
    },
    enabled: !!userId,
    onSuccess: (cart) => {
      setCart(cart)
      setLoading(false)
    },
    onError: () => {
      setLoading(false)
    },
  })
}

// Get cart summary
export const useCartSummary = (userId?: string) => {
  return useQuery({
    queryKey: ['cart-summary', userId],
    queryFn: async (): Promise<CartSummary> => {
      if (!userId) throw new Error('User ID required')
      const response = await api.get<CartSummary>(`/cart/${userId}/summary`)
      return response.data
    },
    enabled: !!userId,
  })
}

// Add item to cart
export const useAddToCart = (userId?: string) => {
  const queryClient = useQueryClient()
  const addItem = useCartStore((state) => state.addItem)

  return useMutation({
    mutationFn: async (request: AddToCartRequest): Promise<CartItem> => {
      if (!userId) throw new Error('User ID required')
      const response = await api.post<CartItem>(`/cart/${userId}/items`, request)
      return response.data
    },
    onSuccess: (item) => {
      addItem(item)
      queryClient.invalidateQueries({ queryKey: ['cart', userId] })
      queryClient.invalidateQueries({ queryKey: ['cart-summary', userId] })
      toast.success('Товар добавлен в корзину')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка добавления в корзину'
      toast.error(message)
    },
  })
}

// Update cart item quantity
export const useUpdateCartItem = (userId?: string) => {
  const queryClient = useQueryClient()
  const updateItem = useCartStore((state) => state.updateItem)

  return useMutation({
    mutationFn: async ({
      variantId,
      qty,
    }: {
      variantId: string
      qty: number
    }): Promise<CartItem> => {
      if (!userId) throw new Error('User ID required')
      const request: UpdateCartItemRequest = { qty }
      const response = await api.put<CartItem>(
        `/cart/${userId}/items/${variantId}`,
        request
      )
      return response.data
    },
    onSuccess: (item) => {
      updateItem(item.variantId, item.qty)
      queryClient.invalidateQueries({ queryKey: ['cart', userId] })
      queryClient.invalidateQueries({ queryKey: ['cart-summary', userId] })
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка обновления корзины'
      toast.error(message)
    },
  })
}

// Remove item from cart
export const useRemoveFromCart = (userId?: string) => {
  const queryClient = useQueryClient()
  const removeItem = useCartStore((state) => state.removeItem)

  return useMutation({
    mutationFn: async (variantId: string): Promise<void> => {
      if (!userId) throw new Error('User ID required')
      await api.delete(`/cart/${userId}/items/${variantId}`)
    },
    onSuccess: (_, variantId) => {
      removeItem(variantId)
      queryClient.invalidateQueries({ queryKey: ['cart', userId] })
      queryClient.invalidateQueries({ queryKey: ['cart-summary', userId] })
      toast.success('Товар удален из корзины')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка удаления из корзины'
      toast.error(message)
    },
  })
}

// Clear cart
export const useClearCart = (userId?: string) => {
  const queryClient = useQueryClient()
  const clearCart = useCartStore((state) => state.clearCart)

  return useMutation({
    mutationFn: async (): Promise<void> => {
      if (!userId) throw new Error('User ID required')
      await api.delete(`/cart/${userId}`)
    },
    onSuccess: () => {
      clearCart()
      queryClient.invalidateQueries({ queryKey: ['cart', userId] })
      queryClient.invalidateQueries({ queryKey: ['cart-summary', userId] })
      toast.success('Корзина очищена')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка очистки корзины'
      toast.error(message)
    },
  })
}
