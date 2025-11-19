package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.PaymentDtos.*;
import kg.bishkek.fucent.fusent.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
@Tag(name = "Payments", description = "Payment processing and management")
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/initiate")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Initiate payment for an order")
    public ResponseEntity<PaymentResponse> initiatePayment(@Valid @RequestBody InitiatePaymentRequest request) {
        PaymentResponse response = paymentService.initiatePayment(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/status/{orderId}")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get payment status for an order")
    public ResponseEntity<PaymentResponse> getPaymentStatus(@PathVariable UUID orderId) {
        PaymentResponse response = paymentService.getPaymentStatus(orderId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/verify/{orderId}")
    @Operation(summary = "Verify payment (callback from gateway)")
    public ResponseEntity<PaymentResponse> verifyPayment(
        @PathVariable UUID orderId,
        @RequestParam String transactionId
    ) {
        PaymentResponse response = paymentService.verifyPayment(orderId, transactionId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/refund/{orderId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SELLER') or hasRole('MERCHANT')")
    @Operation(summary = "Process refund for an order")
    public ResponseEntity<RefundResponse> processRefund(
        @PathVariable UUID orderId,
        @RequestParam String reason
    ) {
        RefundResponse response = paymentService.processRefund(orderId, reason);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/callback")
    @Operation(summary = "Payment gateway callback (webhook)")
    public ResponseEntity<String> paymentCallback(@Valid @RequestBody PaymentCallbackRequest request) {
        // In production, verify webhook signature and process payment status update
        // For now, just acknowledge receipt
        return ResponseEntity.ok("OK");
    }
}
