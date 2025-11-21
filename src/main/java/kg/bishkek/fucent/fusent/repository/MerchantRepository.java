package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.enums.MerchantApprovalStatus;
import kg.bishkek.fucent.fusent.model.Merchant;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface MerchantRepository extends JpaRepository<Merchant, UUID> {
    Optional<Merchant> findByOwnerUserId(UUID ownerUserId);

    Page<Merchant> findByApprovalStatus(MerchantApprovalStatus status, Pageable pageable);

    long countByApprovalStatus(MerchantApprovalStatus status);
}
