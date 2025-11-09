import { useMutation } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import api from '@/lib/api'
import axios from 'axios'

export interface MediaUploadRequest {
  fileName: string
  contentType: string
  folder: 'products' | 'posts' | 'avatars'
}

export interface UploadUrlResponse {
  uploadUrl: string
  fileKey: string
  publicUrl: string
  expiresAt: string
}

export interface UploadResponse {
  url: string
  fileKey: string
}

// Upload single file using presigned URL
export const useUploadMedia = () => {
  return useMutation({
    mutationFn: async ({ file, folder = 'posts' }: { file: File; folder?: 'products' | 'posts' | 'avatars' }): Promise<UploadResponse> => {
      // Step 1: Get presigned URL from backend
      const request: MediaUploadRequest = {
        fileName: file.name,
        contentType: file.type,
        folder,
      }

      const { data } = await api.post<UploadUrlResponse>('/media/upload-url', request)

      // Step 2: Upload file directly to S3/MinIO using presigned URL
      await axios.put(data.uploadUrl, file, {
        headers: {
          'Content-Type': file.type,
        },
      })

      // Step 3: Return public URL and fileKey
      return {
        url: data.publicUrl,
        fileKey: data.fileKey,
      }
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка загрузки файла'
      toast.error(message)
    },
  })
}

// Upload multiple files
export const useUploadMultipleMedia = () => {
  return useMutation({
    mutationFn: async ({ files, folder = 'posts' }: { files: File[]; folder?: 'products' | 'posts' | 'avatars' }): Promise<UploadResponse[]> => {
      const uploadPromises = files.map(async (file) => {
        // Step 1: Get presigned URL
        const request: MediaUploadRequest = {
          fileName: file.name,
          contentType: file.type,
          folder,
        }

        const { data } = await api.post<UploadUrlResponse>('/media/upload-url', request)

        // Step 2: Upload to S3/MinIO
        await axios.put(data.uploadUrl, file, {
          headers: {
            'Content-Type': file.type,
          },
        })

        return {
          url: data.publicUrl,
          fileKey: data.fileKey,
        }
      })

      return await Promise.all(uploadPromises)
    },
    onSuccess: (data) => {
      toast.success(`${data.length} файл(ов) загружено!`)
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка загрузки файлов'
      toast.error(message)
    },
  })
}

// Delete media file
export const useDeleteMedia = () => {
  return useMutation({
    mutationFn: async (fileKey: string): Promise<void> => {
      await api.delete(`/media/${fileKey}`)
    },
    onSuccess: () => {
      toast.success('Файл удален')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка удаления файла'
      toast.error(message)
    },
  })
}

// Get public URL for media
export const useGetMediaUrl = () => {
  return useMutation({
    mutationFn: async (fileKey: string): Promise<string> => {
      const { data } = await api.get<string>(`/media/url/${fileKey}`)
      return data
    },
  })
}
