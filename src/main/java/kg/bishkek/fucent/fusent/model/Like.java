package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "\"like\"",
    uniqueConstraints = @UniqueConstraint(name = "uq_like_user_post", columnNames = {"user_id", "post_id"}),
    indexes = {
        @Index(name = "idx_like_post", columnList = "post_id"),
        @Index(name = "idx_like_user", columnList = "user_id"),
        @Index(name = "idx_like_created", columnList = "created_at")
    }
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Like {
    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private AppUser user;

    @ManyToOne(optional = false)
    @JoinColumn(name = "post_id", nullable = false)
    private Post post;

    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;
}
