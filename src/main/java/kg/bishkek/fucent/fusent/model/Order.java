package kg.bishkek.fucent.fusent.model;



import jakarta.persistence.*;
import kg.bishkek.fucent.fusent.enums.OrderStatus;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;


import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;


@Entity
@Table(name = "\"order\"")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Order {
    @Id @GeneratedValue
    private UUID id;


    @Column(nullable = false)
    private UUID userId;


    @ManyToOne(optional = false)
    private Shop shop; // only one shop per order


    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private OrderStatus status = OrderStatus.CREATED;


    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount;


    @CreationTimestamp
    private Instant createdAt;


    private Instant paidAt;
}