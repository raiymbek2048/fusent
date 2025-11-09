'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Image from 'next/image'
import { useCart } from '@/hooks/useCart'
import { useCheckout } from '@/hooks/useOrders'
import { useAuthStore } from '@/store/authStore'
import { Button, Card, CardContent, Input, LoadingScreen } from '@/components/ui'
import MainLayout from '@/components/MainLayout'
import { Cart } from '@/types'

export default function CheckoutPage() {
  const router = useRouter()
  const user = useAuthStore((state) => state.user)

  const { data: cart, isLoading } = useCart(user?.id) as { data: Cart | undefined, isLoading: boolean }
  const checkout = useCheckout(user?.id)

  const [shippingAddress, setShippingAddress] = useState('')
  const [phone, setPhone] = useState('')
  const [notes, setNotes] = useState('')
  const [paymentMethod, setPaymentMethod] = useState<'cash' | 'card'>('cash')

  if (!user) {
    router.push('/login')
    return null
  }

  if (isLoading) {
    return <LoadingScreen message="Загрузка..." />
  }

  if (!cart || cart.items.length === 0) {
    router.push('/cart')
    return null
  }

  // Group items by shop
  const itemsByShop = cart.items.reduce((acc, item) => {
    if (!acc[item.shopId]) {
      acc[item.shopId] = {
        shopId: item.shopId,
        shopName: item.shopName,
        items: [],
        total: 0,
      }
    }
    acc[item.shopId].items.push(item)
    acc[item.shopId].total += item.subtotal
    return acc
  }, {} as Record<string, { shopId: string; shopName: string; items: typeof cart.items; total: number }>)

  const handleCheckout = async (shopId: string) => {
    if (!shippingAddress.trim()) {
      alert('Укажите адрес доставки')
      return
    }

    if (!phone.trim()) {
      alert('Укажите номер телефона')
      return
    }

    checkout.mutate({
      shopId,
      shippingAddress: `${shippingAddress}\nТелефон: ${phone}`,
      paymentMethod,
      notes: notes || undefined,
    })
  }

  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-6">
          Оформление заказа
        </h1>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Checkout Form */}
          <div className="lg:col-span-2 space-y-6">
            {/* Delivery Info */}
            <Card>
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-xl font-semibold">Информация о доставке</h2>
              </div>
              <CardContent className="space-y-4">
                <Input
                  label="Адрес доставки"
                  placeholder="Улица, дом, квартира"
                  value={shippingAddress}
                  onChange={(e) => setShippingAddress(e.target.value)}
                  required
                />
                <Input
                  label="Номер телефона"
                  type="tel"
                  placeholder="+996 XXX XXX XXX"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  required
                />
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Комментарий к заказу
                  </label>
                  <textarea
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    rows={3}
                    placeholder="Дополнительная информация..."
                    value={notes}
                    onChange={(e) => setNotes(e.target.value)}
                  />
                </div>
              </CardContent>
            </Card>

            {/* Payment Method */}
            <Card>
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-xl font-semibold">Способ оплаты</h2>
              </div>
              <CardContent className="space-y-3">
                <label className="flex items-center gap-3 p-4 border-2 rounded-lg cursor-pointer hover:bg-gray-50">
                  <input
                    type="radio"
                    name="payment"
                    value="cash"
                    checked={paymentMethod === 'cash'}
                    onChange={(e) => setPaymentMethod(e.target.value as 'cash')}
                    className="w-4 h-4"
                  />
                  <div>
                    <div className="font-medium">Наличными при получении</div>
                    <div className="text-sm text-gray-500">
                      Оплата курьеру при доставке
                    </div>
                  </div>
                </label>
                <label className="flex items-center gap-3 p-4 border-2 rounded-lg cursor-pointer hover:bg-gray-50">
                  <input
                    type="radio"
                    name="payment"
                    value="card"
                    checked={paymentMethod === 'card'}
                    onChange={(e) => setPaymentMethod(e.target.value as 'card')}
                    className="w-4 h-4"
                  />
                  <div>
                    <div className="font-medium">Картой онлайн</div>
                    <div className="text-sm text-gray-500">
                      Visa, MasterCard, МИР
                    </div>
                  </div>
                </label>
              </CardContent>
            </Card>

            {/* Orders by Shop */}
            {Object.values(itemsByShop).map((shop) => (
              <Card key={shop.shopId}>
                <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
                  <h3 className="font-semibold text-gray-900">
                    Заказ из {shop.shopName}
                  </h3>
                </div>
                <CardContent className="divide-y divide-gray-200">
                  {shop.items.map((item) => (
                    <div key={item.id} className="py-3 flex gap-4">
                      <div className="w-16 h-16 bg-gray-100 rounded overflow-hidden flex-shrink-0">
                        {item.productImage && (
                          <Image
                            src={item.productImage}
                            alt={item.productName}
                            width={64}
                            height={64}
                            className="w-full h-full object-cover"
                          />
                        )}
                      </div>
                      <div className="flex-grow">
                        <h4 className="font-medium text-gray-900 text-sm">
                          {item.productName}
                        </h4>
                        <p className="text-xs text-gray-500">{item.variantName}</p>
                        <p className="text-sm text-gray-600 mt-1">
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
                <div className="px-6 py-4 border-t bg-gray-50">
                  <div className="flex justify-between items-center mb-4">
                    <span className="font-semibold">Итого:</span>
                    <span className="text-xl font-bold">
                      {shop.total.toLocaleString()} сом
                    </span>
                  </div>
                  <Button
                    fullWidth
                    onClick={() => handleCheckout(shop.shopId)}
                    isLoading={checkout.isPending}
                    disabled={!shippingAddress || !phone}
                  >
                    Оформить заказ из {shop.shopName}
                  </Button>
                </div>
              </Card>
            ))}
          </div>

          {/* Order Summary */}
          <div>
            <Card className="sticky top-4">
              <div className="px-6 py-4 border-b border-gray-200">
                <h3 className="font-semibold text-gray-900">Итого по всем заказам</h3>
              </div>
              <CardContent className="space-y-3">
                <div className="flex justify-between text-gray-600">
                  <span>Товары ({cart.totalItems})</span>
                  <span>{cart.totalAmount.toLocaleString()} сом</span>
                </div>
                <div className="flex justify-between text-gray-600">
                  <span>Доставка</span>
                  <span>Бесплатно</span>
                </div>
                <div className="border-t pt-3 flex justify-between text-xl font-bold">
                  <span>К оплате</span>
                  <span>{cart.totalAmount.toLocaleString()} сом</span>
                </div>
              </CardContent>
              <div className="px-6 py-4 border-t bg-gray-50 text-sm text-gray-600">
                <p>
                  Заказы из разных магазинов оформляются отдельно и могут быть доставлены в разное время
                </p>
              </div>
            </Card>
          </div>
        </div>
      </div>
    </MainLayout>
  )
}
