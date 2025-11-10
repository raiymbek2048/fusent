'use client'

import { useState, useRef } from 'react'
import { Upload, X, Loader2, ImageIcon } from 'lucide-react'
import { api } from '@/lib/api'
import Image from 'next/image'

interface ImageUploadProps {
  value?: string
  onChange: (url: string | null) => void
  folder?: 'product' | 'avatar' | 'posts' | 'shop'
  label?: string
  description?: string
  maxSizeMB?: number
  disabled?: boolean
}

export default function ImageUpload({
  value,
  onChange,
  folder = 'product',
  label = 'Изображение',
  description,
  maxSizeMB = 10,
  disabled = false,
}: ImageUploadProps) {
  const [uploading, setUploading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [preview, setPreview] = useState<string | null>(value || null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleFileSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    // Validate file type
    if (!file.type.startsWith('image/')) {
      setError('Пожалуйста, выберите изображение')
      return
    }

    // Validate file size
    const fileSizeMB = file.size / (1024 * 1024)
    if (fileSizeMB > maxSizeMB) {
      setError(`Размер файла не должен превышать ${maxSizeMB}МБ`)
      return
    }

    setError(null)
    setUploading(true)

    try {
      // Create preview
      const previewUrl = URL.createObjectURL(file)
      setPreview(previewUrl)

      // Upload to server
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

      const uploadedUrl = response.data.url
      setPreview(uploadedUrl)
      onChange(uploadedUrl)

      // Clean up preview URL
      URL.revokeObjectURL(previewUrl)
    } catch (err: any) {
      console.error('Upload error:', err)
      setError(err.response?.data?.message || 'Ошибка при загрузке изображения')
      setPreview(value || null)
      onChange(value || null)
    } finally {
      setUploading(false)
    }
  }

  const handleRemove = () => {
    setPreview(null)
    onChange(null)
    setError(null)
    if (fileInputRef.current) {
      fileInputRef.current.value = ''
    }
  }

  const handleClick = () => {
    if (!disabled && !uploading) {
      fileInputRef.current?.click()
    }
  }

  return (
    <div className="space-y-2">
      {label && (
        <label className="block text-sm font-medium text-gray-700">
          {label}
        </label>
      )}

      {description && (
        <p className="text-sm text-gray-500">{description}</p>
      )}

      <div className="relative">
        {preview ? (
          <div className="relative w-full h-64 border-2 border-gray-300 rounded-lg overflow-hidden group">
            <Image
              src={preview}
              alt="Preview"
              fill
              className="object-cover"
              unoptimized
            />

            {!disabled && !uploading && (
              <button
                type="button"
                onClick={handleRemove}
                className="absolute top-2 right-2 p-1.5 bg-red-600 text-white rounded-full opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-700"
              >
                <X className="w-4 h-4" />
              </button>
            )}

            {uploading && (
              <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
                <Loader2 className="w-8 h-8 text-white animate-spin" />
              </div>
            )}
          </div>
        ) : (
          <button
            type="button"
            onClick={handleClick}
            disabled={disabled || uploading}
            className={`w-full h-64 border-2 border-dashed rounded-lg flex flex-col items-center justify-center gap-2 transition-colors ${
              disabled || uploading
                ? 'border-gray-200 bg-gray-50 cursor-not-allowed'
                : 'border-gray-300 hover:border-blue-500 hover:bg-blue-50 cursor-pointer'
            }`}
          >
            {uploading ? (
              <>
                <Loader2 className="w-12 h-12 text-blue-500 animate-spin" />
                <span className="text-sm text-gray-600">Загрузка...</span>
              </>
            ) : (
              <>
                <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center">
                  <ImageIcon className="w-8 h-8 text-gray-400" />
                </div>
                <div className="text-center">
                  <p className="text-sm font-medium text-gray-700">
                    Нажмите для загрузки
                  </p>
                  <p className="text-xs text-gray-500 mt-1">
                    PNG, JPG, WEBP до {maxSizeMB}МБ
                  </p>
                </div>
              </>
            )}
          </button>
        )}

        <input
          ref={fileInputRef}
          type="file"
          accept="image/*"
          onChange={handleFileSelect}
          disabled={disabled || uploading}
          className="hidden"
        />
      </div>

      {error && (
        <p className="text-sm text-red-600">{error}</p>
      )}
    </div>
  )
}
