package kg.bishkek.fucent.fusent.dto;



import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;


import java.util.List;
import java.util.UUID;


public record PosSaleRequest(
        @NotNull UUID shopId,
        @NotBlank String receiptNumber,
        @NotNull List<Item> items
) {
    public record Item(@NotNull UUID variantId, @NotNull Integer qty, @NotNull Double unitPrice) {}
}