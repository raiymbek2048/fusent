package kg.bishkek.fucent.fusent.repository;



import kg.bishkek.fucent.fusent.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;
import java.util.UUID;


public interface OrderRepository extends JpaRepository<Order, UUID> {
    List<Order> findByUserIdOrderByCreatedAtDesc(UUID userId);

    List<Order> findByShopIdOrderByCreatedAtDesc(UUID shopId);

    @Query("SELECT o FROM Order o LEFT JOIN FETCH o.shop WHERE o.id = :orderId")
    Optional<Order> findByIdWithShop(UUID orderId);
}