package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import kg.bishkek.fucent.fusent.enums.NotificationChannel;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "notification_pref",
    uniqueConstraints = @UniqueConstraint(name = "uq_notif_pref", columnNames = {"owner_type", "owner_id", "channel"}),
    indexes = {
        @Index(name = "idx_notif_pref_owner", columnList = "owner_type, owner_id")
    }
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class NotificationPref {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "owner_type", nullable = false, length = 20)
    private String ownerType; // user, shop, merchant

    @Column(name = "owner_id", nullable = false)
    private UUID ownerId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private NotificationChannel channel;

    @Builder.Default
    private Boolean enabled = true;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "quiet_hours", columnDefinition = "jsonb")
    private Map<String, Object> quietHours;

    @Column(length = 10)
    @Builder.Default
    private String locale = "ru";

    @Column(columnDefinition = "text[]")
    private String[] categories;

    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private Instant updatedAt;
}
