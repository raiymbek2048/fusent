package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.service.S3Service;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class S3ServiceImpl implements S3Service {

    @Value("${storage.type:local}")
    private String storageType;

    @Value("${storage.local.base-path:./uploads}")
    private String localBasePath;

    @Value("${storage.base-url:http://localhost:8080/uploads}")
    private String baseUrl;

    // S3/MinIO configuration (for future use)
    @Value("${storage.s3.bucket:fusent-media}")
    private String s3Bucket;

    @Value("${storage.s3.region:us-east-1}")
    private String s3Region;

    @Override
    public String uploadFile(MultipartFile file, String folder) {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("File is empty");
        }

        // Validate file type
        String contentType = file.getContentType();
        if (contentType == null || !isAllowedContentType(contentType)) {
            throw new IllegalArgumentException("File type not allowed: " + contentType);
        }

        return switch (storageType.toLowerCase()) {
            case "s3", "minio" -> uploadToS3(file, folder);
            case "local" -> uploadToLocal(file, folder);
            default -> throw new IllegalStateException("Unknown storage type: " + storageType);
        };
    }

    @Override
    public boolean deleteFile(String fileUrl) {
        return switch (storageType.toLowerCase()) {
            case "s3", "minio" -> deleteFromS3(fileUrl);
            case "local" -> deleteFromLocal(fileUrl);
            default -> false;
        };
    }

    @Override
    public String generatePresignedUrl(String fileKey, int expirationMinutes) {
        if ("s3".equalsIgnoreCase(storageType) || "minio".equalsIgnoreCase(storageType)) {
            // TODO: Implement actual S3 pre-signed URL generation
            log.warn("Pre-signed URLs not implemented for S3/MinIO yet");
            return baseUrl + "/" + fileKey;
        }
        // For local storage, return regular URL
        return baseUrl + "/" + fileKey;
    }

    private String uploadToLocal(MultipartFile file, String folder) {
        try {
            // Create folder if it doesn't exist
            Path folderPath = Paths.get(localBasePath, folder);
            Files.createDirectories(folderPath);

            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".")
                    ? originalFilename.substring(originalFilename.lastIndexOf("."))
                    : "";
            String filename = UUID.randomUUID().toString() + extension;

            // Save file
            Path filePath = folderPath.resolve(filename);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            // Return public URL
            String fileUrl = baseUrl + "/" + folder + "/" + filename;
            log.info("File uploaded to local storage: {}", fileUrl);

            return fileUrl;
        } catch (IOException e) {
            log.error("Error uploading file to local storage", e);
            throw new RuntimeException("Failed to upload file", e);
        }
    }

    private boolean deleteFromLocal(String fileUrl) {
        try {
            // Extract file path from URL
            String relativePath = fileUrl.replace(baseUrl + "/", "");
            Path filePath = Paths.get(localBasePath, relativePath);

            if (Files.exists(filePath)) {
                Files.delete(filePath);
                log.info("File deleted from local storage: {}", fileUrl);
                return true;
            }
            return false;
        } catch (IOException e) {
            log.error("Error deleting file from local storage: {}", fileUrl, e);
            return false;
        }
    }

    private String uploadToS3(MultipartFile file, String folder) {
        // TODO: Implement actual S3/MinIO upload using AWS SDK or MinIO client
        /*
        Example with AWS SDK:

        try {
            String key = folder + "/" + UUID.randomUUID() + "-" + file.getOriginalFilename();

            PutObjectRequest putRequest = PutObjectRequest.builder()
                .bucket(s3Bucket)
                .key(key)
                .contentType(file.getContentType())
                .build();

            s3Client.putObject(putRequest, RequestBody.fromInputStream(
                file.getInputStream(),
                file.getSize()
            ));

            return String.format("https://%s.s3.%s.amazonaws.com/%s",
                s3Bucket, s3Region, key);
        } catch (Exception e) {
            throw new RuntimeException("Failed to upload to S3", e);
        }
        */

        log.warn("S3/MinIO upload not implemented yet. Falling back to local storage.");
        return uploadToLocal(file, folder);
    }

    private boolean deleteFromS3(String fileUrl) {
        // TODO: Implement actual S3/MinIO delete
        /*
        Example with AWS SDK:

        try {
            String key = extractKeyFromUrl(fileUrl);
            DeleteObjectRequest deleteRequest = DeleteObjectRequest.builder()
                .bucket(s3Bucket)
                .key(key)
                .build();
            s3Client.deleteObject(deleteRequest);
            return true;
        } catch (Exception e) {
            log.error("Failed to delete from S3", e);
            return false;
        }
        */

        log.warn("S3/MinIO delete not implemented yet. Falling back to local storage.");
        return deleteFromLocal(fileUrl);
    }

    private boolean isAllowedContentType(String contentType) {
        return contentType.startsWith("image/") ||
               contentType.startsWith("video/") ||
               contentType.equals("application/pdf");
    }
}
