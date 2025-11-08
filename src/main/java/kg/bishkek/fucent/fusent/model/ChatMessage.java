package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "chat_message", indexes = {
    @Index(name = "idx_chat_conversation", columnList = "conversation_id"),
    @Index(name = "idx_chat_sender", columnList = "sender_id"),
    @Index(name = "idx_chat_recipient", columnList = "recipient_id"),
    @Index(name = "idx_chat_created", columnList = "created_at")
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ChatMessage {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "conversation_id", nullable = false)
    private UUID conversationId;

    @ManyToOne(optional = false)
    @JoinColumn(name = "sender_id", nullable = false)
    private AppUser sender;

    @ManyToOne(optional = false)
    @JoinColumn(name = "recipient_id", nullable = false)
    private AppUser recipient;

    @Column(name = "message_text", nullable = false, columnDefinition = "TEXT")
    private String messageText;

    @Column(name = "is_read")
    @Builder.Default
    private Boolean isRead = false;

    @Column(name = "is_flagged")
    @Builder.Default
    private Boolean isFlagged = false;

    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;
}
