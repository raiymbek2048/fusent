package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kg.bishkek.fucent.fusent.dto.FcmTokenDto;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.service.FcmService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "FCM", description = "Firebase Cloud Messaging API для push уведомлений")
@RestController
@RequestMapping("/api/v1/fcm")
@RequiredArgsConstructor
public class FcmController {

    private final FcmService fcmService;

    @Operation(summary = "Зарегистрировать FCM токен", description = "Регистрация токена устройства для получения push уведомлений")
    @PostMapping("/register")
    public ResponseEntity<Void> registerToken(
            @AuthenticationPrincipal AppUser user,
            @RequestBody FcmTokenDto.RegisterRequest request
    ) {
        fcmService.registerToken(user, request);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Удалить FCM токен", description = "Удаление токена устройства (например, при выходе)")
    @PostMapping("/unregister")
    public ResponseEntity<Void> unregisterToken(
            @RequestBody FcmTokenDto.UnregisterRequest request
    ) {
        fcmService.unregisterToken(request.getToken());
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Отправить тестовое уведомление", description = "Для тестирования push уведомлений")
    @PostMapping("/test")
    public ResponseEntity<Void> sendTestNotification(
            @AuthenticationPrincipal AppUser user
    ) {
        FcmTokenDto.NotificationRequest request = FcmTokenDto.NotificationRequest.builder()
                .userId(user.getId().toString())
                .title("Тестовое уведомление")
                .body("Это тестовое push уведомление из FUCENT")
                .type("TEST")
                .build();

        fcmService.sendNotificationToUser(user.getId().toString(), request);
        return ResponseEntity.ok().build();
    }
}
