package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.FcmTokenDto;
import kg.bishkek.fucent.fusent.model.AppUser;

public interface FcmService {

    /**
     * Register FCM token for user
     */
    void registerToken(AppUser user, FcmTokenDto.RegisterRequest request);

    /**
     * Unregister FCM token
     */
    void unregisterToken(String token);

    /**
     * Send notification to user
     */
    void sendNotificationToUser(String userId, FcmTokenDto.NotificationRequest request);

    /**
     * Send notification about new like
     */
    void sendLikeNotification(String targetUserId, String likerName, String postId);

    /**
     * Send notification about new comment
     */
    void sendCommentNotification(String targetUserId, String commenterName, String postId, String commentText);

    /**
     * Send notification about new message
     */
    void sendMessageNotification(String targetUserId, String senderName, String conversationId, String messageText);

    /**
     * Send notification about new follower
     */
    void sendFollowerNotification(String targetUserId, String followerName);

    /**
     * Send notification about order status change
     */
    void sendOrderNotification(String targetUserId, String orderId, String status);
}
