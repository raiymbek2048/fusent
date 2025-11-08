package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import kg.bishkek.fucent.fusent.enums.MediaType;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "post_media", indexes = {
    @Index(name = "idx_post_media_post", columnList = "post_id"),
    @Index(name = "idx_post_media_sort", columnList = "post_id, sort_order")
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PostMedia {
    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "post_id", nullable = false)
    private Post post;

    @Enumerated(EnumType.STRING)
    @Column(name = "media_type", nullable = false, length = 20)
    private MediaType mediaType;

    @Column(nullable = false, length = 1000)
    private String url;

    @Column(name = "thumb_url", length = 1000)
    private String thumbUrl;

    @Column(name = "sort_order")
    @Builder.Default
    private Integer sortOrder = 0;

    @Column(name = "duration_seconds")
    private Integer durationSeconds;

    private Integer width;

    private Integer height;

    @CreationTimestamp
    @Column(name = "created_at")
    private Instant createdAt;
}
