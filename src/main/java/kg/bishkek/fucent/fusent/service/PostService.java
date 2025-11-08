package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.SocialDtos.*;
import kg.bishkek.fucent.fusent.enums.OwnerType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface PostService {
    PostResponse createPost(CreatePostRequest request);

    PostResponse updatePost(UUID postId, UpdatePostRequest request);

    void deletePost(UUID postId);

    PostResponse getPost(UUID postId);

    Page<PostResponse> getPublicFeed(Pageable pageable);

    Page<PostResponse> getFollowingFeed(Pageable pageable);

    Page<PostResponse> getPostsByOwner(OwnerType ownerType, UUID ownerId, Pageable pageable);
}
