package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.PaymentMethod;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PaymentMethodRepository extends JpaRepository<PaymentMethod, UUID> {
    List<PaymentMethod> findByUserIdOrderByIsDefaultDescCreatedAtDesc(UUID userId);

    Optional<PaymentMethod> findByIdAndUserId(UUID id, UUID userId);

    @Modifying
    @Query("UPDATE PaymentMethod pm SET pm.isDefault = false WHERE pm.user.id = :userId AND pm.id != :methodId")
    void clearDefaultExcept(UUID userId, UUID methodId);
}
