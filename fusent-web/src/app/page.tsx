'use client'

import Link from 'next/link'
import MainLayout from '@/components/MainLayout'
import ShopCard from '@/components/ShopCard'
import ProductCard from '@/components/ProductCard'
import { useShops } from '@/hooks/useShops'
import { useProducts } from '@/hooks/useProducts'
import { ArrowRight, Store, Package, Users } from 'lucide-react'

export default function HomePage() {
  const { data: shopsData, isLoading: shopsLoading } = useShops({ page: 0, size: 6 })
  const { data: productsData, isLoading: productsLoading } = useProducts({ page: 0, size: 8 })

  return (
    <MainLayout>
      {/* Hero Section */}
      <section className="bg-gradient-to-r from-blue-500 to-blue-600 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
          <div className="text-center">
            <h1 className="text-4xl md:text-5xl font-bold mb-6">
              Добро пожаловать в Fucent
            </h1>
            <p className="text-xl md:text-2xl mb-8 text-blue-100">
              Маркетплейс Кыргызстана - найдите лучшие магазины и товары в Бишкеке
            </p>
            <div className="flex flex-col sm:flex-row justify-center gap-4">
              <Link
                href="/products"
                className="bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors inline-flex items-center justify-center"
              >
                Смотреть товары
                <ArrowRight className="ml-2 h-5 w-5" />
              </Link>
              <Link
                href="/shops"
                className="bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors inline-flex items-center justify-center"
              >
                Смотреть магазины
                <Store className="ml-2 h-5 w-5" />
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <Store className="h-8 w-8 text-blue-600" />
              </div>
              <h3 className="text-xl font-semibold mb-2">Проверенные магазины</h3>
              <p className="text-gray-600">
                Только надежные продавцы с подтвержденной репутацией
              </p>
            </div>
            <div className="text-center">
              <div className="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <Package className="h-8 w-8 text-blue-600" />
              </div>
              <h3 className="text-xl font-semibold mb-2">Широкий выбор</h3>
              <p className="text-gray-600">Тысячи товаров в различных категориях</p>
            </div>
            <div className="text-center">
              <div className="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <Users className="h-8 w-8 text-blue-600" />
              </div>
              <h3 className="text-xl font-semibold mb-2">Социальная лента</h3>
              <p className="text-gray-600">Следите за новостями любимых магазинов</p>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Shops Section */}
      <section className="py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center mb-8">
            <h2 className="text-3xl font-bold text-gray-900">Популярные магазины</h2>
            <Link
              href="/shops"
              className="text-blue-600 hover:text-blue-700 font-semibold inline-flex items-center"
            >
              Смотреть все
              <ArrowRight className="ml-2 h-5 w-5" />
            </Link>
          </div>

          {shopsLoading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[...Array(6)].map((_, i) => (
                <div key={i} className="bg-gray-200 h-64 rounded-lg animate-pulse" />
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {shopsData?.content.map((shop) => (
                <ShopCard key={shop.id} shop={shop} />
              ))}
            </div>
          )}
        </div>
      </section>

      {/* Featured Products Section */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center mb-8">
            <h2 className="text-3xl font-bold text-gray-900">Популярные товары</h2>
            <Link
              href="/products"
              className="text-blue-600 hover:text-blue-700 font-semibold inline-flex items-center"
            >
              Смотреть все
              <ArrowRight className="ml-2 h-5 w-5" />
            </Link>
          </div>

          {productsLoading ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
              {[...Array(8)].map((_, i) => (
                <div key={i} className="bg-gray-200 h-80 rounded-lg animate-pulse" />
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
              {productsData?.content.map((product) => (
                <ProductCard key={product.id} product={product} />
              ))}
            </div>
          )}
        </div>
      </section>
    </MainLayout>
  )
}
