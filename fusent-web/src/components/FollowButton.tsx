'use client'

import { useState, useEffect } from 'react'
import { UserPlus, UserCheck } from 'lucide-react'
import { useFollow, useUnfollow, useIsFollowing } from '@/hooks/useFollow'
import { useAuth } from '@/hooks/useAuth'
import { FollowTargetType } from '@/types'
import toast from 'react-hot-toast'

interface FollowButtonProps {
  targetType: FollowTargetType
  targetId: string
  variant?: 'default' | 'compact'
  className?: string
}

export default function FollowButton({
  targetType,
  targetId,
  variant = 'default',
  className = ''
}: FollowButtonProps) {
  const { user } = useAuth()
  const [isFollowing, setIsFollowing] = useState(false)

  const { data: followingStatus, isLoading } = useIsFollowing(
    targetType,
    targetId,
    { enabled: !!user && !!targetId }
  )
  const { mutate: follow, isPending: isFollowPending } = useFollow()
  const { mutate: unfollow, isPending: isUnfollowPending } = useUnfollow()

  useEffect(() => {
    if (followingStatus !== undefined) {
      setIsFollowing(followingStatus)
    }
  }, [followingStatus])

  const handleToggleFollow = () => {
    if (!user) {
      toast.error('Войдите, чтобы подписаться')
      return
    }

    if (isFollowing) {
      unfollow({ targetType, targetId }, {
        onSuccess: () => setIsFollowing(false),
      })
    } else {
      follow({ targetType, targetId }, {
        onSuccess: () => setIsFollowing(true),
      })
    }
  }

  const isPending = isFollowPending || isUnfollowPending

  if (variant === 'compact') {
    return (
      <button
        onClick={handleToggleFollow}
        disabled={isPending || isLoading}
        className={`text-xs font-semibold transition-colors disabled:opacity-50 disabled:cursor-not-allowed ${
          isFollowing
            ? 'text-gray-600 hover:text-gray-800'
            : 'text-blue-600 hover:text-blue-700'
        } ${className}`}
      >
        {isFollowing ? 'Отписаться' : 'Подписаться'}
      </button>
    )
  }

  return (
    <button
      onClick={handleToggleFollow}
      disabled={isPending || isLoading}
      className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed ${
        isFollowing
          ? 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          : 'bg-blue-600 text-white hover:bg-blue-700'
      } ${className}`}
    >
      {isFollowing ? (
        <>
          <UserCheck className="h-4 w-4" />
          <span>Подписаны</span>
        </>
      ) : (
        <>
          <UserPlus className="h-4 w-4" />
          <span>Подписаться</span>
        </>
      )}
    </button>
  )
}
