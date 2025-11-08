'use client'

import { useState } from 'react'
import MainLayout from '@/components/MainLayout'
import ShopCard from '@/components/ShopCard'
import { useShops } from '@/hooks/useShops'
import { Search } from 'lucide-react'

export default function ShopsPage() {
  const [page, setPage] = useState(0)
  const [searchQuery, setSearchQuery] = useState('')

  const { data, isLoading, error } = useShops({ page, size: 12 })

  const filteredShops = data?.content.filter((shop) =>
    shop.name.toLowerCase().includes(searchQuery.toLowerCase())
  )

  return (
    <MainLayout>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-4">Все магазины</h1>

          {/* Search */}
          <div className="relative max-w-md">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              placeholder="Поиск магазинов..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
            />
          </div>
        </div>

        {/* Loading State */}
        {isLoading && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[...Array(12)].map((_, i) => (
              <div key={i} className="bg-gray-200 h-64 rounded-lg animate-pulse" />
            ))}
          </div>
        )}

        {/* Error State */}
        {error && (
          <div className="text-center py-12">
            <p className="text-red-600">Ошибка загрузки магазинов</p>
          </div>
        )}

        {/* Shops Grid */}
        {!isLoading && !error && filteredShops && (
          <>
            {filteredShops.length === 0 ? (
              <div className="text-center py-12">
                <p className="text-gray-600">Магазины не найдены</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {filteredShops.map((shop) => (
                  <ShopCard key={shop.id} shop={shop} />
                ))}
              </div>
            )}

            {/* Pagination */}
            {data && data.totalPages > 1 && (
              <div className="mt-8 flex justify-center gap-2">
                <button
                  onClick={() => setPage((p) => Math.max(0, p - 1))}
                  disabled={data.first}
                  className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Назад
                </button>

                <span className="px-4 py-2 text-sm text-gray-700">
                  Страница {data.number + 1} из {data.totalPages}
                </span>

                <button
                  onClick={() => setPage((p) => p + 1)}
                  disabled={data.last}
                  className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Вперед
                </button>
              </div>
            )}
          </>
        )}
      </div>
    </MainLayout>
  )
}
