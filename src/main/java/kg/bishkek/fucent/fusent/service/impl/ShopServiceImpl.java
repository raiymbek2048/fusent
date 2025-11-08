package kg.bishkek.fucent.fusent.service.impl;

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

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ShopServiceImpl implements ShopService {
    private final ShopRepository shops;
    private final MerchantRepository merchants;
    private final AppUserRepository users;

    @Transactional
    public Shop create(UUID merchantId, String name, String address, String phone, Double lat, Double lon) {
        var currentUserId = SecurityUtil.currentUserId(users);
        Merchant merchant = merchants.findById(merchantId).orElseThrow();

        if (!merchant.getOwnerUserId().equals(currentUserId)) {
            throw new IllegalArgumentException("Not an owner of this merchant");
        }

        var shop = Shop.builder()
                .merchant(merchant)
                .name(name)
                .address(address)
                .phone(phone)
                .lat(lat)
                .lon(lon)
                .build();

        return shops.save(shop);
    }
}
