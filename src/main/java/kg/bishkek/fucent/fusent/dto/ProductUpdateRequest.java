package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * Request DTO for updating an existing product.
 * Shop cannot be changed, so shopId is not included.
 */
public record ProductUpdateRequest(
        UUID categoryId,  // Optional - can update category
        @NotBlank String name,
        String description,
        String imageUrl,
        @NotNull @PositiveOrZero BigDecimal basePrice,
        Integer initialStock
) {}
