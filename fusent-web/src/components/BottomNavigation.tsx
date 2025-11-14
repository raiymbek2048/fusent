'use client'

import { usePathname, useRouter } from 'next/navigation'
import { Home, Package, MessageCircle, ShoppingCart, User } from 'lucide-react'
import { useAuthStore } from '@/store/authStore'

export default function BottomNavigation() {
  const pathname = usePathname()
  const router = useRouter()
  const { isAuthenticated, user } = useAuthStore()

  const navItems = [
    {
      name: 'Лента',
      href: '/feed',
      icon: Home,
    },
    {
      name: 'Каталог',
      href: '/products',
      icon: Package,
    },
    {
      name: 'Чат',
      href: '/chat',
      icon: MessageCircle,
      requireAuth: true,
    },
    {
      name: 'Корзина',
      href: '/cart',
      icon: ShoppingCart,
      requireAuth: true,
    },
    {
      name: 'Профиль',
      href: '/profile',
      icon: User,
      requireAuth: true,
    },
  ]

  const handleClick = (href: string, requireAuth?: boolean) => {
    if (requireAuth && !isAuthenticated) {
      router.push('/login')
      return
    }
    router.push(href)
  }

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-50 safe-area-bottom">
      <div className="flex justify-around items-center h-16 max-w-screen-xl mx-auto">
        {navItems.map((item) => {
          const Icon = item.icon
          const isActive = pathname === item.href

          return (
            <button
              key={item.name}
              onClick={() => handleClick(item.href, item.requireAuth)}
              className={`flex flex-col items-center justify-center flex-1 h-full transition-colors ${
                isActive
                  ? 'text-blue-600'
                  : 'text-gray-600 hover:text-gray-900'
              }`}
            >
              <Icon className={`h-6 w-6 ${isActive ? 'fill-current' : ''}`} />
              <span className="text-xs mt-1 font-medium">{item.name}</span>
            </button>
          )
        })}
      </div>
    </div>
  )
}
