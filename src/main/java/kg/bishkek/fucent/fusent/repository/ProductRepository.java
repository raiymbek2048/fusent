package kg.bishkek.fucent.fusent.repository;



import kg.bishkek.fucent.fusent.model.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;


public interface ProductRepository extends JpaRepository<Product, UUID> {
    // ProductRepository
    Page<Product> findAllByShopId(UUID shopId, Pageable pageable);
    Page<Product> findAllByCategoryId(UUID categoryId, Pageable pageable);
    Page<Product> findAllByNameContainingIgnoreCase(String q, Pageable pageable);


}