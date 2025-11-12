package kg.bishkek.fucent.fusent.repository;



import kg.bishkek.fucent.fusent.model.ProductVariant;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;


public interface ProductVariantRepository extends JpaRepository<ProductVariant, UUID> {
    boolean existsByProduct_IdAndSkuIgnoreCase(UUID productId, String sku);
    Page<ProductVariant> findAllByProduct_Id(UUID productId, Pageable pageable);

}