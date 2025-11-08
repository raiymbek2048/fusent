package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.ProductMetricDaily;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductMetricDailyRepository extends JpaRepository<ProductMetricDaily, UUID> {
    List<ProductMetricDaily> findByVariantOrderByDayDesc(ProductVariant variant);

    Optional<ProductMetricDaily> findByVariantAndDay(ProductVariant variant, LocalDate day);

    List<ProductMetricDaily> findByVariantAndDayBetween(
        ProductVariant variant, LocalDate startDay, LocalDate endDay);
}
