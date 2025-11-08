package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.ChatDtos.*;
import kg.bishkek.fucent.fusent.model.ChatMessage;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.ChatMessageRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {
    private final ChatMessageRepository chatMessageRepository;
    private final AppUserRepository userRepository;

    @Override
    @Transactional
    public ChatMessageResponse sendMessage(SendMessageRequest request) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var sender = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        var recipient = userRepository.findById(request.recipientId())
            .orElseThrow(() -> new IllegalArgumentException("Recipient not found"));

        // Generate conversation ID (consistent for both users)
        UUID conversationId = generateConversationId(currentUserId, request.recipientId());

        var message = ChatMessage.builder()
            .conversationId(conversationId)
            .sender(sender)
            .recipient(recipient)
            .messageText(request.messageText())
            .isRead(false)
            .isFlagged(false)
            .build();

        message = chatMessageRepository.save(message);
        return toMessageResponse(message);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ChatMessageResponse> getConversation(UUID conversationId, Pageable pageable) {
        return chatMessageRepository.findByConversationIdOrderByCreatedAtDesc(conversationId, pageable)
            .map(this::toMessageResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ConversationResponse> getConversations() {
        var currentUserId = SecurityUtil.currentUserId(userRepository);

        // TODO: Implement proper conversation aggregation
        // This is a simplified version
        return List.of();
    }

    @Override
    @Transactional
    public void markAsRead(UUID messageId) {
        var message = chatMessageRepository.findById(messageId)
            .orElseThrow(() -> new IllegalArgumentException("Message not found"));

        var currentUserId = SecurityUtil.currentUserId(userRepository);
        if (!message.getRecipient().getId().equals(currentUserId)) {
            throw new IllegalArgumentException("You can only mark your own messages as read");
        }

        message.setIsRead(true);
        chatMessageRepository.save(message);
    }

    @Override
    @Transactional(readOnly = true)
    public UnreadCountResponse getUnreadCount() {
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var recipient = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        long count = chatMessageRepository.countByRecipientAndIsReadFalse(recipient);
        return new UnreadCountResponse(count);
    }

    @Override
    @Transactional
    public void flagMessage(UUID messageId) {
        var message = chatMessageRepository.findById(messageId)
            .orElseThrow(() -> new IllegalArgumentException("Message not found"));

        message.setIsFlagged(true);
        chatMessageRepository.save(message);
    }

    private ChatMessageResponse toMessageResponse(ChatMessage message) {
        return new ChatMessageResponse(
            message.getId(),
            message.getConversationId(),
            message.getSender().getId(),
            message.getSender().getEmail(),
            message.getRecipient().getId(),
            message.getRecipient().getEmail(),
            message.getMessageText(),
            message.getIsRead(),
            message.getIsFlagged(),
            message.getCreatedAt()
        );
    }

    private UUID generateConversationId(UUID userId1, UUID userId2) {
        // Generate consistent conversation ID regardless of user order
        String combined = userId1.compareTo(userId2) < 0
            ? userId1.toString() + userId2.toString()
            : userId2.toString() + userId1.toString();

        return UUID.nameUUIDFromBytes(combined.getBytes());
    }
}
