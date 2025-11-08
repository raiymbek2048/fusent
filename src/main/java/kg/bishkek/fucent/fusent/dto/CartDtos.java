package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public class CartDtos {

    public record AddToCartRequest(
        @NotNull UUID variantId,
        @Min(1) int qty
    ) {}

    public record UpdateCartItemRequest(
        @Min(1) int qty
    ) {}

    public record CartItemResponse(
        UUID id,
        UUID variantId,
        String variantName,
        String productName,
        String productImage,
        UUID shopId,
        String shopName,
        Double price,
        Integer qty,
        Double subtotal,
        Integer stockQty,
        Instant addedAt
    ) {}

    public record CartResponse(
        UUID id,
        UUID userId,
        List<CartItemResponse> items,
        Integer totalItems,
        Double totalAmount,
        Instant createdAt,
        Instant updatedAt
    ) {}

    public record CartSummary(
        Integer totalItems,
        Double totalAmount
    ) {}
}
