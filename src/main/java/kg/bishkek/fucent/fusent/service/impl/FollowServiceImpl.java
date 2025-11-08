package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.SocialDtos.*;
import kg.bishkek.fucent.fusent.enums.FollowTargetType;
import kg.bishkek.fucent.fusent.model.Follow;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.FollowRepository;
import kg.bishkek.fucent.fusent.repository.MerchantRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.FollowService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FollowServiceImpl implements FollowService {
    private final FollowRepository followRepository;
    private final AppUserRepository userRepository;
    private final MerchantRepository merchantRepository;

    @Override
    @Transactional
    public FollowResponse follow(FollowRequest request) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var follower = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        // Validate target exists
        validateTarget(request.targetType(), request.targetId());

        // Check if already following
        var existingFollow = followRepository.findByFollowerAndTargetTypeAndTargetId(
            follower, request.targetType(), request.targetId());
        if (existingFollow.isPresent()) {
            return toFollowResponse(existingFollow.get());
        }

        var follow = Follow.builder()
            .follower(follower)
            .targetType(request.targetType())
            .targetId(request.targetId())
            .build();

        follow = followRepository.save(follow);
        return toFollowResponse(follow);
    }

    @Override
    @Transactional
    public void unfollow(FollowTargetType targetType, UUID targetId) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var follower = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        var follow = followRepository.findByFollowerAndTargetTypeAndTargetId(
            follower, targetType, targetId)
            .orElseThrow(() -> new IllegalArgumentException("Follow not found"));

        followRepository.delete(follow);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isFollowing(FollowTargetType targetType, UUID targetId) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var follower = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        return followRepository.existsByFollowerAndTargetTypeAndTargetId(
            follower, targetType, targetId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<FollowResponse> getFollowing(UUID userId) {
        var user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        return followRepository.findByFollower(user).stream()
            .map(this::toFollowResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<FollowResponse> getFollowers(FollowTargetType targetType, UUID targetId) {
        return followRepository.findByTargetTypeAndTargetId(targetType, targetId).stream()
            .map(this::toFollowResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public FollowersStatsResponse getStats(FollowTargetType targetType, UUID targetId) {
        long followersCount = followRepository.countByTargetTypeAndTargetId(targetType, targetId);

        // For users, count how many they follow
        long followingCount = 0;
        if (targetType == FollowTargetType.USER) {
            var user = userRepository.findById(targetId);
            if (user.isPresent()) {
                followingCount = followRepository.findByFollower(user.get()).size();
            }
        }

        return new FollowersStatsResponse(followersCount, followingCount);
    }

    private void validateTarget(FollowTargetType targetType, UUID targetId) {
        switch (targetType) {
            case MERCHANT -> merchantRepository.findById(targetId)
                .orElseThrow(() -> new IllegalArgumentException("Merchant not found"));
            case USER -> userRepository.findById(targetId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        }
    }

    private FollowResponse toFollowResponse(Follow follow) {
        String targetName = getTargetName(follow.getTargetType(), follow.getTargetId());

        return new FollowResponse(
            follow.getId(),
            follow.getFollower().getId(),
            follow.getTargetType(),
            follow.getTargetId(),
            targetName,
            follow.getCreatedAt()
        );
    }

    private String getTargetName(FollowTargetType targetType, UUID targetId) {
        return switch (targetType) {
            case MERCHANT -> merchantRepository.findById(targetId)
                .map(m -> m.getName())
                .orElse("Unknown Merchant");
            case USER -> userRepository.findById(targetId)
                .map(u -> u.getEmail())
                .orElse("Unknown User");
        };
    }
}
