'use client'

import { useState } from 'react'
import MainLayout from '@/components/MainLayout'
import { usePublicFeed, useLikePost, useUnlikePost } from '@/hooks/usePosts'
import { Heart, MessageCircle, Share2, MapPin } from 'lucide-react'
import { formatDistanceToNow } from 'date-fns'
import { ru } from 'date-fns/locale'

export default function FeedPage() {
  const [page, setPage] = useState(0)
  const { data, isLoading } = usePublicFeed({ page, size: 20 })
  const { mutate: likePost } = useLikePost()
  const { mutate: unlikePost } = useUnlikePost()

  const handleLike = (postId: string, isLiked?: boolean) => {
    if (isLiked) {
      unlikePost(postId)
    } else {
      likePost(postId)
    }
  }

  return (
    <MainLayout>
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Лента публикаций</h1>

        {isLoading ? (
          <div className="space-y-6">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="bg-white rounded-lg shadow p-6 animate-pulse">
                <div className="h-4 bg-gray-200 rounded w-1/4 mb-4"></div>
                <div className="h-20 bg-gray-200 rounded mb-4"></div>
                <div className="h-4 bg-gray-200 rounded w-1/2"></div>
              </div>
            ))}
          </div>
        ) : data?.content && data.content.length > 0 ? (
          <div className="space-y-6">
            {data.content.map((post) => (
              <div key={post.id} className="bg-white rounded-lg shadow hover:shadow-md transition-shadow">
                {/* Post Header */}
                <div className="p-6 pb-4">
                  <div className="flex items-center justify-between mb-4">
                    <div>
                      <h3 className="font-semibold text-gray-900">{post.ownerName || 'Пользователь'}</h3>
                      <p className="text-sm text-gray-500">
                        {formatDistanceToNow(new Date(post.createdAt), {
                          addSuffix: true,
                          locale: ru,
                        })}
                      </p>
                    </div>
                    {post.geoLat && post.geoLon && (
                      <div className="flex items-center text-gray-500">
                        <MapPin className="h-4 w-4 mr-1" />
                        <span className="text-sm">Геолокация</span>
                      </div>
                    )}
                  </div>

                  {/* Post Content */}
                  {post.text && (
                    <p className="text-gray-800 mb-4 whitespace-pre-wrap">{post.text}</p>
                  )}

                  {/* Post Media */}
                  {post.media && post.media.length > 0 && (
                    <div className="mb-4 grid grid-cols-2 gap-2">
                      {post.media.map((media, idx) => (
                        <div key={media.id || idx} className="relative">
                          {media.mediaType === 'IMAGE' ? (
                            <img
                              src={media.url}
                              alt=""
                              className="w-full h-48 object-cover rounded-lg"
                            />
                          ) : (
                            <video
                              src={media.url}
                              controls
                              className="w-full h-48 object-cover rounded-lg"
                            />
                          )}
                        </div>
                      ))}
                    </div>
                  )}

                  {/* Post Tags */}
                  {post.tags && post.tags.length > 0 && (
                    <div className="flex flex-wrap gap-2 mb-4">
                      {post.tags.map((tag, idx) => (
                        <span
                          key={idx}
                          className="text-sm text-blue-600 hover:text-blue-700 cursor-pointer"
                        >
                          #{tag}
                        </span>
                      ))}
                    </div>
                  )}
                </div>

                {/* Post Actions */}
                <div className="border-t border-gray-200 px-6 py-3">
                  <div className="flex items-center justify-between">
                    <button
                      onClick={() => handleLike(post.id, post.isLikedByCurrentUser)}
                      className={`flex items-center space-x-2 hover:text-red-600 transition-colors ${
                        post.isLikedByCurrentUser ? 'text-red-600' : 'text-gray-600'
                      }`}
                    >
                      <Heart
                        className={`h-5 w-5 ${post.isLikedByCurrentUser ? 'fill-current' : ''}`}
                      />
                      <span className="text-sm">{post.likesCount}</span>
                    </button>

                    <button className="flex items-center space-x-2 text-gray-600 hover:text-blue-600 transition-colors">
                      <MessageCircle className="h-5 w-5" />
                      <span className="text-sm">{post.commentsCount}</span>
                    </button>

                    <button className="flex items-center space-x-2 text-gray-600 hover:text-green-600 transition-colors">
                      <Share2 className="h-5 w-5" />
                      <span className="text-sm">{post.sharesCount || 0}</span>
                    </button>
                  </div>
                </div>
              </div>
            ))}

            {/* Pagination */}
            {data.totalPages > 1 && (
              <div className="flex justify-center items-center space-x-4 mt-8">
                <button
                  onClick={() => setPage(Math.max(0, page - 1))}
                  disabled={page === 0}
                  className="px-4 py-2 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Предыдущая
                </button>
                <span className="text-gray-600">
                  Страница {page + 1} из {data.totalPages}
                </span>
                <button
                  onClick={() => setPage(Math.min(data.totalPages - 1, page + 1))}
                  disabled={page >= data.totalPages - 1}
                  className="px-4 py-2 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Следующая
                </button>
              </div>
            )}
          </div>
        ) : (
          <div className="bg-white rounded-lg shadow p-12 text-center">
            <p className="text-gray-500 text-lg">Пока нет публикаций</p>
            <p className="text-gray-400 mt-2">Создайте первую публикацию!</p>
          </div>
        )}
      </div>
    </MainLayout>
  )
}
