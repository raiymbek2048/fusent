package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.enums.OwnerType;
import kg.bishkek.fucent.fusent.enums.PostStatus;
import kg.bishkek.fucent.fusent.model.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PostRepository extends JpaRepository<Post, UUID> {
    Page<Post> findByStatusOrderByCreatedAtDesc(PostStatus status, Pageable pageable);

    Page<Post> findByOwnerTypeAndOwnerIdAndStatusOrderByCreatedAtDesc(
        OwnerType ownerType, UUID ownerId, PostStatus status, Pageable pageable);

    List<Post> findByOwnerTypeAndOwnerId(OwnerType ownerType, UUID ownerId);
}
