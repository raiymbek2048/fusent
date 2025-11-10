'use client'

import { useState, useRef } from 'react'
import { Upload, X, Loader2, ImageIcon, MoveLeft, MoveRight } from 'lucide-react'
import { api } from '@/lib/api'
import Image from 'next/image'

interface MultiImageUploadProps {
  value?: string[]
  onChange: (urls: string[]) => void
  folder?: 'products' | 'avatars' | 'posts' | 'shop'
  label?: string
  description?: string
  maxImages?: number
  maxSizeMB?: number
  disabled?: false
}

export default function MultiImageUpload({
  value = [],
  onChange,
  folder = 'posts',
  label = 'Изображения',
  description,
  maxImages = 10,
  maxSizeMB = 10,
  disabled = false,
}: MultiImageUploadProps) {
  const [uploading, setUploading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [images, setImages] = useState<string[]>(value)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleFilesSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || [])
    if (files.length === 0) return

    // Check max images limit
    if (images.length + files.length > maxImages) {
      setError(`Максимум ${maxImages} изображений`)
      return
    }

    // Validate all files
    for (const file of files) {
      if (!file.type.startsWith('image/')) {
        setError('Все файлы должны быть изображениями')
        return
      }

      const fileSizeMB = file.size / (1024 * 1024)
      if (fileSizeMB > maxSizeMB) {
        setError(`Размер каждого файла не должен превышать ${maxSizeMB}МБ`)
        return
      }
    }

    setError(null)
    setUploading(true)

    try {
      const uploadPromises = files.map(async (file) => {
        const formData = new FormData()
        formData.append('file', file)

        const response = await api.post<{ url: string }>(
          `/media/upload/${folder}`,
          formData,
          {
            headers: {
              'Content-Type': 'multipart/form-data',
            },
          }
        )

        return response.data.url
      })

      const uploadedUrls = await Promise.all(uploadPromises)
      const newImages = [...images, ...uploadedUrls]
      setImages(newImages)
      onChange(newImages)

    } catch (err: any) {
      console.error('Upload error:', err)
      setError(err.response?.data?.message || 'Ошибка при загрузке изображений')
    } finally {
      setUploading(false)
      if (fileInputRef.current) {
        fileInputRef.current.value = ''
      }
    }
  }

  const handleRemove = (index: number) => {
    const newImages = images.filter((_, i) => i !== index)
    setImages(newImages)
    onChange(newImages)
  }

  const handleMoveLeft = (index: number) => {
    if (index === 0) return
    const newImages = [...images]
    ;[newImages[index - 1], newImages[index]] = [newImages[index], newImages[index - 1]]
    setImages(newImages)
    onChange(newImages)
  }

  const handleMoveRight = (index: number) => {
    if (index === images.length - 1) return
    const newImages = [...images]
    ;[newImages[index], newImages[index + 1]] = [newImages[index + 1], newImages[index]]
    setImages(newImages)
    onChange(newImages)
  }

  const handleClick = () => {
    if (!disabled && !uploading && images.length < maxImages) {
      fileInputRef.current?.click()
    }
  }

  return (
    <div className="space-y-3">
      {label && (
        <label className="block text-sm font-medium text-gray-700">
          {label} ({images.length}/{maxImages})
        </label>
      )}

      {description && (
        <p className="text-sm text-gray-500">{description}</p>
      )}

      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        {images.map((url, index) => (
          <div
            key={index}
            className="relative aspect-square border-2 border-gray-300 rounded-lg overflow-hidden group"
          >
            <Image
              src={url}
              alt={`Image ${index + 1}`}
              fill
              className="object-cover"
              unoptimized
            />

            {!disabled && (
              <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-50 transition-opacity">
                <div className="absolute top-2 right-2 flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                  <button
                    type="button"
                    onClick={() => handleRemove(index)}
                    className="p-1.5 bg-red-600 text-white rounded-full hover:bg-red-700"
                    title="Удалить"
                  >
                    <X className="w-3 h-3" />
                  </button>
                </div>

                <div className="absolute bottom-2 left-2 right-2 flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                  <button
                    type="button"
                    onClick={() => handleMoveLeft(index)}
                    disabled={index === 0}
                    className="flex-1 p-1.5 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                    title="Переместить влево"
                  >
                    <MoveLeft className="w-3 h-3 mx-auto" />
                  </button>
                  <button
                    type="button"
                    onClick={() => handleMoveRight(index)}
                    disabled={index === images.length - 1}
                    className="flex-1 p-1.5 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                    title="Переместить вправо"
                  >
                    <MoveRight className="w-3 h-3 mx-auto" />
                  </button>
                </div>
              </div>
            )}

            {index === 0 && (
              <div className="absolute top-2 left-2 px-2 py-1 bg-blue-600 text-white text-xs font-semibold rounded">
                Главное
              </div>
            )}
          </div>
        ))}

        {/* Add more images button */}
        {images.length < maxImages && (
          <button
            type="button"
            onClick={handleClick}
            disabled={disabled || uploading}
            className={`aspect-square border-2 border-dashed rounded-lg flex flex-col items-center justify-center gap-2 transition-colors ${
              disabled || uploading
                ? 'border-gray-200 bg-gray-50 cursor-not-allowed'
                : 'border-gray-300 hover:border-blue-500 hover:bg-blue-50 cursor-pointer'
            }`}
          >
            {uploading ? (
              <>
                <Loader2 className="w-8 h-8 text-blue-500 animate-spin" />
                <span className="text-xs text-gray-600">Загрузка...</span>
              </>
            ) : (
              <>
                <div className="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center">
                  <Upload className="w-6 h-6 text-gray-400" />
                </div>
                <span className="text-xs text-gray-600 text-center px-2">
                  Добавить {images.length === 0 ? 'изображения' : 'еще'}
                </span>
              </>
            )}
          </button>
        )}
      </div>

      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        multiple
        onChange={handleFilesSelect}
        disabled={disabled || uploading}
        className="hidden"
      />

      {error && (
        <p className="text-sm text-red-600">{error}</p>
      )}

      <p className="text-xs text-gray-500">
        Выберите до {maxImages} изображений. PNG, JPG, WEBP до {maxSizeMB}МБ каждое.
        Первое изображение будет главным.
      </p>
    </div>
  )
}
