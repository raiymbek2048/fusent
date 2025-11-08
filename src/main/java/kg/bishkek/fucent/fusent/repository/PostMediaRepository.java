package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.Post;
import kg.bishkek.fucent.fusent.model.PostMedia;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PostMediaRepository extends JpaRepository<PostMedia, UUID> {
    List<PostMedia> findByPostOrderBySortOrderAsc(Post post);

    void deleteByPost(Post post);
}
