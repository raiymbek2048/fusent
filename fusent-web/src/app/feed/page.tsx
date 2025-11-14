'use client'

import { useState, useEffect, useRef } from 'react'
import MainLayout from '@/components/MainLayout'
import StoriesBar from '@/components/StoriesBar'
import FeedPost from '@/components/FeedPost'
import { usePublicFeed, useLikePost, useUnlikePost } from '@/hooks/usePosts'
import { useToggleSavePost, useIsPostSaved } from '@/hooks/useSavedPosts'
import { useToggleSharePost } from '@/hooks/useShares'
import { Search } from 'lucide-react'

export default function FeedPage() {
  const [activeTab, setActiveTab] = useState<'subscriptions' | 'recommendations' | 'trending'>('recommendations')
  const [searchQuery, setSearchQuery] = useState('')
  const [showSearch, setShowSearch] = useState(false)
  const [currentPostIndex, setCurrentPostIndex] = useState(0)
  const scrollContainerRef = useRef<HTMLDivElement>(null)

  // Fetch feed based on active tab
  const { data, isLoading } = usePublicFeed({ page: 0, size: 50 })
  const likeMutation = useLikePost()
  const unlikeMutation = useUnlikePost()
  const { toggleSave } = useToggleSavePost()
  const { toggleShare } = useToggleSharePost()

  // Mock stories data (replace with real API call)
  const mockStories = [
    {
      id: '1',
      shopId: 'shop1',
      shopName: 'Магазин 1',
      hasLive: true,
      hasStories: true,
    },
    {
      id: '2',
      shopId: 'shop2',
      shopName: 'Магазин 2',
      hasLive: false,
      hasStories: true,
    },
  ]

  const handleLike = (postId: string) => {
    likeMutation.mutate(postId)
  }

  const handleSave = async (postId: string, isSaved: boolean) => {
    await toggleSave(postId, isSaved)
  }

  const handleShare = async (postId: string, isShared: boolean) => {
    await toggleShare(postId, isShared)
  }

  const tabs = [
    { id: 'subscriptions', label: 'Подписки' },
    { id: 'recommendations', label: 'Рекомендации' },
    { id: 'trending', label: 'Тренды' },
  ] as const

  const posts = data?.content || []

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'ArrowDown') {
        e.preventDefault()
        if (currentPostIndex < posts.length - 1) {
          setCurrentPostIndex(currentPostIndex + 1)
        }
      } else if (e.key === 'ArrowUp') {
        e.preventDefault()
        if (currentPostIndex > 0) {
          setCurrentPostIndex(currentPostIndex - 1)
        }
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [currentPostIndex, posts.length])

  // Scroll to current post
  useEffect(() => {
    if (scrollContainerRef.current && posts.length > 0) {
      const postElements = scrollContainerRef.current.children
      if (postElements[currentPostIndex]) {
        postElements[currentPostIndex].scrollIntoView({ behavior: 'smooth', block: 'start' })
      }
    }
  }, [currentPostIndex, posts.length])

  return (
    <MainLayout>
      <div className="h-screen flex flex-col" style={{ backgroundColor: '#e9d5ff' }}>
        {/* Top Bar with Tabs - Compact Header */}
        <div className="flex-shrink-0 bg-white absolute top-0 left-0 right-0 z-20">
          <div className="flex items-center justify-between px-4 py-2">
            <h1 className="text-lg font-bold text-gray-900">Fucent</h1>
            <button
              onClick={() => setShowSearch(!showSearch)}
              className="p-1.5 hover:bg-gray-100 rounded-full transition-colors"
            >
              <Search className="w-5 h-5 text-gray-600" />
            </button>
          </div>

          {/* Search Bar (показывается только когда активен) */}
          {showSearch && activeTab === 'recommendations' && (
            <div className="px-4 pb-2">
              <input
                type="text"
                placeholder="Поиск магазинов..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full px-3 py-1.5 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          )}

          {/* Tabs */}
          <div className="flex border-b border-gray-200">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex-1 py-2 text-sm font-medium transition-colors ${
                  activeTab === tab.id
                    ? 'text-blue-600 border-b-2 border-blue-600'
                    : 'text-gray-600 hover:text-gray-900'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>

          {/* Stories Bar */}
          <StoriesBar stories={mockStories} />
        </div>

        {/* Feed Content - Full screen vertical scroll */}
        <div className="flex-1 overflow-y-scroll snap-y snap-mandatory scrollbar-hide" ref={scrollContainerRef}>
          {isLoading ? (
            <div className="h-screen flex items-center justify-center">
              <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-purple-600"></div>
            </div>
          ) : posts.length > 0 ? (
            posts.map((post, index) => (
              <FeedPost
                key={post.id}
                post={post}
                onLike={() => handleLike(post.id)}
                onSave={() => handleSave(post.id, false)}
                onShare={() => handleShare(post.id, false)}
                isLiked={post.isLikedByCurrentUser || false}
                isSaved={false}
              />
            ))
          ) : (
            <div className="h-screen flex items-center justify-center">
              <div className="text-center">
                <p className="text-lg mb-2 text-gray-800">Нет публикаций</p>
                <p className="text-sm text-gray-600">Подпишитесь на магазины, чтобы видеть их публикации</p>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* CSS for hiding scrollbar */}
      <style jsx global>{`
        .scrollbar-hide::-webkit-scrollbar {
          display: none;
        }
        .scrollbar-hide {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
    </MainLayout>
  )
}
