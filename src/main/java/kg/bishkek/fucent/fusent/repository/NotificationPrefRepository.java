package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.enums.NotificationChannel;
import kg.bishkek.fucent.fusent.model.NotificationPref;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface NotificationPrefRepository extends JpaRepository<NotificationPref, UUID> {
    Optional<NotificationPref> findByOwnerTypeAndOwnerIdAndChannel(
        String ownerType, UUID ownerId, NotificationChannel channel);

    List<NotificationPref> findByOwnerTypeAndOwnerId(String ownerType, UUID ownerId);

    List<NotificationPref> findByOwnerTypeAndOwnerIdAndEnabledTrue(String ownerType, UUID ownerId);
}
