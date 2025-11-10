package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.RouteDtos.RouteRequest;
import kg.bishkek.fucent.fusent.dto.RouteDtos.RouteResponse;
import kg.bishkek.fucent.fusent.service.RouteService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/routes")
@RequiredArgsConstructor
@Tag(name = "Routes", description = "Route calculation and navigation")
public class RouteController {
    private final RouteService routeService;

    @PostMapping("/calculate")
    @Operation(summary = "Calculate route between two points")
    public RouteResponse calculateRoute(@Valid @RequestBody RouteRequest request) {
        return routeService.calculateRoute(request);
    }
}
