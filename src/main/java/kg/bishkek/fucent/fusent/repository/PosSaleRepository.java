package kg.bishkek.fucent.fusent.repository;



import kg.bishkek.fucent.fusent.model.PosSale;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;


@Repository
public interface PosSaleRepository extends JpaRepository<PosSale, UUID> {
    boolean existsByReceiptNumberAndShopId(String receiptNumber, UUID shopId);
}