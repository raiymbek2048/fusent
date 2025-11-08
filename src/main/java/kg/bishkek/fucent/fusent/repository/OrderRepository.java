package kg.bishkek.fucent.fusent.repository;



import kg.bishkek.fucent.fusent.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;


public interface OrderRepository extends JpaRepository<Order, UUID> {}