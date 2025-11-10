package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.RouteDtos.RouteRequest;
import kg.bishkek.fucent.fusent.dto.RouteDtos.RouteResponse;
import kg.bishkek.fucent.fusent.dto.RouteDtos.RouteStep;
import kg.bishkek.fucent.fusent.service.RouteService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class RouteServiceImpl implements RouteService {
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${openrouteservice.api.key:}")
    private String apiKey;

    private static final String ORS_API_URL = "https://api.openrouteservice.org/v2/directions/";

    @Override
    public RouteResponse calculateRoute(RouteRequest request) {
        try {
            String profile = request.profile() != null ? request.profile() : "driving-car";
            String url = ORS_API_URL + profile;

            // Build request body
            Map<String, Object> requestBody = Map.of(
                "coordinates", List.of(
                    List.of(request.startLon(), request.startLat()),
                    List.of(request.endLon(), request.endLat())
                )
            );

            // Set headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            if (apiKey != null && !apiKey.isEmpty()) {
                headers.set("Authorization", apiKey);
            }

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

            // Make API call
            log.info("Calling OpenRouteService API: {}", url);
            var response = restTemplate.exchange(url, HttpMethod.POST, entity, Map.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return parseOpenRouteServiceResponse(response.getBody());
            } else {
                log.error("Failed to get route from OpenRouteService: {}", response.getStatusCode());
                throw new RuntimeException("Failed to calculate route");
            }
        } catch (Exception e) {
            log.error("Error calculating route", e);
            throw new RuntimeException("Failed to calculate route: " + e.getMessage(), e);
        }
    }

    private RouteResponse parseOpenRouteServiceResponse(Map<String, Object> responseBody) {
        try {
            List<Map<String, Object>> routes = (List<Map<String, Object>>) responseBody.get("routes");
            if (routes == null || routes.isEmpty()) {
                throw new RuntimeException("No routes found");
            }

            Map<String, Object> route = routes.get(0);
            Map<String, Object> summary = (Map<String, Object>) route.get("summary");
            Map<String, Object> geometry = (Map<String, Object>) route.get("geometry");

            // Get coordinates
            List<List<Object>> coordinates = (List<List<Object>>) geometry.get("coordinates");
            List<List<BigDecimal>> formattedCoordinates = new ArrayList<>();
            for (List<Object> coord : coordinates) {
                List<BigDecimal> point = List.of(
                    new BigDecimal(coord.get(0).toString()),
                    new BigDecimal(coord.get(1).toString())
                );
                formattedCoordinates.add(point);
            }

            // Get distance and duration
            Double distance = ((Number) summary.get("distance")).doubleValue();
            Double duration = ((Number) summary.get("duration")).doubleValue();

            // Format distance
            String distanceText = formatDistance(distance);
            String durationText = formatDuration(duration);

            // Parse steps
            List<RouteStep> steps = parseSteps(route);

            return new RouteResponse(
                formattedCoordinates,
                distance,
                duration,
                distanceText,
                durationText,
                steps
            );
        } catch (Exception e) {
            log.error("Error parsing OpenRouteService response", e);
            throw new RuntimeException("Failed to parse route response: " + e.getMessage(), e);
        }
    }

    private List<RouteStep> parseSteps(Map<String, Object> route) {
        List<RouteStep> steps = new ArrayList<>();
        try {
            List<Map<String, Object>> segments = (List<Map<String, Object>>) route.get("segments");
            if (segments != null) {
                for (Map<String, Object> segment : segments) {
                    List<Map<String, Object>> segmentSteps = (List<Map<String, Object>>) segment.get("steps");
                    if (segmentSteps != null) {
                        for (Map<String, Object> step : segmentSteps) {
                            String instruction = (String) step.get("instruction");
                            Double distance = ((Number) step.get("distance")).doubleValue();
                            Double duration = ((Number) step.get("duration")).doubleValue();
                            steps.add(new RouteStep(instruction, distance, duration));
                        }
                    }
                }
            }
        } catch (Exception e) {
            log.warn("Failed to parse route steps", e);
        }
        return steps;
    }

    private String formatDistance(Double meters) {
        if (meters < 1000) {
            return String.format("%.0f м", meters);
        } else {
            DecimalFormat df = new DecimalFormat("#.#");
            return df.format(meters / 1000) + " км";
        }
    }

    private String formatDuration(Double seconds) {
        long minutes = Math.round(seconds / 60);
        if (minutes < 60) {
            return minutes + " мин";
        } else {
            long hours = minutes / 60;
            long remainingMinutes = minutes % 60;
            if (remainingMinutes == 0) {
                return hours + " ч";
            } else {
                return hours + " ч " + remainingMinutes + " мин";
            }
        }
    }
}
