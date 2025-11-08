package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.SavedItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface SavedItemRepository extends JpaRepository<SavedItem, UUID> {
    Optional<SavedItem> findByUserAndProduct(AppUser user, Product product);

    List<SavedItem> findByUser(AppUser user);

    boolean existsByUserAndProduct(AppUser user, Product product);
}
