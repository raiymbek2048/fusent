package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "ad_event_daily",
    uniqueConstraints = @UniqueConstraint(name = "uq_ad_event_campaign_day", columnNames = {"campaign_id", "day"}),
    indexes = {
        @Index(name = "idx_ad_event_campaign", columnList = "campaign_id"),
        @Index(name = "idx_ad_event_day", columnList = "day")
    }
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class AdEventDaily {
    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "campaign_id", nullable = false)
    private AdCampaign campaign;

    @Column(nullable = false)
    private LocalDate day;

    @Builder.Default
    private Integer impressions = 0;

    @Builder.Default
    private Integer clicks = 0;

    @Column(precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal spend = BigDecimal.ZERO;

    @Column(precision = 12, scale = 4)
    private BigDecimal cpc;

    @Column(precision = 12, scale = 4)
    private BigDecimal cpm;

    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;
}
