'use client'

import { useState, useEffect } from 'react'
import { useCalculateRoute, RouteResponse, RouteStep } from '@/hooks/useRoutes'
import { Navigation, X, MapPin, Clock, Ruler, Car, PersonStanding, Bike, ChevronDown, ChevronUp } from 'lucide-react'
import Spinner from '@/components/ui/Spinner'

interface RoutePanelProps {
  startLat: number
  startLon: number
  endLat: number
  endLon: number
  destinationName?: string
  onClose: () => void
  onRouteCalculated?: (route: RouteResponse) => void
}

export default function RoutePanel({
  startLat,
  startLon,
  endLat,
  endLon,
  destinationName = 'Пункт назначения',
  onClose,
  onRouteCalculated,
}: RoutePanelProps) {
  const [profile, setProfile] = useState<'driving-car' | 'foot-walking' | 'cycling-regular'>('driving-car')
  const [showDirections, setShowDirections] = useState(false)
  const calculateRoute = useCalculateRoute()

  useEffect(() => {
    // Auto-calculate route when component mounts or profile changes
    calculateRoute.mutate(
      {
        startLat,
        startLon,
        endLat,
        endLon,
        profile,
      },
      {
        onSuccess: (data) => {
          onRouteCalculated?.(data)
        },
      }
    )
  }, [startLat, startLon, endLat, endLon, profile])

  const profileIcons = {
    'driving-car': Car,
    'foot-walking': PersonStanding,
    'cycling-regular': Bike,
  }

  const profileLabels = {
    'driving-car': 'Авто',
    'foot-walking': 'Пешком',
    'cycling-regular': 'Велосипед',
  }

  const ProfileIcon = profileIcons[profile]

  return (
    <div className="absolute top-20 left-4 z-20 w-96 max-h-[calc(100vh-6rem)] overflow-hidden bg-white rounded-lg shadow-xl flex flex-col">
      {/* Header */}
      <div className="px-4 py-3 border-b border-gray-200 flex items-center justify-between bg-blue-50">
        <div className="flex items-center space-x-2">
          <Navigation className="h-5 w-5 text-blue-600" />
          <h3 className="font-semibold text-gray-900">Маршрут</h3>
        </div>
        <button
          onClick={onClose}
          className="text-gray-400 hover:text-gray-600 transition-colors"
        >
          <X className="h-5 w-5" />
        </button>
      </div>

      {/* Route Info */}
      <div className="px-4 py-3 border-b border-gray-200 bg-gray-50">
        <div className="flex items-start space-x-3 text-sm">
          <div className="flex-shrink-0 mt-1">
            <div className="w-3 h-3 bg-green-500 rounded-full mb-2"></div>
            <div className="w-0.5 h-6 bg-gray-300 mx-auto"></div>
            <div className="w-3 h-3 bg-red-500 rounded-full mt-2"></div>
          </div>
          <div className="flex-1">
            <p className="text-gray-600 mb-1">Ваше местоположение</p>
            <div className="h-6"></div>
            <p className="text-gray-900 font-medium mt-1">{destinationName}</p>
          </div>
        </div>
      </div>

      {/* Profile Selector */}
      <div className="px-4 py-3 border-b border-gray-200">
        <div className="flex gap-2">
          {(['driving-car', 'foot-walking', 'cycling-regular'] as const).map((p) => {
            const Icon = profileIcons[p]
            return (
              <button
                key={p}
                onClick={() => setProfile(p)}
                className={`flex-1 flex flex-col items-center gap-1 px-3 py-2 rounded-lg transition-colors ${
                  profile === p
                    ? 'bg-blue-100 text-blue-600 border-2 border-blue-600'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
              >
                <Icon className="h-5 w-5" />
                <span className="text-xs font-medium">{profileLabels[p]}</span>
              </button>
            )
          })}
        </div>
      </div>

      {/* Route Stats */}
      {calculateRoute.isPending ? (
        <div className="px-4 py-8 flex flex-col items-center justify-center">
          <Spinner />
          <p className="text-sm text-gray-600 mt-4">Расчет маршрута...</p>
        </div>
      ) : calculateRoute.isError ? (
        <div className="px-4 py-6 text-center">
          <p className="text-red-500 text-sm mb-3">Не удалось построить маршрут</p>
          <button
            onClick={() =>
              calculateRoute.mutate({
                startLat,
                startLon,
                endLat,
                endLon,
                profile,
              })
            }
            className="px-4 py-2 bg-blue-600 text-white text-sm rounded-lg hover:bg-blue-700"
          >
            Попробовать снова
          </button>
        </div>
      ) : calculateRoute.data ? (
        <>
          <div className="px-4 py-3 border-b border-gray-200">
            <div className="flex items-center justify-around">
              <div className="flex items-center space-x-2">
                <Clock className="h-4 w-4 text-gray-500" />
                <div>
                  <p className="text-xs text-gray-500">Время</p>
                  <p className="text-sm font-semibold text-gray-900">
                    {calculateRoute.data.durationText}
                  </p>
                </div>
              </div>
              <div className="w-px h-10 bg-gray-200"></div>
              <div className="flex items-center space-x-2">
                <Ruler className="h-4 w-4 text-gray-500" />
                <div>
                  <p className="text-xs text-gray-500">Расстояние</p>
                  <p className="text-sm font-semibold text-gray-900">
                    {calculateRoute.data.distanceText}
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Directions Toggle */}
          {calculateRoute.data.steps && calculateRoute.data.steps.length > 0 && (
            <>
              <button
                onClick={() => setShowDirections(!showDirections)}
                className="px-4 py-3 flex items-center justify-between hover:bg-gray-50 transition-colors border-b border-gray-200"
              >
                <span className="text-sm font-medium text-gray-900">
                  Пошаговые инструкции ({calculateRoute.data.steps.length})
                </span>
                {showDirections ? (
                  <ChevronUp className="h-4 w-4 text-gray-500" />
                ) : (
                  <ChevronDown className="h-4 w-4 text-gray-500" />
                )}
              </button>

              {/* Directions List */}
              {showDirections && (
                <div className="flex-1 overflow-y-auto">
                  <div className="px-4 py-2 space-y-3">
                    {calculateRoute.data.steps.map((step, index) => (
                      <div key={index} className="flex items-start space-x-3 text-sm">
                        <div className="flex-shrink-0 w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center text-blue-600 font-semibold text-xs mt-0.5">
                          {index + 1}
                        </div>
                        <div className="flex-1">
                          <p className="text-gray-900">{step.instruction}</p>
                          {step.name && (
                            <p className="text-gray-500 text-xs mt-1">
                              {step.name}
                            </p>
                          )}
                          <p className="text-gray-400 text-xs mt-1">
                            {step.distance < 1000
                              ? `${Math.round(step.distance)} м`
                              : `${(step.distance / 1000).toFixed(1)} км`}
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </>
          )}
        </>
      ) : null}
    </div>
  )
}
