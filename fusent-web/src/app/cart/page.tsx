'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import Image from 'next/image'
import { Trash2, ShoppingBag } from 'lucide-react'
import { useCart, useUpdateCartItem, useRemoveFromCart, useClearCart } from '@/hooks/useCart'
import { useAuthStore } from '@/store/authStore'
import { Button, Card, CardContent, LoadingScreen } from '@/components/ui'
import MainLayout from '@/components/MainLayout'
import { Cart } from '@/types'

export const dynamic = 'force-dynamic'

export default function CartPage() {
  const router = useRouter()
  const user = useAuthStore((state) => state.user)

  const { data: cart, isLoading } = useCart(user?.id) as { data: Cart | undefined, isLoading: boolean }
  const updateItem = useUpdateCartItem(user?.id)
  const removeItem = useRemoveFromCart(user?.id)
  const clearCart = useClearCart(user?.id)

  useEffect(() => {
    if (!user) {
      router.push('/login')
    }
  }, [user, router])

  if (!user) {
    return <LoadingScreen message="Перенаправление..." />
  }

  if (isLoading) {
    return <LoadingScreen message="Загрузка корзины..." />
  }

  if (!cart || cart.items.length === 0) {
    return (
      <MainLayout>
        <div className="container mx-auto px-4 py-12">
          <div className="max-w-md mx-auto text-center">
            <ShoppingBag className="w-24 h-24 mx-auto text-gray-300 mb-4" />
            <h1 className="text-2xl font-bold text-gray-900 mb-2">
              Корзина пуста
            </h1>
            <p className="text-gray-600 mb-6">
              Добавьте товары в корзину, чтобы продолжить покупки
            </p>
            <Button onClick={() => router.push('/')}>
              Перейти к покупкам
            </Button>
          </div>
        </div>
      </MainLayout>
    )
  }

  const handleUpdateQuantity = (variantId: string, newQty: number) => {
    if (newQty < 1) return
    updateItem.mutate({ variantId, qty: newQty })
  }

  const handleRemoveItem = (variantId: string) => {
    if (confirm('Удалить товар из корзины?')) {
      removeItem.mutate(variantId)
    }
  }

  const handleClearCart = () => {
    if (confirm('Очистить всю корзину?')) {
      clearCart.mutate()
    }
  }

  const handleCheckout = () => {
    router.push('/checkout')
  }

  // Group items by shop
  const itemsByShop = cart.items.reduce((acc, item) => {
    if (!acc[item.shopId]) {
      acc[item.shopId] = {
        shopId: item.shopId,
        shopName: item.shopName,
        items: [],
      }
    }
    acc[item.shopId].items.push(item)
    return acc
  }, {} as Record<string, { shopId: string; shopName: string; items: typeof cart.items }>)

  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-8">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-3xl font-bold text-gray-900">Корзина</h1>
          {cart.items.length > 0 && (
            <Button variant="ghost" onClick={handleClearCart}>
              Очистить корзину
            </Button>
          )}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Cart Items */}
          <div className="lg:col-span-2 space-y-4">
            {Object.values(itemsByShop).map((shop) => (
              <Card key={shop.shopId}>
                <div className="px-6 py-3 border-b border-gray-200 bg-gray-50">
                  <h3 className="font-semibold text-gray-900">{shop.shopName}</h3>
                </div>
                <CardContent className="divide-y divide-gray-200">
                  {shop.items.map((item) => (
                    <div key={item.id} className="py-4 flex gap-4">
                      {/* Product Image */}
                      <div className="w-24 h-24 bg-gray-100 rounded-lg overflow-hidden flex-shrink-0">
                        {item.productImage ? (
                          <Image
                            src={item.productImage}
                            alt={item.productName}
                            width={96}
                            height={96}
                            className="w-full h-full object-cover"
                          />
                        ) : (
                          <div className="w-full h-full flex items-center justify-center text-gray-400 text-xs">
                            Нет фото
                          </div>
                        )}
                      </div>

                      {/* Product Info */}
                      <div className="flex-grow">
                        <h4 className="font-medium text-gray-900 mb-1">
                          {item.productName}
                        </h4>
                        <p className="text-sm text-gray-600 mb-2">
                          {item.variantName}
                        </p>
                        <p className="text-lg font-semibold text-gray-900">
                          {item.price.toLocaleString()} сом
                        </p>

                        {/* Quantity Controls */}
                        <div className="flex items-center gap-2 mt-3">
                          <button
                            onClick={() => handleUpdateQuantity(item.variantId, item.qty - 1)}
                            className="w-8 h-8 border border-gray-300 rounded hover:bg-gray-100"
                            disabled={updateItem.isPending}
                          >
                            -
                          </button>
                          <span className="w-12 text-center font-medium">
                            {item.qty}
                          </span>
                          <button
                            onClick={() => handleUpdateQuantity(item.variantId, item.qty + 1)}
                            className="w-8 h-8 border border-gray-300 rounded hover:bg-gray-100"
                            disabled={updateItem.isPending || item.qty >= item.stockQty}
                          >
                            +
                          </button>
                          <span className="text-sm text-gray-500 ml-2">
                            В наличии: {item.stockQty}
                          </span>
                        </div>
                      </div>

                      {/* Subtotal & Remove */}
                      <div className="text-right flex flex-col justify-between">
                        <p className="text-xl font-bold text-gray-900">
                          {item.subtotal.toLocaleString()} сом
                        </p>
                        <button
                          onClick={() => handleRemoveItem(item.variantId)}
                          className="text-red-600 hover:text-red-700 mt-2"
                          disabled={removeItem.isPending}
                        >
                          <Trash2 className="w-5 h-5" />
                        </button>
                      </div>
                    </div>
                  ))}
                </CardContent>
              </Card>
            ))}
          </div>

          {/* Order Summary */}
          <div>
            <Card className="sticky top-4">
              <div className="px-6 py-4 border-b border-gray-200">
                <h3 className="font-semibold text-gray-900">Итого</h3>
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
              <div className="px-6 py-4 border-t">
                <Button
                  fullWidth
                  onClick={handleCheckout}
                  disabled={cart.items.length === 0}
                >
                  Оформить заказ
                </Button>
              </div>
            </Card>
          </div>
        </div>
      </div>
    </MainLayout>
  )
}
