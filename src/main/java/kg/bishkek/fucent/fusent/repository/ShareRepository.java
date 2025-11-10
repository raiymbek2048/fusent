package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Post;
import kg.bishkek.fucent.fusent.model.Share;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface ShareRepository extends JpaRepository<Share, UUID> {
    Optional<Share> findByUserAndPost(AppUser user, Post post);

    boolean existsByUserAndPost(AppUser user, Post post);

    Long countByPost(Post post);

    Page<Share> findByPost(Post post, Pageable pageable);

    @Query("SELECT COUNT(s) FROM Share s WHERE s.post.id = :postId")
    Long countByPostId(@Param("postId") UUID postId);
}
