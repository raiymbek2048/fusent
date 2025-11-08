package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.ChatDtos.*;
import kg.bishkek.fucent.fusent.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/chat")
@RequiredArgsConstructor
@Tag(name = "Chat", description = "Buyer-seller chat messaging")
public class ChatController {
    private final ChatService chatService;

    @PostMapping("/messages")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Send a chat message")
    public ChatMessageResponse sendMessage(@Valid @RequestBody SendMessageRequest request) {
        return chatService.sendMessage(request);
    }

    @GetMapping("/conversations/{conversationId}/messages")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get messages in a conversation")
    public Page<ChatMessageResponse> getConversation(
        @PathVariable UUID conversationId,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "50") int size
    ) {
        return chatService.getConversation(
            conversationId,
            PageRequest.of(page, size, Sort.by("createdAt").descending())
        );
    }

    @GetMapping("/conversations")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get all conversations for current user")
    public List<ConversationResponse> getConversations() {
        return chatService.getConversations();
    }

    @GetMapping("/conversations/{conversationId}")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get a specific conversation by ID")
    public ConversationResponse getConversationById(@PathVariable UUID conversationId) {
        return chatService.getConversationById(conversationId);
    }

    @PatchMapping("/messages/{messageId}/read")
    @PreAuthorize("isAuthenticated()")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Mark message as read")
    public void markAsRead(@PathVariable UUID messageId) {
        chatService.markAsRead(messageId);
    }

    @GetMapping("/unread-count")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get unread messages count")
    public UnreadCountResponse getUnreadCount() {
        return chatService.getUnreadCount();
    }

    @PostMapping("/messages/{messageId}/flag")
    @PreAuthorize("isAuthenticated()")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Flag message as inappropriate")
    public void flagMessage(@PathVariable UUID messageId) {
        chatService.flagMessage(messageId);
    }
}
