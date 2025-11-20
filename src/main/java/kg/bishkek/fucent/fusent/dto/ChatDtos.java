package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import kg.bishkek.fucent.fusent.model.MessageType;

import java.time.Instant;
import java.util.UUID;

public class ChatDtos {

    public record CreateConversationRequest(
        @NotNull UUID recipientId
    ) {}

    public record SendMessageRequest(
        @NotNull UUID recipientId,
        String messageText,
        MessageType messageType,
        UUID sharedProductId,
        UUID sharedPostId
    ) {}

    public record ChatMessageResponse(
        UUID id,
        UUID conversationId,
        UUID senderId,
        String senderName,
        UUID recipientId,
        String recipientName,
        String messageText,
        MessageType messageType,
        SharedProductInfo sharedProduct,
        SharedPostInfo sharedPost,
        Boolean isRead,
        Boolean isFlagged,
        Instant createdAt
    ) {}

    public record SharedProductInfo(
        UUID id,
        String name,
        String imageUrl,
        Double price
    ) {}

    public record SharedPostInfo(
        UUID id,
        String caption,
        String imageUrl,
        String shopName
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
