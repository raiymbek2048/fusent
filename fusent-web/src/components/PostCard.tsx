'use client'

import { useState } from 'react'
import Link from 'next/link'
import { Post } from '@/types'
import { useLikePost, useUnlikePost } from '@/hooks/usePosts'
import { Heart, MessageCircle, Store } from 'lucide-react'
import { useAuthStore } from '@/store/authStore'

interface PostCardProps {
  post: Post
}

export default function PostCard({ post }: PostCardProps) {
  const { isAuthenticated } = useAuthStore()
  const [isLiked, setIsLiked] = useState(false)

  const likeMutation = useLikePost()
  const unlikeMutation = useUnlikePost()

  const handleLike = () => {
    if (!isAuthenticated) {
      alert('Войдите, чтобы поставить лайк')
      return
    }

    if (isLiked) {
      unlikeMutation.mutate(post.id)
      setIsLiked(false)
    } else {
      likeMutation.mutate(post.id)
      setIsLiked(true)
    }
  }

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden">
      {/* Owner Header */}
      {post.ownerName && (
        <div className="p-4 border-b border-gray-200">
          <Link
            href={`/${post.ownerType === 'MERCHANT' ? 'shops' : 'users'}/${post.ownerId}`}
            className="flex items-center hover:text-primary-500"
          >
            <div className="w-10 h-10 rounded-full bg-primary-100 flex items-center justify-center">
              <Store className="h-5 w-5 text-primary-500" />
            </div>
            <div className="ml-3">
              <p className="text-sm font-semibold text-gray-900">{post.ownerName}</p>
              <p className="text-xs text-gray-500">
                {new Date(post.createdAt).toLocaleDateString('ru-RU')}
              </p>
            </div>
          </Link>
        </div>
      )}

      {/* Post Content */}
      <div className="p-4">
        {post.text && <p className="text-gray-900 whitespace-pre-wrap">{post.text}</p>}

        {/* Media */}
        {post.media && post.media.length > 0 && (
          <div className="mt-4 grid grid-cols-2 gap-2">
            {post.media.map((mediaItem, index) => (
              <img
                key={index}
                src={mediaItem.url}
                alt={`Post media ${index + 1}`}
                className="rounded-lg object-cover w-full h-48"
              />
            ))}
          </div>
        )}
      </div>

      {/* Actions */}
      <div className="px-4 py-3 border-t border-gray-200">
        <div className="flex items-center justify-between">
          <button
            onClick={handleLike}
            className={`flex items-center space-x-2 ${
              isLiked ? 'text-red-500' : 'text-gray-600 hover:text-red-500'
            } transition-colors`}
          >
            <Heart className={`h-5 w-5 ${isLiked ? 'fill-current' : ''}`} />
            <span className="text-sm font-medium">{post.likesCount}</span>
          </button>

          <Link
            href={`/posts/${post.id}`}
            className="flex items-center space-x-2 text-gray-600 hover:text-primary-500 transition-colors"
          >
            <MessageCircle className="h-5 w-5" />
            <span className="text-sm font-medium">{post.commentsCount}</span>
          </Link>
        </div>
      </div>
    </div>
  )
}
