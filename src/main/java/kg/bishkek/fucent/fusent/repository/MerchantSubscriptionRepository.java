package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.enums.SubscriptionStatus;
import kg.bishkek.fucent.fusent.model.Merchant;
import kg.bishkek.fucent.fusent.model.MerchantSubscription;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MerchantSubscriptionRepository extends JpaRepository<MerchantSubscription, UUID> {
    Optional<MerchantSubscription> findByMerchant(Merchant merchant);

    List<MerchantSubscription> findByStatus(SubscriptionStatus status);
}
