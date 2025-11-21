package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.DeliveryAddress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DeliveryAddressRepository extends JpaRepository<DeliveryAddress, UUID> {
    List<DeliveryAddress> findByUserIdOrderByIsDefaultDescCreatedAtDesc(UUID userId);

    Optional<DeliveryAddress> findByIdAndUserId(UUID id, UUID userId);

    Optional<DeliveryAddress> findByUserIdAndIsDefaultTrue(UUID userId);

    @Modifying
    @Query("UPDATE DeliveryAddress da SET da.isDefault = false WHERE da.user.id = :userId AND da.id != :addressId")
    void clearDefaultExcept(UUID userId, UUID addressId);
}
