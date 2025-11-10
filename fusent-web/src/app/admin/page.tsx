'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/store/authStore'
import MainLayout from '@/components/MainLayout'
import {
  Users,
  ShoppingBag,
  Store,
  Package,
  TrendingUp,
  AlertCircle,
  DollarSign,
  Activity
} from 'lucide-react'

export default function AdminDashboard() {
  const router = useRouter()
  const { user, isAuthenticated } = useAuthStore()

  useEffect(() => {
    if (!isAuthenticated || user?.role !== 'ADMIN') {
      router.push('/')
    }
  }, [isAuthenticated, user, router])

  if (!user || user.role !== 'ADMIN') {
    return null
  }

  // Mock statistics - replace with real API calls
  const stats = [
    {
      title: 'Всего пользователей',
      value: '1,234',
      change: '+12%',
      icon: Users,
      color: 'blue',
    },
    {
      title: 'Активные заказы',
      value: '56',
      change: '+5%',
      icon: ShoppingBag,
      color: 'green',
    },
    {
      title: 'Магазины',
      value: '89',
      change: '+8%',
      icon: Store,
      color: 'purple',
    },
    {
      title: 'Продукты',
      value: '3,456',
      change: '+15%',
      icon: Package,
      color: 'orange',
    },
    {
      title: 'Выручка (сегодня)',
      value: '₸ 245,600',
      change: '+22%',
      icon: DollarSign,
      color: 'emerald',
    },
    {
      title: 'Активность',
      value: '892',
      change: '-3%',
      icon: Activity,
      color: 'red',
    },
  ]

  const recentAlerts = [
    { id: 1, type: 'warning', message: 'Низкий остаток товара #12345', time: '5 минут назад' },
    { id: 2, type: 'info', message: 'Новый продавец зарегистрирован', time: '15 минут назад' },
    { id: 3, type: 'error', message: 'Ошибка платежа заказа #7890', time: '1 час назад' },
  ]

  return (
    <MainLayout>
      <div className="max-w-7xl mx-auto px-4 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Панель администратора
          </h1>
          <p className="text-gray-600">
            Управление платформой Fucent
          </p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
          {stats.map((stat) => {
            const Icon = stat.icon
            return (
              <div
                key={stat.title}
                className="bg-white rounded-lg shadow p-6 border border-gray-200 hover:shadow-lg transition-shadow"
              >
                <div className="flex items-center justify-between mb-4">
                  <div className={`p-3 rounded-lg bg-${stat.color}-100`}>
                    <Icon className={`h-6 w-6 text-${stat.color}-600`} />
                  </div>
                  <span
                    className={`text-sm font-semibold ${
                      stat.change.startsWith('+') ? 'text-green-600' : 'text-red-600'
                    }`}
                  >
                    {stat.change}
                  </span>
                </div>
                <h3 className="text-gray-600 text-sm font-medium mb-1">
                  {stat.title}
                </h3>
                <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
              </div>
            )
          })}
        </div>

        {/* Quick Actions & Alerts */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Quick Actions */}
          <div className="bg-white rounded-lg shadow p-6 border border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Быстрые действия
            </h2>
            <div className="space-y-3">
              <button
                onClick={() => router.push('/admin/users')}
                className="w-full text-left px-4 py-3 bg-gray-50 hover:bg-gray-100 rounded-lg transition-colors flex items-center justify-between"
              >
                <span className="flex items-center gap-3">
                  <Users className="h-5 w-5 text-blue-600" />
                  <span className="font-medium">Управление пользователями</span>
                </span>
              </button>
              <button
                onClick={() => router.push('/admin/orders')}
                className="w-full text-left px-4 py-3 bg-gray-50 hover:bg-gray-100 rounded-lg transition-colors flex items-center justify-between"
              >
                <span className="flex items-center gap-3">
                  <ShoppingBag className="h-5 w-5 text-green-600" />
                  <span className="font-medium">Управление заказами</span>
                </span>
              </button>
              <button
                onClick={() => router.push('/admin/products')}
                className="w-full text-left px-4 py-3 bg-gray-50 hover:bg-gray-100 rounded-lg transition-colors flex items-center justify-between"
              >
                <span className="flex items-center gap-3">
                  <Package className="h-5 w-5 text-purple-600" />
                  <span className="font-medium">Модерация продуктов</span>
                </span>
              </button>
              <button
                onClick={() => router.push('/admin/posts')}
                className="w-full text-left px-4 py-3 bg-gray-50 hover:bg-gray-100 rounded-lg transition-colors flex items-center justify-between"
              >
                <span className="flex items-center gap-3">
                  <Activity className="h-5 w-5 text-orange-600" />
                  <span className="font-medium">Модерация постов</span>
                </span>
              </button>
            </div>
          </div>

          {/* Recent Alerts */}
          <div className="bg-white rounded-lg shadow p-6 border border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Последние уведомления
            </h2>
            <div className="space-y-3">
              {recentAlerts.map((alert) => (
                <div
                  key={alert.id}
                  className="flex items-start gap-3 p-3 bg-gray-50 rounded-lg"
                >
                  <AlertCircle
                    className={`h-5 w-5 flex-shrink-0 mt-0.5 ${
                      alert.type === 'error'
                        ? 'text-red-600'
                        : alert.type === 'warning'
                        ? 'text-yellow-600'
                        : 'text-blue-600'
                    }`}
                  />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900">
                      {alert.message}
                    </p>
                    <p className="text-xs text-gray-500 mt-1">{alert.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  )
}
