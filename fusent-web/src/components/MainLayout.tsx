'use client'

import { usePathname } from 'next/navigation'
import Header from './Header'
import Footer from './Footer'
import BottomNavigation from './BottomNavigation'

export default function MainLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()

  // Pages where bottom navigation should be shown (Instagram-like pages)
  const showBottomNav = ['/feed', '/products', '/chat', '/cart', '/profile'].includes(pathname)

  // Pages where header should be hidden (full-screen feed)
  const hideHeader = pathname === '/feed'

  // Pages where footer should be hidden
  const hideFooter = showBottomNav

  return (
    <div className="flex flex-col min-h-screen">
      {!hideHeader && <Header />}
      <main className={`flex-grow ${showBottomNav ? 'pb-16' : ''}`}>
        {children}
      </main>
      {!hideFooter && <Footer />}
      {showBottomNav && <BottomNavigation />}
    </div>
  )
}
