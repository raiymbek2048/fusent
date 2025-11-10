'use client'

import { useState } from 'react'
import { X, MapPin } from 'lucide-react'
import { useCreatePost } from '@/hooks/usePosts'
import { useAuth } from '@/hooks/useAuth'
import MultiImageUpload from '@/components/MultiImageUpload'
import toast from 'react-hot-toast'

interface CreatePostModalProps {
  isOpen: boolean
  onClose: () => void
  ownerId?: string
  ownerType?: 'USER' | 'MERCHANT'
}

export default function CreatePostModal({
  isOpen,
  onClose,
  ownerId,
  ownerType = 'USER',
}: CreatePostModalProps) {
  const { user } = useAuth()
  const { mutate: createPost, isPending } = useCreatePost()

  const [text, setText] = useState('')
  const [mediaUrls, setMediaUrls] = useState<string[]>([])
  const [tags, setTags] = useState<string[]>([])
  const [tagInput, setTagInput] = useState('')
  const [visibility, setVisibility] = useState<'PUBLIC' | 'FOLLOWERS' | 'PRIVATE'>('PUBLIC')
  const [location, setLocation] = useState<{ lat: number; lon: number } | null>(null)

  if (!isOpen) return null

  const handleAddTag = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && tagInput.trim()) {
      e.preventDefault()
      const tag = tagInput.trim().replace('#', '')
      if (!tags.includes(tag)) {
        setTags(prev => [...prev, tag])
      }
      setTagInput('')
    }
  }

  const removeTag = (tag: string) => {
    setTags(prev => prev.filter(t => t !== tag))
  }

  const getCurrentLocation = () => {
    if ('geolocation' in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setLocation({
            lat: position.coords.latitude,
            lon: position.coords.longitude,
          })
          toast.success('Местоположение добавлено')
        },
        () => {
          toast.error('Не удалось получить местоположение')
        }
      )
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!text.trim() && mediaUrls.length === 0) {
      toast.error('Добавьте текст или медиа')
      return
    }

    const finalOwnerId = ownerId || user?.id
    if (!finalOwnerId) {
      toast.error('Необходима авторизация')
      return
    }

    try {
      createPost({
        ownerType,
        ownerId: finalOwnerId,
        text: text.trim(),
        postType: mediaUrls.length > 0 ? 'PHOTO' : 'TEXT',
        visibility,
        tags: tags.length > 0 ? tags : undefined,
        geoLat: location?.lat,
        geoLon: location?.lon,
        media: mediaUrls.length > 0 ? mediaUrls.map((url, index) => ({
          mediaType: 'IMAGE' as const,
          url,
          sortOrder: index,
        })) : undefined,
      }, {
        onSuccess: () => {
          // Reset form
          setText('')
          setMediaUrls([])
          setTags([])
          setLocation(null)
          onClose()
        },
      })
    } catch (error) {
      console.error('Error creating post:', error)
    }
  }

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex min-h-screen items-center justify-center p-4">
        {/* Backdrop */}
        <div
          className="fixed inset-0 bg-black bg-opacity-50 transition-opacity"
          onClick={onClose}
        />

        {/* Modal */}
        <div className="relative w-full max-w-2xl transform overflow-hidden rounded-2xl bg-white p-6 shadow-xl transition-all">
          {/* Header */}
          <div className="flex items-center justify-between border-b pb-4 mb-4">
            <h3 className="text-xl font-semibold text-gray-900">
              Создать публикацию
            </h3>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-500 transition-colors"
            >
              <X className="h-6 w-6" />
            </button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Text Input */}
            <textarea
              value={text}
              onChange={(e) => setText(e.target.value)}
              placeholder="Что нового?"
              rows={4}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
            />

            {/* Media Upload */}
            <MultiImageUpload
              value={mediaUrls}
              onChange={setMediaUrls}
              folder="posts"
              label="Фото"
              maxImages={10}
              maxSizeMB={5}
            />

            {/* Tags */}
            {tags.length > 0 && (
              <div className="flex flex-wrap gap-2">
                {tags.map(tag => (
                  <span
                    key={tag}
                    className="inline-flex items-center gap-1 px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-sm"
                  >
                    #{tag}
                    <button
                      type="button"
                      onClick={() => removeTag(tag)}
                      className="hover:text-blue-900"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  </span>
                ))}
              </div>
            )}

            {/* Tag Input */}
            <input
              type="text"
              value={tagInput}
              onChange={(e) => setTagInput(e.target.value)}
              onKeyDown={handleAddTag}
              placeholder="Добавить тег (нажмите Enter)"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />

            {/* Location */}
            {location && (
              <div className="flex items-center gap-2 text-sm text-gray-600 bg-gray-50 p-2 rounded-lg">
                <MapPin className="h-4 w-4" />
                <span>Местоположение добавлено</span>
                <button
                  type="button"
                  onClick={() => setLocation(null)}
                  className="ml-auto text-red-500 hover:text-red-700"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>
            )}

            {/* Visibility Select */}
            <select
              value={visibility}
              onChange={(e) => setVisibility(e.target.value as any)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="PUBLIC">Публичная</option>
              <option value="FOLLOWERS">Только подписчики</option>
              <option value="PRIVATE">Приватная</option>
            </select>

            {/* Action Buttons */}
            <div className="flex items-center justify-between pt-4 border-t">
              <button
                type="button"
                onClick={getCurrentLocation}
                className="px-3 py-2 text-gray-600 hover:bg-gray-100 rounded-lg transition-colors flex items-center gap-2"
              >
                <MapPin className="h-5 w-5" />
                <span className="text-sm">{location ? 'Изменить местоположение' : 'Добавить местоположение'}</span>
              </button>

              <div className="flex gap-2">
                <button
                  type="button"
                  onClick={onClose}
                  className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  Отмена
                </button>
                <button
                  type="submit"
                  disabled={isPending || (!text.trim() && mediaUrls.length === 0)}
                  className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isPending ? 'Публикация...' : 'Опубликовать'}
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  )
}
