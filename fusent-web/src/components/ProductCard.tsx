import Link from 'next/link'
import { Product } from '@/types'
import { Star, ShoppingCart } from 'lucide-react'

interface ProductCardProps {
  product: Product
}

export default function ProductCard({ product }: ProductCardProps) {
  const mainImage = product.images?.[0]?.imageUrl

  return (
    <Link href={`/products/${product.id}`}>
      <div className="bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow overflow-hidden cursor-pointer">
        {/* Product Image */}
        <div className="relative h-48 bg-gray-200">
          {mainImage ? (
            <img src={mainImage} alt={product.name} className="w-full h-full object-cover" />
          ) : (
            <div className="w-full h-full flex items-center justify-center">
              <ShoppingCart className="h-16 w-16 text-gray-400" />
            </div>
          )}
        </div>

        {/* Product Info */}
        <div className="p-4">
          {/* Product Name */}
          <h3 className="text-md font-semibold text-gray-900 mb-2 line-clamp-2 h-12">
            {product.name}
          </h3>

          {/* Product Rating & Sales */}
          <div className="flex items-center justify-between text-sm text-gray-500 mb-3">
            <div className="flex items-center">
              <Star className="h-4 w-4 text-yellow-400 mr-1" />
              <span>{(product.rating || 0).toFixed(1)}</span>
              <span className="ml-1">({product.totalReviews || 0})</span>
            </div>
            <span className="text-xs">{product.totalSales || 0} продаж</span>
          </div>

          {/* Product Price */}
          <div className="flex items-center justify-between">
            <span className="text-xl font-bold text-primary-500">
              {(product.basePrice || 0).toLocaleString('ru-RU')} сом
            </span>
          </div>
        </div>
      </div>
    </Link>
  )
}
