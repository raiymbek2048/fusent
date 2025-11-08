package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.MediaDtos.*;
import kg.bishkek.fucent.fusent.service.MediaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/media")
@RequiredArgsConstructor
@Tag(name = "Media", description = "Media upload and management (S3/MinIO)")
public class MediaController {
    private final MediaService mediaService;

    @PostMapping("/upload-url")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Generate presigned URL for media upload")
    public UploadUrlResponse generateUploadUrl(@Valid @RequestBody MediaUploadRequest request) {
        return mediaService.generateUploadUrl(request);
    }

    @DeleteMapping("/{fileKey}")
    @PreAuthorize("isAuthenticated()")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete media file")
    public void deleteMedia(@PathVariable String fileKey) {
        mediaService.deleteMedia(fileKey);
    }

    @GetMapping("/url/{fileKey}")
    @Operation(summary = "Get public URL for media file")
    public String getPublicUrl(@PathVariable String fileKey) {
        return mediaService.getPublicUrl(fileKey);
    }
}
