package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "analytics_event", indexes = {
    @Index(name = "idx_analytics_event_type", columnList = "event_type"),
    @Index(name = "idx_analytics_user", columnList = "user_id"),
    @Index(name = "idx_analytics_target", columnList = "target_type, target_id"),
    @Index(name = "idx_analytics_owner", columnList = "owner_type, owner_id"),
    @Index(name = "idx_analytics_created", columnList = "created_at")
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class AnalyticsEvent {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "event_type", nullable = false, length = 50)
    private String eventType;

    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "target_type", length = 30)
    private String targetType;

    @Column(name = "target_id")
    private UUID targetId;

    @Column(name = "owner_type", length = 30)
    private String ownerType;

    @Column(name = "owner_id")
    private UUID ownerId;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "event_data", columnDefinition = "jsonb")
    private String eventData;

    @Column(name = "session_id", length = 100)
    private String sessionId;

    @Column(name = "device_type", length = 20)
    private String deviceType;

    @Column(name = "platform", length = 20)
    private String platform;

    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    @Column(name = "country", length = 2)
    private String country;

    @Column(name = "city", length = 100)
    private String city;

    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;
}
