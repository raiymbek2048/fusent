package kg.bishkek.fucent.fusent.dto;

import java.math.BigDecimal;
import java.util.List;

public class RouteDtos {

    public record RouteRequest(
        BigDecimal startLat,
        BigDecimal startLon,
        BigDecimal endLat,
        BigDecimal endLon,
        String profile  // car, foot-walking, cycling-regular
    ) {}

    public record RouteResponse(
        List<List<BigDecimal>> coordinates,  // [[lon, lat], [lon, lat], ...]
        Double distance,      // in meters
        Double duration,      // in seconds
        String distanceText,  // formatted distance (e.g., "5.2 км")
        String durationText,  // formatted duration (e.g., "15 мин")
        List<RouteStep> steps
    ) {}

    public record RouteStep(
        String instruction,
        Double distance,
        Double duration
    ) {}
}
