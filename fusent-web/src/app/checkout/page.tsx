'use client'

import { useState, useEffect, useCallback, useRef } from 'react'
import { useRouter } from 'next/navigation'
import Image from 'next/image'
import { useCart } from '@/hooks/useCart'
import { useCheckout } from '@/hooks/useOrders'
import { useAuthStore } from '@/store/authStore'
import { Button, Card, CardContent, Input, LoadingScreen } from '@/components/ui'
import MainLayout from '@/components/MainLayout'
import { Cart } from '@/types'
import { MapPin } from 'lucide-react'
import dynamic from 'next/dynamic'

const LocationPicker = dynamic(() => import('@/components/LocationPicker'), {
  ssr: false,
})

export const dynamic = 'force-dynamic'

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

export default function CheckoutPage() {
  const router = useRouter()
  const user = useAuthStore((state) => state.user)

  const { data: cart, isLoading } = useCart(user?.id) as { data: Cart | undefined, isLoading: boolean }
  const checkout = useCheckout(user?.id)

  const [shippingAddress, setShippingAddress] = useState('')
  const [phone, setPhone] = useState('')
  const [notes, setNotes] = useState('')
  const [paymentMethod, setPaymentMethod] = useState<'cash' | 'card'>('cash')
  const [lat, setLat] = useState<number | undefined>(undefined)
  const [lon, setLon] = useState<number | undefined>(undefined)
  const [showLocationPicker, setShowLocationPicker] = useState(false)
  const [addressSuggestions, setAddressSuggestions] = useState<NominatimResult[]>([])
  const [showSuggestions, setShowSuggestions] = useState(false)
  const [isLoadingSuggestions, setIsLoadingSuggestions] = useState(false)
  const addressInputRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!user) {
      router.push('/login')
    } else if (!isLoading && (!cart || cart.items.length === 0)) {
      router.push('/cart')
    }
  }, [user, cart, isLoading, router])

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

  // Reverse geocoding: get address from coordinates
  const reverseGeocode = async (latitude: number, longitude: number) => {
    try {
      const response = await fetch(
        `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitude}&addressdetails=1&accept-language=ru`
      )
      const data = await response.json()
      if (data.display_name) {
        setShippingAddress(data.display_name)
      }
    } catch (error) {
      console.error('Error reverse geocoding:', error)
    }
  }

  const handleLocationSelect = (location: { lat: number; lon: number }) => {
    setLat(location.lat)
    setLon(location.lon)
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
    setShippingAddress(value)
    debouncedSearch(value)
  }

  const handleSuggestionClick = (suggestion: NominatimResult) => {
    setShippingAddress(suggestion.display_name)
    setLat(parseFloat(suggestion.lat))
    setLon(parseFloat(suggestion.lon))
    setShowSuggestions(false)
    setAddressSuggestions([])
  }

  if (!user) {
    return <LoadingScreen message="Перенаправление..." />
  }

  if (isLoading) {
    return <LoadingScreen message="Загрузка..." />
  }

  if (!cart || cart.items.length === 0) {
    return <LoadingScreen message="Перенаправление..." />
  }

  // Group items by shop
  const itemsByShop = cart.items.reduce((acc, item) => {
    if (!acc[item.shopId]) {
      acc[item.shopId] = {
        shopId: item.shopId,
        shopName: item.shopName,
        items: [],
        total: 0,
      }
    }
    acc[item.shopId].items.push(item)
    acc[item.shopId].total += item.subtotal
    return acc
  }, {} as Record<string, { shopId: string; shopName: string; items: typeof cart.items; total: number }>)

  const handleCheckout = async (shopId: string) => {
    if (!shippingAddress.trim()) {
      alert('Укажите адрес доставки')
      return
    }

    if (!phone.trim()) {
      alert('Укажите номер телефона')
      return
    }

    checkout.mutate({
      shopId,
      shippingAddress: `${shippingAddress}\nТелефон: ${phone}`,
      paymentMethod,
      notes: notes || undefined,
    })
  }

  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-6">
          Оформление заказа
        </h1>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Checkout Form */}
          <div className="lg:col-span-2 space-y-6">
            {/* Delivery Info */}
            <Card>
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-xl font-semibold">Информация о доставке</h2>
              </div>
              <CardContent className="space-y-4">
                <div className="relative" ref={addressInputRef}>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Адрес доставки <span className="text-red-500">*</span>
                  </label>
                  <div className="relative">
                    <Input
                      placeholder="Начните вводить адрес..."
                      value={shippingAddress}
                      onChange={handleAddressChange}
                      required
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

                {/* Location display */}
                {lat && lon && (
                  <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                    <div className="flex items-center gap-2">
                      <MapPin className="h-5 w-5 text-green-600" />
                      <div>
                        <p className="text-sm font-medium text-green-900">Локация установлена</p>
                        <p className="text-xs text-green-700">
                          Координаты: {lat.toFixed(6)}, {lon.toFixed(6)}
                        </p>
                      </div>
                    </div>
                  </div>
                )}

                <Input
                  label="Номер телефона"
                  type="tel"
                  placeholder="+996 XXX XXX XXX"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  required
                />
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Комментарий к заказу
                  </label>
                  <textarea
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    rows={3}
                    placeholder="Дополнительная информация..."
                    value={notes}
                    onChange={(e) => setNotes(e.target.value)}
                  />
                </div>
              </CardContent>
            </Card>

            {/* Payment Method */}
            <Card>
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-xl font-semibold">Способ оплаты</h2>
              </div>
              <CardContent className="space-y-3">
                <label className="flex items-center gap-3 p-4 border-2 rounded-lg cursor-pointer hover:bg-gray-50">
                  <input
                    type="radio"
                    name="payment"
                    value="cash"
                    checked={paymentMethod === 'cash'}
                    onChange={(e) => setPaymentMethod(e.target.value as 'cash')}
                    className="w-4 h-4"
                  />
                  <div>
                    <div className="font-medium">Наличными при получении</div>
                    <div className="text-sm text-gray-500">
                      Оплата курьеру при доставке
                    </div>
                  </div>
                </label>
                <label className="flex items-center gap-3 p-4 border-2 rounded-lg cursor-pointer hover:bg-gray-50">
                  <input
                    type="radio"
                    name="payment"
                    value="card"
                    checked={paymentMethod === 'card'}
                    onChange={(e) => setPaymentMethod(e.target.value as 'card')}
                    className="w-4 h-4"
                  />
                  <div>
                    <div className="font-medium">Картой онлайн</div>
                    <div className="text-sm text-gray-500">
                      Visa, MasterCard, МИР
                    </div>
                  </div>
                </label>
              </CardContent>
            </Card>

            {/* Orders by Shop */}
            {Object.values(itemsByShop).map((shop) => (
              <Card key={shop.shopId}>
                <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
                  <h3 className="font-semibold text-gray-900">
                    Заказ из {shop.shopName}
                  </h3>
                </div>
                <CardContent className="divide-y divide-gray-200">
                  {shop.items.map((item) => (
                    <div key={item.id} className="py-3 flex gap-4">
                      <div className="w-16 h-16 bg-gray-100 rounded overflow-hidden flex-shrink-0">
                        {item.productImage && (
                          <Image
                            src={item.productImage}
                            alt={item.productName}
                            width={64}
                            height={64}
                            className="w-full h-full object-cover"
                          />
                        )}
                      </div>
                      <div className="flex-grow">
                        <h4 className="font-medium text-gray-900 text-sm">
                          {item.productName}
                        </h4>
                        <p className="text-xs text-gray-500">{item.variantName}</p>
                        <p className="text-sm text-gray-600 mt-1">
                          {item.price.toLocaleString()} сом × {item.qty}
                        </p>
                      </div>
                      <div className="text-right">
                        <p className="font-semibold text-gray-900">
                          {item.subtotal.toLocaleString()} сом
                        </p>
                      </div>
                    </div>
                  ))}
                </CardContent>
                <div className="px-6 py-4 border-t bg-gray-50">
                  <div className="flex justify-between items-center mb-4">
                    <span className="font-semibold">Итого:</span>
                    <span className="text-xl font-bold">
                      {shop.total.toLocaleString()} сом
                    </span>
                  </div>
                  <Button
                    fullWidth
                    onClick={() => handleCheckout(shop.shopId)}
                    isLoading={checkout.isPending}
                    disabled={!shippingAddress || !phone}
                  >
                    Оформить заказ из {shop.shopName}
                  </Button>
                </div>
              </Card>
            ))}
          </div>

          {/* Order Summary */}
          <div>
            <Card className="sticky top-4">
              <div className="px-6 py-4 border-b border-gray-200">
                <h3 className="font-semibold text-gray-900">Итого по всем заказам</h3>
              </div>
              <CardContent className="space-y-3">
                <div className="flex justify-between text-gray-600">
                  <span>Товары ({cart.totalItems})</span>
                  <span>{cart.totalAmount.toLocaleString()} сом</span>
                </div>
                <div className="flex justify-between text-gray-600">
                  <span>Доставка</span>
                  <span>Бесплатно</span>
                </div>
                <div className="border-t pt-3 flex justify-between text-xl font-bold">
                  <span>К оплате</span>
                  <span>{cart.totalAmount.toLocaleString()} сом</span>
                </div>
              </CardContent>
              <div className="px-6 py-4 border-t bg-gray-50 text-sm text-gray-600">
                <p>
                  Заказы из разных магазинов оформляются отдельно и могут быть доставлены в разное время
                </p>
              </div>
            </Card>
          </div>
        </div>
      </div>

      {/* Location Picker Modal */}
      {showLocationPicker && (
        <LocationPicker
          initialLocation={
            lat && lon
              ? { lat, lon }
              : undefined
          }
          onLocationSelect={handleLocationSelect}
          onClose={() => setShowLocationPicker(false)}
        />
      )}
    </MainLayout>
  )
}
