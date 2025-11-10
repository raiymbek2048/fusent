'use client'

import { Bookmark } from 'lucide-react'
import { useToggleSavePost, useIsPostSaved } from '@/hooks/useSavedPosts'
import { useAuth } from '@/hooks/useAuth'

interface SaveButtonProps {
  postId: string
  className?: string
}

export default function SaveButton({ postId, className = '' }: SaveButtonProps) {
  const { user } = useAuth()
  const { data: isSaved = false, isLoading } = useIsPostSaved(user ? postId : undefined)
  const { toggleSave, isPending } = useToggleSavePost()

  const handleSave = async () => {
    if (!user) {
      alert('Войдите, чтобы сохранить пост')
      return
    }

    try {
      await toggleSave(postId, isSaved)
    } catch (error) {
      console.error('Error toggling save:', error)
      alert('Не удалось сохранить пост')
    }
  }

  return (
    <button
      onClick={handleSave}
      disabled={isPending || isLoading}
      className={`hover:opacity-70 transition-opacity disabled:opacity-50 ${className}`}
    >
      <Bookmark
        className={`h-7 w-7 ${
          isSaved
            ? 'fill-yellow-500 text-yellow-500'
            : 'text-gray-900'
        }`}
      />
    </button>
  )
}
