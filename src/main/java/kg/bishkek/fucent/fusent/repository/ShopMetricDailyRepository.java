package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.Shop;
import kg.bishkek.fucent.fusent.model.ShopMetricDaily;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ShopMetricDailyRepository extends JpaRepository<ShopMetricDaily, UUID> {
    List<ShopMetricDaily> findByShopOrderByDayDesc(Shop shop);

    Optional<ShopMetricDaily> findByShopAndDay(Shop shop, LocalDate day);

    List<ShopMetricDaily> findByShopAndDayBetween(Shop shop, LocalDate startDay, LocalDate endDay);
}
