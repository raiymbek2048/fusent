package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.enums.OwnerType;
import kg.bishkek.fucent.fusent.enums.PostStatus;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface PostRepository extends JpaRepository<Post, UUID> {
    Page<Post> findByStatus(PostStatus status, Pageable pageable);

    Page<Post> findByOwnerTypeAndOwnerIdAndStatus(
        OwnerType ownerType, UUID ownerId, PostStatus status, Pageable pageable);

    List<Post> findByOwnerTypeAndOwnerId(OwnerType ownerType, UUID ownerId);

    @Query("""
        SELECT DISTINCT p FROM Post p
        WHERE EXISTS (
            SELECT 1 FROM Follow f
            WHERE f.follower.id = :followerId
            AND (
                (f.targetType = kg.bishkek.fucent.fusent.enums.FollowTargetType.MERCHANT
                 AND p.ownerType = kg.bishkek.fucent.fusent.enums.OwnerType.MERCHANT
                 AND p.ownerId = f.targetId)
                OR
                (f.targetType = kg.bishkek.fucent.fusent.enums.FollowTargetType.USER
                 AND p.ownerType = kg.bishkek.fucent.fusent.enums.OwnerType.USER
                 AND p.ownerId = f.targetId)
            )
        )
        AND p.status = :status
        """)
    Page<Post> findFollowingFeedByUser(
        @Param("followerId") UUID followerId,
        @Param("status") PostStatus status,
        Pageable pageable
    );

    // Trending posts queries
    @Query("SELECT p FROM Post p WHERE p.status = :status ORDER BY p.trendingScore DESC, p.createdAt DESC")
    Page<Post> findTrendingPosts(@Param("status") PostStatus status, Pageable pageable);

    @Query("SELECT p FROM Post p WHERE p.status = :status AND p.createdAt >= :since ORDER BY p.trendingScore DESC, p.createdAt DESC")
    Page<Post> findTrendingPostsWithinTimeWindow(
        @Param("status") PostStatus status,
        @Param("since") Instant since,
        Pageable pageable
    );

    @Query("SELECT p FROM Post p WHERE p.status = :status")
    List<Post> findAllActivePostsForScoreUpdate(@Param("status") PostStatus status);

    @Modifying
    @Query("UPDATE Post p SET p.viewsCount = p.viewsCount + 1 WHERE p.id = :postId")
    void incrementViewCount(@Param("postId") UUID postId);
}
