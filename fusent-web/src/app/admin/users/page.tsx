'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/store/authStore'
import MainLayout from '@/components/MainLayout'
import { Search, UserCheck, UserX, Shield, ShoppingBag, User as UserIcon, RefreshCw } from 'lucide-react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { api } from '@/lib/api'

interface User {
  id: string
  email: string
  role: 'ADMIN' | 'SELLER' | 'BUYER'
  createdAt: string
  updatedAt: string
  verified: boolean
  blocked: boolean
}

interface UsersResponse {
  content: User[]
  totalElements: number
  totalPages: number
  number: number
  size: number
}

export default function AdminUsersPage() {
  const router = useRouter()
  const { user, isAuthenticated } = useAuthStore()
  const queryClient = useQueryClient()
  const [searchTerm, setSearchTerm] = useState('')
  const [filterRole, setFilterRole] = useState<'all' | 'ADMIN' | 'SELLER' | 'BUYER'>('all')
  const [page, setPage] = useState(0)

  const blockMutation = useMutation({
    mutationFn: async ({ userId, blocked }: { userId: string; blocked: boolean }) => {
      await api.post(`/admin/users/${userId}/${blocked ? 'block' : 'unblock'}`, { reason: 'Admin action' })
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin', 'users'] })
    },
  })

  useEffect(() => {
    if (!isAuthenticated || user?.role !== 'ADMIN') {
      router.push('/')
    }
  }, [isAuthenticated, user, router])

  const { data: usersData, isLoading, refetch } = useQuery<UsersResponse>({
    queryKey: ['admin', 'users', page, filterRole],
    queryFn: async () => {
      const params: any = { page, size: 20 }
      if (filterRole !== 'all') {
        params.role = filterRole
      }
      const response = await api.get<UsersResponse>('/users', { params })
      return response.data
    },
    enabled: isAuthenticated && user?.role === 'ADMIN',
  })

  if (!user || user.role !== 'ADMIN') {
    return null
  }

  const filteredUsers = usersData?.content?.filter((u) => {
    const matchesSearch = u.email.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesSearch
  }) || []

  const getRoleIcon = (role: string) => {
    switch (role) {
      case 'ADMIN':
        return <Shield className="h-5 w-5 text-purple-600" />
      case 'SELLER':
        return <ShoppingBag className="h-5 w-5 text-blue-600" />
      case 'BUYER':
        return <UserIcon className="h-5 w-5 text-green-600" />
      default:
        return <UserIcon className="h-5 w-5 text-gray-600" />
    }
  }

  const getRoleBadge = (role: string) => {
    const colors = {
      ADMIN: 'bg-purple-100 text-purple-800',
      SELLER: 'bg-blue-100 text-blue-800',
      BUYER: 'bg-green-100 text-green-800',
    }
    return colors[role as keyof typeof colors] || 'bg-gray-100 text-gray-800'
  }

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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">
                Управление пользователями
              </h1>
              <p className="text-gray-600">
                Всего пользователей: {usersData?.totalElements || 0}
              </p>
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

        {/* Filters */}
        <div className="bg-white rounded-lg shadow p-6 mb-6 border border-gray-200">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Search */}
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                placeholder="Поиск по email..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            {/* Role Filter */}
            <select
              value={filterRole}
              onChange={(e) => {
                setFilterRole(e.target.value as any)
                setPage(0)
              }}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="all">Все роли</option>
              <option value="ADMIN">Администраторы</option>
              <option value="SELLER">Продавцы</option>
              <option value="BUYER">Покупатели</option>
            </select>
          </div>
        </div>

        {/* Users Table */}
        {isLoading ? (
          <div className="bg-white rounded-lg shadow p-8 text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Загрузка пользователей...</p>
          </div>
        ) : filteredUsers.length === 0 ? (
          <div className="bg-white rounded-lg shadow p-8 text-center">
            <p className="text-gray-600">Пользователи не найдены</p>
          </div>
        ) : (
        <div className="bg-white rounded-lg shadow border border-gray-200 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Пользователь
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Роль
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Статус
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Дата регистрации
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Действия
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filteredUsers.map((u) => (
                  <tr key={u.id} className={`hover:bg-gray-50 transition-colors ${u.blocked ? 'bg-red-50' : ''}`}>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="flex-shrink-0 h-10 w-10 bg-gray-200 rounded-full flex items-center justify-center">
                          {getRoleIcon(u.role)}
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">
                            {u.email}
                          </div>
                          <div className="text-sm text-gray-500">ID: {u.id}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span
                        className={`px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${getRoleBadge(
                          u.role
                        )}`}
                      >
                        {u.role}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      {u.blocked ? (
                        <span className="flex items-center text-sm text-red-600">
                          <UserX className="h-4 w-4 mr-1" />
                          Заблокирован
                        </span>
                      ) : u.verified ? (
                        <span className="flex items-center text-sm text-green-600">
                          <UserCheck className="h-4 w-4 mr-1" />
                          Подтвержден
                        </span>
                      ) : (
                        <span className="flex items-center text-sm text-gray-500">
                          <UserX className="h-4 w-4 mr-1" />
                          Не подтвержден
                        </span>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {new Date(u.createdAt).toLocaleDateString('ru-RU')}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <button
                        onClick={() => blockMutation.mutate({ userId: u.id, blocked: !u.blocked })}
                        disabled={blockMutation.isPending}
                        className={`px-3 py-1 rounded-lg ${
                          u.blocked
                            ? 'bg-green-100 text-green-700 hover:bg-green-200'
                            : 'bg-red-100 text-red-700 hover:bg-red-200'
                        }`}
                      >
                        {u.blocked ? 'Разблокировать' : 'Заблокировать'}
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
        {usersData && usersData.totalPages > 1 && (
          <div className="mt-6 flex justify-center gap-2">
            <button
              onClick={() => setPage(Math.max(0, page - 1))}
              disabled={page === 0}
              className="px-4 py-2 bg-white border rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
              Назад
            </button>
            <span className="px-4 py-2 bg-white border rounded-lg">
              Страница {page + 1} из {usersData.totalPages}
            </span>
            <button
              onClick={() => setPage(Math.min(usersData.totalPages - 1, page + 1))}
              disabled={page >= usersData.totalPages - 1}
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
