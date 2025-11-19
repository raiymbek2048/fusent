package kg.bishkek.fucent.fusent.repository;



import kg.bishkek.fucent.fusent.model.ProductVariant;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;


public interface ProductVariantRepository extends JpaRepository<ProductVariant, UUID> {
    boolean existsByProduct_IdAndSkuIgnoreCase(UUID productId, String sku);
    Page<ProductVariant> findAllByProduct_Id(UUID productId, Pageable pageable);

    // SKU validation - global uniqueness
    boolean existsBySku(String sku);
    boolean existsBySkuIgnoreCase(String sku);
    Optional<ProductVariant> findBySku(String sku);
    Optional<ProductVariant> findBySkuIgnoreCase(String sku);

    // Barcode validation - global uniqueness
    boolean existsByBarcode(String barcode);
    Optional<ProductVariant> findByBarcode(String barcode);

    // Check if SKU exists for a different variant (for updates)
    boolean existsBySkuAndIdNot(String sku, UUID id);
    boolean existsByBarcodeAndIdNot(String barcode, UUID id);
}