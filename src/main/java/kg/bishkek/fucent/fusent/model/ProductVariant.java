package kg.bishkek.fucent.fusent.model;



import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;


import java.time.Instant;
import java.util.UUID;


@Entity
@Table(name = "product_variant")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ProductVariant {
    @Id @GeneratedValue
    private UUID id;


    @ManyToOne(optional = false)
    private Product product;


    @Column(nullable = false)
    private String sku;


    private String barcode; // required for online purchase later


    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private String attributesJson; // {"size":"42","color":"black"}


    @Column(nullable = false)
    private Double price;


    @Column(nullable = false)
    private Integer stockQty = 0;


    @UpdateTimestamp
    private Instant updatedAt;
}