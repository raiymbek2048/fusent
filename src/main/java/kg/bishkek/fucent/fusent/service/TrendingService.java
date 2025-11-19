package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.model.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

/**
 * Service for calculating and managing trending scores for posts
 */
public interface TrendingService {

    /**
     * Calculate trending score for a specific post based on:
     * - Likes (weight: 10)
     * - Views (weight: 1)
     * - Comments (weight: 15)
     * - Shares (weight: 20)
     * - Time decay factor
     *
     * Formula: TrendingScore = (likes*10 + views*1 + comments*15 + shares*20) / (ageInHours + 2)^1.5
     *
     * @param post Post to calculate score for
     * @return Calculated trending score
     */
    double calculateTrendingScore(Post post);

    /**
     * Update trending score for a specific post
     *
     * @param postId Post ID
     */
    void updateTrendingScore(UUID postId);

    /**
     * Update trending scores for all active posts
     * Should be run periodically (e.g., every hour)
     */
    void updateAllTrendingScores();

    /**
     * Increment view count and update trending score
     *
     * @param postId Post ID
     */
    void incrementViewCount(UUID postId);

    /**
     * Get trending posts (paginated)
     *
     * @param pageable Pagination parameters
     * @return Page of trending posts
     */
    Page<Post> getTrendingPosts(Pageable pageable);

    /**
     * Get trending posts within time window (e.g., last 24 hours, last week)
     *
     * @param hoursAgo Number of hours to look back
     * @param pageable Pagination parameters
     * @return Page of trending posts within time window
     */
    Page<Post> getTrendingPostsWithinTimeWindow(int hoursAgo, Pageable pageable);
}
