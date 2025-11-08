package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "post_tag",
    uniqueConstraints = @UniqueConstraint(name = "uq_post_tag", columnNames = {"post_id", "tag"}),
    indexes = {
        @Index(name = "idx_post_tag_post", columnList = "post_id"),
        @Index(name = "idx_post_tag_tag", columnList = "tag")
    }
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PostTag {
    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "post_id", nullable = false)
    private Post post;

    @Column(nullable = false, length = 100)
    private String tag;

    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;
}
