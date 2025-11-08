package kg.bishkek.fucent.fusent.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import kg.bishkek.fucent.fusent.dto.AnalyticsDtos.TrackEventRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class AnalyticsEventConsumer {
    private final ObjectMapper objectMapper;

    @KafkaListener(topics = "analytics-events", groupId = "analytics-processor")
    public void consumeAnalyticsEvent(String message) {
        try {
            TrackEventRequest event = objectMapper.readValue(message, TrackEventRequest.class);
            log.info("Processing analytics event: type={}, userId={}, targetId={}, targetType={}",
                event.eventType(), event.userId(), event.targetId(), event.targetType());

            // TODO: Aggregate metrics and update daily tables
            // This would be implemented based on event type:
            // - "shop_view" -> increment shop_metric_daily.views
            // - "product_view" -> increment product_metric_daily.views
            // - "product_click" -> increment product_metric_daily.clicks
            // - "add_to_cart" -> increment product_metric_daily.add_to_cart
            // etc.

        } catch (Exception e) {
            log.error("Error processing analytics event: {}", message, e);
        }
    }
}
