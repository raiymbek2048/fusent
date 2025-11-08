package kg.bishkek.fucent.fusent.dto;

import java.time.Instant;

public class MediaDtos {

    public record UploadUrlResponse(
        String uploadUrl,
        String fileKey,
        String publicUrl,
        Instant expiresAt
    ) {}

    public record MediaUploadRequest(
        String fileName,
        String contentType,
        String folder // e.g., "products", "posts", "avatars"
    ) {}

    public record DeleteMediaRequest(
        String fileKey
    ) {}
}
