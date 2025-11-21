package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.AnalyticsDtos.*;
import kg.bishkek.fucent.fusent.model.AnalyticsEvent;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.repository.AnalyticsEventRepository;
import kg.bishkek.fucent.fusent.repository.ProductRepository;
import kg.bishkek.fucent.fusent.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Service
@RequiredArgsConstructor
public class AnalyticsServiceImpl implements AnalyticsService {

    private final AnalyticsEventRepository analyticsEventRepository;
    private final ProductRepository productRepository;

    @Override
    public void trackEvent(TrackEventRequest request, UUID userId) {
        AnalyticsEvent event = new AnalyticsEvent();
        event.setEventType(request.eventType());
        event.setUserId(userId);
        event.setTargetType(request.targetType());
        event.setTargetId(request.targetId());
        
        if ("PRODUCT".equals(request.targetType())) {
            Product product = productRepository.findById(request.targetId()).orElse(null);
            if (product != null && product.getShop() != null) {
                event.setOwnerType("MERCHANT");
                event.setOwnerId(product.getShop().getMerchant().getId());
            }
        }
        
        analyticsEventRepository.save(event);
    }

    @Override
    public SellerAnalyticsResponse getSellerAnalytics(UUID merchantId, String period) {
        Instant from = getFromDate(period);
        
        return SellerAnalyticsResponse.builder()
                .totalViews(analyticsEventRepository.countByOwnerAndType("MERCHANT", merchantId, "PRODUCT_VIEW", from) +
                           analyticsEventRepository.countByOwnerAndType("MERCHANT", merchantId, "POST_VIEW", from))
                .uniqueVisitors(analyticsEventRepository.countUniqueVisitors("MERCHANT", merchantId, from))
                .productViews(analyticsEventRepository.countByOwnerAndType("MERCHANT", merchantId, "PRODUCT_VIEW", from))
                .postViews(analyticsEventRepository.countByOwnerAndType("MERCHANT", merchantId, "POST_VIEW", from))
                .addToCartCount(analyticsEventRepository.countByOwnerAndType("MERCHANT", merchantId, "ADD_TO_CART", from))
                .purchaseCount(analyticsEventRepository.countByOwnerAndType("MERCHANT", merchantId, "PURCHASE", from))
                .build();
    }

    @Override
    public ProductAnalyticsResponse getProductAnalytics(UUID productId, String period) {
        Instant from = getFromDate(period);
        
        return ProductAnalyticsResponse.builder()
                .totalViews(analyticsEventRepository.countByOwnerAndType("PRODUCT", productId, "PRODUCT_VIEW", from))
                .uniqueVisitors(analyticsEventRepository.countUniqueVisitors("PRODUCT", productId, from))
                .addToCartCount(analyticsEventRepository.countByOwnerAndType("PRODUCT", productId, "ADD_TO_CART", from))
                .purchaseCount(analyticsEventRepository.countByOwnerAndType("PRODUCT", productId, "PURCHASE", from))
                .build();
    }

    private Instant getFromDate(String period) {
        return switch (period) {
            case "week" -> Instant.now().minus(7, ChronoUnit.DAYS);
            case "month" -> Instant.now().minus(30, ChronoUnit.DAYS);
            case "year" -> Instant.now().minus(365, ChronoUnit.DAYS);
            default -> Instant.now().minus(7, ChronoUnit.DAYS);
        };
    }
}
