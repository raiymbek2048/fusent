'use client'

import { useState, useEffect, Suspense } from 'react'
import { useRouter, useParams } from 'next/navigation'
import MainLayout from '@/components/MainLayout'
import { useProduct, useUpdateProduct } from '@/hooks/useProducts'
import { useCategories } from '@/hooks/useCategories'
import { useAuthStore } from '@/store/authStore'
import { Button, Input, Textarea, LoadingScreen } from '@/components/ui'
import ImageUpload from '@/components/ImageUpload'
import { Package, Loader } from 'lucide-react'

export const dynamic = 'force-dynamic'

function EditProductPageContent() {
  const router = useRouter()
  const params = useParams()
  const productId = params.id as string
  const user = useAuthStore((state) => state.user)
  const updateProductMutation = useUpdateProduct()
  const { data: product, isLoading: productLoading } = useProduct(productId)
  const { data: categories, isLoading: categoriesLoading } = useCategories()

  const [formData, setFormData] = useState({
    name: '',
    description: '',
    categoryId: '',
    basePrice: '',
    imageUrl: '',
  })

  // Pre-populate form with existing product data
  useEffect(() => {
    if (product) {
      setFormData({
        name: product.name || '',
        description: product.description || '',
        categoryId: product.categoryId || '',
        basePrice: product.basePrice?.toString() || '',
        imageUrl: product.images?.[0]?.imageUrl || '',
      })
    }
  }, [product])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!formData.name.trim() || !formData.categoryId) {
      return
    }

    try {
      await updateProductMutation.mutateAsync({
        id: productId,
        data: {
          name: formData.name,
          description: formData.description || undefined,
          categoryId: formData.categoryId,
          basePrice: parseFloat(formData.basePrice) || 0,
          shopId: product!.shopId, // Required field
        },
      })
      router.push(`/shops/${product!.shopId}`)
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
            <p className="text-yellow-800">Только продавцы могут редактировать товары</p>
          </div>
        </div>
      </MainLayout>
    )
  }

  // Loading state
  if (productLoading) {
    return <LoadingScreen message="Загрузка товара..." />
  }

  // Product not found
  if (!product) {
    return (
      <MainLayout>
        <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
            <p className="text-red-800">Товар не найден</p>
            <Button onClick={() => router.back()} className="mt-4">
              Назад
            </Button>
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
            <h1 className="text-2xl font-bold text-gray-900">Редактировать товар</h1>
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
                disabled={updateProductMutation.isPending || !formData.name.trim() || !formData.categoryId}
                className="flex-1"
              >
                {updateProductMutation.isPending ? 'Сохранение...' : 'Сохранить изменения'}
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

export default function EditProductPage() {
  return (
    <Suspense fallback={<LoadingScreen message="Загрузка..." />}>
      <EditProductPageContent />
    </Suspense>
  )
}
