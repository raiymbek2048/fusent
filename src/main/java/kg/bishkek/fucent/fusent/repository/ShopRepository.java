package kg.bishkek.fucent.fusent.repository;



import kg.bishkek.fucent.fusent.model.Shop;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;


public interface ShopRepository extends JpaRepository<Shop, UUID> {}
