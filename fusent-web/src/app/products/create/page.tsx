'use client'

import { useState } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import MainLayout from '@/components/MainLayout'
import { useCreateProduct } from '@/hooks/useProducts'
import { useCategories } from '@/hooks/useCategories'
import { useAuthStore } from '@/store/authStore'
import { Button, Input, Textarea } from '@/components/ui'
import ImageUpload from '@/components/ImageUpload'
import { Package, Loader } from 'lucide-react'

export const dynamic = 'force-dynamic'

export default function CreateProductPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const shopId = searchParams.get('shopId')
  const user = useAuthStore((state) => state.user)
  const createProductMutation = useCreateProduct()
  const { data: categories, isLoading: categoriesLoading } = useCategories()

  const [formData, setFormData] = useState({
    name: '',
    description: '',
    categoryId: '',
    basePrice: '',
    imageUrl: '',
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!formData.name.trim() || !formData.categoryId || !shopId) {
      return
    }

    try {
      const product = await createProductMutation.mutateAsync({
        shopId,
        categoryId: formData.categoryId,
        name: formData.name,
        description: formData.description || undefined,
        basePrice: parseFloat(formData.basePrice) || 0,
      })
      router.push(`/shops/${shopId}`)
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
            <p className="text-yellow-800">Только продавцы могут создавать товары</p>
          </div>
        </div>
      </MainLayout>
    )
  }

  // Check if shopId is provided
  if (!shopId) {
    return (
      <MainLayout>
        <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
            <p className="text-red-800">ID магазина не указан</p>
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
            <Package className="h-8 w-8 text-blue-600 mr-3" />
            <h1 className="text-2xl font-bold text-gray-900">Добавить товар</h1>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-2">
                Название товара <span className="text-red-500">*</span>
              </label>
              <Input
                id="name"
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="Введите название товара"
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
                placeholder="Опишите ваш товар"
                rows={4}
              />
            </div>

            <ImageUpload
              value={formData.imageUrl}
              onChange={(url) => setFormData({ ...formData, imageUrl: url || '' })}
              folder="product"
              label="Изображение товара"
              description="Загрузите главное изображение товара"
              maxSizeMB={10}
            />

            <div>
              <label htmlFor="categoryId" className="block text-sm font-medium text-gray-700 mb-2">
                Категория <span className="text-red-500">*</span>
              </label>
              {categoriesLoading ? (
                <div className="flex items-center justify-center py-4">
                  <Loader className="h-6 w-6 text-primary-500 animate-spin" />
                </div>
              ) : (
                <select
                  id="categoryId"
                  value={formData.categoryId}
                  onChange={(e) => setFormData({ ...formData, categoryId: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                  required
                >
                  <option value="">Выберите категорию</option>
                  {categories?.map((category) => (
                    <option key={category.id} value={category.id}>
                      {category.name}
                    </option>
                  ))}
                </select>
              )}
            </div>

            <div>
              <label htmlFor="basePrice" className="block text-sm font-medium text-gray-700 mb-2">
                Базовая цена <span className="text-red-500">*</span>
              </label>
              <Input
                id="basePrice"
                type="number"
                step="0.01"
                min="0"
                value={formData.basePrice}
                onChange={(e) => setFormData({ ...formData, basePrice: e.target.value })}
                placeholder="0.00"
                required
              />
            </div>

            <div className="flex gap-4">
              <Button
                type="submit"
                disabled={createProductMutation.isPending || !formData.name.trim() || !formData.categoryId}
                className="flex-1"
              >
                {createProductMutation.isPending ? 'Создание...' : 'Создать товар'}
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
