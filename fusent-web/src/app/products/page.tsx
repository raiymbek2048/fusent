'use client'

import { useState, useEffect, Suspense } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { Search, Filter, MapPin } from 'lucide-react'
import { useProducts, useSearchProducts } from '@/hooks/useProducts'
import { useCategories } from '@/hooks/useCategories'
import { Button, Input, Card, LoadingScreen } from '@/components/ui'
import ProductCard from '@/components/ProductCard'
import MainLayout from '@/components/MainLayout'

export const dynamic = 'force-dynamic'

function ProductsPageContent() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const categoryId = searchParams.get('category')

  const [searchQuery, setSearchQuery] = useState('')
  const [page, setPage] = useState(0)
  const [showFilters, setShowFilters] = useState(false)
  const [isClient, setIsClient] = useState(false)

  useEffect(() => {
    setIsClient(true)
  }, [])

  const { data: categories } = useCategories()
  const { data: productsData, isLoading } = searchQuery
    ? useSearchProducts(searchQuery, { page, size: 12 })
    : useProducts({ page, size: 12, categoryId: categoryId || undefined })

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault()
    setPage(0)
  }

  const handleCategoryChange = (catId: string) => {
    router.push(`/products?category=${catId}`)
    setPage(0)
  }

  if (isLoading) {
    return <LoadingScreen message="Загрузка товаров..." />
  }

  const products = productsData?.content || []
  const totalPages = productsData?.totalPages || 0

  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-8">
        {/* Search Bar */}
        <div className="mb-6">
          <form onSubmit={handleSearch} className="flex gap-2">
            <Input
              type="search"
              placeholder="Поиск товаров..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="flex-grow"
            />
            <Button type="submit">
              <Search className="w-5 h-5 mr-2" />
              Найти
            </Button>
            <Button
              type="button"
              variant="outline"
              onClick={() => router.push('/shops/map')}
            >
              <MapPin className="w-5 h-5 mr-2" />
              Карта
            </Button>
            <Button
              type="button"
              variant="outline"
              onClick={() => setShowFilters(!showFilters)}
            >
              <Filter className="w-5 h-5" />
            </Button>
          </form>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
          {/* Filters Sidebar */}
          {(showFilters || (isClient && window.innerWidth >= 1024)) && (
            <div className="lg:col-span-1">
              <Card>
                <div className="px-6 py-4 border-b border-gray-200">
                  <h3 className="font-semibold text-gray-900">Категории</h3>
                </div>
                <div className="p-4 space-y-2">
                  <button
                    onClick={() => {
                      router.push('/products')
                      setPage(0)
                    }}
                    className={`w-full text-left px-3 py-2 rounded-lg transition-colors ${
                      !categoryId
                        ? 'bg-blue-50 text-blue-600 font-medium'
                        : 'hover:bg-gray-100 text-gray-700'
                    }`}
                  >
                    Все категории
                  </button>
                  {categories?.map((category) => (
                    <button
                      key={category.id}
                      onClick={() => handleCategoryChange(category.id)}
                      className={`w-full text-left px-3 py-2 rounded-lg transition-colors ${
                        categoryId === category.id
                          ? 'bg-blue-50 text-blue-600 font-medium'
                          : 'hover:bg-gray-100 text-gray-700'
                      }`}
                    >
                      {category.name}
                    </button>
                  ))}
                </div>
              </Card>
            </div>
          )}

          {/* Products Grid */}
          <div className="lg:col-span-3">
            {products.length > 0 ? (
              <>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mb-6">
                  {products.map((product) => (
                    <ProductCard key={product.id} product={product} />
                  ))}
                </div>

                {/* Pagination */}
                {totalPages > 1 && (
                  <div className="flex justify-center gap-2">
                    <Button
                      variant="outline"
                      onClick={() => setPage(Math.max(0, page - 1))}
                      disabled={page === 0}
                    >
                      Назад
                    </Button>
                    <div className="flex items-center gap-2 px-4">
                      <span className="text-gray-600">
                        Страница {page + 1} из {totalPages}
                      </span>
                    </div>
                    <Button
                      variant="outline"
                      onClick={() => setPage(Math.min(totalPages - 1, page + 1))}
                      disabled={page >= totalPages - 1}
                    >
                      Вперед
                    </Button>
                  </div>
                )}
              </>
            ) : (
              <Card>
                <div className="text-center py-12">
                  <Search className="w-16 h-16 mx-auto text-gray-300 mb-4" />
                  <h3 className="text-xl font-semibold text-gray-900 mb-2">
                    Товары не найдены
                  </h3>
                  <p className="text-gray-600">
                    Попробуйте изменить параметры поиска
                  </p>
                </div>
              </Card>
            )}
          </div>
        </div>
      </div>
    </MainLayout>
  )
}

export default function ProductsPage() {
  return (
    <Suspense fallback={<LoadingScreen message="Загрузка товаров..." />}>
      <ProductsPageContent />
    </Suspense>
  )
}
