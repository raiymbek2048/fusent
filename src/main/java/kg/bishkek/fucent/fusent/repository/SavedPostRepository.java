package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Post;
import kg.bishkek.fucent.fusent.model.SavedPost;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface SavedPostRepository extends JpaRepository<SavedPost, UUID> {
    Optional<SavedPost> findByUserAndPost(AppUser user, Post post);

    Page<SavedPost> findByUser(AppUser user, Pageable pageable);

    boolean existsByUserAndPost(AppUser user, Post post);

    void deleteByUserAndPost(AppUser user, Post post);
}
