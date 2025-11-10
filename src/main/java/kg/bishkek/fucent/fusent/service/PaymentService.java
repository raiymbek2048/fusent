package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.PaymentDtos.*;

import java.util.UUID;

public interface PaymentService {
    /**
     * Initiate payment for an order
     */
    PaymentResponse initiatePayment(InitiatePaymentRequest request);

    /**
     * Verify payment status (callback from payment gateway)
     */
    PaymentResponse verifyPayment(UUID orderId, String transactionId);

    /**
     * Get payment status
     */
    PaymentResponse getPaymentStatus(UUID orderId);

    /**
     * Process refund
     */
    RefundResponse processRefund(UUID orderId, String reason);
}
