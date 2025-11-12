import Link from 'next/link'
import { Product } from '@/types'
import { Star, ShoppingCart, Edit, Trash2 } from 'lucide-react'
import { useAuthStore } from '@/store/authStore'
import { useState } from 'react'

interface ProductCardProps {
  product: Product
  isOwner?: boolean
  onEdit?: (productId: string) => void
  onDelete?: (productId: string) => void
}

export default function ProductCard({ product, isOwner, onEdit, onDelete }: ProductCardProps) {
  const user = useAuthStore((state) => state.user)
  const mainImage = product.imageUrl
  const [showActions, setShowActions] = useState(false)

  // Check if current user is the owner (via shop)
  const isProductOwner = isOwner || (user && product.shopId && user.id === product.shopId)

  const handleEdit = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    if (onEdit) {
      onEdit(product.id)
    }
  }

  const handleDelete = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    if (onDelete) {
      onDelete(product.id)
    }
  }

  return (
    <div
      className="relative bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow overflow-hidden"
      onMouseEnter={() => setShowActions(true)}
      onMouseLeave={() => setShowActions(false)}
    >
      <Link href={`/products/${product.id}`}>
        <div className="cursor-pointer">
          {/* Product Image */}
          <div className="relative h-48 bg-gray-200">
            {mainImage ? (
              <img src={mainImage} alt={product.name} className="w-full h-full object-cover" />
            ) : (
              <div className="w-full h-full flex items-center justify-center">
                <ShoppingCart className="h-16 w-16 text-gray-400" />
              </div>
            )}

            {/* Owner Actions Overlay */}
            {isProductOwner && showActions && (
              <div className="absolute top-2 right-2 flex gap-2">
                <button
                  onClick={handleEdit}
                  className="bg-white p-2 rounded-full shadow-md hover:bg-blue-50 transition-colors"
                  title="Редактировать"
                >
                  <Edit className="h-4 w-4 text-blue-600" />
                </button>
                <button
                  onClick={handleDelete}
                  className="bg-white p-2 rounded-full shadow-md hover:bg-red-50 transition-colors"
                  title="Удалить"
                >
                  <Trash2 className="h-4 w-4 text-red-600" />
                </button>
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
    </div>
  )
}
