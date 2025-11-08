package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.SocialDtos.*;
import kg.bishkek.fucent.fusent.enums.FollowTargetType;

import java.util.List;
import java.util.UUID;

public interface FollowService {
    FollowResponse follow(FollowRequest request);

    void unfollow(FollowTargetType targetType, UUID targetId);

    boolean isFollowing(FollowTargetType targetType, UUID targetId);

    List<FollowResponse> getFollowing(UUID userId);

    List<FollowResponse> getFollowers(FollowTargetType targetType, UUID targetId);

    FollowersStatsResponse getStats(FollowTargetType targetType, UUID targetId);
}
