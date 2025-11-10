'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/store/authStore'
import MainLayout from '@/components/MainLayout'
import { Search, Eye, CheckCircle, XCircle, AlertTriangle, Image as ImageIcon, RefreshCw } from 'lucide-react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { api } from '@/lib/api'

interface Post {
  id: string
  ownerType: 'USER' | 'MERCHANT'
  ownerId: string
  ownerName?: string
  content: string
  mediaUrls?: string[]
  status: 'PENDING' | 'ACTIVE' | 'REJECTED'
  createdAt: string
  updatedAt: string
  location?: {
    latitude: number
    longitude: number
    address?: string
  }
}

interface PostsResponse {
  content: Post[]
  totalElements: number
  totalPages: number
  number: number
  size: number
}

export default function AdminPostsPage() {
  const router = useRouter()
  const queryClient = useQueryClient()
  const { user, isAuthenticated } = useAuthStore()
  const [searchTerm, setSearchTerm] = useState('')
  const [filterStatus, setFilterStatus] = useState<string>('all')
  const [page, setPage] = useState(0)
  const [selectedPost, setSelectedPost] = useState<Post | null>(null)

  useEffect(() => {
    if (!isAuthenticated || user?.role !== 'ADMIN') {
      router.push('/')
    }
  }, [isAuthenticated, user, router])

  const { data: postsData, isLoading, refetch } = useQuery<PostsResponse>({
    queryKey: ['admin', 'posts', page, filterStatus],
    queryFn: async () => {
      const params: any = { page, size: 20 }
      if (filterStatus !== 'all') {
        params.status = filterStatus
      }
      const response = await api.get<PostsResponse>('/posts/all', { params })
      return response.data
    },
    enabled: isAuthenticated && user?.role === 'ADMIN',
  })

  const updateStatusMutation = useMutation({
    mutationFn: async ({ postId, status }: { postId: string; status: 'ACTIVE' | 'REJECTED' }) => {
      await api.patch(`/posts/${postId}/status`, { status })
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin', 'posts'] })
      setSelectedPost(null)
    },
  })

  if (!user || user.role !== 'ADMIN') {
    return null
  }

  const filteredPosts = postsData?.content?.filter(post => {
    const matchesSearch = !searchTerm ||
      post.content.toLowerCase().includes(searchTerm.toLowerCase()) ||
      post.ownerName?.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesSearch
  }) || []

  const getStatusBadge = (status: string) => {
    const styles = {
      ACTIVE: 'bg-green-100 text-green-800',
      PENDING: 'bg-yellow-100 text-yellow-800',
      REJECTED: 'bg-red-100 text-red-800',
    }
    return (
      <span className={`px-2 py-1 rounded-full text-xs font-semibold ${styles[status as keyof typeof styles]}`}>
        {status}
      </span>
    )
  }

  return (
    <MainLayout>
      <div className="max-w-7xl mx-auto px-4 py-8">
        <button onClick={() => router.push('/admin')} className="text-blue-600 hover:text-blue-700 mb-4">
          ← Назад к панели
        </button>

        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold text-gray-900">Модерация постов</h1>
          <button
            onClick={() => refetch()}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            <RefreshCw className="w-4 h-4" />
            Обновить
          </button>
        </div>

        {/* Filters */}
        <div className="bg-white rounded-lg shadow p-4 mb-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                type="text"
                placeholder="Поиск по содержанию или владельцу..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <select
              value={filterStatus}
              onChange={(e) => {
                setFilterStatus(e.target.value)
                setPage(0)
              }}
              className="px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="all">Все статусы</option>
              <option value="PENDING">На модерации</option>
              <option value="ACTIVE">Активные</option>
              <option value="REJECTED">Отклоненные</option>
            </select>
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">На модерации</p>
                <p className="text-2xl font-bold text-yellow-800">
                  {postsData?.content?.filter(p => p.status === 'PENDING').length || 0}
                </p>
              </div>
              <AlertTriangle className="w-8 h-8 text-yellow-600" />
            </div>
          </div>

          <div className="bg-green-50 border border-green-200 rounded-lg p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Активные</p>
                <p className="text-2xl font-bold text-green-800">
                  {postsData?.content?.filter(p => p.status === 'ACTIVE').length || 0}
                </p>
              </div>
              <CheckCircle className="w-8 h-8 text-green-600" />
            </div>
          </div>

          <div className="bg-red-50 border border-red-200 rounded-lg p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Отклоненные</p>
                <p className="text-2xl font-bold text-red-800">
                  {postsData?.content?.filter(p => p.status === 'REJECTED').length || 0}
                </p>
              </div>
              <XCircle className="w-8 h-8 text-red-600" />
            </div>
          </div>
        </div>

        {/* Posts Table */}
        {isLoading ? (
          <div className="bg-white rounded-lg shadow p-8 text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Загрузка постов...</p>
          </div>
        ) : filteredPosts.length === 0 ? (
          <div className="bg-white rounded-lg shadow p-8 text-center">
            <p className="text-gray-600">Посты не найдены</p>
          </div>
        ) : (
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Владелец
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Содержание
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Медиа
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Статус
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Дата
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Действия
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredPosts.map((post) => (
                  <tr key={post.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm">
                        <div className="font-medium text-gray-900">
                          {post.ownerName || 'Unknown'}
                        </div>
                        <div className="text-gray-500 text-xs">
                          {post.ownerType}
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900 max-w-md truncate">
                        {post.content}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      {post.mediaUrls && post.mediaUrls.length > 0 ? (
                        <div className="flex items-center text-sm text-gray-500">
                          <ImageIcon className="w-4 h-4 mr-1" />
                          {post.mediaUrls.length}
                        </div>
                      ) : (
                        <span className="text-gray-400 text-sm">—</span>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      {getStatusBadge(post.status)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {new Date(post.createdAt).toLocaleDateString('ru-RU')}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <button
                        onClick={() => setSelectedPost(post)}
                        className="text-blue-600 hover:text-blue-900 mr-4"
                      >
                        <Eye className="w-5 h-5" />
                      </button>
                      {post.status === 'PENDING' && (
                        <>
                          <button
                            onClick={() => updateStatusMutation.mutate({ postId: post.id, status: 'ACTIVE' })}
                            className="text-green-600 hover:text-green-900 mr-2"
                            disabled={updateStatusMutation.isPending}
                          >
                            <CheckCircle className="w-5 h-5" />
                          </button>
                          <button
                            onClick={() => updateStatusMutation.mutate({ postId: post.id, status: 'REJECTED' })}
                            className="text-red-600 hover:text-red-900"
                            disabled={updateStatusMutation.isPending}
                          >
                            <XCircle className="w-5 h-5" />
                          </button>
                        </>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {/* Pagination */}
        {postsData && postsData.totalPages > 1 && (
          <div className="mt-6 flex justify-center gap-2">
            <button
              onClick={() => setPage(Math.max(0, page - 1))}
              disabled={page === 0}
              className="px-4 py-2 bg-white border rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
              Назад
            </button>
            <span className="px-4 py-2 bg-white border rounded-lg">
              Страница {page + 1} из {postsData.totalPages}
            </span>
            <button
              onClick={() => setPage(Math.min(postsData.totalPages - 1, page + 1))}
              disabled={page >= postsData.totalPages - 1}
              className="px-4 py-2 bg-white border rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
              Далее
            </button>
          </div>
        )}

        {/* Post Details Modal */}
        {selectedPost && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
              <div className="p-6">
                <div className="flex justify-between items-start mb-4">
                  <h2 className="text-2xl font-bold text-gray-900">Детали поста</h2>
                  <button
                    onClick={() => setSelectedPost(null)}
                    className="text-gray-400 hover:text-gray-600"
                  >
                    <XCircle className="w-6 h-6" />
                  </button>
                </div>

                <div className="space-y-4">
                  <div>
                    <label className="text-sm font-medium text-gray-700">Владелец</label>
                    <p className="text-gray-900">{selectedPost.ownerName || 'Unknown'}</p>
                    <p className="text-sm text-gray-500">{selectedPost.ownerType}</p>
                  </div>

                  <div>
                    <label className="text-sm font-medium text-gray-700">Содержание</label>
                    <p className="text-gray-900 whitespace-pre-wrap">{selectedPost.content}</p>
                  </div>

                  {selectedPost.mediaUrls && selectedPost.mediaUrls.length > 0 && (
                    <div>
                      <label className="text-sm font-medium text-gray-700">Медиафайлы</label>
                      <div className="grid grid-cols-2 gap-2 mt-2">
                        {selectedPost.mediaUrls.map((url, idx) => (
                          <img
                            key={idx}
                            src={url}
                            alt={`Media ${idx + 1}`}
                            className="w-full h-48 object-cover rounded-lg"
                          />
                        ))}
                      </div>
                    </div>
                  )}

                  {selectedPost.location && (
                    <div>
                      <label className="text-sm font-medium text-gray-700">Местоположение</label>
                      <p className="text-gray-900">
                        {selectedPost.location.address || `${selectedPost.location.latitude}, ${selectedPost.location.longitude}`}
                      </p>
                    </div>
                  )}

                  <div>
                    <label className="text-sm font-medium text-gray-700">Статус</label>
                    <div className="mt-1">{getStatusBadge(selectedPost.status)}</div>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="text-sm font-medium text-gray-700">Создан</label>
                      <p className="text-gray-900">
                        {new Date(selectedPost.createdAt).toLocaleString('ru-RU')}
                      </p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-gray-700">Обновлен</label>
                      <p className="text-gray-900">
                        {new Date(selectedPost.updatedAt).toLocaleString('ru-RU')}
                      </p>
                    </div>
                  </div>

                  {selectedPost.status === 'PENDING' && (
                    <div className="flex gap-4 pt-4 border-t">
                      <button
                        onClick={() => updateStatusMutation.mutate({ postId: selectedPost.id, status: 'ACTIVE' })}
                        disabled={updateStatusMutation.isPending}
                        className="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 flex items-center justify-center gap-2"
                      >
                        <CheckCircle className="w-5 h-5" />
                        Одобрить
                      </button>
                      <button
                        onClick={() => updateStatusMutation.mutate({ postId: selectedPost.id, status: 'REJECTED' })}
                        disabled={updateStatusMutation.isPending}
                        className="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 flex items-center justify-center gap-2"
                      >
                        <XCircle className="w-5 h-5" />
                        Отклонить
                      </button>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </MainLayout>
  )
}
