package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import kg.bishkek.fucent.fusent.enums.MediaType;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "media_files", indexes = {
    @Index(name = "idx_media_owner", columnList = "owner_id, owner_type"),
    @Index(name = "idx_media_created", columnList = "created_at")
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MediaFile {
    @Id
    @GeneratedValue
    private UUID id;

    /**
     * ID of the owner entity (User, Product, Post, etc.)
     */
    @Column(name = "owner_id")
    private UUID ownerId;

    /**
     * Type of owner entity: USER, PRODUCT, POST, SHOP, etc.
     */
    @Column(name = "owner_type", length = 50)
    private String ownerType;

    /**
     * Purpose of the media: AVATAR, COVER, PRODUCT_IMAGE, POST_IMAGE, etc.
     */
    @Column(length = 50)
    private String purpose;

    @Enumerated(EnumType.STRING)
    @Column(name = "media_type", nullable = false, length = 20)
    private MediaType mediaType;

    /**
     * Original filename uploaded by user
     */
    @Column(name = "original_filename", length = 255)
    private String originalFilename;

    /**
     * Key/path in S3 bucket
     */
    @Column(name = "storage_key", nullable = false, length = 500)
    private String storageKey;

    /**
     * Public URL to access the file
     */
    @Column(nullable = false, length = 1000)
    private String url;

    /**
     * Thumbnail URL (for images/videos)
     */
    @Column(name = "thumbnail_url", length = 1000)
    private String thumbnailUrl;

    /**
     * MIME type of the file
     */
    @Column(name = "mime_type", length = 100)
    private String mimeType;

    /**
     * File size in bytes
     */
    @Column(name = "file_size")
    private Long fileSize;

    /**
     * Image/video width in pixels
     */
    private Integer width;

    /**
     * Image/video height in pixels
     */
    private Integer height;

    /**
     * Video duration in seconds
     */
    @Column(name = "duration_seconds")
    private Integer durationSeconds;

    /**
     * ID of the user who uploaded the file
     */
    @Column(name = "uploaded_by")
    private UUID uploadedBy;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "deleted_at")
    private Instant deletedAt;
}
