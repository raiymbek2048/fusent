package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import kg.bishkek.fucent.fusent.enums.NotificationChannel;
import kg.bishkek.fucent.fusent.enums.NotificationStatus;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "notification_log", indexes = {
    @Index(name = "idx_notif_log_status", columnList = "status"),
    @Index(name = "idx_notif_log_created", columnList = "created_at"),
    @Index(name = "idx_notif_log_recipient", columnList = "recipient")
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class NotificationLog {
    @Id
    @GeneratedValue
    private UUID id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private NotificationChannel channel;

    @Column(nullable = false)
    private String recipient;

    @Column(name = "template_key", nullable = false, length = 100)
    private String templateKey;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "payload_json", columnDefinition = "jsonb")
    private Map<String, Object> payloadJson;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private NotificationStatus status = NotificationStatus.QUEUED;

    @Column(length = 50)
    private String provider;

    @Column(name = "provider_ref")
    private String providerRef;

    @Builder.Default
    private Integer attempts = 0;

    @Column(name = "last_error", columnDefinition = "TEXT")
    private String lastError;

    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "delivered_at")
    private Instant deliveredAt;
}
