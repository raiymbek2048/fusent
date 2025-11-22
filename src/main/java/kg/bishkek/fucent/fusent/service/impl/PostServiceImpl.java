package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.SocialDtos.*;
import kg.bishkek.fucent.fusent.enums.OwnerType;
import kg.bishkek.fucent.fusent.enums.PostStatus;
import kg.bishkek.fucent.fusent.model.*;
import kg.bishkek.fucent.fusent.repository.*;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.LikeService;
import kg.bishkek.fucent.fusent.service.PostService;
import kg.bishkek.fucent.fusent.service.SavedPostService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PostServiceImpl implements PostService {
    private final PostRepository postRepository;
    private final PostMediaRepository postMediaRepository;
    private final PostTagRepository postTagRepository;
    private final PostPlaceRepository postPlaceRepository;
    private final ShopRepository shopRepository;
    private final MerchantRepository merchantRepository;
    private final AppUserRepository userRepository;
    private final LikeService likeService;
    private final SavedPostService savedPostService;
    private final FollowRepository followRepository;

    @Override
    @Transactional
    public PostResponse createPost(CreatePostRequest request) {
        // Determine owner type and ID based on current user's role
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var currentUser = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("Current user not found"));

        OwnerType ownerType;
        UUID ownerId;

        if (currentUser.getRole() == kg.bishkek.fucent.fusent.enums.Role.SELLER) {
            // Sellers post as MERCHANT
            var merchant = merchantRepository.findByOwnerUserId(currentUserId)
                .orElseThrow(() -> new IllegalArgumentException("Merchant not found for seller"));

            ownerType = OwnerType.MERCHANT;
            ownerId = merchant.getId();
        } else {
            // BUYER and ADMIN post as USER
            ownerType = OwnerType.USER;
            ownerId = currentUserId;
        }

        var post = Post.builder()
            .ownerType(ownerType)
            .ownerId(ownerId)
            .text(request.text())
            .postType(request.postType())
            .geoLat(request.geoLat())
            .geoLon(request.geoLon())
            .visibility(request.visibility())
            .status(PostStatus.ACTIVE)
            .linkedProductId(request.linkedProductId())
            .likesCount(0)
            .commentsCount(0)
            .sharesCount(0)
            .build();

        post = postRepository.save(post);

        // Add media
        if (request.media() != null && !request.media().isEmpty()) {
            for (PostMediaDto mediaDto : request.media()) {
                var media = PostMedia.builder()
                    .post(post)
                    .mediaType(mediaDto.mediaType())
                    .url(mediaDto.url())
                    .thumbUrl(mediaDto.thumbUrl())
                    .sortOrder(mediaDto.sortOrder())
                    .durationSeconds(mediaDto.durationSeconds())
                    .width(mediaDto.width())
                    .height(mediaDto.height())
                    .build();
                postMediaRepository.save(media);
            }
        }

        // Add tags
        if (request.tags() != null && !request.tags().isEmpty()) {
            for (String tag : request.tags()) {
                var postTag = PostTag.builder()
                    .post(post)
                    .tag(tag.toLowerCase().trim())
                    .build();
                postTagRepository.save(postTag);
            }
        }

        // Add places
        if (request.placeIds() != null && !request.placeIds().isEmpty()) {
            for (UUID placeId : request.placeIds()) {
                var shop = shopRepository.findById(placeId)
                    .orElseThrow(() -> new IllegalArgumentException("Shop not found: " + placeId));
                var postPlace = PostPlace.builder()
                    .post(post)
                    .place(shop)
                    .build();
                postPlaceRepository.save(postPlace);
            }
        }

        return toPostResponse(post);
    }

    @Override
    @Transactional
    public PostResponse updatePost(UUID postId, UpdatePostRequest request) {
        var post = postRepository.findById(postId)
            .orElseThrow(() -> new IllegalArgumentException("Post not found"));

        if (request.text() != null) {
            post.setText(request.text());
        }
        if (request.visibility() != null) {
            post.setVisibility(request.visibility());
        }
        if (request.status() != null) {
            post.setStatus(request.status());
        }

        post = postRepository.save(post);
        return toPostResponse(post);
    }

    @Override
    @Transactional
    public void deletePost(UUID postId) {
        var post = postRepository.findById(postId)
            .orElseThrow(() -> new IllegalArgumentException("Post not found"));
        post.setStatus(PostStatus.DELETED);
        postRepository.save(post);
    }

    @Override
    @Transactional(readOnly = true)
    public PostResponse getPost(UUID postId) {
        var post = postRepository.findById(postId)
            .orElseThrow(() -> new IllegalArgumentException("Post not found"));
        return toPostResponse(post);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<PostResponse> getPublicFeed(Pageable pageable) {
        return postRepository.findByStatus(PostStatus.ACTIVE, pageable)
            .map(this::toPostResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<PostResponse> getFollowingFeed(Pageable pageable) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);

        // Get posts from users and merchants the current user follows
        return postRepository.findFollowingFeedByUser(currentUserId, PostStatus.ACTIVE, pageable)
            .map(this::toPostResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<PostResponse> getPostsByOwner(OwnerType ownerType, UUID ownerId, Pageable pageable) {
        return postRepository.findByOwnerTypeAndOwnerIdAndStatus(
            ownerType, ownerId, PostStatus.ACTIVE, pageable
        ).map(this::toPostResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<PostResponse> getPostsByShop(UUID shopId, Pageable pageable) {
        // Get the shop first
        var shop = shopRepository.findById(shopId)
            .orElseThrow(() -> new IllegalArgumentException("Shop not found with id: " + shopId));

        // Get the merchant ID from the shop
        UUID merchantId = shop.getMerchant().getId();

        // Return posts owned by the merchant
        return postRepository.findByOwnerTypeAndOwnerIdAndStatus(
            OwnerType.MERCHANT, merchantId, PostStatus.ACTIVE, pageable
        ).map(this::toPostResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<PostResponse> getMyPosts(Pageable pageable) {
        // Get current user
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var currentUser = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("Current user not found"));

        OwnerType ownerType;
        UUID ownerId;

        if (currentUser.getRole() == kg.bishkek.fucent.fusent.enums.Role.SELLER) {
            // Sellers post as MERCHANT, so get posts by merchant ID
            var merchant = merchantRepository.findByOwnerUserId(currentUserId)
                .orElseThrow(() -> new IllegalArgumentException("Merchant not found for seller"));

            ownerType = OwnerType.MERCHANT;
            ownerId = merchant.getId();
        } else {
            // BUYER and ADMIN post as USER
            ownerType = OwnerType.USER;
            ownerId = currentUserId;
        }

        return getPostsByOwner(ownerType, ownerId, pageable);
    }

    private PostResponse toPostResponse(Post post) {
        // Get owner name
        String ownerName = getOwnerName(post.getOwnerType(), post.getOwnerId());

        // Get media
        var mediaList = postMediaRepository.findByPostOrderBySortOrderAsc(post).stream()
            .map(m -> new PostMediaDto(
                m.getId(),
                m.getMediaType(),
                m.getUrl(),
                m.getThumbUrl(),
                m.getSortOrder(),
                m.getDurationSeconds(),
                m.getWidth(),
                m.getHeight()
            ))
            .collect(Collectors.toList());

        // Get tags
        var tags = postTagRepository.findByPost(post).stream()
            .map(PostTag::getTag)
            .collect(Collectors.toList());

        // Check if liked by current user
        Boolean isLiked = false;
        try {
            isLiked = likeService.isPostLikedByCurrentUser(post.getId());
        } catch (Exception e) {
            // User not authenticated
        }

        // Check if saved by current user
        Boolean isSaved = false;
        try {
            isSaved = savedPostService.isPostSaved(post.getId());
        } catch (Exception e) {
            // User not authenticated
        }

        return new PostResponse(
            post.getId(),
            post.getOwnerType(),
            post.getOwnerId(),
            ownerName,
            post.getText(),
            post.getPostType(),
            post.getGeoLat(),
            post.getGeoLon(),
            post.getVisibility(),
            post.getStatus(),
            post.getLikesCount(),
            post.getCommentsCount(),
            post.getSharesCount(),
            mediaList,
            tags,
            isLiked,
            isSaved,
            post.getLinkedProductId(),
            post.getCreatedAt(),
            post.getUpdatedAt()
        );
    }

    private String getOwnerName(OwnerType ownerType, UUID ownerId) {
        return switch (ownerType) {
            case MERCHANT -> {
                // Get first shop of merchant, or merchant name if no shops
                var shops = shopRepository.findByMerchant_Id(ownerId);
                if (!shops.isEmpty()) {
                    yield shops.get(0).getName();
                }
                yield merchantRepository.findById(ownerId)
                    .map(Merchant::getName)
                    .orElse("Unknown Merchant");
            }
            case USER -> userRepository.findById(ownerId)
                .map(AppUser::getFullName)
                .orElse("Unknown User");
            case SHOP -> shopRepository.findById(ownerId)
                .map(Shop::getName)
                .orElse("Unknown Shop");
        };
    }
}
