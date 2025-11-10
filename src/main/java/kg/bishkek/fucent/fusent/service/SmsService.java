package kg.bishkek.fucent.fusent.service;

import java.util.Map;

/**
 * SMS service for sending transactional SMS messages
 * To integrate with real SMS providers:
 * - Twilio: https://www.twilio.com/
 * - AWS SNS: https://aws.amazon.com/sns/
 * - Local providers: Beeline, MegaCom, O! etc.
 */
public interface SmsService {
    /**
     * Send a simple text SMS
     */
    void sendSms(String phoneNumber, String message);

    /**
     * Send templated SMS with variables
     */
    void sendTemplatedSms(String phoneNumber, String templateKey, Map<String, Object> variables);

    /**
     * Send OTP (One-Time Password) SMS
     */
    void sendOtp(String phoneNumber, String otp);

    /**
     * Verify phone number (send verification code)
     */
    void sendVerificationCode(String phoneNumber, String code);
}
