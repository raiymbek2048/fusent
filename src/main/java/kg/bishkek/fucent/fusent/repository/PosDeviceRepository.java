package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.enums.PosDeviceStatus;
import kg.bishkek.fucent.fusent.model.PosDevice;
import kg.bishkek.fucent.fusent.model.Shop;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PosDeviceRepository extends JpaRepository<PosDevice, UUID> {
    Optional<PosDevice> findByDeviceId(String deviceId);

    List<PosDevice> findByShop(Shop shop);

    List<PosDevice> findByShopAndStatus(Shop shop, PosDeviceStatus status);
}
