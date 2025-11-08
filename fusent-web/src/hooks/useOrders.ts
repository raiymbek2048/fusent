import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useRouter } from 'next/navigation'
import toast from 'react-hot-toast'
import api from '@/lib/api'
import { Order, OrderSummary, CheckoutRequest } from '@/types'

// Get order by ID
export const useOrder = (orderId?: string) => {
  return useQuery({
    queryKey: ['order', orderId],
    queryFn: async (): Promise<Order> => {
      if (!orderId) throw new Error('Order ID required')
      const response = await api.get<Order>(`/orders/${orderId}`)
      return response.data
    },
    enabled: !!orderId,
  })
}

// Get user orders
export const useUserOrders = (userId?: string) => {
  return useQuery({
    queryKey: ['orders', 'user', userId],
    queryFn: async (): Promise<OrderSummary[]> => {
      if (!userId) throw new Error('User ID required')
      const response = await api.get<OrderSummary[]>(`/orders/user/${userId}`)
      return response.data
    },
    enabled: !!userId,
  })
}

// Get shop orders
export const useShopOrders = (shopId?: string) => {
  return useQuery({
    queryKey: ['orders', 'shop', shopId],
    queryFn: async (): Promise<OrderSummary[]> => {
      if (!shopId) throw new Error('Shop ID required')
      const response = await api.get<OrderSummary[]>(`/orders/shop/${shopId}`)
      return response.data
    },
    enabled: !!shopId,
  })
}

// Checkout from cart
export const useCheckout = (userId?: string) => {
  const router = useRouter()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (request: CheckoutRequest): Promise<Order> => {
      if (!userId) throw new Error('User ID required')
      const response = await api.post<Order>(`/checkout/${userId}`, request)
      return response.data
    },
    onSuccess: (order) => {
      // Invalidate cart and orders queries
      queryClient.invalidateQueries({ queryKey: ['cart', userId] })
      queryClient.invalidateQueries({ queryKey: ['cart-summary', userId] })
      queryClient.invalidateQueries({ queryKey: ['orders', 'user', userId] })

      toast.success('Заказ успешно оформлен!')
      router.push(`/orders/${order.id}`)
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка оформления заказа'
      toast.error(message)
    },
  })
}

// Update order status
export const useUpdateOrderStatus = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({
      orderId,
      status,
    }: {
      orderId: string
      status: string
    }): Promise<Order> => {
      const response = await api.put<Order>(`/orders/${orderId}/status`, {
        status,
      })
      return response.data
    },
    onSuccess: (order) => {
      queryClient.invalidateQueries({ queryKey: ['order', order.id] })
      queryClient.invalidateQueries({ queryKey: ['orders'] })
      toast.success('Статус заказа обновлен')
    },
    onError: (error: any) => {
      const message =
        error.response?.data?.message || 'Ошибка обновления статуса заказа'
      toast.error(message)
    },
  })
}

// Cancel order
export const useCancelOrder = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (orderId: string): Promise<void> => {
      await api.delete(`/orders/${orderId}`)
    },
    onSuccess: (_, orderId) => {
      queryClient.invalidateQueries({ queryKey: ['order', orderId] })
      queryClient.invalidateQueries({ queryKey: ['orders'] })
      toast.success('Заказ отменен')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка отмены заказа'
      toast.error(message)
    },
  })
}
