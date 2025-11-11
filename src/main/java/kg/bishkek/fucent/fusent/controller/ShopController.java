package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.ShopDtos.*;
import kg.bishkek.fucent.fusent.service.ShopService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/shops")
@RequiredArgsConstructor
@Tag(name = "Shops", description = "Shop browsing and search")
public class ShopController {

    private final ShopService shopService;

    @Operation(summary = "Create a new shop")
    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ShopResponse> createShop(@Valid @RequestBody CreateShopRequest request) {
        ShopResponse response = shopService.createShop(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @Operation(summary = "Get all shops with pagination")
    @GetMapping
    public ResponseEntity<Page<ShopResponse>> getAllShops(Pageable pageable) {
        return ResponseEntity.ok(shopService.getAllShops(pageable));
    }

    @Operation(summary = "Get shop by ID")
    @GetMapping("/{id}")
    public ResponseEntity<ShopResponse> getShopById(@PathVariable UUID id) {
        try {
            ShopResponse shop = shopService.getShopById(id);
            return ResponseEntity.ok(shop);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(summary = "Get shops by seller user ID")
    @GetMapping("/seller/{sellerId}")
    public ResponseEntity<List<ShopResponse>> getShopsBySeller(@PathVariable UUID sellerId) {
        List<ShopResponse> shops = shopService.getShopsBySeller(sellerId);
        return ResponseEntity.ok(shops);
    }

    @Operation(summary = "Search shops by name")
    @GetMapping("/search")
    public ResponseEntity<Page<ShopResponse>> searchShops(
            @RequestParam String query,
            Pageable pageable) {
        return ResponseEntity.ok(shopService.searchShops(query, pageable));
    }
}
