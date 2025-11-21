'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/store/authStore'
import MainLayout from '@/components/MainLayout'
import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/api'
import {
  Users,
  ShoppingBag,
  Store,
  Package,
  TrendingUp,
  AlertCircle,
  DollarSign,
  Activity,
  FolderTree,
  CheckCircle
} from 'lucide-react'

interface DashboardStats {
  totalUsers: number
  totalSellers: number
  totalMerchants: number
  pendingMerchants: number
  totalProducts: number
  blockedProducts: number
  totalOrders: number
  pendingOrders: number
}

export default function AdminDashboard() {
  const router = useRouter()
  const { user, isAuthenticated } = useAuthStore()

  const { data: statsData } = useQuery<DashboardStats>({
    queryKey: ['admin', 'stats'],
    queryFn: async () => {
      const response = await api.get<DashboardStats>('/admin/stats')
      return response.data
    },
    enabled: isAuthenticated && user?.role === 'ADMIN',
  })

  useEffect(() => {
    if (!isAuthenticated || user?.role !== 'ADMIN') {
      router.push('/')
    }
  }, [isAuthenticated, user, router])

  if (!user || user.role !== 'ADMIN') {
    return null
  }

  const stats = [
    {
      title: 'Всего пользователей',
      value: statsData?.totalUsers?.toLocaleString() || '0',
      icon: Users,
      color: 'blue',
    },
    {
      title: 'Продавцы',
      value: statsData?.totalSellers?.toLocaleString() || '0',
      icon: ShoppingBag,
      color: 'green',
    },
    {
      title: 'Магазины',
      value: statsData?.totalMerchants?.toLocaleString() || '0',
      icon: Store,
      color: 'purple',
    },
    {
      title: 'Ожидают одобрения',
      value: statsData?.pendingMerchants?.toLocaleString() || '0',
      icon: AlertCircle,
      color: 'yellow',
    },
    {
      title: 'Продукты',
      value: statsData?.totalProducts?.toLocaleString() || '0',
      icon: Package,
      color: 'orange',
    },
    {
      title: 'Заблокировано товаров',
      value: statsData?.blockedProducts?.toLocaleString() || '0',
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
              <button
                onClick={() => router.push('/admin/categories')}
                className="w-full text-left px-4 py-3 bg-gray-50 hover:bg-gray-100 rounded-lg transition-colors flex items-center justify-between"
              >
                <span className="flex items-center gap-3">
                  <FolderTree className="h-5 w-5 text-indigo-600" />
                  <span className="font-medium">Управление категориями</span>
                </span>
              </button>
              <button
                onClick={() => router.push('/admin/merchants')}
                className="w-full text-left px-4 py-3 bg-gray-50 hover:bg-gray-100 rounded-lg transition-colors flex items-center justify-between"
              >
                <span className="flex items-center gap-3">
                  <CheckCircle className="h-5 w-5 text-teal-600" />
                  <span className="font-medium">Одобрение магазинов</span>
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
