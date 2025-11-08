package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import kg.bishkek.fucent.fusent.enums.CampaignStatus;
import kg.bishkek.fucent.fusent.enums.CampaignType;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;

public class AdsDtos {

    // Campaign DTOs
    public record CreateCampaignRequest(
        @NotNull UUID merchantId,
        @NotBlank String name,
        @NotNull CampaignType campaignType,
        @DecimalMin("0.0") BigDecimal budget,
        Instant startDate,
        Instant endDate,
        Map<String, Object> targetingJson
    ) {}

    public record UpdateCampaignRequest(
        String name,
        BigDecimal budget,
        CampaignStatus status,
        Instant startDate,
        Instant endDate,
        Map<String, Object> targetingJson
    ) {}

    public record CampaignResponse(
        UUID id,
        UUID merchantId,
        String merchantName,
        String name,
        CampaignType campaignType,
        BigDecimal budget,
        BigDecimal spent,
        CampaignStatus status,
        Instant startDate,
        Instant endDate,
        Map<String, Object> targetingJson,
        Instant createdAt,
        Instant updatedAt
    ) {}

    // Campaign Metrics DTOs
    public record CampaignMetricsResponse(
        UUID campaignId,
        String campaignName,
        Long totalImpressions,
        Long totalClicks,
        BigDecimal totalSpend,
        Double avgCpc,
        Double avgCpm,
        Double ctr // Click-through rate
    ) {}

    public record AdEventDailyResponse(
        UUID id,
        UUID campaignId,
        LocalDate day,
        Integer impressions,
        Integer clicks,
        BigDecimal spend,
        BigDecimal cpc,
        BigDecimal cpm,
        Instant createdAt
    ) {}

    public record CampaignDailyMetricsRequest(
        @NotNull UUID campaignId,
        @NotNull LocalDate startDate,
        @NotNull LocalDate endDate
    ) {}

    // Budget and Spend DTOs
    public record UpdateBudgetRequest(
        @NotNull @DecimalMin("0.0") BigDecimal newBudget
    ) {}

    public record RecordAdEventRequest(
        @NotNull UUID campaignId,
        @NotNull LocalDate day,
        @NotNull Integer impressions,
        @NotNull Integer clicks,
        @NotNull @DecimalMin("0.0") BigDecimal spend
    ) {}
}
