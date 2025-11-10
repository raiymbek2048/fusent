package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.SocialDtos.ShareRequest;
import kg.bishkek.fucent.fusent.dto.SocialDtos.ShareResponse;
import kg.bishkek.fucent.fusent.model.Share;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.PostRepository;
import kg.bishkek.fucent.fusent.repository.ShareRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.ShareService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ShareServiceImpl implements ShareService {
    private final ShareRepository shareRepository;
    private final PostRepository postRepository;
    private final AppUserRepository userRepository;

    @Override
    @Transactional
    public ShareResponse sharePost(ShareRequest request) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var user = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        var post = postRepository.findById(request.postId())
            .orElseThrow(() -> new IllegalArgumentException("Post not found: " + request.postId()));

        // Check if already shared
        var existing = shareRepository.findByUserAndPost(user, post);
        if (existing.isPresent()) {
            return toShareResponse(existing.get());
        }

        // Create new share
        var share = Share.builder()
            .user(user)
            .post(post)
            .build();

        share = shareRepository.save(share);

        // Update shares count
        post.setSharesCount(post.getSharesCount() + 1);
        postRepository.save(post);

        return toShareResponse(share);
    }

    @Override
    @Transactional
    public void unsharePost(UUID postId) {
        var currentUserId = SecurityUtil.currentUserId(userRepository);
        var user = userRepository.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        var post = postRepository.findById(postId)
            .orElseThrow(() -> new IllegalArgumentException("Post not found: " + postId));

        var share = shareRepository.findByUserAndPost(user, post);
        if (share.isPresent()) {
            shareRepository.delete(share.get());

            // Update shares count
            post.setSharesCount(Math.max(0, post.getSharesCount() - 1));
            postRepository.save(post);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isPostShared(UUID postId) {
        try {
            var currentUserId = SecurityUtil.currentUserId(userRepository);
            var user = userRepository.findById(currentUserId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

            var post = postRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("Post not found: " + postId));

            return shareRepository.existsByUserAndPost(user, post);
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    @Transactional(readOnly = true)
    public Long getSharesCount(UUID postId) {
        return shareRepository.countByPostId(postId);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ShareResponse> getPostShares(UUID postId, Pageable pageable) {
        var post = postRepository.findById(postId)
            .orElseThrow(() -> new IllegalArgumentException("Post not found: " + postId));

        return shareRepository.findByPost(post, pageable)
            .map(this::toShareResponse);
    }

    private ShareResponse toShareResponse(Share share) {
        return new ShareResponse(
            share.getId(),
            share.getUser().getId(),
            share.getUser().getEmail(),
            share.getPost().getId(),
            share.getCreatedAt()
        );
    }
}
