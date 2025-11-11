'use client'

import { useParams, useRouter } from 'next/navigation'
import MainLayout from '@/components/MainLayout'
import ProductCard from '@/components/ProductCard'
import PostCard from '@/components/PostCard'
import { useShop, useUpdateShop, useDeleteShop } from '@/hooks/useShops'
import { useShopProducts } from '@/hooks/useProducts'
import { useDeleteProduct } from '@/hooks/useProducts'
import { useShopPosts } from '@/hooks/usePosts'
import { useAuthStore } from '@/store/authStore'
import { Button, Input } from '@/components/ui'
import { MapPin, Star, Package, Loader, Plus, Edit, Trash2, X } from 'lucide-react'
import { useState } from 'react'
import toast from 'react-hot-toast'

// Helper function to validate UUID
const isValidUUID = (uuid: string): boolean => {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
  return uuidRegex.test(uuid)
}

export default function ShopDetailPage() {
  const params = useParams()
  const router = useRouter()
  const shopId = params.id as string
  const user = useAuthStore((state) => state.user)
  const [activeTab, setActiveTab] = useState<'products' | 'posts'>('products')

  // Edit and delete state
  const [showEditModal, setShowEditModal] = useState(false)
  const [showDeleteModal, setShowDeleteModal] = useState(false)
  const [showDeleteProductModal, setShowDeleteProductModal] = useState(false)
  const [productToDelete, setProductToDelete] = useState<string | null>(null)
  const [editForm, setEditForm] = useState({
    name: '',
    address: '',
    phone: '',
  })

  const updateShopMutation = useUpdateShop()
  const deleteShopMutation = useDeleteShop()
  const deleteProductMutation = useDeleteProduct()

  // Check if shopId is a valid UUID
  const isValid = isValidUUID(shopId)

  const { data: shop, isLoading: shopLoading } = useShop(isValid ? shopId : '')
  const { data: productsData, isLoading: productsLoading } = useShopProducts(
    isValid ? shopId : '',
    {
      page: 0,
      size: 12,
    }
  )
  const { data: postsData, isLoading: postsLoading } = useShopPosts(
    isValid ? shopId : '',
    { page: 0, size: 10 }
  )

  // Handle edit shop
  const handleEditClick = () => {
    if (shop) {
      setEditForm({
        name: shop.name,
        address: shop.address || '',
        phone: shop.phone || '',
      })
      setShowEditModal(true)
    }
  }

  const handleEditSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!editForm.name.trim()) {
      toast.error('Название магазина обязательно')
      return
    }

    try {
      await updateShopMutation.mutateAsync({
        id: shopId,
        data: {
          name: editForm.name,
          address: editForm.address || undefined,
          phone: editForm.phone || undefined,
        },
      })
      setShowEditModal(false)
    } catch (error) {
      // Error handled by mutation
    }
  }

  // Handle delete shop
  const handleDeleteConfirm = async () => {
    try {
      await deleteShopMutation.mutateAsync(shopId)
      setShowDeleteModal(false)
      router.push('/shops')
    } catch (error) {
      // Error handled by mutation
    }
  }

  // Handle edit product
  const handleEditProduct = (productId: string) => {
    router.push(`/products/${productId}/edit`)
  }

  // Handle delete product
  const handleDeleteProduct = (productId: string) => {
    setProductToDelete(productId)
    setShowDeleteProductModal(true)
  }

  const handleConfirmDeleteProduct = async () => {
    if (!productToDelete) return

    try {
      await deleteProductMutation.mutateAsync(productToDelete)
      setShowDeleteProductModal(false)
      setProductToDelete(null)
    } catch (error) {
      // Error handled by mutation
    }
  }

  // Handle invalid UUID
  if (!isValid) {
    return (
      <MainLayout>
        <div className="text-center py-12">
          <p className="text-gray-600">Неверный ID магазина</p>
        </div>
      </MainLayout>
    )
  }

  if (shopLoading) {
    return (
      <MainLayout>
        <div className="flex justify-center py-12">
          <Loader className="h-8 w-8 text-primary-500 animate-spin" />
        </div>
      </MainLayout>
    )
  }

  if (!shop) {
    return (
      <MainLayout>
        <div className="text-center py-12">
          <p className="text-gray-600">Магазин не найден</p>
        </div>
      </MainLayout>
    )
  }

  return (
    <MainLayout>
      {/* Shop Header */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="flex items-start space-x-6">
            {/* Shop Logo */}
            {shop.logoUrl ? (
              <img
                src={shop.logoUrl}
                alt={shop.name}
                className="w-24 h-24 rounded-full object-cover"
              />
            ) : (
              <div className="w-24 h-24 rounded-full bg-primary-100 flex items-center justify-center">
                <Package className="h-12 w-12 text-primary-500" />
              </div>
            )}

            {/* Shop Info */}
            <div className="flex-1">
              <div className="flex items-start justify-between mb-2">
                <h1 className="text-3xl font-bold text-gray-900">{shop.name}</h1>
                {/* Show action buttons if user is the shop owner */}
                {user && user.id === shop.sellerId && (
                  <div className="flex items-center gap-2">
                    <Button
                      onClick={handleEditClick}
                      variant="outline"
                      className="flex items-center gap-2"
                    >
                      <Edit className="h-4 w-4" />
                      Редактировать
                    </Button>
                    <Button
                      onClick={() => setShowDeleteModal(true)}
                      variant="outline"
                      className="flex items-center gap-2 text-red-600 border-red-300 hover:bg-red-50"
                    >
                      <Trash2 className="h-4 w-4" />
                      Удалить
                    </Button>
                    <Button
                      onClick={() => router.push(`/products/create?shopId=${shopId}`)}
                      className="flex items-center gap-2"
                    >
                      <Plus className="h-4 w-4" />
                      Добавить товар
                    </Button>
                  </div>
                )}
              </div>

              {shop.description && <p className="text-gray-600 mb-4">{shop.description}</p>}

              <div className="flex flex-wrap gap-6 text-sm text-gray-600">
                <div className="flex items-center">
                  <Star className="h-4 w-4 text-yellow-400 mr-1" />
                  <span className="font-semibold">{(shop.rating || 0).toFixed(1)}</span>
                  <span className="ml-1">({shop.totalReviews || 0} отзывов)</span>
                </div>

                <div className="flex items-center">
                  <Package className="h-4 w-4 mr-1" />
                  <span>{shop.totalProducts} товаров</span>
                </div>

                {shop.address && (
                  <div className="flex items-center">
                    <MapPin className="h-4 w-4 mr-1" />
                    <span>{shop.address}</span>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex space-x-8">
            <button
              onClick={() => setActiveTab('products')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'products'
                  ? 'border-primary-500 text-primary-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              Товары
            </button>
            <button
              onClick={() => setActiveTab('posts')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'posts'
                  ? 'border-primary-500 text-primary-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              Посты
            </button>
          </div>
        </div>
      </div>

      {/* Tab Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {activeTab === 'products' && (
          <>
            {productsLoading ? (
              <div className="flex justify-center py-12">
                <Loader className="h-8 w-8 text-primary-500 animate-spin" />
              </div>
            ) : productsData && productsData.content.length > 0 ? (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                {productsData.content.map((product) => (
                  <ProductCard
                    key={product.id}
                    product={product}
                    isOwner={user?.id === shop?.sellerId}
                    onEdit={handleEditProduct}
                    onDelete={handleDeleteProduct}
                  />
                ))}
              </div>
            ) : (
              <div className="text-center py-12">
                <p className="text-gray-600">Товары не найдены</p>
              </div>
            )}
          </>
        )}

        {activeTab === 'posts' && (
          <>
            {postsLoading ? (
              <div className="flex justify-center py-12">
                <Loader className="h-8 w-8 text-primary-500 animate-spin" />
              </div>
            ) : postsData && postsData.content.length > 0 ? (
              <div className="max-w-3xl mx-auto space-y-6">
                {postsData.content.map((post) => (
                  <PostCard key={post.id} post={post} />
                ))}
              </div>
            ) : (
              <div className="text-center py-12">
                <p className="text-gray-600">Посты не найдены</p>
              </div>
            )}
          </>
        )}
      </div>

      {/* Edit Shop Modal */}
      {showEditModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-bold">Редактировать магазин</h2>
              <button
                onClick={() => setShowEditModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <form onSubmit={handleEditSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Название магазина *
                </label>
                <Input
                  value={editForm.name}
                  onChange={(e) => setEditForm({ ...editForm, name: e.target.value })}
                  placeholder="Название магазина"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Адрес
                </label>
                <Input
                  value={editForm.address}
                  onChange={(e) => setEditForm({ ...editForm, address: e.target.value })}
                  placeholder="Адрес магазина"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Телефон
                </label>
                <Input
                  value={editForm.phone}
                  onChange={(e) => setEditForm({ ...editForm, phone: e.target.value })}
                  placeholder="+996 555 123 456"
                />
              </div>

              <div className="flex gap-2 pt-4">
                <Button
                  type="submit"
                  disabled={updateShopMutation.isPending}
                  className="flex-1"
                >
                  {updateShopMutation.isPending ? 'Сохранение...' : 'Сохранить'}
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setShowEditModal(false)}
                >
                  Отмена
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {showDeleteModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-bold text-red-600">Подтверждение удаления</h2>
              <button
                onClick={() => setShowDeleteModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <p className="text-gray-700 mb-6">
              Вы действительно хотите удалить магазин <strong>{shop?.name}</strong>?
              <br />
              <span className="text-red-600 text-sm">
                Это действие нельзя отменить!
              </span>
            </p>

            <div className="flex gap-2">
              <Button
                onClick={handleDeleteConfirm}
                disabled={deleteShopMutation.isPending}
                className="flex-1 bg-red-600 hover:bg-red-700"
              >
                {deleteShopMutation.isPending ? 'Удаление...' : 'Удалить'}
              </Button>
              <Button
                variant="outline"
                onClick={() => setShowDeleteModal(false)}
              >
                Отмена
              </Button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Product Confirmation Modal */}
      {showDeleteProductModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-bold text-red-600">Подтверждение удаления</h2>
              <button
                onClick={() => setShowDeleteProductModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <p className="text-gray-700 mb-6">
              Вы действительно хотите удалить этот товар?
              <br />
              <span className="text-red-600 text-sm">
                Это действие нельзя отменить!
              </span>
            </p>

            <div className="flex gap-2">
              <Button
                onClick={handleConfirmDeleteProduct}
                disabled={deleteProductMutation.isPending}
                className="flex-1 bg-red-600 hover:bg-red-700"
              >
                {deleteProductMutation.isPending ? 'Удаление...' : 'Удалить'}
              </Button>
              <Button
                variant="outline"
                onClick={() => {
                  setShowDeleteProductModal(false)
                  setProductToDelete(null)
                }}
              >
                Отмена
              </Button>
            </div>
          </div>
        </div>
      )}
    </MainLayout>
  )
}
