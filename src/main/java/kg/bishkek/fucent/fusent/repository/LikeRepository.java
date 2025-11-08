package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Like;
import kg.bishkek.fucent.fusent.model.Post;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface LikeRepository extends JpaRepository<Like, UUID> {
    Optional<Like> findByUserAndPost(AppUser user, Post post);

    List<Like> findByPost(Post post);

    List<Like> findByUser(AppUser user);

    long countByPost(Post post);

    boolean existsByUserAndPost(AppUser user, Post post);
}
