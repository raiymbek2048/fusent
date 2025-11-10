package kg.bishkek.fucent.fusent.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import kg.bishkek.fucent.fusent.dto.NotificationDtos.SendNotificationRequest;
import kg.bishkek.fucent.fusent.enums.NotificationChannel;
import kg.bishkek.fucent.fusent.enums.NotificationStatus;
import kg.bishkek.fucent.fusent.repository.NotificationLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationEventConsumer {

    private final NotificationLogRepository notificationLogRepository;
    private final ObjectMapper objectMapper;

    @KafkaListener(topics = "notification-events", groupId = "notification-processor")
    @Transactional
    public void consumeNotificationEvent(String message) {
        try {
            log.info("Processing notification event: {}", message);

            // Deserialize JSON to SendNotificationRequest
            SendNotificationRequest request = objectMapper.readValue(message, SendNotificationRequest.class);

            // Find the notification log entry
            var notificationOpt = notificationLogRepository.findByRecipientAndTemplateKeyOrderByCreatedAtDesc(
                    request.recipient(), request.templateKey()
            ).stream().findFirst();

            if (notificationOpt.isEmpty()) {
                log.warn("Notification log not found for recipient: {}, templateKey: {}",
                        request.recipient(), request.templateKey());
                return;
            }

            var notifLog = notificationOpt.get();
            notifLog.setAttempts(notifLog.getAttempts() + 1);

            try {
                // Send notification based on channel
                boolean success = sendNotificationByChannel(request);

                if (success) {
                    notifLog.setStatus(NotificationStatus.DELIVERED);
                    notifLog.setDeliveredAt(java.time.Instant.now());
                    notifLog.setProvider(getProviderName(request.channel()));
                    log.info("Successfully delivered notification to {}: channel={}, template={}",
                            request.recipient(), request.channel(), request.templateKey());
                } else {
                    notifLog.setStatus(NotificationStatus.FAILED);
                    notifLog.setLastError("Failed to send notification");
                }
            } catch (Exception e) {
                notifLog.setStatus(NotificationStatus.FAILED);
                notifLog.setLastError(e.getMessage());
                log.error("Error sending notification: {}", e.getMessage(), e);
            }

            notificationLogRepository.save(notifLog);

        } catch (Exception e) {
            log.error("Error processing notification event: {}", message, e);
        }
    }

    private boolean sendNotificationByChannel(SendNotificationRequest request) {
        return switch (request.channel()) {
            case PUSH -> sendPushNotification(request);
            case SMS -> sendSmsNotification(request);
            case EMAIL -> sendEmailNotification(request);
            case NotificationChannel.IN_APP -> sendInAppNotification(request);
        };
    }

    private boolean sendPushNotification(SendNotificationRequest request) {
        // TODO: Integrate with Firebase Cloud Messaging (FCM) or similar service
        log.info("[PUSH] Sending to {}: {}", request.recipient(), request.templateKey());
        log.info("[PUSH] Payload: {}", request.payloadJson());
        return true; // Simulated success
    }

    private boolean sendSmsNotification(SendNotificationRequest request) {
        // TODO: Integrate with Twilio, AWS SNS, or similar SMS service
        log.info("[SMS] Sending to {}: {}", request.recipient(), request.templateKey());
        log.info("[SMS] Payload: {}", request.payloadJson());
        return true; // Simulated success
    }

    private boolean sendEmailNotification(SendNotificationRequest request) {
        // TODO: Integrate with SendGrid, AWS SES, or similar email service
        log.info("[EMAIL] Sending to {}: {}", request.recipient(), request.templateKey());
        log.info("[EMAIL] Payload: {}", request.payloadJson());
        return true; // Simulated success
    }

    private boolean sendInAppNotification(SendNotificationRequest request) {
        // In-app notifications are stored in database and retrieved by the client
        log.info("[IN_APP] Notification stored for {}: {}", request.recipient(), request.templateKey());
        return true;
    }

    private String getProviderName(NotificationChannel channel) {
        return switch (channel) {
            case PUSH -> "FCM";
            case SMS -> "Twilio";
            case EMAIL -> "SendGrid";
            case NotificationChannel.IN_APP -> "Database";
        };
    }
}
