package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.Post;
import kg.bishkek.fucent.fusent.model.PostTag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PostTagRepository extends JpaRepository<PostTag, UUID> {
    List<PostTag> findByPost(Post post);

    List<PostTag> findByTag(String tag);

    void deleteByPost(Post post);
}
