package kg.bishkek.fucent.fusent.repository;



import kg.bishkek.fucent.fusent.model.ProductVariant;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;


public interface ProductVariantRepository extends JpaRepository<ProductVariant, UUID> {
    boolean existsByProductIdAndSkuIgnoreCase(UUID productId, String sku);
    Page<ProductVariant> findAllByProductId(UUID productId, Pageable pageable);

}