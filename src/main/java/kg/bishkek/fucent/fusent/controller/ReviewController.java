package kg.bishkek.fucent.fusent.controller;

import kg.bishkek.fucent.fusent.dto.ReviewDtos.*;
import kg.bishkek.fucent.fusent.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    /**
     * Create a review for a shop
     * POST /api/reviews/shops
     */
    @PostMapping("/shops")
    public ResponseEntity<ReviewResponse> createShopReview(
            @RequestBody CreateShopReviewRequest request,
            Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        ReviewResponse response = reviewService.createShopReview(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * Create a review for a product
     * POST /api/reviews/products
     */
    @PostMapping("/products")
    public ResponseEntity<ReviewResponse> createProductReview(
            @RequestBody CreateProductReviewRequest request,
            Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        ReviewResponse response = reviewService.createProductReview(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * Get all reviews for a shop
     * GET /api/reviews/shops/{shopId}
     */
    @GetMapping("/shops/{shopId}")
    public ResponseEntity<Page<ReviewResponse>> getShopReviews(
            @PathVariable UUID shopId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "DESC") String sortDirection) {

        Sort.Direction direction = sortDirection.equalsIgnoreCase("ASC") ? Sort.Direction.ASC : Sort.Direction.DESC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));

        Page<ReviewResponse> reviews = reviewService.getShopReviews(shopId, pageable);
        return ResponseEntity.ok(reviews);
    }

    /**
     * Get all reviews for a product
     * GET /api/reviews/products/{productId}
     */
    @GetMapping("/products/{productId}")
    public ResponseEntity<Page<ReviewResponse>> getProductReviews(
            @PathVariable UUID productId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "DESC") String sortDirection) {

        Sort.Direction direction = sortDirection.equalsIgnoreCase("ASC") ? Sort.Direction.ASC : Sort.Direction.DESC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));

        Page<ReviewResponse> reviews = reviewService.getProductReviews(productId, pageable);
        return ResponseEntity.ok(reviews);
    }

    /**
     * Get review summary for a shop
     * GET /api/reviews/shops/{shopId}/summary
     */
    @GetMapping("/shops/{shopId}/summary")
    public ResponseEntity<ReviewSummary> getShopReviewSummary(@PathVariable UUID shopId) {
        ReviewSummary summary = reviewService.getShopReviewSummary(shopId);
        return ResponseEntity.ok(summary);
    }

    /**
     * Get review summary for a product
     * GET /api/reviews/products/{productId}/summary
     */
    @GetMapping("/products/{productId}/summary")
    public ResponseEntity<ReviewSummary> getProductReviewSummary(@PathVariable UUID productId) {
        ReviewSummary summary = reviewService.getProductReviewSummary(productId);
        return ResponseEntity.ok(summary);
    }

    /**
     * Get all reviews by current user
     * GET /api/reviews/me
     */
    @GetMapping("/me")
    public ResponseEntity<Page<ReviewResponse>> getMyReviews(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Authentication authentication) {

        UUID userId = UUID.fromString(authentication.getName());
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

        Page<ReviewResponse> reviews = reviewService.getUserReviews(userId, pageable);
        return ResponseEntity.ok(reviews);
    }

    /**
     * Mark a review as helpful
     * POST /api/reviews/{reviewId}/helpful
     */
    @PostMapping("/{reviewId}/helpful")
    public ResponseEntity<ReviewResponse> markReviewHelpful(
            @PathVariable UUID reviewId,
            @RequestBody MarkHelpfulRequest request,
            Authentication authentication) {

        UUID userId = UUID.fromString(authentication.getName());
        ReviewResponse response = reviewService.markReviewHelpful(reviewId, userId, request);
        return ResponseEntity.ok(response);
    }

    /**
     * Delete a review
     * DELETE /api/reviews/{reviewId}
     */
    @DeleteMapping("/{reviewId}")
    public ResponseEntity<Void> deleteReview(
            @PathVariable UUID reviewId,
            Authentication authentication) {

        UUID userId = UUID.fromString(authentication.getName());
        reviewService.deleteReview(reviewId, userId);
        return ResponseEntity.noContent().build();
    }

    /**
     * Check if user can review a shop
     * GET /api/reviews/shops/{shopId}/can-review
     */
    @GetMapping("/shops/{shopId}/can-review")
    public ResponseEntity<Map<String, Boolean>> canReviewShop(
            @PathVariable UUID shopId,
            Authentication authentication) {

        UUID userId = UUID.fromString(authentication.getName());
        boolean canReview = reviewService.canReviewShop(userId, shopId);

        Map<String, Boolean> response = new HashMap<>();
        response.put("canReview", canReview);
        return ResponseEntity.ok(response);
    }

    /**
     * Check if user can review a product
     * GET /api/reviews/products/{productId}/can-review
     */
    @GetMapping("/products/{productId}/can-review")
    public ResponseEntity<Map<String, Boolean>> canReviewProduct(
            @PathVariable UUID productId,
            Authentication authentication) {

        UUID userId = UUID.fromString(authentication.getName());
        boolean canReview = reviewService.canReviewProduct(userId, productId);

        Map<String, Boolean> response = new HashMap<>();
        response.put("canReview", canReview);
        return ResponseEntity.ok(response);
    }
}
