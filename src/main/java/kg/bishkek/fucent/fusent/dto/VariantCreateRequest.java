package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.util.UUID;


public record VariantCreateRequest(
        @NotNull UUID productId,
        @NotBlank String sku,
        String barcode,
        String attributesJson,
        @NotNull BigDecimal price,
        @NotNull Integer stockQty
) {}