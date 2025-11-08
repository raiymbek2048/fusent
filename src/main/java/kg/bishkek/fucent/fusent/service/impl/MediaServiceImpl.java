package kg.bishkek.fucent.fusent.service.impl;

import io.minio.GetPresignedObjectUrlArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.RemoveObjectArgs;
import io.minio.http.Method;
import kg.bishkek.fucent.fusent.dto.MediaDtos.*;
import kg.bishkek.fucent.fusent.service.MediaService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
@Slf4j
public class MediaServiceImpl implements MediaService {
    private final MinioClient minioClient;

    @Value("${minio.bucket-name:fucent-media}")
    private String bucketName;

    @Value("${minio.url:http://localhost:9000}")
    private String minioUrl;

    @Override
    public UploadUrlResponse generateUploadUrl(MediaUploadRequest request) {
        try {
            // Generate unique file key
            String fileKey = String.format("%s/%s-%s",
                request.folder(),
                UUID.randomUUID(),
                sanitizeFileName(request.fileName())
            );

            // Generate presigned upload URL (valid for 15 minutes)
            String uploadUrl = minioClient.getPresignedObjectUrl(
                GetPresignedObjectUrlArgs.builder()
                    .method(Method.PUT)
                    .bucket(bucketName)
                    .object(fileKey)
                    .expiry(15, TimeUnit.MINUTES)
                    .build()
            );

            // Generate public URL
            String publicUrl = String.format("%s/%s/%s", minioUrl, bucketName, fileKey);

            Instant expiresAt = Instant.now().plus(15, ChronoUnit.MINUTES);

            return new UploadUrlResponse(uploadUrl, fileKey, publicUrl, expiresAt);

        } catch (Exception e) {
            log.error("Error generating upload URL", e);
            throw new RuntimeException("Failed to generate upload URL", e);
        }
    }

    @Override
    public void deleteMedia(String fileKey) {
        try {
            minioClient.removeObject(
                RemoveObjectArgs.builder()
                    .bucket(bucketName)
                    .object(fileKey)
                    .build()
            );
        } catch (Exception e) {
            log.error("Error deleting media: {}", fileKey, e);
            throw new RuntimeException("Failed to delete media", e);
        }
    }

    @Override
    public String getPublicUrl(String fileKey) {
        return String.format("%s/%s/%s", minioUrl, bucketName, fileKey);
    }

    private String sanitizeFileName(String fileName) {
        // Remove special characters and spaces
        return fileName.replaceAll("[^a-zA-Z0-9.-]", "_");
    }
}
