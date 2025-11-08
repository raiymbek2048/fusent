package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.AdsDtos.*;
import kg.bishkek.fucent.fusent.enums.CampaignStatus;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface AdCampaignService {
    CampaignResponse createCampaign(CreateCampaignRequest request);

    CampaignResponse updateCampaign(UUID campaignId, UpdateCampaignRequest request);

    void deleteCampaign(UUID campaignId);

    CampaignResponse getCampaign(UUID campaignId);

    List<CampaignResponse> getCampaignsByMerchant(UUID merchantId);

    List<CampaignResponse> getCampaignsByStatus(CampaignStatus status);

    void updateCampaignStatus(UUID campaignId, CampaignStatus status);

    void updateBudget(UUID campaignId, UpdateBudgetRequest request);

    // Metrics
    CampaignMetricsResponse getCampaignMetrics(UUID campaignId);

    List<AdEventDailyResponse> getCampaignDailyMetrics(UUID campaignId, LocalDate startDate, LocalDate endDate);

    void recordAdEvent(RecordAdEventRequest request);
}
