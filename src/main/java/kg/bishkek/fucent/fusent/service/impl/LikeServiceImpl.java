package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.SocialDtos.*;
import kg.bishkek.fucent.fusent.model.Like;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.LikeRepository;
import kg.bishkek.fucent.fusent.repository.PostRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.LikeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class LikeServiceImpl implements LikeService {
    private final LikeRepository likeRepository;
    private final PostRepository postRepository;
    private final AppUserRepository userRepository;

    @Override
    @Transactional
    public LikeResponse likePost(LikeRequest request) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var user = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        var post = postRepository.findById(request.postId())
            .orElseThrow(() -> new IllegalArgumentException("Post not found"));

        // Check if already liked
        var existingLike = likeRepository.findByUserAndPost(user, post);
        if (existingLike.isPresent()) {
            return toLikeResponse(existingLike.get());
        }

        var like = Like.builder()
            .user(user)
            .post(post)
            .build();

        like = likeRepository.save(like);

        // Update post likes count
        post.setLikesCount(post.getLikesCount() + 1);
        postRepository.save(post);

        return toLikeResponse(like);
    }

    @Override
    @Transactional
    public void unlikePost(UUID postId) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var user = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        var post = postRepository.findById(postId)
            .orElseThrow(() -> new IllegalArgumentException("Post not found"));

        var like = likeRepository.findByUserAndPost(user, post)
            .orElseThrow(() -> new IllegalArgumentException("Like not found"));

        // Update post likes count
        post.setLikesCount(Math.max(0, post.getLikesCount() - 1));
        postRepository.save(post);

        likeRepository.delete(like);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isPostLikedByCurrentUser(UUID postId) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var user = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        var post = postRepository.findById(postId)
            .orElseThrow(() -> new IllegalArgumentException("Post not found"));

        return likeRepository.existsByUserAndPost(user, post);
    }

    @Override
    @Transactional(readOnly = true)
    public Long getLikesCount(UUID postId) {
        var post = postRepository.findById(postId)
            .orElseThrow(() -> new IllegalArgumentException("Post not found"));

        return likeRepository.countByPost(post);
    }

    private LikeResponse toLikeResponse(Like like) {
        return new LikeResponse(
            like.getId(),
            like.getUser().getId(),
            like.getPost().getId(),
            like.getCreatedAt()
        );
    }
}
