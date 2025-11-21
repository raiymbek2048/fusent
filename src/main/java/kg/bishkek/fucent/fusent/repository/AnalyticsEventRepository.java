package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.AnalyticsEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Repository
public interface AnalyticsEventRepository extends JpaRepository<AnalyticsEvent, UUID> {

    // Count events by type for a specific owner
    @Query("SELECT COUNT(e) FROM AnalyticsEvent e WHERE e.ownerType = :ownerType AND e.ownerId = :ownerId AND e.eventType = :eventType AND e.createdAt >= :from")
    long countByOwnerAndType(@Param("ownerType") String ownerType, @Param("ownerId") UUID ownerId,
                             @Param("eventType") String eventType, @Param("from") Instant from);

    // Count unique users for owner
    @Query("SELECT COUNT(DISTINCT e.userId) FROM AnalyticsEvent e WHERE e.ownerType = :ownerType AND e.ownerId = :ownerId AND e.createdAt >= :from")
    long countUniqueVisitors(@Param("ownerType") String ownerType, @Param("ownerId") UUID ownerId, @Param("from") Instant from);

    // Get events by target
    List<AnalyticsEvent> findByTargetTypeAndTargetIdAndCreatedAtAfter(String targetType, UUID targetId, Instant after);

    // Get events for owner (for seller dashboard)
    List<AnalyticsEvent> findByOwnerTypeAndOwnerIdAndCreatedAtAfterOrderByCreatedAtDesc(
            String ownerType, UUID ownerId, Instant after);

    // Count by event type for admin dashboard
    @Query("SELECT e.eventType, COUNT(e) FROM AnalyticsEvent e WHERE e.createdAt >= :from GROUP BY e.eventType")
    List<Object[]> countByEventType(@Param("from") Instant from);
}
