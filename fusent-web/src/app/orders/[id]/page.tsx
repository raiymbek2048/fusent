'use client'

import { useParams, useRouter } from 'next/navigation'
import Image from 'next/image'
import { ArrowLeft, Package, MapPin, CreditCard } from 'lucide-react'
import { useOrder, useCancelOrder } from '@/hooks/useOrders'
import { useAuthStore } from '@/store/authStore'
import { Button, Badge, Card, CardContent, LoadingScreen } from '@/components/ui'
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

export default function OrderDetailPage() {
  const params = useParams()
  const router = useRouter()
  const orderId = params.id as string
  const user = useAuthStore((state) => state.user)

  const { data: order, isLoading } = useOrder(orderId)
  const cancelOrder = useCancelOrder()

  if (!user) {
    router.push('/login')
    return null
  }

  if (isLoading) {
    return <LoadingScreen message="Загрузка заказа..." />
  }

  if (!order) {
    return (
      <MainLayout>
        <div className="container mx-auto px-4 py-12 text-center">
          <h1 className="text-2xl font-bold text-gray-900">Заказ не найден</h1>
          <Button onClick={() => router.push('/orders')} className="mt-4">
            К списку заказов
          </Button>
        </div>
      </MainLayout>
    )
  }

  const handleCancelOrder = () => {
    if (confirm('Вы уверены, что хотите отменить заказ?')) {
      cancelOrder.mutate(order.id, {
        onSuccess: () => {
          router.push('/orders')
        },
      })
    }
  }

  const canCancel = order.status === 'pending' || order.status === 'paid'

  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-8">
        {/* Header */}
        <div className="flex items-center gap-4 mb-6">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => router.push('/orders')}
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-grow">
            <h1 className="text-3xl font-bold text-gray-900">
              Заказ #{order.id.slice(0, 8)}
            </h1>
            <p className="text-gray-600 mt-1">
              {new Date(order.createdAt).toLocaleDateString('ru-RU', {
                day: 'numeric',
                month: 'long',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
              })}
            </p>
          </div>
          <Badge variant={statusColors[order.status]} size="md">
            {statusLabels[order.status]}
          </Badge>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Order Items */}
          <div className="lg:col-span-2 space-y-4">
            <Card>
              <div className="px-6 py-4 border-b border-gray-200">
                <div className="flex items-center gap-2">
                  <Package className="w-5 h-5 text-gray-600" />
                  <h2 className="text-xl font-semibold">Товары</h2>
                </div>
              </div>
              <CardContent className="divide-y divide-gray-200">
                {order.items.map((item) => (
                  <div key={item.id} className="py-4 flex gap-4">
                    <div className="w-20 h-20 bg-gray-100 rounded overflow-hidden flex-shrink-0">
                      {item.productImage && (
                        <Image
                          src={item.productImage}
                          alt={item.productName}
                          width={80}
                          height={80}
                          className="w-full h-full object-cover"
                        />
                      )}
                    </div>
                    <div className="flex-grow">
                      <h4 className="font-medium text-gray-900 mb-1">
                        {item.productName}
                      </h4>
                      <p className="text-sm text-gray-600 mb-2">
                        {item.variantName}
                      </p>
                      <p className="text-sm text-gray-600">
                        {item.price.toLocaleString()} сом × {item.qty}
                      </p>
                    </div>
                    <div className="text-right">
                      <p className="font-semibold text-gray-900">
                        {item.subtotal.toLocaleString()} сом
                      </p>
                    </div>
                  </div>
                ))}
              </CardContent>
            </Card>

            {/* Delivery Info */}
            <Card>
              <div className="px-6 py-4 border-b border-gray-200">
                <div className="flex items-center gap-2">
                  <MapPin className="w-5 h-5 text-gray-600" />
                  <h2 className="text-xl font-semibold">Доставка</h2>
                </div>
              </div>
              <CardContent>
                <p className="text-gray-700">
                  Адрес доставки указан при оформлении заказа
                </p>
              </CardContent>
            </Card>
          </div>

          {/* Order Summary */}
          <div className="space-y-4">
            <Card>
              <div className="px-6 py-4 border-b border-gray-200">
                <h3 className="font-semibold text-gray-900">Детали заказа</h3>
              </div>
              <CardContent className="space-y-3">
                <div className="flex justify-between text-gray-600">
                  <span>Магазин:</span>
                  <span className="font-medium">{order.shopName}</span>
                </div>
                <div className="flex justify-between text-gray-600">
                  <span>Товаров:</span>
                  <span>{order.items.length}</span>
                </div>
                {order.paidAt && (
                  <div className="flex justify-between text-gray-600">
                    <span>Оплачен:</span>
                    <span className="text-sm">
                      {new Date(order.paidAt).toLocaleDateString('ru-RU')}
                    </span>
                  </div>
                )}
                {order.fulfilledAt && (
                  <div className="flex justify-between text-gray-600">
                    <span>Выполнен:</span>
                    <span className="text-sm">
                      {new Date(order.fulfilledAt).toLocaleDateString('ru-RU')}
                    </span>
                  </div>
                )}
                <div className="border-t pt-3 flex justify-between text-xl font-bold">
                  <span>Итого:</span>
                  <span>{order.totalAmount.toLocaleString()} сом</span>
                </div>
              </CardContent>
            </Card>

            {/* Actions */}
            {canCancel && (
              <Button
                fullWidth
                variant="danger"
                onClick={handleCancelOrder}
                isLoading={cancelOrder.isPending}
              >
                Отменить заказ
              </Button>
            )}

            <Button
              fullWidth
              variant="outline"
              onClick={() => router.push(`/shops/${order.shopId}`)}
            >
              Перейти в магазин
            </Button>
          </div>
        </div>
      </div>
    </MainLayout>
  )
}
