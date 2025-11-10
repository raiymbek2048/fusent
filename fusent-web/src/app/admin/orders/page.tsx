'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/store/authStore'
import MainLayout from '@/components/MainLayout'
import { Search, Package, Clock, CheckCircle, XCircle, TruckIcon, RefreshCw } from 'lucide-react'
import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/api'

interface Order {
  id: string
  userId: string
  shopId: string
  shopName: string
  status: 'PENDING' | 'PAID' | 'FULFILLED' | 'CANCELLED'
  itemCount: number
  totalAmount: number
  createdAt: string
}

interface OrdersResponse {
  content: Order[]
  totalElements: number
  totalPages: number
  number: number
  size: number
}

export default function AdminOrdersPage() {
  const router = useRouter()
  const { user, isAuthenticated } = useAuthStore()
  const [searchTerm, setSearchTerm] = useState('')
  const [filterStatus, setFilterStatus] = useState<'all' | 'PENDING' | 'PAID' | 'FULFILLED' | 'CANCELLED'>('all')
  const [page, setPage] = useState(0)

  useEffect(() => {
    if (!isAuthenticated || user?.role !== 'ADMIN') {
      router.push('/')
    }
  }, [isAuthenticated, user, router])

  const { data: ordersData, isLoading, refetch } = useQuery<OrdersResponse>({
    queryKey: ['admin', 'orders', page, filterStatus],
    queryFn: async () => {
      const params: any = { page, size: 20 }
      if (filterStatus !== 'all') {
        params.status = filterStatus
      }
      const response = await api.get<OrdersResponse>('/orders/all', { params })
      return response.data
    },
    enabled: isAuthenticated && user?.role === 'ADMIN',
  })

  if (!user || user.role !== 'ADMIN') {
    return null
  }

  const filteredOrders = ordersData?.content?.filter((order) => {
    const matchesSearch = !searchTerm ||
      order.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      order.userId.toLowerCase().includes(searchTerm.toLowerCase()) ||
      order.shopName.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesSearch
  }) || []

  const getStatusIcon = (status: string) => {
    const statusUpper = status.toUpperCase()
    switch (statusUpper) {
      case 'PENDING':
        return <Clock className="h-5 w-5 text-yellow-600" />
      case 'PAID':
        return <CheckCircle className="h-5 w-5 text-blue-600" />
      case 'FULFILLED':
        return <TruckIcon className="h-5 w-5 text-green-600" />
      case 'CANCELLED':
        return <XCircle className="h-5 w-5 text-red-600" />
      default:
        return <Package className="h-5 w-5 text-gray-600" />
    }
  }

  const getStatusBadge = (status: string) => {
    const statusUpper = status.toUpperCase()
    const colors = {
      PENDING: 'bg-yellow-100 text-yellow-800',
      PAID: 'bg-blue-100 text-blue-800',
      FULFILLED: 'bg-green-100 text-green-800',
      CANCELLED: 'bg-red-100 text-red-800',
    }
    return colors[statusUpper as keyof typeof colors] || 'bg-gray-100 text-gray-800'
  }

  const getStatusText = (status: string) => {
    const statusUpper = status.toUpperCase()
    const texts = {
      PENDING: 'Ожидает оплаты',
      PAID: 'Оплачен',
      FULFILLED: 'Выполнен',
      CANCELLED: 'Отменен',
    }
    return texts[statusUpper as keyof typeof texts] || status
  }

  const stats = [
    { label: 'Ожидают оплаты', value: ordersData?.content?.filter((o) => o.status === 'PENDING').length || 0, color: 'yellow' },
    { label: 'Оплачены', value: ordersData?.content?.filter((o) => o.status === 'PAID').length || 0, color: 'blue' },
    { label: 'Выполнены', value: ordersData?.content?.filter((o) => o.status === 'FULFILLED').length || 0, color: 'green' },
    { label: 'Отменены', value: ordersData?.content?.filter((o) => o.status === 'CANCELLED').length || 0, color: 'red' },
  ]

  return (
    <MainLayout>
      <div className="max-w-7xl mx-auto px-4 py-8">
        {/* Header */}
        <div className="mb-8">
          <button
            onClick={() => router.push('/admin')}
            className="text-blue-600 hover:text-blue-700 mb-4"
          >
            ← Назад к панели
          </button>
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Управление заказами</h1>
              <p className="text-gray-600">Всего заказов: {ordersData?.totalElements || 0}</p>
            </div>
            <button
              onClick={() => refetch()}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              <RefreshCw className="w-4 h-4" />
              Обновить
            </button>
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
          {stats.map((stat) => (
            <div
              key={stat.label}
              className="bg-white rounded-lg shadow p-4 border border-gray-200"
            >
              <p className="text-sm text-gray-600 mb-1">{stat.label}</p>
              <p className={`text-2xl font-bold text-${stat.color}-600`}>{stat.value}</p>
            </div>
          ))}
        </div>

        {/* Filters */}
        <div className="bg-white rounded-lg shadow p-6 mb-6 border border-gray-200">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                placeholder="Поиск по ID, пользователю, магазину..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <select
              value={filterStatus}
              onChange={(e) => {
                setFilterStatus(e.target.value as any)
                setPage(0)
              }}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="all">Все статусы</option>
              <option value="PENDING">Ожидает оплаты</option>
              <option value="PAID">Оплачен</option>
              <option value="FULFILLED">Выполнен</option>
              <option value="CANCELLED">Отменен</option>
            </select>
          </div>
        </div>

        {/* Orders Table */}
        {isLoading ? (
          <div className="bg-white rounded-lg shadow p-8 text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Загрузка заказов...</p>
          </div>
        ) : filteredOrders.length === 0 ? (
          <div className="bg-white rounded-lg shadow p-8 text-center">
            <p className="text-gray-600">Заказы не найдены</p>
          </div>
        ) : (
        <div className="bg-white rounded-lg shadow border border-gray-200 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    ID заказа
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Покупатель
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Магазин
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Статус
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Сумма
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Дата
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Действия
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filteredOrders.map((order) => (
                  <tr key={order.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        {getStatusIcon(order.status)}
                        <span className="ml-2 text-sm font-medium text-gray-900">
                          {order.id}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {order.userId}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {order.shopName}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span
                        className={`px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusBadge(
                          order.status
                        )}`}
                      >
                        {getStatusText(order.status)}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {order.totalAmount.toLocaleString()} ₸
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {new Date(order.createdAt).toLocaleString('ru-RU')}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <button className="text-blue-600 hover:text-blue-900">
                        Детали
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
        )}

        {/* Pagination */}
        {ordersData && ordersData.totalPages > 1 && (
          <div className="mt-6 flex justify-center gap-2">
            <button
              onClick={() => setPage(Math.max(0, page - 1))}
              disabled={page === 0}
              className="px-4 py-2 bg-white border rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
              Назад
            </button>
            <span className="px-4 py-2 bg-white border rounded-lg">
              Страница {page + 1} из {ordersData.totalPages}
            </span>
            <button
              onClick={() => setPage(Math.min(ordersData.totalPages - 1, page + 1))}
              disabled={page >= ordersData.totalPages - 1}
              className="px-4 py-2 bg-white border rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
              Далее
            </button>
          </div>
        )}
      </div>
    </MainLayout>
  )
}
