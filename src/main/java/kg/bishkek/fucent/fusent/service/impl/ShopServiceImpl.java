package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.ShopDtos.*;
import kg.bishkek.fucent.fusent.model.Merchant;
import kg.bishkek.fucent.fusent.model.Shop;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.MerchantRepository;
import kg.bishkek.fucent.fusent.repository.ShopRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.ShopService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class ShopServiceImpl implements ShopService {
    private final ShopRepository shops;
    private final MerchantRepository merchants;
    private final AppUserRepository users;

    @Override
    @Transactional
    public ShopResponse createShop(CreateShopRequest request) {
        log.info("=== Starting createShop ===");
        log.info("Request: merchantId={}, name={}", request.merchantId(), request.name());

        var currentUserId = SecurityUtil.currentUserId(users);
        log.info("Current user ID from SecurityUtil: {}", currentUserId);

        // Find or create merchant for the current user
        Merchant merchant;
        if (request.merchantId() != null) {
            log.info("MerchantId provided in request: {}", request.merchantId());
            // If merchantId is provided, use it and verify ownership
            merchant = merchants.findById(request.merchantId())
                .orElseThrow(() -> new IllegalArgumentException("Merchant not found"));
            log.info("Found existing merchant: id={}, ownerUserId={}", merchant.getId(), merchant.getOwnerUserId());
            if (!merchant.getOwnerUserId().equals(currentUserId)) {
                throw new IllegalArgumentException("Not an owner of this merchant");
            }
        } else {
            log.info("No merchantId provided, looking for existing merchant by ownerUserId: {}", currentUserId);
            // If no merchantId provided, find existing merchant by user ID or create one
            merchant = merchants.findByOwnerUserId(currentUserId)
                .orElseGet(() -> {
                    log.info("No existing merchant found, creating new merchant for user: {}", currentUserId);
                    var newMerchant = Merchant.builder()
                        .ownerUserId(currentUserId)
                        .name("Мой магазин")
                        .payoutStatus("pending")
                        .buyEligibility("manual_contact")
                        .build();
                    log.info("Built new merchant object - ownerUserId={}, name={}, payoutStatus={}, buyEligibility={}",
                        newMerchant.getOwnerUserId(), newMerchant.getName(),
                        newMerchant.getPayoutStatus(), newMerchant.getBuyEligibility());
                    log.info("Attempting to save new merchant...");
                    try {
                        var savedMerchant = merchants.save(newMerchant);
                        log.info("Successfully saved merchant: id={}, ownerUserId={}",
                            savedMerchant.getId(), savedMerchant.getOwnerUserId());
                        return savedMerchant;
                    } catch (Exception e) {
                        log.error("Failed to save merchant! Exception: {}", e.getMessage(), e);
                        throw e;
                    }
                });
        }
        log.info("Using merchant: id={}, ownerUserId={}", merchant.getId(), merchant.getOwnerUserId());

        var shop = Shop.builder()
                .merchant(merchant)
                .name(request.name())
                .address(request.address())
                .phone(request.phone())
                .lat(request.lat() != null ? BigDecimal.valueOf(request.lat()) : null)
                .lon(request.lon() != null ? BigDecimal.valueOf(request.lon()) : null)
                .build();

        shop = shops.save(shop);
        return toShopResponse(shop);
    }

    @Override
    public ShopResponse getShopById(UUID id) {
        Shop shop = shops.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Shop not found with id: " + id));
        return toShopResponse(shop);
    }

    private ShopResponse toShopResponse(Shop shop) {
        return new ShopResponse(
            shop.getId(),
            shop.getMerchant().getId(),
            shop.getMerchant().getName(),
            shop.getMerchant().getOwnerUserId(),  // sellerId
            shop.getName(),
            shop.getAddress(),
            shop.getPhone(),
            shop.getLat(),
            shop.getLon(),
            shop.getPosStatus(),
            shop.getLastHeartbeatAt(),
            shop.getCreatedAt(),
            0.0,  // rating - placeholder until review system is implemented
            0     // totalReviews - placeholder until review system is implemented
        );
    }
}
