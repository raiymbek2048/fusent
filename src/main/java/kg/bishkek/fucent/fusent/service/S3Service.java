package kg.bishkek.fucent.fusent.service;

import org.springframework.web.multipart.MultipartFile;

public interface S3Service {
    /**
     * Upload file to S3/MinIO
     * @param file The file to upload
     * @param folder The folder/prefix (e.g., "products", "posts", "avatars")
     * @return The public URL of the uploaded file
     */
    String uploadFile(MultipartFile file, String folder);

    /**
     * Delete file from S3/MinIO
     * @param fileUrl The URL of the file to delete
     * @return true if successful
     */
    boolean deleteFile(String fileUrl);

    /**
     * Generate pre-signed URL for temporary access
     * @param fileKey The S3 object key
     * @param expirationMinutes Expiration time in minutes
     * @return Pre-signed URL
     */
    String generatePresignedUrl(String fileKey, int expirationMinutes);
}
