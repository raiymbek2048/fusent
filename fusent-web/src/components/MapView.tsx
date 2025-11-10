'use client'

import { useEffect, useRef } from 'react'

interface MapViewProps {
  center: { lat: number; lon: number }
  shops: any[]
  posts: any[]
  onShopClick: (shop: any) => void
  onPostClick: (post: any) => void
  routeCoordinates?: [number, number][] // [lon, lat] pairs from OpenRouteService
}

export default function MapView({ center, shops, posts, onShopClick, onPostClick, routeCoordinates }: MapViewProps) {
  const mapRef = useRef<HTMLDivElement>(null)
  const mapInstanceRef = useRef<any>(null)
  const markersRef = useRef<any[]>([])
  const routeLayerRef = useRef<any>(null)

  useEffect(() => {
    if (typeof window === 'undefined' || !mapRef.current) return

    // Dynamically import Leaflet
    const initMap = async () => {
      const L = (await import('leaflet')).default
      await import('leaflet/dist/leaflet.css')

      // Fix for default marker icons in Leaflet with Next.js
      delete (L.Icon.Default.prototype as any)._getIconUrl
      L.Icon.Default.mergeOptions({
        iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
        iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
      })

      // Initialize map if not already initialized
      if (!mapInstanceRef.current && mapRef.current) {
        const map = L.map(mapRef.current).setView([center.lat, center.lon], 13)

        // Add OpenStreetMap tiles
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          attribution: '© OpenStreetMap contributors',
          maxZoom: 19,
        }).addTo(map)

        // Add user location marker
        const userIcon = L.divIcon({
          className: 'custom-user-marker',
          html: `
            <div style="
              width: 20px;
              height: 20px;
              background: #10b981;
              border: 3px solid white;
              border-radius: 50%;
              box-shadow: 0 2px 4px rgba(0,0,0,0.3);
            "></div>
          `,
          iconSize: [20, 20],
          iconAnchor: [10, 10],
        })

        L.marker([center.lat, center.lon], { icon: userIcon })
          .addTo(map)
          .bindPopup('<b>Вы здесь</b>')

        mapInstanceRef.current = map
      }

      const map = mapInstanceRef.current
      if (!map) return

      // Clear existing markers
      markersRef.current.forEach(marker => marker.remove())
      markersRef.current = []

      // Add shop markers
      shops.forEach(shop => {
        if (shop.lat && shop.lon) {
          const shopIcon = L.divIcon({
            className: 'custom-shop-marker',
            html: `
              <div style="
                width: 30px;
                height: 30px;
                background: #2563eb;
                border: 3px solid white;
                border-radius: 50%;
                box-shadow: 0 2px 6px rgba(0,0,0,0.3);
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 16px;
              ">
                🏪
              </div>
            `,
            iconSize: [30, 30],
            iconAnchor: [15, 15],
          })

          const marker = L.marker([Number(shop.lat), Number(shop.lon)], { icon: shopIcon })
            .addTo(map)
            .bindPopup(`
              <div style="min-width: 200px;">
                <h3 style="font-weight: bold; margin-bottom: 8px;">${shop.name}</h3>
                ${shop.address ? `<p style="font-size: 14px; color: #666; margin-bottom: 4px;">${shop.address}</p>` : ''}
                ${shop.phone ? `<p style="font-size: 14px; color: #666;">${shop.phone}</p>` : ''}
              </div>
            `)

          marker.on('click', () => {
            onShopClick(shop)
          })

          markersRef.current.push(marker)
        }
      })

      // Add post markers
      posts.forEach(post => {
        if (post.geoLat && post.geoLon) {
          const postIcon = L.divIcon({
            className: 'custom-post-marker',
            html: `
              <div style="
                width: 40px;
                height: 40px;
                background: #ec4899;
                border: 3px solid white;
                border-radius: 8px;
                box-shadow: 0 2px 6px rgba(0,0,0,0.3);
                overflow: hidden;
              ">
                ${post.media && post.media.length > 0
                  ? `<img src="${post.media[0].url}" style="width: 100%; height: 100%; object-fit: cover;" />`
                  : '<div style="display: flex; align-items: center; justify-content: center; height: 100%; font-size: 20px;">📸</div>'
                }
              </div>
            `,
            iconSize: [40, 40],
            iconAnchor: [20, 20],
          })

          const marker = L.marker([Number(post.geoLat), Number(post.geoLon)], { icon: postIcon })
            .addTo(map)
            .bindPopup(`
              <div style="min-width: 200px;">
                <h3 style="font-weight: bold; margin-bottom: 8px;">${post.ownerName || 'Пользователь'}</h3>
                ${post.text ? `<p style="font-size: 14px; margin-bottom: 8px;">${post.text.substring(0, 100)}${post.text.length > 100 ? '...' : ''}</p>` : ''}
                <div style="font-size: 12px; color: #666;">
                  ❤️ ${post.likesCount} 💬 ${post.commentsCount}
                </div>
              </div>
            `)

          marker.on('click', () => {
            onPostClick(post)
          })

          markersRef.current.push(marker)
        }
      })

      // Draw route if coordinates are provided
      if (routeLayerRef.current) {
        routeLayerRef.current.remove()
        routeLayerRef.current = null
      }

      if (routeCoordinates && routeCoordinates.length > 0) {
        // Convert [lon, lat] to [lat, lon] for Leaflet
        const latLngs = routeCoordinates.map(coord => [coord[1], coord[0]] as [number, number])

        // Draw route polyline
        const routeLayer = L.polyline(latLngs, {
          color: '#2563eb',
          weight: 5,
          opacity: 0.8,
          lineJoin: 'round',
          lineCap: 'round',
        }).addTo(map)

        routeLayerRef.current = routeLayer

        // Fit map to show the entire route
        const routeBounds = routeLayer.getBounds()
        map.fitBounds(routeBounds, { padding: [80, 80] })
      } else if (shops.length + posts.length > 50) {
        // If we have many markers, fit bounds to show all
        const bounds = L.latLngBounds([])
        markersRef.current.forEach(marker => {
          bounds.extend(marker.getLatLng())
        })
        if (bounds.isValid()) {
          map.fitBounds(bounds, { padding: [50, 50] })
        }
      }
    }

    initMap()

    return () => {
      // Cleanup markers and route on unmount
      markersRef.current.forEach(marker => marker.remove())
      markersRef.current = []
      if (routeLayerRef.current) {
        routeLayerRef.current.remove()
        routeLayerRef.current = null
      }
    }
  }, [center, shops, posts, onShopClick, onPostClick, routeCoordinates])

  return <div ref={mapRef} className="w-full h-full" />
}
