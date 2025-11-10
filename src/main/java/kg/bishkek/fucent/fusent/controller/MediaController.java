package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kg.bishkek.fucent.fusent.service.S3Service;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/media")
@RequiredArgsConstructor
@Tag(name = "Media", description = "File upload and management")
public class MediaController {

    private final S3Service s3Service;

    @PostMapping("/upload/product")
    @PreAuthorize("hasRole('SELLER') or hasRole('ADMIN')")
    @Operation(summary = "Upload product image")
    public ResponseEntity<Map<String, String>> uploadProductImage(@RequestParam("file") MultipartFile file) {
        String url = s3Service.uploadFile(file, "products");
        return ResponseEntity.ok(createResponse(url));
    }

    @PostMapping("/upload/avatar")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Upload user avatar")
    public ResponseEntity<Map<String, String>> uploadAvatar(@RequestParam("file") MultipartFile file) {
        String url = s3Service.uploadFile(file, "avatars");
        return ResponseEntity.ok(createResponse(url));
    }

    @PostMapping("/upload/posts")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Upload post media (image/video)")
    public ResponseEntity<Map<String, String>> uploadPostMedia(@RequestParam("file") MultipartFile file) {
        String url = s3Service.uploadFile(file, "posts");
        return ResponseEntity.ok(createResponse(url));
    }

    @PostMapping("/upload/shop")
    @PreAuthorize("hasRole('SELLER') or hasRole('ADMIN')")
    @Operation(summary = "Upload shop logo or banner")
    public ResponseEntity<Map<String, String>> uploadShopMedia(@RequestParam("file") MultipartFile file) {
        String url = s3Service.uploadFile(file, "shops");
        return ResponseEntity.ok(createResponse(url));
    }

    @DeleteMapping
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Delete uploaded file")
    public ResponseEntity<Map<String, Object>> deleteFile(@RequestParam("url") String fileUrl) {
        boolean deleted = s3Service.deleteFile(fileUrl);
        Map<String, Object> response = new HashMap<>();
        response.put("success", deleted);
        response.put("message", deleted ? "File deleted successfully" : "File not found or already deleted");
        return ResponseEntity.ok(response);
    }

    private Map<String, String> createResponse(String url) {
        Map<String, String> response = new HashMap<>();
        response.put("url", url);
        response.put("message", "File uploaded successfully");
        return response;
    }
}
