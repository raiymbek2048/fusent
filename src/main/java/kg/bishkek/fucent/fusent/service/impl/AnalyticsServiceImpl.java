package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.AnalyticsDtos.*;
import kg.bishkek.fucent.fusent.model.AnalyticEventRaw;
import kg.bishkek.fucent.fusent.model.ProductMetricDaily;
import kg.bishkek.fucent.fusent.model.ShopMetricDaily;
import kg.bishkek.fucent.fusent.repository.*;
import kg.bishkek.fucent.fusent.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnalyticsServiceImpl implements AnalyticsService {
    private final AnalyticEventRawRepository analyticEventRepository;
    private final ShopMetricDailyRepository shopMetricRepository;
    private final ProductMetricDailyRepository productMetricRepository;
    private final ShopRepository shopRepository;
    private final ProductVariantRepository productVariantRepository;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Override
    @Transactional
    public void trackEvent(TrackEventRequest request) {
        var event = AnalyticEventRaw.builder()
            .eventType(request.eventType())
            .userId(request.userId())
            .targetId(request.targetId())
            .targetType(request.targetType())
            .context(request.context())
            .build();

        analyticEventRepository.save(event);

        // Send to Kafka for processing
        kafkaTemplate.send("analytics-events", request);
    }

    @Override
    @Transactional(readOnly = true)
    public ShopMetricDailyResponse getShopMetricsForDay(UUID shopId, LocalDate day) {
        var shop = shopRepository.findById(shopId)
            .orElseThrow(() -> new IllegalArgumentException("Shop not found"));

        var metrics = shopMetricRepository.findByShopAndDay(shop, day)
            .orElse(ShopMetricDaily.builder()
                .shop(shop)
                .day(day)
                .views(0)
                .clicks(0)
                .routeBuilds(0)
                .chatsStarted(0)
                .follows(0)
                .unfollows(0)
                .revenue(BigDecimal.ZERO)
                .build());

        return toShopMetricResponse(metrics);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ShopMetricDailyResponse> getShopMetricsRange(UUID shopId, LocalDate startDate, LocalDate endDate) {
        var shop = shopRepository.findById(shopId)
            .orElseThrow(() -> new IllegalArgumentException("Shop not found"));

        return shopMetricRepository.findByShopAndDayBetween(shop, startDate, endDate).stream()
            .map(this::toShopMetricResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public ShopMetricsSummaryResponse getShopMetricsSummary(UUID shopId, LocalDate startDate, LocalDate endDate) {
        var shop = shopRepository.findById(shopId)
            .orElseThrow(() -> new IllegalArgumentException("Shop not found"));

        var metrics = shopMetricRepository.findByShopAndDayBetween(shop, startDate, endDate);

        long totalViews = metrics.stream().mapToLong(m -> m.getViews() != null ? m.getViews() : 0).sum();
        long totalClicks = metrics.stream().mapToLong(m -> m.getClicks() != null ? m.getClicks() : 0).sum();
        long totalRouteBuilds = metrics.stream().mapToLong(m -> m.getRouteBuilds() != null ? m.getRouteBuilds() : 0).sum();
        long totalChatsStarted = metrics.stream().mapToLong(m -> m.getChatsStarted() != null ? m.getChatsStarted() : 0).sum();
        long totalFollows = metrics.stream().mapToLong(m -> m.getFollows() != null ? m.getFollows() : 0).sum();
        long totalUnfollows = metrics.stream().mapToLong(m -> m.getUnfollows() != null ? m.getUnfollows() : 0).sum();
        BigDecimal totalRevenue = metrics.stream()
            .map(m -> m.getRevenue() != null ? m.getRevenue() : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        long dayCount = metrics.size();
        double avgViewsPerDay = dayCount > 0 ? (double) totalViews / dayCount : 0;
        double conversionRate = totalViews > 0 ? (double) totalClicks / totalViews * 100 : 0;

        return new ShopMetricsSummaryResponse(
            shopId,
            shop.getName(),
            startDate,
            endDate,
            totalViews,
            totalClicks,
            totalRouteBuilds,
            totalChatsStarted,
            totalFollows,
            totalUnfollows,
            totalRevenue,
            avgViewsPerDay,
            conversionRate
        );
    }

    @Override
    @Transactional(readOnly = true)
    public ProductMetricDailyResponse getProductMetricsForDay(UUID variantId, LocalDate day) {
        var variant = productVariantRepository.findById(variantId)
            .orElseThrow(() -> new IllegalArgumentException("Product variant not found"));

        var metrics = productMetricRepository.findByVariantAndDay(variant, day)
            .orElse(ProductMetricDaily.builder()
                .variant(variant)
                .day(day)
                .views(0)
                .clicks(0)
                .addToCart(0)
                .orders(0)
                .revenue(BigDecimal.ZERO)
                .build());

        return toProductMetricResponse(metrics);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProductMetricDailyResponse> getProductMetricsRange(UUID variantId, LocalDate startDate, LocalDate endDate) {
        var variant = productVariantRepository.findById(variantId)
            .orElseThrow(() -> new IllegalArgumentException("Product variant not found"));

        return productMetricRepository.findByVariantAndDayBetween(variant, startDate, endDate).stream()
            .map(this::toProductMetricResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProductMetricDailyResponse> getTopProducts(UUID shopId, LocalDate startDate, LocalDate endDate, String sortBy, Integer limit) {
        // For now, return empty list - would need complex query to aggregate across variants
        // TODO: Implement aggregation query
        return List.of();
    }

    private ShopMetricDailyResponse toShopMetricResponse(ShopMetricDaily metrics) {
        return new ShopMetricDailyResponse(
            metrics.getId(),
            metrics.getShop().getId(),
            metrics.getShop().getName(),
            metrics.getDay(),
            metrics.getViews(),
            metrics.getClicks(),
            metrics.getRouteBuilds(),
            metrics.getChatsStarted(),
            metrics.getFollows(),
            metrics.getUnfollows(),
            metrics.getRevenue(),
            metrics.getCreatedAt()
        );
    }

    private ProductMetricDailyResponse toProductMetricResponse(ProductMetricDaily metrics) {
        return new ProductMetricDailyResponse(
            metrics.getId(),
            metrics.getVariant().getId(),
            metrics.getVariant().getProduct().getName(),
            metrics.getVariant().getSku(),
            metrics.getDay(),
            metrics.getViews(),
            metrics.getClicks(),
            metrics.getAddToCart(),
            metrics.getOrders(),
            metrics.getRevenue(),
            metrics.getCreatedAt()
        );
    }
}
