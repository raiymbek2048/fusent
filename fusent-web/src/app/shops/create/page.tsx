'use client'

import { useState, useCallback, useEffect, useRef } from 'react'
import { useRouter } from 'next/navigation'
import MainLayout from '@/components/MainLayout'
import { useCreateShop } from '@/hooks/useShops'
import { useAuthStore } from '@/store/authStore'
import { Button, Input, Textarea } from '@/components/ui'
import { Store, MapPin } from 'lucide-react'
import dynamic from 'next/dynamic'

const LocationPicker = dynamic(() => import('@/components/LocationPicker'), {
  ssr: false,
})

interface NominatimResult {
  place_id: number
  display_name: string
  lat: string
  lon: string
}

// Debounce utility function
function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout | null = null
  return (...args: Parameters<T>) => {
    if (timeout) clearTimeout(timeout)
    timeout = setTimeout(() => func(...args), wait)
  }
}

export default function CreateShopPage() {
  const router = useRouter()
  const user = useAuthStore((state) => state.user)
  const createShopMutation = useCreateShop()

  const [formData, setFormData] = useState({
    name: '',
    description: '',
    address: '',
    phone: '',
    lat: undefined as number | undefined,
    lon: undefined as number | undefined,
  })
  const [showLocationPicker, setShowLocationPicker] = useState(false)
  const [addressSuggestions, setAddressSuggestions] = useState<NominatimResult[]>([])
  const [showSuggestions, setShowSuggestions] = useState(false)
  const [isLoadingSuggestions, setIsLoadingSuggestions] = useState(false)
  const addressInputRef = useRef<HTMLDivElement>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!formData.name.trim() || !user?.id) {
      return
    }

    try {
      const shop = await createShopMutation.mutateAsync({
        name: formData.name,
        description: formData.description || undefined,
        address: formData.address || undefined,
        phone: formData.phone || undefined,
        lat: formData.lat,
        lon: formData.lon,
      })
      router.push(`/shops/${shop.id}`)
    } catch (error) {
      // Error is handled by the mutation
    }
  }

  // Reverse geocoding: get address from coordinates
  const reverseGeocode = async (lat: number, lon: number) => {
    try {
      const response = await fetch(
        `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}&addressdetails=1&accept-language=ru`
      )
      const data = await response.json()
      if (data.display_name) {
        setFormData(prev => ({ ...prev, address: data.display_name }))
      }
    } catch (error) {
      console.error('Error reverse geocoding:', error)
    }
  }

  const handleLocationSelect = (location: { lat: number; lon: number }) => {
    setFormData({ ...formData, lat: location.lat, lon: location.lon })
    // Automatically fill address from coordinates
    reverseGeocode(location.lat, location.lon)
  }

  // Search for address suggestions using Nominatim
  const searchAddress = async (query: string) => {
    if (!query || query.length < 3) {
      setAddressSuggestions([])
      return
    }

    setIsLoadingSuggestions(true)
    try {
      const response = await fetch(
        `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&countrycodes=kg&limit=5&addressdetails=1&accept-language=ru`
      )
      const data: NominatimResult[] = await response.json()
      setAddressSuggestions(data)
      setShowSuggestions(true)
    } catch (error) {
      console.error('Error searching address:', error)
      setAddressSuggestions([])
    } finally {
      setIsLoadingSuggestions(false)
    }
  }

  // Debounced search function
  const debouncedSearch = useCallback(
    debounce((query: string) => searchAddress(query), 500),
    []
  )

  const handleAddressChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value
    setFormData({ ...formData, address: value })
    debouncedSearch(value)
  }

  const handleSuggestionClick = (suggestion: NominatimResult) => {
    setFormData({
      ...formData,
      address: suggestion.display_name,
      lat: parseFloat(suggestion.lat),
      lon: parseFloat(suggestion.lon),
    })
    setShowSuggestions(false)
    setAddressSuggestions([])
  }

  // Close suggestions when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (addressInputRef.current && !addressInputRef.current.contains(event.target as Node)) {
        setShowSuggestions(false)
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  // Redirect if not seller
  if (user && user.role !== 'SELLER') {
    return (
      <MainLayout>
        <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6 text-center">
            <p className="text-yellow-800">Только продавцы могут создавать магазины</p>
          </div>
        </div>
      </MainLayout>
    )
  }

  return (
    <MainLayout>
      <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center mb-6">
            <Store className="h-8 w-8 text-blue-600 mr-3" />
            <h1 className="text-2xl font-bold text-gray-900">Создать магазин</h1>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-2">
                Название магазина <span className="text-red-500">*</span>
              </label>
              <Input
                id="name"
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="Введите название магазина"
                required
              />
            </div>

            <div>
              <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-2">
                Описание
              </label>
              <Textarea
                id="description"
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                placeholder="Опишите ваш магазин"
                rows={4}
              />
            </div>

            <div className="relative" ref={addressInputRef}>
              <label htmlFor="address" className="block text-sm font-medium text-gray-700 mb-2">
                Адрес
              </label>
              <div className="relative">
                <Input
                  id="address"
                  type="text"
                  value={formData.address}
                  onChange={handleAddressChange}
                  placeholder="Начните вводить адрес..."
                  className="pr-20"
                />
                <div className="absolute right-2 top-1/2 transform -translate-y-1/2 flex gap-1 items-center">
                  {isLoadingSuggestions && (
                    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-blue-600"></div>
                  )}
                  <button
                    type="button"
                    onClick={() => setShowLocationPicker(true)}
                    className="p-1.5 text-blue-600 hover:bg-blue-50 rounded-md transition-colors"
                    title="Выбрать на карте"
                  >
                    <MapPin className="h-5 w-5" />
                  </button>
                </div>
              </div>

              {/* Address suggestions dropdown */}
              {showSuggestions && addressSuggestions.length > 0 && (
                <div className="absolute z-50 w-full mt-1 bg-white border border-gray-300 rounded-lg shadow-lg max-h-60 overflow-y-auto">
                  {addressSuggestions.map((suggestion) => (
                    <button
                      key={suggestion.place_id}
                      type="button"
                      onClick={() => handleSuggestionClick(suggestion)}
                      className="w-full text-left px-4 py-3 hover:bg-blue-50 border-b border-gray-100 last:border-b-0 transition-colors"
                    >
                      <div className="flex items-start gap-2">
                        <MapPin className="h-4 w-4 text-gray-400 mt-0.5 flex-shrink-0" />
                        <span className="text-sm text-gray-900">{suggestion.display_name}</span>
                      </div>
                    </button>
                  ))}
                </div>
              )}

              <p className="mt-2 text-sm text-gray-500">
                Введите адрес или нажмите на иконку карты для выбора точного местоположения
              </p>
            </div>

            <div>
              <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-2">
                Телефон
              </label>
              <Input
                id="phone"
                type="tel"
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                placeholder="+996 555 123 456"
              />
            </div>

            {/* Location display */}
            {formData.lat && formData.lon && (
              <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                <div className="flex items-center gap-2">
                  <MapPin className="h-5 w-5 text-green-600" />
                  <div>
                    <p className="text-sm font-medium text-green-900">Локация установлена</p>
                    <p className="text-xs text-green-700">
                      Координаты: {formData.lat.toFixed(6)}, {formData.lon.toFixed(6)}
                    </p>
                  </div>
                </div>
              </div>
            )}

            <div className="flex gap-4">
              <Button
                type="submit"
                disabled={createShopMutation.isPending || !formData.name.trim()}
                className="flex-1"
              >
                {createShopMutation.isPending ? 'Создание...' : 'Создать магазин'}
              </Button>
              <Button
                type="button"
                variant="outline"
                onClick={() => router.back()}
              >
                Отмена
              </Button>
            </div>
          </form>
        </div>
      </div>

      {/* Location Picker Modal */}
      {showLocationPicker && (
        <LocationPicker
          initialLocation={
            formData.lat && formData.lon
              ? { lat: formData.lat, lon: formData.lon }
              : undefined
          }
          onLocationSelect={handleLocationSelect}
          onClose={() => setShowLocationPicker(false)}
        />
      )}
    </MainLayout>
  )
}
