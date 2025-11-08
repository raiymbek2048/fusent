package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import kg.bishkek.fucent.fusent.enums.NotificationChannel;
import kg.bishkek.fucent.fusent.enums.NotificationStatus;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

public class NotificationDtos {

    // Notification Preferences DTOs
    public record NotificationPrefRequest(
        @NotNull NotificationChannel channel,
        @NotNull Boolean enabled,
        Map<String, Object> quietHours,
        String locale,
        String[] categories
    ) {}

    public record NotificationPrefResponse(
        UUID id,
        String ownerType,
        UUID ownerId,
        NotificationChannel channel,
        Boolean enabled,
        Map<String, Object> quietHours,
        String locale,
        String[] categories,
        Instant createdAt,
        Instant updatedAt
    ) {}

    // Notification Template DTOs
    public record CreateTemplateRequest(
        @NotBlank String templateKey,
        @NotNull NotificationChannel channel,
        @NotBlank String locale,
        String subject,
        @NotBlank String body,
        Integer version
    ) {}

    public record NotificationTemplateResponse(
        UUID id,
        String templateKey,
        NotificationChannel channel,
        String locale,
        String subject,
        String body,
        Integer version,
        Boolean isActive,
        Instant createdAt
    ) {}

    // Send Notification DTOs
    public record SendNotificationRequest(
        @NotNull NotificationChannel channel,
        @NotBlank String recipient,
        @NotBlank String templateKey,
        Map<String, Object> payloadJson
    ) {}

    public record NotificationLogResponse(
        UUID id,
        NotificationChannel channel,
        String recipient,
        String templateKey,
        Map<String, Object> payloadJson,
        NotificationStatus status,
        String provider,
        String providerRef,
        Integer attempts,
        String lastError,
        Instant createdAt,
        Instant deliveredAt
    ) {}

    // Subscription DTOs
    public record SubscriptionResponse(
        UUID id,
        UUID merchantId,
        String merchantName,
        String plan,
        String status,
        Instant trialEndAt,
        Instant currentPeriodStart,
        Instant currentPeriodEnd,
        Boolean autoRenew,
        Instant createdAt,
        Instant updatedAt
    ) {}

    public record UpdateSubscriptionRequest(
        String plan,
        String status,
        Boolean autoRenew
    ) {}
}
