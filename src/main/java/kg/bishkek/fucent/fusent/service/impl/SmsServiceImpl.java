package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.service.SmsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;

/**
 * SMS Service implementation stub
 * TODO: Integrate with real SMS provider
 *
 * Options for Kyrgyzstan:
 * 1. Local providers (Beeline, MegaCom, O!)
 * 2. International: Twilio, AWS SNS, MessageBird
 * 3. Aggregators: Infobip, Vonage
 */
@Service
@Slf4j
public class SmsServiceImpl implements SmsService {

    @Override
    public void sendSms(String phoneNumber, String message) {
        // TODO: Integrate with SMS provider API
        log.info("SMS would be sent to {}: {}", phoneNumber, message);
        log.warn("SMS service is not configured. Using stub implementation.");

        // Example Twilio integration:
        // Twilio.init(accountSid, authToken);
        // Message.creator(
        //     new PhoneNumber(phoneNumber),
        //     new PhoneNumber(twilioPhoneNumber),
        //     message
        // ).create();
    }

    @Override
    public void sendTemplatedSms(String phoneNumber, String templateKey, Map<String, Object> variables) {
        String message = buildTemplateMessage(templateKey, variables);
        sendSms(phoneNumber, message);
    }

    @Override
    public void sendOtp(String phoneNumber, String otp) {
        String message = String.format("Ваш код подтверждения: %s. Никому не сообщайте этот код.", otp);
        sendSms(phoneNumber, message);
    }

    @Override
    public void sendVerificationCode(String phoneNumber, String code) {
        String message = String.format("Код верификации Fusent: %s", code);
        sendSms(phoneNumber, message);
    }

    /**
     * Build SMS message from template
     */
    private String buildTemplateMessage(String templateKey, Map<String, Object> variables) {
        return switch (templateKey) {
            case "order_created" -> String.format(
                "Fusent: Заказ #%s создан. Сумма: %s сом",
                variables.getOrDefault("orderId", ""),
                variables.getOrDefault("totalAmount", "0")
            );
            case "order_paid" -> String.format(
                "Fusent: Оплата за заказ #%s получена",
                variables.getOrDefault("orderId", "")
            );
            case "order_shipped" -> String.format(
                "Fusent: Заказ #%s отправлен. Трек: %s",
                variables.getOrDefault("orderId", ""),
                variables.getOrDefault("trackingNumber", "N/A")
            );
            case "order_delivered" -> String.format(
                "Fusent: Заказ #%s доставлен. Спасибо!",
                variables.getOrDefault("orderId", "")
            );
            default -> variables.getOrDefault("message", "Уведомление от Fusent").toString();
        };
    }
}
