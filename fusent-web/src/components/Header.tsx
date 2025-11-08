'use client'

import Link from 'next/link'
import { useAuthStore } from '@/store/authStore'
import { useLogout } from '@/hooks/useAuth'
import { User, ShoppingBag, MessageCircle, LogOut, Store } from 'lucide-react'

export default function Header() {
  const { user, isAuthenticated } = useAuthStore()
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
            <ShoppingBag className="h-8 w-8 text-primary-500" />
            <span className="ml-2 text-xl font-bold text-gray-900">
              {process.env.NEXT_PUBLIC_APP_NAME || 'Fusent'}
            </span>
          </Link>

          {/* Navigation */}
          <nav className="hidden md:flex space-x-8">
            <Link
              href="/shops"
              className="text-gray-700 hover:text-primary-500 transition-colors"
            >
              Магазины
            </Link>
            <Link
              href="/feed"
              className="text-gray-700 hover:text-primary-500 transition-colors"
            >
              Лента
            </Link>
          </nav>

          {/* User Menu */}
          <div className="flex items-center space-x-4">
            {isAuthenticated && user ? (
              <>
                {user.role === 'SELLER' && (
                  <Link
                    href="/seller/shops"
                    className="flex items-center text-gray-700 hover:text-primary-500 transition-colors"
                  >
                    <Store className="h-5 w-5 mr-1" />
                    Мои магазины
                  </Link>
                )}

                <Link
                  href="/messages"
                  className="text-gray-700 hover:text-primary-500 transition-colors"
                >
                  <MessageCircle className="h-5 w-5" />
                </Link>

                <div className="flex items-center space-x-3">
                  <Link
                    href="/profile"
                    className="flex items-center text-gray-700 hover:text-primary-500 transition-colors"
                  >
                    <User className="h-5 w-5 mr-2" />
                    <span className="hidden sm:inline">
                      {user.profile?.firstName || user.email}
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
                  className="text-gray-700 hover:text-primary-500 transition-colors"
                >
                  Войти
                </Link>
                <Link
                  href="/register"
                  className="bg-primary-500 text-white px-4 py-2 rounded-lg hover:bg-primary-600 transition-colors"
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
