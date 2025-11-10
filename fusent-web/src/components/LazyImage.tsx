'use client'

import { useState, useEffect } from 'react'
import { useIntersectionObserver } from '@/hooks/useIntersectionObserver'

interface LazyImageProps {
  src: string
  alt: string
  className?: string
  placeholder?: string
  onLoad?: () => void
  onError?: () => void
}

/**
 * Lazy-loaded image component with placeholder
 */
export function LazyImage({
  src,
  alt,
  className = '',
  placeholder = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200"%3E%3Crect fill="%23f3f4f6" width="200" height="200"/%3E%3C/svg%3E',
  onLoad,
  onError,
}: LazyImageProps) {
  const { targetRef, isIntersecting } = useIntersectionObserver<HTMLImageElement>({
    threshold: 0.1,
    rootMargin: '50px',
  })
  const [imageSrc, setImageSrc] = useState(placeholder)
  const [isLoaded, setIsLoaded] = useState(false)
  const [hasError, setHasError] = useState(false)

  useEffect(() => {
    if (isIntersecting && !isLoaded && !hasError) {
      // Create a new image to preload
      const img = new Image()
      img.src = src

      img.onload = () => {
        setImageSrc(src)
        setIsLoaded(true)
        onLoad?.()
      }

      img.onerror = () => {
        setHasError(true)
        onError?.()
      }
    }
  }, [isIntersecting, src, isLoaded, hasError, onLoad, onError])

  return (
    <img
      ref={targetRef}
      src={imageSrc}
      alt={alt}
      className={`transition-opacity duration-300 ${
        isLoaded ? 'opacity-100' : 'opacity-70'
      } ${className}`}
      loading="lazy"
    />
  )
}
