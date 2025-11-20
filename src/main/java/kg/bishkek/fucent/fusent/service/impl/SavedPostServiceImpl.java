package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.SocialDtos.SavedPostRequest;
import kg.bishkek.fucent.fusent.dto.SocialDtos.SavedPostResponse;
import kg.bishkek.fucent.fusent.model.SavedPost;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.PostRepository;
import kg.bishkek.fucent.fusent.repository.SavedPostRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.PostService;
import kg.bishkek.fucent.fusent.service.SavedPostService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SavedPostServiceImpl implements SavedPostService {
    private final SavedPostRepository savedPostRepository;
    private final PostRepository postRepository;
    private final AppUserRepository userRepository;
    private final PostService postService;

    @Override
    @Transactional
    public SavedPostResponse savePost(SavedPostRequest request) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var user = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        var post = postRepository.findById(request.postId())
            .orElseThrow(() -> new IllegalArgumentException("Post not found: " + request.postId()));

        // Check if already saved
        var existing = savedPostRepository.findByUserAndPost(user, post);
        if (existing.isPresent()) {
            return toSavedPostResponse(existing.get());
        }

        // Create new saved post
        var savedPost = SavedPost.builder()
            .user(user)
            .post(post)
            .build();

        savedPost = savedPostRepository.save(savedPost);
        return toSavedPostResponse(savedPost);
    }

    @Override
    @Transactional
    public void unsavePost(UUID postId) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var user = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        var post = postRepository.findById(postId)
            .orElseThrow(() -> new IllegalArgumentException("Post not found: " + postId));

        savedPostRepository.deleteByUserAndPost(user, post);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isPostSaved(UUID postId) {
        try {
            var currentUserId = SecurityUtil.currentUserId(userRepository);
            var user = userRepository.findById(currentUserId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

            var post = postRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("Post not found: " + postId));

            return savedPostRepository.existsByUserAndPost(user, post);
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SavedPostResponse> getSavedPosts(Pageable pageable) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var user = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        return savedPostRepository.findByUser(user, pageable)
            .map(this::toSavedPostResponse);
    }

    private SavedPostResponse toSavedPostResponse(SavedPost savedPost) {
        var postResponse = postService.getPost(savedPost.getPost().getId());
        return new SavedPostResponse(
            savedPost.getId(),
            savedPost.getUser().getId(),
            savedPost.getPost().getId(),
            postResponse,
            savedPost.getCreatedAt()
        );
    }
}