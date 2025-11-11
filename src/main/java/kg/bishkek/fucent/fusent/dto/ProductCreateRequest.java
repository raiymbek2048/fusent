package kg.bishkek.fucent.fusent.dto;



import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import java.math.BigDecimal;
import java.util.UUID;


public record ProductCreateRequest(
        @NotNull UUID shopId,
        @NotNull UUID categoryId,
        @NotBlank String name,
        String description,
        String imageUrl,
        @NotNull @PositiveOrZero BigDecimal basePrice
) {}