package kg.bishkek.fucent.fusent.model;



import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;


@Entity
@Table(name = "order_item")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class OrderItem {
    @Id @GeneratedValue
    private UUID id;


    @ManyToOne(optional = false)
    private Order order;


    @ManyToOne(optional = false)
    private ProductVariant variant;


    @Column(nullable = false)
    private Integer qty;


    @Column(nullable = false)
    private Double price;


    @Column(nullable = false)
    private Double subtotal;
}