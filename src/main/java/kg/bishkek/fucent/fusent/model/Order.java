package kg.bishkek.fucent.fusent.model;



import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;


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


    @Column(nullable = false)
    private String status = "created"; // created|paid|cancelled|fulfilled


    @Column(nullable = false)
    private Double totalAmount;


    @CreationTimestamp
    private Instant createdAt;


    private Instant paidAt;
}