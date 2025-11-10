import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import api from '@/lib/api'

export interface PaymentResponse {
  paymentId: string
  orderId: string
  status: 'pending' | 'processing' | 'success' | 'failed' | 'cancelled'
  paymentMethod: string
  amount: number
  currency: string
  transactionId: string
  paymentUrl?: string
  provider: string
  createdAt: string
  paidAt?: string
  errorMessage?: string
}

export interface InitiatePaymentRequest {
  orderId: string
  paymentMethod: 'cash' | 'card' | 'online'
  returnUrl?: string
  callbackUrl?: string
}

// Initiate payment
export const useInitiatePayment = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (request: InitiatePaymentRequest): Promise<PaymentResponse> => {
      const response = await api.post<PaymentResponse>('/payments/initiate', request)
      return response.data
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['orders'] })
      queryClient.invalidateQueries({ queryKey: ['order', data.orderId] })

      if (data.paymentUrl) {
        // Redirect to payment gateway
        toast.success('Перенаправление на страницу оплаты...')
        setTimeout(() => {
          window.location.href = data.paymentUrl!
        }, 1000)
      } else if (data.paymentMethod === 'cash') {
        toast.success('Заказ создан! Оплата при получении')
      }
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка при инициализации платежа'
      toast.error(message)
    },
  })
}

// Get payment status
export const usePaymentStatus = (orderId?: string) => {
  return useQuery({
    queryKey: ['payment', 'status', orderId],
    queryFn: async (): Promise<PaymentResponse> => {
      if (!orderId) throw new Error('Order ID required')
      const response = await api.get<PaymentResponse>(`/payments/status/${orderId}`)
      return response.data
    },
    enabled: !!orderId,
  })
}

// Verify payment (after returning from gateway)
export const useVerifyPayment = () => {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({
      orderId,
      transactionId,
    }: {
      orderId: string
      transactionId: string
    }): Promise<PaymentResponse> => {
      const response = await api.post<PaymentResponse>(
        `/payments/verify/${orderId}?transactionId=${transactionId}`
      )
      return response.data
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['orders'] })
      queryClient.invalidateQueries({ queryKey: ['order', data.orderId] })
      toast.success('Платёж подтверждён!')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка при подтверждении платежа'
      toast.error(message)
    },
  })
}
