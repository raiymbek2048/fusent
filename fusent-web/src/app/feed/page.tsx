'use client'

import { useState } from 'react'
import MainLayout from '@/components/MainLayout'
import PostCard from '@/components/PostCard'
import { useFeedPosts } from '@/hooks/usePosts'
import { Loader } from 'lucide-react'

export default function FeedPage() {
  const [page, setPage] = useState(0)
  const { data, isLoading, error } = useFeedPosts({ page, size: 10 })

  return (
    <MainLayout>
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Социальная лента</h1>
          <p className="text-gray-600 mt-2">Следите за новостями и обновлениями магазинов</p>
        </div>

        {/* Loading State */}
        {isLoading && (
          <div className="flex justify-center py-12">
            <Loader className="h-8 w-8 text-primary-500 animate-spin" />
          </div>
        )}

        {/* Error State */}
        {error && (
          <div className="text-center py-12">
            <p className="text-red-600">Ошибка загрузки ленты</p>
          </div>
        )}

        {/* Posts */}
        {!isLoading && !error && data && (
          <>
            {data.content.length === 0 ? (
              <div className="text-center py-12">
                <p className="text-gray-600">Посты не найдены</p>
                <p className="text-gray-500 text-sm mt-2">
                  Подпишитесь на магазины, чтобы видеть их обновления
                </p>
              </div>
            ) : (
              <div className="space-y-6">
                {data.content.map((post) => (
                  <PostCard key={post.id} post={post} />
                ))}
              </div>
            )}

            {/* Pagination */}
            {data.totalPages > 1 && (
              <div className="mt-8 flex justify-center gap-2">
                <button
                  onClick={() => setPage((p) => Math.max(0, p - 1))}
                  disabled={data.first}
                  className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Назад
                </button>

                <span className="px-4 py-2 text-sm text-gray-700">
                  Страница {data.number + 1} из {data.totalPages}
                </span>

                <button
                  onClick={() => setPage((p) => p + 1)}
                  disabled={data.last}
                  className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Вперед
                </button>
              </div>
            )}
          </>
        )}
      </div>
    </MainLayout>
  )
}
