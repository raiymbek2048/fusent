package kg.bishkek.fucent.fusent.dto;

// kg.bishkek.fucent.fusent.dto.ProductUpdateDtos.java
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public class ProductUpdateDtos {
    public record VariantPriceStockUpdate(
            @NotNull UUID variantId,
            Double price, Integer stockQty
    ) {}
    public record ProductActivateRequest(@NotNull UUID productId, boolean active) {}
}
