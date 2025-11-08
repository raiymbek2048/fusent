package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.Shop;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface ShopRepository extends JpaRepository<Shop, UUID> {
    List<Shop> findByMerchantId(UUID merchantId);
    Page<Shop> findByNameContainingIgnoreCase(String name, Pageable pageable);
}
