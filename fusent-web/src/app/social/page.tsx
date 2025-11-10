'use client'

import { useState } from 'react'
import MainLayout from '@/components/MainLayout'
import CreatePostModal from '@/components/CreatePostModal'
import PostModal from '@/components/PostModal'
import { usePublicFeed, useFollowingFeed, useLikePost, useUnlikePost } from '@/hooks/usePosts'
import { useAuth } from '@/hooks/useAuth'
import { Heart, MessageCircle, Share2, MapPin, Plus, Bookmark } from 'lucide-react'
import { formatDistanceToNow } from 'date-fns'
import { ru } from 'date-fns/locale'
import { Post } from '@/types'

type FeedTab = 'explore' | 'following'

export default function SocialPage() {
  const { user } = useAuth()
  const [activeTab, setActiveTab] = useState<FeedTab>('explore')
  const [page, setPage] = useState(0)
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false)
  const [selectedPost, setSelectedPost] = useState<Post | null>(null)

  const { data: exploreData, isLoading: isLoadingExplore } = usePublicFeed(
    { page, size: 20 },
    { enabled: activeTab === 'explore' }
  )

  const { data: followingData, isLoading: isLoadingFollowing } = useFollowingFeed(
    { page, size: 20 },
    { enabled: activeTab === 'following' && !!user }
  )

  const { mutate: likePost } = useLikePost()
  const { mutate: unlikePost } = useUnlikePost()

  const data = activeTab === 'explore' ? exploreData : followingData
  const isLoading = activeTab === 'explore' ? isLoadingExplore : isLoadingFollowing

  const handleLike = (postId: string, isLiked?: boolean) => {
    if (isLiked) {
      unlikePost(postId)
    } else {
      likePost(postId)
    }
  }

  return (
    <MainLayout>
      <div className="max-w-6xl mx-auto">
        {/* Header with Tabs */}
        <div className="sticky top-0 z-10 bg-white border-b border-gray-200">
          <div className="max-w-6xl mx-auto px-4">
            <div className="flex items-center justify-between h-16">
              {/* Tabs */}
              <div className="flex items-center gap-8">
                <button
                  onClick={() => {
                    setActiveTab('explore')
                    setPage(0)
                  }}
                  className={`pb-4 pt-4 border-b-2 font-medium transition-colors ${
                    activeTab === 'explore'
                      ? 'border-blue-600 text-blue-600'
                      : 'border-transparent text-gray-600 hover:text-gray-900'
                  }`}
                >
                  Explore
                </button>
                {user && (
                  <button
                    onClick={() => {
                      setActiveTab('following')
                      setPage(0)
                    }}
                    className={`pb-4 pt-4 border-b-2 font-medium transition-colors ${
                      activeTab === 'following'
                        ? 'border-blue-600 text-blue-600'
                        : 'border-transparent text-gray-600 hover:text-gray-900'
                    }`}
                  >
                    Following
                  </button>
                )}
              </div>

              {/* Create Post Button */}
              {user && (
                <button
                  onClick={() => setIsCreateModalOpen(true)}
                  className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-full hover:bg-blue-700 transition-colors"
                >
                  <Plus className="h-5 w-5" />
                  <span className="hidden sm:inline">Создать</span>
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Feed Content */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 px-4 py-6">
          {/* Posts Column - Takes 2/3 on desktop */}
          <div className="md:col-span-2 space-y-6">
            {isLoading ? (
              // Loading Skeleton
              [...Array(5)].map((_, i) => (
                <div key={i} className="bg-white border border-gray-200 rounded-lg animate-pulse">
                  <div className="p-4">
                    <div className="flex items-center gap-3 mb-4">
                      <div className="w-10 h-10 bg-gray-200 rounded-full" />
                      <div className="flex-1">
                        <div className="h-4 bg-gray-200 rounded w-32 mb-2" />
                        <div className="h-3 bg-gray-200 rounded w-24" />
                      </div>
                    </div>
                    <div className="h-64 bg-gray-200 rounded mb-4" />
                    <div className="h-4 bg-gray-200 rounded w-full mb-2" />
                    <div className="h-4 bg-gray-200 rounded w-3/4" />
                  </div>
                </div>
              ))
            ) : data?.content && data.content.length > 0 ? (
              <>
                {data.content.map((post) => (
                  <article
                    key={post.id}
                    className="bg-white border border-gray-200 rounded-lg overflow-hidden hover:shadow-md transition-shadow"
                  >
                    {/* Post Header */}
                    <div className="flex items-center justify-between p-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-gradient-to-br from-purple-400 to-pink-600 rounded-full flex items-center justify-center text-white font-semibold">
                          {(post.ownerName || 'U')[0].toUpperCase()}
                        </div>
                        <div>
                          <p className="font-semibold text-gray-900">
                            {post.ownerName || 'Пользователь'}
                          </p>
                          {post.geoLat && post.geoLon && (
                            <p className="text-xs text-gray-500 flex items-center gap-1">
                              <MapPin className="h-3 w-3" />
                              Местоположение
                            </p>
                          )}
                        </div>
                      </div>
                      <button className="text-gray-600 hover:text-gray-900">
                        <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                          <circle cx="12" cy="5" r="1.5" />
                          <circle cx="12" cy="12" r="1.5" />
                          <circle cx="12" cy="19" r="1.5" />
                        </svg>
                      </button>
                    </div>

                    {/* Post Media */}
                    {post.media && post.media.length > 0 && (
                      <div className="relative bg-black">
                        {post.media.length === 1 ? (
                          <div className="aspect-square">
                            {post.media[0].mediaType === 'IMAGE' ? (
                              <img
                                src={post.media[0].url}
                                alt=""
                                className="w-full h-full object-contain"
                              />
                            ) : (
                              <video
                                src={post.media[0].url}
                                controls
                                className="w-full h-full object-contain"
                              />
                            )}
                          </div>
                        ) : (
                          <div className="grid grid-cols-2 gap-1">
                            {post.media.slice(0, 4).map((media, idx) => (
                              <div key={media.id || idx} className="aspect-square relative">
                                {media.mediaType === 'IMAGE' ? (
                                  <img
                                    src={media.url}
                                    alt=""
                                    className="w-full h-full object-cover"
                                  />
                                ) : (
                                  <video
                                    src={media.url}
                                    className="w-full h-full object-cover"
                                  />
                                )}
                                {idx === 3 && post.media && post.media.length > 4 && (
                                  <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center text-white text-2xl font-semibold">
                                    +{post.media.length - 4}
                                  </div>
                                )}
                              </div>
                            ))}
                          </div>
                        )}
                      </div>
                    )}

                    {/* Post Actions */}
                    <div className="px-4 py-3">
                      <div className="flex items-center justify-between mb-2">
                        <div className="flex items-center gap-4">
                          <button
                            onClick={() => handleLike(post.id, post.isLikedByCurrentUser)}
                            className="hover:opacity-70 transition-opacity"
                          >
                            <Heart
                              className={`h-7 w-7 ${
                                post.isLikedByCurrentUser
                                  ? 'fill-red-500 text-red-500'
                                  : 'text-gray-900'
                              }`}
                            />
                          </button>
                          <button
                            onClick={() => setSelectedPost(post)}
                            className="hover:opacity-70 transition-opacity"
                          >
                            <MessageCircle className="h-7 w-7 text-gray-900" />
                          </button>
                          <button className="hover:opacity-70 transition-opacity">
                            <Share2 className="h-7 w-7 text-gray-900" />
                          </button>
                        </div>
                        <button className="hover:opacity-70 transition-opacity">
                          <Bookmark className="h-7 w-7 text-gray-900" />
                        </button>
                      </div>

                      {/* Likes Count */}
                      <p className="font-semibold text-sm mb-2">
                        {post.likesCount} {post.likesCount === 1 ? 'отметка «Нравится»' : 'отметок «Нравится»'}
                      </p>

                      {/* Post Caption */}
                      {post.text && (
                        <p className="text-sm mb-2">
                          <span className="font-semibold mr-2">{post.ownerName || 'Пользователь'}</span>
                          <span className="text-gray-900">{post.text}</span>
                        </p>
                      )}

                      {/* Tags */}
                      {post.tags && post.tags.length > 0 && (
                        <div className="flex flex-wrap gap-2 mb-2">
                          {post.tags.map((tag, idx) => (
                            <span key={idx} className="text-sm text-blue-600 hover:underline cursor-pointer">
                              #{tag}
                            </span>
                          ))}
                        </div>
                      )}

                      {/* View Comments */}
                      {post.commentsCount > 0 && (
                        <button
                          onClick={() => setSelectedPost(post)}
                          className="text-sm text-gray-500 hover:text-gray-700 mb-2"
                        >
                          Посмотреть все комментарии ({post.commentsCount})
                        </button>
                      )}

                      {/* Time */}
                      <p className="text-xs text-gray-400 uppercase">
                        {formatDistanceToNow(new Date(post.createdAt), {
                          addSuffix: true,
                          locale: ru,
                        })}
                      </p>
                    </div>
                  </article>
                ))}

                {/* Pagination */}
                {data.totalPages > 1 && (
                  <div className="flex justify-center items-center gap-4 py-6">
                    <button
                      onClick={() => setPage(Math.max(0, page - 1))}
                      disabled={page === 0}
                      className="px-4 py-2 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                    >
                      Предыдущая
                    </button>
                    <span className="text-gray-600 text-sm">
                      {page + 1} / {data.totalPages}
                    </span>
                    <button
                      onClick={() => setPage(Math.min(data.totalPages - 1, page + 1))}
                      disabled={page >= data.totalPages - 1}
                      className="px-4 py-2 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                    >
                      Следующая
                    </button>
                  </div>
                )}
              </>
            ) : (
              <div className="bg-white border border-gray-200 rounded-lg p-12 text-center">
                <p className="text-gray-500 text-lg mb-2">
                  {activeTab === 'following'
                    ? 'Нет публикаций от подписок'
                    : 'Пока нет публикаций'}
                </p>
                <p className="text-gray-400 text-sm">
                  {activeTab === 'following'
                    ? 'Подпишитесь на продавцов, чтобы видеть их публикации'
                    : 'Создайте первую публикацию!'}
                </p>
              </div>
            )}
          </div>

          {/* Sidebar - Takes 1/3 on desktop */}
          <div className="hidden md:block space-y-4">
            {/* User Profile Card */}
            {user && (
              <div className="bg-white border border-gray-200 rounded-lg p-4">
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-14 h-14 bg-gradient-to-br from-purple-400 to-pink-600 rounded-full flex items-center justify-center text-white font-semibold text-xl">
                    {user.profile?.firstName?.[0]?.toUpperCase() || user.email?.[0]?.toUpperCase() || 'U'}
                  </div>
                  <div>
                    <p className="font-semibold text-gray-900">
                      {user.profile?.firstName && user.profile?.lastName
                        ? `${user.profile.firstName} ${user.profile.lastName}`
                        : user.email}
                    </p>
                    <p className="text-sm text-gray-500">{user.email}</p>
                  </div>
                </div>
              </div>
            )}

            {/* Suggestions Card */}
            <div className="bg-white border border-gray-200 rounded-lg p-4">
              <div className="flex items-center justify-between mb-4">
                <p className="text-sm font-semibold text-gray-500">Рекомендации для вас</p>
                <button className="text-xs font-semibold text-blue-600 hover:text-blue-700">
                  Показать все
                </button>
              </div>
              <div className="space-y-3">
                {[1, 2, 3].map((i) => (
                  <div key={i} className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 bg-gray-200 rounded-full" />
                      <div>
                        <p className="text-sm font-semibold text-gray-900">Магазин {i}</p>
                        <p className="text-xs text-gray-500">Популярный продавец</p>
                      </div>
                    </div>
                    <button className="text-xs font-semibold text-blue-600 hover:text-blue-700">
                      Подписаться
                    </button>
                  </div>
                ))}
              </div>
            </div>

            {/* Footer Links */}
            <div className="text-xs text-gray-400 space-y-2">
              <div className="flex flex-wrap gap-2">
                <a href="#" className="hover:underline">О нас</a>
                <span>·</span>
                <a href="#" className="hover:underline">Помощь</a>
                <span>·</span>
                <a href="#" className="hover:underline">Условия</a>
                <span>·</span>
                <a href="#" className="hover:underline">Конфиденциальность</a>
              </div>
              <p>© 2025 FUCENT</p>
            </div>
          </div>
        </div>
      </div>

      {/* Create Post Modal */}
      <CreatePostModal
        isOpen={isCreateModalOpen}
        onClose={() => setIsCreateModalOpen(false)}
      />

      {/* Post Details Modal */}
      <PostModal
        post={selectedPost}
        isOpen={!!selectedPost}
        onClose={() => setSelectedPost(null)}
      />
    </MainLayout>
  )
}
