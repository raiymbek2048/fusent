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

        // Get all messages where current user is involved (optimized query)
        var allMessages = chatMessageRepository.findAllByUserIdInvolved(currentUserId);

        // Group by conversation ID
        var conversationMap = new HashMap<UUID, List<ChatMessage>>();
        for (var message : allMessages) {
            conversationMap
                .computeIfAbsent(message.getConversationId(), k -> new ArrayList<>())
                .add(message);
        }

        // Build conversation responses
        return conversationMap.entrySet().stream()
            .map(entry -> {
                var conversationId = entry.getKey();
                var messages = entry.getValue();

                // Sort by created date descending to get latest message first
                messages.sort((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()));
                var latestMessage = messages.get(0);

                // Determine the other participant
                UUID otherUserId = latestMessage.getSender().getId().equals(currentUserId)
                    ? latestMessage.getRecipient().getId()
                    : latestMessage.getSender().getId();

                var otherUser = userRepository.findById(otherUserId).orElse(null);
                String otherUserName = otherUser != null ? otherUser.getEmail() : "Unknown";

                // Count unread messages in this conversation (optimized query)
                long unreadCount = chatMessageRepository.countUnreadInConversation(conversationId, currentUserId);

                return new ConversationResponse(
                    conversationId,
                    otherUserId,
                    otherUserName,
                    latestMessage.getMessageText(),
                    latestMessage.getCreatedAt(),
                    (int) unreadCount
                );
            })
            .sorted((a, b) -> b.lastMessageAt().compareTo(a.lastMessageAt()))
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public ConversationResponse getConversationById(UUID conversationId) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);

        // Get all messages in this conversation
        var messages = chatMessageRepository.findByConversationIdOrderByCreatedAtDesc(conversationId);

        if (messages.isEmpty()) {
            throw new IllegalArgumentException("Conversation not found");
        }

        // Verify that current user is part of this conversation
        var firstMessage = messages.get(0);
        boolean isParticipant = firstMessage.getSender().getId().equals(currentUserId)
            || firstMessage.getRecipient().getId().equals(currentUserId);

        if (!isParticipant) {
            throw new IllegalArgumentException("You are not a participant in this conversation");
        }

        // Determine the other participant
        UUID otherUserId = firstMessage.getSender().getId().equals(currentUserId)
            ? firstMessage.getRecipient().getId()
            : firstMessage.getSender().getId();

        var otherUser = userRepository.findById(otherUserId)
            .orElseThrow(() -> new IllegalArgumentException("Other user not found"));

        // Count unread messages in this conversation
        long unreadCount = chatMessageRepository.countUnreadInConversation(conversationId, currentUserId);

        return new ConversationResponse(
            conversationId,
            otherUserId,
            otherUser.getEmail(),
            firstMessage.getMessageText(),
            firstMessage.getCreatedAt(),
            unreadCount
        );
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
