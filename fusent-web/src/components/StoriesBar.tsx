'use client'

import { Circle, Video } from 'lucide-react'

interface Story {
  id: string
  shopId: string
  shopName: string
  shopAvatar?: string
  hasLive: boolean
  hasStories: boolean
}

interface StoriesBarProps {
  stories: Story[]
}

export default function StoriesBar({ stories }: StoriesBarProps) {
  const handleStoryClick = (story: Story) => {
    if (story.hasLive) {
      // Redirect to live stream
      window.location.href = `/live/${story.shopId}`
    } else {
      // Open stories viewer
      window.location.href = `/stories/${story.shopId}`
    }
  }

  return (
    <div className="bg-white border-b border-gray-200 overflow-x-auto scrollbar-hide">
      <div className="flex space-x-4 px-4 py-3">
        {stories.map((story) => (
          <button
            key={story.id}
            onClick={() => handleStoryClick(story)}
            className="flex flex-col items-center flex-shrink-0 space-y-1"
          >
            <div className="relative">
              {/* Avatar with ring */}
              <div
                className={`relative w-16 h-16 rounded-full p-0.5 ${
                  story.hasLive
                    ? 'bg-gradient-to-tr from-red-500 to-red-600'
                    : story.hasStories
                    ? 'bg-gradient-to-tr from-yellow-400 via-pink-500 to-purple-500'
                    : 'bg-gray-300'
                }`}
              >
                <div className="w-full h-full rounded-full border-2 border-white bg-gray-200 overflow-hidden">
                  {story.shopAvatar ? (
                    <img
                      src={story.shopAvatar}
                      alt={story.shopName}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-blue-500 to-blue-600">
                      <span className="text-white font-bold text-lg">
                        {story.shopName.charAt(0).toUpperCase()}
                      </span>
                    </div>
                  )}
                </div>
              </div>

              {/* Live indicator */}
              {story.hasLive && (
                <div className="absolute bottom-0 left-1/2 transform -translate-x-1/2 translate-y-1 bg-red-600 text-white text-xs font-bold px-2 py-0.5 rounded-full flex items-center space-x-1">
                  <Video className="w-2.5 h-2.5" />
                  <span>LIVE</span>
                </div>
              )}
            </div>

            {/* Shop name */}
            <span className="text-xs text-gray-900 font-medium max-w-[64px] truncate">
              {story.shopName}
            </span>
          </button>
        ))}
      </div>
    </div>
  )
}
