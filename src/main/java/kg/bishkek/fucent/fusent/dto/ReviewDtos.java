package kg.bishkek.fucent.fusent.dto;

import kg.bishkek.fucent.fusent.enums.ReviewStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

public class ReviewDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateShopReviewRequest {
        private UUID shopId;
        private UUID orderId; // Optional, for verified purchase
        private Short rating; // 1-5
        private String title;
        private String comment;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateProductReviewRequest {
        private UUID productId;
        private UUID orderId; // Optional, for verified purchase
        private Short rating; // 1-5
        private String title;
        private String comment;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ReviewResponse {
        private UUID id;
        private UUID reviewerId;
        private String reviewerName;

        // Either shopId or productId will be set
        private UUID shopId;
        private String shopName;

        private UUID productId;
        private String productName;

        private UUID orderId;

        private Short rating;
        private String title;
        private String comment;

        private Boolean isVerifiedPurchase;
        private Integer helpfulCount;

        private ReviewStatus status;
        private Instant createdAt;
        private Instant updatedAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ReviewSummary {
        private Double averageRating;
        private Integer totalReviews;
        private Integer fiveStarCount;
        private Integer fourStarCount;
        private Integer threeStarCount;
        private Integer twoStarCount;
        private Integer oneStarCount;
        private Integer verifiedPurchaseCount;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MarkHelpfulRequest {
        private Boolean helpful; // true to mark helpful, false to unmark
    }
}
