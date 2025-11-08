package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "analytic_event_raw", indexes = {
    @Index(name = "idx_analytic_event_type", columnList = "event_type"),
    @Index(name = "idx_analytic_event_user", columnList = "user_id"),
    @Index(name = "idx_analytic_event_target", columnList = "target_type, target_id"),
    @Index(name = "idx_analytic_event_created", columnList = "created_at")
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class AnalyticEventRaw {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "event_type", nullable = false, length = 50)
    private String eventType;

    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "target_id")
    private UUID targetId;

    @Column(name = "target_type", length = 50)
    private String targetType;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private Map<String, Object> context;

    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;
}
