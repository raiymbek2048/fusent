package kg.bishkek.fucent.fusent.dto;

// kg.bishkek.fucent.fusent.dto.ProductUpdateDtos.java
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.UUID;

public class ProductUpdateDtos {
    public record VariantPriceStockUpdate(
            @NotNull UUID variantId,
            BigDecimal price, Integer stockQty
    ) {}
    public record ProductActivateRequest(@NotNull UUID productId, boolean active) {}
}
