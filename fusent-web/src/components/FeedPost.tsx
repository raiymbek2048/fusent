'use client'

import { useState } from 'react'
import Link from 'next/link'
import { Heart, MessageCircle, Share2, Bookmark, ShoppingBag, ChevronLeft, ChevronRight } from 'lucide-react'
import { Post } from '@/types'
import { useAuthStore } from '@/store/authStore'
import ShareModal from './ShareModal'

interface FeedPostProps {
  post: Post
  onLike: () => void
  onSave: () => void
  onShare: () => void
  isLiked: boolean
  isSaved: boolean
}

export default function FeedPost({
  post,
  onLike,
  onSave,
  onShare,
  isLiked,
  isSaved,
}: FeedPostProps) {
  const { isAuthenticated } = useAuthStore()
  const [currentMediaIndex, setCurrentMediaIndex] = useState(0)
  const [showShareModal, setShowShareModal] = useState(false)

  const media = post.media || []
  const hasMultipleMedia = media.length > 1

  const handleNext = () => {
    if (currentMediaIndex < media.length - 1) {
      setCurrentMediaIndex(currentMediaIndex + 1)
    }
  }

  const handlePrev = () => {
    if (currentMediaIndex > 0) {
      setCurrentMediaIndex(currentMediaIndex - 1)
    }
  }

  return (
    <div className="relative w-full h-screen snap-start snap-always flex items-center justify-center" style={{ backgroundColor: '#e9d5ff' }}>
      {/* Media Content - Centered and Limited Width */}
      <div className="relative flex items-center justify-center" style={{ maxWidth: '450px', maxHeight: '80vh' }}>
        {media.length > 0 ? (
          <>
            {media[currentMediaIndex].mediaType === 'IMAGE' ? (
              <img
                src={media[currentMediaIndex].url}
                alt=""
                className="object-contain"
                style={{ maxWidth: '450px', maxHeight: '80vh' }}
              />
            ) : (
              <video
                src={media[currentMediaIndex].url}
                className="object-contain"
                style={{ maxWidth: '450px', maxHeight: '80vh' }}
                controls
                autoPlay
                loop
                playsInline
              />
            )}

            {/* Media Navigation Arrows (if multiple images) */}
            {hasMultipleMedia && (
              <>
                {currentMediaIndex > 0 && (
                  <button
                    onClick={handlePrev}
                    className="absolute left-4 top-1/2 transform -translate-y-1/2 bg-black/50 text-white p-2 rounded-full hover:bg-black/70 transition-colors"
                  >
                    <ChevronLeft className="w-6 h-6" />
                  </button>
                )}
                {currentMediaIndex < media.length - 1 && (
                  <button
                    onClick={handleNext}
                    className="absolute right-4 top-1/2 transform -translate-y-1/2 bg-black/50 text-white p-2 rounded-full hover:bg-black/70 transition-colors"
                  >
                    <ChevronRight className="w-6 h-6" />
                  </button>
                )}
              </>
            )}

            {/* Media Indicators */}
            {hasMultipleMedia && (
              <div className="absolute top-4 left-0 right-0 flex justify-center space-x-2">
                {media.map((_, index) => (
                  <div
                    key={index}
                    className={`h-1 rounded-full transition-all ${
                      index === currentMediaIndex
                        ? 'w-8 bg-white'
                        : 'w-1 bg-white/50'
                    }`}
                  />
                ))}
              </div>
            )}
          </>
        ) : (
          <div className="flex items-center justify-center text-white" style={{ width: '450px', height: '80vh' }}>
            <p>Нет медиа</p>
          </div>
        )}

        {/* Gradient Overlays for readability */}
        <div className="absolute top-0 left-0 right-0 h-32 bg-gradient-to-b from-black/60 to-transparent pointer-events-none" />
        <div className="absolute bottom-0 left-0 right-0 h-64 bg-gradient-to-t from-black/80 to-transparent pointer-events-none" />

        {/* Post Info Overlay - Inside media container */}
        <div className="absolute bottom-0 left-0 right-0 p-4 text-white">
          {/* Shop Info */}
          <Link
            href={`/shops/${post.ownerId}`}
            className="flex items-center space-x-3 mb-3 pointer-events-auto"
          >
          <div className="w-10 h-10 rounded-full bg-gray-200 overflow-hidden border-2 border-white">
            {post.ownerName && (
              <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-blue-500 to-blue-600 text-white font-bold">
                {post.ownerName.charAt(0).toUpperCase()}
              </div>
            )}
          </div>
          <div>
            <p className="font-semibold text-sm">{post.ownerName || 'Магазин'}</p>
            <p className="text-xs text-white/80">
              {new Date(post.createdAt).toLocaleDateString('ru-RU')}
            </p>
          </div>
        </Link>

        {/* Post Caption */}
        {post.text && (
          <p className="text-sm mb-3 line-clamp-3">{post.text}</p>
        )}

        {/* Product Link Button (if linked to product) */}
        {post.productId && (
          <Link
            href={`/products/${post.productId}`}
            className="inline-flex items-center space-x-2 bg-white text-black px-4 py-2 rounded-full font-semibold text-sm mb-3 hover:bg-gray-100 transition-colors pointer-events-auto"
          >
            <ShoppingBag className="w-4 h-4" />
            <span>Перейти к товару</span>
          </Link>
        )}
        </div>
      </div>

      {/* Action Buttons - Right Side of the video */}
      <div className="absolute right-4 bottom-24 flex flex-col space-y-6 z-10">
        {/* Like */}
        <button
          onClick={onLike}
          className="flex flex-col items-center space-y-1"
          disabled={!isAuthenticated}
        >
          <div className="w-12 h-12 rounded-full bg-black/30 flex items-center justify-center">
            <Heart
              className={`w-7 h-7 ${
                isLiked ? 'fill-red-500 text-red-500' : 'text-white'
              }`}
            />
          </div>
          <span className="text-white text-xs font-semibold">
            {post.likesCount}
          </span>
        </button>

        {/* Comments */}
        <Link
          href={`/posts/${post.id}`}
          className="flex flex-col items-center space-y-1"
        >
          <div className="w-12 h-12 rounded-full bg-black/30 flex items-center justify-center">
            <MessageCircle className="w-7 h-7 text-white" />
          </div>
          <span className="text-white text-xs font-semibold">
            {post.commentsCount}
          </span>
        </Link>

        {/* Share */}
        <button
          onClick={() => {
            setShowShareModal(true)
            onShare()
          }}
          className="flex flex-col items-center space-y-1"
          disabled={!isAuthenticated}
        >
          <div className="w-12 h-12 rounded-full bg-black/30 flex items-center justify-center">
            <Share2 className="w-7 h-7 text-white" />
          </div>
          <span className="text-white text-xs font-semibold">
            {post.sharesCount || 0}
          </span>
        </button>

        {/* Save */}
        <button
          onClick={onSave}
          className="flex flex-col items-center"
          disabled={!isAuthenticated}
        >
          <div className="w-12 h-12 rounded-full bg-black/30 flex items-center justify-center">
            <Bookmark
              className={`w-7 h-7 ${
                isSaved ? 'fill-yellow-400 text-yellow-400' : 'text-white'
              }`}
            />
          </div>
        </button>
      </div>

      {/* Share Modal */}
      <ShareModal
        isOpen={showShareModal}
        onClose={() => setShowShareModal(false)}
        shareUrl={`${typeof window !== 'undefined' ? window.location.origin : ''}/posts/${post.id}`}
        shareType="post"
        title={post.text || 'Публикация'}
      />
    </div>
  )
}
