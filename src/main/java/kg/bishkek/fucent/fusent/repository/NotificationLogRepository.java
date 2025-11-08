package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.enums.NotificationStatus;
import kg.bishkek.fucent.fusent.model.NotificationLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface NotificationLogRepository extends JpaRepository<NotificationLog, UUID> {
    Page<NotificationLog> findByRecipientOrderByCreatedAtDesc(String recipient, Pageable pageable);

    List<NotificationLog> findByStatus(NotificationStatus status);

    List<NotificationLog> findByStatusAndAttemptsLessThan(NotificationStatus status, Integer maxAttempts);
}
