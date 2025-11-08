package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.AuditLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface AuditLogRepository extends JpaRepository<AuditLog, UUID> {
    Page<AuditLog> findByActorIdOrderByCreatedAtDesc(UUID actorId, Pageable pageable);

    Page<AuditLog> findByEntityAndEntityIdOrderByCreatedAtDesc(
        String entity, String entityId, Pageable pageable);

    List<AuditLog> findByAction(String action);
}
