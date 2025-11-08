package kg.bishkek.fucent.fusent.repository;



import kg.bishkek.fucent.fusent.model.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;


public interface CartItemRepository extends JpaRepository<CartItem, UUID> {
    Optional<CartItem> findByCartIdAndVariantId(UUID cartId, UUID variantId);
    void deleteByCartId(UUID cartId);
}
