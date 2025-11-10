package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.PaymentDtos.*;
import kg.bishkek.fucent.fusent.enums.OrderStatus;
import kg.bishkek.fucent.fusent.model.Order;
import kg.bishkek.fucent.fusent.repository.OrderRepository;
import kg.bishkek.fucent.fusent.service.PaymentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentServiceImpl implements PaymentService {

    private final OrderRepository orderRepository;

    @Override
    @Transactional
    public PaymentResponse initiatePayment(InitiatePaymentRequest request) {
        // Get the order
        Order order = orderRepository.findById(request.orderId())
            .orElseThrow(() -> new IllegalArgumentException("Order not found"));

        // Check if already paid
        if (order.getPaidAt() != null) {
            throw new IllegalStateException("Order already paid");
        }

        String paymentMethod = request.paymentMethod().toLowerCase();

        return switch (paymentMethod) {
            case "cash" -> processCashPayment(order);
            case "card", "online" -> processOnlinePayment(order, request);
            default -> throw new IllegalArgumentException("Unsupported payment method: " + paymentMethod);
        };
    }

    private PaymentResponse processCashPayment(Order order) {
        // For cash payments, we just create a pending payment record
        // Payment will be confirmed when order is delivered

        UUID paymentId = UUID.randomUUID();
        String transactionId = "CASH-" + paymentId.toString().substring(0, 8).toUpperCase();

        log.info("Cash payment initiated for order {}: {}", order.getId(), transactionId);

        return new PaymentResponse(
            paymentId,
            order.getId(),
            "pending",
            "cash",
            order.getTotalAmount(),
            "KGS",
            transactionId,
            null,
            "cash",
            Instant.now(),
            null,
            null
        );
    }

    private PaymentResponse processOnlinePayment(Order order, InitiatePaymentRequest request) {
        // Simulate integration with payment gateway (e.g., Stripe, mBank, etc.)
        // In production, this would call the actual payment gateway API

        UUID paymentId = UUID.randomUUID();
        String transactionId = "PAY-" + paymentId.toString().substring(0, 8).toUpperCase();

        // Generate mock payment URL (in production, this would come from payment gateway)
        String paymentUrl = String.format(
            "https://payment-gateway.example.com/pay?order_id=%s&amount=%.2f&return_url=%s",
            order.getId(),
            order.getTotalAmount(),
            request.returnUrl()
        );

        log.info("Online payment initiated for order {}: {}", order.getId(), transactionId);
        log.info("Payment URL: {}", paymentUrl);

        return new PaymentResponse(
            paymentId,
            order.getId(),
            "processing",
            request.paymentMethod(),
            order.getTotalAmount(),
            "KGS",
            transactionId,
            paymentUrl,
            "payment-gateway",
            Instant.now(),
            null,
            null
        );
    }

    @Override
    @Transactional
    public PaymentResponse verifyPayment(UUID orderId, String transactionId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found"));

        // In production, verify payment status with payment gateway
        // For now, simulate successful payment

        if (order.getPaidAt() == null) {
            order.setStatus(OrderStatus.PAID);
            order.setPaidAt(Instant.now());
            orderRepository.save(order);

            log.info("Payment verified and order {} marked as paid: {}", orderId, transactionId);
        }

        return new PaymentResponse(
            UUID.randomUUID(),
            orderId,
            "success",
            "online",
            order.getTotalAmount(),
            "KGS",
            transactionId,
            null,
            "payment-gateway",
            order.getCreatedAt(),
            order.getPaidAt(),
            null
        );
    }

    @Override
    @Transactional(readOnly = true)
    public PaymentResponse getPaymentStatus(UUID orderId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found"));

        String status = order.getPaidAt() != null ? "success" : "pending";

        return new PaymentResponse(
            UUID.randomUUID(),
            orderId,
            status,
            "unknown",
            order.getTotalAmount(),
            "KGS",
            null,
            null,
            "unknown",
            order.getCreatedAt(),
            order.getPaidAt(),
            null
        );
    }

    @Override
    @Transactional
    public RefundResponse processRefund(UUID orderId, String reason) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found"));

        if (order.getPaidAt() == null) {
            throw new IllegalStateException("Cannot refund unpaid order");
        }

        if (order.getStatus() == OrderStatus.REFUNDED) {
            throw new IllegalStateException("Order already refunded");
        }

        // In production, initiate refund with payment gateway
        // For now, simulate successful refund

        order.setStatus(OrderStatus.REFUNDED);
        orderRepository.save(order);

        UUID refundId = UUID.randomUUID();
        Instant now = Instant.now();

        log.info("Refund processed for order {}: {}", orderId, refundId);

        return new RefundResponse(
            refundId,
            orderId,
            UUID.randomUUID(),
            "processed",
            order.getTotalAmount(),
            reason,
            now,
            now
        );
    }
}
