package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.AnalyticsDtos.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface AnalyticsService {
    // Event tracking
    void trackEvent(TrackEventRequest request);

    // Shop metrics
    ShopMetricDailyResponse getShopMetricsForDay(UUID shopId, LocalDate day);

    List<ShopMetricDailyResponse> getShopMetricsRange(UUID shopId, LocalDate startDate, LocalDate endDate);

    ShopMetricsSummaryResponse getShopMetricsSummary(UUID shopId, LocalDate startDate, LocalDate endDate);

    // Product metrics
    ProductMetricDailyResponse getProductMetricsForDay(UUID variantId, LocalDate day);

    List<ProductMetricDailyResponse> getProductMetricsRange(UUID variantId, LocalDate startDate, LocalDate endDate);

    List<ProductMetricDailyResponse> getTopProducts(UUID shopId, LocalDate startDate, LocalDate endDate, String sortBy, Integer limit);
}
