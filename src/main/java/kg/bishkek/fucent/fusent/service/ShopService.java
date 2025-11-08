package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.ShopDtos.*;

import java.util.UUID;

public interface ShopService {
    ShopResponse createShop(CreateShopRequest request);
    ShopResponse getShopById(UUID id);
}
