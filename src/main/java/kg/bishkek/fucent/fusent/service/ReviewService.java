package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.ReviewDtos.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface ReviewService {

    /**
     * Create a review for a shop
     * Checks if user has purchased from this shop if orderId is provided
     */
    ReviewResponse createShopReview(UUID userId, CreateShopReviewRequest request);

    /**
     * Create a review for a product
     * Checks if user has purchased this product if orderId is provided
     */
    ReviewResponse createProductReview(UUID userId, CreateProductReviewRequest request);

    /**
     * Get all reviews for a shop with pagination
     */
    Page<ReviewResponse> getShopReviews(UUID shopId, Pageable pageable);

    /**
     * Get all reviews for a product with pagination
     */
    Page<ReviewResponse> getProductReviews(UUID productId, Pageable pageable);

    /**
     * Get review summary statistics for a shop
     */
    ReviewSummary getShopReviewSummary(UUID shopId);

    /**
     * Get review summary statistics for a product
     */
    ReviewSummary getProductReviewSummary(UUID productId);

    /**
     * Get all reviews by a specific user
     */
    Page<ReviewResponse> getUserReviews(UUID userId, Pageable pageable);

    /**
     * Mark a review as helpful
     */
    ReviewResponse markReviewHelpful(UUID reviewId, UUID userId, MarkHelpfulRequest request);

    /**
     * Delete a review (soft delete by changing status)
     */
    void deleteReview(UUID reviewId, UUID userId);

    /**
     * Check if user can review a shop (has made a purchase)
     */
    boolean canReviewShop(UUID userId, UUID shopId);

    /**
     * Check if user can review a product (has purchased it)
     */
    boolean canReviewProduct(UUID userId, UUID productId);
}
