package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.ChatDtos.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface ChatService {
    ChatMessageResponse sendMessage(SendMessageRequest request);

    Page<ChatMessageResponse> getConversation(UUID conversationId, Pageable pageable);

    List<ConversationResponse> getConversations();

    void markAsRead(UUID messageId);

    UnreadCountResponse getUnreadCount();

    void flagMessage(UUID messageId);
}
