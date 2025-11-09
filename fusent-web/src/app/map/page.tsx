'use client'

import { useState, useEffect } from 'react'
import MainLayout from '@/components/MainLayout'
import dynamic from 'next/dynamic'
import { useShops } from '@/hooks/useShops'
import { usePublicFeed } from '@/hooks/usePosts'
import { MapPin, Store, Image as ImageIcon, Navigation, X } from 'lucide-react'

// Dynamic import to avoid SSR issues with map libraries
const MapComponent = dynamic(() => import('@/components/MapView'), {
  ssr: false,
  loading: () => (
    <div className="w-full h-full flex items-center justify-center bg-gray-100">
      <div className="text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
        <p className="text-gray-600">Загрузка карты...</p>
      </div>
    </div>
  ),
})

type ViewMode = 'shops' | 'posts' | 'all'

export default function MapPage() {
  const [viewMode, setViewMode] = useState<ViewMode>('all')
  const [selectedShop, setSelectedShop] = useState<any>(null)
  const [selectedPost, setSelectedPost] = useState<any>(null)
  const [userLocation, setUserLocation] = useState<{ lat: number; lon: number } | null>(null)

  const { data: shopsData } = useShops({ page: 0, size: 1000 })
  const { data: postsData } = usePublicFeed({ page: 0, size: 1000 })

  // Get user's current location
  useEffect(() => {
    if ('geolocation' in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setUserLocation({
            lat: position.coords.latitude,
            lon: position.coords.longitude,
          })
        },
        (error) => {
          console.error('Error getting location:', error)
          // Default to Bishkek
          setUserLocation({ lat: 42.8746, lon: 74.5698 })
        }
      )
    } else {
      // Default to Bishkek
      setUserLocation({ lat: 42.8746, lon: 74.5698 })
    }
  }, [])

  // Filter items based on view mode
  const shops = viewMode === 'posts' ? [] : (shopsData?.content || []).filter(shop => shop.lat && shop.lon)
  const posts = viewMode === 'shops' ? [] : (postsData?.content || []).filter(post => post.geoLat && post.geoLon)

  const handleShopClick = (shop: any) => {
    setSelectedShop(shop)
    setSelectedPost(null)
  }

  const handlePostClick = (post: any) => {
    setSelectedPost(post)
    setSelectedShop(null)
  }

  const buildRoute = (lat: number, lon: number) => {
    if (userLocation) {
      // Open in 2GIS or Google Maps
      const url = `https://2gis.kg/routeSearch/rsType/car/from/${userLocation.lon},${userLocation.lat}/to/${lon},${lat}`
      window.open(url, '_blank')
    }
  }

  return (
    <MainLayout>
      <div className="relative h-[calc(100vh-4rem)]">
        {/* Map Controls */}
        <div className="absolute top-4 left-4 z-10 bg-white rounded-lg shadow-lg p-2">
          <div className="flex gap-2">
            <button
              onClick={() => setViewMode('all')}
              className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                viewMode === 'all'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Все
            </button>
            <button
              onClick={() => setViewMode('shops')}
              className={`px-4 py-2 rounded-lg font-medium transition-colors flex items-center gap-2 ${
                viewMode === 'shops'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <Store className="h-4 w-4" />
              Магазины ({shops.length})
            </button>
            <button
              onClick={() => setViewMode('posts')}
              className={`px-4 py-2 rounded-lg font-medium transition-colors flex items-center gap-2 ${
                viewMode === 'posts'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <ImageIcon className="h-4 w-4" />
              Посты ({posts.length})
            </button>
          </div>
        </div>

        {/* Map */}
        <div className="w-full h-full">
          {userLocation && (
            <MapComponent
              center={userLocation}
              shops={shops}
              posts={posts}
              onShopClick={handleShopClick}
              onPostClick={handlePostClick}
            />
          )}
        </div>

        {/* Shop Detail Card */}
        {selectedShop && (
          <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2 w-full max-w-md z-20">
            <div className="bg-white rounded-lg shadow-xl p-6 m-4">
              <div className="flex items-start justify-between mb-4">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    <Store className="h-5 w-5 text-blue-600" />
                    <h3 className="text-lg font-bold text-gray-900">{selectedShop.name}</h3>
                  </div>
                  {selectedShop.address && (
                    <p className="text-sm text-gray-600 mb-2">{selectedShop.address}</p>
                  )}
                  {selectedShop.phone && (
                    <p className="text-sm text-gray-600">{selectedShop.phone}</p>
                  )}
                </div>
                <button
                  onClick={() => setSelectedShop(null)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <X className="h-5 w-5" />
                </button>
              </div>

              <div className="flex gap-2">
                <button
                  onClick={() => buildRoute(selectedShop.lat, selectedShop.lon)}
                  className="flex-1 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center justify-center gap-2"
                >
                  <Navigation className="h-4 w-4" />
                  Маршрут
                </button>
                <a
                  href={`/shops/${selectedShop.id}`}
                  className="flex-1 bg-gray-100 text-gray-900 px-4 py-2 rounded-lg hover:bg-gray-200 transition-colors text-center"
                >
                  Открыть
                </a>
              </div>
            </div>
          </div>
        )}

        {/* Post Detail Card */}
        {selectedPost && (
          <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2 w-full max-w-md z-20">
            <div className="bg-white rounded-lg shadow-xl p-4 m-4">
              <div className="flex items-start justify-between mb-3">
                <div className="flex-1">
                  <h3 className="font-semibold text-gray-900 mb-1">
                    {selectedPost.ownerName || 'Пользователь'}
                  </h3>
                  {selectedPost.text && (
                    <p className="text-sm text-gray-700 line-clamp-2">{selectedPost.text}</p>
                  )}
                </div>
                <button
                  onClick={() => setSelectedPost(null)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <X className="h-5 w-5" />
                </button>
              </div>

              {selectedPost.media && selectedPost.media.length > 0 && (
                <div className="mb-3">
                  <img
                    src={selectedPost.media[0].url}
                    alt=""
                    className="w-full h-40 object-cover rounded-lg"
                  />
                </div>
              )}

              <div className="flex gap-2 text-sm text-gray-600">
                <span>❤️ {selectedPost.likesCount}</span>
                <span>💬 {selectedPost.commentsCount}</span>
              </div>
            </div>
          </div>
        )}

        {/* Legend */}
        <div className="absolute bottom-4 right-4 z-10 bg-white rounded-lg shadow-lg p-4">
          <h4 className="font-semibold text-gray-900 mb-2">Легенда</h4>
          <div className="space-y-2 text-sm">
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-blue-600 rounded-full"></div>
              <span className="text-gray-700">Магазины</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-pink-500 rounded-full"></div>
              <span className="text-gray-700">Посты</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-green-500 rounded-full"></div>
              <span className="text-gray-700">Ваше местоположение</span>
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  )
}
