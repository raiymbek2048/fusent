package kg.bishkek.fucent.fusent.dto;



import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;


import java.util.UUID;


public record MerchantCreateRequest(
        @NotBlank String name,
        String description
) {}