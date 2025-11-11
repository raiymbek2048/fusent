package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import kg.bishkek.fucent.fusent.enums.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public class SocialDtos {

    // Post DTOs
    public record CreatePostRequest(
        OwnerType ownerType, // Optional - automatically determined from user role
        UUID ownerId, // Optional - automatically determined from user role
        String text,
        @NotNull PostType postType,
        BigDecimal geoLat,
        BigDecimal geoLon,
        PostVisibility visibility,
        List<PostMediaDto> media,
        List<String> tags,
        List<UUID> placeIds
    ) {}

    public record UpdatePostRequest(
        String text,
        PostVisibility visibility,
        PostStatus status
    ) {}

    public record PostResponse(
        UUID id,
        OwnerType ownerType,
        UUID ownerId,
        String ownerName,
        String text,
        PostType postType,
        BigDecimal geoLat,
        BigDecimal geoLon,
        PostVisibility visibility,
        PostStatus status,
        Integer likesCount,
        Integer commentsCount,
        Integer sharesCount,
        List<PostMediaDto> media,
        List<String> tags,
        Boolean isLikedByCurrentUser,
        Instant createdAt,
        Instant updatedAt
    ) {}

    public record PostMediaDto(
        UUID id,
        MediaType mediaType,
        String url,
        String thumbUrl,
        Integer sortOrder,
        Integer durationSeconds,
        Integer width,
        Integer height
    ) {}

    // Comment DTOs
    public record CreateCommentRequest(
        @NotNull UUID postId,
        @NotBlank String text
    ) {}

    public record CommentResponse(
        UUID id,
        UUID postId,
        UUID userId,
        String userName,
        String text,
        Boolean isFlagged,
        Boolean verifiedPurchase,
        Instant createdAt,
        Instant updatedAt
    ) {}

    // Like DTOs
    public record LikeRequest(
        @NotNull UUID postId
    ) {}

    public record LikeResponse(
        UUID id,
        UUID userId,
        UUID postId,
        Instant createdAt
    ) {}

    // Follow DTOs
    public record FollowRequest(
        @NotNull FollowTargetType targetType,
        @NotNull UUID targetId
    ) {}

    public record FollowResponse(
        UUID id,
        UUID followerId,
        FollowTargetType targetType,
        UUID targetId,
        String targetName,
        Instant createdAt
    ) {}

    public record FollowersStatsResponse(
        Long followersCount,
        Long followingCount
    ) {}

    // Feed DTOs
    public record FeedRequest(
        Integer page,
        Integer size,
        String sortBy
    ) {
        public FeedRequest {
            if (page == null) page = 0;
            if (size == null) size = 20;
            if (sortBy == null) sortBy = "createdAt";
        }
    }

    // SavedPost DTOs
    public record SavedPostRequest(
        @NotNull UUID postId
    ) {}

    public record SavedPostResponse(
        UUID id,
        UUID userId,
        UUID postId,
        PostResponse post,
        Instant createdAt
    ) {}

    // Share DTOs
    public record ShareRequest(
        @NotNull UUID postId
    ) {}

    public record ShareResponse(
        UUID id,
        UUID userId,
        String userName,
        UUID postId,
        Instant createdAt
    ) {}
}
