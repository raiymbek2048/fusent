package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.ViewHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ViewHistoryRepository extends JpaRepository<ViewHistory, UUID> {

    @Query("SELECT vh FROM ViewHistory vh " +
           "LEFT JOIN FETCH vh.product p " +
           "LEFT JOIN FETCH p.shop " +
           "LEFT JOIN FETCH p.category " +
           "WHERE vh.user.id = :userId ORDER BY vh.viewedAt DESC")
    List<ViewHistory> findByUserIdOrderByViewedAtDesc(UUID userId);

    Optional<ViewHistory> findByUserIdAndProductId(UUID userId, UUID productId);

    @Modifying
    @Query("DELETE FROM ViewHistory vh WHERE vh.user.id = :userId")
    void deleteAllByUserId(UUID userId);
}
