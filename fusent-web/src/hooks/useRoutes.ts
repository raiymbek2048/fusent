import { useMutation, UseMutationResult } from '@tanstack/react-query';
import api from '@/lib/api';

export interface RouteStep {
  instruction: string;
  distance: number;
  duration: number;
  name?: string;
  type: string;
}

export interface RouteRequest {
  startLat: number;
  startLon: number;
  endLat: number;
  endLon: number;
  profile?: 'driving-car' | 'foot-walking' | 'cycling-regular';
}

export interface RouteResponse {
  coordinates: [number, number][]; // [lon, lat] pairs
  distance: number; // meters
  duration: number; // seconds
  distanceText: string; // "5.2 км" or "850 м"
  durationText: string; // "15 мин" or "1 ч 20 мин"
  steps: RouteStep[];
}

/**
 * Hook for calculating routes using OpenRouteService
 */
export function useCalculateRoute(): UseMutationResult<RouteResponse, Error, RouteRequest> {
  return useMutation({
    mutationFn: async (request: RouteRequest) => {
      const { data } = await api.post<RouteResponse>('/routes/calculate', request);
      return data;
    },
  });
}
