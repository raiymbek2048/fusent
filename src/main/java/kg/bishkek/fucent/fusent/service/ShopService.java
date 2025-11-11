package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.ShopDtos.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface ShopService {
    ShopResponse createShop(CreateShopRequest request);
    ShopResponse getShopById(UUID id);
    Page<ShopResponse> getAllShops(Pageable pageable);
    Page<ShopResponse> searchShops(String query, Pageable pageable);
    List<ShopResponse> getShopsBySeller(UUID sellerId);
    ShopResponse updateShop(UUID id, UpdateShopRequest request);
    void deleteShop(UUID id);
}
