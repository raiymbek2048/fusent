import { useMutation } from '@tanstack/react-query'
import toast from 'react-hot-toast'
import api from '@/lib/api'

export interface UploadResponse {
  url: string
  fileName: string
  fileSize: number
  contentType: string
}

// Upload file
export const useUploadFile = () => {
  return useMutation({
    mutationFn: async (file: File): Promise<UploadResponse> => {
      const formData = new FormData()
      formData.append('file', file)

      const response = await api.post<UploadResponse>('/media/upload', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      })
      return response.data
    },
    onSuccess: () => {
      toast.success('Файл загружен успешно!')
    },
    onError: (error: any) => {
      const message = error.response?.data?.message || 'Ошибка загрузки файла'
      toast.error(message)
    },
  })
}

// Upload multiple files
export const useUploadFiles = () => {
  return useMutation({
    mutationFn: async (files: File[]): Promise<UploadResponse[]> => {
      const formData = new FormData()
      files.forEach((file) => {
        formData.append('files', file)
      })

      const response = await api.post<UploadResponse[]>('/media/upload-multiple', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      })
      return response.data
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

// Delete file
export const useDeleteFile = () => {
  return useMutation({
    mutationFn: async (fileUrl: string): Promise<void> => {
      await api.delete('/media/delete', { data: { url: fileUrl } })
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
