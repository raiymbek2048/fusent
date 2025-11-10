'use client'

import { useState, useEffect, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { Search, X, TrendingUp } from 'lucide-react'
import { useDebounce } from '@/hooks/useDebounce'
import { Input } from './ui/Input'

interface Product {
  id: string
  name: string
  imageUrl?: string
  price?: number
}

export function SearchBar() {
  const router = useRouter()
  const [query, setQuery] = useState('')
  const [isOpen, setIsOpen] = useState(false)
  const [suggestions, setSuggestions] = useState<Product[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [recentSearches, setRecentSearches] = useState<string[]>([])
  const debouncedQuery = useDebounce(query, 300)
  const searchRef = useRef<HTMLDivElement>(null)

  // Load recent searches from localStorage
  useEffect(() => {
    const saved = localStorage.getItem('recentSearches')
    if (saved) {
      setRecentSearches(JSON.parse(saved))
    }
  }, [])

  // Fetch autocomplete suggestions
  useEffect(() => {
    if (debouncedQuery.length < 2) {
      setSuggestions([])
      return
    }

    const fetchSuggestions = async () => {
      setIsLoading(true)
      try {
        const response = await fetch(
          `${process.env.NEXT_PUBLIC_API_URL}/api/v1/catalog/autocomplete?q=${encodeURIComponent(debouncedQuery)}&size=5`
        )
        const data = await response.json()
        setSuggestions(data.content || [])
      } catch (error) {
        console.error('Error fetching suggestions:', error)
        setSuggestions([])
      } finally {
        setIsLoading(false)
      }
    }

    fetchSuggestions()
  }, [debouncedQuery])

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (searchRef.current && !searchRef.current.contains(event.target as Node)) {
        setIsOpen(false)
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  const handleSearch = (searchQuery: string) => {
    if (!searchQuery.trim()) return

    // Save to recent searches
    const updated = [searchQuery, ...recentSearches.filter(s => s !== searchQuery)].slice(0, 5)
    setRecentSearches(updated)
    localStorage.setItem('recentSearches', JSON.stringify(updated))

    // Navigate to search results
    router.push(`/products?q=${encodeURIComponent(searchQuery)}`)
    setIsOpen(false)
    setQuery('')
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    handleSearch(query)
  }

  const handleSuggestionClick = (product: Product) => {
    router.push(`/products/${product.id}`)
    setIsOpen(false)
    setQuery('')
  }

  const handleRecentSearchClick = (search: string) => {
    setQuery(search)
    handleSearch(search)
  }

  const clearRecentSearches = () => {
    setRecentSearches([])
    localStorage.removeItem('recentSearches')
  }

  return (
    <div ref={searchRef} className="relative w-full max-w-2xl">
      <form onSubmit={handleSubmit} className="relative">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
          <Input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            onFocus={() => setIsOpen(true)}
            placeholder="Поиск товаров..."
            className="pl-10 pr-10"
          />
          {query && (
            <button
              type="button"
              onClick={() => setQuery('')}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
            >
              <X className="h-5 w-5" />
            </button>
          )}
        </div>
      </form>

      {/* Dropdown */}
      {isOpen && (
        <div className="absolute z-50 mt-2 w-full bg-white rounded-lg shadow-lg border border-gray-200 max-h-96 overflow-y-auto">
          {/* Loading state */}
          {isLoading && (
            <div className="p-4 text-center text-gray-500">
              <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-indigo-600 mx-auto"></div>
            </div>
          )}

          {/* Suggestions */}
          {!isLoading && suggestions.length > 0 && (
            <div className="py-2">
              <div className="px-4 py-2 text-xs font-semibold text-gray-500 uppercase">
                Предложения
              </div>
              {suggestions.map((product) => (
                <button
                  key={product.id}
                  onClick={() => handleSuggestionClick(product)}
                  className="w-full px-4 py-3 hover:bg-gray-50 flex items-center gap-3 text-left transition-colors"
                >
                  {product.imageUrl && (
                    <img
                      src={product.imageUrl}
                      alt={product.name}
                      className="w-10 h-10 object-cover rounded"
                    />
                  )}
                  <div className="flex-1">
                    <div className="font-medium text-gray-900">{product.name}</div>
                    {product.price && (
                      <div className="text-sm text-gray-500">{product.price} сом</div>
                    )}
                  </div>
                  <Search className="h-4 w-4 text-gray-400" />
                </button>
              ))}
            </div>
          )}

          {/* Recent searches */}
          {!isLoading && query.length < 2 && recentSearches.length > 0 && (
            <div className="py-2">
              <div className="px-4 py-2 flex items-center justify-between">
                <div className="text-xs font-semibold text-gray-500 uppercase flex items-center gap-2">
                  <TrendingUp className="h-4 w-4" />
                  Недавние поиски
                </div>
                <button
                  onClick={clearRecentSearches}
                  className="text-xs text-indigo-600 hover:text-indigo-700"
                >
                  Очистить
                </button>
              </div>
              {recentSearches.map((search, index) => (
                <button
                  key={index}
                  onClick={() => handleRecentSearchClick(search)}
                  className="w-full px-4 py-2 hover:bg-gray-50 flex items-center gap-3 text-left transition-colors"
                >
                  <Search className="h-4 w-4 text-gray-400" />
                  <span className="text-gray-700">{search}</span>
                </button>
              ))}
            </div>
          )}

          {/* No results */}
          {!isLoading && query.length >= 2 && suggestions.length === 0 && (
            <div className="p-4 text-center text-gray-500">
              Ничего не найдено для "{query}"
            </div>
          )}
        </div>
      )}
    </div>
  )
}
