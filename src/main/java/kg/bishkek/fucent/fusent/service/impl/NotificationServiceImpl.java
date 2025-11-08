package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.NotificationDtos.*;
import kg.bishkek.fucent.fusent.enums.NotificationChannel;
import kg.bishkek.fucent.fusent.enums.NotificationStatus;
import kg.bishkek.fucent.fusent.model.NotificationLog;
import kg.bishkek.fucent.fusent.model.NotificationPref;
import kg.bishkek.fucent.fusent.model.NotificationTemplate;
import kg.bishkek.fucent.fusent.repository.NotificationLogRepository;
import kg.bishkek.fucent.fusent.repository.NotificationPrefRepository;
import kg.bishkek.fucent.fusent.repository.NotificationTemplateRepository;
import kg.bishkek.fucent.fusent.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {
    private final NotificationPrefRepository prefRepository;
    private final NotificationTemplateRepository templateRepository;
    private final NotificationLogRepository logRepository;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Override
    @Transactional(readOnly = true)
    public NotificationPrefResponse getPreference(String ownerType, UUID ownerId, NotificationChannel channel) {
        var pref = prefRepository.findByOwnerTypeAndOwnerIdAndChannel(ownerType, ownerId, channel)
            .orElse(NotificationPref.builder()
                .ownerType(ownerType)
                .ownerId(ownerId)
                .channel(channel)
                .enabled(true)
                .locale("ru")
                .build());

        return toPrefResponse(pref);
    }

    @Override
    @Transactional(readOnly = true)
    public List<NotificationPrefResponse> getAllPreferences(String ownerType, UUID ownerId) {
        return prefRepository.findByOwnerTypeAndOwnerId(ownerType, ownerId).stream()
            .map(this::toPrefResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public NotificationPrefResponse updatePreference(String ownerType, UUID ownerId, NotificationPrefRequest request) {
        var pref = prefRepository.findByOwnerTypeAndOwnerIdAndChannel(ownerType, ownerId, request.channel())
            .orElse(NotificationPref.builder()
                .ownerType(ownerType)
                .ownerId(ownerId)
                .channel(request.channel())
                .build());

        pref.setEnabled(request.enabled());
        pref.setQuietHours(request.quietHours());
        pref.setLocale(request.locale() != null ? request.locale() : "ru");
        pref.setCategories(request.categories());

        pref = prefRepository.save(pref);
        return toPrefResponse(pref);
    }

    @Override
    @Transactional
    public NotificationTemplateResponse createTemplate(CreateTemplateRequest request) {
        var template = NotificationTemplate.builder()
            .templateKey(request.templateKey())
            .channel(request.channel())
            .locale(request.locale())
            .subject(request.subject())
            .body(request.body())
            .version(request.version() != null ? request.version() : 1)
            .isActive(true)
            .build();

        template = templateRepository.save(template);
        return toTemplateResponse(template);
    }

    @Override
    @Transactional(readOnly = true)
    public NotificationTemplateResponse getActiveTemplate(String templateKey, NotificationChannel channel, String locale) {
        var template = templateRepository.findByTemplateKeyAndChannelAndLocaleAndIsActiveTrue(templateKey, channel, locale)
            .orElseThrow(() -> new IllegalArgumentException("Template not found"));

        return toTemplateResponse(template);
    }

    @Override
    @Transactional
    public void sendNotification(SendNotificationRequest request) {
        // Create notification log entry
        var log = NotificationLog.builder()
            .channel(request.channel())
            .recipient(request.recipient())
            .templateKey(request.templateKey())
            .payloadJson(request.payloadJson())
            .status(NotificationStatus.QUEUED)
            .attempts(0)
            .build();

        logRepository.save(log);

        // Send to Kafka for async processing
        kafkaTemplate.send("notification-events", request);
    }

    @Override
    @Transactional(readOnly = true)
    public List<NotificationLogResponse> getNotificationHistory(String recipient, int page, int size) {
        return logRepository.findByRecipientOrderByCreatedAtDesc(recipient, PageRequest.of(page, size))
            .stream()
            .map(this::toLogResponse)
            .collect(Collectors.toList());
    }

    private NotificationPrefResponse toPrefResponse(NotificationPref pref) {
        return new NotificationPrefResponse(
            pref.getId(),
            pref.getOwnerType(),
            pref.getOwnerId(),
            pref.getChannel(),
            pref.getEnabled(),
            pref.getQuietHours(),
            pref.getLocale(),
            pref.getCategories(),
            pref.getCreatedAt(),
            pref.getUpdatedAt()
        );
    }

    private NotificationTemplateResponse toTemplateResponse(NotificationTemplate template) {
        return new NotificationTemplateResponse(
            template.getId(),
            template.getTemplateKey(),
            template.getChannel(),
            template.getLocale(),
            template.getSubject(),
            template.getBody(),
            template.getVersion(),
            template.getIsActive(),
            template.getCreatedAt()
        );
    }

    private NotificationLogResponse toLogResponse(NotificationLog log) {
        return new NotificationLogResponse(
            log.getId(),
            log.getChannel(),
            log.getRecipient(),
            log.getTemplateKey(),
            log.getPayloadJson(),
            log.getStatus(),
            log.getProvider(),
            log.getProviderRef(),
            log.getAttempts(),
            log.getLastError(),
            log.getCreatedAt(),
            log.getDeliveredAt()
        );
    }
}
