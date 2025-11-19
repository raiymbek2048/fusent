package kg.bishkek.fucent.fusent.repository;



import kg.bishkek.fucent.fusent.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;


public interface CategoryRepository extends JpaRepository<Category, UUID> {
    /**
     * Find category by name (for import/export)
     */
    Optional<Category> findByName(String name);
}