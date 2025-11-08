package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.MediaDtos.*;

public interface MediaService {
    UploadUrlResponse generateUploadUrl(MediaUploadRequest request);

    void deleteMedia(String fileKey);

    String getPublicUrl(String fileKey);
}
