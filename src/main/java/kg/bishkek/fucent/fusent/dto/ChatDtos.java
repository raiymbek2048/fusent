package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;
import java.util.UUID;

public class ChatDtos {

    public record CreateConversationRequest(
        @NotNull UUID recipientId
    ) {}

    public record SendMessageRequest(
        @NotNull UUID recipientId,
        @NotBlank String messageText
    ) {}

    public record ChatMessageResponse(
        UUID id,
        UUID conversationId,
        UUID senderId,
        String senderName,
        UUID recipientId,
        String recipientName,
        String messageText,
        Boolean isRead,
        Boolean isFlagged,
        Instant createdAt
    ) {}

    public record ConversationResponse(
        UUID conversationId,
        UUID otherUserId,
        String otherUserName,
        String lastMessage,
        Instant lastMessageAt,
        Integer unreadCount
    ) {}

    public record MarkAsReadRequest(
        @NotNull UUID messageId
    ) {}

    public record UnreadCountResponse(
        Long unreadCount
    ) {}
}
