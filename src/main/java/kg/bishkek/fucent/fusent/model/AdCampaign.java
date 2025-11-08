package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import kg.bishkek.fucent.fusent.enums.CampaignStatus;
import kg.bishkek.fucent.fusent.enums.CampaignType;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "ad_campaign", indexes = {
    @Index(name = "idx_ad_campaign_merchant", columnList = "merchant_id"),
    @Index(name = "idx_ad_campaign_status", columnList = "status"),
    @Index(name = "idx_ad_campaign_dates", columnList = "start_date, end_date")
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class AdCampaign {
    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "merchant_id", nullable = false)
    private Merchant merchant;

    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "campaign_type", nullable = false, length = 20)
    private CampaignType campaignType;

    @Column(precision = 12, scale = 2)
    private BigDecimal budget;

    @Column(precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal spent = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private CampaignStatus status = CampaignStatus.DRAFT;

    @Column(name = "start_date")
    private Instant startDate;

    @Column(name = "end_date")
    private Instant endDate;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "targeting_json", columnDefinition = "jsonb")
    private Map<String, Object> targetingJson;

    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private Instant updatedAt;
}
