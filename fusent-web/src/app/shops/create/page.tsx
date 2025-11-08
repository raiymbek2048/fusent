'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import MainLayout from '@/components/MainLayout'
import { useCreateShop } from '@/hooks/useShops'
import { useAuthStore } from '@/store/authStore'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Store } from 'lucide-react'

export default function CreateShopPage() {
  const router = useRouter()
  const user = useAuthStore((state) => state.user)
  const createShopMutation = useCreateShop()

  const [formData, setFormData] = useState({
    name: '',
    description: '',
    address: '',
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!formData.name.trim() || !user?.id) {
      return
    }

    try {
      const shop = await createShopMutation.mutateAsync({
        merchantId: user.id,
        name: formData.name,
        address: formData.address || undefined,
      })
      router.push(`/shops/${shop.id}`)
    } catch (error) {
      // Error is handled by the mutation
    }
  }

  // Redirect if not seller
  if (user && user.role !== 'SELLER') {
    return (
      <MainLayout>
        <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6 text-center">
            <p className="text-yellow-800">Только продавцы могут создавать магазины</p>
          </div>
        </div>
      </MainLayout>
    )
  }

  return (
    <MainLayout>
      <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center mb-6">
            <Store className="h-8 w-8 text-blue-600 mr-3" />
            <h1 className="text-2xl font-bold text-gray-900">Создать магазин</h1>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-2">
                Название магазина <span className="text-red-500">*</span>
              </label>
              <Input
                id="name"
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="Введите название магазина"
                required
              />
            </div>

            <div>
              <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-2">
                Описание
              </label>
              <Textarea
                id="description"
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                placeholder="Опишите ваш магазин"
                rows={4}
              />
            </div>

            <div>
              <label htmlFor="address" className="block text-sm font-medium text-gray-700 mb-2">
                Адрес
              </label>
              <Input
                id="address"
                type="text"
                value={formData.address}
                onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                placeholder="Введите адрес магазина"
              />
            </div>

            <div className="flex gap-4">
              <Button
                type="submit"
                disabled={createShopMutation.isPending || !formData.name.trim()}
                className="flex-1"
              >
                {createShopMutation.isPending ? 'Создание...' : 'Создать магазин'}
              </Button>
              <Button
                type="button"
                variant="outline"
                onClick={() => router.back()}
              >
                Отмена
              </Button>
            </div>
          </form>
        </div>
      </div>
    </MainLayout>
  )
}
