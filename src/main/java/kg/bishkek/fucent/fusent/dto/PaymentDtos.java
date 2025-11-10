package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.time.Instant;
import java.util.UUID;

public class PaymentDtos {

    public record InitiatePaymentRequest(
        @NotNull UUID orderId,
        @NotNull String paymentMethod, // "cash", "card", "online"
        String returnUrl,
        String callbackUrl
    ) {}

    public record PaymentResponse(
        UUID paymentId,
        UUID orderId,
        String status, // "pending", "processing", "success", "failed", "cancelled"
        String paymentMethod,
        Double amount,
        String currency,
        String transactionId,
        String paymentUrl, // For online payments (redirect to gateway)
        String provider, // "cash", "stripe", "paypal", "mbank", etc.
        Instant createdAt,
        Instant paidAt,
        String errorMessage
    ) {}

    public record RefundResponse(
        UUID refundId,
        UUID orderId,
        UUID paymentId,
        String status,
        Double amount,
        String reason,
        Instant createdAt,
        Instant processedAt
    ) {}

    public record PaymentCallbackRequest(
        @NotNull String transactionId,
        @NotNull String status,
        String signature,
        String metadata
    ) {}
}
