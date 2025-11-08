package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.AdsDtos.*;
import kg.bishkek.fucent.fusent.enums.CampaignStatus;
import kg.bishkek.fucent.fusent.model.AdCampaign;
import kg.bishkek.fucent.fusent.model.AdEventDaily;
import kg.bishkek.fucent.fusent.repository.AdCampaignRepository;
import kg.bishkek.fucent.fusent.repository.AdEventDailyRepository;
import kg.bishkek.fucent.fusent.repository.MerchantRepository;
import kg.bishkek.fucent.fusent.service.AdCampaignService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdCampaignServiceImpl implements AdCampaignService {
    private final AdCampaignRepository campaignRepository;
    private final AdEventDailyRepository adEventRepository;
    private final MerchantRepository merchantRepository;

    @Override
    @Transactional
    public CampaignResponse createCampaign(CreateCampaignRequest request) {
        var merchant = merchantRepository.findById(request.merchantId())
            .orElseThrow(() -> new IllegalArgumentException("Merchant not found"));

        var campaign = AdCampaign.builder()
            .merchant(merchant)
            .name(request.name())
            .campaignType(request.campaignType())
            .budget(request.budget())
            .spent(BigDecimal.ZERO)
            .status(CampaignStatus.DRAFT)
            .startDate(request.startDate())
            .endDate(request.endDate())
            .targetingJson(request.targetingJson())
            .build();

        campaign = campaignRepository.save(campaign);
        return toCampaignResponse(campaign);
    }

    @Override
    @Transactional
    public CampaignResponse updateCampaign(UUID campaignId, UpdateCampaignRequest request) {
        var campaign = campaignRepository.findById(campaignId)
            .orElseThrow(() -> new IllegalArgumentException("Campaign not found"));

        if (request.name() != null) {
            campaign.setName(request.name());
        }
        if (request.budget() != null) {
            campaign.setBudget(request.budget());
        }
        if (request.status() != null) {
            campaign.setStatus(request.status());
        }
        if (request.startDate() != null) {
            campaign.setStartDate(request.startDate());
        }
        if (request.endDate() != null) {
            campaign.setEndDate(request.endDate());
        }
        if (request.targetingJson() != null) {
            campaign.setTargetingJson(request.targetingJson());
        }

        campaign = campaignRepository.save(campaign);
        return toCampaignResponse(campaign);
    }

    @Override
    @Transactional
    public void deleteCampaign(UUID campaignId) {
        var campaign = campaignRepository.findById(campaignId)
            .orElseThrow(() -> new IllegalArgumentException("Campaign not found"));

        campaign.setStatus(CampaignStatus.CANCELLED);
        campaignRepository.save(campaign);
    }

    @Override
    @Transactional(readOnly = true)
    public CampaignResponse getCampaign(UUID campaignId) {
        var campaign = campaignRepository.findById(campaignId)
            .orElseThrow(() -> new IllegalArgumentException("Campaign not found"));

        return toCampaignResponse(campaign);
    }

    @Override
    @Transactional(readOnly = true)
    public List<CampaignResponse> getCampaignsByMerchant(UUID merchantId) {
        var merchant = merchantRepository.findById(merchantId)
            .orElseThrow(() -> new IllegalArgumentException("Merchant not found"));

        return campaignRepository.findByMerchant(merchant).stream()
            .map(this::toCampaignResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<CampaignResponse> getCampaignsByStatus(CampaignStatus status) {
        return campaignRepository.findByStatus(status).stream()
            .map(this::toCampaignResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void updateCampaignStatus(UUID campaignId, CampaignStatus status) {
        var campaign = campaignRepository.findById(campaignId)
            .orElseThrow(() -> new IllegalArgumentException("Campaign not found"));

        campaign.setStatus(status);
        campaignRepository.save(campaign);
    }

    @Override
    @Transactional
    public void updateBudget(UUID campaignId, UpdateBudgetRequest request) {
        var campaign = campaignRepository.findById(campaignId)
            .orElseThrow(() -> new IllegalArgumentException("Campaign not found"));

        campaign.setBudget(request.newBudget());
        campaignRepository.save(campaign);
    }

    @Override
    @Transactional(readOnly = true)
    public CampaignMetricsResponse getCampaignMetrics(UUID campaignId) {
        var campaign = campaignRepository.findById(campaignId)
            .orElseThrow(() -> new IllegalArgumentException("Campaign not found"));

        var events = adEventRepository.findByCampaignOrderByDayDesc(campaign);

        long totalImpressions = events.stream().mapToLong(e -> e.getImpressions() != null ? e.getImpressions() : 0).sum();
        long totalClicks = events.stream().mapToLong(e -> e.getClicks() != null ? e.getClicks() : 0).sum();
        BigDecimal totalSpend = events.stream()
            .map(e -> e.getSpend() != null ? e.getSpend() : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        double avgCpc = totalClicks > 0 ? totalSpend.divide(BigDecimal.valueOf(totalClicks), 4, RoundingMode.HALF_UP).doubleValue() : 0;
        double avgCpm = totalImpressions > 0 ? totalSpend.divide(BigDecimal.valueOf(totalImpressions / 1000.0), 4, RoundingMode.HALF_UP).doubleValue() : 0;
        double ctr = totalImpressions > 0 ? (double) totalClicks / totalImpressions * 100 : 0;

        return new CampaignMetricsResponse(
            campaignId,
            campaign.getName(),
            totalImpressions,
            totalClicks,
            totalSpend,
            avgCpc,
            avgCpm,
            ctr
        );
    }

    @Override
    @Transactional(readOnly = true)
    public List<AdEventDailyResponse> getCampaignDailyMetrics(UUID campaignId, LocalDate startDate, LocalDate endDate) {
        var campaign = campaignRepository.findById(campaignId)
            .orElseThrow(() -> new IllegalArgumentException("Campaign not found"));

        return adEventRepository.findByCampaignAndDayBetween(campaign, startDate, endDate).stream()
            .map(this::toAdEventResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void recordAdEvent(RecordAdEventRequest request) {
        var campaign = campaignRepository.findById(request.campaignId())
            .orElseThrow(() -> new IllegalArgumentException("Campaign not found"));

        var existingEvent = adEventRepository.findByCampaignAndDay(campaign, request.day());

        AdEventDaily event;
        if (existingEvent.isPresent()) {
            event = existingEvent.get();
            event.setImpressions(event.getImpressions() + request.impressions());
            event.setClicks(event.getClicks() + request.clicks());
            event.setSpend(event.getSpend().add(request.spend()));
        } else {
            event = AdEventDaily.builder()
                .campaign(campaign)
                .day(request.day())
                .impressions(request.impressions())
                .clicks(request.clicks())
                .spend(request.spend())
                .build();
        }

        // Calculate CPC and CPM
        if (event.getClicks() > 0) {
            event.setCpc(event.getSpend().divide(BigDecimal.valueOf(event.getClicks()), 4, RoundingMode.HALF_UP));
        }
        if (event.getImpressions() > 0) {
            event.setCpm(event.getSpend().divide(BigDecimal.valueOf(event.getImpressions() / 1000.0), 4, RoundingMode.HALF_UP));
        }

        adEventRepository.save(event);

        // Update campaign spent
        campaign.setSpent(campaign.getSpent().add(request.spend()));
        campaignRepository.save(campaign);
    }

    private CampaignResponse toCampaignResponse(AdCampaign campaign) {
        return new CampaignResponse(
            campaign.getId(),
            campaign.getMerchant().getId(),
            campaign.getMerchant().getName(),
            campaign.getName(),
            campaign.getCampaignType(),
            campaign.getBudget(),
            campaign.getSpent(),
            campaign.getStatus(),
            campaign.getStartDate(),
            campaign.getEndDate(),
            campaign.getTargetingJson(),
            campaign.getCreatedAt(),
            campaign.getUpdatedAt()
        );
    }

    private AdEventDailyResponse toAdEventResponse(AdEventDaily event) {
        return new AdEventDailyResponse(
            event.getId(),
            event.getCampaign().getId(),
            event.getDay(),
            event.getImpressions(),
            event.getClicks(),
            event.getSpend(),
            event.getCpc(),
            event.getCpm(),
            event.getCreatedAt()
        );
    }
}
