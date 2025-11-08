package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "product_metric_daily",
    uniqueConstraints = @UniqueConstraint(name = "uq_product_metric_variant_day", columnNames = {"variant_id", "day"}),
    indexes = {
        @Index(name = "idx_product_metric_variant", columnList = "variant_id"),
        @Index(name = "idx_product_metric_day", columnList = "day")
    }
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ProductMetricDaily {
    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "variant_id", nullable = false)
    private ProductVariant variant;

    @Column(nullable = false)
    private LocalDate day;

    @Builder.Default
    private Integer views = 0;

    @Builder.Default
    private Integer clicks = 0;

    @Column(name = "add_to_cart")
    @Builder.Default
    private Integer addToCart = 0;

    @Builder.Default
    private Integer orders = 0;

    @Column(precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal revenue = BigDecimal.ZERO;

    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;
}
