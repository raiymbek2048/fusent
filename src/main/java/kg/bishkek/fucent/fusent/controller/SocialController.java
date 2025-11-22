package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.SocialDtos.*;
import kg.bishkek.fucent.fusent.enums.FollowTargetType;
import kg.bishkek.fucent.fusent.enums.OwnerType;
import kg.bishkek.fucent.fusent.service.CommentService;
import kg.bishkek.fucent.fusent.service.FollowService;
import kg.bishkek.fucent.fusent.service.LikeService;
import kg.bishkek.fucent.fusent.service.PostService;
import kg.bishkek.fucent.fusent.service.SavedPostService;
import kg.bishkek.fucent.fusent.service.ShareService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/social")
@RequiredArgsConstructor
@Tag(name = "Social", description = "Social feed, posts, comments, likes, and follows")
public class SocialController {
    private final PostService postService;
    private final CommentService commentService;
    private final LikeService likeService;
    private final FollowService followService;
    private final SavedPostService savedPostService;
    private final ShareService shareService;

    // ========== Posts ==========

    @PostMapping("/posts")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Create a new post")
    public PostResponse createPost(@Valid @RequestBody CreatePostRequest request) {
        return postService.createPost(request);
    }

    @PutMapping("/posts/{postId}")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Update a post")
    public PostResponse updatePost(
        @PathVariable UUID postId,
        @Valid @RequestBody UpdatePostRequest request
    ) {
        return postService.updatePost(postId, request);
    }

    @DeleteMapping("/posts/{postId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete a post")
    public void deletePost(@PathVariable UUID postId) {
        postService.deletePost(postId);
    }

    @GetMapping("/posts/{postId}")
    @Operation(summary = "Get a post by ID")
    public PostResponse getPost(@PathVariable UUID postId) {
        return postService.getPost(postId);
    }

    @GetMapping("/feed/public")
    @Operation(summary = "Get public feed")
    public Page<PostResponse> getPublicFeed(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size
    ) {
        return postService.getPublicFeed(
            PageRequest.of(page, size, Sort.by("createdAt").descending())
        );
    }

    @GetMapping("/feed/following")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get feed from followed users and merchants")
    public Page<PostResponse> getFollowingFeed(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size
    ) {
        return postService.getFollowingFeed(
            PageRequest.of(page, size, Sort.by("createdAt").descending())
        );
    }

    @GetMapping("/posts/by-owner")
    @Operation(summary = "Get posts by owner (merchant or user)")
    public Page<PostResponse> getPostsByOwner(
        @RequestParam OwnerType ownerType,
        @RequestParam UUID ownerId,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size
    ) {
        return postService.getPostsByOwner(
            ownerType,
            ownerId,
            PageRequest.of(page, size, Sort.by("createdAt").descending())
        );
    }

    @GetMapping("/posts/my-posts")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get posts for the current logged-in user")
    public Page<PostResponse> getMyPosts(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size
    ) {
        return postService.getMyPosts(
            PageRequest.of(page, size, Sort.by("createdAt").descending())
        );
    }

    @GetMapping("/shops/{shopId}/posts")
    @Operation(summary = "Get posts by shop (returns merchant's posts)")
    public Page<PostResponse> getPostsByShop(
        @PathVariable UUID shopId,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "10") int size
    ) {
        return postService.getPostsByShop(
            shopId,
            PageRequest.of(page, size, Sort.by("createdAt").descending())
        );
    }

    // ========== Comments ==========

    @PostMapping("/comments")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Create a comment on a post")
    public CommentResponse createComment(@Valid @RequestBody CreateCommentRequest request) {
        return commentService.createComment(request);
    }

    @DeleteMapping("/comments/{commentId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete a comment")
    public void deleteComment(@PathVariable UUID commentId) {
        commentService.deleteComment(commentId);
    }

    @GetMapping("/posts/{postId}/comments")
    @Operation(summary = "Get comments for a post")
    public Page<CommentResponse> getCommentsByPost(
        @PathVariable UUID postId,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size
    ) {
        return commentService.getCommentsByPost(
            postId,
            PageRequest.of(page, size, Sort.by("createdAt").descending())
        );
    }

    @PostMapping("/comments/{commentId}/flag")
    @PreAuthorize("isAuthenticated()")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Flag a comment as inappropriate")
    public void flagComment(@PathVariable UUID commentId) {
        commentService.flagComment(commentId);
    }

    // ========== Likes ==========

    @PostMapping("/likes")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Like a post")
    public LikeResponse likePost(@Valid @RequestBody LikeRequest request) {
        return likeService.likePost(request);
    }

    @DeleteMapping("/posts/{postId}/likes")
    @PreAuthorize("isAuthenticated()")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Unlike a post")
    public void unlikePost(@PathVariable UUID postId) {
        likeService.unlikePost(postId);
    }

    @GetMapping("/posts/{postId}/liked")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Check if current user liked a post")
    public boolean isPostLiked(@PathVariable UUID postId) {
        return likeService.isPostLikedByCurrentUser(postId);
    }

    @GetMapping("/posts/{postId}/likes/count")
    @Operation(summary = "Get likes count for a post")
    public Long getLikesCount(@PathVariable UUID postId) {
        return likeService.getLikesCount(postId);
    }

    // ========== Follows ==========

    @PostMapping("/follows")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Follow a user or merchant")
    public FollowResponse follow(@Valid @RequestBody FollowRequest request) {
        return followService.follow(request);
    }

    @DeleteMapping("/follows/{targetType}/{targetId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Unfollow a user or merchant")
    public void unfollow(
        @PathVariable FollowTargetType targetType,
        @PathVariable UUID targetId
    ) {
        followService.unfollow(targetType, targetId);
    }

    @GetMapping("/follows/{targetType}/{targetId}/is-following")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Check if current user is following")
    public boolean isFollowing(
        @PathVariable FollowTargetType targetType,
        @PathVariable UUID targetId
    ) {
        return followService.isFollowing(targetType, targetId);
    }

    @GetMapping("/users/{userId}/following")
    @Operation(summary = "Get list of users/merchants that a user follows")
    public List<FollowResponse> getFollowing(@PathVariable UUID userId) {
        return followService.getFollowing(userId);
    }

    @GetMapping("/follows/{targetType}/{targetId}/followers")
    @Operation(summary = "Get followers of a user or merchant")
    public List<FollowResponse> getFollowers(
        @PathVariable FollowTargetType targetType,
        @PathVariable UUID targetId
    ) {
        return followService.getFollowers(targetType, targetId);
    }

    @GetMapping("/follows/{targetType}/{targetId}/stats")
    @Operation(summary = "Get followers/following stats")
    public FollowersStatsResponse getFollowStats(
        @PathVariable FollowTargetType targetType,
        @PathVariable UUID targetId
    ) {
        return followService.getStats(targetType, targetId);
    }

    // ========== Saved Posts ==========

    @PostMapping("/saved-posts")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Save a post")
    public SavedPostResponse savePost(@Valid @RequestBody SavedPostRequest request) {
        return savedPostService.savePost(request);
    }

    @DeleteMapping("/saved-posts/{postId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Unsave a post")
    public void unsavePost(@PathVariable UUID postId) {
        savedPostService.unsavePost(postId);
    }

    @GetMapping("/saved-posts/{postId}/is-saved")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Check if post is saved")
    public boolean isPostSaved(@PathVariable UUID postId) {
        return savedPostService.isPostSaved(postId);
    }

    @GetMapping("/saved-posts")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get all saved posts for current user")
    public Page<SavedPostResponse> getSavedPosts(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size
    ) {
        var savedPosts = savedPostService.getSavedPosts(
            PageRequest.of(page, size, Sort.by("createdAt").descending())
        );

        // Populate post data for each saved post to avoid circular dependency
        return savedPosts.map(sp -> new SavedPostResponse(
            sp.id(),
            sp.userId(),
            sp.postId(),
            postService.getPost(sp.postId()),
            sp.createdAt()
        ));
    }

    // ========== Shares ==========

    @PostMapping("/shares")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Share a post")
    public ShareResponse sharePost(@Valid @RequestBody ShareRequest request) {
        return shareService.sharePost(request);
    }

    @DeleteMapping("/shares/{postId}")
    @PreAuthorize("isAuthenticated()")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Unshare a post")
    public void unsharePost(@PathVariable UUID postId) {
        shareService.unsharePost(postId);
    }

    @GetMapping("/shares/{postId}/is-shared")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Check if post is shared by current user")
    public boolean isPostShared(@PathVariable UUID postId) {
        return shareService.isPostShared(postId);
    }

    @GetMapping("/posts/{postId}/shares/count")
    @Operation(summary = "Get shares count for a post")
    public Long getSharesCount(@PathVariable UUID postId) {
        return shareService.getSharesCount(postId);
    }

    @GetMapping("/posts/{postId}/shares")
    @Operation(summary = "Get list of users who shared a post")
    public Page<ShareResponse> getPostShares(
        @PathVariable UUID postId,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size
    ) {
        return shareService.getPostShares(
            postId,
            PageRequest.of(page, size, Sort.by("createdAt").descending())
        );
    }
}
