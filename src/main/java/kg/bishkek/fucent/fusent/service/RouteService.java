package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.RouteDtos.RouteRequest;
import kg.bishkek.fucent.fusent.dto.RouteDtos.RouteResponse;

public interface RouteService {
    RouteResponse calculateRoute(RouteRequest request);
}
