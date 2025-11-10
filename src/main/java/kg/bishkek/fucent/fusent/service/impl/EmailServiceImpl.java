package kg.bishkek.fucent.fusent.service.impl;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import kg.bishkek.fucent.fusent.service.EmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.io.File;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailServiceImpl implements EmailService {
    private final JavaMailSender mailSender;

    @Value("${spring.mail.username:noreply@fusent.kg}")
    private String fromEmail;

    @Override
    public void sendSimpleEmail(String to, String subject, String text) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(to);
            message.setSubject(subject);
            message.setText(text);

            mailSender.send(message);
            log.info("Simple email sent to: {}", to);
        } catch (Exception e) {
            log.error("Failed to send simple email to: {}", to, e);
            throw new RuntimeException("Failed to send email", e);
        }
    }

    @Override
    public void sendHtmlEmail(String to, String subject, String htmlContent) {
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlContent, true); // true = HTML

            mailSender.send(mimeMessage);
            log.info("HTML email sent to: {}", to);
        } catch (MessagingException e) {
            log.error("Failed to send HTML email to: {}", to, e);
            throw new RuntimeException("Failed to send HTML email", e);
        }
    }

    @Override
    public void sendTemplatedEmail(String to, String templateKey, Map<String, Object> variables) {
        // Build HTML content from template
        String htmlContent = buildTemplateContent(templateKey, variables);
        String subject = getTemplateSubject(templateKey, variables);

        sendHtmlEmail(to, subject, htmlContent);
    }

    @Override
    public void sendEmailWithAttachment(String to, String subject, String text, String attachmentPath) {
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(text);

            // Add attachment
            FileSystemResource file = new FileSystemResource(new File(attachmentPath));
            helper.addAttachment(file.getFilename(), file);

            mailSender.send(mimeMessage);
            log.info("Email with attachment sent to: {}", to);
        } catch (MessagingException e) {
            log.error("Failed to send email with attachment to: {}", to, e);
            throw new RuntimeException("Failed to send email with attachment", e);
        }
    }

    /**
     * Build HTML content from template key and variables
     */
    private String buildTemplateContent(String templateKey, Map<String, Object> variables) {
        // TODO: Integrate with template engine (Thymeleaf, Freemarker, etc.)
        // For now, return basic HTML templates

        return switch (templateKey) {
            case "order_created" -> buildOrderCreatedTemplate(variables);
            case "order_paid" -> buildOrderPaidTemplate(variables);
            case "order_shipped" -> buildOrderShippedTemplate(variables);
            case "order_delivered" -> buildOrderDeliveredTemplate(variables);
            case "welcome" -> buildWelcomeTemplate(variables);
            default -> buildGenericTemplate(variables);
        };
    }

    private String getTemplateSubject(String templateKey, Map<String, Object> variables) {
        return switch (templateKey) {
            case "order_created" -> "Заказ создан #" + variables.getOrDefault("orderId", "");
            case "order_paid" -> "Оплата получена #" + variables.getOrDefault("orderId", "");
            case "order_shipped" -> "Заказ отправлен #" + variables.getOrDefault("orderId", "");
            case "order_delivered" -> "Заказ доставлен #" + variables.getOrDefault("orderId", "");
            case "welcome" -> "Добро пожаловать в Fusent!";
            default -> "Уведомление от Fusent";
        };
    }

    private String buildOrderCreatedTemplate(Map<String, Object> variables) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background-color: #4F46E5; color: white; padding: 20px; text-align: center; }
                    .content { padding: 20px; background-color: #f9f9f9; }
                    .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>Заказ создан</h1>
                    </div>
                    <div class="content">
                        <p>Здравствуйте, %s!</p>
                        <p>Ваш заказ <strong>#%s</strong> успешно создан.</p>
                        <p>Сумма заказа: <strong>%s сом</strong></p>
                        <p>Спасибо за покупку!</p>
                    </div>
                    <div class="footer">
                        <p>&copy; 2025 Fusent. Все права защищены.</p>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(
                variables.getOrDefault("userName", ""),
                variables.getOrDefault("orderId", ""),
                variables.getOrDefault("totalAmount", "0")
            );
    }

    private String buildOrderPaidTemplate(Map<String, Object> variables) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
            </head>
            <body>
                <h2>Оплата получена</h2>
                <p>Здравствуйте, %s!</p>
                <p>Оплата за заказ <strong>#%s</strong> успешно получена.</p>
                <p>Сумма: <strong>%s сом</strong></p>
            </body>
            </html>
            """.formatted(
                variables.getOrDefault("userName", ""),
                variables.getOrDefault("orderId", ""),
                variables.getOrDefault("amount", "0")
            );
    }

    private String buildOrderShippedTemplate(Map<String, Object> variables) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
            </head>
            <body>
                <h2>Заказ отправлен</h2>
                <p>Здравствуйте, %s!</p>
                <p>Ваш заказ <strong>#%s</strong> отправлен.</p>
                <p>Трек-номер: <strong>%s</strong></p>
            </body>
            </html>
            """.formatted(
                variables.getOrDefault("userName", ""),
                variables.getOrDefault("orderId", ""),
                variables.getOrDefault("trackingNumber", "N/A")
            );
    }

    private String buildOrderDeliveredTemplate(Map<String, Object> variables) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
            </head>
            <body>
                <h2>Заказ доставлен</h2>
                <p>Здравствуйте, %s!</p>
                <p>Ваш заказ <strong>#%s</strong> успешно доставлен.</p>
                <p>Спасибо за покупку! Будем рады видеть вас снова.</p>
            </body>
            </html>
            """.formatted(
                variables.getOrDefault("userName", ""),
                variables.getOrDefault("orderId", "")
            );
    }

    private String buildWelcomeTemplate(Map<String, Object> variables) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
            </head>
            <body>
                <h2>Добро пожаловать в Fusent!</h2>
                <p>Здравствуйте, %s!</p>
                <p>Спасибо за регистрацию на нашей платформе.</p>
                <p>Начните покупать у лучших продавцов Кыргызстана!</p>
            </body>
            </html>
            """.formatted(variables.getOrDefault("userName", ""));
    }

    private String buildGenericTemplate(Map<String, Object> variables) {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
            </head>
            <body>
                <p>%s</p>
            </body>
            </html>
            """.formatted(variables.getOrDefault("message", "Уведомление от Fusent"));
    }
}
