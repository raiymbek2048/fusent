package kg.bishkek.fucent.fusent.service.impl;

import io.minio.*;
import io.minio.errors.*;
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
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
@Slf4j
public class S3ServiceImpl implements S3Service {

    private final MinioClient minioClient;

    @Value("${storage.type:local}")
    private String storageType;

    @Value("${storage.local.base-path:./uploads}")
    private String localBasePath;

    @Value("${storage.base-url:http://localhost:8080/uploads}")
    private String baseUrl;

    // S3/MinIO configuration
    @Value("${app.s3.endpoint}")
    private String s3Endpoint;

    @Value("${app.s3.bucket-media}")
    private String s3Bucket;

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
            try {
                String url = minioClient.getPresignedObjectUrl(
                    GetPresignedObjectUrlArgs.builder()
                        .method(io.minio.http.Method.GET)
                        .bucket(s3Bucket)
                        .object(fileKey)
                        .expiry(expirationMinutes, TimeUnit.MINUTES)
                        .build()
                );
                log.info("Generated pre-signed URL for key: {}", fileKey);
                return url;
            } catch (Exception e) {
                log.error("Error generating pre-signed URL for key: {}", fileKey, e);
                // Fallback to regular URL
                return s3Endpoint + "/" + s3Bucket + "/" + fileKey;
            }
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
        try {
            // Ensure bucket exists
            ensureBucketExists();

            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".")
                    ? originalFilename.substring(originalFilename.lastIndexOf("."))
                    : "";
            String filename = UUID.randomUUID().toString() + extension;
            String objectKey = folder + "/" + filename;

            // Upload to MinIO
            minioClient.putObject(
                PutObjectArgs.builder()
                    .bucket(s3Bucket)
                    .object(objectKey)
                    .stream(file.getInputStream(), file.getSize(), -1)
                    .contentType(file.getContentType())
                    .build()
            );

            // Generate public URL
            String fileUrl = s3Endpoint + "/" + s3Bucket + "/" + objectKey;
            log.info("File uploaded to MinIO: {}", fileUrl);

            return fileUrl;

        } catch (Exception e) {
            log.error("Error uploading file to MinIO", e);
            throw new RuntimeException("Failed to upload file to MinIO", e);
        }
    }

    private boolean deleteFromS3(String fileUrl) {
        try {
            // Extract object key from URL
            // Expected format: http://localhost:9000/fusent-media/folder/filename.ext
            String objectKey = extractKeyFromUrl(fileUrl);
            if (objectKey == null) {
                log.error("Failed to extract object key from URL: {}", fileUrl);
                return false;
            }

            // Delete from MinIO
            minioClient.removeObject(
                RemoveObjectArgs.builder()
                    .bucket(s3Bucket)
                    .object(objectKey)
                    .build()
            );

            log.info("File deleted from MinIO: {}", fileUrl);
            return true;

        } catch (Exception e) {
            log.error("Error deleting file from MinIO: {}", fileUrl, e);
            return false;
        }
    }

    private String extractKeyFromUrl(String fileUrl) {
        // Extract object key from URL
        // Format: http://localhost:9000/fusent-media/folder/filename.ext
        // Result: folder/filename.ext
        try {
            String prefix = s3Endpoint + "/" + s3Bucket + "/";
            if (fileUrl.startsWith(prefix)) {
                return fileUrl.substring(prefix.length());
            }
            return null;
        } catch (Exception e) {
            log.error("Error extracting key from URL: {}", fileUrl, e);
            return null;
        }
    }

    private void ensureBucketExists() {
        try {
            boolean exists = minioClient.bucketExists(
                BucketExistsArgs.builder()
                    .bucket(s3Bucket)
                    .build()
            );

            if (!exists) {
                minioClient.makeBucket(
                    MakeBucketArgs.builder()
                        .bucket(s3Bucket)
                        .build()
                );
                log.info("Created MinIO bucket: {}", s3Bucket);

                // Set public read policy for the bucket (optional)
                String policy = """
                    {
                        "Version": "2012-10-17",
                        "Statement": [
                            {
                                "Effect": "Allow",
                                "Principal": {"AWS": "*"},
                                "Action": ["s3:GetObject"],
                                "Resource": ["arn:aws:s3:::%s/*"]
                            }
                        ]
                    }
                    """.formatted(s3Bucket);

                minioClient.setBucketPolicy(
                    SetBucketPolicyArgs.builder()
                        .bucket(s3Bucket)
                        .config(policy)
                        .build()
                );
                log.info("Set public read policy for bucket: {}", s3Bucket);
            }
        } catch (Exception e) {
            log.error("Error ensuring bucket exists", e);
            throw new RuntimeException("Failed to ensure bucket exists", e);
        }
    }

    private boolean isAllowedContentType(String contentType) {
        return contentType.startsWith("image/") ||
               contentType.startsWith("video/") ||
               contentType.equals("application/pdf");
    }
}
