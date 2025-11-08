'use client'

import { useCurrentUser } from '@/hooks/useAuth'
import { useAuthStore } from '@/store/authStore'
import { useEffect } from 'react'

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const { data: user, isLoading } = useCurrentUser()
  const setLoading = useAuthStore((state) => state.setLoading)

  useEffect(() => {
    setLoading(isLoading)
  }, [isLoading, setLoading])

  return <>{children}</>
}
