'use client'

import { useRouter } from 'next/navigation'
import { Package, ChevronRight } from 'lucide-react'
import { useUserOrders } from '@/hooks/useOrders'
import { useAuthStore } from '@/store/authStore'
import { Badge, Card, CardContent, LoadingScreen } from '@/components/ui'
import MainLayout from '@/components/MainLayout'

const statusColors = {
  pending: 'default' as const,
  paid: 'info' as const,
  cancelled: 'error' as const,
  fulfilled: 'success' as const,
  refunded: 'warning' as const,
}

const statusLabels = {
  pending: 'Ожидает оплаты',
  paid: 'Оплачен',
  cancelled: 'Отменен',
  fulfilled: 'Выполнен',
  refunded: 'Возвращен',
}

export default function OrdersPage() {
  const router = useRouter()
  const user = useAuthStore((state) => state.user)
  const { data: orders, isLoading } = useUserOrders(user?.id)

  if (!user) {
    router.push('/login')
    return null
  }

  if (isLoading) {
    return <LoadingScreen message="Загрузка заказов..." />
  }

  if (!orders || orders.length === 0) {
    return (
      <MainLayout>
        <div className="container mx-auto px-4 py-12">
          <div className="max-w-md mx-auto text-center">
            <Package className="w-24 h-24 mx-auto text-gray-300 mb-4" />
            <h1 className="text-2xl font-bold text-gray-900 mb-2">
              У вас пока нет заказов
            </h1>
            <p className="text-gray-600 mb-6">
              Начните покупки и ваши заказы появятся здесь
            </p>
          </div>
        </div>
      </MainLayout>
    )
  }

  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-6">
          Мои заказы
        </h1>

        <div className="space-y-4">
          {orders.map((order) => (
            <Card
              key={order.id}
              hover
              onClick={() => router.push(`/orders/${order.id}`)}
            >
              <CardContent className="flex items-center justify-between">
                <div className="flex-grow">
                  <div className="flex items-center gap-3 mb-2">
                    <h3 className="font-semibold text-gray-900">
                      Заказ #{order.id.slice(0, 8)}
                    </h3>
                    <Badge variant={statusColors[order.status]}>
                      {statusLabels[order.status]}
                    </Badge>
                  </div>
                  <p className="text-sm text-gray-600 mb-1">
                    Магазин: {order.shopName}
                  </p>
                  <p className="text-sm text-gray-500">
                    {new Date(order.createdAt).toLocaleDateString('ru-RU', {
                      day: 'numeric',
                      month: 'long',
                      year: 'numeric',
                      hour: '2-digit',
                      minute: '2-digit',
                    })}
                  </p>
                </div>

                <div className="text-right flex items-center gap-4">
                  <div>
                    <p className="text-sm text-gray-600 mb-1">
                      {order.itemCount} {order.itemCount === 1 ? 'товар' : 'товара'}
                    </p>
                    <p className="text-xl font-bold text-gray-900">
                      {order.totalAmount.toLocaleString()} сом
                    </p>
                  </div>
                  <ChevronRight className="w-5 h-5 text-gray-400" />
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </MainLayout>
  )
}
