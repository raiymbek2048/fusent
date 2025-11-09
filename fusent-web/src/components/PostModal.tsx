'use client'

import { useState, useEffect } from 'react'
import { X, Heart, MessageCircle, Send, MapPin, Store } from 'lucide-react'
import { Post } from '@/types'
import { useLikePost, useUnlikePost, usePostComments, useCreateComment } from '@/hooks/usePosts'
import { useAuth } from '@/hooks/useAuth'
import FollowButton from './FollowButton'
import toast from 'react-hot-toast'

interface PostModalProps {
  post: Post | null
  isOpen: boolean
  onClose: () => void
}

export default function PostModal({ post, isOpen, onClose }: PostModalProps) {
  const { user } = useAuth()
  const [commentText, setCommentText] = useState('')
  const [isLiked, setIsLiked] = useState(false)

  const { mutate: likePost } = useLikePost()
  const { mutate: unlikePost } = useUnlikePost()
  const { mutate: createComment, isPending: isCommenting } = useCreateComment()
  const { data: commentsData, isLoading: isLoadingComments } = usePostComments(
    post?.id || '',
    { page: 0, size: 50 }
  )

  useEffect(() => {
    if (post) {
      setIsLiked(post.isLikedByCurrentUser || false)
    }
  }, [post])

  if (!isOpen || !post) return null

  const handleLike = () => {
    if (!user) {
      toast.error('Войдите, чтобы поставить лайк')
      return
    }

    if (isLiked) {
      unlikePost(post.id)
      setIsLiked(false)
    } else {
      likePost(post.id)
      setIsLiked(true)
    }
  }

  const handleSubmitComment = (e: React.FormEvent) => {
    e.preventDefault()

    if (!user) {
      toast.error('Войдите, чтобы комментировать')
      return
    }

    if (!commentText.trim()) {
      toast.error('Введите текст комментария')
      return
    }

    createComment({
      postId: post.id,
      text: commentText.trim(),
    }, {
      onSuccess: () => {
        setCommentText('')
      },
    })
  }

  const comments = commentsData?.content || []

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex min-h-screen items-center justify-center p-4">
        {/* Backdrop */}
        <div
          className="fixed inset-0 bg-black bg-opacity-50 transition-opacity"
          onClick={onClose}
        />

        {/* Modal */}
        <div className="relative w-full max-w-4xl transform overflow-hidden rounded-2xl bg-white shadow-xl transition-all">
          <div className="flex h-[80vh]">
            {/* Left side - Media */}
            <div className="w-1/2 bg-black flex items-center justify-center">
              {post.media && post.media.length > 0 ? (
                <div className="w-full h-full relative">
                  {post.media.length === 1 ? (
                    <img
                      src={post.media[0].url}
                      alt="Post media"
                      className="w-full h-full object-contain"
                    />
                  ) : (
                    <div className="grid grid-cols-2 gap-1 w-full h-full p-2">
                      {post.media.slice(0, 4).map((media, index) => (
                        <div key={media.id || index} className="relative">
                          <img
                            src={media.url}
                            alt={`Media ${index + 1}`}
                            className="w-full h-full object-cover rounded"
                          />
                          {index === 3 && post.media!.length > 4 && (
                            <div className="absolute inset-0 bg-black bg-opacity-60 flex items-center justify-center rounded">
                              <span className="text-white text-2xl font-bold">
                                +{post.media!.length - 4}
                              </span>
                            </div>
                          )}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              ) : (
                <div className="text-gray-400 text-center p-8">
                  <MessageCircle className="h-16 w-16 mx-auto mb-2" />
                  <p>Нет медиа</p>
                </div>
              )}
            </div>

            {/* Right side - Details & Comments */}
            <div className="w-1/2 flex flex-col">
              {/* Header */}
              <div className="p-4 border-b flex items-center justify-between">
                <div className="flex items-center gap-3">
                  {post.ownerType === 'MERCHANT' ? (
                    <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center">
                      <Store className="h-5 w-5 text-blue-600" />
                    </div>
                  ) : (
                    <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center text-gray-600 font-semibold">
                      {post.ownerName?.[0]?.toUpperCase() || 'U'}
                    </div>
                  )}
                  <div className="flex-1">
                    <p className="text-sm font-semibold text-gray-900">{post.ownerName || 'Anonymous'}</p>
                    <p className="text-xs text-gray-500">
                      {new Date(post.createdAt).toLocaleDateString('ru-RU', {
                        day: 'numeric',
                        month: 'long',
                        year: 'numeric',
                      })}
                    </p>
                  </div>
                  {user && user.id !== post.ownerId && (
                    <FollowButton
                      targetType={post.ownerType}
                      targetId={post.ownerId}
                      variant="compact"
                    />
                  )}
                </div>
                <button
                  onClick={onClose}
                  className="text-gray-400 hover:text-gray-600 transition-colors"
                >
                  <X className="h-6 w-6" />
                </button>
              </div>

              {/* Post Content */}
              <div className="p-4 border-b">
                {post.text && (
                  <p className="text-gray-900 whitespace-pre-wrap mb-3">{post.text}</p>
                )}

                {/* Tags */}
                {post.tags && post.tags.length > 0 && (
                  <div className="flex flex-wrap gap-2 mb-3">
                    {post.tags.map((tag) => (
                      <span
                        key={tag}
                        className="text-sm text-blue-600 hover:text-blue-700 cursor-pointer"
                      >
                        #{tag}
                      </span>
                    ))}
                  </div>
                )}

                {/* Location */}
                {post.geoLat && post.geoLon && (
                  <div className="flex items-center text-sm text-gray-500 mb-3">
                    <MapPin className="h-4 w-4 mr-1" />
                    <span>
                      {post.geoLat.toFixed(4)}, {post.geoLon.toFixed(4)}
                    </span>
                  </div>
                )}

                {/* Actions */}
                <div className="flex items-center gap-4 pt-2">
                  <button
                    onClick={handleLike}
                    className={`flex items-center gap-2 transition-colors ${
                      isLiked ? 'text-red-500' : 'text-gray-600 hover:text-red-500'
                    }`}
                  >
                    <Heart className={`h-6 w-6 ${isLiked ? 'fill-current' : ''}`} />
                    <span className="text-sm font-medium">{post.likesCount}</span>
                  </button>
                  <div className="flex items-center gap-2 text-gray-600">
                    <MessageCircle className="h-6 w-6" />
                    <span className="text-sm font-medium">{post.commentsCount}</span>
                  </div>
                </div>
              </div>

              {/* Comments */}
              <div className="flex-1 overflow-y-auto p-4">
                {isLoadingComments ? (
                  <div className="text-center text-gray-500 py-4">
                    Загрузка комментариев...
                  </div>
                ) : comments.length === 0 ? (
                  <div className="text-center text-gray-500 py-8">
                    <MessageCircle className="h-12 w-12 mx-auto mb-2 text-gray-300" />
                    <p>Пока нет комментариев</p>
                    <p className="text-sm">Будьте первым!</p>
                  </div>
                ) : (
                  <div className="space-y-4">
                    {comments.map((comment) => (
                      <div key={comment.id} className="flex gap-3">
                        <div className="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center text-gray-600 font-semibold text-sm flex-shrink-0">
                          {comment.userName?.[0]?.toUpperCase() || 'U'}
                        </div>
                        <div className="flex-1">
                          <div className="bg-gray-50 rounded-lg p-3">
                            <p className="text-sm font-semibold text-gray-900 mb-1">
                              {comment.userName || 'Anonymous'}
                            </p>
                            <p className="text-sm text-gray-700">{comment.text}</p>
                          </div>
                          <p className="text-xs text-gray-500 mt-1 ml-3">
                            {new Date(comment.createdAt).toLocaleDateString('ru-RU', {
                              day: 'numeric',
                              month: 'short',
                              hour: '2-digit',
                              minute: '2-digit',
                            })}
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Add Comment */}
              <div className="p-4 border-t">
                <form onSubmit={handleSubmitComment} className="flex gap-2">
                  <input
                    type="text"
                    value={commentText}
                    onChange={(e) => setCommentText(e.target.value)}
                    placeholder="Добавьте комментарий..."
                    className="flex-1 px-4 py-2 border border-gray-300 rounded-full focus:outline-none focus:border-blue-500"
                    disabled={isCommenting}
                  />
                  <button
                    type="submit"
                    disabled={isCommenting || !commentText.trim()}
                    className="px-4 py-2 bg-blue-600 text-white rounded-full hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <Send className="h-5 w-5" />
                  </button>
                </form>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
