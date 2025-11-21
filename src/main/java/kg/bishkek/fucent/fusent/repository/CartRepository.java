package kg.bishkek.fucent.fusent.repository;



import kg.bishkek.fucent.fusent.model.Cart;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;
import java.util.UUID;


public interface CartRepository extends JpaRepository<Cart, UUID> {
    Optional<Cart> findByUserId(UUID userId);

    @Query("SELECT DISTINCT c FROM Cart c " +
           "LEFT JOIN FETCH c.items i " +
           "LEFT JOIN FETCH i.variant v " +
           "LEFT JOIN FETCH v.product p " +
           "LEFT JOIN FETCH p.shop " +
           "WHERE c.userId = :userId")
    Optional<Cart> findByUserIdWithItems(UUID userId);

    boolean existsByUserId(UUID userId);
}
