package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.ChatDtos.*;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.ChatMessage;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.ChatMessageRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ChatServiceImplTest {

    @Mock
    private ChatMessageRepository chatMessageRepository;

    @Mock
    private AppUserRepository userRepository;

    @InjectMocks
    private ChatServiceImpl chatService;

    private AppUser testSender;
    private AppUser testRecipient;
    private ChatMessage testMessage;
    private UUID conversationId;

    @BeforeEach
    void setUp() {
        testSender = AppUser.builder()
            .id(UUID.randomUUID())
            .email("sender@test.com")
            .build();

        testRecipient = AppUser.builder()
            .id(UUID.randomUUID())
            .email("recipient@test.com")
            .build();

        conversationId = generateConversationId(testSender.getId(), testRecipient.getId());

        testMessage = ChatMessage.builder()
            .id(UUID.randomUUID())
            .conversationId(conversationId)
            .sender(testSender)
            .recipient(testRecipient)
            .messageText("Hello, how are you?")
            .isRead(false)
            .isFlagged(false)
            .build();
    }

    @Test
    void sendMessage_shouldCreateMessageWithCorrectConversationId() {
        // Given
        SendMessageRequest request = new SendMessageRequest(
            testRecipient.getId(),
            "Hello!",
            null,
            null,
            null
        );

        when(userRepository.findById(testSender.getId())).thenReturn(Optional.of(testSender));
        when(userRepository.findById(testRecipient.getId())).thenReturn(Optional.of(testRecipient));
        when(chatMessageRepository.save(any(ChatMessage.class))).thenAnswer(invocation -> {
            ChatMessage message = invocation.getArgument(0);
            message.setId(UUID.randomUUID());
            return message;
        });

        // When
        try (MockedStatic<kg.bishkek.fucent.fusent.security.SecurityUtil> mockedSecurity = mockStatic(
            kg.bishkek.fucent.fusent.security.SecurityUtil.class)) {

            mockedSecurity.when(() -> kg.bishkek.fucent.fusent.security.SecurityUtil.currentUserId(any()))
                .thenReturn(testSender.getId());

            ChatMessageResponse response = chatService.sendMessage(request);

            // Then
            assertThat(response).isNotNull();
            assertThat(response.conversationId()).isEqualTo(conversationId);
            assertThat(response.senderId()).isEqualTo(testSender.getId());
            assertThat(response.recipientId()).isEqualTo(testRecipient.getId());
            assertThat(response.messageText()).isEqualTo("Hello!");
            assertThat(response.isRead()).isFalse();

            verify(chatMessageRepository, times(1)).save(any(ChatMessage.class));
        }
    }

    @Test
    void sendMessage_shouldThrowExceptionWhenRecipientNotFound() {
        // Given
        UUID nonExistentRecipientId = UUID.randomUUID();
        SendMessageRequest request = new SendMessageRequest(nonExistentRecipientId, "Hello!", null, null, null);

        when(userRepository.findById(testSender.getId())).thenReturn(Optional.of(testSender));
        when(userRepository.findById(nonExistentRecipientId)).thenReturn(Optional.empty());

        // When & Then
        try (MockedStatic<kg.bishkek.fucent.fusent.security.SecurityUtil> mockedSecurity = mockStatic(
            kg.bishkek.fucent.fusent.security.SecurityUtil.class)) {

            mockedSecurity.when(() -> kg.bishkek.fucent.fusent.security.SecurityUtil.currentUserId(any()))
                .thenReturn(testSender.getId());

            assertThatThrownBy(() -> chatService.sendMessage(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Recipient not found");
        }
    }

    @Test
    void getConversation_shouldReturnPagedMessages() {
        // Given
        List<ChatMessage> messages = List.of(testMessage);
        Page<ChatMessage> messagePage = new PageImpl<>(messages);
        PageRequest pageRequest = PageRequest.of(0, 20);

        when(chatMessageRepository.findByConversationIdOrderByCreatedAtDesc(conversationId, pageRequest))
            .thenReturn(messagePage);

        // When
        Page<ChatMessageResponse> result = chatService.getConversation(conversationId, pageRequest);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getContent()).hasSize(1);
        assertThat(result.getContent().get(0).messageText()).isEqualTo("Hello, how are you?");
    }

    @Test
    void markAsRead_shouldUpdateMessageReadStatus() {
        // Given
        when(chatMessageRepository.findById(testMessage.getId())).thenReturn(Optional.of(testMessage));
        when(chatMessageRepository.save(any(ChatMessage.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // When
        try (MockedStatic<kg.bishkek.fucent.fusent.security.SecurityUtil> mockedSecurity = mockStatic(
            kg.bishkek.fucent.fusent.security.SecurityUtil.class)) {

            mockedSecurity.when(() -> kg.bishkek.fucent.fusent.security.SecurityUtil.currentUserId(any()))
                .thenReturn(testRecipient.getId());

            chatService.markAsRead(testMessage.getId());

            // Then
            verify(chatMessageRepository, times(1)).save(argThat(msg -> msg.getIsRead()));
        }
    }

    @Test
    void markAsRead_shouldThrowExceptionWhenNotRecipient() {
        // Given
        when(chatMessageRepository.findById(testMessage.getId())).thenReturn(Optional.of(testMessage));

        // When & Then
        try (MockedStatic<kg.bishkek.fucent.fusent.security.SecurityUtil> mockedSecurity = mockStatic(
            kg.bishkek.fucent.fusent.security.SecurityUtil.class)) {

            UUID unauthorizedUserId = UUID.randomUUID();
            mockedSecurity.when(() -> kg.bishkek.fucent.fusent.security.SecurityUtil.currentUserId(any()))
                .thenReturn(unauthorizedUserId);

            assertThatThrownBy(() -> chatService.markAsRead(testMessage.getId()))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("You can only mark your own messages as read");
        }
    }

    @Test
    void getUnreadCount_shouldReturnCorrectCount() {
        // Given
        long expectedCount = 5L;
        when(userRepository.findById(testRecipient.getId())).thenReturn(Optional.of(testRecipient));
        when(chatMessageRepository.countByRecipientAndIsReadFalse(testRecipient)).thenReturn(expectedCount);

        // When
        try (MockedStatic<kg.bishkek.fucent.fusent.security.SecurityUtil> mockedSecurity = mockStatic(
            kg.bishkek.fucent.fusent.security.SecurityUtil.class)) {

            mockedSecurity.when(() -> kg.bishkek.fucent.fusent.security.SecurityUtil.currentUserId(any()))
                .thenReturn(testRecipient.getId());

            UnreadCountResponse response = chatService.getUnreadCount();

            // Then
            assertThat(response.unreadCount()).isEqualTo(expectedCount);
        }
    }

    @Test
    void flagMessage_shouldSetFlaggedToTrue() {
        // Given
        when(chatMessageRepository.findById(testMessage.getId())).thenReturn(Optional.of(testMessage));
        when(chatMessageRepository.save(any(ChatMessage.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // When
        chatService.flagMessage(testMessage.getId());

        // Then
        verify(chatMessageRepository, times(1)).save(argThat(msg -> msg.getIsFlagged()));
    }

    @Test
    void getConversations_shouldReturnListOfConversations() {
        // Given
        ChatMessage message1 = ChatMessage.builder()
            .id(UUID.randomUUID())
            .conversationId(conversationId)
            .sender(testSender)
            .recipient(testRecipient)
            .messageText("First message")
            .isRead(false)
            .createdAt(Instant.now().minusSeconds(100))
            .build();

        ChatMessage message2 = ChatMessage.builder()
            .id(UUID.randomUUID())
            .conversationId(conversationId)
            .sender(testRecipient)
            .recipient(testSender)
            .messageText("Second message")
            .isRead(true)
            .createdAt(Instant.now())
            .build();

        when(userRepository.findById(testSender.getId())).thenReturn(Optional.of(testSender));
        when(userRepository.findById(testRecipient.getId())).thenReturn(Optional.of(testRecipient));
        when(chatMessageRepository.findAll()).thenReturn(List.of(message1, message2));

        // When
        try (MockedStatic<kg.bishkek.fucent.fusent.security.SecurityUtil> mockedSecurity = mockStatic(
            kg.bishkek.fucent.fusent.security.SecurityUtil.class)) {

            mockedSecurity.when(() -> kg.bishkek.fucent.fusent.security.SecurityUtil.currentUserId(any()))
                .thenReturn(testSender.getId());

            List<ConversationResponse> conversations = chatService.getConversations();

            // Then
            assertThat(conversations).hasSize(1);
            ConversationResponse conversation = conversations.get(0);
            assertThat(conversation.conversationId()).isEqualTo(conversationId);
            assertThat(conversation.otherUserId()).isEqualTo(testRecipient.getId());
            assertThat(conversation.lastMessage()).isEqualTo("Second message");
            assertThat(conversation.unreadCount()).isEqualTo(1); // Only message1 is unread for sender
        }
    }

    // Helper method to generate conversation ID (same logic as in ChatServiceImpl)
    private UUID generateConversationId(UUID userId1, UUID userId2) {
        String combined = userId1.compareTo(userId2) < 0
            ? userId1.toString() + userId2.toString()
            : userId2.toString() + userId1.toString();
        return UUID.nameUUIDFromBytes(combined.getBytes());
    }
}
