package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "saved_item",
    uniqueConstraints = @UniqueConstraint(name = "uq_saved_item", columnNames = {"user_id", "product_id"}),
    indexes = {
        @Index(name = "idx_saved_item_user", columnList = "user_id"),
        @Index(name = "idx_saved_item_product", columnList = "product_id")
    }
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class SavedItem {
    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private AppUser user;

    @ManyToOne(optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;
}
