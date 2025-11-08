package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.AnalyticEventRaw;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface AnalyticEventRawRepository extends JpaRepository<AnalyticEventRaw, UUID> {
    Page<AnalyticEventRaw> findByEventTypeOrderByCreatedAtDesc(String eventType, Pageable pageable);

    List<AnalyticEventRaw> findByUserIdAndEventType(UUID userId, String eventType);

    List<AnalyticEventRaw> findByTargetTypeAndTargetId(String targetType, UUID targetId);

    void deleteByCreatedAtBefore(Instant cutoffDate);
}
