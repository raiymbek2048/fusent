package kg.bishkek.fucent.fusent.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

public class FcmTokenDto {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RegisterRequest {
        private String token;
        private String deviceType; // ANDROID, IOS
        private String deviceId;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UnregisterRequest {
        private String token;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class NotificationRequest {
        private String userId; // Target user
        private String title;
        private String body;
        private String type; // LIKE, COMMENT, MESSAGE, ORDER, FOLLOW
        private String targetId; // postId, messageId, orderId, etc.
    }
}
