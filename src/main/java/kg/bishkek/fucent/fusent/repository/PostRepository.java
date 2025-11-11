package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.enums.OwnerType;
import kg.bishkek.fucent.fusent.enums.PostStatus;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface PostRepository extends JpaRepository<Post, UUID> {
    Page<Post> findByStatusOrderByCreatedAtDesc(PostStatus status, Pageable pageable);

    Page<Post> findByOwnerTypeAndOwnerIdAndStatusOrderByCreatedAtDesc(
        OwnerType ownerType, UUID ownerId, PostStatus status, Pageable pageable);

    List<Post> findByOwnerTypeAndOwnerId(OwnerType ownerType, UUID ownerId);

    @Query("""
        SELECT p FROM Post p
        WHERE p.status = :status
        AND EXISTS (
            SELECT 1 FROM Follow f
            WHERE f.follower = :follower
            AND (
                (f.targetType = kg.bishkek.fucent.fusent.enums.FollowTargetType.MERCHANT
                 AND p.ownerType = kg.bishkek.fucent.fusent.enums.OwnerType.MERCHANT
                 AND p.ownerId = f.targetId)
                OR (f.targetType = kg.bishkek.fucent.fusent.enums.FollowTargetType.USER
                    AND p.ownerType = kg.bishkek.fucent.fusent.enums.OwnerType.USER
                    AND p.ownerId = f.targetId)
            )
        )
        ORDER BY p.createdAt DESC
        """)
    Page<Post> findFollowingFeedByUser(
        @Param("follower") AppUser follower,
        @Param("status") PostStatus status,
        Pageable pageable
    );
}
