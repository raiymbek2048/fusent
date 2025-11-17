package kg.bishkek.fucent.fusent.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record ProductResponse(
        UUID id,
        UUID shopId,
        UUID categoryId,
        String name,
        String description,
        String imageUrl,
        BigDecimal basePrice,
        boolean active
) {}
