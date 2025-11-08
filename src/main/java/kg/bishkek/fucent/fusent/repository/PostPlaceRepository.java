package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.Post;
import kg.bishkek.fucent.fusent.model.PostPlace;
import kg.bishkek.fucent.fusent.model.Shop;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PostPlaceRepository extends JpaRepository<PostPlace, UUID> {
    List<PostPlace> findByPost(Post post);

    List<PostPlace> findByPlace(Shop place);

    void deleteByPost(Post post);
}
