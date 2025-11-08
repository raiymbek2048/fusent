package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "post_place",
    uniqueConstraints = @UniqueConstraint(name = "uq_post_place", columnNames = {"post_id", "place_id"}),
    indexes = {
        @Index(name = "idx_post_place_post", columnList = "post_id"),
        @Index(name = "idx_post_place_place", columnList = "place_id")
    }
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PostPlace {
    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "post_id", nullable = false)
    private Post post;

    @ManyToOne(optional = false)
    @JoinColumn(name = "place_id", nullable = false)
    private Shop place;

    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;
}
