package kg.bishkek.fucent.fusent.service;

import java.util.Map;

/**
 * Email service for sending transactional and marketing emails
 */
public interface EmailService {
    /**
     * Send a simple text email
     */
    void sendSimpleEmail(String to, String subject, String text);

    /**
     * Send an HTML email
     */
    void sendHtmlEmail(String to, String subject, String htmlContent);

    /**
     * Send templated email with variables
     */
    void sendTemplatedEmail(String to, String templateKey, Map<String, Object> variables);

    /**
     * Send email with attachment
     */
    void sendEmailWithAttachment(String to, String subject, String text, String attachmentPath);
}
