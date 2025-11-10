package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.enums.MediaType;
import kg.bishkek.fucent.fusent.model.MediaFile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MediaFileRepository extends JpaRepository<MediaFile, UUID> {

    List<MediaFile> findByOwnerIdAndOwnerTypeAndDeletedAtIsNull(UUID ownerId, String ownerType);

    List<MediaFile> findByOwnerIdAndOwnerTypeAndPurposeAndDeletedAtIsNull(
        UUID ownerId, String ownerType, String purpose);

    Optional<MediaFile> findByStorageKeyAndDeletedAtIsNull(String storageKey);

    List<MediaFile> findByUploadedByAndDeletedAtIsNull(UUID uploadedBy);

    List<MediaFile> findByMediaTypeAndDeletedAtIsNull(MediaType mediaType);

    @Query("SELECT m FROM MediaFile m WHERE m.deletedAt IS NULL AND m.createdAt < :before")
    List<MediaFile> findOrphanedFiles(Instant before);

    long countByOwnerIdAndOwnerTypeAndDeletedAtIsNull(UUID ownerId, String ownerType);
}
