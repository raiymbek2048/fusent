'use client'

import { useCurrentUser } from '@/hooks/useAuth'
import { useAuthStore } from '@/store/authStore'
import { useEffect } from 'react'

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const { data: user, isLoading, isError } = useCurrentUser()
  const setUser = useAuthStore((state) => state.setUser)
  const setLoading = useAuthStore((state) => state.setLoading)

  useEffect(() => {
    setLoading(isLoading)
  }, [isLoading, setLoading])

  useEffect(() => {
    if (!isLoading) {
      if (isError || !user) {
        setUser(null)
      } else {
        setUser(user)
      }
    }
  }, [user, isLoading, isError, setUser])

  return <>{children}</>
}
