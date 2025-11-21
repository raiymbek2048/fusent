package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public class CartDtos {

    public record AddToCartRequest(
        @NotNull UUID variantId,
        @Min(1) int qty
    ) {}

    public record AddToCartLegacyRequest(
        @NotNull String productId,
        @Min(1) int quantity
    ) {}

    public record RemoveFromCartLegacyRequest(
        @NotNull String productId
    ) {}

    public record UpdateCartItemLegacyRequest(
        @NotNull String productId,
        @Min(1) int quantity
    ) {}

    public record UpdateCartItemRequest(
        @Min(1) int qty
    ) {}

    public record CartItemResponse(
        UUID id,
        UUID productId,
        UUID variantId,
        String variantName,
        String productName,
        String productImage,
        UUID shopId,
        String shopName,
        BigDecimal price,
        Integer qty,
        BigDecimal subtotal,
        Integer stockQty,
        Instant addedAt
    ) {}

    public record CartResponse(
        UUID id,
        UUID userId,
        List<CartItemResponse> items,
        Integer totalItems,
        BigDecimal totalAmount,
        Instant createdAt,
        Instant updatedAt
    ) {}

    public record CartSummary(
        Integer totalItems,
        BigDecimal totalAmount
    ) {}
}
