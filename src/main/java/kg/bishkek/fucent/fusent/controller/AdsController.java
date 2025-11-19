package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.AdsDtos.*;
import kg.bishkek.fucent.fusent.enums.CampaignStatus;
import kg.bishkek.fucent.fusent.service.AdCampaignService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/ads")
@RequiredArgsConstructor
@Tag(name = "Advertising", description = "Ad campaigns and metrics")
public class AdsController {
    private final AdCampaignService adCampaignService;

    // ========== Campaigns ==========

    @PostMapping("/campaigns")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @Operation(summary = "Create a new ad campaign")
    public CampaignResponse createCampaign(@Valid @RequestBody CreateCampaignRequest request) {
        return adCampaignService.createCampaign(request);
    }

    @PutMapping("/campaigns/{campaignId}")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @Operation(summary = "Update an ad campaign")
    public CampaignResponse updateCampaign(
        @PathVariable UUID campaignId,
        @Valid @RequestBody UpdateCampaignRequest request
    ) {
        return adCampaignService.updateCampaign(campaignId, request);
    }

    @DeleteMapping("/campaigns/{campaignId}")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Cancel an ad campaign")
    public void deleteCampaign(@PathVariable UUID campaignId) {
        adCampaignService.deleteCampaign(campaignId);
    }

    @GetMapping("/campaigns/{campaignId}")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @Operation(summary = "Get campaign by ID")
    public CampaignResponse getCampaign(@PathVariable UUID campaignId) {
        return adCampaignService.getCampaign(campaignId);
    }

    @GetMapping("/merchants/{merchantId}/campaigns")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @Operation(summary = "Get all campaigns for a merchant")
    public List<CampaignResponse> getCampaignsByMerchant(@PathVariable UUID merchantId) {
        return adCampaignService.getCampaignsByMerchant(merchantId);
    }

    @GetMapping("/campaigns/status/{status}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Get campaigns by status (admin only)")
    public List<CampaignResponse> getCampaignsByStatus(@PathVariable CampaignStatus status) {
        return adCampaignService.getCampaignsByStatus(status);
    }

    @PatchMapping("/campaigns/{campaignId}/status")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Update campaign status")
    public void updateCampaignStatus(
        @PathVariable UUID campaignId,
        @RequestParam CampaignStatus status
    ) {
        adCampaignService.updateCampaignStatus(campaignId, status);
    }

    @PatchMapping("/campaigns/{campaignId}/budget")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Update campaign budget")
    public void updateBudget(
        @PathVariable UUID campaignId,
        @Valid @RequestBody UpdateBudgetRequest request
    ) {
        adCampaignService.updateBudget(campaignId, request);
    }

    // ========== Metrics ==========

    @GetMapping("/campaigns/{campaignId}/metrics")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @Operation(summary = "Get overall campaign metrics")
    public CampaignMetricsResponse getCampaignMetrics(@PathVariable UUID campaignId) {
        return adCampaignService.getCampaignMetrics(campaignId);
    }

    @GetMapping("/campaigns/{campaignId}/metrics/daily")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @Operation(summary = "Get daily campaign metrics for a date range")
    public List<AdEventDailyResponse> getCampaignDailyMetrics(
        @PathVariable UUID campaignId,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate
    ) {
        return adCampaignService.getCampaignDailyMetrics(campaignId, startDate, endDate);
    }

    @PostMapping("/events")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.ACCEPTED)
    @Operation(summary = "Record ad event (admin/system only)")
    public void recordAdEvent(@Valid @RequestBody RecordAdEventRequest request) {
        adCampaignService.recordAdEvent(request);
    }
}
