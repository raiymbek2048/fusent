package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.enums.PostStatus;
import kg.bishkek.fucent.fusent.model.Post;
import kg.bishkek.fucent.fusent.repository.PostRepository;
import kg.bishkek.fucent.fusent.service.TrendingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class TrendingServiceImpl implements TrendingService {

    private final PostRepository postRepository;

    // Weights for different engagement metrics
    private static final double LIKES_WEIGHT = 10.0;
    private static final double VIEWS_WEIGHT = 1.0;
    private static final double COMMENTS_WEIGHT = 15.0;
    private static final double SHARES_WEIGHT = 20.0;

    // Time decay factor
    private static final double TIME_DECAY_EXPONENT = 1.5;
    private static final double TIME_OFFSET_HOURS = 2.0; // Prevents division by zero for new posts

    @Override
    public double calculateTrendingScore(Post post) {
        if (post == null || post.getCreatedAt() == null) {
            return 0.0;
        }

        // Calculate engagement score
        double engagementScore =
                (post.getLikesCount() != null ? post.getLikesCount() : 0) * LIKES_WEIGHT +
                (post.getViewsCount() != null ? post.getViewsCount() : 0) * VIEWS_WEIGHT +
                (post.getCommentsCount() != null ? post.getCommentsCount() : 0) * COMMENTS_WEIGHT +
                (post.getSharesCount() != null ? post.getSharesCount() : 0) * SHARES_WEIGHT;

        // Calculate time decay
        Duration age = Duration.between(post.getCreatedAt(), Instant.now());
        double ageInHours = age.toHours() + (age.toMinutesPart() / 60.0);
        double timeDecay = Math.pow(ageInHours + TIME_OFFSET_HOURS, TIME_DECAY_EXPONENT);

        // Calculate final score
        double trendingScore = engagementScore / timeDecay;

        log.debug("Calculated trending score for post {}: engagement={}, age={}h, decay={}, score={}",
                post.getId(), engagementScore, ageInHours, timeDecay, trendingScore);

        return trendingScore;
    }

    @Override
    @Transactional
    public void updateTrendingScore(UUID postId) {
        postRepository.findById(postId).ifPresent(post -> {
            double score = calculateTrendingScore(post);
            post.setTrendingScore(BigDecimal.valueOf(score).setScale(4, RoundingMode.HALF_UP));
            postRepository.save(post);
            log.debug("Updated trending score for post {}: {}", postId, score);
        });
    }

    @Override
    @Transactional
    @Scheduled(cron = "0 0 * * * *") // Every hour
    public void updateAllTrendingScores() {
        log.info("Starting scheduled trending score update for all active posts");

        List<Post> activePosts = postRepository.findAllActivePostsForScoreUpdate(PostStatus.ACTIVE);
        int updated = 0;

        for (Post post : activePosts) {
            try {
                double score = calculateTrendingScore(post);
                post.setTrendingScore(BigDecimal.valueOf(score).setScale(4, RoundingMode.HALF_UP));
                postRepository.save(post);
                updated++;
            } catch (Exception e) {
                log.error("Failed to update trending score for post {}: {}", post.getId(), e.getMessage());
            }
        }

        log.info("Completed trending score update: {} posts updated out of {}", updated, activePosts.size());
    }

    @Override
    @Transactional
    public void incrementViewCount(UUID postId) {
        postRepository.incrementViewCount(postId);
        // Update trending score asynchronously to avoid performance impact
        updateTrendingScore(postId);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Post> getTrendingPosts(Pageable pageable) {
        return postRepository.findTrendingPosts(PostStatus.ACTIVE, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Post> getTrendingPostsWithinTimeWindow(int hoursAgo, Pageable pageable) {
        Instant since = Instant.now().minus(Duration.ofHours(hoursAgo));
        return postRepository.findTrendingPostsWithinTimeWindow(PostStatus.ACTIVE, since, pageable);
    }
}
