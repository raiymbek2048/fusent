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
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ShopServiceImpl implements ShopService {
    private final ShopRepository shops;
    private final MerchantRepository merchants;
    private final AppUserRepository users;

    @Override
    @Transactional
    public ShopResponse createShop(CreateShopRequest request) {
        var currentUserId = SecurityUtil.currentUserId(users);

        // Find or create merchant for the current user
        Merchant merchant;
        if (request.merchantId() != null) {
            // If merchantId is provided, use it and verify ownership
            merchant = merchants.findById(request.merchantId())
                .orElseThrow(() -> new IllegalArgumentException("Merchant not found"));
            if (!merchant.getOwnerUserId().equals(currentUserId)) {
                throw new IllegalArgumentException("Not an owner of this merchant");
            }
        } else {
            // If no merchantId provided, find existing merchant by user ID or create one
            merchant = merchants.findByOwnerUserId(currentUserId)
                .orElseGet(() -> {
                    var newMerchant = Merchant.builder()
                        .ownerUserId(currentUserId)
                        .name("Мой магазин")
                        .payoutStatus("pending")
                        .buyEligibility("manual_contact")
                        .build();
                    return merchants.save(newMerchant);
                });
        }

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

    private ShopResponse toShopResponse(Shop shop) {
        return new ShopResponse(
            shop.getId(),
            shop.getMerchant().getId(),
            shop.getMerchant().getName(),
            shop.getName(),
            shop.getAddress(),
            shop.getPhone(),
            shop.getLat(),
            shop.getLon(),
            shop.getPosStatus(),
            shop.getLastHeartbeatAt(),
            shop.getCreatedAt()
        );
    }
}
