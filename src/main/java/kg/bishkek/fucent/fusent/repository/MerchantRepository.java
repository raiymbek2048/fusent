package kg.bishkek.fucent.fusent.repository;



import kg.bishkek.fucent.fusent.model.Merchant;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;


public interface MerchantRepository extends JpaRepository<Merchant, UUID> {}
