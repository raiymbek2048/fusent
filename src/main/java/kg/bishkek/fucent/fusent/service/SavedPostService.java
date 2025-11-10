package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.SocialDtos.SavedPostRequest;
import kg.bishkek.fucent.fusent.dto.SocialDtos.SavedPostResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface SavedPostService {
    SavedPostResponse savePost(SavedPostRequest request);

    void unsavePost(UUID postId);

    boolean isPostSaved(UUID postId);

    Page<SavedPostResponse> getSavedPosts(Pageable pageable);
}
