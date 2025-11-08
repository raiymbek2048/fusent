package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public class OrderDtos {

    public record OrderItemResponse(
        UUID id,
        UUID variantId,
        String variantName,
        String productName,
        String productImage,
        Integer qty,
        Double price,
        Double subtotal
    ) {}

    public record OrderResponse(
        UUID id,
        UUID userId,
        UUID shopId,
        String shopName,
        String status,
        List<OrderItemResponse> items,
        Double totalAmount,
        Instant createdAt,
        Instant paidAt,
        Instant fulfilledAt
    ) {}

    public record OrderSummary(
        UUID id,
        UUID shopId,
        String shopName,
        String status,
        Integer itemCount,
        Double totalAmount,
        Instant createdAt
    ) {}

    public record UpdateOrderStatusRequest(
        @NotNull String status
    ) {}

    public record CheckoutRequest(
        @NotNull UUID shopId,
        String shippingAddress,
        String paymentMethod,
        String notes
    ) {}

    public record CheckoutFromItemsRequest(
        @NotNull UUID shopId,
        @NotNull List<OrderItemRequest> items,
        String shippingAddress,
        String paymentMethod,
        String notes
    ) {}

    public record OrderItemRequest(
        @NotNull UUID variantId,
        @Min(1) int qty
    ) {}
}
