package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.SocialDtos.*;
import kg.bishkek.fucent.fusent.enums.OwnerType;
import kg.bishkek.fucent.fusent.model.Comment;
import kg.bishkek.fucent.fusent.model.Post;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.CommentRepository;
import kg.bishkek.fucent.fusent.repository.OrderRepository;
import kg.bishkek.fucent.fusent.repository.PostRepository;
import kg.bishkek.fucent.fusent.repository.ShopRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.CommentService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CommentServiceImpl implements CommentService {
    private final CommentRepository commentRepository;
    private final PostRepository postRepository;
    private final AppUserRepository userRepository;
    private final OrderRepository orderRepository;
    private final ShopRepository shopRepository;

    @Override
    @Transactional
    public CommentResponse createComment(CreateCommentRequest request) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var user = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        var post = postRepository.findById(request.postId())
            .orElseThrow(() -> new IllegalArgumentException("Post not found"));

        // Check if this is a verified purchase
        boolean isVerifiedPurchase = checkVerifiedPurchase(currentUserId, post);

        var comment = Comment.builder()
            .post(post)
            .user(user)
            .text(request.text())
            .isFlagged(false)
            .verifiedPurchase(isVerifiedPurchase)
            .build();

        comment = commentRepository.save(comment);

        // Update post comments count
        post.setCommentsCount(post.getCommentsCount() + 1);
        postRepository.save(post);

        return toCommentResponse(comment);
    }

    @Override
    @Transactional
    public void deleteComment(UUID commentId) {
        var comment = commentRepository.findById(commentId)
            .orElseThrow(() -> new IllegalArgumentException("Comment not found"));

        var currentUserId = SecurityUtil.currentUserId(userRepository);
        if (!comment.getUser().getId().equals(currentUserId)) {
            throw new IllegalArgumentException("You can only delete your own comments");
        }

        var post = comment.getPost();
        post.setCommentsCount(Math.max(0, post.getCommentsCount() - 1));
        postRepository.save(post);

        commentRepository.delete(comment);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<CommentResponse> getCommentsByPost(UUID postId, Pageable pageable) {
        var post = postRepository.findById(postId)
            .orElseThrow(() -> new IllegalArgumentException("Post not found"));

        return commentRepository.findByPostOrderByCreatedAtDesc(post, pageable)
            .map(this::toCommentResponse);
    }

    @Override
    @Transactional
    public void flagComment(UUID commentId) {
        var comment = commentRepository.findById(commentId)
            .orElseThrow(() -> new IllegalArgumentException("Comment not found"));

        comment.setIsFlagged(true);
        commentRepository.save(comment);
    }

    private CommentResponse toCommentResponse(Comment comment) {
        return new CommentResponse(
            comment.getId(),
            comment.getPost().getId(),
            comment.getUser().getId(),
            comment.getUser().getEmail(),
            comment.getText(),
            comment.getIsFlagged(),
            comment.getVerifiedPurchase(),
            comment.getCreatedAt(),
            comment.getUpdatedAt()
        );
    }

    private boolean checkVerifiedPurchase(UUID userId, Post post) {
        // Only check for shop posts
        if (post.getOwnerType() != OwnerType.SHOP) {
            return false;
        }

        // Check if user has any paid/fulfilled orders from this shop
        var shop = shopRepository.findById(post.getOwnerId()).orElse(null);
        if (shop == null) {
            return false;
        }

        // Check if user has completed orders from this shop
        return orderRepository.findAll().stream()
            .anyMatch(order ->
                order.getUserId().equals(userId) &&
                order.getShop().getId().equals(shop.getId()) &&
                (order.getStatus().equals("paid") || order.getStatus().equals("fulfilled"))
            );
    }
}
