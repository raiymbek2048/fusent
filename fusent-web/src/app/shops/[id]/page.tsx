'use client'

import { useParams } from 'next/navigation'
import MainLayout from '@/components/MainLayout'
import ProductCard from '@/components/ProductCard'
import PostCard from '@/components/PostCard'
import { useShop } from '@/hooks/useShops'
import { useShopProducts } from '@/hooks/useProducts'
import { useShopPosts } from '@/hooks/usePosts'
import { MapPin, Star, Package, Loader } from 'lucide-react'
import { useState } from 'react'

// Helper function to validate UUID
const isValidUUID = (uuid: string): boolean => {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
  return uuidRegex.test(uuid)
}

export default function ShopDetailPage() {
  const params = useParams()
  const shopId = params.id as string
  const [activeTab, setActiveTab] = useState<'products' | 'posts'>('products')

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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">{shop.name}</h1>

              {shop.description && <p className="text-gray-600 mb-4">{shop.description}</p>}

              <div className="flex flex-wrap gap-6 text-sm text-gray-600">
                <div className="flex items-center">
                  <Star className="h-4 w-4 text-yellow-400 mr-1" />
                  <span className="font-semibold">{shop.rating.toFixed(1)}</span>
                  <span className="ml-1">({shop.totalReviews} отзывов)</span>
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
                  <ProductCard key={product.id} product={product} />
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
    </MainLayout>
  )
}
