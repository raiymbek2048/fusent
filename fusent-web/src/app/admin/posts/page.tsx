'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/store/authStore'
import MainLayout from '@/components/MainLayout'
import { Search, Eye, CheckCircle, XCircle, AlertTriangle, Image as ImageIcon } from 'lucide-react'

export default function AdminPostsPage() {
  const router = useRouter()
  const { user, isAuthenticated } = useAuthStore()
  const [searchTerm, setSearchTerm] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')

  useEffect(() => {
    if (!isAuthenticated || user?.role !== 'ADMIN') {
      router.push('/')
    }
  }, [isAuthenticated, user, router])

  if (!user || user.role !== 'ADMIN') {
    return null
  }

  const mockPosts = [
    {
      id: 'POST-001',
      ownerName: 'Fashion Store Bishkek',
      content: 'Новая коллекция зимней одежды! Скидки до 50%',
      status: 'ACTIVE',
      createdAt: '2025-11-10T10:00:00',
    },
  ]

  return (
    <MainLayout>
      <div className="max-w-7xl mx-auto px-4 py-8">
        <button onClick={() => router.push('/admin')} className="text-blue-600 hover:text-blue-700 mb-4">
          ← Назад к панели
        </button>
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Модерация постов</h1>
      </div>
    </MainLayout>
  )
}
