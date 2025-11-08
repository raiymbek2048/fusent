package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;

public class AnalyticsDtos {

    // Shop Metrics DTOs
    public record ShopMetricDailyResponse(
        UUID id,
        UUID shopId,
        String shopName,
        LocalDate day,
        Integer views,
        Integer clicks,
        Integer routeBuilds,
        Integer chatsStarted,
        Integer follows,
        Integer unfollows,
        BigDecimal revenue,
        Instant createdAt
    ) {}

    public record ShopMetricsRangeRequest(
        @NotNull UUID shopId,
        @NotNull LocalDate startDate,
        @NotNull LocalDate endDate
    ) {}

    public record ShopMetricsSummaryResponse(
        UUID shopId,
        String shopName,
        LocalDate startDate,
        LocalDate endDate,
        Long totalViews,
        Long totalClicks,
        Long totalRouteBuilds,
        Long totalChatsStarted,
        Long totalFollows,
        Long totalUnfollows,
        BigDecimal totalRevenue,
        Double avgViewsPerDay,
        Double conversionRate
    ) {}

    // Product Metrics DTOs
    public record ProductMetricDailyResponse(
        UUID id,
        UUID variantId,
        String productName,
        String variantSku,
        LocalDate day,
        Integer views,
        Integer clicks,
        Integer addToCart,
        Integer orders,
        BigDecimal revenue,
        Instant createdAt
    ) {}

    public record ProductMetricsRangeRequest(
        @NotNull UUID variantId,
        @NotNull LocalDate startDate,
        @NotNull LocalDate endDate
    ) {}

    public record TopProductsRequest(
        @NotNull UUID shopId,
        @NotNull LocalDate startDate,
        @NotNull LocalDate endDate,
        String sortBy, // revenue, views, orders
        Integer limit
    ) {
        public TopProductsRequest {
            if (sortBy == null) sortBy = "revenue";
            if (limit == null) limit = 10;
        }
    }

    // Analytic Events DTOs
    public record TrackEventRequest(
        @NotBlank String eventType,
        UUID userId,
        UUID targetId,
        String targetType,
        Map<String, Object> context
    ) {}

    public record AnalyticEventResponse(
        UUID id,
        String eventType,
        UUID userId,
        UUID targetId,
        String targetType,
        Map<String, Object> context,
        Instant createdAt
    ) {}

    // Common Analytics DTOs
    public record DateRangeRequest(
        @NotNull LocalDate startDate,
        @NotNull LocalDate endDate
    ) {}

    public record MetricTrendResponse(
        LocalDate date,
        Long value
    ) {}
}
