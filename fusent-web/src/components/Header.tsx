'use client'

import Link from 'next/link'
import { useAuthStore } from '@/store/authStore'
import { useCartSummary } from '@/hooks/useCart'
import { useLogout } from '@/hooks/useAuth'
import { User, ShoppingCart, MessageCircle, LogOut, Store, Package, Search, Image, Map, Bookmark } from 'lucide-react'
import NotificationDropdown from '@/components/NotificationDropdown'

export default function Header() {
  const { user, isAuthenticated, isLoading } = useAuthStore()
  const { data: cartSummary } = useCartSummary(user?.id)
  const logoutMutation = useLogout()

  const handleLogout = () => {
    logoutMutation.mutate()
  }

  return (
    <header className="bg-white shadow-sm sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo */}
          <Link href="/" className="flex items-center">
            <ShoppingCart className="h-8 w-8 text-blue-600" />
            <span className="ml-2 text-xl font-bold text-gray-900">
              Fucent
            </span>
          </Link>

          {/* Navigation */}
          <nav className="hidden md:flex space-x-6">
            <Link
              href="/products"
              className="flex items-center text-gray-700 hover:text-blue-600 transition-colors font-medium"
            >
              <Search className="h-4 w-4 mr-1" />
              Каталог
            </Link>
            <Link
              href="/shops"
              className="flex items-center text-gray-700 hover:text-blue-600 transition-colors font-medium"
            >
              <Store className="h-4 w-4 mr-1" />
              Магазины
            </Link>
            <Link
              href="/social"
              className="flex items-center text-gray-700 hover:text-blue-600 transition-colors font-medium"
            >
              <Image className="h-4 w-4 mr-1" />
              Лента
            </Link>
            <Link
              href="/map"
              className="flex items-center text-gray-700 hover:text-blue-600 transition-colors font-medium"
            >
              <Map className="h-4 w-4 mr-1" />
              Карта
            </Link>
            {user && user.role === 'SELLER' && (
              <Link
                href="/seller"
                className="flex items-center text-gray-700 hover:text-blue-600 transition-colors font-medium"
              >
                <Package className="h-4 w-4 mr-1" />
                Панель продавца
              </Link>
            )}
            {user && user.role === 'ADMIN' && (
              <Link
                href="/admin"
                className="flex items-center text-purple-700 hover:text-purple-900 transition-colors font-medium"
              >
                <Package className="h-4 w-4 mr-1" />
                Админ панель
              </Link>
            )}
          </nav>

          {/* User Menu */}
          <div className="flex items-center space-x-4">
            {isLoading ? (
              // Show loading state to prevent flash of unauthenticated content
              <div className="w-32 h-8" />
            ) : isAuthenticated && user ? (
              <>
                {/* Cart */}
                <Link
                  href="/cart"
                  className="relative text-gray-700 hover:text-blue-600 transition-colors"
                  title="Корзина"
                >
                  <ShoppingCart className="h-6 w-6" />
                  {cartSummary && cartSummary.totalItems > 0 && (
                    <span className="absolute -top-2 -right-2 bg-blue-600 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center">
                      {cartSummary.totalItems}
                    </span>
                  )}
                </Link>

                {/* Orders */}
                <Link
                  href="/orders"
                  className="text-gray-700 hover:text-blue-600 transition-colors"
                  title="Мои заказы"
                >
                  <Package className="h-6 w-6" />
                </Link>

                {/* Messages */}
                <Link
                  href="/chat"
                  className="text-gray-700 hover:text-blue-600 transition-colors"
                  title="Сообщения"
                >
                  <MessageCircle className="h-6 w-6" />
                </Link>

                {/* Saved Posts */}
                <Link
                  href="/saved-posts"
                  className="text-gray-700 hover:text-yellow-600 transition-colors"
                  title="Сохраненные"
                >
                  <Bookmark className="h-6 w-6" />
                </Link>

                {/* Notifications */}
                <NotificationDropdown userEmail={user.email} />

                {/* Profile */}
                <div className="flex items-center space-x-3 border-l pl-4 ml-2">
                  <Link
                    href="/profile"
                    className="flex items-center text-gray-700 hover:text-blue-600 transition-colors"
                  >
                    <User className="h-5 w-5 mr-2" />
                    <span className="hidden sm:inline font-medium">
                      {user.profile?.firstName || user.email.split('@')[0]}
                    </span>
                  </Link>

                  <button
                    onClick={handleLogout}
                    className="text-gray-700 hover:text-red-500 transition-colors"
                    title="Выйти"
                  >
                    <LogOut className="h-5 w-5" />
                  </button>
                </div>
              </>
            ) : (
              <div className="flex items-center space-x-4">
                <Link
                  href="/login"
                  className="text-gray-700 hover:text-blue-600 transition-colors font-medium"
                >
                  Войти
                </Link>
                <Link
                  href="/register"
                  className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors font-medium"
                >
                  Регистрация
                </Link>
              </div>
            )}
          </div>
        </div>
      </div>
    </header>
  )
}
