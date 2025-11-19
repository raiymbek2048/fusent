package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.enums.ReviewStatus;
import kg.bishkek.fucent.fusent.model.Review;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ReviewRepository extends JpaRepository<Review, UUID> {

    // Find reviews for a shop
    Page<Review> findByShop_IdAndStatus(UUID shopId, ReviewStatus status, Pageable pageable);

    List<Review> findByShop_IdAndStatus(UUID shopId, ReviewStatus status);

    // Find reviews for a product
    Page<Review> findByProduct_IdAndStatus(UUID productId, ReviewStatus status, Pageable pageable);

    List<Review> findByProduct_IdAndStatus(UUID productId, ReviewStatus status);

    // Find reviews by reviewer
    Page<Review> findByReviewerIdAndStatus(UUID reviewerId, ReviewStatus status, Pageable pageable);

    // Check if user already reviewed a shop
    boolean existsByShop_IdAndReviewerId(UUID shopId, UUID reviewerId);

    // Check if user already reviewed a product
    boolean existsByProduct_IdAndReviewerId(UUID productId, UUID reviewerId);

    // Find review by shop and reviewer
    Optional<Review> findByShop_IdAndReviewerId(UUID shopId, UUID reviewerId);

    // Find review by product and reviewer
    Optional<Review> findByProduct_IdAndReviewerId(UUID productId, UUID reviewerId);

    // Count reviews for shop
    long countByShop_IdAndStatus(UUID shopId, ReviewStatus status);

    // Count reviews for product
    long countByProduct_IdAndStatus(UUID productId, ReviewStatus status);

    // Calculate average rating for shop
    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.shop.id = :shopId AND r.status = :status")
    Double findAverageRatingByShopId(@Param("shopId") UUID shopId, @Param("status") ReviewStatus status);

    // Calculate average rating for product
    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.product.id = :productId AND r.status = :status")
    Double findAverageRatingByProductId(@Param("productId") UUID productId, @Param("status") ReviewStatus status);

    // Count reviews by rating for shop
    long countByShop_IdAndStatusAndRating(UUID shopId, ReviewStatus status, Short rating);

    // Count reviews by rating for product
    long countByProduct_IdAndStatusAndRating(UUID productId, ReviewStatus status, Short rating);

    // Count verified purchase reviews for shop
    long countByShop_IdAndStatusAndIsVerifiedPurchase(UUID shopId, ReviewStatus status, Boolean isVerifiedPurchase);

    // Count verified purchase reviews for product
    long countByProduct_IdAndStatusAndIsVerifiedPurchase(UUID productId, ReviewStatus status, Boolean isVerifiedPurchase);
}
