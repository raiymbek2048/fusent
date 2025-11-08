package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.SocialDtos.*;

import java.util.UUID;

public interface LikeService {
    LikeResponse likePost(LikeRequest request);

    void unlikePost(UUID postId);

    boolean isPostLikedByCurrentUser(UUID postId);

    Long getLikesCount(UUID postId);
}
