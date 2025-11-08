package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "shop_metric_daily",
    uniqueConstraints = @UniqueConstraint(name = "uq_shop_metric_shop_day", columnNames = {"shop_id", "day"}),
    indexes = {
        @Index(name = "idx_shop_metric_shop", columnList = "shop_id"),
        @Index(name = "idx_shop_metric_day", columnList = "day")
    }
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ShopMetricDaily {
    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "shop_id", nullable = false)
    private Shop shop;

    @Column(nullable = false)
    private LocalDate day;

    @Builder.Default
    private Integer views = 0;

    @Builder.Default
    private Integer clicks = 0;

    @Column(name = "route_builds")
    @Builder.Default
    private Integer routeBuilds = 0;

    @Column(name = "chats_started")
    @Builder.Default
    private Integer chatsStarted = 0;

    @Builder.Default
    private Integer follows = 0;

    @Builder.Default
    private Integer unfollows = 0;

    @Column(precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal revenue = BigDecimal.ZERO;

    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;
}
