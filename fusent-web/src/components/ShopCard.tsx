import Link from 'next/link'
import { Shop } from '@/types'
import { MapPin, Star, Package } from 'lucide-react'

interface ShopCardProps {
  shop: Shop
}

export default function ShopCard({ shop }: ShopCardProps) {
  return (
    <Link href={`/shops/${shop.id}`}>
      <div className="bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow p-6 cursor-pointer">
        {/* Shop Logo */}
        {shop.logoUrl ? (
          <img
            src={shop.logoUrl}
            alt={shop.name}
            className="w-20 h-20 rounded-full mx-auto mb-4 object-cover"
          />
        ) : (
          <div className="w-20 h-20 rounded-full mx-auto mb-4 bg-primary-100 flex items-center justify-center">
            <Package className="h-10 w-10 text-primary-500" />
          </div>
        )}

        {/* Shop Name */}
        <h3 className="text-lg font-semibold text-gray-900 text-center mb-2">{shop.name}</h3>

        {/* Shop Description */}
        {shop.description && (
          <p className="text-gray-600 text-sm text-center mb-4 line-clamp-2">
            {shop.description}
          </p>
        )}

        {/* Shop Stats */}
        <div className="flex items-center justify-center space-x-4 text-sm text-gray-500 mb-3">
          <div className="flex items-center">
            <Star className="h-4 w-4 text-yellow-400 mr-1" />
            <span>{shop.rating.toFixed(1)}</span>
          </div>
          <div className="flex items-center">
            <Package className="h-4 w-4 mr-1" />
            <span>{shop.totalProducts} товаров</span>
          </div>
        </div>

        {/* Shop Address */}
        {shop.address && (
          <div className="flex items-center justify-center text-gray-500 text-xs">
            <MapPin className="h-3 w-3 mr-1" />
            <span className="line-clamp-1">{shop.address}</span>
          </div>
        )}
      </div>
    </Link>
  )
}
