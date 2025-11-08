package kg.bishkek.fucent.fusent.dto;

import java.util.UUID;

public record MerchantResponse(UUID id, String name, String description, String payoutStatus, String buyEligibility) {}