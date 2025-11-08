package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.enums.NotificationChannel;
import kg.bishkek.fucent.fusent.model.NotificationTemplate;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface NotificationTemplateRepository extends JpaRepository<NotificationTemplate, UUID> {
    Optional<NotificationTemplate> findByTemplateKeyAndChannelAndLocaleAndIsActiveTrue(
        String templateKey, NotificationChannel channel, String locale);

    List<NotificationTemplate> findByTemplateKeyAndIsActiveTrue(String templateKey);
}
