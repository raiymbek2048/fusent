package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.NotificationDtos.*;
import kg.bishkek.fucent.fusent.enums.NotificationChannel;

import java.util.List;
import java.util.UUID;

public interface NotificationService {
    // Preferences
    NotificationPrefResponse getPreference(String ownerType, UUID ownerId, NotificationChannel channel);

    List<NotificationPrefResponse> getAllPreferences(String ownerType, UUID ownerId);

    NotificationPrefResponse updatePreference(String ownerType, UUID ownerId, NotificationPrefRequest request);

    // Templates
    NotificationTemplateResponse createTemplate(CreateTemplateRequest request);

    NotificationTemplateResponse getActiveTemplate(String templateKey, NotificationChannel channel, String locale);

    // Sending
    void sendNotification(SendNotificationRequest request);

    List<NotificationLogResponse> getNotificationHistory(String recipient, int page, int size);

    // Reading notifications
    void markAsRead(UUID notificationId);

    void markAllAsRead();

    List<NotificationLogResponse> getUserNotifications(int page, int size);

    Long getUnreadCount();
}
