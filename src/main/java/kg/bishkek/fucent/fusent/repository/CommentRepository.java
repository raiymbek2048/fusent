package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Comment;
import kg.bishkek.fucent.fusent.model.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface CommentRepository extends JpaRepository<Comment, UUID> {
    Page<Comment> findByPostOrderByCreatedAtDesc(Post post, Pageable pageable);

    List<Comment> findByUser(AppUser user);

    List<Comment> findByPostAndVerifiedPurchaseTrue(Post post);

    long countByPost(Post post);
}
