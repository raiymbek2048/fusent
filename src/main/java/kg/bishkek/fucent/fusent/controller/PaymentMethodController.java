package kg.bishkek.fucent.fusent.controller;

import kg.bishkek.fucent.fusent.dto.PaymentMethodDtos.*;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.PaymentMethod;
import kg.bishkek.fucent.fusent.repository.PaymentMethodRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/payment-methods")
@RequiredArgsConstructor
public class PaymentMethodController {

    private final PaymentMethodRepository repository;

    @GetMapping
    public ResponseEntity<List<PaymentMethodResponse>> getPaymentMethods(@AuthenticationPrincipal AppUser user) {
        List<PaymentMethod> methods = repository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(user.getId());
        return ResponseEntity.ok(methods.stream().map(this::toResponse).collect(Collectors.toList()));
    }

    @PostMapping
    @Transactional
    public ResponseEntity<PaymentMethodResponse> createPaymentMethod(
            @AuthenticationPrincipal AppUser user,
            @RequestBody PaymentMethodRequest request) {

        PaymentMethod method = PaymentMethod.builder()
                .user(user)
                .type(request.getType())
                .cardNumber(maskCardNumber(request.getCardNumber()))
                .cardHolder(request.getCardHolder())
                .expiryDate(request.getExpiryDate())
                .phone(request.getPhone())
                .isDefault(request.getIsDefault() != null && request.getIsDefault())
                .build();

        if (Boolean.TRUE.equals(method.getIsDefault())) {
            repository.clearDefaultExcept(user.getId(), UUID.randomUUID());
        }

        method = repository.save(method);
        return ResponseEntity.ok(toResponse(method));
    }

    @DeleteMapping("/{methodId}")
    public ResponseEntity<Void> deletePaymentMethod(
            @AuthenticationPrincipal AppUser user,
            @PathVariable UUID methodId) {

        PaymentMethod method = repository.findByIdAndUserId(methodId, user.getId())
                .orElseThrow(() -> new RuntimeException("Payment method not found"));

        repository.delete(method);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{methodId}/default")
    @Transactional
    public ResponseEntity<PaymentMethodResponse> setDefault(
            @AuthenticationPrincipal AppUser user,
            @PathVariable UUID methodId) {

        PaymentMethod method = repository.findByIdAndUserId(methodId, user.getId())
                .orElseThrow(() -> new RuntimeException("Payment method not found"));

        repository.clearDefaultExcept(user.getId(), methodId);
        method.setIsDefault(true);
        method = repository.save(method);

        return ResponseEntity.ok(toResponse(method));
    }

    private String maskCardNumber(String cardNumber) {
        if (cardNumber == null || cardNumber.length() < 4) return cardNumber;
        String digits = cardNumber.replaceAll("\\D", "");
        if (digits.length() < 4) return cardNumber;
        return "**** **** **** " + digits.substring(digits.length() - 4);
    }

    private PaymentMethodResponse toResponse(PaymentMethod method) {
        return PaymentMethodResponse.builder()
                .id(method.getId().toString())
                .type(method.getType())
                .cardNumber(method.getCardNumber())
                .cardHolder(method.getCardHolder())
                .expiryDate(method.getExpiryDate())
                .phone(method.getPhone())
                .isDefault(method.getIsDefault())
                .createdAt(method.getCreatedAt())
                .build();
    }
}
