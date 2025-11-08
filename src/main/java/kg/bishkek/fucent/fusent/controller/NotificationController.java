package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.NotificationDtos.*;
import kg.bishkek.fucent.fusent.enums.NotificationChannel;
import kg.bishkek.fucent.fusent.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
@Tag(name = "Notifications", description = "Notification preferences, templates, and sending")
public class NotificationController {
    private final NotificationService notificationService;

    // ========== Preferences ==========

    @GetMapping("/preferences/{ownerType}/{ownerId}")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get all notification preferences for owner")
    public List<NotificationPrefResponse> getAllPreferences(
        @PathVariable String ownerType,
        @PathVariable UUID ownerId
    ) {
        return notificationService.getAllPreferences(ownerType, ownerId);
    }

    @GetMapping("/preferences/{ownerType}/{ownerId}/{channel}")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get notification preference for specific channel")
    public NotificationPrefResponse getPreference(
        @PathVariable String ownerType,
        @PathVariable UUID ownerId,
        @PathVariable NotificationChannel channel
    ) {
        return notificationService.getPreference(ownerType, ownerId, channel);
    }

    @PutMapping("/preferences/{ownerType}/{ownerId}")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Update notification preferences")
    public NotificationPrefResponse updatePreference(
        @PathVariable String ownerType,
        @PathVariable UUID ownerId,
        @Valid @RequestBody NotificationPrefRequest request
    ) {
        return notificationService.updatePreference(ownerType, ownerId, request);
    }

    // ========== Templates ==========

    @PostMapping("/templates")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Create notification template (admin only)")
    public NotificationTemplateResponse createTemplate(@Valid @RequestBody CreateTemplateRequest request) {
        return notificationService.createTemplate(request);
    }

    @GetMapping("/templates/{templateKey}/{channel}/{locale}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Get active template")
    public NotificationTemplateResponse getTemplate(
        @PathVariable String templateKey,
        @PathVariable NotificationChannel channel,
        @PathVariable String locale
    ) {
        return notificationService.getActiveTemplate(templateKey, channel, locale);
    }

    // ========== Sending ==========

    @PostMapping("/send")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SELLER')")
    @ResponseStatus(HttpStatus.ACCEPTED)
    @Operation(summary = "Send a notification")
    public void sendNotification(@Valid @RequestBody SendNotificationRequest request) {
        notificationService.sendNotification(request);
    }

    @GetMapping("/history/{recipient}")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get notification history for recipient")
    public List<NotificationLogResponse> getHistory(
        @PathVariable String recipient,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size
    ) {
        return notificationService.getNotificationHistory(recipient, page, size);
    }
}
