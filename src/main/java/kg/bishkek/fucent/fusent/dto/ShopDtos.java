package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public class ShopDtos {

    public record CreateShopRequest(
        UUID merchantId,  // Optional - will auto-create merchant if not provided

        @NotBlank(message = "Shop name is required")
        String name,

        String address,
        String phone,
        Double lat,
        Double lon
    ) {}

    public record ShopResponse(
        UUID id,
        UUID merchantId,
        String merchantName,
        String name,
        String address,
        String phone,
        BigDecimal lat,
        BigDecimal lon,
        String posStatus,
        Instant lastHeartbeatAt,
        Instant createdAt,
        Double rating,
        Integer totalReviews
    ) {}
}
