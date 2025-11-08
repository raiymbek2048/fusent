package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.AdCampaign;
import kg.bishkek.fucent.fusent.model.AdEventDaily;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AdEventDailyRepository extends JpaRepository<AdEventDaily, UUID> {
    List<AdEventDaily> findByCampaignOrderByDayDesc(AdCampaign campaign);

    Optional<AdEventDaily> findByCampaignAndDay(AdCampaign campaign, LocalDate day);

    List<AdEventDaily> findByCampaignAndDayBetween(AdCampaign campaign, LocalDate startDay, LocalDate endDay);
}
