package kg.bishkek.fucent.fusent.kafka;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationEventConsumer {

    @KafkaListener(topics = "notification-events", groupId = "notification-processor")
    public void consumeNotificationEvent(String message) {
        try {
            log.info("Processing notification event: {}", message);

            // TODO: Process notification events
            // - Send push notifications
            // - Send SMS
            // - Send emails
            // - Log to notification_log table

        } catch (Exception e) {
            log.error("Error processing notification event: {}", message, e);
        }
    }
}
