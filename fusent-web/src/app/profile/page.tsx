'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { User, ShoppingBag, Store, Settings, LogOut } from 'lucide-react'
import { useAuthStore } from '@/store/authStore'
import { useUserOrders } from '@/hooks/useOrders'
import { useSellerShops } from '@/hooks/useShops'
import { useLogout } from '@/hooks/useAuth'
import { Button, Card, CardContent, Badge, LoadingScreen } from '@/components/ui'
import MainLayout from '@/components/MainLayout'

export default function ProfilePage() {
  const router = useRouter()
  const user = useAuthStore((state) => state.user)
  const isLoading = useAuthStore((state) => state.isLoading)
  const logout = useLogout()

  const { data: orders } = useUserOrders(user?.id)
  const { data: shops } = useSellerShops(user?.id || '')

  const [activeTab, setActiveTab] = useState<'info' | 'orders' | 'shops'>('info')

  // Show loading screen while checking authentication
  if (isLoading) {
    return <LoadingScreen message="Загрузка профиля..." />
  }

  // Redirect to login if not authenticated
  if (!user) {
    router.push('/login')
    return null
  }

  const handleLogout = () => {
    if (confirm('Вы уверены, что хотите выйти?')) {
      logout.mutate()
    }
  }

  const roleLabels = {
    ADMIN: 'Администратор',
    SELLER: 'Продавец',
    BUYER: 'Покупатель',
  }

  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto">
          {/* Profile Header */}
          <Card className="mb-6">
            <CardContent className="flex items-center gap-6">
              <div className="w-24 h-24 bg-blue-100 rounded-full flex items-center justify-center">
                <User className="w-12 h-12 text-blue-600" />
              </div>
              <div className="flex-grow">
                <h1 className="text-2xl font-bold text-gray-900 mb-1">
                  {user.profile?.firstName || user.email}
                  {user.profile?.lastName && ` ${user.profile.lastName}`}
                </h1>
                <p className="text-gray-600 mb-2">{user.email}</p>
                <Badge>{roleLabels[user.role]}</Badge>
              </div>
              <div className="space-y-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => router.push('/profile/settings')}
                >
                  <Settings className="w-4 h-4 mr-2" />
                  Настройки
                </Button>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={handleLogout}
                >
                  <LogOut className="w-4 h-4 mr-2" />
                  Выйти
                </Button>
              </div>
            </CardContent>
          </Card>

          {/* Tabs */}
          <div className="flex gap-2 mb-6">
            <button
              onClick={() => setActiveTab('info')}
              className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                activeTab === 'info'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Информация
            </button>
            <button
              onClick={() => setActiveTab('orders')}
              className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                activeTab === 'orders'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Мои заказы ({orders?.length || 0})
            </button>
            {user.role === 'SELLER' && (
              <button
                onClick={() => setActiveTab('shops')}
                className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                  activeTab === 'shops'
                    ? 'bg-blue-600 text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                Мои магазины ({shops?.length || 0})
              </button>
            )}
          </div>

          {/* Tab Content */}
          {activeTab === 'info' && (
            <Card>
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-xl font-semibold">Личная информация</h2>
              </div>
              <CardContent className="space-y-4">
                <div>
                  <label className="text-sm text-gray-600">Email</label>
                  <p className="text-gray-900 font-medium">{user.email}</p>
                </div>
                {user.profile?.firstName && (
                  <div>
                    <label className="text-sm text-gray-600">Имя</label>
                    <p className="text-gray-900 font-medium">
                      {user.profile.firstName} {user.profile.lastName}
                    </p>
                  </div>
                )}
                {user.profile?.phone && (
                  <div>
                    <label className="text-sm text-gray-600">Телефон</label>
                    <p className="text-gray-900 font-medium">{user.profile.phone}</p>
                  </div>
                )}
                <div>
                  <label className="text-sm text-gray-600">Роль</label>
                  <p className="text-gray-900 font-medium">{roleLabels[user.role]}</p>
                </div>
                <div>
                  <label className="text-sm text-gray-600">Дата регистрации</label>
                  <p className="text-gray-900 font-medium">
                    {new Date(user.createdAt).toLocaleDateString('ru-RU', {
                      day: 'numeric',
                      month: 'long',
                      year: 'numeric',
                    })}
                  </p>
                </div>
              </CardContent>
            </Card>
          )}

          {activeTab === 'orders' && (
            <div className="space-y-3">
              {orders && orders.length > 0 ? (
                orders.slice(0, 5).map((order) => (
                  <Card
                    key={order.id}
                    hover
                    onClick={() => router.push(`/orders/${order.id}`)}
                  >
                    <CardContent className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <ShoppingBag className="w-10 h-10 text-gray-400" />
                        <div>
                          <p className="font-medium text-gray-900">
                            Заказ #{order.id.slice(0, 8)}
                          </p>
                          <p className="text-sm text-gray-600">{order.shopName}</p>
                        </div>
                      </div>
                      <div className="text-right">
                        <p className="font-semibold text-gray-900">
                          {order.totalAmount.toLocaleString()} сом
                        </p>
                        <Badge variant="info" size="sm">
                          {order.status}
                        </Badge>
                      </div>
                    </CardContent>
                  </Card>
                ))
              ) : (
                <Card>
                  <CardContent className="text-center py-12">
                    <ShoppingBag className="w-16 h-16 mx-auto text-gray-300 mb-4" />
                    <p className="text-gray-600">У вас пока нет заказов</p>
                  </CardContent>
                </Card>
              )}
              {orders && orders.length > 5 && (
                <Button
                  fullWidth
                  variant="outline"
                  onClick={() => router.push('/orders')}
                >
                  Показать все заказы
                </Button>
              )}
            </div>
          )}

          {activeTab === 'shops' && user.role === 'SELLER' && (
            <div className="space-y-3">
              {shops && shops.length > 0 ? (
                shops.map((shop) => (
                  <Card
                    key={shop.id}
                    hover
                    onClick={() => router.push(`/shops/${shop.id}`)}
                  >
                    <CardContent className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <Store className="w-10 h-10 text-gray-400" />
                        <div>
                          <p className="font-medium text-gray-900">{shop.name}</p>
                          <p className="text-sm text-gray-600">
                            {shop.totalProducts} товаров
                          </p>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="flex items-center gap-1 mb-1">
                          <span className="text-yellow-500">★</span>
                          <span className="font-medium">{shop.rating.toFixed(1)}</span>
                        </div>
                        <p className="text-sm text-gray-600">
                          {shop.totalReviews} отзывов
                        </p>
                      </div>
                    </CardContent>
                  </Card>
                ))
              ) : (
                <Card>
                  <CardContent className="text-center py-12">
                    <Store className="w-16 h-16 mx-auto text-gray-300 mb-4" />
                    <p className="text-gray-600 mb-4">У вас пока нет магазинов</p>
                    <Button onClick={() => router.push('/shops/create')}>
                      Создать магазин
                    </Button>
                  </CardContent>
                </Card>
              )}
            </div>
          )}
        </div>
      </div>
    </MainLayout>
  )
}
