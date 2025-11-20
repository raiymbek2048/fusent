package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.ShopDtos.*;
import kg.bishkek.fucent.fusent.enums.FollowTargetType;
import kg.bishkek.fucent.fusent.model.Merchant;
import kg.bishkek.fucent.fusent.model.Shop;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.FollowRepository;
import kg.bishkek.fucent.fusent.repository.MerchantRepository;
import kg.bishkek.fucent.fusent.repository.ProductRepository;
import kg.bishkek.fucent.fusent.repository.ShopRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.ShopService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ShopServiceImpl implements ShopService {
    private final ShopRepository shops;
    private final MerchantRepository merchants;
    private final AppUserRepository users;
    private final ProductRepository products;
    private final FollowRepository follows;

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
    @Transactional(readOnly = true)
    public ShopResponse getShopById(UUID id) {
        Shop shop = shops.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Shop not found with id: " + id));
        return toShopResponse(shop);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ShopResponse> getAllShops(Pageable pageable) {
        Page<Shop> shopsPage = shops.findAll(pageable);
        return shopsPage.map(this::toShopResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ShopResponse> searchShops(String query, Pageable pageable) {
        Page<Shop> shopsPage = shops.findByNameContainingIgnoreCase(query, pageable);
        return shopsPage.map(this::toShopResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ShopResponse> getShopsBySeller(UUID sellerId) {
        List<Shop> shopsList = shops.findByMerchantOwnerUserId(sellerId);
        return shopsList.stream()
            .map(this::toShopResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<ShopResponse> getMyShops() {
        var currentUserId = SecurityUtil.currentUserId(users);
        log.info("Fetching shops for current user: {}", currentUserId);

        List<Shop> shopsList = shops.findByMerchantOwnerUserId(currentUserId);
        log.info("Found {} shops for user {}", shopsList.size(), currentUserId);

        return shopsList.stream()
            .map(this::toShopResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public ShopResponse updateShop(UUID id, UpdateShopRequest request) {
        log.info("Updating shop with id: {}", id);

        var currentUserId = SecurityUtil.currentUserId(users);

        Shop shop = shops.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Shop not found with id: " + id));

        // Verify ownership
        if (!shop.getMerchant().getOwnerUserId().equals(currentUserId)) {
            throw new IllegalArgumentException("Not authorized to update this shop");
        }

        // Update shop fields
        shop.setName(request.name());
        shop.setAddress(request.address());
        shop.setPhone(request.phone());
        shop.setLat(request.lat() != null ? BigDecimal.valueOf(request.lat()) : null);
        shop.setLon(request.lon() != null ? BigDecimal.valueOf(request.lon()) : null);

        shop = shops.save(shop);
        log.info("Successfully updated shop: {}", id);

        return toShopResponse(shop);
    }

    @Override
    @Transactional
    public void deleteShop(UUID id) {
        log.info("Deleting shop with id: {}", id);

        var currentUserId = SecurityUtil.currentUserId(users);

        Shop shop = shops.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Shop not found with id: " + id));

        // Verify ownership
        if (!shop.getMerchant().getOwnerUserId().equals(currentUserId)) {
            throw new IllegalArgumentException("Not authorized to delete this shop");
        }

        shops.delete(shop);
        log.info("Successfully deleted shop: {}", id);
    }

    private ShopResponse toShopResponse(Shop shop) {
        Merchant merchant = shop.getMerchant();

        Double rating = shop.getRating() != null ? shop.getRating().doubleValue() : 0.0;
        Integer reviewCount = shop.getReviewCount() != null ? shop.getReviewCount() : 0;

        // Calculate real-time counts
        long followersCount = follows.countByTargetTypeAndTargetId(FollowTargetType.MERCHANT, merchant.getId());
        long productsCount = products.countByMerchantId(merchant.getId());

        return new ShopResponse(
            shop.getId(),
            merchant.getId(),
            merchant.getName(),
            merchant.getOwnerUserId(),  // sellerId
            shop.getName(),
            shop.getAddress(),
            shop.getPhone(),
            shop.getLat(),
            shop.getLon(),
            shop.getPosStatus(),
            shop.getLastHeartbeatAt(),
            shop.getCreatedAt(),
            rating,
            rating,  // averageRating (same as rating for compatibility)
            reviewCount,
            merchant.getLogoUrl(),
            merchant.getBannerUrl(),
            (int) followersCount,
            (int) productsCount,
            merchant.getIsVerified() != null ? merchant.getIsVerified() : false,
            merchant.getOwnerUserId()  // ownerId (same as sellerId)
        );
    }
}
