package kg.bishkek.fucent.fusent.model;



import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;


import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;


@Entity
@Table(name = "pos_sale")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PosSale {
    @Id @GeneratedValue
    private UUID id;


    @Column(nullable = false)
    private UUID shopId;


    @ManyToOne(optional = false)
    private ProductVariant variant;


    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal qty;


    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal unitPrice;


    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal totalPrice;


    @CreationTimestamp
    private Instant soldAt;


    @Column(nullable = false)
    private String receiptNumber;
}