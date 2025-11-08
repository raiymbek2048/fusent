package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.enums.CampaignStatus;
import kg.bishkek.fucent.fusent.model.AdCampaign;
import kg.bishkek.fucent.fusent.model.Merchant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface AdCampaignRepository extends JpaRepository<AdCampaign, UUID> {
    List<AdCampaign> findByMerchant(Merchant merchant);

    List<AdCampaign> findByMerchantAndStatus(Merchant merchant, CampaignStatus status);

    List<AdCampaign> findByStatus(CampaignStatus status);
}
