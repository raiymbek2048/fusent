'use client'

import { useState } from 'react'
import { useSavedPosts } from '@/hooks/useSavedPosts'
import PostCard from '@/components/PostCard'
import { useAuthStore } from '@/store/authStore'
import { useRouter } from 'next/navigation'
import { Bookmark, ChevronLeft, ChevronRight } from 'lucide-react'
import { Spinner } from '@/components/ui/Spinner'
import MainLayout from '@/components/MainLayout'

export const dynamic = 'force-dynamic'

export default function SavedPostsPage() {
  const router = useRouter()
  const { isAuthenticated } = useAuthStore()
  const [page, setPage] = useState(0)
  const { data, isLoading, error } = useSavedPosts(page, 20)

  // Redirect if not authenticated
  if (!isAuthenticated) {
    router.push('/login')
    return null
  }

  if (isLoading) {
    return (
      <MainLayout>
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <Spinner />
        </div>
      </MainLayout>
    )
  }

  if (error) {
    return (
      <MainLayout>
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="text-center">
            <p className="text-red-500 text-lg mb-4">Ошибка при загрузке сохраненных постов</p>
            <button
              onClick={() => window.location.reload()}
              className="px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600"
            >
              Повторить
            </button>
          </div>
        </div>
      </MainLayout>
    )
  }

  const savedPosts = data?.content || []
  const totalPages = data?.totalPages || 0

  return (
    <MainLayout>
      <div className="min-h-screen bg-gray-50">
        <div className="max-w-4xl mx-auto px-4 py-8">
        {/* Header */}
        <div className="mb-6 flex items-center space-x-3">
          <div className="w-12 h-12 bg-yellow-100 rounded-full flex items-center justify-center">
            <Bookmark className="h-6 w-6 text-yellow-600 fill-current" />
          </div>
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Сохраненные посты</h1>
            <p className="text-gray-600 mt-1">
              {savedPosts.length > 0
                ? `Всего: ${data?.totalElements || 0} постов`
                : 'У вас пока нет сохраненных постов'}
            </p>
          </div>
        </div>

        {/* Posts Grid */}
        {savedPosts.length > 0 ? (
          <div className="space-y-4">
            {savedPosts.map((savedPost) => (
              <PostCard key={savedPost.id} post={savedPost.post} />
            ))}
          </div>
        ) : (
          <div className="text-center py-12 bg-white rounded-lg shadow">
            <Bookmark className="h-16 w-16 text-gray-300 mx-auto mb-4" />
            <h2 className="text-xl font-semibold text-gray-700 mb-2">
              Нет сохраненных постов
            </h2>
            <p className="text-gray-500 mb-6">
              Сохраняйте интересные посты, нажимая на значок закладки
            </p>
            <button
              onClick={() => router.push('/social')}
              className="px-6 py-3 bg-primary-500 text-white rounded-lg hover:bg-primary-600 transition-colors"
            >
              Перейти к ленте
            </button>
          </div>
        )}

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="mt-8 flex items-center justify-center space-x-4">
            <button
              onClick={() => setPage((p) => Math.max(0, p - 1))}
              disabled={page === 0}
              className="p-2 rounded-lg bg-white shadow hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <ChevronLeft className="h-5 w-5" />
            </button>
            <span className="text-sm text-gray-600">
              Страница {page + 1} из {totalPages}
            </span>
            <button
              onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
              disabled={page >= totalPages - 1}
              className="p-2 rounded-lg bg-white shadow hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <ChevronRight className="h-5 w-5" />
            </button>
          </div>
        )}
        </div>
      </div>
    </MainLayout>
  )
}
