package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.enums.Role;
import kg.bishkek.fucent.fusent.model.AppUser;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AppUserRepository extends JpaRepository<AppUser, UUID> {
    Optional<AppUser> findByEmail(String email);

    boolean existsByEmail(String email);

    Page<AppUser> findByRole(Role role, Pageable pageable);

    // Find employees by shop
    List<AppUser> findByShop_IdAndRole(UUID shopId, Role role);

    // Find all employees for a merchant (across all shops)
    @Query("SELECT u FROM AppUser u WHERE u.shop.merchant.id = :merchantId AND u.role = :role")
    List<AppUser> findByShop_Merchant_IdAndRole(@Param("merchantId") UUID merchantId, @Param("role") Role role);
}