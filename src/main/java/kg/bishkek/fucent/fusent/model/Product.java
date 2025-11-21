package kg.bishkek.fucent.fusent.model;



import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;


import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;


@Entity
@Table(name = "product")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Product {
    @Id @GeneratedValue
    private UUID id;


    @ManyToOne(optional = false)
    private Shop shop;


    @ManyToOne(optional = false)
    private Category category;


    @Column(nullable = false)
    private String name;


    @Column(length = 4000)
    private String description;

    @Column(name = "image_url", columnDefinition = "TEXT", length = 9000)
    private String imageUrl;

    @Column(name = "base_price", precision = 12, scale = 2)
    private BigDecimal basePrice;

    @Column(name = "is_active")
    @Builder.Default
    private boolean active = true;

    @Column(nullable = false)
    @Builder.Default
    private Boolean blocked = false;

    private Instant blockedAt;

    @Column(length = 500)
    private String blockedReason;

    @CreationTimestamp
    private Instant createdAt;

    @OneToMany(mappedBy = "product", fetch = FetchType.LAZY)
    private List<ProductVariant> variants;

    // Add shopId and categoryId for JSON serialization
    @JsonProperty("shopId")
    public UUID getShopId() {
        return shop != null ? shop.getId() : null;
    }

    @JsonProperty("categoryId")
    public UUID getCategoryId() {
        return category != null ? category.getId() : null;
    }

    // Add stock for JSON serialization (from first/default variant)
    @JsonProperty("stock")
    public Integer getStock() {
        if (variants != null && !variants.isEmpty()) {
            // Create a defensive copy to avoid concurrent modification
            try {
                return variants.get(0).getStockQty();
            } catch (Exception e) {
                return 0;
            }
        }
        return 0;
    }
}