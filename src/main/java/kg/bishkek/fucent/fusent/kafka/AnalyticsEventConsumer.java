package kg.bishkek.fucent.fusent.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import kg.bishkek.fucent.fusent.dto.AnalyticsDtos.TrackEventRequest;
import kg.bishkek.fucent.fusent.model.ProductMetricDaily;
import kg.bishkek.fucent.fusent.model.ShopMetricDaily;
import kg.bishkek.fucent.fusent.repository.ProductMetricDailyRepository;
import kg.bishkek.fucent.fusent.repository.ProductVariantRepository;
import kg.bishkek.fucent.fusent.repository.ShopMetricDailyRepository;
import kg.bishkek.fucent.fusent.repository.ShopRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;

@Component
@RequiredArgsConstructor
@Slf4j
public class AnalyticsEventConsumer {
    private final ObjectMapper objectMapper;
    private final ShopMetricDailyRepository shopMetricRepository;
    private final ProductMetricDailyRepository productMetricRepository;
    private final ShopRepository shopRepository;
    private final ProductVariantRepository productVariantRepository;

    @KafkaListener(topics = "analytics-events", groupId = "analytics-processor")
    @Transactional
    public void consumeAnalyticsEvent(String message) {
        try {
            TrackEventRequest event = objectMapper.readValue(message, TrackEventRequest.class);
            log.info("Processing analytics event: type={}, userId={}, targetId={}, targetType={}",
                event.eventType(), event.userId(), event.targetId(), event.targetType());

            LocalDate today = LocalDate.now();

            // Process based on event type
            switch (event.eventType().toLowerCase()) {
                case "shop_view" -> incrementShopMetric(event.targetId(), today, "views");
                case "shop_click" -> incrementShopMetric(event.targetId(), today, "clicks");
                case "shop_route_build" -> incrementShopMetric(event.targetId(), today, "routeBuilds");
                case "shop_chat_started" -> incrementShopMetric(event.targetId(), today, "chatsStarted");
                case "shop_follow" -> incrementShopMetric(event.targetId(), today, "follows");
                case "shop_unfollow" -> incrementShopMetric(event.targetId(), today, "unfollows");
                case "product_view" -> incrementProductMetric(event.targetId(), today, "views");
                case "product_click" -> incrementProductMetric(event.targetId(), today, "clicks");
                case "product_add_to_cart" -> incrementProductMetric(event.targetId(), today, "addToCart");
                default -> log.warn("Unknown event type: {}", event.eventType());
            }

        } catch (Exception e) {
            log.error("Error processing analytics event: {}", message, e);
        }
    }

    private void incrementShopMetric(java.util.UUID shopId, LocalDate day, String metricType) {
        var shop = shopRepository.findById(shopId).orElse(null);
        if (shop == null) {
            log.warn("Shop not found: {}", shopId);
            return;
        }

        var metric = shopMetricRepository.findByShopAndDay(shop, day)
            .orElseGet(() -> ShopMetricDaily.builder()
                .shop(shop)
                .day(day)
                .views(0)
                .clicks(0)
                .routeBuilds(0)
                .chatsStarted(0)
                .follows(0)
                .unfollows(0)
                .revenue(BigDecimal.ZERO)
                .build()
            );

        switch (metricType) {
            case "views" -> metric.setViews(metric.getViews() + 1);
            case "clicks" -> metric.setClicks(metric.getClicks() + 1);
            case "routeBuilds" -> metric.setRouteBuilds(metric.getRouteBuilds() + 1);
            case "chatsStarted" -> metric.setChatsStarted(metric.getChatsStarted() + 1);
            case "follows" -> metric.setFollows(metric.getFollows() + 1);
            case "unfollows" -> metric.setUnfollows(metric.getUnfollows() + 1);
        }

        shopMetricRepository.save(metric);
    }

    private void incrementProductMetric(java.util.UUID variantId, LocalDate day, String metricType) {
        var variant = productVariantRepository.findById(variantId).orElse(null);
        if (variant == null) {
            log.warn("Product variant not found: {}", variantId);
            return;
        }

        var metric = productMetricRepository.findByVariantAndDay(variant, day)
            .orElseGet(() -> ProductMetricDaily.builder()
                .variant(variant)
                .day(day)
                .views(0)
                .clicks(0)
                .addToCart(0)
                .orders(0)
                .revenue(BigDecimal.ZERO)
                .build()
            );

        switch (metricType) {
            case "views" -> metric.setViews(metric.getViews() + 1);
            case "clicks" -> metric.setClicks(metric.getClicks() + 1);
            case "addToCart" -> metric.setAddToCart(metric.getAddToCart() + 1);
        }

        productMetricRepository.save(metric);
    }
}
