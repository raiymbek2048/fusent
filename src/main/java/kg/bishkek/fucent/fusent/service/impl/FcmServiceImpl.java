package kg.bishkek.fucent.fusent.service.impl;

import com.google.firebase.messaging.*;
import kg.bishkek.fucent.fusent.dto.FcmTokenDto;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.FcmToken;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.FcmTokenRepository;
import kg.bishkek.fucent.fusent.service.FcmService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class FcmServiceImpl implements FcmService {

    private final FcmTokenRepository fcmTokenRepository;
    private final AppUserRepository appUserRepository;

    @Override
    @Transactional
    public void registerToken(AppUser user, FcmTokenDto.RegisterRequest request) {
        try {
            // Check if token already exists for this device
            var existingToken = fcmTokenRepository.findByUserAndDeviceId(user, request.getDeviceId());

            if (existingToken.isPresent()) {
                // Update existing token
                FcmToken token = existingToken.get();
                token.setToken(request.getToken());
                token.setDeviceType(request.getDeviceType());
                token.setIsActive(true);
                fcmTokenRepository.save(token);
                log.info("Updated FCM token for user: {} device: {}", user.getId(), request.getDeviceId());
            } else {
                // Create new token
                FcmToken token = FcmToken.builder()
                        .token(request.getToken())
                        .user(user)
                        .deviceType(request.getDeviceType())
                        .deviceId(request.getDeviceId())
                        .isActive(true)
                        .build();
                fcmTokenRepository.save(token);
                log.info("Registered new FCM token for user: {} device: {}", user.getId(), request.getDeviceId());
            }
        } catch (Exception e) {
            log.error("Failed to register FCM token for user: {}", user.getId(), e);
        }
    }

    @Override
    @Transactional
    public void unregisterToken(String token) {
        try {
            fcmTokenRepository.deleteByToken(token);
            log.info("Unregistered FCM token: {}", token);
        } catch (Exception e) {
            log.error("Failed to unregister FCM token: {}", token, e);
        }
    }

    @Override
    public void sendNotificationToUser(String userId, FcmTokenDto.NotificationRequest request) {
        try {
            // Get all active tokens for user
            List<FcmToken> tokens = fcmTokenRepository.findByUserIdAndIsActiveTrue(UUID.fromString(userId));

            if (tokens.isEmpty()) {
                log.warn("No active FCM tokens found for user: {}", userId);
                return;
            }

            // Build notification data
            Map<String, String> data = new HashMap<>();
            data.put("type", request.getType());
            if (request.getTargetId() != null) {
                data.put("targetId", request.getTargetId());
            }

            // Send to all devices
            for (FcmToken fcmToken : tokens) {
                try {
                    sendMessage(fcmToken.getToken(), request.getTitle(), request.getBody(), data);
                } catch (Exception e) {
                    log.error("Failed to send notification to token: {}", fcmToken.getToken(), e);
                    // Mark token as inactive if send fails
                    fcmToken.setIsActive(false);
                    fcmTokenRepository.save(fcmToken);
                }
            }

            log.info("Sent notification to user: {} ({} devices)", userId, tokens.size());
        } catch (Exception e) {
            log.error("Failed to send notification to user: {}", userId, e);
        }
    }

    @Override
    public void sendLikeNotification(String targetUserId, String likerName, String postId) {
        FcmTokenDto.NotificationRequest request = FcmTokenDto.NotificationRequest.builder()
                .userId(targetUserId)
                .title("Новый лайк ❤️")
                .body(likerName + " оценил ваш пост")
                .type("LIKE")
                .targetId(postId)
                .build();

        sendNotificationToUser(targetUserId, request);
    }

    @Override
    public void sendCommentNotification(String targetUserId, String commenterName, String postId, String commentText) {
        // Truncate comment text if too long
        String truncatedComment = commentText.length() > 50
                ? commentText.substring(0, 47) + "..."
                : commentText;

        FcmTokenDto.NotificationRequest request = FcmTokenDto.NotificationRequest.builder()
                .userId(targetUserId)
                .title("Новый комментарий 💬")
                .body(commenterName + ": " + truncatedComment)
                .type("COMMENT")
                .targetId(postId)
                .build();

        sendNotificationToUser(targetUserId, request);
    }

    @Override
    public void sendMessageNotification(String targetUserId, String senderName, String conversationId, String messageText) {
        String truncatedMessage = messageText.length() > 50
                ? messageText.substring(0, 47) + "..."
                : messageText;

        FcmTokenDto.NotificationRequest request = FcmTokenDto.NotificationRequest.builder()
                .userId(targetUserId)
                .title(senderName)
                .body(truncatedMessage)
                .type("MESSAGE")
                .targetId(conversationId)
                .build();

        sendNotificationToUser(targetUserId, request);
    }

    @Override
    public void sendFollowerNotification(String targetUserId, String followerName) {
        FcmTokenDto.NotificationRequest request = FcmTokenDto.NotificationRequest.builder()
                .userId(targetUserId)
                .title("Новый подписчик")
                .body(followerName + " подписался на вас")
                .type("FOLLOW")
                .targetId(targetUserId)
                .build();

        sendNotificationToUser(targetUserId, request);
    }

    @Override
    public void sendOrderNotification(String targetUserId, String orderId, String status) {
        String statusText = switch (status) {
            case "CONFIRMED" -> "подтвержден";
            case "SHIPPED" -> "отправлен";
            case "DELIVERED" -> "доставлен";
            case "CANCELLED" -> "отменен";
            default -> "обновлен";
        };

        FcmTokenDto.NotificationRequest request = FcmTokenDto.NotificationRequest.builder()
                .userId(targetUserId)
                .title("Статус заказа")
                .body("Ваш заказ #" + orderId.substring(0, 8) + " " + statusText)
                .type("ORDER")
                .targetId(orderId)
                .build();

        sendNotificationToUser(targetUserId, request);
    }

    /**
     * Send FCM message
     */
    private void sendMessage(String token, String title, String body, Map<String, String> data) throws FirebaseMessagingException {
        // Build notification
        Notification notification = Notification.builder()
                .setTitle(title)
                .setBody(body)
                .build();

        // Build Android config
        AndroidConfig androidConfig = AndroidConfig.builder()
                .setNotification(AndroidNotification.builder()
                        .setColor("#9C27B0") // Purple color
                        .setPriority(AndroidNotification.Priority.HIGH)
                        .build())
                .build();

        // Build iOS config
        ApnsConfig apnsConfig = ApnsConfig.builder()
                .setAps(Aps.builder()
                        .setBadge(1)
                        .setSound("default")
                        .build())
                .build();

        // Build message
        Message message = Message.builder()
                .setToken(token)
                .setNotification(notification)
                .putAllData(data)
                .setAndroidConfig(androidConfig)
                .setApnsConfig(apnsConfig)
                .build();

        // Send
        String response = FirebaseMessaging.getInstance().send(message);
        log.debug("Successfully sent message: {}", response);
    }
}
