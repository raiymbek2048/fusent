package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.AnalyticsDtos.*;
import kg.bishkek.fucent.fusent.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/analytics")
@RequiredArgsConstructor
@Tag(name = "Analytics", description = "Analytics and metrics tracking")
public class AnalyticsController {
    private final AnalyticsService analyticsService;

    // ========== Event Tracking ==========

    @PostMapping("/events")
    @ResponseStatus(HttpStatus.ACCEPTED)
    @Operation(summary = "Track an analytics event")
    public void trackEvent(@Valid @RequestBody TrackEventRequest request) {
        analyticsService.trackEvent(request);
    }

    // ========== Shop Metrics ==========

    @GetMapping("/shops/{shopId}/metrics/daily")
    @PreAuthorize("hasRole('SELLER') or hasRole('ADMIN')")
    @Operation(summary = "Get shop metrics for a specific day")
    public ShopMetricDailyResponse getShopMetricsForDay(
        @PathVariable UUID shopId,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate day
    ) {
        return analyticsService.getShopMetricsForDay(shopId, day);
    }

    @GetMapping("/shops/{shopId}/metrics/range")
    @PreAuthorize("hasRole('SELLER') or hasRole('ADMIN')")
    @Operation(summary = "Get shop metrics for a date range")
    public List<ShopMetricDailyResponse> getShopMetricsRange(
        @PathVariable UUID shopId,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate
    ) {
        return analyticsService.getShopMetricsRange(shopId, startDate, endDate);
    }

    @GetMapping("/shops/{shopId}/metrics/summary")
    @PreAuthorize("hasRole('SELLER') or hasRole('ADMIN')")
    @Operation(summary = "Get shop metrics summary for a date range")
    public ShopMetricsSummaryResponse getShopMetricsSummary(
        @PathVariable UUID shopId,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate
    ) {
        return analyticsService.getShopMetricsSummary(shopId, startDate, endDate);
    }

    // ========== Product Metrics ==========

    @GetMapping("/products/variants/{variantId}/metrics/daily")
    @PreAuthorize("hasRole('SELLER') or hasRole('ADMIN')")
    @Operation(summary = "Get product variant metrics for a specific day")
    public ProductMetricDailyResponse getProductMetricsForDay(
        @PathVariable UUID variantId,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate day
    ) {
        return analyticsService.getProductMetricsForDay(variantId, day);
    }

    @GetMapping("/products/variants/{variantId}/metrics/range")
    @PreAuthorize("hasRole('SELLER') or hasRole('ADMIN')")
    @Operation(summary = "Get product variant metrics for a date range")
    public List<ProductMetricDailyResponse> getProductMetricsRange(
        @PathVariable UUID variantId,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate
    ) {
        return analyticsService.getProductMetricsRange(variantId, startDate, endDate);
    }

    @GetMapping("/shops/{shopId}/products/top")
    @PreAuthorize("hasRole('SELLER') or hasRole('ADMIN')")
    @Operation(summary = "Get top performing products for a shop")
    public List<ProductMetricDailyResponse> getTopProducts(
        @PathVariable UUID shopId,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
        @RequestParam(defaultValue = "revenue") String sortBy,
        @RequestParam(defaultValue = "10") Integer limit
    ) {
        return analyticsService.getTopProducts(shopId, startDate, endDate, sortBy, limit);
    }
}
