package kg.bishkek.fucent.fusent.controller;

import kg.bishkek.fucent.fusent.dto.AnalyticsDtos.*;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Merchant;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.MerchantRepository;
import kg.bishkek.fucent.fusent.service.AnalyticsService;
import kg.bishkek.fucent.fusent.service.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/analytics")
@RequiredArgsConstructor
public class AnalyticsController {

    private final AnalyticsService analyticsService;
    private final JwtService jwtService;
    private final AppUserRepository userRepository;
    private final MerchantRepository merchantRepository;

    @PostMapping("/track")
    public ResponseEntity<?> trackEvent(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody TrackEventRequest request) {
        UUID userId = extractUserId(authHeader);
        analyticsService.trackEvent(request, userId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    @GetMapping("/seller")
    public ResponseEntity<?> getSellerAnalytics(
            @RequestHeader("Authorization") String authHeader,
            @RequestParam(defaultValue = "week") String period) {
        UUID userId = extractUserId(authHeader);
        Merchant merchant = merchantRepository.findByOwnerUserId(userId).orElse(null);
        if (merchant == null) {
            return ResponseEntity.status(403).body(Map.of("error", "Not a seller"));
        }
        return ResponseEntity.ok(analyticsService.getSellerAnalytics(merchant.getId(), period));
    }

    @GetMapping("/product/{productId}")
    public ResponseEntity<?> getProductAnalytics(
            @PathVariable UUID productId,
            @RequestParam(defaultValue = "week") String period) {
        return ResponseEntity.ok(analyticsService.getProductAnalytics(productId, period));
    }

    private UUID extractUserId(String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        String email = jwtService.extractUsername(token);
        AppUser user = userRepository.findByEmail(email).orElse(null);
        return user != null ? user.getId() : null;
    }
}
