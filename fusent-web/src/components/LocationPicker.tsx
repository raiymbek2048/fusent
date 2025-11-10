'use client'

import { useEffect, useRef, useState } from 'react'
import { X, MapPin } from 'lucide-react'
import { Button } from '@/components/ui'

interface LocationPickerProps {
  initialLocation?: { lat: number; lon: number }
  onLocationSelect: (location: { lat: number; lon: number }) => void
  onClose: () => void
}

export default function LocationPicker({ initialLocation, onLocationSelect, onClose }: LocationPickerProps) {
  const mapRef = useRef<HTMLDivElement>(null)
  const mapInstanceRef = useRef<any>(null)
  const markerRef = useRef<any>(null)
  const [selectedLocation, setSelectedLocation] = useState<{ lat: number; lon: number } | null>(
    initialLocation || null
  )

  useEffect(() => {
    if (typeof window === 'undefined' || !mapRef.current) return

    const initMap = async () => {
      const L = (await import('leaflet')).default

      // Fix for default marker icons
      delete (L.Icon.Default.prototype as any)._getIconUrl
      L.Icon.Default.mergeOptions({
        iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
        iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
      })

      if (!mapInstanceRef.current && mapRef.current) {
        // Default to Bishkek or user's location
        const defaultCenter = initialLocation || { lat: 42.8746, lon: 74.5698 }

        // Try to get user's current location
        if (!initialLocation && 'geolocation' in navigator) {
          navigator.geolocation.getCurrentPosition(
            (position) => {
              const userLoc = { lat: position.coords.latitude, lon: position.coords.longitude }
              if (mapInstanceRef.current) {
                mapInstanceRef.current.setView([userLoc.lat, userLoc.lon], 13)
              }
            },
            (error) => {
              console.error('Error getting location:', error)
            }
          )
        }

        const map = L.map(mapRef.current).setView([defaultCenter.lat, defaultCenter.lon], 13)

        // Add OpenStreetMap tiles
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          attribution: '© OpenStreetMap contributors',
          maxZoom: 19,
        }).addTo(map)

        // Add initial marker if location provided
        if (initialLocation) {
          const marker = L.marker([initialLocation.lat, initialLocation.lon], {
            draggable: true,
          }).addTo(map)

          marker.on('dragend', () => {
            const pos = marker.getLatLng()
            setSelectedLocation({ lat: pos.lat, lon: pos.lng })
          })

          markerRef.current = marker
        }

        // Add click handler to place/move marker
        map.on('click', (e: any) => {
          const { lat, lng } = e.latlng
          setSelectedLocation({ lat, lon: lng })

          if (markerRef.current) {
            markerRef.current.setLatLng([lat, lng])
          } else {
            const marker = L.marker([lat, lng], {
              draggable: true,
            }).addTo(map)

            marker.on('dragend', () => {
              const pos = marker.getLatLng()
              setSelectedLocation({ lat: pos.lat, lon: pos.lng })
            })

            markerRef.current = marker
          }
        })

        mapInstanceRef.current = map
      }
    }

    initMap()

    return () => {
      if (markerRef.current) {
        markerRef.current.remove()
        markerRef.current = null
      }
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove()
        mapInstanceRef.current = null
      }
    }
  }, [])

  const handleConfirm = () => {
    if (selectedLocation) {
      onLocationSelect(selectedLocation)
      onClose()
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-xl w-full max-w-4xl max-h-[90vh] flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b">
          <div className="flex items-center gap-2">
            <MapPin className="h-6 w-6 text-blue-600" />
            <h2 className="text-xl font-bold text-gray-900">Выберите локацию магазина</h2>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="h-6 w-6" />
          </button>
        </div>

        {/* Instructions */}
        <div className="px-4 py-3 bg-blue-50 border-b">
          <p className="text-sm text-blue-900">
            Нажмите на карту, чтобы выбрать точное местоположение вашего магазина. Вы можете переместить маркер, перетащив его.
          </p>
        </div>

        {/* Map */}
        <div className="flex-1 relative" style={{ minHeight: '400px' }}>
          <div ref={mapRef} className="w-full h-full" />
        </div>

        {/* Selected Location Display */}
        {selectedLocation && (
          <div className="px-4 py-3 bg-gray-50 border-t">
            <p className="text-sm text-gray-700">
              <span className="font-medium">Выбранная локация:</span>{' '}
              {selectedLocation.lat.toFixed(6)}, {selectedLocation.lon.toFixed(6)}
            </p>
          </div>
        )}

        {/* Footer */}
        <div className="flex gap-3 p-4 border-t">
          <Button
            onClick={handleConfirm}
            disabled={!selectedLocation}
            className="flex-1"
          >
            Подтвердить локацию
          </Button>
          <Button
            onClick={onClose}
            variant="outline"
          >
            Отмена
          </Button>
        </div>
      </div>
    </div>
  )
}
