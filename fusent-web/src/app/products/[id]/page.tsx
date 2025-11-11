'use client'

import { useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import Image from 'next/image'
import { ShoppingCart, Heart, Star, MapPin, MessageCircle } from 'lucide-react'
import { useProduct } from '@/hooks/useProducts'
import { useShop } from '@/hooks/useShops'
import { useAddToCart } from '@/hooks/useCart'
import { useAuthStore } from '@/store/authStore'
import { Button, Badge, Card, CardContent, LoadingScreen } from '@/components/ui'
import MainLayout from '@/components/MainLayout'

export default function ProductPage() {
  const params = useParams()
  const router = useRouter()
  const productId = params.id as string
  const user = useAuthStore((state) => state.user)

  const { data: product, isLoading } = useProduct(productId)
  const { data: shop } = useShop(product?.shopId || '')
  const addToCart = useAddToCart(user?.id)

  const [selectedVariant, setSelectedVariant] = useState<string | null>(null)
  const [quantity, setQuantity] = useState(1)

  if (isLoading) {
    return <LoadingScreen message="Загрузка товара..." />
  }

  if (!product) {
    return (
      <MainLayout>
        <div className="container mx-auto px-4 py-12 text-center">
          <h1 className="text-2xl font-bold text-gray-900">Товар не найден</h1>
          <Button onClick={() => router.push('/')} className="mt-4">
            На главную
          </Button>
        </div>
      </MainLayout>
    )
  }

  const hasVariants = product.variants && product.variants.length > 0
  const currentVariant = product.variants?.find(v => v.id === selectedVariant) || product.variants?.[0]
  const currentPrice = currentVariant?.price || product.basePrice
  // If product has no variants, consider it in stock. Otherwise check variant stock.
  const inStock = hasVariants ? (currentVariant?.stockQuantity || 0) > 0 : true
  const maxQuantity = hasVariants ? (currentVariant?.stockQuantity || 0) : 999

  const handleAddToCart = () => {
    if (!user) {
      router.push('/login')
      return
    }

    // Check if product has variants
    if (!product.variants || product.variants.length === 0) {
      alert('Этот товар временно недоступен для покупки. Пожалуйста, свяжитесь с продавцом.')
      return
    }

    if (!selectedVariant && product.variants.length > 0) {
      alert('Выберите вариант товара')
      return
    }

    if (!selectedVariant) {
      alert('Выберите вариант товара')
      return
    }

    addToCart.mutate({
      variantId: selectedVariant,
      qty: quantity,
    })
  }

  const handleContactSeller = () => {
    if (!user) {
      router.push('/login')
      return
    }
    // Try to get sellerId from different possible sources
    const sellerId = shop?.sellerId || shop?.merchantId
    if (!sellerId) {
      console.error('Shop data:', shop)
      alert('Информация о продавце недоступна. Пожалуйста, попробуйте позже.')
      return
    }
    router.push(`/chat?sellerId=${sellerId}`)
  }

  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Product Images */}
          <div>
            <div className="aspect-square relative bg-gray-100 rounded-lg overflow-hidden">
              {product.images && product.images.length > 0 ? (
                <Image
                  src={product.images[0].imageUrl}
                  alt={product.name}
                  fill
                  className="object-cover"
                />
              ) : (
                <div className="flex items-center justify-center h-full text-gray-400">
                  Нет изображения
                </div>
              )}
            </div>

            {/* Thumbnails */}
            {product.images && product.images.length > 1 && (
              <div className="grid grid-cols-4 gap-2 mt-4">
                {product.images.slice(0, 4).map((img) => (
                  <div key={img.id} className="aspect-square relative bg-gray-100 rounded-lg overflow-hidden cursor-pointer hover:opacity-75">
                    <Image
                      src={img.imageUrl}
                      alt={product.name}
                      fill
                      className="object-cover"
                    />
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Product Info */}
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">
              {product.name}
            </h1>

            {/* Rating */}
            <div className="flex items-center gap-2 mb-4">
              <div className="flex items-center">
                <Star className="w-5 h-5 text-yellow-400 fill-current" />
                <span className="ml-1 font-medium">{(product.rating || 0).toFixed(1)}</span>
              </div>
              <span className="text-gray-500">
                ({product.totalReviews || 0} отзывов)
              </span>
              <span className="text-gray-400">•</span>
              <span className="text-gray-600">
                Продано: {product.totalSales || 0}
              </span>
            </div>

            {/* Shop Info */}
            {shop && (
              <Card className="mb-4">
                <CardContent className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    {shop.logoUrl && (
                      <Image
                        src={shop.logoUrl}
                        alt={shop.name}
                        width={48}
                        height={48}
                        className="rounded-full"
                      />
                    )}
                    <div>
                      <h3 className="font-semibold text-gray-900">{shop.name}</h3>
                      <div className="flex items-center gap-1 text-sm text-gray-500">
                        <MapPin className="w-4 h-4" />
                        {shop.address}
                      </div>
                    </div>
                  </div>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => router.push(`/shops/${shop.id}`)}
                  >
                    В магазин
                  </Button>
                </CardContent>
              </Card>
            )}

            {/* Price */}
            <div className="mb-6">
              <div className="text-4xl font-bold text-gray-900">
                {(currentPrice || 0).toLocaleString()} сом
              </div>
              {!inStock && (
                <Badge variant="error" className="mt-2">
                  Нет в наличии
                </Badge>
              )}
            </div>

            {/* Variants */}
            {product.variants && product.variants.length > 0 && (
              <div className="mb-6">
                <h3 className="font-semibold text-gray-900 mb-3">Выберите вариант:</h3>
                <div className="grid grid-cols-2 gap-2">
                  {product.variants.map((variant) => (
                    <button
                      key={variant.id}
                      onClick={() => setSelectedVariant(variant.id)}
                      className={`p-3 border-2 rounded-lg transition-colors ${
                        selectedVariant === variant.id
                          ? 'border-blue-600 bg-blue-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                    >
                      <div className="font-medium">{variant.name}</div>
                      <div className="text-sm text-gray-600">
                        {(variant.price || 0).toLocaleString()} сом
                      </div>
                      <div className="text-xs text-gray-500">
                        В наличии: {variant.stockQuantity || 0}
                      </div>
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Quantity */}
            <div className="mb-6">
              <h3 className="font-semibold text-gray-900 mb-3">Количество:</h3>
              <div className="flex items-center gap-3">
                <button
                  onClick={() => setQuantity(Math.max(1, quantity - 1))}
                  className="w-10 h-10 border border-gray-300 rounded-lg hover:bg-gray-100"
                  disabled={!inStock}
                >
                  -
                </button>
                <span className="text-xl font-medium w-12 text-center">{quantity}</span>
                <button
                  onClick={() => setQuantity(quantity + 1)}
                  className="w-10 h-10 border border-gray-300 rounded-lg hover:bg-gray-100"
                  disabled={!inStock || quantity >= maxQuantity}
                >
                  +
                </button>
              </div>
            </div>

            {/* Actions */}
            <div className="flex gap-3 mb-6">
              <Button
                fullWidth
                onClick={handleAddToCart}
                disabled={!inStock || addToCart.isPending || !hasVariants || (hasVariants && !selectedVariant)}
                isLoading={addToCart.isPending}
              >
                <ShoppingCart className="w-5 h-5 mr-2" />
                {!hasVariants ? 'Товар недоступен' : 'Добавить в корзину'}
              </Button>
              <Button variant="outline" size="md">
                <Heart className="w-5 h-5" />
              </Button>
            </div>

            <Button
              fullWidth
              variant="outline"
              onClick={handleContactSeller}
            >
              <MessageCircle className="w-5 h-5 mr-2" />
              Написать продавцу
            </Button>

            {/* Description */}
            {product.description && (
              <div className="mt-8 border-t pt-6">
                <h3 className="font-semibold text-gray-900 mb-3">Описание:</h3>
                <p className="text-gray-700 whitespace-pre-wrap">
                  {product.description}
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </MainLayout>
  )
}
