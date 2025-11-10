package kg.bishkek.fucent.fusent.controller;

import kg.bishkek.fucent.fusent.dto.ChatDtos.*;
import kg.bishkek.fucent.fusent.service.ChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.security.Principal;

/**
 * WebSocket controller for real-time chat functionality
 * Uses STOMP protocol over WebSocket
 */
@Controller
@RequiredArgsConstructor
@Slf4j
public class WebSocketChatController {
    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;

    /**
     * Handle incoming chat messages via WebSocket
     * Client sends to: /app/chat.sendMessage
     * Message is sent to recipient: /queue/messages/{recipientId}
     */
    @MessageMapping("/chat.sendMessage")
    public void sendMessage(@Payload SendMessageRequest request, Principal principal) {
        try {
            // Save message to database
            ChatMessageResponse message = chatService.sendMessage(request);

            log.info("WebSocket message sent from {} to {}",
                principal.getName(), request.recipientId());

            // Send to recipient's personal queue
            messagingTemplate.convertAndSendToUser(
                request.recipientId().toString(),
                "/queue/messages",
                message
            );

            // Also send back to sender for confirmation
            messagingTemplate.convertAndSendToUser(
                message.senderId().toString(),
                "/queue/messages",
                message
            );
        } catch (Exception e) {
            log.error("Error sending WebSocket message", e);
            // Send error to sender
            messagingTemplate.convertAndSendToUser(
                principal.getName(),
                "/queue/errors",
                new ErrorMessage("Failed to send message: " + e.getMessage())
            );
        }
    }

    /**
     * Handle typing indicator
     * Client sends to: /app/chat.typing
     * Sent to recipient: /queue/typing/{recipientId}
     */
    @MessageMapping("/chat.typing")
    public void typing(@Payload TypingIndicator indicator, Principal principal) {
        messagingTemplate.convertAndSendToUser(
            indicator.recipientId().toString(),
            "/queue/typing",
            new TypingIndicator(
                indicator.conversationId(),
                indicator.recipientId(),
                principal.getName(),
                indicator.isTyping()
            )
        );
    }

    /**
     * Handle mark as read via WebSocket
     * Client sends to: /app/chat.markRead
     */
    @MessageMapping("/chat.markRead")
    public void markAsRead(@Payload MarkAsReadRequest request, Principal principal) {
        try {
            chatService.markAsRead(request.messageId());

            // Notify sender that message was read
            messagingTemplate.convertAndSendToUser(
                principal.getName(),
                "/queue/read-receipts",
                new ReadReceipt(request.messageId(), true)
            );
        } catch (Exception e) {
            log.error("Error marking message as read", e);
        }
    }

    /**
     * DTO for typing indicator
     */
    public record TypingIndicator(
        java.util.UUID conversationId,
        java.util.UUID recipientId,
        String senderName,
        Boolean isTyping
    ) {}

    /**
     * DTO for read receipt
     */
    public record ReadReceipt(
        java.util.UUID messageId,
        Boolean isRead
    ) {}

    /**
     * DTO for error messages
     */
    public record ErrorMessage(
        String message
    ) {}
}
