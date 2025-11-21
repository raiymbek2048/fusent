package kg.bishkek.fucent.fusent.dto;

import lombok.*;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class AnalyticsDtos {

    public record TrackEventRequest(
        String eventType,
        UUID userId,
        String targetType,
        UUID targetId,
        Map<String, Object> eventData
    ) {}

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SellerAnalyticsResponse {
        private long totalViews;
        private long uniqueVisitors;
        private long productViews;
        private long postViews;
        private long addToCartCount;
        private long purchaseCount;
        private List<DailyStats> dailyStats;
        private List<TopProduct> topProducts;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProductAnalyticsResponse {
        private long totalViews;
        private long uniqueVisitors;
        private long addToCartCount;
        private long purchaseCount;
        private List<DailyStats> dailyStats;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyStats {
        private String date;
        private long views;
        private long visitors;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TopProduct {
        private UUID productId;
        private String productName;
        private long views;
    }
}
