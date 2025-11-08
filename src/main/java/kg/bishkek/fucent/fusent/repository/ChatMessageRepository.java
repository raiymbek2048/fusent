package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.ChatMessage;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, UUID> {
    Page<ChatMessage> findByConversationIdOrderByCreatedAtDesc(UUID conversationId, Pageable pageable);

    List<ChatMessage> findByConversationIdOrderByCreatedAtDesc(UUID conversationId);

    List<ChatMessage> findByRecipientAndIsReadFalse(AppUser recipient);

    long countByRecipientAndIsReadFalse(AppUser recipient);

    @Query("SELECT cm FROM ChatMessage cm WHERE " +
           "(cm.sender.id = :userId OR cm.recipient.id = :userId)")
    List<ChatMessage> findAllByUserIdInvolved(@Param("userId") UUID userId);

    @Query("SELECT COUNT(cm) FROM ChatMessage cm WHERE " +
           "cm.conversationId = :conversationId AND " +
           "cm.recipient.id = :userId AND " +
           "cm.isRead = false")
    long countUnreadInConversation(@Param("conversationId") UUID conversationId, @Param("userId") UUID userId);
}
