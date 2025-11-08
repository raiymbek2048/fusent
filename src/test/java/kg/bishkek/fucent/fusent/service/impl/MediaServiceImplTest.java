package kg.bishkek.fucent.fusent.service.impl;

import io.minio.GetPresignedObjectUrlArgs;
import io.minio.MinioClient;
import io.minio.RemoveObjectArgs;
import kg.bishkek.fucent.fusent.dto.MediaDtos.*;
import kg.bishkek.fucent.fusent.exception.MediaStorageException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MediaServiceImplTest {

    @Mock
    private MinioClient minioClient;

    @InjectMocks
    private MediaServiceImpl mediaService;

    private final String bucketName = "test-bucket";
    private final String minioUrl = "http://localhost:9000";

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(mediaService, "bucketName", bucketName);
        ReflectionTestUtils.setField(mediaService, "minioUrl", minioUrl);
    }

    @Test
    void generateUploadUrl_shouldReturnValidResponse() throws Exception {
        // Given
        MediaUploadRequest request = new MediaUploadRequest("test.jpg", "image/jpeg", "products");
        String expectedPresignedUrl = "http://localhost:9000/test-bucket/products/test.jpg?signature=xyz";

        when(minioClient.getPresignedObjectUrl(any(GetPresignedObjectUrlArgs.class)))
            .thenReturn(expectedPresignedUrl);

        // When
        UploadUrlResponse response = mediaService.generateUploadUrl(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.uploadUrl()).isEqualTo(expectedPresignedUrl);
        assertThat(response.fileKey()).contains("products/");
        assertThat(response.fileKey()).contains("test.jpg");
        assertThat(response.publicUrl()).startsWith("http://localhost:9000/test-bucket/products/");
        assertThat(response.expiresAt()).isNotNull();

        verify(minioClient, times(1)).getPresignedObjectUrl(any(GetPresignedObjectUrlArgs.class));
    }

    @Test
    void generateUploadUrl_shouldSanitizeFileName() throws Exception {
        // Given
        MediaUploadRequest request = new MediaUploadRequest(
            "test file with spaces!@#.jpg",
            "image/jpeg",
            "products"
        );

        when(minioClient.getPresignedObjectUrl(any(GetPresignedObjectUrlArgs.class)))
            .thenReturn("http://presigned-url");

        // When
        UploadUrlResponse response = mediaService.generateUploadUrl(request);

        // Then
        assertThat(response.fileKey()).contains("test_file_with_spaces___.jpg");
        assertThat(response.fileKey()).doesNotContain(" ");
        assertThat(response.fileKey()).doesNotContain("!");
        assertThat(response.fileKey()).doesNotContain("@");
    }

    @Test
    void generateUploadUrl_shouldThrowExceptionWhenFileNameIsEmpty() {
        // Given
        MediaUploadRequest request = new MediaUploadRequest("", "image/jpeg", "products");

        // When & Then
        assertThatThrownBy(() -> mediaService.generateUploadUrl(request))
            .isInstanceOf(MediaStorageException.class)
            .hasMessageContaining("File name cannot be empty");

        verify(minioClient, never()).getPresignedObjectUrl(any());
    }

    @Test
    void generateUploadUrl_shouldThrowExceptionWhenFolderIsEmpty() {
        // Given
        MediaUploadRequest request = new MediaUploadRequest("test.jpg", "image/jpeg", "");

        // When & Then
        assertThatThrownBy(() -> mediaService.generateUploadUrl(request))
            .isInstanceOf(MediaStorageException.class)
            .hasMessageContaining("Folder name cannot be empty");

        verify(minioClient, never()).getPresignedObjectUrl(any());
    }

    @Test
    void generateUploadUrl_shouldThrowMediaStorageExceptionWhenMinioFails() throws Exception {
        // Given
        MediaUploadRequest request = new MediaUploadRequest("test.jpg", "image/jpeg", "products");

        when(minioClient.getPresignedObjectUrl(any(GetPresignedObjectUrlArgs.class)))
            .thenThrow(new RuntimeException("MinIO connection failed"));

        // When & Then
        assertThatThrownBy(() -> mediaService.generateUploadUrl(request))
            .isInstanceOf(MediaStorageException.class)
            .hasMessageContaining("Failed to generate upload URL");
    }

    @Test
    void deleteMedia_shouldCallMinioRemoveObject() throws Exception {
        // Given
        String fileKey = "products/test-file.jpg";

        doNothing().when(minioClient).removeObject(any(RemoveObjectArgs.class));

        // When
        mediaService.deleteMedia(fileKey);

        // Then
        verify(minioClient, times(1)).removeObject(any(RemoveObjectArgs.class));
    }

    @Test
    void deleteMedia_shouldThrowExceptionWhenFileKeyIsEmpty() {
        // Given
        String emptyFileKey = "";

        // When & Then
        assertThatThrownBy(() -> mediaService.deleteMedia(emptyFileKey))
            .isInstanceOf(MediaStorageException.class)
            .hasMessageContaining("File key cannot be empty");

        verify(minioClient, never()).removeObject(any());
    }

    @Test
    void deleteMedia_shouldThrowExceptionWhenFileKeyIsNull() {
        // When & Then
        assertThatThrownBy(() -> mediaService.deleteMedia(null))
            .isInstanceOf(MediaStorageException.class)
            .hasMessageContaining("File key cannot be empty");

        verify(minioClient, never()).removeObject(any());
    }

    @Test
    void deleteMedia_shouldThrowMediaStorageExceptionWhenMinioFails() throws Exception {
        // Given
        String fileKey = "products/test-file.jpg";

        doThrow(new RuntimeException("MinIO delete failed"))
            .when(minioClient).removeObject(any(RemoveObjectArgs.class));

        // When & Then
        assertThatThrownBy(() -> mediaService.deleteMedia(fileKey))
            .isInstanceOf(MediaStorageException.class)
            .hasMessageContaining("Failed to delete media file");
    }

    @Test
    void getPublicUrl_shouldReturnCorrectUrl() {
        // Given
        String fileKey = "products/test-file.jpg";

        // When
        String publicUrl = mediaService.getPublicUrl(fileKey);

        // Then
        assertThat(publicUrl).isEqualTo("http://localhost:9000/test-bucket/products/test-file.jpg");
    }

    @Test
    void getPublicUrl_shouldThrowExceptionWhenFileKeyIsEmpty() {
        // When & Then
        assertThatThrownBy(() -> mediaService.getPublicUrl(""))
            .isInstanceOf(MediaStorageException.class)
            .hasMessageContaining("File key cannot be empty");
    }

    @Test
    void getPublicUrl_shouldThrowExceptionWhenFileKeyIsNull() {
        // When & Then
        assertThatThrownBy(() -> mediaService.getPublicUrl(null))
            .isInstanceOf(MediaStorageException.class)
            .hasMessageContaining("File key cannot be empty");
    }
}
