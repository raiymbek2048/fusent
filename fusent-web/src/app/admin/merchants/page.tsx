'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/store/authStore'
import MainLayout from '@/components/MainLayout'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { api } from '@/lib/api'
import { Store, Check, X, Clock, Search, ChevronLeft, ChevronRight } from 'lucide-react'

interface Merchant {
  id: string
  businessName: string
  ownerName: string
  email: string
  phone: string
  approvalStatus: 'PENDING' | 'APPROVED' | 'REJECTED'
  createdAt: string
  blocked: boolean
}

interface MerchantsResponse {
  content: Merchant[]
  totalPages: number
  totalElements: number
  number: number
}

export default function MerchantsManagementPage() {
  const router = useRouter()
  const { user, isAuthenticated } = useAuthStore()
  const queryClient = useQueryClient()
  const [search, setSearch] = useState('')
  const [status, setStatus] = useState<string>('PENDING')
  const [page, setPage] = useState(0)

  const { data, isLoading } = useQuery<MerchantsResponse>({
    queryKey: ['admin', 'merchants', status, search, page],
    queryFn: async () => {
      const params = new URLSearchParams({
        page: page.toString(),
        size: '10',
        ...(status && { status }),
        ...(search && { search }),
      })
      const response = await api.get<MerchantsResponse>(`/admin/merchants?${params}`)
      return response.data
    },
    enabled: isAuthenticated && user?.role === 'ADMIN',
  })

  const approveMutation = useMutation({
    mutationFn: async (merchantId: string) => {
      await api.post(`/admin/merchants/${merchantId}/approve`, { status: 'APPROVED' })
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin', 'merchants'] })
    },
  })

  const rejectMutation = useMutation({
    mutationFn: async (merchantId: string) => {
      await api.post(`/admin/merchants/${merchantId}/approve`, { status: 'REJECTED' })
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin', 'merchants'] })
    },
  })

  const blockMutation = useMutation({
    mutationFn: async ({ merchantId, blocked }: { merchantId: string; blocked: boolean }) => {
      await api.post(`/admin/merchants/${merchantId}/${blocked ? 'block' : 'unblock'}`, { reason: 'Admin action' })
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin', 'merchants'] })
    },
  })

  useEffect(() => {
    if (!isAuthenticated || user?.role !== 'ADMIN') {
      router.push('/')
    }
  }, [isAuthenticated, user, router])

  if (!user || user.role !== 'ADMIN') {
    return null
  }

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'APPROVED':
        return <span className="px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-green-800">Одобрен</span>
      case 'REJECTED':
        return <span className="px-2 py-1 text-xs font-medium rounded-full bg-red-100 text-red-800">Отклонен</span>
      default:
        return <span className="px-2 py-1 text-xs font-medium rounded-full bg-yellow-100 text-yellow-800">Ожидает</span>
    }
  }

  return (
    <MainLayout>
      <div className="max-w-7xl mx-auto px-4 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Управление магазинами</h1>
          <p className="text-gray-600">Одобрение и модерация магазинов</p>
        </div>

        <div className="bg-white rounded-lg shadow border border-gray-200">
          <div className="p-4 border-b border-gray-200">
            <div className="flex flex-col sm:flex-row gap-4">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type="text"
                  placeholder="Поиск по названию..."
                  value={search}
                  onChange={(e) => { setSearch(e.target.value); setPage(0) }}
                  className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>
              <select
                value={status}
                onChange={(e) => { setStatus(e.target.value); setPage(0) }}
                className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              >
                <option value="PENDING">Ожидающие</option>
                <option value="APPROVED">Одобренные</option>
                <option value="REJECTED">Отклоненные</option>
                <option value="">Все</option>
              </select>
            </div>
          </div>

          {isLoading ? (
            <div className="p-8 text-center text-gray-500">Загрузка...</div>
          ) : (
            <>
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Магазин</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Владелец</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Статус</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Дата</th>
                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Действия</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {data?.content?.map((merchant) => (
                    <tr key={merchant.id} className={merchant.blocked ? 'bg-red-50' : ''}>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div className="p-2 bg-purple-100 rounded-lg">
                            <Store className="h-5 w-5 text-purple-600" />
                          </div>
                          <div>
                            <p className="font-medium text-gray-900">{merchant.businessName}</p>
                            <p className="text-sm text-gray-500">{merchant.email}</p>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-gray-900">{merchant.ownerName}</td>
                      <td className="px-6 py-4">{getStatusBadge(merchant.approvalStatus)}</td>
                      <td className="px-6 py-4 text-gray-500 text-sm">
                        {new Date(merchant.createdAt).toLocaleDateString('ru-RU')}
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex justify-end gap-2">
                          {merchant.approvalStatus === 'PENDING' && (
                            <>
                              <button
                                onClick={() => approveMutation.mutate(merchant.id)}
                                disabled={approveMutation.isPending}
                                className="p-2 text-green-600 hover:bg-green-50 rounded-lg"
                                title="Одобрить"
                              >
                                <Check className="h-5 w-5" />
                              </button>
                              <button
                                onClick={() => rejectMutation.mutate(merchant.id)}
                                disabled={rejectMutation.isPending}
                                className="p-2 text-red-600 hover:bg-red-50 rounded-lg"
                                title="Отклонить"
                              >
                                <X className="h-5 w-5" />
                              </button>
                            </>
                          )}
                          <button
                            onClick={() => blockMutation.mutate({ merchantId: merchant.id, blocked: !merchant.blocked })}
                            disabled={blockMutation.isPending}
                            className={`px-3 py-1 text-sm rounded-lg ${
                              merchant.blocked
                                ? 'bg-green-100 text-green-700 hover:bg-green-200'
                                : 'bg-red-100 text-red-700 hover:bg-red-200'
                            }`}
                          >
                            {merchant.blocked ? 'Разблокировать' : 'Заблокировать'}
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>

              {data && data.totalPages > 1 && (
                <div className="px-6 py-4 border-t border-gray-200 flex items-center justify-between">
                  <p className="text-sm text-gray-500">
                    Показано {data.content.length} из {data.totalElements}
                  </p>
                  <div className="flex gap-2">
                    <button
                      onClick={() => setPage((p) => Math.max(0, p - 1))}
                      disabled={page === 0}
                      className="p-2 rounded-lg hover:bg-gray-100 disabled:opacity-50"
                    >
                      <ChevronLeft className="h-5 w-5" />
                    </button>
                    <span className="px-4 py-2 text-sm">
                      {page + 1} / {data.totalPages}
                    </span>
                    <button
                      onClick={() => setPage((p) => Math.min(data.totalPages - 1, p + 1))}
                      disabled={page >= data.totalPages - 1}
                      className="p-2 rounded-lg hover:bg-gray-100 disabled:opacity-50"
                    >
                      <ChevronRight className="h-5 w-5" />
                    </button>
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </MainLayout>
  )
}
