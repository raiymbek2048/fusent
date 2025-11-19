package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.ReviewDtos.*;
import kg.bishkek.fucent.fusent.enums.OrderStatus;
import kg.bishkek.fucent.fusent.enums.ReviewStatus;
import kg.bishkek.fucent.fusent.model.*;
import kg.bishkek.fucent.fusent.repository.*;
import kg.bishkek.fucent.fusent.service.ReviewService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReviewServiceImpl implements ReviewService {

    private final ReviewRepository reviewRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final ShopRepository shopRepository;
    private final ProductRepository productRepository;
    private final AppUserRepository appUserRepository;

    @Override
    @Transactional
    public ReviewResponse createShopReview(UUID userId, CreateShopReviewRequest request) {
        // Validate shop exists
        Shop shop = shopRepository.findById(request.getShopId())
                .orElseThrow(() -> new IllegalArgumentException("Shop not found"));

        // Check if user already reviewed this shop
        if (reviewRepository.existsByShop_IdAndReviewerId(request.getShopId(), userId)) {
            throw new IllegalStateException("You have already reviewed this shop");
        }

        // Verify purchase if orderId is provided
        boolean isVerifiedPurchase = false;
        Order order = null;

        if (request.getOrderId() != null) {
            order = orderRepository.findById(request.getOrderId())
                    .orElseThrow(() -> new IllegalArgumentException("Order not found"));

            // Check if order belongs to user and is from this shop
            if (!order.getUserId().equals(userId)) {
                throw new IllegalArgumentException("Order does not belong to you");
            }

            if (!order.getShop().getId().equals(request.getShopId())) {
                throw new IllegalArgumentException("Order is not from this shop");
            }

            // Check if order is fulfilled (completed)
            if (order.getStatus() == OrderStatus.FULFILLED || order.getStatus() == OrderStatus.PAID) {
                isVerifiedPurchase = true;
            }
        }

        // Create review
        Review review = Review.builder()
                .reviewerId(userId)
                .shop(shop)
                .order(order)
                .rating(request.getRating())
                .title(request.getTitle())
                .comment(request.getComment())
                .isVerifiedPurchase(isVerifiedPurchase)
                .status(ReviewStatus.ACTIVE)
                .build();

        review = reviewRepository.save(review);

        // Update shop rating
        updateShopRating(shop.getId());

        return mapToResponse(review);
    }

    @Override
    @Transactional
    public ReviewResponse createProductReview(UUID userId, CreateProductReviewRequest request) {
        // Validate product exists
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        // Check if user already reviewed this product
        if (reviewRepository.existsByProduct_IdAndReviewerId(request.getProductId(), userId)) {
            throw new IllegalStateException("You have already reviewed this product");
        }

        // Verify purchase if orderId is provided
        boolean isVerifiedPurchase = false;
        Order order = null;

        if (request.getOrderId() != null) {
            order = orderRepository.findById(request.getOrderId())
                    .orElseThrow(() -> new IllegalArgumentException("Order not found"));

            // Check if order belongs to user
            if (!order.getUserId().equals(userId)) {
                throw new IllegalArgumentException("Order does not belong to you");
            }

            // Check if order contains this product
            boolean productInOrder = orderItemRepository.findByOrderId(order.getId()).stream()
                    .anyMatch(item -> item.getVariant().getProduct().getId().equals(request.getProductId()));

            if (!productInOrder) {
                throw new IllegalArgumentException("Order does not contain this product");
            }

            // Check if order is fulfilled (completed)
            if (order.getStatus() == OrderStatus.FULFILLED || order.getStatus() == OrderStatus.PAID) {
                isVerifiedPurchase = true;
            }
        }

        // Create review
        Review review = Review.builder()
                .reviewerId(userId)
                .product(product)
                .order(order)
                .rating(request.getRating())
                .title(request.getTitle())
                .comment(request.getComment())
                .isVerifiedPurchase(isVerifiedPurchase)
                .status(ReviewStatus.ACTIVE)
                .build();

        review = reviewRepository.save(review);

        return mapToResponse(review);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ReviewResponse> getShopReviews(UUID shopId, Pageable pageable) {
        Page<Review> reviews = reviewRepository.findByShop_IdAndStatus(shopId, ReviewStatus.ACTIVE, pageable);
        return reviews.map(this::mapToResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ReviewResponse> getProductReviews(UUID productId, Pageable pageable) {
        Page<Review> reviews = reviewRepository.findByProduct_IdAndStatus(productId, ReviewStatus.ACTIVE, pageable);
        return reviews.map(this::mapToResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public ReviewSummary getShopReviewSummary(UUID shopId) {
        Double avgRating = reviewRepository.findAverageRatingByShopId(shopId, ReviewStatus.ACTIVE);
        long totalReviews = reviewRepository.countByShop_IdAndStatus(shopId, ReviewStatus.ACTIVE);

        return ReviewSummary.builder()
                .averageRating(avgRating != null ? avgRating : 0.0)
                .totalReviews((int) totalReviews)
                .fiveStarCount((int) reviewRepository.countByShop_IdAndStatusAndRating(shopId, ReviewStatus.ACTIVE, (short) 5))
                .fourStarCount((int) reviewRepository.countByShop_IdAndStatusAndRating(shopId, ReviewStatus.ACTIVE, (short) 4))
                .threeStarCount((int) reviewRepository.countByShop_IdAndStatusAndRating(shopId, ReviewStatus.ACTIVE, (short) 3))
                .twoStarCount((int) reviewRepository.countByShop_IdAndStatusAndRating(shopId, ReviewStatus.ACTIVE, (short) 2))
                .oneStarCount((int) reviewRepository.countByShop_IdAndStatusAndRating(shopId, ReviewStatus.ACTIVE, (short) 1))
                .verifiedPurchaseCount((int) reviewRepository.countByShop_IdAndStatusAndIsVerifiedPurchase(shopId, ReviewStatus.ACTIVE, true))
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public ReviewSummary getProductReviewSummary(UUID productId) {
        Double avgRating = reviewRepository.findAverageRatingByProductId(productId, ReviewStatus.ACTIVE);
        long totalReviews = reviewRepository.countByProduct_IdAndStatus(productId, ReviewStatus.ACTIVE);

        return ReviewSummary.builder()
                .averageRating(avgRating != null ? avgRating : 0.0)
                .totalReviews((int) totalReviews)
                .fiveStarCount((int) reviewRepository.countByProduct_IdAndStatusAndRating(productId, ReviewStatus.ACTIVE, (short) 5))
                .fourStarCount((int) reviewRepository.countByProduct_IdAndStatusAndRating(productId, ReviewStatus.ACTIVE, (short) 4))
                .threeStarCount((int) reviewRepository.countByProduct_IdAndStatusAndRating(productId, ReviewStatus.ACTIVE, (short) 3))
                .twoStarCount((int) reviewRepository.countByProduct_IdAndStatusAndRating(productId, ReviewStatus.ACTIVE, (short) 2))
                .oneStarCount((int) reviewRepository.countByProduct_IdAndStatusAndRating(productId, ReviewStatus.ACTIVE, (short) 1))
                .verifiedPurchaseCount((int) reviewRepository.countByProduct_IdAndStatusAndIsVerifiedPurchase(productId, ReviewStatus.ACTIVE, true))
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ReviewResponse> getUserReviews(UUID userId, Pageable pageable) {
        Page<Review> reviews = reviewRepository.findByReviewerIdAndStatus(userId, ReviewStatus.ACTIVE, pageable);
        return reviews.map(this::mapToResponse);
    }

    @Override
    @Transactional
    public ReviewResponse markReviewHelpful(UUID reviewId, UUID userId, MarkHelpfulRequest request) {
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new IllegalArgumentException("Review not found"));

        // TODO: Track which users marked it helpful to prevent duplicates
        // For now, just increment/decrement the counter
        if (request.getHelpful()) {
            review.setHelpfulCount(review.getHelpfulCount() + 1);
        } else {
            review.setHelpfulCount(Math.max(0, review.getHelpfulCount() - 1));
        }

        review = reviewRepository.save(review);
        return mapToResponse(review);
    }

    @Override
    @Transactional
    public void deleteReview(UUID reviewId, UUID userId) {
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new IllegalArgumentException("Review not found"));

        // Only the reviewer can delete their review
        if (!review.getReviewerId().equals(userId)) {
            throw new IllegalArgumentException("You can only delete your own reviews");
        }

        review.setStatus(ReviewStatus.DELETED);
        reviewRepository.save(review);

        // Update shop rating if it's a shop review
        if (review.getShop() != null) {
            updateShopRating(review.getShop().getId());
        }
    }

    @Override
    @Transactional(readOnly = true)
    public boolean canReviewShop(UUID userId, UUID shopId) {
        // Check if user has any fulfilled orders from this shop
        return orderRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .anyMatch(order -> order.getShop().getId().equals(shopId) &&
                        (order.getStatus() == OrderStatus.FULFILLED || order.getStatus() == OrderStatus.PAID));
    }

    @Override
    @Transactional(readOnly = true)
    public boolean canReviewProduct(UUID userId, UUID productId) {
        // Check if user has any fulfilled orders containing this product
        return orderRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .filter(order -> order.getStatus() == OrderStatus.FULFILLED || order.getStatus() == OrderStatus.PAID)
                .anyMatch(order -> orderItemRepository.findByOrderId(order.getId()).stream()
                        .anyMatch(item -> item.getVariant().getProduct().getId().equals(productId)));
    }

    private void updateShopRating(UUID shopId) {
        Double avgRating = reviewRepository.findAverageRatingByShopId(shopId, ReviewStatus.ACTIVE);
        long reviewCount = reviewRepository.countByShop_IdAndStatus(shopId, ReviewStatus.ACTIVE);

        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new IllegalArgumentException("Shop not found"));

        shop.setRating(avgRating != null ? BigDecimal.valueOf(avgRating) : BigDecimal.ZERO);
        shop.setReviewCount((int) reviewCount);
        shopRepository.save(shop);
    }

    private ReviewResponse mapToResponse(Review review) {
        AppUser reviewer = appUserRepository.findById(review.getReviewerId()).orElse(null);

        return ReviewResponse.builder()
                .id(review.getId())
                .reviewerId(review.getReviewerId())
                .reviewerName(reviewer != null ? reviewer.getUsername() : "Unknown")
                .shopId(review.getShop() != null ? review.getShop().getId() : null)
                .shopName(review.getShop() != null ? review.getShop().getName() : null)
                .productId(review.getProduct() != null ? review.getProduct().getId() : null)
                .productName(review.getProduct() != null ? review.getProduct().getName() : null)
                .orderId(review.getOrder() != null ? review.getOrder().getId() : null)
                .rating(review.getRating())
                .title(review.getTitle())
                .comment(review.getComment())
                .isVerifiedPurchase(review.getIsVerifiedPurchase())
                .helpfulCount(review.getHelpfulCount())
                .status(review.getStatus())
                .createdAt(review.getCreatedAt())
                .updatedAt(review.getUpdatedAt())
                .build();
    }
}
