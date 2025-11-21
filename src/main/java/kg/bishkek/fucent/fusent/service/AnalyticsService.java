package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.AnalyticsDtos.*;
import java.util.UUID;

public interface AnalyticsService {
    void trackEvent(TrackEventRequest request, UUID userId);
    SellerAnalyticsResponse getSellerAnalytics(UUID merchantId, String period);
    ProductAnalyticsResponse getProductAnalytics(UUID productId, String period);
}
